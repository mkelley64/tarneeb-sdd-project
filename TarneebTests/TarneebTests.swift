import Foundation
import XCTest

final class TarneebTests: XCTestCase {
    func testUnitTestTargetRunsWithApplicationHost() {
        XCTAssertEqual(Bundle.main.bundleIdentifier, "com.mkelley.Tarneeb")
    }

    func testDesignTokenSourceCoversRequiredMVP007TokenKeys() {
        let requiredTokenKeys = [
            "color.table.background.primary",
            "color.table.background.secondary",
            "color.table.felt.highlight",
            "color.card.background",
            "color.card.border",
            "color.card.shadow",
            "color.card.suit.red",
            "color.card.suit.red.dark",
            "color.card.suit.black",
            "color.card.suit.black.soft",
            "color.station.outline",
            "color.station.outline.active",
            "color.station.outline.inactive",
            "color.dealerBadge.background",
            "color.dealerBadge.text",
            "color.text.primary",
            "color.text.secondary",
            "color.text.disabled",
            "color.text.warning",
            "color.bidArea.background",
            "color.bidArea.border",
            "color.bidArea.label",
            "color.bidArea.table.divider",
            "color.bidArea.value.text",
            "color.bidArea.value.pending.text",
            "color.bidArea.value.highest.text",
            "color.bidArea.seat.text",
            "color.postBiddingSummary.background",
            "color.postBiddingSummary.border",
            "color.postBiddingSummary.label.text",
            "color.postBiddingSummary.team.text",
            "color.postBiddingSummary.bid.text",
            "color.postBiddingSummary.tarneeb.text",
            "color.bidSelector.background",
            "color.bidSelector.border",
            "color.bidSelector.text",
            "color.bidSelector.focusRing",
            "color.bidSuitSelector.background",
            "color.bidSuitSelector.border",
            "color.bidSuitSelector.text",
            "color.bidSuitSelector.selected.background",
            "color.bidSuitSelector.selected.text",
            "color.bidSuitSelector.focusRing",
            "color.tableTitle.text",
            "effect.tableTitle.shadow.color",
            "color.button.deal.background",
            "color.button.deal.background.pressed",
            "color.button.deal.text",
            "color.button.bid.background",
            "color.button.bid.background.pressed",
            "color.button.bid.text",
            "color.button.newGame.background",
            "color.button.newGame.background.pressed",
            "color.button.newGame.text",
            "color.button.destructive.background",
            "color.button.destructive.text"
        ]

        XCTAssertEqual(Set(GameColorToken.allCases.map(\.rawValue)), Set(requiredTokenKeys))
        XCTAssertEqual(GameColorToken.allCases.count, requiredTokenKeys.count)
        XCTAssertTrue(GameColorToken.allCases.allSatisfy { !$0.hexValue.isEmpty })
    }

    func testDesignTokenRolesResolveToRequiredTokens() {
        let expectedRoleTokens: [GameColorRole: GameColorToken] = [
            .tableSurface: .tableBackgroundPrimary,
            .tableSurfaceSecondary: .tableBackgroundSecondary,
            .tableHighlight: .tableFeltHighlight,
            .cardFace: .cardBackground,
            .cardBorder: .cardBorder,
            .cardShadow: .cardShadow,
            .suitWarm: .cardSuitRed,
            .suitWarmEmphasis: .cardSuitRedDark,
            .suitNeutral: .cardSuitBlack,
            .suitNeutralSecondary: .cardSuitBlackSoft,
            .stationOutline: .stationOutline,
            .stationOutlineActive: .stationOutlineActive,
            .stationOutlineInactive: .stationOutlineInactive,
            .dealerBadgeBackground: .dealerBadgeBackground,
            .dealerBadgeText: .dealerBadgeText,
            .textPrimary: .textPrimary,
            .textSecondary: .textSecondary,
            .textDisabled: .textDisabled,
            .textWarning: .textWarning,
            .bidAreaBackground: .bidAreaBackground,
            .bidAreaBorder: .bidAreaBorder,
            .bidAreaLabel: .bidAreaLabel,
            .bidAreaTableDivider: .bidAreaTableDivider,
            .bidAreaValueText: .bidAreaValueText,
            .bidAreaPendingValueText: .bidAreaPendingValueText,
            .bidAreaHighestValueText: .bidAreaHighestValueText,
            .bidAreaSeatText: .bidAreaSeatText,
            .postBiddingSummaryBackground: .postBiddingSummaryBackground,
            .postBiddingSummaryBorder: .postBiddingSummaryBorder,
            .postBiddingSummaryLabelText: .postBiddingSummaryLabelText,
            .postBiddingSummaryTeamText: .postBiddingSummaryTeamText,
            .postBiddingSummaryBidText: .postBiddingSummaryBidText,
            .postBiddingSummaryTarneebText: .postBiddingSummaryTarneebText,
            .bidSelectorBackground: .bidSelectorBackground,
            .bidSelectorBorder: .bidSelectorBorder,
            .bidSelectorText: .bidSelectorText,
            .bidSelectorFocusRing: .bidSelectorFocusRing,
            .bidSuitSelectorBackground: .bidSuitSelectorBackground,
            .bidSuitSelectorBorder: .bidSuitSelectorBorder,
            .bidSuitSelectorText: .bidSuitSelectorText,
            .bidSuitSelectorSelectedBackground: .bidSuitSelectorSelectedBackground,
            .bidSuitSelectorSelectedText: .bidSuitSelectorSelectedText,
            .bidSuitSelectorFocusRing: .bidSuitSelectorFocusRing,
            .tableTitleText: .tableTitleText,
            .tableTitleShadow: .tableTitleShadow,
            .dealActionBackground: .buttonDealBackground,
            .dealActionPressedBackground: .buttonDealBackgroundPressed,
            .dealActionText: .buttonDealText,
            .bidActionBackground: .buttonBidBackground,
            .bidActionPressedBackground: .buttonBidBackgroundPressed,
            .bidActionText: .buttonBidText,
            .newGameActionBackground: .buttonNewGameBackground,
            .newGameActionPressedBackground: .buttonNewGameBackgroundPressed,
            .newGameActionText: .buttonNewGameText
        ]

        let actualRoleTokens = Dictionary(uniqueKeysWithValues: GameColorRole.allCases.map { ($0, $0.token) })

        XCTAssertEqual(actualRoleTokens, expectedRoleTokens)
    }

    func testTableTitleTypographyAndEffectTokensAreAvailable() {
        XCTAssertEqual(GameTypographyToken.tableTitleFont.stringValue, "SF Arabic Rounded Bold")
        XCTAssertEqual(GameTypographyToken.tableTitleFontSize.stringValue, "26pt")
        XCTAssertEqual(GameTypographyToken.tableTitleFontSize.numericValue, 26)
        XCTAssertEqual(GameTypographyToken.tableTitleTrackingMinimum.numericValue, 2)
        XCTAssertEqual(GameTypographyToken.tableTitleTrackingMaximum.numericValue, 4)
        XCTAssertEqual(GameColorToken.tableTitleText.hexValue, "#E8DFC8")
        XCTAssertEqual(GameColorToken.tableTitleShadow.hexValue, "#000000")
        XCTAssertEqual(GameEffectToken.tableTitleTextOpacity.value, 0.92)
        XCTAssertEqual(GameEffectToken.tableTitleShadowOpacity.value, 0.25)
        XCTAssertEqual(GameEffectToken.tableTitleShadowBlurRadius.value, 4)
        XCTAssertEqual(GameEffectToken.bidButtonDisabledOpacity.value, 0.55)
        XCTAssertEqual(GameEffectToken.bidSuitSelectorDisabledOpacity.value, 0.55)
        XCTAssertEqual(GameEffectToken.tableCenterSurfaceOpacity.value, 0.16)
        XCTAssertEqual(GameEffectToken.tableInnerRingOpacity.value, 0.38)
        XCTAssertEqual(GameEffectToken.tableRailHighlightOpacity.value, 0.42)
        XCTAssertEqual(GameEffectToken.tableRailInnerBevelOpacity.value, 0.28)
        XCTAssertEqual(GameEffectToken.tableRailShadowOpacity.value, 0.24)
        XCTAssertEqual(GameEffectToken.tableRailShadowRadius.value, 6)
        XCTAssertEqual(GameEffectToken.tablePlayAreaShadowOpacity.value, 0.16)
        XCTAssertEqual(GameEffectToken.southHandRailBackgroundOpacity.value, 0.14)
        XCTAssertEqual(GameEffectToken.southHandRailStrokeOpacity.value, 0.36)
        XCTAssertEqual(GameEffectToken.stationBackgroundDefaultOpacity.value, 0.08)
        XCTAssertEqual(GameEffectToken.stationBackgroundActiveOpacity.value, 0.24)
        XCTAssertEqual(GameEffectToken.bidStationCueBackgroundOpacity.value, 0.34)
        XCTAssertEqual(GameEffectToken.bidStationCueScale.value, 1.035)
        XCTAssertEqual(GameEffectToken.bidStationCueShadowOpacity.value, 0.34)
        XCTAssertEqual(GameEffectToken.bidStationCueShadowRadius.value, 7)
        XCTAssertEqual(GameEffectToken.bidTurnPillBackgroundOpacity.value, 0.22)
        XCTAssertEqual(GameEffectToken.bidCellDefaultBackgroundOpacity.value, 0.06)
        XCTAssertEqual(GameEffectToken.bidCellActiveBackgroundOpacity.value, 0.10)
        XCTAssertEqual(GameEffectToken.bidCellHighestBackgroundOpacity.value, 0.14)
        XCTAssertEqual(GameEffectToken.bidActionTrayBackgroundOpacity.value, 0.10)
        XCTAssertEqual(GameEffectToken.statusPillBorderOpacity.value, 0.55)
        XCTAssertEqual(GameEffectToken.phaseStatusBackgroundOpacity.value, 0.72)
        XCTAssertEqual(GameEffectToken.bottomControlSeparatorOpacity.value, 0.35)
    }

    func testUndealtDeckLayoutTokensAreAvailable() {
        let requiredLayoutTokenKeys = [
            "layout.undealtDeck.anchor.x",
            "layout.undealtDeck.anchor.y",
            "layout.undealtDeck.centerOffset.x",
            "layout.undealtDeck.centerOffset.y",
            "layout.undealtDeck.stack.rotation",
            "layout.undealtDeck.stack.offset.x",
            "layout.undealtDeck.stack.offset.y",
            "layout.undealtDeck.edgeBuffer.min"
        ]

        XCTAssertEqual(Set(GameLayoutToken.allCases.map(\.rawValue)), Set(requiredLayoutTokenKeys))
        XCTAssertEqual(GameLayoutToken.undealtDeckAnchorX.numericValue, 0.5)
        XCTAssertEqual(GameLayoutToken.undealtDeckAnchorY.numericValue, 0.5)
        XCTAssertEqual(GameLayoutToken.undealtDeckCenterOffsetX.numericValue, 0)
        XCTAssertEqual(GameLayoutToken.undealtDeckCenterOffsetY.numericValue, 0)
        XCTAssertEqual(GameLayoutToken.undealtDeckStackRotation.numericValue, 0)
        XCTAssertEqual(GameLayoutToken.undealtDeckStackOffsetX.numericValue, 0)
        XCTAssertEqual(GameLayoutToken.undealtDeckStackOffsetY.numericValue, 0)
        XCTAssertEqual(GameLayoutToken.undealtDeckEdgeBufferMinimum.numericValue, 12)
    }

    func testBidAreaAndSelectorTokensAreAvailable() {
        let requiredLayoutTokenKeys = [
            "layout.bidArea.padding",
            "layout.bidArea.table.rowGap",
            "layout.bidArea.cornerRadius",
            "layout.bidSelector.height",
            "layout.bidSelector.minimumWidth",
            "layout.bidSelector.optionGap",
            "layout.bidSuitSelector.height",
            "layout.bidSuitSelector.minimumWidth",
            "layout.bidSuitSelector.optionMinimumWidth",
            "layout.bidSuitSelector.optionGap",
            "layout.bidButton.height",
            "layout.bidButton.minimumWidth",
            "layout.postBiddingSummary.padding",
            "layout.postBiddingSummary.rowGap",
            "layout.postBiddingSummary.cornerRadius",
            "layout.postBiddingSummary.tableEdgeVerticalOffsetRatio"
        ]
        let bidAreaTokens = BidAreaTokenSet()
        let selectorTokens = BidSelectorTokenSet()
        let suitSelectorTokens = BidSuitSelectorTokenSet()
        let summaryTokens = PostBiddingSummaryTokenSet()

        XCTAssertEqual(Set(GameBidLayoutToken.allCases.map(\.rawValue)), Set(requiredLayoutTokenKeys))
        XCTAssertEqual(GameBidLayoutToken.bidAreaPadding.numericValue, 12)
        XCTAssertEqual(GameBidLayoutToken.bidTableRowGap.numericValue, 6)
        XCTAssertEqual(GameBidLayoutToken.bidAreaCornerRadius.numericValue, 10)
        XCTAssertEqual(GameBidLayoutToken.bidSelectorHeight.numericValue, 36)
        XCTAssertEqual(GameBidLayoutToken.bidSelectorMinimumWidth.numericValue, 32)
        XCTAssertEqual(GameBidLayoutToken.bidSelectorOptionGap.numericValue, 2)
        XCTAssertEqual(GameBidLayoutToken.bidSuitSelectorHeight.numericValue, 36)
        XCTAssertEqual(GameBidLayoutToken.bidSuitSelectorMinimumWidth.numericValue, 132)
        XCTAssertEqual(GameBidLayoutToken.bidSuitSelectorOptionMinimumWidth.numericValue, 36)
        XCTAssertEqual(GameBidLayoutToken.bidSuitSelectorOptionGap.numericValue, 4)
        XCTAssertEqual(GameBidLayoutToken.bidButtonHeight.numericValue, 36)
        XCTAssertEqual(GameBidLayoutToken.bidButtonMinimumWidth.numericValue, 56)
        XCTAssertEqual(GameBidLayoutToken.postBiddingSummaryPadding.numericValue, 12)
        XCTAssertEqual(GameBidLayoutToken.postBiddingSummaryRowGap.numericValue, 6)
        XCTAssertEqual(GameBidLayoutToken.postBiddingSummaryCornerRadius.numericValue, 10)
        XCTAssertEqual(GameBidLayoutToken.postBiddingSummaryTableEdgeVerticalOffsetRatio.numericValue, 0.35)
        XCTAssertEqual(bidAreaTokens.background, .bidAreaBackground)
        XCTAssertEqual(bidAreaTokens.border, .bidAreaBorder)
        XCTAssertEqual(bidAreaTokens.label, .bidAreaLabel)
        XCTAssertEqual(bidAreaTokens.divider, .bidAreaTableDivider)
        XCTAssertEqual(bidAreaTokens.valueText, .bidAreaValueText)
        XCTAssertEqual(bidAreaTokens.pendingValueText, .bidAreaPendingValueText)
        XCTAssertEqual(bidAreaTokens.highestValueText, .bidAreaHighestValueText)
        XCTAssertEqual(bidAreaTokens.highestValueText.hexValue, GameColorToken.buttonNewGameBackground.hexValue)
        XCTAssertEqual(bidAreaTokens.seatText, .bidAreaSeatText)
        XCTAssertEqual(selectorTokens.background, .bidSelectorBackground)
        XCTAssertEqual(selectorTokens.border, .bidSelectorBorder)
        XCTAssertEqual(selectorTokens.text, .bidSelectorText)
        XCTAssertEqual(selectorTokens.focusRing, .bidSelectorFocusRing)
        XCTAssertEqual(suitSelectorTokens.background, .cardBackground)
        XCTAssertEqual(suitSelectorTokens.border, .cardBorder)
        XCTAssertEqual(suitSelectorTokens.text, .cardSuitBlack)
        XCTAssertEqual(suitSelectorTokens.selectedBackground, .cardBackground)
        XCTAssertEqual(suitSelectorTokens.selectedText, .cardSuitBlack)
        XCTAssertEqual(suitSelectorTokens.focusRing, .buttonNewGameBackground)
        XCTAssertEqual(suitSelectorTokens.disabledOpacity, .bidSuitSelectorDisabledOpacity)
        XCTAssertEqual(summaryTokens.background, .postBiddingSummaryBackground)
        XCTAssertEqual(summaryTokens.border, .postBiddingSummaryBorder)
        XCTAssertEqual(summaryTokens.labelText, .postBiddingSummaryLabelText)
        XCTAssertEqual(summaryTokens.teamText, .postBiddingSummaryTeamText)
        XCTAssertEqual(summaryTokens.bidText, .postBiddingSummaryBidText)
        XCTAssertEqual(summaryTokens.tarneebText, .postBiddingSummaryTarneebText)
        XCTAssertEqual(summaryTokens.bidText.hexValue, GameColorToken.buttonNewGameBackground.hexValue)
        XCTAssertTrue(bidAreaTokens.accessibilityValue.contains("background=color.bidArea.background"))
        XCTAssertTrue(selectorTokens.accessibilityValue.contains("background=color.bidSelector.background"))
        XCTAssertTrue(suitSelectorTokens.accessibilityValue.contains("background=color.card.background"))
        XCTAssertTrue(suitSelectorTokens.accessibilityValue.contains("border=color.card.border"))
        XCTAssertTrue(suitSelectorTokens.accessibilityValue.contains("selectedBackground=color.card.background"))
        XCTAssertTrue(suitSelectorTokens.accessibilityValue.contains("focusRing=color.button.newGame.background"))
        XCTAssertTrue(summaryTokens.accessibilityValue.contains("background=color.postBiddingSummary.background"))
        XCTAssertFalse(bidAreaTokens.accessibilityValue.contains("#"))
        XCTAssertFalse(selectorTokens.accessibilityValue.contains("#"))
        XCTAssertFalse(suitSelectorTokens.accessibilityValue.contains("#"))
        XCTAssertFalse(summaryTokens.accessibilityValue.contains("#"))
    }

    func testDealAnimationTokensAreAvailable() {
        let requiredAnimationTokenKeys = [
            "animation.deal.stack.flight.duration",
            "animation.deal.station.expand.duration",
            "animation.deal.step.pause.duration",
            "animation.deal.southReveal.total.duration",
            "animation.deal.southReveal.flip.duration",
            "animation.deal.southReveal.flip.stagger",
            "animation.bid.simulatedTurn.delay",
            "animation.bid.stationCue.pulse.duration",
            "animation.bid.value.fadeOut.duration",
            "animation.bid.value.fadeIn.duration",
            "animation.bid.area.fadeOut.duration",
            "animation.trick.playedCard.flight.duration"
        ]

        XCTAssertEqual(Set(GameAnimationToken.allCases.map(\.rawValue)), Set(requiredAnimationTokenKeys))
        XCTAssertGreaterThan(GameAnimationToken.dealStackFlightDuration.seconds, 0)
        XCTAssertGreaterThan(GameAnimationToken.dealStationExpansionDuration.seconds, 0)
        XCTAssertGreaterThan(GameAnimationToken.dealStepPauseDuration.seconds, 0)
        XCTAssertGreaterThan(GameAnimationToken.dealStackFlightDuration.nanoseconds, 0)
        XCTAssertGreaterThan(GameAnimationToken.dealStationExpansionDuration.nanoseconds, 0)
        XCTAssertGreaterThan(GameAnimationToken.dealStepPauseDuration.nanoseconds, 0)
        XCTAssertGreaterThan(GameAnimationToken.dealSouthRevealTotalDuration.nanoseconds, 0)
        XCTAssertGreaterThan(GameAnimationToken.dealSouthRevealFlipDuration.nanoseconds, 0)
        XCTAssertGreaterThan(GameAnimationToken.dealSouthRevealFlipStagger.nanoseconds, 0)
        XCTAssertGreaterThan(GameAnimationToken.bidSimulatedTurnDelay.nanoseconds, 0)
        XCTAssertGreaterThan(GameAnimationToken.bidStationCuePulseDuration.nanoseconds, 0)
        XCTAssertGreaterThan(GameAnimationToken.bidValueFadeOutDuration.nanoseconds, 0)
        XCTAssertGreaterThan(GameAnimationToken.bidValueFadeInDuration.nanoseconds, 0)
        XCTAssertGreaterThan(GameAnimationToken.bidAreaFadeOutDuration.nanoseconds, 0)
        XCTAssertGreaterThan(GameAnimationToken.trickPlayedCardFlightDuration.nanoseconds, 0)
        XCTAssertEqual(GameAnimationToken.dealStackFlightDuration.seconds, 0.36)
        XCTAssertEqual(GameAnimationToken.dealStationExpansionDuration.seconds, 0.16)
        XCTAssertEqual(GameAnimationToken.dealStepPauseDuration.seconds, 0.06)
        XCTAssertEqual(GameAnimationToken.dealSouthRevealTotalDuration.seconds, 1.5)
        XCTAssertEqual(GameAnimationToken.dealSouthRevealFlipDuration.seconds, 0.18)
        XCTAssertEqual(GameAnimationToken.dealSouthRevealFlipStagger.seconds, 0.11)
        XCTAssertEqual(GameAnimationToken.bidSimulatedTurnDelay.seconds, 1.0)
        XCTAssertEqual(GameAnimationToken.bidStationCuePulseDuration.seconds, 0.24)
        XCTAssertEqual(GameAnimationToken.bidValueFadeOutDuration.seconds, 0.5)
        XCTAssertEqual(GameAnimationToken.bidValueFadeInDuration.seconds, 0.5)
        XCTAssertEqual(GameAnimationToken.bidAreaFadeOutDuration.seconds, 1.0)
        XCTAssertEqual(GameAnimationToken.trickPlayedCardFlightDuration.seconds, 0.30)
        XCTAssertEqual(GameAnimationToken.bidValueFadeOutDuration.seconds + GameAnimationToken.bidValueFadeInDuration.seconds, 1.0)
        XCTAssertEqual(
            GameAnimationToken.dealSouthRevealFlipStagger.seconds * 12
                + GameAnimationToken.dealSouthRevealFlipDuration.seconds,
            GameAnimationToken.dealSouthRevealTotalDuration.seconds,
            accuracy: 0.001
        )
    }

    func testDealerRingTokenMatchesDealButton() {
        XCTAssertEqual(GameColorToken.dealerBadgeBackground.hexValue, GameColorToken.buttonDealBackground.hexValue)
        XCTAssertEqual(GameColorRole.dealerBadgeBackground.token, .dealerBadgeBackground)
    }

    func testTableTitlePresentationUsesOnlyTokenizedVisualValues() {
        let presentation = TableTitlePresentation(tracking: 3)

        XCTAssertEqual(presentation.text, "طرنيب")
        XCTAssertEqual(presentation.fontToken, .tableTitleFont)
        XCTAssertEqual(presentation.fontSizeToken, .tableTitleFontSize)
        XCTAssertEqual(presentation.fontPointSize, 26)
        XCTAssertEqual(presentation.tracking, 3)
        XCTAssertEqual(presentation.trackingMinimumToken, .tableTitleTrackingMinimum)
        XCTAssertEqual(presentation.trackingMaximumToken, .tableTitleTrackingMaximum)
        XCTAssertEqual(presentation.textColorRole.token, .tableTitleText)
        XCTAssertEqual(presentation.textOpacityToken, .tableTitleTextOpacity)
        XCTAssertEqual(presentation.shadowColorRole.token, .tableTitleShadow)
        XCTAssertEqual(presentation.shadowOpacityToken, .tableTitleShadowOpacity)
        XCTAssertEqual(presentation.shadowBlurRadiusToken, .tableTitleShadowBlurRadius)
        XCTAssertTrue(presentation.usesShadow)
        XCTAssertTrue(presentation.accessibilityValue.contains("font=typography.tableTitle.font"))
        XCTAssertTrue(presentation.accessibilityValue.contains("fontName=SF Arabic Rounded Bold"))
        XCTAssertTrue(presentation.accessibilityValue.contains("fontSize=typography.tableTitle.fontSize"))
        XCTAssertTrue(presentation.accessibilityValue.contains("pointSize=26.0"))
        XCTAssertTrue(presentation.accessibilityValue.contains("textColor=color.tableTitle.text"))
        XCTAssertTrue(presentation.accessibilityValue.contains("textOpacity=effect.tableTitle.text.opacity"))
        XCTAssertTrue(presentation.accessibilityValue.contains("textOpacityValue=0.92"))
        XCTAssertTrue(presentation.accessibilityValue.contains("shadowColor=effect.tableTitle.shadow.color"))
        XCTAssertTrue(presentation.accessibilityValue.contains("usesShadow=true"))
        XCTAssertTrue(presentation.accessibilityValue.contains("shadowOpacityValue=0.25"))
        XCTAssertFalse(presentation.accessibilityValue.contains("#"))
    }

    func testTableTitleTrackingIsClampedToTokenRange() {
        XCTAssertEqual(TableTitlePresentation(tracking: -10).tracking, 2)
        XCTAssertEqual(TableTitlePresentation(tracking: 10).tracking, 4)
    }

    func testDealButtonTokenSetUsesPrimaryDealTokens() {
        XCTAssertEqual(ButtonTokenSet.deal.background, .buttonDealBackground)
        XCTAssertEqual(ButtonTokenSet.deal.pressedBackground, .buttonDealBackgroundPressed)
        XCTAssertEqual(ButtonTokenSet.deal.text, .buttonDealText)
        XCTAssertTrue(ButtonTokenSet.deal.accessibilityValue.contains("background=color.button.deal.background"))
        XCTAssertTrue(ButtonTokenSet.deal.accessibilityValue.contains("pressed=color.button.deal.background.pressed"))
        XCTAssertTrue(ButtonTokenSet.deal.accessibilityValue.contains("text=color.button.deal.text"))
        XCTAssertFalse(ButtonTokenSet.deal.accessibilityValue.contains("newGame"))
    }

    func testNewGameButtonTokenSetUsesNewGameTokens() {
        XCTAssertEqual(ButtonTokenSet.newGame.background, .buttonNewGameBackground)
        XCTAssertEqual(ButtonTokenSet.newGame.pressedBackground, .buttonNewGameBackgroundPressed)
        XCTAssertEqual(ButtonTokenSet.newGame.text, .buttonNewGameText)
        XCTAssertTrue(ButtonTokenSet.newGame.accessibilityValue.contains("background=color.button.newGame.background"))
        XCTAssertTrue(ButtonTokenSet.newGame.accessibilityValue.contains("pressed=color.button.newGame.background.pressed"))
        XCTAssertTrue(ButtonTokenSet.newGame.accessibilityValue.contains("text=color.button.newGame.text"))
    }

    func testBidButtonTokenSetUsesBidTokens() {
        XCTAssertEqual(ButtonTokenSet.bid.background, .buttonBidBackground)
        XCTAssertEqual(ButtonTokenSet.bid.pressedBackground, .buttonBidBackgroundPressed)
        XCTAssertEqual(ButtonTokenSet.bid.text, .buttonBidText)
        XCTAssertTrue(ButtonTokenSet.bid.accessibilityValue.contains("background=color.button.bid.background"))
        XCTAssertTrue(ButtonTokenSet.bid.accessibilityValue.contains("pressed=color.button.bid.background.pressed"))
        XCTAssertTrue(ButtonTokenSet.bid.accessibilityValue.contains("text=color.button.bid.text"))
    }

    func testConcreteVisualValuesAreConfinedToDesignTokenSource() throws {
        let projectRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceRoot = projectRoot.appendingPathComponent("Tarneeb")
        let tokenSourcePath = sourceRoot
            .appendingPathComponent("DesignTokens.swift")
            .standardizedFileURL
            .path
        let sourceFiles = try FileManager.default.contentsOfDirectory(
            at: sourceRoot,
            includingPropertiesForKeys: nil
        )
        .filter { $0.pathExtension == "swift" }

        let forbiddenPatterns = [
            "#[0-9A-Fa-f]{6,8}",
            "\\b(?:Color|UIColor|NSColor)\\.(?:red|black|white|blue|green|orange|yellow|gray|grey|secondary|primary)\\b",
            "Avenir Next Condensed Heavy",
            "SF Arabic Rounded Bold"
        ]
        let uiVisualNumberPatterns = [
            "\\b0\\.92\\b",
            "\\b0\\.25\\b",
            "\\b0\\.35\\b"
        ]
        let forbiddenRegexes = try forbiddenPatterns.map { try NSRegularExpression(pattern: $0) }
        let uiVisualNumberRegexes = try uiVisualNumberPatterns.map { try NSRegularExpression(pattern: $0) }

        for file in sourceFiles where file.standardizedFileURL.path != tokenSourcePath {
            let source = try String(contentsOf: file)
            let range = NSRange(source.startIndex..<source.endIndex, in: source)
            let regexes = forbiddenRegexes + (file.lastPathComponent == "ContentView.swift" ? uiVisualNumberRegexes : [])

            for regex in regexes {
                XCTAssertNil(
                    regex.firstMatch(in: source, range: range),
                    "\(file.lastPathComponent) contains a concrete visual value outside DesignTokens.swift"
                )
            }
        }
    }

    func testSuitValuesSymbolsAndPresentationRoles() {
        XCTAssertEqual(Suit.allCases.map(\.rawValue), ["spades", "clubs", "hearts", "diamonds"])
        XCTAssertEqual(Suit.allCases.map(\.displaySymbol), ["♠", "♣", "♥", "♦"])

        XCTAssertEqual(Suit.hearts.colorRole, .suitWarm)
        XCTAssertEqual(Suit.diamonds.colorRole, .suitWarm)
        XCTAssertEqual(Suit.hearts.colorToken, .cardSuitRed)
        XCTAssertEqual(Suit.diamonds.colorToken, .cardSuitRed)

        XCTAssertEqual(Suit.clubs.colorRole, .suitNeutral)
        XCTAssertEqual(Suit.spades.colorRole, .suitNeutral)
        XCTAssertEqual(Suit.clubs.colorToken, .cardSuitBlack)
        XCTAssertEqual(Suit.spades.colorToken, .cardSuitBlack)
    }

    func testRankValuesAndDisplayLabels() {
        let expectedRanks = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]

        XCTAssertEqual(Rank.allCases.map(\.rawValue), expectedRanks)
        XCTAssertEqual(Rank.allCases.map(\.displayLabel), expectedRanks)
    }

    func testCardIdentityIsStableAndDerivedFromSuitAndRank() {
        let card = Card(suit: .spades, rank: .ace)

        XCTAssertEqual(card.id, "spades-A")
        XCTAssertEqual(card, Card(suit: .spades, rank: .ace))
        XCTAssertNotEqual(card.id, Card(suit: .hearts, rank: .ace).id)
    }

    func testDuplicateSuitRankPairsCannotAppearAsUniqueIdentities() {
        let duplicatedCards = [
            Card(suit: .spades, rank: .ace),
            Card(suit: .spades, rank: .ace)
        ]

        XCTAssertEqual(Set(duplicatedCards.map(\.id)).count, 1)
        XCTAssertEqual(Set(duplicatedCards).count, 1)
    }

    func testDeckContains52Cards() {
        XCTAssertEqual(DeckFactory.makeCanonicalDeck().count, 52)
    }

    func testDeckContainsNoJokersOrUnsupportedValues() {
        let deck = DeckFactory.makeCanonicalDeck()

        XCTAssertEqual(Set(deck.map(\.suit)), Set(Suit.allCases))
        XCTAssertEqual(Set(deck.map(\.rank)), Set(Rank.allCases))

        for suit in Suit.allCases {
            let ranksForSuit = deck.filter { $0.suit == suit }.map(\.rank)
            XCTAssertEqual(ranksForSuit, Rank.allCases)
        }
    }

    func testDeckContainsUniqueCards() {
        let deck = DeckFactory.makeCanonicalDeck()

        XCTAssertEqual(Set(deck.map(\.id)).count, 52)
        XCTAssertEqual(Set(deck).count, 52)
    }

    func testSeatPlayerAndTeamSetup() throws {
        let players = Player.initialPlayers()
        let playersBySeat = Dictionary(uniqueKeysWithValues: players.map { ($0.seat, $0) })

        XCTAssertEqual(Seat.allCases.map(\.rawValue), ["south", "west", "north", "east"])
        XCTAssertEqual(Seat.allCases.map(\.displayLabel), ["South", "West", "North", "East"])
        XCTAssertEqual(players.map(\.seat), [.south, .east, .north, .west])
        XCTAssertEqual(Set(players.map(\.seat)), Set(Seat.allCases))
        XCTAssertEqual(players.filter { $0.type == .human }.map(\.seat), [.south])
        XCTAssertEqual(Set(players.filter { $0.type == .simulated }.map(\.seat)), Set([.west, .north, .east]))
        XCTAssertEqual(playersBySeat[.south]?.team, .teamA)
        XCTAssertEqual(playersBySeat[.north]?.team, .teamA)
        XCTAssertEqual(playersBySeat[.east]?.team, .teamB)
        XCTAssertEqual(playersBySeat[.west]?.team, .teamB)
    }

    func testBidValuesAllowPassAndSevenThroughThirteenOnly() {
        let expectedValues = ["Pass", "7", "8", "9", "10", "11", "12", "13"]

        XCTAssertEqual(BidValue.allCases.map(\.rawValue), expectedValues)
        XCTAssertEqual(BidValue.allCases.map(\.displayLabel), expectedValues)
        XCTAssertEqual(BidValue.allCases.map(\.numericValue), [nil, 7, 8, 9, 10, 11, 12, 13])
        XCTAssertEqual(BidValue.legalValues(afterHighest: nil), BidValue.allCases)
        XCTAssertEqual(BidValue.legalValues(afterHighest: .ten), [.pass, .eleven, .twelve, .thirteen])
        XCTAssertEqual(BidValue.legalValues(afterHighest: .twelve), [.pass, .thirteen])
        XCTAssertEqual(BidValue.displayValue("pass"), .pass)
        XCTAssertEqual(BidValue.displayValue("13"), .thirteen)
        XCTAssertNil(BidValue(rawValue: "6"))
        XCTAssertNil(BidValue(rawValue: "14"))
        XCTAssertNil(BidValue(rawValue: "Bid"))
    }

    func testRandomBidGeneratorUsesAllowedValuesAndFallsBackToPass() {
        for (index, expectedBid) in BidValue.allCases.enumerated() {
            let generator = RandomBidGenerator { range in
                XCTAssertEqual(range, 0..<BidValue.allCases.count)
                return index
            }

            XCTAssertEqual(generator.bid(for: .east), expectedBid)
        }

        let outOfRangeGenerator = RandomBidGenerator { _ in 99 }
        XCTAssertEqual(outOfRangeGenerator.bid(for: .west), .pass)
    }

    func testInjectedBidGeneratorCanForceDeterministicSimulatedBids() {
        let forcedBids: [Seat: BidValue] = [
            .east: .seven,
            .north: .ten,
            .west: .thirteen
        ]
        let generator = BidGenerator { seat in
            forcedBids[seat] ?? .pass
        }

        XCTAssertEqual(generator.bid(for: .east), .seven)
        XCTAssertEqual(generator.bid(for: .north), .ten)
        XCTAssertEqual(generator.bid(for: .west), .thirteen)
        XCTAssertEqual(generator.bid(for: .south), .pass)
    }

    func testEnvironmentBidGeneratorUsesConfiguredSeatValuesWhenProvided() {
        let generator = EnvironmentBidGenerator(
            environment: ["TARNEEB_SIMULATED_BIDS": "east:7,north:Pass,west:13"],
            fallback: BidGenerator { _ in .eight }
        )

        XCTAssertEqual(generator.bid(for: .east), .seven)
        XCTAssertEqual(generator.bid(for: .north), .pass)
        XCTAssertEqual(generator.bid(for: .west), .thirteen)
        XCTAssertEqual(generator.bid(for: .south), .eight)
    }

    func testGameStateOnlyUsesMVPPhasesAndInitialStateHasEmptySeats() {
        let state = GameState.initial(dealerSeat: .east)

        XCTAssertEqual(GamePhase.allCases.map(\.rawValue), ["notStarted", "dealt"])
        XCTAssertEqual(state.phase, .notStarted)
        XCTAssertEqual(state.players.count, 4)
        XCTAssertTrue(state.players.allSatisfy(\.hand.isEmpty))
        XCTAssertEqual(state.dealerSeat, .east)
        XCTAssertNil(state.deck)
        XCTAssertTrue(state.bids.isEmpty)
    }

    func testRandomDealerSelectorCanSelectAnySeatThroughInjectedRandomIndex() {
        for (index, expectedSeat) in Seat.dealerRotationOrder.enumerated() {
            let selector = RandomDealerSelector { range in
                XCTAssertEqual(range, 0..<4)
                return index
            }

            XCTAssertEqual(selector.selectDealer(), expectedSeat)
        }
    }

    func testEnvironmentDealerSelectorUsesForcedDealerWhenProvided() {
        let selector = EnvironmentDealerSelector(
            environment: ["TARNEEB_INITIAL_DEALER": "north"],
            fallback: RandomDealerSelector { _ in 0 }
        )

        XCTAssertEqual(selector.selectDealer(), .north)
    }

    func testDealerRotationOrderIsCounterclockwise() {
        XCTAssertEqual(Seat.dealerRotationOrder, [.south, .east, .north, .west])
        XCTAssertEqual(Seat.south.nextCounterclockwiseDealer, .east)
        XCTAssertEqual(Seat.east.nextCounterclockwiseDealer, .north)
        XCTAssertEqual(Seat.north.nextCounterclockwiseDealer, .west)
        XCTAssertEqual(Seat.west.nextCounterclockwiseDealer, .south)
    }

    func testGameStateRequiresExactlyFourPlayers() {
        let players = makeFourPlayers()

        XCTAssertNil(GameState(phase: .notStarted, players: Array(players.prefix(3)), dealerSeat: .south))
        XCTAssertNotNil(GameState(phase: .notStarted, players: players, dealerSeat: .south))
        XCTAssertNil(GameState(phase: .dealt, players: players + [players[0]], dealerSeat: .south))
    }

    func testStandardShufflerPreservesCardCountAndUniqueness() {
        let deck = DeckFactory.makeCanonicalDeck()
        let shuffledDeck = StandardCardShuffler().shuffle(deck)

        XCTAssertEqual(shuffledDeck.count, 52)
        XCTAssertEqual(Set(shuffledDeck.map(\.id)).count, 52)
        XCTAssertEqual(Set(shuffledDeck), Set(deck))
    }

    func testDealServiceShufflesCanonicalDeckBeforeAssigningCards() throws {
        let canonicalDeck = DeckFactory.makeCanonicalDeck()
        let reversedDeck = Array(canonicalDeck.reversed())
        let shuffler = RecordingShuffler(outputs: [reversedDeck])
        let state = try makeCompletedDeal(shuffler: shuffler)

        XCTAssertEqual(shuffler.receivedDecks, [canonicalDeck])
        XCTAssertEqual(try player(in: state, seat: .south).hand, Array(reversedDeck[0..<13]))
        XCTAssertNotEqual(try player(in: state, seat: .south).hand, Array(canonicalDeck[0..<13]))
    }

    func testDealAssignsShuffledCardsAsSouthEastNorthWestChunks() throws {
        let deck = DeckFactory.makeCanonicalDeck()
        let reversedDeck = Array(deck.reversed())
        let state = try makeCompletedDeal(shuffler: CardShuffler { _ in reversedDeck })

        XCTAssertEqual(try player(in: state, seat: .south).hand, Array(reversedDeck[0..<13]))
        XCTAssertEqual(try player(in: state, seat: .east).hand, Array(reversedDeck[13..<26]))
        XCTAssertEqual(try player(in: state, seat: .north).hand, Array(reversedDeck[26..<39]))
        XCTAssertEqual(try player(in: state, seat: .west).hand, Array(reversedDeck[39..<52]))
    }

    func testDealLogsEachPlayerHandThroughReplaceableLogger() throws {
        final class CapturingHandLogger: HandLogging {
            var capturedPlayers: [[Player]] = []

            func logHands(_ players: [Player]) {
                capturedPlayers.append(players)
            }
        }

        let logger = CapturingHandLogger()
        let state = try XCTUnwrap(DealService(
            shuffler: CardShuffler { $0 },
            handLogger: logger
        ).deal(dealerSeat: .south))

        XCTAssertEqual(logger.capturedPlayers.count, 1)
        let loggedPlayers = logger.capturedPlayers[0]
        XCTAssertEqual(Set(loggedPlayers.map(\.seat)), Set(Seat.allCases))
        for seat in Seat.allCases {
            let loggedHand = try XCTUnwrap(loggedPlayers.first { $0.seat == seat }?.hand)
            let stateHand = try player(in: state, seat: seat).hand
            XCTAssertEqual(loggedHand.count, 13)
            XCTAssertEqual(loggedHand, stateHand)
        }
    }

    func testCompletedDealContainsFourThirteenCardHandsAndNoDuplicates() throws {
        let state = try makeCompletedDeal(dealerSeat: .west)
        let dealtCards = state.players.flatMap(\.hand)

        XCTAssertEqual(state.phase, .dealt)
        XCTAssertEqual(state.dealerSeat, .west)
        XCTAssertEqual(state.deck, [])
        XCTAssertEqual(Set(state.bids.keys), Set(Seat.allCases))
        XCTAssertTrue(state.bids.values.allSatisfy { $0 == .pending })
        XCTAssertEqual(state.currentBiddingSeat, .south)
        XCTAssertNil(state.highestBidSeat)
        XCTAssertNil(state.highestBidValue)
        XCTAssertEqual(state.biddingStatus, .inProgress)
        XCTAssertEqual(state.players.map(\.hand.count), [13, 13, 13, 13])
        XCTAssertEqual(dealtCards.count, 52)
        XCTAssertEqual(Set(dealtCards), Set(DeckFactory.makeCanonicalDeck()))
        XCTAssertEqual(Set(dealtCards.map(\.id)).count, 52)
    }

    func testDealInitializesPendingBiddingRoundForEverySeat() throws {
        let state = try makeCompletedDeal(dealerSeat: .south)

        XCTAssertEqual(state.bids[.south], .pending)
        XCTAssertEqual(state.bids[.east], .pending)
        XCTAssertEqual(state.bids[.north], .pending)
        XCTAssertEqual(state.bids[.west], .pending)
        XCTAssertEqual(Set(state.bids.keys), Set(Seat.allCases))
        XCTAssertEqual(state.currentBiddingSeat, .east)
        XCTAssertNil(state.highestBidSeat)
        XCTAssertNil(state.highestBidValue)
        XCTAssertEqual(state.biddingStatus, .inProgress)
    }

    func testDealerSelectionDoesNotAlterChunkAssignmentOrder() throws {
        let deck = DeckFactory.makeCanonicalDeck()
        let reversedDeck = Array(deck.reversed())
        let state = try makeCompletedDeal(
            shuffler: CardShuffler { _ in reversedDeck },
            dealerSeat: .west
        )

        XCTAssertEqual(state.dealerSeat, .west)
        XCTAssertEqual(try player(in: state, seat: .south).hand, Array(reversedDeck[0..<13]))
        XCTAssertEqual(try player(in: state, seat: .east).hand, Array(reversedDeck[13..<26]))
        XCTAssertEqual(try player(in: state, seat: .north).hand, Array(reversedDeck[26..<39]))
        XCTAssertEqual(try player(in: state, seat: .west).hand, Array(reversedDeck[39..<52]))
    }

    func testInvalidCompletedDealsAreRejected() {
        let emptyHandPlayers = Player.initialPlayers()
        XCTAssertNil(GameState(phase: .dealt, players: emptyHandPlayers, dealerSeat: .south, deck: []))

        var shortHandPlayers = Player.initialPlayers()
        let canonicalDeck = DeckFactory.makeCanonicalDeck()
        for (index, seat) in Seat.dealOrder.enumerated() {
            let startIndex = index * 13
            let endIndex = startIndex + 13
            let hand = Array(canonicalDeck[startIndex..<endIndex])
            let playerIndex = shortHandPlayers.firstIndex { $0.seat == seat }!
            shortHandPlayers[playerIndex].hand = seat == .south ? Array(hand.dropLast()) : hand
        }
        XCTAssertNil(GameState(phase: .dealt, players: shortHandPlayers, dealerSeat: .south, deck: []))

        var duplicateCardPlayers = Player.initialPlayers()
        let repeatedHand = Array(repeating: Card(suit: .spades, rank: .ace), count: 13)
        for index in duplicateCardPlayers.indices {
            duplicateCardPlayers[index].hand = repeatedHand
        }
        XCTAssertNil(GameState(phase: .dealt, players: duplicateCardPlayers, dealerSeat: .south, deck: []))

        let validDeal = DealService(shuffler: CardShuffler { $0 }).deal(dealerSeat: .south)
        let validPlayers = validDeal?.players ?? []
        XCTAssertNil(GameState(phase: .dealt, players: validPlayers, dealerSeat: .south, deck: [canonicalDeck[0]]))

        let droppingShuffler = CardShuffler { cards in
            Array(cards.dropLast())
        }
        XCTAssertNil(DealService(shuffler: droppingShuffler).deal(dealerSeat: .south))
    }

    func testGameStateRequiresPostDealBiddingStateForAllSeatsOnlyInDealtState() throws {
        let completedDeal = try makeCompletedDeal()
        let validBiddingState = BiddingState.started(dealerSeat: .south)

        XCTAssertNotNil(GameState(
            phase: .dealt,
            players: completedDeal.players,
            dealerSeat: .south,
            deck: [],
            biddingState: validBiddingState
        ))
        XCTAssertNil(GameState(
            phase: .dealt,
            players: completedDeal.players,
            dealerSeat: .south,
            deck: [],
            biddingState: BiddingState(
                bids: [.south: .pending, .east: .pending, .north: .pending],
                currentTurnSeat: .east,
                highestBidSeat: nil,
                highestBidValue: nil,
                status: .inProgress
            )
        ))
        XCTAssertNil(GameState(
            phase: .dealt,
            players: completedDeal.players,
            dealerSeat: .south,
            deck: []
        ))
        XCTAssertNil(GameState(
            phase: .notStarted,
            players: Player.initialPlayers(),
            dealerSeat: .south,
            biddingState: validBiddingState
        ))
    }

    func testBiddingStartsAtDealersRightAndShowsPendingValues() {
        let southDealerState = BiddingState.started(dealerSeat: .south)
        let westDealerState = BiddingState.started(dealerSeat: .west)

        XCTAssertEqual(southDealerState.currentTurnSeat, .east)
        XCTAssertEqual(westDealerState.currentTurnSeat, .south)
        XCTAssertEqual(southDealerState.bids[.south]?.displayLabel, "--")
        XCTAssertEqual(southDealerState.bids[.east]?.displayLabel, "--")
        XCTAssertEqual(southDealerState.bids[.north]?.displayLabel, "--")
        XCTAssertEqual(southDealerState.bids[.west]?.displayLabel, "--")
        XCTAssertEqual(southDealerState.southLegalValues, BidValue.allCases)
        XCTAssertFalse(southDealerState.isWaitingForSouth)
        XCTAssertTrue(westDealerState.isWaitingForSouth)
    }

    func testBiddingServiceAdvancesSimulatedTurnsUntilSouthTurn() throws {
        var generatedBids: [BidValue] = [.seven, .eight, .nine]
        let state = try makeCompletedDeal(dealerSeat: .south)
        let service = BiddingService(bidGenerator: BidGenerator { _ in generatedBids.removeFirst() })
        let advancedState = service.advanceSimulatedTurns(in: state)

        XCTAssertEqual(advancedState.bids[.east], .resolved(.seven))
        XCTAssertEqual(advancedState.bids[.north], .resolved(.eight))
        XCTAssertEqual(advancedState.bids[.west], .resolved(.nine))
        XCTAssertEqual(advancedState.bids[.south], .pending)
        XCTAssertEqual(advancedState.currentBiddingSeat, .south)
        XCTAssertEqual(advancedState.highestBidSeat, .west)
        XCTAssertEqual(advancedState.highestBidValue, .nine)
        XCTAssertEqual(advancedState.biddingStatus, .inProgress)
    }

    func testBiddingServiceConvertsLowerOrEqualSimulatedSelectionsToPass() throws {
        var generatedBids: [BidValue] = [.ten, .nine, .ten]
        let state = try makeCompletedDeal(dealerSeat: .south)
        let service = BiddingService(bidGenerator: BidGenerator { _ in generatedBids.removeFirst() })
        let advancedState = service.advanceSimulatedTurns(in: state)

        XCTAssertEqual(advancedState.bids[.east], .resolved(.ten))
        XCTAssertEqual(advancedState.bids[.north], .resolved(.pass))
        XCTAssertEqual(advancedState.bids[.west], .resolved(.pass))
        XCTAssertEqual(advancedState.bids[.south], .pending)
        XCTAssertEqual(advancedState.highestBidSeat, .east)
        XCTAssertEqual(advancedState.highestBidValue, .ten)
        XCTAssertEqual(advancedState.currentBiddingSeat, .south)
    }

    func testBiddingServiceRejectsOneTrickPartnerRaiseOverride() throws {
        let dealtState = try makeCompletedDeal(dealerSeat: .north)
        let partnerHighBiddingState = BiddingState(
            bids: [
                .south: .resolved(.pass),
                .east: .pending,
                .north: .pending,
                .west: .resolved(.seven)
            ],
            bidRecommendations: [
                .west: BidRecommendation(bid: .seven, preferredTarneebSuit: .diamonds, confidence: 1)
            ],
            currentTurnSeat: .east,
            highestBidSeat: .west,
            highestBidValue: .seven,
            status: .inProgress
        )
        let state = dealtState.replacingBiddingState(partnerHighBiddingState)
        let service = BiddingService(bidGenerator: BidGenerator { seat in
            XCTAssertEqual(seat, .east)
            return .eight
        })

        let resolvedState = service.resolveNextSimulatedBid(in: state)

        XCTAssertEqual(resolvedState.bids[.east], .resolved(.pass))
        XCTAssertEqual(resolvedState.highestBidSeat, .west)
        XCTAssertEqual(resolvedState.highestBidValue, .seven)
        XCTAssertEqual(resolvedState.currentBiddingSeat, .north)
        XCTAssertNil(resolvedState.biddingState?.bidRecommendations[.east])
    }

    func testBiddingServiceCompletesWhenEveryNonHighestBidderPasses() throws {
        var generatedBids: [BidValue] = [.seven, .pass, .pass, .pass, .pass, .pass]
        let state = try makeCompletedDeal(dealerSeat: .south)
        let service = BiddingService(bidGenerator: BidGenerator { _ in generatedBids.removeFirst() })
        let advancedState = service.advanceSimulatedTurns(in: state)
        let completedState = service.submitSouthBid(.pass, in: advancedState)

        XCTAssertEqual(completedState.biddingStatus, .complete)
        XCTAssertEqual(completedState.biddingCompletionOutcome, .numericHighBid)
        XCTAssertNil(completedState.currentBiddingSeat)
        XCTAssertEqual(completedState.highestBidSeat, .east)
        XCTAssertEqual(completedState.highestBidValue, .seven)
        XCTAssertEqual(completedState.bids[.south], .resolved(.pass))
        XCTAssertEqual(completedState.bids[.north], .resolved(.pass))
        XCTAssertEqual(completedState.bids[.west], .resolved(.pass))
    }

    func testBiddingServiceCompletesWithNoHighestBidderWhenAllPlayersPass() throws {
        var generatedBids: [BidValue] = [.pass, .pass, .pass]
        let state = try makeCompletedDeal(dealerSeat: .south)
        let service = BiddingService(bidGenerator: BidGenerator { _ in generatedBids.removeFirst() })
        let advancedState = service.advanceSimulatedTurns(in: state)
        let completedState = service.submitSouthBid(.pass, in: advancedState)

        XCTAssertEqual(completedState.biddingStatus, .complete)
        XCTAssertEqual(completedState.biddingCompletionOutcome, .allPassRedeal)
        XCTAssertNil(completedState.currentBiddingSeat)
        XCTAssertNil(completedState.highestBidSeat)
        XCTAssertNil(completedState.highestBidValue)
        XCTAssertTrue(completedState.bids.values.allSatisfy { $0 == .resolved(.pass) })
    }

    func testBiddingServiceCompletesImmediatelyWhenAnyPlayerBidsThirteen() throws {
        let state = try makeCompletedDeal(dealerSeat: .south)
        let service = BiddingService(bidGenerator: BidGenerator { _ in .thirteen })
        let completedState = service.advanceSimulatedTurns(in: state)

        XCTAssertEqual(completedState.biddingStatus, .complete)
        XCTAssertEqual(completedState.biddingCompletionOutcome, .numericHighBid)
        XCTAssertNil(completedState.currentBiddingSeat)
        XCTAssertEqual(completedState.highestBidSeat, .east)
        XCTAssertEqual(completedState.highestBidValue, .thirteen)
        XCTAssertEqual(completedState.bids[.east], .resolved(.thirteen))
        XCTAssertEqual(completedState.bids[.south], .resolved(.pass))
        XCTAssertEqual(completedState.bids[.north], .resolved(.pass))
        XCTAssertEqual(completedState.bids[.west], .resolved(.pass))
    }

    func testSouthBidSubmissionCommitsSelectionWithoutResolvingSimulatedTurns() throws {
        var generatedBids: [BidValue] = [.pass, .pass, .pass]
        let state = try makeCompletedDeal(dealerSeat: .west)
        let service = BiddingService(bidGenerator: BidGenerator { _ in generatedBids.removeFirst() })
        let submittedState = service.submitSouthBid(.ten, selectedTarneebSuit: .spades, in: state)

        XCTAssertEqual(submittedState.biddingStatus, .inProgress)
        XCTAssertEqual(submittedState.currentBiddingSeat, .east)
        XCTAssertEqual(submittedState.highestBidSeat, .south)
        XCTAssertEqual(submittedState.highestBidValue, .ten)
        XCTAssertEqual(submittedState.bids[.south], .resolved(.ten))
        XCTAssertEqual(submittedState.biddingState?.bidRecommendations[.south]?.preferredTarneebSuit, .spades)
        XCTAssertEqual(submittedState.bids[.east], .pending)
        XCTAssertEqual(submittedState.bids[.north], .pending)
        XCTAssertEqual(submittedState.bids[.west], .pending)

        let afterEast = service.resolveNextSimulatedBid(in: submittedState)
        let afterNorth = service.resolveNextSimulatedBid(in: afterEast)
        let completedState = service.resolveNextSimulatedBid(in: afterNorth)

        XCTAssertEqual(completedState.biddingStatus, .complete)
        XCTAssertNil(completedState.currentBiddingSeat)
        XCTAssertEqual(completedState.highestBidSeat, .south)
        XCTAssertEqual(completedState.highestBidValue, .ten)
        XCTAssertEqual(completedState.bids[.east], .resolved(.pass))
        XCTAssertEqual(completedState.bids[.north], .resolved(.pass))
        XCTAssertEqual(completedState.bids[.west], .resolved(.pass))
    }

    func testSouthNumericBidWaitsForPostBiddingTarneebSuitSelection() throws {
        let state = try makeCompletedDeal(dealerSeat: .west)
        let service = BiddingService(bidGenerator: BidGenerator { _ in .pass })
        let submittedState = service.submitSouthBid(.ten, in: state)

        XCTAssertEqual(submittedState.bids[.south], .resolved(.ten))
        XCTAssertEqual(submittedState.highestBidSeat, .south)
        XCTAssertEqual(submittedState.highestBidValue, .ten)
        XCTAssertNil(submittedState.biddingState?.bidRecommendations[.south]?.preferredTarneebSuit)
        XCTAssertNil(submittedState.postBiddingSummary)

        let afterEast = service.resolveNextSimulatedBid(in: submittedState)
        let afterNorth = service.resolveNextSimulatedBid(in: afterEast)
        let completedWithoutSuit = service.resolveNextSimulatedBid(in: afterNorth)

        XCTAssertEqual(completedWithoutSuit.biddingStatus, .complete)
        XCTAssertEqual(completedWithoutSuit.highestBidSeat, .south)
        XCTAssertNil(completedWithoutSuit.biddingState?.bidRecommendations[.south]?.preferredTarneebSuit)
        XCTAssertNil(completedWithoutSuit.postBiddingSummary)

        let completedWithSuit = service.submitSouthTarneebSuit(.hearts, in: completedWithoutSuit)
        let summary = try XCTUnwrap(completedWithSuit.postBiddingSummary)

        XCTAssertEqual(completedWithSuit.biddingState?.bidRecommendations[.south]?.preferredTarneebSuit, .hearts)
        XCTAssertEqual(summary.highBidderSeat, .south)
        XCTAssertEqual(summary.bidValue, .ten)
        XCTAssertEqual(summary.tarneebSuit, .hearts)
    }

    func testSouthCannotBidAgainAfterPassingAndLaterPlayerRaises() throws {
        var generatedBids: [BidValue] = [.seven, .eight, .pass]
        let state = try makeCompletedDeal(dealerSeat: .west)
        let service = BiddingService(bidGenerator: BidGenerator { _ in generatedBids.removeFirst() })

        let afterSouthPass = service.submitSouthBid(.pass, in: state)
        let afterEastBid = service.resolveNextSimulatedBid(in: afterSouthPass)
        let afterNorthRaise = service.resolveNextSimulatedBid(in: afterEastBid)
        let afterWestPass = service.resolveNextSimulatedBid(in: afterNorthRaise)

        XCTAssertEqual(afterWestPass.bids[.south], .resolved(.pass))
        XCTAssertEqual(afterWestPass.bids[.east], .resolved(.seven))
        XCTAssertEqual(afterWestPass.bids[.north], .resolved(.eight))
        XCTAssertEqual(afterWestPass.bids[.west], .resolved(.pass))
        XCTAssertEqual(afterWestPass.highestBidSeat, .north)
        XCTAssertEqual(afterWestPass.highestBidValue, .eight)
        XCTAssertEqual(afterWestPass.currentBiddingSeat, .east)
        XCTAssertFalse(afterWestPass.biddingState?.isWaitingForSouth == true)

        let afterRejectedSouthBid = service.submitSouthBid(.thirteen, selectedTarneebSuit: .hearts, in: afterWestPass)
        XCTAssertEqual(afterRejectedSouthBid, afterWestPass)
    }

    func testAutomatedBidRecommenderUsesHandStrengthPreferredSuitAndConfidence() {
        let hand = [
            Card(suit: .spades, rank: .ace),
            Card(suit: .spades, rank: .king),
            Card(suit: .spades, rank: .queen),
            Card(suit: .spades, rank: .jack),
            Card(suit: .spades, rank: .ten),
            Card(suit: .spades, rank: .nine),
            Card(suit: .spades, rank: .eight),
            Card(suit: .hearts, rank: .ace),
            Card(suit: .clubs, rank: .ace),
            Card(suit: .diamonds, rank: .ace),
            Card(suit: .hearts, rank: .two),
            Card(suit: .clubs, rank: .three),
            Card(suit: .diamonds, rank: .four)
        ]
        let context = BidRecommendationContext(
            seat: .east,
            hand: hand,
            partnerSeat: .west,
            currentHighestBidValue: nil,
            currentHighestBidder: nil,
            priorBidStates: Dictionary(uniqueKeysWithValues: Seat.allCases.map { ($0, .pending) })
        )

        let recommendation = AutomatedBidRecommender().recommendation(for: context)

        XCTAssertNotEqual(recommendation.bid, .pass)
        XCTAssertEqual(recommendation.preferredTarneebSuit, .spades)
        XCTAssertGreaterThan(recommendation.confidence, 0)
        XCTAssertLessThanOrEqual(recommendation.confidence, 1)
    }

    func testWeakLongSuitWithoutAcesDoesNotOverbid() {
        let hand = [
            Card(suit: .diamonds, rank: .two),
            Card(suit: .diamonds, rank: .four),
            Card(suit: .spades, rank: .two),
            Card(suit: .spades, rank: .three),
            Card(suit: .hearts, rank: .two),
            Card(suit: .spades, rank: .eight),
            Card(suit: .spades, rank: .queen),
            Card(suit: .diamonds, rank: .king),
            Card(suit: .diamonds, rank: .ten),
            Card(suit: .diamonds, rank: .five),
            Card(suit: .clubs, rank: .seven),
            Card(suit: .clubs, rank: .three),
            Card(suit: .diamonds, rank: .jack)
        ]
        let context = BidRecommendationContext(
            seat: .north,
            hand: hand,
            partnerSeat: .south,
            currentHighestBidValue: nil,
            currentHighestBidder: nil,
            priorBidStates: Dictionary(uniqueKeysWithValues: Seat.allCases.map { ($0, .pending) })
        )

        let recommendation = AutomatedBidRecommender().recommendation(for: context)

        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 7)
        XCTAssertNotEqual(recommendation.bid, .eight)
        XCTAssertNotEqual(recommendation.bid, .nine)
    }

    func testFiveCardTrumpWithSideWinnersDoesNotOverbidTen() {
        let hand = [
            Card(suit: .hearts, rank: .seven),
            Card(suit: .diamonds, rank: .six),
            Card(suit: .diamonds, rank: .eight),
            Card(suit: .spades, rank: .four),
            Card(suit: .spades, rank: .ten),
            Card(suit: .spades, rank: .ace),
            Card(suit: .spades, rank: .jack),
            Card(suit: .diamonds, rank: .ten),
            Card(suit: .hearts, rank: .ace),
            Card(suit: .hearts, rank: .king),
            Card(suit: .clubs, rank: .four),
            Card(suit: .spades, rank: .queen),
            Card(suit: .hearts, rank: .five)
        ]
        let context = BidRecommendationContext(
            seat: .west,
            hand: hand,
            partnerSeat: .east,
            currentHighestBidValue: nil,
            currentHighestBidder: nil,
            priorBidStates: Dictionary(uniqueKeysWithValues: Seat.allCases.map { ($0, .pending) })
        )

        let recommendation = AutomatedBidRecommender().recommendation(for: context)

        XCTAssertEqual(recommendation.preferredTarneebSuit, .spades)
        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 9)
        XCTAssertNotEqual(recommendation.bid, .ten)
        XCTAssertNotEqual(recommendation.bid, .eleven)
        XCTAssertNotEqual(recommendation.bid, .twelve)
        XCTAssertNotEqual(recommendation.bid, .thirteen)
    }

    func testAceLedFiveCardTrumpWithoutKingOrQueenDoesNotOverbidEight() {
        let hand = [
            Card(suit: .spades, rank: .three),
            Card(suit: .hearts, rank: .six),
            Card(suit: .diamonds, rank: .nine),
            Card(suit: .clubs, rank: .two),
            Card(suit: .hearts, rank: .three),
            Card(suit: .spades, rank: .two),
            Card(suit: .diamonds, rank: .jack),
            Card(suit: .spades, rank: .nine),
            Card(suit: .clubs, rank: .ace),
            Card(suit: .diamonds, rank: .two),
            Card(suit: .diamonds, rank: .five),
            Card(suit: .spades, rank: .jack),
            Card(suit: .spades, rank: .ace)
        ]
        let context = BidRecommendationContext(
            seat: .north,
            hand: hand,
            partnerSeat: .south,
            currentHighestBidValue: nil,
            currentHighestBidder: nil,
            priorBidStates: Dictionary(uniqueKeysWithValues: Seat.allCases.map { ($0, .pending) })
        )

        let recommendation = AutomatedBidRecommender().recommendation(for: context)

        XCTAssertEqual(recommendation.preferredTarneebSuit, .spades)
        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 7)
        XCTAssertNotEqual(recommendation.bid, .eight)
        XCTAssertNotEqual(recommendation.bid, .nine)
    }

    func testSixCardTrumpAceQueenDoesNotOverbidTen() {
        let hand = [
            Card(suit: .clubs, rank: .king),
            Card(suit: .diamonds, rank: .ace),
            Card(suit: .hearts, rank: .ten),
            Card(suit: .spades, rank: .ten),
            Card(suit: .spades, rank: .two),
            Card(suit: .clubs, rank: .eight),
            Card(suit: .diamonds, rank: .three),
            Card(suit: .diamonds, rank: .six),
            Card(suit: .diamonds, rank: .queen),
            Card(suit: .diamonds, rank: .two),
            Card(suit: .diamonds, rank: .four),
            Card(suit: .spades, rank: .ace),
            Card(suit: .spades, rank: .four)
        ]
        let context = BidRecommendationContext(
            seat: .north,
            hand: hand,
            partnerSeat: .south,
            currentHighestBidValue: nil,
            currentHighestBidder: nil,
            priorBidStates: Dictionary(uniqueKeysWithValues: Seat.allCases.map { ($0, .pending) })
        )

        let recommendation = AutomatedBidRecommender().recommendation(for: context)

        XCTAssertEqual(recommendation.preferredTarneebSuit, .diamonds)
        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 9)
        XCTAssertNotEqual(recommendation.bid, .ten)
        XCTAssertNotEqual(recommendation.bid, .eleven)
        XCTAssertNotEqual(recommendation.bid, .twelve)
        XCTAssertNotEqual(recommendation.bid, .thirteen)
    }

    func testFiveCardAceKingQueenTenTrumpWithoutOutsideAcesDoesNotOverbidTen() {
        let hand = [
            Card(suit: .clubs, rank: .queen),
            Card(suit: .spades, rank: .ten),
            Card(suit: .diamonds, rank: .queen),
            Card(suit: .clubs, rank: .four),
            Card(suit: .clubs, rank: .five),
            Card(suit: .spades, rank: .king),
            Card(suit: .clubs, rank: .jack),
            Card(suit: .spades, rank: .ace),
            Card(suit: .diamonds, rank: .five),
            Card(suit: .diamonds, rank: .king),
            Card(suit: .spades, rank: .queen),
            Card(suit: .spades, rank: .seven),
            Card(suit: .clubs, rank: .seven)
        ]
        let context = BidRecommendationContext(
            seat: .west,
            hand: hand,
            partnerSeat: .east,
            currentHighestBidValue: nil,
            currentHighestBidder: nil,
            priorBidStates: Dictionary(uniqueKeysWithValues: Seat.allCases.map { ($0, .pending) })
        )

        let recommendation = AutomatedBidRecommender().recommendation(for: context)

        XCTAssertEqual(recommendation.preferredTarneebSuit, .spades)
        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 9)
        XCTAssertNotEqual(recommendation.bid, .ten)
        XCTAssertNotEqual(recommendation.bid, .eleven)
        XCTAssertNotEqual(recommendation.bid, .twelve)
        XCTAssertNotEqual(recommendation.bid, .thirteen)
    }

    func testFiveCardAceKingLowTrumpWithOneOutsideAceDoesNotOverbidNine() {
        let hand = [
            Card(suit: .diamonds, rank: .three),
            Card(suit: .clubs, rank: .queen),
            Card(suit: .spades, rank: .five),
            Card(suit: .clubs, rank: .five),
            Card(suit: .hearts, rank: .three),
            Card(suit: .spades, rank: .seven),
            Card(suit: .spades, rank: .four),
            Card(suit: .clubs, rank: .ace),
            Card(suit: .diamonds, rank: .four),
            Card(suit: .hearts, rank: .ten),
            Card(suit: .diamonds, rank: .two),
            Card(suit: .diamonds, rank: .king),
            Card(suit: .diamonds, rank: .ace)
        ]

        let recommendation = automatedRecommendation(for: hand)

        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 8)
        XCTAssertNotEqual(recommendation.bid, .nine)
    }

    func testFiveCardAceKingTenTrumpMissingQueenJackDoesNotOverbidNine() {
        let hand = [
            Card(suit: .diamonds, rank: .jack),
            Card(suit: .hearts, rank: .five),
            Card(suit: .spades, rank: .ace),
            Card(suit: .hearts, rank: .king),
            Card(suit: .diamonds, rank: .queen),
            Card(suit: .spades, rank: .four),
            Card(suit: .diamonds, rank: .eight),
            Card(suit: .hearts, rank: .ten),
            Card(suit: .clubs, rank: .four),
            Card(suit: .diamonds, rank: .ten),
            Card(suit: .diamonds, rank: .four),
            Card(suit: .hearts, rank: .six),
            Card(suit: .hearts, rank: .ace)
        ]

        let recommendation = automatedRecommendation(for: hand)

        XCTAssertEqual(recommendation.preferredTarneebSuit, .hearts)
        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 8)
        XCTAssertNotEqual(recommendation.bid, .nine)
    }

    func testFiveCardAceQueenTenTrumpMissingKingJackDoesNotOverbidNine() {
        let hand = [
            Card(suit: .spades, rank: .three),
            Card(suit: .clubs, rank: .queen),
            Card(suit: .spades, rank: .jack),
            Card(suit: .clubs, rank: .ten),
            Card(suit: .clubs, rank: .four),
            Card(suit: .clubs, rank: .ace),
            Card(suit: .diamonds, rank: .ace),
            Card(suit: .hearts, rank: .seven),
            Card(suit: .spades, rank: .seven),
            Card(suit: .spades, rank: .nine),
            Card(suit: .clubs, rank: .eight),
            Card(suit: .hearts, rank: .two),
            Card(suit: .spades, rank: .queen)
        ]

        let recommendation = automatedRecommendation(for: hand)

        XCTAssertEqual(recommendation.preferredTarneebSuit, .clubs)
        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 8)
        XCTAssertNotEqual(recommendation.bid, .nine)
    }

    func testSixCardAceJackTrumpWithoutKingQueenTenDoesNotOverbidTen() {
        let hand = [
            Card(suit: .diamonds, rank: .three),
            Card(suit: .spades, rank: .ten),
            Card(suit: .hearts, rank: .three),
            Card(suit: .diamonds, rank: .ace),
            Card(suit: .diamonds, rank: .four),
            Card(suit: .diamonds, rank: .jack),
            Card(suit: .hearts, rank: .four),
            Card(suit: .spades, rank: .ace),
            Card(suit: .hearts, rank: .six),
            Card(suit: .diamonds, rank: .eight),
            Card(suit: .diamonds, rank: .nine),
            Card(suit: .spades, rank: .king),
            Card(suit: .spades, rank: .seven)
        ]

        let recommendation = automatedRecommendation(for: hand)

        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 9)
        XCTAssertNotEqual(recommendation.bid, .ten)
    }

    func testFiveCardKingQueenTenTrumpMissingAceDoesNotOverbidEight() {
        let hand = [
            Card(suit: .clubs, rank: .two),
            Card(suit: .diamonds, rank: .king),
            Card(suit: .diamonds, rank: .queen),
            Card(suit: .diamonds, rank: .ten),
            Card(suit: .spades, rank: .king),
            Card(suit: .hearts, rank: .eight),
            Card(suit: .diamonds, rank: .three),
            Card(suit: .hearts, rank: .four),
            Card(suit: .diamonds, rank: .seven),
            Card(suit: .hearts, rank: .six),
            Card(suit: .clubs, rank: .ten),
            Card(suit: .clubs, rank: .king),
            Card(suit: .spades, rank: .ace)
        ]

        let recommendation = automatedRecommendation(for: hand)

        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 7)
        XCTAssertNotEqual(recommendation.bid, .eight)
    }

    func testSixCardAceKingTrumpWithTwoOutsideAcesDoesNotOverbidEleven() {
        let hand = [
            Card(suit: .clubs, rank: .queen),
            Card(suit: .spades, rank: .ace),
            Card(suit: .spades, rank: .king),
            Card(suit: .spades, rank: .six),
            Card(suit: .clubs, rank: .ten),
            Card(suit: .spades, rank: .two),
            Card(suit: .diamonds, rank: .ten),
            Card(suit: .hearts, rank: .ace),
            Card(suit: .spades, rank: .seven),
            Card(suit: .hearts, rank: .five),
            Card(suit: .clubs, rank: .nine),
            Card(suit: .spades, rank: .four),
            Card(suit: .clubs, rank: .ace)
        ]

        let recommendation = automatedRecommendation(for: hand)

        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 10)
        XCTAssertNotEqual(recommendation.bid, .eleven)
    }

    func testSixCardAceKingQueenJackTrumpWithoutOutsideAcesDoesNotOverbidEleven() {
        let hand = [
            Card(suit: .hearts, rank: .jack),
            Card(suit: .diamonds, rank: .nine),
            Card(suit: .hearts, rank: .four),
            Card(suit: .diamonds, rank: .eight),
            Card(suit: .clubs, rank: .four),
            Card(suit: .spades, rank: .king),
            Card(suit: .hearts, rank: .ace),
            Card(suit: .hearts, rank: .queen),
            Card(suit: .diamonds, rank: .three),
            Card(suit: .hearts, rank: .king),
            Card(suit: .spades, rank: .five),
            Card(suit: .spades, rank: .jack),
            Card(suit: .hearts, rank: .three)
        ]

        let recommendation = automatedRecommendation(for: hand)

        XCTAssertEqual(recommendation.preferredTarneebSuit, .hearts)
        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 10)
        XCTAssertNotEqual(recommendation.bid, .eleven)
    }

    func testFourCardAceKingTenTrumpDoesNotOverbidTen() {
        let hand = [
            Card(suit: .spades, rank: .nine),
            Card(suit: .clubs, rank: .eight),
            Card(suit: .hearts, rank: .ten),
            Card(suit: .hearts, rank: .two),
            Card(suit: .spades, rank: .eight),
            Card(suit: .clubs, rank: .jack),
            Card(suit: .spades, rank: .four),
            Card(suit: .hearts, rank: .ace),
            Card(suit: .clubs, rank: .four),
            Card(suit: .hearts, rank: .king),
            Card(suit: .clubs, rank: .king),
            Card(suit: .clubs, rank: .ace),
            Card(suit: .diamonds, rank: .king)
        ]

        let recommendation = automatedRecommendation(for: hand)

        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 9)
        XCTAssertNotEqual(recommendation.bid, .ten)
    }

    func testFourCardAceKingJackTrumpDoesNotOverbidNine() {
        let hand = [
            Card(suit: .clubs, rank: .jack),
            Card(suit: .clubs, rank: .ace),
            Card(suit: .diamonds, rank: .five),
            Card(suit: .diamonds, rank: .jack),
            Card(suit: .clubs, rank: .six),
            Card(suit: .spades, rank: .king),
            Card(suit: .hearts, rank: .king),
            Card(suit: .hearts, rank: .nine),
            Card(suit: .spades, rank: .eight),
            Card(suit: .diamonds, rank: .eight),
            Card(suit: .spades, rank: .six),
            Card(suit: .hearts, rank: .jack),
            Card(suit: .hearts, rank: .ace)
        ]

        let recommendation = automatedRecommendation(for: hand)

        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 8)
        XCTAssertNotEqual(recommendation.bid, .nine)
    }

    func testFourCardAceKingLowTrumpWithSideQueensDoesNotOverbidNine() {
        let hand = [
            Card(suit: .diamonds, rank: .six),
            Card(suit: .hearts, rank: .queen),
            Card(suit: .spades, rank: .nine),
            Card(suit: .spades, rank: .eight),
            Card(suit: .hearts, rank: .ten),
            Card(suit: .spades, rank: .six),
            Card(suit: .spades, rank: .ace),
            Card(suit: .diamonds, rank: .five),
            Card(suit: .spades, rank: .king),
            Card(suit: .clubs, rank: .queen),
            Card(suit: .hearts, rank: .seven),
            Card(suit: .clubs, rank: .eight),
            Card(suit: .clubs, rank: .ace)
        ]

        let recommendation = automatedRecommendation(for: hand)

        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 8)
        XCTAssertNotEqual(recommendation.bid, .nine)
    }

    func testFourCardAceQueenJackTrumpDoesNotOverbidNine() {
        let hand = [
            Card(suit: .clubs, rank: .ace),
            Card(suit: .diamonds, rank: .five),
            Card(suit: .spades, rank: .king),
            Card(suit: .clubs, rank: .five),
            Card(suit: .hearts, rank: .four),
            Card(suit: .clubs, rank: .queen),
            Card(suit: .hearts, rank: .two),
            Card(suit: .hearts, rank: .jack),
            Card(suit: .hearts, rank: .ace),
            Card(suit: .spades, rank: .eight),
            Card(suit: .clubs, rank: .seven),
            Card(suit: .spades, rank: .two),
            Card(suit: .clubs, rank: .jack)
        ]

        let recommendation = automatedRecommendation(for: hand)

        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 8)
        XCTAssertNotEqual(recommendation.bid, .nine)
    }

    func testFourCardAceLowTrumpOneOutsideAceDoesNotOpenSeven() {
        let hand = [
            Card(suit: .hearts, rank: .five),
            Card(suit: .spades, rank: .ten),
            Card(suit: .spades, rank: .eight),
            Card(suit: .clubs, rank: .eight),
            Card(suit: .spades, rank: .six),
            Card(suit: .diamonds, rank: .six),
            Card(suit: .diamonds, rank: .eight),
            Card(suit: .spades, rank: .jack),
            Card(suit: .hearts, rank: .ace),
            Card(suit: .clubs, rank: .ace),
            Card(suit: .spades, rank: .seven),
            Card(suit: .clubs, rank: .seven),
            Card(suit: .clubs, rank: .three)
        ]

        let recommendation = automatedRecommendation(for: hand)

        XCTAssertEqual(recommendation.bid, .pass)
        XCTAssertNil(recommendation.preferredTarneebSuit)
    }

    func testFiveCardAceKingQueenTrumpMissingJackTenDoesNotOverbidNine() {
        let recommendation = automatedRecommendation(
            for: hand("7♠ 8♠ Q♦ 9♦ A♥ 2♦ 9♣ Q♥ K♥ 7♣ 2♥ 9♥ 5♣")
        )

        XCTAssertEqual(recommendation.preferredTarneebSuit, .hearts)
        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 8)
        XCTAssertNotEqual(recommendation.bid, .nine)
    }

    func testSixCardAceKingQueenTrumpMissingJackTenDoesNotOverbidTwelve() {
        let recommendation = automatedRecommendation(
            for: hand("7♦ Q♦ 3♥ A♠ 5♣ K♣ K♦ 4♦ 6♠ 5♦ 10♣ A♦ A♣")
        )

        XCTAssertEqual(recommendation.preferredTarneebSuit, .diamonds)
        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 11)
        XCTAssertNotEqual(recommendation.bid, .twelve)
    }

    func testFiveCardKingQueenTrumpMissingAceJackTenDoesNotOverbidEight() {
        let recommendation = automatedRecommendation(
            for: hand("10♥ K♠ Q♠ 7♠ K♦ 2♦ 2♠ 7♦ 6♣ 3♣ 5♦ A♣ Q♦")
        )

        if recommendation.bid != .pass {
            XCTAssertEqual(recommendation.preferredTarneebSuit, .diamonds)
        }
        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 7)
        XCTAssertNotEqual(recommendation.bid, .eight)
    }

    func testFiveCardAceQueenTenTrumpMissingKingJackWithThreeOutsideAcesDoesNotOverbidEleven() {
        let recommendation = automatedRecommendation(
            for: hand("5♠ A♠ A♦ 4♦ 2♥ 10♦ A♥ A♣ 9♥ K♣ 7♣ Q♦ 2♦")
        )

        XCTAssertEqual(recommendation.preferredTarneebSuit, .diamonds)
        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 10)
        XCTAssertNotEqual(recommendation.bid, .eleven)
    }

    func testShortFourCardAceKingTenOrAceQueenTextureDoesNotOverbidNine() {
        let recommendation = automatedRecommendation(
            for: hand("3♠ K♥ 3♦ 5♣ 8♥ A♣ 2♠ 9♣ 6♠ 10♥ 8♣ Q♣ A♥")
        )

        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 8)
        XCTAssertNotEqual(recommendation.bid, .nine)
    }

    func testFourCardAceKingJackTenTrumpWithoutOutsideAcesDoesNotOverbidEight() {
        let recommendation = automatedRecommendation(
            for: hand("10♣ 8♠ 5♠ 9♠ 3♥ J♣ K♦ A♣ J♥ 6♥ 4♦ J♦ K♣")
        )

        if recommendation.bid != .pass {
            XCTAssertEqual(recommendation.preferredTarneebSuit, .clubs)
        }
        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 7)
        XCTAssertNotEqual(recommendation.bid, .eight)
    }

    func testFourCardAceKingLowTrumpWithoutOutsideAcesDoesNotOverbidEight() {
        let recommendation = automatedRecommendation(
            for: hand("7♠ K♣ 9♣ 3♦ 9♠ 2♥ 4♦ 6♥ Q♥ K♥ 10♣ K♦ A♦")
        )

        if recommendation.bid != .pass {
            XCTAssertEqual(recommendation.preferredTarneebSuit, .diamonds)
        }
        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 7)
        XCTAssertNotEqual(recommendation.bid, .eight)
    }

    func testFiveCardAceJackTenTrumpMissingKingQueenDoesNotOpenSeven() {
        let recommendation = automatedRecommendation(
            for: hand("A♦ 10♦ 2♣ Q♣ J♦ 9♥ Q♠ 4♥ 7♦ K♥ 9♦ 5♣ K♠")
        )

        XCTAssertEqual(recommendation.bid, .pass)
        XCTAssertNil(recommendation.preferredTarneebSuit)
    }

    func testFiveCardAceLowTrumpWithTwoOutsideAcesDoesNotOverbidEight() {
        let recommendation = automatedRecommendation(
            for: hand("A♣ 6♥ 5♥ 8♥ 3♠ 4♦ 3♣ 4♠ A♦ 6♦ A♥ 4♥ K♣")
        )

        if recommendation.bid != .pass {
            XCTAssertEqual(recommendation.preferredTarneebSuit, .hearts)
        }
        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 7)
        XCTAssertNotEqual(recommendation.bid, .eight)
    }

    func testSevenCardAceQueenTenTrumpMissingKingJackDoesNotOverbidEleven() {
        let recommendation = automatedRecommendation(
            for: hand("2♦ 5♠ Q♦ A♦ 8♦ 10♦ 6♠ 2♠ 10♥ 2♥ 3♦ 4♦ 9♥")
        )

        XCTAssertEqual(recommendation.preferredTarneebSuit, .diamonds)
        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 10)
        XCTAssertNotEqual(recommendation.bid, .eleven)
    }

    func testSevenCardAceQueenTrumpMissingKingJackTenDoesNotOverbidEleven() {
        let recommendation = automatedRecommendation(
            for: hand("A♠ 7♠ A♣ 4♣ 3♠ 5♠ 9♠ 7♥ 4♥ J♦ Q♠ 4♠ 3♥")
        )

        XCTAssertEqual(recommendation.preferredTarneebSuit, .spades)
        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 10)
        XCTAssertNotEqual(recommendation.bid, .eleven)
    }

    func testSixCardAceKingQueenTrumpMissingJackTenWithoutOutsideSupportDoesNotOverbidTen() {
        let recommendation = automatedRecommendation(
            for: hand("J♠ Q♥ 3♦ 10♠ 3♥ A♦ 6♦ J♣ Q♦ K♦ Q♣ 2♦ 10♥")
        )

        XCTAssertEqual(recommendation.preferredTarneebSuit, .diamonds)
        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 9)
        XCTAssertNotEqual(recommendation.bid, .ten)
    }

    func testFourCardAceKingJackTrumpWithStrongOutsideHonorsDoesNotOverbidTen() {
        let recommendation = automatedRecommendation(
            for: hand("A♥ A♦ K♠ 6♦ Q♥ J♣ Q♦ 4♠ 6♣ K♦ 10♥ A♣ K♣")
        )

        XCTAssertEqual(recommendation.preferredTarneebSuit, .clubs)
        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 9)
        XCTAssertNotEqual(recommendation.bid, .ten)
    }

    func testFiveCardAceTenTrumpWithoutOutsideAcesDoesNotOpenSeven() {
        let recommendation = automatedRecommendation(
            for: hand("9♠ 6♥ 10♠ 8♥ 8♣ J♦ J♣ 7♦ K♣ K♦ 3♠ A♠ 7♠")
        )

        XCTAssertEqual(recommendation.bid, .pass)
        XCTAssertNil(recommendation.preferredTarneebSuit)
    }

    func testFiveCardAceKingQueenJackTrumpMissingTenDoesNotOverbidTen() {
        let recommendation = automatedRecommendation(
            for: hand("Q♥ J♥ J♣ Q♦ 4♣ A♥ Q♠ K♥ 8♦ K♣ 2♥ 4♦ 9♣")
        )

        XCTAssertEqual(recommendation.preferredTarneebSuit, .hearts)
        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 9)
        XCTAssertNotEqual(recommendation.bid, .ten)
    }

    func testFourCardAceQueenLowTrumpWithoutOutsideAcesDoesNotOpenSeven() {
        let recommendation = automatedRecommendation(
            for: hand("9♥ 2♥ Q♠ 6♠ 8♦ Q♣ 4♥ 2♣ 8♣ 6♦ 5♥ A♠ 4♠")
        )

        XCTAssertEqual(recommendation.bid, .pass)
        XCTAssertNil(recommendation.preferredTarneebSuit)
    }

    func testFourCardAceJackTenTrumpWithoutOutsideAcesDoesNotOpenSeven() {
        let recommendation = automatedRecommendation(
            for: hand("7♥ J♣ K♠ Q♦ 7♠ 9♥ 7♦ 6♣ 10♣ A♣ 3♠ 6♠ 4♥")
        )

        XCTAssertEqual(recommendation.bid, .pass)
        XCTAssertNil(recommendation.preferredTarneebSuit)
    }

    func testFourCardAceJackTenLowTrumpWithoutOutsideAcesOrKingsDoesNotOpenSeven() {
        let recommendation = automatedRecommendation(
            for: hand("J♣ A♣ J♠ 5♥ Q♦ 8♥ 9♦ 2♦ 5♣ J♦ 5♠ 3♠ 10♣")
        )

        XCTAssertEqual(recommendation.bid, .pass)
        XCTAssertNil(recommendation.preferredTarneebSuit)
    }

    func testShallowTrumpCandidatesWithOutsideAcesDoNotOverbidEight() {
        let recommendation = automatedRecommendation(
            for: hand("7♥ J♦ Q♣ K♥ J♠ A♦ 6♠ 8♦ 5♣ 5♦ 8♠ A♠ Q♥")
        )

        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 7)
        XCTAssertNotEqual(recommendation.bid, .eight)
    }

    func testFiveCardAceKingJackTrumpMissingQueenTenDoesNotOverbidNine() {
        let recommendation = automatedRecommendation(
            for: hand("J♠ 3♥ 6♠ J♥ 9♠ 8♦ 4♦ K♥ 9♣ 9♦ A♣ A♥ 4♥")
        )

        XCTAssertEqual(recommendation.preferredTarneebSuit, .hearts)
        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 8)
        XCTAssertNotEqual(recommendation.bid, .nine)
    }

    func testSixCardAceKingQueenTrumpMissingJackTenWithOneOutsideKingDoesNotOverbidEleven() {
        let recommendation = automatedRecommendation(
            for: hand("7♠ 10♠ 5♠ 8♦ K♣ A♦ 8♠ 2♦ 9♣ Q♦ K♦ 6♠ 5♦")
        )

        XCTAssertEqual(recommendation.preferredTarneebSuit, .diamonds)
        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 10)
        XCTAssertNotEqual(recommendation.bid, .eleven)
    }

    func testEightCardAceQueenJackTenTrumpMissingKingDoesNotOverbidTwelve() {
        let recommendation = automatedRecommendation(
            for: hand("7♦ 4♥ 7♥ 9♦ 5♥ Q♦ 2♥ J♦ 6♦ A♦ 2♦ 10♦ 5♠")
        )

        XCTAssertEqual(recommendation.preferredTarneebSuit, .diamonds)
        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 11)
        XCTAssertNotEqual(recommendation.bid, .twelve)
    }

    func testSixCardKingQueenTrumpWithoutAcesDoesNotOverbidNine() {
        let recommendation = automatedRecommendation(
            for: hand("9♥ 6♦ 6♠ K♠ 4♥ 10♠ 7♦ K♦ 7♥ Q♥ 3♥ Q♦ K♥")
        )

        XCTAssertEqual(recommendation.preferredTarneebSuit, .hearts)
        XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 8)
        XCTAssertNotEqual(recommendation.bid, .nine)
    }

    func testBidRecommendationDiagnosticsExposeExpectedTricksAndSafeBidCeilings() throws {
        let cards = hand("K♣ Q♣ 9♣ 4♣ J♥ 5♠ 10♥ 10♦ 8♠ A♥ A♦ A♠ 8♥")
        let recommendation = automatedRecommendation(for: cards)
        let diagnostics = try XCTUnwrap(recommendation.diagnostics)
        let heartsEvaluation = try XCTUnwrap(diagnostics.suitEvaluations.first { $0.suit == .hearts })

        XCTAssertEqual(diagnostics.suitEvaluations.count, Suit.allCases.count)
        XCTAssertEqual(diagnostics.selectedSuit, .hearts)
        XCTAssertEqual(diagnostics.finalBid, recommendation.bid)
        XCTAssertGreaterThan(heartsEvaluation.expectedTricks, heartsEvaluation.safeBidCeiling)
        XCTAssertLessThanOrEqual(heartsEvaluation.safeBid.numericValue ?? 0, 8)
        XCTAssertTrue(heartsEvaluation.riskSummary.contains("trumpLength=4"))
    }

    func testGeneralizedSafeCeilingCoversRecentTooAggressiveRegressionHands() throws {
        let fixtures: [(rawHand: String, preferredSuit: Suit, maximumBid: Int)] = [
            ("K♣ Q♣ 9♣ 4♣ J♥ 5♠ 10♥ 10♦ 8♠ A♥ A♦ A♠ 8♥", .hearts, 8),
            ("6♣ A♣ 8♠ K♥ Q♣ 8♣ 10♣ A♠ J♣ 4♦ 7♦ 3♥ 3♣", .clubs, 11),
            ("A♦ A♥ Q♣ 4♠ A♠ 4♦ 2♥ 6♥ K♦ 9♥ Q♥ 7♦ 10♥", .hearts, 10),
            ("K♠ 4♣ K♦ K♣ Q♣ 10♣ 10♠ 7♣ 8♠ J♠ 3♦ A♣ 2♥", .clubs, 10),
            ("Q♣ K♦ 9♠ A♠ 5♦ 10♥ 8♦ Q♠ 2♣ 3♦ J♠ A♣ K♠", .spades, 10),
            ("7♦ K♣ 10♥ 9♣ 7♣ Q♣ 8♣ 10♠ 5♣ J♣ A♣ 4♠ 8♠", .clubs, 12),
            ("8♠ A♣ A♦ K♦ K♣ 10♦ A♠ 5♠ J♠ 6♥ 5♣ K♥ Q♠", .spades, 10),
            ("Q♦ 9♠ 5♠ A♠ 6♠ 7♦ 7♥ 2♥ A♣ 4♠ 10♠ 4♣ 6♦", .spades, 8),
            ("A♦ A♠ 8♦ 9♣ Q♠ J♦ 4♦ Q♥ 10♦ K♥ 7♦ 7♠ A♥", .diamonds, 9),
            ("Q♠ K♣ 10♥ 8♦ 4♠ K♥ 4♣ 7♣ J♣ 5♠ K♠ A♠ 7♠", .spades, 9),
            ("6♦ A♠ Q♥ Q♠ 10♠ 9♥ 8♠ 7♠ 5♠ J♣ K♠ 3♦ 4♦", .spades, 10),
            ("10♥ 3♥ 4♠ K♥ J♣ Q♥ Q♦ 5♥ 5♦ A♣ 10♣ A♥ Q♣", .hearts, 10),
            ("5♦ A♠ 8♣ 6♦ A♦ 7♦ J♥ 4♦ 7♠ 4♥ 2♦ 10♣ 3♦", .diamonds, 8),
            ("A♦ 2♦ 4♦ A♣ 2♥ 8♦ 7♦ 6♦ 7♥ 8♠ J♦ 4♠ 4♥", .diamonds, 8),
            ("4♣ Q♥ A♦ 7♣ K♥ K♠ Q♦ 10♦ J♠ A♥ K♦ 6♣ 10♠", .diamonds, 8)
        ]

        for fixture in fixtures {
            let recommendation = automatedRecommendation(for: hand(fixture.rawHand))
            let diagnostics = try XCTUnwrap(recommendation.diagnostics)
            let selectedEvaluation = try XCTUnwrap(diagnostics.selectedEvaluation)

            XCTAssertEqual(diagnostics.selectedSuit, fixture.preferredSuit, fixture.rawHand)
            if recommendation.bid != .pass {
                XCTAssertEqual(recommendation.preferredTarneebSuit, fixture.preferredSuit, fixture.rawHand)
            }
            XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, fixture.maximumBid, fixture.rawHand)
            XCTAssertLessThanOrEqual(selectedEvaluation.safeBid.numericValue ?? 0, fixture.maximumBid, fixture.rawHand)
            XCTAssertFalse(selectedEvaluation.riskSummary.isEmpty, fixture.rawHand)
        }
    }

    func testLatestSimulationSuspectsStayWithinGeneralizedConservativeCaps() throws {
        let fixtures: [(rawHand: String, targetSuit: Suit, maximumBid: Int, forbiddenBid: BidValue)] = [
            ("K♦ Q♥ Q♠ K♥ 4♥ 2♠ 7♥ A♦ Q♣ 8♠ J♣ A♥ 2♥", .hearts, 10, .eleven),
            ("3♠ 5♦ 5♠ 6♦ 8♠ K♠ Q♠ A♣ 4♠ 10♦ 9♥ 6♠ K♣", .spades, 8, .nine),
            ("8♣ J♣ A♣ A♥ 10♣ K♥ 4♠ 3♦ 10♠ 4♦ 7♦ J♥ Q♥", .hearts, 8, .nine),
            ("A♥ K♣ 6♣ Q♦ 9♦ 7♥ 3♥ K♥ 5♠ A♦ 2♦ 4♥ 9♥", .hearts, 9, .ten),
            ("3♠ 5♦ 10♥ 10♠ 7♦ A♥ 5♥ A♠ 3♥ 2♥ K♥ 9♦ 10♦", .hearts, 9, .ten),
            ("8♥ A♦ A♥ 4♦ 8♣ 2♦ 2♥ 3♥ K♥ J♠ A♠ 8♦ 10♠", .hearts, 9, .ten),
            ("10♥ 9♥ 7♥ A♣ 8♠ Q♠ 8♣ 2♣ A♥ A♠ Q♣ 6♣ Q♥", .hearts, 9, .ten),
            ("Q♣ 4♦ Q♥ A♣ A♦ A♠ 10♦ 7♣ K♦ 9♥ 7♥ 9♦ 3♥", .diamonds, 9, .ten),
            ("K♣ 3♠ 9♣ J♦ 5♦ 6♠ 3♣ J♣ A♣ 8♥ A♠ A♥ 4♠", .clubs, 9, .ten),
            ("10♦ 7♠ A♦ Q♥ 3♦ 3♥ J♥ J♠ 2♦ 8♦ K♦ Q♣ 8♥", .diamonds, 8, .nine),
            ("5♣ 4♣ A♣ 8♦ Q♠ 6♣ 7♣ K♣ 3♠ J♥ 7♦ 7♥ 4♠", .clubs, 8, .nine),
            ("8♦ 7♥ 6♣ K♣ A♣ 2♥ J♦ 5♥ 10♣ 8♣ Q♠ 2♣ 5♠", .clubs, 8, .nine),
            ("6♣ 4♥ 3♣ 2♥ 8♥ A♠ K♥ Q♥ A♥ 5♥ 4♦ 10♣ K♣", .hearts, 11, .twelve),
            ("A♠ K♥ 8♣ 7♠ Q♥ A♥ 4♠ 7♥ 4♣ 7♣ 8♥ 2♥ 4♥", .hearts, 11, .twelve)
        ]

        for fixture in fixtures {
            let recommendation = automatedRecommendation(for: hand(fixture.rawHand))
            let diagnostics = try XCTUnwrap(recommendation.diagnostics)
            let targetEvaluation = try XCTUnwrap(diagnostics.suitEvaluations.first { $0.suit == fixture.targetSuit })

            XCTAssertLessThanOrEqual(targetEvaluation.safeBid.numericValue ?? 0, fixture.maximumBid, fixture.rawHand)
            XCTAssertNotEqual(targetEvaluation.safeBid, fixture.forbiddenBid, fixture.rawHand)
            XCTAssertFalse(targetEvaluation.riskSummary.isEmpty, fixture.rawHand)
            if diagnostics.selectedSuit == fixture.targetSuit {
                XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, fixture.maximumBid, fixture.rawHand)
            }
        }
    }

    func testSixCardAceKingTrumpWithoutReliableOutsideWinnersDoesNotReachNine() throws {
        let fixtures: [(rawHand: String, preferredSuit: Suit)] = [
            ("10♦ 7♠ A♦ Q♥ 3♦ 3♥ J♥ J♠ 2♦ 8♦ K♦ Q♣ 8♥", .diamonds),
            ("5♣ 4♣ A♣ 8♦ Q♠ 6♣ 7♣ K♣ 3♠ J♥ 7♦ 7♥ 4♠", .clubs),
            ("8♦ 7♥ 6♣ K♣ A♣ 2♥ J♦ 5♥ 10♣ 8♣ Q♠ 2♣ 5♠", .clubs)
        ]

        for fixture in fixtures {
            let recommendation = automatedRecommendation(for: hand(fixture.rawHand))
            let diagnostics = try XCTUnwrap(recommendation.diagnostics)
            let selectedEvaluation = try XCTUnwrap(diagnostics.selectedEvaluation)

            XCTAssertEqual(diagnostics.selectedSuit, fixture.preferredSuit, fixture.rawHand)
            XCTAssertEqual(selectedEvaluation.reliableOutsideWinnerCount, 0, fixture.rawHand)
            XCTAssertLessThanOrEqual(selectedEvaluation.safeBid.numericValue ?? 0, 8, fixture.rawHand)
            XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 8, fixture.rawHand)
        }
    }

    func testSixCardKingQueenMissingAceWithLimitedOutsideAcesDoesNotReachNine() throws {
        let fixtures: [(rawHand: String, targetSuit: Suit)] = [
            ("A♣ K♥ 10♣ 5♥ Q♠ 3♦ 2♥ 6♠ 7♠ 10♥ Q♥ J♥ K♠", .hearts),
            ("9♦ J♦ 3♥ 3♦ 2♣ J♠ A♠ J♥ 5♦ K♠ Q♦ Q♠ K♦", .diamonds),
            ("Q♣ 5♥ A♠ K♠ 3♣ Q♦ 8♦ J♣ 7♠ K♣ 2♦ 10♣ 7♣", .clubs),
            ("A♣ 7♦ 3♣ 10♠ 4♠ 9♠ K♠ 3♠ K♣ Q♣ 9♣ Q♠ K♦", .spades),
            ("Q♦ K♦ J♦ 5♣ 5♥ 2♥ 8♦ K♠ 10♦ K♣ Q♥ A♥ 3♦", .diamonds),
            ("3♥ A♦ 9♦ J♠ K♦ 7♥ 6♦ 9♣ Q♥ 8♣ J♥ K♥ 10♥", .hearts)
        ]

        for fixture in fixtures {
            let recommendation = automatedRecommendation(for: hand(fixture.rawHand))
            let diagnostics = try XCTUnwrap(recommendation.diagnostics)
            let targetEvaluation = try XCTUnwrap(diagnostics.suitEvaluations.first { $0.suit == fixture.targetSuit })

            XCTAssertEqual(targetEvaluation.trumpLength, 6, fixture.rawHand)
            XCTAssertEqual(targetEvaluation.topTrumpControlCount, 2, fixture.rawHand)
            XCTAssertLessThanOrEqual(targetEvaluation.safeBid.numericValue ?? 0, 8, fixture.rawHand)
            if diagnostics.selectedSuit == fixture.targetSuit {
                XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 8, fixture.rawHand)
            }
        }
    }

    func testSevenCardNearCommandingTrumpDoesNotReachThirteen() throws {
        let rawHand = "A♣ A♥ K♦ 4♦ J♦ 4♣ Q♦ 7♦ 8♠ 8♥ Q♥ A♦ 10♦"
        let recommendation = automatedRecommendation(for: hand(rawHand))
        let diamondsEvaluation = try XCTUnwrap(recommendation.diagnostics?.suitEvaluations.first { $0.suit == .diamonds })

        XCTAssertEqual(diamondsEvaluation.trumpLength, 7)
        XCTAssertLessThanOrEqual(diamondsEvaluation.safeBid.numericValue ?? 0, 12)
        XCTAssertNotEqual(diamondsEvaluation.safeBid, .thirteen)
        if recommendation.diagnostics?.selectedSuit == .diamonds {
            XCTAssertLessThanOrEqual(recommendation.bid.numericValue ?? 0, 12)
            XCTAssertNotEqual(recommendation.bid, .thirteen)
        }
    }

    func testFiveCardTrumpTenGateBlocksMarginalPartnerRaise() {
        let recommendation = automatedRecommendation(
            for: hand("10♥ 9♥ 7♥ A♣ 8♠ Q♠ 8♣ 2♣ A♥ A♠ Q♣ 6♣ Q♥"),
            seat: .south,
            partnerSeat: .north,
            currentHighestBidValue: .eight,
            currentHighestBidder: .north
        )

        XCTAssertEqual(recommendation.bid, .pass)
        XCTAssertNil(recommendation.preferredTarneebSuit)
    }

    func testSideKingsAndQueensAreConditionalSupportInDiagnostics() throws {
        let recommendation = automatedRecommendation(
            for: hand("Q♣ K♦ 9♠ A♠ 5♦ 10♥ 8♦ Q♠ 2♣ 3♦ J♠ A♣ K♠")
        )
        let selectedEvaluation = try XCTUnwrap(recommendation.diagnostics?.selectedEvaluation)

        XCTAssertEqual(selectedEvaluation.suit, .spades)
        XCTAssertGreaterThan(selectedEvaluation.conditionalSideHonorCount, selectedEvaluation.reliableOutsideWinnerCount)
        XCTAssertLessThanOrEqual(selectedEvaluation.safeBid.numericValue ?? 0, 10)
    }

    func testShortSuitValueRequiresTrumpControlInDiagnostics() throws {
        let diagnostics = AutomatedBidRecommender.diagnostics(
            for: hand("A♥ 7♥ 6♥ 5♥ 4♥ 2♠ 3♠ 4♠ 5♠ 6♣ 7♣ 8♣ 9♣")
        )
        let heartsEvaluation = try XCTUnwrap(diagnostics.suitEvaluations.first { $0.suit == .hearts })

        XCTAssertFalse(heartsEvaluation.shortSuitValueAllowed)
        XCTAssertLessThan(heartsEvaluation.safeBidCeiling, heartsEvaluation.expectedTricks + 0.001)
    }

    func testBiddingSimulationReportSummarizesDistributionAndDiagnostics() {
        let dealHands: [Seat: [Card]] = [
            .south: hand("A♥ K♥ Q♥ J♥ 10♥ 9♥ 8♥ A♣ A♦ K♠ 2♣ 3♦ 4♠"),
            .east: hand("K♣ Q♣ 9♣ 4♣ J♥ 5♠ 10♥ 10♦ 8♠ A♥ A♦ A♠ 8♥"),
            .north: hand("Q♦ 9♠ 5♠ A♠ 6♠ 7♦ 7♥ 2♥ A♣ 4♠ 10♠ 4♣ 6♦"),
            .west: hand("9♥ 6♦ 6♠ K♠ 4♥ 10♠ 7♦ K♦ 7♥ Q♥ 3♥ Q♦ K♥")
        ]
        let report = BiddingSimulationReporter().report(for: [dealHands], initialDealer: .south)
        let distributionTotal = report.bidDistribution.values.reduce(0, +)

        XCTAssertFalse(report.samples.isEmpty)
        XCTAssertEqual(distributionTotal, report.samples.count)
        XCTAssertGreaterThanOrEqual(report.passRate, 0)
        XCTAssertLessThanOrEqual(report.passRate, 1)
        XCTAssertTrue(report.samples.allSatisfy { $0.recommendation.diagnostics != nil })
        XCTAssertTrue(report.highBidSamples.allSatisfy { ($0.recommendation.bid.numericValue ?? 0) >= 10 })
    }

    func testAutomatedBidRecommenderPassesWhenPartnerIsHighestUnlessMaterialRaise() {
        let hand = [
            Card(suit: .hearts, rank: .ace),
            Card(suit: .hearts, rank: .king),
            Card(suit: .clubs, rank: .two),
            Card(suit: .clubs, rank: .three),
            Card(suit: .clubs, rank: .four),
            Card(suit: .diamonds, rank: .two),
            Card(suit: .diamonds, rank: .three),
            Card(suit: .diamonds, rank: .four),
            Card(suit: .spades, rank: .two),
            Card(suit: .spades, rank: .three),
            Card(suit: .spades, rank: .four),
            Card(suit: .spades, rank: .five),
            Card(suit: .spades, rank: .six)
        ]
        let context = BidRecommendationContext(
            seat: .east,
            hand: hand,
            partnerSeat: .west,
            currentHighestBidValue: .seven,
            currentHighestBidder: .west,
            priorBidStates: Dictionary(uniqueKeysWithValues: Seat.allCases.map { ($0, .pending) })
        )

        XCTAssertEqual(AutomatedBidRecommender().recommendation(for: context).bid, .pass)
    }

    func testAutomatedBidRecommenderRejectsPartnerRaiseWithoutStrongTrumpControl() {
        let hand = [
            Card(suit: .spades, rank: .king),
            Card(suit: .spades, rank: .jack),
            Card(suit: .spades, rank: .ten),
            Card(suit: .spades, rank: .nine),
            Card(suit: .spades, rank: .eight),
            Card(suit: .spades, rank: .seven),
            Card(suit: .spades, rank: .six),
            Card(suit: .hearts, rank: .ace),
            Card(suit: .clubs, rank: .ace),
            Card(suit: .diamonds, rank: .ace),
            Card(suit: .hearts, rank: .king),
            Card(suit: .clubs, rank: .king),
            Card(suit: .diamonds, rank: .two)
        ]
        let context = BidRecommendationContext(
            seat: .east,
            hand: hand,
            partnerSeat: .west,
            currentHighestBidValue: .seven,
            currentHighestBidder: .west,
            priorBidStates: Dictionary(uniqueKeysWithValues: Seat.allCases.map { ($0, .pending) })
        )

        let recommendation = AutomatedBidRecommender().recommendation(for: context)

        XCTAssertEqual(recommendation.bid, .pass)
        XCTAssertNil(recommendation.preferredTarneebSuit)
    }

    func testAutomatedBidRecommenderRaisesPartnerWithStrongTrumpControl() {
        let hand = [
            Card(suit: .hearts, rank: .ace),
            Card(suit: .hearts, rank: .king),
            Card(suit: .hearts, rank: .queen),
            Card(suit: .hearts, rank: .jack),
            Card(suit: .hearts, rank: .ten),
            Card(suit: .hearts, rank: .nine),
            Card(suit: .clubs, rank: .ace),
            Card(suit: .diamonds, rank: .ace),
            Card(suit: .spades, rank: .king),
            Card(suit: .clubs, rank: .two),
            Card(suit: .diamonds, rank: .three),
            Card(suit: .spades, rank: .four),
            Card(suit: .clubs, rank: .five)
        ]
        let context = BidRecommendationContext(
            seat: .east,
            hand: hand,
            partnerSeat: .west,
            currentHighestBidValue: .seven,
            currentHighestBidder: .west,
            priorBidStates: Dictionary(uniqueKeysWithValues: Seat.allCases.map { ($0, .pending) })
        )

        let recommendation = AutomatedBidRecommender().recommendation(for: context)

        XCTAssertNotEqual(recommendation.bid, .pass)
        XCTAssertGreaterThanOrEqual(recommendation.bid.numericValue ?? 0, 9)
        XCTAssertEqual(recommendation.preferredTarneebSuit, .hearts)
    }

    func testPostBiddingSummaryUsesHighBidderTeamBidAndPreferredSuit() throws {
        let state = try makeCompletedDeal(dealerSeat: .west)
        let service = BiddingService(bidGenerator: BidGenerator { _ in .pass })
        let afterSouthBid = service.submitSouthBid(.twelve, selectedTarneebSuit: .clubs, in: state)
        let afterEastPass = service.resolveNextSimulatedBid(in: afterSouthBid)
        let afterNorthPass = service.resolveNextSimulatedBid(in: afterEastPass)
        let completedState = service.resolveNextSimulatedBid(in: afterNorthPass)
        let summary = try XCTUnwrap(completedState.postBiddingSummary)

        XCTAssertEqual(summary.teamLabel, "North-South")
        XCTAssertEqual(summary.bidValue, .twelve)
        XCTAssertEqual(summary.highBidderSeat, .south)
        XCTAssertEqual(summary.tarneebSuit, .clubs)
        XCTAssertEqual(summary.tarneebSymbol, "♣")
    }

    func testPostBiddingSummaryUsesEastWestForEastOrWestHighBidder() throws {
        let state = try makeCompletedDeal(dealerSeat: .south)
        let service = BiddingService(bidGenerator: BidGenerator { _ in .thirteen })
        let completedState = service.resolveNextSimulatedBid(in: state)
        let summary = try XCTUnwrap(completedState.postBiddingSummary)

        XCTAssertEqual(summary.teamLabel, "East-West")
        XCTAssertEqual(summary.bidValue, .thirteen)
        XCTAssertEqual(summary.highBidderSeat, .east)
    }

    func testAllPassBiddingDoesNotShowHighBidSummary() throws {
        let state = try makeCompletedDeal(dealerSeat: .south)
        let service = BiddingService(bidGenerator: BidGenerator { _ in .pass })
        let advancedState = service.advanceSimulatedTurns(in: state)
        let completedState = service.submitSouthBid(.pass, in: advancedState)

        XCTAssertEqual(completedState.biddingStatus, .complete)
        XCTAssertEqual(completedState.biddingCompletionOutcome, .allPassRedeal)
        XCTAssertNil(completedState.postBiddingSummary)
    }

    func testSouthHandPresentationSortsBySuitThenRankWithoutChangingOwnership() {
        let unsortedHand = [
            Card(suit: .spades, rank: .ace),
            Card(suit: .diamonds, rank: .two),
            Card(suit: .hearts, rank: .ace),
            Card(suit: .clubs, rank: .king),
            Card(suit: .hearts, rank: .two),
            Card(suit: .spades, rank: .two),
            Card(suit: .diamonds, rank: .ace),
            Card(suit: .clubs, rank: .two)
        ]

        let presentations = SouthHandPresentation.cardPresentations(from: unsortedHand)

        XCTAssertEqual(presentations.map(\.displayLabel), ["2♥", "A♥", "2♣", "K♣", "2♦", "A♦", "2♠", "A♠"])
        XCTAssertEqual(Set(presentations.map(\.cardID)), Set(unsortedHand.map(\.id)))
        XCTAssertEqual(unsortedHand.map(\.id), ["spades-A", "diamonds-2", "hearts-A", "clubs-K", "hearts-2", "spades-2", "diamonds-A", "clubs-2"])
    }

    func testSouthHandPresentationUsesReadableSuitSeparatedGridAfterReveal() {
        let hand = [
            Card(suit: .hearts, rank: .two),
            Card(suit: .hearts, rank: .ace),
            Card(suit: .clubs, rank: .two),
            Card(suit: .clubs, rank: .king),
            Card(suit: .diamonds, rank: .two),
            Card(suit: .diamonds, rank: .ace),
            Card(suit: .spades, rank: .two),
            Card(suit: .spades, rank: .ace)
        ]
        let cardPresentations = SouthHandPresentation.cardPresentations(from: hand)
        let layout = SouthHandPresentation.readableLayout(cardCount: cardPresentations.count)

        XCTAssertEqual(layout.cardSpacing, 4)
        XCTAssertEqual(layout.suitBoundarySpacing, 8)
        XCTAssertEqual(layout.additionalSuitBoundarySpacing, 4)
        XCTAssertEqual(layout.additionalLeadingSpacing(beforeCardAt: 0, in: cardPresentations), 0)
        XCTAssertEqual(layout.additionalLeadingSpacing(beforeCardAt: 1, in: cardPresentations), 0)
        XCTAssertEqual(layout.additionalLeadingSpacing(beforeCardAt: 2, in: cardPresentations), 4)
        XCTAssertEqual(layout.additionalLeadingSpacing(beforeCardAt: 3, in: cardPresentations), 0)
        XCTAssertEqual(layout.additionalLeadingSpacing(beforeCardAt: 4, in: cardPresentations), 4)
        XCTAssertEqual(layout.additionalLeadingSpacing(beforeCardAt: 6, in: cardPresentations), 4)
        XCTAssertTrue(layout.accessibilityValue.contains("layout=suitSeparatedGrid"))
        XCTAssertTrue(layout.accessibilityValue.contains("count=8"))
        XCTAssertTrue(layout.accessibilityValue.contains("suitBoundarySpacing=8"))
    }

    func testCardPresentationExposesTokenHooksWithoutConcreteColors() {
        let warmPresentation = CardPresentation(card: Card(suit: .hearts, rank: .ace))
        let neutralPresentation = CardPresentation(card: Card(suit: .spades, rank: .two))

        XCTAssertEqual(warmPresentation.cardID, "hearts-A")
        XCTAssertEqual(warmPresentation.displayLabel, "A♥")
        XCTAssertEqual(warmPresentation.faceAssetName, "card_face_AH")
        XCTAssertEqual(warmPresentation.rankText, "A")
        XCTAssertEqual(warmPresentation.suitSymbol, "♥")
        XCTAssertEqual(warmPresentation.suitColorRole, .suitWarm)
        XCTAssertEqual(warmPresentation.suitColorToken, .cardSuitRed)
        XCTAssertEqual(warmPresentation.accessibilityLabel, "A♥")
        XCTAssertEqual(warmPresentation.sizeCategory, .sharedBaseCard)
        XCTAssertTrue(warmPresentation.accessibilityValue.contains("asset=card_face_AH"))
        XCTAssertTrue(warmPresentation.accessibilityValue.contains("surface=color.card.background"))
        XCTAssertTrue(warmPresentation.accessibilityValue.contains("border=color.card.border"))
        XCTAssertTrue(warmPresentation.accessibilityValue.contains("shadow=color.card.shadow"))
        XCTAssertFalse(warmPresentation.accessibilityValue.contains("#"))

        XCTAssertEqual(neutralPresentation.faceAssetName, "card_face_2S")
        XCTAssertEqual(neutralPresentation.suitColorRole, .suitNeutral)
        XCTAssertEqual(neutralPresentation.suitColorToken, .cardSuitBlack)
        XCTAssertEqual(neutralPresentation.sizeCategory, .sharedBaseCard)
        XCTAssertTrue(neutralPresentation.accessibilityValue.contains("asset=card_face_2S"))
        XCTAssertFalse(neutralPresentation.accessibilityValue.contains("#"))
    }

    func testHiddenAndExposedPlayerCardsShareBaseSizeAndAspectRatio() {
        let sizeConfiguration = CardSizeConfiguration.sharedBase
        let exposedCard = CardPresentation(
            card: Card(suit: .hearts, rank: .two),
            sizeConfiguration: sizeConfiguration
        )
        let hiddenHand = HiddenHandPresentation(
            seat: .west,
            hiddenCardCount: 13,
            sizeConfiguration: sizeConfiguration
        )

        XCTAssertEqual(exposedCard.sizeConfiguration, sizeConfiguration)
        XCTAssertEqual(hiddenHand.sizeConfiguration, exposedCard.sizeConfiguration)
        XCTAssertTrue(hiddenHand.hiddenCards.allSatisfy { $0.sizeConfiguration == exposedCard.sizeConfiguration })
        XCTAssertEqual(sizeConfiguration.aspectRatio, 5.0 / 7.0, accuracy: 0.01)
        XCTAssertGreaterThan(sizeConfiguration.rankFontPointSize, 0)
    }

    func testHiddenHandPresentationRepresentsHiddenCardsWithoutCardIdentities() {
        let hiddenHand = HiddenHandPresentation(seat: .north, hiddenCardCount: 13)

        XCTAssertEqual(hiddenHand.seat, .north)
        XCTAssertEqual(hiddenHand.hiddenCardCount, 13)
        XCTAssertEqual(hiddenHand.hiddenCards.map(\.assetName), Array(repeating: "card_back", count: 13))
        XCTAssertEqual(hiddenHand.hiddenCards.map(\.accessibilityLabel), Array(repeating: "Card back", count: 13))
        XCTAssertTrue(hiddenHand.hiddenCards.allSatisfy { $0.accessibilityValue == CardSizeCategory.sharedBaseCard.rawValue })
        XCTAssertGreaterThan(hiddenHand.stackOffset, 0)
        XCTAssertLessThan(hiddenHand.stackWidth, hiddenHand.sizeConfiguration.baseCardWidth * 13)
        XCTAssertEqual(hiddenHand.stackHeight, hiddenHand.sizeConfiguration.baseCardHeight + hiddenHand.sizeConfiguration.hiddenFanArcDepth)
        XCTAssertTrue(hiddenHand.accessibilityValue.contains("layout=stackedFan"))
        XCTAssertTrue(hiddenHand.accessibilityValue.contains("fanRotationStep=0.35"))
        XCTAssertTrue(hiddenHand.accessibilityValue.contains("fanArcDepth=2.5"))

        let firstCardTransform = hiddenHand.visualTransform(for: hiddenHand.hiddenCards[0])
        let centerCardTransform = hiddenHand.visualTransform(for: hiddenHand.hiddenCards[6])
        let lastCardTransform = hiddenHand.visualTransform(for: hiddenHand.hiddenCards[12])
        XCTAssertLessThan(firstCardTransform.rotationDegrees, 0)
        XCTAssertEqual(centerCardTransform.rotationDegrees, 0, accuracy: 0.01)
        XCTAssertGreaterThan(lastCardTransform.rotationDegrees, 0)
        XCTAssertGreaterThan(centerCardTransform.offsetY, firstCardTransform.offsetY)
        XCTAssertGreaterThan(centerCardTransform.offsetY, lastCardTransform.offsetY)

        for hiddenCard in hiddenHand.hiddenCards {
            XCTAssertFalse(hiddenCard.id.contains("spades"))
            XCTAssertFalse(hiddenCard.id.contains("clubs"))
            XCTAssertFalse(hiddenCard.id.contains("hearts"))
            XCTAssertFalse(hiddenCard.id.contains("diamonds"))
            XCTAssertFalse(hiddenCard.accessibilityValue.contains("rank"))
            XCTAssertFalse(hiddenCard.accessibilityValue.contains("suit"))
        }
    }

    func testUndealtDeckStackPresentationRepresents52HiddenCardsOnlyBeforeDeal() {
        let initialStack = UndealtDeckStackPresentation(phase: .notStarted)
        let dealtStack = UndealtDeckStackPresentation(phase: .dealt)
        let firstCardTransform = initialStack.visualTransform(for: initialStack.hiddenCards[0])
        let lastCardTransform = initialStack.visualTransform(for: initialStack.hiddenCards[51])

        XCTAssertTrue(initialStack.isVisible)
        XCTAssertEqual(initialStack.hiddenCardCount, 52)
        XCTAssertEqual(initialStack.hiddenCards.map(\.assetName), Array(repeating: "card_back", count: 52))
        XCTAssertEqual(initialStack.stackWidth, initialStack.sizeConfiguration.baseCardWidth)
        XCTAssertEqual(initialStack.stackHeight, initialStack.sizeConfiguration.baseCardHeight)
        XCTAssertEqual(initialStack.layout.placementLabel, "dealerStation")
        XCTAssertEqual(initialStack.layout.anchorLabel, "stationCenter")
        XCTAssertEqual(initialStack.layout.anchorXToken, .undealtDeckAnchorX)
        XCTAssertEqual(initialStack.layout.anchorYToken, .undealtDeckAnchorY)
        XCTAssertEqual(initialStack.layout.centerOffsetXToken, .undealtDeckCenterOffsetX)
        XCTAssertEqual(initialStack.layout.centerOffsetYToken, .undealtDeckCenterOffsetY)
        XCTAssertEqual(initialStack.layout.stackRotationToken, .undealtDeckStackRotation)
        XCTAssertEqual(initialStack.layout.stackOffsetXToken, .undealtDeckStackOffsetX)
        XCTAssertEqual(initialStack.layout.stackOffsetYToken, .undealtDeckStackOffsetY)
        XCTAssertEqual(initialStack.layout.edgeBufferToken, .undealtDeckEdgeBufferMinimum)
        XCTAssertEqual(initialStack.layout.anchorX, 0.5)
        XCTAssertEqual(initialStack.layout.anchorY, 0.5)
        XCTAssertEqual(initialStack.layout.centerOffsetX, 0)
        XCTAssertEqual(initialStack.layout.centerOffsetY, 0)
        XCTAssertEqual(initialStack.layout.offset(forTableDiameter: 200).x, 0)
        XCTAssertEqual(initialStack.layout.offset(forTableDiameter: 200).y, 0)
        XCTAssertEqual(initialStack.layout.stackRotation, 0)
        XCTAssertEqual(initialStack.layout.stackOffsetX, 0)
        XCTAssertEqual(initialStack.layout.stackOffsetY, 0)
        XCTAssertEqual(initialStack.layout.edgeBuffer, 12)
        XCTAssertFalse(initialStack.layout.titleOverlapAllowed)
        XCTAssertEqual(firstCardTransform.offsetX, 0)
        XCTAssertEqual(firstCardTransform.offsetY, 0)
        XCTAssertEqual(firstCardTransform.rotationDegrees, 0)
        XCTAssertEqual(lastCardTransform.offsetX, 0)
        XCTAssertEqual(lastCardTransform.offsetY, 0)
        XCTAssertEqual(lastCardTransform.rotationDegrees, 0)
        XCTAssertTrue(initialStack.accessibilityValue.contains("count=52"))
        XCTAssertTrue(initialStack.accessibilityValue.contains("asset=card_back"))
        XCTAssertTrue(initialStack.accessibilityValue.contains("layout=squaredStack"))
        XCTAssertTrue(initialStack.accessibilityValue.contains("source=dealerStation"))
        XCTAssertTrue(initialStack.accessibilityValue.contains("dealerSeat=south"))
        XCTAssertTrue(initialStack.accessibilityValue.contains("placement=dealerStation"))
        XCTAssertTrue(initialStack.accessibilityValue.contains("anchor=stationCenter"))
        XCTAssertTrue(initialStack.accessibilityValue.contains("anchorX=layout.undealtDeck.anchor.x"))
        XCTAssertTrue(initialStack.accessibilityValue.contains("anchorXValue=0.5"))
        XCTAssertTrue(initialStack.accessibilityValue.contains("anchorY=layout.undealtDeck.anchor.y"))
        XCTAssertTrue(initialStack.accessibilityValue.contains("anchorYValue=0.5"))
        XCTAssertTrue(initialStack.accessibilityValue.contains("centerOffsetX=layout.undealtDeck.centerOffset.x"))
        XCTAssertTrue(initialStack.accessibilityValue.contains("centerOffsetXValue=0.0"))
        XCTAssertTrue(initialStack.accessibilityValue.contains("centerOffsetY=layout.undealtDeck.centerOffset.y"))
        XCTAssertTrue(initialStack.accessibilityValue.contains("centerOffsetYValue=0.0"))
        XCTAssertTrue(initialStack.accessibilityValue.contains("stackRotation=layout.undealtDeck.stack.rotation"))
        XCTAssertTrue(initialStack.accessibilityValue.contains("stackRotationValue=0.0"))
        XCTAssertTrue(initialStack.accessibilityValue.contains("stackOffsetX=layout.undealtDeck.stack.offset.x"))
        XCTAssertTrue(initialStack.accessibilityValue.contains("stackOffsetXValue=0.0"))
        XCTAssertTrue(initialStack.accessibilityValue.contains("stackOffsetY=layout.undealtDeck.stack.offset.y"))
        XCTAssertTrue(initialStack.accessibilityValue.contains("stackOffsetYValue=0.0"))
        XCTAssertTrue(initialStack.accessibilityValue.contains("edgeBuffer=layout.undealtDeck.edgeBuffer.min"))
        XCTAssertTrue(initialStack.accessibilityValue.contains("edgeBufferValue=12.0"))
        XCTAssertTrue(initialStack.accessibilityValue.contains("titleOverlapAllowed=false"))
        XCTAssertFalse(initialStack.accessibilityValue.contains("rank"))
        XCTAssertFalse(initialStack.accessibilityValue.contains("suit"))

        XCTAssertFalse(dealtStack.isVisible)
        XCTAssertEqual(dealtStack.hiddenCardCount, 0)
    }

    func testCenteredDeckLayoutProvidesDealerStationSquaredStackAnchor() {
        let layout = CenteredDeckLayoutPresentation(sizeConfiguration: .sharedBase)

        XCTAssertEqual(layout.placementLabel, "dealerStation")
        XCTAssertEqual(layout.anchorLabel, "stationCenter")
        XCTAssertEqual(layout.anchorX, 0.5)
        XCTAssertEqual(layout.anchorY, 0.5)
        XCTAssertEqual(layout.centerOffsetX, 0)
        XCTAssertEqual(layout.centerOffsetY, 0)
        XCTAssertEqual(layout.stackRotation, 0)
        XCTAssertEqual(layout.stackOffsetX, 0)
        XCTAssertEqual(layout.stackOffsetY, 0)
        XCTAssertGreaterThan(layout.edgeBuffer, 0)
        XCTAssertEqual(layout.offset(forTableDiameter: 200).x, 0)
        XCTAssertEqual(layout.offset(forTableDiameter: 200).y, 0)
        XCTAssertFalse(layout.titleOverlapAllowed)
    }

    func testDealAnimationPresentationStartsAtDealerRightAndMovesCounterclockwiseInThirteenCardStacks() throws {
        let southDealerAnimation = DealAnimationPresentation(dealerSeat: .south)
        let westDealerAnimation = DealAnimationPresentation(dealerSeat: .west)
        let movingStack = try XCTUnwrap(southDealerAnimation.movingStackPresentation(forStep: 0))

        XCTAssertEqual(DealAnimationPresentation.cardsPerStack, 13)
        XCTAssertEqual(DealAnimationPresentation.totalCards, 52)
        XCTAssertEqual(southDealerAnimation.targetOrder, [.east, .north, .west, .south])
        XCTAssertEqual(westDealerAnimation.targetOrder, [.south, .east, .north, .west])
        XCTAssertEqual(southDealerAnimation.targetSeat(forStep: 0), .east)
        XCTAssertEqual(southDealerAnimation.targetSeat(forStep: 1), .north)
        XCTAssertEqual(southDealerAnimation.targetSeat(forStep: 2), .west)
        XCTAssertEqual(southDealerAnimation.targetSeat(forStep: 3), .south)
        XCTAssertNil(southDealerAnimation.targetSeat(forStep: 4))
        XCTAssertEqual(southDealerAnimation.deliveredSeats(afterCompletedSteps: 0), [])
        XCTAssertEqual(southDealerAnimation.deliveredSeats(afterCompletedSteps: 2), [.east, .north])
        XCTAssertEqual(southDealerAnimation.deliveredSeats(afterCompletedSteps: 99), [.east, .north, .west, .south])
        XCTAssertEqual(southDealerAnimation.centralCardCount(deliveredSeatCount: 0, movingStackVisible: false), 52)
        XCTAssertEqual(southDealerAnimation.centralCardCount(deliveredSeatCount: 0, movingStackVisible: true), 39)
        XCTAssertEqual(southDealerAnimation.centralCardCount(deliveredSeatCount: 1, movingStackVisible: true), 26)
        XCTAssertEqual(southDealerAnimation.centralCardCount(deliveredSeatCount: 3, movingStackVisible: true), 0)
        XCTAssertEqual(southDealerAnimation.centralCardCount(deliveredSeatCount: 4, movingStackVisible: false), 0)
        XCTAssertTrue(southDealerAnimation.accessibilityValue.contains("dealerSeat=south"))
        XCTAssertTrue(southDealerAnimation.accessibilityValue.contains("start=dealerRight"))
        XCTAssertTrue(southDealerAnimation.accessibilityValue.contains("direction=counterclockwise"))
        XCTAssertTrue(southDealerAnimation.accessibilityValue.contains("origin=dealerStation"))
        XCTAssertTrue(southDealerAnimation.accessibilityValue.contains("targetOrder=east,north,west,south"))
        XCTAssertTrue(southDealerAnimation.accessibilityValue.contains("flightDuration=animation.deal.stack.flight.duration"))
        XCTAssertTrue(southDealerAnimation.accessibilityValue.contains("southRevealTotalDuration=animation.deal.southReveal.total.duration"))
        XCTAssertTrue(southDealerAnimation.accessibilityValue.contains("southRevealFlipDuration=animation.deal.southReveal.flip.duration"))
        XCTAssertTrue(southDealerAnimation.accessibilityValue.contains("southRevealFlipStagger=animation.deal.southReveal.flip.stagger"))

        XCTAssertEqual(movingStack.targetSeat, .east)
        XCTAssertEqual(movingStack.sourceSeat, .south)
        XCTAssertEqual(movingStack.hiddenCardCount, 13)
        XCTAssertEqual(movingStack.hiddenCards.map(\.assetName), Array(repeating: "card_back", count: 13))
        XCTAssertEqual(movingStack.stackWidth, movingStack.sizeConfiguration.baseCardWidth)
        XCTAssertEqual(movingStack.stackHeight, movingStack.sizeConfiguration.baseCardHeight)
        XCTAssertTrue(movingStack.accessibilityValue.contains("count=13"))
        XCTAssertTrue(movingStack.accessibilityValue.contains("from=dealerStation"))
        XCTAssertTrue(movingStack.accessibilityValue.contains("origin=dealerStation"))
        XCTAssertTrue(movingStack.accessibilityValue.contains("source=south"))
        XCTAssertTrue(movingStack.accessibilityValue.contains("destination=playerStation"))
        XCTAssertTrue(movingStack.accessibilityValue.contains("renderLayer=tableSceneOverlay"))
        XCTAssertTrue(movingStack.accessibilityValue.contains("target=east"))
        XCTAssertTrue(movingStack.accessibilityValue.contains("targetOrder=east,north,west,south"))
        XCTAssertFalse(movingStack.accessibilityValue.contains("rank"))
        XCTAssertFalse(movingStack.accessibilityValue.contains("suit"))
    }

    func testDealAnimationPathStartsEveryStackAtDealerStationBeforeMovingToTargetStation() {
        let compactPath = DealAnimationPathPresentation(
            dealerSeat: .south,
            tableDiameter: 196,
            compactStationSide: 112,
            southStationHeight: 112,
            horizontalSpacing: 6,
            verticalSpacing: 10
        )
        let southRevealedPath = DealAnimationPathPresentation(
            dealerSeat: .south,
            tableDiameter: 196,
            compactStationSide: 112,
            southStationHeight: 142,
            horizontalSpacing: 6,
            verticalSpacing: 10
        )
        let westDealerPath = DealAnimationPathPresentation(
            dealerSeat: .west,
            tableDiameter: 196,
            compactStationSide: 112,
            southStationHeight: 112,
            horizontalSpacing: 6,
            verticalSpacing: 10
        )

        XCTAssertEqual(compactPath.tableCenterOffsetFromSceneCenter, DealAnimationOffset(x: 0, y: 0))
        XCTAssertEqual(compactPath.sourceDeckOffsetFromSceneCenter, DealAnimationOffset(x: 0, y: 164))
        XCTAssertEqual(southRevealedPath.tableCenterOffsetFromSceneCenter, DealAnimationOffset(x: 0, y: -15))
        XCTAssertEqual(southRevealedPath.sourceDeckOffsetFromSceneCenter, DealAnimationOffset(x: 0, y: 149))
        XCTAssertEqual(westDealerPath.sourceDeckOffsetFromSceneCenter, DealAnimationOffset(x: -160, y: 0))

        for seat in Seat.dealerRotationOrder {
            XCTAssertEqual(
                compactPath.offset(to: seat, stackAtTarget: false),
                compactPath.sourceDeckOffsetFromSceneCenter
            )
            XCTAssertEqual(
                southRevealedPath.offset(to: seat, stackAtTarget: false),
                southRevealedPath.sourceDeckOffsetFromSceneCenter
            )
            XCTAssertEqual(
                westDealerPath.offset(to: seat, stackAtTarget: false),
                westDealerPath.sourceDeckOffsetFromSceneCenter
            )
        }

        XCTAssertEqual(compactPath.offset(to: .east, stackAtTarget: true), DealAnimationOffset(x: 160, y: 0))
        XCTAssertEqual(compactPath.offset(to: .north, stackAtTarget: true), DealAnimationOffset(x: 0, y: -164))
        XCTAssertEqual(compactPath.offset(to: .west, stackAtTarget: true), DealAnimationOffset(x: -160, y: 0))
        XCTAssertEqual(compactPath.offset(to: .south, stackAtTarget: true), DealAnimationOffset(x: 0, y: 164))

        XCTAssertEqual(southRevealedPath.offset(to: .east, stackAtTarget: true), DealAnimationOffset(x: 160, y: -15))
        XCTAssertEqual(southRevealedPath.offset(to: .north, stackAtTarget: true), DealAnimationOffset(x: 0, y: -179))
        XCTAssertEqual(southRevealedPath.offset(to: .west, stackAtTarget: true), DealAnimationOffset(x: -160, y: -15))
        XCTAssertEqual(southRevealedPath.offset(to: .south, stackAtTarget: true), DealAnimationOffset(x: 0, y: 149))
    }

    func testDealerStationPresentationShowsPillBesideCurrentDealerBeforeBidding() {
        let dealerStation = DealerStationPresentation(seat: .north, phase: .notStarted, dealerSeat: .north)
        let otherStation = DealerStationPresentation(seat: .south, phase: .notStarted, dealerSeat: .north)
        let dealtStation = DealerStationPresentation(seat: .north, phase: .dealt, dealerSeat: .north)
        let activeStation = DealerStationPresentation(seat: .east, phase: .dealt, dealerSeat: .north, activeSeat: .east)
        let activeDealerStation = DealerStationPresentation(seat: .north, phase: .dealt, dealerSeat: .north, activeSeat: .north)
        let cuedStation = DealerStationPresentation(
            seat: .west,
            phase: .dealt,
            dealerSeat: .north,
            activeSeat: .east,
            bidCueSeat: .west,
            isBidCuePulsed: true
        )

        XCTAssertTrue(dealerStation.showsDealerPill)
        XCTAssertEqual(dealerStation.outlineColorRole, .stationOutline)
        XCTAssertEqual(dealerStation.outlineToken, .stationOutline)
        XCTAssertEqual(dealerStation.outlineLineWidth, 1)
        XCTAssertFalse(dealerStation.isActiveTurn)
        XCTAssertFalse(dealerStation.isBidMotionCueActive)
        XCTAssertEqual(dealerStation.stationBackgroundOpacityToken, .stationBackgroundDefaultOpacity)
        XCTAssertEqual(dealerStation.stationBackgroundOpacity, 0.08)
        XCTAssertEqual(dealerStation.stationScale, 1)
        XCTAssertEqual(dealerStation.stationShadowOpacity, 0)
        XCTAssertEqual(dealerStation.dealerPillBackgroundToken, .dealerBadgeBackground)
        XCTAssertEqual(dealerStation.dealerPillTextToken, .dealerBadgeText)
        XCTAssertTrue(dealerStation.accessibilityValue.contains("dealerIndicator=pill"))
        XCTAssertTrue(dealerStation.accessibilityValue.contains("dealerPillVisible=true"))
        XCTAssertTrue(dealerStation.accessibilityValue.contains("dealerPillPlacement=besideName"))
        XCTAssertTrue(dealerStation.accessibilityValue.contains("dealerPillText=D"))
        XCTAssertTrue(dealerStation.accessibilityValue.contains("dealerPillBackground=color.dealerBadge.background"))
        XCTAssertTrue(dealerStation.accessibilityValue.contains("dealerPillTextColor=color.dealerBadge.text"))
        XCTAssertTrue(dealerStation.accessibilityValue.contains("activeTurn=false"))
        XCTAssertTrue(dealerStation.accessibilityValue.contains("bidMotionCueActive=false"))
        XCTAssertTrue(dealerStation.accessibilityValue.contains("stationBackgroundOpacity=effect.station.background.default.opacity"))
        XCTAssertTrue(dealerStation.accessibilityValue.contains("outline=color.station.outline"))

        XCTAssertFalse(otherStation.showsDealerPill)
        XCTAssertEqual(otherStation.outlineColorRole, .stationOutline)
        XCTAssertEqual(otherStation.outlineToken, .stationOutline)

        XCTAssertFalse(dealtStation.showsDealerPill)
        XCTAssertEqual(dealtStation.outlineColorRole, .stationOutline)
        XCTAssertEqual(dealtStation.outlineToken, .stationOutline)

        XCTAssertFalse(activeStation.showsDealerPill)
        XCTAssertTrue(activeStation.isActiveTurn)
        XCTAssertEqual(activeStation.outlineColorRole, .stationOutlineActive)
        XCTAssertEqual(activeStation.outlineToken, .stationOutlineActive)
        XCTAssertEqual(activeStation.outlineLineWidth, 2)
        XCTAssertEqual(activeStation.stationBackgroundOpacityToken, .stationBackgroundActiveOpacity)
        XCTAssertEqual(activeStation.stationBackgroundOpacity, 0.24)
        XCTAssertTrue(activeStation.accessibilityValue.contains("activeTurn=true"))
        XCTAssertTrue(activeStation.accessibilityValue.contains("outline=color.station.outline.active"))

        XCTAssertFalse(activeDealerStation.showsDealerPill)
        XCTAssertTrue(activeDealerStation.isActiveTurn)
        XCTAssertEqual(activeDealerStation.outlineColorRole, .stationOutlineActive)
        XCTAssertEqual(activeDealerStation.outlineToken, .stationOutlineActive)
        XCTAssertTrue(activeDealerStation.accessibilityValue.contains("dealerPillVisible=false"))
        XCTAssertTrue(activeDealerStation.accessibilityValue.contains("outline=color.station.outline.active"))

        XCTAssertFalse(cuedStation.isActiveTurn)
        XCTAssertTrue(cuedStation.isBidMotionCueActive)
        XCTAssertTrue(cuedStation.isBidMotionCuePulsed)
        XCTAssertEqual(cuedStation.outlineColorRole, .stationOutlineActive)
        XCTAssertEqual(cuedStation.outlineLineWidth, 3)
        XCTAssertEqual(cuedStation.stationBackgroundOpacityToken, .bidStationCueBackgroundOpacity)
        XCTAssertEqual(cuedStation.stationBackgroundOpacity, 0.34)
        XCTAssertEqual(cuedStation.stationScale, 1.035)
        XCTAssertEqual(cuedStation.stationShadowOpacity, 0.34)
        XCTAssertEqual(cuedStation.stationShadowRadius, 7)
        XCTAssertTrue(cuedStation.accessibilityValue.contains("bidMotionCueActive=true"))
        XCTAssertTrue(cuedStation.accessibilityValue.contains("bidMotionCuePulsed=true"))
        XCTAssertTrue(cuedStation.accessibilityValue.contains("bidMotionCueSeat=west"))
        XCTAssertTrue(cuedStation.accessibilityValue.contains("outlineLineWidth=3.0"))
        XCTAssertTrue(cuedStation.accessibilityValue.contains("stationCuePulse=animation.bid.stationCue.pulse.duration"))
        XCTAssertTrue(cuedStation.accessibilityValue.contains("stationCuePulseSeconds=0.24"))
    }

    func testBidAreaPresentationMapsBiddingState() throws {
        let biddingState = BiddingState(
            bids: [
                .south: .pending,
                .east: .resolved(.seven),
                .north: .resolved(.pass),
                .west: .resolved(.ten)
            ],
            currentTurnSeat: .south,
            highestBidSeat: .west,
            highestBidValue: .ten,
            status: .inProgress
        )
        let presentation = try XCTUnwrap(BidAreaPresentation(
            phase: .dealt,
            biddingState: biddingState,
            southDraftBid: .eleven,
            southDraftTarneebSuit: .spades
        ))

        XCTAssertNil(BidAreaPresentation(phase: .notStarted, biddingState: biddingState))
        XCTAssertNil(BidAreaPresentation(phase: .dealt, biddingState: nil))
        XCTAssertEqual(presentation.label, "Bidding")
        XCTAssertEqual(presentation.entries.map(\.seat), Seat.dealOrder)
        XCTAssertEqual(presentation.entries.map(\.seatLabel), ["South", "East", "North", "West"])
        XCTAssertEqual(presentation.entries.map(\.valueLabel), ["--", "7", "Pass", "10"])
        XCTAssertEqual(presentation.entries.map(\.isSelectable), [true, false, false, false])
        XCTAssertEqual(presentation.entries.map(\.isActiveTurn), [true, false, false, false])
        XCTAssertEqual(presentation.entries.map(\.isCurrentHighestBid), [false, false, false, true])
        XCTAssertEqual(
            presentation.entries.map(\.valueColorToken),
            [.bidAreaPendingValueText, .bidAreaValueText, .bidAreaValueText, .bidAreaHighestValueText]
        )
        XCTAssertEqual(presentation.allowedValues, [.pass, .eleven, .twelve, .thirteen])
        XCTAssertEqual(presentation.allowedValuesLabel, "Pass,11,12,13")
        XCTAssertEqual(presentation.southSuitOptions, Suit.allCases)
        XCTAssertEqual(presentation.southSuitOptionsLabel, "spades,clubs,hearts,diamonds")
        XCTAssertEqual(presentation.southDraftBid, .eleven)
        XCTAssertNil(presentation.southDraftTarneebSuit)
        XCTAssertFalse(presentation.southSuitSelectorVisible)
        XCTAssertFalse(presentation.southSuitSelectorEnabled)
        XCTAssertEqual(presentation.status, .inProgress)
        XCTAssertNil(presentation.completionOutcome)
        XCTAssertEqual(presentation.presentationState, .visible)
        XCTAssertEqual(presentation.currentTurnSeat, .south)
        XCTAssertEqual(presentation.highestBidSeat, .west)
        XCTAssertEqual(presentation.highestBidValue, .ten)
        XCTAssertTrue(presentation.southBidButtonVisible)
        XCTAssertTrue(presentation.southBidButtonEnabled)
        XCTAssertEqual(presentation.areaTokens.background, .bidAreaBackground)
        XCTAssertEqual(presentation.selectorTokens.background, .bidSelectorBackground)
        XCTAssertEqual(presentation.suitSelectorTokens.background, .cardBackground)
        XCTAssertTrue(presentation.accessibilityValue.contains("label=Bidding"))
        XCTAssertTrue(presentation.accessibilityValue.contains("rows=south,east,north,west"))
        XCTAssertTrue(presentation.accessibilityValue.contains("values=south:--,east:7,north:Pass,west:10"))
        XCTAssertTrue(presentation.accessibilityValue.contains("valueTextRoles=south:color.bidArea.value.pending.text,east:color.bidArea.value.text,north:color.bidArea.value.text,west:color.bidArea.value.highest.text"))
        XCTAssertTrue(presentation.accessibilityValue.contains("allowed=Pass,11,12,13"))
        XCTAssertTrue(presentation.accessibilityValue.contains("southDraftBid=11"))
        XCTAssertTrue(presentation.accessibilityValue.contains("southSuitOptions=spades,clubs,hearts,diamonds"))
        XCTAssertTrue(presentation.accessibilityValue.contains("southDraftTarneebSuit=none"))
        XCTAssertTrue(presentation.accessibilityValue.contains("completionOutcome=none"))
        XCTAssertTrue(presentation.accessibilityValue.contains("currentTurn=south"))
        XCTAssertTrue(presentation.accessibilityValue.contains("highestSeat=west"))
        XCTAssertTrue(presentation.accessibilityValue.contains("highestBid=10"))
        XCTAssertTrue(presentation.accessibilityValue.contains("southTarneebSuitSelectorVisible=false"))
        XCTAssertTrue(presentation.accessibilityValue.contains("southTarneebSuitSelectorEnabled=false"))
        XCTAssertTrue(presentation.accessibilityValue.contains("southBidButtonVisible=true"))
        XCTAssertTrue(presentation.accessibilityValue.contains("southBidButtonEnabled=true"))
        XCTAssertTrue(presentation.accessibilityValue.contains("areaTokens=background=color.bidArea.background"))
        XCTAssertTrue(presentation.accessibilityValue.contains("selectorTokens=background=color.bidSelector.background"))
        XCTAssertTrue(presentation.accessibilityValue.contains("suitSelectorTokens=background=color.card.background"))
        XCTAssertTrue(presentation.accessibilityValue.contains("selectedBackground=color.card.background"))
        XCTAssertTrue(presentation.accessibilityValue.contains("focusRing=color.button.newGame.background"))
        XCTAssertTrue(presentation.accessibilityValue.contains("bidButtonTokens=background=color.button.bid.background"))
        XCTAssertTrue(presentation.accessibilityValue.contains("simulatedBidDelay=animation.bid.simulatedTurn.delay"))
        XCTAssertTrue(presentation.accessibilityValue.contains("simulatedBidDelaySeconds=1.0"))
        XCTAssertTrue(presentation.accessibilityValue.contains("stationCuePulse=animation.bid.stationCue.pulse.duration"))
        XCTAssertTrue(presentation.accessibilityValue.contains("stationCuePulseSeconds=0.24"))
        XCTAssertTrue(presentation.accessibilityValue.contains("fadeOut=animation.bid.value.fadeOut.duration"))
        XCTAssertTrue(presentation.accessibilityValue.contains("fadeTotalSeconds=1.0"))
        XCTAssertTrue(presentation.accessibilityValue.contains("areaFadeOut=animation.bid.area.fadeOut.duration"))
        XCTAssertTrue(presentation.accessibilityValue.contains("areaFadeOutSeconds=1.0"))
        XCTAssertFalse(presentation.accessibilityValue.contains("#"))
    }

    func testBidAreaPresentationKeepsSouthBidButtonVisibleDisabledUntilTerminalState() throws {
        let simulatedTurnState = BiddingState(
            bids: [
                .south: .pending,
                .east: .pending,
                .north: .pending,
                .west: .pending
            ],
            currentTurnSeat: .east,
            highestBidSeat: nil,
            highestBidValue: nil,
            status: .inProgress
        )
        let simulatedTurnPresentation = try XCTUnwrap(BidAreaPresentation(
            phase: .dealt,
            biddingState: simulatedTurnState
        ))

        XCTAssertEqual(simulatedTurnPresentation.entries.map(\.valueLabel), ["--", "--", "--", "--"])
        XCTAssertEqual(simulatedTurnPresentation.entries.map(\.isSelectable), [false, false, false, false])
        XCTAssertTrue(simulatedTurnPresentation.southBidButtonVisible)
        XCTAssertFalse(simulatedTurnPresentation.southBidButtonEnabled)
        XCTAssertFalse(simulatedTurnPresentation.southSuitSelectorVisible)
        XCTAssertFalse(simulatedTurnPresentation.southSuitSelectorEnabled)
        XCTAssertTrue(simulatedTurnPresentation.accessibilityValue.contains("southBidButtonVisible=true"))
        XCTAssertTrue(simulatedTurnPresentation.accessibilityValue.contains("southBidButtonEnabled=false"))

        let activeSouthTurnState = BiddingState(
            bids: [
                .south: .pending,
                .east: .pending,
                .north: .pending,
                .west: .pending
            ],
            currentTurnSeat: .south,
            highestBidSeat: nil,
            highestBidValue: nil,
            status: .inProgress
        )
        let activeSouthNumericWithoutSuitPresentation = try XCTUnwrap(BidAreaPresentation(
            phase: .dealt,
            biddingState: activeSouthTurnState,
            southDraftBid: .seven
        ))

        XCTAssertFalse(activeSouthNumericWithoutSuitPresentation.southSuitSelectorVisible)
        XCTAssertFalse(activeSouthNumericWithoutSuitPresentation.southSuitSelectorEnabled)
        XCTAssertNil(activeSouthNumericWithoutSuitPresentation.southDraftTarneebSuit)
        XCTAssertTrue(activeSouthNumericWithoutSuitPresentation.southBidButtonVisible)
        XCTAssertTrue(activeSouthNumericWithoutSuitPresentation.southBidButtonEnabled)
        XCTAssertTrue(activeSouthNumericWithoutSuitPresentation.accessibilityValue.contains("southDraftTarneebSuit=none"))
        XCTAssertTrue(activeSouthNumericWithoutSuitPresentation.accessibilityValue.contains("southTarneebSuitSelectorEnabled=false"))

        let activeSouthPassPresentation = try XCTUnwrap(BidAreaPresentation(
            phase: .dealt,
            biddingState: activeSouthTurnState,
            southDraftBid: .pass
        ))

        XCTAssertFalse(activeSouthPassPresentation.southSuitSelectorVisible)
        XCTAssertFalse(activeSouthPassPresentation.southSuitSelectorEnabled)
        XCTAssertTrue(activeSouthPassPresentation.southBidButtonEnabled)

        let passedSouthTurnState = BiddingState(
            bids: [
                .south: .resolved(.pass),
                .east: .resolved(.seven),
                .north: .pending,
                .west: .pending
            ],
            currentTurnSeat: .south,
            highestBidSeat: .east,
            highestBidValue: .seven,
            status: .inProgress
        )
        let passedSouthTurnPresentation = try XCTUnwrap(BidAreaPresentation(
            phase: .dealt,
            biddingState: passedSouthTurnState
        ))

        XCTAssertEqual(passedSouthTurnPresentation.entries.map(\.valueLabel), ["Pass", "7", "--", "--"])
        XCTAssertEqual(passedSouthTurnPresentation.entries.map(\.isSelectable), [false, false, false, false])
        XCTAssertTrue(passedSouthTurnPresentation.southBidButtonVisible)
        XCTAssertFalse(passedSouthTurnPresentation.southBidButtonEnabled)
        XCTAssertFalse(passedSouthTurnPresentation.southSuitSelectorVisible)
        XCTAssertTrue(passedSouthTurnPresentation.accessibilityValue.contains("currentTurn=south"))
        XCTAssertTrue(passedSouthTurnPresentation.accessibilityValue.contains("southBidButtonEnabled=false"))

        let terminalState = BiddingState(
            bids: [
                .south: .resolved(.pass),
                .east: .resolved(.thirteen),
                .north: .resolved(.pass),
                .west: .resolved(.pass)
            ],
            currentTurnSeat: nil,
            highestBidSeat: .east,
            highestBidValue: .thirteen,
            status: .complete
        )
        let terminalPresentation = try XCTUnwrap(BidAreaPresentation(
            phase: .dealt,
            biddingState: terminalState,
            presentationState: .fadingOut
        ))

        XCTAssertFalse(terminalPresentation.southBidButtonVisible)
        XCTAssertFalse(terminalPresentation.southBidButtonEnabled)
        XCTAssertEqual(terminalPresentation.status, .complete)
        XCTAssertEqual(terminalPresentation.completionOutcome, .numericHighBid)
        XCTAssertEqual(terminalPresentation.presentationState, .fadingOut)
        XCTAssertTrue(terminalPresentation.accessibilityValue.contains("status=complete"))
        XCTAssertTrue(terminalPresentation.accessibilityValue.contains("completionOutcome=numericHighBid"))
        XCTAssertTrue(terminalPresentation.accessibilityValue.contains("presentationState=fadingOut"))
        XCTAssertTrue(terminalPresentation.accessibilityValue.contains("southBidButtonVisible=false"))
    }

    func testPostBiddingSummaryPresentationMapsSummaryTokensAndValues() throws {
        let summary = PostBiddingSummary(
            highBidderSeat: .west,
            bidValue: .ten,
            tarneebSuit: .clubs
        )
        let presentation = try XCTUnwrap(PostBiddingSummaryPresentation(
            phase: .dealt,
            biddingStatus: .complete,
            summary: summary,
            isBiddingAreaFadingOut: false
        ))

        XCTAssertEqual(presentation.teamLabel, "East-West")
        XCTAssertEqual(presentation.highBidderLabel, "West")
        XCTAssertEqual(presentation.bidValueLabel, "10")
        XCTAssertEqual(presentation.tarneebLabel, "Tarneeb")
        XCTAssertEqual(presentation.tarneebSuit, .clubs)
        XCTAssertEqual(presentation.tarneebSymbol, "♣")
        XCTAssertEqual(presentation.tarneebSymbolColorToken, .cardSuitBlack)
        XCTAssertEqual(presentation.tarneebSymbolBackgroundColorToken, .cardBackground)
        XCTAssertEqual(presentation.tarneebSymbolBorderColorToken, .buttonNewGameBackground)
        XCTAssertEqual(presentation.tarneebSymbolChipTokens.background, .cardBackground)
        XCTAssertEqual(presentation.tarneebSymbolChipTokens.border, .cardBorder)
        XCTAssertEqual(presentation.tarneebSymbolChipTokens.focusRing, .buttonNewGameBackground)
        XCTAssertEqual(presentation.tokens.background, .postBiddingSummaryBackground)
        XCTAssertTrue(presentation.accessibilityValue.contains("display=tarneebOnlyRibbon"))
        XCTAssertTrue(presentation.accessibilityValue.contains("tarneebLabel=Tarneeb"))
        XCTAssertFalse(presentation.accessibilityValue.contains("highBidder=West"))
        XCTAssertFalse(presentation.accessibilityValue.contains("bid=10"))
        XCTAssertTrue(presentation.accessibilityValue.contains("tarneebSymbol=♣"))
        XCTAssertTrue(presentation.accessibilityValue.contains("tarneebSymbolColor=color.card.suit.black"))
        XCTAssertTrue(presentation.accessibilityValue.contains("tarneebSymbolBackground=color.card.background"))
        XCTAssertTrue(presentation.accessibilityValue.contains("tarneebSymbolBorder=color.button.newGame.background"))
        XCTAssertTrue(presentation.accessibilityValue.contains("tarneebSymbolChipTokens=background=color.card.background"))
        XCTAssertTrue(presentation.accessibilityValue.contains("focusRing=color.button.newGame.background"))
        XCTAssertTrue(presentation.accessibilityValue.contains("background=color.postBiddingSummary.background"))

        let warmSummary = PostBiddingSummary(
            highBidderSeat: .south,
            bidValue: .eleven,
            tarneebSuit: .hearts
        )
        let warmPresentation = try XCTUnwrap(PostBiddingSummaryPresentation(
            phase: .dealt,
            biddingStatus: .complete,
            summary: warmSummary,
            isBiddingAreaFadingOut: false
        ))

        XCTAssertEqual(warmPresentation.tarneebSymbol, "♥")
        XCTAssertEqual(warmPresentation.tarneebSymbolColorToken, .cardSuitRed)
        XCTAssertTrue(warmPresentation.accessibilityValue.contains("tarneebSymbolColor=color.card.suit.red"))
        XCTAssertNil(PostBiddingSummaryPresentation(phase: .notStarted, biddingStatus: nil, summary: summary, isBiddingAreaFadingOut: false))
        XCTAssertNil(PostBiddingSummaryPresentation(phase: .dealt, biddingStatus: .complete, summary: summary, isBiddingAreaFadingOut: true))
        XCTAssertNil(PostBiddingSummaryPresentation(phase: .dealt, biddingStatus: .complete, summary: nil, isBiddingAreaFadingOut: false))
    }

    func testSouthTarneebSelectionPresentationOnlyAppearsAfterSouthWinsWithoutSummary() throws {
        let presentation = try XCTUnwrap(SouthTarneebSelectionPresentation(
            phase: .dealt,
            biddingStatus: .complete,
            highestBidSeat: .south,
            highestBidValue: .ten,
            summary: nil,
            isBiddingAreaFadingOut: false,
            selectedSuit: .spades
        ))

        XCTAssertEqual(presentation.teamLabel, "North-South")
        XCTAssertEqual(presentation.highBidderLabel, "South")
        XCTAssertEqual(presentation.bidValueLabel, "10")
        XCTAssertEqual(presentation.tarneebLabel, "Tarneeb")
        XCTAssertEqual(presentation.selectedSuit, .spades)
        XCTAssertEqual(presentation.suitOptions, Suit.allCases)
        XCTAssertTrue(presentation.submitEnabled)
        XCTAssertEqual(presentation.suitOptionsLabel, "spades,clubs,hearts,diamonds")
        XCTAssertTrue(presentation.accessibilityValue.contains("visible=true"))
        XCTAssertTrue(presentation.accessibilityValue.contains("highBidder=South"))
        XCTAssertTrue(presentation.accessibilityValue.contains("bid=10"))
        XCTAssertTrue(presentation.accessibilityValue.contains("selected=spades"))
        XCTAssertTrue(presentation.accessibilityValue.contains("submitEnabled=true"))
        XCTAssertNil(SouthTarneebSelectionPresentation(phase: .notStarted, biddingStatus: .complete, highestBidSeat: .south, highestBidValue: .ten, summary: nil, isBiddingAreaFadingOut: false, selectedSuit: nil))
        XCTAssertNil(SouthTarneebSelectionPresentation(phase: .dealt, biddingStatus: .inProgress, highestBidSeat: .south, highestBidValue: .ten, summary: nil, isBiddingAreaFadingOut: false, selectedSuit: nil))
        XCTAssertNil(SouthTarneebSelectionPresentation(phase: .dealt, biddingStatus: .complete, highestBidSeat: .east, highestBidValue: .ten, summary: nil, isBiddingAreaFadingOut: false, selectedSuit: nil))
        XCTAssertNil(SouthTarneebSelectionPresentation(phase: .dealt, biddingStatus: .complete, highestBidSeat: .south, highestBidValue: .pass, summary: nil, isBiddingAreaFadingOut: false, selectedSuit: nil))
        XCTAssertNil(SouthTarneebSelectionPresentation(phase: .dealt, biddingStatus: .complete, highestBidSeat: .south, highestBidValue: .ten, summary: PostBiddingSummary(highBidderSeat: .south, bidValue: .ten, tarneebSuit: .spades), isBiddingAreaFadingOut: false, selectedSuit: nil))
        XCTAssertNil(SouthTarneebSelectionPresentation(phase: .dealt, biddingStatus: .complete, highestBidSeat: .south, highestBidValue: .ten, summary: nil, isBiddingAreaFadingOut: true, selectedSuit: nil))
    }

    func testTableLayoutPresentationExposesDiameterStationPlacementsAndDealerStationDeckAnchor() {
        let layout = TableLayoutPresentation(screenWidth: 390)

        XCTAssertEqual(layout.tableDiameter, 195)
        XCTAssertEqual(layout.stationPlacement(for: .north), .aboveTable)
        XCTAssertEqual(layout.stationPlacement(for: .west), .leftOfTable)
        XCTAssertEqual(layout.stationPlacement(for: .south), .belowTable)
        XCTAssertEqual(layout.stationPlacement(for: .east), .rightOfTable)
        XCTAssertEqual(layout.undealtDeckLayout().placementLabel, "dealerStation")
        XCTAssertEqual(layout.undealtDeckLayout().anchorLabel, "stationCenter")
        XCTAssertFalse(layout.undealtDeckLayout().titleOverlapAllowed)
    }

    func testCardBackAssetCatalogExposesExpectedCardBackImage() throws {
        let projectRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let imageSetURL = projectRoot
            .appendingPathComponent("Tarneeb")
            .appendingPathComponent("Assets.xcassets")
            .appendingPathComponent("card_back.imageset")
        let contentsURL = imageSetURL.appendingPathComponent("Contents.json")
        let imageURL = imageSetURL.appendingPathComponent("card_back.png")

        XCTAssertTrue(FileManager.default.fileExists(atPath: contentsURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: imageURL.path))

        let contents = try JSONDecoder().decode(
            AssetCatalogContents.self,
            from: Data(contentsOf: contentsURL)
        )

        XCTAssertTrue(contents.images.contains { image in
            image.filename == "card_back.png"
                && image.idiom == "universal"
                && image.scale == "1x"
        })
    }

    func testCardFaceAssetCatalogExposesXCardsFaceImages() throws {
        let projectRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let assetCatalogURL = projectRoot
            .appendingPathComponent("Tarneeb")
            .appendingPathComponent("Assets.xcassets")

        for card in DeckFactory.makeCanonicalDeck() {
            let presentation = CardPresentation(card: card)
            let imageSetURL = assetCatalogURL
                .appendingPathComponent("\(presentation.faceAssetName).imageset")
            let contentsURL = imageSetURL.appendingPathComponent("Contents.json")
            let assetCode = presentation.faceAssetName.replacingOccurrences(of: "card_face_", with: "")
            let scaleFilenames = ["1x", "2x", "3x"].map { scale in
                "\(assetCode)@\(scale).png"
            }

            XCTAssertTrue(FileManager.default.fileExists(atPath: contentsURL.path), presentation.faceAssetName)
            for filename in scaleFilenames {
                XCTAssertTrue(
                    FileManager.default.fileExists(atPath: imageSetURL.appendingPathComponent(filename).path),
                    "\(presentation.faceAssetName) \(filename)"
                )
            }

            let contents = try JSONDecoder().decode(
                AssetCatalogContents.self,
                from: Data(contentsOf: contentsURL)
            )

            for scale in ["1x", "2x", "3x"] {
                XCTAssertTrue(contents.images.contains { image in
                    image.filename == "\(assetCode)@\(scale).png"
                        && image.idiom == "universal"
                        && image.scale == scale
                }, "\(presentation.faceAssetName) \(scale)")
            }
        }

        let jokerImageSetURL = assetCatalogURL.appendingPathComponent("card_face_joker.imageset")
        XCTAssertFalse(FileManager.default.fileExists(atPath: jokerImageSetURL.path))
    }

    func testAppIconAssetCatalogUsesTarneebImage() throws {
        let projectRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let appIconSetURL = projectRoot
            .appendingPathComponent("Tarneeb")
            .appendingPathComponent("Assets.xcassets")
            .appendingPathComponent("AppIcon.appiconset")
        let contentsURL = appIconSetURL.appendingPathComponent("Contents.json")
        let marketingIconURL = appIconSetURL.appendingPathComponent("AppIcon-1024.png")
        let projectFile = projectRoot
            .appendingPathComponent("Tarneeb.xcodeproj")
            .appendingPathComponent("project.pbxproj")

        XCTAssertTrue(FileManager.default.fileExists(atPath: contentsURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: marketingIconURL.path))

        let contents = try JSONDecoder().decode(
            AssetCatalogContents.self,
            from: Data(contentsOf: contentsURL)
        )
        let source = try String(contentsOf: projectFile)

        XCTAssertEqual(contents.images.count, 18)
        XCTAssertTrue(contents.images.contains { image in
            image.filename == "AppIcon-1024.png"
                && image.idiom == "ios-marketing"
                && image.size == "1024x1024"
                && image.scale == "1x"
        })
        XCTAssertTrue(contents.images.contains { image in
            image.filename == "AppIcon-60@3x.png"
                && image.idiom == "iphone"
                && image.size == "60x60"
                && image.scale == "3x"
        })
        XCTAssertTrue(contents.images.contains { image in
            image.filename == "AppIcon-83.5-ipad@2x.png"
                && image.idiom == "ipad"
                && image.size == "83.5x83.5"
                && image.scale == "2x"
        })
        XCTAssertTrue(source.contains("ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;"))
    }

    func testPresentationInitialStateHasDeckStackTitleDealActionAndNoVisibleCards() {
        let presentation = TarneebPresentationState(
            dealService: QueuedDealService(),
            dealerSelector: QueuedDealerSelector(seats: [.west])
        )
        let undealtDeckStack = UndealtDeckStackPresentation(
            phase: presentation.gameState.phase,
            dealerSeat: presentation.gameState.dealerSeat
        )
        let dealerStation = DealerStationPresentation(
            seat: presentation.gameState.dealerSeat,
            phase: presentation.gameState.phase,
            dealerSeat: presentation.gameState.dealerSeat
        )
        let tableTitle = TableTitlePresentation()

        XCTAssertEqual(presentation.gameState.phase, .notStarted)
        XCTAssertEqual(presentation.gameState.dealerSeat, .west)
        XCTAssertEqual(presentation.gameState.players.count, 4)
        XCTAssertEqual(Set(presentation.gameState.players.map(\.seat)), Set(Seat.allCases))
        XCTAssertEqual(presentation.gameState.players.flatMap(\.hand).count, 0)
        XCTAssertTrue(presentation.gameState.bids.isEmpty)
        XCTAssertEqual(undealtDeckStack.hiddenCardCount, 52)
        XCTAssertEqual(undealtDeckStack.dealerSeat, .west)
        XCTAssertEqual(undealtDeckStack.layout.placementLabel, "dealerStation")
        XCTAssertFalse(undealtDeckStack.layout.titleOverlapAllowed)
        XCTAssertTrue(dealerStation.showsDealerPill)
        XCTAssertEqual(dealerStation.outlineToken, .stationOutline)
        XCTAssertEqual(tableTitle.text, "طرنيب")
        XCTAssertNil(BidAreaPresentation(phase: presentation.gameState.phase, biddingState: presentation.gameState.biddingState))
        XCTAssertEqual(presentation.availableActions, [.newGame, .deal])
        XCTAssertEqual(PresentationAction.newGame.visibleLabel, "New Game")
        XCTAssertEqual(PresentationAction.deal.visibleLabel, "Deal")
    }

    func testDealActionMovesPresentationStateToDealtAndHidesCentralStack() throws {
        let service = QueuedDealService(results: [try makeCompletedDeal(dealerSeat: .north)])
        let presentation = TarneebPresentationState(
            dealService: service,
            dealerSelector: QueuedDealerSelector(seats: [.north])
        )

        presentation.deal()

        XCTAssertEqual(service.callCount, 1)
        XCTAssertEqual(service.receivedDealerSeats, [.north])
        XCTAssertEqual(presentation.gameState.phase, .dealt)
        XCTAssertEqual(presentation.gameState.dealerSeat, .north)
        XCTAssertEqual(presentation.gameState.players.map(\.hand.count), [13, 13, 13, 13])
        XCTAssertEqual(presentation.gameState.players.flatMap(\.hand).count, 52)
        XCTAssertEqual(Set(presentation.gameState.players.flatMap(\.hand).map(\.id)).count, 52)
        XCTAssertEqual(presentation.gameState.deck, [])
        XCTAssertEqual(Set(presentation.gameState.bids.keys), Set(Seat.allCases))
        XCTAssertNotNil(BidAreaPresentation(phase: presentation.gameState.phase, biddingState: presentation.gameState.biddingState))
        XCTAssertEqual(presentation.availableActions, [.newGame, .deal])
        XCTAssertEqual(UndealtDeckStackPresentation(phase: presentation.gameState.phase).hiddenCardCount, 0)
    }

    func testRepeatedDealTapDoesNotStartOverlappingDeals() throws {
        let service = ReentrantDealService(result: try makeCompletedDeal(dealerSeat: .south))
        let presentation = TarneebPresentationState(
            dealService: service,
            dealerSelector: QueuedDealerSelector(seats: [.south])
        )
        service.onDeal = {
            presentation.deal()
        }

        presentation.deal()

        XCTAssertEqual(service.callCount, 1)
        XCTAssertEqual(presentation.gameState.phase, .dealt)
        XCTAssertEqual(Set(presentation.gameState.players.flatMap(\.hand).map(\.id)).count, 52)
    }

    func testVisibleDealActionReplacesCompletedDeal() throws {
        let firstDeal = try makeCompletedDeal(dealerSeat: .south)
        let secondDeal = try makeCompletedDeal(shuffler: CardShuffler { Array($0.reversed()) }, dealerSeat: .east)
        let service = QueuedDealService(results: [firstDeal, secondDeal])
        let presentation = TarneebPresentationState(
            dealService: service,
            dealerSelector: QueuedDealerSelector(seats: [.south])
        )

        presentation.deal()
        let firstSouthHand = try player(in: presentation.gameState, seat: .south).hand
        XCTAssertEqual(presentation.gameState.dealerSeat, .south)

        presentation.deal()
        let secondSouthHand = try player(in: presentation.gameState, seat: .south).hand

        XCTAssertEqual(service.callCount, 2)
        XCTAssertEqual(service.receivedDealerSeats, [.south, .east])
        XCTAssertEqual(presentation.gameState.phase, .dealt)
        XCTAssertEqual(presentation.gameState.dealerSeat, .east)
        XCTAssertEqual(presentation.gameState.players.map(\.hand.count), [13, 13, 13, 13])
        XCTAssertEqual(Set(presentation.gameState.bids.keys), Set(Seat.allCases))
        XCTAssertNotEqual(firstSouthHand, secondSouthHand)
        XCTAssertEqual(UndealtDeckStackPresentation(phase: presentation.gameState.phase).hiddenCardCount, 0)
        XCTAssertEqual(presentation.availableActions, [.newGame, .deal])
    }

    func testReplacementDealClearsPreviousHandsBeforeRequestingReplacement() throws {
        let firstDeal = try makeCompletedDeal(dealerSeat: .west)
        let secondDeal = try makeCompletedDeal(shuffler: CardShuffler { Array($0.reversed()) }, dealerSeat: .south)
        let service = QueuedDealService(results: [firstDeal, secondDeal])
        let presentation = TarneebPresentationState(
            dealService: service,
            dealerSelector: QueuedDealerSelector(seats: [.west])
        )

        presentation.deal()

        var observedStateBeforeSecondDeal: GameState?
        service.onDeal = {
            observedStateBeforeSecondDeal = presentation.gameState
        }

        presentation.deal()

        let observedState = try XCTUnwrap(observedStateBeforeSecondDeal)
        XCTAssertEqual(observedState.phase, .notStarted)
        XCTAssertEqual(observedState.dealerSeat, .south)
        XCTAssertTrue(observedState.players.allSatisfy(\.hand.isEmpty))
        XCTAssertTrue(observedState.bids.isEmpty)
        XCTAssertEqual(presentation.gameState.phase, .dealt)
        XCTAssertEqual(presentation.gameState.dealerSeat, .south)
    }

    func testNewGameActionResetsPresentationStateToOriginalLaunchState() throws {
        let service = QueuedDealService(results: [try makeCompletedDeal(dealerSeat: .south)])
        let presentation = TarneebPresentationState(
            dealService: service,
            dealerSelector: QueuedDealerSelector(seats: [.south, .north])
        )

        presentation.deal()
        XCTAssertEqual(presentation.gameState.phase, .dealt)

        presentation.newGame()

        XCTAssertEqual(service.callCount, 1)
        XCTAssertEqual(presentation.gameState.phase, .notStarted)
        XCTAssertEqual(presentation.gameState.dealerSeat, .north)
        XCTAssertEqual(presentation.gameState.players.count, 4)
        XCTAssertTrue(presentation.gameState.players.allSatisfy(\.hand.isEmpty))
        XCTAssertNil(presentation.gameState.deck)
        XCTAssertTrue(presentation.gameState.bids.isEmpty)
        XCTAssertNil(BidAreaPresentation(phase: presentation.gameState.phase, biddingState: presentation.gameState.biddingState))
        XCTAssertEqual(
            UndealtDeckStackPresentation(phase: presentation.gameState.phase).hiddenCardCount,
            52
        )
        XCTAssertEqual(presentation.availableActions, [.newGame, .deal])
    }

    func testNewGameFromInitialStateDoesNotStartADeal() {
        let service = QueuedDealService()
        let presentation = TarneebPresentationState(
            dealService: service,
            dealerSelector: QueuedDealerSelector(seats: [.south, .east])
        )

        presentation.newGame()

        XCTAssertEqual(service.callCount, 0)
        XCTAssertEqual(presentation.gameState.phase, .notStarted)
        XCTAssertTrue(presentation.gameState.players.allSatisfy(\.hand.isEmpty))
        XCTAssertTrue(presentation.gameState.bids.isEmpty)
        XCTAssertEqual(presentation.availableActions, [.newGame, .deal])
    }

    func testPresentationStateSubmitsSouthBidOnlyOnSouthTurn() throws {
        let service = QueuedDealService(results: [try makeCompletedDeal(dealerSeat: .west)])
        let presentation = TarneebPresentationState(
            dealService: service,
            dealerSelector: QueuedDealerSelector(seats: [.west, .north]),
            biddingService: BiddingService(bidGenerator: BidGenerator { _ in .pass })
        )

        presentation.submitSouthBid(.thirteen)
        XCTAssertTrue(presentation.gameState.bids.isEmpty)

        presentation.deal()

        XCTAssertEqual(presentation.gameState.currentBiddingSeat, .south)
        XCTAssertEqual(presentation.gameState.bids[.south], .pending)

        presentation.submitSouthBid(.twelve, selectedTarneebSuit: .hearts)

        XCTAssertEqual(presentation.gameState.bids[.south], .resolved(.twelve))
        XCTAssertEqual(presentation.gameState.biddingState?.bidRecommendations[.south]?.preferredTarneebSuit, .hearts)
        XCTAssertEqual(presentation.gameState.bids[.east], .pending)
        XCTAssertEqual(presentation.gameState.bids[.north], .pending)
        XCTAssertEqual(presentation.gameState.bids[.west], .pending)
        XCTAssertEqual(presentation.gameState.highestBidSeat, .south)
        XCTAssertEqual(presentation.gameState.highestBidValue, .twelve)
        XCTAssertEqual(presentation.gameState.currentBiddingSeat, .east)
        XCTAssertEqual(presentation.gameState.biddingStatus, .inProgress)

        presentation.resolveNextSimulatedBid()
        presentation.resolveNextSimulatedBid()
        presentation.resolveNextSimulatedBid()

        XCTAssertEqual(presentation.gameState.bids[.east], .resolved(.pass))
        XCTAssertEqual(presentation.gameState.bids[.north], .resolved(.pass))
        XCTAssertEqual(presentation.gameState.bids[.west], .resolved(.pass))
        XCTAssertEqual(presentation.gameState.biddingStatus, .complete)
        XCTAssertEqual(presentation.gameState.phase, .dealt)
    }

    func testReplacementDealRefreshesBiddingRoundAndResetsSouthBid() throws {
        var bidSequence: [BidValue] = [.seven, .eight, .nine]
        let shuffler = RecordingShuffler(outputs: [
            DeckFactory.makeCanonicalDeck(),
            Array(DeckFactory.makeCanonicalDeck().reversed())
        ])
        let presentation = TarneebPresentationState(
            dealService: DealService(shuffler: shuffler),
            dealerSelector: QueuedDealerSelector(seats: [.south]),
            biddingService: BiddingService(bidGenerator: BidGenerator { _ in bidSequence.removeFirst() })
        )

        presentation.deal()
        XCTAssertEqual(presentation.gameState.bids.values.filter { $0 == .pending }.count, 4)

        presentation.resolveNextSimulatedBid()
        presentation.resolveNextSimulatedBid()
        presentation.resolveNextSimulatedBid()
        let firstBids = presentation.gameState.bids

        presentation.submitSouthBid(.thirteen, selectedTarneebSuit: .spades)
        XCTAssertEqual(presentation.gameState.bids[.south], .resolved(.thirteen))

        presentation.deal()
        let secondBids = presentation.gameState.bids

        XCTAssertEqual(firstBids[.east], .resolved(.seven))
        XCTAssertEqual(firstBids[.north], .resolved(.eight))
        XCTAssertEqual(firstBids[.west], .resolved(.nine))
        XCTAssertEqual(firstBids[.south], .pending)
        XCTAssertEqual(secondBids[.south], .pending)
        XCTAssertEqual(secondBids[.east], .pending)
        XCTAssertEqual(secondBids[.north], .pending)
        XCTAssertEqual(secondBids[.west], .pending)
        XCTAssertNotEqual(firstBids.filter { $0.key != .south }, secondBids.filter { $0.key != .south })
        XCTAssertEqual(presentation.gameState.currentBiddingSeat, .north)
        XCTAssertEqual(presentation.gameState.dealerSeat, .east)
        XCTAssertEqual(shuffler.receivedDecks.count, 2)
    }

    func testAllPassCompletionAutomaticallyRedealsWithDealerOnRight() throws {
        let canonicalDeck = DeckFactory.makeCanonicalDeck()
        let reversedDeck = Array(canonicalDeck.reversed())
        let shuffler = RecordingShuffler(outputs: [canonicalDeck, reversedDeck])
        let presentation = TarneebPresentationState(
            dealService: DealService(shuffler: shuffler),
            dealerSelector: QueuedDealerSelector(seats: [.south]),
            biddingService: BiddingService(bidGenerator: BidGenerator { _ in .pass })
        )

        presentation.deal()
        let firstSouthHand = try player(in: presentation.gameState, seat: .south).hand
        presentation.resolveNextSimulatedBid()
        presentation.resolveNextSimulatedBid()
        presentation.resolveNextSimulatedBid()
        presentation.submitSouthBid(.pass)

        XCTAssertEqual(presentation.gameState.biddingStatus, .complete)
        XCTAssertEqual(presentation.gameState.biddingCompletionOutcome, .allPassRedeal)
        XCTAssertNil(presentation.gameState.postBiddingSummary)
        XCTAssertEqual(presentation.gameState.dealerSeat, .south)

        presentation.automaticRedealAfterAllPass()

        XCTAssertEqual(presentation.gameState.phase, .dealt)
        XCTAssertEqual(presentation.gameState.dealerSeat, .east)
        XCTAssertEqual(presentation.gameState.currentBiddingSeat, .north)
        XCTAssertEqual(presentation.gameState.biddingStatus, .inProgress)
        XCTAssertNil(presentation.gameState.biddingCompletionOutcome)
        XCTAssertNil(presentation.gameState.postBiddingSummary)
        XCTAssertEqual(presentation.gameState.bids[.south], .pending)
        XCTAssertEqual(presentation.gameState.bids[.east], .pending)
        XCTAssertEqual(presentation.gameState.bids[.north], .pending)
        XCTAssertEqual(presentation.gameState.bids[.west], .pending)
        XCTAssertEqual(shuffler.receivedDecks.count, 2)
        XCTAssertNotEqual(try player(in: presentation.gameState, seat: .south).hand, firstSouthHand)
    }

    func testAutomaticRedealDoesNothingWhenBiddingCompletedWithHighBid() throws {
        let canonicalDeck = DeckFactory.makeCanonicalDeck()
        let reversedDeck = Array(canonicalDeck.reversed())
        let shuffler = RecordingShuffler(outputs: [canonicalDeck, reversedDeck])
        let presentation = TarneebPresentationState(
            dealService: DealService(shuffler: shuffler),
            dealerSelector: QueuedDealerSelector(seats: [.south]),
            biddingService: BiddingService(bidGenerator: BidGenerator { _ in .pass })
        )

        presentation.deal()
        presentation.resolveNextSimulatedBid()
        presentation.resolveNextSimulatedBid()
        presentation.resolveNextSimulatedBid()
        presentation.submitSouthBid(.thirteen, selectedTarneebSuit: .spades)
        let completedState = presentation.gameState

        XCTAssertEqual(completedState.biddingCompletionOutcome, .numericHighBid)

        presentation.automaticRedealAfterAllPass()

        XCTAssertEqual(presentation.gameState, completedState)
        XCTAssertEqual(shuffler.receivedDecks.count, 1)
    }

    func testReplacementDealUsesFreshCompleteDeckAndShufflesBeforeAssigningCards() throws {
        let canonicalDeck = DeckFactory.makeCanonicalDeck()
        let reversedDeck = Array(canonicalDeck.reversed())
        let shuffler = RecordingShuffler(outputs: [canonicalDeck, reversedDeck])
        let presentation = TarneebPresentationState(
            dealService: DealService(shuffler: shuffler),
            dealerSelector: QueuedDealerSelector(seats: [.south])
        )

        presentation.deal()
        let firstSouthHand = try player(in: presentation.gameState, seat: .south).hand

        presentation.deal()
        let secondSouthHand = try player(in: presentation.gameState, seat: .south).hand

        XCTAssertEqual(shuffler.receivedDecks.count, 2)
        XCTAssertEqual(presentation.gameState.dealerSeat, .east)
        for receivedDeck in shuffler.receivedDecks {
            XCTAssertEqual(receivedDeck, canonicalDeck)
            XCTAssertEqual(receivedDeck.count, 52)
            XCTAssertEqual(Set(receivedDeck.map(\.id)).count, 52)
        }
        XCTAssertEqual(firstSouthHand, Array(canonicalDeck[0..<13]))
        XCTAssertEqual(secondSouthHand, Array(reversedDeck[0..<13]))
        XCTAssertNotEqual(firstSouthHand, secondSouthHand)
    }

    func testPresentationStateOnlyExposesMVPTableActions() {
        let presentation = TarneebPresentationState(
            dealService: QueuedDealService(results: [DealService(shuffler: CardShuffler { $0 }).deal(dealerSeat: .south)]),
            dealerSelector: QueuedDealerSelector(seats: [.south])
        )
        let prohibitedActionNames = [
            "dealCards",
            "newDeal",
            "bid",
            "pass",
            "trump",
            "tarneebSuit",
            "playCard",
            "trick",
            "score",
            "gameOver"
        ]

        XCTAssertEqual(PresentationAction.allCases, [.newGame, .deal])
        XCTAssertEqual(presentation.availableActions, [.newGame, .deal])
        XCTAssertEqual(PresentationAction.newGame.visibleLabel, "New Game")
        XCTAssertEqual(PresentationAction.deal.visibleLabel, "Deal")
        XCTAssertTrue(prohibitedActionNames.allSatisfy { !PresentationAction.allCases.map(\.rawValue).contains($0) })

        presentation.deal()
        XCTAssertEqual(presentation.availableActions, [.newGame, .deal])
    }

    func testProjectInfoPlistLocksAppToPortrait() throws {
        let projectRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let projectFile = projectRoot
            .appendingPathComponent("Tarneeb.xcodeproj")
            .appendingPathComponent("project.pbxproj")
        let source = try String(contentsOf: projectFile)

        XCTAssertTrue(source.contains("INFOPLIST_KEY_UISupportedInterfaceOrientations = UIInterfaceOrientationPortrait;"))
        XCTAssertTrue(source.contains("INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = UIInterfaceOrientationPortrait;"))
    }

    private func makeFourPlayers() -> [Player] {
        [
            Player(id: "player-south", seat: .south, type: .human, team: .teamA, hand: []),
            Player(id: "player-west", seat: .west, type: .simulated, team: .teamB, hand: []),
            Player(id: "player-north", seat: .north, type: .simulated, team: .teamA, hand: []),
            Player(id: "player-east", seat: .east, type: .simulated, team: .teamB, hand: [])
        ]
    }

    private func makeCompletedDeal(
        shuffler: CardShuffling = CardShuffler { $0 },
        bidGenerator: BidGenerating = BidGenerator { _ in .pass },
        southDefaultBid: BidValue = .pass,
        dealerSeat: Seat = .south,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> GameState {
        try XCTUnwrap(
            DealService(
                shuffler: shuffler,
                bidGenerator: bidGenerator,
                southDefaultBid: southDefaultBid
            ).deal(dealerSeat: dealerSeat),
            file: file,
            line: line
        )
    }

    private func player(
        in state: GameState,
        seat: Seat,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> Player {
        try XCTUnwrap(state.players.first { $0.seat == seat }, file: file, line: line)
    }

    private func automatedRecommendation(
        for hand: [Card],
        seat: Seat = .north,
        partnerSeat: Seat = .south,
        currentHighestBidValue: BidValue? = nil,
        currentHighestBidder: Seat? = nil
    ) -> BidRecommendation {
        let context = BidRecommendationContext(
            seat: seat,
            hand: hand,
            partnerSeat: partnerSeat,
            currentHighestBidValue: currentHighestBidValue,
            currentHighestBidder: currentHighestBidder,
            priorBidStates: Dictionary(uniqueKeysWithValues: Seat.allCases.map { ($0, .pending) })
        )

        return AutomatedBidRecommender().recommendation(for: context)
    }

    private func hand(
        _ rawHand: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> [Card] {
        let cards = rawHand.split(separator: " ").map { card(from: $0, file: file, line: line) }

        XCTAssertEqual(cards.count, 13, file: file, line: line)
        return cards
    }

    private func card(
        from token: Substring,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Card {
        let tokenString = String(token)

        guard let suitSymbol = tokenString.last,
              let suit = suit(for: suitSymbol),
              let rank = Rank(rawValue: String(tokenString.dropLast())) else {
            XCTFail("Invalid card token: \(tokenString)", file: file, line: line)
            return Card(suit: .spades, rank: .two)
        }

        return Card(suit: suit, rank: rank)
    }

    private func suit(for symbol: Character) -> Suit? {
        switch symbol {
        case "♠":
            return .spades
        case "♣":
            return .clubs
        case "♥":
            return .hearts
        case "♦":
            return .diamonds
        default:
            return nil
        }
    }
}

private final class QueuedDealService: Dealing {
    private var results: [GameState?]
    var callCount = 0
    private(set) var receivedDealerSeats: [Seat] = []
    var onDeal: (() -> Void)?

    init(results: [GameState?] = []) {
        self.results = results
    }

    func deal(dealerSeat: Seat) -> GameState? {
        callCount += 1
        receivedDealerSeats.append(dealerSeat)
        onDeal?()

        guard !results.isEmpty else {
            return nil
        }

        return results.removeFirst()
    }
}

private final class ReentrantDealService: Dealing {
    private let result: GameState?
    var callCount = 0
    var onDeal: (() -> Void)?

    init(result: GameState?) {
        self.result = result
    }

    func deal(dealerSeat: Seat) -> GameState? {
        callCount += 1
        onDeal?()
        return result
    }
}

private final class QueuedDealerSelector: DealerSelecting {
    private var seats: [Seat]

    init(seats: [Seat]) {
        self.seats = seats
    }

    func selectDealer() -> Seat {
        guard !seats.isEmpty else {
            return .south
        }

        return seats.removeFirst()
    }
}

private final class RecordingShuffler: CardShuffling {
    private var outputs: [[Card]]
    private(set) var receivedDecks: [[Card]] = []

    init(outputs: [[Card]]) {
        self.outputs = outputs
    }

    func shuffle(_ cards: [Card]) -> [Card] {
        receivedDecks.append(cards)

        guard !outputs.isEmpty else {
            return cards
        }

        return outputs.removeFirst()
    }
}

private struct AssetCatalogContents: Decodable {
    let images: [AssetCatalogImage]
}

private struct AssetCatalogImage: Decodable {
    let filename: String?
    let idiom: String
    let size: String?
    let scale: String?
}
