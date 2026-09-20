import Foundation

func verifySkills() throws {
    let service = TrickPlayService()
    func card(_ suit: Suit, _ rank: Rank) -> Card { Card(suit: suit, rank: rank) }
    func context(_ hand: [Card], _ plays: [PlayedCard] = [], seat: Seat = .south,
                 history: [CompletedTrick] = [], bid: Int = 7) -> AIDecisionContext {
        AIDecisionContext(seat: seat, ownHand: hand,
            trick: TrickPlayState(declarerSeat: .south, tarneebSuit: .spades,
                                  currentTurnSeat: seat, currentTrick: plays, completedTricks: history),
            contract: bid, matchScore: GameScore())
    }
    let drawing = context([card(.spades,.ace), card(.spades,.king), card(.spades,.five), card(.clubs,.two)])
    require(drawing.standard() == card(.clubs,.two), "frozen lead")
    require(AdvancedCardPolicy.select(drawing) == card(.spades,.king), "draw trump from control, retaining ace entry")
    let second = context([card(.clubs,.two),card(.clubs,.seven),card(.clubs,.ace)],
                         [PlayedCard(seat:.west,card:card(.clubs,.six))])
    require(second.standard() == card(.clubs,.seven), "Standard economical winner")
    require(AdvancedCardPolicy.select(second) == card(.clubs,.seven), "do not spend ace on unsupported higher-card speculation")
    let long = context([card(.clubs,.three),card(.clubs,.four),card(.clubs,.jack),card(.clubs,.queen),card(.clubs,.king),card(.diamonds,.two)])
    require(long.standard() == card(.diamonds,.two), "Standard low lead")
    require(AdvancedCardPolicy.select(long)?.suit == .clubs, "establish long suit")
    let partner = context([card(.clubs,.ace), card(.clubs,.two)],
        [PlayedCard(seat:.east,card:card(.clubs,.three)), PlayedCard(seat:.north,card:card(.clubs,.queen)), PlayedCard(seat:.west,card:card(.clubs,.four))])
    require(AdvancedCardPolicy.select(partner) == card(.clubs,.two), "do not overtake secure partner")
    let voidTrick = CompletedTrick(leaderSeat:.south,winnerSeat:.east,ledSuit:.clubs,playedCards:[
        PlayedCard(seat:.south,card:card(.clubs,.two)),PlayedCard(seat:.east,card:card(.spades,.two)),
        PlayedCard(seat:.north,card:card(.clubs,.three)),PlayedCard(seat:.west,card:card(.clubs,.four))])
    let risky = context([card(.clubs,.ace),card(.diamonds,.ace)],history:[voidTrick])
    require(AdvancedCardPolicy.select(risky) == card(.diamonds,.ace), "avoid demonstrated ruff risk")
    let vulnerable = context([card(.spades,.ace),card(.diamonds,.two)],
        [PlayedCard(seat:.north,card:card(.clubs,.queen)),PlayedCard(seat:.west,card:card(.clubs,.six))],
        history:[voidTrick])
    require(vulnerable.standard() == card(.diamonds,.two), "Standard partner conservation")
    require(AdvancedCardPolicy.select(vulnerable) == card(.spades,.ace), "protect partner against known ruff")
    for bid in 7...13 {
        let c = context([card(.clubs,.ace)],bid:bid)
        for wins in 0...13 {
            let result = TarneebScoringService().scoreRound(declaringTeam:.teamA,bid:bid,declaringTricks:wins)!
            require(c.utility(declaringWins:wins) == Double(result.declaringScoreDelta-result.defendingScoreDelta), "actual scoring boundary")
        }
    }
    let match = AIDecisionContext(seat:.south,ownHand:drawing.ownHand,trick:drawing.trick,contract:7,
                                matchScore:GameScore(northSouth:24,eastWest:30))
    require(match.utility(declaringWins:7) == 71, "match winning boundary")
    require(match.utility(declaringWins:6) == -78, "match losing boundary")
    var samples = 0, decisions = 0
    for seed in 10000..<10012 {
        guard var game = benchmarkBid(benchmarkDeal(seed:UInt64(seed))) else { continue }
        while game.phase != .handComplete {
            if game.isCurrentTrickComplete { game = service.clearCompletedTrickIfNeeded(in:game); continue }
            let c = service.decisionContext(in:game,score:GameScore())!
            require(c.standard() == FrozenStandard.select(from:c.legalCards,for:c.seat,
                currentTrick:c.trick.currentTrick,tarneebSuit:c.trick.tarneebSuit,
                ownHand:c.ownHand,completedTricks:c.trick.completedTricks), "history baseline parity")
            let info = PublicCardInference(c)
            var rng = AISeededGenerator(state:UInt64(seed))
            let sampled = PlausibleHandSampler.sample(c,using:&rng)!
            let all = sampled.values.flatMap { $0 } + c.trick.playedCards.map(\.card)
            require(all.count == 52 && Set(all) == Set(DeckFactory.makeCanonicalDeck()), "sample conservation")
            for seat in Seat.allCases {
                require(sampled[seat]!.count == info.handSizes[seat], "sample hand sizes")
                require(sampled[seat]!.allSatisfy { info.couldHold($0,seat:seat) }, "sample respects void")
            }
            require(sampled[c.seat] == c.ownHand, "own hand fixed")
            var replay = AISeededGenerator(state:UInt64(seed))
            require(PlausibleHandSampler.sample(c,using:&replay) == sampled, "sample seed repeatability")
            samples += 1
            let reversed = AIDecisionContext(seat:c.seat,ownHand:c.ownHand.reversed(),trick:c.trick,contract:c.contract,matchScore:c.matchScore)
            require(AdvancedCardPolicy.select(c) == AdvancedCardPolicy.select(reversed), "Advanced ordering")
            let skill = AISkill.allCases[(seed + c.trick.completedTricks.count) % 3]
            let result = AIDecisionEngine.select(c,skill:skill,seed:UInt64(seed),limits:AISearchLimits(samples:2,maxTricks:3,seconds:2))
            require(result.card.map { c.legalCards.contains($0) } == true, "legal decision")
            if decisions % 17 == 0 {
                let repeatResult = AIDecisionEngine.select(reversed,skill:skill,seed:UInt64(seed),limits:AISearchLimits(samples:2,maxTricks:3,seconds:2))
                require(result.card == repeatResult.card, "seed and hand-order invariance")
                // Permute opponents' actual hands. Context construction may read only our hand.
                var players = game.players
                let opponents = players.indices.filter { players[$0].seat != c.seat }
                let hidden = opponents.flatMap { players[$0].hand }.reversed()
                var cursor = hidden.makeIterator()
                for i in opponents { players[i].hand = players[i].hand.map { _ in cursor.next()! } }
                let permutation = game.replacingTrickPlayState(c.trick,players:players,phase:.trickPlay)
                let other = service.decisionContext(in:permutation,score:GameScore())!
                require(other == c, "hidden-hand permutation context")
                require(AIDecisionEngine.select(other,skill:skill,seed:UInt64(seed),limits:AISearchLimits(samples:2,maxTricks:3,seconds:2)).card == result.card, "hidden-hand permutation decision")
            }
            let before = game.players.reduce(0) { $0 + $1.hand.count }
            game = c.seat == .south ? service.playSouthCard(result.card!,in:game)
                : service.playSimulatedCard(result.card!,for:c.seat,in:game)
            require(game.players.reduce(0) { $0 + $1.hand.count } == before-1, "one-card mutation")
            let conserved = game.players.flatMap(\.hand) + game.trickPlayState!.playedCards.map(\.card)
            require(conserved.count == 52 && Set(conserved).count == 52, "actual card conservation")
            decisions += 1
        }
        require(game.trickPlayState!.completedTricks.count == 13, "all tricks finish")
    }
    let valid = service.decisionContext(in:benchmarkBid(benchmarkDeal(seed:10000))!,score:GameScore())!
    for limits in [AISearchLimits(samples:0),AISearchLimits(seconds:0),AISearchLimits(maxTricks:0),AISearchLimits(seconds:1e-12)] {
        let result = ExpertCardPolicy.select(valid,seed:1,limits:limits)
        require(result.fallback && result.card == AdvancedCardPolicy.select(valid), "budget fallback")
    }
    let cancelled = ExpertCardPolicy.select(valid,seed:1,shouldCancel:{true})
    require(cancelled.cancelled && cancelled.fallback, "cancellation")
    var cancellationChecks = 0
    let midSearch = ExpertCardPolicy.select(valid,seed:1,shouldCancel:{
        cancellationChecks += 1
        return cancellationChecks > 20
    })
    require(midSearch.cancelled && midSearch.fallback, "mid-search cancellation")
    let finished = DispatchSemaphore(value:0)
    Task.detached {
        let worker = Task { await AIDecisionEngine.detached(valid,skill:.expert,seed:1) }
        worker.cancel()
        let result = await worker.value
        require(result.cancelled, "detached cancellation propagation")
        finished.signal()
    }
    require(finished.wait(timeout:.now()+2) == .success, "detached cancellation finishes promptly")
    let invalid = context([card(.clubs,.two),card(.diamonds,.two)])
    let failed = ExpertCardPolicy.select(invalid,seed:1)
    require(failed.fallback && failed.card == AdvancedCardPolicy.select(invalid), "sampling failure fallback")
    let impossibleHistory = CompletedTrick(leaderSeat:.south,winnerSeat:.west,ledSuit:.clubs,playedCards:[
        PlayedCard(seat:.south,card:card(.clubs,.two)),PlayedCard(seat:.east,card:card(.hearts,.two)),
        PlayedCard(seat:.north,card:card(.diamonds,.two)),PlayedCard(seat:.west,card:card(.spades,.two))])
    let impossible = context(Rank.allCases.filter { $0 != .two }.map { card(.spades,$0) },history:[impossibleHistory])
    var impossibleRNG = AISeededGenerator(state:1)
    require(PlausibleHandSampler.sample(impossible,using:&impossibleRNG) == nil, "impossible void/capacity constraints")
    require(ExpertCardPolicy.select(impossible,seed:1).fallback, "constraint failure falls back")
    print("Tactics/scoring and \(decisions) legal plays, \(samples) constrained samples passed")
    try verifySkillPersistence()
}

func verifySkillPersistence() throws {
    let name = "tarneeb-ai-tests-\(UUID().uuidString)"
    let preferences = UserDefaults(suiteName:name)!
    defer { preferences.removePersistentDomain(forName:name) }
    require(AISkill.preference(in:preferences) == .standard, "default preference")
    preferences.set("unknown",forKey:AISkill.preferenceKey)
    require(AISkill.preference(in:preferences) == .standard, "unknown preference")
    preferences.set("advanced",forKey:AISkill.preferenceKey)
    require(AISkill.preference(in:UserDefaults(suiteName:name)!) == .advanced, "persisted preference")
    let model = TarneebPresentationState(
        dealService:DealService(shuffler:CardShuffler { $0 },handLogger:HandLogger { _ in }),
        dealerSelector:EnvironmentDealerSelector(environment:["TARNEEB_INITIAL_DEALER":"west"]),
        biddingService:BiddingService(bidGenerator:BidGenerator { _ in .pass }),aiPreferences:preferences)
    require(model.activeAISkill == .standard, "fresh default before Deal")
    model.deal()
    require(model.activeAISkill == .advanced, "first Deal freezes preference")
    preferences.set("expert",forKey:AISkill.preferenceKey)
    model.submitSouthBid(.seven,selectedTarneebSuit:.spades)
    for _ in 0..<3 { model.resolveNextSimulatedBid() }
    model.startTrickPlayIfReady()
    let service = TrickPlayService()
    let human = service.legalCards(for:.south,in:model.gameState).first!
    model.playSouthCard(human)
    let request = model.prepareAIDecision()!
    let result = AIDecisionEngine.select(request.context,skill:request.skill,seed:1)
    require(model.activeAISkill == .advanced, "preference change leaves match frozen")
    let superseding = model.prepareAIDecision()!
    require(!model.applyAIDecision(result,request:request), "superseded request rejected")
    let bad = AIDecisionResult(card:human,samples:0,fallback:false,cancelled:false)
    require(!model.applyAIDecision(bad,request:superseding), "illegal result rejected")
    let cancelled = AIDecisionResult(card:result.card,samples:0,fallback:false,cancelled:true)
    require(!model.applyAIDecision(cancelled,request:superseding), "cancelled result rejected")
    require(model.applyAIDecision(result,request:superseding), "current result accepted")
    require(!model.applyAIDecision(result,request:superseding), "duplicate/changed-turn result rejected")
    let folder = FileManager.default.temporaryDirectory.appendingPathComponent(name)
    defer { try? FileManager.default.removeItem(at:folder) }
    let store = MatchStore(url:folder.appendingPathComponent("match.json"))
    try store.save(model.snapshot)
    let resumed = TarneebPresentationState(dealService:DealService(handLogger:HandLogger { _ in }),aiPreferences:preferences)
    resumed.enablePersistence(store)
    require(resumed.gameState == model.gameState && resumed.activeAISkill == .advanced, "resume frozen skill")
    let beforeRestore = resumed.prepareAIDecision()!
    resumed.enablePersistence(store)
    require(!resumed.applyAIDecision(AIDecisionEngine.select(beforeRestore.context,skill:.advanced,seed:1),request:beforeRestore), "restore invalidates request even for identical state")
    var legacy = try JSONSerialization.jsonObject(with:JSONEncoder().encode(model.snapshot)) as! [String:Any]
    legacy["version"] = 1
    legacy.removeValue(forKey:"activeAISkill")
    let migrated = try JSONDecoder().decode(MatchSnapshot.self,from:JSONSerialization.data(withJSONObject:legacy)).validated()
    require(migrated.restoredAISkill == .standard, "v1 migrates Standard")
    legacy["version"] = 2
    let missingLevel = try JSONDecoder().decode(MatchSnapshot.self,from:JSONSerialization.data(withJSONObject:legacy))
    do { _ = try missingLevel.validated(); require(false,"v2 missing level rejected") } catch { }
    try store.save(migrated)
    resumed.enablePersistence(store)
    require(resumed.activeAISkill == .standard, "legacy resume ignores preference")
    let stale = resumed.prepareAIDecision()!
    resumed.newGame()
    require(resumed.activeAISkill == .expert, "New Game captures preference")
    require(!resumed.applyAIDecision(result,request:stale), "reset rejects stale result")
    preferences.set("standard",forKey:AISkill.preferenceKey)
    resumed.deal()
    require(resumed.activeAISkill == .expert, "New Game boundary remains frozen before Deal")
    while model.gameState.phase != .handComplete {
        if model.gameState.isCurrentTrickComplete { model.clearCompletedTrickIfNeeded() }
        else if model.gameState.currentTrickTurnSeat == .south { model.playSouthCard(service.legalCards(for:.south,in:model.gameState).first!) }
        else {
            let next = model.prepareAIDecision()!
            require(next.skill == .advanced, "same active skill for East, North and West")
            require(model.applyAIDecision(AIDecisionEngine.select(next.context,skill:next.skill,seed:1),request:next), "valid result applies for every simulated seat")
        }
    }
    model.startNextRound()
    require(model.activeAISkill == .advanced, "next hand remains frozen")
    let allPass = TarneebPresentationState(
        dealService:DealService(handLogger:HandLogger { _ in }),
        dealerSelector:EnvironmentDealerSelector(environment:["TARNEEB_INITIAL_DEALER":"west"]),
        biddingService:BiddingService(bidGenerator:BidGenerator { _ in .pass }),aiPreferences:preferences)
    preferences.set("advanced",forKey:AISkill.preferenceKey)
    allPass.deal()
    preferences.set("expert",forKey:AISkill.preferenceKey)
    allPass.submitSouthBid(.pass)
    for _ in 0..<3 { allPass.resolveNextSimulatedBid() }
    allPass.automaticRedealAfterAllPass()
    require(allPass.activeAISkill == .advanced, "all-pass redeal remains frozen")
    print("Preference, freeze, migration, restore, legality and stale-result tests passed")
}

// Deterministic tuning-domain audit: changing only public contract/score information
// must be capable of changing strategy. No policy parameters are tuned by this test.
func verifyContractSensitivity() {
    var targetDifferences = 0
    var scoreDifferences = 0
    let service = TrickPlayService()
    for seed in 10000..<10032 {
        guard var game = benchmarkBid(benchmarkDeal(seed:UInt64(seed))) else { continue }
        while game.phase != .handComplete {
            if game.isCurrentTrickComplete { game = service.clearCompletedTrickIfNeeded(in:game); continue }
            let c = service.decisionContext(in:game,score:GameScore())!
            let seven = AIDecisionContext(seat:c.seat,ownHand:c.ownHand,trick:c.trick,contract:7,matchScore:GameScore())
            let thirteen = AIDecisionContext(seat:c.seat,ownHand:c.ownHand,trick:c.trick,contract:13,matchScore:GameScore())
            let closing = AIDecisionContext(seat:c.seat,ownHand:c.ownHand,trick:c.trick,contract:7,matchScore:GameScore(northSouth:24,eastWest:30))
            if AdvancedCardPolicy.select(seven) != AdvancedCardPolicy.select(thirteen) { targetDifferences += 1 }
            if AdvancedCardPolicy.select(seven) != AdvancedCardPolicy.select(closing) { scoreDifferences += 1 }
            let card = c.standard()!
            game = c.seat == .south ? service.playSouthCard(card,in:game) : service.playSimulatedCard(card,for:c.seat,in:game)
        }
    }
    require(targetDifferences > 0, "contract target affects actual policy decisions")
    require(scoreDifferences > 0, "match score affects actual policy decisions")
    print("Contract sensitivity: \(targetDifferences) target-sensitive and \(scoreDifferences) match-score-sensitive decisions")
}

func verifyEveryContractSeatAndSuit() {
    let service = TrickPlayService()
    var plays = 0
    for skill in AISkill.allCases {
        for declarer in Seat.allCases {
            for suit in Suit.allCases {
                let dealt = benchmarkDeal(seed:10001)
                var bidding = BiddingState.started(dealerSeat:dealt.dealerSeat)
                while let seat = bidding.currentTurnSeat {
                    let bid: BidValue = seat == declarer ? .seven : .pass
                    bidding.submit(bid,recommendation:BidRecommendation(bid:bid,preferredTarneebSuit:bid == .pass ? nil : suit,confidence:1),for:seat)
                }
                var game = dealt.replacingBiddingState(bidding,postBiddingSummary:PostBiddingSummary(highBidderSeat:declarer,bidValue:.seven,tarneebSuit:suit)).startingTrickPlayIfReady()
                require(game.currentTrickTurnSeat == declarer,"declarer leads")
                while game.phase != .handComplete {
                    if game.isCurrentTrickComplete { game = service.clearCompletedTrickIfNeeded(in:game); continue }
                    let context = service.decisionContext(in:game,score:GameScore())!
                    let result = AIDecisionEngine.select(context,skill:skill,seed:77,
                        limits:AISearchLimits(samples:2,maxTricks:13,seconds:2))
                    require(result.card.map { context.legalCards.contains($0) } == true,"legal across seat/suit matrix")
                    require(!result.fallback,"valid full-rollout position does not fail sampling")
                    game = context.seat == .south ? service.playSouthCard(result.card!,in:game)
                        : service.playSimulatedCard(result.card!,for:context.seat,in:game)
                    let all = game.players.flatMap(\.hand) + game.trickPlayState!.playedCards.map(\.card)
                    require(all.count == 52 && Set(all).count == 52,"conservation across seat/suit matrix")
                    plays += 1
                }
                require(game.players.allSatisfy { $0.hand.isEmpty },"finished hands empty")
                require(game.trickPlayState!.completedTricks.count == 13,"exactly 13 tricks")
            }
        }
    }
    print("All 48 skill/declarer/trump combinations passed: \(plays) legal conserved plays")
}
