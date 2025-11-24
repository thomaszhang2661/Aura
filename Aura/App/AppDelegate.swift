//
//  AppDelegate.swift
//  Aura
//

import UIKit
import FirebaseCore

@main                      // 👈 this is now the single entry point
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?  // 👈 old-style UIWindow property

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // 1. Configure Firebase
        FirebaseApp.configure()
        print("✅ Firebase configured in AppDelegate")

        // 2. Create the main window
        window = UIWindow(frame: UIScreen.main.bounds)

        // 3. Set your login flow as the root view controller
        let loginVC = LoginViewController()
        let nav = UINavigationController(rootViewController: loginVC)
        window?.rootViewController = nav

        // 4. Show the window
        window?.makeKeyAndVisible()

        return true
    }
}
