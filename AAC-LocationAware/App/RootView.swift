import SwiftUI

struct RootView: View {
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        Group {
            if authManager.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(hex: "#F5F6FA"))
            } else if authManager.isSignedIn {
                BoardView()
            } else {
                LoginView()
            }
        }
        .task { await authManager.loadCurrentUser() }
    }
}

#Preview("Signed in") {
    RootView()
        .previewAllEnvironments(isSignedIn: true)
}

#Preview("Signed out") {
    RootView()
        .previewAllEnvironments(isSignedIn: false)
}

#Preview("Interactive — sign in/out") {
    @Previewable @State var authManager = AuthManager(service: MockAuthService(authUser: nil, delay: 0.5))
    RootView()
        .environment(authManager)
        .environment(PictogramManager(service: MockPictogramService()))
}
