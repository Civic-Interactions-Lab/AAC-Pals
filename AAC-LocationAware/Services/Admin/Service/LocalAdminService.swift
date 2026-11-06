import Foundation

private let kLocalAdminData = "aac_local_admin_data"

final class LocalAdminService: AdminService {
    private struct Store: Codable {
        var rooms: [Room] = []
        var words: [String: [RoomWord]] = [:]
        var beacons: [String: [AppBeacon]] = [:]
    }

    private var store: Store

    init(seedIfEmpty seed: Bool = false) {
        if let data = UserDefaults.standard.data(forKey: kLocalAdminData),
           let saved = try? JSONDecoder().decode(Store.self, from: data) {
            store = saved
        } else if seed {
            store = Store(
                rooms: Room.mocks,
                words: Dictionary(uniqueKeysWithValues: Room.mocks.map { ($0.id, RoomWord.mocks(for: $0.id)) }),
                beacons: AppBeacon.mockPairings
            )
            persist()
        } else {
            store = Store()
        }
    }

    func fetchRooms(adminId: String) async -> [Room] {
        store.rooms.sorted { $0.label.localizedCaseInsensitiveCompare($1.label) == .orderedAscending }
    }

    func addRoom(label: String, adminId: String) async -> Room? {
        let room = Room(id: UUID().uuidString, adminId: adminId, label: label)
        store.rooms.append(room)
        store.words[room.id] = []
        persist()
        return room
    }

    func updateRoom(id: String, label: String) async {
        guard let i = store.rooms.firstIndex(where: { $0.id == id }) else { return }
        store.rooms[i].label = label
        persist()
    }

    func deleteRoom(id: String) async {
        store.rooms.removeAll { $0.id == id }
        store.words.removeValue(forKey: id)
        store.beacons.removeValue(forKey: id)
        persist()
    }

    func fetchWords(roomId: String) async -> [RoomWord] {
        (store.words[roomId] ?? []).sorted { $0.position < $1.position }
    }

    func addWord(label: String, category: String, position: Int, roomId: String, adminId: String) async -> RoomWord? {
        let word = RoomWord(id: UUID().uuidString, adminId: adminId, roomId: roomId, label: label, category: category, position: position)
        store.words[roomId, default: []].append(word)
        persist()
        return word
    }

    func updateWord(id: String, label: String, category: String) async {
        for key in store.words.keys {
            guard let i = store.words[key]?.firstIndex(where: { $0.id == id }) else { continue }
            store.words[key]?[i].label = label
            store.words[key]?[i].category = category
        }
        persist()
    }

    func deleteWord(id: String) async {
        for key in store.words.keys {
            store.words[key]?.removeAll { $0.id == id }
        }
        persist()
    }

    func fetchAllBeacons(adminId: String) async -> [AppBeacon] {
        store.beacons.values.flatMap { $0 }
    }

    func fetchBeacons(roomId: String) async -> [AppBeacon] {
        store.beacons[roomId] ?? []
    }

    func addBeacon(beaconUuid: String, label: String, radius: Double, roomId: String, adminId: String) async -> AppBeacon? {
        let beacon = AppBeacon(id: UUID().uuidString, adminId: adminId, roomId: roomId, beaconUuid: beaconUuid, label: label, radius: radius)
        store.beacons[roomId, default: []].append(beacon)
        persist()
        return beacon
    }

    func updateBeacon(id: String, label: String, radius: Double) async {
        for key in store.beacons.keys {
            guard let i = store.beacons[key]?.firstIndex(where: { $0.id == id }) else { continue }
            store.beacons[key]?[i].label = label
            store.beacons[key]?[i].radius = radius
        }
        persist()
    }

    func deleteBeacon(id: String) async {
        for key in store.beacons.keys {
            store.beacons[key]?.removeAll { $0.id == id }
        }
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(store) else { return }
        UserDefaults.standard.set(data, forKey: kLocalAdminData)
    }
}
