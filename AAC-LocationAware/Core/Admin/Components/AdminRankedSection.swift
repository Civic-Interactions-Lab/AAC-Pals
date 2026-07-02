import SwiftUI

struct AdminRankedSection: View {
    let title: String
    let items: [(label: String, count: Int)]
    let emptyText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color(hex: "#1A1A2E"))

            if items.isEmpty {
                Text(emptyText)
                    .font(.system(size: 13))
                    .foregroundStyle(Color(hex: "#1A1A2E").opacity(0.4))
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        HStack {
                            Text("\(index + 1).")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color(hex: "#FF9F43"))
                                .frame(width: 20, alignment: .leading)
                            Text(item.label)
                                .font(.system(size: 13))
                                .foregroundStyle(Color(hex: "#1A1A2E"))
                            Spacer()
                            Text("\(item.count)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color(hex: "#FF9F43"))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(hex: "#FF9F43").opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview("With items") {
    AdminRankedSection(
        title: "Top Words",
        items: [("hello", 24), ("eat", 18), ("more", 12)],
        emptyText: "No data yet."
    )
    .padding()
    .background(Color(hex: "#FFF7EE"))
}

#Preview("Empty") {
    AdminRankedSection(title: "Top Words", items: [], emptyText: "No word activity yet.")
        .padding()
        .background(Color(hex: "#FFF7EE"))
}
