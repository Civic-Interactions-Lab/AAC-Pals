import SwiftUI

struct WordGrid: View {
    let words: [Word]
    let tileSize: CGFloat
    let columns: Int
    let spacing: CGFloat
    let onTap: (Word) -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(
                columns: Array(repeating: GridItem(.fixed(tileSize), spacing: spacing), count: columns),
                alignment: .leading,
                spacing: spacing
            ) {
                ForEach(words) { word in
                    WordTile(word: word, labelSize: min(44, max(18, tileSize * 0.12))) {
                        onTap(word)
                    }
                    .frame(width: tileSize, height: tileSize)
                }
            }
            .padding(.bottom, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

#Preview {
    WordGrid(words: AACVocabulary.defaultBoardWords, tileSize: 200, columns: 4, spacing: 12, onTap: { _ in })
        .padding()
        .background(Color.paper)
        .environment(PictogramManager(service: MockPictogramService()))
}
