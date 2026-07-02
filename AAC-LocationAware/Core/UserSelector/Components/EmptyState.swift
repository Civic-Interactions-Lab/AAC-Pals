import SwiftUI

struct EmptyState: View {
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#FF9F43").opacity(0.1))
                    .frame(width: 120, height: 120)

                Image(systemName: "person.3.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "#FF9F43"), Color(hex: "#FF6B6B")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: 8) {
                Text("No users yet")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "#1A1A2E"))

                Text("Add your first user to get started")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#9CA3AF"))
                    .multilineTextAlignment(.center)
            }

            Button(action: onAdd) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 17))
                    Text("Create User")
                        .font(.system(size: 17, weight: .black, design: .rounded))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#FF9F43"), Color(hex: "#FF6B6B")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: Color(hex: "#FF9F43").opacity(0.4), radius: 16, x: 0, y: 8)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    ZStack {
        DecorativeBackground()
        EmptyState(onAdd: {})
    }
}
