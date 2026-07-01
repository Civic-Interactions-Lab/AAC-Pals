import Foundation

protocol UserService {
    func loadProfiles() async -> [UserProfile]
    func saveProfiles(_ profiles: [UserProfile]) async
}
