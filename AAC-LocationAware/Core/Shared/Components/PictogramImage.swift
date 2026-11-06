import SwiftUI

struct PictogramImage: View {
    @Environment(PictogramManager.self) private var pictogramManager

    let word: Word
    var fallbackSize: CGFloat = 44

    @State private var image: UIImage?
    @State private var didLoad = false

    var body: some View {
        ZStack {
            Color.clear

            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else if didLoad {
                Text(word.label.prefix(1).uppercased())
                    .font(.fredoka(fallbackSize * 0.45))
                    .foregroundStyle(Color.ink)
                    .frame(width: fallbackSize, height: fallbackSize)
                    .background(Color.paper, in: Circle())
                    .overlay(Circle().strokeBorder(Color.ink, lineWidth: 2))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityHidden(true)
        .task(id: word.id) {
            if let bundled = Self.bundledImage(for: word.label) {
                image = bundled
            } else {
                image = await pictogramManager.fetchImage(for: word.label, arasaacId: word.arasaacId)
            }
            didLoad = true
        }
    }

    static func bundledImage(for label: String) -> UIImage? {
        let slug = label.lowercased()
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: " ", with: "-")
        return UIImage(named: "pic-\(slug)")
    }
}

#Preview {
    PictogramImage(word: AACVocabulary.defaultBoardWords[0])
        .frame(width: 200, height: 200)
        .environment(PictogramManager(service: MockPictogramService()))
}
