//
//  MoodEntry.swift
//  Aura
//
//  Created by Stephen Wang on 11/19/25.
//  Member B - Mood model
//

import Foundation
import FirebaseFirestore

/// A single mood log entry saved under /users/{uid}/mood_logs/{moodId}
struct MoodEntry {
    enum Mood: String, CaseIterable {
        case happy
        case okay
        case anxious
        case sad
        case stressed
        
        var emoji: String {
            switch self {
            case .happy: return "😊"
            case .okay: return "😐"
            case .anxious: return "😟"
            case .sad: return "☹️"
            case .stressed: return "😣"
            }
        }
        
        var displayName: String {
            switch self {
            case .happy: return "Happy"
            case .okay: return "Okay"
            case .anxious: return "Anxious"
            case .sad: return "Sad"
            case .stressed: return "Stressed"
            }
        }
    }
    
    let id: String
    let mood: Mood
    let note: String?
    let createdAt: Date
    
    init(id: String = UUID().uuidString,
         mood: Mood,
         note: String? = nil,
         createdAt: Date = Date()) {
        self.id = id
        self.mood = mood
        self.note = note
        self.createdAt = createdAt
    }
    
    // MARK: - Firestore Mapping
    var asDictionary: [String: Any] {
        var dict: [String: Any] = [
            "mood": mood.rawValue,
            "createdAt": Timestamp(date: createdAt)
        ]
        if let note = note, !note.isEmpty {
            dict["note"] = note
        }
        return dict
    }
    
    static func from(document: DocumentSnapshot) -> MoodEntry? {
        guard let data = document.data(),
              let moodRaw = data["mood"] as? String,
              let mood = Mood(rawValue: moodRaw),
              let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() else {
            return nil
        }
        let note = data["note"] as? String
        return MoodEntry(id: document.documentID, mood: mood, note: note, createdAt: createdAt)
    }
}
