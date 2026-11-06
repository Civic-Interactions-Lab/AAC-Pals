import Foundation

enum BoardSection: String, Codable {
    case main
    case room
}

struct InteractionLog: Identifiable, Codable {
    let id: String
    let userId: String
    let adminId: String
    let word: String
    let roomId: String?
    let pressedAt: Date
    var userName: String?
    var roomLabel: String?
    var wordCategory: String?
    var boardSection: BoardSection?
    var beaconId: String?
    var beaconRssi: Int?
    var deviceId: String?
    var deviceName: String?
    var deviceModel: String?
    var osVersion: String?
    var appVersion: String?

    static func make(
        userId: String,
        userName: String,
        adminId: String,
        word: String,
        roomId: String?,
        roomLabel: String?,
        boardSection: BoardSection,
        beacon: DetectedBeacon?,
        device: DeviceInfo
    ) -> InteractionLog {
        InteractionLog(
            id: UUID().uuidString,
            userId: userId,
            adminId: adminId,
            word: word,
            roomId: roomId,
            pressedAt: Date(),
            userName: userName,
            roomLabel: roomLabel,
            wordCategory: fitzgeraldCategory(for: word).name,
            boardSection: boardSection,
            beaconId: beacon?.pairingId,
            beaconRssi: beacon?.rssi,
            deviceId: device.id,
            deviceName: device.name,
            deviceModel: device.model,
            osVersion: device.osVersion,
            appVersion: device.appVersion
        )
    }

    func toRow() -> InsertRow {
        InsertRow(
            userId: userId,
            adminId: adminId,
            word: word,
            roomId: roomId,
            pressedAt: pressedAt,
            userName: userName,
            roomLabel: roomLabel,
            wordCategory: wordCategory,
            boardSection: boardSection,
            beaconId: beaconId,
            beaconRssi: beaconRssi,
            deviceId: deviceId,
            deviceName: deviceName,
            deviceModel: deviceModel,
            osVersion: osVersion,
            appVersion: appVersion
        )
    }

    struct InsertRow: Encodable {
        let userId: String
        let adminId: String
        let word: String
        let roomId: String?
        let pressedAt: Date
        let userName: String?
        let roomLabel: String?
        let wordCategory: String?
        let boardSection: BoardSection?
        let beaconId: String?
        let beaconRssi: Int?
        let deviceId: String?
        let deviceName: String?
        let deviceModel: String?
        let osVersion: String?
        let appVersion: String?

        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case adminId = "admin_id"
            case word
            case roomId = "room_id"
            case pressedAt = "pressed_at"
            case userName = "user_name"
            case roomLabel = "room_label"
            case wordCategory = "word_category"
            case boardSection = "board_section"
            case beaconId = "beacon_id"
            case beaconRssi = "beacon_rssi"
            case deviceId = "device_id"
            case deviceName = "device_name"
            case deviceModel = "device_model"
            case osVersion = "os_version"
            case appVersion = "app_version"
        }
    }

    struct Record: Decodable {
        let id: String
        let userId: String
        let adminId: String
        let word: String
        let roomId: String?
        let pressedAt: Date
        let userName: String?
        let roomLabel: String?
        let wordCategory: String?
        let boardSection: BoardSection?
        let beaconId: String?
        let beaconRssi: Int?
        let deviceId: String?
        let deviceName: String?
        let deviceModel: String?
        let osVersion: String?
        let appVersion: String?

        enum CodingKeys: String, CodingKey {
            case id
            case userId = "user_id"
            case adminId = "admin_id"
            case word
            case roomId = "room_id"
            case pressedAt = "pressed_at"
            case userName = "user_name"
            case roomLabel = "room_label"
            case wordCategory = "word_category"
            case boardSection = "board_section"
            case beaconId = "beacon_id"
            case beaconRssi = "beacon_rssi"
            case deviceId = "device_id"
            case deviceName = "device_name"
            case deviceModel = "device_model"
            case osVersion = "os_version"
            case appVersion = "app_version"
        }

        var asInteractionLog: InteractionLog {
            InteractionLog(
                id: id,
                userId: userId,
                adminId: adminId,
                word: word,
                roomId: roomId,
                pressedAt: pressedAt,
                userName: userName,
                roomLabel: roomLabel,
                wordCategory: wordCategory,
                boardSection: boardSection,
                deviceId: deviceId,
                deviceName: deviceName,
                deviceModel: deviceModel,
                osVersion: osVersion,
                appVersion: appVersion
            )
        }
    }
}
