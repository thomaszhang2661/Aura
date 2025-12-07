//
//  PublicMoodRepository.swift
//  Aura
//
//  Shared mood feed (public) with like support.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

final class PublicMoodRepository {
    static let shared = PublicMoodRepository()
    private let db = Firestore.firestore()

    private init() {}

    private var collection: CollectionReference {
        db.collection(FirestoreCollections.publicMoodLogs)
    }

    func publishCurrentMood(from entry: MoodEntry, authorName: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = AuthService.shared.currentUserUID else {
            completion(.failure(NSError(domain: "PublicMoodRepository", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not logged in"])))
            return
        }
        let publicEntry = PublicMoodEntry(
            id: entry.id,
            authorId: uid,
            authorName: authorName,
            mood: entry.mood,
            note: entry.note,
            createdAt: entry.createdAt,
            likeCount: 0,
            likedByCurrentUser: false
        )
        collection.document(publicEntry.id).setData(publicEntry.asDictionary) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func fetchRecent(limit: Int = 50, completion: @escaping (Result<[PublicMoodEntry], Error>) -> Void) {
        let uid = AuthService.shared.currentUserUID
        collection
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
            .getDocuments { [weak self] snapshot, error in
                guard let self else { return }
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }

                var entries: [PublicMoodEntry] = []
                let group = DispatchGroup()

                for doc in documents {
                    guard let base = PublicMoodEntry.from(document: doc, currentUserId: uid) else { continue }
                    if let uid = uid {
                        group.enter()
                        self.likesCollection(for: doc.documentID).document(uid).getDocument { likeDoc, _ in
                            let liked = likeDoc?.exists ?? false
                            let merged = PublicMoodEntry(
                                id: base.id,
                                authorId: base.authorId,
                                authorName: base.authorName,
                                mood: base.mood,
                                note: base.note,
                                createdAt: base.createdAt,
                                likeCount: base.likeCount,
                                likedByCurrentUser: liked
                            )
                            entries.append(merged)
                            group.leave()
                        }
                    } else {
                        entries.append(base)
                    }
                }

                group.notify(queue: .main) {
                    // Preserve order
                    let ordered = documents.compactMap { doc in
                        entries.first(where: { $0.id == doc.documentID })
                    }
                    completion(.success(ordered))
                }
            }
    }

    func toggleLike(entryId: String, like: Bool, completion: ((Error?) -> Void)? = nil) {
        guard let uid = AuthService.shared.currentUserUID else {
            completion?(NSError(domain: "PublicMoodRepository", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not logged in"]))
            return
        }
        let likeDoc = likesCollection(for: entryId).document(uid)
        let postDoc = collection.document(entryId)

        db.runTransaction { transaction, errorPointer in
            let postSnapshot: DocumentSnapshot
            do {
                postSnapshot = try transaction.getDocument(postDoc)
            } catch let err as NSError {
                errorPointer?.pointee = err
                return nil
            }
            var likeCount = postSnapshot.data()?["likeCount"] as? Int ?? 0
            if like {
                transaction.setData([:], forDocument: likeDoc)
                likeCount += 1
            } else {
                transaction.deleteDocument(likeDoc)
                likeCount = max(0, likeCount - 1)
            }
            transaction.updateData(["likeCount": likeCount], forDocument: postDoc)
            return nil
        } completion: { _, error in
            DispatchQueue.main.async {
                completion?(error)
            }
        }
    }

    private func likesCollection(for entryId: String) -> CollectionReference {
        collection.document(entryId).collection("likes")
    }
}
