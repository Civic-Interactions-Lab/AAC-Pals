import SwiftUI

struct AdminRecentLogRow: View {
    let log: InteractionLog
    let userName: String
    let roomLabel: String

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
                HStack(spacing: 4) {
                    Text(log.word)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(hex: "#1A1A2E"))
                    Text("·")
                        .foregroundStyle(Color(hex: "#9CA3AF"))
                    Text(userName)
                        .font(.system(size: 13))
                        .foregroundStyle(Color(hex: "#1A1A2E").opacity(0.7))
                }
                Text(roomLabel)
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: "#1A1A2E").opacity(0.5))
            }

            Spacer()

            Text(log.pressedAt, style: .time)
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
        AdminRecentLogRow(
            log: InteractionLog.make(userId: "u1", adminId: "a1", word: "hello", roomId: "kitchen"),
            userName: "Alex",
            roomLabel: "Kitchen"
        )
        AdminRecentLogRow(
            log: InteractionLog.make(userId: "u2", adminId: "a1", word: "eat", roomId: "common"),
            userName: "Jordan",
            roomLabel: "Common Room"
        )
    }
    .padding()
    .background(Color(hex: "#FFF7EE"))
}
