import Foundation

struct Word: Identifiable, Hashable {
    let id: UUID
    let label: String
    var arasaacId: Int?

    init(id: UUID = UUID(), label: String, arasaacId: Int? = nil) {
        self.id = id
        self.label = label
        self.arasaacId = arasaacId
    }

    static var mock: Word {
        Word(label: "Eat", arasaacId: 6456)
    }

    static var mocks: [Word] {
        AACVocabulary.coreWords
    }
}
