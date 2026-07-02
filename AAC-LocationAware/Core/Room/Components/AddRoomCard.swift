import SwiftUI

struct AddRoomCard: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color(hex: "#FF9F43"), style: StrokeStyle(lineWidth: 2, dash: [6]))
                        .frame(width: 100, height: 100)
                    Image(systemName: "plus")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(Color(hex: "#FF9F43"))
                }

                VStack(spacing: 4) {
                    Text("New Room")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "#FF9F43"))
                    Text("Add a room")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#B2BEC3"))
                }

                Text("+ Add Room")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "#FF9F43"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(hex: "#FF9F43").opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#FF9F43").opacity(0.3), lineWidth: 1))

                // spacer matching the edit/delete buttons row height in RoomCard
                Color.clear.frame(height: 36)
            }
            .padding(24)
            .background(Color.white.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color(hex: "#FF9F43").opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [6])))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        DecorativeBackground()
        AddRoomCard(onTap: {})
            .frame(width: 220)
            .padding()
    }
}
