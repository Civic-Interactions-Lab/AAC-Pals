import SwiftUI

struct PictogramTile: View {
    let word: Word
    let tileSize: CGFloat
    let onTap: () -> Void

    @Environment(PictogramManager.self) private var pictogramManager
    @State private var image: UIImage?
    @State private var loading = true

    private var color: Color { fitzgeraldColor(for: word.label) }
    private var isWhite: Bool { fitzgeraldCategory(for: word.label) == .conjunction }
    private var borderColor: Color { isWhite ? Color(hex: "#4B4B4B") : color }
    private var bgColor: Color { isWhite ? .white : color.opacity(0.13) }
    private var pictogramSize: CGFloat { max(44, min(84, tileSize * 0.62)) }
    private var tileHeight: CGFloat { pictogramSize + 28 }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Group {
                    if let img = image {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(width: pictogramSize, height: pictogramSize)
                    } else if loading {
                        ProgressView()
                            .frame(width: pictogramSize, height: pictogramSize)
                    } else {
                        fallbackIcon
                    }
                }

                Text(word.label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isWhite ? Color(hex: "#4B4B4B") : color)
                    .lineLimit(1)
            }
            .padding(6)
            .frame(width: tileSize, height: tileHeight)
            .background(bgColor)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(borderColor, lineWidth: 2))
            .cornerRadius(14)
        }
        .buttonStyle(.plain)
        .task(id: word.label) {
            loading = true
            image = await pictogramManager.fetchImage(for: word.label, arasaacId: word.arasaacId)
            loading = false
        }
    }

    private var fallbackIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColor, lineWidth: 1.5)
                .frame(width: pictogramSize, height: pictogramSize)
            Text(String(word.label.prefix(1).uppercased()))
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(isWhite ? Color(hex: "#4B4B4B") : color)
        }
    }
}

#Preview("Known ARASAAC IDs — loads instantly") {
    HStack(spacing: 12) {
        PictogramTile(word: Word(label: "I", arasaacId: 6632), tileSize: 100, onTap: {})
        PictogramTile(word: Word(label: "Want", arasaacId: 5441), tileSize: 100, onTap: {})
        PictogramTile(word: Word(label: "Eat", arasaacId: 6456), tileSize: 100, onTap: {})
        PictogramTile(word: Word(label: "No", arasaacId: 5526), tileSize: 100, onTap: {})
    }
    .padding()
    .background(Color(hex: "#F5F6FA"))
        .previewAllEnvironments()
}

#Preview("API search — resolves via search term") {
    HStack(spacing: 12) {
        PictogramTile(word: Word(label: "all done"), tileSize: 100, onTap: {})
        PictogramTile(word: Word(label: "wash hands"), tileSize: 100, onTap: {})
        PictogramTile(word: Word(label: "go home"), tileSize: 100, onTap: {})
    }
    .padding()
    .background(Color(hex: "#F5F6FA"))
        .previewAllEnvironments()
}

#Preview("Fallback — unknown word") {
    HStack(spacing: 12) {
        PictogramTile(word: Word(label: "xyzunknown123"), tileSize: 100, onTap: {})
        PictogramTile(word: Word(label: "zzz"), tileSize: 100, onTap: {})
    }
    .padding()
    .background(Color(hex: "#F5F6FA"))
        .previewAllEnvironments()
}

#Preview("Fitzgerald colors") {
    HStack(spacing: 12) {
        PictogramTile(word: Word(label: "I"), tileSize: 100, onTap: {})
        PictogramTile(word: Word(label: "Want"), tileSize: 100, onTap: {})
        PictogramTile(word: Word(label: "Big"), tileSize: 100, onTap: {})
        PictogramTile(word: Word(label: "Food"), tileSize: 100, onTap: {})
        PictogramTile(word: Word(label: "Please"), tileSize: 100, onTap: {})
        PictogramTile(word: Word(label: "No"), tileSize: 100, onTap: {})      
    }
    .padding()
    .background(Color(hex: "#F5F6FA"))
        .previewAllEnvironments()
}
