import SwiftUI

struct AddWordCard: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(hex: "#FF9F43"), style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                    .frame(height: 56)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color(hex: "#FF9F43"))
                    )

                Text("Add Word")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#FF9F43"))

                Text("tap to add")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#9CA3AF"))
            }
            .padding(10)
            .background(Color.white.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "#FF9F43").opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [5])))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AddWordCard(onTap: {})
        .frame(width: 120)
        .padding()
        .background(Color(hex: "#FFF7EE"))
}
