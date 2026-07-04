import SwiftUI
import AVFoundation

let kActiveUserIdKey = "activeUserId"

struct BoardView: View {
    @Environment(PictogramManager.self) private var pictogramManager
    @Environment(UserManager.self) private var userManager
    @Environment(BeaconManager.self) private var beaconManager
    @Environment(AdminManager.self) private var adminManager
    @Environment(InteractionManager.self) private var interactionManager

    @State private var manualRoomId: String? = nil
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var showPasscodeExit = false

    private var currentRoom: String { manualRoomId ?? beaconManager.currentRoomId }
    private var currentRoomName: String {
        adminManager.rooms.first { $0.id == currentRoom }?.label ?? "General"
    }
    private var roomWords: [Word] {
        adminManager.words(for: currentRoom).sorted { $0.position < $1.position }.map { Word(label: $0.label) }
    }

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
                        speakWord(word.label)
                        if let user = userManager.activeProfile,
                           let adminId = userManager.activeAdminId {
                            interactionManager.logWord(word, userId: user.id, adminId: adminId, roomId: currentRoom)
                        }
                    },
                    roomName: currentRoomName,
                    rooms: adminManager.rooms,
                    selectedRoomId: currentRoom,
                    beaconRoomId: beaconManager.currentRoomId,
                    onRoomSelect: { manualRoomId = $0 }
                )
                .padding(.top, 12)
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button { showPasscodeExit = true } label: {
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

            if showPasscodeExit, let profile = userManager.activeProfile {
                PasscodeModal(
                    correctPasscode: profile.passcode,
                    message: "Enter passcode to leave the board",
                    onSuccess: {
                        showPasscodeExit = false
                        UserDefaults.standard.removeObject(forKey: kActiveUserIdKey)
                        userManager.exitProfile()
                    },
                    onCancel: { showPasscodeExit = false }
                )
                .transition(.opacity)
                .animation(.easeOut(duration: 0.15), value: showPasscodeExit)
            }
        }
        .background(Color(hex: "#F5F6FA"))
        .task { warmUpSynthesizer(); await startBeaconScanning() }
        .task(id: currentRoom) {
            if currentRoom != kCommonRoomId {
                await adminManager.loadWords(for: currentRoom)
            }
            await prefetch()
        }
        .onAppear {
            if let userId = userManager.activeProfile?.id {
                UserDefaults.standard.set(userId, forKey: kActiveUserIdKey)
            }
        }
        .onDisappear {
            beaconManager.stopScanning()
            pictogramManager.clearSentence()
        }
        .onChange(of: beaconManager.currentRoomId) { manualRoomId = nil }
    }

    private func startBeaconScanning() async {
        if let adminId = userManager.activeAdminId {
            await adminManager.loadRooms(adminId: adminId)
            let beacons = await adminManager.loadAllBeacons(adminId: adminId)
            beaconManager.loadBeacons(beacons)
        }
        beaconManager.startScanning()
    }

    private func prefetch() async {
        await pictogramManager.prefetch(words: AACVocabulary.coreWords + roomWords)
    }

    private func warmUpSynthesizer() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .duckOthers)
        try? AVAudioSession.sharedInstance().setActive(true)
        let utterance = AVSpeechUtterance(string: " ")
        utterance.volume = 0
        synthesizer.speak(utterance)
    }

    private func speakWord(_ label: String) {
        if synthesizer.isSpeaking { synthesizer.stopSpeaking(at: .immediate) }
        let utterance = AVSpeechUtterance(string: label)
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }

    private func speakSentence() {
        let text = pictogramManager.sentence.map(\.label).joined(separator: " ")
        guard !text.isEmpty else { return }
        if synthesizer.isSpeaking { synthesizer.stopSpeaking(at: .immediate) }
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
}

#Preview("Kitchen (beacon detected)") {
    let beacon = MockBeaconService(simulatedBeacon: DetectedBeacon(uuid: nil, name: "Kitchen", major: nil, minor: nil, rssi: -58))
    BoardView()
        .previewAllEnvironments(withProfile: true)
        .environment(BeaconManager(service: beacon))
}

#Preview("Common (no beacon)") {
    let beacon = MockBeaconService(simulatedBeacon: nil)
    BoardView()
        .previewAllEnvironments(withProfile: true)
        .environment(BeaconManager(service: beacon))
}
