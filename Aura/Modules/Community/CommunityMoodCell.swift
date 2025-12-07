//
//  CommunityMoodCell.swift
//  Aura
//
//  Simple cell showing a public mood entry with like button.
//

import UIKit

final class CommunityMoodCell: UITableViewCell {
    static let reuseId = "CommunityMoodCell"

    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let noteLabel = UILabel()
    private let likeButton = UIButton(type: .system)
    private var onLikeTapped: ((Bool) -> Void)?
    private var isLiked = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        selectionStyle = .none
        emojiLabel.font = UIFont.systemFont(ofSize: 26)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        subtitleLabel.font = UIFont.systemFont(ofSize: 13)
        subtitleLabel.textColor = .secondaryLabel
        noteLabel.font = UIFont.systemFont(ofSize: 14)
        noteLabel.textColor = .label
        noteLabel.numberOfLines = 0

        likeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        likeButton.tintColor = .systemPink
        likeButton.layer.cornerRadius = 12
        likeButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        likeButton.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let headerStack = UIStackView(arrangedSubviews: [emojiLabel, textStack, UIView(), likeButton])
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = 8

        let mainStack = UIStackView(arrangedSubviews: [headerStack, noteLabel])
        mainStack.axis = .vertical
        mainStack.spacing = 8
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    func configure(with entry: PublicMoodEntry, onLike: @escaping (Bool) -> Void) {
        emojiLabel.text = entry.mood.emoji
        titleLabel.text = "\(entry.mood.displayName)"
        let author = entry.authorName ?? "Someone"
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        subtitleLabel.text = "\(author) • \(formatter.string(from: entry.createdAt))"
        noteLabel.text = entry.note?.isEmpty == false ? entry.note : "No note"
        isLiked = entry.likedByCurrentUser
        updateLikeTitle(count: entry.likeCount)
        onLikeTapped = onLike
    }

    private func updateLikeTitle(count: Int) {
        let heart = isLiked ? "❤️" : "🤍"
        likeButton.setTitle("\(heart) \(count)", for: .normal)
        likeButton.backgroundColor = isLiked ? UIColor.systemPink.withAlphaComponent(0.12) : UIColor.secondarySystemBackground
        likeButton.setTitleColor(.systemPink, for: .normal)
    }

    @objc private func likeTapped() {
        isLiked.toggle()
        onLikeTapped?(isLiked)
    }
}
