import Foundation

enum UserRole: String, Codable {
    case user
    case admin
}

struct UserProfile: Identifiable, Codable, Equatable {
    let id: String
    var displayName: String
    var role: UserRole

    static func makeNew(displayName: String) -> UserProfile {
        UserProfile(id: UUID().uuidString, displayName: displayName, role: .user)
    }

    static var mocks: [UserProfile] {
        [
            UserProfile(id: "mock-user-1", displayName: "Alex", role: .user),
            UserProfile(id: "mock-user-2", displayName: "Jordan", role: .user),
        ]
    }
}
