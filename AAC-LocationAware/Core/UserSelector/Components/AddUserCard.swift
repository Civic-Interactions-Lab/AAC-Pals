import SwiftUI

struct AddUserCard: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#FF9F43").opacity(0.05))
                        .frame(width: 100, height: 100)
                    Circle()
                        .strokeBorder(
                            Color(hex: "#FF9F43"),
                            style: StrokeStyle(lineWidth: 2.5, dash: [6, 4])
                        )
                        .frame(width: 100, height: 100)
                    Image(systemName: "plus")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(Color(hex: "#FF9F43"))
                }

                VStack(spacing: 4) {
                    Text("New User")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "#FF9F43"))

                    Text("Start a new adventure")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#FF9F43").opacity(0.55))
                }

                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "#FF9F43").opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color(hex: "#FF9F43").opacity(0.3), lineWidth: 1.5)
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .overlay(
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 15))
                            Text("Add User")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(Color(hex: "#FF9F43"))
                    )
            }
            .padding(24)
            .background(
                ZStack {
                    Color.white
                    Color(hex: "#FF9F43").opacity(0.05)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .strokeBorder(
                        Color(hex: "#FF9F43"),
                        style: StrokeStyle(lineWidth: 2, dash: [8, 5])
                    )
            )
            .shadow(color: Color(hex: "#FF9F43").opacity(0.10), radius: 20, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AddUserCard(action: {})
        .frame(width: 240)
        .padding()
}
