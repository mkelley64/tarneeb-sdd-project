import SwiftUI

struct ContentView: View {
    @State private var presentationState: TarneebPresentationState
    @State private var gameState: GameState
    @State private var pendingDealtState: GameState?
    @State private var dealAnimation: DealAnimationPlayback?
    @State private var lastDealAnimationPresentation: DealAnimationPresentation?

    private let cardSizeConfiguration = CardSizeConfiguration.sharedBase
    private let tableTitle = TableTitlePresentation()

    init(presentationState: TarneebPresentationState = TarneebPresentationState()) {
        _presentationState = State(initialValue: presentationState)
        _gameState = State(initialValue: presentationState.gameState)
    }

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

        return ZStack {
            VStack(spacing: metrics.verticalSpacing) {
                playerStation(for: displayPlayer(for: .north), metrics: metrics)

                HStack(alignment: .center, spacing: metrics.horizontalSpacing) {
                    playerStation(for: displayPlayer(for: .west), metrics: metrics)

                    circularCardTable(metrics: metrics)

                    playerStation(for: displayPlayer(for: .east), metrics: metrics)
                }

                playerStation(for: displayPlayer(for: .south), metrics: metrics)
            }

            if let movingStackPresentation = dealAnimation?.movingStackPresentation {
                movingDealStackView(movingStackPresentation)
                    .id(movingStackPresentation.targetSeat)
                    .offset(dealAnimationOffset(to: movingStackPresentation.targetSeat, metrics: metrics))
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-table-scene")
        .accessibilityValue(
            "table=\(GameColorRole.tableSurface.token.rawValue);label=\(GameColorRole.textPrimary.token.rawValue);station=\(GameColorRole.stationOutline.token.rawValue);dealer=\(gameState.dealerSeat.rawValue);diameter=\(Int(metrics.tableDiameter.rounded()));\(dealAnimationAccessibilityValue)"
        )
    }

    private func circularCardTable(metrics: TableLayoutMetrics) -> some View {
        let undealtDeckStack = currentUndealtDeckStackPresentation(
            sizeConfiguration: cardSizeConfiguration
        )
        let deckOffset = undealtDeckStack.layout.offset(forTableDiameter: Double(metrics.tableDiameter))

        return ZStack {
            Circle()
                .fill(GameColorRole.tableSurfaceSecondary.token.swiftUIColor)
                .overlay(
                    Circle()
                        .stroke(GameColorRole.tableHighlight.token.swiftUIColor, lineWidth: 2)
                )

            tableTitleView()

            if undealtDeckStack.isVisible && undealtDeckStack.hiddenCardCount > 0 {
                undealtDeckStackView(undealtDeckStack)
                    .offset(x: CGFloat(deckOffset.x), y: CGFloat(deckOffset.y))
            }

        }
        .frame(width: metrics.tableDiameter, height: metrics.tableDiameter)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-card-table")
        .accessibilityValue(
            "shape=circle;diameter=\(Int(metrics.tableDiameter.rounded()));surface=\(GameColorRole.tableSurfaceSecondary.token.rawValue);highlight=\(GameColorRole.tableHighlight.token.rawValue);dealer=\(gameState.dealerSeat.rawValue);\(dealAnimationAccessibilityValue)"
        )
    }

    private func currentUndealtDeckStackPresentation(sizeConfiguration: CardSizeConfiguration) -> UndealtDeckStackPresentation {
        if let dealAnimation {
            return UndealtDeckStackPresentation(
                phase: .notStarted,
                hiddenCardCount: dealAnimation.centralCardCount,
                sizeConfiguration: sizeConfiguration
            )
        }

        return UndealtDeckStackPresentation(
            phase: gameState.phase,
            sizeConfiguration: sizeConfiguration
        )
    }

    private func tableTitleView() -> some View {
        Text(tableTitle.text)
            .font(.custom(tableTitle.fontName, fixedSize: CGFloat(tableTitle.fontPointSize)))
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

    private func undealtDeckStackView(_ presentation: UndealtDeckStackPresentation) -> some View {
        ZStack {
            ForEach(presentation.hiddenCards) { hiddenCard in
                let transform = presentation.visualTransform(for: hiddenCard)

                Image(hiddenCard.assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: hiddenCard.sizeConfiguration.baseCardWidth,
                        height: hiddenCard.sizeConfiguration.baseCardHeight
                    )
                    .rotationEffect(.degrees(transform.rotationDegrees))
                    .offset(x: CGFloat(transform.offsetX), y: CGFloat(transform.offsetY))
                    .accessibilityLabel("Deck card back")
                    .accessibilityIdentifier("tarneeb-undealt-deck-stack-card")
                    .accessibilityValue("asset=card_back;hidden=true;size=\(hiddenCard.sizeConfiguration.category.rawValue)")
            }
        }
        .frame(width: presentation.stackWidth, height: presentation.stackHeight)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-undealt-deck-stack")
        .accessibilityValue(presentation.accessibilityValue)
    }

    private func movingDealStackView(_ presentation: DealAnimationStackPresentation) -> some View {
        ZStack {
            ForEach(presentation.hiddenCards) { hiddenCard in
                Image(hiddenCard.assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: hiddenCard.sizeConfiguration.baseCardWidth,
                        height: hiddenCard.sizeConfiguration.baseCardHeight
                    )
                    .accessibilityLabel("Deal animation card back")
                    .accessibilityIdentifier("tarneeb-deal-animation-stack-card")
                    .accessibilityValue("asset=card_back;hidden=true;size=\(hiddenCard.sizeConfiguration.category.rawValue)")
            }
        }
        .frame(width: presentation.stackWidth, height: presentation.stackHeight)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-deal-animation-stack")
        .accessibilityValue(presentation.accessibilityValue)
    }

    @ViewBuilder
    private func playerStation(for player: Player, metrics: TableLayoutMetrics) -> some View {
        let dealerPresentation = DealerStationPresentation(
            seat: player.seat,
            phase: gameState.phase,
            dealerSeat: gameState.dealerSeat
        )
        let stationContent = VStack(spacing: 4) {
            Text(player.seat.displayLabel)
                .font(.headline)
                .foregroundStyle(GameColorRole.textPrimary.token.swiftUIColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .accessibilityIdentifier("tarneeb-seat-\(player.seat.rawValue)")
                .accessibilityValue("text=\(GameColorRole.textPrimary.token.rawValue)")

            if showsDealtHand(for: player.seat) {
                if player.seat == .south {
                    visibleHand(for: player)
                } else {
                    hiddenHand(for: player)
                }
            }
        }
        .padding(4)

        if player.seat == .south && showsDealtHand(for: player.seat) {
            stationContent
                .frame(maxWidth: metrics.southStationMaxWidth)
                .frame(minHeight: metrics.southStationMinHeight)
                .background(
                    RoundedRectangle(cornerRadius: metrics.stationCornerRadius)
                        .stroke(dealerPresentation.outlineColorRole.token.swiftUIColor, lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    if dealerPresentation.showsDealerBadge {
                        dealerBadgeView(dealerPresentation)
                            .padding(6)
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("tarneeb-seat-area-\(player.seat.rawValue)")
                .accessibilityValue(stationAccessibilityValue(for: player, metrics: metrics, dealerPresentation: dealerPresentation))
                .animation(
                    .easeInOut(duration: GameAnimationToken.dealStationExpansionDuration.seconds),
                    value: showsDealtHand(for: player.seat)
                )
        } else {
            stationContent
                .frame(width: metrics.compactStationSide, height: metrics.compactStationSide)
                .background(
                    RoundedRectangle(cornerRadius: metrics.stationCornerRadius)
                        .stroke(dealerPresentation.outlineColorRole.token.swiftUIColor, lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    if dealerPresentation.showsDealerBadge {
                        dealerBadgeView(dealerPresentation)
                            .padding(6)
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("tarneeb-seat-area-\(player.seat.rawValue)")
                .accessibilityValue(stationAccessibilityValue(for: player, metrics: metrics, dealerPresentation: dealerPresentation))
                .animation(
                    .easeInOut(duration: GameAnimationToken.dealStationExpansionDuration.seconds),
                    value: showsDealtHand(for: player.seat)
                )
        }
    }

    private func dealerBadgeView(_ presentation: DealerStationPresentation) -> some View {
        ZStack {
            Circle()
                .fill(presentation.badgeBackgroundToken.swiftUIColor)

            Text("D")
                .font(.caption2.weight(.bold))
                .foregroundStyle(presentation.badgeTextToken.swiftUIColor)
                .accessibilityHidden(true)
        }
        .frame(width: 22, height: 22)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("D")
        .accessibilityIdentifier("tarneeb-dealer-badge-\(presentation.seat.rawValue)")
        .accessibilityValue(presentation.accessibilityValue)
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
                    .disabled(isDealAnimationRunning)
                    .accessibilityIdentifier("tarneeb-new-game-button")
                    .accessibilityValue("\(ButtonTokenSet.newGame.accessibilityValue);dealAnimationRunning=\(dealAnimationRunningValue)")

                Button(PresentationAction.deal.visibleLabel, action: deal)
                    .buttonStyle(TokenButtonStyle(tokens: .deal))
                    .disabled(isDealAnimationRunning)
                    .accessibilityIdentifier("tarneeb-deal-button")
                    .accessibilityValue("\(ButtonTokenSet.deal.accessibilityValue);dealAnimationRunning=\(dealAnimationRunningValue)")
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
        guard !isDealAnimationRunning else {
            return
        }

        presentationState.deal()
        let dealtState = presentationState.gameState

        guard dealtState.phase == .dealt else {
            gameState = dealtState
            return
        }

        pendingDealtState = dealtState
        gameState = .initial(dealerSeat: dealtState.dealerSeat)
        let animationPresentation = DealAnimationPresentation(
            dealerSeat: dealtState.dealerSeat,
            sizeConfiguration: cardSizeConfiguration
        )
        lastDealAnimationPresentation = animationPresentation
        dealAnimation = DealAnimationPlayback(presentation: animationPresentation)

        Task {
            await runDealAnimation(finalState: dealtState)
        }
    }

    private func newGame() {
        guard !isDealAnimationRunning else {
            return
        }

        presentationState.newGame()
        pendingDealtState = nil
        lastDealAnimationPresentation = nil
        gameState = presentationState.gameState
    }

    @MainActor
    private func runDealAnimation(finalState: GameState) async {
        for stepIndex in 0..<Seat.dealerRotationOrder.count {
            guard dealAnimation != nil else {
                return
            }

            dealAnimation?.activeStepIndex = stepIndex
            dealAnimation?.movingStackAtTarget = false
            dealAnimation?.isMovingStackVisible = true

            try? await Task.sleep(nanoseconds: GameAnimationToken.dealStepPauseDuration.nanoseconds)

            guard dealAnimation != nil else {
                return
            }

            withAnimation(.easeInOut(duration: GameAnimationToken.dealStackFlightDuration.seconds)) {
                dealAnimation?.movingStackAtTarget = true
            }

            try? await Task.sleep(nanoseconds: GameAnimationToken.dealStackFlightDuration.nanoseconds)

            guard let targetSeat = dealAnimation?.activeTargetSeat else {
                return
            }

            withAnimation(.easeInOut(duration: GameAnimationToken.dealStationExpansionDuration.seconds)) {
                dealAnimation?.deliveredSeats.insert(targetSeat)
                dealAnimation?.isMovingStackVisible = false
            }

            try? await Task.sleep(nanoseconds: GameAnimationToken.dealStationExpansionDuration.nanoseconds)
        }

        guard dealAnimation != nil else {
            return
        }

        withAnimation(.easeInOut(duration: GameAnimationToken.dealStationExpansionDuration.seconds)) {
            gameState = finalState
            pendingDealtState = nil
            dealAnimation = nil
        }
    }

    private func player(for seat: Seat) -> Player {
        player(for: seat, in: gameState)
    }

    private func player(for seat: Seat, in state: GameState) -> Player {
        guard let player = state.players.first(where: { $0.seat == seat }) else {
            preconditionFailure("Expected player for \(seat.rawValue) seat.")
        }

        return player
    }

    private func displayPlayer(for seat: Seat) -> Player {
        if showsAnimatedHand(for: seat), let pendingPlayer = pendingDealtState?.players.first(where: { $0.seat == seat }) {
            return pendingPlayer
        }

        return player(for: seat)
    }

    private var isDealAnimationRunning: Bool {
        dealAnimation != nil
    }

    private var dealAnimationRunningValue: String {
        isDealAnimationRunning ? "true" : "false"
    }

    private var dealAnimationAccessibilityValue: String {
        if let dealAnimation {
            return "dealAnimation=running;\(dealAnimation.presentation.accessibilityValue)"
        }

        if let lastDealAnimationPresentation {
            return "dealAnimation=idle;lastDealAnimation=completed;\(lastDealAnimationPresentation.accessibilityValue)"
        }

        return "dealAnimation=idle"
    }

    private func showsDealtHand(for seat: Seat) -> Bool {
        gameState.phase == .dealt || showsAnimatedHand(for: seat)
    }

    private func showsAnimatedHand(for seat: Seat) -> Bool {
        dealAnimation?.deliveredSeats.contains(seat) ?? false
    }

    private func dealAnimationOffset(to seat: Seat, metrics: TableLayoutMetrics) -> CGSize {
        let path = DealAnimationPathPresentation(
            tableDiameter: Double(metrics.tableDiameter),
            compactStationSide: Double(metrics.compactStationSide),
            southStationHeight: Double(southStationHeight(metrics: metrics)),
            horizontalSpacing: Double(metrics.horizontalSpacing),
            verticalSpacing: Double(metrics.verticalSpacing)
        )
        let offset = path.offset(
            to: seat,
            stackAtTarget: dealAnimation?.movingStackAtTarget == true
        )

        return CGSize(width: CGFloat(offset.x), height: CGFloat(offset.y))
    }

    private func southStationHeight(metrics: TableLayoutMetrics) -> CGFloat {
        showsDealtHand(for: .south) ? metrics.southStationMinHeight : metrics.compactStationSide
    }

    private func stationAccessibilityValue(
        for player: Player,
        metrics: TableLayoutMetrics,
        dealerPresentation: DealerStationPresentation
    ) -> String {
        let stateValue: String
        if dealAnimation != nil {
            stateValue = showsDealtHand(for: player.seat) ? "dealingDelivered" : "dealingWaiting"
        } else {
            stateValue = gameState.phase == .dealt ? "dealt" : "notStarted"
        }
        let shapeValue = player.seat == .south && showsDealtHand(for: player.seat) ? "expandedRoundedStation" : "roundedSquare"

        return [
            "label=\(GameColorRole.textPrimary.token.rawValue)",
            "outline=\(dealerPresentation.outlineToken.rawValue)",
            "shape=\(shapeValue)",
            "position=\(player.seat.rawValue)",
            "state=\(stateValue)",
            "dealAnimationDelivered=\(showsAnimatedHand(for: player.seat))",
            "compactSide=\(Int(metrics.compactStationSide.rounded()))",
            dealerPresentation.accessibilityValue
        ].joined(separator: ";")
    }

}

private struct DealAnimationPlayback: Equatable {
    let presentation: DealAnimationPresentation
    var activeStepIndex = 0
    var movingStackAtTarget = false
    var isMovingStackVisible = false
    var deliveredSeats: Set<Seat> = []

    var activeTargetSeat: Seat? {
        presentation.targetSeat(forStep: activeStepIndex)
    }

    var movingStackPresentation: DealAnimationStackPresentation? {
        guard isMovingStackVisible else {
            return nil
        }

        return presentation.movingStackPresentation(forStep: activeStepIndex)
    }

    var centralCardCount: Int {
        presentation.centralCardCount(
            deliveredSeatCount: deliveredSeats.count,
            movingStackVisible: isMovingStackVisible
        )
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
