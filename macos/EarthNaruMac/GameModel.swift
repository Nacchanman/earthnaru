import Foundation
import SwiftUI

struct LiftObject: Identifiable, Equatable {
    let id = UUID()
    let level: Int
    let name: String
    let emoji: String
}

@MainActor
final class GameModel: ObservableObject {
    @Published private(set) var totalKeys: Int
    @Published private(set) var level: Int
    @Published var isCelebrating = false
    @Published var isPaused = false

    private let totalKeysStorageKey = "earthnaru.mac.totalKeys"
    private var celebrationTask: Task<Void, Never>?

    let levelTable: [(requiredKeys: Int, object: LiftObject)] = [
        (0, LiftObject(level: 1, name: "Feather", emoji: "🪶")),
        (50, LiftObject(level: 2, name: "Pencil", emoji: "✏️")),
        (150, LiftObject(level: 3, name: "Book", emoji: "📘")),
        (350, LiftObject(level: 4, name: "Dumbbell", emoji: "🏋️")),
        (700, LiftObject(level: 5, name: "Keyboard", emoji: "⌨️")),
        (1_200, LiftObject(level: 6, name: "Boulder", emoji: "🪨")),
        (2_000, LiftObject(level: 7, name: "Small moon", emoji: "🌙")),
        (3_500, LiftObject(level: 8, name: "Rocket", emoji: "🚀")),
        (5_500, LiftObject(level: 9, name: "Mountain", emoji: "⛰️")),
        (8_000, LiftObject(level: 10, name: "Tiny sun", emoji: "☀️"))
    ]

    init() {
        let saved = UserDefaults.standard.integer(forKey: totalKeysStorageKey)
        self.totalKeys = saved
        self.level = Self.level(for: saved)
    }

    var currentObject: LiftObject {
        levelTable[max(0, level - 1)].object
    }

    var nextRequiredKeys: Int? {
        guard level < levelTable.count else { return nil }
        return levelTable[level].requiredKeys
    }

    var progressToNextLevel: Double {
        guard let nextRequiredKeys else { return 1 }
        let currentRequired = levelTable[level - 1].requiredKeys
        let span = max(1, nextRequiredKeys - currentRequired)
        return min(1, max(0, Double(totalKeys - currentRequired) / Double(span)))
    }

    func addKeypress() {
        guard !isPaused else { return }
        setTotalKeys(totalKeys + 1)
    }

    func reset() {
        setTotalKeys(0)
        isCelebrating = false
    }

    private func setTotalKeys(_ newValue: Int) {
        let oldLevel = level
        totalKeys = max(0, newValue)
        level = Self.level(for: totalKeys)
        UserDefaults.standard.set(totalKeys, forKey: totalKeysStorageKey)

        if level > oldLevel {
            celebrate()
        }
    }

    private func celebrate() {
        celebrationTask?.cancel()
        isCelebrating = true
        celebrationTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_200_000_000)
            isCelebrating = false
        }
    }

    private static func level(for keys: Int) -> Int {
        let thresholds = [0, 50, 150, 350, 700, 1_200, 2_000, 3_500, 5_500, 8_000]
        return (thresholds.lastIndex(where: { keys >= $0 }) ?? 0) + 1
    }
}
