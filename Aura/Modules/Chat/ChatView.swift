//
//  ChatView.swift
//  Aura
//
//  Created by Chance Q on 11/17/25.
//  Member B - Chat UI
//

import UIKit

final class ChatView: UIView {
    
    let tableView = UITableView(frame: .zero, style: .plain)
    let inputTextView = UITextView()
    private let placeholderLabel = UILabel()
    let sendButton = UIButton(type: .system)
    private let inputContainer = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .systemBackground
        setupTableView()
        setupInputBar()
        layoutUI()
    }
    
    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.keyboardDismissMode = .interactive
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 72
    }
    
    private func setupInputBar() {
        inputContainer.backgroundColor = UIColor.secondarySystemBackground
        inputContainer.layer.cornerRadius = 18
        inputContainer.layer.borderWidth = 1
        inputContainer.layer.borderColor = UIColor.systemGray4.cgColor
        
        inputTextView.font = UIFont.systemFont(ofSize: 16)
        inputTextView.isScrollEnabled = false
        inputTextView.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        
        placeholderLabel.text = "Type a message…"
        placeholderLabel.textColor = .secondaryLabel
        placeholderLabel.font = UIFont.systemFont(ofSize: 15)
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        inputTextView.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: inputTextView.topAnchor, constant: 10),
            placeholderLabel.leadingAnchor.constraint(equalTo: inputTextView.leadingAnchor, constant: 12)
        ])
        
        sendButton.setTitle("Send", for: .normal)
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        sendButton.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.2)
        sendButton.layer.cornerRadius = 14
        sendButton.layer.borderWidth = 1
        sendButton.layer.borderColor = UIColor.systemPurple.withAlphaComponent(0.4).cgColor
        sendButton.setTitleColor(.label, for: .normal)
    }
    
    private func layoutUI() {
        addSubview(tableView)
        addSubview(inputContainer)
        inputContainer.addSubview(inputTextView)
        inputContainer.addSubview(sendButton)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        inputTextView.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            inputContainer.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 8),
            inputContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            inputContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            inputContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8),
            
            inputTextView.topAnchor.constraint(equalTo: inputContainer.topAnchor, constant: 8),
            inputTextView.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 10),
            inputTextView.bottomAnchor.constraint(equalTo: inputContainer.bottomAnchor, constant: -8),
            
            sendButton.leadingAnchor.constraint(equalTo: inputTextView.trailingAnchor, constant: 8),
            sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -10),
            sendButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 72),
            sendButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func updatePlaceholderVisibility() {
        placeholderLabel.isHidden = !inputTextView.text.isEmpty
    }
}
