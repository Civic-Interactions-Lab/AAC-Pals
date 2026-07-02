import Foundation
import Observation

@MainActor
@Observable
final class InteractionManager {
    private let service: InteractionService

    private(set) var logs: [InteractionLog] = []
    private(set) var isLoading = false

    init(service: InteractionService) {
        self.service = service
    }

    func logWord(_ word: Word, userId: String, adminId: String, roomId: String) {
        Task {
            await service.log(userId: userId, adminId: adminId, word: word.label, roomId: roomId)
        }
    }

    func fetchLogs(adminId: String, limit: Int = 100) async {
        isLoading = true
        logs = await service.fetchLogs(adminId: adminId, limit: limit)
        isLoading = false
    }

    func fetchLogs(adminId: String, userId: String, limit: Int = 100) async {
        isLoading = true
        logs = await service.fetchLogs(adminId: adminId, userId: userId, limit: limit)
        isLoading = false
    }
}
