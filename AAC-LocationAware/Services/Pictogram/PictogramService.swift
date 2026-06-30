import Foundation

private let arasaacSearch = "https://api.arasaac.org/api/pictograms/en/search"
private let arasaacImage  = "https://static.arasaac.org/pictograms"

// Shared singleton — one cache for the entire app session.
// URL strings are also persisted to UserDefaults so they survive app restarts.
final class PictogramService {
    static let shared = PictogramService()
    private init() {
        diskCache = UserDefaults.standard.dictionary(forKey: "pictogram_cache") as? [String: String] ?? [:]
    }

    private var memoryCache: [String: URL] = [:]
    private var diskCache: [String: String]

    func url(for label: String, arasaacId: Int?) async -> URL? {
        if let id = arasaacId { return pictogramURL(for: id) }

        let key = label.lowercased().trimmingCharacters(in: .whitespaces)

        if let cached = memoryCache[key] { return cached }

        if let saved = diskCache[key], let url = URL(string: saved) {
            memoryCache[key] = url
            return url
        }

        let alias    = AACVocabulary.searchAliases[key] ?? key
        let fallback = key.split(separator: " ").last.map(String.init) ?? key

        var result = await search(term: alias)
        if result == nil && alias != fallback {
            result = await search(term: fallback)
        }

        if let url = result {
            memoryCache[key] = url
            diskCache[key] = url.absoluteString
            UserDefaults.standard.set(diskCache, forKey: "pictogram_cache")
        }
        return result
    }
}

func pictogramURL(for id: Int) -> URL {
    URL(string: "\(arasaacImage)/\(id)/\(id)_500.png")!
}

func fetchPictogramURL(label: String, arasaacId: Int?) async -> URL? {
    await PictogramService.shared.url(for: label, arasaacId: arasaacId)
}

private func search(term: String) async -> URL? {
    guard let encoded = term.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
          let url = URL(string: "\(arasaacSearch)/\(encoded)") else { return nil }
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        let results = try JSONDecoder().decode([ArasaacResult].self, from: data)
        guard !results.isEmpty else { return nil }
        return pictogramURL(for: bestMatch(results: results, target: term))
    } catch {
        return nil
    }
}

private func bestMatch(results: [ArasaacResult], target: String) -> Int {
    let targetLower = target.lowercased()
    let targetWords = targetLower.split(separator: " ").map(String.init)
    var bestId = results[0].id
    var bestScore = -1

    for result in results {
        let keywords = result.keywords.map { $0.keyword.lowercased() }
        var score = 0
        for kw in keywords {
            if kw == targetLower                                    { score += 100; break }
            if targetWords.allSatisfy({ kw.contains($0) })         { score += 50 }
            if targetWords.contains(where: { kw == $0 })           { score += 20 }
            if kw.hasPrefix(targetLower)                            { score += 10 }
        }
        if score > bestScore { bestScore = score; bestId = result.id }
    }
    return bestId
}

private struct ArasaacResult: Decodable {
    let id: Int
    let keywords: [ArasaacKeyword]
    enum CodingKeys: String, CodingKey { case id = "_id"; case keywords }
}

private struct ArasaacKeyword: Decodable {
    let keyword: String
}
