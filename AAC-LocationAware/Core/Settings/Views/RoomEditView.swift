import SwiftUI

struct RoomEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager
    @Environment(AdminManager.self) private var adminManager
    @Environment(BeaconManager.self) private var beaconManager

    let room: Room

    @State private var name = ""
    @State private var beaconId = ""
    @State private var newWord = ""
    @State private var confirmDelete = false
    @State private var beaconLoaded = false

    private var adminId: String { authManager.currentUser?.id ?? "" }
    private var words: [RoomWord] { adminManager.words(for: room.id).sorted { $0.position < $1.position } }
    private var pairedBeacon: AppBeacon? { adminManager.beacons(for: room.id).first }
    private var title: String { name.trimmingCharacters(in: .whitespaces).isEmpty ? room.label : name }

    var body: some View {
        VStack(spacing: 0) {
            SettingsHeader(title: title, onBack: save, onDone: save) {
                PillButton(title: "DELETE ROOM", fill: .categoryNegation) { confirmDelete = true }
            }

            HStack(alignment: .top, spacing: 18) {
                detailsColumn
                wordsCard
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 18)
        }
        .background(Color.paper)
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog("Delete \(room.label)?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete room", role: .destructive, action: deleteRoom)
        } message: {
            Text("Its words and beacon pairing are removed too.")
        }
        .onAppear {
            name = room.label
            beaconManager.startScanning()
        }
        .task {
            await adminManager.loadBeacons(for: room.id)
            beaconId = pairedBeacon?.beaconUuid ?? ""
            beaconLoaded = true
            await adminManager.loadWords(for: room.id)
        }
    }

    private var detailsColumn: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                SectionLabel("Room name")
                StickerTextField(placeholder: "Room name", text: $name, font: .fredoka(22), height: 46, onSubmit: saveName)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .sticker(.paper, radius: 16)

            VStack(alignment: .leading, spacing: 6) {
                SectionLabel("Beacon ID")
                StickerTextField(
                    placeholder: "Kitchen",
                    text: $beaconId,
                    font: .system(size: 16, weight: .heavy, design: .monospaced),
                    height: 42,
                    onSubmit: saveBeacon
                )

                TimelineView(.periodic(from: .now, by: 2)) { _ in
                    let status = beaconStatus
                    HStack(spacing: 9) {
                        Circle()
                            .fill(status.inRange ? Color.signalGreen : Color.categoryNegation)
                            .frame(width: 13, height: 13)
                            .overlay(Circle().strokeBorder(Color.ink, lineWidth: 2))
                        Text(status.text)
                            .font(.figtree(13, .bold))
                            .foregroundStyle(Color.ink.opacity(0.88))
                    }
                    .padding(.top, 4)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .sticker(.paper, radius: 16)

            Caption("These words sit in the left panel while the beacon is heard. The main board never changes.")
        }
        .frame(width: 300)
    }

    private var beaconStatus: (inRange: Bool, text: String) {
        let id = beaconId.trimmingCharacters(in: .whitespaces).lowercased()
        guard !id.isEmpty else { return (false, "No beacon paired") }
        let heard = beaconManager.scannedBeacons.first { beacon in
            [beacon.uuid, beacon.name].compactMap { $0?.lowercased() }.contains(id)
        }
        guard let heard else { return (false, "Not heard right now") }
        return heard.rssi >= DetectionRadius.medium.rssi
            ? (true, "In range now")
            : (false, "Heard, but too far · \(heard.rssi) dBm")
    }

    private var wordsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                SectionLabel("\(title) words · \(words.count)")
                Spacer()
                StickerTextField(placeholder: "Type a word", text: $newWord, height: 38, capitalization: .sentences, onSubmit: addWord)
                    .frame(width: 190)
                PillButton(title: "+ ADD WORD", fill: .actionBlue, foreground: .white, size: 12, radius: 14, action: addWord)
            }

            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5), spacing: 10) {
                    ForEach(words) { roomWord in
                        EditorWordTile(word: Word(label: roomWord.label)) {
                            Task { await adminManager.deleteWord(id: roomWord.id, roomId: room.id) }
                        }
                        .frame(height: 140)
                    }
                }
                .padding(2)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .sticker(.paper, radius: 16)
    }

    private func addWord() {
        let label = newWord.trimmingCharacters(in: .whitespaces)
        guard !label.isEmpty, !words.contains(where: { $0.label.lowercased() == label.lowercased() }) else {
            newWord = ""
            return
        }
        newWord = ""
        Task {
            await adminManager.addWord(label: label, category: fitzgeraldCategory(for: label).name, roomId: room.id, adminId: adminId)
        }
    }

    private func saveName() {
        let label = name.trimmingCharacters(in: .whitespaces)
        guard !label.isEmpty, label != room.label else { return }
        Task { await adminManager.updateRoom(id: room.id, label: label) }
    }

    private func saveBeacon() {
        let id = beaconId.trimmingCharacters(in: .whitespaces)
        guard beaconLoaded, id != (pairedBeacon?.beaconUuid ?? "") else { return }
        let old = pairedBeacon
        let label = name.trimmingCharacters(in: .whitespaces)
        Task {
            if let old { await adminManager.deleteBeacon(id: old.id, roomId: room.id) }
            if !id.isEmpty {
                await adminManager.addBeacon(beaconUuid: id, label: label.isEmpty ? room.label : label, radius: 2.0, roomId: room.id, adminId: adminId)
            }
            beaconManager.loadBeacons(await adminManager.loadAllBeacons(adminId: adminId))
        }
    }

    private func save() {
        saveName()
        saveBeacon()
        dismiss()
    }

    private func deleteRoom() {
        Task {
            await adminManager.deleteRoom(id: room.id)
            beaconManager.loadBeacons(await adminManager.loadAllBeacons(adminId: adminId))
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        RoomEditView(room: Room.mocks[0])
    }
    .previewAllEnvironments(preloadRooms: true)
}
