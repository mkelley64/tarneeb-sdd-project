import Foundation

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
    func deal(dealerSeat: Seat) -> GameState?
}

protocol HandLogging {
    func logHands(_ players: [Player])
}

enum BidValue: String, CaseIterable, Equatable, Hashable {
    case pass = "Pass"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case ten = "10"
    case eleven = "11"
    case twelve = "12"
    case thirteen = "13"

    var displayLabel: String {
        rawValue
    }

    var numericValue: Int? {
        switch self {
        case .pass:
            return nil
        case .seven:
            return 7
        case .eight:
            return 8
        case .nine:
            return 9
        case .ten:
            return 10
        case .eleven:
            return 11
        case .twelve:
            return 12
        case .thirteen:
            return 13
        }
    }

    static func displayValue(_ rawValue: String) -> BidValue? {
        BidValue.allCases.first { $0.displayLabel.caseInsensitiveCompare(rawValue) == .orderedSame }
    }

    static func legalValues(afterHighest highestBid: BidValue?) -> [BidValue] {
        let minimumNumericBid = (highestBid?.numericValue ?? 6) + 1
        let numericValues = BidValue.allCases.filter { bidValue in
            guard let numericValue = bidValue.numericValue else {
                return false
            }

            return numericValue >= minimumNumericBid
        }

        return [.pass] + numericValues
    }
}

struct BidRecommendation: Equatable, Hashable {
    let bid: BidValue
    let preferredTarneebSuit: Suit?
    let confidence: Double

    init(bid: BidValue, preferredTarneebSuit: Suit? = nil, confidence: Double = 0) {
        self.bid = bid
        self.preferredTarneebSuit = bid.numericValue == nil ? nil : preferredTarneebSuit
        self.confidence = min(max(confidence, 0), 1)
    }
}

struct BidRecommendationContext: Equatable {
    let seat: Seat
    let hand: [Card]
    let partnerSeat: Seat
    let currentHighestBidValue: BidValue?
    let currentHighestBidder: Seat?
    let priorBidStates: [Seat: BidState]
}

protocol BidRecommending {
    func recommendation(for context: BidRecommendationContext) -> BidRecommendation
}

protocol BidGenerating {
    func bid(for seat: Seat) -> BidValue
}

struct RandomBidGenerator: BidGenerating {
    private let randomIndex: (Range<Int>) -> Int

    init(randomIndex: @escaping (Range<Int>) -> Int = { Int.random(in: $0) }) {
        self.randomIndex = randomIndex
    }

    func bid(for seat: Seat) -> BidValue {
        let values = BidValue.allCases
        let index = randomIndex(values.indices)

        guard values.indices.contains(index) else {
            return .pass
        }

        return values[index]
    }
}

struct BidGenerator: BidGenerating {
    private let generateBid: (Seat) -> BidValue

    init(_ generateBid: @escaping (Seat) -> BidValue) {
        self.generateBid = generateBid
    }

    func bid(for seat: Seat) -> BidValue {
        generateBid(seat)
    }
}

struct BidGeneratorRecommendationAdapter: BidRecommending {
    let bidGenerator: BidGenerating

    func recommendation(for context: BidRecommendationContext) -> BidRecommendation {
        let bid = bidGenerator.bid(for: context.seat)
        let preferredSuit = bid.numericValue == nil
            ? nil
            : AutomatedBidRecommender.preferredSuit(for: context.hand)
        let confidence = bid.numericValue == nil ? 0.25 : 0.5

        return BidRecommendation(
            bid: bid,
            preferredTarneebSuit: preferredSuit,
            confidence: confidence
        )
    }
}

struct EnvironmentBidGenerator: BidGenerating {
    private let environment: [String: String]
    private let fallback: BidGenerating

    init(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        fallback: BidGenerating = RandomBidGenerator()
    ) {
        self.environment = environment
        self.fallback = fallback
    }

    func bid(for seat: Seat) -> BidValue {
        guard let configuredBids = environment["TARNEEB_SIMULATED_BIDS"] else {
            return fallback.bid(for: seat)
        }

        let entries = configuredBids
            .split { $0 == "," || $0 == ";" }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        for entry in entries {
            let components = entry.split(separator: ":", maxSplits: 1).map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            }

            guard components.count == 2,
                  components[0].caseInsensitiveCompare(seat.rawValue) == .orderedSame,
                  let bidValue = BidValue.displayValue(components[1]) else {
                continue
            }

            return bidValue
        }

        return fallback.bid(for: seat)
    }
}

struct EnvironmentBidRecommender: BidRecommending {
    private let environment: [String: String]
    private let fallback: BidRecommending

    init(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        fallback: BidRecommending = AutomatedBidRecommender()
    ) {
        self.environment = environment
        self.fallback = fallback
    }

    func recommendation(for context: BidRecommendationContext) -> BidRecommendation {
        guard let configuredBids = environment["TARNEEB_SIMULATED_BIDS"] else {
            return fallback.recommendation(for: context)
        }

        let entries = configuredBids
            .split { $0 == "," || $0 == ";" }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        for entry in entries {
            let components = entry.split(separator: ":", maxSplits: 1).map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            }

            guard components.count == 2,
                  components[0].caseInsensitiveCompare(context.seat.rawValue) == .orderedSame,
                  let bidValue = BidValue.displayValue(components[1]) else {
                continue
            }

            return BidRecommendation(
                bid: bidValue,
                preferredTarneebSuit: bidValue.numericValue == nil ? nil : AutomatedBidRecommender.preferredSuit(for: context.hand),
                confidence: bidValue.numericValue == nil ? 0.25 : 0.5
            )
        }

        return fallback.recommendation(for: context)
    }
}

struct AutomatedBidRecommender: BidRecommending {
    func recommendation(for context: BidRecommendationContext) -> BidRecommendation {
        guard let evaluation = Self.bestSuitEvaluation(for: context.hand) else {
            return BidRecommendation(bid: .pass, confidence: 0)
        }

        var estimatedBid = Self.bidValue(forEstimatedTricks: evaluation.estimatedTricks)

        if context.currentHighestBidder == context.partnerSeat {
            let canRaisePartner: Bool
            if let highest = context.currentHighestBidValue?.numericValue,
               let estimated = estimatedBid.numericValue {
                canRaisePartner = estimated >= highest + 2
                    && Self.hasStrongIndependentTrumpControl(in: context.hand, tarneebSuit: evaluation.suit)
            } else {
                canRaisePartner = false
            }

            if !canRaisePartner {
                estimatedBid = .pass
            }
        }

        if estimatedBid.numericValue == nil {
            return BidRecommendation(bid: .pass, confidence: evaluation.confidence)
        }

        return BidRecommendation(
            bid: estimatedBid,
            preferredTarneebSuit: evaluation.suit,
            confidence: evaluation.confidence
        )
    }

    static func preferredSuit(for hand: [Card]) -> Suit? {
        bestSuitEvaluation(for: hand)?.suit
    }

    private static func bestSuitEvaluation(for hand: [Card]) -> SuitEvaluation? {
        Suit.allCases
            .map { SuitEvaluation(suit: $0, estimatedTricks: estimatedTricks(for: hand, tarneebSuit: $0)) }
            .sorted { lhs, rhs in
                if lhs.estimatedTricks == rhs.estimatedTricks {
                    return suitTieBreakIndex(lhs.suit) < suitTieBreakIndex(rhs.suit)
                }

                return lhs.estimatedTricks > rhs.estimatedTricks
            }
            .first
    }

    private static func estimatedTricks(for hand: [Card], tarneebSuit: Suit) -> Double {
        let trumpCards = hand.filter { $0.suit == tarneebSuit }
        let nonTrumpCards = hand.filter { $0.suit != tarneebSuit }
        let hasTrumpAce = trumpCards.contains { $0.rank == .ace }
        let hasTrumpKing = trumpCards.contains { $0.rank == .king }
        let hasTrumpQueen = trumpCards.contains { $0.rank == .queen }
        let hasTrumpJack = trumpCards.contains { $0.rank == .jack }
        let hasTrumpTen = trumpCards.contains { $0.rank == .ten }
        let trumpTopControlCount = trumpCards.filter { isTopTrumpControl($0.rank) }.count
        let hasStrongTrumpControl = hasTrumpAce || trumpTopControlCount >= 2
        let outsideAceCount = nonTrumpCards.filter { $0.rank == .ace }.count
        let outsideKingCount = nonTrumpCards.filter { $0.rank == .king }.count
        let trumpHighStrength = trumpCards.reduce(0) { $0 + highCardStrength($1.rank) }
        let sideWinnerStrength = nonTrumpCards.reduce(0) { total, card in
            switch card.rank {
            case .ace:
                return total + 0.9
            case .king:
                return total + 0.35
            default:
                return total
            }
        }
        let canUseShortSuitValue = trumpCards.count >= 5 && hasStrongTrumpControl
        let shortSuitBonus = canUseShortSuitValue
            ? Suit.allCases
                .filter { $0 != tarneebSuit }
                .reduce(0.0) { total, suit in
                    let count = hand.filter { $0.suit == suit }.count
                    if count == 0 {
                        return total + 0.65
                    }
                    if count == 1 {
                        return total + 0.3
                    }
                    return total
                }
            : 0
        let lengthBonusRate = hasStrongTrumpControl ? 0.85 : 0.45
        let lengthBonus = Double(max(0, trumpCards.count - 3)) * lengthBonusRate
        let shortTrumpRiskPenalty = trumpCards.count < 4 ? 0.8 : 0
        let missingTrumpAcePenalty = trumpCards.count >= 4 && !hasTrumpAce ? 1.15 : 0
        let weakTopControlPenalty = trumpCards.count >= 5 && trumpTopControlCount < 2 ? 0.55 : 0
        let tenLevelCommitmentPenalty = trumpCards.count == 5
            && hasTrumpAce
            && trumpTopControlCount == 2
            && sideWinnerStrength < 2
            ? 0.35
            : 0
        let aceLedFiveCardUncertaintyPenalty = trumpCards.count == 5
            && hasTrumpAce
            && !hasTrumpKing
            && !hasTrumpQueen
            ? 0.75
            : 0
        let sixCardTenLevelCommitmentPenalty = trumpCards.count == 6
            && hasTrumpAce
            && hasTrumpQueen
            && !hasTrumpKing
            ? 0.75
            : 0
        let fiveCardTopTextureNoOutsideAcePenalty = trumpCards.count == 5
            && hasTrumpAce
            && hasTrumpKing
            && hasTrumpQueen
            && hasTrumpTen
            && outsideAceCount == 0
            ? 1.0
            : 0
        let riskPenalty = shortTrumpRiskPenalty
            + missingTrumpAcePenalty
            + weakTopControlPenalty
            + tenLevelCommitmentPenalty
            + aceLedFiveCardUncertaintyPenalty
            + sixCardTenLevelCommitmentPenalty
            + fiveCardTopTextureNoOutsideAcePenalty

        let normalEstimate = 3.6
            + Double(trumpCards.count) * 0.18
            + lengthBonus
            + trumpHighStrength
            + sideWinnerStrength
            + shortSuitBonus
            - riskPenalty
        let conservativeCap = conservativeShapeCap(
            trumpCards: trumpCards,
            hasTrumpAce: hasTrumpAce,
            hasTrumpKing: hasTrumpKing,
            hasTrumpQueen: hasTrumpQueen,
            hasTrumpJack: hasTrumpJack,
            hasTrumpTen: hasTrumpTen,
            outsideAceCount: outsideAceCount,
            outsideKingCount: outsideKingCount
        )

        if let conservativeCap {
            return min(normalEstimate, conservativeCap)
        }

        return normalEstimate
    }

    private static func conservativeShapeCap(
        trumpCards: [Card],
        hasTrumpAce: Bool,
        hasTrumpKing: Bool,
        hasTrumpQueen: Bool,
        hasTrumpJack: Bool,
        hasTrumpTen: Bool,
        outsideAceCount: Int,
        outsideKingCount: Int
    ) -> Double? {
        switch trumpCards.count {
        case 4:
            if hasTrumpAce && !hasTrumpKing && !hasTrumpQueen && !hasTrumpJack && !hasTrumpTen && outsideAceCount <= 1 {
                return 6.99
            }

            if hasTrumpAce && hasTrumpKing && !hasTrumpQueen && hasTrumpJack && hasTrumpTen && outsideAceCount == 0 {
                return 7.99
            }

            if hasTrumpAce && hasTrumpKing && !hasTrumpQueen && !hasTrumpJack && !hasTrumpTen && outsideAceCount == 0 {
                return 7.99
            }

            if hasTrumpAce && hasTrumpKing && !hasTrumpQueen && !hasTrumpJack && hasTrumpTen {
                return 8.99
            }

            if hasTrumpAce && hasTrumpKing && hasTrumpQueen && !hasTrumpJack && !hasTrumpTen && outsideAceCount <= 2 {
                return 9.99
            }

            if hasTrumpAce && !hasTrumpKing && hasTrumpQueen && !hasTrumpJack && !hasTrumpTen {
                return 8.99
            }

            if hasTrumpAce && hasTrumpKing && hasTrumpJack && !hasTrumpQueen && !hasTrumpTen && outsideAceCount <= 1 {
                return 8.99
            }

            if hasTrumpAce && hasTrumpKing && hasTrumpJack && !hasTrumpQueen && !hasTrumpTen && outsideAceCount <= 2 {
                return 9.99
            }

            if hasTrumpAce && hasTrumpKing && !hasTrumpQueen && !hasTrumpJack && !hasTrumpTen && outsideAceCount <= 1 {
                return 8.99
            }

            if hasTrumpAce && !hasTrumpKing && hasTrumpQueen && hasTrumpJack && !hasTrumpTen && outsideAceCount <= 1 {
                return 8.99
            }
        case 5:
            if hasTrumpAce && hasTrumpKing && !hasTrumpQueen && !hasTrumpJack && !hasTrumpTen && outsideAceCount <= 1 {
                return 8.99
            }

            if hasTrumpAce && hasTrumpKing && !hasTrumpQueen && !hasTrumpJack && hasTrumpTen && outsideAceCount <= 1 {
                return 8.99
            }

            if hasTrumpAce && !hasTrumpKing && hasTrumpQueen && !hasTrumpJack && hasTrumpTen && outsideAceCount <= 1 {
                return 8.99
            }

            if hasTrumpAce && !hasTrumpKing && hasTrumpQueen && !hasTrumpJack && hasTrumpTen && outsideAceCount <= 3 {
                return 10.99
            }

            if hasTrumpAce && !hasTrumpKing && hasTrumpQueen && !hasTrumpJack && !hasTrumpTen && outsideAceCount <= 1 {
                return 8.99
            }

            if hasTrumpAce && hasTrumpKing && hasTrumpQueen && !hasTrumpJack && !hasTrumpTen && outsideAceCount == 0 {
                return 8.99
            }

            if !hasTrumpAce && hasTrumpKing && hasTrumpQueen && !hasTrumpJack && !hasTrumpTen && outsideAceCount <= 1 {
                return 7.99
            }

            if hasTrumpAce && hasTrumpKing && !hasTrumpQueen && hasTrumpJack && !hasTrumpTen && outsideAceCount <= 1 {
                return 9.99
            }

            if !hasTrumpAce && hasTrumpKing && hasTrumpQueen && hasTrumpTen && outsideAceCount <= 1 {
                return 7.99
            }

            if hasTrumpAce && !hasTrumpKing && !hasTrumpQueen && hasTrumpJack && hasTrumpTen && outsideAceCount == 0 {
                return 6.99
            }

            if hasTrumpAce && !hasTrumpKing && !hasTrumpQueen && !hasTrumpJack && hasTrumpTen && outsideAceCount == 0 {
                return 6.99
            }

            if hasTrumpAce && !hasTrumpKing && !hasTrumpQueen && !hasTrumpJack && !hasTrumpTen && outsideAceCount <= 2 {
                return 7.99
            }

            if hasTrumpAce && !hasTrumpKing && hasTrumpQueen && hasTrumpJack && !hasTrumpTen && outsideAceCount <= 1 {
                return 8.99
            }

            if hasTrumpAce && hasTrumpKing && hasTrumpQueen && hasTrumpTen && outsideAceCount == 0 {
                return 9.99
            }

            if hasTrumpAce && hasTrumpKing && hasTrumpQueen && hasTrumpJack && !hasTrumpTen && outsideAceCount == 0 {
                return 9.99
            }
        case 6:
            if hasTrumpAce && !hasTrumpKing && !hasTrumpQueen && hasTrumpJack && !hasTrumpTen && outsideAceCount <= 1 {
                return 9.99
            }

            if hasTrumpAce && hasTrumpKing && !hasTrumpQueen && !hasTrumpJack && !hasTrumpTen && outsideAceCount <= 2 {
                return 10.99
            }

            if hasTrumpAce && hasTrumpKing && hasTrumpQueen && hasTrumpJack && outsideAceCount == 0 {
                return 10.99
            }

            if hasTrumpAce && hasTrumpKing && hasTrumpQueen && !hasTrumpJack && !hasTrumpTen && outsideAceCount == 0 && outsideKingCount == 0 {
                return 9.99
            }

            if hasTrumpAce && hasTrumpKing && hasTrumpQueen && !hasTrumpJack && !hasTrumpTen && outsideAceCount <= 2 {
                return 11.99
            }
        case 7:
            if hasTrumpAce && !hasTrumpKing && hasTrumpQueen && !hasTrumpJack && outsideAceCount <= 1 && outsideKingCount == 0 {
                return 10.99
            }
        default:
            break
        }

        return nil
    }

    private static func hasStrongIndependentTrumpControl(in hand: [Card], tarneebSuit: Suit) -> Bool {
        let trumpCards = hand.filter { $0.suit == tarneebSuit }
        let hasTrumpAce = trumpCards.contains { $0.rank == .ace }
        let trumpTopControlCount = trumpCards.filter { isTopTrumpControl($0.rank) }.count

        return hasTrumpAce || trumpTopControlCount >= 2
    }

    private static func highCardStrength(_ rank: Rank) -> Double {
        switch rank {
        case .ace:
            return 1.25
        case .king:
            return 1.0
        case .queen:
            return 0.65
        case .jack:
            return 0.4
        case .ten:
            return 0.2
        default:
            return 0
        }
    }

    private static func isTopTrumpControl(_ rank: Rank) -> Bool {
        switch rank {
        case .ace, .king, .queen:
            return true
        case .two, .three, .four, .five, .six, .seven, .eight, .nine, .ten, .jack:
            return false
        }
    }

    private static func bidValue(forEstimatedTricks estimatedTricks: Double) -> BidValue {
        guard estimatedTricks >= 7 else {
            return .pass
        }

        let rounded = min(13, max(7, Int(estimatedTricks.rounded(.down))))
        return BidValue.allCases.first { $0.numericValue == rounded } ?? .pass
    }

    private static func suitTieBreakIndex(_ suit: Suit) -> Int {
        Suit.allCases.firstIndex(of: suit) ?? 0
    }

    private struct SuitEvaluation: Equatable {
        let suit: Suit
        let estimatedTricks: Double

        var confidence: Double {
            min(max((estimatedTricks - 6) / 7, 0), 1)
        }
    }
}

enum BidState: Equatable, Hashable {
    case pending
    case resolved(BidValue)

    var displayLabel: String {
        switch self {
        case .pending:
            return "--"
        case .resolved(let bidValue):
            return bidValue.displayLabel
        }
    }

    var resolvedValue: BidValue? {
        switch self {
        case .pending:
            return nil
        case .resolved(let bidValue):
            return bidValue
        }
    }

    var isPass: Bool {
        resolvedValue == .pass
    }
}

enum BiddingRoundStatus: String, Equatable, Hashable {
    case inProgress
    case complete
}

enum BiddingCompletionOutcome: String, Equatable, Hashable {
    case numericHighBid
    case allPassRedeal
}

struct BiddingState: Equatable, Hashable {
    private(set) var bids: [Seat: BidState]
    private(set) var bidRecommendations: [Seat: BidRecommendation]
    private(set) var currentTurnSeat: Seat?
    private(set) var highestBidSeat: Seat?
    private(set) var highestBidValue: BidValue?
    private(set) var status: BiddingRoundStatus

    init(
        bids: [Seat: BidState],
        bidRecommendations: [Seat: BidRecommendation] = [:],
        currentTurnSeat: Seat?,
        highestBidSeat: Seat?,
        highestBidValue: BidValue?,
        status: BiddingRoundStatus
    ) {
        self.bids = bids
        self.bidRecommendations = bidRecommendations
        self.currentTurnSeat = currentTurnSeat
        self.highestBidSeat = highestBidSeat
        self.highestBidValue = highestBidValue
        self.status = status
    }

    static func started(dealerSeat: Seat) -> BiddingState {
        BiddingState(
            bids: Dictionary(uniqueKeysWithValues: Seat.allCases.map { ($0, BidState.pending) }),
            currentTurnSeat: dealerSeat.nextCounterclockwiseDealer,
            highestBidSeat: nil,
            highestBidValue: nil,
            status: .inProgress
        )
    }

    var isWaitingForSouth: Bool {
        status == .inProgress && currentTurnSeat == .south && canBid(.south)
    }

    var completionOutcome: BiddingCompletionOutcome? {
        guard status == .complete else {
            return nil
        }

        return highestBidSeat == nil ? .allPassRedeal : .numericHighBid
    }

    var southLegalValues: [BidValue] {
        BidValue.legalValues(afterHighest: highestBidValue)
    }

    mutating func submit(_ selectedBid: BidValue, for seat: Seat) {
        submit(selectedBid, recommendation: nil, for: seat)
    }

    mutating func submit(_ selectedBid: BidValue, recommendation: BidRecommendation?, for seat: Seat) {
        guard status == .inProgress, currentTurnSeat == seat, canBid(seat) else {
            return
        }

        let acceptedBid = acceptedBid(from: selectedBid)
        guard acceptedBid.numericValue == nil || recommendation?.preferredTarneebSuit != nil else {
            return
        }

        bids[seat] = .resolved(acceptedBid)

        if acceptedBid == .thirteen {
            storeRecommendation(recommendation, acceptedBid: acceptedBid, for: seat)
            highestBidSeat = seat
            highestBidValue = acceptedBid
            completeAfterThirteenBid(from: seat)
            return
        }

        if acceptedBid.numericValue != nil {
            storeRecommendation(recommendation, acceptedBid: acceptedBid, for: seat)
            highestBidSeat = seat
            highestBidValue = acceptedBid
        }

        if shouldComplete {
            complete()
        } else if let nextTurnSeat = nextEligibleTurnSeat(after: seat) {
            currentTurnSeat = nextTurnSeat
        } else {
            complete()
        }
    }

    private func canBid(_ seat: Seat) -> Bool {
        guard bids[seat]?.isPass != true else {
            return false
        }

        return highestBidSeat != seat
    }

    private func nextEligibleTurnSeat(after seat: Seat) -> Seat? {
        var candidate = seat.nextCounterclockwiseDealer

        for _ in Seat.allCases {
            if canBid(candidate) {
                return candidate
            }

            candidate = candidate.nextCounterclockwiseDealer
        }

        return nil
    }

    private func acceptedBid(from selectedBid: BidValue) -> BidValue {
        guard let selectedNumericValue = selectedBid.numericValue else {
            return .pass
        }

        guard selectedNumericValue > highestNumericBid else {
            return .pass
        }

        return selectedBid
    }

    private var highestNumericBid: Int {
        highestBidValue?.numericValue ?? 0
    }

    private var shouldComplete: Bool {
        if let highestBidSeat {
            return Seat.allCases
                .filter { $0 != highestBidSeat }
                .allSatisfy { bids[$0]?.isPass == true }
        }

        return Seat.allCases.allSatisfy { bids[$0]?.isPass == true }
    }

    private mutating func completeAfterThirteenBid(from bidderSeat: Seat) {
        for seat in Seat.allCases where seat != bidderSeat {
            bids[seat] = .resolved(.pass)
        }

        complete()
    }

    private mutating func complete() {
        status = .complete
        currentTurnSeat = nil
    }

    private mutating func storeRecommendation(_ recommendation: BidRecommendation?, acceptedBid: BidValue, for seat: Seat) {
        guard acceptedBid.numericValue != nil else {
            return
        }

        if let recommendation {
            bidRecommendations[seat] = BidRecommendation(
                bid: acceptedBid,
                preferredTarneebSuit: recommendation.preferredTarneebSuit,
                confidence: recommendation.confidence
            )
        } else {
            bidRecommendations[seat] = BidRecommendation(
                bid: acceptedBid,
                preferredTarneebSuit: nil,
                confidence: 0
            )
        }
    }
}

struct BiddingService {
    let bidRecommender: BidRecommending

    init(bidRecommender: BidRecommending = EnvironmentBidRecommender()) {
        self.bidRecommender = bidRecommender
    }

    init(bidGenerator: BidGenerating) {
        self.bidRecommender = BidGeneratorRecommendationAdapter(bidGenerator: bidGenerator)
    }

    func advanceSimulatedTurns(in gameState: GameState) -> GameState {
        guard let biddingState = gameState.biddingState else {
            return gameState
        }

        let resolvedBiddingState = advanceSimulatedTurns(in: biddingState, gameState: gameState)
        return gameState.replacingBiddingState(
            resolvedBiddingState,
            postBiddingSummary: summaryIfComplete(for: resolvedBiddingState, players: gameState.players)
        )
    }

    func submitSouthBid(_ selectedBid: BidValue, selectedTarneebSuit: Suit? = nil, in gameState: GameState) -> GameState {
        guard var biddingState = gameState.biddingState,
              biddingState.isWaitingForSouth else {
            return gameState
        }

        let recommendation: BidRecommendation
        if selectedBid.numericValue == nil {
            recommendation = BidRecommendation(bid: selectedBid, confidence: 0)
        } else {
            guard let selectedTarneebSuit else {
                return gameState
            }

            recommendation = BidRecommendation(
                bid: selectedBid,
                preferredTarneebSuit: selectedTarneebSuit,
                confidence: 1
            )
        }

        biddingState.submit(selectedBid, recommendation: recommendation, for: .south)
        return gameState.replacingBiddingState(
            biddingState,
            postBiddingSummary: summaryIfComplete(for: biddingState, players: gameState.players)
        )
    }

    func resolveNextSimulatedBid(in gameState: GameState) -> GameState {
        guard var biddingState = gameState.biddingState,
              biddingState.status == .inProgress,
              let currentSeat = biddingState.currentTurnSeat,
              currentSeat != .south else {
            return gameState
        }

        let recommendation = resolvedRecommendation(for: currentSeat, in: gameState, biddingState: biddingState)
        biddingState.submit(recommendation.bid, recommendation: recommendation, for: currentSeat)
        return gameState.replacingBiddingState(
            biddingState,
            postBiddingSummary: summaryIfComplete(for: biddingState, players: gameState.players)
        )
    }

    private func advanceSimulatedTurns(in biddingState: BiddingState, gameState: GameState) -> BiddingState {
        var resolvedBiddingState = biddingState
        var guardrail = 0

        while resolvedBiddingState.status == .inProgress,
              let currentSeat = resolvedBiddingState.currentTurnSeat,
              currentSeat != .south,
              guardrail < 64 {
            let recommendation = resolvedRecommendation(for: currentSeat, in: gameState, biddingState: resolvedBiddingState)
            resolvedBiddingState.submit(recommendation.bid, recommendation: recommendation, for: currentSeat)
            guardrail += 1
        }

        return resolvedBiddingState
    }

    private func resolvedRecommendation(
        for seat: Seat,
        in gameState: GameState,
        biddingState: BiddingState
    ) -> BidRecommendation {
        let recommendation = recommendation(for: seat, in: gameState, biddingState: biddingState)

        guard recommendation.bid.numericValue != nil else {
            return recommendation
        }

        guard biddingState.highestBidSeat == seat.partnerSeat,
              let currentHighestValue = biddingState.highestBidValue?.numericValue,
              let recommendedValue = recommendation.bid.numericValue else {
            return recommendation
        }

        let playerHand = gameState.players.first(where: { $0.seat == seat })?.hand ?? []
        guard recommendedValue >= currentHighestValue + 2,
              let preferredSuit = recommendation.preferredTarneebSuit,
              hasStrongIndependentTrumpControl(in: playerHand, tarneebSuit: preferredSuit) else {
            return BidRecommendation(bid: .pass, confidence: recommendation.confidence)
        }

        return recommendation
    }

    private func recommendation(
        for seat: Seat,
        in gameState: GameState,
        biddingState: BiddingState,
        overridingBid: BidValue? = nil
    ) -> BidRecommendation {
        let playerHand = gameState.players.first(where: { $0.seat == seat })?.hand ?? []

        if let overridingBid {
            return BidRecommendation(
                bid: overridingBid,
                preferredTarneebSuit: overridingBid.numericValue == nil
                    ? nil
                    : AutomatedBidRecommender.preferredSuit(for: playerHand),
                confidence: overridingBid.numericValue == nil ? 0 : 1
            )
        }

        let context = BidRecommendationContext(
            seat: seat,
            hand: playerHand,
            partnerSeat: seat.partnerSeat,
            currentHighestBidValue: biddingState.highestBidValue,
            currentHighestBidder: biddingState.highestBidSeat,
            priorBidStates: biddingState.bids
        )
        return bidRecommender.recommendation(for: context)
    }

    private func hasStrongIndependentTrumpControl(in hand: [Card], tarneebSuit: Suit) -> Bool {
        let trumpCards = hand.filter { $0.suit == tarneebSuit }
        let hasTrumpAce = trumpCards.contains { $0.rank == .ace }
        let trumpTopControlCount = trumpCards.filter { isTopTrumpControl($0.rank) }.count

        return hasTrumpAce || trumpTopControlCount >= 2
    }

    private func isTopTrumpControl(_ rank: Rank) -> Bool {
        switch rank {
        case .ace, .king, .queen:
            return true
        case .two, .three, .four, .five, .six, .seven, .eight, .nine, .ten, .jack:
            return false
        }
    }

    private func summaryIfComplete(for biddingState: BiddingState, players: [Player]) -> PostBiddingSummary? {
        guard biddingState.status == .complete,
              let highBidderSeat = biddingState.highestBidSeat,
              let highBidValue = biddingState.highestBidValue,
              highBidValue.numericValue != nil else {
            return nil
        }

        guard let tarneebSuit = biddingState.bidRecommendations[highBidderSeat]?.preferredTarneebSuit else {
            return nil
        }

        return PostBiddingSummary(
            highBidderSeat: highBidderSeat,
            bidValue: highBidValue,
            tarneebSuit: tarneebSuit
        )
    }
}

enum Seat: String, CaseIterable, Equatable, Hashable {
    case south
    case west
    case north
    case east

    static let dealOrder: [Seat] = [.south, .east, .north, .west]
    static let initialSetupOrder: [Seat] = dealOrder
    static let dealerRotationOrder: [Seat] = dealOrder

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

    var nextCounterclockwiseDealer: Seat {
        guard let currentIndex = Seat.dealerRotationOrder.firstIndex(of: self) else {
            return .south
        }

        let nextIndex = Seat.dealerRotationOrder.index(after: currentIndex)
        return Seat.dealerRotationOrder[nextIndex == Seat.dealerRotationOrder.endIndex ? Seat.dealerRotationOrder.startIndex : nextIndex]
    }

    var partnerSeat: Seat {
        switch self {
        case .south:
            return .north
        case .north:
            return .south
        case .east:
            return .west
        case .west:
            return .east
        }
    }

    var highBiddingTeamLabel: String {
        switch self {
        case .south, .north:
            return "North-South"
        case .east, .west:
            return "East-West"
        }
    }
}

protocol DealerSelecting {
    func selectDealer() -> Seat
}

struct RandomDealerSelector: DealerSelecting {
    private let randomIndex: (Range<Int>) -> Int

    init(randomIndex: @escaping (Range<Int>) -> Int = { Int.random(in: $0) }) {
        self.randomIndex = randomIndex
    }

    func selectDealer() -> Seat {
        let seats = Seat.dealerRotationOrder
        let index = randomIndex(seats.indices)
        guard seats.indices.contains(index) else {
            return seats[0]
        }

        return seats[index]
    }
}

struct EnvironmentDealerSelector: DealerSelecting {
    private let environment: [String: String]
    private let fallback: DealerSelecting

    init(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        fallback: DealerSelecting = RandomDealerSelector()
    ) {
        self.environment = environment
        self.fallback = fallback
    }

    func selectDealer() -> Seat {
        guard let rawSeat = environment["TARNEEB_INITIAL_DEALER"]?.lowercased(),
              let forcedSeat = Seat(rawValue: rawSeat) else {
            return fallback.selectDealer()
        }

        return forcedSeat
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

struct PostBiddingSummary: Equatable, Hashable {
    let highBidderSeat: Seat
    let teamLabel: String
    let bidValue: BidValue
    let tarneebSuit: Suit

    var tarneebSymbol: String {
        tarneebSuit.displaySymbol
    }

    init(highBidderSeat: Seat, bidValue: BidValue, tarneebSuit: Suit) {
        self.highBidderSeat = highBidderSeat
        self.teamLabel = highBidderSeat.highBiddingTeamLabel
        self.bidValue = bidValue
        self.tarneebSuit = tarneebSuit
    }
}

struct GameState: Equatable {
    let phase: GamePhase
    let players: [Player]
    let dealerSeat: Seat
    let deck: [Card]?
    let biddingState: BiddingState?
    let postBiddingSummary: PostBiddingSummary?

    var bids: [Seat: BidState] {
        biddingState?.bids ?? [:]
    }

    var currentBiddingSeat: Seat? {
        biddingState?.currentTurnSeat
    }

    var highestBidSeat: Seat? {
        biddingState?.highestBidSeat
    }

    var highestBidValue: BidValue? {
        biddingState?.highestBidValue
    }

    var biddingStatus: BiddingRoundStatus? {
        biddingState?.status
    }

    var biddingCompletionOutcome: BiddingCompletionOutcome? {
        biddingState?.completionOutcome
    }

    init?(
        phase: GamePhase,
        players: [Player],
        dealerSeat: Seat,
        deck: [Card]? = nil,
        biddingState: BiddingState? = nil,
        postBiddingSummary: PostBiddingSummary? = nil
    ) {
        guard players.count == 4 else {
            return nil
        }

        if phase == .dealt {
            guard GameState.isValidCompletedDeal(players: players, deck: deck) else {
                return nil
            }

            guard let biddingState,
                  Set(biddingState.bids.keys) == Set(Seat.allCases),
                  biddingState.status == .inProgress || biddingState.status == .complete else {
                return nil
            }
        } else if biddingState != nil {
            return nil
        } else if postBiddingSummary != nil {
            return nil
        }

        self.phase = phase
        self.players = players
        self.dealerSeat = dealerSeat
        self.deck = deck
        self.biddingState = biddingState
        self.postBiddingSummary = postBiddingSummary
    }

    static var initial: GameState {
        initial(dealerSeat: EnvironmentDealerSelector().selectDealer())
    }

    static func initial(dealerSeat: Seat) -> GameState {
        guard let state = GameState(phase: .notStarted, players: Player.initialPlayers(), dealerSeat: dealerSeat) else {
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

    func replacingBiddingState(_ biddingState: BiddingState, postBiddingSummary: PostBiddingSummary? = nil) -> GameState {
        guard let updatedState = GameState(
            phase: phase,
            players: players,
            dealerSeat: dealerSeat,
            deck: deck,
            biddingState: biddingState,
            postBiddingSummary: postBiddingSummary
        ) else {
            preconditionFailure("Bidding state replacement must preserve a valid dealt game state.")
        }

        return updatedState
    }
}

struct DealService: Dealing {
    private let shuffler: CardShuffling
    private let handLogger: HandLogging

    init(
        shuffler: CardShuffling = StandardCardShuffler(),
        bidGenerator: BidGenerating = RandomBidGenerator(),
        southDefaultBid: BidValue = .pass,
        handLogger: HandLogging = ConsoleHandLogger()
    ) {
        self.shuffler = shuffler
        self.handLogger = handLogger
    }

    func deal(dealerSeat: Seat) -> GameState? {
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

        handLogger.logHands(players)

        return GameState(
            phase: .dealt,
            players: players,
            dealerSeat: dealerSeat,
            deck: [],
            biddingState: .started(dealerSeat: dealerSeat)
        )
    }
}

struct ConsoleHandLogger: HandLogging {
    func logHands(_ players: [Player]) {
        for seat in Seat.dealOrder {
            guard let player = players.first(where: { $0.seat == seat }) else {
                continue
            }

            let cards = player.hand.map { "\($0.rank.displayLabel)\($0.suit.displaySymbol)" }.joined(separator: " ")
            print("\(seat.displayLabel) hand: \(cards)")
        }
    }
}

struct HandLogger: HandLogging {
    private let log: ([Player]) -> Void

    init(_ log: @escaping ([Player]) -> Void) {
        self.log = log
    }

    func logHands(_ players: [Player]) {
        log(players)
    }
}

enum PresentationAction: String, CaseIterable, Equatable {
    case newGame
    case deal

    var visibleLabel: String {
        switch self {
        case .newGame:
            return "New Game"
        case .deal:
            return "Deal"
        }
    }
}

final class TarneebPresentationState {
    private let dealService: Dealing
    private let dealerSelector: DealerSelecting
    private let biddingService: BiddingService
    private var isDealing = false

    private(set) var gameState: GameState

    var availableActions: [PresentationAction] {
        [.newGame, .deal]
    }

    init(
        dealService: Dealing = DealService(),
        dealerSelector: DealerSelecting = EnvironmentDealerSelector(),
        biddingService: BiddingService = BiddingService()
    ) {
        self.dealService = dealService
        self.dealerSelector = dealerSelector
        self.biddingService = biddingService
        self.gameState = .initial(dealerSeat: dealerSelector.selectDealer())
    }

    func deal() {
        guard !isDealing else {
            return
        }

        isDealing = true
        defer {
            isDealing = false
        }

        let dealerForDeal: Seat
        if gameState.phase == .dealt {
            dealerForDeal = gameState.dealerSeat.nextCounterclockwiseDealer
            gameState = .initial(dealerSeat: dealerForDeal)
        } else {
            dealerForDeal = gameState.dealerSeat
        }

        guard let dealtState = dealService.deal(dealerSeat: dealerForDeal) else {
            return
        }

        gameState = dealtState
    }

    func automaticRedealAfterAllPass() {
        guard gameState.biddingCompletionOutcome == .allPassRedeal else {
            return
        }

        deal()
    }

    func newGame() {
        guard !isDealing else {
            return
        }

        gameState = .initial(dealerSeat: dealerSelector.selectDealer())
    }

    func submitSouthBid(_ bid: BidValue, selectedTarneebSuit: Suit? = nil) {
        gameState = biddingService.submitSouthBid(bid, selectedTarneebSuit: selectedTarneebSuit, in: gameState)
    }

    func resolveNextSimulatedBid() {
        gameState = biddingService.resolveNextSimulatedBid(in: gameState)
    }
}
