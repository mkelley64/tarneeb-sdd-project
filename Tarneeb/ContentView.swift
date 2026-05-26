import Foundation
import SwiftUI

struct ContentView: View {
    @State private var presentationState = TarneebPresentationState()
    @State private var gameState = GameState.initial
    private let cardSizeConfiguration = CardSizeConfiguration.sharedBase

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Tarneeb")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(GameColorRole.textPrimary.token.swiftUIColor)
                    .accessibilityIdentifier("tarneeb-title")
                    .accessibilityValue("text=\(GameColorRole.textPrimary.token.rawValue)")

                if gameState.phase == .dealt {
                    Text("Deal complete")
                        .font(.headline)
                        .foregroundStyle(GameColorRole.textPrimary.token.swiftUIColor)
                        .accessibilityIdentifier("tarneeb-deal-complete-message")
                        .accessibilityValue("text=\(GameColorRole.textPrimary.token.rawValue)")
                }

                if gameState.phase == .notStarted {
                    Button("Deal Cards", action: dealCards)
                        .buttonStyle(TokenButtonStyle(tokens: .deal))
                        .accessibilityIdentifier("tarneeb-deal-cards-button")
                        .accessibilityValue(ButtonTokenSet.deal.accessibilityValue)
                } else {
                    Button("New Deal", action: newDeal)
                        .buttonStyle(TokenButtonStyle(tokens: .newDeal))
                        .accessibilityIdentifier("tarneeb-new-deal-button")
                        .accessibilityValue(ButtonTokenSet.newDeal.accessibilityValue)
                }

                playerAreas
            }
            .padding()
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("tarneeb-table-surface")
            .accessibilityValue("background=\(GameColorRole.tableSurface.token.rawValue)")
        }
        .background(GameColorRole.tableSurface.token.swiftUIColor)
    }

    private var playerAreas: some View {
        VStack(spacing: 12) {
            centeredPlayerArea(for: player(for: .north))

            HStack(alignment: .center, spacing: 12) {
                playerArea(for: player(for: .west))

                Spacer(minLength: 12)

                playerArea(for: player(for: .east))
            }

            playerArea(for: player(for: .south))
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-diamond-table")
        .accessibilityValue(
            "table=\(GameColorRole.tableSurface.token.rawValue);label=\(GameColorRole.textPrimary.token.rawValue);station=\(GameColorRole.stationOutline.token.rawValue)"
        )
    }

    private func centeredPlayerArea(for player: Player) -> some View {
        HStack {
            Spacer(minLength: 0)
            playerArea(for: player)
            Spacer(minLength: 0)
        }
    }

    private func playerArea(for player: Player) -> some View {
        VStack(spacing: 8) {
            Text(player.seat.displayLabel)
                .font(.headline)
                .foregroundStyle(GameColorRole.textPrimary.token.swiftUIColor)
                .accessibilityIdentifier("tarneeb-seat-\(player.seat.rawValue)")
                .accessibilityValue("text=\(GameColorRole.textPrimary.token.rawValue)")

            if gameState.phase == .dealt {
                if player.seat == .south {
                    visibleHand(for: player)
                } else {
                    hiddenHand(for: player)
                }
            }
        }
        .frame(maxWidth: stationMaxWidth(for: player), minHeight: stationMinHeight(for: player))
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(GameColorRole.stationOutline.token.swiftUIColor, lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-seat-area-\(player.seat.rawValue)")
        .accessibilityValue(
            "label=\(GameColorRole.textPrimary.token.rawValue);outline=\(GameColorRole.stationOutline.token.rawValue)"
        )
    }

    private func visibleHand(for player: Player) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.adaptive(minimum: cardSizeConfiguration.baseCardWidth), spacing: 4)
            ],
            spacing: 4
        ) {
            ForEach(SouthHandPresentation.cardPresentations(from: player.hand, sizeConfiguration: cardSizeConfiguration), id: \.cardID) { presentation in
                Text(presentation.displayLabel)
                    .font(.system(size: cardSizeConfiguration.rankFontPointSize, weight: .semibold))
                    .frame(width: cardSizeConfiguration.baseCardWidth, height: cardSizeConfiguration.baseCardHeight)
                    .foregroundStyle(presentation.suitColorToken.swiftUIColor)
                    .background(
                        RoundedRectangle(cornerRadius: cardSizeConfiguration.cornerRadius)
                            .fill(GameColorRole.cardFace.token.swiftUIColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: cardSizeConfiguration.cornerRadius)
                                    .stroke(GameColorRole.cardBorder.token.swiftUIColor, lineWidth: 1)
                            )
                    )
                    .shadow(color: GameColorRole.cardShadow.token.swiftUIColor, radius: 1, y: 1)
                    .accessibilityLabel(presentation.accessibilityLabel)
                    .accessibilityIdentifier("tarneeb-visible-card")
                    .accessibilityValue(presentation.accessibilityValue)
            }
        }
        .accessibilityIdentifier("tarneeb-visible-hand-\(player.seat.rawValue)")
    }

    private func hiddenHand(for player: Player) -> some View {
        let presentation = HiddenHandPresentation(
            seat: player.seat,
            hiddenCardCount: player.hand.count,
            sizeConfiguration: cardSizeConfiguration
        )

        return ZStack(alignment: .leading) {
            ForEach(presentation.hiddenCards) { hiddenCard in
                Image(hiddenCard.assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: hiddenCard.sizeConfiguration.baseCardWidth,
                        height: hiddenCard.sizeConfiguration.baseCardHeight
                    )
                    .offset(x: Double(hiddenCard.index) * presentation.stackOffset)
                    .accessibilityLabel(hiddenCard.accessibilityLabel)
                    .accessibilityIdentifier("tarneeb-hidden-card-back-\(player.seat.rawValue)")
                    .accessibilityValue(hiddenCard.accessibilityValue)
            }
        }
        .frame(width: presentation.stackWidth, height: presentation.sizeConfiguration.baseCardHeight, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-hidden-hand-\(player.seat.rawValue)")
    }

    private func dealCards() {
        presentationState.dealCards()
        gameState = presentationState.gameState
    }

    private func newDeal() {
        presentationState.newDeal()
        gameState = presentationState.gameState
    }

    private func player(for seat: Seat) -> Player {
        guard let player = gameState.players.first(where: { $0.seat == seat }) else {
            preconditionFailure("Expected player for \(seat.rawValue) seat.")
        }

        return player
    }

    private func stationMaxWidth(for player: Player) -> CGFloat? {
        player.seat == .south ? nil : 156
    }

    private func stationMinHeight(for player: Player) -> CGFloat {
        switch (gameState.phase, player.seat) {
        case (.dealt, .south):
            return 170
        case (.dealt, _):
            return 96
        case (.notStarted, _):
            return 56
        }
    }
}

private struct TokenButtonStyle: ButtonStyle {
    let tokens: ButtonTokenSet

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(tokens.text.swiftUIColor)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill((configuration.isPressed ? tokens.pressedBackground : tokens.background).swiftUIColor)
            )
    }
}

private extension GameColorToken {
    var swiftUIColor: Color {
        Color(hexValue: hexValue)
    }
}

private extension Color {
    init(hexValue: String) {
        let sanitizedHex = hexValue.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let value = UInt64(sanitizedHex, radix: 16) ?? 0

        let red: Double
        let green: Double
        let blue: Double
        let opacity: Double

        switch sanitizedHex.count {
        case 8:
            red = Double((value & 0xFF000000) >> 24) / 255
            green = Double((value & 0x00FF0000) >> 16) / 255
            blue = Double((value & 0x0000FF00) >> 8) / 255
            opacity = Double(value & 0x000000FF) / 255
        case 6:
            red = Double((value & 0xFF0000) >> 16) / 255
            green = Double((value & 0x00FF00) >> 8) / 255
            blue = Double(value & 0x0000FF) / 255
            opacity = 1
        default:
            red = 0
            green = 0
            blue = 0
            opacity = 1
        }

        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

#Preview {
    ContentView()
}
