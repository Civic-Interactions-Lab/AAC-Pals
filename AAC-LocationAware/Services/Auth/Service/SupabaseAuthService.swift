import Foundation

// TODO: implement with Supabase Swift SDK
struct SupabaseAuthService: AuthService {
    func signIn(email: String, password: String) async throws -> AuthUser {
        throw AuthError.unknown
    }

    func signOut() async throws {
        throw AuthError.unknown
    }

    func getCurrentUser() async -> AuthUser? {
        nil
    }
}
