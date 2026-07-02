import Foundation
import Observation

@MainActor
@Observable
final class AdminManager {
    private let service: AdminService

    private(set) var rooms: [Room] = []
    private(set) var wordsByRoom: [String: [RoomWord]] = [:]
    private(set) var isLoading = false
    private(set) var loadError: String? = nil

    init(service: AdminService) {
        self.service = service
    }

    func words(for roomId: String) -> [RoomWord] {
        wordsByRoom[roomId] ?? []
    }

    // MARK: - Rooms

    func loadRooms(adminId: String) async {
        isLoading = true
        loadError = nil
        rooms = await service.fetchRooms(adminId: adminId)
        isLoading = false
        if rooms.isEmpty {
            print("[AdminManager] loadRooms returned 0 rooms for adminId: \(adminId)")
        }
    }

    func addRoom(label: String, roomId: String, adminId: String) async {
        guard let room = await service.addRoom(label: label, roomId: roomId, adminId: adminId) else { return }
        rooms.append(room)
    }

    func updateRoom(id: String, label: String, roomId: String) async {
        await service.updateRoom(id: id, label: label, roomId: roomId)
        guard let i = rooms.firstIndex(where: { $0.id == id }) else { return }
        rooms[i].label = label
        rooms[i].roomId = roomId
    }

    func deleteRoom(id: String) async {
        await service.deleteRoom(id: id)
        rooms.removeAll { $0.id == id }
        wordsByRoom.removeValue(forKey: id)
    }

    // MARK: - Words

    func loadWords(for roomId: String) async {
        wordsByRoom[roomId] = await service.fetchWords(roomId: roomId)
    }

    func addWord(label: String, category: String, roomId: String, adminId: String) async {
        let position = wordsByRoom[roomId]?.count ?? 0
        guard let word = await service.addWord(label: label, category: category, position: position, roomId: roomId, adminId: adminId) else { return }
        wordsByRoom[roomId, default: []].append(word)
    }

    func updateWord(id: String, label: String, category: String, roomId: String) async {
        await service.updateWord(id: id, label: label, category: category)
        guard let i = wordsByRoom[roomId]?.firstIndex(where: { $0.id == id }) else { return }
        wordsByRoom[roomId]?[i].label = label
        wordsByRoom[roomId]?[i].category = category
    }

    func deleteWord(id: String, roomId: String) async {
        await service.deleteWord(id: id)
        wordsByRoom[roomId]?.removeAll { $0.id == id }
    }
}
