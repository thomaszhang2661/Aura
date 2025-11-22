//
//  HomeView.swift
//  Aura
//
//  Created by Chance Q on 11/17/25.
//  Member C - Home Module UI
//

import UIKit

final class HomeView: UIView {
    
    // MARK: - UI Components
    let welcomeLabel = UILabel()
    let moodLogButton = UIButton(type: .system)
    let chatButton = UIButton(type: .system)
    let resourcesButton = UIButton(type: .system)
    
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
        backgroundColor = .systemBackground
        setupWelcomeLabel()
        setupButtons()
        setupLayout()
    }
    
    private func setupWelcomeLabel() {
        welcomeLabel.text = "Welcome to Aura"
        welcomeLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        welcomeLabel.textAlignment = .center
        welcomeLabel.textColor = .label
        welcomeLabel.numberOfLines = 0
    }
    
    private func setupButtons() {
        styleCardButton(moodLogButton, 
                       title: "📝 Mood Log", 
                       subtitle: "Track your daily emotions",
                       color: .systemIndigo)
        
        styleCardButton(chatButton, 
                       title: "💬 Chat with Aura", 
                       subtitle: "AI support assistant",
                       color: .systemPurple)
        
        styleCardButton(resourcesButton, 
                       title: "🏥 Find Resources", 
                       subtitle: "Get help nearby",
                       color: .systemTeal)
    }
    
    private func setupLayout() {
        // Container Stack
        let buttonStack = UIStackView(arrangedSubviews: [moodLogButton, chatButton, resourcesButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = 20
        buttonStack.alignment = .fill
        buttonStack.distribution = .fillEqually
        
        addSubview(welcomeLabel)
        addSubview(buttonStack)
        
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Welcome Label
            welcomeLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 40),
            welcomeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            welcomeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            
            // Button Stack
            buttonStack.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 60),
            buttonStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            buttonStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            buttonStack.heightAnchor.constraint(equalToConstant: 420)
        ])
    }
    
    private func styleCardButton(_ button: UIButton, title: String, subtitle: String, color: UIColor) {
        // Create attributed title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 22),
            .foregroundColor: UIColor.label
        ]
        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.secondaryLabel
        ]
        
        let attributedString = NSMutableAttributedString(string: title + "\n", attributes: titleAttributes)
        attributedString.append(NSAttributedString(string: subtitle, attributes: subtitleAttributes))
        
        button.setAttributedTitle(attributedString, for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.contentVerticalAlignment = .center
        
        // Style
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.layer.borderWidth = 2
        button.layer.borderColor = color.withAlphaComponent(0.6).cgColor
        button.backgroundColor = color.withAlphaComponent(0.12)
        
        // Add shadow
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.1
    }
}
