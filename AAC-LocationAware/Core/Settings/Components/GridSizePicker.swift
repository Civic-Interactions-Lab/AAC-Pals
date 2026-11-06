import SwiftUI

struct GridSizePicker: View {
    @Binding var selection: BoardGridSize

    var body: some View {
        HStack(spacing: 14) {
            SectionLabel("Tile size")

            HStack(spacing: 8) {
                ForEach(BoardGridSize.allCases, id: \.self) { size in
                    Button { selection = size } label: {
                        VStack(spacing: 1) {
                            Text(size.title)
                                .font(.fredoka(17))
                            Text(size.subtitle)
                                .font(.figtree(9))
                                .opacity(0.86)
                        }
                        .foregroundStyle(Color.ink)
                        .padding(.horizontal, 16)
                        .frame(height: 44)
                        .sticker(selection == size ? .signalGreen : .paper, radius: 16)
                        .contentShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(selection == size ? .isSelected : [])
                }
            }
        }
    }
}

#Preview {
    GridSizePicker(selection: .constant(.standard)).padding().background(Color.paper)
}
