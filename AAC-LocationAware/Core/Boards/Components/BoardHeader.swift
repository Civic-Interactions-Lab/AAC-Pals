import SwiftUI

struct BoardHeader: View {
    let kidName: String
    var avatarColor: Color = .categoryQuestion
    let room: Room?
    let onProfiles: () -> Void
    let onSettings: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            KidChip(name: kidName, avatarColor: avatarColor, onTap: onProfiles)
            RoomChip(room: room)

            Spacer(minLength: 12)

            Button(action: onSettings) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.ink)
                    .frame(width: 38, height: 38)
                    .sticker(.paper, radius: 12)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Settings")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.butter)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.ink).frame(height: 2)
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        BoardHeader(kidName: "Katerina", room: Room.mocks[0], onProfiles: {}, onSettings: {})
        BoardHeader(kidName: "Katerina", room: nil, onProfiles: {}, onSettings: {})
    }
}
