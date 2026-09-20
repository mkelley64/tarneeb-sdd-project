import Foundation

struct PublicThreatSettings: Codable, Equatable {
    let publicSurvival: Double
    let speculation: Double
    func select(_ c: AIDecisionContext) -> Card? {
        PublicThreatCardPolicy.select(c, publicSurvival: publicSurvival, speculation: speculation)
    }
}
struct PublicThreatTraining: Codable {
    let settings: [PublicThreatSettings]
    let results: [AblationEvaluation]
    let selected: PublicThreatSettings
}
struct PublicThreatHeldout: Codable {
    let selected: PublicThreatSettings
    let versusStandard: AblationEvaluation
    let versusOriginal: AblationEvaluation
    let standardAdjusted975: AblationInterval
    let originalAdjusted975: AblationInterval
}

func checkPublicThreat(_ settings: PublicThreatSettings) {
    func card(_ suit: Suit, _ rank: Rank) -> Card { Card(suit: suit, rank: rank) }
    let history = CompletedTrick(leaderSeat: .south, winnerSeat: .east, ledSuit: .clubs, playedCards: [
        PlayedCard(seat: .south, card: card(.clubs,.two)), PlayedCard(seat: .east, card: card(.spades,.two)),
        PlayedCard(seat: .north, card: card(.clubs,.three)), PlayedCard(seat: .west, card: card(.clubs,.four))])
    let trumpVoid = CompletedTrick(leaderSeat: .south, winnerSeat: .west, ledSuit: .spades, playedCards: [
        PlayedCard(seat: .south, card: card(.spades,.three)), PlayedCard(seat: .east, card: card(.diamonds,.three)),
        PlayedCard(seat: .north, card: card(.spades,.four)), PlayedCard(seat: .west, card: card(.spades,.five))])
    func context(_ hand: [Card], plays: [PlayedCard] = [], history: [CompletedTrick] = []) -> AIDecisionContext {
        AIDecisionContext(seat: .south, ownHand: hand, trick: TrickPlayState(declarerSeat: .south,
            tarneebSuit: .spades, currentTurnSeat: .south, currentTrick: plays, completedTricks: history), contract: 7, matchScore: GameScore())
    }
    let plays = [PlayedCard(seat: .north, card: card(.clubs,.queen)), PlayedCard(seat: .west, card: card(.clubs,.six))]
    require(settings.select(context([card(.spades,.ace),card(.diamonds,.two)], plays: plays, history: [history])) == card(.spades,.ace), "independent known-void partner protection")
    require(settings.select(context([card(.spades,.ace),card(.diamonds,.two)], plays: plays, history: [history,trumpVoid])) == card(.diamonds,.two), "known trump void removes risk")
    require(settings.select(context([card(.spades,.ace),card(.diamonds,.two)], plays: plays)) == card(.diamonds,.two), "unobserved void is not proof")
    require(settings.select(context([card(.clubs,.two),card(.clubs,.seven),card(.clubs,.ace)],
        plays: [PlayedCard(seat: .west, card: card(.clubs,.six))])) == card(.clubs,.seven), "bounded speculation preserves economical winner")
    require(settings.select(context([card(.clubs,.three),card(.clubs,.four),card(.clubs,.jack),card(.clubs,.queen),card(.clubs,.king),card(.diamonds,.two)]))?.suit == .clubs, "long suit retained")
    require(settings.select(context([card(.spades,.ace),card(.spades,.king),card(.spades,.five),card(.clubs,.two)])) == card(.spades,.king), "draw trump retained")
    require(settings.select(context([card(.clubs,.ace),card(.clubs,.two)], plays: [PlayedCard(seat: .east, card: card(.clubs,.three))] + plays)) == card(.clubs,.two), "secure partner not overtaken")
    require(settings.select(context([card(.clubs,.ace),card(.diamonds,.ace)], history: [history])) == card(.diamonds,.ace), "lead avoids known ruff")
}

func trainPublicThreat() {
    var settings: [PublicThreatSettings] = [], results: [AblationEvaluation] = []
    for speculation in [0.0,0.05,0.1] {
        for survival in [0.4,0.25] {
            let setting = PublicThreatSettings(publicSurvival: survival, speculation: speculation)
            checkPublicThreat(setting)
            let result = evaluateAblation(nil, firstSeed: 80000, count: 512, candidatePolicy: setting.select)
            settings.append(setting); results.append(result)
            FileHandle.standardError.write(Data("public=\(survival) speculation=\(speculation) mean=\(result.interval95.mean)\n".utf8))
        }
    }
    var best = 0
    for i in settings.indices where results[i].interval95.mean > results[best].interval95.mean + 1e-10 { best = i }
    printAblationJSON(PublicThreatTraining(settings: settings, results: results, selected: settings[best]))
}

func publicThreatHeldout(_ path: String) throws {
    let training = try JSONDecoder().decode(PublicThreatTraining.self, from: Data(contentsOf: URL(fileURLWithPath: path)))
    let selected = training.selected
    checkPublicThreat(selected)
    let standard = evaluateAblation(nil, firstSeed: 90000, count: 2048, candidatePolicy: selected.select)
    let original = evaluateAblation(nil, firstSeed: 90000, count: 2048, candidatePolicy: selected.select,
        referencePolicy: FrozenAdvancedCardPolicy.select)
    printAblationJSON(PublicThreatHeldout(selected: selected, versusStandard: standard, versusOriginal: original,
        standardAdjusted975: ablationInterval(standard.clusterScores,z: 2.241403),
        originalAdjusted975: ablationInterval(original.clusterScores,z: 2.241403)))
}

func verifyPromotedPublicThreat() {
    let selected = PublicThreatSettings(publicSurvival: 0.4, speculation: 0)
    checkPublicThreat(selected)
    let service = TrickPlayService()
    var positions = 0, expertChecks = 0
    for seed in 99000..<99032 {
        guard var game = benchmarkBid(benchmarkDeal(seed: UInt64(seed))) else { continue }
        while game.phase != .handComplete {
            if game.isCurrentTrickComplete { game = service.clearCompletedTrickIfNeeded(in: game); continue }
            let c = service.decisionContext(in: game, score: GameScore())!
            let card = AdvancedCardPolicy.select(c)!
            require(card == selected.select(c), "production matches frozen public-threat candidate")
            require(c.legalCards.contains(card), "promoted policy legal")
            require(ExpertRolloutCardPolicy.select(c) == FrozenAdvancedCardPolicy.select(c), "Expert rollout compatibility")
            if positions % 7 == 0 {
                let a = ExpertCardPolicy.select(c, seed: UInt64(seed), limits: AISearchLimits(seconds: 2))
                let b = FrozenExpertCardPolicy.select(c, seed: UInt64(seed), limits: AISearchLimits(seconds: 2))
                require(!a.fallback && !b.fallback && a.card == b.card && a.samples == b.samples, "completed Expert search preserves original decisions")
                expertChecks += 1
            }
            game = c.seat == .south ? service.playSouthCard(card,in:game) : service.playSimulatedCard(card,for:c.seat,in:game)
            positions += 1
        }
    }
    var bidChecks = 0
    for seed in 99032..<99064 {
        var game = benchmarkDeal(seed: UInt64(seed))
        for _ in 0..<64 {
            guard game.currentBiddingSeat != nil else { break }
            let c = bidContext(game)
            let a = ExpertBidPolicy.select(c,seed:UInt64(seed),limits:AIBidSearchLimits(seconds:2))
            let b = FrozenExpertBidPolicy.select(c,seed:UInt64(seed),limits:AIBidSearchLimits(seconds:2))
            require(!a.fallback && !b.fallback && a.recommendation == b.recommendation && a.samples == b.samples, "Expert bidding preserves original decisions")
            game = applyBid(a.recommendation,to:game)
            bidChecks += 1
        }
    }
    print("Public-threat promotion parity and tactics passed: \(positions) positions; \(expertChecks) full Expert search and \(bidChecks) Expert bid compatibility checks")
}
