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

        addDismissKeyboardGesture()

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

                    EventBus.shared.emit(.didLogin(uid: user.uid))
                    self?.goToHome()

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

    // MARK: - Helpers

    private func showAlert(_ message: String, title: String = "Alert") {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func goToHome() {
        // Push HomeViewController on the current navigation stack
        let homeVC = HomeViewController()
        navigationController?.setViewControllers([homeVC], animated: true)
    }
}
