import Foundation

if CommandLine.arguments.count == 2, CommandLine.arguments[1] == "latency-profile" { profileLatency(); exit(0) }
if CommandLine.arguments.count == 2, CommandLine.arguments[1] == "latency-check" { try verifyLatencyDiagnostics(); exit(0) }
if CommandLine.arguments.count == 4, CommandLine.arguments[1] == "latency-replay" {
    try replayLatency(path:CommandLine.arguments[2],index:Int(CommandLine.arguments[3])!); exit(0)
}

if CommandLine.arguments.count == 3, CommandLine.arguments[1] == "hybrid-confirmation" {
    runFullMatchBenchmark(candidate:.expert,reference:AISkill(rawValue:CommandLine.arguments[2])!,
        candidateBidding:.advanced,firstStream:400000,streamCount:256,protocolID:"hybrid-confirmation-2026-09-19")
    exit(0)
}

if CommandLine.arguments.count == 4, CommandLine.arguments[1] == "match-component" {
    let bid = AISkill(rawValue:CommandLine.arguments[2])!, card = AISkill(rawValue:CommandLine.arguments[3])!
    require(bid != .standard && card != .standard, "components use Advanced or Expert")
    runFullMatchBenchmark(candidate:card,reference:.advanced,candidateBidding:bid,
        firstStream:300000,streamCount:256,protocolID:"match-components-2026-09-19")
    exit(0)
}
if CommandLine.arguments.count == 6, CommandLine.arguments[1] == "match-component-analysis" {
    try analyzeMatchComponents(paths:Array(CommandLine.arguments.dropFirst(2))); exit(0)
}

if CommandLine.arguments.count == 4, CommandLine.arguments[1] == "full-match" {
    runFullMatchBenchmark(candidate:AISkill(rawValue:CommandLine.arguments[2])!,reference:AISkill(rawValue:CommandLine.arguments[3])!)
    exit(0)
}

if CommandLine.arguments.contains("current-expert-advanced") { evaluateCurrentExpertAdvanced(); exit(0) }

if CommandLine.arguments.contains("public-threat-expert-cards") { integrateExpertCards(); exit(0) }
if CommandLine.arguments.contains("public-threat-expert-bids") { integrateExpertBidding(); exit(0) }

if CommandLine.arguments.contains("public-threat-train") { trainPublicThreat(); exit(0) }
if CommandLine.arguments.count == 3, CommandLine.arguments[1] == "public-threat-heldout" {
    try publicThreatHeldout(CommandLine.arguments[2]); exit(0)
}

if CommandLine.arguments.contains("ablation-check") { verifyAblation(); exit(0) }
if CommandLine.arguments.contains("ablation-train") { trainAblation(); exit(0) }
if CommandLine.arguments.count == 3, CommandLine.arguments[1] == "ablation-heldout" {
    try evaluateFrozenAblation(path: CommandLine.arguments[2]); exit(0)
}

if CommandLine.arguments.contains("bid-profile") { profileBidding(); exit(0) }
if CommandLine.arguments.count >= 6, CommandLine.arguments[1] == "bid-benchmark" {
    runBiddingBenchmark(candidate: AISkill(rawValue: CommandLine.arguments[2])!,
        reference: AISkill(rawValue: CommandLine.arguments[3])!,
        firstSeed: Int(CommandLine.arguments[4])!, count: Int(CommandLine.arguments[5])!)
    exit(0)
}

if CommandLine.arguments.contains("bid-baseline") {
    let (hash, count) = biddingBaselineFingerprint()
    print("Standard bidding baseline: \(count) recommendations; FNV-1a \(hash)")
    exit(0)
}

if CommandLine.arguments.contains("profile") {
    profileSearch()
    exit(0)
}
if CommandLine.arguments.count >= 6, CommandLine.arguments[1] == "benchmark" {
    runBenchmark(candidate: AISkill(rawValue: CommandLine.arguments[2])!,
                 reference: AISkill(rawValue: CommandLine.arguments[3])!,
                 firstSeed: Int(CommandLine.arguments[4])!, count: Int(CommandLine.arguments[5])!,
                 limits: AISearchLimits())
    exit(0)
}

func require(_ condition: @autoclosure () -> Bool, _ message: String) {
    if !condition() {
        FileHandle.standardError.write(Data("FAIL: \(message)\n".utf8))
        exit(1)
    }
}

// Characterization is added and run before changing shared selection paths.
var checks = 0
let deck = DeckFactory.makeCanonicalDeck()
for trump in Suit.allCases {
    for seat in Seat.allCases {
        for offset in 0..<52 {
            let hand = (0..<13).map { deck[(offset + $0 * 3) % 52] }
            for count in 0...3 {
                var actor = seat
                for _ in 0..<(4-count) { actor = actor.nextCounterclockwiseDealer }
                let others = deck.filter { !hand.contains($0) }
                let trick = (0..<count).map { index -> PlayedCard in
                    defer { actor = actor.nextCounterclockwiseDealer }
                    return PlayedCard(seat: actor, card: others[index])
                }
                let follow = hand.filter { $0.suit == trick.first?.card.suit }
                let legal = follow.isEmpty ? hand : follow
                let expected = FrozenStandard.select(from: legal, for: seat, currentTrick: trick, tarneebSuit: trump, ownHand: hand)
                for options in [legal, Array(legal.reversed())] {
                    require(AutomatedCardSelector.select(from: options, for: seat, currentTrick: trick, tarneebSuit: trump, ownHand: hand) == expected, "Standard parity")
                    checks += 1
                }
            }
        }
    }
}
print("Standard characterization: \(checks) comparisons passed")
try verifySkills()
verifyContractSensitivity()
verifyEveryContractSeatAndSuit()
try verifyBidding()
verifyPromotedPublicThreat()
verifyFullMatchHarness()
verifyMatchComponents()
