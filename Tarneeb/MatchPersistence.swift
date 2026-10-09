import Foundation

enum CoachPreference {
    static let key = "tarneeb.coachEnabled"
    static func enabled(in defaults: UserDefaults = .standard) -> Bool { defaults.bool(forKey: key) }
}

struct CurrentHandCoach: Codable, Equatable {
    let handID: UUID
    private(set) var openCount: Int
    init(handID: UUID = UUID(), openCount: Int = 0) {
        self.handID = handID
        self.openCount = openCount
    }
    mutating func recordOpen() {
        if openCount < Int.max { openCount += 1 }
    }
    var resultCopy: String {
        "You checked the played-card tracker \(openCount) \(openCount == 1 ? "time" : "times") this hand."
    }
}

/// The modal receives this value, never GameState, a hand, saved JSON or strategy input.
struct PlayedTrackerSnapshot: Equatable {
    static let suits: [Suit] = [.spades, .hearts, .clubs, .diamonds]
    static let ranks = Array(Rank.allCases.reversed())
    let handID: UUID
    let played: Set<Card>
    init?(handID: UUID, publicPlays: [PlayedCard]) {
        let cards = publicPlays.map(\.card)
        let unique = Set(cards)
        guard unique.count == cards.count, unique.isSubset(of: Set(DeckFactory.makeCanonicalDeck())) else { return nil }
        self.handID = handID
        self.played = unique
    }
    func count(in suit: Suit) -> Int { played.filter { $0.suit == suit }.count }
    func summary(for suit: Suit) -> String {
        let seen = Self.ranks.filter { played.contains(Card(suit: suit, rank: $0)) }.map(\.displayLabel)
        let unseen = Self.ranks.filter { !played.contains(Card(suit: suit, rank: $0)) }.map(\.displayLabel)
        return "\(suit.rawValue.capitalized), \(seen.count) played. Played: \(seen.isEmpty ? "none" : seen.joined(separator: ", ")). Not yet played: \(unseen.isEmpty ? "none" : unseen.joined(separator: ", "))."
    }
}

struct PlayedTrackerAvailability {
    let enabled: Bool
    let active: Bool
    let paused: Bool
    let confirming: Bool
    let flying: Bool
    let southTask: Bool
    let collecting: Bool
    let visibleMatchesAuthority: Bool
    let playing: Bool
    let southTurn: Bool
    let pendingTrick: Bool
    var canOpen: Bool {
        enabled && active && !paused && !confirming && !flying && !southTask && !collecting
            && visibleMatchesAuthority && playing && southTurn && !pendingTrick
    }
}

struct PlayedTrackerPresentation: Identifiable {
    let id: UUID
    let snapshot: PlayedTrackerSnapshot
}

struct MatchSnapshot: Codable, Equatable {
    var version = 2
    let game: GameState
    let score: GameScore
    let lastRound: RoundScoreResult?
    let completedRounds: Int
    let hasStarted: Bool
    let announcedRound: Int?
    // Optional on disk for v1 migration. New snapshots always write a concrete value.
    var activeAISkill: AISkill? = .standard
    var currentHandCoach: CurrentHandCoach? = nil
    var coachMetadataWasInvalid = false

    enum CodingKeys: String, CodingKey {
        case version, game, score, lastRound, completedRounds, hasStarted, announcedRound, activeAISkill, currentHandCoach
    }

    var restoredAISkill: AISkill { version == 1 ? .standard : (activeAISkill ?? .standard) }

    func validated() throws -> MatchSnapshot {
        guard (1...2).contains(version), (version == 1 || activeAISkill != nil), (0...1_000_000).contains(completedRounds),
              announcedRound.map({ (0...completedRounds).contains($0) }) ?? true,
              GameState(phase: game.phase, players: game.players, dealerSeat: game.dealerSeat,
                        deck: game.deck, biddingState: game.biddingState,
                        postBiddingSummary: game.postBiddingSummary, trickPlayState: game.trickPlayState) == game,
              hasStarted == (game.phase != .notStarted),
              (-completedRounds * 26...completedRounds * 26).contains(score.northSouth),
              (-completedRounds * 26...completedRounds * 26).contains(score.eastWest),
              hasStarted || completedRounds == 0,
              (completedRounds == 0) == (lastRound == nil),
              score.winnerTeam == nil || game.phase == .handComplete else { throw MatchStoreError.invalidSave }
        if let lastRound {
            guard TarneebScoringService().scoreRound(declaringTeam: lastRound.declaringTeam, bid: lastRound.bid,
                                                    declaringTricks: lastRound.declaringTricks) == lastRound else { throw MatchStoreError.invalidSave }
            let previous = GameScore(northSouth: score.northSouth - lastRound.scoreDelta(for: .teamA),
                                     eastWest: score.eastWest - lastRound.scoreDelta(for: .teamB))
            let previousBounds = (-16 * (completedRounds - 1))...(26 * (completedRounds - 1))
            guard previousBounds.contains(previous.northSouth), previousBounds.contains(previous.eastWest),
                  previous.winnerTeam == nil else { throw MatchStoreError.invalidSave }
        }
        if let summary = game.postBiddingSummary,
           summary != PostBiddingSummary(highBidderSeat: summary.highBidderSeat, bidValue: summary.bidValue, tarneebSuit: summary.tarneebSuit) {
            throw MatchStoreError.invalidSave
        }
        if game.phase == .handComplete {
            guard completedRounds > 0, TarneebScoringService().scoreRound(in: game) == lastRound else { throw MatchStoreError.invalidSave }
        }
        if let bidding = game.biddingState {
            guard Set(bidding.bids.keys) == Set(Seat.allCases),
                  (bidding.highestBidSeat == nil) == (bidding.highestBidValue == nil),
                  bidding.highestBidValue != .pass else { throw MatchStoreError.invalidSave }
            if let highest = bidding.highestBidSeat {
                guard bidding.bids[highest]?.resolvedValue == bidding.highestBidValue else { throw MatchStoreError.invalidSave }
                if bidding.status == .complete, highest != .south, game.postBiddingSummary == nil { throw MatchStoreError.invalidSave }
            }
            if bidding.status == .inProgress {
                guard let turn = bidding.currentTurnSeat, bidding.bids[turn]?.isPass == false,
                      turn != bidding.highestBidSeat else { throw MatchStoreError.invalidSave }
            } else if bidding.currentTurnSeat != nil { throw MatchStoreError.invalidSave }
            if bidding.status == .complete, bidding.highestBidSeat == nil,
               !bidding.bids.values.allSatisfy(\.isPass) { throw MatchStoreError.invalidSave }
        }
        if let trick = game.trickPlayState {
            // Rebuild the original hands and replay public plays to validate order and follow-suit.
            var hands = Dictionary(uniqueKeysWithValues: game.players.map { ($0.seat, $0.hand) })
            for play in trick.playedCards { hands[play.seat, default: []].append(play.card) }
            var replay = TrickPlayState(declarerSeat: trick.declarerSeat, tarneebSuit: trick.tarneebSuit)
            func apply(_ play: PlayedCard) throws {
                guard replay.currentTurnSeat == play.seat,
                      let hand = hands[play.seat], let index = hand.firstIndex(of: play.card) else { throw MatchStoreError.invalidSave }
                if let led = replay.ledSuit, play.card.suit != led, hand.contains(where: { $0.suit == led }) { throw MatchStoreError.invalidSave }
                hands[play.seat]?.remove(at: index)
                replay.appendPlayedCard(play)
            }
            for completed in trick.completedTricks {
                for play in completed.playedCards { try apply(play) }
                guard replay.pendingCompletedTrick == completed else { throw MatchStoreError.invalidSave }
                replay.clearPendingCompletedTrick()
            }
            for play in trick.currentTrick { try apply(play) }
            guard replay == trick else { throw MatchStoreError.invalidSave }
        }
        return self
    }
}

extension MatchSnapshot {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        version = try values.decode(Int.self, forKey: .version)
        game = try values.decode(GameState.self, forKey: .game)
        score = try values.decode(GameScore.self, forKey: .score)
        lastRound = try values.decodeIfPresent(RoundScoreResult.self, forKey: .lastRound)
        completedRounds = try values.decode(Int.self, forKey: .completedRounds)
        hasStarted = try values.decode(Bool.self, forKey: .hasStarted)
        announcedRound = try values.decodeIfPresent(Int.self, forKey: .announcedRound)
        activeAISkill = try values.decodeIfPresent(AISkill.self, forKey: .activeAISkill)
        if values.contains(.currentHandCoach), !(try values.decodeNil(forKey: .currentHandCoach)) {
            if let metadata = try? values.decode(CurrentHandCoach.self, forKey: .currentHandCoach), metadata.openCount >= 0 {
                currentHandCoach = metadata
            } else {
                currentHandCoach = nil
                coachMetadataWasInvalid = true
            }
        }
    }
}

enum MatchStoreError: Error { case invalidSave }

struct MatchStore {
    let url: URL

    static var standard: MatchStore {
        MatchStore(url: FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Tarneeb/match-v1.json"))
    }

    func load() throws -> MatchSnapshot? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        let data = try Data(contentsOf: url)
        guard data.count <= 1_000_000 else { throw MatchStoreError.invalidSave }
        return try JSONDecoder().decode(MatchSnapshot.self, from: data).validated()
    }

    func save(_ snapshot: MatchSnapshot) throws {
        let data = try JSONEncoder().encode(snapshot)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: url, options: .atomic)
    }
}
