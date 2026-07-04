import Foundation

enum UserRole: String, Codable {
    case user
    case admin
}

struct UserProfile: Identifiable, Codable, Equatable {
    let id: String
    var displayName: String
    var role: UserRole
    var passcode: String

    static func makeNew(displayName: String, passcode: String) -> UserProfile {
        UserProfile(id: UUID().uuidString, displayName: displayName, role: .user, passcode: passcode)
    }

    func toRow(adminId: String) -> Record {
        Record(id: id, displayName: displayName, role: role.rawValue, adminId: adminId, passcode: passcode)
    }

    static var mocks: [UserProfile] {
        [
            UserProfile(id: "mock-user-1", displayName: "Alex", role: .user, passcode: "1234"),
            UserProfile(id: "mock-user-2", displayName: "Jordan", role: .user, passcode: "5678"),
        ]
    }

    struct Record: Codable {
        let id: String
        var displayName: String
        var role: String
        var adminId: String?
        var passcode: String

        enum CodingKeys: String, CodingKey {
            case id
            case displayName = "display_name"
            case role
            case adminId = "admin_id"
            case passcode
        }

        init(id: String, displayName: String, role: String, adminId: String? = nil, passcode: String = "0000") {
            self.id = id
            self.displayName = displayName
            self.role = role
            self.adminId = adminId
            self.passcode = passcode
        }

        var asUserProfile: UserProfile {
            UserProfile(id: id, displayName: displayName, role: UserRole(rawValue: role) ?? .user, passcode: passcode)
        }
    }
}
