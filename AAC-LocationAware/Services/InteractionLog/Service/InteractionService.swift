import Foundation

protocol InteractionService {
    func log(userId: String, adminId: String, word: String, roomId: String) async
    func fetchLogs(adminId: String, limit: Int) async -> [InteractionLog]
    func fetchLogs(adminId: String, userId: String, limit: Int) async -> [InteractionLog]
}
