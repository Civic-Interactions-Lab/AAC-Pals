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

    func toRecord(adminId: String) -> Record {
        Record(id: id, displayName: displayName, role: role.rawValue, adminId: adminId)
    }

    static var mocks: [UserProfile] {
        [
            UserProfile(id: "mock-user-1", displayName: "Alex", role: .user),
            UserProfile(id: "mock-user-2", displayName: "Jordan", role: .user),
        ]
    }

    struct Record: Codable {
        let id: String
        var displayName: String
        var role: String
        var adminId: String?

        enum CodingKeys: String, CodingKey {
            case id
            case displayName = "display_name"
            case role
            case adminId = "admin_id"
        }

        init(id: String, displayName: String, role: String, adminId: String? = nil) {
            self.id = id
            self.displayName = displayName
            self.role = role
            self.adminId = adminId
        }

        var asUserProfile: UserProfile {
            UserProfile(id: id, displayName: displayName, role: UserRole(rawValue: role) ?? .user)
        }
    }
}
