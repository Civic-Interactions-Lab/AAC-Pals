import Foundation

struct Room: Identifiable, Equatable {
    let id: String
    let adminId: String
    var label: String

    struct Insert: Encodable {
        let adminId: String
        let label: String

        enum CodingKeys: String, CodingKey {
            case adminId = "admin_id"
            case label
        }
    }

    struct Record: Decodable {
        let id: String
        let adminId: String
        let label: String

        enum CodingKeys: String, CodingKey {
            case id
            case adminId = "admin_id"
            case label
        }

        var asRoom: Room {
            Room(id: id, adminId: adminId, label: label)
        }
    }

    static let mocks: [Room] = [
        Room(id: "room-kitchen",  adminId: "admin-1", label: "Kitchen"),
        Room(id: "room-bathroom", adminId: "admin-1", label: "Bathroom"),
        Room(id: "room-bedroom",  adminId: "admin-1", label: "Bedroom"),
    ]
}
