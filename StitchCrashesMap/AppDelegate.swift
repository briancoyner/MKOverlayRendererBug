//
//  Created by Brian Coyner on 3/12/22.
//

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = UIWindow()
}

extension AppDelegate {

    func application(
        _ application: UIApplication,
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Needed for iOS 15 navigation bars to render "default" appearance.
        let navigationBar = UINavigationBar.appearance()
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        navigationBar.standardAppearance = navigationBarAppearance
        navigationBar.scrollEdgeAppearance = navigationBarAppearance

        let toolbar = UIToolbar.appearance()
        let toolbarAppearance = UIToolbarAppearance()
        toolbarAppearance.configureWithDefaultBackground()
        toolbar.standardAppearance = toolbarAppearance
        toolbar.scrollEdgeAppearance = toolbarAppearance

        let mainViewController = MapViewController()
        window?.rootViewController = UINavigationController(rootViewController: mainViewController)
        window?.makeKeyAndVisible()
        return true
    }
}
