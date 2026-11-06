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
    let room: Room
    let words: [Word]
    let columns: Int
    let rowHeight: CGFloat
    let labelSize: CGFloat
    let onTap: (Word) -> Void

    var body: some View {
        BoardCard {
            if words.isEmpty {
                Caption("No words for this room yet.", size: 14)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                WordGrid(words: words, columns: columns, rowHeight: rowHeight, labelSize: labelSize, onTap: onTap)
                    .accessibilityLabel("\(room.label) words")
            }
        }
    }
}

#Preview {
    HStack {
        RoomPanel(room: Room.mocks[0], words: AACVocabulary.roomWords["kitchen"] ?? [], columns: 2, rowHeight: 165, labelSize: 36, onTap: { _ in })
        RoomPanel(room: Room.mocks[1], words: [], columns: 2, rowHeight: 165, labelSize: 36, onTap: { _ in })
    }
    .frame(width: 760, height: 600)
    .padding()
    .background(Color.paper)
    .environment(PictogramManager(service: MockPictogramService()))
}
