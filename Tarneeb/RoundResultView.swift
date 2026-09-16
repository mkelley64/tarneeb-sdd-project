import SwiftUI

struct RoundResultView: View {
    let presentation: RoundResultPresentation
    let roundNumber: Int
    let trump: Suit?
    let reduceMotion: Bool
    let blocked: Bool
    let nextHand: () -> Void
    let newGame: () -> Void
    let announce: () -> Void
    var lastTrick: CompletedTrick? = nil

    @State private var appeared = false
    @AppStorage("tarneeb.soundEnabled") private var soundEnabled = true
    @AppStorage("tarneeb.hapticsEnabled") private var hapticsEnabled = true

    private var winner: Team? { presentation.score.winnerTeam }
    private var accent: Color { GameColorToken.stationOutlineActive.swiftUIColor }

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(winner == nil ? "Round \(roundNumber)" : "Match complete")
                            .font(.subheadline.weight(.semibold))
                        Text("First to \(GameScore.winningScore)")
                            .font(.caption2)
                            .foregroundStyle(GameColorToken.textSecondary.swiftUIColor)
                            .accessibilityIdentifier("tarneeb-match-target")
                    }
                    Spacer()
                    LastTrickRecallButton(trick: lastTrick, blocked: blocked)
                    Menu {
                        Toggle("Sound effects", isOn: $soundEnabled)
                        Toggle("Haptics", isOn: $hapticsEnabled)
                        if winner == nil {
                            Divider()
                            Button("New Game", systemImage: "arrow.counterclockwise", action: newGame)
                        }
                    } label: {
                        Image(systemName: "ellipsis").frame(width: 44, height: 36)
                    }
                    .accessibilityLabel("Game options")
                    .accessibilityIdentifier("tarneeb-game-options")
                }
                Spacer(minLength: 0)
                VStack(spacing: 12) {
                    Image(systemName: winner != nil ? "trophy.fill" : (presentation.contractMade ? "checkmark.seal.fill" : "flag.slash.fill"))
                        .font(.system(size: RoundResultToken.emblemSize))
                        .foregroundStyle(winner == .teamA || (winner == nil && presentation.playerSucceeded) ? accent : GameColorToken.textSecondary.swiftUIColor)
                        .scaleEffect(reduceMotion || appeared || winner != .teamA ? 1 : RoundResultToken.entranceScale)
                        .accessibilityHidden(true)
                    Text(presentation.title)
                        .font(.system(size: RoundResultToken.titleSize, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .lineLimit(2).minimumScaleFactor(0.8)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityIdentifier("tarneeb-result-title")
                    if winner != nil {
                        Text("Round \(roundNumber): \(presentation.contractTitle)")
                            .font(.subheadline.weight(.semibold))
                    }
                    Text(presentation.detail)
                        .font(.subheadline)
                        .foregroundStyle(GameColorToken.textSecondary.swiftUIColor)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                HStack(spacing: 24) {
                    VStack(spacing: 4) {
                        Text("\(presentation.result.declaringTeam.displayLabel) bid")
                            .font(.caption).lineLimit(1).minimumScaleFactor(0.8)
                            .foregroundStyle(GameColorToken.textSecondary.swiftUIColor)
                        HStack(spacing: 6) {
                            Text("\(presentation.result.bid)")
                            if let trump { Text(trump.displaySymbol).foregroundStyle(accent) }
                        }
                        .font(.title2.weight(.bold))
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Bid \(presentation.result.bid)\(trump.map { ", Tarneeb \($0.rawValue)" } ?? "")")
                    }
                    VStack(spacing: 4) {
                        Text("Tricks taken").font(.caption)
                            .foregroundStyle(GameColorToken.textSecondary.swiftUIColor)
                        Text("\(presentation.result.declaringTricks) / 13")
                            .font(.title2.weight(.bold)).monospacedDigit()
                            .accessibilityLabel("\(presentation.result.declaringTeam.displayLabel) took \(presentation.result.declaringTricks) of 13 tricks")
                    }
                }
                .padding(.vertical, 8)
                scoreTable
                Spacer(minLength: 0)
                Button(action: winner == nil ? nextHand : newGame) {
                    Text(winner == nil ? "Next Hand" : "New Game")
                }
                    .buttonStyle(TableCommandStyle(
                        emblem: winner == nil ? "rectangle.stack.fill" : "arrow.counterclockwise",
                        height: RoundResultToken.commandHeight, reduceMotion: reduceMotion
                    ))
                    .disabled(blocked)
                    .accessibilityIdentifier(winner == nil ? "tarneeb-next-hand" : "tarneeb-new-match")
            }
            .frame(width: min(proxy.size.width - 32, 480), height: proxy.size.height - 16)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .opacity(appeared ? 1 : 0)
        }
        .foregroundStyle(GameColorToken.textPrimary.swiftUIColor)
        .background {
            GameColorToken.tableBackgroundPrimary.swiftUIColor.ignoresSafeArea()
            TableFeltSurface(showsRim: false).padding(24)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-round-result")
        .onAppear {
            withAnimation(reduceMotion ? .easeOut(duration: LiveTableToken.reducedMotionDuration) : .spring(duration: RoundResultToken.entranceDuration)) {
                appeared = true
            }
            announce()
        }
    }

    private var scoreTable: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Team").frame(maxWidth: .infinity, alignment: .leading)
                Text("Round").frame(width: RoundResultToken.scoreColumnWidth, alignment: .trailing)
                Text("Total").frame(width: RoundResultToken.scoreColumnWidth, alignment: .trailing)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(GameColorToken.textSecondary.swiftUIColor)
            ForEach([Team.teamA, .teamB], id: \.self) { team in
                Rectangle()
                    .fill(GameColorToken.textSecondary.swiftUIColor.opacity(TableFinishToken.dividerOpacity))
                    .frame(height: TableFinishToken.hairline)
                    .accessibilityHidden(true)
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(team == .teamA ? "You + North" : "East + West").font(.subheadline.weight(.semibold))
                        Text("Was \(presentation.previousScore(for: team))")
                            .font(.caption).foregroundStyle(GameColorToken.textSecondary.swiftUIColor)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Text(presentation.change(for: team))
                        .font(.title3.weight(.semibold)).monospacedDigit()
                        .foregroundStyle(presentation.result.scoreDelta(for: team) > 0 ? accent : GameColorToken.textPrimary.swiftUIColor)
                        .frame(width: RoundResultToken.scoreColumnWidth, alignment: .trailing)
                        .accessibilityLabel("\(team.displayLabel) round change \(presentation.change(for: team))")
                    Text("\(presentation.score.points(for: team))")
                        .font(.title2.weight(.bold)).monospacedDigit()
                        .frame(width: RoundResultToken.scoreColumnWidth, alignment: .trailing)
                        .accessibilityLabel("\(team == .teamA ? "North South" : "East West") score \(presentation.score.points(for: team))")
                }
                .lineLimit(1).minimumScaleFactor(0.75)
            }
        }
    }
}
