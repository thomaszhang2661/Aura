//
//  IntegrationContracts.swift
//  Aura
//
//  Created by Chance Q on 11/17/25.
//  Maintained by Member C - Integration & Event System
//

import Foundation

// MARK: - AppEvent
/// Events that can be broadcast across the app for inter-module communication
enum AppEvent {
    case didLogin(uid: String)
    case didLogout
    case openChat
    case openMoodLog
    case openResources
}

// MARK: - DeepLink
/// Deep link support for navigating between modules
enum DeepLink: String {
    case home = "aura://home"
    case chat = "aura://chat"
    case moodLog = "aura://mood-log"
    case resources = "aura://resources"
    case login = "aura://login"
}

// MARK: - EventBus
/// Simple event bus for broadcasting and listening to app events
final class EventBus {
    static let shared = EventBus()
    
    private var listeners: [String: [(AppEvent) -> Void]] = [:]
    
    private init() {}
    
    /// Register a listener for app events
    /// - Parameters:
    ///   - id: Unique identifier for this listener (typically use the ViewController class name)
    ///   - handler: Closure to handle events
    func on(id: String, handler: @escaping (AppEvent) -> Void) {
        listeners[id] = listeners[id] ?? []
        listeners[id]?.append(handler)
    }
    
    /// Remove a listener
    /// - Parameter id: The identifier used when registering
    func off(id: String) {
        listeners.removeValue(forKey: id)
    }
    
    /// Broadcast an event to all listeners
    /// - Parameter event: The event to broadcast
    func emit(_ event: AppEvent) {
        DispatchQueue.main.async {
            self.listeners.values.forEach { handlers in
                handlers.forEach { handler in
                    handler(event)
                }
            }
        }
    }
}

// MARK: - DeepLinkRouter
/// Router for handling deep links
final class DeepLinkRouter {
    static let shared = DeepLinkRouter()
    
    private init() {}
    
    /// Parse a URL string and return a DeepLink if valid
    func parse(url: String) -> DeepLink? {
        DeepLink(rawValue: url)
    }
    
    /// Handle a deep link and emit corresponding event
    func handle(_ deepLink: DeepLink) {
        switch deepLink {
        case .home:
            // Navigation handled by HomeViewController
            break
        case .chat:
            EventBus.shared.emit(.openChat)
        case .moodLog:
            EventBus.shared.emit(.openMoodLog)
        case .resources:
            EventBus.shared.emit(.openResources)
        case .login:
            EventBus.shared.emit(.didLogout)
        }
    }
}
