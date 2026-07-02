import SwiftUI

struct AdminRecentLogRow: View {
    let log: InteractionLog

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: "#FF9F43").opacity(0.15))
                .frame(width: 36, height: 36)
                .overlay(
                    Text(String(log.word.prefix(1)).uppercased())
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color(hex: "#FF9F43"))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(log.word)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(hex: "#1A1A2E"))
                Text(log.roomId.capitalized)
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: "#1A1A2E").opacity(0.5))
            }

            Spacer()

            Text(log.pressedAt.formatted(.relative(presentation: .named)))
                .font(.system(size: 11))
                .foregroundStyle(Color(hex: "#1A1A2E").opacity(0.4))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(hex: "#FF9F43").opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    VStack(spacing: 8) {
        AdminRecentLogRow(log: InteractionLog.make(userId: "u1", adminId: "a1", word: "hello", roomId: "kitchen"))
        AdminRecentLogRow(log: InteractionLog.make(userId: "u2", adminId: "a1", word: "eat", roomId: "common"))
    }
    .padding()
    .background(Color(hex: "#FFF7EE"))
}
