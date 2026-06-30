import UIKit

private let arasaacSearch = "https://api.arasaac.org/api/pictograms/en/search"

func arasaacImageURL(for id: Int) -> URL {
    URL(string: "https://static.arasaac.org/pictograms/\(id)/\(id)_500.png")!
}

struct ArasaacPictogramService: PictogramService {
    private let urlCache = URLPictogramCache()
    private let imageCache = ImageCache()

    func fetchURL(for label: String, arasaacId: Int?) async -> URL? {
        if let id = arasaacId { return arasaacImageURL(for: id) }

        let key = label.lowercased().trimmingCharacters(in: .whitespaces)
        if let cached = await urlCache.get(key) { return cached }

        let alias    = AACVocabulary.searchAliases[key] ?? key
        let fallback = key.split(separator: " ").last.map(String.init) ?? key

        var result = await search(term: alias)
        if result == nil && alias != fallback {
            result = await search(term: fallback)
        }

        if let url = result { await urlCache.set(url, for: key) }
        return result
    }

    func fetchImage(for label: String, arasaacId: Int?) async -> UIImage? {
        guard let url = await fetchURL(for: label, arasaacId: arasaacId) else { return nil }
        return await imageCache.load(url)
    }

    private func search(term: String) async -> URL? {
        guard let encoded = term.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "\(arasaacSearch)/\(encoded)") else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let results = try JSONDecoder().decode([ArasaacResult].self, from: data)
            guard !results.isEmpty else { return nil }
            return arasaacImageURL(for: bestMatch(results: results, target: term))
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
                if kw == targetLower                                 { score += 100; break }
                if targetWords.allSatisfy({ kw.contains($0) })      { score += 50 }
                if targetWords.contains(where: { kw == $0 })        { score += 20 }
                if kw.hasPrefix(targetLower)                         { score += 10 }
            }
            if score > bestScore { bestScore = score; bestId = result.id }
        }
        return bestId
    }
}

private struct ArasaacResult: Decodable {
    let id: Int
    let keywords: [ArasaacKeyword]
    enum CodingKeys: String, CodingKey { case id = "_id"; case keywords }
}

private struct ArasaacKeyword: Decodable {
    let keyword: String
}

// MARK: - Caches

private actor URLPictogramCache {
    private var memory: [String: URL] = [:]
    private let defaultsKey = "pictogram_url_cache"

    init() {
        let saved = UserDefaults.standard.dictionary(forKey: defaultsKey) as? [String: String] ?? [:]
        memory = saved.compactMapValues { URL(string: $0) }
    }

    func get(_ key: String) -> URL? { memory[key] }

    func set(_ url: URL, for key: String) {
        memory[key] = url
        var saved = UserDefaults.standard.dictionary(forKey: defaultsKey) as? [String: String] ?? [:]
        saved[key] = url.absoluteString
        UserDefaults.standard.set(saved, forKey: defaultsKey)
    }
}

actor ImageCache {
    private var cache: [URL: UIImage] = [:]

    func load(_ url: URL) async -> UIImage? {
        if let cached = cache[url] { return cached }
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let image = UIImage(data: data) else { return nil }
        cache[url] = image
        return image
    }
}
