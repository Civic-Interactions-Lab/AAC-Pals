import Foundation

private let kBoardSetups = "aac_board_setups"
private let kBoardMyDefault = "aac_board_my_default"

struct LocalBoardWordsService: BoardWordsService {
    func loadSetup(profileId: String) async -> BoardSetup? {
        loadAll()[profileId]
    }

    func saveSetup(_ setup: BoardSetup, profileId: String) async {
        var all = loadAll()
        all[profileId] = setup
        guard let data = try? JSONEncoder().encode(all) else { return }
        UserDefaults.standard.set(data, forKey: kBoardSetups)
    }

    func loadMyDefault() async -> [String]? {
        UserDefaults.standard.stringArray(forKey: kBoardMyDefault)
    }

    func saveMyDefault(_ labels: [String]) async {
        UserDefaults.standard.set(labels, forKey: kBoardMyDefault)
    }

    func deleteMyDefault() async {
        UserDefaults.standard.removeObject(forKey: kBoardMyDefault)
    }

    private func loadAll() -> [String: BoardSetup] {
        guard
            let data = UserDefaults.standard.data(forKey: kBoardSetups),
            let all = try? JSONDecoder().decode([String: BoardSetup].self, from: data)
        else { return [:] }
        return all
    }
}
