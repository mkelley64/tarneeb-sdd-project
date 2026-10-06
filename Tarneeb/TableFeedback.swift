import AVFoundation
import UIKit

@MainActor
final class TableFeedback {
    enum Event: CaseIterable {
        case select, land, collect, openingSquare, roundWin, defenseWin, roundLoss, matchWin

        var duration: Double {
            switch self {
            case .select: return 0.045
            case .land: return 0.13
            case .collect: return 0.28
            case .openingSquare: return 0.07
            case .roundWin: return 0.24
            case .defenseWin: return 0.11
            case .roundLoss: return 0.12
            case .matchWin: return 0.46
            }
        }

        var recordingPrefix: String? {
            switch self {
            case .select, .openingSquare: return "card-slide"
            case .land: return "card-place"
            case .collect: return "card-shove"
            case .roundWin, .defenseWin, .roundLoss, .matchWin: return nil
            }
        }

        var volume: Float {
            switch self {
            case .select: return CardSoundToken.selectionVolume
            case .land: return CardSoundToken.landingVolume
            case .collect: return CardSoundToken.collectionVolume
            case .openingSquare: return 0.25
            case .roundWin, .defenseWin, .roundLoss, .matchWin: return 1
            }
        }
    }

    private struct SoundKey: Hashable { let event: Event; let variant: Int }
    private var players: [SoundKey: AVAudioPlayer] = [:]
    private var nextVariant: [Event: Int] = [:]
    private var eventGate = FeedbackEventGate()
    private var hapticTask: Task<Void, Never>?

    @discardableResult
    func playOnce(_ event: Event, identity: String, haptic: Bool = true) -> Bool {
        guard eventGate.accept(identity) else { return false }
        play(event, haptic: haptic)
        return true
    }

    func suppress(identity: String) { _ = eventGate.accept(identity) }
    func beginMatch() { stop(); eventGate.reset() }

    func play(_ event: Event, haptic: Bool = true) {
        guard UIApplication.shared.applicationState == .active else { return }
        let defaults = UserDefaults.standard
        let policy = FeedbackPreferencePolicy(soundEnabled: defaults.object(forKey: "tarneeb.soundEnabled") as? Bool ?? true,
            hapticsEnabled: defaults.object(forKey: "tarneeb.hapticsEnabled") as? Bool ?? true,
            requestsHaptic: haptic, active: UIApplication.shared.applicationState == .active)
        if policy.sound {
            do {
                let paper = event == .select || event == .land || event == .collect || event == .openingSquare
                let variant = paper ? nextVariant[event, default: 0] : 0
                if paper { nextVariant[event] = (variant + 1) % PaperSoundVariation.count }
                let key = SoundKey(event: event, variant: variant)
                try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
                if players[key] == nil {
                    players[key] = try Self.makePlayer(event, variation: PaperSoundVariation(index: variant))
                    players[key]?.prepareToPlay()
                }
                players[key]?.currentTime = 0
                players[key]?.play()
            } catch {
                // Audio is optional; a missing output must never interrupt a turn.
            }
        }
        if policy.haptic {
            switch event {
            case .select: UISelectionFeedbackGenerator().selectionChanged()
            case .land: UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.5)
            case .collect: UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.7)
            case .openingSquare: break
            case .defenseWin: UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.6)
            case .roundLoss: UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.35)
            case .roundWin, .matchWin:
                let match = event == .matchWin
                UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: match ? 0.85 : 0.55)
                hapticTask?.cancel()
                hapticTask = Task { @MainActor in
                    do { try await Task.sleep(for: .seconds(match ? 0.10 : 0.07)) } catch { return }
                    guard !Task.isCancelled, UIApplication.shared.applicationState == .active,
                          UserDefaults.standard.object(forKey: "tarneeb.hapticsEnabled") as? Bool ?? true else { return }
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: match ? 0.75 : 0.45)
                }
            }
        }
    }

    func stop() {
        hapticTask?.cancel(); hapticTask = nil
        players.values.forEach { $0.stop() }
    }

    static func makePlayer(_ event: Event, variation: PaperSoundVariation, bundle: Bundle = .main) throws -> AVAudioPlayer {
        let player = try AVAudioPlayer(data: soundData(event, variation: variation, bundle: bundle))
        player.volume = event.volume
        if event.recordingPrefix != nil {
            player.enableRate = true
            player.rate = CardSoundToken.playbackRate
        }
        return player
    }

    static func recordingURL(_ event: Event, variation: PaperSoundVariation, bundle: Bundle = .main) -> URL? {
        guard let prefix = event.recordingPrefix else { return nil }
        return bundle.url(forResource: "\(prefix)-\(variation.index + 1)", withExtension: "wav", subdirectory: "CardSounds")
    }

    static func soundData(_ event: Event, variation: PaperSoundVariation, bundle: Bundle = .main) -> Data {
        if let url = recordingURL(event, variation: variation, bundle: bundle),
           let data = try? Data(contentsOf: url) {
            return data
        }
        return synthesizedSoundData(event, variation: variation)
    }

    // Muted wood/paper outcome responses; recorded paper remains unchanged for ordinary cards.
    static func synthesizedSoundData(_ event: Event, variation: PaperSoundVariation) -> Data {
        let sampleRate = 22_050
        let count = Int(Double(sampleRate) * event.duration)
        var samples = Data(capacity: count * 2)
        var seed = event.recordingPrefix == nil ? UInt32(0x51A7) : variation.seed
        var filtered = 0.0
        for index in 0..<count {
            seed = 1664525 &* seed &+ 1013904223
            let noise = Double(seed) / Double(UInt32.max) * 2 - 1
            let smoothing = event.recordingPrefix == nil ? 0.66 : variation.smoothing
            filtered = filtered * smoothing + noise * (1 - smoothing)
            let t = Double(index) / Double(sampleRate)
            let progress = Double(index) / Double(count)
            let attack = min(1, t / 0.006)
            let envelope: Double
            var signal = filtered
            switch event {
            case .select: envelope = attack * exp(-progress * 9) * 0.18
            case .land: envelope = attack * exp(-progress * 7) * 0.45
            case .collect: envelope = sin(progress * .pi) * (0.65 + 0.35 * cos(t * 110)) * 0.18
            case .openingSquare: envelope = attack * exp(-progress * 8) * 0.10
            case .roundWin, .defenseWin, .roundLoss, .matchWin:
                // Two restrained resonances for partnership wins; one grounded cue otherwise.
                let pair = event == .roundWin || event == .matchWin
                let secondAt = event == .matchWin ? 0.17 : 0.085
                let local = pair && t >= secondAt ? t - secondAt : t
                let second = pair && t >= secondAt
                let frequency = event == .matchWin ? (second ? 260.0 : 196.0) : event == .roundWin ? (second ? 247.0 : 185.0) : 146.0
                signal = 0.50 * filtered + 0.34 * sin(2 * .pi * frequency * local) + 0.12 * sin(2 * .pi * frequency * 2.7 * local)
                envelope = min(1, local / 0.003) * exp(-local * (event == .matchWin ? 16 : 29)) * min(1, (event.duration - t) / 0.025) * (event == .matchWin ? 0.32 : 0.24)
            }
            var sample = Int16(max(-1, min(1, signal * envelope)) * Double(Int16.max)).littleEndian
            withUnsafeBytes(of: &sample) { samples.append(contentsOf: $0) }
        }
        var data = Data()
        func word<T: FixedWidthInteger>(_ value: T) {
            var value = value.littleEndian
            withUnsafeBytes(of: &value) { data.append(contentsOf: $0) }
        }
        data.append(contentsOf: "RIFF".utf8)
        word(UInt32(36 + samples.count))
        data.append(contentsOf: "WAVEfmt ".utf8)
        word(UInt32(16)); word(UInt16(1)); word(UInt16(1))
        word(UInt32(sampleRate)); word(UInt32(sampleRate * 2))
        word(UInt16(2)); word(UInt16(16))
        data.append(contentsOf: "data".utf8)
        word(UInt32(samples.count))
        data.append(samples)
        return data
    }
}
