import SwiftUI

struct WordCard: View {
    let word: RoomWord
    let onEdit: () -> Void
    let onDelete: () -> Void

    private var color: Color {
        fitzgeraldColor(for: word.label)
    }

    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.15))
                .frame(height: 56)
                .overlay(
                    Text(word.label.prefix(1).uppercased())
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(color)
                )

            Text(word.label)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#1A1A2E"))
                .lineLimit(1)

            Text(word.category)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#9CA3AF"))
        }
        .padding(10)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        .contextMenu {
            Button { onEdit() } label: { Label("Edit", systemImage: "pencil") }
            Button(role: .destructive) { onDelete() } label: { Label("Delete", systemImage: "trash") }
        }
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
        WordCard(word: RoomWord.mocks(for: "room-1")[0], onEdit: {}, onDelete: {})
        WordCard(word: RoomWord.mocks(for: "room-1")[1], onEdit: {}, onDelete: {})
        WordCard(word: RoomWord.mocks(for: "room-1")[2], onEdit: {}, onDelete: {})
    }
    .padding()
    .background(Color(hex: "#FFF7EE"))
}
