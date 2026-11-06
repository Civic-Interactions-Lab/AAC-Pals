import Foundation

struct Room: Identifiable, Hashable, Codable {
    let id: String
    let adminId: String
    var label: String

    static let mocks: [Room] = [
        Room(id: "room-kitchen",  adminId: "admin-1", label: "Kitchen"),
        Room(id: "room-bathroom", adminId: "admin-1", label: "Bathroom"),
        Room(id: "room-bedroom",  adminId: "admin-1", label: "Bedroom"),
    ]
}
