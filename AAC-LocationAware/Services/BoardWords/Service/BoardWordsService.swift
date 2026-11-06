import Foundation

protocol BoardWordsService {
    func loadSetup(profileId: String) async -> BoardSetup?
    func saveSetup(_ setup: BoardSetup, profileId: String) async
    func loadMyDefault() async -> [String]?
    func saveMyDefault(_ labels: [String]) async
    func deleteMyDefault() async
}
