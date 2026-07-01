import Foundation
import Supabase

let supabase = SupabaseClient(
    supabaseURL: Config.Supabase.url,
    supabaseKey: Config.Supabase.anonKey
)

struct SupabaseAuthService: AuthService {
    func signUp(email: String, password: String) async throws -> AuthUser {
        let session = try await supabase.auth.signUp(email: email, password: password)
        return AuthUser(id: session.user.id.uuidString, email: session.user.email ?? "")
    }

    func signIn(email: String, password: String) async throws -> AuthUser {
        let session = try await supabase.auth.signIn(email: email, password: password)
        return AuthUser(id: session.user.id.uuidString, email: session.user.email ?? "")
    }

    func signOut() async throws {
        try await supabase.auth.signOut()
    }

    func getCurrentUser() async -> AuthUser? {
        guard let user = try? await supabase.auth.session.user else { return nil }
        return AuthUser(id: user.id.uuidString, email: user.email ?? "")
    }
}
