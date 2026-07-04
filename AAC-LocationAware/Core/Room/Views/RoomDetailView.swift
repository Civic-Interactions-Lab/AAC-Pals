import SwiftUI

struct RoomDetailView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(AdminManager.self) private var adminManager
    @Environment(\.dismiss) private var dismiss

    let room: Room

    @State private var showAddWord = false
    @State private var editWord: RoomWord? = nil
    @State private var deleteWord: RoomWord? = nil
    @State private var showBeaconScanner = false
    @State private var editBeacon: AppBeacon? = nil
    @State private var deleteBeacon: AppBeacon? = nil

    private var words: [RoomWord] {
        adminManager.words(for: room.id).sorted { $0.position < $1.position }
    }

    private var beacons: [AppBeacon] {
        adminManager.beacons(for: room.id)
    }

    var body: some View {
        ZStack {
            DecorativeBackground()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        beaconSection
                        wordGrid
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }

            if showAddWord {
                AddEditWordModal(mode: .add, word: nil, roomId: room.id, isPresented: $showAddWord)
                    .transition(.opacity)
            }

            if let word = editWord {
                AddEditWordModal(
                    mode: .edit,
                    word: word,
                    roomId: room.id,
                    isPresented: Binding(get: { editWord != nil }, set: { if !$0 { editWord = nil } })
                )
                .transition(.opacity)
            }

            if showBeaconScanner {
                BeaconScannerModal(room: room, isPresented: $showBeaconScanner)
                    .transition(.opacity)
            }

            if let beacon = editBeacon {
                EditBeaconModal(
                    beacon: beacon,
                    roomId: room.id,
                    isPresented: Binding(get: { editBeacon != nil }, set: { if !$0 { editBeacon = nil } })
                )
                .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.18), value: showAddWord)
        .animation(.easeOut(duration: 0.18), value: editWord?.id)
        .animation(.easeOut(duration: 0.18), value: showBeaconScanner)
        .animation(.easeOut(duration: 0.18), value: editBeacon?.id)
        .confirmationDialog(
            "Delete \"\(deleteWord?.label ?? "word")\"?",
            isPresented: Binding(get: { deleteWord != nil }, set: { if !$0 { deleteWord = nil } }),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let id = deleteWord?.id {
                    Task { await adminManager.deleteWord(id: id, roomId: room.id) }
                }
                deleteWord = nil
            }
            Button("Cancel", role: .cancel) { deleteWord = nil }
        }
        .confirmationDialog(
            "Remove beacon?",
            isPresented: Binding(get: { deleteBeacon != nil }, set: { if !$0 { deleteBeacon = nil } }),
            titleVisibility: .visible
        ) {
            Button("Remove", role: .destructive) {
                if let b = deleteBeacon {
                    Task { await adminManager.deleteBeacon(id: b.id, roomId: room.id) }
                }
                deleteBeacon = nil
            }
            Button("Cancel", role: .cancel) { deleteBeacon = nil }
        }
        .task {
            await adminManager.loadWords(for: room.id)
            await adminManager.loadBeacons(for: room.id)
        }
    }

    // MARK: - Beacon section

    private var beaconSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Beacons", systemImage: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "#1A1A2E"))

                Spacer()

                Button {
                    showBeaconScanner = true
                } label: {
                    Label("Add Beacon", systemImage: "plus")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Color(hex: "#FF9F43"))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 20)

            if beacons.isEmpty {
                Text("No beacons linked to this room yet.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#9CA3AF"))
                    .padding(.horizontal, 20)
            } else {
                VStack(spacing: 8) {
                    ForEach(beacons) { beacon in
                        BeaconRow(beacon: beacon) {
                            editBeacon = beacon
                        } onDelete: {
                            deleteBeacon = beacon
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Word grid

    private var wordGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Words", systemImage: "text.bubble")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "#1A1A2E"))
                Spacer()
            }
            .padding(.horizontal, 20)

            GeometryReader { geo in
                let tileSize: CGFloat = {
                    let cols: CGFloat = 8
                    let gap: CGFloat = 10
                    let pad: CGFloat = 16
                    return floor((geo.size.width - pad * 2 - gap * (cols - 1)) / cols)
                }()
                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(tileSize), spacing: 10), count: 8),
                    spacing: 10
                ) {
                    ForEach(words) { word in
                        PictogramTile(
                            word: Word(label: word.label),
                            tileSize: tileSize,
                            onTap: {}
                        )
                        .contextMenu {
                            Button { editWord = word } label: { Label("Edit", systemImage: "pencil") }
                            Button(role: .destructive) { deleteWord = word } label: { Label("Delete", systemImage: "trash") }
                        }
                    }
                    AddWordCard(onTap: { showAddWord = true })
                }
                .padding(.horizontal, 16)
            }
            .frame(minHeight: 300)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(hex: "#FF9F43"))
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.9))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
            }

            Spacer()

            VStack(spacing: 2) {
                Text(room.label)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "#1A1A2E"))
                Text("\(words.count) word\(words.count == 1 ? "" : "s")")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#9CA3AF"))
            }

            Spacer()

            Button { showAddWord = true } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(hex: "#FF9F43"))
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.9))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

#Preview("No beacons") {
    RoomDetailView(room: Room.mocks[0])
        .previewAllEnvironments()
}

#Preview("With beacons") {
    let room = Room.mocks[0]
    let service = MockAdminService(beacons: [
        room.id: AppBeacon.mocks(for: room.id) + [
            AppBeacon(id: "b2", adminId: "admin-1", roomId: room.id, beaconUuid: "Kitchen-BLE", label: "Doorway Sensor", radius: 15)
        ]
    ])
    RoomDetailView(room: room)
        .previewAllEnvironments(adminService: service)
}
