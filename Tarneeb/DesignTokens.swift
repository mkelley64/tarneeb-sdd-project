enum GameColorToken: String, CaseIterable, Equatable, Hashable {
    case tableBackgroundPrimary = "color.table.background.primary"
    case tableBackgroundSecondary = "color.table.background.secondary"
    case tableFeltHighlight = "color.table.felt.highlight"
    case cardBackground = "color.card.background"
    case cardBorder = "color.card.border"
    case cardShadow = "color.card.shadow"
    case cardSuitRed = "color.card.suit.red"
    case cardSuitRedDark = "color.card.suit.red.dark"
    case cardSuitBlack = "color.card.suit.black"
    case cardSuitBlackSoft = "color.card.suit.black.soft"
    case stationOutline = "color.station.outline"
    case stationOutlineActive = "color.station.outline.active"
    case stationOutlineInactive = "color.station.outline.inactive"
    case dealerBadgeBackground = "color.dealerBadge.background"
    case dealerBadgeText = "color.dealerBadge.text"
    case textPrimary = "color.text.primary"
    case textSecondary = "color.text.secondary"
    case textDisabled = "color.text.disabled"
    case textWarning = "color.text.warning"
    case bidAreaBackground = "color.bidArea.background"
    case bidAreaBorder = "color.bidArea.border"
    case bidAreaLabel = "color.bidArea.label"
    case bidAreaTableDivider = "color.bidArea.table.divider"
    case bidAreaValueText = "color.bidArea.value.text"
    case bidAreaPendingValueText = "color.bidArea.value.pending.text"
    case bidAreaHighestValueText = "color.bidArea.value.highest.text"
    case bidAreaSeatText = "color.bidArea.seat.text"
    case postBiddingSummaryBackground = "color.postBiddingSummary.background"
    case postBiddingSummaryBorder = "color.postBiddingSummary.border"
    case postBiddingSummaryLabelText = "color.postBiddingSummary.label.text"
    case postBiddingSummaryTeamText = "color.postBiddingSummary.team.text"
    case postBiddingSummaryBidText = "color.postBiddingSummary.bid.text"
    case postBiddingSummaryTarneebText = "color.postBiddingSummary.tarneeb.text"
    case bidSelectorBackground = "color.bidSelector.background"
    case bidSelectorBorder = "color.bidSelector.border"
    case bidSelectorText = "color.bidSelector.text"
    case bidSelectorFocusRing = "color.bidSelector.focusRing"
    case bidSuitSelectorBackground = "color.bidSuitSelector.background"
    case bidSuitSelectorBorder = "color.bidSuitSelector.border"
    case bidSuitSelectorText = "color.bidSuitSelector.text"
    case bidSuitSelectorSelectedBackground = "color.bidSuitSelector.selected.background"
    case bidSuitSelectorSelectedText = "color.bidSuitSelector.selected.text"
    case bidSuitSelectorFocusRing = "color.bidSuitSelector.focusRing"
    case tableTitleText = "color.tableTitle.text"
    case tableTitleShadow = "effect.tableTitle.shadow.color"
    case buttonDealBackground = "color.button.deal.background"
    case buttonDealBackgroundPressed = "color.button.deal.background.pressed"
    case buttonDealText = "color.button.deal.text"
    case buttonBidBackground = "color.button.bid.background"
    case buttonBidBackgroundPressed = "color.button.bid.background.pressed"
    case buttonBidText = "color.button.bid.text"
    case buttonNewGameBackground = "color.button.newGame.background"
    case buttonNewGameBackgroundPressed = "color.button.newGame.background.pressed"
    case buttonNewGameText = "color.button.newGame.text"
    case buttonDestructiveBackground = "color.button.destructive.background"
    case buttonDestructiveText = "color.button.destructive.text"

    var hexValue: String {
        switch self {
        case .tableBackgroundPrimary:
            return "#1E5A3C"
        case .tableBackgroundSecondary:
            return "#17452E"
        case .tableFeltHighlight:
            return "#2B7A52"
        case .cardBackground:
            return "#FDFDFB"
        case .cardBorder:
            return "#D7D7D2"
        case .cardShadow:
            return "#00000022"
        case .cardSuitRed:
            return "#C62828"
        case .cardSuitRedDark:
            return "#8E1B1B"
        case .cardSuitBlack:
            return "#1A1A1A"
        case .cardSuitBlackSoft:
            return "#2E2E2E"
        case .stationOutline:
            return "#F5F5F5"
        case .stationOutlineActive:
            return "#FFFFFF"
        case .stationOutlineInactive:
            return "#FFFFFF66"
        case .dealerBadgeBackground:
            return "#1976D2"
        case .dealerBadgeText:
            return "#FFFFFF"
        case .textPrimary:
            return "#FFFFFF"
        case .textSecondary:
            return "#D9D9D9"
        case .textDisabled:
            return "#FFFFFF66"
        case .textWarning:
            return "#FFD166"
        case .bidAreaBackground:
            return "#123A2A"
        case .bidAreaBorder:
            return "#E8DFC866"
        case .bidAreaLabel:
            return "#E8DFC8"
        case .bidAreaTableDivider:
            return "#FFFFFF2E"
        case .bidAreaValueText:
            return "#FFFFFF"
        case .bidAreaPendingValueText:
            return "#FFFFFF99"
        case .bidAreaHighestValueText:
            return "#FFB300"
        case .bidAreaSeatText:
            return "#D9D9D9"
        case .postBiddingSummaryBackground:
            return "#123A2A"
        case .postBiddingSummaryBorder:
            return "#E8DFC866"
        case .postBiddingSummaryLabelText:
            return "#D9D9D9"
        case .postBiddingSummaryTeamText:
            return "#FFFFFF"
        case .postBiddingSummaryBidText:
            return "#FFB300"
        case .postBiddingSummaryTarneebText:
            return "#FFFFFF"
        case .bidSelectorBackground:
            return "#FDFDFB"
        case .bidSelectorBorder:
            return "#D7D7D2"
        case .bidSelectorText:
            return "#1A1A1A"
        case .bidSelectorFocusRing:
            return "#1976D2"
        case .bidSuitSelectorBackground:
            return "#FDFDFB"
        case .bidSuitSelectorBorder:
            return "#D7D7D2"
        case .bidSuitSelectorText:
            return "#1A1A1A"
        case .bidSuitSelectorSelectedBackground:
            return "#1976D2"
        case .bidSuitSelectorSelectedText:
            return "#FFFFFF"
        case .bidSuitSelectorFocusRing:
            return "#1976D2"
        case .tableTitleText:
            return "#E8DFC8"
        case .tableTitleShadow:
            return "#000000"
        case .buttonDealBackground:
            return "#1976D2"
        case .buttonDealBackgroundPressed:
            return "#1257A0"
        case .buttonDealText:
            return "#FFFFFF"
        case .buttonBidBackground:
            return "#1976D2"
        case .buttonBidBackgroundPressed:
            return "#1257A0"
        case .buttonBidText:
            return "#FFFFFF"
        case .buttonNewGameBackground:
            return "#FFB300"
        case .buttonNewGameBackgroundPressed:
            return "#CC8A00"
        case .buttonNewGameText:
            return "#1A1A1A"
        case .buttonDestructiveBackground:
            return "#B71C1C"
        case .buttonDestructiveText:
            return "#FFFFFF"
        }
    }
}

enum GameColorRole: String, CaseIterable, Equatable, Hashable {
    case tableSurface
    case tableSurfaceSecondary
    case tableHighlight
    case cardFace
    case cardBorder
    case cardShadow
    case suitWarm
    case suitWarmEmphasis
    case suitNeutral
    case suitNeutralSecondary
    case stationOutline
    case stationOutlineActive
    case stationOutlineInactive
    case dealerBadgeBackground
    case dealerBadgeText
    case textPrimary
    case textSecondary
    case textDisabled
    case textWarning
    case bidAreaBackground
    case bidAreaBorder
    case bidAreaLabel
    case bidAreaTableDivider
    case bidAreaValueText
    case bidAreaPendingValueText
    case bidAreaHighestValueText
    case bidAreaSeatText
    case postBiddingSummaryBackground
    case postBiddingSummaryBorder
    case postBiddingSummaryLabelText
    case postBiddingSummaryTeamText
    case postBiddingSummaryBidText
    case postBiddingSummaryTarneebText
    case bidSelectorBackground
    case bidSelectorBorder
    case bidSelectorText
    case bidSelectorFocusRing
    case bidSuitSelectorBackground
    case bidSuitSelectorBorder
    case bidSuitSelectorText
    case bidSuitSelectorSelectedBackground
    case bidSuitSelectorSelectedText
    case bidSuitSelectorFocusRing
    case tableTitleText
    case tableTitleShadow
    case dealActionBackground
    case dealActionPressedBackground
    case dealActionText
    case bidActionBackground
    case bidActionPressedBackground
    case bidActionText
    case newGameActionBackground
    case newGameActionPressedBackground
    case newGameActionText

    var token: GameColorToken {
        switch self {
        case .tableSurface:
            return .tableBackgroundPrimary
        case .tableSurfaceSecondary:
            return .tableBackgroundSecondary
        case .tableHighlight:
            return .tableFeltHighlight
        case .cardFace:
            return .cardBackground
        case .cardBorder:
            return .cardBorder
        case .cardShadow:
            return .cardShadow
        case .suitWarm:
            return .cardSuitRed
        case .suitWarmEmphasis:
            return .cardSuitRedDark
        case .suitNeutral:
            return .cardSuitBlack
        case .suitNeutralSecondary:
            return .cardSuitBlackSoft
        case .stationOutline:
            return .stationOutline
        case .stationOutlineActive:
            return .stationOutlineActive
        case .stationOutlineInactive:
            return .stationOutlineInactive
        case .dealerBadgeBackground:
            return .dealerBadgeBackground
        case .dealerBadgeText:
            return .dealerBadgeText
        case .textPrimary:
            return .textPrimary
        case .textSecondary:
            return .textSecondary
        case .textDisabled:
            return .textDisabled
        case .textWarning:
            return .textWarning
        case .bidAreaBackground:
            return .bidAreaBackground
        case .bidAreaBorder:
            return .bidAreaBorder
        case .bidAreaLabel:
            return .bidAreaLabel
        case .bidAreaTableDivider:
            return .bidAreaTableDivider
        case .bidAreaValueText:
            return .bidAreaValueText
        case .bidAreaPendingValueText:
            return .bidAreaPendingValueText
        case .bidAreaHighestValueText:
            return .bidAreaHighestValueText
        case .bidAreaSeatText:
            return .bidAreaSeatText
        case .postBiddingSummaryBackground:
            return .postBiddingSummaryBackground
        case .postBiddingSummaryBorder:
            return .postBiddingSummaryBorder
        case .postBiddingSummaryLabelText:
            return .postBiddingSummaryLabelText
        case .postBiddingSummaryTeamText:
            return .postBiddingSummaryTeamText
        case .postBiddingSummaryBidText:
            return .postBiddingSummaryBidText
        case .postBiddingSummaryTarneebText:
            return .postBiddingSummaryTarneebText
        case .bidSelectorBackground:
            return .bidSelectorBackground
        case .bidSelectorBorder:
            return .bidSelectorBorder
        case .bidSelectorText:
            return .bidSelectorText
        case .bidSelectorFocusRing:
            return .bidSelectorFocusRing
        case .bidSuitSelectorBackground:
            return .bidSuitSelectorBackground
        case .bidSuitSelectorBorder:
            return .bidSuitSelectorBorder
        case .bidSuitSelectorText:
            return .bidSuitSelectorText
        case .bidSuitSelectorSelectedBackground:
            return .bidSuitSelectorSelectedBackground
        case .bidSuitSelectorSelectedText:
            return .bidSuitSelectorSelectedText
        case .bidSuitSelectorFocusRing:
            return .bidSuitSelectorFocusRing
        case .tableTitleText:
            return .tableTitleText
        case .tableTitleShadow:
            return .tableTitleShadow
        case .dealActionBackground:
            return .buttonDealBackground
        case .dealActionPressedBackground:
            return .buttonDealBackgroundPressed
        case .dealActionText:
            return .buttonDealText
        case .bidActionBackground:
            return .buttonBidBackground
        case .bidActionPressedBackground:
            return .buttonBidBackgroundPressed
        case .bidActionText:
            return .buttonBidText
        case .newGameActionBackground:
            return .buttonNewGameBackground
        case .newGameActionPressedBackground:
            return .buttonNewGameBackgroundPressed
        case .newGameActionText:
            return .buttonNewGameText
        }
    }
}

enum GameTypographyToken: String, CaseIterable, Equatable, Hashable {
    case tableTitleFont = "typography.tableTitle.font"
    case tableTitleFontSize = "typography.tableTitle.fontSize"
    case tableTitleTrackingMinimum = "typography.tableTitle.tracking.min"
    case tableTitleTrackingMaximum = "typography.tableTitle.tracking.max"

    var stringValue: String {
        switch self {
        case .tableTitleFont:
            return "SF Arabic Rounded Bold"
        case .tableTitleFontSize:
            return "26pt"
        case .tableTitleTrackingMinimum:
            return "+2"
        case .tableTitleTrackingMaximum:
            return "+4"
        }
    }

    var numericValue: Double? {
        switch self {
        case .tableTitleFont:
            return nil
        case .tableTitleFontSize:
            return 26
        case .tableTitleTrackingMinimum:
            return 2
        case .tableTitleTrackingMaximum:
            return 4
        }
    }
}

enum GameEffectToken: String, CaseIterable, Equatable, Hashable {
    case tableTitleTextOpacity = "effect.tableTitle.text.opacity"
    case tableTitleShadowOpacity = "effect.tableTitle.shadow.opacity"
    case tableTitleShadowBlurRadius = "effect.tableTitle.shadow.blurRadius"
    case bidButtonDisabledOpacity = "effect.bidButton.disabled.opacity"
    case bidSuitSelectorDisabledOpacity = "effect.bidSuitSelector.disabled.opacity"

    var value: Double {
        switch self {
        case .tableTitleTextOpacity:
            return 0.92
        case .tableTitleShadowOpacity:
            return 0.25
        case .tableTitleShadowBlurRadius:
            return 4
        case .bidButtonDisabledOpacity:
            return 0.55
        case .bidSuitSelectorDisabledOpacity:
            return 0.55
        }
    }
}

enum GameAnimationToken: String, CaseIterable, Equatable, Hashable {
    case dealStackFlightDuration = "animation.deal.stack.flight.duration"
    case dealStationExpansionDuration = "animation.deal.station.expand.duration"
    case dealStepPauseDuration = "animation.deal.step.pause.duration"
    case dealSouthRevealTotalDuration = "animation.deal.southReveal.total.duration"
    case dealSouthRevealFlipDuration = "animation.deal.southReveal.flip.duration"
    case dealSouthRevealFlipStagger = "animation.deal.southReveal.flip.stagger"
    case bidSimulatedTurnDelay = "animation.bid.simulatedTurn.delay"
    case bidValueFadeOutDuration = "animation.bid.value.fadeOut.duration"
    case bidValueFadeInDuration = "animation.bid.value.fadeIn.duration"
    case bidAreaFadeOutDuration = "animation.bid.area.fadeOut.duration"

    var seconds: Double {
        switch self {
        case .dealStackFlightDuration:
            return 0.36
        case .dealStationExpansionDuration:
            return 0.16
        case .dealStepPauseDuration:
            return 0.06
        case .dealSouthRevealTotalDuration:
            return 1.5
        case .dealSouthRevealFlipDuration:
            return 0.18
        case .dealSouthRevealFlipStagger:
            return 0.11
        case .bidSimulatedTurnDelay:
            return 1.0
        case .bidValueFadeOutDuration:
            return 0.5
        case .bidValueFadeInDuration:
            return 0.5
        case .bidAreaFadeOutDuration:
            return 1.0
        }
    }

    var nanoseconds: UInt64 {
        UInt64(seconds * 1_000_000_000)
    }
}

enum GameLayoutToken: String, CaseIterable, Equatable, Hashable {
    case undealtDeckAnchorX = "layout.undealtDeck.anchor.x"
    case undealtDeckAnchorY = "layout.undealtDeck.anchor.y"
    case undealtDeckCenterOffsetX = "layout.undealtDeck.centerOffset.x"
    case undealtDeckCenterOffsetY = "layout.undealtDeck.centerOffset.y"
    case undealtDeckStackRotation = "layout.undealtDeck.stack.rotation"
    case undealtDeckStackOffsetX = "layout.undealtDeck.stack.offset.x"
    case undealtDeckStackOffsetY = "layout.undealtDeck.stack.offset.y"
    case undealtDeckEdgeBufferMinimum = "layout.undealtDeck.edgeBuffer.min"

    var numericValue: Double {
        switch self {
        case .undealtDeckAnchorX:
            return 0.5
        case .undealtDeckAnchorY:
            return 0.5
        case .undealtDeckCenterOffsetX:
            return 0
        case .undealtDeckCenterOffsetY:
            return 0
        case .undealtDeckStackRotation:
            return 0
        case .undealtDeckStackOffsetX:
            return 0
        case .undealtDeckStackOffsetY:
            return 0
        case .undealtDeckEdgeBufferMinimum:
            return 12
        }
    }
}

enum GameBidLayoutToken: String, CaseIterable, Equatable, Hashable {
    case bidAreaPadding = "layout.bidArea.padding"
    case bidTableRowGap = "layout.bidArea.table.rowGap"
    case bidAreaCornerRadius = "layout.bidArea.cornerRadius"
    case bidSelectorHeight = "layout.bidSelector.height"
    case bidSelectorMinimumWidth = "layout.bidSelector.minimumWidth"
    case bidSuitSelectorHeight = "layout.bidSuitSelector.height"
    case bidSuitSelectorMinimumWidth = "layout.bidSuitSelector.minimumWidth"
    case bidSuitSelectorOptionMinimumWidth = "layout.bidSuitSelector.optionMinimumWidth"
    case bidSuitSelectorOptionGap = "layout.bidSuitSelector.optionGap"
    case bidButtonHeight = "layout.bidButton.height"
    case bidButtonMinimumWidth = "layout.bidButton.minimumWidth"
    case postBiddingSummaryPadding = "layout.postBiddingSummary.padding"
    case postBiddingSummaryRowGap = "layout.postBiddingSummary.rowGap"
    case postBiddingSummaryCornerRadius = "layout.postBiddingSummary.cornerRadius"

    var numericValue: Double {
        switch self {
        case .bidAreaPadding:
            return 12
        case .bidTableRowGap:
            return 6
        case .bidAreaCornerRadius:
            return 10
        case .bidSelectorHeight:
            return 36
        case .bidSelectorMinimumWidth:
            return 82
        case .bidSuitSelectorHeight:
            return 36
        case .bidSuitSelectorMinimumWidth:
            return 132
        case .bidSuitSelectorOptionMinimumWidth:
            return 36
        case .bidSuitSelectorOptionGap:
            return 4
        case .bidButtonHeight:
            return 36
        case .bidButtonMinimumWidth:
            return 56
        case .postBiddingSummaryPadding:
            return 12
        case .postBiddingSummaryRowGap:
            return 6
        case .postBiddingSummaryCornerRadius:
            return 10
        }
    }
}

enum CardSizeCategory: String, CaseIterable, Equatable, Hashable {
    case sharedBaseCard
}

struct CardSizeConfiguration: Equatable {
    let category: CardSizeCategory
    let baseCardWidth: Double
    let baseCardHeight: Double
    let cornerRadius: Double
    let rankFontPointSize: Double
    let hiddenStackOffset: Double

    static let sharedBase = CardSizeConfiguration(
        category: .sharedBaseCard,
        baseCardWidth: 36,
        baseCardHeight: 50.4,
        cornerRadius: 6,
        rankFontPointSize: 12,
        hiddenStackOffset: 2.5
    )

    var aspectRatio: Double {
        baseCardWidth / baseCardHeight
    }

    func hiddenStackWidth(for count: Int) -> Double {
        guard count > 0 else {
            return 0
        }

        return baseCardWidth + hiddenStackOffset * Double(count - 1)
    }
}

struct ButtonTokenSet: Equatable {
    let background: GameColorToken
    let pressedBackground: GameColorToken
    let text: GameColorToken

    static let deal = ButtonTokenSet(
        background: .buttonDealBackground,
        pressedBackground: .buttonDealBackgroundPressed,
        text: .buttonDealText
    )

    static let newGame = ButtonTokenSet(
        background: .buttonNewGameBackground,
        pressedBackground: .buttonNewGameBackgroundPressed,
        text: .buttonNewGameText
    )

    static let bid = ButtonTokenSet(
        background: .buttonBidBackground,
        pressedBackground: .buttonBidBackgroundPressed,
        text: .buttonBidText
    )

    var accessibilityValue: String {
        "background=\(background.rawValue);pressed=\(pressedBackground.rawValue);text=\(text.rawValue)"
    }
}

struct BidAreaTokenSet: Equatable {
    let background = GameColorToken.bidAreaBackground
    let border = GameColorToken.bidAreaBorder
    let label = GameColorToken.bidAreaLabel
    let divider = GameColorToken.bidAreaTableDivider
    let valueText = GameColorToken.bidAreaValueText
    let pendingValueText = GameColorToken.bidAreaPendingValueText
    let highestValueText = GameColorToken.bidAreaHighestValueText
    let seatText = GameColorToken.bidAreaSeatText
    let padding = GameBidLayoutToken.bidAreaPadding
    let rowGap = GameBidLayoutToken.bidTableRowGap
    let cornerRadius = GameBidLayoutToken.bidAreaCornerRadius

    var accessibilityValue: String {
        [
            "background=\(background.rawValue)",
            "border=\(border.rawValue)",
            "label=\(label.rawValue)",
            "divider=\(divider.rawValue)",
            "valueText=\(valueText.rawValue)",
            "pendingValueText=\(pendingValueText.rawValue)",
            "highestValueText=\(highestValueText.rawValue)",
            "seatText=\(seatText.rawValue)",
            "padding=\(padding.rawValue)",
            "rowGap=\(rowGap.rawValue)",
            "cornerRadius=\(cornerRadius.rawValue)"
        ].joined(separator: ";")
    }
}

struct BidSelectorTokenSet: Equatable {
    let background = GameColorToken.bidSelectorBackground
    let border = GameColorToken.bidSelectorBorder
    let text = GameColorToken.bidSelectorText
    let focusRing = GameColorToken.bidSelectorFocusRing
    let height = GameBidLayoutToken.bidSelectorHeight
    let minimumWidth = GameBidLayoutToken.bidSelectorMinimumWidth

    var accessibilityValue: String {
        [
            "background=\(background.rawValue)",
            "border=\(border.rawValue)",
            "text=\(text.rawValue)",
            "focusRing=\(focusRing.rawValue)",
            "height=\(height.rawValue)",
            "minimumWidth=\(minimumWidth.rawValue)"
        ].joined(separator: ";")
    }
}

struct BidSuitSelectorTokenSet: Equatable {
    let background = GameColorToken.bidSuitSelectorBackground
    let border = GameColorToken.bidSuitSelectorBorder
    let text = GameColorToken.bidSuitSelectorText
    let selectedBackground = GameColorToken.bidSuitSelectorSelectedBackground
    let selectedText = GameColorToken.bidSuitSelectorSelectedText
    let focusRing = GameColorToken.bidSuitSelectorFocusRing
    let disabledOpacity = GameEffectToken.bidSuitSelectorDisabledOpacity
    let height = GameBidLayoutToken.bidSuitSelectorHeight
    let minimumWidth = GameBidLayoutToken.bidSuitSelectorMinimumWidth
    let optionMinimumWidth = GameBidLayoutToken.bidSuitSelectorOptionMinimumWidth
    let optionGap = GameBidLayoutToken.bidSuitSelectorOptionGap

    var accessibilityValue: String {
        [
            "background=\(background.rawValue)",
            "border=\(border.rawValue)",
            "text=\(text.rawValue)",
            "selectedBackground=\(selectedBackground.rawValue)",
            "selectedText=\(selectedText.rawValue)",
            "focusRing=\(focusRing.rawValue)",
            "disabledOpacity=\(disabledOpacity.rawValue)",
            "height=\(height.rawValue)",
            "minimumWidth=\(minimumWidth.rawValue)",
            "optionMinimumWidth=\(optionMinimumWidth.rawValue)",
            "optionGap=\(optionGap.rawValue)"
        ].joined(separator: ";")
    }
}

struct PostBiddingSummaryTokenSet: Equatable {
    let background = GameColorToken.postBiddingSummaryBackground
    let border = GameColorToken.postBiddingSummaryBorder
    let labelText = GameColorToken.postBiddingSummaryLabelText
    let teamText = GameColorToken.postBiddingSummaryTeamText
    let bidText = GameColorToken.postBiddingSummaryBidText
    let tarneebText = GameColorToken.postBiddingSummaryTarneebText
    let padding = GameBidLayoutToken.postBiddingSummaryPadding
    let rowGap = GameBidLayoutToken.postBiddingSummaryRowGap
    let cornerRadius = GameBidLayoutToken.postBiddingSummaryCornerRadius

    var accessibilityValue: String {
        [
            "background=\(background.rawValue)",
            "border=\(border.rawValue)",
            "labelText=\(labelText.rawValue)",
            "teamText=\(teamText.rawValue)",
            "bidText=\(bidText.rawValue)",
            "tarneebText=\(tarneebText.rawValue)",
            "padding=\(padding.rawValue)",
            "rowGap=\(rowGap.rawValue)",
            "cornerRadius=\(cornerRadius.rawValue)"
        ].joined(separator: ";")
    }
}

struct BidEntryPresentation: Equatable, Identifiable {
    let seat: Seat
    let bidState: BidState
    let isSelectable: Bool
    let isCurrentHighestBid: Bool
    let southDraftBid: BidValue
    let southDraftTarneebSuit: Suit?
    let allowedValues: [BidValue]

    var id: Seat {
        seat
    }

    var seatLabel: String {
        seat.displayLabel
    }

    var valueLabel: String {
        bidState.displayLabel
    }

    var historyValueLabel: String {
        bidState.displayLabel
    }

    var historyValueColorToken: GameColorToken {
        bidState == .pending ? .bidAreaPendingValueText : valueColorToken
    }

    var valueColorToken: GameColorToken {
        if bidState == .pending {
            return .bidAreaPendingValueText
        }

        if isCurrentHighestBid {
            return .bidAreaHighestValueText
        }

        return .bidAreaValueText
    }

    var accessibilityValue: String {
        [
            "seat=\(seat.rawValue)",
            "value=\(valueLabel)",
            "state=\(stateLabel)",
            "selectable=\(isSelectable)",
            "currentHighest=\(isCurrentHighestBid)",
            "allowed=\(allowedValuesLabel)",
            "draftBid=\(southDraftBid.displayLabel)",
            "draftTarneebSuit=\(southDraftTarneebSuit?.rawValue ?? "none")",
            "valueText=\(valueColorToken.rawValue)"
        ].joined(separator: ";")
    }

    private var stateLabel: String {
        switch bidState {
        case .pending:
            return "pending"
        case .resolved:
            return "resolved"
        }
    }

    private var allowedValuesLabel: String {
        allowedValues.map(\.displayLabel).joined(separator: ",")
    }
}

struct BidAreaPresentation: Equatable {
    enum PresentationState: String, Equatable {
        case visible
        case fadingOut
    }

    let label = "Bidding"
    let presentationState: PresentationState
    let entries: [BidEntryPresentation]
    let status: BiddingRoundStatus
    let completionOutcome: BiddingCompletionOutcome?
    let currentTurnSeat: Seat?
    let highestBidSeat: Seat?
    let highestBidValue: BidValue?
    let allowedValues: [BidValue]
    let southSuitOptions: [Suit]
    let southDraftBid: BidValue
    let southDraftTarneebSuit: Suit?
    let southSuitSelectorVisible: Bool
    let southSuitSelectorEnabled: Bool
    let southBidButtonVisible: Bool
    let southBidButtonEnabled: Bool
    let areaTokens = BidAreaTokenSet()
    let selectorTokens = BidSelectorTokenSet()
    let suitSelectorTokens = BidSuitSelectorTokenSet()
    let bidButtonTokens = ButtonTokenSet.bid
    let bidButtonHeightToken = GameBidLayoutToken.bidButtonHeight
    let bidButtonMinimumWidthToken = GameBidLayoutToken.bidButtonMinimumWidth
    let simulatedTurnDelayToken = GameAnimationToken.bidSimulatedTurnDelay
    let fadeOutToken = GameAnimationToken.bidValueFadeOutDuration
    let fadeInToken = GameAnimationToken.bidValueFadeInDuration
    let areaFadeOutToken = GameAnimationToken.bidAreaFadeOutDuration

    init?(
        phase: GamePhase,
        biddingState: BiddingState?,
        southDraftBid: BidValue = .pass,
        southDraftTarneebSuit: Suit? = nil,
        presentationState: PresentationState = .visible
    ) {
        guard phase == .dealt else {
            return nil
        }

        guard let biddingState,
              Set(biddingState.bids.keys) == Set(Seat.allCases) else {
            return nil
        }

        let legalSouthValues = biddingState.southLegalValues
        let normalizedSouthDraftBid = legalSouthValues.contains(southDraftBid) ? southDraftBid : .pass
        let normalizedSouthDraftSuit: Suit? = nil

        self.presentationState = presentationState
        self.status = biddingState.status
        self.completionOutcome = biddingState.completionOutcome
        self.currentTurnSeat = biddingState.currentTurnSeat
        self.highestBidSeat = biddingState.highestBidSeat
        self.highestBidValue = biddingState.highestBidValue
        self.allowedValues = legalSouthValues
        self.southSuitOptions = Suit.allCases
        self.southDraftBid = normalizedSouthDraftBid
        self.southDraftTarneebSuit = normalizedSouthDraftSuit
        self.southSuitSelectorVisible = false
        self.southSuitSelectorEnabled = false
        self.southBidButtonVisible = biddingState.status == .inProgress
        self.southBidButtonEnabled = biddingState.isWaitingForSouth
        self.entries = Seat.dealOrder.map { seat in
            BidEntryPresentation(
                seat: seat,
                bidState: biddingState.bids[seat] ?? .pending,
                isSelectable: seat == .south && biddingState.isWaitingForSouth,
                isCurrentHighestBid: seat == biddingState.highestBidSeat
                    && (biddingState.bids[seat] ?? .pending).resolvedValue == biddingState.highestBidValue,
                southDraftBid: normalizedSouthDraftBid,
                southDraftTarneebSuit: normalizedSouthDraftSuit,
                allowedValues: legalSouthValues
            )
        }
    }

    var allowedValuesLabel: String {
        allowedValues.map(\.displayLabel).joined(separator: ",")
    }

    var southSuitOptionsLabel: String {
        southSuitOptions.map(\.rawValue).joined(separator: ",")
    }

    var accessibilityValue: String {
        [
            "label=\(label)",
            "visible=true",
            "presentationState=\(presentationState.rawValue)",
            "rows=\(entries.map(\.seat.rawValue).joined(separator: ","))",
            "values=\(entries.map { "\($0.seat.rawValue):\($0.valueLabel)" }.joined(separator: ","))",
            "valueTextRoles=\(entries.map { "\($0.seat.rawValue):\($0.valueColorToken.rawValue)" }.joined(separator: ","))",
            "allowed=\(allowedValuesLabel)",
            "southDraftBid=\(southDraftBid.displayLabel)",
            "southSuitOptions=\(southSuitOptionsLabel)",
            "southDraftTarneebSuit=\(southDraftTarneebSuit?.rawValue ?? "none")",
            "status=\(status.rawValue)",
            "completionOutcome=\(completionOutcome?.rawValue ?? "none")",
            "currentTurn=\(currentTurnSeat?.rawValue ?? "none")",
            "highestSeat=\(highestBidSeat?.rawValue ?? "none")",
            "highestBid=\(highestBidValue?.displayLabel ?? "none")",
            "southSelectable=\(southBidButtonEnabled)",
            "southTarneebSuitSelectorVisible=\(southSuitSelectorVisible)",
            "southTarneebSuitSelectorEnabled=\(southSuitSelectorEnabled)",
            "southBidButtonVisible=\(southBidButtonVisible)",
            "southBidButtonEnabled=\(southBidButtonEnabled)",
            "areaTokens=\(areaTokens.accessibilityValue)",
            "selectorTokens=\(selectorTokens.accessibilityValue)",
            "suitSelectorTokens=\(suitSelectorTokens.accessibilityValue)",
            "bidButtonTokens=\(bidButtonTokens.accessibilityValue)",
            "bidButtonHeight=\(bidButtonHeightToken.rawValue)",
            "bidButtonMinimumWidth=\(bidButtonMinimumWidthToken.rawValue)",
            "simulatedBidDelay=\(simulatedTurnDelayToken.rawValue)",
            "simulatedBidDelaySeconds=\(simulatedTurnDelayToken.seconds)",
            "fadeOut=\(fadeOutToken.rawValue)",
            "fadeIn=\(fadeInToken.rawValue)",
            "fadeTotalSeconds=\(fadeOutToken.seconds + fadeInToken.seconds)",
            "areaFadeOut=\(areaFadeOutToken.rawValue)",
            "areaFadeOutSeconds=\(areaFadeOutToken.seconds)"
        ].joined(separator: ";")
    }
}

struct PostBiddingSummaryPresentation: Equatable {
    let teamLabel: String
    let bidValueLabel: String
    let tarneebLabel = "Tarneeb"
    let tarneebSymbol: String
    let tarneebSymbolColorToken: GameColorToken
    let tarneebSymbolBackgroundColorToken = GameColorToken.cardBackground
    let tarneebSymbolBorderColorToken = GameColorToken.buttonNewGameBackground
    let tokens = PostBiddingSummaryTokenSet()

    init?(
        phase: GamePhase,
        biddingStatus: BiddingRoundStatus?,
        summary: PostBiddingSummary?,
        isBiddingAreaFadingOut: Bool
    ) {
        guard phase == .dealt,
              biddingStatus == .complete,
              !isBiddingAreaFadingOut,
              let summary else {
            return nil
        }

        self.teamLabel = summary.teamLabel
        self.bidValueLabel = summary.bidValue.displayLabel
        self.tarneebSymbol = summary.tarneebSymbol
        self.tarneebSymbolColorToken = summary.tarneebSuit.colorToken
    }

    var accessibilityValue: String {
        [
            "visible=true",
            "team=\(teamLabel)",
            "bid=\(bidValueLabel)",
            "tarneebLabel=\(tarneebLabel)",
            "tarneebSymbol=\(tarneebSymbol)",
            "tarneebSymbolColor=\(tarneebSymbolColorToken.rawValue)",
            "tarneebSymbolBackground=\(tarneebSymbolBackgroundColorToken.rawValue)",
            "tarneebSymbolBorder=\(tarneebSymbolBorderColorToken.rawValue)",
            "tokens=\(tokens.accessibilityValue)"
        ].joined(separator: ";")
    }
}

struct SouthTarneebSelectionPresentation: Equatable {
    let teamLabel: String
    let bidValueLabel: String
    let tarneebLabel = "Tarneeb"
    let selectedSuit: Suit?
    let suitOptions = Suit.allCases
    let tokens = PostBiddingSummaryTokenSet()
    let suitSelectorTokens = BidSuitSelectorTokenSet()
    let bidButtonTokens = ButtonTokenSet.bid
    let bidButtonHeightToken = GameBidLayoutToken.bidButtonHeight
    let bidButtonMinimumWidthToken = GameBidLayoutToken.bidButtonMinimumWidth

    init?(
        phase: GamePhase,
        biddingStatus: BiddingRoundStatus?,
        highestBidSeat: Seat?,
        highestBidValue: BidValue?,
        summary: PostBiddingSummary?,
        isBiddingAreaFadingOut: Bool,
        selectedSuit: Suit?
    ) {
        guard phase == .dealt,
              biddingStatus == .complete,
              !isBiddingAreaFadingOut,
              highestBidSeat == .south,
              let highestBidValue,
              highestBidValue.numericValue != nil,
              summary == nil else {
            return nil
        }

        self.teamLabel = Seat.south.highBiddingTeamLabel
        self.bidValueLabel = highestBidValue.displayLabel
        self.selectedSuit = selectedSuit
    }

    var submitEnabled: Bool {
        selectedSuit != nil
    }

    var suitOptionsLabel: String {
        suitOptions.map(\.rawValue).joined(separator: ",")
    }

    var accessibilityValue: String {
        [
            "visible=true",
            "team=\(teamLabel)",
            "bid=\(bidValueLabel)",
            "tarneebLabel=\(tarneebLabel)",
            "selected=\(selectedSuit?.rawValue ?? "none")",
            "options=\(suitOptionsLabel)",
            "submitEnabled=\(submitEnabled)",
            "tokens=\(tokens.accessibilityValue)",
            "suitSelectorTokens=\(suitSelectorTokens.accessibilityValue)",
            "bidButtonTokens=\(bidButtonTokens.accessibilityValue)",
            "bidButtonHeight=\(bidButtonHeightToken.rawValue)",
            "bidButtonMinimumWidth=\(bidButtonMinimumWidthToken.rawValue)"
        ].joined(separator: ";")
    }
}

struct TableTitlePresentation: Equatable {
    let text = "طرنيب"
    let fontToken = GameTypographyToken.tableTitleFont
    let fontSizeToken = GameTypographyToken.tableTitleFontSize
    let trackingMinimumToken = GameTypographyToken.tableTitleTrackingMinimum
    let trackingMaximumToken = GameTypographyToken.tableTitleTrackingMaximum
    let tracking: Double
    let textColorRole = GameColorRole.tableTitleText
    let textOpacityToken = GameEffectToken.tableTitleTextOpacity
    let shadowColorRole = GameColorRole.tableTitleShadow
    let shadowOpacityToken = GameEffectToken.tableTitleShadowOpacity
    let shadowBlurRadiusToken = GameEffectToken.tableTitleShadowBlurRadius
    let usesShadow: Bool

    init(
        tracking: Double = GameTypographyToken.tableTitleTrackingMinimum.numericValue ?? 2,
        usesShadow: Bool = true
    ) {
        let minimumTracking = GameTypographyToken.tableTitleTrackingMinimum.numericValue ?? tracking
        let maximumTracking = GameTypographyToken.tableTitleTrackingMaximum.numericValue ?? tracking
        self.tracking = min(max(tracking, minimumTracking), maximumTracking)
        self.usesShadow = usesShadow
    }

    var fontPointSize: Double {
        fontSizeToken.numericValue ?? 26
    }

    var fontName: String {
        fontToken.stringValue
    }

    var accessibilityValue: String {
        [
            "font=\(fontToken.rawValue)",
            "fontName=\(fontToken.stringValue)",
            "fontSize=\(fontSizeToken.rawValue)",
            "pointSize=\(fontPointSize)",
            "tracking=\(tracking)",
            "trackingMin=\(trackingMinimumToken.rawValue)",
            "trackingMax=\(trackingMaximumToken.rawValue)",
            "textColor=\(textColorRole.token.rawValue)",
            "textOpacity=\(textOpacityToken.rawValue)",
            "textOpacityValue=\(textOpacityToken.value)",
            "shadowColor=\(shadowColorRole.token.rawValue)",
            "usesShadow=\(usesShadow)",
            "shadowOpacity=\(shadowOpacityToken.rawValue)",
            "shadowOpacityValue=\(shadowOpacityToken.value)",
            "shadowBlur=\(shadowBlurRadiusToken.rawValue)"
        ].joined(separator: ";")
    }
}

struct CardPresentation: Equatable {
    let cardID: String
    let displayLabel: String
    let faceAssetName: String
    let rankText: String
    let suitSymbol: String
    let suitColorRole: GameColorRole
    let suitColorToken: GameColorToken
    let sortKey: Int
    let accessibilityLabel: String
    let sizeConfiguration: CardSizeConfiguration

    init(card: Card, sizeConfiguration: CardSizeConfiguration = .sharedBase) {
        self.cardID = card.id
        self.rankText = card.rank.displayLabel
        self.suitSymbol = card.suit.displaySymbol
        self.displayLabel = "\(card.rank.displayLabel)\(card.suit.displaySymbol)"
        self.faceAssetName = "card_face_\(card.rank.cardFaceAssetCode)\(card.suit.cardFaceAssetCode)"
        self.suitColorRole = card.suit.colorRole
        self.suitColorToken = card.suit.colorToken
        self.sortKey = card.southHandSortKey
        self.accessibilityLabel = displayLabel
        self.sizeConfiguration = sizeConfiguration
    }

    var sizeCategory: CardSizeCategory {
        sizeConfiguration.category
    }

    var accessibilityValue: String {
        "asset=\(faceAssetName);role=\(suitColorRole.rawValue);token=\(suitColorToken.rawValue);size=\(sizeCategory.rawValue);surface=\(GameColorRole.cardFace.token.rawValue);border=\(GameColorRole.cardBorder.token.rawValue);shadow=\(GameColorRole.cardShadow.token.rawValue)"
    }
}

struct HiddenCardBackPresentation: Equatable, Identifiable {
    let index: Int
    let sizeConfiguration: CardSizeConfiguration

    var id: String {
        "hidden-card-back-\(index)"
    }

    var assetName: String {
        "card_back"
    }

    var accessibilityLabel: String {
        "Card back"
    }

    var accessibilityValue: String {
        sizeConfiguration.category.rawValue
    }
}

struct HiddenHandPresentation: Equatable {
    let seat: Seat
    let hiddenCards: [HiddenCardBackPresentation]
    let sizeConfiguration: CardSizeConfiguration

    init(
        seat: Seat,
        hiddenCardCount: Int,
        sizeConfiguration: CardSizeConfiguration = .sharedBase
    ) {
        self.seat = seat
        self.hiddenCards = (0..<hiddenCardCount).map { index in
            HiddenCardBackPresentation(index: index, sizeConfiguration: sizeConfiguration)
        }
        self.sizeConfiguration = sizeConfiguration
    }

    var hiddenCardCount: Int {
        hiddenCards.count
    }

    var stackOffset: Double {
        sizeConfiguration.hiddenStackOffset
    }

    var stackWidth: Double {
        sizeConfiguration.hiddenStackWidth(for: hiddenCardCount)
    }
}

struct DealAnimationPresentation: Equatable {
    static let cardsPerStack = 13
    static let totalCards = 52

    let dealerSeat: Seat
    let sizeConfiguration: CardSizeConfiguration

    init(
        dealerSeat: Seat,
        sizeConfiguration: CardSizeConfiguration = .sharedBase
    ) {
        self.dealerSeat = dealerSeat
        self.sizeConfiguration = sizeConfiguration
    }

    var targetOrder: [Seat] {
        var order: [Seat] = []
        var seat = dealerSeat.nextCounterclockwiseDealer

        while order.count < Seat.dealerRotationOrder.count {
            order.append(seat)
            seat = seat.nextCounterclockwiseDealer
        }

        return order
    }

    var targetOrderAccessibilityValue: String {
        targetOrder.map(\.rawValue).joined(separator: ",")
    }

    func targetSeat(forStep stepIndex: Int) -> Seat? {
        guard targetOrder.indices.contains(stepIndex) else {
            return nil
        }

        return targetOrder[stepIndex]
    }

    func deliveredSeats(afterCompletedSteps completedStepCount: Int) -> [Seat] {
        Array(targetOrder.prefix(max(0, min(completedStepCount, targetOrder.count))))
    }

    func centralCardCount(deliveredSeatCount: Int, movingStackVisible: Bool) -> Int {
        let reservedMovingCards = movingStackVisible ? Self.cardsPerStack : 0
        let deliveredCards = max(0, deliveredSeatCount) * Self.cardsPerStack
        return max(0, Self.totalCards - deliveredCards - reservedMovingCards)
    }

    func movingStackPresentation(forStep stepIndex: Int) -> DealAnimationStackPresentation? {
        guard let targetSeat = targetSeat(forStep: stepIndex) else {
            return nil
        }

        return DealAnimationStackPresentation(
            targetSeat: targetSeat,
            targetOrder: targetOrder,
            sizeConfiguration: sizeConfiguration
        )
    }

    var accessibilityValue: String {
        [
            "dealerSeat=\(dealerSeat.rawValue)",
            "start=dealerRight",
            "direction=counterclockwise",
            "cardsPerStack=\(Self.cardsPerStack)",
            "totalCards=\(Self.totalCards)",
            "targetOrder=\(targetOrderAccessibilityValue)",
            "flightDuration=\(GameAnimationToken.dealStackFlightDuration.rawValue)",
            "stationExpansionDuration=\(GameAnimationToken.dealStationExpansionDuration.rawValue)",
            "stepPauseDuration=\(GameAnimationToken.dealStepPauseDuration.rawValue)",
            "southRevealTotalDuration=\(GameAnimationToken.dealSouthRevealTotalDuration.rawValue)",
            "southRevealFlipDuration=\(GameAnimationToken.dealSouthRevealFlipDuration.rawValue)",
            "southRevealFlipStagger=\(GameAnimationToken.dealSouthRevealFlipStagger.rawValue)"
        ].joined(separator: ";")
    }
}

struct DealAnimationOffset: Equatable {
    let x: Double
    let y: Double
}

struct DealAnimationPathPresentation: Equatable {
    let tableDiameter: Double
    let compactStationSide: Double
    let southStationHeight: Double
    let horizontalSpacing: Double
    let verticalSpacing: Double

    var deckCenterOffsetFromSceneCenter: DealAnimationOffset {
        let middleRowHeight = max(tableDiameter, compactStationSide)
        let sceneHeight = compactStationSide + verticalSpacing + middleRowHeight + verticalSpacing + southStationHeight
        let deckCenterY = compactStationSide + verticalSpacing + middleRowHeight / 2

        return DealAnimationOffset(x: 0, y: deckCenterY - sceneHeight / 2)
    }

    func offset(to seat: Seat, stackAtTarget: Bool) -> DealAnimationOffset {
        let origin = deckCenterOffsetFromSceneCenter

        guard stackAtTarget else {
            return origin
        }

        let targetOffset = stationOffsetFromDeckCenter(to: seat)

        return DealAnimationOffset(
            x: origin.x + targetOffset.x,
            y: origin.y + targetOffset.y
        )
    }

    private func stationOffsetFromDeckCenter(to seat: Seat) -> DealAnimationOffset {
        let horizontalOffset = tableDiameter / 2 + horizontalSpacing + compactStationSide / 2
        let verticalOffset = tableDiameter / 2 + verticalSpacing + compactStationSide / 2

        switch seat {
        case .north:
            return DealAnimationOffset(x: 0, y: -verticalOffset)
        case .west:
            return DealAnimationOffset(x: -horizontalOffset, y: 0)
        case .south:
            return DealAnimationOffset(x: 0, y: verticalOffset)
        case .east:
            return DealAnimationOffset(x: horizontalOffset, y: 0)
        }
    }
}

struct DealAnimationStackPresentation: Equatable {
    let targetSeat: Seat
    let targetOrder: [Seat]
    let hiddenCards: [HiddenCardBackPresentation]
    let sizeConfiguration: CardSizeConfiguration

    init(
        targetSeat: Seat,
        targetOrder: [Seat],
        sizeConfiguration: CardSizeConfiguration = .sharedBase
    ) {
        self.targetSeat = targetSeat
        self.targetOrder = targetOrder
        self.sizeConfiguration = sizeConfiguration
        self.hiddenCards = (0..<DealAnimationPresentation.cardsPerStack).map { index in
            HiddenCardBackPresentation(index: index, sizeConfiguration: sizeConfiguration)
        }
    }

    var hiddenCardCount: Int {
        hiddenCards.count
    }

    var stackWidth: Double {
        sizeConfiguration.baseCardWidth
    }

    var stackHeight: Double {
        sizeConfiguration.baseCardHeight
    }

    var accessibilityValue: String {
        [
            "count=\(hiddenCardCount)",
            "asset=card_back",
            "hidden=true",
            "from=center",
            "origin=centerDeck",
            "destination=playerStation",
            "renderLayer=tableSceneOverlay",
            "target=\(targetSeat.rawValue)",
            "start=dealerRight",
            "direction=counterclockwise",
            "targetOrder=\(targetOrder.map(\.rawValue).joined(separator: ","))",
            "size=\(sizeConfiguration.category.rawValue)"
        ].joined(separator: ";")
    }
}

struct UndealtDeckStackPresentation: Equatable {
    let hiddenCards: [HiddenCardBackPresentation]
    let sizeConfiguration: CardSizeConfiguration
    let isVisible: Bool
    let layout: CenteredDeckLayoutPresentation

    init(
        phase: GamePhase,
        hiddenCardCount: Int = 52,
        sizeConfiguration: CardSizeConfiguration = .sharedBase
    ) {
        self.isVisible = phase == .notStarted
        self.sizeConfiguration = sizeConfiguration
        self.layout = CenteredDeckLayoutPresentation(sizeConfiguration: sizeConfiguration)
        self.hiddenCards = isVisible
            ? (0..<hiddenCardCount).map { index in
                HiddenCardBackPresentation(index: index, sizeConfiguration: sizeConfiguration)
            }
            : []
    }

    var hiddenCardCount: Int {
        hiddenCards.count
    }

    var stackWidth: Double {
        guard hiddenCardCount > 0 else {
            return 0
        }

        return sizeConfiguration.baseCardWidth + abs(layout.stackOffsetX) * Double(hiddenCardCount - 1)
    }

    var stackHeight: Double {
        guard hiddenCardCount > 0 else {
            return 0
        }

        return sizeConfiguration.baseCardHeight + abs(layout.stackOffsetY) * Double(hiddenCardCount - 1)
    }

    var accessibilityValue: String {
        [
            "count=\(hiddenCardCount)",
            "asset=card_back",
            "hidden=true",
            "layout=squaredStack",
            "placement=\(layout.placementLabel)",
            "anchor=\(layout.anchorLabel)",
            "anchorX=\(layout.anchorXToken.rawValue)",
            "anchorXValue=\(layout.anchorX)",
            "anchorY=\(layout.anchorYToken.rawValue)",
            "anchorYValue=\(layout.anchorY)",
            "centerOffsetX=\(layout.centerOffsetXToken.rawValue)",
            "centerOffsetXValue=\(layout.centerOffsetX)",
            "centerOffsetY=\(layout.centerOffsetYToken.rawValue)",
            "centerOffsetYValue=\(layout.centerOffsetY)",
            "stackRotation=\(layout.stackRotationToken.rawValue)",
            "stackRotationValue=\(layout.stackRotation)",
            "stackOffsetX=\(layout.stackOffsetXToken.rawValue)",
            "stackOffsetXValue=\(layout.stackOffsetX)",
            "stackOffsetY=\(layout.stackOffsetYToken.rawValue)",
            "stackOffsetYValue=\(layout.stackOffsetY)",
            "edgeBuffer=\(layout.edgeBufferToken.rawValue)",
            "edgeBufferValue=\(layout.edgeBuffer)",
            "titleOverlapAllowed=\(layout.titleOverlapAllowed)",
            "size=\(sizeConfiguration.category.rawValue)"
        ].joined(separator: ";")
    }

    func visualTransform(for hiddenCard: HiddenCardBackPresentation) -> UndealtDeckCardTransform {
        layout.visualTransform(forCardAt: hiddenCard.index, cardCount: hiddenCardCount)
    }
}

struct CenteredDeckLayoutPresentation: Equatable {
    let sizeConfiguration: CardSizeConfiguration

    let anchorXToken = GameLayoutToken.undealtDeckAnchorX
    let anchorYToken = GameLayoutToken.undealtDeckAnchorY
    let centerOffsetXToken = GameLayoutToken.undealtDeckCenterOffsetX
    let centerOffsetYToken = GameLayoutToken.undealtDeckCenterOffsetY
    let stackRotationToken = GameLayoutToken.undealtDeckStackRotation
    let stackOffsetXToken = GameLayoutToken.undealtDeckStackOffsetX
    let stackOffsetYToken = GameLayoutToken.undealtDeckStackOffsetY
    let edgeBufferToken = GameLayoutToken.undealtDeckEdgeBufferMinimum

    var anchorX: Double {
        anchorXToken.numericValue
    }

    var anchorY: Double {
        anchorYToken.numericValue
    }

    var centerOffsetX: Double {
        centerOffsetXToken.numericValue
    }

    var centerOffsetY: Double {
        centerOffsetYToken.numericValue
    }

    var stackRotation: Double {
        stackRotationToken.numericValue
    }

    var stackOffsetX: Double {
        stackOffsetXToken.numericValue
    }

    var stackOffsetY: Double {
        stackOffsetYToken.numericValue
    }

    var edgeBuffer: Double {
        edgeBufferToken.numericValue
    }

    var titleOverlapAllowed: Bool {
        true
    }

    var placementLabel: String {
        "veryCenter"
    }

    var anchorLabel: String {
        "center"
    }

    func offset(forTableDiameter _: Double) -> (x: Double, y: Double) {
        (x: centerOffsetX, y: centerOffsetY)
    }

    func visualTransform(forCardAt index: Int, cardCount _: Int) -> UndealtDeckCardTransform {
        return UndealtDeckCardTransform(
            offsetX: stackOffsetX * Double(index),
            offsetY: stackOffsetY * Double(index),
            rotationDegrees: stackRotation
        )
    }
}

struct UndealtDeckCardTransform: Equatable {
    let offsetX: Double
    let offsetY: Double
    let rotationDegrees: Double
}

struct DealerStationPresentation: Equatable {
    let seat: Seat
    let phase: GamePhase
    let dealerSeat: Seat

    var showsDealerBadge: Bool {
        seat == dealerSeat
    }

    var outlineColorRole: GameColorRole {
        .stationOutline
    }

    var outlineToken: GameColorToken {
        outlineColorRole.token
    }

    var badgeBackgroundRole: GameColorRole {
        .dealerBadgeBackground
    }

    var badgeBackgroundToken: GameColorToken {
        badgeBackgroundRole.token
    }

    var badgeTextRole: GameColorRole {
        .dealerBadgeText
    }

    var badgeTextToken: GameColorToken {
        badgeTextRole.token
    }

    var accessibilityValue: String {
        [
            "dealerSeat=\(dealerSeat.rawValue)",
            "dealerBadgeVisible=\(showsDealerBadge)",
            "badgeShape=circle",
            "badgePlacement=upper-left",
            "badgeText=D",
            "badgeBackground=\(badgeBackgroundToken.rawValue)",
            "badgeTextColor=\(badgeTextToken.rawValue)",
            "outline=\(outlineToken.rawValue)",
            "defaultOutline=\(GameColorRole.stationOutline.token.rawValue)"
        ].joined(separator: ";")
    }
}

enum StationPlacement: String, Equatable {
    case aboveTable
    case leftOfTable
    case belowTable
    case rightOfTable
}

struct TableLayoutPresentation: Equatable {
    let screenWidth: Double

    var tableDiameter: Double {
        screenWidth * 0.5
    }

    func stationPlacement(for seat: Seat) -> StationPlacement {
        switch seat {
        case .north:
            return .aboveTable
        case .west:
            return .leftOfTable
        case .south:
            return .belowTable
        case .east:
            return .rightOfTable
        }
    }

    func undealtDeckLayout() -> CenteredDeckLayoutPresentation {
        CenteredDeckLayoutPresentation(sizeConfiguration: .sharedBase)
    }
}

enum SouthHandPresentation {
    static func sortedCards(from cards: [Card]) -> [Card] {
        cards.sorted { lhs, rhs in
            if lhs.suit.southDisplayOrder != rhs.suit.southDisplayOrder {
                return lhs.suit.southDisplayOrder < rhs.suit.southDisplayOrder
            }

            return lhs.rank.displayOrder < rhs.rank.displayOrder
        }
    }

    static func cardPresentations(
        from cards: [Card],
        sizeConfiguration: CardSizeConfiguration = .sharedBase
    ) -> [CardPresentation] {
        sortedCards(from: cards).map { card in
            CardPresentation(card: card, sizeConfiguration: sizeConfiguration)
        }
    }
}

extension Suit {
    var colorRole: GameColorRole {
        switch self {
        case .hearts, .diamonds:
            return .suitWarm
        case .clubs, .spades:
            return .suitNeutral
        }
    }

    var colorToken: GameColorToken {
        colorRole.token
    }

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

    var cardFaceAssetCode: String {
        switch self {
        case .clubs:
            return "C"
        case .diamonds:
            return "D"
        case .hearts:
            return "H"
        case .spades:
            return "S"
        }
    }
}

extension Rank {
    var displayOrder: Int {
        Rank.allCases.firstIndex(of: self) ?? 0
    }

    var cardFaceAssetCode: String {
        switch self {
        case .ten:
            return "T"
        default:
            return rawValue
        }
    }
}

private extension Card {
    var southHandSortKey: Int {
        suit.southDisplayOrder * 100 + rank.displayOrder
    }
}
