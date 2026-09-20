import Foundation

func bidContext(_ game: GameState, score: GameScore = GameScore()) -> AIBiddingContext {
    let seat = game.currentBiddingSeat!
    return AIBiddingContext(auction: BidRecommendationContext(seat: seat,
        hand: game.players.first { $0.seat == seat }!.hand, partnerSeat: seat.partnerSeat,
        currentHighestBidValue: game.highestBidValue, currentHighestBidder: game.highestBidSeat,
        priorBidStates: game.bids), matchScore: score)
}

func bidRequest(_ context: AIBiddingContext, skill: AISkill) -> AIBidRequest {
    AIBidRequest(id: UUID(), revision: UUID(), context: context, skill: skill,
        baseline: AutomatedBidRecommender().recommendation(for: context.auction), useSkillPolicy: true)
}

func applyBid(_ result: BidRecommendation, to game: GameState) -> GameState {
    let service = BiddingService(bidRecommender: PreparedBidRecommender(prepared: result))
    return game.currentBiddingSeat == .south
        ? service.submitSouthBid(result.bid, selectedTarneebSuit: result.preferredTarneebSuit, in: game)
        : service.resolveNextSimulatedBid(in: game)
}

func profileBidding() {
    for samples in [8, 16, 32] {
        var times: [Double] = [], fallbacks = 0, searched = 0
        for seed in 30000..<30032 {
            var game = benchmarkDeal(seed: UInt64(seed))
            for turn in 0..<64 {
                guard game.currentBiddingSeat != nil else { break }
                let context = bidContext(game)
                let start = ProcessInfo.processInfo.systemUptime
                let result = ExpertBidPolicy.select(context, seed: UInt64(seed * 100 + turn),
                    limits: AIBidSearchLimits(samples: samples, seconds: 2))
                times.append((ProcessInfo.processInfo.systemUptime - start) * 1000)
                if result.fallback { fallbacks += 1 }
                if result.samples > 0 { searched += 1 }
                game = applyBid(result.recommendation, to: game)
            }
        }
        times.sort()
        print("samples=\(samples) n=\(times.count) searched=\(searched) medianMS=\(times[times.count/2]) p95MS=\(times[Int(Double(times.count-1)*0.95)]) maxMS=\(times.last!) fallbacks=\(fallbacks)")
    }
}

func runBiddingBenchmark(candidate: AISkill, reference: AISkill, firstSeed: Int, count: Int) {
    var clusters: [Double] = [], latency: [AISkill: [Double]] = [:]
    var fallbacks: [AISkill: Int] = [:], contracts: [AISkill: Int] = [:], made: [AISkill: Int] = [:]
    var defenses: [AISkill: Int] = [:], defeated: [AISkill: Int] = [:]
    var allPass = 0, rounds = 0, wins = 0, ties = 0, losses = 0
    for seed in firstSeed..<(firstSeed+count) {
        var differences: [Double] = []
        for rotation in 0..<4 {
            let initial = benchmarkDeal(seed: UInt64(seed), rotation: rotation, dealer: Seat.dealOrder[rotation])
            var pair = 0.0
            for team in Team.allCases {
                var game = initial
                for turn in 0..<64 {
                    guard game.currentBiddingSeat != nil else { break }
                    let context = bidContext(game)
                    let skill = context.team == team ? candidate : reference
                    // Independent search random stream, not the deal seed or deck order.
                    let searchSeed = UInt64(seed) &* 0x9e3779b97f4a7c15 &+ UInt64(rotation*100+turn)
                    let start = ProcessInfo.processInfo.systemUptime
                    let request = bidRequest(context, skill: skill)
                    let result = AIBiddingEngine.select(request, seed: searchSeed)
                    latency[skill, default: []].append((ProcessInfo.processInfo.systemUptime-start)*1000)
                    if result.fallback { fallbacks[skill, default: 0] += 1 }
                    // The frozen bidder may propose a too-low bid; the unchanged
                    // service converts it to Pass. Higher policies emit legal values.
                    require(skill == .standard || context.legalValues.contains(result.recommendation.bid), "legal benchmark bid")
                    let next = applyBid(result.recommendation, to: game)
                    require(next != game, "auction progresses")
                    game = next
                }
                require(game.currentBiddingSeat == nil, "bounded auction completes")
                rounds += 1
                guard game.highestBidValue != nil else { allPass += 1; continue }
                let round = benchmarkRound(game.startingTrickPlayIfReady(), candidate: .advanced,
                    reference: .advanced, candidateTeam: team, seed: 0, limits: AISearchLimits())
                pair += Double(round.score.scoreDelta(for: team)-round.score.scoreDelta(for: team.opponent))/2
                let declarer = round.score.declaringTeam == team ? candidate : reference
                let defender = round.score.declaringTeam == team ? reference : candidate
                contracts[declarer, default: 0] += 1
                defenses[defender, default: 0] += 1
                if round.score.declaringTricks >= round.score.bid { made[declarer, default: 0] += 1 }
                else { defeated[defender, default: 0] += 1 }
            }
            differences.append(pair)
            if pair > 0 { wins += 1 } else if pair < 0 { losses += 1 } else { ties += 1 }
        }
        clusters.append(differences.reduce(0,+)/4)
        if (seed-firstSeed+1)%32 == 0 {
            FileHandle.standardError.write(Data("bidding \(candidate.rawValue)-\(reference.rawValue): \(seed-firstSeed+1)/\(count) decks\n".utf8))
        }
    }
    let n = Double(clusters.count), mean = clusters.reduce(0,+)/Double(clusters.count)
    let variance = clusters.reduce(0) { $0+pow($1-mean,2) } / max(1,n-1)
    let interval = 1.96*sqrt(variance/n)
    var metrics: [String: Any] = [:]
    for skill in [candidate, reference] {
        let times = (latency[skill] ?? []).sorted()
        metrics[skill.rawValue] = ["decisions": times.count, "fallbacks": fallbacks[skill] ?? 0,
            "latencyMedianMS": times.isEmpty ? 0 : times[times.count/2],
            "latencyP95MS": times.isEmpty ? 0 : times[Int(Double(times.count-1)*0.95)],
            "latencyMaxMS": times.last ?? 0, "contracts": contracts[skill] ?? 0,
            "contractsMade": made[skill] ?? 0, "defenses": defenses[skill] ?? 0,
            "contractsDefeated": defeated[skill] ?? 0]
    }
    let report: [String: Any] = ["scope": "bidding; Advanced card play for all seats",
        "candidate": candidate.rawValue, "reference": reference.rawValue, "firstSeed": firstSeed,
        "requestedDecks": count, "scoredDeckClusters": clusters.count, "rounds": rounds,
        "allPassRounds": allPass, "pairWins": wins, "pairTies": ties, "pairLosses": losses,
        "meanPairedScoreDifference": mean, "ci95": [mean-interval,mean+interval],
        "samples": AIBidSearchLimits().samples, "budgetSeconds": AIBidSearchLimits().seconds, "metrics": metrics]
    print(String(decoding: try! JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted,.sortedKeys]), as: UTF8.self))
}
