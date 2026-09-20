import Foundation

// Fixed order: AA, EA, AE, EE; bidding letter first, card play second.
func componentContrast(_ cells: [[Double]], weights: [Double]) -> [Double] {
    require(cells.count == 4 && weights.count == 4 && cells.allSatisfy { $0.count == cells[0].count }, "matched component arrays")
    return cells[0].indices.map { i in zip(cells,weights).reduce(0.0) { $0 + $1.0[i]*$1.1 } }
}

struct MatchComponentContrast: Codable {
    let name: String
    let weights: [Double]
    let streamEffects: [Double]
    let interval: AblationInterval
    let confidenceLevel: Double
}

struct MatchComponentAnalysis: Codable {
    let protocolID: String
    let cellOrder: [String]
    let unresolved: [Int]
    let primaryInterpretable: Bool
    let primary: [MatchComponentContrast]
    let secondary: [MatchComponentContrast]
}

func analyzeMatchComponents(paths: [String]) throws {
    require(paths.count == 4, "supply AA EA AE EE result paths")
    let reports = try paths.map { try JSONDecoder().decode(FullMatchEvaluation.self,from:Data(contentsOf:URL(fileURLWithPath:$0))) }
    let bids: [AISkill] = [.advanced,.expert,.advanced,.expert]
    let cards: [AISkill] = [.advanced,.advanced,.expert,.expert]
    for i in 0..<4 {
        let r = reports[i]
        require(r.protocolID == "match-components-2026-09-19" && r.reference == .advanced
            && r.candidateBidding == bids[i] && r.candidate == cards[i]
            && r.firstStream == 300000 && r.streams == 256 && r.matches.count == 2048, "frozen component metadata")
        let groups = Dictionary(grouping:r.matches,by:\.stream)
        require(groups.count == 256, "component stream count")
        let reconstructed = (300000..<300256).map { seed -> Double in
            let group = groups[seed] ?? []
            require(group.count == 8 && Set(group.map { "\($0.rotation):\($0.candidateTeam)" }).count == 8, "balanced component arrangements")
            return Double(group.filter { $0.candidateWon == true }.count)/8
        }
        require(reconstructed == r.streamWinLower, "component match records agree with aggregate")
    }
    let complete = reports.allSatisfy { $0.unresolved == 0 }
    let cells = reports.map(\.streamWinLower)
    func contrast(_ name: String, _ weights: [Double], primary: Bool) -> MatchComponentContrast {
        let values = componentContrast(cells,weights:weights)
        return MatchComponentContrast(name:name,weights:weights,streamEffects:values,
            interval:ablationInterval(values,z:primary ? 2.39397979981851 : 1.96),
            confidenceLevel:primary ? 0.9833333333333333 : 0.95)
    }
    // Do not make inferential claims using arbitrarily imputed censored matches.
    printAblationJSON(MatchComponentAnalysis(protocolID:"match-components-2026-09-19",cellOrder:["AA","EA","AE","EE"],
        unresolved:reports.map(\.unresolved),primaryInterpretable:complete,
        primary:complete ? [
            contrast("Expert bidding main effect",[-0.5,0.5,-0.5,0.5],primary:true),
            contrast("Expert card-play main effect",[-0.5,-0.5,0.5,0.5],primary:true),
            contrast("Bidding by card-play interaction",[1,-1,-1,1],primary:true)] : [],
        secondary:complete ? [
            contrast("Expert bidding with Advanced cards",[-1,1,0,0],primary:false),
            contrast("Expert bidding with Expert cards",[0,0,-1,1],primary:false),
            contrast("Expert cards with Advanced bidding",[-1,0,1,0],primary:false),
            contrast("Expert cards with Expert bidding",[0,-1,0,1],primary:false),
            contrast("Combined Expert versus control",[-1,0,0,1],primary:false)] : []))
}

func verifyMatchComponents() {
    func metrics() -> [MatchMetricAccumulator] { [MatchMetricAccumulator(),MatchMetricAccumulator()] }
    let old = simulateFullMatch(stream:130000,rotation:0,candidateTeam:.teamA,candidate:.standard,reference:.standard,metrics:metrics())
    let explicit = simulateFullMatch(stream:130000,rotation:0,candidateTeam:.teamA,candidate:.standard,reference:.standard,metrics:metrics(),candidateBidding:.standard)
    require(old == explicit, "component default routing preserves historical full matches")
    let control = simulateFullMatch(stream:130001,rotation:1,candidateTeam:.teamB,candidate:.advanced,reference:.advanced,metrics:metrics())
    for (bid,card) in [(AISkill.expert,AISkill.advanced),(.advanced,.expert)] {
        let m = metrics()
        let result = simulateFullMatch(stream:130001,rotation:1,candidateTeam:.teamB,candidate:card,reference:.advanced,
            metrics:m,cardLimits:AISearchLimits(seconds:0),bidLimits:AIBidSearchLimits(seconds:0),candidateBidding:bid)
        require(result == control, "forced component fallback reproduces Advanced control")
        require((m[0].bidFallbacks > 0) == (bid == .expert) && (m[0].cardFallbacks > 0) == (card == .expert)
            && m[1].bidFallbacks == 0 && m[1].cardFallbacks == 0, "independent component routing; reference unchanged")
    }
    let fixture = [[0.5,0.5],[0.25,0.25],[0.75,0.75],[0.5,0.5]]
    require(componentContrast(fixture,weights:[-0.5,0.5,-0.5,0.5]) == [-0.25,-0.25], "factorial bidding contrast")
    require(componentContrast(fixture,weights:[-0.5,-0.5,0.5,0.5]) == [0.25,0.25], "factorial card contrast")
    require(componentContrast(fixture,weights:[1,-1,-1,1]) == [0,0], "factorial additive interaction")
    require(componentContrast([[0.5],[0.25],[0.75],[0.75]],weights:[1,-1,-1,1]) == [0.25], "factorial interaction sign")
    print("Match components: historical routing parity, independent bid/card selection, fixed reference, fallback and factorial contrasts passed")
}
