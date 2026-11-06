import Foundation

let kBoardGridSizeKey = "boardGridSize"

enum BoardGridSize: String, CaseIterable {
    case standard, roomy

    var title: String {
        switch self {
        case .standard: "Standard"
        case .roomy:    "Roomy"
        }
    }

    var subtitle: String { "\(columns) across" }

    var columns: Int {
        switch self {
        case .standard: 4
        case .roomy:    2
        }
    }

    var panelColumns: Int {
        switch self {
        case .standard: 2
        case .roomy:    1
        }
    }

    var tileAspect: CGFloat {
        switch self {
        case .standard: 169.0 / 177.0
        case .roomy:    226.0 / 366.0
        }
    }
}
