import UIKit

struct PictogramResult {
    let label: String
    let imageURL: URL
    let image: UIImage?

    static func mock(label: String = "eat") -> PictogramResult {
        PictogramResult(
            label: label,
            imageURL: URL(string: "https://static.arasaac.org/pictograms/6456/6456_500.png")!,
            image: nil
        )
    }

    static var mocks: [PictogramResult] {
        [
            mock(label: "eat"),
            mock(label: "drink"),
            mock(label: "sleep"),
        ]
    }
}
