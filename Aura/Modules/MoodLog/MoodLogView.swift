//
//  MoodLogView.swift
//  Aura
//
//  Created by Chance Q on 11/17/25.
//  Member B - Mood Log UI
//

import UIKit

final class MoodLogView: UIView {
    
    // MARK: - UI
    private let titleLabel = UILabel()
    private let moodStack = UIStackView()
    private(set) var moodButtons: [MoodEntry.Mood: UIButton] = [:]
    
    let noteTextView = UITextView()
    private let notePlaceholder = UILabel()
    let saveButton = UIButton(type: .system)
    let historyTableView = UITableView(frame: .zero, style: .insetGrouped)
    
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
        setupTitle()
        setupMoodRow()
        setupNoteField()
        setupSaveButton()
        setupTable()
        setupLayout()
    }
    
    private func setupTitle() {
        titleLabel.text = "Mood Logging"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .left
        titleLabel.textColor = .label
    }
    
    private func setupMoodRow() {
        moodStack.axis = .horizontal
        moodStack.spacing = 12
        moodStack.distribution = .fillEqually
        
        MoodEntry.Mood.allCases.forEach { mood in
            let button = UIButton(type: .system)
            button.setTitle("\(mood.emoji)\n\(mood.displayName)", for: .normal)
            button.titleLabel?.numberOfLines = 2
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            button.layer.cornerRadius = 16
            button.layer.borderWidth = 1.5
            button.layer.borderColor = UIColor.systemGray4.cgColor
            button.backgroundColor = UIColor.secondarySystemBackground
            button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 6, bottom: 10, right: 6)
            moodButtons[mood] = button
            moodStack.addArrangedSubview(button)
        }
    }
    
    private func setupNoteField() {
        noteTextView.layer.cornerRadius = 14
        noteTextView.layer.borderWidth = 1.2
        noteTextView.layer.borderColor = UIColor.systemGray4.cgColor
        noteTextView.font = UIFont.systemFont(ofSize: 16)
        noteTextView.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        
        notePlaceholder.text = "Journal entry (optional)"
        notePlaceholder.textColor = UIColor.secondaryLabel
        notePlaceholder.font = UIFont.systemFont(ofSize: 15)
        notePlaceholder.translatesAutoresizingMaskIntoConstraints = false
        noteTextView.addSubview(notePlaceholder)
        NSLayoutConstraint.activate([
            notePlaceholder.topAnchor.constraint(equalTo: noteTextView.topAnchor, constant: 12),
            notePlaceholder.leadingAnchor.constraint(equalTo: noteTextView.leadingAnchor, constant: 14)
        ])
    }
    
    private func setupSaveButton() {
        saveButton.setTitle("Save Mood", for: .normal)
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        saveButton.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.2)
        saveButton.setTitleColor(.label, for: .normal)
        saveButton.layer.cornerRadius = 14
        saveButton.layer.borderWidth = 1.5
        saveButton.layer.borderColor = UIColor.systemPurple.withAlphaComponent(0.5).cgColor
        saveButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
    }
    
    private func setupTable() {
        historyTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MoodCell")
        historyTableView.rowHeight = UITableView.automaticDimension
        historyTableView.estimatedRowHeight = 64
        historyTableView.backgroundColor = .clear
        historyTableView.setContentHuggingPriority(.defaultLow, for: .vertical)
        historyTableView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }
    
    private func setupLayout() {
        let stack = UIStackView(arrangedSubviews: [titleLabel, moodStack, noteTextView, saveButton, historyTableView])
        stack.axis = .vertical
        stack.spacing = 16
        stack.setCustomSpacing(10, after: titleLabel)
        stack.setCustomSpacing(18, after: moodStack)
        stack.setCustomSpacing(22, after: noteTextView)
        
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        noteTextView.translatesAutoresizingMaskIntoConstraints = false
        historyTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            
            moodStack.heightAnchor.constraint(equalToConstant: 110),
            noteTextView.heightAnchor.constraint(equalToConstant: 140),
            historyTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 220)
        ])
    }
    
    // MARK: - Helpers
    func updateMoodSelection(_ selectedMood: MoodEntry.Mood?) {
        moodButtons.forEach { mood, button in
            let isSelected = mood == selectedMood
            button.layer.borderColor = (isSelected ? UIColor.systemPurple : UIColor.systemGray4).cgColor
            button.backgroundColor = isSelected
                ? UIColor.systemPurple.withAlphaComponent(0.18)
                : UIColor.secondarySystemBackground
        }
    }
    
    func updateNotePlaceholderVisibility() {
        notePlaceholder.isHidden = !noteTextView.text.isEmpty
    }
}
