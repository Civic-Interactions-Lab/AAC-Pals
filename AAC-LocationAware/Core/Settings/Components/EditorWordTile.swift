import SwiftUI

struct EditorWordTile: View {
    let word: Word
    var position: Int?
    var onRemove: (() -> Void)?

    private var category: FitzgeraldCategory { fitzgeraldCategory(for: word.label) }

    var body: some View {
        VStack(spacing: 0) {
            PictogramImage(word: word, fallbackSize: 36)
                .padding(7)

            VStack(alignment: position == nil ? .center : .leading, spacing: 0) {
                if let position {
                    Text("\(position) · \(category.group.name)")
                        .font(.figtree(9))
                        .foregroundStyle(Color.ink.opacity(0.86))
                }

                Text(word.label)
                    .font(.fredoka(20))
                    .foregroundStyle(Color.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .frame(maxWidth: .infinity, alignment: position == nil ? .center : .leading)
            .padding(.horizontal, 8)
            .padding(.bottom, 7)
        }
        .sticker(category.color, radius: 16)
        .overlay(alignment: .topTrailing) {
            if let onRemove {
                RemoveBadge(label: word.label, action: onRemove)
                    .padding(5)
            }
        }
    }
}

#Preview {
    HStack {
        EditorWordTile(word: AACVocabulary.defaultBoardWords[2], position: 3)
        EditorWordTile(word: Word(label: "milk"), onRemove: {})
    }
    .frame(width: 300, height: 150)
    .padding()
    .environment(PictogramManager(service: MockPictogramService()))
}
