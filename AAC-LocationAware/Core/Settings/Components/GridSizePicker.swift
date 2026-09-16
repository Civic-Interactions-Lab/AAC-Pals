import SwiftUI

struct GridSizePicker: View {
    @Binding var selection: BoardGridSize

    var body: some View {
        HStack(spacing: 16) {
            Text("GRID SIZE")
                .font(.system(size: 11, weight: .heavy))
                .tracking(1)
                .foregroundStyle(Color.ink.opacity(0.86))

            HStack(spacing: 8) {
                ForEach(BoardGridSize.allCases, id: \.self) { size in
                    Button { selection = size } label: {
                        Text(size.title)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.ink)
                            .padding(.horizontal, 16)
                            .frame(height: 44)
                            .background(selection == size ? Color.butter : Color.paper, in: RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.ink, lineWidth: 2))
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
    GridSizePicker(selection: .constant(.medium)).padding().background(Color.paper)
}
