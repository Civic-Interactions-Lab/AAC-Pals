import SwiftUI

struct FloatingShapes: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(colors: [Color(hex: "#FF6B6B"), Color(hex: "#FF9F43")], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 48, height: 48)
                .offset(x: -10, y: animate ? -6 : 0)
                .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: animate)

            Circle()
                .fill(LinearGradient(colors: [Color(hex: "#A29BFE"), Color(hex: "#6C5CE7")], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 32, height: 32)
                .offset(x: 36, y: animate ? 4 : -4)
                .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true).delay(0.4), value: animate)

            Circle()
                .fill(LinearGradient(colors: [Color(hex: "#1DD1A1"), Color(hex: "#00B894")], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 22, height: 22)
                .offset(x: 16, y: animate ? 44 : 38)
                .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(0.8), value: animate)

            RoundedRectangle(cornerRadius: 8)
                .fill(LinearGradient(colors: [Color(hex: "#FD79A8"), Color(hex: "#E84393")], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 20, height: 20)
                .rotationEffect(.degrees(animate ? 30 : 10))
                .offset(x: -28, y: animate ? 52 : 44)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.2), value: animate)
        }
        .onAppear { animate = true }
    }
}

#Preview {
    ZStack {
        DecorativeBackground()
        FloatingShapes()
            .frame(width: 120, height: 110)
    }
}
