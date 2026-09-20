// Frozen before skill routing changes. Do not tune this benchmark oracle.
enum FrozenStandard {
    // Unknown cards stay possible in any other hand; only public history is tracked.
    static func select(
        from legalCards: [Card],
        for seat: Seat,
        currentTrick: [PlayedCard],
        tarneebSuit: Suit,
        ownHand: [Card] = [],
        completedTricks: [CompletedTrick] = []
    ) -> Card? {
        let economicalCards = legalCards.sorted { lhs, rhs in
            let left = lhs.rank.frozenPower + (lhs.suit == tarneebSuit ? 100 : 0)
            let right = rhs.rank.frozenPower + (rhs.suit == tarneebSuit ? 100 : 0)
            return left == right ? Suit.allCases.firstIndex(of: lhs.suit)! < Suit.allCases.firstIndex(of: rhs.suit)! : left < right
        }
        guard let discard = economicalCards.first else { return nil }
        let known = Set(ownHand + legalCards + completedTricks.flatMap(\.playedCards).map(\.card) + currentTrick.map(\.card))
        func isTopRemaining(_ card: Card) -> Bool {
            Rank.allCases.filter { $0.frozenPower > card.rank.frozenPower }
                .allSatisfy { known.contains(Card(suit: card.suit, rank: $0)) }
        }
        let opponents = Seat.allCases.filter { $0 != seat && $0 != seat.partnerSeat }
        func isRiskyLead(_ suit: Suit) -> Bool {
            let unknownTrump = Rank.allCases.contains { !known.contains(Card(suit: tarneebSuit, rank: $0)) }
            return suit != tarneebSuit && unknownTrump && completedTricks.contains { trick in
                trick.ledSuit == suit && trick.playedCards.contains { opponents.contains($0.seat) && $0.card.suit != suit }
            }
        }
        guard let ledSuit = currentTrick.first?.card.suit,
              let winner = TrickPlayRules.winner(for: currentTrick, ledSuit: ledSuit, tarneebSuit: tarneebSuit) else {
            let safe = economicalCards.filter { $0.suit != tarneebSuit && !isRiskyLead($0.suit) }
            return safe.first(where: isTopRemaining) ?? safe.first ?? discard
        }

        if winner == seat.partnerSeat {
            if currentTrick.count == 2,
               let partnerCard = currentTrick.first(where: { $0.seat == winner })?.card,
               partnerCard.suit == ledSuit, !isTopRemaining(partnerCard),
               !isRiskyLead(ledSuit),
               let cover = economicalCards.first(where: {
                   $0.suit == ledSuit && isTopRemaining($0) && $0.rank.frozenPower > partnerCard.rank.frozenPower
               }) { return cover }
            return discard
        }

        return economicalCards.first { card in
            TrickPlayRules.winner(
                for: currentTrick + [PlayedCard(seat: seat, card: card)],
                ledSuit: ledSuit,
                tarneebSuit: tarneebSuit
            ) == seat
        } ?? discard
    }
}

private extension Rank {
    var frozenPower: Int { Rank.allCases.firstIndex(of: self)! + 2 }
}
