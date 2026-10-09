import Foundation
import AVFoundation
import ImageIO
import XCTest
import SwiftUI
@testable import Tarneeb
import Darwin

extension TarneebTests {
    @MainActor
    func testLaunchScreenLayout() throws {
        XCTAssertEqual(Bundle.main.object(forInfoDictionaryKey: "UILaunchStoryboardName") as? String, "LaunchScreen")
        for size in [CGSize(width: 320, height: 568), CGSize(width: 393, height: 852), CGSize(width: 430, height: 932)] {
            let vc = try XCTUnwrap(UIStoryboard(name: "LaunchScreen", bundle: .main).instantiateInitialViewController())
            vc.loadViewIfNeeded(); vc.view.frame = CGRect(origin: .zero, size: size); vc.view.layoutIfNeeded()
            XCTAssertTrue(vc.view.subviews.isEmpty, "System handoff must contain no branded splash or progress UI")
            XCTAssertNil(vc.view.viewWithTag(100)); XCTAssertNil(vc.view.viewWithTag(101))
            XCTAssertFalse(vc.view.hasAmbiguousLayout)
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            try XCTUnwrap(vc.view.backgroundColor).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            XCTAssertEqual(red, 16.0 / 255, accuracy: 0.001)
            XCTAssertEqual(green, 60.0 / 255, accuracy: 0.001)
            XCTAssertEqual(blue, 49.0 / 255, accuracy: 0.001)
            XCTAssertEqual(alpha, 1, accuracy: 0.001)
            let image = UIGraphicsImageRenderer(size: size).image { _ in vc.view.drawHierarchy(in: vc.view.bounds, afterScreenUpdates: true) }
            let attachment = XCTAttachment(image: image); attachment.name = "Forest launch handoff \(Int(size.width))x\(Int(size.height))"
            attachment.lifetime = .keepAlways; add(attachment)
        }
    }

    func testOpeningArrivalStartsOnceOnlyOnFreshReadyActiveTable() throws {
        var arrival = OpeningArrival()
        XCTAssertNil(arrival.begin(eligible: true, ready: true, active: false, blocked: false, reduceMotion: false))
        XCTAssertNil(arrival.begin(eligible: true, ready: false, active: true, blocked: false, reduceMotion: false))
        XCTAssertNil(arrival.begin(eligible: true, ready: true, active: true, blocked: true, reduceMotion: false))
        let id = try XCTUnwrap(arrival.begin(eligible: true, ready: true, active: true, blocked: false, reduceMotion: false))
        XCTAssertTrue(arrival.permitsFeedback(id, ready: true, active: true, blocked: false, reduceMotion: false))
        XCTAssertNil(arrival.begin(eligible: true, ready: true, active: true, blocked: false, reduceMotion: false))
    }

    func testOpeningArrivalCancellationRejectsLateSquareAndResume() throws {
        var arrival = OpeningArrival()
        let id = try XCTUnwrap(arrival.begin(eligible: true, ready: true, active: true, blocked: false, reduceMotion: false))
        arrival.cancel()
        XCTAssertFalse(arrival.permitsFeedback(id, ready: true, active: true, blocked: false, reduceMotion: false))
        XCTAssertNil(arrival.begin(eligible: true, ready: true, active: true, blocked: false, reduceMotion: false))
    }

    func testOpeningArrivalReducedMotionNeverStartsOrEmitsFeedback() {
        var arrival = OpeningArrival()
        XCTAssertNil(arrival.begin(eligible: true, ready: true, active: true, blocked: false, reduceMotion: true))
        XCTAssertTrue(arrival.consumed)
        XCTAssertNil(arrival.generation)
        XCTAssertNil(arrival.begin(eligible: true, ready: true, active: true, blocked: false, reduceMotion: false))
    }

    func testOpeningArrivalRestoredTableIsIneligible() {
        var arrival = OpeningArrival()
        XCTAssertNil(arrival.begin(eligible: false, ready: true, active: true, blocked: false, reduceMotion: false))
        XCTAssertNil(arrival.generation)
    }

    func testOpeningArrivalFeedbackRequiresCurrentActiveUnblockedReadyGeneration() throws {
        var arrival = OpeningArrival()
        let id = try XCTUnwrap(arrival.begin(eligible: true, ready: true, active: true, blocked: false, reduceMotion: false))
        for flags in [(false, true, false, false), (true, false, false, false), (true, true, true, false), (true, true, false, true)] {
            XCTAssertFalse(arrival.permitsFeedback(id, ready: flags.0, active: flags.1, blocked: flags.2, reduceMotion: flags.3))
        }
        XCTAssertFalse(arrival.permitsFeedback(UUID(), ready: true, active: true, blocked: false, reduceMotion: false))
        arrival.finish(id)
        XCTAssertFalse(arrival.permitsFeedback(id, ready: true, active: true, blocked: false, reduceMotion: false))
    }

    /// Explicit device diagnostic. No defaults, saves or actual app match are mutated.
    @MainActor
    func testPhysicalExpertLatency() async throws {
        #if targetEnvironment(simulator)
        throw XCTSkip("Physical-device profiling only")
        #else
        func distribution(_ values: [Double]) -> [String: Double] {
            let s = values.sorted()
            func q(_ p: Double) -> Double { s.isEmpty ? 0 : s[Int(Double(s.count-1)*p)] }
            return ["count":Double(s.count),"median":q(0.5),"p95":q(0.95),"p99":q(0.99),"max":s.last ?? 0]
        }
        // Baseline cadence is measured separately; neither is an animation/frame-time metric.
        var idle: [Double] = []
        for _ in 0..<50 {
            let start = ProcessInfo.processInfo.systemUptime
            try await Task.sleep(nanoseconds:10_000_000)
            idle.append((ProcessInfo.processInfo.systemUptime-start)*1000)
        }
        var heartbeat: [Double] = []
        let pulse = Task { @MainActor in
            var last = ProcessInfo.processInfo.systemUptime
            while !Task.isCancelled {
                do { try await Task.sleep(nanoseconds:10_000_000) } catch { break }
                let now = ProcessInfo.processInfo.systemUptime
                heartbeat.append((now-last)*1000); last = now
            }
        }
        var wall: [Double] = [], observedWall: [Double] = [], cpu: [Double] = [], gaps: [Double] = []
        var baseFallbacks = 0, observedFallbacks = 0, mismatches = 0
        var records: [[String:Any]] = []
        for deck in 520000..<520064 {
            var rng = AISeededGenerator(state:UInt64(deck))
            let cards = DeckFactory.makeCanonicalDeck().shuffled(using:&rng)
            for (index,seat) in Seat.dealOrder.enumerated() {
                let c = AIDecisionContext(seat:seat,ownHand:Array(cards[(index*13)..<(index*13+13)]),
                    trick:TrickPlayState(declarerSeat:seat,tarneebSuit:Suit.allCases[(deck+index)%4]),
                    contract:7+(deck+index)%7,matchScore:(deck+index)%2 == 0 ? GameScore() : GameScore(northSouth:30,eastWest:29))
                // Search seed uses only own cards and public context, not the deck seed.
                let tokens = c.ownHand.map(\.id).sorted() + [seat.rawValue,c.trick.tarneebSuit.rawValue,
                    String(c.contract),String(c.matchScore.northSouth),String(c.matchScore.eastWest)]
                let seed = tokens.joined(separator:":").utf8.reduce(UInt64(14695981039346656037)) { ($0 ^ UInt64($1)) &* 1099511628211 }
                func ordinary() async -> (AIDecisionResult,Double) {
                    let start = ProcessInfo.processInfo.systemUptime
                    let result = await AIDecisionEngine.detached(c,skill:.expert,seed:seed)
                    return (result,(ProcessInfo.processInfo.systemUptime-start)*1000)
                }
                func observed() async -> (AIDecisionResult,Double,Double,Double,Int) {
                    await Task.detached(priority:.userInitiated) {
                        func cpuTime() -> Double {
                            var t = timespec()
                            precondition(clock_gettime(CLOCK_THREAD_CPUTIME_ID,&t) == 0)
                            return Double(t.tv_sec)+Double(t.tv_nsec)/1_000_000_000
                        }
                        let start = ProcessInfo.processInfo.systemUptime, firstCPU = cpuTime()
                        var last = start, gap = 0.0, checkpoints = 0
                        func observe() {
                            let now = ProcessInfo.processInfo.systemUptime
                            gap = max(gap,now-last); last = now; checkpoints += 1
                        }
                        let result = ExpertCardPolicy.select(c,seed:seed,shouldCancel:{ observe(); return Task.isCancelled })
                        observe()
                        return (result,(last-start)*1000,(cpuTime()-firstCPU)*1000,gap*1000,checkpoints-1)
                    }.value
                }
                let base: (AIDecisionResult,Double), seen: (AIDecisionResult,Double,Double,Double,Int)
                if records.count%2 == 0 { base = await ordinary(); seen = await observed() }
                else { seen = await observed(); base = await ordinary() }
                XCTAssertFalse(base.0.cancelled); XCTAssertFalse(seen.0.cancelled)
                XCTAssertTrue(c.legalCards.contains(try XCTUnwrap(base.0.card)))
                XCTAssertTrue(c.legalCards.contains(try XCTUnwrap(seen.0.card)))
                let same = base.0.card == seen.0.card && base.0.samples == seen.0.samples && base.0.fallback == seen.0.fallback
                if !base.0.fallback && !seen.0.fallback { XCTAssertTrue(same) }
                if !same { mismatches += 1 }
                if base.0.fallback { baseFallbacks += 1 }; if seen.0.fallback { observedFallbacks += 1 }
                wall.append(base.1); observedWall.append(seen.1); cpu.append(seen.2); gaps.append(seen.3)
                records.append(["index":records.count,"searchSeed":String(seed),"seat":seat.rawValue,
                    "ownHand":c.ownHand.map(\.id),"trump":c.trick.tarneebSuit.rawValue,"contract":c.contract,
                    "northSouth":c.matchScore.northSouth,"eastWest":c.matchScore.eastWest,
                    "wallMS":base.1,"observedWallMS":seen.1,"threadCPUMS":seen.2,"maxGapMS":seen.3,
                    "checkpoints":seen.4,"card":base.0.card!.id,"observedCard":seen.0.card!.id,
                    "fallback":base.0.fallback,"observedFallback":seen.0.fallback,"same":same])
            }
        }
        pulse.cancel(); await pulse.value
        XCTAssertEqual(records.count,256)
        XCTAssertFalse(heartbeat.isEmpty,"Main actor continued servicing heartbeat during detached searches")
        let report: [String:Any] = ["protocol":"physical-opening-latency-2026-09-20","positions":256,
            "device":UIDevice.current.model,"systemVersion":UIDevice.current.systemVersion,
            "thermalStateAtEnd":ProcessInfo.processInfo.thermalState.rawValue,
            "ordinaryRoundTripMS":distribution(wall),"observedWorkerMS":distribution(observedWall),
            "observedThreadCPUMS":distribution(cpu),"maxCheckpointGapMS":distribution(gaps),
            "idleHeartbeatMS":distribution(idle),"loadedHeartbeatMS":distribution(heartbeat),
            "fallbacks":baseFallbacks,"observedFallbacks":observedFallbacks,"mismatches":mismatches,"records":records]
        let data = try JSONSerialization.data(withJSONObject:report,options:[.sortedKeys])
        let attachment = XCTAttachment(data:data,uniformTypeIdentifier:"public.json")
        attachment.name = "physical-opening-latency.json"; attachment.lifetime = .keepAlways; add(attachment)
        print("PHYSICAL_LATENCY_JSON " + String(decoding:data,as:UTF8.self))
        #endif
    }
}

final class TarneebTests: XCTestCase {
    func testRoomOwnershipIncludesPendingPartnerWinExactlyOnce() {
        let north = CompletedTrick(leaderSeat: .south, winnerSeat: .north, ledSuit: .spades, playedCards: [])
        let south = CompletedTrick(leaderSeat: .south, winnerSeat: .south, ledSuit: .spades, playedCards: [])
        let east = CompletedTrick(leaderSeat: .east, winnerSeat: .east, ledSuit: .spades, playedCards: [])
        let previous = [south, south, south, north, east, east]
        let pending = RoomTrickOwnership(trick: TrickPlayState(declarerSeat: .south, tarneebSuit: .spades, pendingCompletedTrick: north, completedTricks: previous))
        let collected = RoomTrickOwnership(trick: TrickPlayState(declarerSeat: .south, tarneebSuit: .spades, completedTricks: previous + [north]))
        XCTAssertEqual(pending.count(for: Team.forSeat(.south)), 5)
        XCTAssertEqual(pending.count(for: .south), 3)
        XCTAssertEqual(pending.count(for: Team.forSeat(.east)), 2)
        for seat in Seat.allCases { XCTAssertEqual(pending.count(for: seat), collected.count(for: seat)) }
    }

    func testFeedbackIdentityGatePreventsReplayAndResetsOnlyForNewMatch() {
        var gate = FeedbackEventGate()
        XCTAssertTrue(gate.accept("match1-round0-trick0-land-card"))
        XCTAssertFalse(gate.accept("match1-round0-trick0-land-card"))
        XCTAssertTrue(gate.accept("match1-round0-trick0-collect"))
        XCTAssertFalse(gate.accept("match1-round0-trick0-collect"))
        XCTAssertTrue(gate.accept("match1-round1-trick0-land-card"))
        gate.reset()
        XCTAssertTrue(gate.accept("match1-round0-trick0-land-card"))
    }

    func testRoomGeometryCollectionEndsBelowPartnerLabelAcrossPhoneSizes() {
        for size in [CGSize(width: 351, height: 228), CGSize(width: 378, height: 328), CGSize(width: 416, height: 400)] {
            let geometry = RoomTableGeometry(size: size)
            for seat in Seat.allCases {
                XCTAssertTrue(CGRect(origin: .zero, size: size).contains(geometry.slot(seat)))
                XCTAssertTrue(CGRect(origin: .zero, size: size).contains(geometry.collection(seat)))
            }
            XCTAssertGreaterThan(geometry.collection(.north).y, geometry.station(.north).y + 30)
            XCTAssertLessThan(geometry.slot(.west).x, geometry.slot(.north).x)
            XCTAssertGreaterThan(geometry.slot(.east).x, geometry.slot(.north).x)
        }
    }

    func testExpertRolloutIsStableWhileFallbackUsesRevisedAdvanced() {
        let c = AIDecisionContext(seat: .south, ownHand: [Card(suit: .clubs,rank: .two),
            Card(suit: .clubs,rank: .seven),Card(suit: .clubs,rank: .ace)],
            trick: TrickPlayState(declarerSeat: .south,tarneebSuit: .spades,currentTurnSeat: .south,
                currentTrick: [PlayedCard(seat: .west,card: Card(suit: .clubs,rank: .six))]), contract: 7,matchScore: GameScore())
        XCTAssertEqual(AdvancedCardPolicy.select(c), Card(suit: .clubs,rank: .seven))
        XCTAssertEqual(ExpertRolloutCardPolicy.select(c), Card(suit: .clubs,rank: .ace))
        let fallback = ExpertCardPolicy.select(c,seed: 1,limits: AISearchLimits(seconds: 0))
        XCTAssertTrue(fallback.fallback)
        XCTAssertEqual(fallback.card, AdvancedCardPolicy.select(c))
    }

    func testAdvancedPublicVoidProtectionHasIndependentEvidenceBoundaries() {
        func card(_ suit: Suit, _ rank: Rank) -> Card { Card(suit: suit, rank: rank) }
        let void = CompletedTrick(leaderSeat: .south, winnerSeat: .east, ledSuit: .clubs, playedCards: [
            PlayedCard(seat: .south, card: card(.clubs,.two)), PlayedCard(seat: .east, card: card(.spades,.two)),
            PlayedCard(seat: .north, card: card(.clubs,.three)), PlayedCard(seat: .west, card: card(.clubs,.four))])
        let trumpVoid = CompletedTrick(leaderSeat: .south, winnerSeat: .west, ledSuit: .spades, playedCards: [
            PlayedCard(seat: .south, card: card(.spades,.three)), PlayedCard(seat: .east, card: card(.diamonds,.three)),
            PlayedCard(seat: .north, card: card(.spades,.four)), PlayedCard(seat: .west, card: card(.spades,.five))])
        let plays = [PlayedCard(seat: .north, card: card(.clubs,.queen)), PlayedCard(seat: .west, card: card(.clubs,.six))]
        func context(_ history: [CompletedTrick], hand: [Card]? = nil, current: [PlayedCard]? = nil) -> AIDecisionContext {
            AIDecisionContext(seat: .south, ownHand: hand ?? [card(.spades,.ace),card(.diamonds,.two)],
                trick: TrickPlayState(declarerSeat: .south, tarneebSuit: .spades, currentTurnSeat: .south,
                    currentTrick: current ?? plays, completedTricks: history), contract: 7, matchScore: GameScore())
        }
        XCTAssertEqual(AdvancedCardPolicy.select(context([void])), card(.spades,.ace))
        XCTAssertEqual(AdvancedCardPolicy.select(context([])), card(.diamonds,.two))
        XCTAssertEqual(AdvancedCardPolicy.select(context([void,trumpVoid])), card(.diamonds,.two))
        let info = PublicCardInference(context([void]))
        XCTAssertTrue(info.hasDemonstratedRuffRisk(for: .east, ledSuit: .clubs, winningCard: card(.clubs,.queen), trump: .spades))
        XCTAssertFalse(info.hasDemonstratedRuffRisk(for: .east, ledSuit: .spades, winningCard: card(.spades,.three), trump: .spades))
        XCTAssertFalse(info.hasDemonstratedRuffRisk(for: .east, ledSuit: .clubs, winningCard: card(.spades,.ace), trump: .spades))
        XCTAssertTrue(info.hasDemonstratedRuffRisk(for: .east, ledSuit: .clubs, winningCard: card(.spades,.three), trump: .spades))
        let exhausted = PublicCardInference(context([void], hand: Rank.allCases.filter { $0 != .two }.map { card(.spades,$0) }))
        XCTAssertFalse(exhausted.hasDemonstratedRuffRisk(for: .east, ledSuit: .clubs, winningCard: card(.clubs,.queen), trump: .spades))
        // West has already acted (discarding on clubs); South must not spend
        // its ace to guard against an opponent whose turn is over.
        let fourth = context([], current: [PlayedCard(seat: .east, card: card(.clubs,.five)),
            PlayedCard(seat: .north, card: card(.clubs,.queen)), PlayedCard(seat: .west, card: card(.diamonds,.six))])
        XCTAssertTrue(PublicCardInference(fourth).hasDemonstratedRuffRisk(for: .west, ledSuit: .clubs,
            winningCard: card(.clubs,.queen), trump: .spades))
        XCTAssertEqual(AdvancedCardPolicy.select(fourth), card(.diamonds,.two))
    }

    func testAdvancedKeepsEconomicalWinnersAndLongSuitEstablishment() {
        func card(_ suit: Suit, _ rank: Rank) -> Card { Card(suit: suit, rank: rank) }
        let second = AIDecisionContext(seat: .south, ownHand: [card(.clubs,.two),card(.clubs,.seven),card(.clubs,.ace)],
            trick: TrickPlayState(declarerSeat: .south, tarneebSuit: .spades, currentTurnSeat: .south,
                currentTrick: [PlayedCard(seat: .west, card: card(.clubs,.six))]), contract: 7, matchScore: GameScore())
        XCTAssertEqual(AdvancedCardPolicy.select(second), card(.clubs,.seven))
        let long = AIDecisionContext(seat: .south,
            ownHand: [card(.clubs,.three),card(.clubs,.four),card(.clubs,.jack),card(.clubs,.queen),card(.clubs,.king),card(.diamonds,.two)],
            trick: TrickPlayState(declarerSeat: .south, tarneebSuit: .spades), contract: 7, matchScore: GameScore())
        XCTAssertEqual(AdvancedCardPolicy.select(long)?.suit, .clubs)
    }

    private func biddingSweepContext() -> AIBiddingContext {
        AIBiddingContext(auction: BidRecommendationContext(seat: .east,
            hand: Rank.allCases.map { Card(suit: .spades, rank: $0) }, partnerSeat: .west,
            currentHighestBidValue: nil, currentHighestBidder: nil,
            priorBidStates: Dictionary(uniqueKeysWithValues: Seat.allCases.map { ($0, $0 == .east ? BidState.pending : .resolved(.pass)) })), matchScore: GameScore())
    }

    func testBiddingLevelsPreserveStandardAndRecognizeCertainSweep() {
        let context = biddingSweepContext()
        let baseline = AutomatedBidRecommender().recommendation(for: context.auction)
        let request = AIBidRequest(id: UUID(), revision: UUID(), context: context, skill: .standard,
            baseline: baseline, useSkillPolicy: true)
        XCTAssertEqual(AIBiddingEngine.select(request, seed: 9).recommendation, baseline)
        XCTAssertEqual(AdvancedBidPolicy.select(context).bid, .thirteen)
        let expert = ExpertBidPolicy.select(context, seed: 9, limits: AIBidSearchLimits(samples: 4, seconds: 5))
        XCTAssertFalse(expert.fallback)
        XCTAssertEqual(expert.recommendation.bid, .thirteen)
        XCTAssertEqual(expert.recommendation.preferredTarneebSuit, .spades)
    }

    func testBiddingSamplingConservationSeedsAndFallback() throws {
        let context = biddingSweepContext()
        var rng = AISeededGenerator(state: 91), repeated = AISeededGenerator(state: 91)
        let hands = try XCTUnwrap(BiddingHandSampler.sample(context, using: &rng))
        XCTAssertEqual(hands, BiddingHandSampler.sample(context, using: &repeated))
        XCTAssertEqual(hands[.east], context.auction.hand)
        XCTAssertTrue(hands.values.allSatisfy { $0.count == 13 })
        XCTAssertEqual(Set(hands.values.flatMap { $0 }), Set(DeckFactory.makeCanonicalDeck()))
        let first = ExpertBidPolicy.select(context, seed: 4, limits: AIBidSearchLimits(samples: 4, seconds: 5))
        let second = ExpertBidPolicy.select(context, seed: 4, limits: AIBidSearchLimits(samples: 4, seconds: 5))
        XCTAssertFalse(first.fallback)
        XCTAssertEqual(first.recommendation, second.recommendation)
        let fallback = ExpertBidPolicy.select(context, seed: 4, limits: AIBidSearchLimits(seconds: 0))
        XCTAssertTrue(fallback.fallback)
        XCTAssertEqual(fallback.recommendation, AdvancedBidPolicy.select(context))
    }

    func testBiddingDetachedCancellation() async {
        let context = biddingSweepContext()
        let request = AIBidRequest(id: UUID(), revision: UUID(), context: context, skill: .expert,
            baseline: AutomatedBidRecommender().recommendation(for: context.auction), useSkillPolicy: true)
        let task = Task { await AIBiddingEngine.detached(request, seed: 19) }
        task.cancel()
        let result = await task.value
        XCTAssertTrue(result.cancelled)
    }

    func testBiddingLevelFreezesAndRejectsStaleResults() throws {
        let name = "bid-lifecycle-\(UUID().uuidString)"
        let prefs = try XCTUnwrap(UserDefaults(suiteName: name))
        defer { prefs.removePersistentDomain(forName: name) }
        prefs.set("advanced", forKey: AISkill.preferenceKey)
        let model = TarneebPresentationState(dealService: DealService(handLogger: HandLogger { _ in }),
            dealerSelector: EnvironmentDealerSelector(environment: ["TARNEEB_INITIAL_DEALER":"south"]), aiPreferences: prefs)
        model.deal()
        prefs.set("expert", forKey: AISkill.preferenceKey)
        let first = try XCTUnwrap(model.prepareAIBidDecision())
        let current = try XCTUnwrap(model.prepareAIBidDecision())
        XCTAssertEqual(current.skill, .advanced)
        XCTAssertTrue(current.useSkillPolicy)
        let pass = AIBidResult(recommendation: BidRecommendation(bid: .pass), samples: 0, fallback: false, cancelled: false)
        XCTAssertFalse(model.applyAIBidDecision(pass, request: first))
        XCTAssertTrue(model.applyAIBidDecision(pass, request: current))
        XCTAssertFalse(model.applyAIBidDecision(pass, request: current))
        let stale = try XCTUnwrap(model.prepareAIBidDecision())
        XCTAssertEqual(stale.context.auction.seat, .north)
        XCTAssertEqual(stale.skill, .advanced)
        model.newGame()
        XCTAssertEqual(model.activeAISkill, .expert)
        XCTAssertFalse(model.applyAIBidDecision(pass, request: stale))
    }

    func testAISkillDefaultsMigrationAndFirstDealFreezing() throws {
        let suite = "ai-skill-\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        XCTAssertEqual(AISkill.preference(in: defaults), .standard)
        let model = TarneebPresentationState(aiPreferences: defaults)
        defaults.set(AISkill.advanced.rawValue, forKey: AISkill.preferenceKey)
        model.deal()
        XCTAssertEqual(model.activeAISkill, .advanced)
        defaults.set(AISkill.expert.rawValue, forKey: AISkill.preferenceKey)
        XCTAssertEqual(model.activeAISkill, .advanced)
        let data = try JSONEncoder().encode(model.snapshot)
        XCTAssertEqual(try JSONDecoder().decode(MatchSnapshot.self, from: data).validated().restoredAISkill, .advanced)
        var old = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        old["version"] = 1
        old.removeValue(forKey: "activeAISkill")
        let legacy = try JSONDecoder().decode(MatchSnapshot.self, from: JSONSerialization.data(withJSONObject: old))
        XCTAssertEqual(try legacy.validated().restoredAISkill, .standard)
        model.newGame()
        XCTAssertEqual(model.activeAISkill, .expert)
        defaults.set(AISkill.standard.rawValue, forKey: AISkill.preferenceKey)
        model.deal()
        XCTAssertEqual(model.activeAISkill, .expert)
    }

    func testAdvancedDrawsTrumpWithoutChangingStandardLead() {
        let hand = [Card(suit: .spades, rank: .ace), Card(suit: .spades, rank: .king),
                    Card(suit: .spades, rank: .five), Card(suit: .clubs, rank: .two)]
        let context = AIDecisionContext(seat: .south, ownHand: hand,
            trick: TrickPlayState(declarerSeat: .south, tarneebSuit: .spades), contract: 7, matchScore: GameScore())
        XCTAssertEqual(context.standard(), Card(suit: .clubs, rank: .two))
        XCTAssertEqual(AdvancedCardPolicy.select(context), Card(suit: .spades, rank: .king))
        let fallback = ExpertCardPolicy.select(context, seed: 17, limits: AISearchLimits(seconds: 0))
        XCTAssertTrue(fallback.fallback)
        XCTAssertEqual(fallback.card, AdvancedCardPolicy.select(context))
    }

    func testExpertDetachedCancellationPropagates() async {
        let hand = Array(DeckFactory.makeCanonicalDeck().prefix(13))
        let context = AIDecisionContext(seat: .south, ownHand: hand,
            trick: TrickPlayState(declarerSeat: .south, tarneebSuit: .spades), contract: 7, matchScore: GameScore())
        let task = Task { await AIDecisionEngine.detached(context, skill: .expert, seed: 17) }
        task.cancel()
        let result = await task.value
        XCTAssertTrue(result.cancelled)
    }

    func testContractProgressMilestonesRespectDeclaringTeamAndRemainingTricks() throws {
        for seat in Seat.allCases {
            let summary = PostBiddingSummary(highBidderSeat: seat, bidValue: .seven, tarneebSuit: .spades)
            let teammate = Seat.allCases.first { $0 != seat && Team.forSeat($0) == Team.forSeat(seat) }!
            let opponent = Seat.allCases.first { Team.forSeat($0) != Team.forSeat(seat) }!
            for (wins, losses, expected) in [(0, 0, ContractProgressPresentation.Milestone.building),
                                           (6, 0, .oneAway), (7, 0, .secured), (8, 0, .secured),
                                           (6, 7, .missed), (2, 7, .missed)] {
                let tricks = (0..<(wins + losses)).map { index in
                    CompletedTrick(leaderSeat: seat, winnerSeat: index < wins ? teammate : opponent, ledSuit: .spades, playedCards: [])
                }
                let progress = try XCTUnwrap(ContractProgressPresentation(summary: summary, trick: TrickPlayState(declarerSeat: seat, tarneebSuit: .spades, completedTricks: tricks)))
                XCTAssertEqual(progress.won, wins)
                XCTAssertEqual(progress.remaining, 13 - wins - losses)
                XCTAssertEqual(progress.milestone, expected)
                XCTAssertTrue(progress.visibleLabel.contains("\(wins) / 7"))
                XCTAssertEqual(progress.fraction, min(1, Double(wins) / 7), accuracy: 0.001)
                XCTAssertTrue(progress.accessibilityValue.contains(summary.teamLabel))
            }
        }
        XCTAssertNil(ContractProgressPresentation(summary: nil, trick: nil))
        XCTAssertNil(ContractProgressPresentation(summary: PostBiddingSummary(highBidderSeat: .south, bidValue: .pass, tarneebSuit: .spades), trick: TrickPlayState(declarerSeat: .south, tarneebSuit: .spades)))
    }

    func testPendingWinningTrickSecuresContractWithoutDoubleCountingOnCollection() throws {
        for bid in [BidValue.seven, .thirteen] {
            let target = try XCTUnwrap(bid.numericValue)
            let summary = PostBiddingSummary(highBidderSeat: .south, bidValue: bid, tarneebSuit: .spades)
            let winner = CompletedTrick(leaderSeat: .south, winnerSeat: .south, ledSuit: .spades, playedCards: [])
            let tricks = Array(repeating: winner, count: target - 1)
            let before = try XCTUnwrap(ContractProgressPresentation(summary: summary, trick: TrickPlayState(declarerSeat: .south, tarneebSuit: .spades, completedTricks: tricks)))
            let pending = try XCTUnwrap(ContractProgressPresentation(summary: summary, trick: TrickPlayState(declarerSeat: .south, tarneebSuit: .spades, pendingCompletedTrick: winner, completedTricks: tricks)))
            let collected = try XCTUnwrap(ContractProgressPresentation(summary: summary, trick: TrickPlayState(declarerSeat: .south, tarneebSuit: .spades, completedTricks: tricks + [winner])))
            XCTAssertEqual(before.milestone, .oneAway)
            XCTAssertEqual(pending.milestone, .secured)
            XCTAssertEqual(pending, collected)
        }
    }

    func testCircularFeltFitsAvailableSpaceAndSharesTrickCenter() {
        for size in [CGSize(width: 351, height: 232), CGSize(width: 369, height: 500), CGSize(width: 560, height: 300)] {
            let felt = CircularTableGeometry(size: size)
            XCTAssertEqual(felt.diameter, min(size.width - 36, size.height - 40))
            let circle = CGRect(x: felt.center.x - felt.diameter / 2, y: felt.center.y - felt.diameter / 2, width: felt.diameter, height: felt.diameter)
            XCTAssertTrue(CGRect(origin: .zero, size: size).contains(circle))
            let slots = LiveTrickGeometry(size: size)
            XCTAssertEqual((slots.slot(.east).x + slots.slot(.west).x) / 2, felt.center.x)
            XCTAssertEqual((slots.slot(.north).y + slots.slot(.south).y) / 2, felt.center.y)
        }
        XCTAssertEqual(CircularTableGeometry(size: .zero).diameter, 0)
    }

    func testTableFinishRemainsSubtleAndUsesSpacedStaticWeave() {
        XCTAssertGreaterThan(TableFinishToken.weaveSpacing, TableFinishToken.weaveLength * 2)
        XCTAssertGreaterThan(TableFinishToken.weaveLength, 0)
        XCTAssertLessThanOrEqual(TableFinishToken.weaveOpacity, 0.05)
        XCTAssertGreaterThan(TableFinishToken.rimInset, TableFinishToken.hairline)
        XCTAssertLessThanOrEqual(TableFinishToken.rimOpacity, 0.2)
        for opacity in [TableFinishToken.fillOpacity, TableFinishToken.edgeOpacity,
                        TableFinishToken.rimOpacity, TableFinishToken.dividerOpacity] {
            XCTAssertTrue((0...1).contains(opacity))
        }
    }

    func testTableCommandFinishFitsExistingTouchTargets() {
        XCTAssertLessThanOrEqual(TableCommandToken.cornerRadius, 8)
        XCTAssertGreaterThan(TableCommandToken.rimInset, 0)
        XCTAssertLessThan(TableCommandToken.rimInset, TableCommandToken.cornerRadius)
        XCTAssertGreaterThan(TableCommandToken.depth, 0)
        XCTAssertLessThan(TableCommandToken.depth, OpeningTableToken.controlHeight / 8)
        XCTAssertGreaterThanOrEqual(OpeningTableToken.controlHeight, 44)
        XCTAssertGreaterThanOrEqual(RoundResultToken.commandHeight, 44)
        XCTAssertLessThanOrEqual(TableCommandToken.pressDuration, 0.2)
        XCTAssertTrue((0...1).contains(TableCommandToken.rimOpacity))
        XCTAssertTrue((0...1).contains(TableCommandToken.disabledOpacity))
    }

    @MainActor
    func testCardPlayersUseQuickerPlaybackWithoutChangingChimesOrVolume() throws {
        for event in TableFeedback.Event.allCases {
            for index in 0..<PaperSoundVariation.count {
                let player = try TableFeedback.makePlayer(event, variation: PaperSoundVariation(index: index), bundle: Bundle(for: TarneebTests.self))
                XCTAssertEqual(player.volume, event.volume)
                if event.recordingPrefix != nil {
                    XCTAssertTrue(player.enableRate)
                    XCTAssertEqual(player.rate, 1.2, accuracy: 0.001)
                    XCTAssertLessThan(player.duration / Double(player.rate), event == .collect ? 0.60 : 0.20)
                } else {
                    XCTAssertFalse(player.enableRate)
                    XCTAssertEqual(player.rate, 1)
                }
            }
        }
    }

    func testQuickerCardTimingRetainsReadableWinnerAndReducedMotion() {
        XCTAssertEqual(LiveTableToken.flightDuration, 0.40)
        XCTAssertEqual(LiveTableToken.landingPause, 0.10)
        XCTAssertEqual(LiveTableToken.winnerHold, 0.85)
        XCTAssertEqual(LiveTableToken.collectionDuration, 0.44)
        XCTAssertEqual(LiveTableToken.reducedMotionDuration, 0.12)
        XCTAssertGreaterThan(LiveTableToken.winnerHold, LiveTableToken.collectionDuration)
        let revealDuration = 12 * GameAnimationToken.dealSouthRevealFlipStagger.seconds + GameAnimationToken.dealSouthRevealFlipDuration.seconds
        XCTAssertEqual(revealDuration, GameAnimationToken.dealSouthRevealTotalDuration.seconds, accuracy: 0.001)
    }

    @MainActor
    func testBundledCardRecordingsDecodeAndVaryWithoutClipping() throws {
        let bundle = Bundle(for: TarneebTests.self)
        for event in [TableFeedback.Event.select, .land, .collect] {
            var variants = Set<Data>()
            for index in 0..<PaperSoundVariation.count {
                let variation = PaperSoundVariation(index: index)
                let url = try XCTUnwrap(TableFeedback.recordingURL(event, variation: variation, bundle: bundle))
                let data = TableFeedback.soundData(event, variation: variation, bundle: bundle)
                XCTAssertEqual(data, try Data(contentsOf: url), "Must use bundled foley, not synthesized fallback")
                variants.insert(data)
                let player = try AVAudioPlayer(data: data)
                XCTAssertGreaterThan(player.duration, 0.08)
                XCTAssertLessThan(player.duration, event == .collect ? 0.75 : 0.25)
                let file = try AVAudioFile(forReading: url)
                let buffer = try XCTUnwrap(AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length)))
                try file.read(into: buffer)
                let channel = try XCTUnwrap(buffer.floatChannelData?[0])
                let values = Array(UnsafeBufferPointer(start: channel, count: Int(buffer.frameLength)))
                let peak = values.map { abs($0) }.max() ?? 0
                XCTAssertGreaterThan(peak, 0.1)
                XCTAssertLessThanOrEqual(peak, 0.61)
                XCTAssertLessThan(abs(values.first ?? 1), 0.001)
                XCTAssertLessThan(abs(values.last ?? 1), 0.001)
            }
            XCTAssertEqual(variants.count, PaperSoundVariation.count)
            XCTAssertGreaterThan(event.volume, 0)
            XCTAssertLessThan(event.volume, 1)
        }
    }

    @MainActor
    func testMissingCardRecordingsFallBackAndOutcomeResponsesUseSynthesizedAudio() {
        let withoutRecordings = Bundle(for: NSObject.self)
        let variation = PaperSoundVariation(index: 0)
        for event in TableFeedback.Event.allCases {
            XCTAssertNil(TableFeedback.recordingURL(event, variation: variation, bundle: withoutRecordings))
            XCTAssertEqual(TableFeedback.soundData(event, variation: variation, bundle: withoutRecordings),
                           TableFeedback.synthesizedSoundData(event, variation: variation))
        }
        for event in [TableFeedback.Event.roundWin, .roundLoss, .matchWin] {
            XCTAssertNil(TableFeedback.recordingURL(event, variation: variation, bundle: Bundle(for: TarneebTests.self)))
            XCTAssertEqual(TableFeedback.soundData(event, variation: variation, bundle: Bundle(for: TarneebTests.self)),
                           TableFeedback.synthesizedSoundData(event, variation: variation))
            XCTAssertEqual(event.volume, 1)
        }
    }

    @MainActor
    func testGeneratedPaperSoundsHaveDistinctValidSamplesAndStableOutcomeResponses() {
        for event in TableFeedback.Event.allCases {
            let samples = (0..<3).map { TableFeedback.synthesizedSoundData(event, variation: PaperSoundVariation(index: $0)) }
            for data in samples {
                XCTAssertEqual(String(data: data.prefix(4), encoding: .utf8), "RIFF")
                XCTAssertEqual(String(data: data[8..<12], encoding: .utf8), "WAVE")
                XCTAssertEqual(data.count, 44 + Int(event.duration * 22_050) * 2)
                XCTAssertTrue(data.dropFirst(44).contains { $0 != 0 })
            }
            switch event {
            case .select, .land, .collect, .openingSquare: XCTAssertEqual(Set(samples).count, 3)
            case .roundWin, .defenseWin, .roundLoss, .matchWin: XCTAssertEqual(Set(samples).count, 1)
            }
        }
    }

    func testPublicHistoryPromotesWinnersAndAvoidsKnownVoidOpponents() {
        let king = Card(suit: .clubs, rank: .king)
        let discard = Card(suit: .diamonds, rank: .two)
        let options = [king, discard]
        let safeHistory = CompletedTrick(leaderSeat: .south, winnerSeat: .south, ledSuit: .clubs, playedCards: [
            PlayedCard(seat: .south, card: Card(suit: .clubs, rank: .ace)),
            PlayedCard(seat: .east, card: Card(suit: .clubs, rank: .two)),
            PlayedCard(seat: .north, card: Card(suit: .clubs, rank: .three)),
            PlayedCard(seat: .west, card: Card(suit: .clubs, rank: .four))
        ])
        XCTAssertEqual(AutomatedCardSelector.select(from: options, for: .east, currentTrick: [], tarneebSuit: .spades, ownHand: options), discard)
        XCTAssertEqual(AutomatedCardSelector.select(from: options, for: .east, currentTrick: [], tarneebSuit: .spades, ownHand: options, completedTricks: [safeHistory]), king)
        let voidHistory = CompletedTrick(leaderSeat: .south, winnerSeat: .north, ledSuit: .clubs, playedCards: [
            safeHistory.playedCards[0], safeHistory.playedCards[1],
            PlayedCard(seat: .north, card: Card(suit: .spades, rank: .two)), safeHistory.playedCards[3]
        ])
        XCTAssertEqual(AutomatedCardSelector.select(from: options, for: .east, currentTrick: [], tarneebSuit: .spades, ownHand: options, completedTricks: [voidHistory]), discard)
        let allRemainingTrump = Rank.allCases.filter { $0 != .two }.map { Card(suit: .spades, rank: $0) }
        XCTAssertEqual(AutomatedCardSelector.select(from: options, for: .east, currentTrick: [], tarneebSuit: .spades, ownHand: options + allRemainingTrump, completedTricks: [voidHistory]), king)
    }

    func testThirdSeatStrengthensVulnerablePartnerButKeepsSafePartnerWinner() {
        let ace = Card(suit: .clubs, rank: .ace)
        let low = Card(suit: .clubs, rank: .two)
        let options = [ace, low]
        let queenLead = [PlayedCard(seat: .south, card: Card(suit: .clubs, rank: .queen)), PlayedCard(seat: .east, card: Card(suit: .clubs, rank: .three))]
        XCTAssertEqual(AutomatedCardSelector.select(from: options, for: .north, currentTrick: queenLead, tarneebSuit: .spades, ownHand: options), ace)
        let kingLead = [PlayedCard(seat: .south, card: Card(suit: .clubs, rank: .king)), queenLead[1]]
        XCTAssertEqual(AutomatedCardSelector.select(from: options, for: .north, currentTrick: kingLead, tarneebSuit: .spades, ownHand: options), low)
    }

    func testOpponentPacingAndPaperVariationsAreBounded() {
        let low = Card(suit: .clubs, rank: .two)
        let high = Card(suit: .clubs, rank: .ace)
        let trick = [PlayedCard(seat: .south, card: Card(suit: .clubs, rank: .king))]
        let forced = OpponentPacing.delay(legalCards: [low], selected: low, seat: .east, trick: trick, trump: .spades)
        let discard = OpponentPacing.delay(legalCards: [low, high], selected: low, seat: .east, trick: trick, trump: .spades)
        let win = OpponentPacing.delay(legalCards: [low, high], selected: high, seat: .east, trick: trick, trump: .spades)
        XCTAssertGreaterThan(forced, 0)
        XCTAssertLessThan(forced, discard)
        XCTAssertLessThan(discard, win)
        XCTAssertLessThanOrEqual(win, 0.6)
        XCTAssertEqual(Set((0..<3).map { PaperSoundVariation(index: $0).seed }).count, 3)
        for index in -6...6 {
            let variation = PaperSoundVariation(index: index)
            XCTAssertTrue((0..<3).contains(variation.index))
            XCTAssertTrue((0.6...0.7).contains(variation.smoothing))
            XCTAssertEqual(variation.seed, PaperSoundVariation(index: index + 3).seed)
        }
    }

    func testSavedMatchRoundTripsCommandsAndPendingFinalCollectionExactlyOnce() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathComponent("match.json")
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
        let store = MatchStore(url: url)
        XCTAssertNil(try store.load())
        let game = TarneebPresentationState(
            dealService: DealService(shuffler: CardShuffler { $0 }, handLogger: HandLogger { _ in }),
            dealerSelector: EnvironmentDealerSelector(environment: ["TARNEEB_INITIAL_DEALER": "west"]),
            biddingService: BiddingService(bidGenerator: BidGenerator { _ in .pass })
        )
        game.enablePersistence(store)
        func verifyRestore() throws {
            XCTAssertEqual(try store.load(), game.snapshot)
            let restored = TarneebPresentationState()
            restored.enablePersistence(store)
            XCTAssertNil(restored.saveNotice)
            XCTAssertEqual(restored.snapshot, game.snapshot)
        }
        game.deal()
        try verifyRestore()
        game.submitSouthBid(.seven)
        for _ in 0..<3 { game.resolveNextSimulatedBid(); try verifyRestore() }
        XCTAssertNil(game.gameState.postBiddingSummary)
        game.submitSouthTarneebSuit(.spades)
        try verifyRestore()
        game.startTrickPlayIfReady()
        for round in 0..<13 {
            for _ in 0..<4 {
                let state = game.gameState
                if state.currentTrickTurnSeat == .south {
                    game.playSouthCard(try XCTUnwrap(TrickPlayRules.legalCards(for: .south, in: state).first))
                } else { game.resolveNextSimulatedTrickPlay() }
                try verifyRestore()
            }
            if round < 12 { game.clearCompletedTrickIfNeeded(); try verifyRestore() }
        }
        XCTAssertEqual(game.completedRoundCount, 0)
        let resumed = TarneebPresentationState()
        resumed.enablePersistence(store)
        resumed.clearCompletedTrickIfNeeded()
        XCTAssertEqual(resumed.completedRoundCount, 1)
        XCTAssertEqual(resumed.gameScore.northSouth, 16)
        resumed.markRoundAnnounced()
        let scored = TarneebPresentationState()
        scored.enablePersistence(store)
        scored.clearCompletedTrickIfNeeded()
        XCTAssertEqual(scored.snapshot, resumed.snapshot)
        XCTAssertEqual(scored.announcedRound, 1)
        scored.startNextRound()
        XCTAssertEqual(scored.gameScore.northSouth, 16)
        XCTAssertEqual(scored.gameState.dealerSeat, .south)
        XCTAssertNotNil(try store.load())
        scored.newGame()
        let reset = TarneebPresentationState()
        reset.enablePersistence(store)
        XCTAssertEqual(reset.gameState.phase, .notStarted)
        XCTAssertEqual(reset.gameScore, GameScore())
        XCTAssertNil(reset.announcedRound)
    }

    func testSavedMatchRejectsCorruptionVersionsIllegalPlayAndStorageFailures() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathComponent("match.json")
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
        let store = MatchStore(url: url)
        let initial = TarneebPresentationState(dealerSelector: EnvironmentDealerSelector(environment: ["TARNEEB_INITIAL_DEALER": "west"]))
        try store.save(initial.snapshot)
        var version = initial.snapshot
        version.version = 99
        try store.save(version)
        XCTAssertThrowsError(try store.load())
        let invalidScore = MatchSnapshot(game: initial.gameState, score: GameScore(northSouth: Int.min), lastRound: nil, completedRounds: 0, hasStarted: false, announcedRound: nil)
        XCTAssertThrowsError(try invalidScore.validated())
        try Data("not json".utf8).write(to: url)
        let fallback = TarneebPresentationState()
        fallback.enablePersistence(store)
        XCTAssertNotNil(fallback.saveNotice)
        XCTAssertEqual(fallback.gameState.phase, .notStarted)
        let blockedStore = MatchStore(url: url.appendingPathComponent("unwritable.json"))
        fallback.enablePersistence(blockedStore, restoring: false)
        XCTAssertNotNil(fallback.saveNotice)

        let dealt = try makeRoundRobinCompletedDeal()
        let contract = try makeContractState(from: dealt, highBidderSeat: .south, bidValue: .seven, tarneebSuit: .hearts)
        let valid = TrickPlayService().playSouthCard(Card(suit: .spades, rank: .six), in: contract.startingTrickPlayIfReady())
        let wrongTurn = TrickPlayState(declarerSeat: .south, tarneebSuit: .hearts, currentTurnSeat: .west, currentTrick: try XCTUnwrap(valid.trickPlayState).currentTrick)
        let invalidGame = try XCTUnwrap(GameState(phase: .trickPlay, players: valid.players, dealerSeat: valid.dealerSeat, deck: [], biddingState: valid.biddingState, postBiddingSummary: valid.postBiddingSummary, trickPlayState: wrongTurn))
        let invalidSnapshot = MatchSnapshot(game: invalidGame, score: GameScore(), lastRound: nil, completedRounds: 0, hasStarted: true, announcedRound: nil)
        XCTAssertThrowsError(try invalidSnapshot.validated())
        let noTrump = BiddingState(bids: [.south: .resolved(.pass), .east: .resolved(.seven), .north: .resolved(.pass), .west: .resolved(.pass)], currentTurnSeat: nil, highestBidSeat: .east, highestBidValue: .seven, status: .complete)
        let stalled = try XCTUnwrap(GameState(phase: .dealt, players: dealt.players, dealerSeat: dealt.dealerSeat, deck: [], biddingState: noTrump))
        XCTAssertThrowsError(try MatchSnapshot(game: stalled, score: GameScore(), lastRound: nil, completedRounds: 0, hasStarted: true, announcedRound: nil).validated())
    }

    func testOpponentTacticalChoicesAndStableOrdering() {
        func card(_ suit: Suit, _ rank: Rank) -> Card { Card(suit: suit, rank: rank) }
        func play(_ seat: Seat, _ suit: Suit, _ rank: Rank) -> PlayedCard {
            PlayedCard(seat: seat, card: card(suit, rank))
        }
        let cases: [(String, Seat, [PlayedCard], [Card], Card?)] = [
            ("North preserves South's winner", .north,
             [play(.south, .clubs, .king), play(.east, .clubs, .three)],
             [card(.clubs, .ace), card(.clubs, .two)], card(.clubs, .two)),
            ("West preserves East's winner", .west,
             [play(.south, .clubs, .three), play(.east, .clubs, .nine), play(.north, .clubs, .two)],
             [card(.clubs, .king), card(.clubs, .four)], card(.clubs, .four)),
            ("Do not trump a partner", .north,
             [play(.south, .clubs, .ace), play(.east, .clubs, .three)],
             [card(.spades, .two), card(.diamonds, .nine)], card(.diamonds, .nine)),
            ("Do not overtrump a partner", .west,
             [play(.south, .clubs, .ace), play(.east, .spades, .seven), play(.north, .clubs, .two)],
             [card(.spades, .eight), card(.spades, .two)], card(.spades, .two)),
            ("Cheapest second-seat winner", .east, [play(.south, .clubs, .six)],
             [card(.clubs, .queen), card(.clubs, .two), card(.clubs, .seven)], card(.clubs, .seven)),
            ("Cheapest last-seat winner", .west,
             [play(.south, .clubs, .nine), play(.east, .clubs, .two), play(.north, .clubs, .jack)],
             [card(.clubs, .ace), card(.clubs, .three), card(.clubs, .queen)], card(.clubs, .queen)),
            ("Following suit cannot beat a trump", .north,
             [play(.south, .clubs, .king), play(.east, .spades, .five)],
             [card(.clubs, .ace), card(.clubs, .two)], card(.clubs, .two)),
            ("Trump an opponent cheaply when void", .east, [play(.south, .clubs, .king)],
             [card(.diamonds, .two), card(.spades, .queen), card(.spades, .three)], card(.spades, .three)),
            ("Overtrump an opponent cheaply", .west,
             [play(.south, .clubs, .king), play(.east, .clubs, .two), play(.north, .spades, .five)],
             [card(.diamonds, .two), card(.spades, .three), card(.spades, .queen), card(.spades, .six)], card(.spades, .six)),
            ("Cannot overtrump: save remaining trump", .west,
             [play(.south, .clubs, .king), play(.east, .clubs, .two), play(.north, .spades, .ace)],
             [card(.spades, .two), card(.diamonds, .seven)], card(.diamonds, .seven)),
            ("Cannot overtrump with only trumps left", .west,
             [play(.south, .clubs, .king), play(.east, .clubs, .two), play(.north, .spades, .ace)],
             [card(.spades, .king), card(.spades, .two)], card(.spades, .two)),
            ("Off-suit ace is not a winner", .east, [play(.south, .clubs, .king)],
             [card(.diamonds, .ace), card(.diamonds, .two)], card(.diamonds, .two)),
            ("Trump-led trick still uses cheapest winner", .east, [play(.south, .spades, .six)],
             [card(.spades, .ace), card(.spades, .two), card(.spades, .seven)], card(.spades, .seven)),
            ("Lead policy stays conservative", .east, [],
             [card(.spades, .two), card(.clubs, .nine), card(.diamonds, .two)], card(.diamonds, .two)),
            ("Forced losing card", .east, [play(.south, .clubs, .ace)],
             [card(.clubs, .king)], card(.clubs, .king)),
            ("No legal moves", .east, [], [], nil)
        ]
        for (name, seat, trick, legal, expected) in cases {
            for options in [legal, Array(legal.reversed())] {
                XCTAssertEqual(AutomatedCardSelector.select(from: options, for: seat, currentTrick: trick, tarneebSuit: .spades), expected, name)
            }
        }
        let tiedDiscards = [card(.diamonds, .two), card(.clubs, .two)]
        XCTAssertEqual(
            AutomatedCardSelector.select(from: tiedDiscards, for: .east, currentTrick: [], tarneebSuit: .spades),
            AutomatedCardSelector.select(from: Array(tiedDiscards.reversed()), for: .east, currentTrick: [], tarneebSuit: .spades)
        )
    }

    func testOpponentServiceFollowsSuitWinsEconomicallyAndCannotSeeHiddenHands() throws {
        let dealt = try makeRoundRobinCompletedDeal()
        let contract = try makeContractState(from: dealt, highBidderSeat: .south, bidValue: .seven, tarneebSuit: .hearts)
        let service = TrickPlayService()
        let aceLead = service.playSouthCard(Card(suit: .spades, rank: .ace), in: contract.startingTrickPlayIfReady())
        XCTAssertTrue(try player(in: aceLead, seat: .east).hand.contains { $0.suit == .hearts })
        XCTAssertEqual(
            service.playSimulatedTurn(in: aceLead).trickPlayState?.playedCard(for: .east)?.card,
            Card(suit: .spades, rank: .three)
        )
        let state = service.playSouthCard(Card(suit: .spades, rank: .six), in: contract.startingTrickPlayIfReady())
        let result = service.playSimulatedTurn(in: state)
        let expected = Card(suit: .spades, rank: .seven)
        XCTAssertEqual(result.trickPlayState?.playedCard(for: .east)?.card, expected)
        XCTAssertEqual(result.currentTrickTurnSeat, .north)
        XCTAssertEqual(try player(in: result, seat: .east).hand.count, 12)
        for seat in [Seat.south, .north, .west] {
            XCTAssertEqual(try player(in: state, seat: seat), try player(in: result, seat: seat))
        }

        var swappedPlayers = state.players
        let north = try XCTUnwrap(swappedPlayers.firstIndex { $0.seat == .north })
        let west = try XCTUnwrap(swappedPlayers.firstIndex { $0.seat == .west })
        let northHand = swappedPlayers[north].hand
        swappedPlayers[north].hand = swappedPlayers[west].hand
        swappedPlayers[west].hand = northHand
        let swapped = try XCTUnwrap(GameState(
            phase: state.phase, players: swappedPlayers, dealerSeat: state.dealerSeat, deck: state.deck,
            biddingState: state.biddingState, postBiddingSummary: state.postBiddingSummary, trickPlayState: state.trickPlayState
        ))
        XCTAssertEqual(service.playSimulatedTurn(in: swapped).trickPlayState?.playedCard(for: .east)?.card, expected)
    }

    func testOpponentServiceLeavesHumanAndCollectionBoundariesUntouched() throws {
        let service = TrickPlayService()
        let initial = GameState.initial(dealerSeat: .south)
        XCTAssertEqual(service.playSimulatedTurn(in: initial), initial)
        let dealt = try makeRoundRobinCompletedDeal()
        XCTAssertEqual(service.playSimulatedTurn(in: dealt), dealt)
        let contract = try makeContractState(from: dealt, highBidderSeat: .south, bidValue: .seven, tarneebSuit: .hearts)
        var state = contract.startingTrickPlayIfReady()
        XCTAssertEqual(service.playSimulatedTurn(in: state), state)
        let card = try XCTUnwrap(service.legalCards(for: .south, in: state).first)
        state = service.playSouthCard(card, in: state)
        for _ in 0..<3 { state = service.playSimulatedTurn(in: state) }
        XCTAssertTrue(state.isCurrentTrickComplete)
        XCTAssertEqual(service.playSimulatedTurn(in: state), state)
    }

    func testTacticalOpponentsCompleteHandsForEveryDeclarerAndTrumpWithoutLosingCards() throws {
        let service = TrickPlayService()
        for declarer in Seat.allCases {
            for trump in Suit.allCases {
                let dealt = try makeRoundRobinCompletedDeal()
                let contract = try makeContractState(from: dealt, highBidderSeat: declarer, bidValue: .seven, tarneebSuit: trump)
                var state = contract.startingTrickPlayIfReady()
                for _ in 0..<65 {
                    let before = state
                    if state.isCurrentTrickComplete {
                        state = service.clearCompletedTrickIfNeeded(in: state)
                    } else {
                        let seat = try XCTUnwrap(state.currentTrickTurnSeat)
                        let legal = service.legalCards(for: seat, in: state)
                        if seat == .south {
                            state = service.playSouthCard(try XCTUnwrap(legal.first), in: state)
                        } else {
                            state = service.playSimulatedTurn(in: state)
                        }
                        let played = try XCTUnwrap(state.trickPlayState?.playedCard(for: seat)?.card)
                        XCTAssertTrue(legal.contains(played))
                        XCTAssertEqual(state.players.flatMap(\.hand).count, before.players.flatMap(\.hand).count - 1)
                    }
                    XCTAssertNotEqual(state, before)
                    let cards = state.players.flatMap(\.hand) + (state.trickPlayState?.playedCards.map(\.card) ?? [])
                    XCTAssertEqual(cards.count, 52)
                    XCTAssertEqual(Set(cards), Set(DeckFactory.makeCanonicalDeck()))
                }
                XCTAssertEqual(state.phase, .handComplete)
                XCTAssertEqual(state.trickPlayState?.completedTrickCount, 13)
                XCTAssertTrue(state.players.allSatisfy { $0.hand.isEmpty })
                XCTAssertEqual(service.playSimulatedTurn(in: state), state)
                let result = try XCTUnwrap(TarneebScoringService().scoreRound(in: state))
                var score = GameScore()
                score.apply(result)
                let snapshot = MatchSnapshot(game: state, score: score, lastRound: result, completedRounds: 1, hasStarted: true, announcedRound: nil)
                XCTAssertNoThrow(try snapshot.validated())
                let corruptScore = MatchSnapshot(game: state, score: GameScore(), lastRound: result, completedRounds: 1, hasStarted: true, announcedRound: nil)
                XCTAssertThrowsError(try corruptScore.validated())
            }
        }
    }

    func testRoundResultPresentationPreservesAllScoringOutcomesAndPartnerships() throws {
        let service = TarneebScoringService()
        for team in [Team.teamA, .teamB] {
            for (bid, tricks) in [(7, 9), (8, 5), (7, 13), (7, 0), (13, 13), (13, 11)] {
                let result = try XCTUnwrap(service.scoreRound(declaringTeam: team, bid: bid, declaringTricks: tricks))
                let before = GameScore(northSouth: -12, eastWest: 4)
                var after = before
                after.apply(result)
                let summary = RoundResultPresentation(result: result, score: after)
                XCTAssertEqual(summary.contractMade, tricks >= bid)
                XCTAssertEqual(summary.contractTitle, tricks >= bid ? "Contract made" : "Contract missed")
                XCTAssertEqual(summary.playerSucceeded, (tricks >= bid) == (team == .teamA))
                XCTAssertFalse(summary.detail.isEmpty)
                for partnership in [Team.teamA, .teamB] {
                    XCTAssertEqual(summary.previousScore(for: partnership), before.points(for: partnership))
                    XCTAssertEqual(Int(summary.change(for: partnership)), result.scoreDelta(for: partnership))
                }
            }
        }
    }

    func testRoundResultPresentationIdentifiesEitherMatchWinner() throws {
        let result = try XCTUnwrap(TarneebScoringService().scoreRound(declaringTeam: .teamA, bid: 7, declaringTricks: 9))
        XCTAssertEqual(RoundResultPresentation(result: result, score: GameScore(northSouth: 31)).title, "You and North win!")
        XCTAssertEqual(RoundResultPresentation(result: result, score: GameScore(eastWest: 31)).title, "East-West win")
    }

    func testAutomaticSouthPlayRequiresLastCardAndItsLegalTurn() throws {
        let presentation = TarneebPresentationState(
            dealService: DealService(shuffler: CardShuffler { $0 }, handLogger: HandLogger { _ in }),
            dealerSelector: EnvironmentDealerSelector(environment: ["TARNEEB_INITIAL_DEALER": "west"]),
            biddingService: BiddingService(bidGenerator: BidGenerator { _ in .pass })
        )
        XCTAssertNil(TrickPlayRules.automaticSouthPlay(in: presentation.gameState))
        presentation.deal()
        presentation.submitSouthBid(.seven, selectedTarneebSuit: .spades)
        for _ in 0..<3 { presentation.resolveNextSimulatedBid() }
        presentation.startTrickPlayIfReady()
        for _ in 0..<12 {
            let state = presentation.gameState
            XCTAssertNil(TrickPlayRules.automaticSouthPlay(in: state))
            let card = try XCTUnwrap(state.players.first { $0.seat == .south }?.hand.first)
            presentation.playSouthCard(card)
            XCTAssertNil(TrickPlayRules.automaticSouthPlay(in: presentation.gameState))
            for _ in 0..<3 { presentation.resolveNextSimulatedTrickPlay() }
            XCTAssertNil(TrickPlayRules.automaticSouthPlay(in: presentation.gameState))
            presentation.clearCompletedTrickIfNeeded()
        }
        let state = presentation.gameState
        let card = try XCTUnwrap(TrickPlayRules.automaticSouthPlay(in: state))
        XCTAssertEqual(state.players.first { $0.seat == .south }?.hand, [card])
        presentation.playSouthCard(card)
        let afterPlay = presentation.gameState
        XCTAssertNil(TrickPlayRules.automaticSouthPlay(in: afterPlay))
        presentation.playSouthCard(card)
        XCTAssertEqual(presentation.gameState, afterPlay)
        for _ in 0..<3 { presentation.resolveNextSimulatedTrickPlay() }
        presentation.clearCompletedTrickIfNeeded()
        XCTAssertEqual(presentation.gameState.phase, .handComplete)
        XCTAssertNil(TrickPlayRules.automaticSouthPlay(in: presentation.gameState))
    }

    func testOpeningHandAndActionsFitSmallestPortraitHeight() {
        let hand = LiveHandLayout(width: 351)
        let fixedHeight = 36 + 24 + hand.height + OpeningTableToken.actionHeight + 16 + 8
        XCTAssertLessThanOrEqual(fixedHeight + OpeningTableToken.minimumTableHeight, 647)
        XCTAssertGreaterThanOrEqual(OpeningTableToken.controlHeight, 44)
    }

    func testLiveHandKeepsIndicesAndTouchTargetsExposedAtPhoneWidths() {
        for width in [351.0, 369, 406, 560] {
            let layout = LiveHandLayout(width: width)
            XCTAssertEqual(layout.columns, 7)
            XCTAssertGreaterThanOrEqual(layout.stride, LiveTableToken.minimumHitWidth)
            for count in 1...13 {
                for index in 0..<count {
                    let center = layout.center(at: index, cardCount: count)
                    XCTAssertGreaterThanOrEqual(center.x - LiveTableToken.cardWidth / 2, 0)
                    XCTAssertLessThanOrEqual(center.x + LiveTableToken.cardWidth / 2, width)
                    XCTAssertLessThanOrEqual(center.y + LiveTableToken.cardHeight / 2, layout.height)
                    if index % layout.columns != 0 {
                        let previous = layout.center(at: index - 1, cardCount: count)
                        XCTAssertGreaterThanOrEqual(center.x - previous.x, 44)
                    }
                }
            }
            XCTAssertEqual(layout.height, 180)
        }
    }

    func testLiveTrickSlotsDoNotOverlapAndRemainInsideTable() {
        for size in [CGSize(width: 351, height: 232), CGSize(width: 369, height: 350), CGSize(width: 560, height: 500)] {
            let geometry = LiveTrickGeometry(size: size)
            let rects = Seat.allCases.map { seat in
                let point = geometry.slot(seat)
                return CGRect(x: point.x - 32, y: point.y - 45, width: 64, height: 90)
            }
            for (index, rect) in rects.enumerated() {
                XCTAssertTrue(CGRect(origin: .zero, size: size).contains(rect))
                for other in rects.dropFirst(index + 1) { XCTAssertFalse(rect.intersects(other)) }
            }
        }
    }

    func testLiveTrickPresentationCanHoldEachLandingAndCollectExactlyOnce() throws {
        let presentation = TarneebPresentationState(
            dealService: DealService(shuffler: CardShuffler { $0 }, handLogger: HandLogger { _ in }),
            dealerSelector: EnvironmentDealerSelector(environment: ["TARNEEB_INITIAL_DEALER": "west"]),
            biddingService: BiddingService(bidGenerator: BidGenerator { _ in .pass })
        )
        presentation.deal()
        presentation.submitSouthBid(.seven, selectedTarneebSuit: .spades)
        for _ in 0..<3 { presentation.resolveNextSimulatedBid() }
        presentation.startTrickPlayIfReady()
        var visible = presentation.gameState
        let card = try XCTUnwrap(visible.players.first { $0.seat == .south }?.hand.first)
        for seat in Seat.dealOrder {
            if seat == .south { presentation.playSouthCard(card) }
            else { presentation.resolveNextSimulatedTrickPlay() }
            let next = presentation.gameState
            let played = try XCTUnwrap(next.trickPlayState?.playedCard(for: seat))
            var flight = LiveCardFlight(play: played)
            XCTAssertFalse(flight.arrived)
            XCTAssertTrue(visible.players.first { $0.seat == seat }!.hand.contains(played.card))
            XCTAssertFalse(next.players.first { $0.seat == seat }!.hand.contains(played.card))
            flight.arrived = true
            visible = next
            let allCards = visible.players.flatMap(\.hand) + (visible.trickPlayState?.playedCards.map(\.card) ?? [])
            XCTAssertEqual(allCards.count, 52)
            XCTAssertEqual(Set(allCards).count, 52)
        }
        XCTAssertEqual(visible.trickPlayState?.completedTricks.count, 0)
        XCTAssertEqual(visible.trickPlayState?.pendingCompletedTrick?.winnerSeat, .south)
        presentation.clearCompletedTrickIfNeeded()
        XCTAssertEqual(presentation.gameState.trickPlayState?.completedTricks.count, 1)
        XCTAssertEqual(presentation.gameState.currentTrickTurnSeat, .south)
        presentation.clearCompletedTrickIfNeeded()
        XCTAssertEqual(presentation.gameState.trickPlayState?.completedTricks.count, 1)
    }

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
            "color.trickPlay.slot.background",
            "color.trickPlay.slot.border",
            "color.trickPlay.activeSeat.outline",
            "color.trickPlay.legalCard.outline",
            "color.trickPlay.winnerHighlight.border",
            "color.trickPlay.count.background",
            "color.trickPlay.count.text",
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
            "effect.tableTitle.highlight.color",
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
            .trickPlaySlotBackground: .trickPlaySlotBackground,
            .trickPlaySlotBorder: .trickPlaySlotBorder,
            .trickPlayActiveSeatOutline: .trickPlayActiveSeatOutline,
            .trickPlayLegalCardOutline: .trickPlayLegalCardOutline,
            .trickPlayWinnerHighlightBorder: .trickPlayWinnerHighlightBorder,
            .trickPlayCountBackground: .trickPlayCountBackground,
            .trickPlayCountText: .trickPlayCountText,
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
            .tableTitleHighlight: .tableTitleHighlight,
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
        XCTAssertEqual(GameColorToken.tableTitleText.hexValue, "#BBAA7E")
        XCTAssertEqual(GameColorToken.tableTitleShadow.hexValue, "#000000")
        XCTAssertEqual(GameColorToken.tableTitleHighlight.hexValue, "#F2E8CE")
        XCTAssertEqual(GameEffectToken.tableTitleTextOpacity.value, 0.72)
        XCTAssertEqual(GameEffectToken.tableTitleShadowOpacity.value, 0.38)
        XCTAssertEqual(GameEffectToken.tableTitleShadowBlurRadius.value, 1.2)
        XCTAssertEqual(GameEffectToken.tableTitleShadowOffsetY.value, 1)
        XCTAssertEqual(GameEffectToken.tableTitleHighlightOpacity.value, 0.18)
        XCTAssertEqual(GameEffectToken.tableTitleHighlightBlurRadius.value, 0.8)
        XCTAssertEqual(GameEffectToken.tableTitleHighlightOffsetY.value, -1)
        XCTAssertEqual(GameEffectToken.bidButtonDisabledOpacity.value, 0.55)
        XCTAssertEqual(GameEffectToken.bidSuitSelectorDisabledOpacity.value, 0.55)
        XCTAssertEqual(GameEffectToken.tableCenterSurfaceOpacity.value, 0.16)
        XCTAssertEqual(GameEffectToken.tableInnerRingOpacity.value, 0.38)
        XCTAssertEqual(GameEffectToken.tableRailHighlightOpacity.value, 0.42)
        XCTAssertEqual(GameEffectToken.tableRailInnerBevelOpacity.value, 0.28)
        XCTAssertEqual(GameEffectToken.tableRailShadowOpacity.value, 0.24)
        XCTAssertEqual(GameEffectToken.tableRailShadowRadius.value, 6)
        XCTAssertEqual(GameEffectToken.tablePlayAreaShadowOpacity.value, 0.16)
        XCTAssertEqual(GameEffectToken.trickPlaySlotBackgroundOpacity.value, 0.34)
        XCTAssertEqual(GameEffectToken.trickPlaySlotBorderOpacity.value, 0.42)
        XCTAssertEqual(GameEffectToken.trickPlayActiveSlotBackgroundOpacity.value, 0.16)
        XCTAssertEqual(GameEffectToken.trickPlayActiveSlotOutlineOpacity.value, 0.88)
        XCTAssertEqual(GameEffectToken.trickPlayPlayedCardShadowOpacity.value, 0.28)
        XCTAssertEqual(GameEffectToken.trickPlayLegalCardOutlineOpacity.value, 0.95)
        XCTAssertEqual(GameEffectToken.trickPlayUnavailableSouthCardOpacity.value, 0.55)
        XCTAssertEqual(GameEffectToken.trickPlayWinnerHighlightOpacity.value, 0.30)
        XCTAssertEqual(GameEffectToken.southHandRailBackgroundOpacity.value, 0.14)
        XCTAssertEqual(GameEffectToken.southHandRailStrokeOpacity.value, 0.36)
        XCTAssertEqual(GameEffectToken.postBiddingSummaryBackgroundOpacity.value, 0.86)
        XCTAssertEqual(GameEffectToken.postBiddingSummaryBorderOpacity.value, 0.34)
        XCTAssertEqual(GameEffectToken.postBiddingSummaryShadowOpacity.value, 0.20)
        XCTAssertEqual(GameEffectToken.postBiddingSummaryShadowRadius.value, 5)
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
        XCTAssertEqual(GameEffectToken.bottomDealSecondaryOpacity.value, 0.62)
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
            "layout.postBiddingSummary.suitChip.padding.horizontal",
            "layout.postBiddingSummary.suitChip.padding.vertical",
            "layout.postBiddingSummary.outsideTableHorizontalOffsetRatio",
            "layout.postBiddingSummary.outsideTableVerticalOffsetRatio"
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
        XCTAssertEqual(GameBidLayoutToken.postBiddingSummarySuitChipHorizontalPadding.numericValue, 4)
        XCTAssertEqual(GameBidLayoutToken.postBiddingSummarySuitChipVerticalPadding.numericValue, 0)
        XCTAssertEqual(GameBidLayoutToken.postBiddingSummaryOutsideTableHorizontalOffsetRatio.numericValue, 0.62)
        XCTAssertEqual(GameBidLayoutToken.postBiddingSummaryOutsideTableVerticalOffsetRatio.numericValue, 0.70)
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
        XCTAssertEqual(summaryTokens.suitChipHorizontalPadding, .postBiddingSummarySuitChipHorizontalPadding)
        XCTAssertEqual(summaryTokens.suitChipVerticalPadding, .postBiddingSummarySuitChipVerticalPadding)
        XCTAssertEqual(summaryTokens.backgroundOpacity, .postBiddingSummaryBackgroundOpacity)
        XCTAssertEqual(summaryTokens.borderOpacity, .postBiddingSummaryBorderOpacity)
        XCTAssertEqual(summaryTokens.shadowOpacity, .postBiddingSummaryShadowOpacity)
        XCTAssertEqual(summaryTokens.shadowRadius, .postBiddingSummaryShadowRadius)
        XCTAssertEqual(summaryTokens.bidText.hexValue, GameColorToken.buttonNewGameBackground.hexValue)
        XCTAssertTrue(bidAreaTokens.accessibilityValue.contains("background=color.bidArea.background"))
        XCTAssertTrue(selectorTokens.accessibilityValue.contains("background=color.bidSelector.background"))
        XCTAssertTrue(suitSelectorTokens.accessibilityValue.contains("background=color.card.background"))
        XCTAssertTrue(suitSelectorTokens.accessibilityValue.contains("border=color.card.border"))
        XCTAssertTrue(suitSelectorTokens.accessibilityValue.contains("selectedBackground=color.card.background"))
        XCTAssertTrue(suitSelectorTokens.accessibilityValue.contains("focusRing=color.button.newGame.background"))
        XCTAssertTrue(summaryTokens.accessibilityValue.contains("background=color.postBiddingSummary.background"))
        XCTAssertTrue(summaryTokens.accessibilityValue.contains("suitChipHorizontalPadding=layout.postBiddingSummary.suitChip.padding.horizontal"))
        XCTAssertTrue(summaryTokens.accessibilityValue.contains("backgroundOpacity=effect.postBiddingSummary.background.opacity"))
        XCTAssertTrue(summaryTokens.accessibilityValue.contains("shadowOpacity=effect.postBiddingSummary.shadow.opacity"))
        XCTAssertTrue(summaryTokens.accessibilityValue.contains("outsideTableHorizontalOffset=layout.postBiddingSummary.outsideTableHorizontalOffsetRatio"))
        XCTAssertTrue(summaryTokens.accessibilityValue.contains("outsideTableVerticalOffset=layout.postBiddingSummary.outsideTableVerticalOffsetRatio"))
        XCTAssertFalse(bidAreaTokens.accessibilityValue.contains("#"))
        XCTAssertFalse(selectorTokens.accessibilityValue.contains("#"))
        XCTAssertFalse(suitSelectorTokens.accessibilityValue.contains("#"))
        XCTAssertFalse(summaryTokens.accessibilityValue.contains("#"))
    }

    func testBottomControlLayoutTokensAreAvailable() {
        let requiredLayoutTokenKeys = [
            "layout.bottomControl.button.gap",
            "layout.bottomControl.deal.secondary.maxWidth"
        ]

        XCTAssertEqual(Set(GameControlLayoutToken.allCases.map(\.rawValue)), Set(requiredLayoutTokenKeys))
        XCTAssertEqual(GameControlLayoutToken.bottomControlButtonGap.numericValue, 10)
        XCTAssertEqual(GameControlLayoutToken.bottomControlSecondaryDealMaxWidth.numericValue, 160)
    }

    func testGameScoreTokensAreAvailable() {
        let requiredLayoutTokenKeys = [
            "layout.gameScore.padding.horizontal",
            "layout.gameScore.padding.vertical",
            "layout.gameScore.team.gap",
            "layout.gameScore.cornerRadius",
            "layout.gameScore.minimumHeight"
        ]
        let tokens = GameScoreTokenSet()

        XCTAssertEqual(Set(GameScoreLayoutToken.allCases.map(\.rawValue)), Set(requiredLayoutTokenKeys))
        XCTAssertEqual(GameScoreLayoutToken.horizontalPadding.numericValue, 12)
        XCTAssertEqual(GameScoreLayoutToken.verticalPadding.numericValue, 8)
        XCTAssertEqual(GameScoreLayoutToken.teamGap.numericValue, 12)
        XCTAssertEqual(GameScoreLayoutToken.cornerRadius.numericValue, 8)
        XCTAssertEqual(GameScoreLayoutToken.minimumHeight.numericValue, 44)
        XCTAssertEqual(tokens.background, .postBiddingSummaryBackground)
        XCTAssertEqual(tokens.border, .postBiddingSummaryBorder)
        XCTAssertEqual(tokens.teamText, .postBiddingSummaryLabelText)
        XCTAssertEqual(tokens.scoreText, .postBiddingSummaryTeamText)
        XCTAssertEqual(tokens.winnerText, .buttonNewGameBackground)
        XCTAssertTrue(tokens.accessibilityValue.contains("minimumHeight=layout.gameScore.minimumHeight"))
        XCTAssertFalse(tokens.accessibilityValue.contains("#"))
    }

    func testTrickPlayTokensAreAvailable() {
        let requiredLayoutTokenKeys = [
            "layout.trickPlay.slot.width",
            "layout.trickPlay.slot.height",
            "layout.trickPlay.slot.gap",
            "layout.trickPlay.slot.cornerRadius",
            "layout.trickPlay.counter.minimumWidth",
            "layout.trickPlay.counter.height",
            "layout.trickPlay.counter.headerOffset",
            "layout.trickPlay.counter.stationEdgeOffset"
        ]
        let tokens = TrickPlayTokenSet()

        XCTAssertEqual(Set(GameTrickLayoutToken.allCases.map(\.rawValue)), Set(requiredLayoutTokenKeys))
        XCTAssertEqual(GameTrickLayoutToken.playAreaSlotWidth.numericValue, 42)
        XCTAssertEqual(GameTrickLayoutToken.playAreaSlotHeight.numericValue, 58)
        XCTAssertEqual(GameTrickLayoutToken.playAreaSlotGap.numericValue, 6)
        XCTAssertEqual(GameTrickLayoutToken.playAreaSlotCornerRadius.numericValue, 6)
        XCTAssertEqual(GameTrickLayoutToken.trickCounterMinimumWidth.numericValue, 34)
        XCTAssertEqual(GameTrickLayoutToken.trickCounterHeight.numericValue, 18)
        XCTAssertEqual(GameTrickLayoutToken.trickCounterHeaderOffset.numericValue, 4)
        XCTAssertEqual(GameTrickLayoutToken.trickCounterStationEdgeOffset.numericValue, 4)
        XCTAssertEqual(tokens.slotBackground, .trickPlaySlotBackground)
        XCTAssertEqual(tokens.slotBorder, .trickPlaySlotBorder)
        XCTAssertEqual(tokens.activeSeatOutline, .trickPlayActiveSeatOutline)
        XCTAssertEqual(tokens.legalCardOutline, .trickPlayLegalCardOutline)
        XCTAssertEqual(tokens.winnerHighlightBorder, .trickPlayWinnerHighlightBorder)
        XCTAssertEqual(tokens.countBackground, .trickPlayCountBackground)
        XCTAssertEqual(tokens.countText, .trickPlayCountText)
        XCTAssertEqual(tokens.countBackgroundOpacity, .trickPlayCountBackgroundOpacity)
        XCTAssertEqual(tokens.activeSlotBackgroundOpacity, .trickPlayActiveSlotBackgroundOpacity)
        XCTAssertEqual(tokens.activeSlotOutlineOpacity, .trickPlayActiveSlotOutlineOpacity)
        XCTAssertEqual(tokens.counterStationEdgeOffset, .trickCounterStationEdgeOffset)
        XCTAssertEqual(tokens.playedCardFlight, .trickPlayedCardFlightDuration)
        XCTAssertEqual(tokens.clearPause, .trickClearPauseDuration)
        XCTAssertEqual(tokens.clearFade, .trickClearFadeDuration)
        XCTAssertTrue(tokens.accessibilityValue.contains("slotBackground=color.trickPlay.slot.background"))
        XCTAssertTrue(tokens.accessibilityValue.contains("activeSlotBackgroundOpacity=effect.trickPlay.activeSlot.background.opacity"))
        XCTAssertTrue(tokens.accessibilityValue.contains("activeSlotOutlineOpacity=effect.trickPlay.activeSlot.outline.opacity"))
        XCTAssertTrue(tokens.accessibilityValue.contains("countBackgroundOpacity=effect.trickPlay.count.background.opacity"))
        XCTAssertTrue(tokens.accessibilityValue.contains("counterHeaderOffset=layout.trickPlay.counter.headerOffset"))
        XCTAssertTrue(tokens.accessibilityValue.contains("counterStationEdgeOffset=layout.trickPlay.counter.stationEdgeOffset"))
        XCTAssertTrue(tokens.accessibilityValue.contains("playedCardFlight=animation.trick.playedCard.flight.duration"))
        XCTAssertTrue(tokens.accessibilityValue.contains("clearPause=animation.trick.clear.pause.duration"))
        XCTAssertFalse(tokens.accessibilityValue.contains("#"))
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
            "animation.trick.playedCard.flight.duration",
            "animation.trick.clear.pause.duration",
            "animation.trick.clear.fade.duration",
            "animation.round.scoreDisplay.duration"
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
        XCTAssertGreaterThan(GameAnimationToken.trickClearPauseDuration.nanoseconds, 0)
        XCTAssertGreaterThan(GameAnimationToken.trickClearFadeDuration.nanoseconds, 0)
        XCTAssertGreaterThan(GameAnimationToken.roundScoreDisplayDuration.nanoseconds, 0)
        XCTAssertEqual(GameAnimationToken.dealStackFlightDuration.seconds, 0.30)
        XCTAssertEqual(GameAnimationToken.dealStationExpansionDuration.seconds, 0.14)
        XCTAssertEqual(GameAnimationToken.dealStepPauseDuration.seconds, 0.05)
        XCTAssertEqual(GameAnimationToken.dealSouthRevealTotalDuration.seconds, 1.23)
        XCTAssertEqual(GameAnimationToken.dealSouthRevealFlipDuration.seconds, 0.15)
        XCTAssertEqual(GameAnimationToken.dealSouthRevealFlipStagger.seconds, 0.09)
        XCTAssertEqual(GameAnimationToken.bidSimulatedTurnDelay.seconds, 1.0)
        XCTAssertEqual(GameAnimationToken.bidStationCuePulseDuration.seconds, 0.24)
        XCTAssertEqual(GameAnimationToken.bidValueFadeOutDuration.seconds, 0.5)
        XCTAssertEqual(GameAnimationToken.bidValueFadeInDuration.seconds, 0.5)
        XCTAssertEqual(GameAnimationToken.bidAreaFadeOutDuration.seconds, 1.0)
        XCTAssertEqual(GameAnimationToken.trickPlayedCardFlightDuration.seconds, 0.30)
        XCTAssertEqual(GameAnimationToken.trickClearPauseDuration.seconds, 0.75)
        XCTAssertEqual(GameAnimationToken.trickClearFadeDuration.seconds, 0.20)
        XCTAssertEqual(GameAnimationToken.roundScoreDisplayDuration.seconds, 2.0)
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
        XCTAssertEqual(presentation.shadowOffsetYToken, .tableTitleShadowOffsetY)
        XCTAssertEqual(presentation.highlightColorRole.token, .tableTitleHighlight)
        XCTAssertEqual(presentation.highlightOpacityToken, .tableTitleHighlightOpacity)
        XCTAssertEqual(presentation.highlightBlurRadiusToken, .tableTitleHighlightBlurRadius)
        XCTAssertEqual(presentation.highlightOffsetYToken, .tableTitleHighlightOffsetY)
        XCTAssertEqual(presentation.style, "embossedFelt")
        XCTAssertTrue(presentation.usesShadow)
        XCTAssertTrue(presentation.accessibilityValue.contains("font=typography.tableTitle.font"))
        XCTAssertTrue(presentation.accessibilityValue.contains("fontName=SF Arabic Rounded Bold"))
        XCTAssertTrue(presentation.accessibilityValue.contains("fontSize=typography.tableTitle.fontSize"))
        XCTAssertTrue(presentation.accessibilityValue.contains("pointSize=26.0"))
        XCTAssertTrue(presentation.accessibilityValue.contains("textColor=color.tableTitle.text"))
        XCTAssertTrue(presentation.accessibilityValue.contains("textOpacity=effect.tableTitle.text.opacity"))
        XCTAssertTrue(presentation.accessibilityValue.contains("textOpacityValue=0.72"))
        XCTAssertTrue(presentation.accessibilityValue.contains("shadowColor=effect.tableTitle.shadow.color"))
        XCTAssertTrue(presentation.accessibilityValue.contains("usesShadow=true"))
        XCTAssertTrue(presentation.accessibilityValue.contains("shadowOpacityValue=0.38"))
        XCTAssertTrue(presentation.accessibilityValue.contains("shadowOffsetY=effect.tableTitle.shadow.offset.y"))
        XCTAssertTrue(presentation.accessibilityValue.contains("highlightColor=effect.tableTitle.highlight.color"))
        XCTAssertTrue(presentation.accessibilityValue.contains("highlightOpacity=effect.tableTitle.highlight.opacity"))
        XCTAssertTrue(presentation.accessibilityValue.contains("highlightOpacityValue=0.18"))
        XCTAssertTrue(presentation.accessibilityValue.contains("highlightBlur=effect.tableTitle.highlight.blurRadius"))
        XCTAssertTrue(presentation.accessibilityValue.contains("highlightOffsetY=effect.tableTitle.highlight.offset.y"))
        XCTAssertTrue(presentation.accessibilityValue.contains("style=embossedFelt"))
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

        XCTAssertEqual(GamePhase.allCases.map(\.rawValue), ["notStarted", "dealt", "trickPlay", "handComplete"])
        XCTAssertEqual(state.phase, .notStarted)
        XCTAssertEqual(state.players.count, 4)
        XCTAssertTrue(state.players.allSatisfy(\.hand.isEmpty))
        XCTAssertEqual(state.dealerSeat, .east)
        XCTAssertNil(state.deck)
        XCTAssertTrue(state.bids.isEmpty)
        XCTAssertNil(state.trickPlayState)
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
        XCTAssertNil(state.trickPlayState)
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

    func testTrickPlayStartsFromNumericContractWithHighBidderLeading() throws {
        let dealtState = try makeRoundRobinCompletedDeal(dealerSeat: .south)
        let contractState = try makeContractState(
            from: dealtState,
            highBidderSeat: .west,
            bidValue: .nine,
            tarneebSuit: .hearts
        )

        let trickState = contractState.startingTrickPlayIfReady()

        XCTAssertEqual(trickState.phase, .trickPlay)
        XCTAssertEqual(trickState.currentTrickTurnSeat, .west)
        XCTAssertEqual(trickState.trickPlayState?.declarerSeat, .west)
        XCTAssertEqual(trickState.trickPlayState?.leaderSeat, .west)
        XCTAssertEqual(trickState.trickPlayState?.tarneebSuit, .hearts)
        XCTAssertEqual(trickState.players.map(\.hand.count), [13, 13, 13, 13])
    }

    func testTrickPlayRequiresFollowSuitWhenPossibleAndRejectsIllegalSouthPlay() throws {
        let dealtState = try makeRoundRobinCompletedDeal(dealerSeat: .south)
        let contractState = try makeContractState(
            from: dealtState,
            highBidderSeat: .east,
            bidValue: .eight,
            tarneebSuit: .hearts
        )
        let eastLead = Card(suit: .spades, rank: .three)
        var players = contractState.players
        let eastIndex = try XCTUnwrap(players.firstIndex { $0.seat == .east })
        let eastLeadIndex = try XCTUnwrap(players[eastIndex].hand.firstIndex(of: eastLead))
        players[eastIndex].hand.remove(at: eastLeadIndex)
        let trickPlayState = TrickPlayState(
            declarerSeat: .east,
            tarneebSuit: .hearts,
            leaderSeat: .east,
            currentTurnSeat: .south,
            currentTrick: [PlayedCard(seat: .east, card: eastLead)]
        )
        let state = try XCTUnwrap(GameState(
            phase: .trickPlay,
            players: players,
            dealerSeat: contractState.dealerSeat,
            deck: [],
            biddingState: contractState.biddingState,
            postBiddingSummary: contractState.postBiddingSummary,
            trickPlayState: trickPlayState
        ))
        let legalSouthCards = TrickPlayService().legalCards(for: .south, in: state)
        let illegalSouthCard = try XCTUnwrap(player(in: state, seat: .south).hand.first { $0.suit != .spades })

        XCTAssertFalse(legalSouthCards.isEmpty)
        XCTAssertTrue(legalSouthCards.allSatisfy { $0.suit == .spades })
        let projected = RoomInputProjection(authoritative: state)
        XCTAssertEqual(projected.game, state)
        XCTAssertFalse(projected.canPlay(illegalSouthCard))
        for card in legalSouthCards { XCTAssertTrue(projected.canPlay(card)) }

        let rejectedState = TrickPlayService().playSouthCard(illegalSouthCard, in: state)
        XCTAssertEqual(rejectedState, state)
    }

    func testTrickPlayRemovesPlayedCardAndAdvancesCounterclockwise() throws {
        let dealtState = try makeRoundRobinCompletedDeal(dealerSeat: .south)
        let contractState = try makeContractState(
            from: dealtState,
            highBidderSeat: .south,
            bidValue: .seven,
            tarneebSuit: .hearts
        )
        let trickState = contractState.startingTrickPlayIfReady()
        let southCard = try XCTUnwrap(player(in: trickState, seat: .south).hand.first)
        let playedState = TrickPlayService().playSouthCard(southCard, in: trickState)

        XCTAssertEqual(try player(in: playedState, seat: .south).hand.count, 12)
        XCTAssertFalse(try player(in: playedState, seat: .south).hand.contains(southCard))
        XCTAssertEqual(playedState.trickPlayState?.playedCard(for: .south)?.card, southCard)
        XCTAssertEqual(playedState.currentTrickTurnSeat, .east)
    }

    func testTrickWinnerUsesTarneebBeforeLedSuitAndClearStartsNextLeader() throws {
        let playedCards = [
            PlayedCard(seat: .south, card: Card(suit: .clubs, rank: .ace)),
            PlayedCard(seat: .east, card: Card(suit: .clubs, rank: .king)),
            PlayedCard(seat: .north, card: Card(suit: .hearts, rank: .two)),
            PlayedCard(seat: .west, card: Card(suit: .clubs, rank: .queen))
        ]

        XCTAssertEqual(
            TrickPlayRules.winner(for: playedCards, ledSuit: .clubs, tarneebSuit: .hearts),
            .north
        )

        var trickPlayState = TrickPlayState(declarerSeat: .south, tarneebSuit: .hearts)
        for playedCard in playedCards {
            trickPlayState.appendPlayedCard(playedCard)
        }

        XCTAssertEqual(trickPlayState.pendingCompletedTrick?.winnerSeat, .north)
        XCTAssertNil(trickPlayState.currentTurnSeat)
        XCTAssertEqual(trickPlayState.individualTrickCount(for: .north), 1)
        XCTAssertEqual(trickPlayState.individualTrickCount(for: .south), 0)
        XCTAssertEqual(trickPlayState.partnershipTrickCount(for: .north), 1)
        XCTAssertEqual(trickPlayState.partnershipTrickCount(for: .south), 1)

        trickPlayState.clearPendingCompletedTrick()

        XCTAssertEqual(trickPlayState.completedTrickCount, 1)
        XCTAssertEqual(trickPlayState.currentTurnSeat, .north)
        XCTAssertEqual(trickPlayState.leaderSeat, .north)
        XCTAssertEqual(trickPlayState.currentTrick, [])
        XCTAssertEqual(trickPlayState.individualTrickCount(for: .north), 1)
        XCTAssertEqual(trickPlayState.individualTrickCount(for: .south), 0)
        XCTAssertEqual(trickPlayState.partnershipTrickCount(for: .south), 1)

        let presentation = try XCTUnwrap(TrickPlayPresentation(phase: .trickPlay, trickPlayState: trickPlayState))
        XCTAssertEqual(presentation.individualTrickCount(for: .north), 1)
        XCTAssertEqual(presentation.individualTrickCount(for: .south), 0)
        XCTAssertEqual(presentation.northSouthTrickCount, 1)
        XCTAssertTrue(presentation.accessibilityValue.contains("individualTricks=south:0,west:0,north:1,east:0"))
        XCTAssertTrue(presentation.accessibilityValue.contains("northSouthTricks=1"))
    }

    func testScoringServiceScoresMadeAndFailedContracts() throws {
        let service = TarneebScoringService()
        let made = try XCTUnwrap(service.scoreRound(declaringTeam: .teamA, bid: 8, declaringTricks: 9))
        let failed = try XCTUnwrap(service.scoreRound(declaringTeam: .teamB, bid: 10, declaringTricks: 7))

        XCTAssertEqual(made.outcome, .contractMade)
        XCTAssertEqual(made.declaringScoreDelta, 9)
        XCTAssertEqual(made.defendingScoreDelta, 0)
        XCTAssertEqual(made.scoreDelta(for: .teamA), 9)
        XCTAssertEqual(made.scoreDelta(for: .teamB), 0)

        XCTAssertEqual(failed.outcome, .contractFailed)
        XCTAssertEqual(failed.declaringScoreDelta, -10)
        XCTAssertEqual(failed.defendingScoreDelta, 6)
        XCTAssertEqual(failed.scoreDelta(for: .teamA), 6)
        XCTAssertEqual(failed.scoreDelta(for: .teamB), -10)
    }

    func testScoringServiceScoresKabootAndBidThirteenSpecialCases() throws {
        let service = TarneebScoringService()
        let declaringKaboot = try XCTUnwrap(service.scoreRound(declaringTeam: .teamA, bid: 12, declaringTricks: 13))
        let madeThirteen = try XCTUnwrap(service.scoreRound(declaringTeam: .teamA, bid: 13, declaringTricks: 13))
        let failedThirteen = try XCTUnwrap(service.scoreRound(declaringTeam: .teamA, bid: 13, declaringTricks: 11))
        let defendingKaboot = try XCTUnwrap(service.scoreRound(declaringTeam: .teamA, bid: 8, declaringTricks: 0))
        let defendingKabootAgainstThirteen = try XCTUnwrap(service.scoreRound(declaringTeam: .teamA, bid: 13, declaringTricks: 0))

        XCTAssertEqual(declaringKaboot.outcome, .declaringKaboot)
        XCTAssertEqual(declaringKaboot.declaringScoreDelta, 16)
        XCTAssertEqual(declaringKaboot.defendingScoreDelta, 0)

        XCTAssertEqual(madeThirteen.outcome, .bidThirteenMade)
        XCTAssertEqual(madeThirteen.declaringScoreDelta, 26)
        XCTAssertEqual(madeThirteen.defendingScoreDelta, 0)

        XCTAssertEqual(failedThirteen.outcome, .bidThirteenFailed)
        XCTAssertEqual(failedThirteen.declaringScoreDelta, -16)
        XCTAssertEqual(failedThirteen.defendingScoreDelta, 4)

        XCTAssertEqual(defendingKaboot.outcome, .defendingKaboot)
        XCTAssertEqual(defendingKaboot.declaringScoreDelta, -8)
        XCTAssertEqual(defendingKaboot.defendingScoreDelta, 16)

        XCTAssertEqual(defendingKabootAgainstThirteen.outcome, .defendingKaboot)
        XCTAssertEqual(defendingKabootAgainstThirteen.declaringScoreDelta, -16)
        XCTAssertEqual(defendingKabootAgainstThirteen.defendingScoreDelta, 16)
    }

    func testScoringServiceRejectsInvalidBidOrTrickCount() {
        let service = TarneebScoringService()

        XCTAssertNil(service.scoreRound(declaringTeam: .teamA, bid: 6, declaringTricks: 8))
        XCTAssertNil(service.scoreRound(declaringTeam: .teamA, bid: 14, declaringTricks: 8))
        XCTAssertNil(service.scoreRound(declaringTeam: .teamA, bid: 8, declaringTricks: -1))
        XCTAssertNil(service.scoreRound(declaringTeam: .teamA, bid: 8, declaringTricks: 14))
    }

    func testGameScoreAccumulatesRoundDeltasAndDeclaresWinnerAtThirtyOne() throws {
        let service = TarneebScoringService()
        var score = GameScore(northSouth: 25, eastWest: 12)
        let result = try XCTUnwrap(service.scoreRound(declaringTeam: .teamA, bid: 7, declaringTricks: 7))

        score.apply(result)

        XCTAssertEqual(score.northSouth, 32)
        XCTAssertEqual(score.eastWest, 12)
        XCTAssertEqual(score.points(for: .teamA), 32)
        XCTAssertEqual(score.points(for: .teamB), 12)
        XCTAssertEqual(score.winnerTeam, .teamA)
        XCTAssertEqual(GameScore.winningScore, 31)
    }

    func testGameScorePresentationAppearsAfterFirstDealAndCallsOutWinner() throws {
        XCTAssertNil(GameScorePresentation(
            hasStartedGame: false,
            score: GameScore(),
            completedRoundCount: 0,
            lastRoundScore: nil
        ))

        let result = try XCTUnwrap(
            TarneebScoringService().scoreRound(declaringTeam: .teamB, bid: 13, declaringTricks: 13)
        )
        var score = GameScore(northSouth: 4, eastWest: 10)
        score.apply(result)
        let presentation = try XCTUnwrap(GameScorePresentation(
            hasStartedGame: true,
            score: score,
            completedRoundCount: 2,
            lastRoundScore: result
        ))

        XCTAssertEqual(presentation.northSouthScore, 4)
        XCTAssertEqual(presentation.eastWestScore, 36)
        XCTAssertEqual(presentation.winnerTeam, .teamB)
        XCTAssertEqual(presentation.winnerLabel, "East-West wins!")
        XCTAssertEqual(presentation.lastRoundResultLabel, "Round 2: North-South 0, East-West +26")
        XCTAssertTrue(presentation.accessibilityValue.contains("winningScore=31"))
        XCTAssertTrue(presentation.accessibilityValue.contains("winner=teamB"))
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

    func testSouthHandPresentationUsesReadableSuitGroupedLanesAfterReveal() {
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
        let suitGroups = SouthHandPresentation.suitGroups(from: cardPresentations)
        let indexedSuitGroups = SouthHandPresentation.indexedSuitGroups(from: cardPresentations)

        XCTAssertEqual(layout.cardSpacing, 4)
        XCTAssertEqual(layout.suitBoundarySpacing, 8)
        XCTAssertEqual(layout.additionalSuitBoundarySpacing, 4)
        XCTAssertEqual(layout.suitLaneCount, 4)
        XCTAssertEqual(layout.suitLaneGap, 6)
        XCTAssertEqual(layout.suitLaneHeaderHeight, 18)
        XCTAssertEqual(layout.additionalLeadingSpacing(beforeCardAt: 0, in: cardPresentations), 0)
        XCTAssertEqual(layout.additionalLeadingSpacing(beforeCardAt: 1, in: cardPresentations), 0)
        XCTAssertEqual(layout.additionalLeadingSpacing(beforeCardAt: 2, in: cardPresentations), 4)
        XCTAssertEqual(layout.additionalLeadingSpacing(beforeCardAt: 3, in: cardPresentations), 0)
        XCTAssertEqual(layout.additionalLeadingSpacing(beforeCardAt: 4, in: cardPresentations), 4)
        XCTAssertEqual(layout.additionalLeadingSpacing(beforeCardAt: 6, in: cardPresentations), 4)
        XCTAssertEqual(suitGroups.map(\.suit), [.hearts, .clubs, .diamonds, .spades])
        XCTAssertEqual(suitGroups.map { $0.cards.map(\.displayLabel) }, [
            ["2♥", "A♥"],
            ["2♣", "K♣"],
            ["2♦", "A♦"],
            ["2♠", "A♠"]
        ])
        XCTAssertEqual(indexedSuitGroups.map { $0.cards.map(\.index) }, [
            [0, 1],
            [2, 3],
            [4, 5],
            [6, 7]
        ])
        XCTAssertTrue(layout.accessibilityValue.contains("layout=suitGroupedLanes"))
        XCTAssertTrue(layout.accessibilityValue.contains("count=8"))
        XCTAssertTrue(layout.accessibilityValue.contains("laneCount=4"))
        XCTAssertTrue(layout.accessibilityValue.contains("suitLaneHeaders=visible"))
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
        XCTAssertTrue(presentation.accessibilityValue.contains("placement=outsideTableUpperLeft"))
        XCTAssertTrue(presentation.accessibilityValue.contains("display=contractBox"))
        XCTAssertTrue(presentation.accessibilityValue.contains("style=feltScoreboardPlaque"))
        XCTAssertTrue(presentation.accessibilityValue.contains("highBidder=West"))
        XCTAssertTrue(presentation.accessibilityValue.contains("bid=10"))
        XCTAssertTrue(presentation.accessibilityValue.contains("team=East-West"))
        XCTAssertTrue(presentation.accessibilityValue.contains("tarneebLabel=Tarneeb"))
        XCTAssertTrue(presentation.accessibilityValue.contains("tarneebSymbol=♣"))
        XCTAssertTrue(presentation.accessibilityValue.contains("tarneebSymbolColor=color.card.suit.black"))
        XCTAssertTrue(presentation.accessibilityValue.contains("tarneebSymbolBackground=color.card.background"))
        XCTAssertTrue(presentation.accessibilityValue.contains("tarneebSymbolBorder=color.button.newGame.background"))
        XCTAssertTrue(presentation.accessibilityValue.contains("tarneebSymbolChipTokens=background=color.card.background"))
        XCTAssertTrue(presentation.accessibilityValue.contains("focusRing=color.button.newGame.background"))
        XCTAssertTrue(presentation.accessibilityValue.contains("background=color.postBiddingSummary.background"))
        XCTAssertTrue(presentation.accessibilityValue.contains("backgroundOpacity=effect.postBiddingSummary.background.opacity"))
        XCTAssertTrue(presentation.accessibilityValue.contains("borderOpacity=effect.postBiddingSummary.border.opacity"))
        XCTAssertTrue(presentation.accessibilityValue.contains("shadowOpacity=effect.postBiddingSummary.shadow.opacity"))
        XCTAssertTrue(presentation.accessibilityValue.contains("suitChipHorizontalPadding=layout.postBiddingSummary.suitChip.padding.horizontal"))

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
        for (scale, name) in [(1, "card_back.png"), (2, "card_back@2x.png"), (3, "card_back@3x.png")] {
            XCTAssertTrue(contents.images.contains { $0.filename == name && $0.scale == "\(scale)x" })
            let source = try XCTUnwrap(CGImageSourceCreateWithURL(imageSetURL.appendingPathComponent(name) as CFURL, nil))
            let image = try XCTUnwrap(CGImageSourceCreateImageAtIndex(source, 0, nil))
            XCTAssertEqual(image.width, 64 * scale)
            XCTAssertEqual(image.height, 90 * scale)
        }
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
        XCTAssertTrue(presentation.canDeal)
        XCTAssertFalse(presentation.canStartNewGame)
        XCTAssertFalse(presentation.hasStartedGame)
        XCTAssertFalse(presentation.isGameInProgress)
        XCTAssertEqual(presentation.gameScore, GameScore())
        XCTAssertNil(presentation.winnerTeam)
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
        XCTAssertFalse(presentation.canDeal)
        XCTAssertTrue(presentation.canStartNewGame)
        XCTAssertTrue(presentation.hasStartedGame)
        XCTAssertTrue(presentation.isGameInProgress)
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

    func testDealActionIsIgnoredAfterGameBegins() throws {
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

        XCTAssertEqual(service.callCount, 1)
        XCTAssertEqual(service.receivedDealerSeats, [.south])
        XCTAssertEqual(presentation.gameState.phase, .dealt)
        XCTAssertEqual(presentation.gameState.dealerSeat, .south)
        XCTAssertEqual(presentation.gameState.players.map(\.hand.count), [13, 13, 13, 13])
        XCTAssertEqual(Set(presentation.gameState.bids.keys), Set(Seat.allCases))
        XCTAssertEqual(firstSouthHand, secondSouthHand)
        XCTAssertEqual(UndealtDeckStackPresentation(phase: presentation.gameState.phase).hiddenCardCount, 0)
        XCTAssertEqual(presentation.availableActions, [.newGame, .deal])
        XCTAssertFalse(presentation.canDeal)
    }

    func testNextRoundActionIsIgnoredBeforeHandCompletes() throws {
        let firstDeal = try makeCompletedDeal(dealerSeat: .west)
        let secondDeal = try makeCompletedDeal(shuffler: CardShuffler { Array($0.reversed()) }, dealerSeat: .south)
        let service = QueuedDealService(results: [firstDeal, secondDeal])
        let presentation = TarneebPresentationState(
            dealService: service,
            dealerSelector: QueuedDealerSelector(seats: [.west])
        )

        presentation.deal()
        let stateBeforeNextRound = presentation.gameState

        presentation.startNextRound()

        XCTAssertEqual(service.callCount, 1)
        XCTAssertEqual(presentation.gameState, stateBeforeNextRound)
        XCTAssertEqual(presentation.gameState.phase, .dealt)
        XCTAssertEqual(presentation.gameState.dealerSeat, .west)
    }

    func testCompletedHandScoresOnceAndNextRoundPreservesScore() throws {
        let presentation = TarneebPresentationState(
            dealService: DealService(shuffler: CardShuffler { $0 }),
            dealerSelector: QueuedDealerSelector(seats: [.west]),
            biddingService: BiddingService(bidGenerator: BidGenerator { _ in .pass })
        )

        presentation.deal()
        presentation.submitSouthBid(.seven)
        presentation.resolveNextSimulatedBid()
        presentation.resolveNextSimulatedBid()
        presentation.resolveNextSimulatedBid()
        presentation.submitSouthTarneebSuit(.spades)
        presentation.startTrickPlayIfReady()

        var guardrail = 0
        while presentation.gameState.phase == .trickPlay, guardrail < 1000 {
            if presentation.gameState.isCurrentTrickComplete {
                presentation.clearCompletedTrickIfNeeded()
            } else if presentation.gameState.currentTrickTurnSeat == .south {
                let legalCard = try XCTUnwrap(
                    TrickPlayService().legalCards(for: .south, in: presentation.gameState).first
                )
                presentation.playSouthCard(legalCard)
            } else {
                presentation.resolveNextSimulatedTrickPlay()
            }
            guardrail += 1
        }

        XCTAssertLessThan(guardrail, 1000)
        XCTAssertEqual(presentation.gameState.phase, .handComplete)
        XCTAssertEqual(presentation.completedRoundCount, 1)
        let roundResult = try XCTUnwrap(presentation.lastRoundScore)
        var expectedScore = GameScore()
        expectedScore.apply(roundResult)
        XCTAssertEqual(presentation.gameScore, expectedScore)
        XCTAssertNil(presentation.winnerTeam)

        presentation.clearCompletedTrickIfNeeded()
        XCTAssertEqual(presentation.completedRoundCount, 1)
        XCTAssertEqual(presentation.gameScore, expectedScore)

        presentation.startNextRound()
        XCTAssertEqual(presentation.gameState.phase, .dealt)
        XCTAssertEqual(presentation.gameState.dealerSeat, .south)
        XCTAssertEqual(presentation.gameScore, expectedScore)
        XCTAssertEqual(presentation.completedRoundCount, 1)
        XCTAssertFalse(presentation.canDeal)
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
        XCTAssertTrue(presentation.canDeal)
        XCTAssertFalse(presentation.canStartNewGame)
        XCTAssertFalse(presentation.hasStartedGame)
        XCTAssertEqual(presentation.gameScore, GameScore())
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
        XCTAssertTrue(presentation.canDeal)
        XCTAssertFalse(presentation.canStartNewGame)
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

    func testRepeatedDealDoesNotRefreshBiddingRound() throws {
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
        let completedBids = presentation.gameState.bids

        presentation.deal()

        XCTAssertEqual(firstBids[.east], .resolved(.seven))
        XCTAssertEqual(firstBids[.north], .resolved(.eight))
        XCTAssertEqual(firstBids[.west], .resolved(.nine))
        XCTAssertEqual(firstBids[.south], .pending)
        XCTAssertEqual(presentation.gameState.bids, completedBids)
        XCTAssertEqual(presentation.gameState.currentBiddingSeat, nil)
        XCTAssertEqual(presentation.gameState.dealerSeat, .south)
        XCTAssertEqual(shuffler.receivedDecks.count, 1)
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

    func testDisabledDealDoesNotRequestAnotherShuffle() throws {
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

        XCTAssertEqual(shuffler.receivedDecks.count, 1)
        XCTAssertEqual(presentation.gameState.dealerSeat, .south)
        for receivedDeck in shuffler.receivedDecks {
            XCTAssertEqual(receivedDeck, canonicalDeck)
            XCTAssertEqual(receivedDeck.count, 52)
            XCTAssertEqual(Set(receivedDeck.map(\.id)).count, 52)
        }
        XCTAssertEqual(firstSouthHand, Array(canonicalDeck[0..<13]))
        XCTAssertEqual(secondSouthHand, firstSouthHand)
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

        let project = try XCTUnwrap(try PropertyListSerialization.propertyList(
            from: Data(source.utf8), options: [], format: nil
        ) as? [String: Any])
        let objects = try XCTUnwrap(project["objects"] as? [String: [String: Any]])
        let projectID = try XCTUnwrap(project["rootObject"] as? String)
        let projectObject = try XCTUnwrap(objects[projectID])

        func configurations(for object: [String: Any]) throws -> [[String: Any]] {
            let listID = try XCTUnwrap(object["buildConfigurationList"] as? String)
            let list = try XCTUnwrap(objects[listID])
            let configurationIDs = try XCTUnwrap(list["buildConfigurations"] as? [String])
            XCTAssertFalse(configurationIDs.isEmpty, "Missing build configurations")
            XCTAssertEqual(Set(configurationIDs).count, configurationIDs.count,
                           "Duplicate build configuration references")
            return try configurationIDs.map { try XCTUnwrap(objects[$0]) }
        }

        let projectConfigurations = try configurations(for: projectObject)
        let requiredNames = Set(try projectConfigurations.map {
            try XCTUnwrap($0["name"] as? String)
        })
        XCTAssertFalse(requiredNames.isEmpty)
        let targetIDs = try XCTUnwrap(projectObject["targets"] as? [String])
        XCTAssertFalse(targetIDs.isEmpty, "Missing native targets")
        var applicationCount = 0
        for targetID in targetIDs {
            let target = try XCTUnwrap(objects[targetID])
            let targetName = try XCTUnwrap(target["name"] as? String)
            let productType = try XCTUnwrap(target["productType"] as? String)
            let isApplication = productType == "com.apple.product-type.application"
            if isApplication { applicationCount += 1 }
            let targetConfigurations = try configurations(for: target)
            let names = try targetConfigurations.map { try XCTUnwrap($0["name"] as? String) }
            XCTAssertEqual(Set(names), requiredNames, "\(targetName): missing or unexpected configuration")
            XCTAssertEqual(Set(names).count, names.count, "\(targetName): duplicate configuration name")
            for configuration in targetConfigurations {
                let name = try XCTUnwrap(configuration["name"] as? String)
                let settings = try XCTUnwrap(configuration["buildSettings"] as? [String: Any])
                let context = "\(targetName)/\(name)"
                XCTAssertEqual(settings["TARGETED_DEVICE_FAMILY"] as? String, "1",
                               "\(context): every target configuration must explicitly support iPhone only")
                XCTAssertFalse(settings.keys.contains { $0.contains("UISupportedInterfaceOrientations_iPad") },
                               "\(context): unexpected iPad orientation setting")
                if isApplication {
                    XCTAssertEqual(settings["INFOPLIST_KEY_UISupportedInterfaceOrientations"] as? String,
                                   "UIInterfaceOrientationPortrait",
                                   "\(context): every app configuration must explicitly lock portrait")
                }
            }
        }
        XCTAssertEqual(applicationCount, 1, "Expected one application target")
        XCTAssertFalse(source.contains("INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad"))
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

    private func makeRoundRobinCompletedDeal(
        dealerSeat: Seat = .south,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> GameState {
        var players = Player.initialPlayers()
        let deck = DeckFactory.makeCanonicalDeck()

        for (index, card) in deck.enumerated() {
            let seat = Seat.dealOrder[index % Seat.dealOrder.count]
            guard let playerIndex = players.firstIndex(where: { $0.seat == seat }) else {
                XCTFail("Missing player for \(seat.rawValue)", file: file, line: line)
                continue
            }

            players[playerIndex].hand.append(card)
        }

        return try XCTUnwrap(
            GameState(
                phase: .dealt,
                players: players,
                dealerSeat: dealerSeat,
                deck: [],
                biddingState: .started(dealerSeat: dealerSeat)
            ),
            file: file,
            line: line
        )
    }

    private func makeContractState(
        from dealtState: GameState,
        highBidderSeat: Seat,
        bidValue: BidValue,
        tarneebSuit: Suit,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> GameState {
        let biddingState = BiddingState(
            bids: Dictionary(uniqueKeysWithValues: Seat.allCases.map { seat in
                (seat, seat == highBidderSeat ? .resolved(bidValue) : .resolved(.pass))
            }),
            bidRecommendations: [
                highBidderSeat: BidRecommendation(
                    bid: bidValue,
                    preferredTarneebSuit: tarneebSuit,
                    confidence: 1
                )
            ],
            currentTurnSeat: nil,
            highestBidSeat: highBidderSeat,
            highestBidValue: bidValue,
            status: .complete
        )

        return dealtState.replacingBiddingState(
            biddingState,
            postBiddingSummary: PostBiddingSummary(
                highBidderSeat: highBidderSeat,
                bidValue: bidValue,
                tarneebSuit: tarneebSuit
            )
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

final class TarneebRoomOutcomeTests: XCTestCase {
    func testOutcomeOwnershipAcrossEveryLegalBidAndTrickCount() throws {
        for team in [Team.teamA, .teamB] {
            for bid in 7...13 {
                for tricks in 0...13 {
                    let result = try XCTUnwrap(TarneebScoringService().scoreRound(declaringTeam: team, bid: bid, declaringTricks: tricks))
                    var score = GameScore(northSouth: -15, eastWest: -16)
                    score.apply(result)
                    let summary = RoundResultPresentation(result: result, score: score)
                    let room = RoomOutcomePresentation(presentation: summary)
                    XCTAssertEqual(summary.previousScore(for: .teamA), -15)
                    XCTAssertEqual(summary.previousScore(for: .teamB), -16)
                    for scoredTeam in [Team.teamA, .teamB] {
                        let delta = result.scoreDelta(for: scoredTeam)
                        let expected = "\(summary.previousScore(for: scoredTeam)) \(delta < 0 ? "−" : "+") \(abs(delta)) = \(score.points(for: scoredTeam))"
                        XCTAssertEqual(room.equation(for: scoredTeam), expected)
                    }
                    XCTAssertEqual(room.isDefense, team == .teamB && tricks < bid)
                    XCTAssertEqual(room.kicker, tricks >= bid ? "CONTRACT MADE" : team == .teamB ? "CONTRACT DEFEATED" : "CONTRACT MISSED")
                    XCTAssertTrue(room.detail.contains("\(team == .teamB && tricks < bid ? 13 - tricks : tricks)"))
                    XCTAssertTrue(room.earned.contains("\(result.scoreDelta(for: .teamA)) points"))
                    XCTAssertEqual(room.title, team == .teamB && tricks < bid ? "You held the line." : team == .teamA && tricks >= bid ? "You brought it home." : tricks >= bid ? "They made the contract." : "The contract slipped away.")
                }
            }
        }
    }
    func testCompactPlayedCardsClearNorthIdentityEachOtherAndSouthStation() {
        for height in [228.0, 240, 280] {
            let room = RoomTableGeometry(size: CGSize(width: 351, height: height))
            let halfCard = 45 * room.cardScale
            XCTAssertGreaterThanOrEqual(room.slot(.north).y - halfCard, 64)
            XCTAssertGreaterThanOrEqual(room.slot(.south).y - halfCard - (room.slot(.north).y + halfCard), 6)
            XCTAssertLessThan(room.slot(.south).y + halfCard, room.station(.south).y - 7)
            XCTAssertGreaterThanOrEqual(64 * room.cardScale, 44)
        }
    }
    func testPreferencesStayIndependentAndInactiveFeedbackIsSuppressed() {
        for sound in [false, true] { for haptic in [false, true] { for requested in [false, true] { for active in [false, true] {
            let policy = FeedbackPreferencePolicy(soundEnabled: sound, hapticsEnabled: haptic, requestsHaptic: requested, active: active)
            XCTAssertEqual(policy.sound, sound && active)
            XCTAssertEqual(policy.haptic, haptic && requested && active)
        } } } }
    }
    @MainActor func testOutcomeSoundHierarchyAndMutedWoodEnvelopes() {
        XCTAssertLessThan(TableFeedback.Event.defenseWin.duration, TableFeedback.Event.roundWin.duration)
        XCTAssertLessThan(TableFeedback.Event.roundWin.duration, TableFeedback.Event.matchWin.duration)
        XCTAssertEqual(TableFeedback.Event.openingSquare.duration, 0.07)
        for event in [TableFeedback.Event.defenseWin, .roundWin, .roundLoss, .matchWin] {
            let data = TableFeedback.synthesizedSoundData(event, variation: PaperSoundVariation(index: 0))
            let values = stride(from: 44, to: data.count - 1, by: 2).map { Double(Int16(bitPattern: UInt16(data[$0]) | UInt16(data[$0 + 1]) << 8)) / Double(Int16.max) }
            XCTAssertLessThan(abs(values.first ?? 1), 0.001)
            XCTAssertLessThan(abs(values.last ?? 1), 0.001)
            XCTAssertGreaterThan(values.map(abs).max() ?? 0, 0.015)
            XCTAssertLessThan(values.map(abs).max() ?? 1, 0.4)
        }
    }
}

final class TarneebReleaseStateTests: XCTestCase {
    func testSeededStandardMatchesPreserveLegalStateAndDiskResume() throws { try verifyMatches(skill: .standard) }
    func testSeededAdvancedMatchesPreserveLegalStateAndDiskResume() throws { try verifyMatches(skill: .advanced) }
    func testSeededExpertMatchesPreserveLegalStateAndDiskResume() throws { try verifyMatches(skill: .expert) }

    private func verifyMatches(skill: AISkill) throws {
        for seed in [UInt64(731_001), UInt64(731_019)] {
            let suite = "release-\(skill.rawValue)-\(seed)-\(UUID().uuidString)"
            let prefs = try XCTUnwrap(UserDefaults(suiteName: suite))
            defer { prefs.removePersistentDomain(forName: suite) }
            prefs.set(skill.rawValue, forKey: AISkill.preferenceKey)
            var rng = AISeededGenerator(state: seed)
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(suite).appendingPathComponent("match.json")
            defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
            let store = MatchStore(url: url)
            func makeModel() -> TarneebPresentationState {
                TarneebPresentationState(
                    dealService: DealService(shuffler: CardShuffler { $0.shuffled(using: &rng) }, handLogger: HandLogger { _ in }),
                    dealerSelector: EnvironmentDealerSelector(environment: ["TARNEEB_INITIAL_DEALER": "west"]),
                    aiPreferences: prefs)
            }
            var model = makeModel()
            model.enablePersistence(store)
            model.deal()
            var commands = 0, redeals = 0, plays = 0, restores = 0
            var expectedScore = GameScore()
            while model.winnerTeam == nil && commands < 5_000 {
                commands += 1
                let state = model.gameState
                let before = model.snapshot
                switch state.phase {
                case .notStarted:
                    XCTFail("Unexpected reset: \(skill) seed \(seed), command \(commands)")
                    return
                case .dealt:
                    if state.biddingCompletionOutcome == .allPassRedeal {
                        model.automaticRedealAfterAllPass()
                        redeals += 1
                        XCTAssertEqual(model.gameState.dealerSeat, state.dealerSeat.nextCounterclockwiseDealer)
                        XCTAssertEqual(model.completedRoundCount, before.completedRounds)
                    } else if state.biddingState?.isWaitingForSouth == true {
                        let legal = state.biddingState!.southLegalValues
                        let choice = try XCTUnwrap(legal.randomElement(using: &rng))
                        model.submitSouthBid(choice)
                    } else if state.biddingStatus == .inProgress {
                        let request = try XCTUnwrap(model.prepareAIBidDecision())
                        let result = AIBiddingEngine.select(request, seed: rng.next())
                        if request.useSkillPolicy && skill != .standard {
                            XCTAssertTrue(request.context.legalValues.contains(result.recommendation.bid))
                        }
                        XCTAssertTrue(model.applyAIBidDecision(result, request: request))
                        // Standard recommendations are intentionally normalized by the
                        // existing bidding service; check the accepted action, not raw advice.
                        let acceptedBid = try XCTUnwrap(model.gameState.bids[request.context.auction.seat]?.resolvedValue)
                        XCTAssertTrue(request.context.legalValues.contains(acceptedBid))
                        XCTAssertFalse(model.applyAIBidDecision(result, request: request))
                    } else if state.postBiddingSummary == nil {
                        XCTAssertEqual(state.highestBidSeat, .south)
                        model.submitSouthTarneebSuit(Suit.allCases[Int(rng.next() % 4)])
                    } else {
                        model.startTrickPlayIfReady()
                    }
                case .trickPlay:
                    if state.isCurrentTrickComplete {
                        model.clearCompletedTrickIfNeeded()
                        if model.gameState.phase == .handComplete {
                            expectedScore.apply(try XCTUnwrap(TarneebScoringService().scoreRound(in: model.gameState)))
                            XCTAssertEqual(model.gameScore, expectedScore)
                            let scored = model.snapshot
                            model.clearCompletedTrickIfNeeded()
                            XCTAssertEqual(model.snapshot, scored, "Repeated collection must not score twice")
                        }
                    } else if state.currentTrickTurnSeat == .south {
                        let legal = TrickPlayRules.legalCards(for: .south, in: state)
                        let card = try XCTUnwrap(legal.randomElement(using: &rng))
                        model.playSouthCard(card)
                        let accepted = model.snapshot
                        model.playSouthCard(card)
                        XCTAssertEqual(model.snapshot, accepted, "Repeated play must not consume a second card")
                        plays += 1
                    } else {
                        let request = try XCTUnwrap(model.prepareAIDecision())
                        let result = AIDecisionEngine.select(request.context, skill: skill, seed: rng.next())
                        XCTAssertTrue(request.context.legalCards.contains(try XCTUnwrap(result.card)))
                        XCTAssertTrue(model.applyAIDecision(result, request: request))
                        XCTAssertFalse(model.applyAIDecision(result, request: request))
                        plays += 1
                    }
                case .handComplete:
                    model.startNextRound()
                    let next = model.snapshot
                    model.startNextRound()
                    XCTAssertEqual(model.snapshot, next, "Repeated Next Hand must not skip a deal")
                    XCTAssertEqual(model.gameState.dealerSeat, state.dealerSeat.nextCounterclockwiseDealer)
                }
                XCTAssertEqual(model.activeAISkill, skill)
                XCTAssertNil(model.saveNotice)
                let cards = model.gameState.players.flatMap(\.hand) + (model.gameState.deck ?? []) + (model.gameState.trickPlayState?.playedCards.map(\.card) ?? [])
                XCTAssertEqual(cards.count, 52)
                XCTAssertEqual(Set(cards), Set(DeckFactory.makeCanonicalDeck()))
                XCTAssertEqual(try store.load(), model.snapshot, "Save rejected: \(skill), seed \(seed), command \(commands)")
                if commands.isMultiple(of: 17) || model.gameState.isCurrentTrickComplete || model.gameState.phase == .handComplete {
                    let restored = makeModel()
                    restored.enablePersistence(store)
                    XCTAssertNil(restored.saveNotice)
                    XCTAssertEqual(restored.snapshot, model.snapshot)
                    model = restored
                    restores += 1
                }
            }
            XCTAssertNotNil(model.winnerTeam, "Bounded match stalled: \(skill), seed \(seed)")
            XCTAssertEqual(model.gameScore, expectedScore)
            XCTAssertEqual(plays, model.completedRoundCount * 52)
            let terminal = model.snapshot
            model.startNextRound()
            XCTAssertEqual(model.snapshot, terminal)
            model.newGame()
            XCTAssertEqual(try store.load(), model.snapshot)
            XCTAssertEqual(model.gameScore, GameScore())
            XCTAssertEqual(model.completedRoundCount, 0)
            XCTAssertEqual(model.gameState.phase, .notStarted)
            print("RELEASE MATCH skill=\(skill.rawValue) seed=\(seed) rounds=\(terminal.completedRounds) plays=\(plays) redeals=\(redeals) restores=\(restores) winner=\(terminal.score.winnerTeam!) score=\(terminal.score)")
        }
    }
}

final class DealLandingSequenceTests: XCTestCase {
    private func establish(_ dealer: Tarneeb.Seat) -> DealAnimationPlayback {
        var p = DealAnimationPlayback(presentation: .init(dealerSeat: dealer))
        for index in 0..<3 { XCTAssertTrue(p.issuePacket(index)); XCTAssertTrue(p.landPacket(index)) }
        XCTAssertTrue(p.retainDealerHand()); XCTAssertTrue(p.finishSettle())
        return p
    }
    func testEveryDealerMovesThreePacketsAndRetains13WithoutSelfFlight() {
        let orders: [(Tarneeb.Seat, [Tarneeb.Seat])] = [(.south,[.east,.north,.west]),(.east,[.north,.west,.south]),(.north,[.west,.south,.east]),(.west,[.south,.east,.north])]
        for (dealer, expected) in orders {
            var p = DealAnimationPlayback(presentation: .init(dealerSeat: dealer))
            XCTAssertEqual(p.recipientOrder, expected); XCTAssertEqual(p.centralCardCount, 52)
            for index in 0..<3 {
                XCTAssertTrue(p.issuePacket(index)); XCTAssertEqual(p.flyingPackets.count, 1)
                XCTAssertEqual(p.centralCardCount, 52 - index * 13, "Counts advance only after the native packet lands")
                XCTAssertEqual(p.seat(forPacket: index), expected[index]); XCTAssertNotEqual(p.seat(forPacket: index), dealer)
                XCTAssertFalse(p.issuePacket(index + 1), "No next packet until the current packet lands")
                XCTAssertFalse(p.beginSpread()); XCTAssertEqual(p.southSpreadProgress, 0); XCTAssertEqual(p.southRevealedCardCount, 0)
                XCTAssertTrue(p.landPacket(index)); XCTAssertFalse(p.landPacket(index)); XCTAssertTrue(p.flyingPackets.isEmpty)
                XCTAssertEqual(p.establishedCardCount, (index + 1) * 13)
                XCTAssertEqual(p.centralCardCount, [39,26,13][index])
                XCTAssertEqual(p.landedCount(for: expected[index]), 13)
                for waitingSeat in expected.dropFirst(index + 1) { XCTAssertEqual(p.landedCount(for: waitingSeat), 0) }
                XCTAssertEqual(p.landedCount(for: dealer), 0)
                if index < 2 { XCTAssertFalse(p.retainDealerHand()) }
            }
            XCTAssertEqual(p.issuedPackets.count, 3); XCTAssertEqual(p.landedPackets.count, 3); XCTAssertFalse(p.issuePacket(3))
            XCTAssertTrue(p.retainDealerHand()); XCTAssertFalse(p.retainDealerHand()); XCTAssertEqual(p.establishedCardCount, 52)
            for seat in Tarneeb.Seat.dealerRotationOrder { XCTAssertEqual(p.landedCount(for: seat), 13) }
            XCTAssertEqual(p.southRevealState, .settlingBacks); XCTAssertEqual(p.southFaceDownCardCount, 13)
            XCTAssertFalse(p.beginSpread(), "The explicit brief settle must finish first")
            XCTAssertTrue(p.finishSettle()); XCTAssertTrue(p.beginSpread()); XCTAssertFalse(p.finishSpread())
            p.southSpreadProgress = 1; XCTAssertTrue(p.finishSpread()); p.southRevealState = .flipping
            for count in 1...13 { XCTAssertTrue(p.issueReveal(count)); XCTAssertFalse(p.dealCompletionAvailable) }
            for count in 1...12 { XCTAssertFalse(p.completeReveal(count)); XCTAssertFalse(p.dealCompletionAvailable) }
            XCTAssertTrue(p.completeReveal(13)); XCTAssertTrue(p.dealCompletionAvailable)
        }
    }
    func testStationHandoffCannotCommitBeforeCompleteDistributionSpreadAndReveal() {
        for dealer in Tarneeb.Seat.dealerRotationOrder {
            var p = DealAnimationPlayback(presentation: .init(dealerSeat: dealer))
            XCTAssertFalse(p.beginStationHandoff())
            for index in 0..<3 { XCTAssertTrue(p.issuePacket(index)); XCTAssertTrue(p.landPacket(index)) }
            XCTAssertTrue(p.retainDealerHand()); XCTAssertTrue(p.finishSettle())
            XCTAssertFalse(p.beginStationHandoff())
            XCTAssertTrue(p.beginSpread()); p.southSpreadProgress = 1; XCTAssertTrue(p.finishSpread())
            p.southRevealState = .flipping
            for count in 1...13 { XCTAssertTrue(p.issueReveal(count)); _ = p.completeReveal(count) }
            XCTAssertTrue(p.beginStationHandoff()); XCTAssertFalse(p.beginStationHandoff())
            XCTAssertFalse(p.stationHandoffCompleted); XCTAssertFalse(p.finishStationHandoff())
            p.stationHandoffProgress = 1
            XCTAssertTrue(p.finishStationHandoff()); XCTAssertTrue(p.stationHandoffCompleted)
            XCTAssertFalse(p.finishStationHandoff())
            XCTAssertEqual(p.issuedPackets.count, 3); XCTAssertEqual(p.establishedCardCount, 52)
        }
    }
    func testUnissuedDuplicateAndOutOfOrderPacketsCannotAdvanceTheDeal() {
        var p = DealAnimationPlayback(presentation: .init(dealerSeat: .south))
        XCTAssertFalse(p.landPacket(0)); XCTAssertFalse(p.issuePacket(1)); XCTAssertFalse(p.finishSettle())
        XCTAssertTrue(p.issuePacket(0)); XCTAssertFalse(p.issuePacket(1)); XCTAssertFalse(p.landPacket(1))
        XCTAssertTrue(p.landPacket(0)); XCTAssertFalse(p.landPacket(0)); XCTAssertFalse(p.retainDealerHand())
        XCTAssertTrue(p.issuePacket(1)); XCTAssertEqual(p.flyingPackets, [1])
        XCTAssertEqual(p.landedCount(for: .south), 0, "South dealer has no self-flight")
    }
    func testOutOfOrderRevealCompletionWaitsForAll13AfterTheRetainedHand() {
        var p = establish(.east)
        XCTAssertTrue(p.beginSpread()); p.southSpreadProgress = 1; XCTAssertTrue(p.finishSpread()); p.southRevealState = .flipping
        XCTAssertFalse(p.completeReveal(0))
        for count in 1...13 { XCTAssertTrue(p.issueReveal(count)) }
        XCTAssertFalse(p.completeReveal(13)); for count in 1...11 { XCTAssertFalse(p.completeReveal(count)) }
        XCTAssertTrue(p.completeReveal(12)); XCTAssertFalse(p.completeReveal(12))
    }
}

extension TarneebTests {
    func testDealerDeckOriginsStayInsideFeltAndClearOfStations() {
        for width in [296.0, 351.0, 369.0, 406.0, 416.0] {
            for height in [196.0, 228.0, 290.0, 400.0] {
                let geometry = RoomTableGeometry(size: CGSize(width: width, height: height))
                for seat in Seat.allCases {
                    let point = geometry.dealerDeckOrigin(seat)
                    let deck = CGRect(x: point.x - 44.5, y: point.y - 58, width: 89, height: 113)
                    XCTAssertTrue(geometry.feltRect.contains(deck), "\(width)x\(height) \(seat)")
                    let station = geometry.station(seat)
                    let label = CGRect(x: station.x - (seat == .north || seat == .south ? 80 : 31),
                                       y: station.y - 14, width: seat == .north || seat == .south ? 160 : 62, height: 28)
                    XCTAssertFalse(deck.intersects(label), "Deck overlaps \(seat) station")
                }
            }
        }
    }
}


extension TarneebTests {
    func testB2SuitPackingDistributionsAndStableShrinkingAtPhoneWidths() {
        XCTAssertEqual(LiveTableToken.cardWidth, 64)
        XCTAssertEqual(LiveTableToken.cardHeight, 90)
        let distributions = [[2,3,5,3], [4,4,3,2], [5,4,3,1], [6,3,2,2], [7,3,2,1],
                             [8,2,2,1], [10,1,1,1], [13,0,0,0], [4,3,3,3], [5,5,3,0]]
        for counts in distributions {
            let original = zip(Suit.allCases, counts).flatMap { suit, count in
                Rank.allCases.prefix(count).map { Card(suit: suit, rank: $0) }
            }
            let plan = SouthHandRowPlan(orderedOriginalHand: original)
            let packable = counts.max()! <= 7 && counts != [5,5,3,0]
            XCTAssertEqual(plan.upperSuits != nil, packable, "\(counts)")
            let initial = plan.rows(for: original)
            XCTAssertEqual(initial.map(\.count).sorted(), [6,7])
            if packable {
                for suit in Suit.allCases {
                    XCTAssertFalse(initial[0].contains { $0.suit == suit } && initial[1].contains { $0.suit == suit })
                }
            } else {
                XCTAssertEqual(initial[0], Array(original.prefix(7)))
                XCTAssertEqual(initial[1], Array(original.dropFirst(7)))
            }
            // Every possible subset catches row jumps regardless of play order.
            for mask in 0..<(1 << original.count) {
                let remaining = original.enumerated().compactMap { index, card in
                    mask & (1 << index) != 0 ? card : nil
                }
                let rows = plan.rows(for: remaining)
                XCTAssertEqual(Set(rows.flatMap { $0 }), Set(remaining))
                XCTAssertEqual(rows.flatMap { $0 }.count, remaining.count)
                XCTAssertTrue(rows.allSatisfy { $0.count <= 7 })
                if remaining.count <= 7 { XCTAssertEqual(rows, [remaining, []]) }
                for (rowIndex, row) in rows.enumerated() {
                    XCTAssertEqual(row, remaining.filter { row.contains($0) })
                    if packable && remaining.count > 7 {
                        XCTAssertEqual(row, initial[rowIndex].filter { remaining.contains($0) })
                    }
                    for width in [351.0, 369, 406] {
                        let layout = LiveHandLayout(width: width)
                        for index in row.indices {
                            let center = layout.center(column: index, row: rowIndex, rowCount: row.count)
                            XCTAssertGreaterThanOrEqual(center.x - 32, 0)
                            XCTAssertLessThanOrEqual(center.x + 32, width)
                            XCTAssertLessThanOrEqual(center.y + 45, layout.height)
                            if index > 0 {
                                XCTAssertGreaterThanOrEqual(center.x - layout.center(column: index - 1, row: rowIndex, rowCount: row.count).x, 44)
                            }
                        }
                    }
                }
            }
        }
    }
}


extension TarneebTests {
    func testB2SharedRevealedHandPolicyKeepsOriginalRowsDuringPlay() {
        for counts in [[2,3,5,3], [4,4,3,2], [6,3,2,2], [7,3,2,1], [8,2,2,1], [5,5,3,0]] {
            let suits = Suit.allCases.sorted { $0.southDisplayOrder < $1.southDisplayOrder }
            let original = zip(suits, counts).flatMap { suit, count in
                Rank.allCases.prefix(count).map { Card(suit: suit, rank: $0) }
            }
            let plan = SouthHandRowPlan(orderedOriginalHand: original)
            XCTAssertEqual(SouthHandRowPlan.presentationRows(orderedHand: original), plan.rows(for: original))
            for playedCount in 0...13 {
                let remaining = Array(original.dropFirst(playedCount))
                let played = Array(original.prefix(playedCount).reversed())
                XCTAssertEqual(SouthHandRowPlan.presentationRows(orderedHand: remaining, southPlayedCards: played),
                               plan.rows(for: remaining), "\(counts), \(playedCount) plays")
            }
        }
    }
}


extension TarneebTests {
    @MainActor
    func testB2OpeningFooterMatchesLiveReservationAfterDealInEveryConfiguration() {
        let state = Tarneeb.TarneebPresentationState(
            dealService: Tarneeb.DealService(shuffler: Tarneeb.CardShuffler { $0 }, handLogger: Tarneeb.HandLogger { _ in })
        )
        func view() -> OpeningTableView {
            OpeningTableView(
                game: state.gameState, pendingGame: nil, score: state.gameScore, playback: nil,
                reduceMotion: true, blocked: false, canDeal: true, canReset: true, choosingTrump: false,
                draftBid: .constant(.seven), draftSuit: .constant(nil),
                deal: {}, newGame: {}, submitBid: {}, submitTrump: {}, selectionFeedback: {}
            )
        }
        XCTAssertEqual(view().actionHeight, 48)
        state.deal()
        XCTAssertEqual(view().actionHeight, LiveTableToken.handFooterHeight)
        XCTAssertEqual(view().actionHeight, 72)
    }
}

extension TarneebTests {
    func testCoachPublicProjectionCoversAllRanksRejectsDuplicatesAndDeduplicatesPending() throws {
        let id = UUID()
        let deck = DeckFactory.makeCanonicalDeck()
        let all = deck.map { PlayedCard(seat: .south, card: $0) }
        let snapshot = try XCTUnwrap(PlayedTrackerSnapshot(handID: id, publicPlays: all))
        XCTAssertEqual(snapshot.played.count, 52)
        XCTAssertEqual(PlayedTrackerSnapshot.suits, [.spades, .hearts, .clubs, .diamonds])
        XCTAssertEqual(PlayedTrackerSnapshot.ranks.map(\.rawValue), ["A","K","Q","J","10","9","8","7","6","5","4","3","2"])
        for suit in PlayedTrackerSnapshot.suits { XCTAssertEqual(snapshot.count(in: suit), 13) }
        XCTAssertNil(PlayedTrackerSnapshot(handID: id, publicPlays: all + [all[0]]))
        XCTAssertEqual(PlayedTrackerSnapshot(handID: id, publicPlays: [])?.played.count, 0)
        var trick = TrickPlayState(declarerSeat: .south, tarneebSuit: .spades)
        for (seat, rank) in zip(Seat.dealOrder, Rank.allCases.prefix(4)) {
            trick.appendPlayedCard(PlayedCard(seat: seat, card: Card(suit: .clubs, rank: rank)))
        }
        XCTAssertNotNil(trick.pendingCompletedTrick)
        let pending = try XCTUnwrap(PlayedTrackerSnapshot(handID: id, publicPlays: trick.playedCards))
        XCTAssertEqual(pending.played.count, 4)
        trick.clearPendingCompletedTrick()
        XCTAssertEqual(PlayedTrackerSnapshot(handID: id, publicPlays: trick.playedCards), pending)
        XCTAssertTrue(pending.summary(for: .clubs).contains("4 played"))
        XCTAssertTrue(pending.summary(for: .spades).contains("Played: none"))
    }

    func testCoachProjectionIsInvariantUnderHiddenHandPermutations() throws {
        let dealt = try makeRoundRobinCompletedDeal()
        let contract = try makeContractState(from: dealt, highBidderSeat: .south, bidValue: .seven, tarneebSuit: .hearts)
        let publicGame = TrickPlayService().playSouthCard(Card(suit: .spades, rank: .six), in: contract.startingTrickPlayIfReady())
        let id = UUID()
        let expected = PlayedTrackerSnapshot(handID: id, publicPlays: publicGame.trickPlayState!.playedCards)
        let hidden = publicGame.players.filter { $0.seat != .south }.map(\.hand)
        for permutation in [[0,1,2],[0,2,1],[1,0,2],[1,2,0],[2,0,1],[2,1,0]] {
            var players = publicGame.players
            var offset = 0
            for i in players.indices where players[i].seat != .south { players[i].hand = hidden[permutation[offset]]; offset += 1 }
            let game = try XCTUnwrap(GameState(phase: publicGame.phase, players: players, dealerSeat: publicGame.dealerSeat,
                deck: publicGame.deck, biddingState: publicGame.biddingState, postBiddingSummary: publicGame.postBiddingSummary,
                trickPlayState: publicGame.trickPlayState))
            XCTAssertEqual(PlayedTrackerSnapshot(handID: id, publicPlays: game.trickPlayState!.playedCards), expected)
        }
        XCTAssertEqual(expected?.played.count, 1)
        XCTAssertFalse(expected!.played.contains(publicGame.players.first { $0.seat == .south }!.hand.first!))
    }

    func testCoachRevealGateRejectsEveryUnsettledAndOffState() {
        // All conditions are independently necessary, including equality and rebound/collection.
        func gate(_ failure: Int?) -> PlayedTrackerAvailability {
            PlayedTrackerAvailability(enabled: failure != 0, active: failure != 1, paused: failure == 2,
                confirming: failure == 3, flying: failure == 4, southTask: failure == 5, collecting: failure == 6,
                visibleMatchesAuthority: failure != 7, playing: failure != 8, southTurn: failure != 9, pendingTrick: failure == 10)
        }
        XCTAssertTrue(gate(nil).canOpen)
        for condition in 0...10 { XCTAssertFalse(gate(condition).canOpen, "Gate condition \(condition)") }
    }

    func testCoachDefaultOffAndToggleDoNotChangeSkillOrGame() throws {
        let suite = "coach-\(UUID())"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        XCTAssertFalse(CoachPreference.enabled(in: defaults))
        defaults.set(AISkill.expert.rawValue, forKey: AISkill.preferenceKey)
        let model = TarneebPresentationState(dealService: DealService(shuffler: CardShuffler { $0 }, handLogger: HandLogger { _ in }), aiPreferences: defaults)
        model.deal()
        let before = model.snapshot
        XCTAssertNil(model.reserveTrackerPresentation(handID: model.currentHandCoach.handID, enabled: false))
        for enabled in [true, false, true, false] {
            defaults.set(enabled, forKey: CoachPreference.key)
            XCTAssertEqual(CoachPreference.enabled(in: defaults), enabled)
            XCTAssertEqual(AISkill.preference(in: defaults), .expert)
            XCTAssertEqual(model.snapshot, before)
            XCTAssertEqual(model.activeAISkill, .expert)
        }
    }

    func testCoachUsageTokensAreIdempotentCancelAndResetAtHandBoundaries() throws {
        let model = TarneebPresentationState(dealService: DealService(shuffler: CardShuffler { $0 }, handLogger: HandLogger { _ in }),
            dealerSelector: EnvironmentDealerSelector(environment: ["TARNEEB_INITIAL_DEALER": "west"]),
            biddingService: BiddingService(bidGenerator: BidGenerator { _ in .pass }))
        model.deal()
        let originalID = model.currentHandCoach.handID
        let cancelled = try XCTUnwrap(model.reserveTrackerPresentation(handID: originalID, enabled: true))
        XCTAssertNil(model.reserveTrackerPresentation(handID: originalID, enabled: true))
        model.cancelTrackerPresentation(cancelled)
        XCTAssertFalse(model.commitTrackerPresentation(token: cancelled, handID: originalID, enabled: true))
        for count in 1...3 {
            let token = try XCTUnwrap(model.reserveTrackerPresentation(handID: originalID, enabled: true))
            XCTAssertFalse(model.commitTrackerPresentation(token: token, handID: originalID, enabled: false))
            XCTAssertTrue(model.commitTrackerPresentation(token: token, handID: originalID, enabled: true))
            XCTAssertFalse(model.commitTrackerPresentation(token: token, handID: originalID, enabled: true))
            XCTAssertEqual(model.currentHandCoach.openCount, count)
            model.cancelTrackerPresentation(token)
        }
        XCTAssertEqual(model.currentHandCoach.resultCopy, "You checked the played-card tracker 3 times this hand.")
        model.submitSouthBid(.pass)
        for _ in 0..<3 { model.resolveNextSimulatedBid() }
        model.automaticRedealAfterAllPass()
        XCTAssertNotEqual(model.currentHandCoach.handID, originalID)
        XCTAssertEqual(model.currentHandCoach.openCount, 0)
        let redealID = model.currentHandCoach.handID
        model.newGame()
        XCTAssertNotEqual(model.currentHandCoach.handID, redealID)
        XCTAssertEqual(model.currentHandCoach.openCount, 0)
        XCTAssertEqual(CurrentHandCoach(openCount: 1).resultCopy, "You checked the played-card tracker 1 time this hand.")
        XCTAssertEqual(CurrentHandCoach().resultCopy, "You checked the played-card tracker 0 times this hand.")
    }

    func testCoachSchemaOneAndTwoRemainReadableByOldReaderAndMalformedMetadataDoesNotLoseGame() throws {
        // Exact pre-Coach envelope fields; synthesized old decoding ignores additive keys.
        struct OldReader: Codable {
            var version: Int
            let game: GameState
            let score: GameScore
            let lastRound: RoundScoreResult?
            let completedRounds: Int
            let hasStarted: Bool
            let announcedRound: Int?
            var activeAISkill: AISkill?
        }
        let model = TarneebPresentationState()
        for version in [1,2] {
            var snapshot = model.snapshot
            snapshot.version = version
            let encoded = try JSONEncoder().encode(snapshot)
            let old = try JSONDecoder().decode(OldReader.self, from: encoded)
            XCTAssertEqual(old.game, snapshot.game)
            let new = try JSONDecoder().decode(MatchSnapshot.self, from: JSONEncoder().encode(old)).validated()
            XCTAssertNil(new.currentHandCoach)
            XCTAssertEqual(new.game, snapshot.game)
            var json = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
            for invalid: Any in ["bad", ["handID":"not-a-uuid","openCount":2], ["handID":UUID().uuidString,"openCount":-1], ["handID":UUID().uuidString,"openCount":"2"]] {
                json["currentHandCoach"] = invalid
                let restored = try JSONDecoder().decode(MatchSnapshot.self, from: JSONSerialization.data(withJSONObject: json)).validated()
                XCTAssertEqual(restored.game, snapshot.game)
                XCTAssertNil(restored.currentHandCoach)
                XCTAssertTrue(restored.coachMetadataWasInvalid)
            }
        }
    }

    func testCoachSaveFailureRetryWritesAbsoluteCountAndRestoreKeepsSameHand() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: folder) }
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let blocker = folder.appendingPathComponent("blocked")
        try Data("block".utf8).write(to: blocker)
        let store = MatchStore(url: blocker.appendingPathComponent("match.json"))
        let model = TarneebPresentationState()
        model.enablePersistence(store, restoring: false)
        let id = model.currentHandCoach.handID
        let token = try XCTUnwrap(model.reserveTrackerPresentation(handID: id, enabled: true))
        XCTAssertTrue(model.commitTrackerPresentation(token: token, handID: id, enabled: true))
        XCTAssertEqual(model.currentHandCoach.openCount, 1)
        XCTAssertTrue(model.coachUsageDirty)
        XCTAssertNotNil(model.saveNotice)
        model.retrySave()
        XCTAssertEqual(model.currentHandCoach.openCount, 1)
        try FileManager.default.removeItem(at: blocker)
        model.retrySave()
        XCTAssertFalse(model.coachUsageDirty)
        XCTAssertNil(model.saveNotice)
        let restored = TarneebPresentationState()
        restored.enablePersistence(store)
        XCTAssertEqual(restored.currentHandCoach, model.currentHandCoach)
        XCTAssertEqual(restored.snapshot.game, model.snapshot.game)
        XCTAssertFalse(restored.commitTrackerPresentation(token: token, handID: id, enabled: true))
        let reopened = try XCTUnwrap(restored.reserveTrackerPresentation(handID: id, enabled: true))
        XCTAssertTrue(restored.commitTrackerPresentation(token: reopened, handID: id, enabled: true))
        XCTAssertEqual(try store.load()?.currentHandCoach?.openCount, 2)
    }
}

extension TarneebTests {
    func testCoachCompletedHandRetainsCountUntilAcceptedNextDealAndRejectsStaleToken() throws {
        let model = TarneebPresentationState(dealService: DealService(shuffler: CardShuffler { $0 }, handLogger: HandLogger { _ in }),
            dealerSelector: EnvironmentDealerSelector(environment: ["TARNEEB_INITIAL_DEALER": "west"]),
            biddingService: BiddingService(bidGenerator: BidGenerator { _ in .pass }))
        model.deal()
        model.submitSouthBid(.seven, selectedTarneebSuit: .spades)
        for _ in 0..<3 { model.resolveNextSimulatedBid() }
        model.startTrickPlayIfReady()
        let id = model.currentHandCoach.handID
        let token = try XCTUnwrap(model.reserveTrackerPresentation(handID: id, enabled: true))
        XCTAssertTrue(model.commitTrackerPresentation(token: token, handID: id, enabled: true))
        for _ in 0..<13 {
            for _ in 0..<4 {
                if model.gameState.currentTrickTurnSeat == .south {
                    model.playSouthCard(try XCTUnwrap(TrickPlayRules.legalCards(for: .south, in: model.gameState).first))
                } else { model.resolveNextSimulatedTrickPlay() }
            }
            model.clearCompletedTrickIfNeeded()
        }
        XCTAssertEqual(model.gameState.phase, .handComplete)
        XCTAssertEqual(model.currentHandCoach.handID, id)
        XCTAssertEqual(model.currentHandCoach.openCount, 1)
        XCTAssertEqual(model.gameState.trickPlayState?.playedCards.count, 52)
        model.startNextRound()
        XCTAssertEqual(model.gameState.phase, .dealt)
        XCTAssertNotEqual(model.currentHandCoach.handID, id)
        XCTAssertEqual(model.currentHandCoach.openCount, 0)
        XCTAssertFalse(model.commitTrackerPresentation(token: token, handID: id, enabled: true))
    }

    func testCoachLegacyRestorePersistsFreshIdentityOnRetryWithoutChangingGame() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = MatchStore(url: directory.appendingPathComponent("match.json"))
        let source = TarneebPresentationState()
        var legacy = source.snapshot
        legacy.currentHandCoach = nil
        try store.save(legacy)
        let restored = TarneebPresentationState()
        restored.enablePersistence(store)
        XCTAssertEqual(restored.gameState, legacy.game)
        XCTAssertEqual(restored.currentHandCoach.openCount, 0)
        XCTAssertTrue(restored.coachUsageDirty)
        let identity = restored.currentHandCoach.handID
        restored.retrySave()
        XCTAssertFalse(restored.coachUsageDirty)
        XCTAssertEqual(try store.load()?.currentHandCoach?.handID, identity)
        let second = TarneebPresentationState()
        second.enablePersistence(store)
        XCTAssertEqual(second.currentHandCoach.handID, identity)
        XCTAssertEqual(second.gameState, legacy.game)
    }
}
