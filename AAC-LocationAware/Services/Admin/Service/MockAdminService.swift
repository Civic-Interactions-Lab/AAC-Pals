import Foundation

final class MockAdminService: AdminService {
    private var rooms: [Room]
    private var words: [String: [RoomWord]]

    init(rooms: [Room] = Room.mocks) {
        self.rooms = rooms
        self.words = Dictionary(uniqueKeysWithValues: rooms.map { ($0.id, RoomWord.mocks(for: $0.id)) })

    }

    func fetchRooms(adminId: String) async -> [Room] { rooms }

    func addRoom(label: String, roomId: String, adminId: String) async -> Room? {
        let room = Room(id: UUID().uuidString, adminId: adminId, label: label, roomId: roomId)
        rooms.append(room)
        words[room.id] = []
        return room
    }

    func updateRoom(id: String, label: String, roomId: String) async {
        guard let i = rooms.firstIndex(where: { $0.id == id }) else { return }
        rooms[i].label = label
        rooms[i].roomId = roomId
    }

    func deleteRoom(id: String) async {
        rooms.removeAll { $0.id == id }
        words.removeValue(forKey: id)
    }

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
}
