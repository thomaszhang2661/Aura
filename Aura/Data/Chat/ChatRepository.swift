//
//  ChatRepository.swift
//  Aura
//
//  Created by Stephen Wang on 11/19/25.
//  Member B - Firestore access for chat history
//

import Foundation
import FirebaseFirestore

final class ChatRepository {
    static let shared = ChatRepository()
    private let db = Firestore.firestore()
    
    private init() {}
    
    private func collectionPath(for uid: String) -> CollectionReference {
        db.collection(FirestoreCollections.users)
            .document(uid)
            .collection(FirestoreCollections.chatHistory)
    }
    
    func addMessage(uid: String,
                    message: ChatMessage,
                    completion: @escaping (Result<Void, Error>) -> Void) {
        let doc = collectionPath(for: uid).document(message.id)
        doc.setData(message.asDictionary) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func fetchRecent(uid: String,
                     limit: Int = 50,
                     completion: @escaping (Result<[ChatMessage], Error>) -> Void) {
        collectionPath(for: uid)
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let docs = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                let messages = docs.compactMap { ChatMessage.from(document: $0) }
                completion(.success(messages.sorted { $0.createdAt < $1.createdAt }))
            }
    }
}
