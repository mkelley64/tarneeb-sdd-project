import XCTest

final class TarneebTests: XCTestCase {
    func testUnitTestTargetRunsWithoutSwiftUIViews() {
        XCTAssertNotEqual(Bundle.main.bundleIdentifier, "com.mkelley.Tarneeb")
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

    func testDeckContainsUniqueCards() {
        let deck = DeckFactory.makeCanonicalDeck()

        XCTAssertEqual(Set(deck.map(\.id)).count, 52)
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

        var duplicateCardPlayers = Player.initialPlayers()
        let repeatedHand = Array(repeating: Card(suit: .spades, rank: .ace), count: 13)
        for index in duplicateCardPlayers.indices {
            duplicateCardPlayers[index].hand = repeatedHand
        }
        XCTAssertNil(GameState(phase: .dealt, players: duplicateCardPlayers, deck: []))

        let droppingShuffler = CardShuffler { cards in
            Array(cards.dropLast())
        }
        XCTAssertNil(DealService(shuffler: droppingShuffler).deal())
    }

    func testPresentationInitialStateHasNotStartedEmptySeatsAndNoVisibleCards() {
        let presentation = TarneebPresentationState(dealService: QueuedDealService())

        XCTAssertEqual(presentation.gameState.phase, .notStarted)
        XCTAssertEqual(presentation.gameState.players.count, 4)
        XCTAssertEqual(presentation.gameState.players.flatMap(\.hand).count, 0)
        XCTAssertEqual(presentation.availableActions, [.dealCards])
    }

    func testDealCardsActionMovesPresentationStateToDealt() throws {
        let service = QueuedDealService(results: [try makeCompletedDeal()])
        let presentation = TarneebPresentationState(dealService: service)

        presentation.dealCards()

        XCTAssertEqual(service.callCount, 1)
        XCTAssertEqual(presentation.gameState.phase, .dealt)
        XCTAssertEqual(presentation.gameState.players.map(\.hand.count), [13, 13, 13, 13])
        XCTAssertEqual(presentation.availableActions, [.newDeal])
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
    }

    func testPresentationStateOnlyExposesDealAndNewDealActions() {
        let presentation = TarneebPresentationState(dealService: QueuedDealService())
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
