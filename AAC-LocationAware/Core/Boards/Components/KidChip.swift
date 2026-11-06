import SwiftUI

struct KidChip: View {
    let name: String
    var avatarColor: Color = .categoryQuestion
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 9) {
                AvatarCircle(name: name, color: avatarColor, size: 32)

                Text(name)
                    .font(.fredoka(18))
                    .foregroundStyle(Color.ink)
                    .lineLimit(1)
            }
            .padding(.leading, 4)
            .padding(.trailing, 13)
            .padding(.vertical, 4)
            .background(Color.paper, in: Capsule())
            .overlay(Capsule().strokeBorder(Color.ink, lineWidth: 2))
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(name). Switch profile")
    }
}

#Preview {
    KidChip(name: "Katerina", onTap: {}).padding().background(Color.butter)
}
