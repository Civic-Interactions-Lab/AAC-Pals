import SwiftUI

struct AuthFloatingShapes: View {
    @State private var animate = false

    private let shapes: [(color: String, size: CGFloat, x: CGFloat, y: CGFloat, delay: Double)] = [
        ("#FF9F43", 28, 10, 80, 0.0),
        ("#FF6B6B", 20, 55, 55, 0.3),
        ("#FFEAA7", 24, 95, 75, 0.6),
        ("#FF9F43", 16, 75, 20, 0.9),
    ]

    var body: some View {
        ZStack {
            ForEach(shapes.indices, id: \.self) { i in
                let s = shapes[i]
                Circle()
                    .fill(Color(hex: s.color).opacity(0.55))
                    .frame(width: s.size, height: s.size)
                    .offset(x: s.x - 55, y: s.y - 55)
                    .offset(y: animate ? -5 : 5)
                    .animation(
                        .easeInOut(duration: 2.2)
                        .repeatForever(autoreverses: true)
                        .delay(s.delay),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
    }
}

#Preview {
    ZStack {
        Color(hex: "#FFF7EE").ignoresSafeArea()
        AuthFloatingShapes()
            .frame(width: 120, height: 110)
    }
}
