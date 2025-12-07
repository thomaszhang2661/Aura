//
//  CommunityViewController.swift
//  Aura
//
//  Shows public mood logs with like support.
//

import UIKit

final class CommunityViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var entries: [PublicMoodEntry] = []
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Community"
        view.backgroundColor = .systemBackground
        setupTable()
        loadFeed()
    }

    private func setupTable() {
        tableView.register(CommunityMoodCell.self, forCellReuseIdentifier: CommunityMoodCell.reuseId)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func refreshPulled() {
        loadFeed()
    }

    private func loadFeed() {
        refreshControl.beginRefreshing()
        PublicMoodRepository.shared.fetchRecent { [weak self] result in
            guard let self else { return }
            self.refreshControl.endRefreshing()
            switch result {
            case .success(let items):
                self.entries = items
                self.tableView.reloadData()
            case .failure(let error):
                self.showError(message: error.localizedDescription)
            }
        }
    }

    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Table
extension CommunityViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        entries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommunityMoodCell.reuseId, for: indexPath) as? CommunityMoodCell else {
            return UITableViewCell()
        }
        let entry = entries[indexPath.row]
        cell.configure(with: entry) { [weak self] liked in
            self?.handleLikeChange(at: indexPath, liked: liked)
        }
        return cell
    }
}

// MARK: - Like handling
private extension CommunityViewController {
    func handleLikeChange(at indexPath: IndexPath, liked: Bool) {
        guard entries.indices.contains(indexPath.row) else { return }
        var entry = entries[indexPath.row]
        let newCount = max(0, entry.likeCount + (liked ? 1 : -1))
        entry = PublicMoodEntry(
            id: entry.id,
            authorId: entry.authorId,
            authorName: entry.authorName,
            mood: entry.mood,
            note: entry.note,
            createdAt: entry.createdAt,
            likeCount: newCount,
            likedByCurrentUser: liked
        )
        entries[indexPath.row] = entry
        tableView.reloadRows(at: [indexPath], with: .automatic)

        PublicMoodRepository.shared.toggleLike(entryId: entry.id, like: liked) { [weak self] error in
            if let error = error {
                self?.showError(message: error.localizedDescription)
            }
        }
    }
}
