import Foundation
import Observation

@MainActor
@Observable
final class InteractionManager {
    private let service: InteractionService

    private(set) var logs: [InteractionLog] = []
    private(set) var analytics: AdminAnalytics = AdminAnalytics()
    private(set) var isLoading = false

    init(service: InteractionService) {
        self.service = service
    }

    func logWord(_ word: Word, user: UserProfile, adminId: String, room: Room?, beacon: DetectedBeacon?, section: BoardSection) {
        let entry = InteractionLog.make(
            userId: user.id,
            userName: user.displayName,
            adminId: adminId,
            word: word.label,
            roomId: room?.id,
            roomLabel: room?.label,
            boardSection: section,
            beacon: room == nil ? nil : beacon,
            device: .current
        )
        Task {
            await service.log(entry)
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

    func loadAnalytics(adminId: String, userId: String? = nil, limit: Int = 500) async {
        isLoading = true
        let fetched: [InteractionLog]
        if let userId {
            fetched = await service.fetchLogs(adminId: adminId, userId: userId, limit: limit)
        } else {
            fetched = await service.fetchLogs(adminId: adminId, limit: limit)
        }
        logs = fetched
        analytics = AdminAnalytics.compute(from: fetched)
        isLoading = false
    }
}
