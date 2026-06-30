import SwiftUI

struct SentenceBar: View {
    let sentence: [Word]
    let onSpeak: () -> Void
    let onClear: () -> Void
    let onRemoveLast: () -> Void
    let onRemoveAt: (Int) -> Void

    private let buttonSize: CGFloat = 60

    var body: some View {
        HStack(spacing: 8) {
            // Word chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    if sentence.isEmpty {
                        Text("Tap words to build a sentence…")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                    } else {
                        ForEach(Array(sentence.enumerated()), id: \.offset) { index, word in
                            SentenceWordChip(word: word, onTap: { onRemoveAt(index) })
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            .frame(height: 52)

            Divider().frame(height: buttonSize)

            HStack(spacing: 8) {
                actionButton(systemImage: "trash", label: "Clear", color: .red, action: onClear)
                actionButton(systemImage: "delete.left", label: "Back", color: Color(hex: "#555555"), action: onRemoveLast)
                actionButton(systemImage: "speaker.wave.2.fill", label: "Speak", color: Color(hex: "#007AFF"), action: onSpeak)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
        .padding(.horizontal, 12)
    }

    private func actionButton(systemImage: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .semibold))
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundColor(color)
            .frame(width: buttonSize, height: buttonSize)
            .background(color.opacity(0.1))
            .cornerRadius(14)
        }
        .buttonStyle(.plain)
    }
}

private struct SentenceWordChip: View {
    let word: Word
    let onTap: () -> Void

    @State private var image: UIImage?

    private let imageSize: CGFloat = 28

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Group {
                    if let img = image {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                    } else {
                        fallbackLetter
                    }
                }
                .frame(width: imageSize, height: imageSize)

                Text(word.label)
                    .font(.system(size: 10, weight: .medium))
                    .lineLimit(1)
            }
            .foregroundColor(.primary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(height: 52)
            .background(Color(hex: "#F0F2FF"))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
        .task(id: word.label) {
            if let url = await fetchPictogramURL(label: word.label, arasaacId: word.arasaacId) {
                image = await ImageCache.shared.load(url)
            }
        }
    }

    private var fallbackLetter: some View {
        Text(String(word.label.prefix(1).uppercased()))
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.secondary)
    }
}

private struct SentenceBarPreview: View {
    @State var sentence: [Word]

    var body: some View {
        VStack {
            Spacer()
            SentenceBar(
                sentence: sentence,
                onSpeak: {},
                onClear: { sentence = [] },
                onRemoveLast: { if !sentence.isEmpty { sentence.removeLast() } },
                onRemoveAt: { sentence.remove(at: $0) }
            )
        }
        .background(Color(hex: "#F5F6FA"))
    }
}

#Preview("With sentence") {
    SentenceBarPreview(sentence: [
        Word(label: "I", arasaacId: 6632),
        Word(label: "Want", arasaacId: 5441),
        Word(label: "Water")
    ])
}

#Preview("Empty") {
    SentenceBarPreview(sentence: [])
}

#Preview("Long sentence — scrolls horizontally") {
    SentenceBarPreview(sentence: AACVocabulary.coreWords)
}
