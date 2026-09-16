import SwiftUI

struct RoomPanel: View {
    static let horizontalInset: CGFloat = 12

    let room: Room
    let words: [Word]
    let tileSize: CGFloat
    let columns: Int
    let spacing: CGFloat
    let onTap: (Word) -> Void
    let onHide: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(spacing: 8) {
                Text("\(room.label.uppercased()) WORDS")
                    .font(.system(size: 11, weight: .heavy))
                    .tracking(1)
                    .foregroundStyle(Color.ink.opacity(0.86))
                    .lineLimit(1)

                Spacer(minLength: 8)

                Button(action: onHide) {
                    Text("HIDE ‹")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(Color.ink)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.paper, in: Capsule())
                        .overlay(Capsule().strokeBorder(Color.ink, lineWidth: 2))
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Hide \(room.label) words")
            }

            if words.isEmpty {
                Text("No words for this room yet.")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.ink.opacity(0.7))
                Spacer()
            } else {
                WordGrid(words: words, tileSize: tileSize, columns: columns, spacing: spacing, onTap: onTap)
            }
        }
        .padding(.horizontal, Self.horizontalInset)
        .padding(.vertical, 13)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.butter, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.ink, lineWidth: 2))
    }
}

#Preview {
    RoomPanel(room: Room.mocks[0], words: AACVocabulary.defaultBoardWords, tileSize: 180, columns: 2, spacing: 12, onTap: { _ in }, onHide: {})
        .frame(width: 420, height: 700)
        .padding()
        .environment(PictogramManager(service: MockPictogramService()))
}
