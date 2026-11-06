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
                .environment(delegate.dependencies.boardWordsManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var dependencies: Dependency!

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return .landscape
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }

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

final class SceneDelegate: NSObject, UIWindowSceneDelegate {
    @available(iOS 27.0, *)
    func supportedInterfaceOrientations(for windowScene: UIWindowScene) -> UIInterfaceOrientationMask {
        .landscape
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
    let boardWordsManager: BoardWordsManager

    init(_ config: BuildConfiguration) {
        switch config {
        case .mock:
            self.authManager = AuthManager(service: MockAuthService(authUser: .mock))
            self.userManager = UserManager(service: MockUserService())
            self.pictogramManager = PictogramManager(service: MockPictogramService())
            self.beaconManager = BeaconManager(service: MockBeaconService())
            self.interactionManager = InteractionManager(service: MockInteractionService())
            self.adminManager = AdminManager(service: LocalAdminService(seedIfEmpty: true))
            self.boardWordsManager = BoardWordsManager(service: LocalBoardWordsService())
        case .development, .production:
            self.authManager = AuthManager(service: SupabaseAuthService())
            self.userManager = UserManager(service: SupabaseUserService())
            self.pictogramManager = PictogramManager(service: ArasaacPictogramService())
            self.beaconManager = BeaconManager(service: CoreBluetoothBeaconService())
            self.interactionManager = InteractionManager(service: SupabaseInteractionService())
            self.adminManager = AdminManager(service: LocalAdminService())
            self.boardWordsManager = BoardWordsManager(service: LocalBoardWordsService())
        }
    }
}
