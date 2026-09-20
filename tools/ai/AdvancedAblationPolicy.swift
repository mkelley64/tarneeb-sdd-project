import Foundation

// Offline research copy, never linked into the app. All-one parity is checked
// against the unchanged production implementation before any training run.
enum AblationFeature: String, CaseIterable, Codable {
    case cashWinners, entries, threats, partner, longSuits, trump, ruff, urgency
}
struct AblationWeights: Codable, Hashable {
    var values: [Double]
    static let zero = AblationWeights(values: Array(repeating: 0, count: 8))
    static let original = AblationWeights(values: Array(repeating: 1, count: 8))
    subscript(_ feature: AblationFeature) -> Double {
        get { values[AblationFeature.allCases.firstIndex(of: feature)!] }
        set { values[AblationFeature.allCases.firstIndex(of: feature)!] = newValue }
    }
    var key: String { values.map { String($0) }.joined(separator: ",") }
    var sum: Double { values.reduce(0,+) }
    func simpler(than other: Self) -> Bool {
        if sum != other.sum { return sum < other.sum }
        return values.lexicographicallyPrecedes(other.values)
    }
}

enum AblationCardPolicy {
    /// Equal scores retain the existing economical rank/suit order, independent of hand ordering.
    static func select(_ context: AIDecisionContext, weights w: AblationWeights) -> Card? {
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
        let originalUrgency = (needed == 1 ? 1.35 : (needed >= context.remainingTricks ? 1.6 : 1.0))
            * (1 + min(1, scoreSwing / 32))
        let urgency = 1 + w[.urgency] * (originalUrgency - 1)
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
                + w[.entries] * ((top ? 0.28 : 0) + (top && length == 1 ? 0.18 : 0))
            if context.trick.currentTrick.isEmpty {
                var value = top ? w[.cashWinners] * 1.5 * urgency : 0
                value -= cost
                if ruffRisk(card.suit) { value -= w[.ruff] * 2.5 }
                // Establish length when no cashable winner is available.
                if card.suit != trump { value += w[.longSuits] * Double(max(0, length - 2)) * 0.19 }
                // Draw outstanding trump from strength on the declaring side, retaining an entry.
                if card.suit == trump {
                    if context.team == context.declaringTeam && ourTrump.count >= 3 && !outstandingTrump.isEmpty {
                        value += w[.trump] * (top ? 1.3 : -0.4)
                    } else { value -= w[.trump] * 0.65 }
                    if outstandingTrump.isEmpty { value -= w[.trump] * 0.8 }
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
                    let rankThreats = possible.filter { $0.suit == winningCard.suit && $0.rank.aiPower > winningCard.rank.aiPower }.count
                    let ruffThreats = possible.filter {
                        winningCard.suit != trump && $0.suit == trump && (inference.voids[opponent]?.contains(led) ?? false)
                    }.count
                    let higher = Double(rankThreats) + w[.ruff] * Double(ruffThreats)
                    // Marginal public estimate only; never treats an unobserved void as certain.
                    let slots = inference.handSizes[opponent] ?? 0
                    let miss = pow(max(0, 1 - Double(higher) / Double(max(1, possible.count))), Double(slots))
                    survival *= w[.threats] == 0 ? 1 : pow(miss, w[.threats])
                }
            }
            var value = 2.7 * urgency * survival - cost
            if currentWinner == context.seat.partnerSeat && winner == context.seat {
                value -= w[.partner] * 0.28 // Require meaningful protection to spend partner's entry.
            }
            if card.suit == trump && ourTrump.count == 1 && !top { value -= w[.entries] * 0.12 }
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
