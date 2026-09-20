import Foundation

/// Post-selection descriptive audit, never used to select or tune weights.
/// Compiled separately so the frozen training/evaluation executable is unchanged.
@main
enum AdvancedTacticAudit {
    static func main() throws {
        let data = try Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let selected = json["selected"] as! [String: Any]
        let weights = AblationWeights(values: selected["values"] as! [Double])
        func card(_ suit: Suit, _ rank: Rank) -> Card { Card(suit: suit, rank: rank) }
        func context(_ hand: [Card], plays: [PlayedCard] = [], history: [CompletedTrick] = []) -> AIDecisionContext {
            AIDecisionContext(seat: .south, ownHand: hand,
                trick: TrickPlayState(declarerSeat: .south, tarneebSuit: .spades,
                    currentTurnSeat: .south, currentTrick: plays, completedTricks: history),
                contract: 7, matchScore: GameScore())
        }
        let observedVoid = CompletedTrick(leaderSeat: .south, winnerSeat: .east, ledSuit: .clubs, playedCards: [
            PlayedCard(seat: .south, card: card(.clubs,.two)), PlayedCard(seat: .east, card: card(.spades,.two)),
            PlayedCard(seat: .north, card: card(.clubs,.three)), PlayedCard(seat: .west, card: card(.clubs,.four))])
        let cases: [(String,AIDecisionContext)] = [
            ("draw trump", context([card(.spades,.ace),card(.spades,.king),card(.spades,.five),card(.clubs,.two)])),
            ("establish long suit", context([card(.clubs,.three),card(.clubs,.four),card(.clubs,.jack),
                card(.clubs,.queen),card(.clubs,.king),card(.diamonds,.two)])),
            ("second seat economy versus possible later winners", context([card(.clubs,.two),card(.clubs,.seven),card(.clubs,.ace)],
                plays: [PlayedCard(seat: .west, card: card(.clubs,.six))])),
            ("preserve secure partner", context([card(.clubs,.ace),card(.clubs,.two)], plays: [
                PlayedCard(seat: .east, card: card(.clubs,.three)), PlayedCard(seat: .north, card: card(.clubs,.queen)),
                PlayedCard(seat: .west, card: card(.clubs,.four))])),
            ("avoid known ruff on lead", context([card(.clubs,.ace),card(.diamonds,.ace)], history: [observedVoid])),
            ("protect vulnerable partner against known ruff", context([card(.spades,.ace),card(.diamonds,.two)], plays: [
                PlayedCard(seat: .north, card: card(.clubs,.queen)), PlayedCard(seat: .west, card: card(.clubs,.six))], history: [observedVoid]))
        ]
        func label(_ card: Card?) -> String { card.map { "\($0.rank.rawValue) \($0.suit.rawValue)" } ?? "nil" }
        let result: [[String: String]] = cases.map { name, c in
            ["position": name, "standard": label(c.standard()), "originalAdvanced": label(FrozenAdvancedCardPolicy.select(c)),
             "calibrated": label(AblationCardPolicy.select(c, weights: weights))]
        }
        print(String(decoding: try JSONSerialization.data(withJSONObject: result, options: [.prettyPrinted,.sortedKeys]), as: UTF8.self))
    }
}
