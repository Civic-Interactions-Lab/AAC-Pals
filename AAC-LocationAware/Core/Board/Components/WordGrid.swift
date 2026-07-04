import SwiftUI

struct WordGrid: View {
    let coreWords: [Word]
    let roomWords: [Word]
    let onTap: (Word) -> Void

    var roomName: String? = nil
    var rooms: [Room] = []
    var selectedRoomId: String = kCommonRoomId
    var beaconRoomId: String = kCommonRoomId
    var onRoomSelect: ((String) -> Void)? = nil

    @State private var showRoomPicker = false

    @State private var gridSize: CGSize = .zero

    private let coreColumns = 6
    private let roomColumns = 2
    private let sectionGap: CGFloat = 12
    private let padding: CGFloat = 12
    private let tileGap: CGFloat = 8
    private let surfacePadding: CGFloat = 10

    private var totalWidth: CGFloat { max(0, gridSize.width - padding * 2 - sectionGap) }
    private var coreFraction: CGFloat { CGFloat(coreColumns) / CGFloat(coreColumns + roomColumns) }

    private var coreTileSize: CGFloat {
        guard gridSize.width > 0 else { return 70 }
        let sectionWidth = totalWidth * coreFraction
        let inner = sectionWidth - surfacePadding * 2 - 2
        let available = inner - tileGap * CGFloat(coreColumns - 1)
        return max(60, floor(available / CGFloat(coreColumns)))
    }

    private var roomTileSize: CGFloat {
        guard gridSize.width > 0 else { return 70 }
        let sectionWidth = totalWidth * (1 - coreFraction)
        let inner = sectionWidth - surfacePadding * 2 - 2
        let available = inner - tileGap * CGFloat(roomColumns - 1)
        return max(60, floor(available / CGFloat(roomColumns)))
    }

    private var tileHeight: CGFloat { max(44, min(84, coreTileSize * 0.62)) + 28 }

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
                    tileSize: coreTileSize,
                    columns: coreColumns,
                    rowsPerPage: rowsPerPage,
                    onTap: onTap
                )
                .frame(width: totalWidth * coreFraction)

                VStack(spacing: 6) {
                    if let roomName {
                        Button(action: { showRoomPicker = true }) {
                            HStack(spacing: 4) {
                                Text(roomName)
                                    .font(.system(size: 13, weight: .semibold))
                                    .lineLimit(1)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .foregroundStyle(Color(hex: "#0d4f4a"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "#0d4f4a").opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        .popover(isPresented: $showRoomPicker, arrowEdge: .top) {
                            RoomPickerPopover(
                                rooms: rooms,
                                selectedRoomId: selectedRoomId,
                                beaconRoomId: beaconRoomId,
                                onSelect: { id in
                                    onRoomSelect?(id)
                                    showRoomPicker = false
                                }
                            )
                        }
                    }

                    PaginatedWordSection(
                        words: filteredRoomWords,
                        tileSize: roomTileSize,
                        columns: roomColumns,
                        rowsPerPage: rowsPerPage,
                        onTap: onTap
                    )
                }
                .frame(width: totalWidth * (1 - coreFraction))
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
        .previewAllEnvironments()
    }
}

#Preview("Kitchen room") { WordGridPreview(roomKey: "kitchen") }
#Preview("Bathroom room") { WordGridPreview(roomKey: "bathroom") }
#Preview("Empty room words") {
    WordGrid(coreWords: AACVocabulary.coreWords, roomWords: [], onTap: { _ in })
        .padding(.top, 12)
        .background(Color(hex: "#F5F6FA"))
        .previewAllEnvironments()
}
