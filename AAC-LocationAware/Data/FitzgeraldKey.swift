import SwiftUI

enum FitzgeraldCategory {
    case noun, pronoun, verb, adjective, prepositionSocial, question, negation, adverb, conjunction, determiner
}

enum WordGroup: CaseIterable {
    case verbs, nouns, descriptors, social, other

    var name: String {
        switch self {
        case .verbs:       "verbs"
        case .nouns:       "nouns"
        case .descriptors: "descriptors"
        case .social:      "social"
        case .other:       "other"
        }
    }

    var color: Color {
        switch self {
        case .verbs:       .categoryVerb
        case .nouns:       .categoryNoun
        case .descriptors: .categoryAdjective
        case .social:      .categorySocial
        case .other:       .categoryNegation
        }
    }
}

extension FitzgeraldCategory {
    var name: String {
        switch self {
        case .noun:              return "noun"
        case .pronoun:           return "pronoun"
        case .verb:              return "verb"
        case .adjective:         return "describing"
        case .prepositionSocial: return "social"
        case .question:          return "question"
        case .negation:          return "negation"
        case .adverb:            return "adverb"
        case .conjunction, .determiner: return "other"
        }
    }

    var group: WordGroup {
        switch self {
        case .verb:                   return .verbs
        case .noun, .pronoun:         return .nouns
        case .adjective:              return .descriptors
        case .prepositionSocial:      return .social
        case .question, .negation, .adverb, .conjunction, .determiner: return .other
        }
    }

    var color: Color {
        switch self {
        case .noun:              return .categoryNoun
        case .pronoun:           return .categoryPronoun
        case .verb:              return .categoryVerb
        case .adjective:         return .categoryAdjective
        case .prepositionSocial: return .categorySocial
        case .question:          return .categoryQuestion
        case .negation:          return .categoryNegation
        case .adverb:            return .categoryAdverb
        case .conjunction, .determiner: return .paper
        }
    }
}

private let negationWords: Set<String> = ["no", "not", "stop", "help", "more", "all done", "finished", "don't", "can't", "won't", "never", "wait", "done"]
private let pronounWords: Set<String> = [
    "i", "me", "my", "mine", "you", "your", "yours", "we", "us", "our", "ours",
    "he", "him", "his", "she", "her", "hers", "it", "its", "they", "them", "their", "theirs", "that", "this"
]
private let verbWords: Set<String> = [
    "want", "need", "like", "go", "eat", "drink", "wash", "sleep", "play", "read", "cook", "watch", "run", "walk",
    "brush teeth", "wash hands", "wake up", "listen", "write", "swing", "slide", "hug",
    "look", "sit", "talk", "relax", "come", "give", "open", "close", "put", "make", "turn", "do", "go home",
    "get", "can", "is", "have", "see", "take", "feel", "think", "know", "say"
]
private let adjectiveWords: Set<String> = [
    "hungry", "thirsty", "tired", "hot", "cold", "quiet",
    "big", "small", "little", "good", "bad", "fast", "slow", "happy", "sad", "angry", "mad", "scared", "sick", "hurt", "loud",
    "all", "some", "different", "same"
]
private let socialWords: Set<String> = ["please", "thank you", "yes", "goodnight", "together", "hello", "bye", "sorry"]
private let prepositionWords: Set<String> = ["in", "on", "up", "down", "out", "off", "with", "for", "to", "under", "over"]
private let adverbWords: Set<String> = ["here", "there", "now", "later", "again"]
private let conjunctionWords: Set<String> = ["and", "because", "or", "but"]
private let questionWords: Set<String> = ["what", "where", "when", "why", "who", "how", "which"]

func fitzgeraldCategory(for label: String) -> FitzgeraldCategory {
    let normalized = label.lowercased().trimmingCharacters(in: .whitespaces)
    if negationWords.contains(normalized)  { return .negation }
    if pronounWords.contains(normalized)   { return .pronoun }
    if verbWords.contains(normalized)      { return .verb }
    if adjectiveWords.contains(normalized) { return .adjective }
    if socialWords.contains(normalized)    { return .prepositionSocial }
    if prepositionWords.contains(normalized) { return .prepositionSocial }
    if adverbWords.contains(normalized)    { return .adverb }
    if conjunctionWords.contains(normalized) { return .conjunction }
    if questionWords.contains(normalized)  { return .question }
    return .noun
}

func fitzgeraldColor(for label: String) -> Color {
    fitzgeraldCategory(for: label).color
}
