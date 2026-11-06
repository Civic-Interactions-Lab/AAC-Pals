import SwiftUI

struct WordsTab: View {
    @Environment(BoardWordsManager.self) private var boardWordsManager
    @Environment(PictogramManager.self) private var pictogramManager

    let kidName: String

    @AppStorage(kBoardGridSizeKey) private var gridSize: BoardGridSize = .standard
    @State private var newWord = ""
    @State private var confirmDeleteMyDefault = false

    private var setup: BoardSetup { boardWordsManager.setup }

    private var note: String {
        var text = "\(kidName)'s board · \(setup.labels.count) words"
        if setup.preset == .myDefault {
            text += " · My default. Adding or removing words updates your default"
        } else if let preset = setup.preset {
            text += boardWordsManager.isUnchanged ? " · \(preset.title) set" : " · based on \(preset.title), customised"
        } else {
            text += " · custom"
        }
        return text + ". Category sets the tile colour. Stop-words always take red."
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                GridSizePicker(selection: $gridSize)
                Spacer(minLength: 12)
                StickerTextField(placeholder: "Type a word", text: $newWord, capitalization: .sentences, onSubmit: addWord)
                    .frame(width: 200)
                PillButton(title: "+ ADD WORD", fill: .actionBlue, foreground: .white, size: 12, radius: 14, action: addWord)
            }

            StarterSetPicker(
                current: setup.preset,
                myDefaultCount: boardWordsManager.myDefault?.count,
                onPick: usePreset,
                onMakeMyDefault: { Task { await boardWordsManager.makeMyDefault() } },
                onDeleteMyDefault: { confirmDeleteMyDefault = true }
            )
                .padding(.top, 11)

            CategoryLegend()
                .padding(.top, 11)

            Caption(note)
                .padding(.top, 9)

            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 6), spacing: 10) {
                    ForEach(Array(boardWordsManager.words.enumerated()), id: \.element.id) { index, word in
                        EditorWordTile(word: word, position: index + 1) {
                            Task { await boardWordsManager.removeWord(at: index) }
                        }
                        .frame(height: 150)
                    }
                }
                .padding(2)
            }
            .scrollBounceBehavior(.basedOnSize)
            .padding(.top, 11)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .confirmationDialog("Delete My default?", isPresented: $confirmDeleteMyDefault, titleVisibility: .visible) {
            Button("Delete My default", role: .destructive) {
                Task { await boardWordsManager.deleteMyDefault() }
            }
        } message: {
            Text("Your own set is removed. Boards already using it keep their words.")
        }
    }

    private func usePreset(_ preset: BoardPreset) {
        Task {
            await boardWordsManager.usePreset(preset)
            await pictogramManager.prefetch(words: boardWordsManager.words)
        }
    }

    private func addWord() {
        let label = newWord
        newWord = ""
        Task { await boardWordsManager.addWord(label) }
    }
}

#Preview {
    WordsTab(kidName: "Alex")
        .background(Color.paper)
        .environment(PictogramManager(service: MockPictogramService()))
        .environment(BoardWordsManager(service: MockBoardWordsService()))
}
