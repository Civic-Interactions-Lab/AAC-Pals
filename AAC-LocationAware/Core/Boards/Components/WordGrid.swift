import SwiftUI

struct WordGrid: View {
    static let shadowRoom: CGFloat = 4

    let words: [Word]
    let columns: Int
    let rowHeight: CGFloat
    var labelSize: CGFloat = 36
    var spacing: CGFloat = 12
    let onTap: (Word) -> Void

    private var rows: [[Word]] {
        stride(from: 0, to: words.count, by: columns).map {
            Array(words[$0..<min($0 + columns, words.count)])
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: spacing) {
                ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                    HStack(spacing: spacing) {
                        ForEach(row) { word in
                            WordTile(word: word, labelSize: labelSize) {
                                onTap(word)
                            }
                        }
                        ForEach(row.count..<columns, id: \.self) { _ in
                            Color.clear
                        }
                    }
                    .frame(height: rowHeight)
                }
            }
            .scrollTargetLayout()
            .padding(.bottom, Self.shadowRoom)
        }
        .scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByOne))
        .scrollBounceBehavior(.basedOnSize)
    }
}

#Preview {
    WordGrid(words: AACVocabulary.defaultBoardWords, columns: 4, rowHeight: 169, onTap: { _ in })
        .frame(height: 169 * 3 + 24 + WordGrid.shadowRoom)
        .padding()
        .background(Color.paper)
        .environment(PictogramManager(service: MockPictogramService()))
}
