import Foundation

final class MockInteractionService: InteractionService {
    private(set) var logs: [InteractionLog] = []

    func log(_ entry: InteractionLog) async {
        logs.insert(entry, at: 0)
        print("[MockInteraction] \(entry.word) (\(entry.wordCategory ?? "-"), \(entry.boardSection?.rawValue ?? "-")) — \(entry.userName ?? entry.userId) in \(entry.roomLabel ?? "no room") via \(entry.beaconId ?? "no beacon") on \(entry.deviceName ?? "-") \(entry.deviceModel ?? "")")
    }

    func fetchLogs(adminId: String, limit: Int = 100) async -> [InteractionLog] {
        Array(logs.filter { $0.adminId == adminId }.prefix(limit))
    }

    func fetchLogs(adminId: String, userId: String, limit: Int = 100) async -> [InteractionLog] {
        Array(logs.filter { $0.adminId == adminId && $0.userId == userId }.prefix(limit))
    }
}
