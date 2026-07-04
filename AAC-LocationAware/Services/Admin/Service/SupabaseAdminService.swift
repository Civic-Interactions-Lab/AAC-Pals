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
            return []
        }
    }

    func addRoom(label: String, adminId: String) async -> Room? {
        let insert = Room.Insert(adminId: adminId, label: label)
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

    func updateRoom(id: String, label: String) async {
        do {
            try await supabase
                .from("rooms")
                .update(["label": label])
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

    // MARK: - Beacons

    func fetchAllBeacons(adminId: String) async -> [AppBeacon] {
        do {
            let records: [AppBeacon.Record] = try await supabase
                .from("beacons")
                .select()
                .eq("admin_id", value: adminId)
                .execute()
                .value
            return records.map(\.asBeacon)
        } catch {
            print("[AdminService] fetchAllBeacons error: \(error)")
            return []
        }
    }

    func fetchBeacons(roomId: String) async -> [AppBeacon] {
        do {
            let records: [AppBeacon.Record] = try await supabase
                .from("beacons")
                .select()
                .eq("room_id", value: roomId)
                .execute()
                .value
            return records.map(\.asBeacon)
        } catch {
            print("[AdminService] fetchBeacons error: \(error)")
            return []
        }
    }

    func addBeacon(beaconUuid: String, label: String, radius: Double, roomId: String, adminId: String) async -> AppBeacon? {
        let insert = AppBeacon.Insert(adminId: adminId, roomId: roomId, beaconUuid: beaconUuid, label: label, radius: radius)
        do {
            let record: AppBeacon.Record = try await supabase
                .from("beacons")
                .insert(insert)
                .select()
                .single()
                .execute()
                .value
            return record.asBeacon
        } catch {
            print("[AdminService] addBeacon error: \(error)")
            return nil
        }
    }

    func updateBeacon(id: String, label: String, radius: Double) async {
        struct Payload: Encodable {
            let label: String
            let radius: Double
        }
        do {
            try await supabase
                .from("beacons")
                .update(Payload(label: label, radius: radius))
                .eq("id", value: id)
                .execute()
        } catch {
            print("[AdminService] updateBeacon error: \(error)")
        }
    }

    func deleteBeacon(id: String) async {
        do {
            try await supabase
                .from("beacons")
                .delete()
                .eq("id", value: id)
                .execute()
        } catch {
            print("[AdminService] deleteBeacon error: \(error)")
        }
    }
}
