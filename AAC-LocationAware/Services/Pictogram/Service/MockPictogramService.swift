import UIKit

struct MockPictogramService: PictogramService {
    let delay: Double
    let showError: Bool

    init(delay: Double = 0, showError: Bool = false) {
        self.delay = delay
        self.showError = showError
    }

    // Returns a known hardcoded ARASAAC URL instantly — no network call
    func fetchURL(for label: String, arasaacId: Int?) async -> URL? {
        try? await Task.sleep(for: .seconds(delay))
        if showError { return nil }

        let knownIds: [String: Int] = [
            "eat": 6456, "drink": 6061, "sleep": 6479,
            "walk": 6044, "i": 6632, "want": 5441, "no": 5526
        ]
        let key = label.lowercased().trimmingCharacters(in: .whitespaces)
        let id = arasaacId ?? knownIds[key] ?? 6456
        return arasaacImageURL(for: id)
    }

    func fetchImage(for label: String, arasaacId: Int?) async -> UIImage? {
        guard let url = await fetchURL(for: label, arasaacId: arasaacId) else { return nil }
        guard let (data, _) = try? await URLSession.shared.data(from: url) else { return nil }
        return UIImage(data: data)
    }
}
