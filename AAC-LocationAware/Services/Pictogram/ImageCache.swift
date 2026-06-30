import UIKit

actor ImageCache {
    static let shared = ImageCache()
    private var cache: [URL: UIImage] = [:]

    func get(_ url: URL) -> UIImage? { cache[url] }

    func set(_ image: UIImage, for url: URL) { cache[url] = image }

    func load(_ url: URL) async -> UIImage? {
        if let cached = cache[url] { return cached }
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let image = UIImage(data: data) else { return nil }
        cache[url] = image
        return image
    }
}
