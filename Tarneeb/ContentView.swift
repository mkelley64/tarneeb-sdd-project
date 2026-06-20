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
    @State private var automatedBidCueSeat: Seat?
    @State private var isAutomatedBidCuePulsed = false
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
        let tableSceneAccessibilityValue = "table=\(GameColorRole.tableSurface.token.rawValue);label=\(GameColorRole.textPrimary.token.rawValue);station=\(GameColorRole.stationOutline.token.rawValue);dealer=\(gameState.dealerSeat.rawValue);diameter=\(Int(metrics.tableDiameter.rounded()));bidAreaVisible=\(String(bidPresentation != nil));bidAreaFading=\(String(isBiddingAreaFadingOut));postBiddingSummaryVisible=\(String(postBiddingSummaryPresentation != nil));southTarneebSelectionVisible=\(String(southTarneebSelectionPresentation != nil));bids=\(bidEntriesAccessibilityValue);summary=\(postBiddingSummaryPresentation?.highBidderLabel ?? "none");\(dealAnimationAccessibilityValue)"

        return ZStack {
            VStack(spacing: metrics.verticalSpacing) {
                playerStation(for: displayPlayer(for: .north), metrics: metrics)

                HStack(alignment: .center, spacing: metrics.horizontalSpacing) {
                    playerStation(for: displayPlayer(for: .west), metrics: metrics)

                    circularCardTable(
                        metrics: metrics,
                        postBiddingSummaryPresentation: postBiddingSummaryPresentation
                    )

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

    private func circularCardTable(
        metrics: TableLayoutMetrics,
        postBiddingSummaryPresentation: PostBiddingSummaryPresentation?
    ) -> some View {
        return ZStack {
            tableRailSurface(metrics: metrics)

            Circle()
                .fill(GameColorRole.tableSurface.token.swiftUIColor.opacity(GameEffectToken.tableCenterSurfaceOpacity.value))
                .padding(metrics.tableCenterInset)

            Circle()
                .stroke(GameColorRole.tableHighlight.token.swiftUIColor.opacity(GameEffectToken.tableInnerRingOpacity.value), lineWidth: 1)
                .padding(metrics.tableInnerRingInset)

            tablePlayArea(metrics: metrics)

            tableTitleView()
                .offset(y: -metrics.tableTitleVerticalOffset)

            if let postBiddingSummaryPresentation {
                postBiddingSummaryView(postBiddingSummaryPresentation)
                    .offset(y: metrics.contractRibbonVerticalOffset)
            }
        }
        .frame(width: metrics.tableDiameter, height: metrics.tableDiameter)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-card-table")
        .accessibilityValue(
            "shape=circle;diameter=\(Int(metrics.tableDiameter.rounded()));surface=\(GameColorRole.tableSurfaceSecondary.token.rawValue);highlight=\(GameColorRole.tableHighlight.token.rawValue);dealer=\(gameState.dealerSeat.rawValue);depth=railAndInnerBevel;railHighlightOpacity=\(GameEffectToken.tableRailHighlightOpacity.rawValue);railInnerBevelOpacity=\(GameEffectToken.tableRailInnerBevelOpacity.rawValue);railShadowOpacity=\(GameEffectToken.tableRailShadowOpacity.rawValue);railShadowRadius=\(GameEffectToken.tableRailShadowRadius.rawValue);playArea=reservedForTrickPlay;playAreaSlots=4;titlePlacement=top;\(dealAnimationAccessibilityValue)"
        )
    }

    private func tableRailSurface(metrics: TableLayoutMetrics) -> some View {
        Circle()
            .fill(GameColorRole.tableSurfaceSecondary.token.swiftUIColor)
            .shadow(
                color: GameColorRole.cardShadow.token.swiftUIColor.opacity(GameEffectToken.tableRailShadowOpacity.value),
                radius: CGFloat(GameEffectToken.tableRailShadowRadius.value),
                y: metrics.tableRailShadowYOffset
            )
            .overlay(
                Circle()
                    .stroke(
                        GameColorRole.tableHighlight.token.swiftUIColor.opacity(GameEffectToken.tableRailHighlightOpacity.value),
                        lineWidth: metrics.tableRailOuterStrokeWidth
                    )
            )
            .overlay(
                Circle()
                    .stroke(
                        GameColorRole.tableSurface.token.swiftUIColor.opacity(GameEffectToken.tableRailInnerBevelOpacity.value),
                        lineWidth: metrics.tableRailInnerBevelWidth
                    )
                    .padding(metrics.tableRailInnerBevelInset)
            )
            .overlay(
                Circle()
                    .stroke(
                        GameColorRole.tableHighlight.token.swiftUIColor.opacity(GameEffectToken.tableInnerRingOpacity.value),
                        lineWidth: 1
                    )
                    .padding(metrics.tableRailHighlightInset)
            )
    }

    private func tablePlayArea(metrics: TableLayoutMetrics) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: metrics.playAreaCornerRadius)
                .fill(GameColorRole.tableSurface.token.swiftUIColor.opacity(GameEffectToken.tableCenterSurfaceOpacity.value))
                .overlay(
                    RoundedRectangle(cornerRadius: metrics.playAreaCornerRadius)
                        .stroke(
                            GameColorRole.tableHighlight.token.swiftUIColor.opacity(GameEffectToken.tableInnerRingOpacity.value),
                            lineWidth: 1
                        )
                )

            ForEach(Seat.allCases, id: \.self) { seat in
                tablePlayAreaSlot(metrics: metrics, seat: seat)
            }
        }
        .frame(width: metrics.playAreaWidth, height: metrics.playAreaHeight)
        .shadow(
            color: GameColorRole.cardShadow.token.swiftUIColor.opacity(GameEffectToken.tablePlayAreaShadowOpacity.value),
            radius: metrics.playAreaShadowRadius,
            y: metrics.playAreaShadowYOffset
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Play area")
        .accessibilityIdentifier("tarneeb-play-area")
        .accessibilityValue(
            Text(
                verbatim: "reservedFor=trickPlay;centerReserved=true;slots=south,west,north,east;slotCount=4;surface=\(GameColorRole.tableSurface.token.rawValue);border=\(GameColorRole.tableHighlight.token.rawValue);slotBorder=\(GameColorRole.cardBorder.token.rawValue);surfaceOpacity=\(GameEffectToken.tableCenterSurfaceOpacity.rawValue);borderOpacity=\(GameEffectToken.tableInnerRingOpacity.rawValue);shadowOpacity=\(GameEffectToken.tablePlayAreaShadowOpacity.rawValue);layout=tableCenter;playedCardMotion=stationToCenter;playedCardTargets=south,west,north,east;playedCardTargetLayout=matchingSeatSlots;playedCardFlight=\(GameAnimationToken.trickPlayedCardFlightDuration.rawValue);playedCardFlightSeconds=\(GameAnimationToken.trickPlayedCardFlightDuration.seconds)"
            )
        )
    }

    private func tablePlayAreaSlot(metrics: TableLayoutMetrics, seat: Seat) -> some View {
        RoundedRectangle(cornerRadius: metrics.playAreaSlotCornerRadius)
            .stroke(
                GameColorRole.cardBorder.token.swiftUIColor.opacity(GameEffectToken.tableInnerRingOpacity.value),
                style: StrokeStyle(lineWidth: 1, dash: [4, 3])
            )
            .frame(width: metrics.playAreaSlotWidth, height: metrics.playAreaSlotHeight)
            .rotationEffect(.degrees(playAreaSlotRotation(for: seat)))
            .offset(playAreaSlotOffset(for: seat, metrics: metrics))
            .accessibilityHidden(true)
    }

    private func playAreaSlotOffset(for seat: Seat, metrics: TableLayoutMetrics) -> CGSize {
        switch seat {
        case .south:
            return CGSize(width: 0, height: metrics.playAreaSlotOffsetY)
        case .west:
            return CGSize(width: -metrics.playAreaSlotOffsetX, height: 0)
        case .north:
            return CGSize(width: 0, height: -metrics.playAreaSlotOffsetY)
        case .east:
            return CGSize(width: metrics.playAreaSlotOffsetX, height: 0)
        }
    }

    private func playAreaSlotRotation(for seat: Seat) -> Double {
        switch seat {
        case .south:
            return 0
        case .west:
            return 90
        case .north:
            return 180
        case .east:
            return -90
        }
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
            dealerSeat: gameState.dealerSeat,
            activeSeat: gameState.currentBiddingSeat,
            bidCueSeat: automatedBidCueSeat,
            isBidCuePulsed: isAutomatedBidCuePulsed
        )
        let bidEntry = stationBidEntry(for: player.seat)

        if expandsSouthStation(for: player.seat) {
            stationBody(for: player)
                .padding(.top, metrics.stationHeaderReservedHeight)
                .padding(.bottom, metrics.stationBodyBottomPadding)
                .frame(maxWidth: metrics.southStationMaxWidth)
                .frame(minHeight: metrics.southStationMinHeight, alignment: .center)
                .background(
                    RoundedRectangle(cornerRadius: metrics.stationCornerRadius)
                        .fill(GameColorRole.tableSurfaceSecondary.token.swiftUIColor.opacity(dealerPresentation.stationBackgroundOpacity))
                        .overlay(
                            RoundedRectangle(cornerRadius: metrics.stationCornerRadius)
                                .stroke(
                                    dealerPresentation.outlineColorRole.token.swiftUIColor,
                                    lineWidth: dealerPresentation.outlineLineWidth
                                )
                        )
                )
                .overlay(alignment: .top) {
                    stationHeader(for: player, dealerPresentation: dealerPresentation, bidEntry: bidEntry)
                        .padding(.horizontal, 4)
                        .padding(.top, 4)
                }
                .overlay(alignment: .topTrailing) {
                    stationTrickCounterSlot(for: player.seat, metrics: metrics)
                        .padding(.trailing, 4)
                        .padding(.top, 4)
                }
                .overlay(alignment: .topTrailing) {
                    if dealerPresentation.isActiveTurn {
                        activeTurnIndicator(dealerPresentation)
                            .padding(8)
                    }
                }
                .scaleEffect(dealerPresentation.stationScale)
                .shadow(
                    color: GameColorRole.stationOutlineActive.token.swiftUIColor.opacity(dealerPresentation.stationShadowOpacity),
                    radius: CGFloat(dealerPresentation.stationShadowRadius)
                )
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("tarneeb-seat-area-\(player.seat.rawValue)")
                .accessibilityValue(stationAccessibilityValue(for: player, metrics: metrics, dealerPresentation: dealerPresentation))
                .animation(
                    .easeInOut(duration: GameAnimationToken.bidStationCuePulseDuration.seconds),
                    value: dealerPresentation.stationScale
                )
                .animation(
                    .easeInOut(duration: GameAnimationToken.bidStationCuePulseDuration.seconds),
                    value: dealerPresentation.isBidMotionCueActive
                )
                .animation(
                    .easeInOut(duration: GameAnimationToken.dealStationExpansionDuration.seconds),
                    value: expandsSouthStation(for: player.seat)
                )
        } else {
            stationBody(for: player)
                .padding(.top, metrics.stationHeaderReservedHeight)
                .padding(.bottom, metrics.stationBodyBottomPadding)
                .frame(width: metrics.compactStationSide, height: metrics.compactStationSide, alignment: .center)
                .background(
                    RoundedRectangle(cornerRadius: metrics.stationCornerRadius)
                        .fill(GameColorRole.tableSurfaceSecondary.token.swiftUIColor.opacity(dealerPresentation.stationBackgroundOpacity))
                        .overlay(
                            RoundedRectangle(cornerRadius: metrics.stationCornerRadius)
                                .stroke(
                                    dealerPresentation.outlineColorRole.token.swiftUIColor,
                                    lineWidth: dealerPresentation.outlineLineWidth
                                )
                        )
                )
                .overlay(alignment: .top) {
                    stationHeader(for: player, dealerPresentation: dealerPresentation, bidEntry: bidEntry)
                        .padding(.horizontal, 4)
                        .padding(.top, 4)
                }
                .overlay(alignment: .topTrailing) {
                    stationTrickCounterSlot(for: player.seat, metrics: metrics)
                        .padding(.trailing, 4)
                        .padding(.top, 4)
                }
                .overlay(alignment: .topTrailing) {
                    if dealerPresentation.isActiveTurn {
                        activeTurnIndicator(dealerPresentation)
                            .padding(8)
                    }
                }
                .scaleEffect(dealerPresentation.stationScale)
                .shadow(
                    color: GameColorRole.stationOutlineActive.token.swiftUIColor.opacity(dealerPresentation.stationShadowOpacity),
                    radius: CGFloat(dealerPresentation.stationShadowRadius)
                )
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("tarneeb-seat-area-\(player.seat.rawValue)")
                .accessibilityValue(stationAccessibilityValue(for: player, metrics: metrics, dealerPresentation: dealerPresentation))
                .animation(
                    .easeInOut(duration: GameAnimationToken.bidStationCuePulseDuration.seconds),
                    value: dealerPresentation.stationScale
                )
                .animation(
                    .easeInOut(duration: GameAnimationToken.bidStationCuePulseDuration.seconds),
                    value: dealerPresentation.isBidMotionCueActive
                )
                .animation(
                    .easeInOut(duration: GameAnimationToken.dealStationExpansionDuration.seconds),
                    value: showsDealtHand(for: player.seat)
                )
        }
    }

    @ViewBuilder
    private func stationBody(for player: Player) -> some View {
        if let sourceDeckStack = sourceDeckStackPresentation(for: player.seat) {
            undealtDeckStackView(sourceDeckStack)
        } else if showsDealtHand(for: player.seat) {
            if player.seat == .south {
                visibleHand(for: player)
            } else {
                hiddenHand(for: player)
            }
        } else {
            Color.clear
        }
    }

    private func stationHeader(
        for player: Player,
        dealerPresentation: DealerStationPresentation,
        bidEntry: BidEntryPresentation?
    ) -> some View {
        HStack(spacing: 4) {
            Text(player.seat.displayLabel)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(GameColorRole.textPrimary.token.swiftUIColor)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .accessibilityIdentifier("tarneeb-seat-\(player.seat.rawValue)")
                .accessibilityValue(Text(verbatim: "text=\(GameColorRole.textPrimary.token.rawValue)"))

            if dealerPresentation.showsDealerPill {
                dealerPillView(dealerPresentation)
            }

            if let bidEntry {
                stationBidBadge(bidEntry)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func sourceDeckStackPresentation(for seat: Seat) -> UndealtDeckStackPresentation? {
        let dealerSeat: Seat
        let hiddenCardCount: Int

        if let dealAnimation {
            dealerSeat = dealAnimation.presentation.dealerSeat
            guard seat == dealerSeat else {
                return nil
            }
            hiddenCardCount = dealAnimation.centralCardCount
        } else {
            dealerSeat = gameState.dealerSeat
            guard gameState.phase == .notStarted, seat == dealerSeat else {
                return nil
            }
            hiddenCardCount = DealAnimationPresentation.totalCards
        }

        guard hiddenCardCount > 0 else {
            return nil
        }

        return UndealtDeckStackPresentation(
            phase: .notStarted,
            hiddenCardCount: hiddenCardCount,
            sizeConfiguration: cardSizeConfiguration,
            dealerSeat: dealerSeat
        )
    }

    private func dealerPillView(_ presentation: DealerStationPresentation) -> some View {
        Text("D")
            .font(.caption2.weight(.bold))
            .foregroundStyle(presentation.dealerPillTextToken.swiftUIColor)
            .lineLimit(1)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(presentation.dealerPillBackgroundToken.swiftUIColor)
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("D")
            .accessibilityIdentifier("tarneeb-dealer-pill-\(presentation.seat.rawValue)")
            .accessibilityValue(presentation.accessibilityValue)
    }

    private func stationBidEntry(for seat: Seat) -> BidEntryPresentation? {
        guard gameState.phase == .dealt,
              dealAnimation == nil,
              let biddingState = gameState.biddingState else {
            return nil
        }

        let legalSouthValues = biddingState.southLegalValues
        let normalizedSouthDraftBid = legalSouthValues.contains(southDraftBid) ? southDraftBid : .pass
        let bidState = biddingState.bids[seat] ?? .pending

        return BidEntryPresentation(
            seat: seat,
            bidState: bidState,
            isSelectable: seat == .south && biddingState.isWaitingForSouth,
            isActiveTurn: seat == biddingState.currentTurnSeat,
            isCurrentHighestBid: seat == biddingState.highestBidSeat
                && bidState.resolvedValue == biddingState.highestBidValue,
            southDraftBid: normalizedSouthDraftBid,
            southDraftTarneebSuit: nil,
            allowedValues: legalSouthValues
        )
    }

    private func stationBidBadge(_ entry: BidEntryPresentation) -> some View {
        Text(entry.valueLabel)
            .font(.caption2.weight(.bold))
            .foregroundStyle(entry.valueColorToken.swiftUIColor)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .id("\(entry.seat.rawValue)-station-bid-\(entry.valueLabel)")
            .transition(.opacity)
            .animation(
                .easeInOut(duration: GameAnimationToken.bidValueFadeOutDuration.seconds + GameAnimationToken.bidValueFadeInDuration.seconds),
                value: entry.valueLabel
            )
            .animation(
                .easeInOut(duration: GameAnimationToken.bidValueFadeOutDuration.seconds + GameAnimationToken.bidValueFadeInDuration.seconds),
                value: entry.valueColorToken.rawValue
            )
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            Capsule()
                .fill(GameColorRole.bidAreaTableDivider.token.swiftUIColor.opacity(GameEffectToken.bidCellDefaultBackgroundOpacity.value))
                .overlay(
                    Capsule()
                        .stroke(
                            entry.isCurrentHighestBid
                                ? GameColorRole.newGameActionBackground.token.swiftUIColor
                                : GameColorRole.bidAreaTableDivider.token.swiftUIColor,
                            lineWidth: entry.isCurrentHighestBid ? 1.5 : 1
                        )
                )
        )
        .accessibilityIdentifier("tarneeb-station-bid-\(entry.seat.rawValue)")
        .accessibilityLabel(Text(verbatim: entry.valueLabel))
        .accessibilityValue(Text(verbatim: entry.accessibilityValue))
    }

    private func activeTurnIndicator(_ presentation: DealerStationPresentation) -> some View {
        Circle()
            .fill(GameColorRole.newGameActionBackground.token.swiftUIColor)
            .frame(width: 9, height: 9)
            .accessibilityLabel("Active bidder")
            .accessibilityIdentifier("tarneeb-active-bidder-\(presentation.seat.rawValue)")
            .accessibilityValue(Text(verbatim: "activeTurn=\(presentation.isActiveTurn);color=\(GameColorRole.newGameActionBackground.token.rawValue)"))
    }

    private func stationTrickCounterSlot(for seat: Seat, metrics: TableLayoutMetrics) -> some View {
        Text("0")
            .font(.caption2.weight(.bold))
            .foregroundStyle(GameColorRole.textSecondary.token.swiftUIColor)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .frame(width: metrics.stationTrickCounterWidth, height: metrics.stationTrickCounterHeight)
            .background(
                Capsule()
                    .fill(GameColorRole.bidAreaTableDivider.token.swiftUIColor.opacity(GameEffectToken.bidCellDefaultBackgroundOpacity.value))
                    .overlay(
                        Capsule()
                            .stroke(GameColorRole.bidAreaTableDivider.token.swiftUIColor, lineWidth: 1)
                    )
            )
            .opacity(0)
            .allowsHitTesting(false)
            .accessibilityIdentifier("tarneeb-trick-counter-slot-\(seat.rawValue)")
            .accessibilityValue(Text(verbatim: "reserved=true;visible=false;count=none;placement=topTrailing"))
            .accessibilityHidden(true)
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
        let cardPresentations = SouthHandPresentation.cardPresentations(
            from: player.hand,
            sizeConfiguration: cardSizeConfiguration
        )
        let layout = SouthHandPresentation.readableLayout(
            cardCount: cardPresentations.count,
            sizeConfiguration: cardSizeConfiguration
        )

        return LazyVGrid(
            columns: [
                GridItem(
                    .adaptive(
                        minimum: CGFloat(cardSizeConfiguration.baseCardWidth + layout.additionalSuitBoundarySpacing)
                    ),
                    spacing: CGFloat(layout.cardSpacing)
                )
            ],
            spacing: CGFloat(layout.cardSpacing)
        ) {
            ForEach(Array(cardPresentations.enumerated()), id: \.element.cardID) { index, presentation in
                cardFaceView(presentation)
                    .padding(
                        .leading,
                        CGFloat(layout.additionalLeadingSpacing(beforeCardAt: index, in: cardPresentations))
                    )
            }
        }
        .background(alignment: .bottom) {
            southHandOwnershipRail()
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-visible-hand-\(player.seat.rawValue)")
        .accessibilityValue(Text(verbatim: "\(layout.accessibilityValue);\(southHandOwnershipAccessibilityValue)"))
    }

    private func southRevealHand(for player: Player, dealAnimation: DealAnimationPlayback) -> some View {
        let cardPresentations = SouthHandPresentation.cardPresentations(
            from: player.hand,
            sizeConfiguration: cardSizeConfiguration
        )

        let layout = SouthHandPresentation.readableLayout(
            cardCount: cardPresentations.count,
            sizeConfiguration: cardSizeConfiguration
        )

        return LazyVGrid(
            columns: [
                GridItem(
                    .adaptive(
                        minimum: CGFloat(cardSizeConfiguration.baseCardWidth + layout.additionalSuitBoundarySpacing)
                    ),
                    spacing: CGFloat(layout.cardSpacing)
                )
            ],
            spacing: CGFloat(layout.cardSpacing)
        ) {
            ForEach(Array(cardPresentations.enumerated()), id: \.element.cardID) { index, presentation in
                let leadingSpacing = CGFloat(layout.additionalLeadingSpacing(beforeCardAt: index, in: cardPresentations))

                if index < dealAnimation.southRevealedCardCount {
                    cardFaceView(presentation)
                        .padding(.leading, leadingSpacing)
                        .transition(.opacity.combined(with: .scale(scale: 0.94)))
                } else {
                    southRevealCardBack(index: index)
                        .padding(.leading, leadingSpacing)
                        .transition(.opacity)
                }
            }
        }
        .background(alignment: .bottom) {
            southHandOwnershipRail()
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-south-reveal-hand")
        .accessibilityValue(
            Text(verbatim: "state=\(dealAnimation.southRevealState.rawValue);backCount=\(DealAnimationPresentation.cardsPerStack);revealedCount=\(dealAnimation.southRevealedCardCount);direction=leftToRight;totalDuration=\(GameAnimationToken.dealSouthRevealTotalDuration.rawValue);totalSeconds=\(GameAnimationToken.dealSouthRevealTotalDuration.seconds);\(layout.accessibilityValue);\(southHandOwnershipAccessibilityValue)")
        )
    }

    private func southHandOwnershipRail() -> some View {
        RoundedRectangle(cornerRadius: CGFloat(cardSizeConfiguration.cornerRadius + 2))
            .fill(GameColorRole.tableSurfaceSecondary.token.swiftUIColor.opacity(GameEffectToken.southHandRailBackgroundOpacity.value))
            .overlay(alignment: .bottom) {
                Capsule()
                    .fill(GameColorRole.tableHighlight.token.swiftUIColor.opacity(GameEffectToken.southHandRailStrokeOpacity.value))
                    .frame(height: 1)
                    .padding(.horizontal, 6)
                    .padding(.bottom, 2)
            }
            .frame(height: CGFloat(cardSizeConfiguration.baseCardHeight * 0.42))
            .offset(y: 3)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    private var southHandOwnershipAccessibilityValue: String {
        "ownership=player;ownershipSurface=baselineRail;ownershipSurfaceVisible=true;ownershipBackgroundOpacity=\(GameEffectToken.southHandRailBackgroundOpacity.rawValue);ownershipStrokeOpacity=\(GameEffectToken.southHandRailStrokeOpacity.rawValue)"
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
                let transform = presentation.visualTransform(for: hiddenCard)

                Image(hiddenCard.assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: hiddenCard.sizeConfiguration.baseCardWidth,
                        height: hiddenCard.sizeConfiguration.baseCardHeight
                    )
                    .rotationEffect(.degrees(transform.rotationDegrees))
                    .offset(x: transform.offsetX, y: transform.offsetY)
                    .accessibilityLabel(hiddenCard.accessibilityLabel)
                    .accessibilityIdentifier("tarneeb-hidden-card-back-\(player.seat.rawValue)")
                    .accessibilityValue(hiddenCard.accessibilityValue)
            }
        }
        .frame(width: presentation.stackWidth, height: presentation.stackHeight, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-hidden-hand-\(player.seat.rawValue)")
        .accessibilityValue(Text(verbatim: presentation.accessibilityValue))
    }

    private func bidAreaView(_ presentation: BidAreaPresentation, metrics: TableLayoutMetrics) -> some View {
        VStack(alignment: .leading, spacing: CGFloat(presentation.areaTokens.rowGap.numericValue)) {
            HStack(alignment: .firstTextBaseline) {
                Text(presentation.label)
                    .font(.headline)
                    .foregroundStyle(presentation.areaTokens.label.swiftUIColor)
                    .accessibilityIdentifier("tarneeb-bid-label")
                    .accessibilityValue(Text(verbatim: "text=\(presentation.areaTokens.label.rawValue)"))

                Spacer(minLength: 8)

                biddingTurnPill(presentation)
            }

            stationBidMetadataTable(presentation)

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

    private func biddingTurnPill(_ presentation: BidAreaPresentation) -> some View {
        let label = presentation.currentTurnSeat.map { "Turn \($0.displayLabel)" } ?? "Complete"

        return Text(label)
            .font(.caption2.weight(.bold))
            .foregroundStyle(GameColorRole.textPrimary.token.swiftUIColor)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(presentation.areaTokens.divider.swiftUIColor.opacity(GameEffectToken.bidTurnPillBackgroundOpacity.value))
                    .overlay(
                        Capsule()
                            .stroke(presentation.areaTokens.border.swiftUIColor, lineWidth: 1)
                    )
            )
        .accessibilityIdentifier("tarneeb-bid-turn-indicator")
        .accessibilityValue(Text(verbatim: "currentTurn=\(presentation.currentTurnSeat?.rawValue ?? "none");text=\(GameColorRole.textPrimary.token.rawValue)"))
    }

    private func stationBidMetadataTable(_ presentation: BidAreaPresentation) -> some View {
        Color.clear
            .frame(height: 1)
            .accessibilityElement(children: .ignore)
            .accessibilityIdentifier("tarneeb-bid-table")
            .accessibilityValue(Text(verbatim: "display=station-surfaces;\(presentation.accessibilityValue)"))
            .accessibilityHidden(false)
    }

    private func postBiddingSummaryView(_ presentation: PostBiddingSummaryPresentation) -> some View {
        HStack(alignment: .center, spacing: 6) {
            Text(presentation.tarneebLabel)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(presentation.tokens.labelText.swiftUIColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            postBiddingTarneebSuitChip(presentation)
        }
        .padding(.horizontal, CGFloat(presentation.tokens.padding.numericValue))
        .padding(.vertical, 6)
        .fixedSize(horizontal: true, vertical: false)
        .background(
            Capsule()
                .fill(presentation.tokens.background.swiftUIColor)
                .overlay(
                    Capsule()
                        .stroke(presentation.tokens.border.swiftUIColor, lineWidth: 1)
                )
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-post-bidding-summary")
        .accessibilityValue(presentation.accessibilityValue)
    }

    private func postBiddingTarneebSuitChip(_ presentation: PostBiddingSummaryPresentation) -> some View {
        Text(presentation.tarneebSymbol)
            .font(.caption.weight(.bold))
            .foregroundStyle(presentation.tarneebSymbolColorToken.swiftUIColor)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.horizontal, 5)
            .padding(.vertical, 1)
            .background(
                CardSuitChipBackground(
                    tokens: presentation.tarneebSymbolChipTokens,
                    isSelected: true,
                    isPressed: false
                )
            )
    }

    private func southTarneebSelectionView(_ presentation: SouthTarneebSelectionPresentation, metrics: TableLayoutMetrics) -> some View {
        VStack(alignment: .leading, spacing: CGFloat(presentation.tokens.rowGap.numericValue)) {
            Text("Contract")
                .font(.caption.weight(.bold))
                .foregroundStyle(presentation.tokens.labelText.swiftUIColor)

            HStack(alignment: .bottom, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Player")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(presentation.tokens.labelText.swiftUIColor)
                    Text(presentation.highBidderLabel)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(presentation.tokens.teamText.swiftUIColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }

                Spacer(minLength: 8)

                VStack(alignment: .center, spacing: 2) {
                    Text("Bid")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(presentation.tokens.labelText.swiftUIColor)
                    Text(presentation.bidValueLabel)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(presentation.tokens.bidText.swiftUIColor)
                }
            }

            Text(presentation.tarneebLabel)
                .font(.caption.weight(.semibold))
                .foregroundStyle(presentation.tokens.labelText.swiftUIColor)

            HStack(alignment: .center, spacing: CGFloat(presentation.tokens.rowGap.numericValue)) {
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
                .layoutPriority(1)
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("tarneeb-post-bidding-suit-selector-south")
                .accessibilityValue(Text(verbatim: "visible=true;enabled=true;selected=\(southDraftTarneebSuit?.rawValue ?? "none");options=\(presentation.suitOptionsLabel);\(presentation.suitSelectorTokens.accessibilityValue)"))

                Spacer(minLength: CGFloat(presentation.tokens.rowGap.numericValue))

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
            .frame(maxWidth: .infinity, alignment: .leading)
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
                HStack(alignment: .center, spacing: CGFloat(presentation.areaTokens.rowGap.numericValue)) {
                    southBidChoiceTray(presentation: presentation)
                        .layoutPriority(1)

                    Spacer(minLength: CGFloat(presentation.areaTokens.rowGap.numericValue))

                    southBidButton(presentation: presentation)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if presentation.southSuitSelectorVisible {
                    southTarneebSuitSelector(presentation: presentation)
                }
            } else {
                southBidButton(presentation: presentation)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(presentation.areaTokens.divider.swiftUIColor.opacity(GameEffectToken.bidActionTrayBackgroundOpacity.value))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(presentation.areaTokens.border.swiftUIColor, lineWidth: 1)
                )
        )
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
        HStack(spacing: CGFloat(presentation.selectorTokens.optionGap.numericValue)) {
            ForEach(presentation.allowedValues, id: \.self) { bidValue in
                Button(bidValue.displayLabel) {
                    selectSouthDraftBid(bidValue)
                }
                .buttonStyle(
                    BidChoiceChipButtonStyle(
                        isSelected: southDraftBid == bidValue,
                        isPass: bidValue == .pass,
                        tokens: presentation.selectorTokens
                    )
                )
                .accessibilityIdentifier("tarneeb-bid-option-\(bidOptionIdentifier(for: bidValue))")
            }
        }
        .frame(maxWidth: .infinity, minHeight: CGFloat(presentation.selectorTokens.height.numericValue), alignment: .leading)
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
        let borderToken = isSelected ? tokens.focusRing : tokens.border
        let accessibilityValue = "selected=\(isSelected);enabled=\(isEnabled);symbol=\(suit.displaySymbol);background=\(tokens.background.rawValue);border=\(borderToken.rawValue);selectedBorder=\(tokens.focusRing.rawValue);text=\(suit.colorToken.rawValue)"

        return Button {
            selectSouthDraftTarneebSuit(suit)
        } label: {
            Text(suit.displaySymbol)
                .font(.caption.weight(.bold))
                .frame(minWidth: optionWidth, minHeight: optionHeight)
        }
        .buttonStyle(BidSuitChipButtonStyle(tokens: tokens, suit: suit, isSelected: isSelected))
        .disabled(!isEnabled)
        .accessibilityIdentifier("tarneeb-bid-suit-option-\(suit.rawValue)")
        .accessibilityLabel(Text(verbatim: suit.rawValue.capitalized))
        .accessibilityValue(Text(verbatim: accessibilityValue))
    }

    private var bottomDealControl: some View {
        VStack(spacing: 4) {
            if gameState.phase == .dealt {
                phaseStatusPill
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
        .overlay(alignment: .top) {
            Rectangle()
                .fill(GameColorRole.tableHighlight.token.swiftUIColor.opacity(GameEffectToken.bottomControlSeparatorOpacity.value))
                .frame(height: 1)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-bottom-deal-control")
        .accessibilityValue(Text(verbatim: "buttons=New Game,Deal;phaseStatusVisible=\(gameState.phase == .dealt);phaseStatusTreatment=compactPhasePill;newGameTokens=\(ButtonTokenSet.newGame.accessibilityValue);dealTokens=\(ButtonTokenSet.deal.accessibilityValue)"))
    }

    private var phaseStatusPill: some View {
        Text(statusLabelText)
            .font(.caption.weight(.semibold))
            .foregroundStyle(GameColorRole.textPrimary.token.swiftUIColor)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.leading, 20)
            .padding(.trailing, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(GameColorRole.tableSurfaceSecondary.token.swiftUIColor.opacity(GameEffectToken.phaseStatusBackgroundOpacity.value))
                    .overlay(
                        Capsule()
                            .stroke(GameColorRole.tableHighlight.token.swiftUIColor.opacity(GameEffectToken.statusPillBorderOpacity.value), lineWidth: 1)
                    )
            )
            .overlay(alignment: .leading) {
                Circle()
                    .fill(phaseStatusAccentColor)
                    .frame(width: 6, height: 6)
                    .padding(.leading, 8)
                    .accessibilityHidden(true)
            }
            .accessibilityIdentifier("tarneeb-deal-complete-message")
            .accessibilityValue(Text(verbatim: "text=\(GameColorRole.textPrimary.token.rawValue);status=\(statusLabelText);phase=\(gameState.phase.rawValue);biddingStatus=\(gameState.biddingStatus?.rawValue ?? "none");treatment=compactPhasePill;backgroundOpacity=\(GameEffectToken.phaseStatusBackgroundOpacity.rawValue);borderOpacity=\(GameEffectToken.statusPillBorderOpacity.rawValue)"))
    }

    private var phaseStatusAccentColor: Color {
        if gameState.biddingStatus == .complete {
            return GameColorRole.newGameActionBackground.token.swiftUIColor
        }

        return GameColorRole.tableHighlight.token.swiftUIColor
    }

    private func deal() {
        guard !isDealAnimationRunning else {
            return
        }

        cancelSimulatedBiddingTask()
        cancelBiddingAreaFadeTask()
        isBiddingAreaFadingOut = false
        clearAutomatedBidCue()
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
        clearAutomatedBidCue()
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
        clearAutomatedBidCue()
    }

    private func cancelBiddingAreaFadeTask() {
        biddingAreaFadeTask?.cancel()
        biddingAreaFadeTask = nil
    }

    private func clearAutomatedBidCue() {
        automatedBidCueSeat = nil
        isAutomatedBidCuePulsed = false
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

            await cueAutomatedBid(for: currentBiddingSeat)

            guard !Task.isCancelled,
                  gameState.phase == .dealt,
                  gameState.biddingStatus == .inProgress,
                  gameState.currentBiddingSeat == currentBiddingSeat else {
                clearAutomatedBidCue()
                return
            }

            withAnimation(.easeInOut(duration: GameAnimationToken.bidValueFadeOutDuration.seconds + GameAnimationToken.bidValueFadeInDuration.seconds)) {
                presentationState.resolveNextSimulatedBid()
                gameState = presentationState.gameState
                southDraftBid = normalizedSouthDraftBid(for: gameState)
                southDraftTarneebSuit = normalizedSouthDraftTarneebSuit(for: gameState)
            }

            withAnimation(.easeInOut(duration: GameAnimationToken.bidStationCuePulseDuration.seconds)) {
                clearAutomatedBidCue()
            }

            beginTerminalBiddingTransitionIfNeeded()
        }

        simulatedBiddingTask = nil
    }

    @MainActor
    private func cueAutomatedBid(for seat: Seat) async {
        withAnimation(.easeOut(duration: GameAnimationToken.bidStationCuePulseDuration.seconds)) {
            automatedBidCueSeat = seat
            isAutomatedBidCuePulsed = true
        }

        try? await Task.sleep(nanoseconds: GameAnimationToken.bidStationCuePulseDuration.nanoseconds)

        guard !Task.isCancelled else {
            clearAutomatedBidCue()
            return
        }

        withAnimation(.easeIn(duration: GameAnimationToken.bidStationCuePulseDuration.seconds)) {
            isAutomatedBidCuePulsed = false
        }

        try? await Task.sleep(nanoseconds: GameAnimationToken.bidStationCuePulseDuration.nanoseconds)
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
        switch gameState.biddingStatus {
        case .complete:
            return "Bidding complete"
        case .inProgress, nil:
            return "Deal complete"
        }
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
            dealerSeat: dealAnimation?.presentation.dealerSeat ?? gameState.dealerSeat,
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
        let bidEntry = stationBidEntry(for: player.seat)

        return [
            "label=\(GameColorRole.textPrimary.token.rawValue)",
            "outline=\(dealerPresentation.outlineToken.rawValue)",
            "shape=\(shapeValue)",
            "position=\(player.seat.rawValue)",
            "activeTurn=\(dealerPresentation.isActiveTurn)",
            "bidSurfaceVisible=\(bidEntry != nil)",
            "bid=\(bidEntry?.valueLabel ?? "none")",
            "bidValueText=\(bidEntry?.valueColorToken.rawValue ?? "none")",
            "trickCounterReserved=true",
            "trickCounterVisible=false",
            "trickCount=none",
            "trickCounterPlacement=topTrailing",
            "trickCounterWidth=\(Int(metrics.stationTrickCounterWidth.rounded()))",
            "trickCounterHeight=\(Int(metrics.stationTrickCounterHeight.rounded()))",
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

    var tableCenterInset: CGFloat {
        tableDiameter * 0.22
    }

    var tableInnerRingInset: CGFloat {
        tableDiameter * 0.12
    }

    var tableTitleVerticalOffset: CGFloat {
        tableDiameter * 0.36
    }

    var tableRailOuterStrokeWidth: CGFloat {
        max(2, tableDiameter * 0.01)
    }

    var tableRailInnerBevelInset: CGFloat {
        max(7, tableDiameter * 0.045)
    }

    var tableRailInnerBevelWidth: CGFloat {
        max(3, tableDiameter * 0.02)
    }

    var tableRailHighlightInset: CGFloat {
        max(12, tableDiameter * 0.07)
    }

    var tableRailShadowYOffset: CGFloat {
        max(2, tableDiameter * 0.012)
    }

    var playAreaWidth: CGFloat {
        tableDiameter * 0.58
    }

    var playAreaHeight: CGFloat {
        tableDiameter * 0.42
    }

    var playAreaCornerRadius: CGFloat {
        14
    }

    var playAreaShadowRadius: CGFloat {
        3
    }

    var playAreaShadowYOffset: CGFloat {
        1
    }

    var playAreaSlotWidth: CGFloat {
        tableDiameter * 0.14
    }

    var playAreaSlotHeight: CGFloat {
        tableDiameter * 0.20
    }

    var playAreaSlotCornerRadius: CGFloat {
        max(4, playAreaSlotWidth * 0.18)
    }

    var playAreaSlotOffsetX: CGFloat {
        playAreaWidth * 0.27
    }

    var playAreaSlotOffsetY: CGFloat {
        playAreaHeight * 0.24
    }

    var contractRibbonVerticalOffset: CGFloat {
        tableDiameter * CGFloat(GameBidLayoutToken.postBiddingSummaryTableEdgeVerticalOffsetRatio.numericValue)
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

    var stationHeaderReservedHeight: CGFloat {
        24
    }

    var stationTrickCounterWidth: CGFloat {
        22
    }

    var stationTrickCounterHeight: CGFloat {
        16
    }

    var stationBodyBottomPadding: CGFloat {
        4
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
    let tokens: BidSelectorTokenSet
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption.weight(.bold))
            .foregroundStyle(foregroundColor.swiftUIColor)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .frame(
                minWidth: CGFloat(tokens.minimumWidth.numericValue) + (isPass ? 12 : 0),
                minHeight: 32
            )
            .padding(.horizontal, isPass ? 2 : 0)
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
    let tokens: BidSuitSelectorTokenSet
    let suit: Suit
    let isSelected: Bool
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foregroundColor.swiftUIColor)
            .background(
                CardSuitChipBackground(
                    tokens: tokens,
                    isSelected: isSelected,
                    isPressed: configuration.isPressed
                )
            )
            .opacity(isEnabled ? 1 : tokens.disabledOpacity.value)
    }

    private var foregroundColor: GameColorToken {
        suit.colorToken
    }
}

private struct CardSuitChipBackground: View {
    let tokens: BidSuitSelectorTokenSet
    let isSelected: Bool
    let isPressed: Bool

    private var borderColor: GameColorToken {
        isSelected || isPressed ? tokens.focusRing : tokens.border
    }

    private var lineWidth: CGFloat {
        isSelected || isPressed ? 2 : 1
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(tokens.background.swiftUIColor)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor.swiftUIColor, lineWidth: lineWidth)
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
