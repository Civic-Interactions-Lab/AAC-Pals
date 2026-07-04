import SwiftUI

struct RoomPickerPopover: View {
    let rooms: [Room]
    let selectedRoomId: String
    let beaconRoomId: String
    let onSelect: (String) -> Void

    private var generalRow: some View {
        RoomPickerRow(
            label: "General",
            isSelected: selectedRoomId == kCommonRoomId,
            isBeaconRoom: beaconRoomId == kCommonRoomId,
            onTap: { onSelect(kCommonRoomId) }
        )
    }

    private func roomRow(_ room: Room) -> some View {
        RoomPickerRow(
            label: room.label,
            isSelected: selectedRoomId == room.id,
            isBeaconRoom: beaconRoomId == room.id,
            onTap: { onSelect(room.id) }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Switch Room")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color(hex: "#0d4f4a"))
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 8)

            Divider()

            ScrollView {
                VStack(spacing: 4) {
                    generalRow
                    ForEach(rooms) { room in roomRow(room) }
                }
                .padding(10)
            }
        }
        .frame(width: 220)
        .frame(minHeight: 160)
    }
}

private struct RoomPickerRow: View {
    let label: String
    let isSelected: Bool
    let isBeaconRoom: Bool
    let onTap: () -> Void

    private let accent = Color(hex: "#0d4f4a")

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Text(label)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? accent : Color.primary)

                Spacer()

                if isBeaconRoom {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(accent)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isSelected ? accent.opacity(0.08) : Color.clear, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RoomPickerPopover(
        rooms: Room.mocks,
        selectedRoomId: Room.mocks[0].id,
        beaconRoomId: Room.mocks[1].id,
        onSelect: { _ in }
    )
}
