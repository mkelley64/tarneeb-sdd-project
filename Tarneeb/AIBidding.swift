import Foundation

/// Public auction information only. In particular, another bidder's stored
/// preferred trump suit is private until the auction finishes and is not copied.
struct AIBiddingContext: Equatable, Sendable {
    let auction: BidRecommendationContext
    let matchScore: GameScore

    var legalValues: [BidValue] { BidValue.legalValues(afterHighest: auction.currentHighestBidValue) }
    var team: Team { Team.forSeat(auction.seat) }
    var validHand: Bool { auction.hand.count == 13 && Set(auction.hand).count == 13 }

    func utility(declarer: Seat, bid: Int, tricks: Int) -> Double {
        guard let result = TarneebScoringService().scoreRound(declaringTeam: Team.forSeat(declarer), bid: bid, declaringTricks: tricks) else { return 0 }
        var score = matchScore
        score.apply(result)
        let terminal = score.winnerTeam.map { $0 == team ? 64.0 : -64.0 } ?? 0
        return Double(result.scoreDelta(for: team) - result.scoreDelta(for: team.opponent)) + terminal
    }
}

struct AIBidRequest: Sendable {
    let id: UUID
    let revision: UUID
    let context: AIBiddingContext
    let skill: AISkill
    let baseline: BidRecommendation
    let useSkillPolicy: Bool
}

struct AIBidResult: Sendable {
    let recommendation: BidRecommendation
    let samples: Int
    let fallback: Bool
    let cancelled: Bool
}

struct AIBidSearchLimits: Sendable {
    // Release profiling on tuning seeds 30000...30031: 16 samples, p95 ~10 ms,
    // maximum ~15 ms on the development Mac. Physical-device profiling remains.
    var samples = 16
    var seconds = 0.20
}

enum AdvancedBidPolicy {
    /// Preserve proven conservative structural ceilings. Raise only the cheapest
    /// legal commitment, or 13 for its different payoff; intermediate jumps have
    /// no direct scoring benefit and are deliberately not used to bully an auction.
    static func candidates(_ context: AIBiddingContext) -> [BidRecommendation] {
        guard context.validHand, context.auction.priorBidStates[context.auction.seat]?.isPass != true,
              context.auction.currentHighestBidder != context.auction.seat else { return [] }
        let partnerLeads = context.auction.currentHighestBidder == context.auction.partnerSeat
        let minimum = max(7, (context.auction.currentHighestBidValue?.numericValue ?? 0) + (partnerLeads ? 2 : 1))
        return AutomatedBidRecommender.diagnostics(for: context.auction.hand).suitEvaluations.flatMap { evaluation in
            let trump = context.auction.hand.filter { $0.suit == evaluation.suit }
            let independent = trump.contains { $0.rank == .ace } || trump.filter { $0.rank.aiPower >= 12 }.count >= 2
            guard let ceiling = evaluation.safeBid.numericValue, minimum <= ceiling,
                  !partnerLeads || independent else { return [BidRecommendation]() }
            let values = minimum == 13 ? [13] : ([minimum] + (ceiling == 13 ? [13] : []))
            return values.compactMap { value in
                guard let bid = BidValue.allCases.first(where: { $0.numericValue == value }), context.legalValues.contains(bid) else { return nil }
                return BidRecommendation(bid: bid, preferredTarneebSuit: evaluation.suit)
            }
        }
    }

    static func distribution(mean: Double, deviation: Double) -> [Double] {
        let weights = (0...13).map { exp(-0.5 * pow((Double($0) - min(13, max(0, mean))) / deviation, 2)) }
        let total = weights.reduce(0,+)
        return weights.map { $0 / total }
    }

    static func select(_ context: AIBiddingContext) -> BidRecommendation {
        let candidates = candidates(context)
        guard !candidates.isEmpty else { return BidRecommendation(bid: .pass) }
        let evaluations = AutomatedBidRecommender.diagnostics(for: context.auction.hand).suitEvaluations
        let sideAces = context.auction.hand.filter { $0.rank == .ace }.count
        var passUtility = 0.0
        if let bidder = context.auction.currentHighestBidder, let bid = context.auction.currentHighestBidValue?.numericValue {
            // Soft strength evidence, not knowledge of partner/opponent cards or suit.
            let support = Team.forSeat(bidder) == context.team ? 0.2 : -0.2
            let distribution = distribution(mean: Double(bid) + 0.3 + support * Double(sideAces), deviation: 1.4)
            passUtility = (0...13).reduce(0) { $0 + distribution[$1] * context.utility(declarer: bidder, bid: bid, tricks: $1) }
        }
        var best = BidRecommendation(bid: .pass)
        var bestValue = passUtility + (context.auction.currentHighestBidder == context.auction.partnerSeat ? 1.5 : 0.5)
        for candidate in candidates {
            let suit = candidate.preferredTarneebSuit!
            let bid = candidate.bid.numericValue!
            let evaluation = evaluations.first { $0.suit == suit }!
            let certainSweep = context.auction.hand.allSatisfy { $0.suit == suit }
            let contested = context.auction.currentHighestBidder.map { Team.forSeat($0) != context.team } ?? false
            let probabilities = certainSweep ? Array(repeating: 0.0, count: 13) + [1.0]
                : distribution(mean: evaluation.expectedTricks - (contested ? 0.25 : 0),
                               deviation: 0.9 + Double(max(0, 3 - evaluation.topTrumpControlCount)) * 0.2)
            let make = probabilities[bid...].reduce(0,+)
            guard make >= (bid == 13 ? 0.97 : 0.60) else { continue }
            let expected = (0...13).reduce(0) { $0 + probabilities[$1] * context.utility(declarer: context.auction.seat, bid: bid, tricks: $1) }
            // Equal values retain canonical suit order and the lower commitment.
            if expected > bestValue + 1e-10 {
                bestValue = expected
                best = BidRecommendation(bid: candidate.bid, preferredTarneebSuit: suit, confidence: make)
            }
        }
        return best
    }
}

enum BiddingHandSampler {
    static func sample(_ context: AIBiddingContext, using rng: inout AISeededGenerator) -> [Seat: [Card]]? {
        guard context.validHand else { return nil }
        let own = Set(context.auction.hand)
        let unseen = DeckFactory.makeCanonicalDeck().filter { !own.contains($0) }.shuffled(using: &rng)
        guard unseen.count == 39 else { return nil }
        var hands = [context.auction.seat: context.auction.hand]
        for (index, seat) in Seat.dealOrder.filter({ $0 != context.auction.seat }).enumerated() {
            hands[seat] = Array(unseen[(index*13)..<(index*13+13)])
        }
        return hands
    }
}

enum ExpertBidPolicy {
    private struct Outcome { let utility: Double; let ownContract: Bool; let made: Bool }

    /// The environment holds sampled hands; every bidding/card policy gets only
    /// that actor's own hand and public state. No double-dummy planning is used.
    private static func rollout(_ context: AIBiddingContext, hands initialHands: [Seat: [Card]],
                                root: BidRecommendation, shouldStop: () -> Bool) -> Outcome? {
        var records: [Seat: BidRecommendation] = [:]
        for seat in Seat.dealOrder {
            if let bid = context.auction.priorBidStates[seat]?.resolvedValue, bid.numericValue != nil {
                records[seat] = BidRecommendation(bid: bid,
                    preferredTarneebSuit: AutomatedBidRecommender.preferredSuit(for: initialHands[seat] ?? []))
            }
        }
        var bidding = BiddingState(bids: context.auction.priorBidStates, bidRecommendations: records,
            currentTurnSeat: context.auction.seat, highestBidSeat: context.auction.currentHighestBidder,
            highestBidValue: context.auction.currentHighestBidValue, status: .inProgress)
        bidding.submit(root.bid, recommendation: root, for: context.auction.seat)
        for _ in 0..<64 {
            guard !shouldStop() else { return nil }
            guard let seat = bidding.currentTurnSeat else { break }
            let local = BidRecommendationContext(seat: seat, hand: initialHands[seat]!, partnerSeat: seat.partnerSeat,
                currentHighestBidValue: bidding.highestBidValue, currentHighestBidder: bidding.highestBidSeat, priorBidStates: bidding.bids)
            let next = AutomatedBidRecommender().recommendation(for: local)
            bidding.submit(next.bid, recommendation: next, for: seat)
        }
        guard bidding.status == .complete, !shouldStop() else { return nil }
        guard let declarer = bidding.highestBidSeat, let bid = bidding.highestBidValue?.numericValue else {
            return Outcome(utility: 0, ownContract: false, made: false) // neutral redeal, not a favorable fabricated hand
        }
        guard let trump = bidding.bidRecommendations[declarer]?.preferredTarneebSuit else { return nil }
        var hands = initialHands
        var trick = TrickPlayState(declarerSeat: declarer, tarneebSuit: trump)
        for _ in 0..<52 {
            guard !shouldStop(), let actor = trick.currentTurnSeat else { return nil }
            let local = AIDecisionContext(seat: actor, ownHand: hands[actor]!, trick: trick, contract: bid, matchScore: context.matchScore)
            guard let card = ExpertRolloutCardPolicy.select(local), local.legalCards.contains(card),
                  let position = hands[actor]?.firstIndex(of: card) else { return nil }
            hands[actor]?.remove(at: position)
            trick.appendPlayedCard(PlayedCard(seat: actor, card: card))
            if trick.pendingCompletedTrick != nil { trick.clearPendingCompletedTrick() }
        }
        let tricks = trick.partnershipTrickCount(for: declarer)
        return Outcome(utility: context.utility(declarer: declarer, bid: bid, tricks: tricks),
                       ownContract: declarer == context.auction.seat, made: tricks >= bid)
    }

    static func select(_ context: AIBiddingContext, seed: UInt64, limits: AIBidSearchLimits = AIBidSearchLimits(),
                       shouldCancel: () -> Bool = { false }) -> AIBidResult {
        let start = ProcessInfo.processInfo.systemUptime
        func stopped() -> Bool { shouldCancel() || ProcessInfo.processInfo.systemUptime - start >= limits.seconds }
        func fallback(_ samples: Int) -> AIBidResult {
            AIBidResult(recommendation: AdvancedBidPolicy.select(context), samples: samples, fallback: true, cancelled: shouldCancel())
        }
        guard context.validHand, limits.samples > 0, limits.seconds > 0, !stopped() else { return fallback(0) }
        let candidates = [BidRecommendation(bid: .pass)] + AdvancedBidPolicy.candidates(context)
        guard candidates.count > 1 else {
            return AIBidResult(recommendation: candidates[0], samples: 0, fallback: false, cancelled: shouldCancel())
        }
        var rng = AISeededGenerator(state: seed)
        var totals = Array(repeating: 0.0, count: candidates.count)
        var contracts = Array(repeating: 0, count: candidates.count)
        var made = contracts
        for sample in 0..<limits.samples {
            guard !stopped(), let hands = BiddingHandSampler.sample(context, using: &rng) else { return fallback(sample) }
            for index in candidates.indices {
                guard let result = rollout(context, hands: hands, root: candidates[index], shouldStop: stopped) else { return fallback(sample) }
                totals[index] += result.utility
                if result.ownContract {
                    contracts[index] += 1
                    if result.made { made[index] += 1 }
                }
            }
        }
        guard !stopped() else { return fallback(limits.samples) }
        var best = 0 // Pass wins ties and avoids gratuitous partner raises.
        let margin = context.auction.currentHighestBidder == context.auction.partnerSeat ? 1.5 : 0.5
        for index in candidates.indices.dropFirst() {
            let success = contracts[index] > 0 ? Double(made[index]) / Double(contracts[index]) : 0
            guard success >= (candidates[index].bid == .thirteen ? 0.97 : 0.60),
                  totals[index] > totals[0] + margin * Double(limits.samples) else { continue }
            if best == 0 || totals[index] > totals[best] + 1e-10 { best = index }
        }
        let confidence = contracts[best] > 0 ? Double(made[best]) / Double(contracts[best]) : 0
        return AIBidResult(recommendation: BidRecommendation(bid: candidates[best].bid,
            preferredTarneebSuit: candidates[best].preferredTarneebSuit, confidence: confidence),
            samples: limits.samples, fallback: false, cancelled: false)
    }
}

enum AIBiddingEngine {
    static func select(_ request: AIBidRequest, seed: UInt64,
                       limits: AIBidSearchLimits = AIBidSearchLimits(), shouldCancel: () -> Bool = { false }) -> AIBidResult {
        guard request.useSkillPolicy, request.skill != .standard else {
            return AIBidResult(recommendation: request.baseline, samples: 0, fallback: false, cancelled: shouldCancel())
        }
        if request.skill == .advanced {
            return AIBidResult(recommendation: AdvancedBidPolicy.select(request.context), samples: 0, fallback: false, cancelled: shouldCancel())
        }
        return ExpertBidPolicy.select(request.context, seed: seed, limits: limits, shouldCancel: shouldCancel)
    }

    static func detached(_ request: AIBidRequest, seed: UInt64 = UInt64.random(in: .min ... .max),
                         limits: AIBidSearchLimits = AIBidSearchLimits()) async -> AIBidResult {
        let worker = Task.detached(priority: .userInitiated) {
            select(request, seed: seed, limits: limits, shouldCancel: { Task.isCancelled })
        }
        return await withTaskCancellationHandler(operation: { await worker.value }, onCancel: { worker.cancel() })
    }
}

/// Existing acceptance and partner checks remain in BiddingService.
struct PreparedBidRecommender: BidRecommending {
    let prepared: BidRecommendation
    func recommendation(for context: BidRecommendationContext) -> BidRecommendation { prepared }
}
