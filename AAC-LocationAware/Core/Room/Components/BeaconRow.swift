import SwiftUI

struct BeaconRow: View {
    let beacon: AppBeacon
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#FF9F43").opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(hex: "#FF9F43"))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(beacon.label)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#1A1A2E"))
                Text(beacon.beaconUuid)
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundStyle(Color(hex: "#9CA3AF"))
                    .lineLimit(1)
                Text("Radius: \(Int(beacon.radius)) ft")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#9CA3AF"))
            }

            Spacer()

            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(hex: "#FF9F43"))
                    .frame(width: 36, height: 36)
                    .background(Color(hex: "#FF9F43").opacity(0.1))
                    .clipShape(Circle())
            }

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(hex: "#FF6B6B"))
                    .frame(width: 36, height: 36)
                    .background(Color(hex: "#FF6B6B").opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}
