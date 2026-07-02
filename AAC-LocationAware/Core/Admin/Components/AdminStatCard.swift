import SwiftUI

struct AdminStatCard: View {
    let label: String
    let value: Int
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(color)
                Spacer()
            }
            Text("\(value)")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color(hex: "#1A1A2E"))
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color(hex: "#1A1A2E").opacity(0.5))
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    HStack(spacing: 12) {
        AdminStatCard(label: "Interactions", value: 142, icon: "hand.tap.fill", color: Color(hex: "#FF9F43"))
        AdminStatCard(label: "Users", value: 3, icon: "person.2.fill", color: Color(hex: "#FF6B6B"))
    }
    .padding()
    .background(Color(hex: "#FFF7EE"))
}
