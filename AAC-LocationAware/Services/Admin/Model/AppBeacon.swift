import Foundation

struct AppBeacon: Identifiable, Equatable {
    let id: String
    let adminId: String
    let roomId: String
    let beaconUuid: String
    var label: String
    var radius: Double

    struct Insert: Encodable {
        let adminId: String
        let roomId: String
        let beaconUuid: String
        let label: String
        let radius: Double

        enum CodingKeys: String, CodingKey {
            case adminId = "admin_id"
            case roomId = "room_id"
            case beaconUuid = "beacon_uuid"
            case label
            case radius
        }
    }

    struct Record: Decodable {
        let id: String
        let adminId: String
        let roomId: String
        let beaconUuid: String
        let label: String
        let radius: Double

        enum CodingKeys: String, CodingKey {
            case id
            case adminId = "admin_id"
            case roomId = "room_id"
            case beaconUuid = "beacon_uuid"
            case label
            case radius
        }

        var asBeacon: AppBeacon {
            AppBeacon(id: id, adminId: adminId, roomId: roomId, beaconUuid: beaconUuid, label: label, radius: radius)
        }
    }

    static func mocks(for roomId: String) -> [AppBeacon] {
        [AppBeacon(id: "beacon-\(roomId)-1", adminId: "admin-1", roomId: roomId, beaconUuid: "550E8400-E29B-41D4-A716-44665544000\(roomId.hashValue % 9)", label: "Main beacon", radius: 2.0)]
    }
}
