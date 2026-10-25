@preconcurrency import ActivityKit
import Foundation
import Observation
import SwiftData
@preconcurrency import UserNotifications
import WidgetKit

// MARK: - Model Container

/// One container shared by the UI and App Intents (Siri runs intents in the app's process).
enum AppModelContainer {
    static let shared: ModelContainer = {
        let schema = Schema(AppSchema.models)
        // `.automatic` syncs through CloudKit when the iCloud capability is enabled,
        // and falls back to a local store when it isn't.
        if let container = try? ModelContainer(
            for: schema, configurations: ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)
        ) {
            return container
        }
        do {
            return try ModelContainer(for: schema, configurations: ModelConfiguration(schema: schema, cloudKitDatabase: .none))
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    /// Seeds on first launch. Safe to call repeatedly.
    @MainActor
    static func prepare() {
        SampleData.seedIfNeeded(context: shared.mainContext)
    }
}

// MARK: - Router (tabs + deep links)

enum AppTab: Hashable {
    case plan, shop, recipes, tracker
}

@MainActor
@Observable
final class AppRouter {
    var selectedTab: AppTab = .plan
    /// Set by deep links; MealPlanView consumes and clears it.
    var requestedDayIndex: Int?

    /// Handles `littlebites://plan?day=3`, `littlebites://shop`, `littlebites://recipes`,
    /// `littlebites://tracker` and `littlebites://cooking`.
    func handle(_ url: URL) {
        guard url.scheme == "littlebites" else { return }
        switch url.host() {
        case "shop": selectedTab = .shop
        case "recipes": selectedTab = .recipes
        case "tracker": selectedTab = .tracker
        default:
            selectedTab = .plan
            let day = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?.first { $0.name == "day" }?.value.flatMap { Int($0) }
            if let day { requestedDayIndex = day }
        }
    }
}

// MARK: - Widget Snapshot

@MainActor
enum WidgetSnapshotWriter {
    /// Copies the plan into the App Group for the widget and asks WidgetKit to reload.
    static func refresh(context: ModelContext) {
        let days = (try? context.fetch(FetchDescriptor<MealPlanDay>(sortBy: [SortDescriptor(\MealPlanDay.dayIndex)]))) ?? []
        let child = (try? context.fetch(FetchDescriptor<ChildProfile>()))?.first
        let age = child?.ageInMonths ?? 36

        let snapshot = WidgetSnapshot(
            childName: child?.name ?? "Your Little One",
            generatedAt: .now,
            days: days.map { day in
                let totals = day.totalMacros
                return WidgetSnapshot.Day(
                    dayIndex: day.dayIndex,
                    date: day.date,
                    proteinGrams: totals.proteinGrams,
                    ironMilligrams: totals.ironMilligrams,
                    meals: day.sortedMeals.map { meal in
                        WidgetSnapshot.Meal(
                            slot: meal.mealSlot,
                            title: meal.title,
                            prepTimeMinutes: meal.prepTimeMinutes,
                            isLeftover: meal.isLeftoverFromMealID != nil,
                            safetyNoteCount: SafetyEngine.callouts(for: meal, ageInMonths: age).count,
                            safeFood: child.flatMap { SafeFoodPlanner.safeFoods(in: meal, for: $0).first?.name }
                        )
                    }
                )
            }
        )
        snapshot.save()
        WidgetCenter.shared.reloadAllTimelines()
    }
}

// MARK: - Cooking Timer (Live Activity + notification)

@MainActor
@Observable
final class CookingTimerStore {
    static let shared = CookingTimerStore()

    private(set) var startDate: Date?
    private(set) var endDate: Date?
    private(set) var label = ""
    private(set) var mealID: UUID?

    private static let notificationID = "littlebites.cooking-timer"

    private init() {
        restoreFromRunningActivity()
    }

    var isRunning: Bool { (endDate ?? .distantPast) > .now }

    func start(minutes: Int, meal: MealItem, step: String) {
        stop()
        let start = Date.now
        let end = start.addingTimeInterval(TimeInterval(minutes * 60))
        startDate = start
        endDate = end
        label = Self.label(for: step)
        mealID = meal.id

        scheduleNotification(at: end, title: "\(meal.mealSlot.title) timer done", body: label)

        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let attributes = CookingActivityAttributes(mealTitle: meal.title, slot: meal.mealSlot)
        let state = CookingActivityAttributes.ContentState(timerLabel: label, stepText: step, startDate: start, endDate: end)
        _ = try? Activity.request(attributes: attributes, content: ActivityContent(state: state, staleDate: end), pushType: nil)
    }

    /// Keeps the Lock Screen in sync as the parent moves through steps.
    func updateStep(_ step: String) {
        guard isRunning, let startDate, let endDate else { return }
        let state = CookingActivityAttributes.ContentState(timerLabel: label, stepText: step, startDate: startDate, endDate: endDate)
        Task {
            for activity in Activity<CookingActivityAttributes>.activities {
                await activity.update(ActivityContent(state: state, staleDate: endDate))
            }
        }
    }

    func stop() {
        startDate = nil
        endDate = nil
        label = ""
        mealID = nil
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Self.notificationID])
        Self.endAllActivities()
    }

    /// Ends activities whose timers have finished (e.g. after relaunch).
    func clearIfExpired() {
        if let endDate, endDate <= .now { stop() }
    }

    // MARK: Helpers

    /// "Steam broccoli florets 5–6 min until fork-tender; cut…" → "Steam broccoli florets 5–6 min"
    static func label(for step: String) -> String {
        let firstClause = step.split(whereSeparator: { ".;,".contains($0) }).first.map(String.init) ?? step
        let trimmed = firstClause.trimmingCharacters(in: .whitespaces)
        return trimmed.count > 40 ? String(trimmed.prefix(38)) + "…" : trimmed
    }

    /// Finds a time like "12–15 min" or "5 minutes" in a step; returns the upper bound.
    static func suggestedMinutes(in step: String) -> Int? {
        guard let match = step.firstMatch(of: /(\d+)(?:\s*[–-]\s*(\d+))?\s*min/) else { return nil }
        let value = match.output.2.map(String.init) ?? String(match.output.1)
        guard let minutes = Int(value), (1...180).contains(minutes) else { return nil }
        return minutes
    }

    private func restoreFromRunningActivity() {
        guard let activity = Activity<CookingActivityAttributes>.activities.first else { return }
        let state = activity.content.state
        if state.endDate > .now {
            startDate = state.startDate
            endDate = state.endDate
            label = state.timerLabel
        } else {
            Self.endAllActivities()
        }
    }

    private static func endAllActivities() {
        Task {
            for activity in Activity<CookingActivityAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }

    private func scheduleNotification(at date: Date, title: String, body: String) {
        let center = UNUserNotificationCenter.current()
        Task {
            let granted = (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, date.timeIntervalSinceNow), repeats: false)
            try? await center.add(UNNotificationRequest(identifier: Self.notificationID, content: content, trigger: trigger))
        }
    }
}
