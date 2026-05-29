import SwiftUI

struct ContentView: View {
    @State private var presentationState = TarneebPresentationState()
    @State private var gameState = GameState.initial

    private let cardSizeConfiguration = CardSizeConfiguration.sharedBase
    private let tableTitle = TableTitlePresentation()

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                ScrollView {
                    tableScene(screenWidth: proxy.size.width)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 4)
                        .padding(.top, 10)
                        .padding(.bottom, 12)
                }

                bottomDealControl
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .background(GameColorRole.tableSurface.token.swiftUIColor)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("tarneeb-table-surface")
            .accessibilityValue("background=\(GameColorRole.tableSurface.token.rawValue)")
        }
    }

    private func tableScene(screenWidth: CGFloat) -> some View {
        let metrics = TableLayoutMetrics(screenWidth: screenWidth)

        return VStack(spacing: metrics.verticalSpacing) {
            playerStation(for: player(for: .north), metrics: metrics)

            HStack(alignment: .center, spacing: metrics.horizontalSpacing) {
                playerStation(for: player(for: .west), metrics: metrics)

                circularCardTable(metrics: metrics)

                playerStation(for: player(for: .east), metrics: metrics)
            }

            playerStation(for: player(for: .south), metrics: metrics)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-table-scene")
        .accessibilityValue(
            "table=\(GameColorRole.tableSurface.token.rawValue);label=\(GameColorRole.textPrimary.token.rawValue);station=\(GameColorRole.stationOutline.token.rawValue);diameter=\(Int(metrics.tableDiameter.rounded()))"
        )
    }

    private func circularCardTable(metrics: TableLayoutMetrics) -> some View {
        let centralDeckStack = CentralDeckStackPresentation(
            phase: gameState.phase,
            sizeConfiguration: cardSizeConfiguration
        )

        return ZStack {
            Circle()
                .fill(GameColorRole.tableSurfaceSecondary.token.swiftUIColor)
                .overlay(
                    Circle()
                        .stroke(GameColorRole.tableHighlight.token.swiftUIColor, lineWidth: 2)
                )

            tableTitleView()

            if centralDeckStack.isVisible {
                centralDeckStackView(centralDeckStack)
                    .offset(y: CGFloat(centralDeckStack.verticalOffset))
            }
        }
        .frame(width: metrics.tableDiameter, height: metrics.tableDiameter)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-card-table")
        .accessibilityValue(
            "shape=circle;diameter=\(Int(metrics.tableDiameter.rounded()));surface=\(GameColorRole.tableSurfaceSecondary.token.rawValue);highlight=\(GameColorRole.tableHighlight.token.rawValue)"
        )
    }

    private func tableTitleView() -> some View {
        Text(tableTitle.text)
            .font(.system(size: CGFloat(tableTitle.fontPointSize), weight: .bold, design: .rounded))
            .tracking(tableTitle.tracking)
            .foregroundStyle(
                tableTitle.textColorRole.token.swiftUIColor.opacity(tableTitle.textOpacityToken.value)
            )
            .shadow(
                color: tableTitle.shadowColorRole.token.swiftUIColor.opacity(
                    tableTitle.usesShadow ? tableTitle.shadowOpacityToken.value : 0
                ),
                radius: tableTitle.usesShadow ? tableTitle.shadowBlurRadiusToken.value : 0
            )
            .minimumScaleFactor(0.72)
            .lineLimit(1)
            .accessibilityIdentifier("tarneeb-title")
            .accessibilityValue(tableTitle.accessibilityValue)
    }

    private func centralDeckStackView(_ presentation: CentralDeckStackPresentation) -> some View {
        ZStack(alignment: .leading) {
            ForEach(presentation.hiddenCards) { hiddenCard in
                Image(hiddenCard.assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: hiddenCard.sizeConfiguration.baseCardWidth,
                        height: hiddenCard.sizeConfiguration.baseCardHeight
                    )
                    .offset(x: Double(hiddenCard.index) * presentation.stackOffset)
                    .accessibilityLabel("Deck card back")
                    .accessibilityIdentifier("tarneeb-deck-stack-card")
                    .accessibilityValue("asset=card_back;hidden=true;size=\(hiddenCard.sizeConfiguration.category.rawValue)")
            }
        }
        .frame(width: presentation.stackWidth, height: presentation.sizeConfiguration.baseCardHeight)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-central-deck-stack")
        .accessibilityValue(presentation.accessibilityValue)
    }

    @ViewBuilder
    private func playerStation(for player: Player, metrics: TableLayoutMetrics) -> some View {
        let stationContent = VStack(spacing: 4) {
            Text(player.seat.displayLabel)
                .font(.headline)
                .foregroundStyle(GameColorRole.textPrimary.token.swiftUIColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
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
        .padding(4)

        if player.seat == .south && gameState.phase == .dealt {
            stationContent
                .frame(maxWidth: metrics.southStationMaxWidth)
                .frame(minHeight: metrics.southStationMinHeight)
                .background(
                    RoundedRectangle(cornerRadius: metrics.stationCornerRadius)
                        .stroke(GameColorRole.stationOutline.token.swiftUIColor, lineWidth: 1)
                )
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("tarneeb-seat-area-\(player.seat.rawValue)")
                .accessibilityValue(stationAccessibilityValue(for: player, metrics: metrics))
        } else {
            stationContent
                .frame(width: metrics.compactStationSide, height: metrics.compactStationSide)
                .background(
                    RoundedRectangle(cornerRadius: metrics.stationCornerRadius)
                        .stroke(GameColorRole.stationOutline.token.swiftUIColor, lineWidth: 1)
                )
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("tarneeb-seat-area-\(player.seat.rawValue)")
                .accessibilityValue(stationAccessibilityValue(for: player, metrics: metrics))
        }
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
        .accessibilityValue("count=\(presentation.hiddenCardCount);asset=card_back;hidden=true;size=\(presentation.sizeConfiguration.category.rawValue)")
    }

    private var bottomDealControl: some View {
        VStack(spacing: 6) {
            if gameState.phase == .dealt {
                Text("Deal complete")
                    .font(.headline)
                    .foregroundStyle(GameColorRole.textPrimary.token.swiftUIColor)
                    .accessibilityIdentifier("tarneeb-deal-complete-message")
                    .accessibilityValue("text=\(GameColorRole.textPrimary.token.rawValue)")
            }

            HStack(spacing: 10) {
                Button(PresentationAction.newGame.visibleLabel, action: newGame)
                    .buttonStyle(TokenButtonStyle(tokens: .newGame))
                    .accessibilityIdentifier("tarneeb-new-game-button")
                    .accessibilityValue(ButtonTokenSet.newGame.accessibilityValue)

                Button(PresentationAction.deal.visibleLabel, action: deal)
                    .buttonStyle(TokenButtonStyle(tokens: .deal))
                    .accessibilityIdentifier("tarneeb-deal-button")
                    .accessibilityValue(ButtonTokenSet.deal.accessibilityValue)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 18)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .background(GameColorRole.tableSurface.token.swiftUIColor)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-bottom-deal-control")
        .accessibilityValue("buttons=New Game,Deal;newGameTokens=\(ButtonTokenSet.newGame.accessibilityValue);dealTokens=\(ButtonTokenSet.deal.accessibilityValue)")
    }

    private func deal() {
        presentationState.deal()
        gameState = presentationState.gameState
    }

    private func newGame() {
        presentationState.newGame()
        gameState = presentationState.gameState
    }

    private func player(for seat: Seat) -> Player {
        guard let player = gameState.players.first(where: { $0.seat == seat }) else {
            preconditionFailure("Expected player for \(seat.rawValue) seat.")
        }

        return player
    }

    private func stationAccessibilityValue(for player: Player, metrics: TableLayoutMetrics) -> String {
        let stateValue = gameState.phase == .dealt ? "dealt" : "notStarted"
        let shapeValue = player.seat == .south && gameState.phase == .dealt ? "expandedRoundedStation" : "roundedSquare"

        return [
            "label=\(GameColorRole.textPrimary.token.rawValue)",
            "outline=\(GameColorRole.stationOutline.token.rawValue)",
            "shape=\(shapeValue)",
            "position=\(player.seat.rawValue)",
            "state=\(stateValue)",
            "compactSide=\(Int(metrics.compactStationSide.rounded()))"
        ].joined(separator: ";")
    }

}

private struct TableLayoutMetrics {
    let screenWidth: CGFloat

    var tableDiameter: CGFloat {
        screenWidth * 0.5
    }

    var compactStationSide: CGFloat {
        min(112, max(86, screenWidth * 0.23))
    }

    var southStationMaxWidth: CGFloat {
        max(280, screenWidth - 16)
    }

    var southStationMinHeight: CGFloat {
        142
    }

    var stationCornerRadius: CGFloat {
        12
    }

    var horizontalSpacing: CGFloat {
        6
    }

    var verticalSpacing: CGFloat {
        10
    }

}

private struct TokenButtonStyle: ButtonStyle {
    let tokens: ButtonTokenSet

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(tokens.text.swiftUIColor)
            .padding(.horizontal, 22)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
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
