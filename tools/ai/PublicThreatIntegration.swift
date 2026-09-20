import Foundation

// Frozen September 18 evaluation: production policies, not the rejected trial below.
func evaluateCurrentExpertAdvanced() {
    var fallbacks = 0
    let limits = AISearchLimits()
    let result = evaluateAblation(nil, firstSeed: 100000, count: 2048, candidatePolicy: { c in
        let decision = AIDecisionEngine.select(c, skill: .expert, seed: expertIntegrationSeed(c), limits: limits)
        require(!decision.cancelled, "evaluation has no cancellation request")
        if decision.fallback { fallbacks += 1 }
        return decision.card
    }, referencePolicy: { c in
        AIDecisionEngine.select(c, skill: .advanced, seed: expertIntegrationSeed(c)).card
    }, searchFallbacks: { (fallbacks, 0) }, progress: { completed in
        if completed % 32 == 0 {
            FileHandle.standardError.write(Data("Current Expert–Advanced: \(completed)/2048 decks\n".utf8))
        }
    })
    let report: [String: Any] = [
        "protocol": "expert-advanced-evaluation-2026-09-18",
        "candidate": "production Expert", "reference": "revised production Advanced",
        "bidding": "fixed Standard", "samples": limits.samples, "maxTricks": limits.maxTricks,
        "budgetSeconds": limits.seconds,
        "evaluation": try! JSONSerialization.jsonObject(with: JSONEncoder().encode(result))
    ]
    print(String(decoding: try! JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys]), as: UTF8.self))
}

func expertIntegrationSeed(_ c: AIDecisionContext) -> UInt64 {
    let tokens = c.ownHand.map(\.id).sorted() + c.trick.playedCards.map { $0.seat.rawValue + $0.card.id }
        + [c.seat.rawValue, c.trick.tarneebSuit.rawValue, String(c.contract)]
    return tokens.joined(separator: ":").utf8.reduce(UInt64(14695981039346656037)) { ($0 ^ UInt64($1)) &* 1099511628211 }
}

func integrateExpertCards() {
    var revisedFallbacks = 0, originalFallbacks = 0
    let result = evaluateAblation(nil, firstSeed: 94000, count: 512, candidatePolicy: { c in
        let result = TrialPublicThreatExpertCardPolicy.select(c, seed: expertIntegrationSeed(c))
        if result.fallback { revisedFallbacks += 1 }
        return result.card
    }, referencePolicy: { c in
        let result = FrozenExpertCardPolicy.select(c, seed: expertIntegrationSeed(c))
        if result.fallback { originalFallbacks += 1 }
        return result.card
    }, searchFallbacks: { (revisedFallbacks, originalFallbacks) })
    printAblationJSON(result)
}

func integrateExpertBidding() {
    var clusterScores: [Double] = [], times = [[Double](),[Double]()]
    var metrics = [AblationMetrics(),AblationMetrics()]
    var rounds = 0, allPass = 0, wins = 0, ties = 0, losses = 0
    let service = TrickPlayService()
    for seed in 96000..<96512 {
        var pairs: [Double] = []
        for rotation in 0..<4 {
            let initial = benchmarkDeal(seed: UInt64(seed), rotation: rotation, dealer: Seat.dealOrder[rotation])
            var pair = 0.0
            for team in Team.allCases {
                var game = initial
                for turn in 0..<64 {
                    guard game.currentBiddingSeat != nil else { break }
                    let c = bidContext(game), index = cTeamIndex(game: game, candidateTeam: team)
                    let searchSeed = UInt64(seed) &* 0x9e3779b97f4a7c15 &+ UInt64(rotation*100+turn)
                    let start = ProcessInfo.processInfo.systemUptime
                    let result = index == 0 ? TrialPublicThreatExpertBidPolicy.select(c,seed:searchSeed) : FrozenExpertBidPolicy.select(c,seed:searchSeed)
                    times[index].append((ProcessInfo.processInfo.systemUptime-start)*1000)
                    metrics[index].decisions += 1
                    if result.fallback { metrics[index].fallbacks += 1 }
                    require(c.legalValues.contains(result.recommendation.bid), "Expert integration legal bid")
                    let next = applyBid(result.recommendation, to: game)
                    require(next != game, "Expert auction progresses")
                    game = next
                }
                require(game.currentBiddingSeat == nil, "Expert auction terminates")
                rounds += 1
                guard game.highestBidValue != nil else { allPass += 1; continue }
                game = game.startingTrickPlayIfReady()
                var plays = 0
                while game.phase != .handComplete {
                    if game.isCurrentTrickComplete { game = service.clearCompletedTrickIfNeeded(in: game); continue }
                    let c = service.decisionContext(in: game,score:GameScore())!
                    let card = FrozenAdvancedCardPolicy.select(c)!
                    require(c.legalCards.contains(card), "integration fixed card policy legal")
                    game = c.seat == .south ? service.playSouthCard(card,in:game) : service.playSimulatedCard(card,for:c.seat,in:game)
                    plays += 1
                    require(plays <= 52, "integration hand terminates")
                }
                require(plays == 52 && Set(game.trickPlayState!.playedCards.map(\.card)).count == 52, "integration conservation")
                let score = TarneebScoringService().scoreRound(in:game)!
                pair += Double(score.scoreDelta(for:team)-score.scoreDelta(for:team.opponent))/2
                let declaring = score.declaringTeam == team ? 0 : 1
                metrics[declaring].contracts += 1; metrics[1-declaring].defenses += 1
                if score.declaringTricks >= score.bid { metrics[declaring].made += 1 } else { metrics[1-declaring].defeated += 1 }
            }
            pairs.append(pair)
            if pair > 0 { wins += 1 } else if pair < 0 { losses += 1 } else { ties += 1 }
        }
        clusterScores.append(pairs.reduce(0,+)/4)
        if (seed-95999)%32 == 0 { FileHandle.standardError.write(Data("Expert bidding integration \(seed-95999)/512\n".utf8)) }
    }
    for i in 0..<2 {
        times[i].sort()
        metrics[i].medianMS = times[i][times[i].count/2]
        metrics[i].p95MS = times[i][Int(Double(times[i].count-1)*0.95)]
        metrics[i].maxMS = times[i].last!
    }
    let report: [String:Any] = ["candidate":"revised Expert bidding", "reference":"original Expert bidding",
        "fixedCardPlay":"frozen original Advanced", "firstSeed":96000,"decks":512,"rounds":rounds,
        "allPassRounds":allPass,"pairWins":wins,"pairTies":ties,"pairLosses":losses,
        "clusterScores":clusterScores,
        "metrics":try! JSONSerialization.jsonObject(with:JSONEncoder().encode(metrics)),
        "interval95":try! JSONSerialization.jsonObject(with:JSONEncoder().encode(ablationInterval(clusterScores)))]
    print(String(decoding:try! JSONSerialization.data(withJSONObject:report,options:[.prettyPrinted,.sortedKeys]),as:UTF8.self))
}

private func cTeamIndex(game: GameState, candidateTeam: Team) -> Int {
    Team.forSeat(game.currentBiddingSeat!) == candidateTeam ? 0 : 1
}
