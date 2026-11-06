import Foundation

@MainActor
@Observable
class AuthManager {
    private let service: AuthService

    private(set) var currentUser: AuthUser?
    private(set) var isLoading = true
    private(set) var error: String?
    private(set) var notice: String?

    var isSignedIn: Bool { currentUser != nil }

    init(service: AuthService) {
        self.service = service
    }

    func loadCurrentUser() async {
        isLoading = true
        currentUser = await service.getCurrentUser()
        isLoading = false
    }

    func signIn(email: String, password: String) async {
        error = nil
        notice = nil
        isLoading = true
        do {
            currentUser = try await service.signIn(email: email, password: password)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    @discardableResult
    func signUp(email: String, password: String) async -> Bool {
        error = nil
        notice = nil
        isLoading = true
        defer { isLoading = false }
        do {
            currentUser = try await service.signUp(email: email, password: password)
            return true
        } catch AuthError.emailConfirmationRequired {
            notice = AuthError.emailConfirmationRequired.errorDescription
            return true
        } catch {
            self.error = error.localizedDescription
            return false
        }
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

    func setError(_ message: String) {
        error = message
    }

    func clearMessages() {
        error = nil
        notice = nil
    }
}
