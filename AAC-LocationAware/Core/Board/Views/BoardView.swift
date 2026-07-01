import SwiftUI
import AVFoundation

struct BoardView: View {
    @Environment(PictogramManager.self) private var pictogramManager
    @Environment(UserManager.self) private var userManager
    @State private var currentRoom: String

    init(currentRoom: String = "kitchen") {
        _currentRoom = State(initialValue: currentRoom)
    }

    private var roomWords: [Word] { AACVocabulary.roomWords[currentRoom] ?? [] }

    var body: some View {
        ZStack {
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

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button { userManager.exitProfile() } label: {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color(hex: "#FF9F43"))
                            .padding(14)
                            .background(.ultraThinMaterial, in: Circle())
                            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 28)
                    .padding(.bottom, 28)
                }
            }
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
