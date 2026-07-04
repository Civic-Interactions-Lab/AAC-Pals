import Foundation

struct MockUserService: UserService {
    private let initialProfiles: [UserProfile]

    init(profiles: [UserProfile] = UserProfile.mocks) {
        self.initialProfiles = profiles
    }

    func loadProfiles(adminId: String) async -> [UserProfile] { initialProfiles }

    func addProfile(displayName: String, passcode: String, adminId: String) async -> UserProfile? {
        UserProfile(id: UUID().uuidString, displayName: displayName, role: .user, passcode: passcode)
    }

    func renameProfile(id: String, displayName: String) async {}
    func updateProfile(id: String, displayName: String, passcode: String) async {}
    func deleteProfile(id: String) async {}
}
