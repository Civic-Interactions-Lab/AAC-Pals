import Foundation
import Supabase

struct SupabaseUserService: UserService {
    func loadProfiles(adminId: String) async -> [UserProfile] {
        do {
            let rows: [UserProfile.Record] = try await supabase
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

    func addProfile(displayName: String, passcode: String, adminId: String) async -> UserProfile? {
        let row = UserProfile.makeNew(displayName: displayName, passcode: passcode).toRow(adminId: adminId)
        do {
            let created: UserProfile.Record = try await supabase
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

    func updateProfile(id: String, displayName: String, passcode: String) async {
        struct Payload: Encodable { let displayName: String; let passcode: String
            enum CodingKeys: String, CodingKey { case displayName = "display_name"; case passcode }
        }
        do {
            try await supabase
                .from("user_profiles")
                .update(Payload(displayName: displayName, passcode: passcode))
                .eq("id", value: id)
                .execute()
        } catch { print("SupabaseUserService.updateProfile error:", error) }
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
