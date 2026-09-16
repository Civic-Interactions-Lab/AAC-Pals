import SwiftUI

struct PictogramImage: View {
    @Environment(PictogramManager.self) private var pictogramManager

    let word: Word
    var fallbackSize: CGFloat = 40

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
                    .font(.system(size: fallbackSize * 0.5, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ink)
                    .frame(width: fallbackSize, height: fallbackSize)
                    .overlay(Circle().strokeBorder(Color.ink, lineWidth: 2))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task(id: word.id) {
            image = await pictogramManager.fetchImage(for: word.label, arasaacId: word.arasaacId)
            didLoad = true
        }
    }
}

#Preview {
    PictogramImage(word: AACVocabulary.defaultBoardWords[0])
        .frame(width: 200, height: 200)
        .environment(PictogramManager(service: MockPictogramService()))
}
