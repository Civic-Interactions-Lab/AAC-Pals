import SwiftUI

enum SettingsTab: CaseIterable {
    case words
    case roomsAndBeacons

    var title: String {
        switch self {
        case .words: "Words"
        case .roomsAndBeacons: "Rooms & beacons"
        }
    }
}

struct SettingsSidebar: View {
    @Binding var selectedTab: SettingsTab

    var body: some View {
        VStack(spacing: 10) {
            ForEach(SettingsTab.allCases, id: \.self) { tab in
                Button { selectedTab = tab } label: {
                    Text(tab.title)
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundStyle(Color.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(selectedTab == tab ? Color.butter : Color.paper, in: RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.ink, lineWidth: 2))
                        .contentShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .frame(width: 236)
    }
}

#Preview {
    SettingsSidebar(selectedTab: .constant(.words))
        .background(Color.paper)
}
