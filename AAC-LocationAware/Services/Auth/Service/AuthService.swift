import Foundation

protocol AuthService: Sendable {
    func signIn(email: String, password: String) async throws -> AuthUser
    func signUp(email: String, password: String) async throws -> AuthUser
    func signOut() async throws
    func getCurrentUser() async -> AuthUser?
}
