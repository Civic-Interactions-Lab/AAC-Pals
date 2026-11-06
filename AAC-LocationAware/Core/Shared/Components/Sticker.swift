import SwiftUI

extension View {
    func sticker(_ fill: Color = .paper, radius: CGFloat = 16) -> some View {
        background(fill, in: RoundedRectangle(cornerRadius: radius))
            .overlay(RoundedRectangle(cornerRadius: radius).strokeBorder(Color.ink, lineWidth: 2))
    }

    func dashedOutline(radius: CGFloat) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: radius)
                .strokeBorder(Color.ink.opacity(0.4), style: StrokeStyle(lineWidth: 2, dash: [6, 5]))
        )
    }
}

struct StickerPressStyle: ButtonStyle {
    var shadowOpacity: Double = 0.28

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .compositingGroup()
            .shadow(color: Color.ink.opacity(configuration.isPressed ? 0 : shadowOpacity), radius: 0, y: 3)
            .offset(y: configuration.isPressed ? 2 : 0)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }
}

struct SectionLabel: View {
    let text: String

    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text.uppercased())
            .font(.figtree(11))
            .tracking(1)
            .foregroundStyle(Color.ink.opacity(0.86))
    }
}

struct Caption: View {
    let text: String
    var size: CGFloat = 12

    init(_ text: String, size: CGFloat = 12) {
        self.text = text
        self.size = size
    }

    var body: some View {
        Text(text)
            .font(.figtree(size, .semibold))
            .foregroundStyle(Color.ink.opacity(0.86))
            .lineSpacing(3)
    }
}

struct PillButton: View {
    let title: String
    var fill: Color = .paper
    var foreground: Color = .ink
    var size: CGFloat = 13
    var radius: CGFloat = 16
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.figtree(size))
                .tracking(0.6)
                .foregroundStyle(foreground)
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .sticker(fill, radius: radius)
                .contentShape(RoundedRectangle(cornerRadius: radius))
        }
        .buttonStyle(.plain)
    }
}

struct AvatarCircle: View {
    let name: String
    var color: Color = .categoryQuestion
    var size: CGFloat = 32

    var body: some View {
        Text(name.prefix(1).uppercased())
            .font(.fredoka(size * 0.46))
            .foregroundStyle(Color.ink)
            .frame(width: size, height: size)
            .background(color, in: Circle())
            .overlay(Circle().strokeBorder(Color.ink, lineWidth: 2))
    }
}

enum AvatarPalette {
    static let colors: [Color] = [.categoryQuestion, .categoryPronoun, .categoryNoun, .categoryAdjective, .categorySocial, .categoryVerb]

    static func color(for index: Int) -> Color {
        colors[max(index, 0) % colors.count]
    }
}

struct StickerTextField: View {
    let placeholder: String
    @Binding var text: String
    var font: Font = .figtree(15, .semibold)
    var height: CGFloat = 40
    var capitalization: TextInputAutocapitalization = .never
    var onSubmit: () -> Void = {}

    var body: some View {
        TextField(placeholder, text: $text)
            .font(font)
            .foregroundStyle(Color.ink)
            .textInputAutocapitalization(capitalization)
            .autocorrectionDisabled()
            .submitLabel(.done)
            .onSubmit(onSubmit)
            .padding(.horizontal, 12)
            .frame(height: height)
            .sticker(.paper, radius: 14)
    }
}

struct BackSquareButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.ink)
                .frame(width: 48, height: 48)
                .sticker(.paper, radius: 16)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back")
    }
}

struct RemoveBadge: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 10, weight: .heavy))
                .foregroundStyle(Color.ink)
                .frame(width: 26, height: 26)
                .background(Color.paper, in: Circle())
                .overlay(Circle().strokeBorder(Color.ink, lineWidth: 2))
                .contentShape(Circle().inset(by: -8))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Remove \(label)")
    }
}
