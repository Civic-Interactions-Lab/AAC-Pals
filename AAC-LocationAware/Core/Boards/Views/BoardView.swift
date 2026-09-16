import SwiftUI

struct BoardView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(AdminManager.self) private var adminManager
    @Environment(BeaconManager.self) private var beaconManager
    @Environment(PictogramManager.self) private var pictogramManager

    @AppStorage(kBoardGridSizeKey) private var gridSize: BoardGridSize = .medium
    @State private var showSettings = false
    @State private var isPanelOpen = false
    @State private var roomWords: [Word] = []

    private let kidName = "Katerina"
    private let words = AACVocabulary.defaultBoardWords

    private var currentRoom: Room? {
        adminManager.rooms.first { $0.id == beaconManager.currentRoomId }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                BoardHeader(
                    kidName: kidName,
                    room: currentRoom,
                    roomWordCount: roomWords.count,
                    isPanelOpen: isPanelOpen,
                    sentence: pictogramManager.sentence,
                    onOpenPanel: { setPanel(open: true) },
                    onSpeak: speakSentence,
                    onDeleteLast: pictogramManager.removeLast,
                    onSettings: { showSettings = true }
                )

                BoardContent(
                    words: words,
                    room: isPanelOpen ? currentRoom : nil,
                    roomWords: roomWords,
                    gridSize: gridSize,
                    onTap: select,
                    onHidePanel: { setPanel(open: false) }
                )
                .padding(.horizontal, 22)
                .padding(.vertical, 18)
            }
            .background(Color.paper)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showSettings) { SettingsView() }
        }
        .onAppear { Task { await startRoomDetection() } }
        .task { await pictogramManager.prefetch(words: words) }
        .task(id: beaconManager.currentRoomId) { await loadRoomWords() }
        .onChange(of: beaconManager.currentRoomId) { setPanel(open: currentRoom != nil) }
    }

    private func startRoomDetection() async {
        let adminId = authManager.currentUser?.id ?? ""
        await adminManager.loadRooms(adminId: adminId)
        beaconManager.loadBeacons(await adminManager.loadAllBeacons(adminId: adminId))
        beaconManager.startScanning()
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

    private func setPanel(open: Bool) {
        withAnimation(.easeInOut(duration: 0.25)) { isPanelOpen = open }
    }

    private func select(_ word: Word) {
        pictogramManager.addWord(word)
        SpeechManager.shared.speak(word.label)
    }

    private func speakSentence() {
        SpeechManager.shared.speak(pictogramManager.sentence.map(\.label).joined(separator: " "))
    }
}

#Preview {
    BoardView().previewAllEnvironments()
}
