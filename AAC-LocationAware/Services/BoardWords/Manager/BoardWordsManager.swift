import Foundation
import Observation

@MainActor
@Observable
final class BoardWordsManager {
    private let service: BoardWordsService

    private(set) var setup: BoardSetup = .default
    private(set) var words: [Word] = BoardSetup.default.labels.map { Word(label: $0) }
    private(set) var profileId: String?
    private(set) var myDefault: [String]?

    var isUnchanged: Bool {
        guard let preset = setup.preset else { return false }
        return setup.labels == labels(for: preset)
    }

    init(service: BoardWordsService) {
        self.service = service
    }

    func load(profileId: String) async {
        self.profileId = profileId
        myDefault = await service.loadMyDefault()
        apply(await service.loadSetup(profileId: profileId) ?? .default)
    }

    func wordCount(for profileId: String) async -> Int {
        (await service.loadSetup(profileId: profileId) ?? .default).labels.count
    }

    func usePreset(_ preset: BoardPreset) async {
        guard let labels = labels(for: preset) else { return }
        await save(BoardSetup(preset: preset, labels: labels))
    }

    func makeMyDefault() async {
        await save(BoardSetup(preset: .myDefault, labels: []))
    }

    func deleteMyDefault() async {
        myDefault = nil
        await service.deleteMyDefault()
        if setup.preset == .myDefault {
            await save(BoardSetup(preset: nil, labels: setup.labels))
        }
    }

    @discardableResult
    func addWord(_ label: String) async -> Bool {
        let trimmed = label.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              !setup.labels.contains(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame })
        else { return false }
        var next = setup
        next.labels.append(trimmed)
        await save(next)
        return true
    }

    func removeWord(at index: Int) async {
        guard setup.labels.indices.contains(index) else { return }
        var next = setup
        next.labels.remove(at: index)
        await save(next)
    }

    private func labels(for preset: BoardPreset) -> [String]? {
        switch preset {
        case .age(let group): group.labels
        case .myDefault:      myDefault
        }
    }

    private func save(_ next: BoardSetup) async {
        apply(next)
        if next.preset == .myDefault {
            myDefault = next.labels
            await service.saveMyDefault(next.labels)
        }
        guard let profileId else { return }
        await service.saveSetup(next, profileId: profileId)
    }

    private func apply(_ next: BoardSetup) {
        var next = next
        if next.preset == .myDefault, myDefault == nil {
            next.preset = nil
        }
        setup = next
        words = next.labels.map { Word(label: $0) }
    }
}
