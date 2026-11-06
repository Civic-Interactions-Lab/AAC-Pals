import SwiftUI

enum SettingsTab: CaseIterable, Hashable {
    case words
    case roomsAndBeacons
    case voice
    case profiles

    var title: String {
        switch self {
        case .words: "Words"
        case .roomsAndBeacons: "Rooms & beacons"
        case .voice: "Voice"
        case .profiles: "Profiles"
        }
    }
}

struct SettingsSidebar: View {
    @Binding var selectedTab: SettingsTab
    let kidName: String
    var avatarColor: Color = .categoryQuestion
    let onSignOut: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(SettingsTab.allCases, id: \.self) { tab in
                Button { selectedTab = tab } label: {
                    Text(tab.title)
                        .font(.figtree(15))
                        .foregroundStyle(Color.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .sticker(selectedTab == tab ? .butter : .paper, radius: 16)
                        .contentShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
            }

            Spacer()

            Button(action: onSignOut) {
                Text("SIGN OUT")
                    .font(.figtree(12))
                    .tracking(0.7)
                    .foregroundStyle(Color.ink.opacity(0.8))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.plain)

            Button { selectedTab = .profiles } label: {
                HStack(spacing: 12) {
                    AvatarCircle(name: kidName, color: avatarColor, size: 44)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(kidName)
                            .font(.fredoka(18))
                            .foregroundStyle(Color.ink)
                            .lineLimit(1)
                        Text("Switch profile")
                            .font(.figtree(12))
                            .foregroundStyle(Color.actionBlue)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .sticker(.paper, radius: 18)
                .contentShape(RoundedRectangle(cornerRadius: 18))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.top, 18)
        .padding(.bottom, 16)
        .frame(width: 236)
        .overlay(alignment: .trailing) {
            Rectangle().fill(Color.ink).frame(width: 2)
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

#Preview {
    SettingsSidebar(selectedTab: .constant(.words), kidName: "Katerina", onSignOut: {})
        .background(Color.paper)
}
