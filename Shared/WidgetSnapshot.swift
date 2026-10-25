import Foundation

/// A small, Codable copy of the meal plan that the app writes to the shared App Group and the
/// widget extension reads. Keeping SwiftData (and CloudKit) out of the extension avoids two
/// processes opening the same store.
struct WidgetSnapshot: Codable, Sendable {
    static let appGroupID = "group.com.example.LittleBitesMacros"
    static let storageKey = "widgetSnapshot.v1"

    struct Meal: Codable, Sendable, Hashable {
        var slot: MealSlot
        var title: String
        var prepTimeMinutes: Int
        var isLeftover: Bool
        var safetyNoteCount: Int
        var safeFood: String?
    }

    struct Day: Codable, Sendable, Hashable {
        var dayIndex: Int
        var date: Date
        var proteinGrams: Double
        var ironMilligrams: Double
        var meals: [Meal]
    }

    var childName: String
    var generatedAt: Date
    var days: [Day]

    // MARK: Storage

    static func load() -> WidgetSnapshot? {
        guard let data = UserDefaults(suiteName: appGroupID)?.data(forKey: storageKey) else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults(suiteName: Self.appGroupID)?.set(data, forKey: Self.storageKey)
    }

    // MARK: Queries

    func day(containing date: Date, calendar: Calendar = .current) -> Day? {
        days.first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    /// The next meal whose serving window hasn't passed, today or later.
    func nextMeal(after date: Date, calendar: Calendar = .current) -> (day: Day, meal: Meal)? {
        let today = calendar.startOfDay(for: date)
        for day in days.sorted(by: { $0.date < $1.date }) where calendar.startOfDay(for: day.date) >= today {
            let meals = day.meals.sorted { $0.slot.sortOrder < $1.slot.sortOrder }
            if let meal = meals.first(where: { $0.slot.windowEnd(on: day.date, calendar: calendar) > date }) {
                return (day, meal)
            }
        }
        return nil
    }

    // MARK: Placeholder

    static let placeholder = WidgetSnapshot(
        childName: "Your Little One",
        generatedAt: .now,
        days: [
            Day(dayIndex: 1, date: .now, proteinGrams: 64, ironMilligrams: 6.2, meals: [
                Meal(slot: .breakfast, title: "Soft Scrambled Eggs, Toast Strips & Banana", prepTimeMinutes: 10, isLeftover: false, safetyNoteCount: 1, safeFood: "Ripe bananas"),
                Meal(slot: .morningSnack, title: "Greek Yogurt with Mashed Berries", prepTimeMinutes: 3, isLeftover: false, safetyNoteCount: 1, safeFood: "Plain Greek yogurt"),
                Meal(slot: .lunch, title: "Leftover Turkey Bolognese", prepTimeMinutes: 5, isLeftover: true, safetyNoteCount: 0, safeFood: nil),
                Meal(slot: .afternoonSnack, title: "Thin Apple Slices with Peanut Butter", prepTimeMinutes: 4, isLeftover: false, safetyNoteCount: 2, safeFood: nil),
                Meal(slot: .dinner, title: "Baked Salmon, Sweet Potato & Broccoli", prepTimeMinutes: 25, isLeftover: false, safetyNoteCount: 1, safeFood: "Whole-wheat bread"),
            ]),
        ]
    )
}
