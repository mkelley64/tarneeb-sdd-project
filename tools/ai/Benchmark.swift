import Foundation

func benchmarkDeal(seed: UInt64, rotation: Int = 0, dealer: Seat = .south) -> GameState {
    var rng = AISeededGenerator(state: seed)
    let shuffled = DeckFactory.makeCanonicalDeck().shuffled(using: &rng)
    let rotated = (0..<52).map { shuffled[($0 + rotation * 13) % 52] }
    return DealService(shuffler: CardShuffler { _ in rotated }, handLogger: HandLogger { _ in }).deal(dealerSeat: dealer)!
}

func benchmarkBid(_ initial: GameState) -> GameState? {
    var state = initial
    let service = BiddingService(bidRecommender: AutomatedBidRecommender())
    for _ in 0..<64 {
        guard let seat = state.currentBiddingSeat else { break }
        if seat == .south {
            let hand = state.players.first { $0.seat == seat }!.hand
            let recommendation = AutomatedBidRecommender().recommendation(for: BidRecommendationContext(
                seat: seat, hand: hand, partnerSeat: seat.partnerSeat, currentHighestBidValue: state.highestBidValue,
                currentHighestBidder: state.highestBidSeat, priorBidStates: state.bids))
            state = service.submitSouthBid(recommendation.bid, selectedTarneebSuit: recommendation.preferredTarneebSuit, in: state)
        } else { state = service.resolveNextSimulatedBid(in: state) }
    }
    guard state.highestBidValue != nil else { return nil }
    return state.startingTrickPlayIfReady()
}

struct BenchmarkRound {
    let score: RoundScoreResult
    let latency: [AISkill: [Double]]
    let fallbacks: [AISkill: Int]
}

func benchmarkRound(_ initial: GameState, candidate: AISkill, reference: AISkill, candidateTeam: Team,
                    seed: UInt64, limits: AISearchLimits) -> BenchmarkRound {
    var game = initial
    var times: [AISkill: [Double]] = [:]
    var fallbacks: [AISkill: Int] = [:]
    let service = TrickPlayService()
    var turn: UInt64 = 0
    while game.phase != .handComplete {
        if game.isCurrentTrickComplete {
            game = service.clearCompletedTrickIfNeeded(in: game)
            continue
        }
        let context = service.decisionContext(in: game, score: GameScore())!
        let skill = context.team == candidateTeam ? candidate : reference
        let start = ProcessInfo.processInfo.systemUptime
        let result: AIDecisionResult
        if skill == .standard {
            result = AIDecisionResult(card: FrozenStandard.select(from: context.legalCards, for: context.seat,
                currentTrick: context.trick.currentTrick, tarneebSuit: context.trick.tarneebSuit,
                ownHand: context.ownHand, completedTricks: context.trick.completedTricks), samples: 0, fallback: false, cancelled: false)
        } else { result = AIDecisionEngine.select(context, skill: skill, seed: seed &+ turn, limits: limits) }
        times[skill, default: []].append((ProcessInfo.processInfo.systemUptime - start) * 1000)
        if result.fallback { fallbacks[skill, default: 0] += 1 }
        let card = result.card!
        require(context.legalCards.contains(card), "benchmark illegal decision")
        game = context.seat == .south ? service.playSouthCard(card, in: game)
            : service.playSimulatedCard(card, for: context.seat, in: game)
        turn += 1
    }
    return BenchmarkRound(score: TarneebScoringService().scoreRound(in: game)!, latency: times, fallbacks: fallbacks)
}

func runBenchmark(candidate: AISkill, reference: AISkill, firstSeed: Int, count: Int,
                  limits: AISearchLimits) {
    var clusters: [Double] = []
    var latency: [AISkill: [Double]] = [:]
    var fallback: [AISkill: Int] = [:]
    var contracts: [AISkill: Int] = [:]
    var made: [AISkill: Int] = [:]
    var defenses: [AISkill: Int] = [:]
    var defeated: [AISkill: Int] = [:]
    var skipped = 0
    var rounds = 0
    var pairWins = 0, pairTies = 0, pairLosses = 0
    for seed in firstSeed..<(firstSeed + count) {
        var differences: [Double] = []
        for rotation in 0..<4 {
            // Rotating the dealer with the hands balances physical seats/dealers while
            // preserving bidding conditions. Partnership swaps use the identical contract.
            let deal = benchmarkDeal(seed: UInt64(seed), rotation: rotation, dealer: Seat.dealOrder[rotation])
            guard let initial = benchmarkBid(deal) else { skipped += 1; continue }
            var pair = 0.0
            for team in Team.allCases {
                let round = benchmarkRound(initial, candidate: candidate, reference: reference, candidateTeam: team,
                    seed: UInt64(seed) &* 1000 &+ UInt64(rotation * 100), limits: limits)
                rounds += 1
                pair += Double(round.score.scoreDelta(for: team) - round.score.scoreDelta(for: team.opponent)) / 2
                let declaringSkill = round.score.declaringTeam == team ? candidate : reference
                let defendingSkill = round.score.declaringTeam == team ? reference : candidate
                contracts[declaringSkill, default: 0] += 1
                defenses[defendingSkill, default: 0] += 1
                if round.score.declaringTricks >= round.score.bid { made[declaringSkill, default: 0] += 1 }
                else { defeated[defendingSkill, default: 0] += 1 }
                for (skill, values) in round.latency { latency[skill, default: []] += values }
                for (skill, value) in round.fallbacks { fallback[skill, default: 0] += value }
            }
            differences.append(pair)
            if pair > 0 { pairWins += 1 } else if pair < 0 { pairLosses += 1 } else { pairTies += 1 }
        }
        if !differences.isEmpty { clusters.append(differences.reduce(0,+) / Double(differences.count)) }
        if (seed - firstSeed + 1) % 32 == 0 {
            FileHandle.standardError.write(Data("\(candidate.rawValue)-\(reference.rawValue): \(seed - firstSeed + 1)/\(count) decks\n".utf8))
        }
    }
    let n = Double(clusters.count)
    let mean = clusters.reduce(0,+) / max(1,n)
    let variance = clusters.reduce(0) { $0 + pow($1 - mean, 2) } / max(1,n-1)
    let interval = 1.96 * sqrt(variance / max(1,n))
    var metrics: [String: Any] = [:]
    for skill in [candidate, reference] {
        let values = (latency[skill] ?? []).sorted()
        func percentile(_ p: Double) -> Double { values.isEmpty ? 0 : values[min(values.count-1, Int(Double(values.count-1)*p))] }
        metrics[skill.rawValue] = ["decisions": values.count, "latencyMedianMS": percentile(0.5),
            "latencyP95MS": percentile(0.95), "latencyMaxMS": values.last ?? 0,
            "fallbacks": fallback[skill] ?? 0, "contracts": contracts[skill] ?? 0,
            "contractsMade": made[skill] ?? 0, "defenses": defenses[skill] ?? 0,
            "contractsDefeated": defeated[skill] ?? 0]
    }
    let report: [String: Any] = ["candidate": candidate.rawValue, "reference": reference.rawValue,
        "firstSeed": firstSeed, "requestedDecks": count, "scoredDeckClusters": clusters.count,
        "allPassOrientations": skipped, "rounds": rounds, "pairWins": pairWins, "pairTies": pairTies,
        "pairLosses": pairLosses, "meanPairedScoreDifference": mean, "ci95": [mean-interval, mean+interval],
        "samples": limits.samples, "maxTricks": limits.maxTricks, "budgetSeconds": limits.seconds, "metrics": metrics]
    let data = try! JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys])
    print(String(decoding: data, as: UTF8.self))
}

func profileSearch() {
    for samples in [4, 8, 12] {
        for depth in [3, 13] {
            var times: [Double] = []
            var fallback = 0
            for seed in 10000..<10016 {
                guard let game = benchmarkBid(benchmarkDeal(seed: UInt64(seed))),
                      let context = TrickPlayService().decisionContext(in: game, score: GameScore()) else { continue }
                let start = ProcessInfo.processInfo.systemUptime
                let result = ExpertCardPolicy.select(context, seed: UInt64(seed),
                    limits: AISearchLimits(samples: samples, maxTricks: depth, seconds: 2))
                times.append((ProcessInfo.processInfo.systemUptime-start)*1000)
                if result.fallback { fallback += 1 }
            }
            times.sort()
            print("samples=\(samples) depth=\(depth) n=\(times.count) medianMS=\(times[times.count/2]) maxMS=\(times.last!) fallbacks=\(fallback)")
        }
    }
}
