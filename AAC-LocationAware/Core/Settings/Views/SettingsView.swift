import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab: SettingsTab = .words

    var body: some View {
        VStack(spacing: 0) {
            SettingsHeader(title: "Settings", onBack: { dismiss() })

            HStack(spacing: 0) {
                SettingsSidebar(selectedTab: $selectedTab)

                Rectangle().fill(Color.ink).frame(width: 2)

                switch selectedTab {
                case .words:
                    WordsTab(words: AACVocabulary.defaultBoardWords)
                case .roomsAndBeacons:
                    RoomsBeaconsTab()
                }
            }
        }
        .background(Color.paper)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    SettingsView().previewAllEnvironments()
}
