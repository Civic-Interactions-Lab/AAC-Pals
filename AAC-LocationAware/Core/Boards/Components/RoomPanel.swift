import SwiftUI

struct BoardCard<Content: View>: View {
    static var inset: CGFloat { 12 }

    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(Self.inset)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .sticker(.butter, radius: 20)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct RoomPanel: View {
    let room: Room?
    let words: [Word]
    let columns: Int
    let rowHeight: CGFloat
    let labelSize: CGFloat
    let onTap: (Word) -> Void

    var body: some View {
        BoardCard {
            if let room, !words.isEmpty {
                WordGrid(words: words, columns: columns, rowHeight: rowHeight, labelSize: labelSize, onTap: onTap)
                    .accessibilityLabel("\(room.label) words")
            } else if room != nil {
                Caption("No words for this room yet.", size: 14)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                emptyState
            }
        }
    }

    private var emptyState: some View {
        Image(systemName: "wifi.slash")
            .font(.system(size: 34, weight: .medium))
            .foregroundStyle(Color.ink.opacity(0.35))
            .frame(width: 92, height: 92)
            .dashedOutline(radius: 26)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityLabel("No room nearby")
    }
}

#Preview {
    HStack {
        RoomPanel(room: Room.mocks[0], words: AACVocabulary.roomWords["kitchen"] ?? [], columns: 2, rowHeight: 165, labelSize: 36, onTap: { _ in })
        RoomPanel(room: nil, words: [], columns: 2, rowHeight: 165, labelSize: 36, onTap: { _ in })
    }
    .frame(width: 760, height: 600)
    .padding()
    .background(Color.paper)
    .environment(PictogramManager(service: MockPictogramService()))
}
