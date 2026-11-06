import SwiftUI

struct WordTile: View {
    let word: Word
    var labelSize: CGFloat = 36
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                PictogramImage(word: word)
                    .padding(9)

                Text(word.label)
                    .font(.fredoka(labelSize, .medium))
                    .foregroundStyle(Color.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 12)
            }
            .sticker(fitzgeraldColor(for: word.label), radius: 16)
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(StickerPressStyle())
        .accessibilityLabel(word.label)
    }
}

#Preview {
    WordTile(word: AACVocabulary.defaultBoardWords[2], onTap: {})
        .frame(width: 177, height: 169)
        .padding()
        .environment(PictogramManager(service: MockPictogramService()))
}
