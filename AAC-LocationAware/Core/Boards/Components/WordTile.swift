import SwiftUI

struct WordTile: View {
    let word: Word
    let labelSize: CGFloat
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                PictogramImage(word: word, fallbackSize: labelSize * 2.6)
                    .padding(18)

                Text(word.label)
                    .font(.system(size: labelSize, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)
                    .padding(.vertical, labelSize * 0.25)
                    .background(fitzgeraldColor(for: word.label))
                    .overlay(alignment: .top) {
                        Rectangle().fill(Color.ink).frame(height: 2)
                    }
            }
            .background(Color.paper)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.ink, lineWidth: 2))
        }
        .buttonStyle(StickerPressStyle())
        .accessibilityLabel(word.label)
    }
}

private struct StickerPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .shadow(color: Color.ink.opacity(configuration.isPressed ? 0 : 0.28), radius: 0, y: 2)
            .offset(y: configuration.isPressed ? 2 : 0)
    }
}

#Preview {
    WordTile(word: AACVocabulary.defaultBoardWords[0], labelSize: 32, onTap: {})
        .frame(width: 300, height: 300)
        .padding()
        .environment(PictogramManager(service: MockPictogramService()))
}
