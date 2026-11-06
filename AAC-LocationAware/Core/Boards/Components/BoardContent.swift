import SwiftUI

struct BoardContent: View {
    let words: [Word]
    let room: Room?
    let roomWords: [Word]
    let gridSize: BoardGridSize
    let onTap: (Word) -> Void

    private let gap: CGFloat = 16
    private let spacing: CGFloat = 12

    var body: some View {
        GeometryReader { proxy in
            let panelColumns = gridSize.panelColumns
            let mainColumns = panelColumns * 2
            let inset = BoardCard<EmptyView>.inset
            let fixed = inset * 4 + gap + spacing * CGFloat(panelColumns - 1 + mainColumns - 1)
            let tileWidth = max((proxy.size.width - fixed) / CGFloat(panelColumns + mainColumns), 1)
            let viewport = max(proxy.size.height - inset * 2 - WordGrid.shadowRoom, 1)
            let idealRowHeight = tileWidth * gridSize.tileAspect
            let visibleRows = max(1, Int(((viewport + spacing) / (idealRowHeight + spacing)).rounded()))
            let rowHeight = (viewport - spacing * CGFloat(visibleRows - 1)) / CGFloat(visibleRows)
            let labelSize = min(44, max(22, min(tileWidth, rowHeight) * 0.2))
            let panelWidth = tileWidth * CGFloat(panelColumns) + spacing * CGFloat(panelColumns - 1) + inset * 2
            let mainWidth = max(proxy.size.width - panelWidth - gap, 0)

            HStack(alignment: .top, spacing: gap) {
                RoomPanel(room: room, words: roomWords, columns: panelColumns, rowHeight: rowHeight, labelSize: labelSize, onTap: onTap)
                    .frame(width: panelWidth)

                BoardCard {
                    WordGrid(words: words, columns: mainColumns, rowHeight: rowHeight, labelSize: labelSize, spacing: spacing, onTap: onTap)
                }
                .frame(width: mainWidth)
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
        }
    }
}

#Preview {
    BoardContent(words: AACVocabulary.defaultBoardWords, room: Room.mocks[0], roomWords: AACVocabulary.roomWords["kitchen"] ?? [], gridSize: .standard, onTap: { _ in })
        .padding()
        .background(Color.paper)
        .environment(PictogramManager(service: MockPictogramService()))
}
