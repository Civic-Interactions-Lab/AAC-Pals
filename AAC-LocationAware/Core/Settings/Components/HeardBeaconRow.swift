import SwiftUI

struct HeardBeaconRow: View {
    let beacon: DetectedBeacon
    let room: Room?
    let isInRange: Bool
    var onUse: (() -> Void)? = nil

    private var bars: Int {
        switch beacon.rssi {
        case (-60)...: 4
        case (-70)...: 3
        case (-80)...: 2
        default: 1
        }
    }

    private var detail: String {
        if let room { return isInRange ? "\(room.label) · in range" : "\(room.label) · too far" }
        if !isInRange { return "too far to pair" }
        if beacon.name?.isEmpty ?? true, beacon.major != nil { return "iBeacon, no name" }
        return "no room uses this ID"
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
                Text(BeaconID.display(beacon))
                    .font(.system(size: 15, weight: .heavy, design: .monospaced))
                    .foregroundStyle(Color.ink)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text(detail)
                    .font(.figtree(11, .semibold))
                    .foregroundStyle(Color.ink.opacity(0.86))
            }

            Spacer(minLength: 8)

            statusPill
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 10)
        .sticker(rowFill, radius: 16)
        .accessibilityElement(children: .combine)
    }

    private var rowFill: Color {
        if !isInRange { return Color.ink.opacity(0.06) }
        return room != nil ? .butter : .paper
    }

    @ViewBuilder
    private var statusPill: some View {
        if room != nil, isInRange {
            pill("Linked", foreground: .white, background: .ink)
        } else if !isInRange {
            pill("Too far", foreground: Color.ink.opacity(0.55), background: Color.ink.opacity(0.08))
        } else if let onUse {
            Button(action: onUse) {
                pill("Use it", foreground: .white, background: .actionBlue)
            }
            .buttonStyle(.plain)
        } else {
            pill("Not linked", foreground: .ink, background: .paper)
        }
    }

    private func pill(_ text: String, foreground: Color, background: Color) -> some View {
        Text(text)
            .font(.figtree(11))
            .foregroundStyle(foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .sticker(background, radius: 16)
    }
}

#Preview {
    VStack {
        HeardBeaconRow(beacon: DetectedBeacon(uuid: nil, name: "Kitchen", major: nil, minor: nil, rssi: -58), room: Room.mocks[0], isInRange: true)
        HeardBeaconRow(beacon: DetectedBeacon(uuid: nil, name: "playroom", major: nil, minor: nil, rssi: -66), room: nil, isInRange: true, onUse: {})
        HeardBeaconRow(beacon: DetectedBeacon(uuid: nil, name: "hallway", major: nil, minor: nil, rssi: -88), room: nil, isInRange: false)
    }
    .frame(width: 392)
    .padding()
    .background(Color.paper)
}
