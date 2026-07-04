import Foundation
import Observation

@MainActor
@Observable
final class AdminManager {
    private let service: AdminService

    private(set) var rooms: [Room] = []
    private(set) var wordsByRoom: [String: [RoomWord]] = [:]
    private(set) var beaconsByRoom: [String: [AppBeacon]] = [:]
    private(set) var isLoading = false

    init(service: AdminService) {
        self.service = service
    }

    func words(for roomId: String) -> [RoomWord] {
        wordsByRoom[roomId] ?? []
    }

    // MARK: - Rooms

    func loadRooms(adminId: String) async {
        isLoading = true
        rooms = await service.fetchRooms(adminId: adminId)
        isLoading = false
    }

    func addRoom(label: String, adminId: String) async {
        guard let room = await service.addRoom(label: label, adminId: adminId) else { return }
        rooms.append(room)
    }

    func updateRoom(id: String, label: String) async {
        await service.updateRoom(id: id, label: label)
        guard let i = rooms.firstIndex(where: { $0.id == id }) else { return }
        rooms[i].label = label
    }

    func deleteRoom(id: String) async {
        await service.deleteRoom(id: id)
        rooms.removeAll { $0.id == id }
        wordsByRoom.removeValue(forKey: id)
        beaconsByRoom.removeValue(forKey: id)
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

    // MARK: - Beacons

    func beacons(for roomId: String) -> [AppBeacon] {
        beaconsByRoom[roomId] ?? []
    }

    func loadAllBeacons(adminId: String) async -> [AppBeacon] {
        let all = await service.fetchAllBeacons(adminId: adminId)
        for beacon in all {
            beaconsByRoom[beacon.roomId, default: []].removeAll { $0.id == beacon.id }
            beaconsByRoom[beacon.roomId, default: []].append(beacon)
        }
        return all
    }

    func loadBeacons(for roomId: String) async {
        beaconsByRoom[roomId] = await service.fetchBeacons(roomId: roomId)
    }

    func addBeacon(beaconUuid: String, label: String, radius: Double, roomId: String, adminId: String) async {
        guard let beacon = await service.addBeacon(beaconUuid: beaconUuid, label: label, radius: radius, roomId: roomId, adminId: adminId) else { return }
        beaconsByRoom[roomId, default: []].append(beacon)
    }

    func updateBeacon(id: String, label: String, radius: Double, roomId: String) async {
        await service.updateBeacon(id: id, label: label, radius: radius)
        guard let i = beaconsByRoom[roomId]?.firstIndex(where: { $0.id == id }) else { return }
        beaconsByRoom[roomId]?[i].label = label
        beaconsByRoom[roomId]?[i].radius = radius
    }

    func deleteBeacon(id: String, roomId: String) async {
        await service.deleteBeacon(id: id)
        beaconsByRoom[roomId]?.removeAll { $0.id == id }
    }
}
