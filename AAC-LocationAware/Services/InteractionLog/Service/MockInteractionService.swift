import Foundation

final class MockInteractionService: InteractionService {
    private(set) var logs: [InteractionLog] = []

    func log(userId: String, adminId: String, word: String, roomId: String) async {
        let entry = InteractionLog.make(userId: userId, adminId: adminId, word: word, roomId: roomId)
        logs.append(entry)
        print("[MockInteraction] \(word) — room: \(roomId) user: \(userId)")
    }

    func fetchLogs(adminId: String, limit: Int = 100) async -> [InteractionLog] {
        Array(logs.filter { $0.adminId == adminId }.prefix(limit))
    }

    func fetchLogs(adminId: String, userId: String, limit: Int = 100) async -> [InteractionLog] {
        Array(logs.filter { $0.adminId == adminId && $0.userId == userId }.prefix(limit))
    }
}
