import AppIntents
import SwiftData
import SwiftUI

// MARK: - Shared lookups

@MainActor
private enum IntentData {
    static var context: ModelContext {
        AppModelContainer.prepare()
        return AppModelContainer.shared.mainContext
    }

    static func child(in context: ModelContext) -> ChildProfile? {
        (try? context.fetch(FetchDescriptor<ChildProfile>()))?.first
    }

    static func planDay(for date: Date, in context: ModelContext) -> MealPlanDay? {
        let days = (try? context.fetch(FetchDescriptor<MealPlanDay>())) ?? []
        return days.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    static func snippetMeal(_ meal: MealItem, child: ChildProfile?) -> SnippetMeal {
        SnippetMeal(
            slot: meal.mealSlot,
            title: meal.title,
            prepTimeMinutes: meal.prepTimeMinutes,
            isLeftover: meal.isLeftoverFromMealID != nil,
            safeFood: child.flatMap { SafeFoodPlanner.safeFoods(in: meal, for: $0).first?.name },
            safetyNotes: SafetyEngine.callouts(for: meal, ageInMonths: child?.ageInMonths ?? 36)
                .map { "\($0.ingredientName): \($0.guidance.instruction)" }
        )
    }
}

// MARK: - "What's for lunch?"

struct WhatsForMealIntent: AppIntent {
    static let title: LocalizedStringResource = "What's for a Meal"
    static let description = IntentDescription("Tells you what's planned for your toddler's meal, with safety prep notes.")

    @Parameter(title: "Meal", requestValueDialog: "Which meal?")
    var slot: MealSlot

    @Parameter(title: "Day", default: .today)
    var day: PlanDayOption

    static var parameterSummary: some ParameterSummary {
        Summary("What's for \(\.$slot) \(\.$day)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let context = IntentData.context
        let child = IntentData.child(in: context)
        let name = child?.name ?? "your little one"
        let meal = IntentData.planDay(for: day.date, in: context)?.sortedMeals.first { $0.mealSlot == slot }

        guard let meal else {
            let message = "There's no \(slot.title.lowercased()) planned for \(day.rawValue). Open LittleBites to pick a recipe."
            return .result(dialog: IntentDialog(stringLiteral: message), view: MealSnippetView(meals: []))
        }

        let snippet = IntentData.snippetMeal(meal, child: child)
        var message = "For \(slot.title.lowercased()) \(day.rawValue), \(name) is having \(meal.title)."
        if let first = snippet.safetyNotes.first { message += " Prep tip: \(first)" }
        return .result(dialog: IntentDialog(stringLiteral: message), view: MealSnippetView(meals: [snippet]))
    }
}

// MARK: - "What's on the menu today?"

struct TodaysMenuIntent: AppIntent {
    static let title: LocalizedStringResource = "Today's Toddler Menu"
    static let description = IntentDescription("Reads out all five meals planned for today.")

    @Parameter(title: "Day", default: .today)
    var day: PlanDayOption

    static var parameterSummary: some ParameterSummary {
        Summary("Read the menu for \(\.$day)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let context = IntentData.context
        let child = IntentData.child(in: context)
        let meals = IntentData.planDay(for: day.date, in: context)?.sortedMeals ?? []

        guard !meals.isEmpty else {
            return .result(
                dialog: IntentDialog(stringLiteral: "Nothing is planned for \(day.rawValue) yet."),
                view: MealSnippetView(meals: [])
            )
        }
        let spoken = meals.map { "\($0.mealSlot.title): \($0.title)" }.joined(separator: ". ")
        return .result(
            dialog: IntentDialog(stringLiteral: "Here's \(day.rawValue)'s menu. \(spoken)."),
            view: MealSnippetView(meals: meals.map { IntentData.snippetMeal($0, child: child) })
        )
    }
}

// MARK: - "Add Greek yogurt to my shopping list"

struct AddToShoppingListIntent: AppIntent {
    static let title: LocalizedStringResource = "Add to Shopping List"
    static let description = IntentDescription("Adds a grocery item to your LittleBites shopping list.")

    @Parameter(title: "Item", requestValueDialog: "What should I add to your shopping list?")
    var item: GroceryItemEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$item) to the shopping list")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let context = IntentData.context
        let resolver = IngredientResolver(context: context)
        let added: Ingredient

        if let key = item.catalogKey, let ingredient = resolver.ingredient(forKey: key) {
            added = ingredient
            if item.isLactoseFree && !ingredient.quantity.localizedCaseInsensitiveContains("lactose") {
                ingredient.quantity = ingredient.quantity.isEmpty ? "Lactose-free" : "Lactose-free · \(ingredient.quantity)"
            }
        } else {
            let name = item.customName ?? item.name
            let existing = (try? context.fetch(FetchDescriptor<Ingredient>()))?
                .first { $0.name.localizedCaseInsensitiveCompare(name) == .orderedSame }
            if let existing {
                added = existing
            } else {
                added = Ingredient(name: name.capitalizedFirst, category: .plantBasedPantry)
                context.insert(added)
            }
        }
        added.isOnShoppingList = true
        added.inPantry = false
        try? context.save()

        return .result(dialog: IntentDialog(stringLiteral: "Added \(item.name) to your shopping list under \(added.category.title)."))
    }
}

// MARK: - "Log that she tasted broccoli"

struct LogFoodExposureIntent: AppIntent {
    static let title: LocalizedStringResource = "Log a Food Exposure"
    static let description = IntentDescription("Records how your toddler reacted to a food, for the 15-exposure tracker.")

    @Parameter(title: "Food", requestValueDialog: "Which food?")
    var food: String

    @Parameter(title: "Reaction", requestValueDialog: "How did it go? Touched it, tasted it, or loved it?")
    var reaction: ExposureStage

    static var parameterSummary: some ParameterSummary {
        Summary("Log that they \(\.$reaction) \(\.$food)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let context = IntentData.context
        guard let child = IntentData.child(in: context) else {
            return .result(dialog: "Add a child profile in LittleBites first.")
        }

        let query = food.lowercased()
        let ingredients = (try? context.fetch(FetchDescriptor<Ingredient>())) ?? []
        let match = ingredients.first { $0.name.lowercased() == query }
            ?? ingredients.first { $0.name.lowercased().contains(query) }
            ?? ingredients.first { item in item.keywords.contains { query.contains($0) } }

        let ingredient: Ingredient
        if let match {
            ingredient = match
        } else {
            ingredient = Ingredient(name: food.capitalizedFirst, category: .produce)
            context.insert(ingredient)
        }

        let entry = FoodExposureLog(reaction: reaction, note: "Logged with Siri")
        context.insert(entry)
        entry.ingredient = ingredient
        entry.child = child
        try? context.save()

        let count = child.logs(for: ingredient).count
        let message = "Logged \(reaction.label.lowercased()) for \(ingredient.name). That's \(count) of 15 exposures."
        return .result(dialog: IntentDialog(stringLiteral: message))
    }
}

// MARK: - App Shortcuts (Siri phrases)

struct LittleBitesShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: WhatsForMealIntent(),
            phrases: [
                "What's for \(\.$slot) in \(.applicationName)",
                "What's my kid's \(\.$slot) in \(.applicationName)",
                "What's for \(\.$slot) today in \(.applicationName)",
                "What's for \(\.$slot) on \(.applicationName)",
            ],
            shortTitle: "What's for…",
            systemImageName: "fork.knife"
        )
        AppShortcut(
            intent: TodaysMenuIntent(),
            phrases: [
                "What's on the menu in \(.applicationName)",
                "Read today's menu in \(.applicationName)",
                "What's my toddler eating today in \(.applicationName)",
            ],
            shortTitle: "Today's Menu",
            systemImageName: "calendar"
        )
        AppShortcut(
            intent: AddToShoppingListIntent(),
            phrases: [
                "Add \(\.$item) to my shopping list in \(.applicationName)",
                "Add \(\.$item) to \(.applicationName)",
                "Add to my \(.applicationName) shopping list",
            ],
            shortTitle: "Add to List",
            systemImageName: "cart.badge.plus"
        )
        AppShortcut(
            intent: LogFoodExposureIntent(),
            phrases: [
                "Log a food exposure in \(.applicationName)",
                "Log a new food in \(.applicationName)",
            ],
            shortTitle: "Log Exposure",
            systemImageName: "face.smiling"
        )
    }
}

// MARK: - Snippet

struct SnippetMeal: Hashable {
    let slot: MealSlot
    let title: String
    let prepTimeMinutes: Int
    let isLeftover: Bool
    let safeFood: String?
    let safetyNotes: [String]
}

struct MealSnippetView: View {
    let meals: [SnippetMeal]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if meals.isEmpty {
                Label("Nothing planned yet", systemImage: "calendar.badge.plus")
                    .foregroundStyle(.secondary)
            }
            ForEach(meals, id: \.self) { meal in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Label(meal.slot.title, systemImage: meal.slot.symbol)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.sage)
                        Spacer()
                        Text("\(meal.prepTimeMinutes) min")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(meal.title)
                        .font(.headline)
                    if meal.isLeftover {
                        Label("Leftovers: just reheat", systemImage: "arrow.uturn.backward.circle.fill")
                            .font(.caption)
                            .foregroundStyle(Color.apricot)
                    }
                    if meals.count == 1 {
                        ForEach(meal.safetyNotes, id: \.self) { note in
                            Label(note, systemImage: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundStyle(Color.apricot)
                        }
                        if let safeFood = meal.safeFood {
                            Label("Safe food: \(safeFood)", systemImage: "checkmark.shield.fill")
                                .font(.caption)
                                .foregroundStyle(Color.sage)
                        }
                    }
                }
                if meal != meals.last { Divider() }
            }
        }
        .padding()
    }
}
