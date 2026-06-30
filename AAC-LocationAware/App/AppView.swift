import SwiftUI

struct AppView: View {
    var body: some View {
        BoardView()
    }
}

// MARK: - Preview Helper

extension View {
    func previewAllEnvironments() -> some View {
        self
            .environment(PictogramManager(service: MockPictogramService()))
    }
}

#Preview("Default") {
    AppView()
        .previewAllEnvironments()
}

#Preview("Slow pictograms") {
    AppView()
        .environment(PictogramManager(service: MockPictogramService(delay: 2)))
}

#Preview("Failed pictograms") {
    AppView()
        .environment(PictogramManager(service: MockPictogramService(showError: true)))
}
