import SwiftUI

/// With the panel closed the board shows `gridSize.columns` per row. With it open,
/// the panel and main grid split those columns and one shared tile size fills the width.
struct BoardContent: View {
    let words: [Word]
    let room: Room?
    let roomWords: [Word]
    let gridSize: BoardGridSize
    let onTap: (Word) -> Void
    let onHidePanel: () -> Void

    private let spacing: CGFloat = 20
    private let gap: CGFloat = 20

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width

            if let room {
                let panelColumns = gridSize.panelColumns
                let mainColumns = gridSize.mainColumnsWithPanel
                let fixed = RoomPanel.horizontalInset * 2 + gap + spacing * CGFloat(panelColumns - 1 + mainColumns - 1)
                let tileSize = (width - fixed) / CGFloat(panelColumns + mainColumns)
                let panelWidth = CGFloat(panelColumns) * tileSize + CGFloat(panelColumns - 1) * spacing + RoomPanel.horizontalInset * 2

                HStack(alignment: .top, spacing: gap) {
                    RoomPanel(
                        room: room,
                        words: roomWords,
                        tileSize: tileSize,
                        columns: panelColumns,
                        spacing: spacing,
                        onTap: onTap,
                        onHide: onHidePanel
                    )
                    .frame(width: panelWidth)
                    .transition(.move(edge: .leading).combined(with: .opacity))

                    WordGrid(words: words, tileSize: tileSize, columns: mainColumns, spacing: spacing, onTap: onTap)
                }
            } else {
                let columns = gridSize.columns
                let tileSize = (width - spacing * CGFloat(columns - 1)) / CGFloat(columns)

                WordGrid(words: words, tileSize: tileSize, columns: columns, spacing: spacing, onTap: onTap)
            }
        }
    }
}
