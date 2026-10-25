import Foundation

/// Shared by the app and the widget extension.
enum MealSlot: String, Codable, CaseIterable, Identifiable, Sendable {
    case breakfast, morningSnack, lunch, afternoonSnack, dinner

    var id: String { rawValue }

    var title: String {
        switch self {
        case .breakfast: "Breakfast"
        case .morningSnack: "Morning Snack"
        case .lunch: "Lunch"
        case .afternoonSnack: "Afternoon Snack"
        case .dinner: "Dinner"
        }
    }

    var shortTitle: String {
        switch self {
        case .breakfast: "Breakfast"
        case .morningSnack: "AM Snack"
        case .lunch: "Lunch"
        case .afternoonSnack: "PM Snack"
        case .dinner: "Dinner"
        }
    }

    var symbol: String {
        switch self {
        case .breakfast: "sunrise.fill"
        case .morningSnack: "sun.max.fill"
        case .lunch: "fork.knife"
        case .afternoonSnack: "cloud.sun.fill"
        case .dinner: "moon.stars.fill"
        }
    }

    var sortOrder: Int { Self.allCases.firstIndex(of: self) ?? 0 }

    /// Typical serving time, used by widgets to decide what's "next".
    var typicalTime: (hour: Int, minute: Int) {
        switch self {
        case .breakfast: (7, 30)
        case .morningSnack: (10, 0)
        case .lunch: (12, 0)
        case .afternoonSnack: (15, 0)
        case .dinner: (17, 30)
        }
    }

    func servingTime(on day: Date, calendar: Calendar = .current) -> Date {
        let time = typicalTime
        return calendar.date(bySettingHour: time.hour, minute: time.minute, second: 0, of: day) ?? day
    }

    /// A meal stays "current" until 45 minutes after its typical serving time.
    func windowEnd(on day: Date, calendar: Calendar = .current) -> Date {
        servingTime(on: day, calendar: calendar).addingTimeInterval(45 * 60)
    }
}
