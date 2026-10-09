import SwiftUI

private struct HandCardDrag {
    let card: Card
    let translation: CGSize
}

struct CardFramePreference: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, next in next })
    }
}

extension View {
    func liveAnchor(_ key: String) -> some View {
        background(GeometryReader { proxy in
            Color.clear.preference(key: CardFramePreference.self, value: [key: proxy.frame(in: .named("liveTable"))])
        })
    }
}

struct LiveTableView: View {
    let game: GameState
    let inputGame: GameState
    let score: GameScore
    let flight: LiveCardFlight?
    let collecting: Bool
    let blocked: Bool
    let reduceMotion: Bool
    let play: (Card) -> Void
    let selectFeedback: () -> Void
    let newGame: () -> Void
    let pause: () -> Void
    let resume: () -> Void
    let roundResult: String
    var continuity: Namespace.ID? = nil
    var coachEnabled = false
    var trackerAvailable = false
    var trackerVisible = false
    var openTracker: () -> Void = {}
    var trackerFocusRevision = 0
    @AccessibilityFocusState private var playedFocused: Bool

    @State private var winnerWarmth = 0.0
    @State private var selectedID: String?
    @State private var showsNewGameConfirmation = false
    @State private var frames: [String: CGRect] = [:]
    @GestureState private var handDrag: HandCardDrag?
    @State private var releasedCardOrigins: [String: CGRect] = [:]
    @AppStorage("tarneeb.soundEnabled") private var soundEnabled = true
    @AppStorage("tarneeb.hapticsEnabled") private var hapticsEnabled = true

    private var hand: [Card] {
        SouthHandPresentation.cardPresentations(
            from: game.players.first { $0.seat == .south }?.hand ?? [],
            sizeConfiguration: .sharedBase
        ).map(\.card)
    }

    private var selectedCard: Card? { hand.first { $0.id == selectedID } }
    private var winner: Seat? { game.trickPlayState?.pendingCompletedTrick?.winnerSeat }
    private var canSelect: Bool { !blocked && inputGame.currentTrickTurnSeat == .south && !inputGame.isCurrentTrickComplete }
    private var ink: Color { RoomColor.ivory }
    private var accent: Color { RoomColor.brass }

    var body: some View {
        GeometryReader { proxy in
            let contentWidth = min(proxy.size.width - 24, 560)
            VStack(spacing: 8) {
                header.accessibilityHidden(trackerVisible)
                contract.accessibilityHidden(trackerVisible)
                table.accessibilityHidden(trackerVisible)
                    .frame(minHeight: 228)
                handView(width: contentWidth)
                actionBar.accessibilityHidden(trackerVisible)
            }
            .frame(width: contentWidth, height: proxy.size.height - 16)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .coordinateSpace(name: "liveTable")
            .onPreferenceChange(CardFramePreference.self) { frames = $0 }
            .overlay(alignment: .topLeading) {
                draggingCard
                if flight?.play.seat == .south { flyingCard(in: nil) }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-live-table")
        .confirmationDialog("Start a new game?", isPresented: $showsNewGameConfirmation, titleVisibility: .visible) {
            Button("Cancel Game", role: .destructive, action: newGame)
            Button("Keep Playing", role: .cancel) { }
        } message: {
            Text("The current score and round progress will be lost.")
        }
        .onChange(of: showsNewGameConfirmation) { _, shown in
            if !shown { resume() }
        }
        .onChange(of: flight?.play.id) { _, id in
            if id == nil { releasedCardOrigins.removeAll() }
        }
        .onChange(of: trackerFocusRevision) { _, _ in playedFocused = true }
        .onChange(of: game) { _, _ in
            if let selectedCard, !TrickPlayRules.isLegal(card: selectedCard, for: .south, in: inputGame) {
                selectedID = nil
            } else if selectedCard == nil {
                selectedID = nil
            }
        }
    }

    private var isWordmarkGeometryTest: Bool {
        #if DEBUG
        return ProcessInfo.processInfo.environment["TARNEEB_HEADER_SCORE"] != nil
        #else
        return false
        #endif
    }
    private var headerScore: GameScore {
        #if DEBUG
        if let values = ProcessInfo.processInfo.environment["TARNEEB_HEADER_SCORE"]?.split(separator: ","),
           values.count == 2, let ours = Int(values[0]), let theirs = Int(values[1]) {
            return GameScore(northSouth: ours, eastWest: theirs)
        }
        #endif
        return score
    }
    private var header: some View {
        HStack {
            RoomScoreHeading(score: headerScore, centersWordmark: true)
            Spacer(minLength: 4)
            Menu {
                AISkillOptions()
                CoachOptions()
                Toggle("Sound effects", isOn: $soundEnabled)
                Toggle("Haptics", isOn: $hapticsEnabled)
                Divider()
                Button("New Game", systemImage: "arrow.counterclockwise") { pause(); showsNewGameConfirmation = true }
            } label: {
                Image(systemName: "ellipsis").font(.system(size: 17)).frame(width: 44, height: 44)
                    .background(RoomColor.felt.opacity(0.6), in: Circle())
                    .overlay(Circle().stroke(RoomColor.edge, lineWidth: 0.65))
            }
            .accessibilityLabel("Game options").accessibilityIdentifier("tarneeb-game-options")
        }.foregroundStyle(ink).frame(height: 50)
        .overlayPreferenceValue(ScoreWordmarkAnchor.self) { anchor in
            GeometryReader { proxy in
                if let anchor {
                    Text("طرنيب").font(.custom("GeezaPro", fixedSize: 23)).foregroundStyle(RoomColor.brass)
                        .position(x: proxy.size.width / 2, y: proxy[anchor].midY)
                        .accessibilityHidden(!isWordmarkGeometryTest)
                        .accessibilityIdentifier("tarneeb-live-wordmark")
                }
            }.allowsHitTesting(false)
        }
    }

    private var contract: some View { RoomContract(game: game, reduceMotion: reduceMotion).frame(height: 66) }

    private var table: some View {
        GeometryReader { proxy in
            let geometry = RoomTableGeometry(size: proxy.size)
            ZStack(alignment: .topLeading) {
                RoomFelt(warmth: winnerWarmth).frame(width: geometry.feltRect.width, height: geometry.feltRect.height)
                    .roomGeometry("felt", in: continuity, properties: .frame)
                    .position(x: geometry.feltRect.midX, y: geometry.feltRect.midY)
                ForEach(Seat.allCases, id: \.self) { seat in
                    station(seat, compact: geometry.compact)
                        .roomGeometry("station-\(seat.rawValue)", in: continuity)
                        .liveAnchor("station-\(seat.rawValue)").position(geometry.station(seat)).zIndex(20)
                }
                if flight?.play.seat != .south { flyingCard(in: frames["drop-table"]).zIndex(10) }
                ForEach(Seat.allCases, id: \.self) { seat in
                    Color.clear.frame(width: 64 * geometry.cardScale, height: 90 * geometry.cardScale)
                        .liveAnchor("slot-\(seat.rawValue)").position(geometry.slot(seat)).accessibilityHidden(true)
                    if let played = game.trickPlayState?.playedCard(for: seat), flight?.play.id != played.id {
                        ReadableCardFace(card: played.card, roomStyle: true)
                            .overlay(RoundedRectangle(cornerRadius: 7).stroke(accent, lineWidth: winner == seat ? 2 : 0))
                            .scaleEffect(geometry.cardScale)
                            .rotationEffect(.degrees(reduceMotion ? 0 : seat == .west ? -6 : seat == .east ? 6 : 0))
                            .modifier(RoomCollection(progress: collecting ? 1 : 0, source: geometry.slot(seat), target: geometry.collection(winner ?? seat), reduceMotion: reduceMotion))
                            .zIndex(collecting ? 5 : 1)
                            .accessibilityLabel("\(seat.displayLabel), \(played.card.rank.displayLabel) of \(played.card.suit.rawValue)\(winner == seat ? ", winning card" : "")")
                            .accessibilityIdentifier("tarneeb-live-played-\(seat.rawValue)")
                    }
                }
            }.contentShape(Rectangle())
        }
        .liveAnchor("drop-table").accessibilityElement(children: .contain).accessibilityIdentifier("tarneeb-live-trick")
        .task(id: winner) {
            winnerWarmth = 0
            guard winner == .north || winner == .south, !reduceMotion else { return }
            withAnimation(.easeOut(duration: 0.12)) { winnerWarmth = 1 }
            do { try await Task.sleep(for: .seconds(0.12)) } catch { winnerWarmth = 0; return }
            withAnimation(.easeOut(duration: 0.53)) { winnerWarmth = 0 }
        }
    }

    private func station(_ seat: Seat, compact: Bool) -> some View {
        let active = game.currentTrickTurnSeat == seat && winner == nil
        let ownership = RoomTrickOwnership(trick: game.trickPlayState)
        let lastWinner = game.trickPlayState?.completedTricks.last?.winnerSeat
        let nextLead = active && game.trickPlayState?.currentTrick.isEmpty == true && lastWinner == seat
        let detail = winner == seat ? "Wins trick \((game.trickPlayState?.completedTricks.count ?? 0) + 1)" : nextLead ? "Leads next" : seat == .south ? (active ? "Your turn" : "") : ""
        return RoomStation(seat: seat, detail: detail, active: active, winner: winner == seat,
                           dealer: game.dealerSeat == seat && seat != .south, cards: seat != .south && game.players.first { $0.seat == seat }?.hand.isEmpty != true,
                           detailInFooter: seat == .north && compact,
                           packetAnchor: "packet-\(seat.rawValue)")
            .accessibilityLabel("\(seat == .north ? "North, your partner" : seat == .south ? "You" : seat.displayLabel), \(ownership.count(for: seat)) tricks\(game.dealerSeat == seat ? ", dealer" : "")\(active ? ", playing" : "")")
            .accessibilityIdentifier("tarneeb-live-station-\(seat.rawValue)")
    }

    private var handRows: [[Card]] {
        let played = game.trickPlayState?.playedCards.filter { $0.seat == .south }.map(\.card) ?? []
        return SouthHandRowPlan.presentationRows(orderedHand: hand, southPlayedCards: played)
    }

    private func handView(width: Double) -> some View {
        let layout = LiveHandLayout(width: width)
        let rows = handRows
        let displayedHand = rows.flatMap { $0 }
        return ZStack(alignment: .topLeading) {
            ForEach(Array(displayedHand.enumerated()), id: \.element.id) { index, card in
                let legal = TrickPlayRules.isLegal(card: card, for: .south, in: inputGame)
                let selected = selectedID == card.id
                Button {
                    select(card)
                } label: {
                    ReadableCardFace(card: card, subdued: canSelect && !legal, roomStyle: true)
                        .overlay {
                            if selected {
                                RoundedRectangle(cornerRadius: 7).stroke(accent, lineWidth: 3)
                            }
                        }
                }
                .buttonStyle(LiveHandButtonStyle())
                .highPriorityGesture(cardGesture(card))
                .disabled(!canSelect || !legal)
                .offset(y: selected ? -LiveTableToken.selectionLift : 0)
                .liveAnchor(card.id)
                .opacity(flight?.play.card.id == card.id || handDrag?.card.id == card.id ? 0 : 1)
                .position(layout.center(column: index < rows[0].count ? index : index - rows[0].count,
                                        row: index < rows[0].count ? 0 : 1,
                                        rowCount: index < rows[0].count ? rows[0].count : rows[1].count))
                .zIndex(Double(index))
                .accessibilityLabel("\(card.rank.displayLabel) of \(card.suit.rawValue)")
                .accessibilityValue(selected ? "Selected" : (legal ? "Playable" : "Unavailable"))
                .accessibilityHint(legal ? "Select card. Use the Play action to play it." : "")
                .accessibilityIdentifier("tarneeb-live-card-\(card.id)")
                .accessibilityHidden(trackerVisible)
                .accessibilityAction(named: "Play") {
                    guard canSelect, legal else { return }
                    play(card)
                }
            }
        }
        .frame(width: width, height: layout.height)
        .roomGeometry("south-hand", in: continuity)
        .liveAnchor("station-south")
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-live-hand")
    }

    private func cardGesture(_ card: Card) -> some Gesture {
        DragGesture(coordinateSpace: .named("liveTable"))
            .updating($handDrag) { value, drag, _ in
                guard canSelect, TrickPlayRules.isLegal(card: card, for: .south, in: inputGame) else { return }
                drag = HandCardDrag(card: card, translation: value.translation)
            }
            .onEnded { value in
                guard canSelect, TrickPlayRules.isLegal(card: card, for: .south, in: inputGame),
                      frames["drop-table"]?.contains(value.location) == true,
                      let source = frames[card.id] else { return }
                // Continue the landing animation from the release point, not the hand.
                releasedCardOrigins[card.id] = source.offsetBy(dx: value.translation.width, dy: value.translation.height)
                play(card)
            }
            .exclusively(before:
                TapGesture(count: 2)
                    .exclusively(before: TapGesture(count: 1))
                    .onEnded { gesture in
                        guard canSelect, TrickPlayRules.isLegal(card: card, for: .south, in: inputGame) else { return }
                        switch gesture {
                        case .first: play(card)
                        case .second: select(card)
                        }
                    }
            )
    }

    @ViewBuilder
    private var draggingCard: some View {
        if let drag = handDrag, canSelect, let source = frames[drag.card.id] {
            ReadableCardFace(card: drag.card, roomStyle: true)
                .position(x: source.midX + drag.translation.width, y: source.midY + drag.translation.height)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
    }

    private func select(_ card: Card) {
        guard canSelect, TrickPlayRules.isLegal(card: card, for: .south, in: inputGame) else { return }
        withAnimation(reduceMotion ? nil : .snappy(duration: 0.18)) {
            selectedID = selectedID == card.id ? nil : card.id
        }
        selectFeedback()
    }

    private var actionBar: some View {
        let ownership = RoomTrickOwnership(trick: game.trickPlayState)
        return VStack(spacing: 7) {
            (Text(trackerVisible ? "Close Played cards to continue" : status) + Text(canSelect && winner == nil && selectedCard == nil ? (inputGame.trickPlayState?.ledSuit.map { " · Follow \($0.rawValue)" } ?? "") + " · Double-tap or drag to play" : ""))
                .font(.system(size: 12, weight: .medium)).foregroundStyle(RoomColor.muted)
                .lineLimit(1).minimumScaleFactor(0.75).accessibilityLabel(status)
                .accessibilityHint(canSelect ? "Double-tap or drag to play" : "").accessibilityIdentifier("tarneeb-live-status")
            HStack(alignment: .center, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("YOUR TEAM").font(.system(size: 9, weight: .medium)).tracking(1).foregroundStyle(RoomColor.muted)
                    HStack(spacing: 3) {
                        Text("\(ownership.count(for: .teamA)) ·").accessibilityLabel("Your team tricks").accessibilityValue("\(ownership.count(for: .teamA))").accessibilityIdentifier("tarneeb-live-team-tricks")
                        Text("You \(ownership.count(for: .south))").accessibilityLabel("Your tricks").accessibilityValue("\(ownership.count(for: .south))").accessibilityIdentifier("tarneeb-live-south-tricks")
                        if game.dealerSeat == .south { RoomDealerBadge().accessibilityLabel("You, dealer").accessibilityIdentifier("tarneeb-live-dealer-south") }
                    }.font(.system(size: 16, weight: .semibold)).monospacedDigit()
                }
                Spacer(minLength: 0)
                VStack(alignment: .leading, spacing: 4) {
                    Text("OPPONENTS").font(.system(size: 9, weight: .medium)).tracking(1).foregroundStyle(RoomColor.muted)
                    Text("\(ownership.count(for: .teamB)) tricks").font(.system(size: 16)).monospacedDigit()
                }
                LastTrickRecallButton(trick: game.trickPlayState?.completedTricks.last, blocked: blocked, pause: pause, resume: resume)
                    // Keep the approved 44×36 ornament; expand only the button's input region.
                    .background(Circle().fill(RoomColor.felt.opacity(0.6)).frame(width: 44, height: 36))
                    .overlay(Circle().stroke(RoomColor.edge, lineWidth: 0.65).frame(width: 44, height: 36))
            }
            .overlay {
                if coachEnabled {
                    Button("Played", action: openTracker)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(RoomColor.ivory)
                        .frame(width: 76, height: 44)
                        .background(RoomColor.forest, in: RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(RoomColor.brass, lineWidth: 1))
                        .disabled(!trackerAvailable)
                        .accessibilityLabel("Played cards")
                        .accessibilityHint(trackerAvailable ? "Opens the played-card tracker" : "Available on your turn after cards settle.")
                        .accessibilityIdentifier("tarneeb-played-button")
                        .accessibilityFocused($playedFocused)
                }
            }
        }.foregroundStyle(ink).frame(height: LiveTableToken.handFooterHeight)
    }

    private var status: String {
        if game.phase == .handComplete { return roundResult }
        if let winner { return winner == .north ? "Partner takes the trick · That one is ours" : winner == .south ? "You take the trick" : "\(winner.displayLabel) takes the trick" }
        if let selectedCard, canSelect { return "\(selectedCard.rank.displayLabel)\(selectedCard.suit.displaySymbol) selected · Double-tap or drag to play" }
        if canSelect { return "Your turn" }
        if let flight { return flight.play.seat == .south ? "You play" : "\(flight.play.seat.displayLabel) plays" }
        if game.currentTrickTurnSeat == .north, game.trickPlayState?.currentTrick.isEmpty == true { return "Partner leads next" }
        return "\(game.currentTrickTurnSeat?.displayLabel ?? "") is playing"
    }

    @ViewBuilder private func flyingCard(in tableFrame: CGRect?) -> some View {
        if let flight {
            let sourceKey = flight.play.seat == .south ? flight.play.card.id : "packet-\(flight.play.seat.rawValue)"
            if let source = releasedCardOrigins[sourceKey] ?? frames[sourceKey] ?? frames["station-\(flight.play.seat.rawValue)"], let target = frames["slot-\(flight.play.seat.rawValue)"] {
                let origin = tableFrame?.origin ?? .zero
                ReadableCardFace(card: flight.play.card, roomStyle: true)
                    .scaleEffect(min(1, target.width / LiveTableToken.cardWidth))
                    .id(flight.play.id)
                    .modifier(RoomCardTravel(progress: flight.arrived ? 1 : 0, contact: flight.contact,
                                             source: CGPoint(x: source.midX - origin.x, y: source.midY - origin.y), target: CGPoint(x: target.midX - origin.x, y: target.midY - origin.y), reduceMotion: reduceMotion,
                                             sourceScale: flight.play.seat == .south ? 1 : min(1, source.width / target.width)))
                    .allowsHitTesting(false).accessibilityHidden(true).accessibilityIdentifier("tarneeb-live-flight")
            }
        }
    }

}

struct MatchScoreHeading: View {
    let score: GameScore

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                scoreValue("Us", points: score.northSouth, spokenTeam: "North South")
                Rectangle()
                    .fill(GameColorToken.textSecondary.swiftUIColor.opacity(TableFinishToken.dividerOpacity))
                    .frame(width: TableFinishToken.hairline, height: 18)
                    .accessibilityHidden(true)
                scoreValue("Them", points: score.eastWest, spokenTeam: "East West")
            }
            .font(.system(.headline, design: .rounded).weight(.bold))
            Text("First to \(GameScore.winningScore)")
                .font(.caption2)
                .foregroundStyle(GameColorToken.textSecondary.swiftUIColor)
                .accessibilityIdentifier("tarneeb-match-target")
        }
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }

    private func scoreValue(_ label: String, points: Int, spokenTeam: String) -> some View {
        (
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(GameColorToken.textSecondary.swiftUIColor)
            + Text("  \(points)")
                .monospacedDigit()
                .foregroundStyle(GameColorToken.textPrimary.swiftUIColor)
        )
        .accessibilityLabel("\(spokenTeam) score \(points)")
    }
}

struct TableFeltSurface: View {
    var showsRim = true

    var body: some View {
        Ellipse()
            .fill(GameColorToken.tableBackgroundSecondary.swiftUIColor.opacity(TableFinishToken.fillOpacity))
            .overlay {
                Canvas { context, size in
                    var threads = Path()
                    // Alternate thread direction without random values or moving texture.
                    for row in 0..<Int(ceil(size.height / TableFinishToken.weaveSpacing)) {
                        for column in 0..<Int(ceil(size.width / TableFinishToken.weaveSpacing)) {
                            let x = Double(column) * TableFinishToken.weaveSpacing
                            let y = Double(row) * TableFinishToken.weaveSpacing
                            threads.move(to: CGPoint(x: x, y: y))
                            threads.addLine(to: CGPoint(
                                x: x + TableFinishToken.weaveLength,
                                y: y + (row.isMultiple(of: 2) ? 1 : -1) * TableFinishToken.weaveLength
                            ))
                        }
                    }
                    context.stroke(threads, with: .color(GameColorToken.tableTitleText.swiftUIColor.opacity(TableFinishToken.weaveOpacity)), lineWidth: TableFinishToken.hairline)
                }
                .clipShape(Ellipse())
            }
            .overlay {
                if showsRim {
                    Ellipse().strokeBorder(GameColorToken.tableFeltHighlight.swiftUIColor.opacity(TableFinishToken.edgeOpacity), lineWidth: 1)
                    Ellipse().inset(by: TableFinishToken.rimInset)
                        .stroke(GameColorToken.tableTitleText.swiftUIColor.opacity(TableFinishToken.rimOpacity), lineWidth: TableFinishToken.hairline)
                }
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

struct CompactDealerBadge: View {
    var body: some View {
        Text("D")
            .font(.system(size: CompactDealerBadgeToken.fontSize, weight: .bold))
            .foregroundStyle(GameColorToken.dealerBadgeText.swiftUIColor)
            .frame(width: CompactDealerBadgeToken.diameter, height: CompactDealerBadgeToken.diameter)
            .background(GameColorToken.dealerBadgeBackground.swiftUIColor, in: Circle())
            .accessibilityLabel("Dealer")
    }
}

struct LastTrickRecallButton: View {
    private struct RecallPresentation: Identifiable {
        let id = UUID()
        let trick: CompletedTrick
    }
    let trick: CompletedTrick?
    var blocked = false
    var pause: () -> Void = {}
    var resume: () -> Void = {}
    @State private var recalled: RecallPresentation?

    var body: some View {
        Button {
            guard let trick else { return }
            recalled = RecallPresentation(trick: trick)
            pause()
        } label: {
            Image(systemName: "clock.arrow.circlepath").font(.system(size: 17)).frame(width: 44, height: 36)
                .padding(.vertical, 4).contentShape(Rectangle())
        }
        .disabled(trick == nil || (blocked && recalled == nil))
        .accessibilityLabel("Last trick")
        .accessibilityIdentifier("tarneeb-last-trick")
        .help("Last trick")
        .sheet(item: $recalled, onDismiss: resume) { presentation in
            TrickRecallSheet(trick: presentation.trick) { self.recalled = nil }
        }
    }
}

private struct TrickRecallSheet: View {
    @Environment(\.dynamicTypeSize) private var typeSize
    let trick: CompletedTrick
    let close: () -> Void

    var body: some View {
        Group {
            if typeSize.isAccessibilitySize {
                ScrollView { contents }
            } else {
                contents.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .foregroundStyle(RoomColor.ivory)
        .presentationDetents(typeSize.isAccessibilitySize ? [.large] : [.height(RecallToken.sheetHeight)])
        .presentationDragIndicator(.visible)
        .presentationBackground(RoomColor.forest)
        .preferredColorScheme(.dark)
        .tint(RoomColor.brass)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-trick-recall")
    }

    private var contents: some View {
        VStack(spacing: 24) {
            HStack {
                Text("Last trick").font(.title2.bold()).accessibilityAddTraits(.isHeader)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                Button(action: close) {
                    Image(systemName: "xmark").font(.system(size: 17))
                        .frame(width: RecallToken.closeTarget, height: RecallToken.closeTarget)
                }
                .accessibilityLabel("Close last trick")
                .accessibilityIdentifier("tarneeb-close-last-trick")
            }
            Text("\(trick.winnerSeat == .south ? "You" : (trick.winnerSeat == .north ? "Partner" : trick.winnerSeat.displayLabel)) won the trick")
                .font(.headline).fixedSize(horizontal: false, vertical: true)
            if typeSize.isAccessibilitySize {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 24) {
                    ForEach(trick.playedCards) { recalledCard($0) }
                }
            } else {
                HStack(spacing: RecallToken.cardGap) {
                    ForEach(trick.playedCards) { recalledCard($0) }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
    }

    private func recalledCard(_ play: PlayedCard) -> some View {
        VStack(spacing: 8) {
            Text(play.seat == .south ? "You" : play.seat.displayLabel).font(.caption.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
            ReadableCardFace(card: play.card, roomStyle: true)
                .frame(width: LiveTableToken.cardWidth, height: LiveTableToken.cardHeight)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(
                    RoomColor.brass, lineWidth: play.seat == trick.winnerSeat ? 3 : 0
                ))
            Image(systemName: "checkmark.circle.fill").font(.system(size: 17))
                .opacity(play.seat == trick.winnerSeat ? 1 : 0)
                .foregroundStyle(RoomColor.brass)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(play.seat.displayLabel), \(play.card.rank.displayLabel) of \(play.card.suit.rawValue)\(play.seat == trick.winnerSeat ? ", winner" : "")")
        .accessibilityIdentifier("tarneeb-recalled-\(play.seat.rawValue)")
    }
}

struct ReadableCardFace: View {
    let card: Card
    var subdued = false
    var roomStyle = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 7)
                .fill(roomStyle ? RoomColor.paper : GameColorToken.cardBackground.swiftUIColor)
                .overlay(RoundedRectangle(cornerRadius: 7).stroke(GameColorToken.cardBorder.swiftUIColor, lineWidth: 1))
            VStack(spacing: -3) {
                Text(card.rank.displayLabel).font(.system(size: LiveTableToken.rankSize, weight: .bold, design: .rounded))
                Text(card.suit.displaySymbol).font(.system(size: 17, weight: .semibold))
            }
            .frame(width: 28)
            .padding(.top, 4)
            .padding(.leading, 1)
            Text(card.suit.displaySymbol)
                .font(.system(size: LiveTableToken.suitSize))
                .position(x: 40, y: 57)
            Text(card.rank.displayLabel)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .rotationEffect(.degrees(180))
                .position(x: 53, y: 79)
        }
        .foregroundStyle((roomStyle ? (card.suit == .hearts || card.suit == .diamonds ? RoomColor.burgundy : RoomColor.ink) : card.suit.colorToken.swiftUIColor).opacity(subdued ? LiveTableToken.unavailableOpacity : 1))
        .frame(width: LiveTableToken.cardWidth, height: LiveTableToken.cardHeight)
        .compositingGroup()
        .shadow(color: GameColorToken.cardShadow.swiftUIColor, radius: 2, y: 2)
        .accessibilityElement(children: .ignore)
    }
}

private struct LiveHandButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

/// Receives only an immutable public observation, never authoritative game state.
struct PlayedTrackerModal: View {
    @Environment(\.dynamicTypeSize) private var typeSize
    let presentation: PlayedTrackerPresentation
    let visible: () -> Void
    let close: () -> Void
    @State private var inspectedSuit: Suit?
    @AccessibilityFocusState private var titleFocused: Bool

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width > 24 ? min(proxy.size.width - 24, 440) : 351
            let columns = width >= 360 && typeSize <= .large ? 13 : (typeSize.isAccessibilitySize ? 4 : 7)
            VStack(alignment: .leading, spacing: 12) {
                if typeSize.isAccessibilitySize {
                    HStack(alignment: .top) {
                        trackerTitle
                        Spacer(minLength: 4)
                        closeButton
                    }
                    trackerSummary.fixedSize(horizontal: false, vertical: true)
                } else {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 3) {
                            trackerTitle
                            trackerSummary
                        }
                        Spacer(minLength: 4)
                        closeButton
                    }
                }
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(PlayedTrackerSnapshot.suits, id: \.self) { suit in
                            suitGroup(suit, columns: columns)
                        }
                        Text("✓ Played · Unmarked: not yet played").font(.footnote)
                        Text("Not yet played does not identify who holds it.").font(.footnote)
                    }
                }
                .scrollIndicators(.visible)
                .fixedSize(horizontal: false, vertical: typeSize <= .large)
            }
            .padding(16)
            .foregroundStyle(RoomColor.ivory)
            .background(RoomColor.forest, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(RoomColor.brass, lineWidth: 1))
            .frame(width: width)
            .frame(maxHeight: max(1, proxy.size.height - 24))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-played-tracker")
        .onAppear { titleFocused = true; visible() }
    }

    private var trackerTitle: some View {
        Text("Played cards").font(.title3.bold())
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader).accessibilityFocused($titleFocused)
    }

    private var trackerSummary: some View {
        Text("\(presentation.snapshot.played.count) of 52 played · This hand")
            .font(.subheadline).accessibilityIdentifier("tarneeb-tracker-total")
    }

    private var closeButton: some View {
        Button("Close", action: close)
            .font(.body).frame(minWidth: 60, minHeight: 44)
            .background(RoomColor.felt, in: RoundedRectangle(cornerRadius: 9))
            .accessibilityIdentifier("tarneeb-tracker-close")
    }

    private func suitGroup(_ suit: Suit, columns: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if typeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(suit.displaySymbol)  \(suit.rawValue.capitalized)").font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("\(presentation.snapshot.count(in: suit)) played").font(.subheadline)
                }
            } else {
                HStack {
                    Text("\(suit.displaySymbol)  \(suit.rawValue.capitalized)").font(.headline)
                    Spacer()
                    Text("\(presentation.snapshot.count(in: suit)) played").font(.subheadline)
                }
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: columns), spacing: 3) {
                ForEach(PlayedTrackerSnapshot.ranks, id: \.self) { rank in
                    let played = presentation.snapshot.played.contains(Card(suit: suit, rank: rank))
                    Text(rank.displayLabel)
                        .font(.body.weight(played ? .bold : .regular))
                        .foregroundStyle(played ? RoomColor.forest : RoomColor.ivory)
                        .frame(maxWidth: .infinity, minHeight: 26)
                        .background(played ? RoomColor.brass : Color.clear, in: RoundedRectangle(cornerRadius: 4))
                        .overlay(alignment: .bottomTrailing) {
                            if played { Image(systemName: "checkmark").font(.system(size: 7, weight: .bold)).foregroundStyle(RoomColor.forest).padding(2) }
                        }
                        .accessibilityLabel("\(rank.displayLabel) of \(suit.rawValue), \(played ? "played" : "not yet played")")
                        .accessibilityIdentifier("tarneeb-tracker-rank-\(suit.rawValue)-\(rank.rawValue)")
                        .accessibilityHidden(inspectedSuit != suit)
                }
            }
        }
        .accessibilityElement(children: inspectedSuit == suit ? .contain : .ignore)
        .accessibilityLabel(presentation.snapshot.summary(for: suit))
        .accessibilityIdentifier("tarneeb-tracker-suit-\(suit.rawValue)")
        .accessibilityAction(named: Text(inspectedSuit == suit ? "Use suit summary" : "Inspect ranks")) {
            inspectedSuit = inspectedSuit == suit ? nil : suit
        }
    }
}
