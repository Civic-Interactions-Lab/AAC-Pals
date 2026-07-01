import Foundation

struct UserProfile: Identifiable, Codable, Equatable {
    let id: String
    var displayName: String
    var allowedRoomIds: [String]

    static func makeNew(displayName: String) -> UserProfile {
        UserProfile(id: UUID().uuidString, displayName: displayName, allowedRoomIds: [])
    }

    static var mocks: [UserProfile] {
        [
            UserProfile(id: "mock-user-1", displayName: "Alex", allowedRoomIds: []),
            UserProfile(id: "mock-user-2", displayName: "Jordan", allowedRoomIds: []),
        ]
    }
}
