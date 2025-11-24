//
//  ChatMessage.swift
//  Aura
//
//  Created by Stephen Wang on 11/19/25.
//  Member B - Chat model
//

import Foundation
import FirebaseFirestore

/// A chat message saved under /users/{uid}/chat_history/{messageId}
struct ChatMessage {
    enum Sender: String {
        case user
        case ai
    }
    
    let id: String
    let sender: Sender
    let text: String
    let createdAt: Date
    
    init(id: String = UUID().uuidString,
         sender: Sender,
         text: String,
         createdAt: Date = Date()) {
        self.id = id
        self.sender = sender
        self.text = text
        self.createdAt = createdAt
    }
    
    // MARK: - Firestore mapping
    var asDictionary: [String: Any] {
        [
            "sender": sender.rawValue,
            "text": text,
            "createdAt": Timestamp(date: createdAt)
        ]
    }
    
    static func from(document: DocumentSnapshot) -> ChatMessage? {
        guard let data = document.data(),
              let senderRaw = data["sender"] as? String,
              let sender = Sender(rawValue: senderRaw),
              let text = data["text"] as? String,
              let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() else {
            return nil
        }
        
        return ChatMessage(
            id: document.documentID,
            sender: sender,
            text: text,
            createdAt: createdAt
        )
    }
}
