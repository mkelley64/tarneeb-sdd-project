import SwiftUI

struct ContentView: View {
    @State private var presentationState: TarneebPresentationState
    @State private var gameState: GameState
    @State private var pendingDealtState: GameState?
    @State private var dealAnimation: DealAnimationPlayback?
    @State private var lastDealAnimationPresentation: DealAnimationPresentation?
    @State private var simulatedBiddingTask: Task<Void, Never>?
    @State private var biddingAreaFadeTask: Task<Void, Never>?
    @State private var isBiddingAreaFadingOut = false
    @State private var southDraftBid: BidValue = .pass
    @State private var southDraftTarneebSuit: Suit?

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
            .accessibilityValue(Text(verbatim: "background=\(GameColorRole.tableSurface.token.rawValue)"))
        }
    }

    private func tableScene(screenWidth: CGFloat) -> some View {
        let metrics = TableLayoutMetrics(screenWidth: screenWidth)
        let shouldShowBidArea = gameState.biddingStatus == .inProgress || isBiddingAreaFadingOut
        let bidPresentation = shouldShowBidArea
            ? BidAreaPresentation(
                phase: gameState.phase,
                biddingState: gameState.biddingState,
                southDraftBid: southDraftBid,
                southDraftTarneebSuit: southDraftTarneebSuit,
                presentationState: isBiddingAreaFadingOut ? .fadingOut : .visible
            )
            : nil
        let postBiddingSummaryPresentation = PostBiddingSummaryPresentation(
            phase: gameState.phase,
            biddingStatus: gameState.biddingStatus,
            summary: gameState.postBiddingSummary,
            isBiddingAreaFadingOut: isBiddingAreaFadingOut
        )
        let southTarneebSelectionPresentation = SouthTarneebSelectionPresentation(
            phase: gameState.phase,
            biddingStatus: gameState.biddingStatus,
            highestBidSeat: gameState.highestBidSeat,
            highestBidValue: gameState.highestBidValue,
            summary: gameState.postBiddingSummary,
            isBiddingAreaFadingOut: isBiddingAreaFadingOut,
            selectedSuit: southDraftTarneebSuit
        )
        let bidEntriesAccessibilityValue = bidPresentation?.entries
            .map { "\($0.seat.rawValue):\($0.valueLabel)" }
            .joined(separator: ",") ?? "none"
        let tableSceneAccessibilityValue = "table=\(GameColorRole.tableSurface.token.rawValue);label=\(GameColorRole.textPrimary.token.rawValue);station=\(GameColorRole.stationOutline.token.rawValue);dealer=\(gameState.dealerSeat.rawValue);diameter=\(Int(metrics.tableDiameter.rounded()));bidAreaVisible=\(String(bidPresentation != nil));bidAreaFading=\(String(isBiddingAreaFadingOut));postBiddingSummaryVisible=\(String(postBiddingSummaryPresentation != nil));southTarneebSelectionVisible=\(String(southTarneebSelectionPresentation != nil));bids=\(bidEntriesAccessibilityValue);summary=\(postBiddingSummaryPresentation?.teamLabel ?? "none");\(dealAnimationAccessibilityValue)"

        return ZStack {
            VStack(spacing: metrics.verticalSpacing) {
                playerStation(for: displayPlayer(for: .north), metrics: metrics)

                HStack(alignment: .center, spacing: metrics.horizontalSpacing) {
                    playerStation(for: displayPlayer(for: .west), metrics: metrics)

                    circularCardTable(metrics: metrics)

                    playerStation(for: displayPlayer(for: .east), metrics: metrics)
                }

                VStack(spacing: metrics.bidAreaVerticalSpacing) {
                    playerStation(for: displayPlayer(for: .south), metrics: metrics)

                    if let bidPresentation {
                        bidAreaView(bidPresentation, metrics: metrics)
                            .opacity(isBiddingAreaFadingOut ? 0 : 1)
                            .animation(
                                .easeInOut(duration: bidPresentation.areaFadeOutToken.seconds),
                                value: isBiddingAreaFadingOut
                            )
                    } else if let postBiddingSummaryPresentation {
                        postBiddingSummaryView(postBiddingSummaryPresentation, metrics: metrics)
                    } else if let southTarneebSelectionPresentation {
                        southTarneebSelectionView(southTarneebSelectionPresentation, metrics: metrics)
                    }
                }
            }

            if let movingStackPresentation = dealAnimation?.movingStackPresentation {
                movingDealStackView(movingStackPresentation)
                    .id(movingStackPresentation.targetSeat)
                    .offset(dealAnimationOffset(to: movingStackPresentation.targetSeat, metrics: metrics))
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-table-scene")
        .accessibilityValue(Text(verbatim: tableSceneAccessibilityValue))
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
                    .accessibilityValue(Text(verbatim: "asset=card_back;hidden=true;size=\(hiddenCard.sizeConfiguration.category.rawValue)"))
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
                    .accessibilityValue(Text(verbatim: "asset=card_back;hidden=true;size=\(hiddenCard.sizeConfiguration.category.rawValue)"))
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
                .accessibilityValue(Text(verbatim: "text=\(GameColorRole.textPrimary.token.rawValue)"))

            if showsDealtHand(for: player.seat) {
                if player.seat == .south {
                    visibleHand(for: player)
                } else {
                    hiddenHand(for: player)
                }
            }
        }
        .padding(4)

        if expandsSouthStation(for: player.seat) {
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
                    value: expandsSouthStation(for: player.seat)
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
        if player.seat == .south, let dealAnimation {
            switch dealAnimation.southRevealState {
            case .hidden:
                break
            case .fannedBacks:
                return AnyView(hiddenHand(for: player))
            case .backsVisible, .flipping, .revealed:
                return AnyView(southRevealHand(for: player, dealAnimation: dealAnimation))
            }
        }

        return AnyView(exposedHand(for: player))
    }

    private func exposedHand(for player: Player) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.adaptive(minimum: cardSizeConfiguration.baseCardWidth), spacing: 4)
            ],
            spacing: 4
        ) {
            ForEach(SouthHandPresentation.cardPresentations(from: player.hand, sizeConfiguration: cardSizeConfiguration), id: \.cardID) { presentation in
                cardFaceView(presentation)
            }
        }
        .accessibilityIdentifier("tarneeb-visible-hand-\(player.seat.rawValue)")
    }

    private func southRevealHand(for player: Player, dealAnimation: DealAnimationPlayback) -> some View {
        let cardPresentations = SouthHandPresentation.cardPresentations(
            from: player.hand,
            sizeConfiguration: cardSizeConfiguration
        )

        return LazyVGrid(
            columns: [
                GridItem(.adaptive(minimum: cardSizeConfiguration.baseCardWidth), spacing: 4)
            ],
            spacing: 4
        ) {
            ForEach(Array(cardPresentations.enumerated()), id: \.element.cardID) { index, presentation in
                if index < dealAnimation.southRevealedCardCount {
                    cardFaceView(presentation)
                        .transition(.opacity.combined(with: .scale(scale: 0.94)))
                } else {
                    southRevealCardBack(index: index)
                        .transition(.opacity)
                }
            }
        }
        .accessibilityIdentifier("tarneeb-south-reveal-hand")
        .accessibilityValue(
            Text(verbatim: "state=\(dealAnimation.southRevealState.rawValue);backCount=\(DealAnimationPresentation.cardsPerStack);revealedCount=\(dealAnimation.southRevealedCardCount);direction=leftToRight;totalDuration=\(GameAnimationToken.dealSouthRevealTotalDuration.rawValue);totalSeconds=\(GameAnimationToken.dealSouthRevealTotalDuration.seconds)")
        )
    }

    private func cardFaceView(_ presentation: CardPresentation) -> some View {
        Image(presentation.faceAssetName)
            .interpolation(.high)
            .antialiased(true)
            .resizable()
            .scaledToFit()
            .frame(width: cardSizeConfiguration.baseCardWidth, height: cardSizeConfiguration.baseCardHeight)
            .shadow(color: GameColorRole.cardShadow.token.swiftUIColor, radius: 1, y: 1)
            .accessibilityLabel(presentation.accessibilityLabel)
            .accessibilityIdentifier("tarneeb-visible-card")
            .accessibilityValue(presentation.accessibilityValue)
    }

    private func southRevealCardBack(index: Int) -> some View {
        Image("card_back")
            .resizable()
            .scaledToFit()
            .frame(
                width: cardSizeConfiguration.baseCardWidth,
                height: cardSizeConfiguration.baseCardHeight
            )
            .accessibilityLabel("South reveal card back")
            .accessibilityIdentifier("tarneeb-south-reveal-card-back")
            .accessibilityValue(Text(verbatim: "index=\(index);asset=card_back;hidden=true;size=\(cardSizeConfiguration.category.rawValue)"))
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
        .accessibilityValue(Text(verbatim: "count=\(presentation.hiddenCardCount);asset=card_back;hidden=true;size=\(presentation.sizeConfiguration.category.rawValue)"))
    }

    private func bidAreaView(_ presentation: BidAreaPresentation, metrics: TableLayoutMetrics) -> some View {
        VStack(alignment: .leading, spacing: CGFloat(presentation.areaTokens.rowGap.numericValue)) {
            Text(presentation.label)
                .font(.headline)
                .foregroundStyle(presentation.areaTokens.label.swiftUIColor)
                .accessibilityIdentifier("tarneeb-bid-label")
                .accessibilityValue(Text(verbatim: "text=\(presentation.areaTokens.label.rawValue)"))

            HStack(alignment: .top, spacing: CGFloat(presentation.areaTokens.rowGap.numericValue)) {
                ForEach(presentation.entries) { entry in
                    bidRow(entry, presentation: presentation)
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("tarneeb-bid-table")
            .accessibilityValue(presentation.accessibilityValue)

            if presentation.southBidButtonVisible {
                southBidActionTray(presentation: presentation)
            }
        }
        .padding(CGFloat(presentation.areaTokens.padding.numericValue))
        .frame(maxWidth: metrics.bidAreaMaxWidth, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CGFloat(presentation.areaTokens.cornerRadius.numericValue))
                .fill(presentation.areaTokens.background.swiftUIColor)
                .overlay(
                    RoundedRectangle(cornerRadius: CGFloat(presentation.areaTokens.cornerRadius.numericValue))
                        .stroke(presentation.areaTokens.border.swiftUIColor, lineWidth: 1)
                )
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-bid-area")
        .accessibilityValue(presentation.accessibilityValue)
    }

    private func postBiddingSummaryView(_ presentation: PostBiddingSummaryPresentation, metrics: TableLayoutMetrics) -> some View {
        VStack(alignment: .leading, spacing: CGFloat(presentation.tokens.rowGap.numericValue)) {
            HStack {
                Text("Team")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(presentation.tokens.labelText.swiftUIColor)
                Spacer()
                Text(presentation.teamLabel)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(presentation.tokens.teamText.swiftUIColor)
            }

            HStack {
                Text("Bid")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(presentation.tokens.labelText.swiftUIColor)
                Spacer()
                Text(presentation.bidValueLabel)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(presentation.tokens.bidText.swiftUIColor)
            }

            HStack {
                Text(presentation.tarneebLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(presentation.tokens.labelText.swiftUIColor)
                Spacer()
                postBiddingTarneebSuitChip(presentation)
            }
        }
        .padding(CGFloat(presentation.tokens.padding.numericValue))
        .frame(maxWidth: metrics.bidAreaMaxWidth, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CGFloat(presentation.tokens.cornerRadius.numericValue))
                .fill(presentation.tokens.background.swiftUIColor)
                .overlay(
                    RoundedRectangle(cornerRadius: CGFloat(presentation.tokens.cornerRadius.numericValue))
                        .stroke(presentation.tokens.border.swiftUIColor, lineWidth: 1)
                )
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-post-bidding-summary")
        .accessibilityValue(presentation.accessibilityValue)
    }

    private func postBiddingTarneebSuitChip(_ presentation: PostBiddingSummaryPresentation) -> some View {
        Text(presentation.tarneebSymbol)
            .font(.subheadline.weight(.bold))
            .foregroundStyle(presentation.tarneebSymbolColorToken.swiftUIColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(presentation.tarneebSymbolBackgroundColorToken.swiftUIColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(presentation.tarneebSymbolBorderColorToken.swiftUIColor, lineWidth: 1)
                    )
            )
    }

    private func southTarneebSelectionView(_ presentation: SouthTarneebSelectionPresentation, metrics: TableLayoutMetrics) -> some View {
        VStack(alignment: .leading, spacing: CGFloat(presentation.tokens.rowGap.numericValue)) {
            HStack {
                Text("Team")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(presentation.tokens.labelText.swiftUIColor)
                Spacer()
                Text(presentation.teamLabel)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(presentation.tokens.teamText.swiftUIColor)
            }

            HStack {
                Text("Bid")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(presentation.tokens.labelText.swiftUIColor)
                Spacer()
                Text(presentation.bidValueLabel)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(presentation.tokens.bidText.swiftUIColor)
            }

            Text(presentation.tarneebLabel)
                .font(.caption.weight(.semibold))
                .foregroundStyle(presentation.tokens.labelText.swiftUIColor)

            HStack(spacing: CGFloat(presentation.suitSelectorTokens.optionGap.numericValue)) {
                ForEach(presentation.suitOptions, id: \.self) { suit in
                    southTarneebSuitOptionButton(
                        suit,
                        selectedSuit: southDraftTarneebSuit,
                        isEnabled: true,
                        tokens: presentation.suitSelectorTokens
                    )
                }
            }
            .frame(
                minHeight: CGFloat(presentation.suitSelectorTokens.height.numericValue),
                alignment: .leading
            )
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("tarneeb-post-bidding-suit-selector-south")
            .accessibilityValue(Text(verbatim: "visible=true;enabled=true;selected=\(southDraftTarneebSuit?.rawValue ?? "none");options=\(presentation.suitOptionsLabel);\(presentation.suitSelectorTokens.accessibilityValue)"))

            Button("Set", action: submitSouthTarneebSuit)
                .buttonStyle(CompactTokenButtonStyle(tokens: presentation.bidButtonTokens))
                .disabled(!presentation.submitEnabled)
                .frame(
                    minWidth: CGFloat(presentation.bidButtonMinimumWidthToken.numericValue),
                    minHeight: CGFloat(presentation.bidButtonHeightToken.numericValue)
                )
                .accessibilityIdentifier("tarneeb-post-bidding-suit-button-south")
                .accessibilityValue(Text(verbatim: "visible=true;enabled=\(String(presentation.submitEnabled));selectedSuit=\(southDraftTarneebSuit?.rawValue ?? "none");title=Set;\(presentation.bidButtonTokens.accessibilityValue);height=\(presentation.bidButtonHeightToken.rawValue);minimumWidth=\(presentation.bidButtonMinimumWidthToken.rawValue)"))
        }
        .padding(CGFloat(presentation.tokens.padding.numericValue))
        .frame(maxWidth: metrics.bidAreaMaxWidth, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CGFloat(presentation.tokens.cornerRadius.numericValue))
                .fill(presentation.tokens.background.swiftUIColor)
                .overlay(
                    RoundedRectangle(cornerRadius: CGFloat(presentation.tokens.cornerRadius.numericValue))
                        .stroke(presentation.tokens.border.swiftUIColor, lineWidth: 1)
                )
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-south-tarneeb-selection")
        .accessibilityValue(presentation.accessibilityValue)
    }

    private func bidRow(_ entry: BidEntryPresentation, presentation: BidAreaPresentation) -> some View {
        VStack(spacing: CGFloat(presentation.areaTokens.rowGap.numericValue)) {
            Text(entry.seatLabel)
                .font(.caption.weight(.semibold))
                .foregroundStyle(presentation.areaTokens.seatText.swiftUIColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            if entry.isSelectable {
                bidValueText(
                    entry.historyValueLabel,
                    colorToken: entry.historyValueColorToken,
                    accessibilityValue: entry.accessibilityValue,
                    identifier: "tarneeb-bid-value-\(entry.seat.rawValue)",
                    presentation: presentation
                )
            } else {
                Text(entry.valueLabel)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(entry.valueColorToken.swiftUIColor)
                    .frame(
                        minHeight: CGFloat(presentation.selectorTokens.height.numericValue),
                        alignment: .center
                    )
                    .id("\(entry.seat.rawValue)-\(entry.valueLabel)")
                    .transition(.opacity)
                    .animation(
                        .easeInOut(duration: presentation.fadeOutToken.seconds + presentation.fadeInToken.seconds),
                        value: entry.valueLabel
                    )
                    .animation(
                        .easeInOut(duration: presentation.fadeOutToken.seconds + presentation.fadeInToken.seconds),
                        value: entry.valueColorToken.rawValue
                    )
                    .accessibilityIdentifier("tarneeb-bid-value-\(entry.seat.rawValue)")
                    .accessibilityValue(entry.accessibilityValue)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 2)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-bid-row-\(entry.seat.rawValue)")
        .accessibilityValue(entry.accessibilityValue)
    }

    private func bidValueText(
        _ value: String,
        colorToken: GameColorToken,
        accessibilityValue: String,
        identifier: String,
        presentation: BidAreaPresentation
    ) -> some View {
        Text(value)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(colorToken.swiftUIColor)
            .frame(
                minHeight: CGFloat(presentation.selectorTokens.height.numericValue),
                alignment: .center
            )
            .id(identifier + "-\(value)")
            .transition(.opacity)
            .animation(
                .easeInOut(duration: presentation.fadeOutToken.seconds + presentation.fadeInToken.seconds),
                value: value
            )
            .animation(
                .easeInOut(duration: presentation.fadeOutToken.seconds + presentation.fadeInToken.seconds),
                value: colorToken.rawValue
            )
            .accessibilityIdentifier(identifier)
            .accessibilityValue(accessibilityValue)
    }

    private func southBidActionTray(presentation: BidAreaPresentation) -> some View {
        VStack(alignment: .leading, spacing: CGFloat(presentation.areaTokens.rowGap.numericValue)) {
            HStack(alignment: .firstTextBaseline) {
                Text(presentation.currentTurnSeat == .south ? "Your bid" : waitingForBidderLabel(presentation))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(presentation.areaTokens.seatText.swiftUIColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .accessibilityIdentifier("tarneeb-bid-action-label-south")

                Spacer(minLength: 8)
            }

            if presentation.currentTurnSeat == .south {
                southBidChoiceTray(presentation: presentation)

                if presentation.southSuitSelectorVisible {
                    southTarneebSuitSelector(presentation: presentation)
                }
            }

            southBidButton(presentation: presentation)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.top, CGFloat(presentation.areaTokens.rowGap.numericValue))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-bid-action-tray-south")
        .accessibilityValue(Text(verbatim: "currentTurn=\(presentation.currentTurnSeat?.rawValue ?? "none");selected=\(southDraftBid.displayLabel);selectedSuit=\(southDraftTarneebSuit?.rawValue ?? "none");allowed=\(presentation.allowedValuesLabel);buttonEnabled=\(presentation.southBidButtonEnabled)"))
    }

    private func southBidButton(presentation: BidAreaPresentation) -> some View {
        let buttonTitle = "Bid"
        let buttonAccessibilityValue = "visible=true;enabled=\(String(presentation.southBidButtonEnabled));selected=\(southDraftBid.displayLabel);selectedSuit=\(southDraftTarneebSuit?.rawValue ?? "none");allowed=\(presentation.allowedValuesLabel);currentTurn=\(presentation.currentTurnSeat?.rawValue ?? "none");title=\(buttonTitle);\(presentation.bidButtonTokens.accessibilityValue);height=\(presentation.bidButtonHeightToken.rawValue);minimumWidth=\(presentation.bidButtonMinimumWidthToken.rawValue)"

        return Button(buttonTitle, action: submitSouthBid)
            .buttonStyle(CompactTokenButtonStyle(tokens: presentation.bidButtonTokens))
            .disabled(!presentation.southBidButtonEnabled)
            .frame(
                minWidth: CGFloat(presentation.bidButtonMinimumWidthToken.numericValue),
                minHeight: CGFloat(presentation.bidButtonHeightToken.numericValue)
            )
            .accessibilityIdentifier("tarneeb-bid-button-south")
            .accessibilityValue(Text(verbatim: buttonAccessibilityValue))
    }

    private func waitingForBidderLabel(_ presentation: BidAreaPresentation) -> String {
        guard let currentTurnSeat = presentation.currentTurnSeat else {
            return "Waiting"
        }

        return "Waiting for \(currentTurnSeat.displayLabel)"
    }

    private func southBidChoiceTray(presentation: BidAreaPresentation) -> some View {
        HStack(spacing: CGFloat(presentation.suitSelectorTokens.optionGap.numericValue)) {
            ForEach(presentation.allowedValues, id: \.self) { bidValue in
                Button(bidValue.displayLabel) {
                    selectSouthDraftBid(bidValue)
                }
                .buttonStyle(BidChoiceChipButtonStyle(isSelected: southDraftBid == bidValue, isPass: bidValue == .pass))
                .accessibilityIdentifier("tarneeb-bid-option-\(bidOptionIdentifier(for: bidValue))")
            }
        }
        .frame(minHeight: CGFloat(presentation.selectorTokens.height.numericValue), alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-bid-selector-south")
        .accessibilityValue(
            Text(verbatim: "selected=\(southDraftBid.displayLabel);allowed=\(presentation.allowedValuesLabel);\(presentation.selectorTokens.accessibilityValue)")
        )
    }

    private func southTarneebSuitSelector(presentation: BidAreaPresentation) -> some View {
        let selectedSuitLabel = southDraftTarneebSuit?.rawValue ?? "none"
        let accessibilityValue = "visible=true;enabled=\(presentation.southSuitSelectorEnabled);selected=\(selectedSuitLabel);options=\(presentation.southSuitOptionsLabel);\(presentation.suitSelectorTokens.accessibilityValue)"

        return HStack(spacing: CGFloat(presentation.suitSelectorTokens.optionGap.numericValue)) {
            ForEach(presentation.southSuitOptions, id: \.self) { suit in
                southTarneebSuitOptionButton(
                    suit,
                    selectedSuit: southDraftTarneebSuit,
                    isEnabled: presentation.southSuitSelectorEnabled,
                    tokens: presentation.suitSelectorTokens
                )
            }
        }
        .frame(
            minHeight: CGFloat(presentation.suitSelectorTokens.height.numericValue),
            alignment: .leading
        )
        .opacity(presentation.southSuitSelectorEnabled ? 1 : presentation.suitSelectorTokens.disabledOpacity.value)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-bid-suit-selector-south")
        .accessibilityValue(Text(verbatim: accessibilityValue))
    }

    private func southTarneebSuitOptionButton(
        _ suit: Suit,
        selectedSuit: Suit?,
        isEnabled: Bool,
        tokens: BidSuitSelectorTokenSet
    ) -> some View {
        let isSelected = selectedSuit == suit
        let optionWidth = CGFloat(tokens.optionMinimumWidth.numericValue)
        let optionHeight = CGFloat(tokens.height.numericValue)
        let accessibilityValue = "selected=\(isSelected);enabled=\(isEnabled);symbol=\(suit.displaySymbol);background=\(GameColorToken.cardBackground.rawValue);text=\(suit.colorToken.rawValue)"

        return Button {
            selectSouthDraftTarneebSuit(suit)
        } label: {
            Text(suit.displaySymbol)
                .font(.caption.weight(.bold))
                .frame(minWidth: optionWidth, minHeight: optionHeight)
        }
        .buttonStyle(BidSuitChipButtonStyle(suit: suit, isSelected: isSelected))
        .disabled(!isEnabled)
        .accessibilityIdentifier("tarneeb-bid-suit-option-\(suit.rawValue)")
        .accessibilityLabel(Text(verbatim: suit.rawValue.capitalized))
        .accessibilityValue(Text(verbatim: accessibilityValue))
    }

    private var bottomDealControl: some View {
        VStack(spacing: 4) {
            if gameState.phase == .dealt {
                Text(statusLabelText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(GameColorRole.textPrimary.token.swiftUIColor)
                    .accessibilityIdentifier("tarneeb-deal-complete-message")
                    .accessibilityValue(Text(verbatim: "text=\(GameColorRole.textPrimary.token.rawValue);status=\(statusLabelText)"))
            }

            HStack(spacing: 10) {
                Button(PresentationAction.newGame.visibleLabel, action: newGame)
                    .buttonStyle(TokenButtonStyle(tokens: .newGame))
                    .disabled(isDealAnimationRunning)
                    .accessibilityIdentifier("tarneeb-new-game-button")
                    .accessibilityValue(Text(verbatim: "\(ButtonTokenSet.newGame.accessibilityValue);dealAnimationRunning=\(dealAnimationRunningValue)"))

                Button(PresentationAction.deal.visibleLabel, action: deal)
                    .buttonStyle(TokenButtonStyle(tokens: .deal))
                    .disabled(isDealAnimationRunning)
                    .accessibilityIdentifier("tarneeb-deal-button")
                    .accessibilityValue(Text(verbatim: "\(ButtonTokenSet.deal.accessibilityValue);dealAnimationRunning=\(dealAnimationRunningValue)"))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 18)
        .padding(.top, 4)
        .padding(.bottom, 6)
        .background(GameColorRole.tableSurface.token.swiftUIColor)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-bottom-deal-control")
        .accessibilityValue(Text(verbatim: "buttons=New Game,Deal;newGameTokens=\(ButtonTokenSet.newGame.accessibilityValue);dealTokens=\(ButtonTokenSet.deal.accessibilityValue)"))
    }

    private func deal() {
        guard !isDealAnimationRunning else {
            return
        }

        cancelSimulatedBiddingTask()
        cancelBiddingAreaFadeTask()
        isBiddingAreaFadingOut = false
        presentationState.deal()
        let dealtState = presentationState.gameState
        southDraftBid = normalizedSouthDraftBid(for: dealtState)
        southDraftTarneebSuit = normalizedSouthDraftTarneebSuit(for: dealtState)

        stageDealAnimationIfNeeded(for: dealtState)
    }

    private func newGame() {
        guard !isDealAnimationRunning else {
            return
        }

        cancelSimulatedBiddingTask()
        cancelBiddingAreaFadeTask()
        isBiddingAreaFadingOut = false
        presentationState.newGame()
        pendingDealtState = nil
        lastDealAnimationPresentation = nil
        southDraftBid = .pass
        southDraftTarneebSuit = nil
        gameState = presentationState.gameState
    }

    private func selectSouthDraftBid(_ bid: BidValue) {
        southDraftBid = bid
        if bid.numericValue == nil {
            southDraftTarneebSuit = nil
        }
    }

    private func selectSouthDraftTarneebSuit(_ suit: Suit) {
        guard isWaitingForSouthPostBiddingTarneebSelection else {
            return
        }

        southDraftTarneebSuit = suit
    }

    private func submitSouthBid() {
        guard gameState.biddingState?.isWaitingForSouth == true else {
            return
        }

        presentationState.submitSouthBid(southDraftBid)
        gameState = presentationState.gameState
        southDraftBid = normalizedSouthDraftBid(for: gameState)
        southDraftTarneebSuit = normalizedSouthDraftTarneebSuit(for: gameState)
        beginTerminalBiddingTransitionIfNeeded()
        scheduleSimulatedBiddingIfNeeded()
    }

    private func submitSouthTarneebSuit() {
        guard isWaitingForSouthPostBiddingTarneebSelection,
              let selectedTarneebSuit = southDraftTarneebSuit else {
            return
        }

        presentationState.submitSouthTarneebSuit(selectedTarneebSuit)
        gameState = presentationState.gameState
        southDraftTarneebSuit = normalizedSouthDraftTarneebSuit(for: gameState)
    }

    private func stageDealAnimationIfNeeded(for dealtState: GameState) {
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

    private func bidOptionIdentifier(for bid: BidValue) -> String {
        bid.rawValue.lowercased()
    }

    private func normalizedSouthDraftBid(for state: GameState) -> BidValue {
        guard state.biddingState?.isWaitingForSouth == true,
              let legalValues = state.biddingState?.southLegalValues,
              legalValues.contains(southDraftBid) else {
            return .pass
        }

        return southDraftBid
    }

    private func normalizedSouthDraftTarneebSuit(for state: GameState) -> Suit? {
        guard state.biddingStatus == .complete,
              state.highestBidSeat == .south,
              state.highestBidValue?.numericValue != nil,
              state.postBiddingSummary == nil else {
            return nil
        }

        return southDraftTarneebSuit
    }

    private var isWaitingForSouthPostBiddingTarneebSelection: Bool {
        gameState.phase == .dealt
            && gameState.biddingStatus == .complete
            && gameState.highestBidSeat == .south
            && gameState.highestBidValue?.numericValue != nil
            && gameState.postBiddingSummary == nil
            && !isBiddingAreaFadingOut
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
                if targetSeat == .south {
                    dealAnimation?.southRevealState = .fannedBacks
                    dealAnimation?.southRevealedCardCount = 0
                }
            }

            try? await Task.sleep(nanoseconds: GameAnimationToken.dealStationExpansionDuration.nanoseconds)
        }

        guard dealAnimation != nil else {
            return
        }

        withAnimation(.easeInOut(duration: GameAnimationToken.dealStationExpansionDuration.seconds)) {
            dealAnimation?.southRevealState = .backsVisible
            dealAnimation?.southRevealedCardCount = 0
        }

        try? await Task.sleep(nanoseconds: GameAnimationToken.dealStationExpansionDuration.nanoseconds)

        guard dealAnimation != nil else {
            return
        }

        dealAnimation?.southRevealState = .flipping

        for revealedCount in 1...DealAnimationPresentation.cardsPerStack {
            guard dealAnimation != nil else {
                return
            }

            withAnimation(.easeInOut(duration: GameAnimationToken.dealSouthRevealFlipDuration.seconds)) {
                dealAnimation?.southRevealedCardCount = revealedCount
            }

            if revealedCount < DealAnimationPresentation.cardsPerStack {
                try? await Task.sleep(nanoseconds: GameAnimationToken.dealSouthRevealFlipStagger.nanoseconds)
            } else {
                try? await Task.sleep(nanoseconds: GameAnimationToken.dealSouthRevealFlipDuration.nanoseconds)
            }
        }

        withAnimation(.easeInOut(duration: GameAnimationToken.dealStationExpansionDuration.seconds)) {
            dealAnimation?.southRevealState = .revealed
            gameState = finalState
            pendingDealtState = nil
            dealAnimation = nil
        }

        scheduleSimulatedBiddingIfNeeded()
    }

    private func scheduleSimulatedBiddingIfNeeded() {
        cancelSimulatedBiddingTask()

        guard gameState.phase == .dealt,
              gameState.biddingStatus == .inProgress,
              let currentBiddingSeat = gameState.currentBiddingSeat,
              currentBiddingSeat != .south else {
            return
        }

        simulatedBiddingTask = Task {
            await runSimulatedBiddingLoop()
        }
    }

    private func cancelSimulatedBiddingTask() {
        simulatedBiddingTask?.cancel()
        simulatedBiddingTask = nil
    }

    private func cancelBiddingAreaFadeTask() {
        biddingAreaFadeTask?.cancel()
        biddingAreaFadeTask = nil
    }

    private func beginTerminalBiddingTransitionIfNeeded() {
        guard gameState.phase == .dealt,
              gameState.biddingStatus == .complete,
              !isBiddingAreaFadingOut,
              biddingAreaFadeTask == nil else {
            return
        }

        cancelSimulatedBiddingTask()
        withAnimation(.easeInOut(duration: GameAnimationToken.bidAreaFadeOutDuration.seconds)) {
            isBiddingAreaFadingOut = true
        }

        biddingAreaFadeTask = Task {
            try? await Task.sleep(nanoseconds: GameAnimationToken.bidAreaFadeOutDuration.nanoseconds)
            guard !Task.isCancelled else {
                return
            }

            await MainActor.run {
                guard gameState.biddingStatus == .complete else {
                    isBiddingAreaFadingOut = false
                    biddingAreaFadeTask = nil
                    return
                }

                let completionOutcome = gameState.biddingCompletionOutcome
                withAnimation(.easeInOut(duration: GameAnimationToken.bidValueFadeInDuration.seconds)) {
                    isBiddingAreaFadingOut = false
                }
                biddingAreaFadeTask = nil

                if completionOutcome == .allPassRedeal {
                    beginAutomaticRedealAfterAllPassIfNeeded()
                }
            }
        }
    }

    private func beginAutomaticRedealAfterAllPassIfNeeded() {
        guard !isDealAnimationRunning,
              gameState.biddingCompletionOutcome == .allPassRedeal else {
            return
        }

        cancelSimulatedBiddingTask()
        presentationState.automaticRedealAfterAllPass()
        let dealtState = presentationState.gameState
        southDraftBid = normalizedSouthDraftBid(for: dealtState)
        southDraftTarneebSuit = normalizedSouthDraftTarneebSuit(for: dealtState)
        stageDealAnimationIfNeeded(for: dealtState)
    }

    @MainActor
    private func runSimulatedBiddingLoop() async {
        while !Task.isCancelled,
              gameState.phase == .dealt,
              gameState.biddingStatus == .inProgress,
              let currentBiddingSeat = gameState.currentBiddingSeat,
              currentBiddingSeat != .south {
            try? await Task.sleep(nanoseconds: GameAnimationToken.bidSimulatedTurnDelay.nanoseconds)

            guard !Task.isCancelled,
                  gameState.phase == .dealt,
                  gameState.biddingStatus == .inProgress,
                  let currentBiddingSeat = gameState.currentBiddingSeat,
                  currentBiddingSeat != .south else {
                return
            }

            withAnimation(.easeInOut(duration: GameAnimationToken.bidValueFadeOutDuration.seconds + GameAnimationToken.bidValueFadeInDuration.seconds)) {
                presentationState.resolveNextSimulatedBid()
                gameState = presentationState.gameState
                southDraftBid = normalizedSouthDraftBid(for: gameState)
                southDraftTarneebSuit = normalizedSouthDraftTarneebSuit(for: gameState)
            }

            beginTerminalBiddingTransitionIfNeeded()
        }

        simulatedBiddingTask = nil
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

    private var statusLabelText: String {
        gameState.biddingStatus == .complete ? "Bidding complete" : "Deal complete"
    }

    private var dealAnimationAccessibilityValue: String {
        if let dealAnimation {
            return "dealAnimation=running;\(dealAnimation.accessibilityValue)"
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
        guard let dealAnimation else {
            return false
        }

        if seat == .south {
            return dealAnimation.southRevealState != .hidden || dealAnimation.deliveredSeats.contains(.south)
        }

        return dealAnimation.deliveredSeats.contains(seat)
    }

    private func expandsSouthStation(for seat: Seat) -> Bool {
        guard seat == .south else {
            return false
        }

        guard let dealAnimation else {
            return gameState.phase == .dealt
        }

        return dealAnimation.southRevealState.usesExpandedStation
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
        expandsSouthStation(for: .south) ? metrics.southStationMinHeight : metrics.compactStationSide
    }

    private func stationAccessibilityValue(
        for player: Player,
        metrics: TableLayoutMetrics,
        dealerPresentation: DealerStationPresentation
    ) -> String {
        let stateValue: String
        if dealAnimation != nil {
            if player.seat == .south, let dealAnimation {
                stateValue = "southReveal=\(dealAnimation.southRevealState.rawValue)"
            } else {
                stateValue = showsDealtHand(for: player.seat) ? "dealingDelivered" : "dealingWaiting"
            }
        } else {
            stateValue = gameState.phase == .dealt ? "dealt" : "notStarted"
        }
        let shapeValue = expandsSouthStation(for: player.seat) ? "expandedRoundedStation" : "roundedSquare"

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
    var southRevealState: SouthRevealState = .hidden
    var southRevealedCardCount = 0

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

    var dealCompletionAvailable: Bool {
        southRevealState == .revealed
    }

    var accessibilityValue: String {
        [
            presentation.accessibilityValue,
            "southRevealState=\(southRevealState.rawValue)",
            "southInterimFannedBacksVisible=\(southRevealState == .fannedBacks)",
            "southRevealBackCount=\(DealAnimationPresentation.cardsPerStack)",
            "southRevealRevealedCount=\(southRevealedCardCount)",
            "southRevealTotalDuration=\(GameAnimationToken.dealSouthRevealTotalDuration.rawValue)",
            "southRevealTotalSeconds=\(GameAnimationToken.dealSouthRevealTotalDuration.seconds)",
            "dealCompletionAvailable=\(dealCompletionAvailable)",
            "deliveredSeats=\(deliveredSeats.map(\.rawValue).sorted().joined(separator: ","))"
        ].joined(separator: ";")
    }
}

private enum SouthRevealState: String, Equatable {
    case hidden
    case fannedBacks
    case backsVisible
    case flipping
    case revealed

    var usesExpandedStation: Bool {
        switch self {
        case .hidden, .fannedBacks:
            return false
        case .backsVisible, .flipping, .revealed:
            return true
        }
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

    var bidAreaMaxWidth: CGFloat {
        southStationMaxWidth
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
        6
    }

    var bidAreaVerticalSpacing: CGFloat {
        CGFloat(GameBidLayoutToken.bidTableRowGap.numericValue)
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

private struct CompactTokenButtonStyle: ButtonStyle {
    let tokens: ButtonTokenSet
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle((isEnabled ? tokens.text : GameColorToken.textDisabled).swiftUIColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill((configuration.isPressed ? tokens.pressedBackground : tokens.background).swiftUIColor)
            )
            .opacity(isEnabled ? 1 : GameEffectToken.bidButtonDisabledOpacity.value)
    }
}

private struct BidSuitOptionButtonStyle: ButtonStyle {
    let tokens: BidSuitSelectorTokenSet
    let isSelected: Bool
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle((isSelected ? tokens.selectedText : tokens.text).swiftUIColor)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill((isSelected ? tokens.selectedBackground : tokens.background).swiftUIColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                (isSelected || configuration.isPressed ? tokens.focusRing : tokens.border).swiftUIColor,
                                lineWidth: isSelected || configuration.isPressed ? 2 : 1
                            )
                    )
            )
            .opacity(isEnabled ? 1 : tokens.disabledOpacity.value)
    }
}

private struct BidChoiceChipButtonStyle: ButtonStyle {
    let isSelected: Bool
    let isPass: Bool
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption.weight(.bold))
            .foregroundStyle(foregroundColor.swiftUIColor)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .frame(minWidth: isPass ? 48 : 32, minHeight: 32)
            .padding(.horizontal, isPass ? 4 : 0)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor.swiftUIColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(borderColor.swiftUIColor, lineWidth: isSelected || configuration.isPressed ? 2 : 1)
                    )
            )
            .opacity(isEnabled ? 1 : GameEffectToken.bidButtonDisabledOpacity.value)
    }

    private var foregroundColor: GameColorToken {
        if isSelected {
            return .buttonNewGameText
        }

        return isPass ? .bidAreaSeatText : .bidAreaValueText
    }

    private var backgroundColor: GameColorToken {
        isSelected ? .buttonNewGameBackground : .bidAreaBackground
    }

    private var borderColor: GameColorToken {
        isSelected ? .buttonNewGameBackground : .bidAreaBorder
    }
}

private struct BidSuitChipButtonStyle: ButtonStyle {
    let suit: Suit
    let isSelected: Bool
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foregroundColor.swiftUIColor)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor.swiftUIColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(borderColor.swiftUIColor, lineWidth: isSelected || configuration.isPressed ? 2 : 1)
                    )
            )
            .opacity(isEnabled ? 1 : GameEffectToken.bidSuitSelectorDisabledOpacity.value)
    }

    private var foregroundColor: GameColorToken {
        suit.colorToken
    }

    private var backgroundColor: GameColorToken {
        .cardBackground
    }

    private var borderColor: GameColorToken {
        isSelected ? .buttonNewGameBackground : .bidAreaBorder
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
