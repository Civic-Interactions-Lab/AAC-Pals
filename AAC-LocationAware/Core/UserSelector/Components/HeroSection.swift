import SwiftUI

struct HeroSection: View {
    let adminName: String

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text("👋")
                        .font(.system(size: 18))
                    Text("Welcome back, \(adminName)!")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#FF9F43"))
                }

                Text("Who's learning today?")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "#1A1A2E"))

                Text("Choose a user to continue\ntheir adventure.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#9CA3AF"))
                    .lineSpacing(2)
            }
            .padding(.leading, 32)

            Spacer()
        }
        .padding(.bottom, 28)
    }
}

#Preview {
    ZStack {
        DecorativeBackground()
        VStack {
            HeroSection(adminName: "jaime")
        }
    }
}
