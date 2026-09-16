import SwiftUI

/// Header chip for the detected room: a live badge while the panel is open,
/// a button to reopen it while closed.
struct RoomChip: View {
    let room: Room
    let wordCount: Int
    let isPanelOpen: Bool
    let onOpen: () -> Void

    var body: some View {
        if isPanelOpen {
            HStack(spacing: 9) {
                PulsingDot()
                Text("\(room.label.uppercased()) · IN RANGE")
                    .font(.system(size: 13, weight: .heavy))
                    .tracking(0.8)
                    .foregroundStyle(Color.ink)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.signalGreen, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.ink, lineWidth: 2))
        } else {
            Button(action: onOpen) {
                Text("\(room.label.uppercased()) WORDS (\(wordCount)) ›")
                    .font(.system(size: 12, weight: .heavy))
                    .tracking(0.7)
                    .foregroundStyle(Color.ink)
                    .lineLimit(1)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(Color.signalGreen, in: Capsule())
                    .overlay(Capsule().strokeBorder(Color.ink, lineWidth: 2))
                    .contentShape(Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Show \(room.label) words")
        }
    }
}

private struct PulsingDot: View {
    @State private var pulsing = false

    var body: some View {
        Circle()
            .fill(Color.ink)
            .frame(width: 11, height: 11)
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
        RoomChip(room: Room.mocks[0], wordCount: 13, isPanelOpen: true, onOpen: {})
        RoomChip(room: Room.mocks[0], wordCount: 13, isPanelOpen: false, onOpen: {})
    }
    .padding()
    .background(Color.butter)
}
