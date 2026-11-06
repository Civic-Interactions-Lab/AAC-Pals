import SwiftUI

struct CategoryLegend: View {
    var body: some View {
        HStack(spacing: 9) {
            ForEach(WordGroup.allCases, id: \.self) { group in
                Text(group.name)
                    .font(.figtree(12))
                    .foregroundStyle(Color.ink)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .sticker(group.color, radius: 16)
            }
        }
    }
}

#Preview {
    CategoryLegend().padding().background(Color.paper)
}
