import SwiftUI

struct HeardBeaconRow: View {
    let beacon: DetectedBeacon
    let room: Room?
    let isInRange: Bool
    var actionTitle: String? = nil

    private var bars: Int {
        switch beacon.rssi {
        case (-60)...: 4
        case (-70)...: 3
        case (-80)...: 2
        default: 1
        }
    }

    private var match: String {
        guard let room else { return "no room uses this ID" }
        return isInRange ? room.label : "\(room.label) · too far"
    }

    var body: some View {
        HStack(spacing: 10) {
            HStack(alignment: .bottom, spacing: 3) {
                ForEach(0..<4, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(index < bars ? Color.ink : Color.paper)
                        .frame(width: 6, height: CGFloat(11 + index * 5))
                        .overlay(RoundedRectangle(cornerRadius: 3).strokeBorder(Color.ink, lineWidth: 2))
                }
            }
            .frame(height: 26, alignment: .bottom)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 1) {
                Text(beacon.displayName)
                    .font(.system(size: 15, weight: .heavy, design: .monospaced))
                    .foregroundStyle(Color.ink)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text("\(match) · \(beacon.rssi) dBm")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.ink.opacity(0.86))
            }

            Spacer(minLength: 8)

            statusPill
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 10)
        .background(room != nil && isInRange ? Color.butter : Color.paper, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.ink, lineWidth: 2))
    }

    @ViewBuilder
    private var statusPill: some View {
        if let actionTitle {
            pill(actionTitle, foreground: .white, background: .actionBlue)
        } else if room == nil {
            pill("Not linked", foreground: .ink, background: .paper)
        } else if isInRange {
            pill("Linked", foreground: .white, background: .ink)
        } else {
            pill("Too far", foreground: Color.shade.opacity(0.55), background: Color.shade.opacity(0.1))
        }
    }

    private func pill(_ text: String, foreground: Color, background: Color) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .heavy))
            .foregroundStyle(foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(background, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.ink, lineWidth: 2))
    }
}

#Preview {
    VStack {
        HeardBeaconRow(beacon: DetectedBeacon(uuid: nil, name: "Kitchen", major: nil, minor: nil, rssi: -58), room: Room.mocks[0], isInRange: true)
        HeardBeaconRow(beacon: DetectedBeacon(uuid: nil, name: "playroom", major: nil, minor: nil, rssi: -66), room: nil, isInRange: true)
    }
    .frame(width: 392)
    .padding()
    .background(Color.paper)
}
