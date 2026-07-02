import SwiftUI

struct DecorativeBackground: View {
    @State private var positions: [CGSize] = Array(repeating: .zero, count: 4)

    private let blobs: [(color: String, opacity: Double, size: CGFloat, blur: CGFloat)] = [
        ("#FF9F43", 0.08, 320, 60),
        ("#FF6B6B", 0.06, 260, 50),
        ("#FFEAA7", 0.12, 200, 40),
        ("#FF9F43", 0.05, 150, 35),
    ]

    private let durations: [Double] = [7.0, 5.5, 8.0, 6.5]

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                Color(hex: "#FFF7EE").ignoresSafeArea()

                ForEach(blobs.indices, id: \.self) { i in
                    let b = blobs[i]
                    Circle()
                        .fill(Color(hex: b.color).opacity(b.opacity))
                        .frame(width: b.size, height: b.size)
                        .blur(radius: b.blur)
                        .offset(positions[i])
                        .animation(
                            .easeInOut(duration: durations[i])
                            .repeatForever(autoreverses: true),
                            value: positions[i]
                        )
                }
            }
            .onAppear {
                positions = [
                    CGSize(width: w * 0.3,   height: h * 0.25),
                    CGSize(width: -w * 0.25, height: h * 0.3),
                    CGSize(width: w * 0.2,   height: -h * 0.25),
                    CGSize(width: -w * 0.3,  height: -h * 0.2),
                ]
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    DecorativeBackground()
}
