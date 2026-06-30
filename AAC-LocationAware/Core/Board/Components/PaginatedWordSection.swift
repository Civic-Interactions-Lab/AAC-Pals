import SwiftUI

struct PaginatedWordSection: View {
    let words: [Word]
    let tileSize: CGFloat
    let columns: Int
    let rowsPerPage: Int
    let onTap: (Word) -> Void

    @State private var page = 0

    private var wordsPerPage: Int { columns * rowsPerPage }
    private var totalPages: Int { max(1, Int(ceil(Double(words.count) / Double(wordsPerPage)))) }
    private var currentWords: [Word] {
        let start = page * wordsPerPage
        let end = min(start + wordsPerPage, words.count)
        return start < words.count ? Array(words[start..<end]) : []
    }

    var body: some View {
        VStack(spacing: 0) {
            if currentWords.isEmpty {
                emptyState
            } else {
                let gridColumns = Array(repeating: GridItem(.fixed(tileSize), spacing: 8), count: columns)
                LazyVGrid(columns: gridColumns, spacing: 8) {
                    ForEach(currentWords) { word in
                        PictogramTile(word: word, tileSize: tileSize, onTap: { onTap(word) })
                    }
                }
                .padding(10)
            }

            if totalPages > 1 {
                paginationRow
            }
        }
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#E3E6EF"), lineWidth: 1)
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 1)
        .onChange(of: words) { _, _ in page = 0 }
    }

    private var emptyState: some View {
        Text("No words available.")
            .font(.system(size: 13))
            .foregroundColor(Color(hex: "#6a7084"))
            .frame(maxWidth: .infinity, minHeight: 92)
            .background(Color(hex: "#fafbff"))
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "#e2e4eb"), lineWidth: 1))
            .padding(10)
    }

    private var paginationRow: some View {
        HStack {
            Button(action: { if page > 0 { page -= 1 } }) {
                Text("‹")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(page == 0 ? Color(hex: "#CCCCCC") : .white)
                    .frame(width: 44, height: 44)
                    .background(page == 0 ? Color(hex: "#E5E5E5") : Color.accentColor)
                    .cornerRadius(22)
            }
            .disabled(page == 0)

            Spacer()

            Button(action: { if page < totalPages - 1 { page += 1 } }) {
                Text("›")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(page == totalPages - 1 ? Color(hex: "#CCCCCC") : .white)
                    .frame(width: 44, height: 44)
                    .background(page == totalPages - 1 ? Color(hex: "#E5E5E5") : Color.accentColor)
                    .cornerRadius(22)
            }
            .disabled(page == totalPages - 1)
        }
        .padding(.horizontal, 15)
        .padding(.bottom, 10)
        .padding(.top, 8)
    }
}

#Preview("Core words — single page") {
    PaginatedWordSection(
        words: AACVocabulary.coreWords,
        tileSize: 100,
        columns: 5,
        rowsPerPage: 4,
        onTap: { _ in }
    )
    .padding()
    .background(Color(hex: "#F5F6FA"))
        .previewAllEnvironments()
}

#Preview("Room words — paginated") {
    PaginatedWordSection(
        words: AACVocabulary.roomWords["kitchen"] ?? [],
        tileSize: 100,
        columns: 4,
        rowsPerPage: 3,
        onTap: { _ in }
    )
    .padding()
    .background(Color(hex: "#F5F6FA"))
        .previewAllEnvironments()
}

#Preview("Empty state") {
    PaginatedWordSection(
        words: [],
        tileSize: 100,
        columns: 4,
        rowsPerPage: 4,
        onTap: { _ in }
    )
    .padding()
    .background(Color(hex: "#F5F6FA"))
        .previewAllEnvironments()
}
