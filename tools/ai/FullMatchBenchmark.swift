import Foundation

private func matchHash(_ tokens: [String]) -> UInt64 {
    tokens.joined(separator: ":").utf8.reduce(UInt64(14695981039346656037)) { ($0 ^ UInt64($1)) &* 1099511628211 }
}

func matchBidSeed(_ c: AIBiddingContext) -> UInt64 {
    let a = c.auction
    return matchHash(a.hand.map(\.id).sorted() + [a.seat.rawValue,
        a.currentHighestBidder?.rawValue ?? "none", a.currentHighestBidValue?.rawValue ?? "none",
        String(c.matchScore.northSouth), String(c.matchScore.eastWest)]
        + Seat.dealOrder.map { $0.rawValue + (a.priorBidStates[$0]?.displayLabel ?? "missing") })
}

func matchCardSeed(_ c: AIDecisionContext) -> UInt64 {
    matchHash([String(expertIntegrationSeed(c)), c.trick.declarerSeat.rawValue,
               String(c.matchScore.northSouth), String(c.matchScore.eastWest)])
}

struct MatchTiming: Codable {
    let decisions: Int
    let fallbacks: Int
    let medianMS: Double
    let p95MS: Double
    let maxMS: Double
}

final class MatchMetricAccumulator {
    var bidTimes: [Double] = [], cardTimes: [Double] = []
    var bidFallbacks = 0, cardFallbacks = 0
    var contracts = 0, made = 0, defenses = 0, defeated = 0
    var nonzeroScoreBids = 0, nonzeroScorePlays = 0
    func timing(_ values: [Double], _ fallbacks: Int) -> MatchTiming {
        let sorted = values.sorted()
        func percentile(_ p: Double) -> Double { sorted.isEmpty ? 0 : sorted[Int(Double(sorted.count-1)*p)] }
        return MatchTiming(decisions: sorted.count, fallbacks: fallbacks, medianMS: percentile(0.5),
                           p95MS: percentile(0.95), maxMS: sorted.last ?? 0)
    }
    var report: MatchMetrics {
        MatchMetrics(bidding: timing(bidTimes,bidFallbacks), cards: timing(cardTimes,cardFallbacks),
                     contracts: contracts, made: made, defenses: defenses, defeated: defeated,
                     nonzeroScoreBids: nonzeroScoreBids, nonzeroScorePlays: nonzeroScorePlays)
    }
}

struct MatchMetrics: Codable {
    let bidding: MatchTiming
    let cards: MatchTiming
    let contracts: Int
    let made: Int
    let defenses: Int
    let defeated: Int
    let nonzeroScoreBids: Int
    let nonzeroScorePlays: Int
}

struct FullMatchRecord: Codable, Equatable {
    let stream: Int
    let rotation: Int
    let candidateTeam: String
    let candidateWon: Bool?
    let candidatePoints: Int
    let referencePoints: Int
    let deals: Int
    let playedHands: Int
    let allPass: Int
    let nextDealer: String
}

func simulateFullMatch(stream: Int, rotation: Int, candidateTeam: Team,
                       candidate: AISkill, reference: AISkill, metrics: [MatchMetricAccumulator],
                       maxDeals: Int = 256, initialScore: GameScore = GameScore(), forcePass: Bool = false,
                       cardLimits: AISearchLimits = AISearchLimits(),
                       bidLimits: AIBidSearchLimits = AIBidSearchLimits(),
                       candidateBidding: AISkill? = nil) -> FullMatchRecord {
    var rng = AISeededGenerator(state: UInt64(stream)), score = initialScore
    var dealer = Seat.dealOrder[rotation], deals = 0, hands = 0, allPass = 0
    let service = TrickPlayService()
    while score.winnerTeam == nil && deals < maxDeals {
        var game = benchmarkDeal(seed: rng.next(), rotation: rotation, dealer: dealer)
        require(game.dealerSeat == dealer, "match dealer retained")
        deals += 1
        for _ in 0..<64 {
            guard game.currentBiddingSeat != nil else { break }
            let c = bidContext(game, score: score), index = c.team == candidateTeam ? 0 : 1
            let skill = index == 0 ? (candidateBidding ?? candidate) : reference
            let start = ProcessInfo.processInfo.systemUptime
            let result = forcePass ? AIBidResult(recommendation: BidRecommendation(bid: .pass), samples: 0, fallback: false, cancelled: false)
                : AIBiddingEngine.select(bidRequest(c,skill:skill),seed:matchBidSeed(c),limits:bidLimits)
            metrics[index].bidTimes.append((ProcessInfo.processInfo.systemUptime-start)*1000)
            if result.fallback { metrics[index].bidFallbacks += 1 }
            if score != GameScore() { metrics[index].nonzeroScoreBids += 1 }
            require(!result.cancelled && (skill == .standard || c.legalValues.contains(result.recommendation.bid)), "match bid legal/not cancelled")
            // Original Standard recommendations are filtered by the unchanged service.
            let next = applyBid(result.recommendation,to:game)
            require(next != game, "match auction progresses")
            game = next
        }
        require(game.currentBiddingSeat == nil, "match auction bounded")
        dealer = dealer.nextCounterclockwiseDealer
        guard game.highestBidValue != nil else {
            require(game.biddingCompletionOutcome == .allPassRedeal, "match redeal is all pass")
            allPass += 1
            continue
        }
        game = game.startingTrickPlayIfReady()
        var plays = 0
        while game.phase != .handComplete {
            if game.isCurrentTrickComplete { game = service.clearCompletedTrickIfNeeded(in:game); continue }
            let c = service.decisionContext(in:game,score:score)!, index = c.team == candidateTeam ? 0 : 1
            let start = ProcessInfo.processInfo.systemUptime
            let result = AIDecisionEngine.select(c,skill:index == 0 ? candidate : reference,seed:matchCardSeed(c),limits:cardLimits)
            metrics[index].cardTimes.append((ProcessInfo.processInfo.systemUptime-start)*1000)
            if result.fallback { metrics[index].cardFallbacks += 1 }
            if score != GameScore() { metrics[index].nonzeroScorePlays += 1 }
            require(!result.cancelled && result.card != nil && c.legalCards.contains(result.card!), "match card legal/not cancelled")
            let next = c.seat == .south ? service.playSouthCard(result.card!,in:game)
                : service.playSimulatedCard(result.card!,for:c.seat,in:game)
            require(next != game, "match card progresses")
            game = next
            plays += 1
            require(plays <= 52, "match hand bounded")
        }
        require(plays == 52 && Set(game.trickPlayState!.playedCards.map(\.card)).count == 52
            && game.players.allSatisfy { $0.hand.isEmpty }, "match card conservation")
        let result = TarneebScoringService().scoreRound(in:game)!
        let declarer = result.declaringTeam == candidateTeam ? 0 : 1
        metrics[declarer].contracts += 1; metrics[1-declarer].defenses += 1
        if result.declaringTricks >= result.bid { metrics[declarer].made += 1 }
        else { metrics[1-declarer].defeated += 1 }
        score.apply(result)
        hands += 1
    }
    require(deals == hands+allPass, "match deal accounting")
    return FullMatchRecord(stream:stream,rotation:rotation,candidateTeam:candidateTeam.rawValue,
        candidateWon:score.winnerTeam.map { $0 == candidateTeam }, candidatePoints:score.points(for:candidateTeam),
        referencePoints:score.points(for:candidateTeam.opponent),deals:deals,playedHands:hands,allPass:allPass,nextDealer:dealer.rawValue)
}

struct FullMatchEvaluation: Codable {
    let protocolID: String
    let candidate: AISkill
    let reference: AISkill
    let firstStream: Int
    let streams: Int
    let matches: [FullMatchRecord]
    let candidateMetrics: MatchMetrics
    let referenceMetrics: MatchMetrics
    let candidateWins: Int
    let referenceWins: Int
    let unresolved: Int
    let streamWinLower: [Double]
    let streamWinUpper: [Double]
    let adjustedWinLowerInterval: AblationInterval
    let adjustedWinUpperInterval: AblationInterval
    let streamScoreMargins: [Double]
    let scoreMarginInterval95: AblationInterval
    let cardSamples: Int
    let cardMaxTricks: Int
    let cardBudgetSeconds: Double
    let bidSamples: Int
    let bidBudgetSeconds: Double
    let maxDeals: Int
    var candidateBidding: AISkill? = nil
}

func runFullMatchBenchmark(candidate: AISkill, reference: AISkill, candidateBidding: AISkill? = nil,
                           firstStream: Int = 200000, streamCount: Int = 256,
                           protocolID: String = "full-match-2026-09-19") {
    require(candidate != reference || candidateBidding != nil, "distinct policies or explicit component control")
    let metrics = [MatchMetricAccumulator(),MatchMetricAccumulator()]
    var records: [FullMatchRecord] = [], lower: [Double] = [], upper: [Double] = [], margins: [Double] = []
    for stream in firstStream..<(firstStream+streamCount) {
        var cluster: [FullMatchRecord] = []
        for rotation in 0..<4 {
            for team in Team.allCases {
                cluster.append(simulateFullMatch(stream:stream,rotation:rotation,candidateTeam:team,
                                                 candidate:candidate,reference:reference,metrics:metrics,candidateBidding:candidateBidding))
            }
        }
        records += cluster
        lower.append(Double(cluster.filter { $0.candidateWon == true }.count)/8)
        upper.append(Double(cluster.filter { $0.candidateWon != false }.count)/8)
        margins.append(cluster.reduce(0.0) { $0+Double($1.candidatePoints-$1.referencePoints) }/8)
        FileHandle.standardError.write(Data("Full match bid=\((candidateBidding ?? candidate).rawValue) play=\(candidate.rawValue) vs \(reference.rawValue): \(stream-firstStream+1)/\(streamCount) streams\n".utf8))
    }
    let cards = AISearchLimits(), bids = AIBidSearchLimits()
    printAblationJSON(FullMatchEvaluation(protocolID:protocolID,candidate:candidate,reference:reference,
        firstStream:firstStream,streams:streamCount,matches:records,candidateMetrics:metrics[0].report,referenceMetrics:metrics[1].report,
        candidateWins:records.filter { $0.candidateWon == true }.count,referenceWins:records.filter { $0.candidateWon == false }.count,
        unresolved:records.filter { $0.candidateWon == nil }.count,streamWinLower:lower,streamWinUpper:upper,
        adjustedWinLowerInterval:ablationInterval(lower,z:2.39397979981851),
        adjustedWinUpperInterval:ablationInterval(upper,z:2.39397979981851),streamScoreMargins:margins,
        scoreMarginInterval95:ablationInterval(margins),cardSamples:cards.samples,cardMaxTricks:cards.maxTricks,
        cardBudgetSeconds:cards.seconds,bidSamples:bids.samples,bidBudgetSeconds:bids.seconds,maxDeals:256,candidateBidding:candidateBidding))
}

func verifyFullMatchHarness() {
    func metrics() -> [MatchMetricAccumulator] { [MatchMetricAccumulator(),MatchMetricAccumulator()] }
    let a = simulateFullMatch(stream:120000,rotation:0,candidateTeam:.teamA,candidate:.standard,reference:.standard,metrics:metrics())
    let b = simulateFullMatch(stream:120000,rotation:0,candidateTeam:.teamA,candidate:.standard,reference:.standard,metrics:metrics())
    require(a == b && a.candidateWon != nil && max(a.candidatePoints,a.referencePoints) >= 31, "full match deterministic/terminal")
    let stopped = simulateFullMatch(stream:120001,rotation:1,candidateTeam:.teamA,candidate:.advanced,reference:.standard,
        metrics:metrics(),initialScore:GameScore(northSouth:31))
    require(stopped.deals == 0 && stopped.candidateWon == true, "already won match does not deal")
    let passed = simulateFullMatch(stream:120002,rotation:0,candidateTeam:.teamA,candidate:.advanced,reference:.standard,
        metrics:metrics(),maxDeals:2,forcePass:true)
    require(passed.allPass == 2 && passed.playedHands == 0 && passed.candidateWon == nil
        && passed.candidatePoints == 0 && passed.referencePoints == 0 && passed.nextDealer == Seat.north.rawValue, "all pass advances dealer without score; cap unresolved")
    let m = metrics()
    let fallback = simulateFullMatch(stream:120003,rotation:3,candidateTeam:.teamB,candidate:.expert,reference:.advanced,
        metrics:m,cardLimits:AISearchLimits(seconds:0),bidLimits:AIBidSearchLimits(seconds:0))
    require(fallback.candidateWon != nil && m[0].bidFallbacks > 0 && m[0].cardFallbacks > 0
        && m[0].nonzeroScoreBids > 0 && m[0].nonzeroScorePlays > 0, "full match fallback and score context")
    let c = bidContext(benchmarkDeal(seed:120003))
    let reordered = AIBiddingContext(auction:BidRecommendationContext(seat:c.auction.seat,hand:c.auction.hand.reversed(),
        partnerSeat:c.auction.partnerSeat,currentHighestBidValue:c.auction.currentHighestBidValue,
        currentHighestBidder:c.auction.currentHighestBidder,priorBidStates:c.auction.priorBidStates),matchScore:c.matchScore)
    require(matchBidSeed(c) == matchBidSeed(reordered), "public bid seed hand-order invariant")
    require(matchBidSeed(c) != matchBidSeed(AIBiddingContext(auction:c.auction,matchScore:GameScore(northSouth:30))), "public bid seed includes score")
    let play = TrickPlayService().decisionContext(in:benchmarkBid(benchmarkDeal(seed:120000))!,score:GameScore())!
    let reorderedPlay = AIDecisionContext(seat:play.seat,ownHand:play.ownHand.reversed(),trick:play.trick,contract:play.contract,matchScore:play.matchScore)
    require(matchCardSeed(play) == matchCardSeed(reorderedPlay), "public card seed hand-order invariant")
    require(matchCardSeed(play) != matchCardSeed(AIDecisionContext(seat:play.seat,ownHand:play.ownHand,trick:play.trick,
        contract:play.contract,matchScore:GameScore(northSouth:30))), "public card seed includes score")
    print("Full-match harness: deterministic replay, terminal score, all-pass/dealer/cap, fallback, score context and public seeds passed")
}
