import Foundation

protocol InteractionService {
    func log(_ entry: InteractionLog) async
    func fetchLogs(adminId: String, limit: Int) async -> [InteractionLog]
    func fetchLogs(adminId: String, userId: String, limit: Int) async -> [InteractionLog]
}
