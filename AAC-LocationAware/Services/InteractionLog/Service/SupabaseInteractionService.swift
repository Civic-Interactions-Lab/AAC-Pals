import Foundation
import Supabase

final class SupabaseInteractionService: InteractionService {

    func log(userId: String, adminId: String, word: String, roomId: String) async {
        let row = InteractionLog.make(userId: userId, adminId: adminId, word: word, roomId: roomId).toRow()
        do {
            try await supabase.from("interaction_logs").insert(row).execute()
        } catch {
            print("[InteractionLog] Failed to sync: \(error.localizedDescription)")
        }
    }

    func fetchLogs(adminId: String, limit: Int = 100) async -> [InteractionLog] {
        do {
            let records: [InteractionLog.Record] = try await supabase
                .from("interaction_logs")
                .select()
                .eq("admin_id", value: adminId)
                .order("pressed_at", ascending: false)
                .limit(limit)
                .execute()
                .value
            return records.map(\.asInteractionLog)
        } catch {
            print("[InteractionLog] fetchLogs error: \(error.localizedDescription)")
            return []
        }
    }

    func fetchLogs(adminId: String, userId: String, limit: Int = 100) async -> [InteractionLog] {
        do {
            let records: [InteractionLog.Record] = try await supabase
                .from("interaction_logs")
                .select()
                .eq("admin_id", value: adminId)
                .eq("user_id", value: userId)
                .order("pressed_at", ascending: false)
                .limit(limit)
                .execute()
                .value
            return records.map(\.asInteractionLog)
        } catch {
            print("[InteractionLog] fetchLogs(userId) error: \(error.localizedDescription)")
            return []
        }
    }
}
