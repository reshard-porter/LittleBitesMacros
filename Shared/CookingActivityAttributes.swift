import ActivityKit
import Foundation

/// Live Activity for Cooking Mode timers (Lock Screen + Dynamic Island).
struct CookingActivityAttributes: ActivityAttributes, Sendable {
    struct ContentState: Codable, Hashable, Sendable {
        /// e.g. "Steam broccoli florets 5–6 min"
        var timerLabel: String
        var stepText: String
        var startDate: Date
        var endDate: Date
    }

    var mealTitle: String
    var slot: MealSlot
}

extension CookingActivityAttributes {
    static let preview = CookingActivityAttributes(mealTitle: "Baked Flaky Salmon, Mashed Sweet Potato & Soft Broccoli", slot: .dinner)
}

extension CookingActivityAttributes.ContentState {
    static let preview = CookingActivityAttributes.ContentState(
        timerLabel: "Steaming broccoli",
        stepText: "Steam broccoli florets 5–6 min until fork-tender; cut into small trees.",
        startDate: .now,
        endDate: .now.addingTimeInterval(4 * 60)
    )
}
