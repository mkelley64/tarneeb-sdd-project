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
    case trickPlaySlotBackground = "color.trickPlay.slot.background"
    case trickPlaySlotBorder = "color.trickPlay.slot.border"
    case trickPlayActiveSeatOutline = "color.trickPlay.activeSeat.outline"
    case trickPlayLegalCardOutline = "color.trickPlay.legalCard.outline"
    case trickPlayWinnerHighlightBorder = "color.trickPlay.winnerHighlight.border"
    case trickPlayCountBackground = "color.trickPlay.count.background"
    case trickPlayCountText = "color.trickPlay.count.text"
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
    case tableTitleHighlight = "effect.tableTitle.highlight.color"
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
            return "#FFB300"
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
        case .trickPlaySlotBackground:
            return "#123A2A"
        case .trickPlaySlotBorder:
            return "#E8DFC866"
        case .trickPlayActiveSeatOutline:
            return "#FFB300"
        case .trickPlayLegalCardOutline:
            return "#FFB300"
        case .trickPlayWinnerHighlightBorder:
            return "#FFD166"
        case .trickPlayCountBackground:
            return "#123A2A"
        case .trickPlayCountText:
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
            return "#BBAA7E"
        case .tableTitleShadow:
            return "#000000"
        case .tableTitleHighlight:
            return "#F2E8CE"
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
    case trickPlaySlotBackground
    case trickPlaySlotBorder
    case trickPlayActiveSeatOutline
    case trickPlayLegalCardOutline
    case trickPlayWinnerHighlightBorder
    case trickPlayCountBackground
    case trickPlayCountText
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
    case tableTitleHighlight
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
        case .trickPlaySlotBackground:
            return .trickPlaySlotBackground
        case .trickPlaySlotBorder:
            return .trickPlaySlotBorder
        case .trickPlayActiveSeatOutline:
            return .trickPlayActiveSeatOutline
        case .trickPlayLegalCardOutline:
            return .trickPlayLegalCardOutline
        case .trickPlayWinnerHighlightBorder:
            return .trickPlayWinnerHighlightBorder
        case .trickPlayCountBackground:
            return .trickPlayCountBackground
        case .trickPlayCountText:
            return .trickPlayCountText
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
        case .tableTitleHighlight:
            return .tableTitleHighlight
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
    case tableTitleShadowOffsetY = "effect.tableTitle.shadow.offset.y"
    case tableTitleHighlightOpacity = "effect.tableTitle.highlight.opacity"
    case tableTitleHighlightBlurRadius = "effect.tableTitle.highlight.blurRadius"
    case tableTitleHighlightOffsetY = "effect.tableTitle.highlight.offset.y"
    case bidButtonDisabledOpacity = "effect.bidButton.disabled.opacity"
    case bidSuitSelectorDisabledOpacity = "effect.bidSuitSelector.disabled.opacity"
    case tableCenterSurfaceOpacity = "effect.table.centerSurface.opacity"
    case tableInnerRingOpacity = "effect.table.innerRing.opacity"
    case tableRailHighlightOpacity = "effect.table.rail.highlight.opacity"
    case tableRailInnerBevelOpacity = "effect.table.rail.innerBevel.opacity"
    case tableRailShadowOpacity = "effect.table.rail.shadow.opacity"
    case tableRailShadowRadius = "effect.table.rail.shadow.radius"
    case tablePlayAreaShadowOpacity = "effect.table.playArea.shadow.opacity"
    case trickPlaySlotBackgroundOpacity = "effect.trickPlay.slot.background.opacity"
    case trickPlaySlotBorderOpacity = "effect.trickPlay.slot.border.opacity"
    case trickPlayPlayedCardShadowOpacity = "effect.trickPlay.playedCard.shadow.opacity"
    case trickPlayLegalCardOutlineOpacity = "effect.trickPlay.legalCard.outline.opacity"
    case trickPlayUnavailableSouthCardOpacity = "effect.trickPlay.southCard.unavailable.opacity"
    case trickPlayWinnerHighlightOpacity = "effect.trickPlay.winnerHighlight.opacity"
    case trickPlayCountBackgroundOpacity = "effect.trickPlay.count.background.opacity"
    case southHandRailBackgroundOpacity = "effect.southHand.rail.background.opacity"
    case southHandRailStrokeOpacity = "effect.southHand.rail.stroke.opacity"
    case stationBackgroundDefaultOpacity = "effect.station.background.default.opacity"
    case stationBackgroundActiveOpacity = "effect.station.background.active.opacity"
    case bidStationCueBackgroundOpacity = "effect.bid.stationCue.background.opacity"
    case bidStationCueScale = "effect.bid.stationCue.scale"
    case bidStationCueShadowOpacity = "effect.bid.stationCue.shadow.opacity"
    case bidStationCueShadowRadius = "effect.bid.stationCue.shadow.radius"
    case bidTurnPillBackgroundOpacity = "effect.bidArea.turnPill.background.opacity"
    case bidCellDefaultBackgroundOpacity = "effect.bidArea.cell.default.background.opacity"
    case bidCellActiveBackgroundOpacity = "effect.bidArea.cell.active.background.opacity"
    case bidCellHighestBackgroundOpacity = "effect.bidArea.cell.highest.background.opacity"
    case bidActionTrayBackgroundOpacity = "effect.bidArea.actionTray.background.opacity"
    case phaseStatusBackgroundOpacity = "effect.phaseStatus.background.opacity"
    case statusPillBorderOpacity = "effect.statusPill.border.opacity"
    case bottomControlSeparatorOpacity = "effect.bottomControl.separator.opacity"

    var value: Double {
        switch self {
        case .tableTitleTextOpacity:
            return 0.72
        case .tableTitleShadowOpacity:
            return 0.38
        case .tableTitleShadowBlurRadius:
            return 1.2
        case .tableTitleShadowOffsetY:
            return 1
        case .tableTitleHighlightOpacity:
            return 0.18
        case .tableTitleHighlightBlurRadius:
            return 0.8
        case .tableTitleHighlightOffsetY:
            return -1
        case .bidButtonDisabledOpacity:
            return 0.55
        case .bidSuitSelectorDisabledOpacity:
            return 0.55
        case .tableCenterSurfaceOpacity:
            return 0.16
        case .tableInnerRingOpacity:
            return 0.38
        case .tableRailHighlightOpacity:
            return 0.42
        case .tableRailInnerBevelOpacity:
            return 0.28
        case .tableRailShadowOpacity:
            return 0.24
        case .tableRailShadowRadius:
            return 6
        case .tablePlayAreaShadowOpacity:
            return 0.16
        case .trickPlaySlotBackgroundOpacity:
            return 0.34
        case .trickPlaySlotBorderOpacity:
            return 0.42
        case .trickPlayPlayedCardShadowOpacity:
            return 0.28
        case .trickPlayLegalCardOutlineOpacity:
            return 0.95
        case .trickPlayUnavailableSouthCardOpacity:
            return 0.55
        case .trickPlayWinnerHighlightOpacity:
            return 0.30
        case .trickPlayCountBackgroundOpacity:
            return 0.68
        case .southHandRailBackgroundOpacity:
            return 0.14
        case .southHandRailStrokeOpacity:
            return 0.36
        case .stationBackgroundDefaultOpacity:
            return 0.08
        case .stationBackgroundActiveOpacity:
            return 0.24
        case .bidStationCueBackgroundOpacity:
            return 0.34
        case .bidStationCueScale:
            return 1.035
        case .bidStationCueShadowOpacity:
            return 0.34
        case .bidStationCueShadowRadius:
            return 7
        case .bidTurnPillBackgroundOpacity:
            return 0.22
        case .bidCellDefaultBackgroundOpacity:
            return 0.06
        case .bidCellActiveBackgroundOpacity:
            return 0.10
        case .bidCellHighestBackgroundOpacity:
            return 0.14
        case .bidActionTrayBackgroundOpacity:
            return 0.10
        case .phaseStatusBackgroundOpacity:
            return 0.72
        case .statusPillBorderOpacity:
            return 0.55
        case .bottomControlSeparatorOpacity:
            return 0.35
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
    case bidStationCuePulseDuration = "animation.bid.stationCue.pulse.duration"
    case bidValueFadeOutDuration = "animation.bid.value.fadeOut.duration"
    case bidValueFadeInDuration = "animation.bid.value.fadeIn.duration"
    case bidAreaFadeOutDuration = "animation.bid.area.fadeOut.duration"
    case trickPlayedCardFlightDuration = "animation.trick.playedCard.flight.duration"
    case trickClearPauseDuration = "animation.trick.clear.pause.duration"
    case trickClearFadeDuration = "animation.trick.clear.fade.duration"

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
        case .bidStationCuePulseDuration:
            return 0.24
        case .bidValueFadeOutDuration:
            return 0.5
        case .bidValueFadeInDuration:
            return 0.5
        case .bidAreaFadeOutDuration:
            return 1.0
        case .trickPlayedCardFlightDuration:
            return 0.30
        case .trickClearPauseDuration:
            return 0.75
        case .trickClearFadeDuration:
            return 0.20
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
    case bidSelectorOptionGap = "layout.bidSelector.optionGap"
    case bidSuitSelectorHeight = "layout.bidSuitSelector.height"
    case bidSuitSelectorMinimumWidth = "layout.bidSuitSelector.minimumWidth"
    case bidSuitSelectorOptionMinimumWidth = "layout.bidSuitSelector.optionMinimumWidth"
    case bidSuitSelectorOptionGap = "layout.bidSuitSelector.optionGap"
    case bidButtonHeight = "layout.bidButton.height"
    case bidButtonMinimumWidth = "layout.bidButton.minimumWidth"
    case postBiddingSummaryPadding = "layout.postBiddingSummary.padding"
    case postBiddingSummaryRowGap = "layout.postBiddingSummary.rowGap"
    case postBiddingSummaryCornerRadius = "layout.postBiddingSummary.cornerRadius"
    case postBiddingSummaryOutsideTableHorizontalOffsetRatio = "layout.postBiddingSummary.outsideTableHorizontalOffsetRatio"
    case postBiddingSummaryOutsideTableVerticalOffsetRatio = "layout.postBiddingSummary.outsideTableVerticalOffsetRatio"

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
            return 32
        case .bidSelectorOptionGap:
            return 2
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
        case .postBiddingSummaryOutsideTableHorizontalOffsetRatio:
            return 0.62
        case .postBiddingSummaryOutsideTableVerticalOffsetRatio:
            return 0.70
        }
    }
}

enum GameTrickLayoutToken: String, CaseIterable, Equatable, Hashable {
    case playAreaSlotWidth = "layout.trickPlay.slot.width"
    case playAreaSlotHeight = "layout.trickPlay.slot.height"
    case playAreaSlotGap = "layout.trickPlay.slot.gap"
    case playAreaSlotCornerRadius = "layout.trickPlay.slot.cornerRadius"
    case trickCounterMinimumWidth = "layout.trickPlay.counter.minimumWidth"
    case trickCounterHeight = "layout.trickPlay.counter.height"
    case trickCounterHeaderOffset = "layout.trickPlay.counter.headerOffset"
    case trickCounterStationEdgeOffset = "layout.trickPlay.counter.stationEdgeOffset"

    var numericValue: Double {
        switch self {
        case .playAreaSlotWidth:
            return 42
        case .playAreaSlotHeight:
            return 58
        case .playAreaSlotGap:
            return 6
        case .playAreaSlotCornerRadius:
            return 6
        case .trickCounterMinimumWidth:
            return 34
        case .trickCounterHeight:
            return 18
        case .trickCounterHeaderOffset:
            return 4
        case .trickCounterStationEdgeOffset:
            return 8
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
    let hiddenFanRotationStepDegrees: Double
    let hiddenFanArcDepth: Double
    let southHandCardSpacing: Double
    let southHandSuitBoundarySpacing: Double

    static let sharedBase = CardSizeConfiguration(
        category: .sharedBaseCard,
        baseCardWidth: 36,
        baseCardHeight: 50.4,
        cornerRadius: 6,
        rankFontPointSize: 12,
        hiddenStackOffset: 2.5,
        hiddenFanRotationStepDegrees: 0.35,
        hiddenFanArcDepth: 2.5,
        southHandCardSpacing: 4,
        southHandSuitBoundarySpacing: 8
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

    var southHandAdditionalSuitBoundarySpacing: Double {
        max(0, southHandSuitBoundarySpacing - southHandCardSpacing)
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
    let optionGap = GameBidLayoutToken.bidSelectorOptionGap

    var accessibilityValue: String {
        [
            "background=\(background.rawValue)",
            "border=\(border.rawValue)",
            "text=\(text.rawValue)",
            "focusRing=\(focusRing.rawValue)",
            "height=\(height.rawValue)",
            "minimumWidth=\(minimumWidth.rawValue)",
            "optionGap=\(optionGap.rawValue)"
        ].joined(separator: ";")
    }
}

struct BidSuitSelectorTokenSet: Equatable {
    let background = GameColorToken.cardBackground
    let border = GameColorToken.cardBorder
    let text = GameColorToken.cardSuitBlack
    let selectedBackground = GameColorToken.cardBackground
    let selectedText = GameColorToken.cardSuitBlack
    let focusRing = GameColorToken.buttonNewGameBackground
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
    let outsideTableHorizontalOffset = GameBidLayoutToken.postBiddingSummaryOutsideTableHorizontalOffsetRatio
    let outsideTableVerticalOffset = GameBidLayoutToken.postBiddingSummaryOutsideTableVerticalOffsetRatio

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
            "cornerRadius=\(cornerRadius.rawValue)",
            "outsideTableHorizontalOffset=\(outsideTableHorizontalOffset.rawValue)",
            "outsideTableVerticalOffset=\(outsideTableVerticalOffset.rawValue)"
        ].joined(separator: ";")
    }
}

struct TrickPlayTokenSet: Equatable {
    let slotBackground = GameColorToken.trickPlaySlotBackground
    let slotBorder = GameColorToken.trickPlaySlotBorder
    let activeSeatOutline = GameColorToken.trickPlayActiveSeatOutline
    let legalCardOutline = GameColorToken.trickPlayLegalCardOutline
    let winnerHighlightBorder = GameColorToken.trickPlayWinnerHighlightBorder
    let countBackground = GameColorToken.trickPlayCountBackground
    let countText = GameColorToken.trickPlayCountText
    let slotBackgroundOpacity = GameEffectToken.trickPlaySlotBackgroundOpacity
    let slotBorderOpacity = GameEffectToken.trickPlaySlotBorderOpacity
    let playedCardShadowOpacity = GameEffectToken.trickPlayPlayedCardShadowOpacity
    let legalCardOutlineOpacity = GameEffectToken.trickPlayLegalCardOutlineOpacity
    let unavailableSouthCardOpacity = GameEffectToken.trickPlayUnavailableSouthCardOpacity
    let winnerHighlightOpacity = GameEffectToken.trickPlayWinnerHighlightOpacity
    let countBackgroundOpacity = GameEffectToken.trickPlayCountBackgroundOpacity
    let slotWidth = GameTrickLayoutToken.playAreaSlotWidth
    let slotHeight = GameTrickLayoutToken.playAreaSlotHeight
    let slotGap = GameTrickLayoutToken.playAreaSlotGap
    let slotCornerRadius = GameTrickLayoutToken.playAreaSlotCornerRadius
    let counterMinimumWidth = GameTrickLayoutToken.trickCounterMinimumWidth
    let counterHeight = GameTrickLayoutToken.trickCounterHeight
    let counterHeaderOffset = GameTrickLayoutToken.trickCounterHeaderOffset
    let counterStationEdgeOffset = GameTrickLayoutToken.trickCounterStationEdgeOffset
    let playedCardFlight = GameAnimationToken.trickPlayedCardFlightDuration
    let clearPause = GameAnimationToken.trickClearPauseDuration
    let clearFade = GameAnimationToken.trickClearFadeDuration

    var accessibilityValue: String {
        [
            "slotBackground=\(slotBackground.rawValue)",
            "slotBorder=\(slotBorder.rawValue)",
            "activeSeatOutline=\(activeSeatOutline.rawValue)",
            "legalCardOutline=\(legalCardOutline.rawValue)",
            "winnerHighlightBorder=\(winnerHighlightBorder.rawValue)",
            "countBackground=\(countBackground.rawValue)",
            "countText=\(countText.rawValue)",
            "slotBackgroundOpacity=\(slotBackgroundOpacity.rawValue)",
            "slotBorderOpacity=\(slotBorderOpacity.rawValue)",
            "playedCardShadowOpacity=\(playedCardShadowOpacity.rawValue)",
            "legalCardOutlineOpacity=\(legalCardOutlineOpacity.rawValue)",
            "unavailableSouthCardOpacity=\(unavailableSouthCardOpacity.rawValue)",
            "winnerHighlightOpacity=\(winnerHighlightOpacity.rawValue)",
            "countBackgroundOpacity=\(countBackgroundOpacity.rawValue)",
            "slotWidth=\(slotWidth.rawValue)",
            "slotHeight=\(slotHeight.rawValue)",
            "slotGap=\(slotGap.rawValue)",
            "slotCornerRadius=\(slotCornerRadius.rawValue)",
            "counterMinimumWidth=\(counterMinimumWidth.rawValue)",
            "counterHeight=\(counterHeight.rawValue)",
            "counterHeaderOffset=\(counterHeaderOffset.rawValue)",
            "counterStationEdgeOffset=\(counterStationEdgeOffset.rawValue)",
            "playedCardFlight=\(playedCardFlight.rawValue)",
            "playedCardFlightSeconds=\(playedCardFlight.seconds)",
            "clearPause=\(clearPause.rawValue)",
            "clearPauseSeconds=\(clearPause.seconds)",
            "clearFade=\(clearFade.rawValue)",
            "clearFadeSeconds=\(clearFade.seconds)"
        ].joined(separator: ";")
    }
}

struct BidEntryPresentation: Equatable, Identifiable {
    let seat: Seat
    let bidState: BidState
    let isSelectable: Bool
    let isActiveTurn: Bool
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
            "activeTurn=\(isActiveTurn)",
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
    let stationCuePulseToken = GameAnimationToken.bidStationCuePulseDuration
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
                isActiveTurn: seat == biddingState.currentTurnSeat,
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
            "stationCuePulse=\(stationCuePulseToken.rawValue)",
            "stationCuePulseSeconds=\(stationCuePulseToken.seconds)",
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
    let highBidderLabel: String
    let bidValueLabel: String
    let tarneebLabel = "Tarneeb"
    let tarneebSuit: Suit
    let tarneebSymbol: String
    let tarneebSymbolColorToken: GameColorToken
    let tokens = PostBiddingSummaryTokenSet()
    let tarneebSymbolChipTokens = BidSuitSelectorTokenSet()

    init?(
        phase: GamePhase,
        biddingStatus: BiddingRoundStatus?,
        summary: PostBiddingSummary?,
        isBiddingAreaFadingOut: Bool
    ) {
        guard phase == .dealt || phase == .trickPlay || phase == .handComplete,
              biddingStatus == .complete,
              !isBiddingAreaFadingOut,
              let summary else {
            return nil
        }

        self.teamLabel = summary.teamLabel
        self.highBidderLabel = summary.highBidderSeat.displayLabel
        self.bidValueLabel = summary.bidValue.displayLabel
        self.tarneebSuit = summary.tarneebSuit
        self.tarneebSymbol = summary.tarneebSymbol
        self.tarneebSymbolColorToken = summary.tarneebSuit.colorToken
    }

    var tarneebSymbolBackgroundColorToken: GameColorToken {
        tarneebSymbolChipTokens.background
    }

    var tarneebSymbolBorderColorToken: GameColorToken {
        tarneebSymbolChipTokens.focusRing
    }

    var accessibilityValue: String {
        [
            "visible=true",
            "placement=outsideTableUpperLeft",
            "display=contractBox",
            "highBidder=\(highBidderLabel)",
            "bid=\(bidValueLabel)",
            "team=\(teamLabel)",
            "tarneebLabel=\(tarneebLabel)",
            "tarneebSymbol=\(tarneebSymbol)",
            "tarneebSymbolColor=\(tarneebSymbolColorToken.rawValue)",
            "tarneebSymbolBackground=\(tarneebSymbolBackgroundColorToken.rawValue)",
            "tarneebSymbolBorder=\(tarneebSymbolBorderColorToken.rawValue)",
            "tarneebSymbolChipTokens=\(tarneebSymbolChipTokens.accessibilityValue)",
            "tokens=\(tokens.accessibilityValue)"
        ].joined(separator: ";")
    }
}

struct SouthTarneebSelectionPresentation: Equatable {
    let teamLabel: String
    let highBidderLabel: String
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
        self.highBidderLabel = Seat.south.displayLabel
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
            "highBidder=\(highBidderLabel)",
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

struct PlayedCardPresentation: Equatable, Identifiable {
    let playedCard: PlayedCard
    let card: Card
    let cardPresentation: CardPresentation
    let isWinningCard: Bool
    let tokens = TrickPlayTokenSet()

    init(
        playedCard: PlayedCard,
        pendingWinnerSeat: Seat?,
        sizeConfiguration: CardSizeConfiguration = .sharedBase
    ) {
        self.playedCard = playedCard
        self.card = playedCard.card
        self.cardPresentation = CardPresentation(card: playedCard.card, sizeConfiguration: sizeConfiguration)
        self.isWinningCard = pendingWinnerSeat == playedCard.seat
    }

    var id: String {
        playedCard.id
    }

    var seat: Seat {
        playedCard.seat
    }

    var accessibilityValue: String {
        [
            "seat=\(seat.rawValue)",
            "card=\(cardPresentation.displayLabel)",
            "asset=\(cardPresentation.faceAssetName)",
            "winning=\(isWinningCard)",
            "tokens=\(tokens.accessibilityValue)"
        ].joined(separator: ";")
    }
}

struct TrickPlayPresentation: Equatable {
    let currentTurnSeat: Seat?
    let declarerSeat: Seat
    let tarneebSuit: Suit
    let currentTrickCards: [PlayedCardPresentation]
    let pendingWinnerSeat: Seat?
    let individualTrickCounts: [Seat: Int]
    let northSouthTrickCount: Int
    let eastWestTrickCount: Int
    let completedTrickCount: Int
    let isHandComplete: Bool
    let tokens = TrickPlayTokenSet()

    init?(
        phase: GamePhase,
        trickPlayState: TrickPlayState?,
        sizeConfiguration: CardSizeConfiguration = .sharedBase
    ) {
        guard (phase == .trickPlay || phase == .handComplete),
              let trickPlayState else {
            return nil
        }

        let pendingWinnerSeat = trickPlayState.pendingCompletedTrick?.winnerSeat
        self.currentTurnSeat = trickPlayState.currentTurnSeat
        self.declarerSeat = trickPlayState.declarerSeat
        self.tarneebSuit = trickPlayState.tarneebSuit
        self.pendingWinnerSeat = pendingWinnerSeat
        self.currentTrickCards = trickPlayState.currentTrick.map {
            PlayedCardPresentation(
                playedCard: $0,
                pendingWinnerSeat: pendingWinnerSeat,
                sizeConfiguration: sizeConfiguration
            )
        }
        self.individualTrickCounts = Dictionary(
            uniqueKeysWithValues: Seat.allCases.map { seat in
                (seat, trickPlayState.individualTrickCount(for: seat))
            }
        )
        self.northSouthTrickCount = trickPlayState.partnershipTrickCount(for: .south)
        self.eastWestTrickCount = trickPlayState.partnershipTrickCount(for: .east)
        self.completedTrickCount = trickPlayState.completedTrickCount
        self.isHandComplete = trickPlayState.isHandComplete
    }

    func playedCard(for seat: Seat) -> PlayedCardPresentation? {
        currentTrickCards.first { $0.seat == seat }
    }

    func individualTrickCount(for seat: Seat) -> Int {
        individualTrickCounts[seat] ?? 0
    }

    var accessibilityValue: String {
        [
            "active=true",
            "declarer=\(declarerSeat.rawValue)",
            "currentTurn=\(currentTurnSeat?.rawValue ?? "none")",
            "tarneebSuit=\(tarneebSuit.rawValue)",
            "pendingWinner=\(pendingWinnerSeat?.rawValue ?? "none")",
            "currentTrickCards=\(currentTrickCards.map { "\($0.seat.rawValue):\($0.cardPresentation.displayLabel)" }.joined(separator: ","))",
            "individualTricks=\(Seat.allCases.map { "\($0.rawValue):\(individualTrickCount(for: $0))" }.joined(separator: ","))",
            "northSouthTricks=\(northSouthTrickCount)",
            "eastWestTricks=\(eastWestTrickCount)",
            "completedTricks=\(completedTrickCount)",
            "handComplete=\(isHandComplete)",
            "tokens=\(tokens.accessibilityValue)"
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
    let shadowOffsetYToken = GameEffectToken.tableTitleShadowOffsetY
    let highlightColorRole = GameColorRole.tableTitleHighlight
    let highlightOpacityToken = GameEffectToken.tableTitleHighlightOpacity
    let highlightBlurRadiusToken = GameEffectToken.tableTitleHighlightBlurRadius
    let highlightOffsetYToken = GameEffectToken.tableTitleHighlightOffsetY
    let usesShadow: Bool
    let style = "embossedFelt"

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
            "shadowBlur=\(shadowBlurRadiusToken.rawValue)",
            "shadowOffsetY=\(shadowOffsetYToken.rawValue)",
            "highlightColor=\(highlightColorRole.token.rawValue)",
            "highlightOpacity=\(highlightOpacityToken.rawValue)",
            "highlightOpacityValue=\(highlightOpacityToken.value)",
            "highlightBlur=\(highlightBlurRadiusToken.rawValue)",
            "highlightOffsetY=\(highlightOffsetYToken.rawValue)",
            "style=\(style)"
        ].joined(separator: ";")
    }
}

struct CardPresentation: Equatable {
    let card: Card
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
        self.card = card
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

    var stackHeight: Double {
        guard hiddenCardCount > 0 else {
            return 0
        }

        return sizeConfiguration.baseCardHeight + sizeConfiguration.hiddenFanArcDepth
    }

    var accessibilityValue: String {
        [
            "count=\(hiddenCardCount)",
            "asset=card_back",
            "hidden=true",
            "size=\(sizeConfiguration.category.rawValue)",
            "layout=stackedFan",
            "stackOffset=\(stackOffset)",
            "fanRotationStep=\(sizeConfiguration.hiddenFanRotationStepDegrees)",
            "fanArcDepth=\(sizeConfiguration.hiddenFanArcDepth)"
        ].joined(separator: ";")
    }

    func visualTransform(for hiddenCard: HiddenCardBackPresentation) -> HandCardTransform {
        let midpoint = Double(max(hiddenCardCount - 1, 0)) / 2
        let centeredIndex = Double(hiddenCard.index) - midpoint
        let normalizedDistance = midpoint > 0 ? abs(centeredIndex) / midpoint : 0

        return HandCardTransform(
            offsetX: Double(hiddenCard.index) * stackOffset,
            offsetY: sizeConfiguration.hiddenFanArcDepth * (1 - normalizedDistance),
            rotationDegrees: centeredIndex * sizeConfiguration.hiddenFanRotationStepDegrees
        )
    }
}

struct HandCardTransform: Equatable {
    let offsetX: Double
    let offsetY: Double
    let rotationDegrees: Double
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
            sourceSeat: dealerSeat,
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
            "origin=dealerStation",
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
    let dealerSeat: Seat
    let tableDiameter: Double
    let compactStationSide: Double
    let southStationHeight: Double
    let horizontalSpacing: Double
    let verticalSpacing: Double

    var tableCenterOffsetFromSceneCenter: DealAnimationOffset {
        let middleRowHeight = max(tableDiameter, compactStationSide)
        let sceneHeight = compactStationSide + verticalSpacing + middleRowHeight + verticalSpacing + southStationHeight
        let deckCenterY = compactStationSide + verticalSpacing + middleRowHeight / 2

        return DealAnimationOffset(x: 0, y: deckCenterY - sceneHeight / 2)
    }

    var sourceDeckOffsetFromSceneCenter: DealAnimationOffset {
        stationOffsetFromSceneCenter(to: dealerSeat)
    }

    func offset(to seat: Seat, stackAtTarget: Bool) -> DealAnimationOffset {
        guard stackAtTarget else {
            return sourceDeckOffsetFromSceneCenter
        }

        return stationOffsetFromSceneCenter(to: seat)
    }

    func stationOffsetFromSceneCenter(to seat: Seat) -> DealAnimationOffset {
        let tableCenter = tableCenterOffsetFromSceneCenter
        let stationOffset = stationOffsetFromTableCenter(to: seat)

        return DealAnimationOffset(
            x: tableCenter.x + stationOffset.x,
            y: tableCenter.y + stationOffset.y
        )
    }

    private func stationOffsetFromTableCenter(to seat: Seat) -> DealAnimationOffset {
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
    let sourceSeat: Seat
    let targetSeat: Seat
    let targetOrder: [Seat]
    let hiddenCards: [HiddenCardBackPresentation]
    let sizeConfiguration: CardSizeConfiguration

    init(
        sourceSeat: Seat,
        targetSeat: Seat,
        targetOrder: [Seat],
        sizeConfiguration: CardSizeConfiguration = .sharedBase
    ) {
        self.sourceSeat = sourceSeat
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
            "from=dealerStation",
            "origin=dealerStation",
            "source=\(sourceSeat.rawValue)",
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
    let dealerSeat: Seat

    init(
        phase: GamePhase,
        hiddenCardCount: Int = 52,
        sizeConfiguration: CardSizeConfiguration = .sharedBase,
        dealerSeat: Seat = .south
    ) {
        self.isVisible = phase == .notStarted
        self.sizeConfiguration = sizeConfiguration
        self.layout = CenteredDeckLayoutPresentation(sizeConfiguration: sizeConfiguration)
        self.dealerSeat = dealerSeat
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
            "source=dealerStation",
            "dealerSeat=\(dealerSeat.rawValue)",
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
        false
    }

    var placementLabel: String {
        "dealerStation"
    }

    var anchorLabel: String {
        "stationCenter"
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
    let activeSeat: Seat?
    let bidCueSeat: Seat?
    let isBidCuePulsed: Bool

    init(
        seat: Seat,
        phase: GamePhase,
        dealerSeat: Seat,
        activeSeat: Seat? = nil,
        bidCueSeat: Seat? = nil,
        isBidCuePulsed: Bool = false
    ) {
        self.seat = seat
        self.phase = phase
        self.dealerSeat = dealerSeat
        self.activeSeat = activeSeat
        self.bidCueSeat = bidCueSeat
        self.isBidCuePulsed = isBidCuePulsed
    }

    var showsDealerPill: Bool {
        seat == dealerSeat && phase == .notStarted
    }

    var isActiveTurn: Bool {
        seat == activeSeat
    }

    var isBidMotionCueActive: Bool {
        seat == bidCueSeat
    }

    var isBidMotionCuePulsed: Bool {
        isBidMotionCueActive && isBidCuePulsed
    }

    var outlineColorRole: GameColorRole {
        if isBidMotionCueActive || isActiveTurn {
            return .stationOutlineActive
        }

        return .stationOutline
    }

    var outlineToken: GameColorToken {
        outlineColorRole.token
    }

    var outlineLineWidth: Double {
        if isBidMotionCueActive {
            return 3
        }

        return isActiveTurn ? 2 : 1
    }

    var stationBackgroundOpacityToken: GameEffectToken {
        if isBidMotionCueActive {
            return .bidStationCueBackgroundOpacity
        }

        return isActiveTurn ? .stationBackgroundActiveOpacity : .stationBackgroundDefaultOpacity
    }

    var stationBackgroundOpacity: Double {
        stationBackgroundOpacityToken.value
    }

    var stationScale: Double {
        isBidMotionCuePulsed ? GameEffectToken.bidStationCueScale.value : 1
    }

    var stationShadowOpacity: Double {
        isBidMotionCueActive ? GameEffectToken.bidStationCueShadowOpacity.value : 0
    }

    var stationShadowRadius: Double {
        isBidMotionCueActive ? GameEffectToken.bidStationCueShadowRadius.value : 0
    }

    var dealerPillBackgroundRole: GameColorRole {
        .dealerBadgeBackground
    }

    var dealerPillBackgroundToken: GameColorToken {
        dealerPillBackgroundRole.token
    }

    var dealerPillTextRole: GameColorRole {
        .dealerBadgeText
    }

    var dealerPillTextToken: GameColorToken {
        dealerPillTextRole.token
    }

    var badgeBackgroundRole: GameColorRole {
        dealerPillBackgroundRole
    }

    var badgeBackgroundToken: GameColorToken {
        dealerPillBackgroundToken
    }

    var badgeTextRole: GameColorRole {
        dealerPillTextRole
    }

    var badgeTextToken: GameColorToken {
        dealerPillTextToken
    }

    var accessibilityValue: String {
        [
            "dealerSeat=\(dealerSeat.rawValue)",
            "dealerIndicator=pill",
            "dealerPillVisible=\(showsDealerPill)",
            "dealerPillPlacement=besideName",
            "dealerPillText=D",
            "dealerPillBackground=\(dealerPillBackgroundToken.rawValue)",
            "dealerPillTextColor=\(dealerPillTextToken.rawValue)",
            "activeTurn=\(isActiveTurn)",
            "bidMotionCueActive=\(isBidMotionCueActive)",
            "bidMotionCuePulsed=\(isBidMotionCuePulsed)",
            "bidMotionCueSeat=\(bidCueSeat?.rawValue ?? "none")",
            "outlineRole=\(outlineColorRole.rawValue)",
            "outline=\(outlineToken.rawValue)",
            "outlineLineWidth=\(outlineLineWidth)",
            "stationBackgroundOpacity=\(stationBackgroundOpacityToken.rawValue)",
            "stationBackgroundOpacityValue=\(stationBackgroundOpacity)",
            "stationScale=\(stationScale)",
            "stationCueScaleToken=\(GameEffectToken.bidStationCueScale.rawValue)",
            "stationShadowOpacity=\(stationShadowOpacity)",
            "stationShadowOpacityToken=\(GameEffectToken.bidStationCueShadowOpacity.rawValue)",
            "stationShadowRadius=\(stationShadowRadius)",
            "stationShadowRadiusToken=\(GameEffectToken.bidStationCueShadowRadius.rawValue)",
            "stationCuePulse=\(GameAnimationToken.bidStationCuePulseDuration.rawValue)",
            "stationCuePulseSeconds=\(GameAnimationToken.bidStationCuePulseDuration.seconds)",
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

    static func readableLayout(
        cardCount: Int,
        sizeConfiguration: CardSizeConfiguration = .sharedBase
    ) -> SouthHandLayoutPresentation {
        SouthHandLayoutPresentation(cardCount: cardCount, sizeConfiguration: sizeConfiguration)
    }
}

struct SouthHandLayoutPresentation: Equatable {
    let cardCount: Int
    let sizeConfiguration: CardSizeConfiguration

    var cardSpacing: Double {
        sizeConfiguration.southHandCardSpacing
    }

    var suitBoundarySpacing: Double {
        sizeConfiguration.southHandSuitBoundarySpacing
    }

    var additionalSuitBoundarySpacing: Double {
        sizeConfiguration.southHandAdditionalSuitBoundarySpacing
    }

    var accessibilityValue: String {
        [
            "layout=suitSeparatedGrid",
            "count=\(cardCount)",
            "cardSpacing=\(cardSpacing)",
            "suitBoundarySpacing=\(suitBoundarySpacing)",
            "additionalSuitBoundarySpacing=\(additionalSuitBoundarySpacing)"
        ].joined(separator: ";")
    }

    func additionalLeadingSpacing(
        beforeCardAt index: Int,
        in cardPresentations: [CardPresentation]
    ) -> Double {
        guard index > 0,
              index < cardPresentations.count else {
            return 0
        }

        return cardPresentations[index].suitSymbol == cardPresentations[index - 1].suitSymbol
            ? 0
            : additionalSuitBoundarySpacing
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
