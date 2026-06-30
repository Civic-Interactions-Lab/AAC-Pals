import SwiftUI
import AVFoundation

struct BoardView: View {
    @State private var sentence: [Word] = []
    @State private var currentRoom: String

    init(currentRoom: String = "kitchen") {
        _currentRoom = State(initialValue: currentRoom)
    }

    private var roomWords: [Word] { AACVocabulary.roomWords[currentRoom] ?? [] }

    var body: some View {
        VStack(spacing: 0) {
            SentenceBar(
                sentence: sentence,
                onSpeak: { speakSentence() },
                onClear: { sentence = [] },
                onRemoveLast: { if !sentence.isEmpty { sentence.removeLast() } },
                onRemoveAt: { sentence.remove(at: $0) }
            )
            .padding(.top, 12)

            WordGrid(
                coreWords: AACVocabulary.coreWords,
                roomWords: roomWords,
                onTap: { sentence.append($0) }
            )
            .padding(.top, 12)
        }
        .background(Color(hex: "#F5F6FA"))
        .task(id: currentRoom) { await prefetch() }
    }

    private func prefetch() async {
        let allWords = AACVocabulary.coreWords + roomWords
        await withTaskGroup(of: Void.self) { group in
            for word in allWords {
                group.addTask {
                    if let url = await fetchPictogramURL(label: word.label, arasaacId: word.arasaacId) {
                        _ = await ImageCache.shared.load(url)
                    }
                }
            }
        }
    }

    private func speakSentence() {
        let text = sentence.map(\.label).joined(separator: " ")
        guard !text.isEmpty else { return }
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.5
        AVSpeechSynthesizer().speak(utterance)
    }
}

#Preview("Kitchen") {
    BoardView(currentRoom: "kitchen")
}

#Preview("Bathroom") {
    BoardView(currentRoom: "bathroom")
}

#Preview("Empty room") {
    BoardView(currentRoom: "unknown")
}
