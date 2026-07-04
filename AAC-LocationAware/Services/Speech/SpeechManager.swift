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

    func speak(_ text: String, rate: Float = 0.5) {
        guard !text.isEmpty else { return }
        if synthesizer.isSpeaking { synthesizer.stopSpeaking(at: .immediate) }
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = rate
        synthesizer.speak(utterance)
    }
}
