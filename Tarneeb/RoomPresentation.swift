import SwiftUI

extension View {
    @ViewBuilder func roomGeometry(_ id: String, in namespace: Namespace.ID?,
                                   properties: MatchedGeometryProperties = .position) -> some View {
        if let namespace { matchedGeometryEffect(id: id, in: namespace, properties: properties) }
        else { self }
    }
}

// Contemporary Levantine card-room presentation across the existing single-player game.
enum RoomColor {
    static let trackerScrim = color(0x000000)
    static let forest = color(0x103C31), felt = color(0x235443)
    static let ivory = color(0xF4EDE0), paper = color(0xFFFDF6)
    static let brass = color(0xDDC69C), muted = color(0xC0CEC1)
    static let burgundy = color(0x9D3438), ink = color(0x1D2D29)
    static let panel = color(0x0F322A), edge = color(0x69806A)
    static func color(_ hex: UInt32) -> Color {
        Color(red: Double((hex >> 16) & 255) / 255, green: Double((hex >> 8) & 255) / 255, blue: Double(hex & 255) / 255)
    }
}

struct RoomBackground: View {
    var body: some View {
        RadialGradient(colors: [RoomColor.color(0x275845), RoomColor.forest, RoomColor.color(0x092D27)],
                       center: .init(x: 0.5, y: 0.35), startRadius: 20, endRadius: 640)
            .ignoresSafeArea().accessibilityHidden(true)
    }
}

struct RoomFelt: View {
    var warmth = 0.0
    var body: some View {
        GeometryReader { proxy in
            let radius = min(112.0, proxy.size.height / 2, proxy.size.width / 2)
            RoundedRectangle(cornerRadius: radius)
                .fill(RoomColor.panel)
                .overlay(RoundedRectangle(cornerRadius: radius).strokeBorder(RoomColor.edge, lineWidth: 0.65))
                .overlay {
                    RoundedRectangle(cornerRadius: max(1, radius - 5))
                        .fill(RadialGradient(colors: [RoomColor.color(0x2A5D49), RoomColor.color(0x1A493B)], center: .init(x: 0.5, y: 0.35), startRadius: 0, endRadius: 300))
                        .overlay(RoundedRectangle(cornerRadius: max(1, radius - 5)).strokeBorder(RoomColor.edge.opacity(0.5), lineWidth: 0.7))
                        .padding(5)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: max(1, radius - 14)).strokeBorder(RoomColor.brass.opacity(0.16), lineWidth: 0.5).padding(14)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: radius)
                        .fill(RadialGradient(colors: [RoomColor.brass.opacity(0.12 * warmth), .clear], center: .center, startRadius: 5, endRadius: 170))
                }
        }
        .allowsHitTesting(false).accessibilityHidden(true)
    }
}

struct RoomDealerBadge: View {
    var body: some View {
        Text("D").font(.system(size: 9, weight: .bold)).foregroundStyle(RoomColor.ink)
            .frame(width: 14, height: 14).background(RoomColor.brass, in: Circle()).accessibilityLabel("Dealer")
    }
}

struct RoomPacket: View {
    var width = 28.0
    var fan = 0.0
    var squared = false
    var settlement: Double? = nil
    private var pose: Double { settlement ?? (squared ? 0 : 1) }
    var body: some View {
        ZStack {
            back.rotationEffect(.degrees(-8 * pose - 5 * fan)).offset(x: -2 - 2 * pose - 7 * fan, y: 3 + 2 * fan)
            back.rotationEffect(.degrees(7 * pose + 5 * fan)).offset(x: 2 + 2 * pose + 7 * fan, y: 1 - 3 * fan)
            back.offset(y: -8 * fan)
        }
        .frame(width: width, height: width * 90 / 64)
        .accessibilityHidden(true)
    }
    private var back: some View {
        Image("card_back").resizable().scaledToFit().frame(width: width, height: width * 90 / 64)
            .clipShape(RoundedRectangle(cornerRadius: settlement.map { 6 - 4 * $0 } ?? (width > 40 ? 6 : 2)))
            .shadow(color: .black.opacity(0.25), radius: 2, y: 3)
    }
}

struct RoomStation: View {
    let seat: Seat
    let detail: String
    var active = false
    var winner = false
    var dealer = false
    var cards = true
    var opening = false
    var detailInFooter = false
    var packetAnchor: String? = nil
    var packetReservation = 1.0
    var externalPacketAnchor: String? = nil
    var body: some View {
        VStack(spacing: 0) {
            if seat == .north && cards && !opening {
                stationPacket(width: 25)
                    .overlay(Circle().stroke(RoomColor.brass.opacity(winner ? 0.9 : 0), lineWidth: 1.5).frame(width: 50, height: 50))
                    .padding(.bottom, 5 * packetReservation)
            }
            HStack(spacing: 4) {
                if seat == .north || seat == .south { Circle().fill(RoomColor.brass).frame(width: 4, height: 4).accessibilityHidden(true) }
                Text(seat == .north ? "North · Partner" : (seat == .south ? "You" : seat.displayLabel))
                    .font(.system(size: seat == .south ? 14 : 13, weight: .semibold))
                if dealer { RoomDealerBadge() }
            }
            .padding(.horizontal, seat == .north ? 5 : 0)
            .background { if seat == .north { RoomColor.felt.clipShape(Capsule()) } }
            .openingAnchor(externalPacketAnchor.map { $0 + "-label" } ?? "")
            if seat != .north && seat != .south && cards && !opening {
                stationPacket(width: 24).padding(.top, 5 * packetReservation).padding(.bottom, 2 * packetReservation)
            }
            if !detail.isEmpty && !detailInFooter {
                Text(detail).font(.system(size: 11, weight: .medium)).foregroundStyle(active || winner ? RoomColor.brass : RoomColor.muted)
                    .openingAnchor(externalPacketAnchor.map { $0 + "-detail" } ?? "")
                    .padding(.top, 3)
                    .padding(.horizontal, seat == .north ? 4 : 0)
                    .background { if seat == .north { RoomColor.felt.clipShape(Capsule()) } }
            }
        }
        .foregroundStyle(RoomColor.ivory)
        .lineLimit(1).minimumScaleFactor(0.75)
        .frame(width: seat == .north ? 156 : (seat == .south ? 160 : 62))
        .overlay(alignment: .bottom) {
            if active { Capsule().fill(RoomColor.brass.opacity(0.6)).frame(width: 24, height: 1).offset(y: 4).accessibilityHidden(true) }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(seat == .north ? "North, your partner" : seat == .south ? "You" : seat.displayLabel)\(dealer ? ", dealer" : "")")
        .accessibilityValue(detail + (active ? ", active" : ""))
    }
    @ViewBuilder private func stationPacket(width: Double) -> some View {
        if let externalPacketAnchor {
            Color.clear.frame(width: width, height: width * 90 / 64)
                .openingAnchor(externalPacketAnchor)
                .frame(height: width * 90 / 64 * packetReservation)
        } else {
            RoomPacket(width: width).liveAnchor(packetAnchor ?? "")
        }
    }
}

struct ScoreWordmarkAnchor: PreferenceKey {
    static var defaultValue: Anchor<CGRect>? = nil
    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) { value = nextValue() ?? value }
}

struct RoomScoreHeading: View {
    let score: GameScore
    var centersWordmark = false
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center) {
                Text("First to \(GameScore.winningScore)").font(.system(size: 10, weight: .medium))
                    .foregroundStyle(RoomColor.muted).accessibilityIdentifier("tarneeb-match-target")
                Spacer(minLength: 12)
                Text("طرنيب").font(.custom("GeezaPro", fixedSize: 23)).foregroundStyle(RoomColor.brass)
                    .opacity(centersWordmark ? 0 : 1)
                    .anchorPreference(key: ScoreWordmarkAnchor.self, value: .bounds) { centersWordmark ? $0 : nil }
                    .accessibilityHidden(true)
            }
            HStack(spacing: 12) {
                value("You + Partner", score.northSouth, "North South")
                Rectangle().fill(RoomColor.muted.opacity(0.23)).frame(width: 0.5, height: 20).accessibilityHidden(true)
                value("Opponents", score.eastWest, "East West")
            }
        }
        .lineLimit(1).fixedSize(horizontal: true, vertical: false).layoutPriority(1)
    }
    private func value(_ title: String, _ points: Int, _ team: String) -> some View {
        (Text(title).font(.system(size: 13, weight: .medium)) + Text("  \(points)").font(.system(size: 23, weight: .semibold)).monospacedDigit())
            .foregroundStyle(RoomColor.ivory).accessibilityLabel("\(team) score \(points)")
    }
}

struct RoomCommandStyle: ButtonStyle {
    @Environment(\.isEnabled) private var enabled
    var primary = true
    var height = 48.0
    var arrow = false
    var reduceMotion = false
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label.font(.system(size: 17, weight: .semibold)).lineLimit(1).minimumScaleFactor(0.8)
            if arrow { Spacer(); Image(systemName: "arrow.right").font(.system(size: 17)) }
        }
        .padding(.horizontal, 18).frame(maxWidth: .infinity).frame(height: height)
        .foregroundStyle(primary ? RoomColor.ink : RoomColor.ivory)
        .background(primary ? RoomColor.ivory : RoomColor.felt, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(primary ? RoomColor.brass.opacity(0.45) : RoomColor.edge, lineWidth: 0.7))
        .contentShape(Rectangle()).opacity(enabled ? 1 : 0.4)
        .shadow(color: .black.opacity(configuration.isPressed ? 0.08 : 0.22), radius: configuration.isPressed ? 1 : 3, y: configuration.isPressed ? 1 : 3)
        .offset(y: configuration.isPressed && !reduceMotion ? 1 : 0)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct RoomContract: View {
    let game: GameState
    let reduceMotion: Bool
    var body: some View {
        if let summary = game.postBiddingSummary, let progress = ContractProgressPresentation(summary: summary, trick: game.trickPlayState) {
            VStack(spacing: 6) {
                HStack(spacing: 10) {
                    Capsule().fill(RoomColor.brass).frame(width: 3, height: 38).accessibilityHidden(true)
                    Text(summary.tarneebSuit.displaySymbol).font(.system(size: 29)).foregroundStyle(RoomColor.brass)
                        .accessibilityLabel("Tarneeb \(summary.tarneebSuit.rawValue)")
                    VStack(alignment: .leading, spacing: 3) {
                        Text(progress.team == .teamA ? "YOUR TEAM’S CONTRACT" : "OPPONENTS’ CONTRACT")
                            .font(.system(size: 9, weight: .medium)).tracking(1).foregroundStyle(RoomColor.muted)
                        (Text(summary.bidValue.displayLabel).font(.system(size: 24, weight: .semibold)) + Text(" \(summary.tarneebSuit.rawValue.capitalized)").font(.system(size: 15, weight: .medium)))
                            .accessibilityLabel("\(summary.highBidderSeat == .south ? "You bid" : summary.highBidderSeat.displayLabel + " bids") \(summary.bidValue.displayLabel)")
                            .accessibilityIdentifier("tarneeb-live-contract-bid")
                    }
                    Spacer(minLength: 0)
                    VStack(alignment: .trailing, spacing: 3) {
                        Text(progress.milestone == .secured ? "SECURED" : progress.milestone == .missed ? "MISSED" : progress.milestone == .oneAway ? "ONE MORE" : "TRICKS")
                            .font(.system(size: 9, weight: .medium)).tracking(1).foregroundStyle(RoomColor.muted)
                        Text("\(progress.won) / \(progress.target)").font(.system(size: 24, weight: .semibold)).monospacedDigit()
                            .accessibilityLabel(progress.label).accessibilityValue(progress.accessibilityValue)
                            .accessibilityIdentifier("tarneeb-contract-progress")
                    }
                }
                .transaction { $0.animation = nil }
                GeometryReader { proxy in
                    Capsule().fill(RoomColor.edge.opacity(0.4)).overlay(alignment: .leading) {
                        Capsule().fill(RoomColor.brass).frame(width: proxy.size.width * progress.fraction)
                            .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: progress.fraction)
                    }
                }.frame(height: 2).accessibilityHidden(true)
            }
            .padding(.horizontal, 12).padding(.top, 9).padding(.bottom, 6)
            .foregroundStyle(RoomColor.ivory)
            .background(RoomColor.panel, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(RoomColor.edge, lineWidth: 0.65))
        }
    }
}

struct RoomCardTravel: AnimatableModifier {
    var progress: Double
    var contact: Double
    let source: CGPoint
    let target: CGPoint
    let reduceMotion: Bool
    var sourceScale = 1.0
    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(progress, contact) }
        set { progress = newValue.first; contact = newValue.second }
    }
    func body(content: Content) -> some View {
        let arc = reduceMotion ? 0 : sin(.pi * progress)
        let bounce = reduceMotion ? 0 : 1.3 * sin(.pi * contact)
        return content
            .scaleEffect(reduceMotion ? 1 : sourceScale + (1 - sourceScale) * progress)
            .shadow(color: .black.opacity(0.24), radius: 2 + 6 * arc, x: 3 * arc, y: 2 + 8 * arc)
            .rotationEffect(.degrees(3 * arc))
            .opacity(reduceMotion && progress < 0.5 ? 0 : 1)
            .position(x: reduceMotion ? target.x : source.x + (target.x - source.x) * progress,
                      y: reduceMotion ? target.y : source.y + (target.y - source.y) * progress - 23 * arc + bounce)
    }
}

struct RoomCollection: AnimatableModifier {
    var progress: Double
    let source: CGPoint
    let target: CGPoint
    let reduceMotion: Bool
    var animatableData: Double { get { progress } set { progress = newValue } }
    func body(content: Content) -> some View {
        content.scaleEffect(reduceMotion ? 1 : 1 - 0.7 * progress)
            .opacity(reduceMotion ? 1 - progress : 1 - max(0, (progress - 0.77) / 0.23))
            .position(x: reduceMotion ? source.x : source.x + (target.x - source.x) * progress,
                      y: reduceMotion ? source.y : source.y + (target.y - source.y) * progress)
    }
}
