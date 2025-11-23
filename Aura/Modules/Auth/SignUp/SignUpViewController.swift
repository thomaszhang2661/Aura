import UIKit
import FirebaseAuth   // make sure you import FirebaseAuth so AuthService works

final class SignUpViewController: UIViewController {

    private let signUpView = SignUpView()

    override func loadView() {
        view = signUpView    // use SignUpView as root view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("✅ SignUpViewController viewDidLoad")

        // Sign up button
        signUpView.signUpButton.addTarget(self,
                                          action: #selector(signUpTapped),
                                          for: .touchUpInside)

        // Bottom label to go back
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(bottomTapped))
        signUpView.bottomLabel.addGestureRecognizer(tap)
    }

    // MARK: - Actions

    @objc private func signUpTapped() {
        // Read input
        let email = signUpView.emailField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = signUpView.passwordField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let confirm = signUpView.confirmField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        // Basic validation
        guard !email.isEmpty, !password.isEmpty, !confirm.isEmpty else {
            showAlert("All fields are required.")
            return
        }

        guard password == confirm else {
            showAlert("Passwords do not match.")
            return
        }

        // Firebase sign up via AuthService
        AuthService.shared.signUp(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    print("✅ Sign up success for uid:", user.uid)

                    // Notify others (Member C) that login succeeded
                    NotificationCenter.default.post(
                        name: .didLogin,
                        object: nil,
                        userInfo: ["uid": user.uid]
                    )

                    // For now: go back to login screen
                    // Later: Member C will replace this with navigation to Home
                    self?.navigationController?.popViewController(animated: true)

                case .failure(let error):
                    self?.showAlert("Sign up failed: \(error.localizedDescription)")
                }
            }
        }
    }

    @objc private func bottomTapped() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Helpers

    private func showAlert(_ message: String) {
        let ac = UIAlertController(title: "Oops",
                                   message: message,
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}
