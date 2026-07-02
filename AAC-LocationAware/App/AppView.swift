import SwiftUI

struct AppView: View {
    var body: some View {
        RootView()
            .preferredColorScheme(.light)
    }
}

// MARK: - Preview Helper

extension View {
    func previewAllEnvironments(
        isSignedIn: Bool = true,
        authError: String? = nil,
        withProfile: Bool = false
    ) -> some View {
        let authManager = AuthManager(service: MockAuthService(authUser: isSignedIn ? .mock : nil))
        if let authError { authManager.setError(authError) }

        let userManager = UserManager(service: MockUserService())
        if withProfile { userManager.selectProfile(UserProfile.mocks[0]) }

        return self
            .environment(authManager)
            .environment(userManager)
            .environment(PictogramManager(service: MockPictogramService()))
            .environment(BeaconManager(service: MockBeaconService()))
            .environment(InteractionManager(service: MockInteractionService()))
            .task { await userManager.loadProfiles(adminId: "preview-admin") }
    }
}

#Preview("Signed in") {
    AppView()
        .previewAllEnvironments(isSignedIn: true)
}

#Preview("Signed out") {
    AppView()
        .previewAllEnvironments(isSignedIn: false)
}
