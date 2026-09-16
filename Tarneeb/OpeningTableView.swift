import SwiftUI

private struct OpeningFramePreference: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}

private extension View {
    func openingAnchor(_ name: String) -> some View {
        background(GeometryReader { proxy in
            Color.clear.preference(key: OpeningFramePreference.self, value: [name: proxy.frame(in: .named("opening"))])
        })
    }
}

struct OpeningTableView: View {
    let game: GameState
    let pendingGame: GameState?
    let score: GameScore
    let playback: DealAnimationPlayback?
    let reduceMotion: Bool
    let blocked: Bool
    let canDeal: Bool
    let canReset: Bool
    let choosingTrump: Bool
    @Binding var draftBid: BidValue
    @Binding var draftSuit: Suit?
    let deal: () -> Void
    let newGame: () -> Void
    let submitBid: () -> Void
    let submitTrump: () -> Void
    let selectionFeedback: () -> Void

    @State private var frames: [String: CGRect] = [:]
    @AppStorage("tarneeb.soundEnabled") private var soundEnabled = true
    @AppStorage("tarneeb.hapticsEnabled") private var hapticsEnabled = true

    private var hand: [Card] {
        SouthHandPresentation.cardPresentations(
            from: (pendingGame ?? game).players.first { $0.seat == .south }?.hand ?? [],
            sizeConfiguration: .sharedBase
        ).map(\.card)
    }
    private var ink: Color { GameColorToken.textPrimary.swiftUIColor }
    private var accent: Color { GameColorToken.stationOutlineActive.swiftUIColor }
    private var isDealing: Bool { playback != nil }
    private var waitingForSouth: Bool { game.biddingState?.isWaitingForSouth == true && !blocked }

    var body: some View {
        GeometryReader { proxy in
            let width = min(proxy.size.width - 24, 560)
            VStack(spacing: 4) {
                header
                HStack {
                    Text(phaseSummary)
                        .accessibilityIdentifier("tarneeb-opening-status")
                    Spacer(minLength: 0)
                    if game.dealerSeat == .south, game.phase == .dealt || playback?.southRevealState.usesExpandedStation == true {
                        HStack(spacing: 4) {
                            Text("You")
                            CompactDealerBadge()
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("You, dealer")
                        .accessibilityIdentifier("tarneeb-opening-south-dealer")
                    }
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(GameColorToken.textSecondary.swiftUIColor)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(height: 24)
                table.frame(minHeight: OpeningTableToken.minimumTableHeight)
                southHand(width: width)
                actions.frame(height: OpeningTableToken.actionHeight, alignment: .top)
            }
            .frame(width: width, height: proxy.size.height - 8)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity)
            .coordinateSpace(name: "opening")
            .onPreferenceChange(OpeningFramePreference.self) { frames = $0 }
            .overlay(alignment: .topLeading) { packetFlight }
        }
        .foregroundStyle(ink)
        .background(GameColorToken.tableBackgroundPrimary.swiftUIColor)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-opening-table")
    }

    private var header: some View {
        HStack(spacing: 12) {
            MatchScoreHeading(score: score)
            Spacer(minLength: 0)
            Menu {
                Toggle("Sound effects", isOn: $soundEnabled)
                Toggle("Haptics", isOn: $hapticsEnabled)
                Divider()
                Button("New Game", systemImage: "arrow.counterclockwise", action: newGame)
                    .disabled(!canReset || isDealing)
            } label: {
                Image(systemName: "ellipsis").frame(width: 44, height: 36)
            }
            .accessibilityLabel("Game options")
            .accessibilityIdentifier("tarneeb-game-options")
        }
        .font(.system(.headline, design: .rounded).weight(.bold))
        .frame(height: 36)
    }

    private var phaseSummary: String {
        if let playback {
            if playback.deliveredSeats.count == 4 { return "Your hand" }
            return "Dealing to \(playback.activeTargetSeat?.displayLabel ?? "")"
        }
        if game.phase == .notStarted { return "\(game.dealerSeat.displayLabel) deals" }
        if choosingTrump { return "You won the bid: \(game.highestBidValue?.displayLabel ?? "")" }
        if game.biddingCompletionOutcome == .allPassRedeal { return "All passed. Dealing again" }
        if let seat = game.highestBidSeat, let bid = game.highestBidValue {
            let stage = game.biddingStatus == .inProgress ? "Talab · " : ""
            return "\(stage)\(seat.displayLabel) leads with \(bid.displayLabel)"
        }
        return "Talab · Bidding"
    }

    private var table: some View {
        GeometryReader { proxy in
            let geometry = LiveTrickGeometry(size: proxy.size)
            let felt = CircularTableGeometry(size: proxy.size)
            let feltCenter = felt.center
            ZStack {
                TableFeltSurface()
                    .frame(width: felt.diameter, height: felt.diameter)
                    .position(feltCenter)
                let title = TableTitlePresentation()
                Text(title.text)
                    .font(.custom(title.fontName, size: title.fontPointSize))
                    .foregroundStyle(GameColorToken.tableTitleText.swiftUIColor.opacity(0.92))
                    .position(feltCenter)
                    .accessibilityIdentifier("tarneeb-table-title")
                ForEach([Seat.north, .west, .east], id: \.self) { seat in
                    station(seat)
                        .openingAnchor(seat.rawValue)
                        .position(geometry.station(seat))
                }
                Color.clear.frame(width: LiveTableToken.cardWidth, height: LiveTableToken.cardHeight)
                    .openingAnchor("deck")
                    .position(feltCenter)
                    .accessibilityHidden(true)
                let count = playback?.centralCardCount ?? (game.phase == .notStarted ? 52 : 0)
                if count > 0 {
                    OpeningCardPacket()
                        .position(feltCenter)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Undealt deck")
                        .accessibilityValue("\(count) cards")
                        .accessibilityIdentifier("tarneeb-opening-deck")
                }
            }
        }
    }

    private func station(_ seat: Seat) -> some View {
        let delivered = playback?.deliveredSeats.contains(seat) ?? (game.phase == .dealt)
        let active = !isDealing && game.currentBiddingSeat == seat
        let bid = game.bids[seat]?.resolvedValue
        return HStack(spacing: 5) {
            if delivered {
                Image("card_back").resizable().scaledToFit().frame(width: 18, height: 26)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
                    .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
                    .accessibilityHidden(true)
            }
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 3) {
                    Text(seat == .south ? "You" : seat.displayLabel).font(.caption.weight(.bold))
                    if seat == game.dealerSeat {
                        CompactDealerBadge()
                    }
                }
                Text(bid?.displayLabel ?? (active ? "Bidding" : (delivered ? "13 cards" : "")))
                    .font(.caption2).monospacedDigit()
                    .foregroundStyle(active ? accent : GameColorToken.textSecondary.swiftUIColor)
            }
        }
        .foregroundStyle(active ? accent : ink)
        .frame(width: OpeningTableToken.stationWidth, height: OpeningTableToken.stationHeight)
        .lineLimit(1).minimumScaleFactor(0.75)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(seat.displayLabel)\(seat == game.dealerSeat ? ", dealer" : "")")
        .accessibilityValue(bid?.displayLabel ?? (active ? "Bidding" : (delivered ? "13 cards" : "No cards")))
        .accessibilityIdentifier("tarneeb-opening-station-\(seat.rawValue)")
    }

    private func southHand(width: Double) -> some View {
        let layout = LiveHandLayout(width: width)
        let showCards = playback?.southRevealState.usesExpandedStation ?? (game.phase == .dealt)
        return ZStack(alignment: .topLeading) {
            if showCards {
                ForEach(Array(hand.enumerated()), id: \.element.id) { index, card in
                    let revealed = playback == nil || index < (playback?.southRevealedCardCount ?? 0)
                    OpeningFlipCard(card: card, angle: revealed ? 180 : 0, reduceMotion: reduceMotion)
                        .position(layout.center(at: index, cardCount: hand.count))
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(revealed ? "\(card.rank.displayLabel) of \(card.suit.rawValue)" : "Face-down card")
                        .accessibilityIdentifier("tarneeb-opening-card-\(card.id)")
                }
            } else {
                ZStack {
                    station(.south)
                        .position(x: width / 2, y: layout.height / 2 - LiveTableToken.cardHeight / 2 - OpeningTableToken.stationHeight / 2 - 6)
                    if playback?.deliveredSeats.contains(.south) == true {
                        OpeningCardPacket().position(x: width / 2, y: layout.height / 2)
                    }
                }
                .frame(width: width, height: layout.height)
            }
        }
        .frame(width: width, height: layout.height)
        .openingAnchor(Seat.south.rawValue)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-opening-hand")
    }

    private var actions: some View {
        VStack(alignment: .leading, spacing: 12) {
            if game.phase == .notStarted {
                Spacer(minLength: 0)
                Button(isDealing ? "Dealing" : "Deal", action: deal)
                    .buttonStyle(TableCommandStyle(emblem: "rectangle.stack.fill", reduceMotion: reduceMotion))
                    .disabled(!canDeal || isDealing || blocked)
                    .accessibilityIdentifier("tarneeb-deal-button")
            } else if choosingTrump {
                Text("Tarneeb").font(.headline)
                    .accessibilityIdentifier("tarneeb-suit-heading")
                HStack(spacing: 8) {
                    ForEach(Suit.allCases, id: \.self) { suit in
                        Button {
                            draftSuit = suit
                            selectionFeedback()
                        } label: {
                            Text(suit.displaySymbol).font(.system(size: 26, weight: .bold))
                                .foregroundStyle(suit.colorToken.swiftUIColor)
                                .frame(maxWidth: .infinity, minHeight: OpeningTableToken.controlHeight)
                                .background(GameColorToken.cardBackground.swiftUIColor, in: RoundedRectangle(cornerRadius: 6))
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(draftSuit == suit ? accent : GameColorToken.cardBorder.swiftUIColor, lineWidth: draftSuit == suit ? 3 : 1))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(suit.rawValue.capitalized)
                        .accessibilityValue(draftSuit == suit ? "Selected" : "")
                        .accessibilityIdentifier("tarneeb-bid-suit-option-\(suit.rawValue)")
                    }
                    Button("Set", action: submitTrump)
                        .buttonStyle(TableCommandStyle(reduceMotion: reduceMotion))
                        .frame(width: 64)
                        .disabled(draftSuit == nil)
                        .accessibilityIdentifier("tarneeb-post-bidding-suit-button-south")
                }
                .disabled(blocked)
            } else if waitingForSouth {
                Text("Your bid").font(.headline)
                HStack(spacing: 12) {
                    Menu {
                        Picker("Your bid", selection: $draftBid) {
                            ForEach(game.biddingState?.southLegalValues ?? [], id: \.self) { bid in
                                Text(bid.displayLabel).tag(bid)
                            }
                        }
                        .pickerStyle(.inline)
                    } label: {
                        HStack(spacing: 8) {
                            Text(draftBid.displayLabel)
                                .monospacedDigit()
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption.weight(.semibold))
                                .accessibilityHidden(true)
                        }
                        .frame(maxWidth: .infinity, minHeight: OpeningTableToken.controlHeight)
                    }
                    .buttonStyle(.plain)
                    .menuIndicator(.hidden)
                    .tint(ink)
                    .frame(maxWidth: .infinity, minHeight: OpeningTableToken.controlHeight)
                    .background(GameColorToken.tableBackgroundSecondary.swiftUIColor, in: RoundedRectangle(cornerRadius: 6))
                    .accessibilityIdentifier("tarneeb-opening-bid-picker")
                    .accessibilityLabel("Your bid")
                    .accessibilityValue(draftBid.displayLabel)
                    Button(draftBid == .pass ? "Pass" : "Bid \(draftBid.displayLabel)", action: submitBid)
                        .buttonStyle(TableCommandStyle(reduceMotion: reduceMotion))
                        .frame(width: 116)
                        .accessibilityIdentifier("tarneeb-bid-button-south")
                }
            } else {
                Text(game.currentBiddingSeat.map { "\($0.displayLabel) is bidding" } ?? "Preparing the table")
                    .font(.headline)
                if let bid = game.bids[.south]?.resolvedValue {
                    Text("Your bid: \(bid.displayLabel)").font(.subheadline)
                        .foregroundStyle(GameColorToken.textSecondary.swiftUIColor)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tarneeb-opening-actions")
    }

    @ViewBuilder
    private var packetFlight: some View {
        if let playback, playback.isMovingStackVisible, let seat = playback.activeTargetSeat,
           let source = frames["deck"], let target = frames[seat.rawValue] {
            OpeningCardPacket()
                .id(playback.activeStepIndex)
                .position(
                    x: playback.movingStackAtTarget && !reduceMotion ? target.midX : source.midX,
                    y: playback.movingStackAtTarget && !reduceMotion ? target.midY : source.midY
                )
                .opacity(reduceMotion && playback.movingStackAtTarget ? 0 : 1)
                .allowsHitTesting(false)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Dealing 13 cards to \(seat.displayLabel)")
                .accessibilityIdentifier("tarneeb-opening-packet")
        }
    }
}

private struct OpeningCardPacket: View {
    var body: some View {
        ZStack {
            ForEach(0..<4) { index in
                OpeningCardBack().offset(x: Double(index) * OpeningTableToken.packetLayerOffset, y: -Double(index) * OpeningTableToken.packetLayerOffset)
            }
        }
        .frame(width: LiveTableToken.cardWidth, height: LiveTableToken.cardHeight)
    }
}

private struct OpeningCardBack: View {
    var body: some View {
        Image("card_back").resizable().scaledToFit()
            .frame(width: LiveTableToken.cardWidth, height: LiveTableToken.cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .background(GameColorToken.cardBackground.swiftUIColor, in: RoundedRectangle(cornerRadius: 7))
            .shadow(color: GameColorToken.cardShadow.swiftUIColor, radius: 2, y: 2)
    }
}

private struct OpeningFlipCard: View, Animatable {
    let card: Card
    var angle: Double
    let reduceMotion: Bool
    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }

    var body: some View {
        ZStack {
            if reduceMotion {
                OpeningCardBack().opacity(1 - angle / 180)
                ReadableCardFace(card: card).opacity(angle / 180)
            } else if angle < 90 {
                OpeningCardBack()
            } else {
                ReadableCardFace(card: card).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
        }
        .rotation3DEffect(.degrees(reduceMotion ? 0 : angle), axis: (x: 0, y: 1, z: 0), perspective: OpeningTableToken.flipPerspective)
    }
}

struct TableCommandStyle: ButtonStyle {
    @Environment(\.isEnabled) private var enabled
    var emblem: String? = nil
    var height: Double = OpeningTableToken.controlHeight
    let reduceMotion: Bool

    func makeBody(configuration: Configuration) -> some View {
        let pressed = enabled && configuration.isPressed
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: TableCommandToken.cornerRadius)
                .fill(GameColorToken.buttonDealBackgroundPressed.swiftUIColor)
            HStack(spacing: 8) {
                if let emblem {
                    Image(systemName: emblem)
                        .font(.system(size: TableCommandToken.iconSize, weight: .semibold))
                        .foregroundStyle(GameColorToken.stationOutlineActive.swiftUIColor)
                        .frame(width: TableCommandToken.iconSize)
                        .accessibilityHidden(true)
                    Spacer(minLength: 0)
                }
                configuration.label
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                if emblem != nil {
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .frame(width: TableCommandToken.iconSize)
                        .accessibilityHidden(true)
                }
            }
            .foregroundStyle(GameColorToken.buttonDealText.swiftUIColor)
            .padding(.horizontal, TableCommandToken.horizontalPadding)
            .frame(maxWidth: .infinity)
            .frame(height: height - TableCommandToken.depth)
            .background(pressed ? GameColorToken.buttonDealBackgroundPressed.swiftUIColor : GameColorToken.buttonDealBackground.swiftUIColor,
                        in: RoundedRectangle(cornerRadius: TableCommandToken.cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: TableCommandToken.cornerRadius - TableCommandToken.rimInset)
                    .strokeBorder(GameColorToken.buttonDealText.swiftUIColor.opacity(TableCommandToken.rimOpacity), lineWidth: 1)
                    .padding(TableCommandToken.rimInset)
                    .allowsHitTesting(false)
            }
            .offset(y: pressed && !reduceMotion ? TableCommandToken.depth : 0)
        }
        .frame(height: height)
        .contentShape(Rectangle())
        .shadow(color: GameColorToken.cardShadow.swiftUIColor, radius: pressed ? 0 : 2, y: pressed ? 0 : 2)
        .opacity(enabled ? 1 : TableCommandToken.disabledOpacity)
        .animation(reduceMotion ? nil : .spring(duration: TableCommandToken.pressDuration, bounce: 0.2), value: pressed)
    }
}
