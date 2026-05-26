enum Suit: String, CaseIterable, Equatable, Hashable {
    case spades
    case clubs
    case hearts
    case diamonds

    var displaySymbol: String {
        switch self {
        case .spades:
            return "♠"
        case .clubs:
            return "♣"
        case .hearts:
            return "♥"
        case .diamonds:
            return "♦"
        }
    }
}

enum Rank: String, CaseIterable, Equatable, Hashable {
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case ten = "10"
    case jack = "J"
    case queen = "Q"
    case king = "K"
    case ace = "A"

    var displayLabel: String {
        rawValue
    }
}

struct Card: Identifiable, Equatable, Hashable {
    let suit: Suit
    let rank: Rank

    var id: String {
        "\(suit.rawValue)-\(rank.rawValue)"
    }
}

enum DeckFactory {
    static func makeCanonicalDeck() -> [Card] {
        Suit.allCases.flatMap { suit in
            Rank.allCases.map { rank in
                Card(suit: suit, rank: rank)
            }
        }
    }
}

protocol CardShuffling {
    func shuffle(_ cards: [Card]) -> [Card]
}

struct StandardCardShuffler: CardShuffling {
    func shuffle(_ cards: [Card]) -> [Card] {
        var shuffledCards = cards
        shuffledCards.shuffle()
        return shuffledCards
    }
}

struct CardShuffler: CardShuffling {
    private let shuffleCards: ([Card]) -> [Card]

    init(_ shuffleCards: @escaping ([Card]) -> [Card]) {
        self.shuffleCards = shuffleCards
    }

    func shuffle(_ cards: [Card]) -> [Card] {
        shuffleCards(cards)
    }
}

protocol Dealing {
    func deal() -> GameState?
}

enum Seat: String, CaseIterable, Equatable, Hashable {
    case south
    case west
    case north
    case east

    static let dealOrder: [Seat] = [.south, .east, .north, .west]
    static let initialSetupOrder: [Seat] = dealOrder

    var displayLabel: String {
        switch self {
        case .south:
            return "South"
        case .west:
            return "West"
        case .north:
            return "North"
        case .east:
            return "East"
        }
    }
}

enum PlayerType: String, CaseIterable, Equatable, Hashable {
    case human
    case simulated
}

enum Team: String, CaseIterable, Equatable, Hashable {
    case teamA
    case teamB

    var displayLabel: String {
        switch self {
        case .teamA:
            return "Team A"
        case .teamB:
            return "Team B"
        }
    }
}

struct Player: Identifiable, Equatable, Hashable {
    let id: String
    let seat: Seat
    let type: PlayerType
    let team: Team
    var hand: [Card]

    static func initialPlayers() -> [Player] {
        Seat.initialSetupOrder.map { seat in
            Player(
                id: "player-\(seat.rawValue)",
                seat: seat,
                type: seat == .south ? .human : .simulated,
                team: seat == .south || seat == .north ? .teamA : .teamB,
                hand: []
            )
        }
    }
}

enum GamePhase: String, CaseIterable, Equatable, Hashable {
    case notStarted
    case dealt
}

struct GameState: Equatable {
    let phase: GamePhase
    let players: [Player]
    let deck: [Card]?

    init?(phase: GamePhase, players: [Player], deck: [Card]? = nil) {
        guard players.count == 4 else {
            return nil
        }

        if phase == .dealt {
            guard GameState.isValidCompletedDeal(players: players, deck: deck) else {
                return nil
            }
        }

        self.phase = phase
        self.players = players
        self.deck = deck
    }

    static var initial: GameState {
        guard let state = GameState(phase: .notStarted, players: Player.initialPlayers()) else {
            preconditionFailure("Initial Tarneeb state must contain exactly four players.")
        }

        return state
    }

    private static func isValidCompletedDeal(players: [Player], deck: [Card]?) -> Bool {
        guard deck?.isEmpty ?? true else {
            return false
        }

        guard Set(players.map(\.seat)) == Set(Seat.allCases) else {
            return false
        }

        guard players.filter({ $0.type == .human }).map(\.seat) == [.south] else {
            return false
        }

        guard players.allSatisfy({ player in
            switch player.seat {
            case .south:
                return player.type == .human && player.team == .teamA
            case .north:
                return player.type == .simulated && player.team == .teamA
            case .east, .west:
                return player.type == .simulated && player.team == .teamB
            }
        }) else {
            return false
        }

        guard players.allSatisfy({ $0.hand.count == 13 }) else {
            return false
        }

        let dealtCards = players.flatMap(\.hand)
        let canonicalDeck = DeckFactory.makeCanonicalDeck()

        return dealtCards.count == 52
            && Set(dealtCards.map(\.id)).count == 52
            && Set(dealtCards) == Set(canonicalDeck)
    }
}

struct DealService: Dealing {
    private let shuffler: CardShuffling

    init(shuffler: CardShuffling = StandardCardShuffler()) {
        self.shuffler = shuffler
    }

    func deal() -> GameState? {
        let deck = DeckFactory.makeCanonicalDeck()
        let shuffledDeck = shuffler.shuffle(deck)

        guard shuffledDeck.count == 52, Set(shuffledDeck) == Set(deck) else {
            return nil
        }

        var players = Player.initialPlayers()

        for (index, seat) in Seat.dealOrder.enumerated() {
            let chunkStartIndex = index * 13
            let chunkEndIndex = chunkStartIndex + 13
            let hand = Array(shuffledDeck[chunkStartIndex..<chunkEndIndex])

            guard let playerIndex = players.firstIndex(where: { $0.seat == seat }) else {
                return nil
            }

            players[playerIndex].hand = hand
        }

        return GameState(phase: .dealt, players: players, deck: [])
    }
}

enum PresentationAction: String, CaseIterable, Equatable {
    case dealCards
    case newDeal
}

final class TarneebPresentationState {
    private let dealService: Dealing
    private var isDealing = false

    private(set) var gameState: GameState

    var availableActions: [PresentationAction] {
        switch gameState.phase {
        case .notStarted:
            return [.dealCards]
        case .dealt:
            return [.newDeal]
        }
    }

    init(dealService: Dealing = DealService()) {
        self.dealService = dealService
        self.gameState = .initial
    }

    func dealCards() {
        guard gameState.phase == .notStarted, !isDealing else {
            return
        }

        isDealing = true
        defer {
            isDealing = false
        }

        guard let dealtState = dealService.deal() else {
            return
        }

        gameState = dealtState
    }

    func newDeal() {
        guard gameState.phase == .dealt else {
            return
        }

        gameState = .initial
        dealCards()
    }
}
