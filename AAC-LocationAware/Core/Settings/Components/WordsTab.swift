import SwiftUI

struct WordsTab: View {
    let words: [Word]

    @AppStorage(kBoardGridSizeKey) private var gridSize: BoardGridSize = .medium

    private let spacing: CGFloat = 10

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GridSizePicker(selection: $gridSize)

            Text("BOARD WORDS · \(words.count)")
                .font(.system(size: 11, weight: .heavy))
                .tracking(1)
                .foregroundStyle(Color.ink.opacity(0.86))
                .padding(.top, 16)

            CategoryLegend()
                .padding(.top, 11)

            Text("Word type sets the tile colour.")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.ink.opacity(0.86))
                .padding(.top, 9)

            GeometryReader { proxy in
                let columns = gridSize.columns
                let tileSize = (proxy.size.width - spacing * CGFloat(columns - 1)) / CGFloat(columns)

                ScrollView(showsIndicators: false) {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns),
                        spacing: spacing
                    ) {
                        ForEach(Array(words.enumerated()), id: \.element.id) { index, word in
                            EditorWordTile(word: word, position: index + 1)
                                .frame(height: tileSize)
                        }
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
            }
            .padding(.top, 11)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

#Preview {
    WordsTab(words: AACVocabulary.defaultBoardWords)
        .background(Color.paper)
        .environment(PictogramManager(service: MockPictogramService()))
}
