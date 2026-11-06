import SwiftUI

struct StarterSetPicker: View {
    let current: BoardPreset?
    let myDefaultCount: Int?
    let onPick: (BoardPreset) -> Void
    let onMakeMyDefault: () -> Void
    let onDeleteMyDefault: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            SectionLabel("Starter set")

            HStack(spacing: 8) {
                ForEach(AgeGroup.allCases, id: \.self) { group in
                    chip(.age(group), title: group.title, subtitle: "\(group.ages) · \(group.labels.count) words")
                }

                if let myDefaultCount {
                    chip(.myDefault, title: BoardPreset.myDefault.title, subtitle: "yours · \(myDefaultCount) words")
                        .overlay(alignment: .topTrailing) {
                            RemoveBadge(label: BoardPreset.myDefault.title, action: onDeleteMyDefault)
                                .scaleEffect(0.8)
                                .offset(x: 9, y: -9)
                        }
                } else {
                    makeMyOwnChip
                }
            }
        }
    }

    private var makeMyOwnChip: some View {
        Button { onMakeMyDefault() } label: {
            VStack(spacing: 1) {
                Text("+ Make my own")
                    .font(.fredoka(17))
                Text("starts empty")
                    .font(.figtree(9))
                    .opacity(0.86)
            }
            .foregroundStyle(Color.ink.opacity(0.75))
            .padding(.horizontal, 14)
            .frame(height: 44)
            .dashedOutline(radius: 16)
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Make my own default set, starting empty")
    }

    private func chip(_ preset: BoardPreset, title: String, subtitle: String) -> some View {
        Button { onPick(preset) } label: {
            VStack(spacing: 1) {
                Text(title)
                    .font(.fredoka(17))
                Text(subtitle)
                    .font(.figtree(9))
                    .opacity(0.86)
            }
            .foregroundStyle(Color.ink)
            .padding(.horizontal, 14)
            .frame(height: 44)
            .sticker(current == preset ? .signalGreen : .paper, radius: 16)
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title), \(subtitle)")
        .accessibilityAddTraits(current == preset ? .isSelected : [])
    }
}

#Preview {
    VStack(alignment: .leading) {
        StarterSetPicker(current: .age(.toddler), myDefaultCount: nil, onPick: { _ in }, onMakeMyDefault: {}, onDeleteMyDefault: {})
        StarterSetPicker(current: .myDefault, myDefaultCount: 20, onPick: { _ in }, onMakeMyDefault: {}, onDeleteMyDefault: {})
    }
    .padding()
    .background(Color.paper)
}
