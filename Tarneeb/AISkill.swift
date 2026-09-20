import Foundation

enum AISkill: String, CaseIterable, Codable, Sendable {
    case standard, advanced, expert
    var title: String { rawValue.capitalized }
    static let preferenceKey = "tarneeb.aiSkill"
    static func preference(in defaults: UserDefaults = .standard) -> AISkill {
        AISkill(rawValue: defaults.string(forKey: preferenceKey) ?? "") ?? .standard
    }
}

struct AIPlayRequest: Sendable {
    let id: UUID
    let revision: UUID
    let context: AIDecisionContext
    let skill: AISkill
}

/// This is the entire information boundary. No GameState, deck, deal seed or other hands.
struct AIDecisionContext: Equatable, Sendable {
    let seat: Seat
    let ownHand: [Card]
    let trick: TrickPlayState
    let contract: Int
    let matchScore: GameScore

    var declaringTeam: Team { Team.forSeat(trick.declarerSeat) }
    var team: Team { Team.forSeat(seat) }
    var remainingTricks: Int { 13 - trick.completedTricks.count }
    var declaringTricks: Int { trick.partnershipTrickCount(for: trick.declarerSeat) }
    var legalCards: [Card] {
        let follow = ownHand.filter { $0.suit == trick.ledSuit }
        return follow.isEmpty ? ownHand : follow
    }
    var orderedCards: [Card] {
        TrickPlayRules.sortedLegalCardsForSimulatedPlay(legalCards, tarneebSuit: trick.tarneebSuit)
    }
    var playersStillToAct: [Seat] {
        var result: [Seat] = []
        var next = seat.nextCounterclockwiseDealer
        for _ in 0..<(3 - trick.currentTrick.count) {
            result.append(next)
            next = next.nextCounterclockwiseDealer
        }
        return result
    }
    func standard() -> Card? {
        AutomatedCardSelector.select(from: legalCards, for: seat, currentTrick: trick.currentTrick,
                                     tarneebSuit: trick.tarneebSuit, ownHand: ownHand,
                                     completedTricks: trick.completedTricks)
    }

    /// Actual round points, with a match-ending bonus; never substitutes another scoring rule.
    func utility(declaringWins: Int) -> Double {
        guard let result = TarneebScoringService().scoreRound(declaringTeam: declaringTeam,
                                                            bid: contract, declaringTricks: declaringWins) else { return 0 }
        var after = matchScore
        after.apply(result)
        let terminal = after.winnerTeam.map { $0 == team ? 64.0 : -64.0 } ?? 0
        return Double(result.scoreDelta(for: team) - result.scoreDelta(for: team.opponent)) + terminal
    }
}

/// Only this adapter touches authoritative state; it reads precisely the acting hand and public fields.
extension TrickPlayService {
    func decisionContext(in game: GameState, score: GameScore) -> AIDecisionContext? {
        guard game.phase == .trickPlay, let trick = game.trickPlayState,
              let seat = trick.currentTurnSeat, trick.pendingCompletedTrick == nil,
              let hand = game.players.first(where: { $0.seat == seat })?.hand,
              let contract = game.highestBidValue?.numericValue else { return nil }
        return AIDecisionContext(seat: seat, ownHand: hand, trick: trick, contract: contract, matchScore: score)
    }
}

struct PublicCardInference {
    let unseen: [Card]
    let voids: [Seat: Set<Suit>]
    let handSizes: [Seat: Int]

    init(_ context: AIDecisionContext) {
        let plays = context.trick.playedCards
        let known = Set(context.ownHand + plays.map(\.card))
        unseen = DeckFactory.makeCanonicalDeck().filter { !known.contains($0) }
        handSizes = Dictionary(uniqueKeysWithValues: Seat.dealOrder.map { seat in
            (seat, 13 - plays.filter { $0.seat == seat }.count)
        })
        var observed: [Seat: Set<Suit>] = [:]
        for trick in context.trick.completedTricks.map(\.playedCards) + [context.trick.currentTrick] {
            guard let led = trick.first?.card.suit else { continue }
            for play in trick where play.card.suit != led { observed[play.seat, default: []].insert(led) }
        }
        voids = observed
    }

    func couldHold(_ card: Card, seat: Seat) -> Bool { !(voids[seat]?.contains(card.suit) ?? false) }
    /// Evidence of a void, not proof that this opponent possesses a trump.
    /// The caller restricts this to opponents still to act in the current trick.
    func hasDemonstratedRuffRisk(for opponent: Seat, ledSuit: Suit, winningCard: Card, trump: Suit) -> Bool {
        guard ledSuit != trump, voids[opponent]?.contains(ledSuit) == true else { return false }
        return unseen.contains {
            $0.suit == trump && couldHold($0, seat: opponent)
            && (winningCard.suit != trump || $0.rank.aiPower > winningCard.rank.aiPower)
        }
    }
    func top(_ card: Card) -> Bool {
        !unseen.contains { $0.suit == card.suit && $0.rank.aiPower > card.rank.aiPower }
    }
}

extension Rank {
    var aiPower: Int { Rank.allCases.firstIndex(of: self)! + 2 }
}

enum AdvancedCardPolicy {
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
                // A demonstrated led-suit void is certain; possession of trump is
                // only possible. Keep this public-risk check independent of the
                // speculative higher-card estimate disabled after held-out tests.
                let publicRisk = opponentsAfter.contains {
                    inference.hasDemonstratedRuffRisk(for: $0, ledSuit: led,
                        winningCard: winningCard, trump: trump)
                }
                if publicRisk { survival *= 0.4 }
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

// Deliberately separate from the live Advanced policy. Replacing this rollout
// model with the public-threat revision regressed Expert in paired evaluation.
// Keep its established behavior until an independently validated search change.
enum ExpertRolloutCardPolicy {
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

struct AISeededGenerator: RandomNumberGenerator {
    var state: UInt64
    mutating func next() -> UInt64 {
        state &+= 0x9e3779b97f4a7c15
        var z = state
        z = (z ^ (z >> 30)) &* 0xbf58476d1ce4e5b9
        z = (z ^ (z >> 27)) &* 0x94d049bb133111eb
        return z ^ (z >> 31)
    }
}

enum PlausibleHandSampler {
    /// Randomized constrained backtracking, not a claim of uniform posterior sampling.
    /// Bids are deliberately unused: a bid cannot prove a holding.
    static func sample(_ context: AIDecisionContext, using rng: inout AISeededGenerator,
                       shouldStop: () -> Bool = { false }) -> [Seat: [Card]]? {
        let info = PublicCardInference(context)
        let seats = Seat.dealOrder.filter { $0 != context.seat }
        let observed = context.ownHand + context.trick.playedCards.map(\.card)
        guard Set(context.ownHand).count == context.ownHand.count,
              Set(observed).count == observed.count,
              context.ownHand.allSatisfy({ info.couldHold($0, seat: context.seat) }),
              context.ownHand.count == info.handSizes[context.seat],
              info.unseen.count == seats.reduce(0, { $0 + (info.handSizes[$1] ?? 0) }) else { return nil }
        var cards = info.unseen.shuffled(using: &rng)
        // Most constrained cards first. The shuffled index deterministically breaks ties.
        cards = cards.enumerated().sorted { lhs, rhs in
            let a = seats.filter { info.couldHold(lhs.element, seat: $0) }.count
            let b = seats.filter { info.couldHold(rhs.element, seat: $0) }.count
            return a == b ? lhs.offset < rhs.offset : a < b
        }.map(\.element)
        var capacity = seats.map { info.handSizes[$0] ?? 0 }
        var hands = Array(repeating: [Card](), count: seats.count)
        var nodes = 0
        func assign(_ index: Int) -> Bool {
            nodes += 1
            guard nodes <= 4096, !shouldStop() else { return false }
            if index == cards.count { return capacity.allSatisfy { $0 == 0 } }
            // Hall capacity check for every subset of the three hidden seats.
            for mask in 1..<8 {
                let subset = (0..<3).filter { mask & (1 << $0) != 0 }
                let required = subset.reduce(0) { $0 + capacity[$1] }
                let available = cards[index...].filter { card in subset.contains { info.couldHold(card, seat: seats[$0]) } }.count
                if required > available { return false }
            }
            let choices = (0..<3).filter { capacity[$0] > 0 && info.couldHold(cards[index], seat: seats[$0]) }.shuffled(using: &rng)
            for choice in choices {
                capacity[choice] -= 1
                hands[choice].append(cards[index])
                if assign(index + 1) { return true }
                hands[choice].removeLast()
                capacity[choice] += 1
            }
            return false
        }
        guard assign(0) else { return nil }
        var result = Dictionary(uniqueKeysWithValues: zip(seats, hands))
        result[context.seat] = context.ownHand
        return result
    }
}

struct AISearchLimits: Sendable {
    var samples = 8
    var maxTricks = 13
    var seconds = 0.15
}

struct AIDecisionResult: Sendable {
    let card: Card?
    let samples: Int
    let fallback: Bool
    let cancelled: Bool
}

enum ExpertCardPolicy {
    static func select(_ context: AIDecisionContext, seed: UInt64,
                       limits: AISearchLimits = AISearchLimits(),
                       shouldCancel: () -> Bool = { false }) -> AIDecisionResult {
        let start = ProcessInfo.processInfo.systemUptime
        func expired() -> Bool { ProcessInfo.processInfo.systemUptime - start >= limits.seconds }
        func fallback(_ count: Int) -> AIDecisionResult {
            AIDecisionResult(card: AdvancedCardPolicy.select(context), samples: count, fallback: true, cancelled: shouldCancel())
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
                    guard let play = next ?? ExpertRolloutCardPolicy.select(local), local.legalCards.contains(play),
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
        let advanced = ExpertRolloutCardPolicy.select(context)
        var best = cards.firstIndex(where: { $0 == advanced }) ?? 0
        for i in cards.indices where totals[i] > totals[best] + 1e-10 { best = i }
        return AIDecisionResult(card: cards[best], samples: limits.samples, fallback: false, cancelled: false)
    }
}

enum AIDecisionEngine {
    static func select(_ context: AIDecisionContext, skill: AISkill, seed: UInt64,
                       limits: AISearchLimits = AISearchLimits(), shouldCancel: () -> Bool = { false }) -> AIDecisionResult {
        switch skill {
        case .standard: return AIDecisionResult(card: context.standard(), samples: 0, fallback: false, cancelled: shouldCancel())
        case .advanced: return AIDecisionResult(card: AdvancedCardPolicy.select(context), samples: 0, fallback: false, cancelled: shouldCancel())
        case .expert: return ExpertCardPolicy.select(context, seed: seed, limits: limits, shouldCancel: shouldCancel)
        }
    }

    static func detached(_ context: AIDecisionContext, skill: AISkill,
                         seed: UInt64 = UInt64.random(in: .min ... .max),
                         limits: AISearchLimits = AISearchLimits()) async -> AIDecisionResult {
        let worker = Task.detached(priority: .userInitiated) {
            select(context, skill: skill, seed: seed, limits: limits, shouldCancel: { Task.isCancelled })
        }
        return await withTaskCancellationHandler(operation: { await worker.value }, onCancel: { worker.cancel() })
    }
}
