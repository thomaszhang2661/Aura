import UIKit

final class LoginViewController: UIViewController {

    private let loginView = LoginView()

    override func loadView() {
        view = loginView      // ← THIS is what “use LoginView as root view” means
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // login button
        loginView.loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)

        // bottom label ("Log in") tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(bottomTapped))
        loginView.bottomLabel.addGestureRecognizer(tap)
    }

    @objc private func loginTapped() {
        print("Login tapped:", loginView.emailField.text ?? "")
    }

    @objc private func bottomTapped() {
        let vc = SignUpViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
