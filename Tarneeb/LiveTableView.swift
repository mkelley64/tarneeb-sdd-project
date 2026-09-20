import SwiftUI

private struct HandCardDrag {
    let card: Card
    let translation: CGSize
}

private struct CardFramePreference: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, next in next })
    }
}

private extension View {
    func liveAnchor(_ key: String) -> some View {
        background(GeometryReader { proxy in
            Color.clear.preference(key: CardFramePreference.self, value: [key: proxy.frame(in: .named("liveTable"))])
        })
    }
}

struct LiveTableView: View {
    let game: GameState
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
    private var canSelect: Bool { !blocked && game.currentTrickTurnSeat == .south && !game.isCurrentTrickComplete }
    private var ink: Color { GameColorToken.textPrimary.swiftUIColor }
    private var accent: Color { GameColorToken.stationOutlineActive.swiftUIColor }

    var body: some View {
        GeometryReader { proxy in
            let contentWidth = min(proxy.size.width - 24, 560)
            VStack(spacing: 4) {
                header
                contract
                table
                    .frame(minHeight: LiveTableToken.minimumTableHeight)
                handView(width: contentWidth)
                actionBar
            }
            .frame(width: contentWidth, height: proxy.size.height - 8)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity)
            .coordinateSpace(name: "liveTable")
            .onPreferenceChange(CardFramePreference.self) { frames = $0 }
            .overlay(alignment: .topLeading) {
                draggingCard
                flyingCard
            }
        }
        .background(GameColorToken.tableBackgroundPrimary.swiftUIColor)
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
        .onChange(of: game) { _, _ in
            if let selectedCard, !TrickPlayRules.isLegal(card: selectedCard, for: .south, in: game) {
                selectedID = nil
            } else if selectedCard == nil {
                selectedID = nil
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            MatchScoreHeading(score: score)
            Spacer(minLength: 0)
            LastTrickRecallButton(trick: game.trickPlayState?.completedTricks.last, blocked: blocked, pause: pause, resume: resume)
            Menu {
                AISkillOptions()
                Toggle("Sound effects", isOn: $soundEnabled)
                Toggle("Haptics", isOn: $hapticsEnabled)
                Divider()
                Button("New Game", systemImage: "arrow.counterclockwise") {
                    pause()
                    showsNewGameConfirmation = true
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.title3.weight(.semibold))
                    .frame(width: 44, height: 36)
            }
            .accessibilityLabel("Game options")
            .accessibilityIdentifier("tarneeb-game-options")
        }
        .foregroundStyle(ink)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .frame(height: 36)
    }

    private var contract: some View {
        VStack(spacing: 2) {
            if let summary = game.postBiddingSummary,
               let progress = ContractProgressPresentation(summary: summary, trick: game.trickPlayState) {
                HStack {
                    Text("\(summary.highBidderSeat == .south ? "You bid" : summary.highBidderSeat.displayLabel + " bids") \(summary.bidValue.displayLabel)")
                        .accessibilityIdentifier("tarneeb-live-contract-bid")
                    Text(summary.tarneebSuit.displaySymbol)
                        .foregroundStyle(accent)
                        .accessibilityLabel("Tarneeb \(summary.tarneebSuit.rawValue)")
                    Spacer()
                    if progress.milestone == .secured {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(accent)
                            .transition(reduceMotion ? .identity : .scale.combined(with: .opacity))
                            .accessibilityHidden(true)
                    }
                    Text(progress.visibleLabel)
                        .monospacedDigit()
                        .foregroundStyle(progress.milestone == .oneAway || progress.milestone == .secured ? accent : GameColorToken.textSecondary.swiftUIColor)
                        .accessibilityLabel(progress.label)
                        .accessibilityValue(progress.accessibilityValue)
                        .accessibilityIdentifier("tarneeb-contract-progress")
                }
                .animation(reduceMotion ? nil : .easeOut(duration: ContractProgressToken.duration), value: progress.milestone)
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule().fill(GameColorToken.textSecondary.swiftUIColor.opacity(TableFinishToken.dividerOpacity))
                        Capsule().fill(accent)
                            .frame(width: proxy.size.width * progress.fraction)
                    }
                    .animation(reduceMotion ? nil : .easeOut(duration: ContractProgressToken.duration), value: progress.fraction)
                }
                .frame(height: ContractProgressToken.barHeight)
                .accessibilityHidden(true)
            }
        }
        .font(.subheadline.weight(.medium))
        .foregroundStyle(GameColorToken.textSecondary.swiftUIColor)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .frame(height: 24)
    }

    private var table: some View {
        GeometryReader { proxy in
            let geometry = LiveTrickGeometry(size: proxy.size)
            let felt = CircularTableGeometry(size: proxy.size)
            ZStack(alignment: .topLeading) {
                TableFeltSurface()
                    .frame(width: felt.diameter, height: felt.diameter)
                    .position(felt.center)
                Text(TableTitlePresentation().text)
                    .font(.custom(TableTitlePresentation().fontName, size: TableTitlePresentation().fontPointSize))
                    .foregroundStyle(GameColorToken.tableTitleText.swiftUIColor.opacity(0.32))
                    .position(x: proxy.size.width / 2, y: geometry.slot(.west).y)
                    .accessibilityHidden(true)

                ForEach([Seat.north, .west, .east], id: \.self) { seat in
                    station(seat)
                        .liveAnchor("station-\(seat.rawValue)")
                        .position(geometry.station(seat))
                }

                ForEach(Seat.allCases, id: \.self) { seat in
                    Color.clear
                        .frame(width: LiveTableToken.cardWidth, height: LiveTableToken.cardHeight)
                        .liveAnchor("slot-\(seat.rawValue)")
                        .position(geometry.slot(seat))
                        .accessibilityHidden(true)
                    if let played = game.trickPlayState?.playedCard(for: seat) {
                        ReadableCardFace(card: played.card)
                            .overlay {
                                if winner == seat {
                                    RoundedRectangle(cornerRadius: 7).stroke(accent, lineWidth: 3)
                                }
                            }
                            .scaleEffect(collecting && !reduceMotion ? LiveTableToken.collectionScale : 1)
                            .opacity(collecting && reduceMotion ? 0 : 1)
                            .position(collecting && !reduceMotion ? geometry.station(winner ?? seat) : geometry.slot(seat))
                            .zIndex(collecting ? 5 : 1)
                            .accessibilityLabel("\(seat.displayLabel), \(played.card.rank.displayLabel) of \(played.card.suit.rawValue)\(winner == seat ? ", winning card" : "")")
                            .accessibilityIdentifier("tarneeb-live-played-\(seat.rawValue)")
                    }
                }
            }
            .contentShape(Rectangle())
        }
        .liveAnchor("drop-table")
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-live-trick")
    }

    private func station(_ seat: Seat) -> some View {
        let active = game.currentTrickTurnSeat == seat && winner == nil
        let count = game.trickPlayState?.completedTricks.filter { $0.winnerSeat == seat }.count ?? 0
        return HStack(spacing: 5) {
            Image("card_back")
                .resizable().scaledToFit().frame(width: 18, height: 26)
                .clipShape(RoundedRectangle(cornerRadius: 2))
                .opacity(game.players.first { $0.seat == seat }?.hand.isEmpty == true ? 0 : 1)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 3) {
                    Text(seat.displayLabel).font(.caption.weight(.bold))
                    if game.dealerSeat == seat { CompactDealerBadge() }
                }
                Text("\(count) tricks").font(.caption2).monospacedDigit()
                    .foregroundStyle(active || winner == seat ? accent : GameColorToken.textSecondary.swiftUIColor)
            }
            .foregroundStyle(active || winner == seat ? accent : ink)
        }
        .frame(width: 92, height: 34)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .overlay(alignment: .bottom) {
            Capsule().fill(active ? accent : Color.clear).frame(width: 30, height: 2)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(seat.displayLabel), \(count) tricks\(game.dealerSeat == seat ? ", dealer" : "")\(active ? ", playing" : "")")
        .accessibilityIdentifier("tarneeb-live-station-\(seat.rawValue)")
    }

    private func handView(width: Double) -> some View {
        let layout = LiveHandLayout(width: width)
        return ZStack(alignment: .topLeading) {
            ForEach(Array(hand.enumerated()), id: \.element.id) { index, card in
                let legal = TrickPlayRules.isLegal(card: card, for: .south, in: game)
                let selected = selectedID == card.id
                Button {
                    select(card)
                } label: {
                    ReadableCardFace(card: card, subdued: canSelect && !legal)
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
                .position(layout.center(at: index, cardCount: hand.count))
                .zIndex(Double(index))
                .accessibilityLabel("\(card.rank.displayLabel) of \(card.suit.rawValue)")
                .accessibilityValue(selected ? "Selected" : (legal ? "Playable" : "Unavailable"))
                .accessibilityHint(legal ? "Select card. Use the Play action to play it." : "")
                .accessibilityIdentifier("tarneeb-live-card-\(card.id)")
                .accessibilityAction(named: "Play") {
                    guard canSelect, legal else { return }
                    play(card)
                }
            }
        }
        .frame(width: width, height: layout.height)
        .liveAnchor("station-south")
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-live-hand")
    }

    private func cardGesture(_ card: Card) -> some Gesture {
        DragGesture(coordinateSpace: .named("liveTable"))
            .updating($handDrag) { value, drag, _ in
                guard canSelect, TrickPlayRules.isLegal(card: card, for: .south, in: game) else { return }
                drag = HandCardDrag(card: card, translation: value.translation)
            }
            .onEnded { value in
                guard canSelect, TrickPlayRules.isLegal(card: card, for: .south, in: game),
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
                        guard canSelect, TrickPlayRules.isLegal(card: card, for: .south, in: game) else { return }
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
            ReadableCardFace(card: drag.card)
                .position(x: source.midX + drag.translation.width, y: source.midY + drag.translation.height)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
    }

    private func select(_ card: Card) {
        guard canSelect, TrickPlayRules.isLegal(card: card, for: .south, in: game) else { return }
        withAnimation(reduceMotion ? nil : .snappy(duration: 0.18)) {
            selectedID = selectedID == card.id ? nil : card.id
        }
        selectFeedback()
    }

    private var actionBar: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(status).font(.subheadline.weight(.semibold))
                    .accessibilityIdentifier("tarneeb-live-status")
                if let ledSuit = game.trickPlayState?.ledSuit, winner == nil {
                    Text("Led \(ledSuit.displaySymbol)").font(.caption).foregroundStyle(GameColorToken.textSecondary.swiftUIColor)
                }
            }
            .lineLimit(2)
            .minimumScaleFactor(0.8)
            Spacer(minLength: 0)
            let count = game.trickPlayState?.completedTricks.filter { $0.winnerSeat == .south }.count ?? 0
            Text("Your tricks: \(count)")
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
                .fixedSize()
                .accessibilityLabel("Your tricks")
                .accessibilityValue("\(count)")
                .accessibilityIdentifier("tarneeb-live-south-tricks")
            if game.dealerSeat == .south {
                CompactDealerBadge()
                    .accessibilityLabel("You, dealer")
                    .accessibilityIdentifier("tarneeb-live-dealer-south")
            }
        }
        .foregroundStyle(ink)
        .frame(height: 48)
    }

    private var status: String {
        if game.phase == .handComplete { return roundResult }
        if let winner { return "\(winner == .south ? "You take" : winner.displayLabel + " takes") the trick" }
        if let flight { return flight.play.seat == .south ? "You play" : "\(flight.play.seat.displayLabel) plays" }
        if let selectedCard, canSelect { return "\(selectedCard.rank.displayLabel)\(selectedCard.suit.displaySymbol) selected" }
        if game.currentTrickTurnSeat == .south { return "Your turn" }
        return "\(game.currentTrickTurnSeat?.displayLabel ?? "") is playing"
    }

    @ViewBuilder
    private var flyingCard: some View {
        if let flight {
            let sourceKey = flight.play.seat == .south ? flight.play.card.id : "station-\(flight.play.seat.rawValue)"
            if let source = releasedCardOrigins[sourceKey] ?? frames[sourceKey], let target = frames["slot-\(flight.play.seat.rawValue)"] {
                ReadableCardFace(card: flight.play.card)
                    .id(flight.play.id)
                    .shadow(color: GameColorToken.cardShadow.swiftUIColor, radius: flight.arrived ? 2 : 10, y: flight.arrived ? 1 : 8)
                    .opacity(reduceMotion && !flight.arrived ? 0 : 1)
                    .position(
                        x: flight.arrived || reduceMotion ? target.midX : source.midX,
                        y: flight.arrived || reduceMotion ? target.midY : source.midY
                    )
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                    .accessibilityIdentifier("tarneeb-live-flight")
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
            Image(systemName: "clock.arrow.circlepath").frame(width: 44, height: 36)
        }
        .disabled(trick == nil || (blocked && recalled == nil))
        .accessibilityLabel("Last trick")
        .accessibilityIdentifier("tarneeb-last-trick")
        .help("Last trick")
        .sheet(item: $recalled, onDismiss: resume) { presentation in
            let recalled = presentation.trick
                VStack(spacing: 24) {
                    HStack {
                        Text("Last trick").font(.title2.bold()).accessibilityAddTraits(.isHeader)
                        Spacer()
                        Button { self.recalled = nil } label: {
                            Image(systemName: "xmark").frame(width: RecallToken.closeTarget, height: RecallToken.closeTarget)
                        }
                        .accessibilityLabel("Close last trick")
                        .accessibilityIdentifier("tarneeb-close-last-trick")
                    }
                    Text("\(recalled.winnerSeat == .south ? "You" : recalled.winnerSeat.displayLabel) won the trick")
                        .font(.headline)
                    HStack(spacing: RecallToken.cardGap) {
                        ForEach(recalled.playedCards) { play in
                            VStack(spacing: 8) {
                                Text(play.seat == .south ? "You" : play.seat.displayLabel).font(.caption.weight(.semibold))
                                ReadableCardFace(card: play.card)
                                    .frame(width: LiveTableToken.cardWidth, height: LiveTableToken.cardHeight)
                                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(
                                        GameColorToken.stationOutlineActive.swiftUIColor,
                                        lineWidth: play.seat == recalled.winnerSeat ? 3 : 0
                                    ))
                                Image(systemName: "crown.fill")
                                    .opacity(play.seat == recalled.winnerSeat ? 1 : 0)
                                    .foregroundStyle(GameColorToken.stationOutlineActive.swiftUIColor)
                            }
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("\(play.seat.displayLabel), \(play.card.rank.displayLabel) of \(play.card.suit.rawValue)\(play.seat == recalled.winnerSeat ? ", winner" : "")")
                            .accessibilityIdentifier("tarneeb-recalled-\(play.seat.rawValue)")
                        }
                    }
                    Spacer(minLength: 0)
                }
                .padding(20)
                .foregroundStyle(GameColorToken.textPrimary.swiftUIColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .presentationDetents([.height(RecallToken.sheetHeight)])
                .presentationDragIndicator(.visible)
                .presentationBackground(GameColorToken.tableBackgroundPrimary.swiftUIColor)
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("tarneeb-trick-recall")
        }
    }
}

struct ReadableCardFace: View {
    let card: Card
    var subdued = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 7)
                .fill(GameColorToken.cardBackground.swiftUIColor)
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
        .foregroundStyle(card.suit.colorToken.swiftUIColor.opacity(subdued ? LiveTableToken.unavailableOpacity : 1))
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
