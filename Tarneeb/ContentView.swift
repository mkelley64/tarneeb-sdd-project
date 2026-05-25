import SwiftUI

struct ContentView: View {
    @State private var presentationState = TarneebPresentationState()
    @State private var gameState = GameState.initial

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Tarneeb")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                if gameState.phase == .dealt {
                    Text("Deal complete")
                        .font(.headline)
                }

                playerAreas

                if gameState.phase == .notStarted {
                    Button("Deal Cards", action: dealCards)
                        .buttonStyle(.borderedProminent)
                } else {
                    Button("New Deal", action: newDeal)
                        .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
    }

    private var playerAreas: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            spacing: 12
        ) {
            ForEach(gameState.players) { player in
                playerArea(for: player)
            }
        }
    }

    private func playerArea(for player: Player) -> some View {
        VStack(spacing: 8) {
            Text(player.seat.displayLabel)
                .font(.headline)
                .accessibilityIdentifier("tarneeb-seat-\(player.seat.rawValue)")

            if gameState.phase == .dealt {
                if player.seat == .south {
                    visibleHand(for: player)
                } else {
                    hiddenHand(for: player)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: gameState.phase == .dealt ? 160 : 72)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.secondary, lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-seat-area-\(player.seat.rawValue)")
    }

    private func visibleHand(for player: Player) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.adaptive(minimum: 40), spacing: 4)
            ],
            spacing: 4
        ) {
            ForEach(player.hand.sortedForSouthDisplay) { card in
                Text(card.displayLabel)
                    .font(.caption)
                    .frame(minWidth: 34, minHeight: 28)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(.secondary.opacity(0.6), lineWidth: 1)
                    )
                    .accessibilityIdentifier("tarneeb-visible-card")
            }
        }
    }

    private func hiddenHand(for player: Player) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.adaptive(minimum: 22), spacing: 3)
            ],
            spacing: 3
        ) {
            ForEach(player.hand.indices, id: \.self) { _ in
                Image("card_back")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 28)
                    .accessibilityLabel("Card back")
                    .accessibilityIdentifier("tarneeb-hidden-card-back-\(player.seat.rawValue)")
            }
        }
    }

    private func dealCards() {
        presentationState.dealCards()
        gameState = presentationState.gameState
    }

    private func newDeal() {
        presentationState.newDeal()
        gameState = presentationState.gameState
    }
}

private extension Card {
    var displayLabel: String {
        "\(rank.displayLabel)\(suit.displaySymbol)"
    }
}

private extension Array where Element == Card {
    var sortedForSouthDisplay: [Card] {
        sorted { lhs, rhs in
            if lhs.suit.southDisplayOrder != rhs.suit.southDisplayOrder {
                return lhs.suit.southDisplayOrder < rhs.suit.southDisplayOrder
            }

            return lhs.rank.displayOrder < rhs.rank.displayOrder
        }
    }
}

private extension Suit {
    var southDisplayOrder: Int {
        switch self {
        case .hearts:
            return 0
        case .clubs:
            return 1
        case .diamonds:
            return 2
        case .spades:
            return 3
        }
    }
}

private extension Rank {
    var displayOrder: Int {
        Rank.allCases.firstIndex(of: self) ?? 0
    }
}

#Preview {
    ContentView()
}
