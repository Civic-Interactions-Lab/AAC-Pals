import Foundation

enum AgeGroup: String, CaseIterable, Codable {
    case toddler, preschool, schoolAge

    var title: String {
        switch self {
        case .toddler:   "Toddler"
        case .preschool: "Preschool"
        case .schoolAge: "School age"
        }
    }

    var ages: String {
        switch self {
        case .toddler:   "1–3 yrs"
        case .preschool: "3–5 yrs"
        case .schoolAge: "6+ yrs"
        }
    }

    var labels: [String] {
        switch self {
        case .toddler:   Self.toddlerWords
        case .preschool: Self.preschoolWords
        case .schoolAge: Self.schoolAgeWords
        }
    }

    private static let toddlerWords = [
        "I", "no", "yes", "want", "it", "that", "go", "mine", "you", "what",
        "on", "in", "here", "more", "out", "off", "help", "all done",
    ]

    private static let preschoolWords = [
        "I", "you", "it", "that", "he", "she",
        "want", "like", "go", "get", "make", "look", "turn", "open", "put", "do", "help", "stop", "can",
        "more", "not", "all", "some", "different", "same", "good", "all done",
        "here", "in", "on", "up",
        "what", "where", "who", "when", "why",
        "yes", "no",
    ]

    private static let schoolAgeWords = preschoolWords + [
        "me", "we", "they", "this",
        "is", "have", "need", "see", "eat", "drink", "play", "come", "give", "take",
        "feel", "think", "know", "say", "read", "write",
        "and", "because", "with", "for", "now", "later", "again",
        "big", "little", "happy", "sad", "mad", "hurt", "tired", "hungry",
        "please", "thank you", "sorry",
    ]
}
