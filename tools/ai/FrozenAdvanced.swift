import Foundation

// Frozen September 17 pre-revision policies for offline regression comparisons.
enum FrozenAdvancedCardPolicy {
    /// Equal scores retain the existing economical rank/suit order, independent of hand ordering.
    static func select(_ context: AIDecisionContext) -> Card? {
        let ordered = context.orderedCards
        guard ordered.count > 1 else { return ordered.first }
        let inference = PublicCardInference(context)
        let trump = context.trick.tarneebSuit
        let hand = context.ownHand
        let ourTricks = context.trick.partnershipTrickCount(for: context.seat)
        let target = context.team == context.declaringTeam ? context.contract : 14 - context.contract
        let needed = max(0, target - ourTricks)
        // Urgency rises at the scoring discontinuity and when every remaining trick is needed.
        let projected = min(12, context.declaringTricks + max(0, context.remainingTricks - 1) / 2)
        let scoreSwing = abs(context.utility(declaringWins: projected + 1) - context.utility(declaringWins: projected))
        let urgency = (needed == 1 ? 1.35 : (needed >= context.remainingTricks ? 1.6 : 1.0))
            * (1 + min(1, scoreSwing / 32))
        let currentWinner = context.trick.ledSuit.flatMap {
            TrickPlayRules.winner(for: context.trick.currentTrick, ledSuit: $0, tarneebSuit: trump)
        }
        let opponentsAfter = context.playersStillToAct.filter { Team.forSeat($0) != context.team }
        let outstandingTrump = inference.unseen.filter { $0.suit == trump }
        let ourTrump = hand.filter { $0.suit == trump }
        func ruffRisk(_ suit: Suit) -> Bool {
            suit != trump && opponentsAfter.contains { opponent in
                (inference.voids[opponent]?.contains(suit) ?? false) && outstandingTrump.contains { inference.couldHold($0, seat: opponent) }
            }
        }
        func score(_ card: Card) -> Double {
            let length = hand.filter { $0.suit == card.suit }.count
            let top = inference.top(card)
            // Preserve side entries and the last trump control when shedding losing cards.
            let cost = Double(card.rank.aiPower) * 0.025 + (card.suit == trump ? 0.38 : 0)
                + (top ? 0.28 : 0) + (top && length == 1 ? 0.18 : 0)
            if context.trick.currentTrick.isEmpty {
                var value = top ? 1.5 * urgency : 0
                value -= cost
                if ruffRisk(card.suit) { value -= 2.5 }
                // Establish length when no cashable winner is available.
                if card.suit != trump { value += Double(max(0, length - 2)) * 0.19 }
                // Draw outstanding trump from strength on the declaring side, retaining an entry.
                if card.suit == trump {
                    if context.team == context.declaringTeam && ourTrump.count >= 3 && !outstandingTrump.isEmpty {
                        value += top ? 1.3 : -0.4
                    } else { value -= 0.65 }
                    if outstandingTrump.isEmpty { value -= 0.8 }
                }
                return value
            }
            let led = context.trick.ledSuit!
            let after = context.trick.currentTrick + [PlayedCard(seat: context.seat, card: card)]
            guard let winner = TrickPlayRules.winner(for: after, ledSuit: led, tarneebSuit: trump),
                  let winningCard = after.first(where: { $0.seat == winner })?.card else { return -cost }
            var survival = Team.forSeat(winner) == context.team ? 1.0 : 0.0
            if survival > 0 {
                for opponent in opponentsAfter {
                    let possible = inference.unseen.filter { inference.couldHold($0, seat: opponent) }
                    let higher = possible.filter {
                        ($0.suit == winningCard.suit && $0.rank.aiPower > winningCard.rank.aiPower)
                        || (winningCard.suit != trump && $0.suit == trump && (inference.voids[opponent]?.contains(led) ?? false))
                    }.count
                    // Marginal public estimate only; never treats an unobserved void as certain.
                    let slots = inference.handSizes[opponent] ?? 0
                    let miss = pow(max(0, 1 - Double(higher) / Double(max(1, possible.count))), Double(slots))
                    survival *= miss
                }
            }
            var value = 2.7 * urgency * survival - cost
            if currentWinner == context.seat.partnerSeat && winner == context.seat {
                value -= 0.28 // Require meaningful protection to spend partner's entry.
            }
            if card.suit == trump && ourTrump.count == 1 && !top { value -= 0.12 }
            return value
        }
        var best = ordered[0]
        var bestScore = score(best)
        for card in ordered.dropFirst() {
            let value = score(card)
            if value > bestScore + 1e-10 { best = card; bestScore = value }
        }
        return best
    }
}

enum FrozenExpertCardPolicy {
    static func select(_ context: AIDecisionContext, seed: UInt64,
                       limits: AISearchLimits = AISearchLimits(),
                       shouldCancel: () -> Bool = { false }) -> AIDecisionResult {
        let start = ProcessInfo.processInfo.systemUptime
        func expired() -> Bool { ProcessInfo.processInfo.systemUptime - start >= limits.seconds }
        func fallback(_ count: Int) -> AIDecisionResult {
            AIDecisionResult(card: FrozenAdvancedCardPolicy.select(context), samples: count, fallback: true, cancelled: shouldCancel())
        }
        let cards = context.orderedCards
        guard cards.count > 1 else { return AIDecisionResult(card: cards.first, samples: 0, fallback: false, cancelled: shouldCancel()) }
        guard limits.samples > 0, limits.maxTricks > 0, limits.seconds > 0 else { return fallback(0) }
        var rng = AISeededGenerator(state: seed)
        var totals = Array(repeating: 0.0, count: cards.count)
        for sample in 0..<limits.samples {
            guard !shouldCancel(), !expired(),
                  let assignment = PlausibleHandSampler.sample(context, using: &rng, shouldStop: { shouldCancel() || expired() }) else { return fallback(sample) }
            for (index, card) in cards.enumerated() {
                var hands = assignment
                var trick = context.trick
                var next: Card? = card
                let end = min(13, trick.completedTricks.count + limits.maxTricks)
                while trick.completedTricks.count < end {
                    if shouldCancel() || expired() { return fallback(sample) }
                    guard let actor = trick.currentTurnSeat, let hand = hands[actor] else { return fallback(sample) }
                    // Each policy sees only its own sampled hand. No double-dummy solver,
                    // no branch choosing later actions by consulting the full assignment.
                    let local = AIDecisionContext(seat: actor, ownHand: hand, trick: trick,
                                                  contract: context.contract, matchScore: context.matchScore)
                    guard let play = next ?? FrozenAdvancedCardPolicy.select(local), local.legalCards.contains(play),
                          let position = hands[actor]?.firstIndex(of: play) else { return fallback(sample) }
                    next = nil
                    hands[actor]?.remove(at: position)
                    trick.appendPlayedCard(PlayedCard(seat: actor, card: play))
                    if trick.pendingCompletedTrick != nil { trick.clearPendingCompletedTrick() }
                }
                let won = trick.partnershipTrickCount(for: trick.declarerSeat)
                let remaining = 13 - trick.completedTricks.count
                // Truncated rollouts integrate all possible terminal scores under a neutral
                // binomial continuation; production uses full-hand rollouts when affordable.
                var expected = 0.0
                var probability = pow(0.5, Double(remaining))
                for additional in 0...remaining {
                    expected += probability * context.utility(declaringWins: won + additional)
                    if additional < remaining { probability *= Double(remaining - additional) / Double(additional + 1) }
                }
                totals[index] += expected
            }
        }
        guard !shouldCancel(), !expired() else { return fallback(limits.samples) }
        let advanced = FrozenAdvancedCardPolicy.select(context)
        var best = cards.firstIndex(where: { $0 == advanced }) ?? 0
        for i in cards.indices where totals[i] > totals[best] + 1e-10 { best = i }
        return AIDecisionResult(card: cards[best], samples: limits.samples, fallback: false, cancelled: false)
    }
}

enum FrozenExpertBidPolicy {
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
            guard let card = FrozenAdvancedCardPolicy.select(local), local.legalCards.contains(card),
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
