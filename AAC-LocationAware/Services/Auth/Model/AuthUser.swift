import Foundation

struct AuthUser {
    let id: String
    let email: String

    static var mock: AuthUser {
        AuthUser(id: "mock-admin-id", email: "admin@aac.dev")
    }
}
