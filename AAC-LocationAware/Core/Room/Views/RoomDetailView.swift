import SwiftUI

struct RoomDetailView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(AdminManager.self) private var adminManager
    @Environment(\.dismiss) private var dismiss

    let room: Room

    @State private var showAddWord = false
    @State private var editWord: RoomWord? = nil
    @State private var deleteWord: RoomWord? = nil

    private var words: [RoomWord] {
        adminManager.words(for: room.id).sorted { $0.position < $1.position }
    }

    var body: some View {
        ZStack {
            DecorativeBackground()

            VStack(spacing: 0) {
                header

                GeometryReader { geo in
                    let tileSize: CGFloat = {
                        let cols: CGFloat = 8
                        let gap: CGFloat = 10
                        let pad: CGFloat = 16
                        return floor((geo.size.width - pad * 2 - gap * (cols - 1)) / cols)
                    }()
                    ScrollView {
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
                        .padding(.vertical, 12)
                    }
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
        }
        .animation(.easeOut(duration: 0.18), value: showAddWord)
        .animation(.easeOut(duration: 0.18), value: editWord?.id)
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
        .task {
            await adminManager.loadWords(for: room.id)
        }
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
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

            Button {
                showAddWord = true
            } label: {
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

#Preview {
    RoomDetailView(room: Room.mocks[0])
        .previewAllEnvironments()
}
