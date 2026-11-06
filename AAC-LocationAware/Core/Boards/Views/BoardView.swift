import SwiftUI

struct BoardView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(AdminManager.self) private var adminManager
    @Environment(BeaconManager.self) private var beaconManager
    @Environment(PictogramManager.self) private var pictogramManager
    @Environment(UserManager.self) private var userManager
    @Environment(BoardWordsManager.self) private var boardWordsManager
    @Environment(InteractionManager.self) private var interactionManager

    @AppStorage(kBoardGridSizeKey) private var gridSize: BoardGridSize = .standard
    @AppStorage(VoiceSettings.speakEachTapKey) private var speakEachTap = VoiceSettings.defaultSpeakEachTap
    @State private var settingsTab: SettingsTab?
    @State private var roomWords: [Word] = []

    private var words: [Word] { boardWordsManager.words }

    private var boardProfileId: String? {
        userManager.activeProfile?.id ?? userManager.profiles.first?.id
    }

    private var currentRoom: Room? {
        adminManager.rooms.first { $0.id == beaconManager.currentRoomId }
    }

    private var kidName: String {
        userManager.activeProfile?.displayName ?? userManager.profiles.first?.displayName ?? "Profile"
    }

    private var avatarColor: Color {
        let index = userManager.profiles.firstIndex { $0.id == userManager.activeProfile?.id } ?? 0
        return AvatarPalette.color(for: index)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                BoardHeader(
                    kidName: kidName,
                    avatarColor: avatarColor,
                    room: currentRoom,
                    onProfiles: { settingsTab = .profiles },
                    onSettings: { settingsTab = .words }
                )

                SentenceStrip(
                    sentence: pictogramManager.sentence,
                    onSpeak: speakSentence,
                    onDeleteLast: pictogramManager.removeLast,
                    onClear: pictogramManager.clearSentence
                )

                BoardContent(
                    words: words,
                    room: currentRoom,
                    roomWords: roomWords,
                    gridSize: gridSize,
                    onTap: select
                )
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
            }
            .background(Color.paper)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $settingsTab) { tab in
                SettingsView(initialTab: tab)
            }
        }
        .onAppear { Task { await startRoomDetection() } }
        .task { await loadProfiles() }
        .task(id: boardProfileId) {
            guard let boardProfileId else { return }
            await boardWordsManager.load(profileId: boardProfileId)
            await pictogramManager.prefetch(words: words)
        }
        .task(id: beaconManager.currentRoomId) { await loadRoomWords() }
    }

    private func startRoomDetection() async {
        let adminId = authManager.currentUser?.id ?? ""
        await adminManager.loadRooms(adminId: adminId)
        beaconManager.loadBeacons(await adminManager.loadAllBeacons(adminId: adminId))
        beaconManager.startScanning()
    }

    private func loadProfiles() async {
        guard userManager.profiles.isEmpty, let adminId = authManager.currentUser?.id else { return }
        await userManager.loadProfiles(adminId: adminId)
    }

    private func loadRoomWords() async {
        let roomId = beaconManager.currentRoomId
        guard roomId != kCommonRoomId else {
            roomWords = []
            return
        }
        await adminManager.loadWords(for: roomId)
        roomWords = adminManager.words(for: roomId)
            .sorted { $0.position < $1.position }
            .map { Word(label: $0.label) }
        await pictogramManager.prefetch(words: roomWords)
    }

    private func select(_ word: Word) {
        pictogramManager.addWord(word)
        logTap(word)
        if speakEachTap { SpeechManager.shared.speak(word.label) }
    }

    private func logTap(_ word: Word) {
        guard let adminId = authManager.currentUser?.id,
              let user = userManager.activeProfile ?? userManager.profiles.first
        else { return }
        interactionManager.logWord(
            word,
            user: user,
            adminId: adminId,
            room: currentRoom,
            beacon: beaconManager.currentBeacon,
            section: roomWords.contains { $0.id == word.id } ? .room : .main
        )
    }

    private func speakSentence() {
        SpeechManager.shared.speak(pictogramManager.sentence.map(\.label).joined(separator: " "))
    }
}

#Preview {
    BoardView().previewAllEnvironments(withProfile: true, preloadRooms: true)
}
