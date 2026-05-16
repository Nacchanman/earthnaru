import Combine
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
    @Published private(set) var todayKeys: Int
    @Published private(set) var level: Int
    @Published private(set) var runFrame = 0
    @Published var isCelebrating = false
    @Published var isPaused = false

    private let totalKeysStorageKey = "earthnaru.mac.totalKeys"
    private let todayKeysStorageKey = "earthnaru.mac.todayKeys"
    private let activityDateStorageKey = "earthnaru.mac.activityDate"
    private var celebrationTask: Task<Void, Never>?
    private var activityDate: String

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
        let today = Self.dayStamp()
        let saved = UserDefaults.standard.integer(forKey: totalKeysStorageKey)
        let savedDate = UserDefaults.standard.string(forKey: activityDateStorageKey)
        self.totalKeys = saved
        self.todayKeys = savedDate == today ? UserDefaults.standard.integer(forKey: todayKeysStorageKey) : 0
        self.level = Self.level(for: saved)
        self.activityDate = today
        UserDefaults.standard.set(today, forKey: activityDateStorageKey)
    }

    var currentObject: LiftObject {
        levelTable[max(0, level - 1)].object
    }

    var nextRequiredKeys: Int? {
        guard level < levelTable.count else { return nil }
        return levelTable[level].requiredKeys
    }

    var currentRequiredKeys: Int {
        levelTable[level - 1].requiredKeys
    }

    var keysToNextLevel: Int {
        guard let nextRequiredKeys else { return 0 }
        return max(0, nextRequiredKeys - totalKeys)
    }

    var todayGoal: Int {
        600
    }

    var todayProgress: Double {
        min(1, max(0, Double(todayKeys) / Double(todayGoal)))
    }

    var activityPace: ActivityPace {
        switch todayKeys {
        case 0:
            return .idle
        case 1..<150:
            return .warmingUp
        case 150..<600:
            return .training
        default:
            return .flow
        }
    }

    var progressToNextLevel: Double {
        guard let nextRequiredKeys else { return 1 }
        let span = max(1, nextRequiredKeys - currentRequiredKeys)
        return min(1, max(0, Double(totalKeys - currentRequiredKeys) / Double(span)))
    }

    func addKeypress() {
        guard !isPaused else { return }
        rollOverDayIfNeeded()
        runFrame = (runFrame + 1) % 4
        todayKeys += 1
        UserDefaults.standard.set(todayKeys, forKey: todayKeysStorageKey)
        setTotalKeys(totalKeys + 1)
    }

    func reset() {
        runFrame = 0
        resetToday()
        setTotalKeys(0)
        isCelebrating = false
    }

    func resetToday() {
        activityDate = Self.dayStamp()
        todayKeys = 0
        UserDefaults.standard.set(activityDate, forKey: activityDateStorageKey)
        UserDefaults.standard.set(todayKeys, forKey: todayKeysStorageKey)
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

    private func rollOverDayIfNeeded() {
        let today = Self.dayStamp()
        guard activityDate != today else { return }

        activityDate = today
        todayKeys = 0
        UserDefaults.standard.set(today, forKey: activityDateStorageKey)
        UserDefaults.standard.set(todayKeys, forKey: todayKeysStorageKey)
    }

    private static func dayStamp(date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.calendar = .current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

enum ActivityPace {
    case idle
    case warmingUp
    case training
    case flow

    var title: String {
        switch self {
        case .idle: return "Ready"
        case .warmingUp: return "Warming up"
        case .training: return "Training"
        case .flow: return "Flow state"
        }
    }

    var caption: String {
        switch self {
        case .idle: return "Start typing to wake the planet."
        case .warmingUp: return "Momentum is building."
        case .training: return "Steady progress today."
        case .flow: return "Daily goal cleared."
        }
    }

    var color: Color {
        switch self {
        case .idle: return Color(red: 0.52, green: 0.56, blue: 0.62)
        case .warmingUp: return Color(red: 0.91, green: 0.58, blue: 0.24)
        case .training: return Color(red: 0.17, green: 0.55, blue: 0.85)
        case .flow: return Color(red: 0.21, green: 0.64, blue: 0.43)
        }
    }
}
