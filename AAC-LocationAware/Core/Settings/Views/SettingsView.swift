import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(PictogramManager.self) private var pictogramManager
    @Environment(BoardWordsManager.self) private var boardWordsManager

    @State private var selectedTab: SettingsTab
    @State private var editingRoom: Room?
    @State private var newRoomBeacon: NewRoomRequest?
    @State private var showNewProfile = false
    @State private var newProfileName = ""

    init(initialTab: SettingsTab = .words) {
        _selectedTab = State(initialValue: initialTab)
    }

    private var kidName: String {
        userManager.activeProfile?.displayName ?? userManager.profiles.first?.displayName ?? "Profile"
    }

    private var avatarColor: Color {
        let index = userManager.profiles.firstIndex { $0.id == userManager.activeProfile?.id } ?? 0
        return AvatarPalette.color(for: index)
    }

    var body: some View {
        VStack(spacing: 0) {
            SettingsHeader(title: selectedTab.title, onBack: { dismiss() }, onDone: { dismiss() }) {
                switch selectedTab {
                case .roomsAndBeacons:
                    PillButton(title: "+ NEW ROOM") { newRoomBeacon = NewRoomRequest(beacon: nil) }
                case .profiles:
                    PillButton(title: "+ NEW PROFILE", action: startNewProfile)
                case .words, .voice:
                    EmptyView()
                }
            }

            HStack(spacing: 0) {
                SettingsSidebar(selectedTab: $selectedTab, kidName: kidName, avatarColor: avatarColor, onSignOut: signOut)

                Group {
                    switch selectedTab {
                    case .words:
                        WordsTab(kidName: kidName)
                    case .roomsAndBeacons:
                        RoomsBeaconsTab(
                            onEdit: { editingRoom = $0 },
                            onUseBeacon: { newRoomBeacon = NewRoomRequest(beacon: $0) }
                        )
                    case .voice:
                        VoiceTab(kidName: kidName)
                    case .profiles:
                        ProfilesTab(onSwitch: switchTo, onNewProfile: startNewProfile)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .background(Color.paper)
        .toolbar(.hidden, for: .navigationBar)
        .task(id: userManager.activeProfile?.id ?? userManager.profiles.first?.id) {
            guard let id = userManager.activeProfile?.id ?? userManager.profiles.first?.id,
                  boardWordsManager.profileId != id else { return }
            await boardWordsManager.load(profileId: id)
        }
        .navigationDestination(item: $editingRoom) { room in
            RoomEditView(room: room)
        }
        .sheet(item: $newRoomBeacon) { request in
            NewRoomSheet(initialBeacon: request.beacon)
        }
        .alert("New profile", isPresented: $showNewProfile) {
            TextField("Child's name", text: $newProfileName)
            Button("Cancel", role: .cancel) {}
            Button("Add", action: addProfile)
        } message: {
            Text("What's the child's name?")
        }
    }

    private func switchTo(_ profile: UserProfile) {
        userManager.selectProfile(profile)
        UserDefaults.standard.set(profile.id, forKey: kActiveUserIdKey)
        pictogramManager.clearSentence()
    }

    private func startNewProfile() {
        newProfileName = ""
        showNewProfile = true
    }

    private func addProfile() {
        let name = newProfileName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty, let adminId = authManager.currentUser?.id else { return }
        Task { await userManager.addProfile(displayName: name, adminId: adminId) }
    }

    private func signOut() {
        Task {
            await authManager.signOut()
            userManager.exitProfile()
            userManager.clearProfiles()
        }
    }
}

private struct NewRoomRequest: Identifiable {
    let id = UUID()
    let beacon: DetectedBeacon?
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .previewAllEnvironments(withProfile: true)
}
