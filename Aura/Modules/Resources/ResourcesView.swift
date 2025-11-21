import UIKit

final class ResourcesView: UIView {

    let findNearbyButton = UIButton(type: .system)
    let chatWithAuraButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = UIColor.systemBackground
        setupLayout()
    }

    private func setupLayout() {
        // Vertical Stack Container
        let stack = UIStackView(arrangedSubviews: [findNearbyButton, chatWithAuraButton])
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .fill
        stack.distribution = .fillEqually

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 80),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            stack.heightAnchor.constraint(equalToConstant: 260)
        ])

        styleCardButton(findNearbyButton, title: "Find Nearby Support")
        styleCardButton(chatWithAuraButton, title: "Chat with Aura")
    }

    private func styleCardButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center

        button.layer.cornerRadius = 24
        button.layer.masksToBounds = true
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemPurple.withAlphaComponent(0.7).cgColor
        button.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.15)
        button.setTitleColor(UIColor.label, for: .normal)
    }
}
