import SwiftUI
import AVFoundation

struct BoardView: View {
    @Environment(PictogramManager.self) private var pictogramManager
    @State private var currentRoom: String

    init(currentRoom: String = "kitchen") {
        _currentRoom = State(initialValue: currentRoom)
    }

    private var roomWords: [Word] { AACVocabulary.roomWords[currentRoom] ?? [] }

    var body: some View {
        VStack(spacing: 0) {
            SentenceBar(
                sentence: pictogramManager.sentence,
                onSpeak: { speakSentence() },
                onClear: { pictogramManager.clearSentence() },
                onRemoveLast: { pictogramManager.removeLast() },
                onRemoveAt: { pictogramManager.remove(at: $0) }
            )
            .padding(.top, 12)

            WordGrid(
                coreWords: AACVocabulary.coreWords,
                roomWords: roomWords,
                onTap: { pictogramManager.addWord($0) }
            )
            .padding(.top, 12)
        }
        .background(Color(hex: "#F5F6FA"))
        .task(id: currentRoom) { await prefetch() }
    }

    private func prefetch() async {
        await pictogramManager.prefetch(words: AACVocabulary.coreWords + roomWords)
    }

    private func speakSentence() {
        let text = pictogramManager.sentence.map(\.label).joined(separator: " ")
        guard !text.isEmpty else { return }
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.5
        AVSpeechSynthesizer().speak(utterance)
    }
}

#Preview("Kitchen") {
    BoardView(currentRoom: "kitchen")
        .previewAllEnvironments()
}

#Preview("Bathroom") {
    BoardView(currentRoom: "bathroom")
        .previewAllEnvironments()
}

#Preview("Empty room") {
    BoardView(currentRoom: "unknown")
        .previewAllEnvironments()
}
