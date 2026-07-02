import Foundation
import Supabase

final class SupabaseAdminService: AdminService {

    // MARK: - Rooms

    func fetchRooms(adminId: String) async -> [Room] {
        do {
            let records: [Room.Record] = try await supabase
                .from("rooms")
                .select()
                .eq("admin_id", value: adminId)
                .order("label", ascending: true)
                .execute()
                .value
            return records.map(\.asRoom)
        } catch {
            print("[AdminService] fetchRooms error: \(error)")
            print("[AdminService] fetchRooms adminId was: \(adminId)")
            return []
        }
    }

    func addRoom(label: String, roomId: String, adminId: String) async -> Room? {
        let insert = Room.Insert(adminId: adminId, label: label, roomId: roomId)
        do {
            let record: Room.Record = try await supabase
                .from("rooms")
                .insert(insert)
                .select()
                .single()
                .execute()
                .value
            return record.asRoom
        } catch {
            print("[AdminService] addRoom error: \(error)")
            return nil
        }
    }

    func updateRoom(id: String, label: String, roomId: String) async {
        do {
            try await supabase
                .from("rooms")
                .update(["label": label, "room_id": roomId])
                .eq("id", value: id)
                .execute()
        } catch {
            print("[AdminService] updateRoom error: \(error)")
        }
    }

    func deleteRoom(id: String) async {
        do {
            try await supabase
                .from("rooms")
                .delete()
                .eq("id", value: id)
                .execute()
        } catch {
            print("[AdminService] deleteRoom error: \(error)")
        }
    }

    // MARK: - Words

    func fetchWords(roomId: String) async -> [RoomWord] {
        do {
            let records: [RoomWord.Record] = try await supabase
                .from("room_words")
                .select()
                .eq("room_id", value: roomId)
                .order("position", ascending: true)
                .execute()
                .value
            return records.map(\.asRoomWord)
        } catch {
            print("[AdminService] fetchWords error: \(error)")
            return []
        }
    }

    func addWord(label: String, category: String, position: Int, roomId: String, adminId: String) async -> RoomWord? {
        let insert = RoomWord.make(label: label, category: category, position: position, roomId: roomId, adminId: adminId).toInsert()
        do {
            let record: RoomWord.Record = try await supabase
                .from("room_words")
                .insert(insert)
                .select()
                .single()
                .execute()
                .value
            return record.asRoomWord
        } catch {
            print("[AdminService] addWord error: \(error)")
            return nil
        }
    }

    func updateWord(id: String, label: String, category: String) async {
        do {
            try await supabase
                .from("room_words")
                .update(["label": label, "category": category])
                .eq("id", value: id)
                .execute()
        } catch {
            print("[AdminService] updateWord error: \(error)")
        }
    }

    func deleteWord(id: String) async {
        do {
            try await supabase
                .from("room_words")
                .delete()
                .eq("id", value: id)
                .execute()
        } catch {
            print("[AdminService] deleteWord error: \(error)")
        }
    }
}
