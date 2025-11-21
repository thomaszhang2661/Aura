//
//  ChatView.swift
//  Aura
//
//  Created by Chance Q on 11/17/25.
//

import UIKit

final class ChatView: UIView {

    // MARK: - Subviews

    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()

    private let bottomBar = UIView()
    let inputBackgroundView = UIView()
    let inputPlaceholderLabel = UILabel()

    // MARK: - Init

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
        setupScrollArea()
        setupBottomBar()
        addDemoBubbles()
    }

    private func setupScrollArea() {
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -80)
        ])

        scrollView.addSubview(contentStackView)
        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.spacing = 16
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    private func setupBottomBar() {
        addSubview(bottomBar)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 64)
        ])

        bottomBar.backgroundColor = UIColor.systemBackground

        bottomBar.addSubview(inputBackgroundView)
        inputBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            inputBackgroundView.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 24),
            inputBackgroundView.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -24),
            inputBackgroundView.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            inputBackgroundView.heightAnchor.constraint(equalToConstant: 44)
        ])

        inputBackgroundView.layer.cornerRadius = 22
        inputBackgroundView.layer.masksToBounds = true
        inputBackgroundView.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.3)

        inputBackgroundView.addSubview(inputPlaceholderLabel)
        inputPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            inputPlaceholderLabel.leadingAnchor.constraint(equalTo: inputBackgroundView.leadingAnchor, constant: 16),
            inputPlaceholderLabel.trailingAnchor.constraint(equalTo: inputBackgroundView.trailingAnchor, constant: -16),
            inputPlaceholderLabel.centerYAnchor.constraint(equalTo: inputBackgroundView.centerYAnchor)
        ])
        inputPlaceholderLabel.text = "Type a message…"
        inputPlaceholderLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        inputPlaceholderLabel.font = UIFont.systemFont(ofSize: 14)
        inputPlaceholderLabel.textAlignment = .center
    }

    private func addDemoBubbles() {
        addBubble(text: "Hello! How are you today?", isMe: false)
        addBubble(text: "……", isMe: true)
        addBubble(text: "……", isMe: true)
    }

    private func addBubble(text: String, isMe: Bool) {
        let container = UIView()
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15)

        container.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        let horizontalPadding: CGFloat = 16
        let verticalPadding: CGFloat = 10

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: verticalPadding),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -verticalPadding),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: horizontalPadding),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -horizontalPadding)
        ])

        container.layer.cornerRadius = 18
        container.layer.masksToBounds = true
        container.layer.borderWidth = 1.2
        container.layer.borderColor = UIColor.systemPurple.withAlphaComponent(0.6).cgColor
        container.backgroundColor = isMe
            ? UIColor.systemPurple.withAlphaComponent(0.12)
            : UIColor.systemGray6

        let wrapper = UIStackView(arrangedSubviews: [container])
        wrapper.axis = .horizontal

        if isMe {
            wrapper.alignment = .trailing
        } else {
            wrapper.alignment = .leading
        }

        contentStackView.addArrangedSubview(wrapper)
    }
}
