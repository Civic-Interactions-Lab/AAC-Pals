import Foundation

private let kUserProfiles = "aac_user_profiles"

struct LocalUserService: UserService {
    func loadProfiles(adminId: String) async -> [UserProfile] {
        guard
            let data = UserDefaults.standard.data(forKey: key(adminId)),
            let profiles = try? JSONDecoder().decode([UserProfile].self, from: data)
        else { return [] }
        return profiles
    }

    func addProfile(displayName: String, passcode: String, adminId: String) async -> UserProfile? {
        let profile = UserProfile(id: UUID().uuidString, displayName: displayName, role: .user, passcode: passcode)
        var profiles = await loadProfiles(adminId: adminId)
        profiles.append(profile)
        save(profiles, adminId: adminId)
        return profile
    }

    func renameProfile(id: String, displayName: String) async {}
    func updateProfile(id: String, displayName: String, passcode: String) async {}

    func deleteProfile(id: String) async {}

    private func key(_ adminId: String) -> String { "\(kUserProfiles)_\(adminId)" }

    private func save(_ profiles: [UserProfile], adminId: String) {
        guard let data = try? JSONEncoder().encode(profiles) else { return }
        UserDefaults.standard.set(data, forKey: key(adminId))
    }
}
