import Foundation

struct AppBeacon: Identifiable, Equatable, Codable {
    let id: String
    let adminId: String
    let roomId: String
    let beaconUuid: String
    var label: String
    var radius: Double

    static let mockPairings: [String: [AppBeacon]] = [
        "room-kitchen": [AppBeacon(id: "beacon-kitchen", adminId: "admin-1", roomId: "room-kitchen", beaconUuid: "Kitchen", label: "Kitchen beacon", radius: 2.0)]
    ]
}
