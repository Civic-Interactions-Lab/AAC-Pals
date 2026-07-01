import Foundation
import Supabase

struct SupabaseUserService: UserService {
    func loadProfiles(adminId: String) async -> [UserProfile] {
        do {
            let rows: [UserProfileRow] = try await supabase
                .from("user_profiles")
                .select()
                .eq("admin_id", value: adminId)
                .eq("role", value: "user")
                .execute()
                .value
            return rows.map(\.asUserProfile)
        } catch {
            print("SupabaseUserService.loadProfiles error:", error)
            return []
        }
    }

    func addProfile(displayName: String, adminId: String) async -> UserProfile? {
        let row = UserProfileRow(
            id: UUID().uuidString,
            displayName: displayName,
            role: "user",
            adminId: adminId
        )
        do {
            let created: UserProfileRow = try await supabase
                .from("user_profiles")
                .insert(row)
                .select()
                .single()
                .execute()
                .value
            return created.asUserProfile
        } catch {
            print("SupabaseUserService.addProfile error:", error)
            return nil
        }
    }

    func renameProfile(id: String, displayName: String) async {
        do {
            try await supabase
                .from("user_profiles")
                .update(["display_name": displayName])
                .eq("id", value: id)
                .execute()
        } catch {
            print("SupabaseUserService.renameProfile error:", error)
        }
    }

    func deleteProfile(id: String) async {
        do {
            try await supabase
                .from("user_profiles")
                .delete()
                .eq("id", value: id)
                .execute()
        } catch {
            print("SupabaseUserService.deleteProfile error:", error)
        }
    }
}

// MARK: - Row mapping

private struct UserProfileRow: Codable {
    let id: String
    var displayName: String
    var role: String
    var adminId: String?

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case role
        case adminId = "admin_id"
    }

    init(id: String, displayName: String, role: String, adminId: String? = nil) {
        self.id = id
        self.displayName = displayName
        self.role = role
        self.adminId = adminId
    }

    var asUserProfile: UserProfile {
        UserProfile(
            id: id,
            displayName: displayName,
            role: UserRole(rawValue: role) ?? .user
        )
    }
}
