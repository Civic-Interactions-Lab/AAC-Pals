import Foundation

struct RoomWord: Identifiable, Equatable, Codable {
    let id: String
    let adminId: String
    let roomId: String
    var label: String
    var category: String
    var position: Int

    static func mocks(for roomId: String) -> [RoomWord] {
        let words: [String]
        switch roomId {
        case "room-kitchen":
            words = ["food", "water", "drink", "eat", "hungry", "thirsty", "snack", "milk", "juice", "spoon", "cup", "bowl", "cook"]
        case "room-bathroom":
            words = ["bathroom", "toilet", "wash", "soap", "toothbrush", "towel", "shower", "potty", "flush", "brush teeth", "wash hands"]
        case "room-bedroom":
            words = ["bed", "sleep", "tired", "blanket", "pillow", "quiet", "pajamas", "book", "light on", "light off", "wake up"]
        default:
            words = ["want", "more", "help", "stop", "yes", "no"]
        }
        return words.enumerated().map { i, label in
            RoomWord(id: "\(roomId)-w\(i)", adminId: "admin-1", roomId: roomId, label: label, category: "noun", position: i)
        }
    }
}
