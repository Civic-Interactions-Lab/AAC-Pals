import AVFoundation

final class SpeechManager {
    static let shared = SpeechManager()

    private let synthesizer = AVSpeechSynthesizer()

    private init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[Speech] Audio session setup error: \(error)")
        }
    }

    var englishVoices: [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix("en") && !$0.voiceTraits.contains(.isNoveltyVoice) }
            .sorted { $0.quality.rawValue != $1.quality.rawValue ? $0.quality.rawValue > $1.quality.rawValue : $0.name < $1.name }
    }

    func speak(_ text: String, voiceIdentifier: String? = nil) {
        guard !text.isEmpty else { return }
        if synthesizer.isSpeaking { synthesizer.stopSpeaking(at: .immediate) }
        let utterance = AVSpeechUtterance(string: text)
        if let id = voiceIdentifier ?? VoiceSettings.voiceIdentifier {
            utterance.voice = AVSpeechSynthesisVoice(identifier: id)
        }
        utterance.rate = min(max(AVSpeechUtteranceDefaultSpeechRate * Float(VoiceSettings.rate), AVSpeechUtteranceMinimumSpeechRate), AVSpeechUtteranceMaximumSpeechRate)
        utterance.pitchMultiplier = Float(VoiceSettings.pitch)
        utterance.volume = Float(VoiceSettings.volume)
        synthesizer.speak(utterance)
    }
}
