import Foundation

final class MockAdminService: AdminService {
    private var rooms: [Room]
    private var words: [String: [RoomWord]]
    private var beacons: [String: [AppBeacon]]

    init(rooms: [Room] = Room.mocks, beacons: [String: [AppBeacon]] = [:]) {
        self.rooms = rooms
        self.words = Dictionary(uniqueKeysWithValues: rooms.map { ($0.id, RoomWord.mocks(for: $0.id)) })
        self.beacons = beacons
    }

    // MARK: - Rooms
    func fetchRooms(adminId: String) async -> [Room] { rooms }

    func addRoom(label: String, adminId: String) async -> Room? {
        let room = Room(id: UUID().uuidString, adminId: adminId, label: label)
        rooms.append(room)
        words[room.id] = []
        return room
    }

    func updateRoom(id: String, label: String) async {
        guard let i = rooms.firstIndex(where: { $0.id == id }) else { return }
        rooms[i].label = label
    }

    func deleteRoom(id: String) async {
        rooms.removeAll { $0.id == id }
        words.removeValue(forKey: id)
        beacons.removeValue(forKey: id)
    }

    // MARK: - Words
    func fetchWords(roomId: String) async -> [RoomWord] { words[roomId] ?? [] }

    func addWord(label: String, category: String, position: Int, roomId: String, adminId: String) async -> RoomWord? {
        let word = RoomWord(id: UUID().uuidString, adminId: adminId, roomId: roomId, label: label, category: category, position: position)
        words[roomId, default: []].append(word)
        return word
    }

    func updateWord(id: String, label: String, category: String) async {
        for key in words.keys {
            guard let i = words[key]?.firstIndex(where: { $0.id == id }) else { continue }
            words[key]?[i].label = label
            words[key]?[i].category = category
        }
    }

    func deleteWord(id: String) async {
        for key in words.keys {
            words[key]?.removeAll { $0.id == id }
        }
    }

    // MARK: - Beacons
    func fetchAllBeacons(adminId: String) async -> [AppBeacon] { beacons.values.flatMap { $0 } }
    func fetchBeacons(roomId: String) async -> [AppBeacon] { beacons[roomId] ?? [] }

    func addBeacon(beaconUuid: String, label: String, radius: Double, roomId: String, adminId: String) async -> AppBeacon? {
        let beacon = AppBeacon(id: UUID().uuidString, adminId: adminId, roomId: roomId, beaconUuid: beaconUuid, label: label, radius: radius)
        beacons[roomId, default: []].append(beacon)
        return beacon
    }

    func updateBeacon(id: String, label: String, radius: Double) async {
        for key in beacons.keys {
            guard let i = beacons[key]?.firstIndex(where: { $0.id == id }) else { continue }
            beacons[key]?[i].label = label
            beacons[key]?[i].radius = radius
        }
    }

    func deleteBeacon(id: String) async {
        for key in beacons.keys {
            beacons[key]?.removeAll { $0.id == id }
        }
    }
}
