import SwiftUI

struct CategoryLegend: View {
    var body: some View {
        HStack(spacing: 9) {
            ForEach(FitzgeraldCategory.legend, id: \.self) { category in
                Text(category.name)
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(Color.ink)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(category.color, in: RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.ink, lineWidth: 2))
            }
        }
    }
}

#Preview {
    CategoryLegend().padding().background(Color.paper)
}
