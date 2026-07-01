import Foundation

struct MockUserService: UserService {
    var profiles: [UserProfile]

    init(profiles: [UserProfile] = UserProfile.mocks) {
        self.profiles = profiles
    }

    func loadProfiles() async -> [UserProfile] { profiles }
    func saveProfiles(_ profiles: [UserProfile]) async {}
}
