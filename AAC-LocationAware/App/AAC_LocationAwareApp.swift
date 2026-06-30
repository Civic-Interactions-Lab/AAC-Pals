import SwiftUI

@main
struct AAC_LocationAwareApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(delegate.dependencies.pictogramManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var dependencies: Dependency!

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        let config: BuildConfiguration

        #if MOCK
        config = .mock
        print("MOCK BUILD")
        #elseif DEV
        config = .development
        print("DEV BUILD")
        #else
        config = .production
        print("PROD BUILD")
        #endif

        config.configure()
        dependencies = Dependency(config)
        return true
    }
}

enum BuildConfiguration {
    case mock, development, production

    func configure() {
        switch self {
        case .mock:
            break
        case .development:
            // Configure Supabase dev + some dev tools
            break
        case .production:
            // Configure Supabase prod
            break
        }
    }
}

@MainActor
struct Dependency {
    let pictogramManager: PictogramManager

    init(_ config: BuildConfiguration) {
        switch config {
        case .mock:
            self.pictogramManager = PictogramManager(service: MockPictogramService())
        case .development:
            self.pictogramManager = PictogramManager(service: ArasaacPictogramService())
        case .production:
            self.pictogramManager = PictogramManager(service: ArasaacPictogramService())
        }
    }
}
