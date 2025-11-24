//
//  HomeViewController.swift
//  Aura
//
//  Created by 张建 on 2025/11/17.
//  Member C - Home Module Controller
//  Refactored: 2025/11/20 - Renamed from ViewController to HomeViewController
//

import UIKit

class HomeViewController: UIViewController {
    
    private var homeView: HomeView {
        return view as! HomeView
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        view = HomeView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Aura"
        setupNavigationBar()
        setupButtonActions()
        setupEventListeners()
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Optional: Add logout button
        let logoutButton = UIBarButtonItem(
            title: "Logout",
            style: .plain,
            target: self,
            action: #selector(logoutTapped)
        )
        navigationItem.rightBarButtonItem = logoutButton
    }
    
    private func setupButtonActions() {
        homeView.moodLogButton.addTarget(self, action: #selector(openMoodLog), for: .touchUpInside)
        homeView.chatButton.addTarget(self, action: #selector(openChat), for: .touchUpInside)
        homeView.resourcesButton.addTarget(self, action: #selector(openResources), for: .touchUpInside)
    }
    
    private func setupEventListeners() {
        // Listen to app events
        EventBus.shared.on(id: "HomeViewController") { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .didLogin(let uid):
                print("✅ Home: User logged in with uid: \(uid)")
                // Could update welcome message with user name
            case .didLogout:
                self.handleLogout()
            case .openChat:
                self.openChat()
            case .openMoodLog:
                self.openMoodLog()
            case .openResources:
                self.openResources()
            }
        }
    }
    
    deinit {
        EventBus.shared.off(id: "HomeViewController")
    }
    
    // MARK: - Navigation Actions
    @objc private func openMoodLog() {
        print("📝 Navigate to Mood Log")
        let moodLogVC = MoodLogViewController()
        navigationController?.pushViewController(moodLogVC, animated: true)
    }
    
    @objc private func openChat() {
        print("💬 Navigate to Chat")
        let chatVC = ChatViewController()
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    @objc private func openResources() {
        print("🏥 Navigate to Resources")
        let resourcesVC = ResourcesViewController()
        navigationController?.pushViewController(resourcesVC, animated: true)
    }
    
    @objc private func logoutTapped() {
        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { _ in
            switch AuthService.shared.signOut() {
            case .success:
                EventBus.shared.emit(.didLogout)
            case .failure(let error):
                self.showPlaceholder(title: "Logout Failed", message: error.localizedDescription)
            }
        })
        present(alert, animated: true)
    }
    
    private func handleLogout() {
        print("🚪 Logging out...")
        navigationController?.setViewControllers([LoginViewController()], animated: true)
    }
    
    // MARK: - Helper
    private func showPlaceholder(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
