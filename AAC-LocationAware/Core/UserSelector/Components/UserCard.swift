import SwiftUI

struct UserCard: View {
    let profile: UserProfile
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var isPressed = false

    private static let gradientPairs: [(String, String)] = [
        ("#FF6B6B", "#FF9F43"),
        ("#A29BFE", "#6C5CE7"),
        ("#54A0FF", "#2E86DE"),
        ("#1DD1A1", "#00B894"),
        ("#FD79A8", "#E84393"),
        ("#FDCB6E", "#E17055"),
    ]

    private var avatarGradient: LinearGradient {
        let pair = Self.gradientPairs[abs(profile.id.hashValue) % Self.gradientPairs.count]
        return LinearGradient(
            colors: [Color(hex: pair.0), Color(hex: pair.1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var initials: String {
        profile.displayName
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first.map(String.init) }
            .joined()
            .uppercased()
    }

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(avatarGradient)
                    .frame(width: 100, height: 100)
                    .shadow(color: Color(hex: "#FF9F43").opacity(0.35), radius: 16, x: 0, y: 8)

                Text(initials.isEmpty ? "?" : initials)
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 6) {
                Text(profile.displayName)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "#1A1A2E"))
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(Color(hex: "#B2BEC3"))
                    Text(profile.passcode)
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(hex: "#B2BEC3"))
                }
            }

            Button(action: onSelect) {
                HStack(spacing: 6) {
                    Text("Continue")
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
            ForEach(UserProfile.mocks) { profile in
                UserCard(profile: profile, onSelect: {}, onEdit: {}, onDelete: {})
                    .frame(width: 220)
            }
        }
        .padding()
    }
}
