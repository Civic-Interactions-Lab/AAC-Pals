import SwiftUI

struct SettingsHeader<Actions: View>: View {
    let title: String
    let onBack: () -> Void
    let onDone: () -> Void
    @ViewBuilder var actions: Actions

    var body: some View {
        HStack(spacing: 14) {
            BackSquareButton(action: onBack)

            Text(title)
                .font(.fredoka(30))
                .foregroundStyle(Color.ink)
                .lineLimit(1)

            Spacer(minLength: 14)

            actions

            PillButton(title: "DONE", fill: .actionBlue, foreground: .white, action: onDone)
        }
        .padding(.horizontal, 26)
        .padding(.vertical, 18)
        .background(Color.butter)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.ink).frame(height: 2)
        }
    }
}

extension SettingsHeader where Actions == EmptyView {
    init(title: String, onBack: @escaping () -> Void, onDone: @escaping () -> Void) {
        self.init(title: title, onBack: onBack, onDone: onDone) { EmptyView() }
    }
}

#Preview {
    VStack(spacing: 0) {
        SettingsHeader(title: "Words", onBack: {}, onDone: {})
        SettingsHeader(title: "Rooms & beacons", onBack: {}, onDone: {}) {
            PillButton(title: "+ NEW ROOM", action: {})
        }
    }
}
