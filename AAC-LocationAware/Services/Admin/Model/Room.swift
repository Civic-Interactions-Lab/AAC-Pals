import Foundation

struct Room: Identifiable, Equatable {
    let id: String
    let adminId: String
    var label: String
    var roomId: String

    struct Insert: Encodable {
        let adminId: String
        let label: String
        let roomId: String

        enum CodingKeys: String, CodingKey {
            case adminId = "admin_id"
            case label
            case roomId = "room_id"
        }
    }

    struct Record: Decodable {
        let id: String
        let adminId: String
        let label: String
        let roomId: String

        enum CodingKeys: String, CodingKey {
            case id
            case adminId = "admin_id"
            case label
            case roomId = "room_id"
        }

        var asRoom: Room {
            Room(id: id, adminId: adminId, label: label, roomId: roomId)
        }
    }

    static let mocks: [Room] = [
        Room(id: "room-kitchen",  adminId: "admin-1", label: "Kitchen",  roomId: "kitchen"),
        Room(id: "room-bathroom", adminId: "admin-1", label: "Bathroom", roomId: "bathroom"),
        Room(id: "room-bedroom",  adminId: "admin-1", label: "Bedroom",  roomId: "bedroom"),
    ]
}
