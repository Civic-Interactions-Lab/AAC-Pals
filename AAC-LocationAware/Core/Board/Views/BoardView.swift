import SwiftUI
import AVFoundation

struct BoardView: View {
    @Environment(PictogramManager.self) private var pictogramManager
    @Environment(UserManager.self) private var userManager
    @Environment(BeaconManager.self) private var beaconManager
    @Environment(InteractionManager.self) private var interactionManager

    private var currentRoom: String { beaconManager.currentRoomId }
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
                    onTap: { word in
                        pictogramManager.addWord(word)
                        if let user = userManager.activeProfile,
                           let adminId = userManager.activeAdminId {
                            interactionManager.logWord(word, userId: user.id, adminId: adminId, roomId: currentRoom)
                        }
                    }
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
                            .background(Color.white.opacity(0.9), in: Circle())
                            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 28)
                    .padding(.bottom, 28)
                }
            }
        }
        .background(Color(hex: "#F5F6FA"))
        .task { beaconManager.startScanning() }
        .task(id: currentRoom) { await prefetch() }
        .onDisappear { beaconManager.stopScanning() }
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

#Preview("Kitchen (beacon detected)") {
    let beacon = MockBeaconService(simulatedBeacon: DetectedBeacon(name: "Kitchen", major: nil, minor: nil, rssi: -58))
    BoardView()
        .previewAllEnvironments()
        .environment(BeaconManager(service: beacon))
}

#Preview("Common (no beacon)") {
    let beacon = MockBeaconService(simulatedBeacon: nil)
    BoardView()
        .previewAllEnvironments()
        .environment(BeaconManager(service: beacon))
}
