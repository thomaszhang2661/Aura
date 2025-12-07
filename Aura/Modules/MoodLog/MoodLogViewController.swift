//
//  MoodLogViewController.swift
//  Aura
//
//  Created by Chance Q on 11/17/25.
//  Member B - Mood Log flow
//

import UIKit
import FirebaseAuth

final class MoodLogViewController: UIViewController {
    
    private var moodView: MoodLogView {
        view as! MoodLogView
    }
    
    private var entries: [MoodEntry] = [] {
        didSet { moodView.historyTableView.reloadData() }
    }
    private var selectedMood: MoodEntry.Mood? {
        didSet { moodView.updateMoodSelection(selectedMood) }
    }
    private var isSaving = false

    // MARK: - Lifecycle
    override func loadView() {
        view = MoodLogView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Mood Log"
        view.backgroundColor = .systemBackground
        
        moodView.historyTableView.dataSource = self
        moodView.historyTableView.delegate = self
        moodView.noteTextView.delegate = self
        addDismissKeyboardGesture()
        
        setupMoodButtons()
        moodView.saveButton.addTarget(self, action: #selector(saveMood), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Community", style: .plain, target: self, action: #selector(openCommunity))
        
        selectedMood = .happy
        loadRecentEntries()
    }
    
    // MARK: - Setup
    private func setupMoodButtons() {
        moodView.moodButtons.forEach { mood, button in
            button.addTarget(self, action: #selector(moodButtonTapped(_:)), for: .touchUpInside)
            button.tag = moodTag(mood)
        }
    }
    
    private func moodTag(_ mood: MoodEntry.Mood) -> Int {
        MoodEntry.Mood.allCases.firstIndex(of: mood) ?? 0
    }
    
    // MARK: - Actions
    @objc private func moodButtonTapped(_ sender: UIButton) {
        guard let mood = MoodEntry.Mood.allCases[safe: sender.tag] else { return }
        selectedMood = mood
    }
    
    @objc private func saveMood() {
        guard !isSaving else { return }
        isSaving = true
        showActivityIndicator()
        guard let uid = AuthService.shared.currentUserUID else {
            hideActivityIndicator()
            isSaving = false
            showAlert(title: "Not Logged In", message: "Please login to save your mood.")
            return
        }
        guard let mood = selectedMood else {
            hideActivityIndicator()
            isSaving = false
            showAlert(title: "Pick a mood", message: "Please select a mood before saving.")
            return
        }
        
        let note = moodView.noteTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        MoodRepository.shared.addMood(uid: uid, mood: mood, note: note.isEmpty ? nil : note) { [weak self] result in
            switch result {
            case .success(let newEntry):
                self?.handleSaveSuccess(newEntry)
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.hideActivityIndicator()
                    self?.showAlert(title: "Save failed", message: error.localizedDescription)
                    self?.isSaving = false
                }
            }
        }
    }
    
    private func loadRecentEntries() {
        guard let uid = AuthService.shared.currentUserUID else { return }
        MoodRepository.shared.fetchRecent(uid: uid) { [weak self] result in
            switch result {
            case .success(let entries):
                self?.applyEntries(entries, scrollToTop: false)
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Load failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - UI Updates
    private func handleSaveSuccess(_ newEntry: MoodEntry) {
        DispatchQueue.main.async {
            self.hideActivityIndicator()
            self.resetInputUI()
            self.appendAndRefresh(newEntry)
            self.isSaving = false
            let authorName = Auth.auth().currentUser?.email
            PublicMoodRepository.shared.publishCurrentMood(from: newEntry, authorName: authorName) { result in
                if case .failure(let error) = result {
                    print("Failed to publish public mood: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func resetInputUI() {
        print("reset input")
        moodView.noteTextView.text = ""
        moodView.updateNotePlaceholderVisibility()
        moodView.noteTextView.resignFirstResponder()
    }
    
    private func appendAndRefresh(_ entry: MoodEntry) {
        print("repend and fresh")
        var updated = entries
        updated.insert(entry, at: 0)
        applyEntries(updated, scrollToTop: true)
        loadRecentEntries() // sync with latest ordering
    }
    
    private func applyEntries(_ newEntries: [MoodEntry], scrollToTop: Bool) {
        DispatchQueue.main.async {
            self.entries = newEntries
            self.moodView.historyTableView.reloadData()
            if scrollToTop, !newEntries.isEmpty {
                self.moodView.historyTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }

    @objc private func openCommunity() {
        let communityVC = CommunityViewController()
        navigationController?.pushViewController(communityVC, animated: true)
    }
}

// MARK: - TableView
extension MoodLogViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoodCell", for: indexPath)
        let entry = entries[indexPath.row]
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        var content = UIListContentConfiguration.subtitleCell()
        content.text = "\(entry.mood.emoji) \(entry.mood.displayName)"
        var detailParts: [String] = [formatter.string(from: entry.createdAt)]
        if let note = entry.note, !note.isEmpty {
            detailParts.append(note)
        }
        content.secondaryText = detailParts.joined(separator: "\n")
        content.secondaryTextProperties.numberOfLines = 0
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - TextView
extension MoodLogViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        moodView.updateNotePlaceholderVisibility()
    }
}

// MARK: - Safe subscript helper
private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
