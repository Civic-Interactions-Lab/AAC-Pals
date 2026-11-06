import SwiftUI

struct RoomRow: View {
    let room: Room
    let wordCount: Int
    let beacons: [AppBeacon]
    let isInRange: Bool
    let onEdit: () -> Void

    private var status: String {
        if isInRange { return "in range" }
        return beacons.isEmpty ? "no beacon" : "not heard"
    }

    var body: some View {
        Button(action: onEdit) {
            HStack(spacing: 12) {
                Circle()
                    .fill(isInRange ? Color.signalGreen : Color.categoryNegation)
                    .frame(width: 14, height: 14)
                    .overlay(Circle().strokeBorder(Color.ink, lineWidth: 2))

                VStack(alignment: .leading, spacing: 2) {
                    Text(room.label)
                        .font(.fredoka(21))
                        .foregroundStyle(Color.ink)
                        .lineLimit(1)
                    Text("\(wordCount) words · \(status)")
                        .font(.figtree(12, .bold))
                        .foregroundStyle(Color.ink.opacity(0.86))
                }

                Spacer(minLength: 8)

                Text(beacons.isEmpty ? "not paired" : beacons.map { BeaconID.display($0.beaconUuid) }.joined(separator: ", "))
                    .font(.system(size: 12, weight: .heavy, design: .monospaced))
                    .foregroundStyle(Color.ink.opacity(0.86))
                    .lineLimit(1)
                    .truncationMode(.middle)

                Text("EDIT")
                    .font(.figtree(11))
                    .foregroundStyle(Color.ink)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .sticker(.paper, radius: 16)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .sticker(isInRange ? .butter : .paper, radius: 16)
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(room.label), \(wordCount) words, \(status). Edit")
    }
}

enum BeaconID {
    static func display(_ id: String) -> String {
        UUID(uuidString: id) != nil ? id : "name · \(id)"
    }

    static func display(_ beacon: DetectedBeacon) -> String {
        if let name = beacon.name, !name.isEmpty { return "name · \(name)" }
        if let major = beacon.major, let minor = beacon.minor { return "major \(major) · minor \(minor)" }
        return beacon.uuid ?? "unknown"
    }
}

#Preview {
    VStack {
        RoomRow(room: Room.mocks[0], wordCount: 22, beacons: AppBeacon.mockPairings["room-kitchen"]!, isInRange: true, onEdit: {})
        RoomRow(room: Room.mocks[1], wordCount: 10, beacons: [], isInRange: false, onEdit: {})
    }
    .padding()
    .background(Color.paper)
}
