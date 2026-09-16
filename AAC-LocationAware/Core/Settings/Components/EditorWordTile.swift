import SwiftUI

struct EditorWordTile: View {
    let word: Word
    let position: Int

    private var category: FitzgeraldCategory { fitzgeraldCategory(for: word.label) }

    var body: some View {
        VStack(spacing: 0) {
            PictogramImage(word: word, fallbackSize: 34)
                .padding(7)

            VStack(alignment: .leading, spacing: 0) {
                Text("\(position) · \(category.name)")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(Color.ink.opacity(0.86))

                Text(word.label)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(category.color)
            .overlay(alignment: .top) {
                Rectangle().fill(Color.ink).frame(height: 2)
            }
        }
        .background(Color.paper)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.ink, lineWidth: 2))
    }
}

#Preview {
    EditorWordTile(word: AACVocabulary.defaultBoardWords[0], position: 1)
        .frame(width: 140, height: 150)
        .padding()
        .environment(PictogramManager(service: MockPictogramService()))
}
