import UIKit

final class LoginViewController: UIViewController {

    private let loginView = LoginView()

    override func loadView() {
        view = loginView      // use LoginView as the root view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("✅ LoginViewController viewDidLoad")

        // login button
        loginView.loginButton.addTarget(self,
                                        action: #selector(loginTapped),
                                        for: .touchUpInside)

        // bottom label ("Log in") tap  → go to SignUp
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(bottomTapped))
        loginView.bottomLabel.addGestureRecognizer(tap)

        // 👇 temporary Logout button in top-right corner
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Logout",
            style: .plain,
            target: self,
            action: #selector(logoutTapped)
        )
    }

    // MARK: - Actions

    @objc private func loginTapped() {
        let email = (loginView.emailField.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let password = (loginView.passwordField.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !email.isEmpty, !password.isEmpty else {
            showAlert("Email and password cannot be empty.", title: "Missing Info")
            return
        }

        AuthService.shared.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    print("✅ Login success for uid:", user.uid)

                    NotificationCenter.default.post(
                        name: .didLogin,
                        object: nil,
                        userInfo: ["uid": user.uid]
                    )

                case .failure(let error):
                    print("❌ Login failed:", error)
                    self?.showAlert(
                        "Login failed: \(error.localizedDescription)",
                        title: "Login Error"
                    )
                }
            }
        }
    }

    @objc private func bottomTapped() {
        let vc = SignUpViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func logoutTapped() {
        let result = AuthService.shared.signOut()

        switch result {
        case .success:
            print("✅ Logout success")

            NotificationCenter.default.post(name: .didLogout, object: nil)

            // Updated alert title
            showAlert("You have been logged out.", title: "Success")

        case .failure(let error):
            print("❌ Logout failed:", error)
            showAlert(
                "Logout failed: \(error.localizedDescription)",
                title: "Logout Error"
            )
        }
    }

    // MARK: - Helpers

    private func showAlert(_ message: String, title: String = "Alert") {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
