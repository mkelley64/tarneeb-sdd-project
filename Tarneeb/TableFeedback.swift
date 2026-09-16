import AVFoundation
import UIKit

@MainActor
final class TableFeedback {
    enum Event: CaseIterable {
        case select, land, collect, roundWin, roundLoss, matchWin

        var duration: Double {
            switch self {
            case .select: return 0.045
            case .land: return 0.13
            case .collect: return 0.28
            case .roundWin: return 0.65
            case .roundLoss: return 0.45
            case .matchWin: return 1.2
            }
        }

        var recordingPrefix: String? {
            switch self {
            case .select: return "card-slide"
            case .land: return "card-place"
            case .collect: return "card-shove"
            case .roundWin, .roundLoss, .matchWin: return nil
            }
        }

        var volume: Float {
            switch self {
            case .select: return CardSoundToken.selectionVolume
            case .land: return CardSoundToken.landingVolume
            case .collect: return CardSoundToken.collectionVolume
            case .roundWin, .roundLoss, .matchWin: return 1
            }
        }
    }

    private struct SoundKey: Hashable { let event: Event; let variant: Int }
    private var players: [SoundKey: AVAudioPlayer] = [:]
    private var nextVariant: [Event: Int] = [:]

    func play(_ event: Event, haptic: Bool = true) {
        guard UIApplication.shared.applicationState == .active else { return }
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "tarneeb.soundEnabled") as? Bool ?? true {
            do {
                let paper = event == .select || event == .land || event == .collect
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
        if haptic, defaults.object(forKey: "tarneeb.hapticsEnabled") as? Bool ?? true {
            switch event {
            case .select: UISelectionFeedbackGenerator().selectionChanged()
            case .land: UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.5)
            case .collect: UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.7)
            case .roundWin, .matchWin: UINotificationFeedbackGenerator().notificationOccurred(.success)
            case .roundLoss: UINotificationFeedbackGenerator().notificationOccurred(.warning)
            }
        }
    }

    func stop() {
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

    // Preserve result chimes and a lightweight fallback if a recording cannot be loaded.
    static func synthesizedSoundData(_ event: Event, variation: PaperSoundVariation) -> Data {
        let sampleRate = 22_050
        let count = Int(Double(sampleRate) * event.duration)
        var samples = Data(capacity: count * 2)
        var seed = variation.seed
        var filtered = 0.0
        for index in 0..<count {
            seed = 1664525 &* seed &+ 1013904223
            let noise = Double(seed) / Double(UInt32.max) * 2 - 1
            filtered = filtered * variation.smoothing + noise * (1 - variation.smoothing)
            let t = Double(index) / Double(sampleRate)
            let progress = Double(index) / Double(count)
            let attack = min(1, t / 0.006)
            let envelope: Double
            var signal = filtered
            switch event {
            case .select: envelope = attack * exp(-progress * 9) * 0.18
            case .land: envelope = attack * exp(-progress * 7) * 0.45
            case .collect: envelope = sin(progress * .pi) * (0.65 + 0.35 * cos(t * 110)) * 0.18
            case .roundWin, .roundLoss, .matchWin:
                let notes: [Double]
                switch event {
                case .matchWin: notes = [523.25, 659.25, 783.99, 1046.5]
                case .roundWin: notes = [523.25, 659.25, 783.99]
                default: notes = [392, 329.63]
                }
                let noteDuration = event.duration / Double(notes.count)
                let note = min(notes.count - 1, Int(t / noteDuration))
                let local = t - Double(note) * noteDuration
                signal = sin(2 * .pi * notes[note] * local) + 0.2 * sin(4 * .pi * notes[note] * local)
                envelope = min(1, local / 0.008) * exp(-local * 12) * min(1, (noteDuration - local) / 0.02) * 0.16
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
