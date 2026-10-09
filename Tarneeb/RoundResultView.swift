import SwiftUI

struct RoundResultView: View {
    @Environment(\.scenePhase) private var scenePhase
    let presentation: RoundResultPresentation
    let roundNumber: Int
    let trump: Suit?
    let reduceMotion: Bool
    var settledOnArrival = false
    let blocked: Bool
    let nextHand: () -> Void
    let newGame: () -> Void
    let announce: () -> Void
    var lastTrick: CompletedTrick? = nil
    var coachUsage: String? = nil
    @AppStorage(CoachPreference.key) private var coachEnabled = false

    @State private var entered = false
    @State private var factsVisible = false
    @State private var scoreVisible = false
    @State private var bloom = 0.0
    @AppStorage("tarneeb.soundEnabled") private var soundEnabled = true
    @AppStorage("tarneeb.hapticsEnabled") private var hapticsEnabled = true
    private var winner: Team? { presentation.score.winnerTeam }
    private var outcome: RoomOutcomePresentation { .init(presentation: presentation) }
    private var successful: Bool { winner.map { $0 == .teamA } ?? presentation.playerSucceeded }

    var body: some View {
        GeometryReader { proxy in
            let compact = proxy.size.height < 700
            VStack(spacing: compact ? 12 : 20) {
                header
                Spacer(minLength: 0)
                if winner == nil {
                    handHero(compact: compact)
                    contractFacts
                        .opacity(factsVisible ? 1 : 0)
                    scoreTable
                        .opacity(scoreVisible ? 1 : 0)
                    Text(outcome.earned).font(.system(size: 12)).foregroundStyle(RoomColor.muted)
                        .opacity(scoreVisible ? 1 : 0)
                } else {
                    victoryHero(compact: compact)
                    Rectangle().fill(RoomColor.brass.opacity(0.35)).frame(width: 270, height: 0.65).accessibilityHidden(true)
                    victoryScores(compact: compact)
                        .opacity(scoreVisible ? 1 : 0)
                        .offset(y: reduceMotion || scoreVisible ? 0 : 10)
                        .scaleEffect(reduceMotion || scoreVisible ? 1 : 0.986)
                    victoryFacts.opacity(factsVisible ? 1 : 0)
                }
                Spacer(minLength: 0)
                if coachEnabled, let coachUsage {
                    Text(coachUsage).font(.footnote).fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("tarneeb-coach-result")
                }
                Button(winner == nil ? "Next Hand" : "New Game", action: winner == nil ? nextHand : newGame)
                    .buttonStyle(RoomCommandStyle(arrow: true, reduceMotion: reduceMotion))
                    .disabled(blocked)
                    .accessibilityIdentifier(winner == nil ? "tarneeb-next-hand" : "tarneeb-new-match")
            }
            .frame(width: min(proxy.size.width - 32, 480), height: proxy.size.height - 16)
            .padding(.vertical, 8).frame(maxWidth: .infinity)
        }
        .foregroundStyle(RoomColor.ivory)
        .background {
            RoomBackground()
            RadialGradient(colors: [RoomColor.brass.opacity(bloom * 0.10), .clear], center: .center, startRadius: 20, endRadius: 300)
                .ignoresSafeArea().allowsHitTesting(false).accessibilityHidden(true)
        }
        .accessibilityElement(children: .contain).accessibilityIdentifier("tarneeb-round-result")
        .accessibilityValue(settledOnArrival ? "Saved result" : "")
        .task(id: scenePhase) {
            guard scenePhase == .active else { settle(); return }
            guard !entered else { settle(); return }
            entered = true
            announce()
            guard !reduceMotion, !settledOnArrival else { settle(); return }
            do {
                if winner != nil {
                    try await Task.sleep(for: .seconds(0.25))
                    withAnimation(.easeOut(duration: 0.58)) { scoreVisible = true; bloom = successful ? 1 : 0 }
                    try await Task.sleep(for: .seconds(0.37))
                    withAnimation(.easeOut(duration: 0.37)) { factsVisible = true; bloom = 0 }
                } else {
                    try await Task.sleep(for: .seconds(0.30))
                    withAnimation(.easeOut(duration: 0.24)) { factsVisible = true }
                    try await Task.sleep(for: .seconds(0.20))
                    withAnimation(.easeOut(duration: 0.28)) { scoreVisible = true }
                }
            } catch { settle() }
        }
        .onDisappear { settle() }
    }

    private func settle() { factsVisible = true; scoreVisible = true; bloom = 0 }

    private var header: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 3) {
                Text(winner == nil ? "Round \(roundNumber) complete" : "Match complete").font(.system(size: 12, weight: .medium))
                Text("First to \(GameScore.winningScore)").font(.system(size: 10)).foregroundStyle(RoomColor.muted)
                    .accessibilityIdentifier("tarneeb-match-target")
            }
            Spacer(minLength: 8)
            if winner == nil { Text("طرنيب").font(.custom("GeezaPro", fixedSize: 26)).foregroundStyle(RoomColor.brass).accessibilityHidden(true) }
            Spacer(minLength: 8)
            LastTrickRecallButton(trick: lastTrick, blocked: blocked)
            Menu {
                AISkillOptions()
                CoachOptions()
                Toggle("Sound effects", isOn: $soundEnabled)
                Toggle("Haptics", isOn: $hapticsEnabled)
                if winner == nil {
                    Divider()
                    Button("New Game", systemImage: "arrow.counterclockwise", action: newGame)
                }
            } label: {
                Image(systemName: "ellipsis").font(.system(size: 17)).frame(width: 44, height: 44)
                    .background(RoomColor.felt.opacity(0.6), in: Circle())
                    .overlay(Circle().stroke(RoomColor.edge, lineWidth: 0.65))
            }
            .accessibilityLabel("Game options").accessibilityIdentifier("tarneeb-game-options")
        }.frame(height: 44)
    }

    private func handHero(compact: Bool) -> some View {
        VStack(spacing: compact ? 10 : 16) {
            kicker(outcome.kicker)
            RoomOutcomeSeal(symbol: successful ? (outcome.isDefense ? "checkmark.shield" : "checkmark") : "minus", successful: successful)
                .frame(width: compact ? 64 : 76, height: compact ? 64 : 76).accessibilityHidden(true)
            Text(outcome.title).font(.system(size: compact ? 25 : 28, weight: .semibold))
                .multilineTextAlignment(.center).lineLimit(2).minimumScaleFactor(0.85)
                .accessibilityAddTraits(.isHeader).accessibilityIdentifier("tarneeb-result-title")
            Text(outcome.detail).font(.system(size: 13)).foregroundStyle(RoomColor.muted)
                .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
        }
    }
    private func victoryHero(compact: Bool) -> some View {
        VStack(spacing: compact ? 8 : 14) {
            // This wordmark is decoration; keep its approved size so accessibility
            // text settings cannot push the result facts or command off screen.
            Text("طرنيب").font(.custom("GeezaPro", fixedSize: compact ? 59 : 72)).foregroundStyle(successful ? RoomColor.brass : RoomColor.muted)
                .accessibilityLabel("Tarneeb Royale")
            kicker(successful ? "A PARTNERSHIP VICTORY" : "MATCH DECIDED")
            Text(outcome.title).font(.system(size: compact ? 25 : 29, weight: .semibold))
                .multilineTextAlignment(.center).lineLimit(2).minimumScaleFactor(0.85)
                .accessibilityAddTraits(.isHeader).accessibilityIdentifier("tarneeb-result-title")
            Text(successful ? "First to 31. Together." : "First to 31.").font(.system(size: 13)).foregroundStyle(RoomColor.muted)
        }
    }
    private func kicker(_ text: String) -> some View {
        Text(text).font(.system(size: 9, weight: .medium)).tracking(1.4).foregroundStyle(RoomColor.brass)
            .accessibilityIdentifier("tarneeb-result-outcome")
    }
    private var contractFacts: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(presentation.result.declaringTeam == .teamA ? "YOUR TEAM’S CONTRACT" : "OPPONENTS’ CONTRACT")
                    .font(.system(size: 9, weight: .medium)).tracking(1).foregroundStyle(RoomColor.muted)
                    .accessibilityLabel("\(presentation.result.declaringTeam.displayLabel) bid")
                bidLabel
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 8) {
                Text(presentation.result.declaringTeam == .teamA ? "YOUR TEAM’S TRICKS" : "THEIR TRICKS")
                    .font(.system(size: 9, weight: .medium)).tracking(1).foregroundStyle(RoomColor.muted)
                Text("\(presentation.result.declaringTricks) / 13").font(.system(size: 23, weight: .semibold)).monospacedDigit()
                    .accessibilityLabel("\(presentation.result.declaringTeam.displayLabel) took \(presentation.result.declaringTricks) of 13 tricks")
            }
        }.padding(16).frame(maxWidth: .infinity)
            .background(RoomColor.panel, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(RoomColor.edge, lineWidth: 0.65))
    }
    private var bidLabel: some View {
        HStack(spacing: 7) {
            if let trump { Text(trump.displaySymbol).foregroundStyle(RoomColor.brass) }
            Text("\(presentation.result.bid)\(trump.map { " \($0.rawValue.capitalized)" } ?? "")")
        }.font(.system(size: 20))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Bid \(presentation.result.bid)\(trump.map { ", Tarneeb \($0.rawValue)" } ?? "")")
    }
    private var scoreTable: some View {
        VStack(spacing: 12) {
            HStack {
                Text("MATCH SCORE").frame(maxWidth: .infinity, alignment: .leading)
                Text("HAND").frame(width: 58, alignment: .trailing)
                Text("TOTAL").frame(width: 64, alignment: .trailing)
            }.font(.system(size: 9, weight: .medium)).tracking(1).foregroundStyle(RoomColor.muted)
            ForEach([Team.teamA, .teamB], id: \.self) { team in
                Rectangle().fill(RoomColor.edge.opacity(0.5)).frame(height: 0.65).accessibilityHidden(true)
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(team == .teamA ? "You + Partner" : "East + West").font(.system(size: 14, weight: .medium))
                        Text("Previously \(presentation.previousScore(for: team))").font(.system(size: 11)).foregroundStyle(RoomColor.muted)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                    Text(presentation.change(for: team)).font(.system(size: 18)).monospacedDigit()
                        .foregroundStyle(presentation.result.scoreDelta(for: team) > 0 ? RoomColor.brass : RoomColor.muted)
                        .frame(width: 58, alignment: .trailing)
                        .accessibilityLabel("\(team.displayLabel) round change \(presentation.change(for: team))")
                    scoreValue(team, size: 27).frame(width: 64, alignment: .trailing)
                }.lineLimit(1).minimumScaleFactor(0.8)
            }
        }
    }
    private func scoreValue(_ team: Team, size: Double) -> some View {
        Text("\(presentation.score.points(for: team))").font(.system(size: size, weight: .medium)).monospacedDigit()
            .accessibilityLabel("\(team == .teamA ? "North South" : "East West") score \(presentation.score.points(for: team))")
    }
    private func victoryScores(compact: Bool) -> some View {
        HStack(spacing: 0) {
            ForEach([Team.teamA, .teamB], id: \.self) { team in
                if team == .teamB { Rectangle().fill(RoomColor.edge.opacity(0.35)).frame(width: 0.65, height: 96).accessibilityHidden(true) }
                VStack(spacing: 15) {
                    Text(team == .teamA ? "YOU + PARTNER" : "EAST + WEST").font(.system(size: 9, weight: .medium)).tracking(1).foregroundStyle(RoomColor.edge)
                    scoreValue(team, size: compact ? 64 : 77).foregroundStyle(team == winner ? RoomColor.ink : RoomColor.edge)
                        .lineLimit(1).minimumScaleFactor(0.6)
                }.frame(maxWidth: .infinity)
            }
        }.frame(height: compact ? 152 : 176)
            .background(RoomColor.ivory, in: RoundedRectangle(cornerRadius: 24))
            .overlay(alignment: .bottom) {
                RoomOutcomeSeal(symbol: successful ? "checkmark" : "minus", successful: successful)
                    .frame(width: 46, height: 46).background(RoomColor.forest, in: Circle())
                    .offset(y: 22).accessibilityHidden(true)
            }.padding(.bottom, 22)
    }
    private var victoryFacts: some View {
        VStack(spacing: 9) {
            kicker("ROUND \(roundNumber) · \(outcome.kicker)")
            Text("\(presentation.result.declaringTeam.displayLabel) bid").font(.system(size: 10)).foregroundStyle(RoomColor.muted)
            bidLabel
            Text("\(presentation.result.declaringTricks) of 13 taken · \(outcome.earned)").font(.system(size: 11)).foregroundStyle(RoomColor.muted)
                .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
            ForEach([Team.teamA, .teamB], id: \.self) { team in
                Text("\(team == .teamA ? "You + Partner" : "East + West"): \(outcome.equation(for: team))")
                    .font(.system(size: 11)).foregroundStyle(RoomColor.muted)
                    .accessibilityLabel("\(team.displayLabel) round change \(presentation.change(for: team))")
            }
        }
    }
}

private struct RoomOutcomeSeal: View {
    let symbol: String
    let successful: Bool
    var body: some View {
        ZStack {
            RoomRosette().stroke(successful ? RoomColor.brass : RoomColor.muted, lineWidth: 1)
            Circle().stroke(successful ? RoomColor.brass : RoomColor.muted, lineWidth: 0.7).padding(10)
            Image(systemName: symbol).font(.system(size: 23, weight: .medium)).foregroundStyle(successful ? RoomColor.brass : RoomColor.muted)
        }
    }
}

private struct RoomRosette: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        for index in 0..<16 {
            let angle = Double(index) * .pi / 8 - .pi / 2
            let r = radius * (index.isMultiple(of: 2) ? 1 : 0.80)
            let point = CGPoint(x: center.x + cos(angle) * r, y: center.y + sin(angle) * r)
            if index == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}
