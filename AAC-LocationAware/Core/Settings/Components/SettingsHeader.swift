import SwiftUI

struct SettingsHeader: View {
    let title: String
    let onBack: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.ink)
                    .frame(width: 48, height: 48)
                    .background(Color.paper, in: RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.ink, lineWidth: 2))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back")

            Text(title)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ink)

            Spacer()
        }
        .padding(.horizontal, 26)
        .padding(.vertical, 18)
        .background(Color.butter)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.ink).frame(height: 2)
        }
    }
}

#Preview {
    SettingsHeader(title: "Settings", onBack: {})
}
