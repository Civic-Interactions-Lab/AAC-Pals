import Foundation

protocol AdminService {
    // Rooms
    func fetchRooms(adminId: String) async -> [Room]
    func addRoom(label: String, adminId: String) async -> Room?
    func updateRoom(id: String, label: String) async
    func deleteRoom(id: String) async

    // Words
    func fetchWords(roomId: String) async -> [RoomWord]
    func addWord(label: String, category: String, position: Int, roomId: String, adminId: String) async -> RoomWord?
    func updateWord(id: String, label: String, category: String) async
    func deleteWord(id: String) async

    // Beacons
    func fetchAllBeacons(adminId: String) async -> [AppBeacon]
    func fetchBeacons(roomId: String) async -> [AppBeacon]
    func addBeacon(beaconUuid: String, label: String, radius: Double, roomId: String, adminId: String) async -> AppBeacon?
    func updateBeacon(id: String, label: String, radius: Double) async
    func deleteBeacon(id: String) async
}
