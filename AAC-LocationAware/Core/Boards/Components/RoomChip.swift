import SwiftUI

struct RoomChip: View {
    let room: Room?

    var body: some View {
        HStack(spacing: 8) {
            if room != nil {
                PulsingDot()
            } else {
                Circle()
                    .fill(Color.ink.opacity(0.3))
                    .frame(width: 9, height: 9)
            }

            Text(room?.label.uppercased() ?? "NO ROOM NEARBY")
                .font(.figtree(12))
                .tracking(0.7)
                .foregroundStyle(room != nil ? Color.ink : Color.ink.opacity(0.6))
                .lineLimit(1)
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 6)
        .background {
            if room != nil {
                Capsule().fill(Color.signalGreen)
                Capsule().strokeBorder(Color.ink, lineWidth: 2)
            } else {
                Capsule().strokeBorder(Color.ink.opacity(0.4), style: StrokeStyle(lineWidth: 2, dash: [6, 5]))
            }
        }
        .accessibilityElement(children: .combine)
    }
}

private struct PulsingDot: View {
    @State private var pulsing = false

    var body: some View {
        Circle()
            .fill(Color.ink)
            .frame(width: 9, height: 9)
            .scaleEffect(pulsing ? 1.45 : 1)
            .opacity(pulsing ? 0.45 : 1)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) { pulsing = true }
            }
            .accessibilityHidden(true)
    }
}

#Preview {
    VStack {
        RoomChip(room: Room.mocks[0])
        RoomChip(room: nil)
    }
    .padding()
    .background(Color.butter)
}
