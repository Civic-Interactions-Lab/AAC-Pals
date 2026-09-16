import Foundation

let kBoardGridSizeKey = "boardGridSize"

enum BoardGridSize: String, CaseIterable {
    case roomy, medium, tight

    var title: String {
        switch self {
        case .roomy:  "Roomy"
        case .medium: "Medium"
        case .tight:  "Tight"
        }
    }

    var columns: Int {
        switch self {
        case .roomy:  3
        case .medium: 5
        case .tight:  7
        }
    }

    var panelColumns: Int {
        switch self {
        case .roomy:  1
        case .medium: 2
        case .tight:  3
        }
    }

    var mainColumnsWithPanel: Int { panelColumns + 1 }
}
