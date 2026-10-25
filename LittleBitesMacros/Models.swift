import Foundation
import SwiftData

// MARK: - Schema

/// Every persistent model in the app. Used by the app container and previews.
enum AppSchema {
    static var models: [any PersistentModel.Type] {
        [ChildProfile.self, Ingredient.self, MealItem.self, MealPlanDay.self, PrepTask.self, FoodExposureLog.self,
         FavoriteRecipe.self]
    }
}

// NOTE ON CLOUDKIT: SwiftData + CloudKit requires every stored property to have a default
// value (or be optional), every relationship to be optional, and no `.unique` attributes.
// That is why relationship arrays below are `[T]?` rather than `[T]`.

// MARK: - Enums

enum Allergen: String, Codable, CaseIterable, Identifiable, Sendable {
    case dairy, egg, peanut, treeNut, soy, wheat, fish, shellfish, sesame

    var id: String { rawValue }

    var label: String {
        switch self {
        case .dairy: "Dairy"
        case .egg: "Egg"
        case .peanut: "Peanut"
        case .treeNut: "Tree Nut"
        case .soy: "Soy"
        case .wheat: "Wheat"
        case .fish: "Fish"
        case .shellfish: "Shellfish"
        case .sesame: "Sesame"
        }
    }
}

enum GroceryCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case poultryAndMeat, seafood, eggsAndDairy, plantBasedPantry, snacksAndBoosters, produce

    var id: String { rawValue }

    var title: String {
        switch self {
        case .poultryAndMeat: "Fresh Poultry & Meat"
        case .seafood: "Seafood & Fish"
        case .eggsAndDairy: "Eggs & Dairy"
        case .plantBasedPantry: "Plant-Based & Pantry"
        case .snacksAndBoosters: "Quick Snacks & Boosters"
        case .produce: "Produce"
        }
    }

    var shortTitle: String {
        switch self {
        case .poultryAndMeat: "Meat"
        case .seafood: "Seafood"
        case .eggsAndDairy: "Dairy"
        case .plantBasedPantry: "Pantry"
        case .snacksAndBoosters: "Snacks"
        case .produce: "Produce"
        }
    }

    var symbol: String {
        switch self {
        case .poultryAndMeat: "fork.knife"
        case .seafood: "fish.fill"
        case .eggsAndDairy: "cup.and.saucer.fill"
        case .plantBasedPantry: "leaf.fill"
        case .snacksAndBoosters: "bolt.fill"
        case .produce: "carrot.fill"
        }
    }
}

enum TextureType: String, Codable, CaseIterable, Identifiable, Sendable {
    case softScoopable, fingerFood, dippers, smoothies, crispy

    var id: String { rawValue }

    var title: String {
        switch self {
        case .softScoopable: "Soft/Scoopable"
        case .fingerFood: "Finger Food"
        case .dippers: "Dippers"
        case .smoothies: "Smoothies"
        case .crispy: "Crispy"
        }
    }

    var symbol: String {
        switch self {
        case .softScoopable: "circle.bottomhalf.filled"
        case .fingerFood: "hand.raised.fill"
        case .dippers: "drop.fill"
        case .smoothies: "waterbottle.fill"
        case .crispy: "sparkles"
        }
    }
}

/// Neutral, no-pressure steps toward accepting a new food.
enum ExposureStage: String, Codable, CaseIterable, Identifiable, Comparable, Sendable {
    case offered, touched, smelled, licked, tasted, accepted

    var id: String { rawValue }

    var label: String {
        switch self {
        case .offered: "Offered"
        case .touched: "Touched It"
        case .smelled: "Smelled It"
        case .licked: "Licked It"
        case .tasted: "Ate a Bite"
        case .accepted: "Loved It"
        }
    }

    var symbol: String {
        switch self {
        case .offered: "hand.point.right.fill"
        case .touched: "hand.tap.fill"
        case .smelled: "nose.fill"
        case .licked: "mouth.fill"
        case .tasted: "fork.knife"
        case .accepted: "heart.fill"
        }
    }

    var rank: Int { Self.allCases.firstIndex(of: self) ?? 0 }

    static func < (lhs: ExposureStage, rhs: ExposureStage) -> Bool { lhs.rank < rhs.rank }
}

// MARK: - Value Types

/// Per-portion estimate for a toddler serving.
struct MacroEstimate: Codable, Hashable, Sendable {
    var proteinGrams: Double = 0
    var healthyFatGrams: Double = 0
    var complexCarbGrams: Double = 0
    var ironMilligrams: Double = 0

    static let zero = MacroEstimate()

    static func + (lhs: MacroEstimate, rhs: MacroEstimate) -> MacroEstimate {
        MacroEstimate(
            proteinGrams: lhs.proteinGrams + rhs.proteinGrams,
            healthyFatGrams: lhs.healthyFatGrams + rhs.healthyFatGrams,
            complexCarbGrams: lhs.complexCarbGrams + rhs.complexCarbGrams,
            ironMilligrams: lhs.ironMilligrams + rhs.ironMilligrams
        )
    }
}

// MARK: - Models

@Model
final class ChildProfile {
    var id: UUID = UUID()
    var name: String = ""
    var birthDate: Date = Date.now
    var allergies: [Allergen] = []
    var texturePreferences: [TextureType] = []

    @Relationship(deleteRule: .nullify, inverse: \Ingredient.safeForChildren)
    var safeFoods: [Ingredient]? = []

    @Relationship(deleteRule: .cascade, inverse: \FoodExposureLog.child)
    var exposureLogs: [FoodExposureLog]? = []

    init(name: String, birthDate: Date, allergies: [Allergen] = [], texturePreferences: [TextureType] = []) {
        self.name = name
        self.birthDate = birthDate
        self.allergies = allergies
        self.texturePreferences = texturePreferences
    }

    var ageInMonths: Int {
        Calendar.current.dateComponents([.month], from: birthDate, to: .now).month ?? 0
    }

    var ageDescription: String {
        let months = ageInMonths
        if months < 24 { return "\(months) mo" }
        let years = months / 12
        let remainder = months % 12
        return remainder == 0 ? "\(years) yrs" : "\(years) yrs \(remainder) mo"
    }

    func isSafeFood(_ ingredient: Ingredient) -> Bool {
        (safeFoods ?? []).contains { $0.id == ingredient.id }
    }

    func logs(for ingredient: Ingredient) -> [FoodExposureLog] {
        (exposureLogs ?? [])
            .filter { $0.ingredient?.id == ingredient.id }
            .sorted { $0.date > $1.date }
    }
}

@Model
final class Ingredient {
    var id: UUID = UUID()
    /// Key into `RecipeLibrary` ingredients; nil for items the user typed in.
    var catalogKey: String?
    var name: String = ""
    var category: GroceryCategory = GroceryCategory.produce
    var isProteinStaple: Bool = false
    var toddlerSafetyNote: String?
    /// Drives the age-adaptive safety engine (see `SafetyEngine`).
    var hazard: ChokingHazard?
    var allergens: [Allergen] = []
    /// Ingredients sharing a swap group can be substituted 1:1 (e.g. "fish").
    var swapGroup: String?
    /// Approximate protein in one toddler serving, in grams.
    var proteinPerServing: Double = 0
    var hasLactoseFreeOption: Bool = false
    var inPantry: Bool = false
    /// True for items added by hand (not via the meal plan).
    var isOnShoppingList: Bool = false
    var quantity: String = ""

    var meals: [MealItem]? = []
    var safeForChildren: [ChildProfile]? = []
    var exposureLogs: [FoodExposureLog]? = []

    init(
        name: String,
        category: GroceryCategory,
        isProteinStaple: Bool = false,
        toddlerSafetyNote: String? = nil,
        hazard: ChokingHazard? = nil,
        allergens: [Allergen] = [],
        swapGroup: String? = nil,
        proteinPerServing: Double = 0,
        hasLactoseFreeOption: Bool = false,
        quantity: String = ""
    ) {
        self.name = name
        self.category = category
        self.isProteinStaple = isProteinStaple
        self.toddlerSafetyNote = toddlerSafetyNote
        self.hazard = hazard
        self.allergens = allergens
        self.swapGroup = swapGroup
        self.proteinPerServing = proteinPerServing
        self.hasLactoseFreeOption = hasLactoseFreeOption
        self.quantity = quantity
    }

    /// Distinctive words used to match receipt text and search queries.
    var keywords: [String] {
        let stopWords: Set<String> = [
            "fillets", "whole", "plain", "natural", "canned", "boneless", "skinless", "fresh",
            "frozen", "shelled", "sliced", "option", "lean", "ground", "with", "water", "ripe",
        ]
        return name.lowercased()
            .components(separatedBy: CharacterSet.letters.inverted)
            .filter { $0.count >= 4 && !stopWords.contains($0) }
    }

    var mealCount: Int { meals?.count ?? 0 }
}

@Model
final class MealItem {
    var id: UUID = UUID()
    /// The `LibraryRecipe` this meal was made from, if any.
    var libraryRecipeID: String?
    var title: String = ""
    var mealSlot: MealSlot = MealSlot.breakfast
    var prepTimeMinutes: Int = 5
    var isLeftoverFromMealID: UUID?
    var spawnsLeftoverForMealID: UUID?
    var toddlerPrepInstructions: [String] = []
    var textures: [TextureType] = []
    var macros: MacroEstimate = MacroEstimate.zero

    @Relationship(deleteRule: .nullify, inverse: \Ingredient.meals)
    var ingredients: [Ingredient]? = []

    var day: MealPlanDay?

    init(
        title: String,
        mealSlot: MealSlot,
        prepTimeMinutes: Int,
        toddlerPrepInstructions: [String],
        textures: [TextureType],
        macros: MacroEstimate
    ) {
        self.title = title
        self.mealSlot = mealSlot
        self.prepTimeMinutes = prepTimeMinutes
        self.toddlerPrepInstructions = toddlerPrepInstructions
        self.textures = textures
        self.macros = macros
    }

    var sortedIngredients: [Ingredient] {
        (ingredients ?? []).sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
    }

    var isLeftoverFriendly: Bool { isLeftoverFromMealID != nil || spawnsLeftoverForMealID != nil }

    /// e.g. "Day 2 Dinner"
    var scheduleLabel: String {
        guard let day else { return mealSlot.title }
        return "Day \(day.dayIndex) \(mealSlot.title)"
    }
}

@Model
final class MealPlanDay {
    var id: UUID = UUID()
    var dayIndex: Int = 1
    var date: Date = Date.now

    @Relationship(deleteRule: .cascade, inverse: \MealItem.day)
    var meals: [MealItem]? = []

    @Relationship(deleteRule: .cascade, inverse: \PrepTask.day)
    var batchPrepTasks: [PrepTask]? = []

    init(dayIndex: Int, date: Date) {
        self.dayIndex = dayIndex
        self.date = date
    }

    var sortedMeals: [MealItem] {
        (meals ?? []).sorted { $0.mealSlot.sortOrder < $1.mealSlot.sortOrder }
    }

    var sortedTasks: [PrepTask] {
        (batchPrepTasks ?? []).sorted { $0.order < $1.order }
    }

    var totalMacros: MacroEstimate {
        sortedMeals.reduce(.zero) { $0 + $1.macros }
    }

    /// Number of distinct protein staples served across the day.
    var proteinVarietyCount: Int {
        Set(sortedMeals.flatMap { $0.ingredients ?? [] }.filter(\.isProteinStaple).map(\.id)).count
    }
}

@Model
final class PrepTask {
    var id: UUID = UUID()
    var title: String = ""
    var detail: String = ""
    var order: Int = 0
    var isDone: Bool = false
    var day: MealPlanDay?

    init(title: String, detail: String, order: Int) {
        self.title = title
        self.detail = detail
        self.order = order
    }
}

@Model
final class FoodExposureLog {
    var id: UUID = UUID()
    @Relationship(deleteRule: .nullify, inverse: \Ingredient.exposureLogs)
    var ingredient: Ingredient?
    var date: Date = Date.now
    var reaction: ExposureStage = ExposureStage.offered
    var note: String = ""
    var child: ChildProfile?

    init(date: Date = .now, reaction: ExposureStage, note: String = "") {
        self.date = date
        self.reaction = reaction
        self.note = note
    }
}

/// A recipe the family starred in the library. Synced, so every caregiver sees the same favorites.
@Model
final class FavoriteRecipe {
    var recipeID: String = ""
    var addedAt: Date = Date.now

    init(recipeID: String) {
        self.recipeID = recipeID
    }
}
