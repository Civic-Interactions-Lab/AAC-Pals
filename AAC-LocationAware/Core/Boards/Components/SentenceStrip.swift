import SwiftUI

struct SentenceStrip: View {
    let sentence: [Word]
    let onSpeak: () -> Void
    let onDeleteLast: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            ViewThatFits(in: .horizontal) {
                words
                ScrollView(.horizontal, showsIndicators: false) { words }
                    .defaultScrollAnchor(.trailing)
            }

            iconButton("delete.left.fill", foreground: .ink, background: .paper, action: onDeleteLast)
            iconButton("play.fill", foreground: .white, background: .actionBlue, action: onSpeak)
        }
        .padding(.leading, 14)
        .padding(.trailing, 12)
        .padding(.vertical, 8)
        .background(Color.paper, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.ink, lineWidth: 2))
    }

    private var words: some View {
        HStack(spacing: 10) {
            ForEach(sentence) { word in
                Text(word.label)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ink)
                    .fixedSize()
            }
        }
    }

    private func iconButton(_ systemName: String, foreground: Color, background: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(foreground)
                .frame(width: 44, height: 40)
                .background(background, in: RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.ink, lineWidth: 2))
        }
        .buttonStyle(.plain)
        .disabled(sentence.isEmpty)
        .opacity(sentence.isEmpty ? 0.5 : 1)
    }
}

#Preview {
    SentenceStrip(sentence: Array(AACVocabulary.defaultBoardWords.prefix(2)), onSpeak: {}, onDeleteLast: {})
        .padding()
        .background(Color.butter)
}
