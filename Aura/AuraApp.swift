//
//  AuraApp.swift
//  Aura
//
//  Created by 张建 on 2025/11/16.
//
//  NOTE: This file is not used when using UIKit AppDelegate + SceneDelegate.
//  The @main entry point is in AppDelegate.swift.

import SwiftUI
import UIKit

// @main  // REMOVED: Using AppDelegate as main entry point
struct AuraApp: App {
    var body: some Scene {
        WindowGroup {
            RootViewControllerWrapper()
                .ignoresSafeArea()
        }
    }
}

struct RootViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return UINavigationController(rootViewController: HomeViewController())
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // no-op
    }
}

