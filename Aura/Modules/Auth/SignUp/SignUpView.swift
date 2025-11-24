import UIKit

final class SignUpView: UIView {

    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let emailField = UITextField()
    let passwordField = UITextField()
    let confirmField = UITextField()
    let signUpButton = UIButton(type: .system)
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
        titleLabel.text = "Sign Up"
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textAlignment = .center

        subtitleLabel.text = "First Create Your Account"
        subtitleLabel.font = .systemFont(ofSize: 15)
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .darkGray

        configureEmailField()
        configurePasswordField()
        configureConfirmField()

        signUpButton.setTitle("SIGN UP", for: .normal)
        signUpButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        signUpButton.backgroundColor = UIColor(red: 154/255, green: 130/255, blue: 199/255, alpha: 1)
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.layer.cornerRadius = 18
        signUpButton.heightAnchor.constraint(equalToConstant: 54).isActive = true

        let txt = NSMutableAttributedString(
            string: "Already have an account? ",
            attributes: [.foregroundColor: UIColor.darkGray]
        )
        txt.append(NSAttributedString(
            string: "Log in",
            attributes: [.foregroundColor: UIColor(red: 154/255, green: 130/255, blue: 199/255, alpha: 1)]
        ))
        bottomLabel.attributedText = txt
        bottomLabel.textAlignment = .center
        bottomLabel.isUserInteractionEnabled = true

        fieldStack.axis = .vertical
        fieldStack.spacing = 22
        fieldStack.addArrangedSubview(emailField)
        fieldStack.addArrangedSubview(passwordField)
        fieldStack.addArrangedSubview(confirmField)

        rootStack.axis = .vertical
        rootStack.spacing = 18
        rootStack.addArrangedSubview(titleLabel)
        rootStack.addArrangedSubview(subtitleLabel)
        rootStack.setCustomSpacing(28, after: subtitleLabel)
        rootStack.addArrangedSubview(fieldStack)
        rootStack.addArrangedSubview(signUpButton)

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

    // MARK: - Field Config
    private func configureEmailField() {
        makeUnderline(emailField, placeholder: "Email")
        emailField.keyboardType = .emailAddress
        emailField.autocapitalizationType = .none
        emailField.autocorrectionType = .no
        emailField.textContentType = .emailAddress
    }

    private func configurePasswordField() {
        makeUnderline(passwordField, placeholder: "Password")
        passwordField.isSecureTextEntry = true
        passwordField.keyboardType = .asciiCapable
        passwordField.autocapitalizationType = .none
        passwordField.autocorrectionType = .no
        passwordField.textContentType = .password
    }

    private func configureConfirmField() {
        makeUnderline(confirmField, placeholder: "Confirm your password")
        confirmField.isSecureTextEntry = true
        confirmField.keyboardType = .asciiCapable
        confirmField.autocapitalizationType = .none
        confirmField.autocorrectionType = .no
        confirmField.textContentType = .newPassword
    }
}
