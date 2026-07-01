import Foundation
import Observation

@MainActor
@Observable
class UserManager {
    private let service: UserService

    private(set) var profiles: [UserProfile] = []
    private(set) var activeProfile: UserProfile?

    init(service: UserService) {
        self.service = service
    }

    func loadProfiles() async {
        profiles = await service.loadProfiles()
    }

    func selectProfile(_ profile: UserProfile) {
        activeProfile = profile
    }

    func exitProfile() {
        activeProfile = nil
    }

    func addProfile(displayName: String) async {
        let profile = UserProfile.makeNew(displayName: displayName)
        profiles.append(profile)
        await service.saveProfiles(profiles)
    }

    func renameProfile(id: String, displayName: String) async {
        guard let index = profiles.firstIndex(where: { $0.id == id }) else { return }
        profiles[index].displayName = displayName
        if activeProfile?.id == id { activeProfile?.displayName = displayName }
        await service.saveProfiles(profiles)
    }

    func deleteProfile(id: String) async {
        profiles.removeAll { $0.id == id }
        if activeProfile?.id == id { activeProfile = nil }
        await service.saveProfiles(profiles)
    }
}
