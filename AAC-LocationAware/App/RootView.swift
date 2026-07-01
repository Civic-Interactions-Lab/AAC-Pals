import SwiftUI

struct RootView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager

    var body: some View {
        Group {
            if authManager.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(hex: "#FFF7EE"))
            } else if !authManager.isSignedIn {
                LoginView()
            } else if userManager.activeProfile == nil {
                UserSelectorView()
            } else {
                BoardView()
            }
        }
        .task {
            await authManager.loadCurrentUser()
            await userManager.loadProfiles()
        }
    }
}

#Preview("Sign in flow") {
    @Previewable @State var authManager = AuthManager(service: MockAuthService(authUser: nil, delay: 0.5))
    @Previewable @State var userManager = UserManager(service: MockUserService(profiles: []))
    RootView()
        .environment(authManager)
        .environment(userManager)
        .environment(PictogramManager(service: MockPictogramService()))
}

#Preview("Profile selector") {
    let authManager = AuthManager(service: MockAuthService(authUser: .mock))
    let userManager = UserManager(service: MockUserService())
    RootView()
        .environment(authManager)
        .environment(userManager)
        .environment(PictogramManager(service: MockPictogramService()))
}
