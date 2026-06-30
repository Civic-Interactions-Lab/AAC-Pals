//
//  AAC_LocationAwareApp.swift
//  AAC-LocationAware
//
//  Created by Dat Nguyen on 6/29/26.
//

import SwiftUI

@main
struct AAC_LocationAwareApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            AppView()
                .onAppear {
                    // Lock to landscape on iPad
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        AppDelegate.lockOrientation(.landscape)
                    }
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock: UIInterfaceOrientationMask = .landscape

    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        orientationLock = orientation
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
    }

    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        AppDelegate.orientationLock
    }
}
