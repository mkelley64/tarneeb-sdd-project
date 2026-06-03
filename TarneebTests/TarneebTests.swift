import Foundation
import XCTest

final class TarneebTests: XCTestCase {
    func testUnitTestTargetRunsWithApplicationHost() {
        XCTAssertEqual(Bundle.main.bundleIdentifier, "com.mkelley.Tarneeb")
    }

    func testDesignTokenSourceCoversRequiredMVP004TokenKeys() {
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
            "color.tableTitle.text",
            "effect.tableTitle.shadow.color",
            "color.button.deal.background",
            "color.button.deal.background.pressed",
            "color.button.deal.text",
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
            .tableTitleText: .tableTitleText,
            .tableTitleShadow: .tableTitleShadow,
            .dealActionBackground: .buttonDealBackground,
            .dealActionPressedBackground: .buttonDealBackgroundPressed,
            .dealActionText: .buttonDealText,
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

    func testDealAnimationTokensAreAvailable() {
        let requiredAnimationTokenKeys = [
            "animation.deal.stack.flight.duration",
            "animation.deal.station.expand.duration",
            "animation.deal.step.pause.duration"
        ]

        XCTAssertEqual(Set(GameAnimationToken.allCases.map(\.rawValue)), Set(requiredAnimationTokenKeys))
        XCTAssertGreaterThan(GameAnimationToken.dealStackFlightDuration.seconds, 0)
        XCTAssertGreaterThan(GameAnimationToken.dealStationExpansionDuration.seconds, 0)
        XCTAssertGreaterThan(GameAnimationToken.dealStepPauseDuration.seconds, 0)
        XCTAssertGreaterThan(GameAnimationToken.dealStackFlightDuration.nanoseconds, 0)
        XCTAssertGreaterThan(GameAnimationToken.dealStationExpansionDuration.nanoseconds, 0)
        XCTAssertGreaterThan(GameAnimationToken.dealStepPauseDuration.nanoseconds, 0)
        XCTAssertEqual(GameAnimationToken.dealStackFlightDuration.seconds, 0.36)
        XCTAssertEqual(GameAnimationToken.dealStationExpansionDuration.seconds, 0.16)
        XCTAssertEqual(GameAnimationToken.dealStepPauseDuration.seconds, 0.06)
    }

    func testDealerBadgeTokensMatchDealButtonAndWhiteText() {
        XCTAssertEqual(GameColorToken.dealerBadgeBackground.hexValue, GameColorToken.buttonDealBackground.hexValue)
        XCTAssertEqual(GameColorToken.dealerBadgeText.hexValue, GameColorToken.buttonDealText.hexValue)
        XCTAssertEqual(GameColorRole.dealerBadgeBackground.token, .dealerBadgeBackground)
        XCTAssertEqual(GameColorRole.dealerBadgeText.token, .dealerBadgeText)
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
            "SF Arabic Rounded Bold",
            "\\b0\\.92\\b",
            "\\b0\\.25\\b",
            "\\b0\\.35\\b"
        ]
        let forbiddenRegexes = try forbiddenPatterns.map { try NSRegularExpression(pattern: $0) }

        for file in sourceFiles where file.standardizedFileURL.path != tokenSourcePath {
            let source = try String(contentsOf: file)
            let range = NSRange(source.startIndex..<source.endIndex, in: source)

            for regex in forbiddenRegexes {
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

    func testGameStateOnlyUsesMVPPhasesAndInitialStateHasEmptySeats() {
        let state = GameState.initial(dealerSeat: .east)

        XCTAssertEqual(GamePhase.allCases.map(\.rawValue), ["notStarted", "dealt"])
        XCTAssertEqual(state.phase, .notStarted)
        XCTAssertEqual(state.players.count, 4)
        XCTAssertTrue(state.players.allSatisfy(\.hand.isEmpty))
        XCTAssertEqual(state.dealerSeat, .east)
        XCTAssertNil(state.deck)
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

    func testCompletedDealContainsFourThirteenCardHandsAndNoDuplicates() throws {
        let state = try makeCompletedDeal(dealerSeat: .west)
        let dealtCards = state.players.flatMap(\.hand)

        XCTAssertEqual(state.phase, .dealt)
        XCTAssertEqual(state.dealerSeat, .west)
        XCTAssertEqual(state.deck, [])
        XCTAssertEqual(state.players.map(\.hand.count), [13, 13, 13, 13])
        XCTAssertEqual(dealtCards.count, 52)
        XCTAssertEqual(Set(dealtCards), Set(DeckFactory.makeCanonicalDeck()))
        XCTAssertEqual(Set(dealtCards.map(\.id)).count, 52)
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

    func testCardPresentationExposesTokenHooksWithoutConcreteColors() {
        let warmPresentation = CardPresentation(card: Card(suit: .hearts, rank: .ace))
        let neutralPresentation = CardPresentation(card: Card(suit: .spades, rank: .two))

        XCTAssertEqual(warmPresentation.cardID, "hearts-A")
        XCTAssertEqual(warmPresentation.displayLabel, "A♥")
        XCTAssertEqual(warmPresentation.rankText, "A")
        XCTAssertEqual(warmPresentation.suitSymbol, "♥")
        XCTAssertEqual(warmPresentation.suitColorRole, .suitWarm)
        XCTAssertEqual(warmPresentation.suitColorToken, .cardSuitRed)
        XCTAssertEqual(warmPresentation.accessibilityLabel, "A♥")
        XCTAssertEqual(warmPresentation.sizeCategory, .sharedBaseCard)
        XCTAssertTrue(warmPresentation.accessibilityValue.contains("surface=color.card.background"))
        XCTAssertTrue(warmPresentation.accessibilityValue.contains("border=color.card.border"))
        XCTAssertTrue(warmPresentation.accessibilityValue.contains("shadow=color.card.shadow"))
        XCTAssertFalse(warmPresentation.accessibilityValue.contains("#"))

        XCTAssertEqual(neutralPresentation.suitColorRole, .suitNeutral)
        XCTAssertEqual(neutralPresentation.suitColorToken, .cardSuitBlack)
        XCTAssertEqual(neutralPresentation.sizeCategory, .sharedBaseCard)
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
        XCTAssertEqual(initialStack.layout.placementLabel, "veryCenter")
        XCTAssertEqual(initialStack.layout.anchorLabel, "center")
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
        XCTAssertTrue(initialStack.layout.titleOverlapAllowed)
        XCTAssertEqual(firstCardTransform.offsetX, 0)
        XCTAssertEqual(firstCardTransform.offsetY, 0)
        XCTAssertEqual(firstCardTransform.rotationDegrees, 0)
        XCTAssertEqual(lastCardTransform.offsetX, 0)
        XCTAssertEqual(lastCardTransform.offsetY, 0)
        XCTAssertEqual(lastCardTransform.rotationDegrees, 0)
        XCTAssertTrue(initialStack.accessibilityValue.contains("count=52"))
        XCTAssertTrue(initialStack.accessibilityValue.contains("asset=card_back"))
        XCTAssertTrue(initialStack.accessibilityValue.contains("layout=squaredStack"))
        XCTAssertTrue(initialStack.accessibilityValue.contains("placement=veryCenter"))
        XCTAssertTrue(initialStack.accessibilityValue.contains("anchor=center"))
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
        XCTAssertTrue(initialStack.accessibilityValue.contains("titleOverlapAllowed=true"))
        XCTAssertFalse(initialStack.accessibilityValue.contains("rank"))
        XCTAssertFalse(initialStack.accessibilityValue.contains("suit"))

        XCTAssertFalse(dealtStack.isVisible)
        XCTAssertEqual(dealtStack.hiddenCardCount, 0)
    }

    func testCenteredDeckLayoutProvidesVeryCenterSquaredTableAnchor() {
        let layout = CenteredDeckLayoutPresentation(sizeConfiguration: .sharedBase)

        XCTAssertEqual(layout.placementLabel, "veryCenter")
        XCTAssertEqual(layout.anchorLabel, "center")
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
        XCTAssertTrue(layout.titleOverlapAllowed)
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
        XCTAssertTrue(southDealerAnimation.accessibilityValue.contains("targetOrder=east,north,west,south"))
        XCTAssertTrue(southDealerAnimation.accessibilityValue.contains("flightDuration=animation.deal.stack.flight.duration"))

        XCTAssertEqual(movingStack.targetSeat, .east)
        XCTAssertEqual(movingStack.hiddenCardCount, 13)
        XCTAssertEqual(movingStack.hiddenCards.map(\.assetName), Array(repeating: "card_back", count: 13))
        XCTAssertEqual(movingStack.stackWidth, movingStack.sizeConfiguration.baseCardWidth)
        XCTAssertEqual(movingStack.stackHeight, movingStack.sizeConfiguration.baseCardHeight)
        XCTAssertTrue(movingStack.accessibilityValue.contains("count=13"))
        XCTAssertTrue(movingStack.accessibilityValue.contains("from=center"))
        XCTAssertTrue(movingStack.accessibilityValue.contains("origin=centerDeck"))
        XCTAssertTrue(movingStack.accessibilityValue.contains("destination=playerStation"))
        XCTAssertTrue(movingStack.accessibilityValue.contains("renderLayer=tableSceneOverlay"))
        XCTAssertTrue(movingStack.accessibilityValue.contains("target=east"))
        XCTAssertTrue(movingStack.accessibilityValue.contains("targetOrder=east,north,west,south"))
        XCTAssertFalse(movingStack.accessibilityValue.contains("rank"))
        XCTAssertFalse(movingStack.accessibilityValue.contains("suit"))
    }

    func testDealAnimationPathStartsEveryStackAtCenterDeckBeforeMovingToTargetStation() {
        let compactPath = DealAnimationPathPresentation(
            tableDiameter: 196,
            compactStationSide: 112,
            southStationHeight: 112,
            horizontalSpacing: 6,
            verticalSpacing: 10
        )
        let southRevealedPath = DealAnimationPathPresentation(
            tableDiameter: 196,
            compactStationSide: 112,
            southStationHeight: 142,
            horizontalSpacing: 6,
            verticalSpacing: 10
        )

        XCTAssertEqual(compactPath.deckCenterOffsetFromSceneCenter, DealAnimationOffset(x: 0, y: 0))
        XCTAssertEqual(southRevealedPath.deckCenterOffsetFromSceneCenter, DealAnimationOffset(x: 0, y: -15))

        for seat in Seat.dealerRotationOrder {
            XCTAssertEqual(
                compactPath.offset(to: seat, stackAtTarget: false),
                compactPath.deckCenterOffsetFromSceneCenter
            )
            XCTAssertEqual(
                southRevealedPath.offset(to: seat, stackAtTarget: false),
                southRevealedPath.deckCenterOffsetFromSceneCenter
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

    func testDealerStationPresentationShowsBadgeOnCurrentDealerWithoutChangingOutline() {
        let dealerStation = DealerStationPresentation(seat: .north, phase: .notStarted, dealerSeat: .north)
        let otherStation = DealerStationPresentation(seat: .south, phase: .notStarted, dealerSeat: .north)
        let dealtStation = DealerStationPresentation(seat: .north, phase: .dealt, dealerSeat: .north)

        XCTAssertTrue(dealerStation.showsDealerBadge)
        XCTAssertEqual(dealerStation.outlineColorRole, .stationOutline)
        XCTAssertEqual(dealerStation.outlineToken, .stationOutline)
        XCTAssertEqual(dealerStation.badgeBackgroundToken, .dealerBadgeBackground)
        XCTAssertEqual(dealerStation.badgeTextToken, .dealerBadgeText)
        XCTAssertTrue(dealerStation.accessibilityValue.contains("dealerBadgeVisible=true"))
        XCTAssertTrue(dealerStation.accessibilityValue.contains("badgeShape=circle"))
        XCTAssertTrue(dealerStation.accessibilityValue.contains("badgePlacement=upper-left"))
        XCTAssertTrue(dealerStation.accessibilityValue.contains("badgeBackground=color.dealerBadge.background"))
        XCTAssertTrue(dealerStation.accessibilityValue.contains("badgeTextColor=color.dealerBadge.text"))
        XCTAssertTrue(dealerStation.accessibilityValue.contains("outline=color.station.outline"))

        XCTAssertFalse(otherStation.showsDealerBadge)
        XCTAssertEqual(otherStation.outlineColorRole, .stationOutline)
        XCTAssertEqual(otherStation.outlineToken, .stationOutline)

        XCTAssertTrue(dealtStation.showsDealerBadge)
        XCTAssertEqual(dealtStation.outlineColorRole, .stationOutline)
        XCTAssertEqual(dealtStation.outlineToken, .stationOutline)
    }

    func testTableLayoutPresentationExposesDiameterStationPlacementsAndCenteredDeckAnchor() {
        let layout = TableLayoutPresentation(screenWidth: 390)

        XCTAssertEqual(layout.tableDiameter, 195)
        XCTAssertEqual(layout.stationPlacement(for: .north), .aboveTable)
        XCTAssertEqual(layout.stationPlacement(for: .west), .leftOfTable)
        XCTAssertEqual(layout.stationPlacement(for: .south), .belowTable)
        XCTAssertEqual(layout.stationPlacement(for: .east), .rightOfTable)
        XCTAssertEqual(layout.undealtDeckLayout().placementLabel, "veryCenter")
        XCTAssertEqual(layout.undealtDeckLayout().anchorLabel, "center")
        XCTAssertTrue(layout.undealtDeckLayout().titleOverlapAllowed)
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
        let undealtDeckStack = UndealtDeckStackPresentation(phase: presentation.gameState.phase)
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
        XCTAssertEqual(undealtDeckStack.hiddenCardCount, 52)
        XCTAssertEqual(undealtDeckStack.layout.placementLabel, "veryCenter")
        XCTAssertTrue(undealtDeckStack.layout.titleOverlapAllowed)
        XCTAssertTrue(dealerStation.showsDealerBadge)
        XCTAssertEqual(dealerStation.outlineToken, .stationOutline)
        XCTAssertEqual(tableTitle.text, "طرنيب")
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
        XCTAssertEqual(presentation.availableActions, [.newGame, .deal])
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
        dealerSeat: Seat = .south,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> GameState {
        try XCTUnwrap(DealService(shuffler: shuffler).deal(dealerSeat: dealerSeat), file: file, line: line)
    }

    private func player(
        in state: GameState,
        seat: Seat,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> Player {
        try XCTUnwrap(state.players.first { $0.seat == seat }, file: file, line: line)
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
