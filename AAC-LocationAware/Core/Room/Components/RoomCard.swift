import SwiftUI

struct RoomCard: View {
    let room: Room
    let wordCount: Int
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var isPressed = false

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#FF9F43"), Color(hex: "#FF6B6B")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: Color(hex: "#FF9F43").opacity(0.35), radius: 16, x: 0, y: 8)

                Text(String(room.label.prefix(1)).uppercased())
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 4) {
                Text(room.label)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "#1A1A2E"))
                    .lineLimit(1)
                Text("\(wordCount) word\(wordCount == 1 ? "" : "s")")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#B2BEC3"))
            }

            Button(action: onTap) {
                HStack(spacing: 6) {
                    Text("Open")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#FF9F43"), Color(hex: "#FF6B6B")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)

            HStack(spacing: 10) {
                Button(action: onEdit) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                        Text("Edit")
                    }
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#FF9F43"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(hex: "#FF9F43").opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                Button(action: onDelete) {
                    HStack(spacing: 4) {
                        Image(systemName: "trash")
                        Text("Delete")
                    }
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#FF6B6B"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(hex: "#FF6B6B").opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: .black.opacity(0.07), radius: 24, x: 0, y: 8)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.65), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

#Preview {
    ZStack {
        DecorativeBackground()
        HStack(spacing: 28) {
            RoomCard(room: Room.mocks[0], wordCount: 22, onTap: {}, onEdit: {}, onDelete: {})
                .frame(width: 220)
            RoomCard(room: Room.mocks[1], wordCount: 8, onTap: {}, onEdit: {}, onDelete: {})
                .frame(width: 220)
        }
        .padding()
    }
}
