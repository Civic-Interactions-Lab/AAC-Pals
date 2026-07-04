import SwiftUI

@main
struct AAC_LocationAwareApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(delegate.dependencies.authManager)
                .environment(delegate.dependencies.userManager)
                .environment(delegate.dependencies.pictogramManager)
                .environment(delegate.dependencies.beaconManager)
                .environment(delegate.dependencies.interactionManager)
                .environment(delegate.dependencies.adminManager)
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
        _ = SpeechManager.shared
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
            break
        case .production:
            break
        }
    }
}

@MainActor
struct Dependency {
    let authManager: AuthManager
    let userManager: UserManager
    let pictogramManager: PictogramManager
    let beaconManager: BeaconManager
    let interactionManager: InteractionManager
    let adminManager: AdminManager

    init(_ config: BuildConfiguration) {
        switch config {
        case .mock:
            self.authManager = AuthManager(service: MockAuthService(authUser: nil))
            self.userManager = UserManager(service: MockUserService())
            self.pictogramManager = PictogramManager(service: MockPictogramService())
            self.beaconManager = BeaconManager(service: MockBeaconService())
            self.interactionManager = InteractionManager(service: MockInteractionService())
            self.adminManager = AdminManager(service: MockAdminService())
        case .development, .production:
            self.authManager = AuthManager(service: SupabaseAuthService())
            self.userManager = UserManager(service: SupabaseUserService())
            self.pictogramManager = PictogramManager(service: ArasaacPictogramService())
            self.beaconManager = BeaconManager(service: CoreBluetoothBeaconService())
            self.interactionManager = InteractionManager(service: SupabaseInteractionService())
            self.adminManager = AdminManager(service: SupabaseAdminService())
        }
    }
}
