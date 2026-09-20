import Foundation
import Darwin

// Offline only. Uses the production observer hook; never forks the search algorithm.
private func latencyCPU() -> Double {
    var value = timespec()
    require(clock_gettime(CLOCK_THREAD_CPUTIME_ID, &value) == 0, "thread CPU clock available")
    return Double(value.tv_sec) + Double(value.tv_nsec) / 1_000_000_000
}

struct LatencyContext: Codable {
    let seat: Seat
    let ownHand: [Card]
    let trick: TrickPlayState
    let contract: Int
    let matchScore: GameScore
    let seed: UInt64
    init(_ c: AIDecisionContext, seed: UInt64) {
        seat = c.seat; ownHand = c.ownHand; trick = c.trick
        contract = c.contract; matchScore = c.matchScore; self.seed = seed
    }
    var context: AIDecisionContext {
        AIDecisionContext(seat: seat, ownHand: ownHand, trick: trick, contract: contract, matchScore: matchScore)
    }
}

struct LatencyReading: Codable {
    let wallMS: Double
    let threadCPUMS: Double
    let checkpoints: Int
    let maxGapWallMS: Double
    let cpuDuringMaxGapMS: Double
    let maxGapEndingCheckpoint: Int
    let card: String?
    let samples: Int
    let fallback: Bool
    let cancelled: Bool
    let evidence: String
}

private final class LatencyProbe {
    let startWall = ProcessInfo.processInfo.systemUptime
    let startCPU = latencyCPU()
    var lastWall: Double = 0, lastCPU: Double = 0
    var checkpoints = 0, maxGap = 0.0, gapCPU = 0.0, gapIndex = 0
    init() { lastWall = startWall; lastCPU = startCPU }
    func checkpoint() {
        let wall = ProcessInfo.processInfo.systemUptime, cpu = latencyCPU()
        checkpoints += 1
        if wall - lastWall > maxGap {
            maxGap = wall - lastWall; gapCPU = cpu - lastCPU; gapIndex = checkpoints
        }
        lastWall = wall; lastCPU = cpu
    }
    func finish(_ result: AIDecisionResult, limits: AISearchLimits) -> LatencyReading {
        checkpoint() // Includes the unchecked tail/fallback and return, not just search callbacks.
        let elapsed = lastWall - startWall
        let evidence: String
        if result.cancelled { evidence = "cancellation observed" }
        else if !result.fallback { evidence = "normal return" }
        else if limits.samples <= 0 || limits.maxTricks <= 0 || limits.seconds <= 0 { evidence = "invalid/zero limits" }
        else if elapsed >= limits.seconds { evidence = "fallback with elapsed budget exceeded; exact internal reason unavailable" }
        else { evidence = "fallback before elapsed budget; exact internal reason unavailable" }
        return LatencyReading(wallMS: elapsed * 1000, threadCPUMS: (lastCPU-startCPU)*1000,
            checkpoints: checkpoints-1, maxGapWallMS: maxGap*1000, cpuDuringMaxGapMS: gapCPU*1000,
            maxGapEndingCheckpoint: gapIndex, card: result.card?.id, samples: result.samples,
            fallback: result.fallback, cancelled: result.cancelled, evidence: evidence)
    }
}

private func measureLatency(_ input: LatencyContext, instrumented: Bool,
                            limits: AISearchLimits = AISearchLimits(),
                            action: ((Int) -> Bool)? = nil) -> (AIDecisionResult, LatencyReading) {
    let probe = LatencyProbe()
    let result: AIDecisionResult
    if instrumented {
        result = ExpertCardPolicy.select(input.context, seed: input.seed, limits: limits, shouldCancel: {
            probe.checkpoint()
            return action?(probe.checkpoints) ?? false
        })
    } else { result = ExpertCardPolicy.select(input.context, seed: input.seed, limits: limits) }
    return (result, probe.finish(result, limits: limits))
}

struct LatencyDecision: Codable {
    let index: Int
    let instrumentedFirst: Bool
    let baseline: LatencyReading
    let observed: LatencyReading
    let sameResult: Bool
}
struct LatencyWitness: Codable {
    let decisionIndex: Int
    let input: LatencyContext
}
struct LatencyDistribution: Codable {
    let count: Int
    let median: Double
    let p95: Double
    let p99: Double
    let max: Double
    init(_ values: [Double]) {
        let sorted = values.sorted(); count = sorted.count
        func q(_ p: Double) -> Double { sorted.isEmpty ? 0 : sorted[Int(Double(sorted.count-1)*p)] }
        median = q(0.5); p95 = q(0.95); p99 = q(0.99); max = sorted.last ?? 0
    }
}
struct LatencyReport: Codable {
    let protocolID: String
    let firstDeck: Int
    let deckCount: Int
    let playedHands: Int
    let allPass: Int
    let baselineWallMS: LatencyDistribution
    let observedWallMS: LatencyDistribution
    let baselineThreadCPUMS: LatencyDistribution
    let observedThreadCPUMS: LatencyDistribution
    let pairedWallOverheadMS: LatencyDistribution
    let checkpointGapsMS: LatencyDistribution
    let baselineFallbacks: Int
    let observedFallbacks: Int
    let decisions: [LatencyDecision]
    let witnesses: [LatencyWitness]
}

func profileLatency() {
    let service = TrickPlayService()
    var records: [LatencyDecision] = [], witnesses: [Int: LatencyContext] = [:]
    var top: [(Int, Double)] = []
    var hands = 0, allPass = 0
    let scores = [GameScore(), GameScore(northSouth:30,eastWest:29), GameScore(northSouth:15,eastWest:20)]
    for deck in 500000..<500032 {
        for rotation in 0..<4 {
            let score = scores[(deck-500000+rotation)%scores.count]
            var game = benchmarkDeal(seed: UInt64(deck), rotation: rotation, dealer: Seat.dealOrder[rotation])
            for _ in 0..<64 {
                guard game.currentBiddingSeat != nil else { break }
                let c = bidContext(game,score:score)
                let result = AIBiddingEngine.select(bidRequest(c,skill:.advanced),seed:matchBidSeed(c))
                let next = applyBid(result.recommendation,to:game)
                require(next != game, "latency auction progression"); game = next
            }
            require(game.currentBiddingSeat == nil, "latency auction bounded")
            guard game.highestBidValue != nil else { allPass += 1; continue }
            game = game.startingTrickPlayIfReady()
            var plays = 0
            while game.phase != .handComplete {
                if game.isCurrentTrickComplete { game = service.clearCompletedTrickIfNeeded(in:game); continue }
                let c = service.decisionContext(in:game,score:score)!
                let input = LatencyContext(c,seed:matchCardSeed(c)), index = records.count
                let base: (AIDecisionResult,LatencyReading), seen: (AIDecisionResult,LatencyReading)
                if index%2 == 0 {
                    base = measureLatency(input,instrumented:false); seen = measureLatency(input,instrumented:true)
                } else {
                    seen = measureLatency(input,instrumented:true); base = measureLatency(input,instrumented:false)
                }
                let same = base.0.card == seen.0.card && base.0.samples == seen.0.samples
                    && base.0.fallback == seen.0.fallback && base.0.cancelled == seen.0.cancelled
                if !base.0.fallback && !seen.0.fallback { require(same,"latency observer parity") }
                require(!base.0.cancelled && !seen.0.cancelled && base.0.card != nil && seen.0.card != nil
                    && c.legalCards.contains(base.0.card!) && c.legalCards.contains(seen.0.card!), "latency selections legal")
                records.append(LatencyDecision(index:index,instrumentedFirst:index%2 == 1,
                    baseline:base.1,observed:seen.1,sameResult:same))
                let elapsed = max(base.1.wallMS,seen.1.wallMS)
                let keep = elapsed >= 50 || base.0.fallback || seen.0.fallback || !same
                if keep { witnesses[index] = input }
                top.append((index,elapsed)); top.sort { $0.1 > $1.1 }
                if top.count > 5 {
                    let removed = top.removeLast().0
                    let old = records[removed]
                    if max(old.baseline.wallMS,old.observed.wallMS) < 50 && !old.baseline.fallback
                        && !old.observed.fallback && old.sameResult { witnesses.removeValue(forKey:removed) }
                }
                if top.contains(where: { $0.0 == index }) { witnesses[index] = input }
                let next = c.seat == .south ? service.playSouthCard(base.0.card!,in:game)
                    : service.playSimulatedCard(base.0.card!,for:c.seat,in:game)
                require(next != game,"latency card progression"); game = next; plays += 1
                require(plays <= 52,"latency hand bounded")
            }
            require(plays == 52 && Set(game.trickPlayState!.playedCards.map(\.card)).count == 52
                && game.players.allSatisfy { $0.hand.isEmpty },"latency conservation")
            hands += 1
        }
        FileHandle.standardError.write(Data("Latency diagnostic decks: \(deck-499999)/32\n".utf8))
    }
    require(records.count == hands*52 && hands+allPass == 128,"latency accounting")
    printAblationJSON(LatencyReport(protocolID:"latency-diagnostics-2026-09-19",firstDeck:500000,deckCount:32,
        playedHands:hands,allPass:allPass,baselineWallMS:LatencyDistribution(records.map { $0.baseline.wallMS }),
        observedWallMS:LatencyDistribution(records.map { $0.observed.wallMS }),
        baselineThreadCPUMS:LatencyDistribution(records.map { $0.baseline.threadCPUMS }),
        observedThreadCPUMS:LatencyDistribution(records.map { $0.observed.threadCPUMS }),
        pairedWallOverheadMS:LatencyDistribution(records.map { $0.observed.wallMS-$0.baseline.wallMS }),
        checkpointGapsMS:LatencyDistribution(records.map { $0.observed.maxGapWallMS }),
        baselineFallbacks:records.filter { $0.baseline.fallback }.count,
        observedFallbacks:records.filter { $0.observed.fallback }.count,decisions:records,
        witnesses:witnesses.keys.sorted().map { LatencyWitness(decisionIndex:$0,input:witnesses[$0]!) }))
}

func replayLatency(path: String, index: Int) throws {
    let report = try JSONDecoder().decode(LatencyReport.self,from:Data(contentsOf:URL(fileURLWithPath:path)))
    guard let witness = report.witnesses.first(where: { $0.decisionIndex == index }) else {
        require(false,"decision is not a retained witness"); return
    }
    printAblationJSON(measureLatency(witness.input,instrumented:true).1)
}

func verifyLatencyDiagnostics() throws {
    let game = benchmarkBid(benchmarkDeal(seed:510000))!
    let c = TrickPlayService().decisionContext(in:game,score:GameScore())!
    require(c.legalCards.count > 1,"latency diagnostic fixture searches")
    let input = LatencyContext(c,seed:matchCardSeed(c))
    let decoded = try JSONDecoder().decode(LatencyContext.self,from:JSONEncoder().encode(input))
    require(decoded.context == c && decoded.seed == input.seed,"public replay round trip")
    let baseline = measureLatency(input,instrumented:false,limits:AISearchLimits(seconds:2))
    let observed = measureLatency(input,instrumented:true,limits:AISearchLimits(seconds:2))
    require(!baseline.0.fallback && !observed.0.fallback && baseline.0.card == observed.0.card
        && baseline.0.samples == observed.0.samples && observed.1.checkpoints > 0,"observer seed parity")
    let sleep = measureLatency(input,instrumented:true,action: { n in
        if n == 2 { Thread.sleep(forTimeInterval:0.2) }; return false
    })
    require(sleep.0.fallback && !sleep.0.cancelled && sleep.1.wallMS >= 190
        && sleep.1.wallMS-sleep.1.threadCPUMS > 100,"non-CPU delay and deadline evidence")
    let busy = measureLatency(input,instrumented:true,action: { n in
        if n == 2 { let start = latencyCPU(); while latencyCPU()-start < 0.2 {} }; return false
    })
    require(busy.0.fallback && !busy.0.cancelled && busy.1.threadCPUMS >= 190,"CPU delay and deadline evidence")
    let cancelled = measureLatency(input,instrumented:true,action: { _ in true })
    let midway = measureLatency(input,instrumented:true,action: { $0 >= 20 })
    require(cancelled.0.cancelled && midway.0.cancelled,"immediate/mid-search cancellation observed")
    let zero = measureLatency(input,instrumented:true,limits:AISearchLimits(seconds:0))
    require(zero.0.fallback && zero.0.card == AdvancedCardPolicy.select(c),"zero budget legal fallback")
    let invalid = AIDecisionContext(seat:c.seat,ownHand:c.ownHand+[c.ownHand[0]],trick:c.trick,contract:c.contract,matchScore:c.matchScore)
    let bad = measureLatency(LatencyContext(invalid,seed:input.seed),instrumented:true,limits:AISearchLimits(seconds:2))
    require(bad.0.fallback && bad.1.wallMS < 2000,"malformed sampler input fallback")
    for result in [sleep.0,busy.0,cancelled.0,midway.0,zero.0] {
        require(result.card != nil && c.legalCards.contains(result.card!),"diagnostic fallback legal")
    }
    printAblationJSON(["normal":observed.1,"injectedSleep":sleep.1,"injectedCPU":busy.1,
        "immediateCancellation":cancelled.1,"midSearchCancellation":midway.1,
        "zeroBudget":zero.1,"malformedInput":bad.1])
}
