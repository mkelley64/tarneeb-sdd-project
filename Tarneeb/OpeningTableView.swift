import SwiftUI

/// Optional presentation only: a cancelled or consumed arrival can never replay on resume.
struct OpeningArrival {
    private(set) var consumed = false
    private(set) var generation: UUID?

    mutating func begin(eligible: Bool, ready: Bool, active: Bool, blocked: Bool, reduceMotion: Bool) -> UUID? {
        guard !consumed, eligible, ready, active, !blocked else { return nil }
        consumed = true
        guard !reduceMotion else { return nil }
        let id = UUID()
        generation = id
        return id
    }

    mutating func cancel() { consumed = true; generation = nil }
    mutating func finish(_ id: UUID) { if generation == id { generation = nil } }

    func permitsFeedback(_ id: UUID, ready: Bool, active: Bool, blocked: Bool, reduceMotion: Bool) -> Bool {
        generation == id && ready && active && !blocked && !reduceMotion
    }
}

struct AISkillOptions: View {
    @AppStorage(AISkill.preferenceKey) private var preference = AISkill.standard.rawValue

    var body: some View {
        Menu("AI skill") {
            Picker("AI skill", selection: $preference) {
                ForEach(AISkill.allCases, id: \.rawValue) { skill in
                    Text(skill.title).tag(skill.rawValue)
                }
            }
            Text("All AI players, including North.")
                .font(.caption)
            Text("Applies to the next new game.")
                .font(.caption)
        }
        .accessibilityIdentifier("tarneeb-ai-skill")
    }
}

private struct OpeningFramePreference: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}

extension View {
    @ViewBuilder func openingArrivalDebugState(_ value: String) -> some View {
        #if DEBUG
        self.accessibilityValue(value)
        #else
        self
        #endif
    }
    func openingAnchor(_ name: String) -> some View {
        background(GeometryReader { proxy in
            Color.clear.preference(key: OpeningFramePreference.self, value: [name: proxy.frame(in: .named("opening"))])
        })
    }
}

struct OpeningTableView: View {
    @Environment(\.scenePhase) private var scenePhase
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
    var allowsArrival = true
    var openingFeedback: () -> Void = {}
    var packetLanded: (UUID, Int) -> Void = { _, _ in }
    var continuity: Namespace.ID? = nil
    var publicationAudit = ""
    @State private var frames: [String: CGRect] = [:]
    @State private var arrival = OpeningArrival()
    @State private var arrivalTask: Task<Void, Never>?
    @State private var openingCueCount = 0
    @State private var fan = 0.0
    @State private var warmth = 0.0
    @AppStorage("tarneeb.soundEnabled") private var soundEnabled = true
    @AppStorage("tarneeb.hapticsEnabled") private var hapticsEnabled = true
    private var hand: [Card] {
        SouthHandPresentation.sortedCards(from: (pendingGame ?? game).players.first { $0.seat == .south }?.hand ?? [])
    }
    @State private var dealDeckOrigin: CGPoint?

    private var isDealing: Bool { playback != nil }
    private var waitingForSouth: Bool { game.biddingState?.isWaitingForSouth == true && !blocked && !isDealing }
    private var ready: Bool { game.phase == .notStarted && !isDealing }
    private var legalNumbers: [BidValue] { (game.biddingState?.southLegalValues ?? []).filter { $0 != .pass } }

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width - 24
            // Match the table reservation without moving the approved South hand.
            let compact = proxy.size.height - 16 - 50 - 62 - LiveHandLayout(width: width).height - 48 - 32 < 290
            VStack(spacing: 8) {
                header
                if ready {
                    VStack(spacing: 0) {
                        Text("طرنيب").font(.custom("GeezaPro", fixedSize: min(84, proxy.size.height * 0.13)))
                            .accessibilityIdentifier("tarneeb-table-title")
                        Text("T A R N E E B   R O Y A L E").font(.system(size: 11, weight: .medium)).foregroundStyle(RoomColor.brass)
                    }
                    .frame(height: max(90, min(170, proxy.size.height * 0.24)))
                } else {
                    phaseBanner(compact: compact).frame(height: 62)
                }
                table(compact: compact)
                if !ready { southHand(width: width) }
                if ready {
                    VStack(spacing: 5) {
                        Text("The table is yours.").font(.system(size: 23, weight: .medium))
                        Text("\(game.dealerSeat == .south ? "You" : game.dealerSeat.displayLabel) deal\(game.dealerSeat == .south ? "" : "s") · First to 31")
                            .font(.system(size: 12)).foregroundStyle(RoomColor.muted)
                    }.frame(height: 58)
                }
                actions.frame(height: 48)
            }
            .frame(width: width, height: proxy.size.height - 16)
            .padding(.vertical, 8).frame(maxWidth: .infinity)
            .coordinateSpace(name: "opening")
            .onPreferenceChange(OpeningFramePreference.self) { frames = $0 }
            .overlay(alignment: .topLeading) { dealerDeck }
            .overlay(alignment: .topLeading) { packetFlight }
        }
        .foregroundStyle(RoomColor.ivory)
        .accessibilityElement(children: .contain).accessibilityIdentifier("tarneeb-opening-table")
        .openingArrivalDebugState("arrival=\(arrival.generation == nil ? "settled" : "active");cue=\(openingCueCount)\(publicationAudit.isEmpty ? "" : ";" + publicationAudit)")
        .onAppear { beginArrival() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { beginArrival() } else { cancelArrival() }
        }
        .onChange(of: isDealing) { _, dealing in if dealing { cancelArrival() } }
        .onChange(of: playback?.generation) { _, generation in
            if generation == nil { dealDeckOrigin = nil }
        }
        .onChange(of: blocked) { _, value in if value { cancelArrival() } }
        .onChange(of: reduceMotion) { _, value in if value { cancelArrival() } }
        .onDisappear { cancelArrival() }
    }

    private func beginArrival() {
        guard let id = arrival.begin(eligible: allowsArrival, ready: ready,
                                     active: scenePhase == .active, blocked: blocked, reduceMotion: reduceMotion) else { return }
        arrivalTask = Task { @MainActor in
            withAnimation(.easeInOut(duration: 0.46)) { fan = 1; warmth = 1 }
            do { try await Task.sleep(for: .seconds(0.46)) } catch { return }
            guard !Task.isCancelled, arrival.permitsFeedback(id, ready: ready, active: scenePhase == .active,
                                                             blocked: blocked, reduceMotion: reduceMotion) else { return }
            withAnimation(.easeInOut(duration: 0.49)) { fan = 0 }
            do { try await Task.sleep(for: .seconds(0.49)) } catch { return }
            guard !Task.isCancelled, arrival.permitsFeedback(id, ready: ready, active: scenePhase == .active,
                                                             blocked: blocked, reduceMotion: reduceMotion) else { return }
            openingFeedback()
            #if DEBUG
            openingCueCount += 1
            #endif
            arrival.finish(id)
            withAnimation(.easeOut(duration: 0.15)) { warmth = 0 }
            arrivalTask = nil
        }
    }

    private func cancelArrival() {
        arrival.cancel()
        arrivalTask?.cancel(); arrivalTask = nil
        var transaction = Transaction(); transaction.disablesAnimations = true
        withTransaction(transaction) { fan = 0; warmth = 0 }
    }

    private var header: some View {
        HStack {
            RoomScoreHeading(score: score)
            Spacer(minLength: 4)
            Menu {
                AISkillOptions()
                Toggle("Sound effects", isOn: $soundEnabled)
                Toggle("Haptics", isOn: $hapticsEnabled)
                Divider()
                Button("New Game", systemImage: "arrow.counterclockwise") { cancelArrival(); newGame() }.disabled(!canReset || isDealing)
            } label: {
                Image(systemName: "ellipsis").font(.system(size: 17)).frame(width: 44, height: 44)
                    .background(RoomColor.felt.opacity(0.6), in: Circle())
                    .overlay(Circle().stroke(RoomColor.edge, lineWidth: 0.65))
            }
            .accessibilityLabel("Game options").accessibilityIdentifier("tarneeb-game-options")
        }.frame(height: 50)
    }

    private var phaseSummary: String {
        if let playback {
            switch playback.southRevealState {
            case .spreadingBacks, .backsVisible: return "Opening your hand"
            case .flipping: return "Revealing your hand"
            case .revealed: return "Your hand"
            default: return playback.establishedCardCount == 52 ? "Cards dealt" : "Dealing cards"
            }
        }
        if choosingTrump { return "You won the bid: \(game.highestBidValue?.displayLabel ?? "")" }
        if game.biddingCompletionOutcome == .allPassRedeal { return "All passed. Dealing again" }
        if let seat = game.highestBidSeat, let bid = game.highestBidValue { return "طلب · \(seat.displayLabel) leads with \(bid.displayLabel)" }
        return "طلب · Bidding"
    }
    private var phaseSummaryText: Text {
        if phaseSummary.hasPrefix("طلب") {
            // Isolate the Arabic word within the primary English paragraph.
            return Text("\u{200E}\u{2067}طلب\u{2069}\u{200E}").font(.custom("GeezaPro", fixedSize: 17).weight(.semibold))
                + Text(String(phaseSummary.dropFirst(3))).font(.system(size: 17, weight: .semibold))
        }
        return Text(phaseSummary).font(.system(size: 17, weight: .semibold))
    }
    private func phaseBanner(compact: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(isDealing ? "DEALING" : choosingTrump ? (compact ? "Choose tarneeb" : "AUCTION WON") : "BIDDING").font(.system(size: 9, weight: .medium)).tracking(1.4).foregroundStyle(RoomColor.muted)
                    .accessibilityLabel(isDealing ? "Dealing" : choosingTrump && compact ? "Tarneeb" : choosingTrump ? "Auction won" : "Bidding")
                    .accessibilityIdentifier(choosingTrump && compact ? "tarneeb-suit-heading" : "tarneeb-phase-kicker")
                phaseSummaryText.accessibilityLabel(phaseSummary).accessibilityIdentifier("tarneeb-opening-status")
            }
            Spacer(minLength: 4)
            if game.dealerSeat == .south {
                HStack(spacing: 3) { Text("You").font(.caption); RoomDealerBadge() }
                    .accessibilityElement(children: .ignore).accessibilityLabel("You, dealer")
                    .accessibilityIdentifier("tarneeb-opening-south-dealer")
            }
            if waitingForSouth { Text("Your turn").font(.system(size: 12)).foregroundStyle(RoomColor.brass) }
        }
        .lineLimit(1).minimumScaleFactor(0.75).padding(.horizontal, 14).frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RoomColor.panel, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(RoomColor.edge, lineWidth: 0.65))
    }

    private func table(compact: Bool) -> some View {
        GeometryReader { proxy in
            let geometry = RoomTableGeometry(size: proxy.size)
            ZStack {
                Color.clear.frame(width: 71, height: 100)
                    .openingAnchor("dealer-deck-origin")
                    .accessibilityElement(children: .ignore).accessibilityLabel("Dealer deck departure position")
                    .accessibilityIdentifier("tarneeb-deck-source")
                    .accessibilityHidden(!exposesDeckOrigin)
                    .position(geometry.dealerDeckOrigin(game.dealerSeat))
                RoomFelt(warmth: warmth).frame(width: geometry.feltRect.width, height: geometry.feltRect.height)
                    .roomGeometry("felt", in: continuity, properties: .frame)
                    .position(x: geometry.feltRect.midX, y: geometry.feltRect.midY)
                ForEach(Seat.allCases, id: \.self) { seat in
                    station(seat, compact: compact)
                        .roomGeometry("station-\(seat.rawValue)", in: continuity)
                        .openingAnchor(seat.rawValue).position(geometry.station(seat))
                }
                ForEach(Seat.allCases, id: \.self) { seat in
                    if seat != .south || ready {
                        let point = dealHandPoint(seat, geometry: geometry)
                        Color.clear.frame(width: 64, height: 90)
                            .openingAnchor("deal-hand-\(seat.rawValue)")
                            .accessibilityElement(children: .ignore).accessibilityLabel("\(seat.displayLabel) hand position")
                            .accessibilityIdentifier("tarneeb-deal-anchor-\(seat.rawValue)")
                            .position(point)
                        if seat != .south, playback.map({ $0.landedCount(for: seat) > 0 }) ?? (game.phase == .dealt) {
                            let progress = playback?.stationHandoffProgress ?? 1
                            let target = stationPacketPoint(seat, geometry: geometry)
                            RoomPacket(width: 64 + ((seat == .north ? 25.0 : 24.0) - 64) * progress,
                                       squared: true, settlement: progress)
                                .position(x: point.x + (target.x - point.x) * progress,
                                          y: point.y + (target.y - point.y) * progress)
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel("\(seat.displayLabel) face-down stack")
                                .accessibilityValue("\(playback?.landedCount(for: seat) ?? 13) cards")
                                .accessibilityIdentifier("tarneeb-deal-stack-\(seat.rawValue)")
                        }
                    }
                }
                if choosingTrump {
                    trumpChoices(compact: compact).position(x: proxy.size.width / 2, y: proxy.size.height * 0.54 + (compact ? 8 : 0))
                } else if waitingForSouth {
                    bidChoices.position(x: proxy.size.width / 2, y: max(137, proxy.size.height - 107))
                } else if !isDealing && !ready {
                    Text(game.currentBiddingSeat.map { "\($0 == .north ? "Partner" : $0.displayLabel) is bidding" } ?? "Preparing the table")
                        .font(.system(size: 17, weight: .medium)).position(x: proxy.size.width / 2, y: proxy.size.height * 0.54)
                }
            }
        }.frame(minHeight: ready ? 196 : 228)
            .openingAnchor("dealer-deck-table")
    }
    private func station(_ seat: Seat, compact: Bool) -> some View {
        let delivered = playback?.deliveredSeats.contains(seat) ?? (game.phase == .dealt)
        let bid = game.bids[seat]?.resolvedValue
        return RoomStation(seat: seat, detail: ready || (compact && choosingTrump && seat == .north) ? "" : bid?.displayLabel ?? "",
                           active: !isDealing && game.currentBiddingSeat == seat, dealer: game.dealerSeat == seat,
                           cards: delivered && seat != .south, opening: ready,
                           packetReservation: playback?.stationHandoffProgress ?? 1,
                           externalPacketAnchor: "station-packet-\(seat.rawValue)")
            .accessibilityIdentifier("tarneeb-opening-station-\(seat.rawValue)")
    }
    private var bidChoices: some View {
        VStack(spacing: 7) {

            LazyVGrid(columns: Array(repeating: GridItem(.fixed(48), spacing: 7), count: legalNumbers.count > 6 ? 4 : 3), spacing: 7) {
                ForEach(legalNumbers, id: \.self) { value in
                    Button { draftBid = value; selectionFeedback() } label: {
                        Text(value.displayLabel).font(.system(size: 24, weight: .semibold)).monospacedDigit()
                            .frame(width: 48, height: 44)
                            .foregroundStyle(draftBid == value ? RoomColor.ink : RoomColor.ivory)
                            .background(draftBid == value ? RoomColor.ivory : RoomColor.felt, in: RoundedRectangle(cornerRadius: 11))
                            .overlay(RoundedRectangle(cornerRadius: 11).stroke(draftBid == value ? RoomColor.brass : RoomColor.edge, lineWidth: 0.7))
                    }.buttonStyle(.plain).accessibilityLabel(value.displayLabel)
                        .accessibilityValue(draftBid == value ? "Selected" : "")
                        .accessibilityIdentifier("tarneeb-bid-option-\(value.displayLabel)")
                }
            }.frame(width: legalNumbers.count > 6 ? 213 : 158)
            HStack(spacing: 8) {
                Button("Pass") { draftBid = .pass; submitBid() }
                    .buttonStyle(RoomCommandStyle(primary: false, height: 44, reduceMotion: reduceMotion)).frame(width: 75)
                    .accessibilityIdentifier("tarneeb-pass-button-south")
                Button(draftBid == .pass ? "Confirm" : "Bid \(draftBid.displayLabel)", action: submitBid)
                    .buttonStyle(RoomCommandStyle(height: 44, reduceMotion: reduceMotion))
                    .disabled(draftBid == .pass || !legalNumbers.contains(draftBid))
                    .accessibilityIdentifier("tarneeb-bid-button-south")
            }.frame(width: 213)
        }.padding(.horizontal, 8).padding(.vertical, 6)
            .background(RoomColor.panel.opacity(0.94), in: RoundedRectangle(cornerRadius: 17))
            .overlay(RoundedRectangle(cornerRadius: 17).stroke(RoomColor.edge, lineWidth: 0.65))
            .accessibilityElement(children: .contain).accessibilityIdentifier("tarneeb-bid-grid")
    }
    private func trumpChoices(compact: Bool) -> some View {
        VStack(spacing: 7) {
            if !compact {
                Text("Choose tarneeb").font(.system(size: 17, weight: .medium)).accessibilityLabel("Tarneeb").accessibilityIdentifier("tarneeb-suit-heading")
            }
            LazyVGrid(columns: [GridItem(.fixed(60)), GridItem(.fixed(60))], spacing: 7) {
                ForEach(Suit.allCases, id: \.self) { suit in
                    Button { draftSuit = suit; selectionFeedback() } label: {
                        Text(suit.displaySymbol).font(.system(size: 34))
                            .foregroundStyle(suit == .hearts || suit == .diamonds ? RoomColor.burgundy : (draftSuit == suit ? RoomColor.ink : RoomColor.ivory))
                            .frame(width: 60, height: 54)
                            .background(draftSuit == suit ? RoomColor.ivory : RoomColor.felt, in: RoundedRectangle(cornerRadius: 13))
                            .overlay(RoundedRectangle(cornerRadius: 13).stroke(draftSuit == suit ? RoomColor.brass : RoomColor.edge, lineWidth: 1))
                    }.buttonStyle(.plain).accessibilityLabel(suit.rawValue.capitalized).accessibilityValue(draftSuit == suit ? "Selected" : "")
                        .accessibilityIdentifier("tarneeb-bid-suit-option-\(suit.rawValue)")
                }
            }.frame(width: 130)
            Text(draftSuit.map { "\($0.rawValue.capitalized) selected" } ?? "Choose a suit")
                .font(.system(size: 11)).foregroundStyle(RoomColor.brass)
        }
    }
    private func southHand(width: Double) -> some View {
        let layout = LiveHandLayout(width: width)
        let showCards = playback.map { $0.landedCount(for: .south) > 0 } ?? (game.phase == .dealt)
        return ZStack(alignment: .topLeading) {
            Color.clear.frame(width: 64, height: 90).position(x: width / 2, y: layout.height / 2)
                .openingAnchor("deal-hand-south")
                .accessibilityElement(children: .ignore).accessibilityLabel("South hand position")
                .accessibilityIdentifier("tarneeb-deal-anchor-south")
            if showCards {
                if let playback, playback.southSpreadProgress == 0 {
                    RoomPacket(width: 64, squared: true).position(x: width / 2, y: layout.height / 2)
                }
                ForEach(Array(hand.enumerated()), id: \.element.id) { index, card in
                    let revealed = playback == nil || index < (playback?.southRevealedCardCount ?? 0)
                    OpeningFlipCard(card: card, angle: revealed ? 180 : 0, reduceMotion: reduceMotion)
                        .opacity(playback == nil || index < (playback?.southFaceDownCardCount ?? 13) ? 1 : 0)
                        .position(southCardPosition(index: index, count: hand.count, width: width, layout: layout))
                        .accessibilityElement(children: .ignore).accessibilityLabel(revealed ? "\(card.rank.displayLabel) of \(card.suit.rawValue)" : "Face-down card")
                        .accessibilityIdentifier("tarneeb-opening-card-\(card.id)")
                }
            } else if playback?.deliveredSeats.contains(.south) == true {
                RoomPacket(width: 64).position(x: width / 2, y: layout.height / 2)
            }
        }.frame(width: width, height: layout.height)
            .roomGeometry("south-hand", in: continuity)
            .openingAnchor("south-hand")
            .accessibilityElement(children: .contain)
            .accessibilityValue(playback.map { "state=\($0.southRevealState.rawValue);faceDown=\($0.southFaceDownCardCount);revealed=\($0.southRevealedCardCount);packetsLanded=\($0.landedPackets.count);packetsIssued=\($0.issuedPackets.count);retained=\($0.dealerHandRetained ? 13 : 0);established=\($0.establishedCardCount);packetsInFlight=\($0.flyingPackets.count);source=\($0.presentation.dealerSeat.rawValue);spread=\($0.southSpreadProgress);revealCompleted=\($0.completedReveals.count)" } ?? "Face-up hand")
            .accessibilityIdentifier("tarneeb-opening-hand")
    }
    @ViewBuilder private var actions: some View {
        if game.phase == .notStarted {
            Button(isDealing ? "Dealing" : "Deal") { cancelArrival(); dealDeckOrigin = frames["dealer-deck-origin"].map { CGPoint(x: $0.midX, y: $0.midY) }; deal() }
                .buttonStyle(RoomCommandStyle(arrow: true, reduceMotion: reduceMotion))
                .disabled(!canDeal || isDealing || blocked).accessibilityIdentifier("tarneeb-deal-button")
        } else if choosingTrump {
            Button(draftSuit.map { "Confirm \($0.rawValue)" } ?? "Confirm tarneeb", action: submitTrump)
                .buttonStyle(RoomCommandStyle(arrow: true, reduceMotion: reduceMotion))
                .disabled(draftSuit == nil || blocked).accessibilityIdentifier("tarneeb-post-bidding-suit-button-south")
        } else if waitingForSouth {
            Text(draftBid == .pass ? "Select a bid above, then confirm · or Pass" : "\(draftBid.displayLabel) proposed · confirm above to commit")
                .font(.system(size: 12)).foregroundStyle(RoomColor.muted)
        } else {
            Text(isDealing ? "Dealing" : game.bids[.south]?.resolvedValue.map { "Your bid: \($0.displayLabel)" } ?? "Preparing the table")
                .font(.system(size: 13)).foregroundStyle(RoomColor.muted)
        }
    }
    private func dealHandPoint(_ seat: Seat, geometry: RoomTableGeometry) -> CGPoint {
        let station = geometry.station(seat)
        switch seat {
        case .north: return CGPoint(x: station.x, y: station.y + 58)
        case .west: return CGPoint(x: 54, y: station.y + 58)
        case .east: return CGPoint(x: geometry.size.width - 54, y: station.y + 58)
        case .south: return CGPoint(x: station.x, y: geometry.size.height - 78)
        }
    }
    private func stationPacketPoint(_ seat: Seat, geometry: RoomTableGeometry) -> CGPoint {
        guard let label = frames["station-packet-\(seat.rawValue)-label"] else {
            return dealHandPoint(seat, geometry: geometry)
        }
        let center = geometry.station(seat)
        let detailHeight = frames["station-packet-\(seat.rawValue)-detail"].map { $0.height + 3 } ?? 0
        // Target the final station layout, independent of its animated reservation.
        // Following preference frames during the animation would restart the trajectory.
        let offset = seat == .north ? -(label.height + detailHeight) / 2 - 2.5
                                   : (label.height - detailHeight) / 2 + 1.5
        return CGPoint(x: center.x, y: center.y + offset)
    }
    private var exposesDeckOrigin: Bool {
        #if DEBUG
        return ProcessInfo.processInfo.environment["TARNEEB_OPENING_FIXTURE"] != nil
        #else
        return false
        #endif
    }
    private var deckSource: CGPoint? {
        if playback != nil, let dealDeckOrigin { return dealDeckOrigin }
        guard let table = frames["dealer-deck-table"] else { return nil }
        let dealer = playback?.presentation.dealerSeat ?? game.dealerSeat
        let point = RoomTableGeometry(size: table.size).dealerDeckOrigin(dealer)
        return CGPoint(x: table.minX + point.x, y: table.minY + point.y)
    }
    @ViewBuilder private var dealerDeck: some View {
        if ready || (playback != nil && playback?.dealerHandRetained == false),
           let source = deckSource {
            RoomPacket(width: ready ? 71 : 64, fan: ready ? fan : 0, squared: true)
                .position(source)
                .accessibilityElement(children: .ignore).accessibilityLabel("Dealer deck at \(game.dealerSeat.displayLabel)")
                .accessibilityValue("\(playback?.centralCardCount ?? 52) cards")
                .accessibilityIdentifier("tarneeb-opening-deck")
        }
    }
    private func southCardPosition(index: Int, count: Int, width: Double, layout: LiveHandLayout) -> CGPoint {
        let final = layout.center(at: index, cardCount: count)
        let progress = playback?.southSpreadProgress ?? 1
        return CGPoint(x: width / 2 + (final.x - width / 2) * progress,
                       y: layout.height / 2 + (final.y - layout.height / 2) * progress)
    }
    @ViewBuilder private var packetFlight: some View {
        if let playback, let source = deckSource {
            ForEach(playback.flyingPackets, id: \.self) { index in
                let seat = playback.seat(forPacket: index)
                if let target = frames["deal-hand-\(seat.rawValue)"] {
                    OpeningPacketFlight(source: source,
                                      target: CGPoint(x: target.midX, y: target.midY),
                                      reduceMotion: reduceMotion) {
                        packetLanded(playback.generation, index)
                    }
                    .id("\(playback.generation)-\(index)")
                    .accessibilityElement(children: .ignore).accessibilityLabel("Dealing 13-card stack to \(seat.displayLabel)").accessibilityValue("13 cards")
                    .accessibilityIdentifier("tarneeb-opening-packet")
                }
            }
        }
    }

}

private struct OpeningCardBack: View {
    var body: some View {
        Image("card_back").resizable().scaledToFit().frame(width: 64, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .shadow(color: .black.opacity(0.25), radius: 2, y: 3)
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
                ReadableCardFace(card: card, roomStyle: true).opacity(angle / 180)
            } else if angle < 90 {
                OpeningCardBack()
            } else {
                ReadableCardFace(card: card, roomStyle: true).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
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

private struct OpeningPacketFlight: View {
    let source: CGPoint
    let target: CGPoint
    let reduceMotion: Bool
    let landed: () -> Void
    @State private var atTarget = false
    var body: some View {
        RoomPacket(width: 64, squared: true)
            .position(atTarget ? target : source)
            .allowsHitTesting(false)
            .onAppear {
                // Completion of the real packet flight, not its nominal duration, owns the landing.
                withAnimation(reduceMotion ? nil : .easeInOut(duration: GameAnimationToken.dealStackFlightDuration.seconds), completionCriteria: .removed) {
                    atTarget = true
                } completion: { landed() }
            }
    }
}
