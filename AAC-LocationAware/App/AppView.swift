import SwiftUI

struct AppView: View {
    var body: some View {
        RootView()
    }
}

// MARK: - Preview Helper

extension View {
    func previewAllEnvironments(isSignedIn: Bool = true, authError: String? = nil) -> some View {
        let authManager = AuthManager(service: MockAuthService(
            authUser: isSignedIn ? .mock : nil
        ))
        if let authError {
            authManager.setError(authError)
        }
        return self
            .environment(authManager)
            .environment(PictogramManager(service: MockPictogramService()))
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
