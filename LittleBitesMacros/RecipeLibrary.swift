import Foundation
import OSLog
import SwiftData

// MARK: - Bundled Library Types (decoded from RecipeLibrary.json)
// The JSON is produced by Tools/generate_recipes.py. Field names must match.

struct CatalogIngredient: Codable, Sendable, Identifiable, Hashable {
    let key: String
    let name: String
    let shortName: String
    let category: GroceryCategory
    let isProteinStaple: Bool
    let toddlerSafetyNote: String?
    let hazard: ChokingHazard?
    let allergens: [Allergen]
    let swapGroup: String?
    let hasLactoseFreeOption: Bool
    let quantity: String
    let nutrition: MacroEstimate

    var id: String { key }
}

struct LibraryRecipe: Codable, Sendable, Identifiable, Hashable {
    let id: String
    let title: String
    let slots: [MealSlot]
    let prepTimeMinutes: Int
    let ingredientKeys: [String]
    let textures: [TextureType]
    let macros: MacroEstimate
    let steps: [String]
    let cuisine: String
    let batchFriendly: Bool
    /// Leftover meals that only exist inside the default plan.
    let planOnly: Bool

    var primarySlot: MealSlot { slots.first ?? .lunch }
    var isSnack: Bool { slots.contains(.morningSnack) || slots.contains(.afternoonSnack) }
}

struct DefaultPlanDay: Codable, Sendable {
    struct PlannedMeal: Codable, Sendable {
        let slot: MealSlot
        let recipeID: String
    }

    struct PrepItem: Codable, Sendable {
        let title: String
        let detail: String
    }

    let dayIndex: Int
    let meals: [PlannedMeal]
    let prepTasks: [PrepItem]
}

struct LeftoverLink: Codable, Sendable {
    let fromDay: Int
    let fromSlot: MealSlot
    let toDay: Int
    let toSlot: MealSlot
}

private struct RecipeLibraryFile: Codable, Sendable {
    let version: Int
    let ingredients: [CatalogIngredient]
    let recipes: [LibraryRecipe]
    let defaultPlan: [DefaultPlanDay]
    let leftoverLinks: [LeftoverLink]
    let defaultSafeFoods: [String]
}

// MARK: - Recipe Library

struct RecipeLibrary: Sendable {
    let ingredients: [CatalogIngredient]
    let recipes: [LibraryRecipe]
    let defaultPlan: [DefaultPlanDay]
    let leftoverLinks: [LeftoverLink]
    let defaultSafeFoods: [String]

    let ingredientsByKey: [String: CatalogIngredient]
    let recipesByID: [String: LibraryRecipe]
    /// Recipes shown in the library (excludes plan-only leftovers).
    let browsable: [LibraryRecipe]
    let cuisines: [String]
    private let allergensByRecipe: [String: Set<Allergen>]
    private let searchText: [String: String]

    static let shared = RecipeLibrary.load()

    private static let logger = Logger(subsystem: "LittleBitesMacros", category: "RecipeLibrary")

    static func load(bundle: Bundle = .main) -> RecipeLibrary {
        do {
            guard let url = bundle.url(forResource: "RecipeLibrary", withExtension: "json") else {
                throw CocoaError(.fileNoSuchFile)
            }
            let file = try JSONDecoder().decode(RecipeLibraryFile.self, from: Data(contentsOf: url))
            return RecipeLibrary(file: file)
        } catch {
            logger.error("Failed to load RecipeLibrary.json: \(error.localizedDescription)")
            assertionFailure("RecipeLibrary.json missing or invalid: \(error)")
            return RecipeLibrary(file: RecipeLibraryFile(version: 0, ingredients: [], recipes: [], defaultPlan: [],
                                                         leftoverLinks: [], defaultSafeFoods: []))
        }
    }

    private init(file: RecipeLibraryFile) {
        ingredients = file.ingredients
        recipes = file.recipes
        defaultPlan = file.defaultPlan
        leftoverLinks = file.leftoverLinks
        defaultSafeFoods = file.defaultSafeFoods

        let byKey = Dictionary(file.ingredients.map { ($0.key, $0) }, uniquingKeysWith: { first, _ in first })
        ingredientsByKey = byKey
        recipesByID = Dictionary(file.recipes.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        browsable = file.recipes.filter { !$0.planOnly }.sorted { $0.title < $1.title }
        cuisines = Set(browsable.map(\.cuisine)).sorted()

        var allergens: [String: Set<Allergen>] = [:]
        var search: [String: String] = [:]
        for recipe in file.recipes {
            let items = recipe.ingredientKeys.compactMap { byKey[$0] }
            allergens[recipe.id] = Set(items.flatMap(\.allergens))
            search[recipe.id] = ([recipe.title, recipe.cuisine] + items.map(\.name)).joined(separator: " ").lowercased()
        }
        allergensByRecipe = allergens
        searchText = search
    }

    func recipe(id: String) -> LibraryRecipe? { recipesByID[id] }

    func allergens(for recipe: LibraryRecipe) -> Set<Allergen> { allergensByRecipe[recipe.id] ?? [] }

    func ingredients(for recipe: LibraryRecipe) -> [CatalogIngredient] {
        recipe.ingredientKeys.compactMap { ingredientsByKey[$0] }
    }

    func matches(_ recipe: LibraryRecipe, search query: String) -> Bool {
        let words = query.lowercased().split(separator: " ")
        guard !words.isEmpty, let text = searchText[recipe.id] else { return true }
        return words.allSatisfy { text.contains($0) }
    }

    func safetyCallouts(for recipe: LibraryRecipe, ageInMonths: Int) -> [SafetyCallout] {
        SafetyEngine.callouts(
            for: ingredients(for: recipe).map { (id: $0.key, name: $0.name, hazard: $0.hazard) },
            ageInMonths: ageInMonths
        )
    }
}

// MARK: - Ingredient ↔ Catalog

extension Ingredient {
    static func make(from entry: CatalogIngredient) -> Ingredient {
        let item = Ingredient(
            name: entry.name,
            category: entry.category,
            isProteinStaple: entry.isProteinStaple,
            toddlerSafetyNote: entry.toddlerSafetyNote,
            hazard: entry.hazard,
            allergens: entry.allergens,
            swapGroup: entry.swapGroup,
            proteinPerServing: entry.nutrition.proteinGrams,
            hasLactoseFreeOption: entry.hasLactoseFreeOption,
            quantity: entry.quantity
        )
        item.catalogKey = entry.key
        return item
    }
}

/// Finds the stored `Ingredient` for a catalog key, inserting it on first use.
@MainActor
final class IngredientResolver {
    private let context: ModelContext
    private var byKey: [String: Ingredient] = [:]

    init(context: ModelContext) {
        self.context = context
        let all = (try? context.fetch(FetchDescriptor<Ingredient>())) ?? []
        for item in all {
            if let key = item.catalogKey, byKey[key] == nil { byKey[key] = item }
        }
    }

    func ingredient(forKey key: String) -> Ingredient? {
        if let existing = byKey[key] { return existing }
        guard let entry = RecipeLibrary.shared.ingredientsByKey[key] else { return nil }
        let item = Ingredient.make(from: entry)
        context.insert(item)
        byKey[key] = item
        return item
    }
}

// MARK: - Plan Builder

@MainActor
enum PlanBuilder {
    static func makeMeal(from recipe: LibraryRecipe, slot: MealSlot, resolver: IngredientResolver, context: ModelContext) -> MealItem {
        let meal = MealItem(
            title: recipe.title,
            mealSlot: slot,
            prepTimeMinutes: recipe.prepTimeMinutes,
            toddlerPrepInstructions: recipe.steps,
            textures: recipe.textures,
            macros: recipe.macros
        )
        meal.libraryRecipeID = recipe.id
        context.insert(meal)
        meal.ingredients = recipe.ingredientKeys.compactMap { resolver.ingredient(forKey: $0) }
        return meal
    }

    /// Puts a library recipe into a day's slot, replacing whatever was there. With `leftoversFor`,
    /// also plans "Cook Once, Serve Twice" leftovers for that day's lunch.
    @discardableResult
    static func place(
        _ recipe: LibraryRecipe,
        in day: MealPlanDay,
        slot: MealSlot,
        leftoversFor target: MealPlanDay? = nil,
        child: ChildProfile?,
        context: ModelContext
    ) -> MealItem {
        let resolver = IngredientResolver(context: context)
        if let existing = (day.meals ?? []).first(where: { $0.mealSlot == slot }) {
            remove(existing, context: context, refreshWidgets: false)
        }
        let meal = makeMeal(from: recipe, slot: slot, resolver: resolver, context: context)
        meal.day = day

        if let target, target.id != day.id {
            if let oldLunch = (target.meals ?? []).first(where: { $0.mealSlot == .lunch }) {
                remove(oldLunch, context: context, refreshWidgets: false)
            }
            let leftover = makeMeal(from: recipe, slot: .lunch, resolver: resolver, context: context)
            leftover.title = "Leftover \(recipe.title)"
            leftover.prepTimeMinutes = 5
            leftover.toddlerPrepInstructions = [
                "Reheat the Day \(day.dayIndex) leftovers until steaming (165°F / 74°C), then cool to warm.",
                "Stir in a splash of water or broth if it has thickened.",
                "Use within 3–4 days of cooking.",
            ]
            leftover.day = target
            meal.spawnsLeftoverForMealID = leftover.id
            leftover.isLeftoverFromMealID = meal.id
            meal.toddlerPrepInstructions.append(
                "Cook once, serve twice: refrigerate a toddler portion for Day \(target.dayIndex) lunch.")
        }

        if let child {
            SafeFoodPlanner.guarantee(days: [day, target].compactMap { $0 }, child: child)
        }
        WidgetSnapshotWriter.refresh(context: context)
        return meal
    }

    /// Removes a meal and keeps leftover links consistent: deleting a cook-once meal also deletes
    /// the leftover it was going to produce.
    static func remove(_ meal: MealItem, context: ModelContext, refreshWidgets: Bool = true) {
        let all = (try? context.fetch(FetchDescriptor<MealItem>())) ?? []
        if let leftoverID = meal.spawnsLeftoverForMealID, let leftover = all.first(where: { $0.id == leftoverID }) {
            leftover.day = nil
            context.delete(leftover)
        }
        if let sourceID = meal.isLeftoverFromMealID, let source = all.first(where: { $0.id == sourceID }) {
            source.spawnsLeftoverForMealID = nil
            source.toddlerPrepInstructions.removeAll { $0.hasPrefix("Cook once, serve twice") }
        }
        meal.day = nil
        context.delete(meal)
        if refreshWidgets { WidgetSnapshotWriter.refresh(context: context) }
    }

    /// Replaces the whole week with a fresh, allergy-aware selection from the library.
    /// Batch-friendly dinners on days 2 and 4 also feed the next day's lunch.
    static func generateWeek(days: [MealPlanDay], child: ChildProfile?, context: ModelContext) {
        let library = RecipeLibrary.shared
        let blocked = Set(child?.allergies ?? [])
        let sorted = days.sorted { $0.dayIndex < $1.dayIndex }
        var used = Set<String>()

        for day in sorted {
            let old = day.meals ?? []
            day.meals = []
            old.forEach { context.delete($0) }
            let oldTasks = day.batchPrepTasks ?? []
            day.batchPrepTasks = []
            oldTasks.forEach { context.delete($0) }
        }

        func pick(_ slot: MealSlot, maxMinutes: Int?) -> LibraryRecipe? {
            let candidates = library.browsable.filter { recipe in
                recipe.slots.contains(slot)
                    && !used.contains(recipe.id)
                    && library.allergens(for: recipe).isDisjoint(with: blocked)
                    && recipe.prepTimeMinutes <= (maxMinutes ?? Int.max)
            }
            guard let choice = candidates.randomElement() else { return nil }
            used.insert(choice.id)
            return choice
        }

        var prepNotes: [Int: [(String, String)]] = [:]
        for (index, day) in sorted.enumerated() {
            for slot in MealSlot.allCases {
                if (day.meals ?? []).contains(where: { $0.mealSlot == slot }) { continue }
                let maxMinutes: Int? = switch slot {
                case .dinner: 60
                case .lunch: 25
                default: 20
                }
                guard let recipe = pick(slot, maxMinutes: maxMinutes) else { continue }
                let next = index + 1 < sorted.count ? sorted[index + 1] : nil
                let chain = slot == .dinner && recipe.batchFriendly && index % 2 == 1 && next != nil
                place(recipe, in: day, slot: slot, leftoversFor: chain ? next : nil, child: nil, context: context)
                if chain, let next {
                    prepNotes[day.dayIndex, default: []].append(
                        ("Make a double batch of \(recipe.title)", "Refrigerate a portion for Day \(next.dayIndex) lunch."))
                }
            }
        }

        prepNotes[sorted.first?.dayIndex ?? 1, default: []].insert(contentsOf: [
            ("Wash & prep produce", "Quarter round fruits lengthwise, hull berries, and steam hard veggies for the week."),
            ("Cook a base grain", "Make 2 cups of rice or quinoa. Cool within 1 hour and refrigerate."),
            ("Hard-boil 4 eggs", "Quick protein for snacks and lunches."),
        ], at: 0)
        for day in sorted {
            day.batchPrepTasks = (prepNotes[day.dayIndex] ?? []).enumerated().map { order, note in
                let task = PrepTask(title: note.0, detail: note.1, order: order)
                context.insert(task)
                return task
            }
        }

        if let child { SafeFoodPlanner.guarantee(days: sorted, child: child) }
        WidgetSnapshotWriter.refresh(context: context)
    }
}
