//
//  PublicMoodEntry.swift
//  Aura
//
//  Simple shared mood post model for community feed.
//

import Foundation
import FirebaseFirestore

struct PublicMoodEntry {
    let id: String
    let authorId: String
    let authorName: String?
    let mood: MoodEntry.Mood
    let note: String?
    let createdAt: Date
    let likeCount: Int
    let likedByCurrentUser: Bool

    init(id: String = UUID().uuidString,
         authorId: String,
         authorName: String?,
         mood: MoodEntry.Mood,
         note: String?,
         createdAt: Date = Date(),
         likeCount: Int = 0,
         likedByCurrentUser: Bool = false) {
        self.id = id
        self.authorId = authorId
        self.authorName = authorName
        self.mood = mood
        self.note = note
        self.createdAt = createdAt
        self.likeCount = likeCount
        self.likedByCurrentUser = likedByCurrentUser
    }

    var asDictionary: [String: Any] {
        var dict: [String: Any] = [
            "authorId": authorId,
            "mood": mood.rawValue,
            "createdAt": Timestamp(date: createdAt),
            "likeCount": likeCount
        ]
        if let authorName = authorName { dict["authorName"] = authorName }
        if let note = note, !note.isEmpty { dict["note"] = note }
        return dict
    }

    static func from(document: DocumentSnapshot, currentUserId: String?) -> PublicMoodEntry? {
        guard let data = document.data(),
              let authorId = data["authorId"] as? String,
              let moodRaw = data["mood"] as? String,
              let mood = MoodEntry.Mood(rawValue: moodRaw),
              let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() else {
            return nil
        }
        let authorName = data["authorName"] as? String
        let note = data["note"] as? String
        let likeCount = data["likeCount"] as? Int ?? 0
        return PublicMoodEntry(
            id: document.documentID,
            authorId: authorId,
            authorName: authorName,
            mood: mood,
            note: note,
            createdAt: createdAt,
            likeCount: likeCount,
            likedByCurrentUser: false
        )
    }
}
