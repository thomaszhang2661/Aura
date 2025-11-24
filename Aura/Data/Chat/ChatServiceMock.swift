//
//  ChatServiceMock.swift
//  Aura
//
//  Member B - simple AI mock responder
//

import Foundation

final class ChatServiceMock {
    static let shared = ChatServiceMock()
    private init() {}
    
    private let responses = [
        "I'm here with you. Tell me more.",
        "That sounds tough. Want to try a quick breathing exercise?",
        "I hear you. What do you need most right now?",
        "Thanks for sharing. Let's take it one step at a time."
    ]
    
    func reply(to userMessage: String, completion: @escaping (ChatMessage) -> Void) {
        let delay = DispatchTime.now() + .milliseconds(600)
        DispatchQueue.main.asyncAfter(deadline: delay) { [responses] in
            let text = responses.randomElement() ?? "I'm here to listen."
            let message = ChatMessage(sender: .ai, text: text)
            completion(message)
        }
    }
}
