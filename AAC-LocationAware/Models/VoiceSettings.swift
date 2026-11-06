import Foundation

enum VoiceSettings {
    static let voiceIdentifierKey = "voiceIdentifier"
    static let rateKey = "voiceRate"
    static let pitchKey = "voicePitch"
    static let volumeKey = "voiceVolume"
    static let speakEachTapKey = "speakEachTap"

    static let defaultRate = 0.9
    static let defaultPitch = 1.1
    static let defaultVolume = 0.8
    static let defaultSpeakEachTap = true

    static var voiceIdentifier: String? {
        UserDefaults.standard.string(forKey: voiceIdentifierKey).flatMap { $0.isEmpty ? nil : $0 }
    }
    static var rate: Double { value(rateKey, default: defaultRate) }
    static var pitch: Double { value(pitchKey, default: defaultPitch) }
    static var volume: Double { value(volumeKey, default: defaultVolume) }
    static var speakEachTap: Bool {
        UserDefaults.standard.object(forKey: speakEachTapKey) as? Bool ?? defaultSpeakEachTap
    }

    private static func value(_ key: String, default fallback: Double) -> Double {
        UserDefaults.standard.object(forKey: key) as? Double ?? fallback
    }
}
