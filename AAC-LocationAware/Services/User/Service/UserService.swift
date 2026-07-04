import Foundation

protocol UserService {
    func loadProfiles(adminId: String) async -> [UserProfile]
    func addProfile(displayName: String, passcode: String, adminId: String) async -> UserProfile?
    func renameProfile(id: String, displayName: String) async
    func updateProfile(id: String, displayName: String, passcode: String) async
    func deleteProfile(id: String) async
}
