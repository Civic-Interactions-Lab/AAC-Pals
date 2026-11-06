import SwiftUI

struct ProfilesTab: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(BoardWordsManager.self) private var boardWordsManager

    @State private var wordCounts: [String: Int] = [:]
    let onSwitch: (UserProfile) -> Void
    let onNewProfile: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel("On this iPad")

            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 3), spacing: 14) {
                    ForEach(Array(userManager.profiles.enumerated()), id: \.element.id) { index, profile in
                        profileCard(profile, color: AvatarPalette.color(for: index))
                    }
                    newProfileCard
                }
                .padding(.horizontal, 2)
                .padding(.top, 2)
                .padding(.bottom, 6)
            }

            Caption("Each profile keeps its own board. Switching is one tap — no password.")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .task {
            if userManager.profiles.isEmpty, let adminId = authManager.currentUser?.id {
                await userManager.loadProfiles(adminId: adminId)
            }
        }
        .task(id: "\(userManager.profiles.map(\.id))-\(boardWordsManager.setup.labels.count)") {
            for profile in userManager.profiles {
                wordCounts[profile.id] = await boardWordsManager.wordCount(for: profile.id)
            }
        }
    }

    private func profileCard(_ profile: UserProfile, color: Color) -> some View {
        let isActive = userManager.activeProfile?.id == profile.id

        return VStack(spacing: 10) {
            AvatarCircle(name: profile.displayName, color: color, size: 84)

            Text(profile.displayName)
                .font(.fredoka(26))
                .foregroundStyle(Color.ink)
                .lineLimit(1)

            Caption("\(wordCounts[profile.id] ?? BoardSetup.default.labels.count) words on the board")

            Button { if !isActive { onSwitch(profile) } } label: {
                Text(isActive ? "IN USE NOW" : "SWITCH TO \(profile.displayName.uppercased())")
                    .font(.figtree(11))
                    .tracking(0.7)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .sticker(isActive ? .ink : .actionBlue, radius: 14)
                    .contentShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(isActive ? .isSelected : [])
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .sticker(isActive ? .butter : .paper, radius: 20)
        .compositingGroup()
        .shadow(color: Color.ink.opacity(0.28), radius: 0, y: 3)
    }

    private var newProfileCard: some View {
        Button(action: onNewProfile) {
            VStack(spacing: 10) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.ink.opacity(0.5))
                    .frame(width: 64, height: 64)
                    .overlay(Circle().strokeBorder(Color.ink.opacity(0.4), style: StrokeStyle(lineWidth: 2, dash: [6, 5])))

                Text("New profile")
                    .font(.fredoka(18))
                    .foregroundStyle(Color.ink.opacity(0.7))
            }
            .frame(maxWidth: .infinity, minHeight: 214)
            .dashedOutline(radius: 20)
            .contentShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ProfilesTab(onSwitch: { _ in }, onNewProfile: {})
        .background(Color.paper)
        .previewAllEnvironments(withProfile: true)
}
