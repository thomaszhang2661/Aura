import UIKit

final class SignUpViewController: UIViewController {

    private let signUpView = SignUpView()

    override func loadView() {
        view = signUpView    // ← this screen uses SignUpView as the whole UI
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Button
        signUpView.signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)

        // Tap bottom label → go back
        let tap = UITapGestureRecognizer(target: self, action: #selector(bottomTapped))
        signUpView.bottomLabel.addGestureRecognizer(tap)
    }

    @objc private func signUpTapped() {
        print("SIGN UP tapped:", signUpView.emailField.text ?? "")
    }

    @objc private func bottomTapped() {
        navigationController?.popViewController(animated: true)
    }
}
