import Foundation

protocol AdminService {
    // Rooms
    func fetchRooms(adminId: String) async -> [Room]
    func addRoom(label: String, roomId: String, adminId: String) async -> Room?
    func updateRoom(id: String, label: String, roomId: String) async
    func deleteRoom(id: String) async

    // Words
    func fetchWords(roomId: String) async -> [RoomWord]
    func addWord(label: String, category: String, position: Int, roomId: String, adminId: String) async -> RoomWord?
    func updateWord(id: String, label: String, category: String) async
    func deleteWord(id: String) async
}
