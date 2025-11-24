import Foundation

final class MoodStore {
    static let shared = MoodStore()

    private(set) var items: [MoodEntry] = []

    private init() {}

    func save(_ entry: MoodEntry) {
        items.insert(entry, at: 0)
    }

    func clear() {
        items.removeAll()
    }
}
