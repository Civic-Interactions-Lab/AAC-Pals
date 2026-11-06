import Foundation

struct MockAuthService: AuthService {
    let authUser: AuthUser?
    let delay: Double
    let showError: Bool

    init(authUser: AuthUser? = nil, delay: Double = 0.5, showError: Bool = false) {
        self.authUser = authUser
        self.delay = delay
        self.showError = showError
    }

    func signUp(email: String, password: String) async throws -> AuthUser {
        try await Task.sleep(for: .seconds(delay))
        if showError { throw AuthError.unknown }
        return AuthUser(id: UUID().uuidString, email: email)
    }

    func signIn(email: String, password: String) async throws -> AuthUser {
        try await Task.sleep(for: .seconds(delay))
        // Mock accepts admin / admin
        guard email == "admin" || email == "admin@aac.dev", password == "admin" else {
            throw AuthError.invalidCredentials
        }
        return .mock
    }

    func signOut() async throws {
        try await Task.sleep(for: .seconds(delay))
    }

    func getCurrentUser() async -> AuthUser? {
        authUser
    }
}

enum AuthError: LocalizedError {
    case invalidCredentials
    case emailConfirmationRequired
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Invalid email or password."
        case .emailConfirmationRequired: return "Account created. Check your email to confirm it, then sign in."
        case .unknown: return "Something went wrong. Please try again."
        }
    }
}
