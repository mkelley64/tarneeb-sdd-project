import Foundation

func biddingBaselineFingerprint() -> (UInt64, Int) {
    var hash: UInt64 = 14695981039346656037
    var count = 0
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    for seed in 1000..<1256 {
        let game = benchmarkDeal(seed: UInt64(seed))
        for seat in Seat.dealOrder {
            for scenario in 0..<7 {
                let highest: Seat? = scenario == 0 ? nil : (scenario % 2 == 0 ? seat.partnerSeat : seat.nextCounterclockwiseDealer)
                let value: BidValue? = scenario == 0 ? nil : [.seven, .nine, .twelve][(scenario-1)/2]
                var bids = Dictionary(uniqueKeysWithValues: Seat.dealOrder.map { ($0, BidState.pending) })
                if let highest, let value { bids[highest] = .resolved(value) }
                let context = BidRecommendationContext(seat: seat, hand: game.players.first { $0.seat == seat }!.hand,
                    partnerSeat: seat.partnerSeat, currentHighestBidValue: value, currentHighestBidder: highest, priorBidStates: bids)
                let recommendation = AutomatedBidRecommender().recommendation(for: context)
                for byte in try! encoder.encode(recommendation) { hash = (hash ^ UInt64(byte)) &* 1099511628211 }
                count += 1
            }
        }
    }
    return (hash, count)
}

func verifyBidding() throws {
    let (hash, count) = biddingBaselineFingerprint()
    require(count == 7168 && hash == 2562604130927913130, "frozen Standard bidding fingerprint")
    var differences = 0, positions = 0
    for seed in 30000..<30128 {
        var game = benchmarkDeal(seed: UInt64(seed))
        for _ in 0..<64 {
            guard game.currentBiddingSeat != nil else { break }
            let context = bidContext(game)
            let request = bidRequest(context, skill: .standard)
            require(AIBiddingEngine.select(request, seed: 1).recommendation == request.baseline, "Standard routing parity")
            let advanced = AdvancedBidPolicy.select(context)
            require(context.legalValues.contains(advanced.bid), "Advanced legal bid")
            require(advanced.bid == .pass || advanced.preferredTarneebSuit != nil, "numeric bid has trump")
            if advanced.bid != request.baseline.bid || advanced.preferredTarneebSuit != request.baseline.preferredTarneebSuit { differences += 1 }
            if context.auction.currentHighestBidder == context.auction.partnerSeat, let value = advanced.bid.numericValue {
                require(value >= context.auction.currentHighestBidValue!.numericValue!+2, "partner raise discipline")
            }
            var rng = AISeededGenerator(state: UInt64(seed))
            let hands = BiddingHandSampler.sample(context, using: &rng)!
            require(hands.values.allSatisfy { $0.count == 13 }, "sample hand sizes")
            require(Set(hands.values.flatMap { $0 }) == Set(DeckFactory.makeCanonicalDeck()), "52-card sample conservation")
            require(hands[context.auction.seat] == context.auction.hand, "own bidding hand fixed")
            var repeatRNG = AISeededGenerator(state: UInt64(seed))
            require(hands == BiddingHandSampler.sample(context, using: &repeatRNG), "bidding sample seed repeatability")
            if seed < 30008 {
                let first = ExpertBidPolicy.select(context, seed: 73, limits: AIBidSearchLimits(samples: 4, seconds: 2))
                let second = ExpertBidPolicy.select(context, seed: 73, limits: AIBidSearchLimits(samples: 4, seconds: 2))
                require(!first.fallback && first.recommendation == second.recommendation && first.samples == second.samples, "Expert bidding reproducibility")
                require(context.legalValues.contains(first.recommendation.bid), "Expert legal bid")
            }
            let legacy = game.currentBiddingSeat == .south ? applyBid(request.baseline, to: game)
                : BiddingService(bidRecommender: AutomatedBidRecommender()).resolveNextSimulatedBid(in: game)
            require(legacy == applyBid(AIBiddingEngine.select(request, seed: 13).recommendation, to: game), "full Standard auction parity")
            game = legacy
            positions += 1
        }
        require(game.currentBiddingSeat == nil, "auction bounded")
    }
    require(differences > 0, "Advanced bidding changes meaningful decisions")
    let hand = Rank.allCases.map { Card(suit: .spades, rank: $0) }
    let context = AIBiddingContext(auction: BidRecommendationContext(seat: .east, hand: hand, partnerSeat: .west,
        currentHighestBidValue: nil, currentHighestBidder: nil,
        priorBidStates: Dictionary(uniqueKeysWithValues: Seat.allCases.map { ($0, $0 == .east ? BidState.pending : .resolved(.pass)) })), matchScore: GameScore())
    require(AdvancedBidPolicy.select(context).bid == .thirteen, "certain 13 scoring boundary")
    let sweep = ExpertBidPolicy.select(context, seed: 1, limits: AIBidSearchLimits(samples: 4, seconds: 2))
    require(sweep.recommendation.bid == .thirteen, "Expert certain sweep: \(sweep)")
    for declarer in Seat.allCases {
        for bid in 7...13 {
            for tricks in 0...13 {
                let score = TarneebScoringService().scoreRound(declaringTeam: Team.forSeat(declarer), bid: bid, declaringTricks: tricks)!
                require(context.utility(declarer: declarer, bid: bid, tricks: tricks) == Double(score.scoreDelta(for: context.team)-score.scoreDelta(for: context.team.opponent)), "bidding scoring boundaries")
            }
        }
    }
    for limits in [AIBidSearchLimits(samples: 0), AIBidSearchLimits(seconds: 0), AIBidSearchLimits(seconds: 1e-12)] {
        let result = ExpertBidPolicy.select(context, seed: 1, limits: limits)
        require(result.fallback && result.recommendation == AdvancedBidPolicy.select(context), "bidding budget fallback")
    }
    var checks = 0
    let cancelled = ExpertBidPolicy.select(context, seed: 1, shouldCancel: { checks += 1; return checks > 20 })
    require(cancelled.cancelled && cancelled.fallback, "bidding mid-rollout cancellation")
    let invalid = AIBiddingContext(auction: BidRecommendationContext(seat: .east, hand: [], partnerSeat: .west,
        currentHighestBidValue: nil, currentHighestBidder: nil, priorBidStates: context.auction.priorBidStates), matchScore: GameScore())
    require(ExpertBidPolicy.select(invalid, seed: 1).fallback, "bidding sample failure fallback")
    let finished = DispatchSemaphore(value: 0)
    Task.detached {
        let task = Task { await AIBiddingEngine.detached(bidRequest(context, skill: .expert), seed: 1) }
        task.cancel()
        let result = await task.value
        require(result.cancelled, "bidding detached cancellation")
        finished.signal()
    }
    require(finished.wait(timeout: .now()+3) == .success, "bidding cancellation bounded")
    try verifyBiddingLifecycle()
    print("Bidding: \(count) frozen recommendations; \(positions) auction positions; \(differences) Advanced differences; fairness/scoring/fallback/lifecycle passed")
}

func verifyBiddingLifecycle() throws {
    let name = "bidding-tests-\(UUID().uuidString)"
    let prefs = UserDefaults(suiteName: name)!
    defer { prefs.removePersistentDomain(forName: name) }
    prefs.set("expert", forKey: AISkill.preferenceKey)
    let model = TarneebPresentationState(dealService: DealService(shuffler: CardShuffler { $0 }, handLogger: HandLogger { _ in }),
        dealerSelector: EnvironmentDealerSelector(environment: ["TARNEEB_INITIAL_DEALER":"south"]), aiPreferences: prefs)
    model.deal()
    prefs.set("standard", forKey: AISkill.preferenceKey)
    let first = model.prepareAIBidDecision()!
    require(first.skill == .expert && first.useSkillPolicy, "first Deal freezes bidding level")
    let pass = AIBidResult(recommendation: BidRecommendation(bid: .pass), samples: 0, fallback: false, cancelled: false)
    let second = model.prepareAIBidDecision()!
    require(!model.applyAIBidDecision(pass, request: first), "superseded bid rejected")
    require(!model.applyAIBidDecision(AIBidResult(recommendation: pass.recommendation, samples: 0, fallback: true, cancelled: true), request: second), "cancelled bid rejected")
    require(!model.applyAIBidDecision(AIBidResult(recommendation: BidRecommendation(bid: .seven), samples: 0, fallback: false, cancelled: false), request: second), "missing trump rejected")
    let path = FileManager.default.temporaryDirectory.appendingPathComponent(name)
    defer { try? FileManager.default.removeItem(at: path) }
    let store = MatchStore(url: path.appendingPathComponent("match.json"))
    try store.save(model.snapshot)
    model.enablePersistence(store)
    require(!model.applyAIBidDecision(pass, request: second), "restore rejects prior auction request")
    require(model.activeAISkill == .expert, "resumed bidding retains match skill")
    for seat in [Seat.east, .north, .west] {
        let request = model.prepareAIBidDecision()!
        require(request.context.auction.seat == seat && request.skill == .expert, "all three seats share bidding skill")
        require(model.applyAIBidDecision(pass, request: request), "current bidding result accepted")
        require(!model.applyAIBidDecision(pass, request: request), "changed turn rejects result")
    }
    model.enablePersistence(store)
    model.newGame()
    model.deal()
    let stale = model.prepareAIBidDecision()!
    model.newGame()
    require(!model.applyAIBidDecision(pass, request: stale), "reset rejects bidding result")
    let initial = (30000..<30128).map { benchmarkDeal(seed: UInt64($0)) }
        .first { !AdvancedBidPolicy.candidates(bidContext($0)).isEmpty }!
    let own = initial.currentBiddingSeat!
    let otherCards = initial.players.filter { $0.seat != own }.flatMap(\.hand).reversed()
    var cards = Array(otherCards)
    let players = initial.players.map { player -> Player in
        guard player.seat != own else { return player }
        let replacement = Array(cards.prefix(13)); cards.removeFirst(13)
        return Player(id: player.id, seat: player.seat, type: player.type, team: player.team, hand: replacement)
    }
    let permuted = GameState(phase: initial.phase, players: players, dealerSeat: initial.dealerSeat,
        biddingState: initial.biddingState, postBiddingSummary: initial.postBiddingSummary, trickPlayState: initial.trickPlayState)!
    require(bidContext(initial) == bidContext(permuted), "hidden-hand permutation leaves bidding context identical")
    for skill in AISkill.allCases {
        let a = AIBiddingEngine.select(bidRequest(bidContext(initial), skill: skill), seed: 95, limits: AIBidSearchLimits(samples: 4, seconds: 2))
        let b = AIBiddingEngine.select(bidRequest(bidContext(permuted), skill: skill), seed: 95, limits: AIBidSearchLimits(samples: 4, seconds: 2))
        require(a.recommendation == b.recommendation, "hidden-hand permutation decision parity")
        if skill == .expert { require(a.samples == 4 && !a.fallback, "fairness test exercises actual search") }
    }
    // Preferred suits stored for other bidders are not public until reveal.
    let committed = applyBid(BidRecommendation(bid: .seven, preferredTarneebSuit: .spades), to: initial)
    let bidding = committed.biddingState!
    var privateRecords = bidding.bidRecommendations
    privateRecords[own] = BidRecommendation(bid: .seven, preferredTarneebSuit: .hearts)
    let altered = committed.replacingBiddingState(BiddingState(bids: bidding.bids,
        bidRecommendations: privateRecords, currentTurnSeat: bidding.currentTurnSeat,
        highestBidSeat: bidding.highestBidSeat, highestBidValue: bidding.highestBidValue, status: bidding.status), postBiddingSummary: nil)
    let service = BiddingService()
    require(service.publicDecisionContext(in: committed, score: GameScore()) == service.publicDecisionContext(in: altered, score: GameScore()), "other bidder's private suit cannot enter context")
    let overridden = BiddingService(bidGenerator: BidGenerator { _ in .pass }).prepareRecommendation(for: bidContext(initial))
    require(!overridden.useSkillPolicy && overridden.baseline.bid == .pass, "explicit fixture injection retained")
    let forced = EnvironmentBidRecommender(environment: ["TARNEEB_SIMULATED_BIDS":"east:7"])
        .configuredRecommendation(for: bidContext(initial).auction)
    require(forced?.bid == .seven, "environment override detected without falling through")
}
