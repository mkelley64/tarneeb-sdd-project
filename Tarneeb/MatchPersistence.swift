import Foundation

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
