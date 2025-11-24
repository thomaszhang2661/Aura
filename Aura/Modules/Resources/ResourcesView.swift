import UIKit

final class ResourcesView: UIView {
    
    // MARK: - UI Components
    let findNearbyButton = UIButton(type: .system)
    let viewMapButton = UIButton(type: .system)
    let chatWithAuraButton = UIButton(type: .system)
    let resourcesTableView = UITableView(frame: .zero, style: .insetGrouped)

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Setup
    private func setup() {
        backgroundColor = UIColor.systemBackground
        setupTableView()
        setupLayout()
    }
    
    private func setupTableView() {
        resourcesTableView.backgroundColor = .clear
        resourcesTableView.separatorStyle = .singleLine
        resourcesTableView.register(ResourceCell.self, forCellReuseIdentifier: "ResourceCell")
    }

    private func setupLayout() {
        // Vertical Stack for buttons
        let buttonStack = UIStackView(arrangedSubviews: [findNearbyButton, viewMapButton, chatWithAuraButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = 12
        buttonStack.alignment = .fill
        buttonStack.distribution = .fillEqually

        addSubview(buttonStack)
        addSubview(resourcesTableView)
        
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        resourcesTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Button Stack
            buttonStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            buttonStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            buttonStack.heightAnchor.constraint(equalToConstant: 210),
            
            // Table View
            resourcesTableView.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 16),
            resourcesTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            resourcesTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            resourcesTableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        styleCardButton(findNearbyButton, title: "📍 Find Nearby Support", color: .systemTeal)
        styleCardButton(viewMapButton, title: "🗺️ View on Map", color: .systemIndigo)
        styleCardButton(chatWithAuraButton, title: "💬 Chat with Aura", color: .systemPurple)
    }

    private func styleCardButton(_ button: UIButton, title: String, color: UIColor) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center

        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.layer.borderWidth = 2
        button.layer.borderColor = color.withAlphaComponent(0.6).cgColor
        button.backgroundColor = color.withAlphaComponent(0.12)
        button.setTitleColor(UIColor.label, for: .normal)
    }
}

// MARK: - Resource Cell
class ResourceCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        textLabel?.numberOfLines = 0
        detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
        detailTextLabel?.textColor = .secondaryLabel
        detailTextLabel?.numberOfLines = 0
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
