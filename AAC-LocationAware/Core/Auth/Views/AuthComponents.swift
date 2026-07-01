import SwiftUI

// MARK: - AuthBackground

struct AuthBackground: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                Color(hex: "#FFF7EE").ignoresSafeArea()

                Circle()
                    .fill(Color(hex: "#FF9F43").opacity(0.18))
                    .frame(width: 320, height: 320)
                    .blur(radius: 60)
                    .offset(x: w * 0.78 - w / 2, y: h * 0.72 - h / 2)

                Circle()
                    .fill(Color(hex: "#FF6B6B").opacity(0.13))
                    .frame(width: 260, height: 260)
                    .blur(radius: 50)
                    .offset(x: w * 0.88 - w / 2, y: h * 0.80 - h / 2)

                Circle()
                    .fill(Color(hex: "#FFEAA7").opacity(0.25))
                    .frame(width: 200, height: 200)
                    .blur(radius: 40)
                    .offset(x: w * 0.70 - w / 2, y: h * 0.85 - h / 2)

                Circle()
                    .fill(Color(hex: "#FF9F43").opacity(0.10))
                    .frame(width: 150, height: 150)
                    .blur(radius: 35)
                    .offset(x: w * 0.92 - w / 2, y: h * 0.88 - h / 2)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - AuthTextField

struct AuthTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure = false
    var isFocused = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color(hex: "#FF9F43"))
                .frame(width: 20)

            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .font(.system(size: 15, weight: .medium, design: .rounded))
        .padding(15)
        .background(Color(hex: "#FFF7EE"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(
                    isFocused ? Color(hex: "#FF9F43") : Color(hex: "#FF9F43").opacity(0.25),
                    lineWidth: isFocused ? 2 : 1.5
                )
        )
    }
}

// MARK: - AuthFloatingShapes

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
