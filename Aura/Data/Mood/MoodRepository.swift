//
//  MoodRepository.swift
//  Aura
//
//  Created by Stephen Wang on 11/19/25.
//  Member B - Firestore access for mood logs
//

import Foundation
import FirebaseFirestore

final class MoodRepository {
    static let shared = MoodRepository()
    private let db = Firestore.firestore()
    
    private init() {}
    
    private func collectionPath(for uid: String) -> CollectionReference {
        db.collection(FirestoreCollections.users)
            .document(uid)
            .collection(FirestoreCollections.moodLogs)
    }
    
    func addMood(uid: String,
                 mood: MoodEntry.Mood,
                 note: String?,
                 completion: @escaping (Result<MoodEntry, Error>) -> Void) {
        let entry = MoodEntry(mood: mood, note: note)
        let doc = collectionPath(for: uid).document(entry.id)
        doc.setData(entry.asDictionary) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(entry))
            }
        }
    }
    
    func fetchRecent(uid: String,
                     limit: Int = 50,
                     completion: @escaping (Result<[MoodEntry], Error>) -> Void) {
        collectionPath(for: uid)
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                let entries = documents.compactMap { MoodEntry.from(document: $0) }
                completion(.success(entries))
            }
    }
}
