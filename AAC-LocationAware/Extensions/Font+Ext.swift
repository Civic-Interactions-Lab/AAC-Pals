import SwiftUI
import CoreText

extension Font {
    static func fredoka(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font {
        _ = fontsRegistered
        return .custom(fredokaName(weight), size: size)
    }

    static func figtree(_ size: CGFloat, _ weight: Font.Weight = .heavy) -> Font {
        _ = fontsRegistered
        return .custom(figtreeName(weight), size: size)
    }

    private static func fredokaName(_ weight: Font.Weight) -> String {
        switch weight {
        case .regular: "Fredoka-Regular"
        case .medium:  "Fredoka-Medium"
        case .semibold: "Fredoka-SemiBold"
        default:       "Fredoka-Bold"
        }
    }

    private static func figtreeName(_ weight: Font.Weight) -> String {
        switch weight {
        case .regular:  "Figtree-Regular"
        case .medium:   "Figtree-Medium"
        case .semibold: "Figtree-SemiBold"
        case .bold:     "Figtree-Bold"
        case .black:    "Figtree-Black"
        default:        "Figtree-ExtraBold"
        }
    }

    private static let fontsRegistered: Void = registerAppFonts()

    static func registerAppFonts() {
        for name in ["Fredoka-Variable", "Figtree-Variable"] {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
