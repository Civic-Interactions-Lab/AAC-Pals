import Foundation

enum BoardPreset: Codable, Hashable {
    case age(AgeGroup)
    case myDefault

    var title: String {
        switch self {
        case .age(let group): group.title
        case .myDefault:      "My default"
        }
    }
}

struct BoardSetup: Codable, Equatable {
    var preset: BoardPreset?
    var labels: [String]

    static var `default`: BoardSetup {
        BoardSetup(preset: .age(.toddler), labels: AgeGroup.toddler.labels)
    }
}
