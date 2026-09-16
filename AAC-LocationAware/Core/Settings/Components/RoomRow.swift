import SwiftUI

struct RoomRow: View {
    let room: Room
    let wordCount: Int
    let beacons: [AppBeacon]
    let isInRange: Bool

    private var status: String {
        if beacons.isEmpty { return "no beacon" }
        return isInRange ? "in range" : "not heard yet"
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(beacons.isEmpty ? Color.categoryNegation : (isInRange ? Color.signalGreen : Color.paper))
                .frame(width: 14, height: 14)
                .overlay(Circle().strokeBorder(Color.ink, lineWidth: 2))

            VStack(alignment: .leading, spacing: 2) {
                Text(room.label)
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ink)
                Text("\(wordCount) words · \(status)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.ink.opacity(0.86))
            }

            Spacer(minLength: 8)

            Text(beacons.isEmpty ? "not paired" : beacons.map(\.beaconUuid).joined(separator: ", "))
                .font(.system(size: 12, weight: .heavy, design: .monospaced))
                .foregroundStyle(Color.ink.opacity(0.86))
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(beacons.isEmpty ? Color.shade.opacity(0.05) : Color.paper, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.ink, lineWidth: 2))
    }
}

#Preview {
    VStack {
        RoomRow(room: Room.mocks[0], wordCount: 22, beacons: AppBeacon.mockPairings["room-kitchen"]!, isInRange: true)
        RoomRow(room: Room.mocks[1], wordCount: 15, beacons: [], isInRange: false)
    }
    .padding()
    .background(Color.paper)
}
