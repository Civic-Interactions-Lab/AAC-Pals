import Foundation

private let kUserProfiles = "aac_user_profiles"

struct LocalUserService: UserService {
    func loadProfiles() async -> [UserProfile] {
        guard
            let data = UserDefaults.standard.data(forKey: kUserProfiles),
            let profiles = try? JSONDecoder().decode([UserProfile].self, from: data)
        else { return [] }
        return profiles
    }

    func saveProfiles(_ profiles: [UserProfile]) async {
        guard let data = try? JSONEncoder().encode(profiles) else { return }
        UserDefaults.standard.set(data, forKey: kUserProfiles)
    }
}
