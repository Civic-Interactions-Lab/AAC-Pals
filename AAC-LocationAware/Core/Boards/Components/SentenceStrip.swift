import SwiftUI

struct SentenceStrip: View {
    let sentence: [Word]
    let onSpeak: () -> Void
    let onDeleteLast: () -> Void
    let onClear: () -> Void

    private let height: CGFloat = 76

    var body: some View {
        HStack(spacing: 12) {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(sentence.enumerated()), id: \.element.id) { index, word in
                            SentenceChip(word: word).id(index)
                        }
                    }
                    .padding(.horizontal, 12)
                    .frame(maxHeight: .infinity)
                }
                .onChange(of: sentence.count) { _, count in
                    withAnimation(.easeOut(duration: 0.2)) { proxy.scrollTo(count - 1, anchor: .trailing) }
                }
            }
            .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
            .sticker(.butter, radius: 18)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .accessibilityElement(children: .combine)
            .accessibilityLabel(sentence.isEmpty ? "Sentence is empty" : sentence.map(\.label).joined(separator: " "))

            HStack(spacing: 10) {
                actionButton("DELETE", systemImage: "delete.left", width: 66, fill: .paper, foreground: .ink, action: onDeleteLast)
                actionButton("CLEAR", systemImage: "xmark", width: 66, fill: .categoryNegation, foreground: .ink, action: onClear)
                actionButton("SPEAK", systemImage: "speaker.wave.2", width: 104, fill: .actionBlue, foreground: .white, shadow: 0.4, action: onSpeak)
            }
            .disabled(sentence.isEmpty)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.paper)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.ink).frame(height: 2)
        }
    }

    private func actionButton(
        _ title: String,
        systemImage: String,
        width: CGFloat,
        fill: Color,
        foreground: Color,
        shadow: Double = 0.28,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: title == "SPEAK" ? 24 : 21, weight: .semibold))
                Text(title)
                    .font(.figtree(title == "SPEAK" ? 11 : 10))
                    .tracking(0.7)
            }
            .foregroundStyle(foreground)
            .frame(width: width, height: height)
            .sticker(fill, radius: 18)
            .contentShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(StickerPressStyle(shadowOpacity: shadow))
        .accessibilityLabel(title.capitalized)
    }
}

private struct SentenceChip: View {
    let word: Word

    var body: some View {
        HStack(spacing: 8) {
            PictogramImage(word: word, fallbackSize: 36)
                .frame(width: 44, height: 44)

            Text(word.label)
                .font(.fredoka(26))
                .foregroundStyle(Color.ink)
                .fixedSize()
        }
        .padding(.leading, 6)
        .padding(.trailing, 12)
        .padding(.vertical, 5)
        .sticker(fitzgeraldColor(for: word.label), radius: 14)
    }
}

#Preview {
    SentenceStrip(sentence: Array(AACVocabulary.defaultBoardWords.prefix(4)), onSpeak: {}, onDeleteLast: {}, onClear: {})
        .environment(PictogramManager(service: MockPictogramService()))
}
