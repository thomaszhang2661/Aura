//
//  UIViewControllerKeyboardManager.swift
//  Aura
//
//  Created by Chance Q on 11/23/25.
//

import UIKit

// MARK: - Shared extension: add tap gesture to dismiss keyboard in any screen.
extension UIViewController {
    func addDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditingTapped))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func endEditingTapped() {
        view.endEditing(true)
    }
}
