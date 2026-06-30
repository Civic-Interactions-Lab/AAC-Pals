import SwiftUI

struct WordGrid: View {
    let coreWords: [Word]
    let roomWords: [Word]
    let onTap: (Word) -> Void

    @State private var gridSize: CGSize = .zero

    private let columns = 4
    private let sectionGap: CGFloat = 12
    private let padding: CGFloat = 12
    private let tileGap: CGFloat = 8
    private let surfacePadding: CGFloat = 10

    private var tileSize: CGFloat {
        guard gridSize.width > 0 else { return 70 }
        let sectionWidth = (gridSize.width - padding * 2 - sectionGap) / 2
        let inner = sectionWidth - surfacePadding * 2 - 2
        let available = inner - tileGap * CGFloat(columns - 1)
        return max(60, floor(available / CGFloat(columns)))
    }

    private var tileHeight: CGFloat { max(44, min(84, tileSize * 0.62)) + 28 }

    private var rowsPerPage: Int {
        guard gridSize.height > 0 else { return 4 }
        let paginationHeight: CGFloat = 70
        let available = gridSize.height - surfacePadding * 2 - paginationHeight - padding
        let rowHeight = tileHeight + tileGap
        return max(2, Int(floor((available + tileGap) / rowHeight)))
    }

    private var filteredRoomWords: [Word] {
        let coreLabels = Set(coreWords.map { $0.label.lowercased().trimmingCharacters(in: .whitespaces) })
        return roomWords.filter { !coreLabels.contains($0.label.lowercased().trimmingCharacters(in: .whitespaces)) }
    }

    var body: some View {
        GeometryReader { geo in
            HStack(alignment: .top, spacing: sectionGap) {
                PaginatedWordSection(
                    words: coreWords,
                    tileSize: tileSize,
                    columns: columns,
                    rowsPerPage: rowsPerPage,
                    onTap: onTap
                )

                PaginatedWordSection(
                    words: filteredRoomWords,
                    tileSize: tileSize,
                    columns: columns,
                    rowsPerPage: rowsPerPage,
                    onTap: onTap
                )
            }
            .padding(.horizontal, padding)
            .padding(.bottom, padding)
            .onAppear { gridSize = geo.size }
            .onChange(of: geo.size) { _, size in gridSize = size }
        }
    }
}

private struct WordGridPreview: View {
    let roomKey: String
    @State private var lastTapped: String = ""

    var body: some View {
        VStack {
            WordGrid(
                coreWords: AACVocabulary.coreWords,
                roomWords: AACVocabulary.roomWords[roomKey] ?? [],
                onTap: { lastTapped = $0.label }
            )
            .padding(.top, 12)

            if !lastTapped.isEmpty {
                Text("Tapped: \(lastTapped)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
            }
        }
        .background(Color(hex: "#F5F6FA"))
    }
}

#Preview("Kitchen room") {
    WordGridPreview(roomKey: "kitchen")
}

#Preview("Bathroom room") {
    WordGridPreview(roomKey: "bathroom")
}

#Preview("Empty room words") {
    WordGrid(
        coreWords: AACVocabulary.coreWords,
        roomWords: [],
        onTap: { _ in }
    )
    .padding(.top, 12)
    .background(Color(hex: "#F5F6FA"))
}
