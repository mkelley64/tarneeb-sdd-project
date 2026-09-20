import Foundation

struct AblationInterval: Codable {
    let mean: Double
    let lower: Double
    let upper: Double
    let clusters: Int
}

func ablationInterval(_ values: [Double], z: Double = 1.96) -> AblationInterval {
    let n = Double(values.count), mean = values.reduce(0,+)/max(1,n)
    let variance = values.reduce(0) { $0 + pow($1-mean,2) }/max(1,n-1)
    let half = z*sqrt(variance/max(1,n))
    return AblationInterval(mean: mean, lower: mean-half, upper: mean+half, clusters: values.count)
}

struct AblationMetrics: Codable {
    var decisions = 0, disagreements = 0, leadDisagreements = 0, followDisagreements = 0
    var contracts = 0, made = 0, defenses = 0, defeated = 0
    var medianMS = 0.0, p95MS = 0.0, maxMS = 0.0
    var fallbacks = 0
}

struct AblationEvaluation: Codable {
    let weights: AblationWeights?
    let referenceWeights: AblationWeights?
    let firstSeed: Int
    let requestedDecks: Int
    let clusterSeeds: [Int]
    let clusterScores: [Double]
    let interval95: AblationInterval
    let allPassOrientations: Int
    let rounds: Int
    let pairWins: Int
    let pairTies: Int
    let pairLosses: Int
    let candidate: AblationMetrics
    let reference: AblationMetrics
}

func frozenCard(_ c: AIDecisionContext) -> Card? {
    FrozenStandard.select(from: c.legalCards, for: c.seat, currentTrick: c.trick.currentTrick,
        tarneebSuit: c.trick.tarneebSuit, ownHand: c.ownHand, completedTricks: c.trick.completedTricks)
}

func evaluateAblation(_ weights: AblationWeights?, reference: AblationWeights? = nil,
                      firstSeed: Int, count: Int,
                      candidatePolicy: ((AIDecisionContext) -> Card?)? = nil,
                      referencePolicy: ((AIDecisionContext) -> Card?)? = nil,
                      searchFallbacks: (() -> (Int, Int))? = nil,
                      progress: ((Int) -> Void)? = nil) -> AblationEvaluation {
    var clusterSeeds: [Int] = [], clusterScores: [Double] = []
    var skipped = 0, rounds = 0, wins = 0, ties = 0, losses = 0
    var metrics = [AblationMetrics(), AblationMetrics()], times = [[Double](), [Double]()]
    let service = TrickPlayService()
    for seed in firstSeed..<(firstSeed+count) {
        var pairs: [Double] = []
        for rotation in 0..<4 {
            guard let initial = benchmarkBid(benchmarkDeal(seed: UInt64(seed), rotation: rotation,
                dealer: Seat.dealOrder[rotation])) else { skipped += 1; continue }
            var pair = 0.0
            for team in Team.allCases {
                var game = initial, plays = 0
                while game.phase != .handComplete {
                    if game.isCurrentTrickComplete { game = service.clearCompletedTrickIfNeeded(in: game); continue }
                    let c = service.decisionContext(in: game, score: GameScore())!
                    let index = c.team == team ? 0 : 1
                    let policy = index == 0 ? weights : reference
                    let custom = index == 0 ? candidatePolicy : referencePolicy
                    let start = ProcessInfo.processInfo.systemUptime
                    let card = custom.map { $0(c) } ?? (policy.map { AblationCardPolicy.select(c, weights: $0) } ?? frozenCard(c))
                    times[index].append((ProcessInfo.processInfo.systemUptime-start)*1000)
                    require(card != nil && c.legalCards.contains(card!), "ablation legal card")
                    if custom == nil && policy == .original { require(card == FrozenAdvancedCardPolicy.select(c), "all-one parity during evaluation") }
                    metrics[index].decisions += 1
                    if card != frozenCard(c) {
                        metrics[index].disagreements += 1
                        if c.trick.currentTrick.isEmpty { metrics[index].leadDisagreements += 1 }
                        else { metrics[index].followDisagreements += 1 }
                    }
                    game = c.seat == .south ? service.playSouthCard(card!, in: game)
                        : service.playSimulatedCard(card!, for: c.seat, in: game)
                    plays += 1
                    require(plays <= 52, "ablation bounded round")
                }
                let played = game.trickPlayState!.playedCards.map(\.card)
                require(plays == 52 && Set(played).count == 52 && game.players.allSatisfy { $0.hand.isEmpty }, "ablation conserves deck")
                let score = TarneebScoringService().scoreRound(in: game)!
                pair += Double(score.scoreDelta(for: team)-score.scoreDelta(for: team.opponent))/2
                let declaringIndex = score.declaringTeam == team ? 0 : 1
                metrics[declaringIndex].contracts += 1
                metrics[1-declaringIndex].defenses += 1
                if score.declaringTricks >= score.bid { metrics[declaringIndex].made += 1 }
                else { metrics[1-declaringIndex].defeated += 1 }
                rounds += 1
            }
            pairs.append(pair)
            if pair > 0 { wins += 1 } else if pair < 0 { losses += 1 } else { ties += 1 }
        }
        if !pairs.isEmpty { clusterSeeds.append(seed); clusterScores.append(pairs.reduce(0,+)/Double(pairs.count)) }
        progress?(seed-firstSeed+1)
    }
    for i in 0..<2 {
        times[i].sort()
        if !times[i].isEmpty {
            metrics[i].medianMS = times[i][times[i].count/2]
            metrics[i].p95MS = times[i][Int(Double(times[i].count-1)*0.95)]
            metrics[i].maxMS = times[i].last!
        }
    }
    if let counts = searchFallbacks?() { metrics[0].fallbacks = counts.0; metrics[1].fallbacks = counts.1 }
    return AblationEvaluation(weights: weights, referenceWeights: reference, firstSeed: firstSeed,
        requestedDecks: count, clusterSeeds: clusterSeeds, clusterScores: clusterScores,
        interval95: ablationInterval(clusterScores), allPassOrientations: skipped, rounds: rounds,
        pairWins: wins, pairTies: ties, pairLosses: losses, candidate: metrics[0], reference: metrics[1])
}

struct AblationContrast: Codable {
    let feature: AblationFeature
    let standaloneVersusStandard: AblationInterval
    let singletonMinusScaffold: AblationInterval
    let originalMinusLeaveOneOut: AblationInterval
}

struct AblationTraining: Codable {
    let protocolVersion: Int
    let featureOrder: [AblationFeature]
    let trainingFirstSeed: Int
    let validationFirstSeed: Int
    let decksPerPartition: Int
    let contrasts: [AblationContrast]
    let training: [AblationEvaluation]
    let validation: [AblationEvaluation]
    let finalists: [AblationWeights]
    let selected: AblationWeights
}

func printAblationJSON<T: Encodable>(_ value: T) {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted,.sortedKeys]
    print(String(decoding: try! encoder.encode(value), as: UTF8.self))
}

func trainAblation() {
    verifyAblation()
    var cache: [AblationWeights: AblationEvaluation] = [:]
    func evaluate(_ weights: AblationWeights) -> AblationEvaluation {
        if let value = cache[weights] { return value }
        let value = evaluateAblation(weights, firstSeed: 50000, count: 512)
        cache[weights] = value
        FileHandle.standardError.write(Data("train \(cache.count): \(weights.key) mean=\(value.interval95.mean)\n".utf8))
        return value
    }
    func better(_ lhs: AblationWeights, _ rhs: AblationWeights) -> Bool {
        let a = evaluate(lhs).interval95.mean, b = evaluate(rhs).interval95.mean
        return abs(a-b) > 1e-10 ? a > b : lhs.simpler(than: rhs)
    }
    let zero = evaluate(.zero), original = evaluate(.original)
    var contrasts: [AblationContrast] = []
    for feature in AblationFeature.allCases {
        var only = AblationWeights.zero, without = AblationWeights.original
        only[feature] = 1; without[feature] = 0
        let single = evaluate(only), removed = evaluate(without)
        require(single.clusterSeeds == zero.clusterSeeds && removed.clusterSeeds == original.clusterSeeds, "matched ablation clusters")
        contrasts.append(AblationContrast(feature: feature, standaloneVersusStandard: single.interval95,
            singletonMinusScaffold: ablationInterval(zip(single.clusterScores,zero.clusterScores).map(-)),
            originalMinusLeaveOneOut: ablationInterval(zip(original.clusterScores,removed.clusterScores).map(-))))
    }
    for start in [AblationWeights.zero, .original] {
        var current = start
        for _ in 0..<2 {
            for feature in AblationFeature.allCases {
                var best = current
                for value in [0.0,0.5,1.0,2.0] {
                    var trial = current; trial[feature] = value
                    if better(trial,best) { best = trial }
                }
                current = best
            }
        }
    }
    let finalists = Array(cache.keys.sorted(by: better).prefix(5))
    var validation: [AblationEvaluation] = []
    for weights in Array(Set(finalists + [.zero,.original])).sorted(by: { $0.simpler(than: $1) }) {
        let value = evaluateAblation(weights, firstSeed: 52000, count: 512)
        validation.append(value)
        FileHandle.standardError.write(Data("validation: \(weights.key) mean=\(value.interval95.mean)\n".utf8))
    }
    let selected = finalists.sorted { a, b in
        let lhs = validation.first { $0.weights == a }!.interval95.mean
        let rhs = validation.first { $0.weights == b }!.interval95.mean
        return abs(lhs-rhs) > 1e-10 ? lhs > rhs : a.simpler(than: b)
    }[0]
    printAblationJSON(AblationTraining(protocolVersion: 1, featureOrder: AblationFeature.allCases,
        trainingFirstSeed: 50000, validationFirstSeed: 52000, decksPerPartition: 512, contrasts: contrasts,
        training: cache.values.sorted { $0.weights!.key < $1.weights!.key }, validation: validation,
        finalists: finalists, selected: selected))
}

struct AblationHeldOut: Codable {
    let selected: AblationWeights
    let selectedVersusStandard: AblationEvaluation
    let originalVersusStandard: AblationEvaluation
    let selectedVersusOriginal: AblationEvaluation
    let selectedVersusStandardAdjusted975: AblationInterval
    let selectedVersusOriginalAdjusted975: AblationInterval
}

func evaluateFrozenAblation(path: String) throws {
    let frozen = try JSONDecoder().decode(AblationTraining.self, from: Data(contentsOf: URL(fileURLWithPath: path)))
    require(frozen.protocolVersion == 1 && frozen.trainingFirstSeed == 50000 && frozen.validationFirstSeed == 52000
        && frozen.decksPerPartition == 512 && frozen.featureOrder == AblationFeature.allCases, "frozen protocol metadata")
    require(frozen.selected.values.count == 8 && frozen.selected.values.allSatisfy { [0.0,0.5,1.0,2.0].contains($0) }
        && frozen.finalists.contains(frozen.selected), "frozen selected configuration")
    let selected = evaluateAblation(frozen.selected, firstSeed: 60000, count: 2048)
    FileHandle.standardError.write(Data("Held-out selected–Standard completed\n".utf8))
    let original = evaluateAblation(.original, firstSeed: 60000, count: 2048)
    FileHandle.standardError.write(Data("Held-out original–Standard completed\n".utf8))
    let headToHead = evaluateAblation(frozen.selected, reference: .original, firstSeed: 60000, count: 2048)
    printAblationJSON(AblationHeldOut(selected: frozen.selected, selectedVersusStandard: selected,
        originalVersusStandard: original, selectedVersusOriginal: headToHead,
        selectedVersusStandardAdjusted975: ablationInterval(selected.clusterScores,z: 2.241403),
        selectedVersusOriginalAdjusted975: ablationInterval(headToHead.clusterScores,z: 2.241403)))
}

func verifyAblation() {
    var parity = 0, switched = Set<AblationFeature>()
    let service = TrickPlayService()
    for seed in 70000..<70032 {
        guard var game = benchmarkBid(benchmarkDeal(seed: UInt64(seed))) else { continue }
        while game.phase != .handComplete {
            if game.isCurrentTrickComplete { game = service.clearCompletedTrickIfNeeded(in: game); continue }
            let c = service.decisionContext(in: game, score: GameScore())!
            let full = AblationCardPolicy.select(c, weights: .original)!
            require(full == FrozenAdvancedCardPolicy.select(c), "experimental all-one historical parity")
            require(frozenCard(c) == c.standard(), "frozen Standard parity")
            let reversed = AIDecisionContext(seat: c.seat, ownHand: c.ownHand.reversed(), trick: c.trick,
                contract: c.contract, matchScore: c.matchScore)
            for feature in AblationFeature.allCases {
                var weights = AblationWeights.original; weights[feature] = 0
                let card = AblationCardPolicy.select(c, weights: weights)!
                require(c.legalCards.contains(card), "switched feature legal")
                require(card == AblationCardPolicy.select(reversed, weights: weights), "hand order invariance")
                if full != card { switched.insert(feature) }
            }
            let hidden = game.players.filter { $0.seat != c.seat }.flatMap(\.hand).reversed()
            var pool = Array(hidden)
            let players = game.players.map { player -> Player in
                if player.seat == c.seat { return player }
                let hand = Array(pool.prefix(player.hand.count)); pool.removeFirst(player.hand.count)
                return Player(id: player.id, seat: player.seat, type: player.type, team: player.team, hand: hand)
            }
            let permuted = GameState(phase: game.phase, players: players, dealerSeat: game.dealerSeat,
                biddingState: game.biddingState, postBiddingSummary: game.postBiddingSummary, trickPlayState: game.trickPlayState)!
            let publicCopy = service.decisionContext(in: permuted, score: GameScore())!
            require(c == publicCopy && full == AblationCardPolicy.select(publicCopy, weights: .original), "hidden-hand permutation parity")
            game = c.seat == .south ? service.playSouthCard(full, in: game) : service.playSimulatedCard(full, for: c.seat, in: game)
            parity += 1
        }
    }
    let neutral = evaluateAblation(nil, firstSeed: 70000, count: 16)
    require(neutral.clusterScores.allSatisfy { $0 == 0 }, "paired Standard self-play neutrality")
    let repeatOne = evaluateAblation(.original, firstSeed: 70000, count: 8)
    let repeatTwo = evaluateAblation(.original, firstSeed: 70000, count: 8)
    require(repeatOne.clusterScores == repeatTwo.clusterScores, "reproducible ablation outcomes")
    FileHandle.standardError.write(Data("Ablation verification: \(parity) parity/legality/fairness positions; active switches \(switched.map(\.rawValue).sorted()); paired neutrality and replay passed\n".utf8))
}
