import UIKit

final class LoginView: UIView {

    let titleLabel = UILabel()
    let emailField = UITextField()
    let passwordField = UITextField()
    let loginButton = UIButton(type: .system)
    let bottomLabel = UILabel()

    private let fieldStack = UIStackView()
    private let rootStack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 250/255, green: 248/255, blue: 244/255, alpha: 1)

        setupSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func makeUnderline(_ tf: UITextField, placeholder: String) {
        tf.placeholder = placeholder
        tf.borderStyle = .none

        let underline = CALayer()
        underline.backgroundColor = UIColor.black.withAlphaComponent(0.7).cgColor
        underline.frame = CGRect(x: 0, y: 43, width: UIScreen.main.bounds.width - 60, height: 1)
        tf.layer.addSublayer(underline)

        tf.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }

    private func setupSubviews() {
        // Title
        titleLabel.text = "Log In"
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textAlignment = .center

        // Email + password fields
        makeUnderline(emailField, placeholder: "Enter Your Email And")
        makeUnderline(passwordField, placeholder: "Password")
        passwordField.isSecureTextEntry = true

        // Button
        loginButton.setTitle("LOGIN", for: .normal)
        loginButton.backgroundColor = UIColor(red: 154/255, green: 130/255, blue: 199/255, alpha: 1)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        loginButton.layer.cornerRadius = 18
        loginButton.heightAnchor.constraint(equalToConstant: 54).isActive = true

        // Bottom label
        let text = NSMutableAttributedString(
            string: "Already have an account? ",
            attributes: [.foregroundColor: UIColor.darkGray]
        )
        text.append(NSAttributedString(
            string: "Log in",
            attributes: [.foregroundColor: UIColor(red: 154/255, green: 130/255, blue: 199/255, alpha: 1)]
        ))
        bottomLabel.attributedText = text
        bottomLabel.textAlignment = .center
        bottomLabel.isUserInteractionEnabled = true

        // Stacks
        fieldStack.axis = .vertical
        fieldStack.spacing = 22
        fieldStack.addArrangedSubview(emailField)
        fieldStack.addArrangedSubview(passwordField)

        rootStack.axis = .vertical
        rootStack.spacing = 28
        rootStack.addArrangedSubview(titleLabel)
        rootStack.addArrangedSubview(fieldStack)
        rootStack.addArrangedSubview(loginButton)

        [rootStack, bottomLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            rootStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            rootStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            rootStack.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),

            bottomLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            bottomLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            bottomLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -22)
        ])
    }
}
