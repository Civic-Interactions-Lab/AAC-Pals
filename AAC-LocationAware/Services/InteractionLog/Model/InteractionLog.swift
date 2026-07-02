import Foundation

struct InteractionLog: Identifiable, Codable {
    let id: String
    let userId: String
    let adminId: String
    let word: String
    let roomId: String
    let pressedAt: Date

    static func make(userId: String, adminId: String, word: String, roomId: String) -> InteractionLog {
        InteractionLog(
            id: UUID().uuidString,
            userId: userId,
            adminId: adminId,
            word: word,
            roomId: roomId,
            pressedAt: Date()
        )
    }

    func toRow() -> InsertRow {
        InsertRow(userId: userId, adminId: adminId, word: word, roomId: roomId, pressedAt: pressedAt)
    }

    struct InsertRow: Encodable {
        let userId: String
        let adminId: String
        let word: String
        let roomId: String
        let pressedAt: Date

        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case adminId = "admin_id"
            case word
            case roomId = "room_id"
            case pressedAt = "pressed_at"
        }
    }

    struct Record: Decodable {
        let id: String
        let userId: String
        let adminId: String
        let word: String
        let roomId: String
        let pressedAt: Date

        enum CodingKeys: String, CodingKey {
            case id
            case userId = "user_id"
            case adminId = "admin_id"
            case word
            case roomId = "room_id"
            case pressedAt = "pressed_at"
        }

        var asInteractionLog: InteractionLog {
            InteractionLog(id: id, userId: userId, adminId: adminId, word: word, roomId: roomId, pressedAt: pressedAt)
        }
    }
}
