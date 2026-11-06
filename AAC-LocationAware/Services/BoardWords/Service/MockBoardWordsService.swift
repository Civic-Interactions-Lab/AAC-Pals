import Foundation

final class MockBoardWordsService: BoardWordsService {
    private var setups: [String: BoardSetup]
    private var myDefault: [String]?

    init(
        setups: [String: BoardSetup] = [
            "mock-user-1": BoardSetup(preset: .age(.preschool), labels: AgeGroup.preschool.labels),
            "mock-user-2": BoardSetup(preset: .age(.toddler), labels: AgeGroup.toddler.labels),
        ],
        myDefault: [String]? = nil
    ) {
        self.setups = setups
        self.myDefault = myDefault
    }

    func loadSetup(profileId: String) async -> BoardSetup? {
        setups[profileId]
    }

    func saveSetup(_ setup: BoardSetup, profileId: String) async {
        setups[profileId] = setup
    }

    func loadMyDefault() async -> [String]? {
        myDefault
    }

    func saveMyDefault(_ labels: [String]) async {
        myDefault = labels
    }

    func deleteMyDefault() async {
        myDefault = nil
    }
}
