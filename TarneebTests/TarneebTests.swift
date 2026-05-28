import Foundation
import XCTest

final class TarneebTests: XCTestCase {
    func testUnitTestTargetRunsWithoutSwiftUIViews() {
        XCTAssertNotEqual(Bundle.main.bundleIdentifier, "com.mkelley.Tarneeb")
    }

    func testDesignTokenSourceCoversRequiredTokenKeys() {
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
            "color.text.primary",
            "color.text.secondary",
            "color.text.disabled",
            "color.text.warning",
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
            .textPrimary: .textPrimary,
            .textSecondary: .textSecondary,
            .textDisabled: .textDisabled,
            .textWarning: .textWarning,
            .dealActionBackground: .buttonDealBackground,
            .dealActionPressedBackground: .buttonDealBackgroundPressed,
            .dealActionText: .buttonDealText,
            .newDealActionBackground: .buttonNewGameBackground,
            .newDealActionPressedBackground: .buttonNewGameBackgroundPressed,
            .newDealActionText: .buttonNewGameText
        ]

        let actualRoleTokens = Dictionary(uniqueKeysWithValues: GameColorRole.allCases.map { ($0, $0.token) })

        XCTAssertEqual(actualRoleTokens, expectedRoleTokens)
    }

    func testSuitPresentationRolesResolveToDesignTokens() {
        XCTAssertEqual(Suit.hearts.colorRole, .suitWarm)
        XCTAssertEqual(Suit.diamonds.colorRole, .suitWarm)
        XCTAssertEqual(Suit.hearts.colorToken, .cardSuitRed)
        XCTAssertEqual(Suit.diamonds.colorToken, .cardSuitRed)

        XCTAssertEqual(Suit.clubs.colorRole, .suitNeutral)
        XCTAssertEqual(Suit.spades.colorRole, .suitNeutral)
        XCTAssertEqual(Suit.clubs.colorToken, .cardSuitBlack)
        XCTAssertEqual(Suit.spades.colorToken, .cardSuitBlack)
    }

    func testSuitPresentationSymbols() {
        let symbolsBySuit = Dictionary(uniqueKeysWithValues: Suit.allCases.map { ($0, $0.displaySymbol) })

        XCTAssertEqual(symbolsBySuit[.hearts], "♥")
        XCTAssertEqual(symbolsBySuit[.clubs], "♣")
        XCTAssertEqual(symbolsBySuit[.diamonds], "♦")
        XCTAssertEqual(symbolsBySuit[.spades], "♠")
    }

    func testRankPresentationLabels() {
        XCTAssertEqual(Rank.allCases.map(\.displayLabel), ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"])
    }

    func testSuitPresentationColors() {
        let expectedPresentation: [Suit: (role: GameColorRole, token: GameColorToken)] = [
            .hearts: (.suitWarm, .cardSuitRed),
            .diamonds: (.suitWarm, .cardSuitRed),
            .clubs: (.suitNeutral, .cardSuitBlack),
            .spades: (.suitNeutral, .cardSuitBlack)
        ]

        for (suit, expected) in expectedPresentation {
            XCTAssertEqual(suit.colorRole, expected.role)
            XCTAssertEqual(suit.colorToken, expected.token)
        }
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
        XCTAssertEqual(warmPresentation.sortKey, 12)
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

    func testButtonTokenSetsExposeDealAndNewDealTokens() {
        XCTAssertEqual(ButtonTokenSet.deal.background, .buttonDealBackground)
        XCTAssertEqual(ButtonTokenSet.deal.pressedBackground, .buttonDealBackgroundPressed)
        XCTAssertEqual(ButtonTokenSet.deal.text, .buttonDealText)

        XCTAssertEqual(ButtonTokenSet.newDeal.background, .buttonNewGameBackground)
        XCTAssertEqual(ButtonTokenSet.newDeal.pressedBackground, .buttonNewGameBackgroundPressed)
        XCTAssertEqual(ButtonTokenSet.newDeal.text, .buttonNewGameText)
        XCTAssertTrue(ButtonTokenSet.newDeal.accessibilityValue.contains("color.button.newGame.background"))
        XCTAssertTrue(ButtonTokenSet.newDeal.accessibilityValue.contains("color.button.newGame.background.pressed"))
        XCTAssertTrue(ButtonTokenSet.newDeal.accessibilityValue.contains("color.button.newGame.text"))
    }

    func testSharedCardSizeCategoryIsAvailableForTestHooks() {
        XCTAssertEqual(CardSizeCategory.allCases, [.sharedBaseCard])
        XCTAssertEqual(CardSizeCategory.sharedBaseCard.rawValue, "sharedBaseCard")
    }

    func testHiddenAndExposedCardsShareBaseSize() {
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
    }

    func testSharedCardSizeUsesStandardPlayingCardAspectRatio() {
        let sizeConfiguration = CardSizeConfiguration.sharedBase

        XCTAssertEqual(sizeConfiguration.aspectRatio, 5.0 / 7.0, accuracy: 0.01)
        XCTAssertGreaterThan(sizeConfiguration.baseCardWidth, 0)
        XCTAssertGreaterThan(sizeConfiguration.baseCardHeight, sizeConfiguration.baseCardWidth)
        XCTAssertGreaterThan(sizeConfiguration.rankFontPointSize, 0)
    }

    func testConcreteColorValuesAreConfinedToDesignTokenSource() throws {
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
            "\\b(?:Color|UIColor|NSColor)\\.(?:red|black|white|blue|green|orange|yellow|gray|grey|secondary|primary)\\b"
        ]
        let forbiddenRegexes = try forbiddenPatterns.map { try NSRegularExpression(pattern: $0) }

        for file in sourceFiles where file.standardizedFileURL.path != tokenSourcePath {
            let source = try String(contentsOf: file)
            let range = NSRange(source.startIndex..<source.endIndex, in: source)

            for regex in forbiddenRegexes {
                XCTAssertNil(
                    regex.firstMatch(in: source, range: range),
                    "\(file.lastPathComponent) contains a concrete color outside DesignTokens.swift"
                )
            }
        }
    }

    func testSuitValuesAndDisplaySymbols() {
        XCTAssertEqual(Suit.allCases.map(\.rawValue), ["spades", "clubs", "hearts", "diamonds"])
        XCTAssertEqual(Suit.allCases.map(\.displaySymbol), ["♠", "♣", "♥", "♦"])
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

    func testDeckContainsNoJokers() {
        let deck = DeckFactory.makeCanonicalDeck()

        XCTAssertEqual(Set(deck.map(\.suit)), Set(Suit.allCases))
        XCTAssertEqual(Set(deck.map(\.rank)), Set(Rank.allCases))

        for suit in Suit.allCases {
            let ranksForSuit = deck.filter { $0.suit == suit }.map(\.rank)
            XCTAssertEqual(ranksForSuit, Rank.allCases)
        }
    }

    func testCanonicalDeckContainsEachSuitRankCombinationExactlyOnce() {
        let deck = DeckFactory.makeCanonicalDeck()

        for suit in Suit.allCases {
            let ranksForSuit = deck
                .filter { $0.suit == suit }
                .map(\.rank)

            XCTAssertEqual(ranksForSuit, Rank.allCases)
        }

        for rank in Rank.allCases {
            let suitsForRank = deck
                .filter { $0.rank == rank }
                .map(\.suit)

            XCTAssertEqual(Set(suitsForRank), Set(Suit.allCases))
            XCTAssertEqual(suitsForRank.count, Suit.allCases.count)
        }
    }

    func testDeckContainsUniqueCards() {
        let deck = DeckFactory.makeCanonicalDeck()

        XCTAssertEqual(Set(deck.map(\.id)).count, 52)
    }

    func testHumanHandSortsBySuitThenRank() {
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

        let sortedHand = SouthHandPresentation.sortedCards(from: unsortedHand)

        XCTAssertEqual(sortedHand.map { CardPresentation(card: $0).displayLabel }, ["2♥", "A♥", "2♣", "K♣", "2♦", "A♦", "2♠", "A♠"])
        XCTAssertEqual(unsortedHand.map(\.id), ["spades-A", "diamonds-2", "hearts-A", "clubs-K", "hearts-2", "spades-2", "diamonds-A", "clubs-2"])
    }

    func testSouthHandPresentationReturnsSortedVisibleCardsWithoutChangingOwnership() {
        let hand = [
            Card(suit: .spades, rank: .three),
            Card(suit: .hearts, rank: .two),
            Card(suit: .clubs, rank: .ace)
        ]

        let presentations = SouthHandPresentation.cardPresentations(from: hand)

        XCTAssertEqual(presentations.map(\.cardID), ["hearts-2", "clubs-A", "spades-3"])
        XCTAssertEqual(Set(presentations.map(\.cardID)), Set(hand.map(\.id)))
        XCTAssertEqual(hand.map(\.id), ["spades-3", "hearts-2", "clubs-A"])
    }

    func testHiddenHandPresentationRepresentsHiddenCardsWithoutCardIdentities() {
        let hiddenHand = HiddenHandPresentation(seat: .north, hiddenCardCount: 13)

        XCTAssertEqual(hiddenHand.seat, .north)
        XCTAssertEqual(hiddenHand.hiddenCardCount, 13)
        XCTAssertEqual(hiddenHand.hiddenCards.map(\.assetName), Array(repeating: "card_back", count: 13))
        XCTAssertEqual(hiddenHand.hiddenCards.map(\.accessibilityLabel), Array(repeating: "Card back", count: 13))
        XCTAssertTrue(hiddenHand.hiddenCards.allSatisfy { $0.accessibilityValue == CardSizeCategory.sharedBaseCard.rawValue })

        for hiddenCard in hiddenHand.hiddenCards {
            XCTAssertFalse(hiddenCard.id.contains("spades"))
            XCTAssertFalse(hiddenCard.id.contains("clubs"))
            XCTAssertFalse(hiddenCard.id.contains("hearts"))
            XCTAssertFalse(hiddenCard.id.contains("diamonds"))
            XCTAssertFalse(hiddenCard.accessibilityValue.contains("rank"))
            XCTAssertFalse(hiddenCard.accessibilityValue.contains("suit"))
        }
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

    func testHiddenStackConfigurationIsCompactAndStillRepresentsThirteenCards() {
        let hiddenHand = HiddenHandPresentation(seat: .east, hiddenCardCount: 13)
        let sizeConfiguration = CardSizeConfiguration.sharedBase

        XCTAssertEqual(hiddenHand.stackOffset, sizeConfiguration.hiddenStackOffset)
        XCTAssertGreaterThan(hiddenHand.stackOffset, 0)
        XCTAssertEqual(hiddenHand.stackWidth, sizeConfiguration.baseCardWidth + sizeConfiguration.hiddenStackOffset * 12)
        XCTAssertLessThan(hiddenHand.stackWidth, sizeConfiguration.baseCardWidth * 13)
        XCTAssertEqual(hiddenHand.hiddenCardCount, 13)
    }

    func testStandardShufflerPreservesCardCountAndUniqueness() {
        let deck = DeckFactory.makeCanonicalDeck()
        let shuffledDeck = StandardCardShuffler().shuffle(deck)

        XCTAssertEqual(shuffledDeck.count, 52)
        XCTAssertEqual(Set(shuffledDeck.map(\.id)).count, 52)
        XCTAssertEqual(Set(shuffledDeck), Set(deck))
    }

    func testDeterministicShuffleInjectionCanControlOrder() {
        let deck = DeckFactory.makeCanonicalDeck()
        let shuffler = CardShuffler { cards in
            Array(cards.reversed())
        }

        XCTAssertEqual(shuffler.shuffle(deck), Array(deck.reversed()))
    }

    func testSeatValuesAndDisplayLabels() {
        XCTAssertEqual(Seat.allCases.map(\.rawValue), ["south", "west", "north", "east"])
        XCTAssertEqual(Seat.allCases.map(\.displayLabel), ["South", "West", "North", "East"])
    }

    func testPlayerTypeValues() {
        XCTAssertEqual(PlayerType.allCases.map(\.rawValue), ["human", "simulated"])
    }

    func testTeamValuesAndDisplayLabels() {
        XCTAssertEqual(Team.allCases.map(\.rawValue), ["teamA", "teamB"])
        XCTAssertEqual(Team.allCases.map(\.displayLabel), ["Team A", "Team B"])
    }

    func testPlayerContainsRequiredFields() {
        let hand = Rank.allCases.map { Card(suit: .clubs, rank: $0) }
        let player = Player(id: "player-south", seat: .south, type: .human, team: .teamA, hand: hand)

        XCTAssertEqual(player.id, "player-south")
        XCTAssertEqual(player.seat, .south)
        XCTAssertEqual(player.type, .human)
        XCTAssertEqual(player.team, .teamA)
        XCTAssertEqual(player.hand, hand)
        XCTAssertEqual(player.hand.count, 13)
    }

    func testGamePhaseValuesOnlyIncludeMVPPhases() {
        XCTAssertEqual(GamePhase.allCases.map(\.rawValue), ["notStarted", "dealt"])
    }

    func testGameStateCanRepresentNotStartedAndDealtStates() throws {
        let players = makeFourPlayers()

        let notStarted = try XCTUnwrap(GameState(phase: .notStarted, players: players))
        XCTAssertEqual(notStarted.phase, .notStarted)
        XCTAssertEqual(notStarted.players, players)
        XCTAssertNil(notStarted.deck)

        let dealt = try makeCompletedDeal()
        XCTAssertEqual(dealt.phase, .dealt)
        XCTAssertEqual(dealt.players.count, 4)
        XCTAssertEqual(dealt.deck, [])
    }

    func testGameStateRequiresExactlyFourPlayers() {
        let players = makeFourPlayers()

        XCTAssertNil(GameState(phase: .notStarted, players: Array(players.prefix(3))))
        XCTAssertNotNil(GameState(phase: .notStarted, players: players))
        XCTAssertNil(GameState(phase: .dealt, players: players + [players[0]]))
    }

    func testInitialStateContainsExactlyFourEmptyPlayerSeats() {
        let state = GameState.initial

        XCTAssertEqual(state.phase, .notStarted)
        XCTAssertEqual(state.players.count, 4)
        XCTAssertTrue(state.players.allSatisfy(\.hand.isEmpty))
        XCTAssertNil(state.deck)
    }

    func testPlayersAreCreatedForAllSeats() {
        let players = Player.initialPlayers()

        XCTAssertEqual(players.map(\.seat), [.south, .east, .north, .west])
        XCTAssertEqual(Set(players.map(\.seat)), Set(Seat.allCases))
        XCTAssertEqual(Set(players.map(\.id)).count, 4)
    }

    func testSouthPlayerIsHuman() throws {
        let south = try XCTUnwrap(Player.initialPlayers().first { $0.seat == .south })

        XCTAssertEqual(south.type, .human)
        XCTAssertEqual(Player.initialPlayers().filter { $0.type == .human }.map(\.seat), [.south])
    }

    func testOtherPlayersAreSimulated() {
        let simulatedSeats = Player.initialPlayers()
            .filter { $0.type == .simulated }
            .map(\.seat)

        XCTAssertEqual(Set(simulatedSeats), Set([.west, .north, .east]))
    }

    func testTeamsAreAssignedCorrectly() {
        let playersBySeat = Dictionary(uniqueKeysWithValues: Player.initialPlayers().map { ($0.seat, $0) })

        XCTAssertEqual(playersBySeat[.south]?.team, .teamA)
        XCTAssertEqual(playersBySeat[.north]?.team, .teamA)
        XCTAssertEqual(playersBySeat[.east]?.team, .teamB)
        XCTAssertEqual(playersBySeat[.west]?.team, .teamB)
    }

    func testInitialPlayerHandsAreEmptyBeforeDealCards() {
        let state = GameState.initial

        XCTAssertEqual(state.players.flatMap(\.hand).count, 0)
        XCTAssertTrue(state.players.allSatisfy(\.hand.isEmpty))
    }

    func testDealServiceReturnsCompletedDealFromFreshSetup() throws {
        let state = try makeCompletedDeal()

        XCTAssertEqual(state.phase, .dealt)
        XCTAssertEqual(state.players.count, 4)
        XCTAssertEqual(state.players.map(\.seat), Seat.dealOrder)
        XCTAssertTrue(state.players.allSatisfy { $0.hand.count == 13 })
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

    func testDealServiceShufflesCanonicalDeckBeforeAssigningCards() throws {
        let canonicalDeck = DeckFactory.makeCanonicalDeck()
        let reversedDeck = Array(canonicalDeck.reversed())
        let shuffler = RecordingShuffler(outputs: [reversedDeck])
        let state = try makeCompletedDeal(shuffler: shuffler)

        XCTAssertEqual(shuffler.receivedDecks, [canonicalDeck])
        XCTAssertEqual(try player(in: state, seat: .south).hand, Array(reversedDeck[0..<13]))
        XCTAssertNotEqual(try player(in: state, seat: .south).hand, Array(canonicalDeck[0..<13]))
    }

    func testDealServiceRejectsInvalidShuffledDecksBeforeAssignment() {
        let duplicateCardShuffler = CardShuffler { cards in
            Array(repeating: cards[0], count: cards.count)
        }
        let shortDeckShuffler = CardShuffler { cards in
            Array(cards.dropLast())
        }
        let oversizedDeckShuffler = CardShuffler { cards in
            cards + [cards[0]]
        }

        XCTAssertNil(DealService(shuffler: duplicateCardShuffler).deal())
        XCTAssertNil(DealService(shuffler: shortDeckShuffler).deal())
        XCTAssertNil(DealService(shuffler: oversizedDeckShuffler).deal())
    }

    func testDealGivesEachPlayer13Cards() throws {
        let state = try makeCompletedDeal()

        XCTAssertEqual(state.players.map(\.hand.count), [13, 13, 13, 13])
    }

    func testDealUsesAll52Cards() throws {
        let state = try makeCompletedDeal()
        let dealtCards = state.players.flatMap(\.hand)

        XCTAssertEqual(dealtCards.count, 52)
        XCTAssertEqual(Set(dealtCards), Set(DeckFactory.makeCanonicalDeck()))
        XCTAssertEqual(state.deck, [])
    }

    func testDealHasNoDuplicateCards() throws {
        let state = try makeCompletedDeal()
        let dealtCards = state.players.flatMap(\.hand)

        XCTAssertEqual(Set(dealtCards.map(\.id)).count, dealtCards.count)
    }

    func testGamePhaseIsDealtAfterDeal() throws {
        XCTAssertEqual(try makeCompletedDeal().phase, .dealt)
    }

    func testInvalidCompletedDealsAreRejected() {
        let emptyHandPlayers = Player.initialPlayers()
        XCTAssertNil(GameState(phase: .dealt, players: emptyHandPlayers, deck: []))

        var shortHandPlayers = Player.initialPlayers()
        let canonicalDeck = DeckFactory.makeCanonicalDeck()
        for (index, seat) in Seat.dealOrder.enumerated() {
            let startIndex = index * 13
            let endIndex = startIndex + 13
            let hand = Array(canonicalDeck[startIndex..<endIndex])
            let playerIndex = shortHandPlayers.firstIndex { $0.seat == seat }!
            shortHandPlayers[playerIndex].hand = seat == .south ? Array(hand.dropLast()) : hand
        }
        XCTAssertNil(GameState(phase: .dealt, players: shortHandPlayers, deck: []))

        var duplicateCardPlayers = Player.initialPlayers()
        let repeatedHand = Array(repeating: Card(suit: .spades, rank: .ace), count: 13)
        for index in duplicateCardPlayers.indices {
            duplicateCardPlayers[index].hand = repeatedHand
        }
        XCTAssertNil(GameState(phase: .dealt, players: duplicateCardPlayers, deck: []))

        let validDeal = DealService(shuffler: CardShuffler { $0 }).deal()
        let validPlayers = validDeal?.players ?? []
        XCTAssertNil(GameState(phase: .dealt, players: validPlayers, deck: [canonicalDeck[0]]))

        let droppingShuffler = CardShuffler { cards in
            Array(cards.dropLast())
        }
        XCTAssertNil(DealService(shuffler: droppingShuffler).deal())
    }

    func testCompletedDealsRejectDuplicateSeatsAndInvalidPlayerAssignments() throws {
        let completedDeal = try makeCompletedDeal()

        var duplicateSeatPlayers = completedDeal.players
        duplicateSeatPlayers[1] = Player(
            id: "player-south-duplicate",
            seat: .south,
            type: .human,
            team: .teamA,
            hand: duplicateSeatPlayers[1].hand
        )
        XCTAssertNil(GameState(phase: .dealt, players: duplicateSeatPlayers, deck: []))

        var wrongHumanPlayers = completedDeal.players
        let southIndex = try XCTUnwrap(wrongHumanPlayers.firstIndex { $0.seat == .south })
        let south = wrongHumanPlayers[southIndex]
        wrongHumanPlayers[southIndex] = Player(
            id: south.id,
            seat: south.seat,
            type: .simulated,
            team: south.team,
            hand: south.hand
        )
        XCTAssertNil(GameState(phase: .dealt, players: wrongHumanPlayers, deck: []))

        var wrongTeamPlayers = completedDeal.players
        let northIndex = try XCTUnwrap(wrongTeamPlayers.firstIndex { $0.seat == .north })
        let north = wrongTeamPlayers[northIndex]
        wrongTeamPlayers[northIndex] = Player(
            id: north.id,
            seat: north.seat,
            type: north.type,
            team: .teamB,
            hand: north.hand
        )
        XCTAssertNil(GameState(phase: .dealt, players: wrongTeamPlayers, deck: []))
    }

    func testPresentationInitialStateHasNotStartedEmptySeatsAndNoVisibleCards() {
        let presentation = TarneebPresentationState(dealService: QueuedDealService())
        let visiblePresentations = presentation.gameState.players
            .filter { $0.seat == .south }
            .flatMap { SouthHandPresentation.cardPresentations(from: $0.hand) }
        let hiddenPresentations = presentation.gameState.players
            .filter { $0.seat != .south }
            .map { HiddenHandPresentation(seat: $0.seat, hiddenCardCount: $0.hand.count) }

        XCTAssertEqual(presentation.gameState.phase, .notStarted)
        XCTAssertEqual(presentation.gameState.players.count, 4)
        XCTAssertEqual(Set(presentation.gameState.players.map(\.seat)), Set(Seat.allCases))
        XCTAssertEqual(presentation.gameState.players.flatMap(\.hand).count, 0)
        XCTAssertTrue(visiblePresentations.isEmpty)
        XCTAssertTrue(hiddenPresentations.allSatisfy { $0.hiddenCards.isEmpty })
        XCTAssertEqual(presentation.availableActions, [.dealCards])
    }

    func testDealCardsActionMovesPresentationStateToDealt() throws {
        let service = QueuedDealService(results: [try makeCompletedDeal()])
        let presentation = TarneebPresentationState(dealService: service)

        presentation.dealCards()

        XCTAssertEqual(service.callCount, 1)
        XCTAssertEqual(presentation.gameState.phase, .dealt)
        XCTAssertEqual(presentation.gameState.players.map(\.hand.count), [13, 13, 13, 13])
        XCTAssertEqual(presentation.gameState.players.flatMap(\.hand).count, 52)
        XCTAssertEqual(Set(presentation.gameState.players.flatMap(\.hand).map(\.id)).count, 52)
        XCTAssertEqual(presentation.gameState.deck, [])
        XCTAssertEqual(presentation.availableActions, [.newDeal])

        let southHand = try player(in: presentation.gameState, seat: .south).hand
        let southCardPresentations = SouthHandPresentation.cardPresentations(from: southHand)
        XCTAssertEqual(southCardPresentations.count, 13)
        XCTAssertTrue(southCardPresentations.allSatisfy { $0.sizeCategory == .sharedBaseCard })
        XCTAssertTrue(southCardPresentations.allSatisfy { !$0.accessibilityValue.contains("#") })

        for seat in [Seat.east, .north, .west] {
            let simulatedPlayer = try player(in: presentation.gameState, seat: seat)
            let hiddenHand = HiddenHandPresentation(seat: seat, hiddenCardCount: simulatedPlayer.hand.count)
            XCTAssertEqual(hiddenHand.hiddenCardCount, 13)
            XCTAssertEqual(hiddenHand.sizeConfiguration, .sharedBase)
        }
    }

    func testRepeatedDealCardsTapDoesNotStartOverlappingDeals() throws {
        let service = ReentrantDealService(result: try makeCompletedDeal())
        let presentation = TarneebPresentationState(dealService: service)
        service.onDeal = {
            presentation.dealCards()
        }

        presentation.dealCards()

        XCTAssertEqual(service.callCount, 1)
        XCTAssertEqual(presentation.gameState.phase, .dealt)
        XCTAssertEqual(Set(presentation.gameState.players.flatMap(\.hand).map(\.id)).count, 52)
        let firstSouthHand = try player(in: presentation.gameState, seat: .south).hand

        presentation.dealCards()

        XCTAssertEqual(service.callCount, 1)
        XCTAssertEqual(try player(in: presentation.gameState, seat: .south).hand, firstSouthHand)
        XCTAssertEqual(presentation.availableActions, [.newDeal])
    }

    func testNewDealResetsAndDealsAgain() throws {
        let firstDeal = try makeCompletedDeal()
        let secondDeal = try makeCompletedDeal(shuffler: CardShuffler { Array($0.reversed()) })
        let service = QueuedDealService(results: [firstDeal, secondDeal])
        let presentation = TarneebPresentationState(dealService: service)

        presentation.dealCards()
        let firstSouthHand = try player(in: presentation.gameState, seat: .south).hand

        presentation.newDeal()
        let secondSouthHand = try player(in: presentation.gameState, seat: .south).hand

        XCTAssertEqual(service.callCount, 2)
        XCTAssertEqual(presentation.gameState.phase, .dealt)
        XCTAssertEqual(presentation.gameState.players.map(\.hand.count), [13, 13, 13, 13])
        XCTAssertNotEqual(firstSouthHand, secondSouthHand)
    }

    func testNewDealClearsPreviousHandsBeforeRequestingReplacement() throws {
        let firstDeal = try makeCompletedDeal()
        let secondDeal = try makeCompletedDeal(shuffler: CardShuffler { Array($0.reversed()) })
        let service = QueuedDealService(results: [firstDeal, secondDeal])
        let presentation = TarneebPresentationState(dealService: service)

        presentation.dealCards()

        var observedStateBeforeSecondDeal: GameState?
        service.onDeal = {
            observedStateBeforeSecondDeal = presentation.gameState
        }

        presentation.newDeal()

        let observedState = try XCTUnwrap(observedStateBeforeSecondDeal)
        XCTAssertEqual(observedState.phase, .notStarted)
        XCTAssertTrue(observedState.players.allSatisfy(\.hand.isEmpty))
        XCTAssertEqual(presentation.gameState.phase, .dealt)
    }

    func testNewDealUsesFreshCompleteDeckAndShufflesBeforeAssigningCards() throws {
        let canonicalDeck = DeckFactory.makeCanonicalDeck()
        let reversedDeck = Array(canonicalDeck.reversed())
        let shuffler = RecordingShuffler(outputs: [canonicalDeck, reversedDeck])
        let presentation = TarneebPresentationState(dealService: DealService(shuffler: shuffler))

        presentation.dealCards()
        let firstSouthHand = try player(in: presentation.gameState, seat: .south).hand

        presentation.newDeal()
        let secondSouthHand = try player(in: presentation.gameState, seat: .south).hand

        XCTAssertEqual(shuffler.receivedDecks.count, 2)
        for receivedDeck in shuffler.receivedDecks {
            XCTAssertEqual(receivedDeck, canonicalDeck)
            XCTAssertEqual(receivedDeck.count, 52)
            XCTAssertEqual(Set(receivedDeck.map(\.id)).count, 52)
        }
        XCTAssertEqual(firstSouthHand, Array(canonicalDeck[0..<13]))
        XCTAssertEqual(secondSouthHand, Array(reversedDeck[0..<13]))
        XCTAssertNotEqual(firstSouthHand, secondSouthHand)
        XCTAssertEqual(presentation.gameState.players.map(\.hand.count), [13, 13, 13, 13])
        XCTAssertEqual(presentation.gameState.phase, .dealt)

        XCTAssertEqual(presentation.gameState.players.map(\.seat), Seat.dealOrder)
        XCTAssertEqual(try player(in: presentation.gameState, seat: .south).team, .teamA)
        XCTAssertEqual(try player(in: presentation.gameState, seat: .north).team, .teamA)
        XCTAssertEqual(try player(in: presentation.gameState, seat: .east).team, .teamB)
        XCTAssertEqual(try player(in: presentation.gameState, seat: .west).team, .teamB)

        let southHand = try player(in: presentation.gameState, seat: .south).hand
        let sortedSouthHand = SouthHandPresentation.sortedCards(from: southHand)
        let cardPresentations = SouthHandPresentation.cardPresentations(from: southHand)
        XCTAssertEqual(cardPresentations.map(\.cardID), sortedSouthHand.map(\.id))
        XCTAssertTrue(cardPresentations.allSatisfy { $0.sizeConfiguration == .sharedBase })

        for (card, cardPresentation) in zip(sortedSouthHand, cardPresentations) {
            XCTAssertEqual(cardPresentation.suitColorRole, card.suit.colorRole)
            XCTAssertEqual(cardPresentation.suitColorToken, card.suit.colorToken)
        }

        for seat in [Seat.east, .north, .west] {
            let simulatedPlayer = try player(in: presentation.gameState, seat: seat)
            let hiddenHand = HiddenHandPresentation(seat: seat, hiddenCardCount: simulatedPlayer.hand.count)
            XCTAssertEqual(hiddenHand.hiddenCardCount, 13)
            XCTAssertEqual(hiddenHand.sizeConfiguration, .sharedBase)
        }
    }

    func testPresentationStateOnlyExposesDealAndNewDealActions() {
        let presentation = TarneebPresentationState(dealService: QueuedDealService(results: [DealService(shuffler: CardShuffler { $0 }).deal()]))
        let prohibitedActionNames = [
            "bid",
            "pass",
            "trump",
            "tarneebSuit",
            "playCard",
            "trick",
            "score",
            "gameOver"
        ]
        let actionNames = presentation.availableActions.map(\.rawValue)

        XCTAssertEqual(presentation.availableActions, [.dealCards])
        XCTAssertEqual(PresentationAction.allCases, [.dealCards, .newDeal])
        XCTAssertTrue(prohibitedActionNames.allSatisfy { !actionNames.contains($0) })

        presentation.dealCards()
        let dealtActionNames = presentation.availableActions.map(\.rawValue)
        XCTAssertEqual(presentation.availableActions, [.newDeal])
        XCTAssertTrue(prohibitedActionNames.allSatisfy { !dealtActionNames.contains($0) })
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
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> GameState {
        try XCTUnwrap(DealService(shuffler: shuffler).deal(), file: file, line: line)
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
    var onDeal: (() -> Void)?

    init(results: [GameState?] = []) {
        self.results = results
    }

    func deal() -> GameState? {
        callCount += 1
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

    func deal() -> GameState? {
        callCount += 1
        onDeal?()
        return result
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
    let scale: String?
}
