import SwiftUI

enum FitzgeraldCategory {
    case noun, pronoun, verb, adjective, prepositionSocial, question, negation, adverb, conjunction, determiner
}

extension FitzgeraldCategory {
    static let legend: [FitzgeraldCategory] = [.noun, .pronoun, .verb, .adjective, .prepositionSocial, .question, .negation, .adverb]

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

private let pronounWords: Set<String> = [
    "i","me","my","mine","you","your","yours","we","us","our","ours",
    "he","him","his","she","her","hers","it","its","they","them","their","theirs",
    "this","that","these","those","here","there"
]
private let verbWords: Set<String> = [
    "want","need","go","stop","help","eat","drink","play","read","walk","sleep",
    "listen","watch","cook","wash","brush","shower","wake","talk","write","run",
    "swing","look","sit","hug","relax"
]
private let adjectiveWords: Set<String> = [
    "big","small","little","new","old","good","bad","fast","slow","long","short",
    "empty","full","clean","dirty","happy","sad","tired","hungry","thirsty","sick",
    "excited","scared","hot","cold","quiet","loud","light","dark"
]
private let adverbWords: Set<String> = ["quickly","slowly","quietly","loudly","really","very","too","away","back"]
private let questionWords: Set<String> = ["what","where","when","why","who","how","which"]
private let negationWords: Set<String> = ["no","not","don't","can't","won't","never","stop","wait","help","more","done","all done"]
private let conjunctionWords: Set<String> = ["and","or","but","because","then"]
private let determinerWords: Set<String> = ["the","a","an","this","that","these","those","some","any","my","your","his","her","our","their"]
private let socialWords: Set<String> = ["hello","please","thank you","yes","in","on","under","over","here","there","together","with","for","from"]

private let explicitOverrides: [String: FitzgeraldCategory] = [
    "i want": .verb, "i need": .verb, "go home": .verb,
    "watch tv": .verb, "wash hands": .verb, "brush teeth": .verb, "wake up": .verb,
    "light on": .adjective, "light off": .adjective,
    "all done": .negation, "thank you": .prepositionSocial, "more time": .negation
]

func fitzgeraldCategory(for label: String) -> FitzgeraldCategory {
    let normalized = label.lowercased().trimmingCharacters(in: .whitespaces)
    if let override = explicitOverrides[normalized] { return override }
    if questionWords.contains(normalized)    { return .question }
    if negationWords.contains(normalized)    { return .negation }
    if conjunctionWords.contains(normalized) { return .conjunction }
    if determinerWords.contains(normalized)  { return .determiner }
    if socialWords.contains(normalized)      { return .prepositionSocial }
    if pronounWords.contains(normalized)     { return .pronoun }
    let tokens = normalized.split(separator: " ").map(String.init)
    if tokens.first.map({ pronounWords.contains($0) }) == true { return .pronoun }
    if verbWords.contains(normalized) || tokens.contains(where: { verbWords.contains($0) }) { return .verb }
    if adjectiveWords.contains(normalized) || tokens.contains(where: { adjectiveWords.contains($0) }) { return .adjective }
    if adverbWords.contains(normalized) || tokens.contains(where: { adverbWords.contains($0) }) { return .adverb }
    return .noun
}

func fitzgeraldColor(for label: String) -> Color {
    fitzgeraldCategory(for: label).color
}

