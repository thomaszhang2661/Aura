import SwiftUI
import UIKit

struct LoginRootView: UIViewControllerRepresentable {
    // The UIKit type we are wrapping
    typealias UIViewControllerType = UINavigationController

    func makeUIViewController(context: Context) -> UINavigationController {
        print("🔥 makeUIViewController in LoginRootView")   // debug
        let loginVC = LoginViewController()
        let nav = UINavigationController(rootViewController: loginVC)
        return nav
    }

    func updateUIViewController(_ uiViewController: UINavigationController,
                                context: Context) {
        // nothing to update for now
    }
}
