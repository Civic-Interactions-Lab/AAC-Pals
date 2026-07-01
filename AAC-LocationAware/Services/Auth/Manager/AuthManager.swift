import Foundation

@MainActor
@Observable
class AuthManager {
    private let service: AuthService

    private(set) var currentUser: AuthUser?
    private(set) var isLoading = true
    private(set) var error: String?

    var isSignedIn: Bool { currentUser != nil }

    init(service: AuthService) {
        self.service = service
    }

    func loadCurrentUser() async {
        isLoading = true
        currentUser = await service.getCurrentUser()
        isLoading = false
    }

    func signUp(email: String, password: String) async {
        error = nil
        isLoading = true
        do {
            currentUser = try await service.signUp(email: email, password: password)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func signIn(email: String, password: String) async {
        error = nil
        isLoading = true
        do {
            currentUser = try await service.signIn(email: email, password: password)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func setError(_ message: String) {
        error = message
    }

    func signOut() async {
        isLoading = true
        do {
            try await service.signOut()
            currentUser = nil
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
