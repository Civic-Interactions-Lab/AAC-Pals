import UIKit

@MainActor
@Observable
class PictogramManager {
    private let service: PictogramService

    // Sentence state
    private(set) var sentence: [Word] = []

    init(service: PictogramService) {
        self.service = service
    }

    // MARK: - Sentence

    func addWord(_ word: Word) {
        sentence.append(word)
    }

    func removeLast() {
        guard !sentence.isEmpty else { return }
        sentence.removeLast()
    }

    func remove(at index: Int) {
        guard sentence.indices.contains(index) else { return }
        sentence.remove(at: index)
    }

    func clearSentence() {
        sentence = []
    }

    // MARK: - Pictogram

    func fetchImage(for label: String, arasaacId: Int?) async -> UIImage? {
        await service.fetchImage(for: label, arasaacId: arasaacId)
    }

    func prefetch(words: [Word]) async {
        await withTaskGroup(of: Void.self) { group in
            for word in words {
                group.addTask {
                    _ = await self.service.fetchImage(for: word.label, arasaacId: word.arasaacId)
                }
            }
        }
    }
}
