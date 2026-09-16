import Foundation
import Observation

let kActiveUserIdKey = "activeUserId"

@MainActor
@Observable
class UserManager {
    private let service: UserService

    private(set) var profiles: [UserProfile] = []
    private(set) var activeProfile: UserProfile?
    private(set) var activeAdminId: String?
    private(set) var isLoading = false

    init(service: UserService) {
        self.service = service
    }

    func clearProfiles() {
        profiles = []
    }

    func loadProfiles(adminId: String) async {
        isLoading = true
        activeAdminId = adminId
        profiles = await service.loadProfiles(adminId: adminId)
        isLoading = false
    }

    func selectProfile(_ profile: UserProfile) {
        activeProfile = profile
    }

    func exitProfile() {
        activeProfile = nil
    }

    func addProfile(displayName: String, adminId: String) async {
        guard let profile = await service.addProfile(displayName: displayName, adminId: adminId) else { return }
        profiles = await service.loadProfiles(adminId: adminId)
        _ = profile
    }

    func renameProfile(id: String, displayName: String, adminId: String) async {
        await service.renameProfile(id: id, displayName: displayName)
        profiles = await service.loadProfiles(adminId: adminId)
        if activeProfile?.id == id { activeProfile?.displayName = displayName }
    }

    func deleteProfile(id: String, adminId: String) async {
        await service.deleteProfile(id: id)
        profiles = await service.loadProfiles(adminId: adminId)
        if activeProfile?.id == id { activeProfile = nil }
    }
}
