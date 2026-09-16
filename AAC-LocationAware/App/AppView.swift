import SwiftUI

struct AppView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager

    var body: some View {
        Group {
            if authManager.isLoading {
                ProgressView()
            } else if !authManager.isSignedIn {
                Text("Login")
            } else {
                BoardView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task { await authManager.loadCurrentUser() }
        .task(id: userManager.profiles.count) { await restoreActiveUser() }
        .preferredColorScheme(.light)
    }

    private func restoreActiveUser() async {
        guard userManager.activeProfile == nil,
              let savedId = UserDefaults.standard.string(forKey: kActiveUserIdKey),
              let match = userManager.profiles.first(where: { $0.id == savedId })
        else { return }
        userManager.selectProfile(match)
    }
}

// MARK: - Preview Helper

extension View {
    func previewAllEnvironments(
        isSignedIn: Bool = true,
        authError: String? = nil,
        withProfile: Bool = false,
        adminService: AdminService = MockAdminService(),
        preloadRooms: Bool = false
    ) -> some View {
        let authManager = AuthManager(service: MockAuthService(authUser: isSignedIn ? .mock : nil))
        if let authError { authManager.setError(authError) }

        let userManager = UserManager(service: MockUserService())
        if withProfile { userManager.selectProfile(UserProfile.mocks[0]) }

        let adminManager = AdminManager(service: adminService)

        return self
            .environment(authManager)
            .environment(userManager)
            .environment(PictogramManager(service: MockPictogramService()))
            .environment(BeaconManager(service: MockBeaconService()))
            .environment(InteractionManager(service: MockInteractionService()))
            .environment(adminManager)
            .task { await userManager.loadProfiles(adminId: "preview-admin") }
            .task { if preloadRooms { await adminManager.loadRooms(adminId: "preview-admin") } }
    }
}

#Preview("Sign in flow") {
    @Previewable @State var authManager = AuthManager(service: MockAuthService(authUser: nil, delay: 0.5))
    @Previewable @State var userManager = UserManager(service: MockUserService(profiles: []))
    AppView()
        .environment(authManager)
        .environment(userManager)
        .environment(PictogramManager(service: MockPictogramService()))
        .environment(BeaconManager(service: MockBeaconService()))
        .environment(InteractionManager(service: MockInteractionService()))
        .environment(AdminManager(service: MockAdminService()))
}

#Preview("Profile selector") {
    let authManager = AuthManager(service: MockAuthService(authUser: .mock))
    let userManager = UserManager(service: MockUserService())
    AppView()
        .environment(authManager)
        .environment(userManager)
        .environment(PictogramManager(service: MockPictogramService()))
        .environment(BeaconManager(service: MockBeaconService()))
        .environment(InteractionManager(service: MockInteractionService()))
        .environment(AdminManager(service: MockAdminService()))
}

#Preview("Signed in") {
    AppView().previewAllEnvironments(isSignedIn: true)
}

#Preview("Signed out") {
    AppView().previewAllEnvironments(isSignedIn: false)
}
