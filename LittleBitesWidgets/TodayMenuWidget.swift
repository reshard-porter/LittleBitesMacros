import SwiftUI
import WidgetKit

// MARK: - Timeline

struct MenuEntry: TimelineEntry, Sendable {
    let date: Date
    let snapshot: WidgetSnapshot?
}

struct MenuProvider: TimelineProvider {
    func placeholder(in context: Context) -> MenuEntry {
        MenuEntry(date: .now, snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (MenuEntry) -> Void) {
        let snapshot = context.isPreview ? WidgetSnapshot.placeholder : (WidgetSnapshot.load() ?? .placeholder)
        completion(MenuEntry(date: .now, snapshot: snapshot))
    }

    /// One entry now, one as each meal window closes (so "Next up" advances), and one at midnight.
    func getTimeline(in context: Context, completion: @escaping (Timeline<MenuEntry>) -> Void) {
        let snapshot = WidgetSnapshot.load()
        let calendar = Calendar.current
        let now = Date.now
        var dates: [Date] = [now]
        for offset in 0...1 {
            guard let day = calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: now)) else { continue }
            if offset > 0 { dates.append(day) }
            for slot in MealSlot.allCases {
                let end = slot.windowEnd(on: day, calendar: calendar)
                if end > now { dates.append(end) }
            }
        }
        let entries = dates.sorted().map { MenuEntry(date: $0, snapshot: snapshot) }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

// MARK: - Widget

struct TodayMenuWidget: Widget {
    let kind = "TodayMenuWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MenuProvider()) { entry in
            TodayMenuWidgetView(entry: entry)
                .containerBackground(for: .widget) { Color.appBackground }
        }
        .configurationDisplayName("Today's Menu")
        .description("Your toddler's 5-part schedule: breakfast, two snacks, lunch and dinner.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge,
                            .accessoryRectangular, .accessoryInline, .accessoryCircular])
    }
}

// MARK: - Views

struct TodayMenuWidgetView: View {
    let entry: MenuEntry
    @Environment(\.widgetFamily) private var family

    private var today: WidgetSnapshot.Day? { entry.snapshot?.day(containing: entry.date) }
    private var next: (day: WidgetSnapshot.Day, meal: WidgetSnapshot.Meal)? { entry.snapshot?.nextMeal(after: entry.date) }

    private func planURL(_ day: WidgetSnapshot.Day?) -> URL? {
        URL(string: "littlebites://plan" + (day.map { "?day=\($0.dayIndex)" } ?? ""))
    }

    var body: some View {
        Group {
            if entry.snapshot == nil {
                emptyState
            } else {
                switch family {
                case .systemSmall: small
                case .systemMedium: schedule(rows: 5, detailed: false)
                case .systemLarge: schedule(rows: 5, detailed: true)
                case .accessoryRectangular: rectangular
                case .accessoryInline: inline
                case .accessoryCircular: circular
                default: small
                }
            }
        }
        .widgetURL(planURL(next?.day ?? today))
    }

    private var emptyState: some View {
        VStack(spacing: 6) {
            Image(systemName: "fork.knife.circle.fill")
                .font(.title)
                .foregroundStyle(Color.sage)
            Text("Open LittleBites to set up your plan")
                .font(.caption)
                .multilineTextAlignment(.center)
        }
    }

    // Small / StandBy: next meal, big and glanceable.
    private var small: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let next {
                Label(isToday(next.day) ? "Next up" : "Tomorrow", systemImage: next.meal.slot.symbol)
                    .font(.caption2.weight(.bold))
                    .textCase(.uppercase)
                    .foregroundStyle(Color.apricot)
                Text(next.meal.slot.title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.sage)
                Text(next.meal.title)
                    .font(.headline)
                    .lineLimit(4)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: 0)
                HStack(spacing: 6) {
                    Label("\(next.meal.prepTimeMinutes)m", systemImage: "clock")
                    if next.meal.isLeftover { Image(systemName: "arrow.uturn.backward.circle.fill").foregroundStyle(Color.apricot) }
                    if next.meal.safetyNoteCount > 0 { Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(Color.apricot) }
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            } else {
                Text("All meals done for the plan!").font(.headline)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // Medium / Large: the full 5-part schedule.
    private func schedule(rows: Int, detailed: Bool) -> some View {
        let day = today ?? next?.day
        let meals = (day?.meals ?? []).sorted { $0.slot.sortOrder < $1.slot.sortOrder }
        return VStack(alignment: .leading, spacing: detailed ? 10 : 4) {
            HStack {
                Text(day.map { isToday($0) ? "Today · Day \($0.dayIndex)" : "Day \($0.dayIndex)" } ?? "Today")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.sage)
                Spacer()
                if detailed, let day {
                    Text("\(Int(day.proteinGrams))g protein · \(day.ironMilligrams.formatted(.number.precision(.fractionLength(1))))mg iron")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else if let name = entry.snapshot?.childName {
                    Text(name).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
                }
            }
            ForEach(meals.prefix(rows), id: \.self) { meal in
                let isNext = next?.meal == meal && next.map { isToday($0.day) } == true
                HStack(alignment: detailed ? .top : .center, spacing: 8) {
                    Image(systemName: meal.slot.symbol)
                        .font(.caption)
                        .foregroundStyle(isNext ? Color.apricot : Color.sage)
                        .frame(width: 16)
                    Text(meal.slot.shortTitle)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 58, alignment: .leading)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(meal.title)
                            .font(detailed ? .subheadline : .caption)
                            .fontWeight(isNext ? .bold : .regular)
                            .lineLimit(detailed ? 2 : 1)
                        if detailed {
                            HStack(spacing: 6) {
                                Text("\(meal.prepTimeMinutes) min")
                                if meal.isLeftover { Text("Leftovers").foregroundStyle(Color.apricot) }
                                if let safe = meal.safeFood { Text("Safe: \(safe)").lineLimit(1) }
                            }
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        }
                    }
                    Spacer(minLength: 0)
                }
                .padding(.vertical, isNext && detailed ? 4 : 0)
                .padding(.horizontal, isNext && detailed ? 6 : 0)
                .background(isNext && detailed ? Color.apricot.opacity(0.15) : Color.clear,
                            in: RoundedRectangle(cornerRadius: 8))
            }
            Spacer(minLength: 0)
        }
    }

    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 1) {
            if let next {
                Label(next.meal.slot.title, systemImage: next.meal.slot.symbol)
                    .font(.caption2.weight(.bold))
                    .widgetAccentable()
                Text(next.meal.title)
                    .font(.caption)
                    .lineLimit(2)
            } else {
                Text("No meals planned")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var inline: some View {
        Group {
            if let next {
                Label("\(next.meal.slot.shortTitle): \(next.meal.title)", systemImage: next.meal.slot.symbol)
            } else {
                Text("LittleBites")
            }
        }
    }

    private var circular: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Image(systemName: next?.meal.slot.symbol ?? "fork.knife")
                    .font(.title3)
                    .widgetAccentable()
                Text(next.map { $0.meal.slot.servingTime(on: $0.day.date) }?.formatted(.dateTime.hour()) ?? "")
                    .font(.caption2)
            }
        }
    }

    private func isToday(_ day: WidgetSnapshot.Day) -> Bool {
        Calendar.current.isDate(day.date, inSameDayAs: entry.date)
    }
}

#Preview("Small", as: .systemSmall) {
    TodayMenuWidget()
} timeline: {
    MenuEntry(date: .now, snapshot: .placeholder)
}

#Preview("Large", as: .systemLarge) {
    TodayMenuWidget()
} timeline: {
    MenuEntry(date: .now, snapshot: .placeholder)
}

#Preview("Lock Screen", as: .accessoryRectangular) {
    TodayMenuWidget()
} timeline: {
    MenuEntry(date: .now, snapshot: .placeholder)
}
