import Foundation

// MARK: - Age-Adaptive Safety & Texture Engine

enum ChokingHazard: String, Codable, CaseIterable, Identifiable, Sendable {
    case roundFood, wholeNuts, nutButter, toughMeat, hardRawProduce, firmCubes, fishBones, honey, sausage, driedFruit

    var id: String { rawValue }

    var title: String {
        switch self {
        case .roundFood: "Small Round Foods"
        case .wholeNuts: "Whole Nuts & Seeds"
        case .nutButter: "Nut & Seed Butters"
        case .toughMeat: "Tough or Chunky Meat"
        case .hardRawProduce: "Hard Raw Fruit & Veg"
        case .firmCubes: "Firm Cheese Cubes"
        case .fishBones: "Fish with Bones"
        case .honey: "Honey"
        case .sausage: "Hot Dogs & Sausages"
        case .driedFruit: "Dried Fruit"
        }
    }

    var examples: String {
        switch self {
        case .roundFood: "Grapes, cherry tomatoes, blueberries, edamame"
        case .wholeNuts: "Almonds, walnuts, pumpkin seeds"
        case .nutButter: "Peanut, almond, sunflower seed butter"
        case .toughMeat: "Chicken breast cubes, deli meat, steak"
        case .hardRawProduce: "Apples, carrots, bell pepper, cucumber"
        case .firmCubes: "Cheddar, mozzarella cubes"
        case .fishBones: "Salmon, cod, tilapia fillets"
        case .honey: "Raw or cooked honey"
        case .sausage: "Hot dogs, chicken sausage, links"
        case .driedFruit: "Raisins, dates, dried apricots"
        }
    }

    var symbol: String {
        switch self {
        case .roundFood: "circle.grid.2x2.fill"
        case .wholeNuts: "leaf.fill"
        case .nutButter: "takeoutbag.and.cup.and.straw.fill"
        case .toughMeat: "fork.knife"
        case .hardRawProduce: "carrot.fill"
        case .firmCubes: "cube.fill"
        case .fishBones: "fish.fill"
        case .honey: "drop.fill"
        case .sausage: "fork.knife.circle.fill"
        case .driedFruit: "leaf.circle.fill"
        }
    }
}

struct SafetyGuidance: Hashable, Sendable {
    enum Level: Int, Comparable, Sendable {
        case ok, modify, avoid

        var label: String {
            switch self {
            case .ok: "OK with supervision"
            case .modify: "Modify"
            case .avoid: "Avoid"
            }
        }

        static func < (lhs: Level, rhs: Level) -> Bool { lhs.rawValue < rhs.rawValue }
    }

    let level: Level
    let instruction: String
}

struct SafetyCallout: Identifiable, Hashable {
    let id: String
    let ingredientName: String
    let hazard: ChokingHazard
    let guidance: SafetyGuidance
}

/// General guidance modeled on common pediatric choking-prevention advice.
/// It is not medical advice; families should confirm with their pediatrician.
enum SafetyEngine {
    static func guidance(for hazard: ChokingHazard, ageInMonths age: Int) -> SafetyGuidance {
        switch hazard {
        case .roundFood:
            if age < 48 { return .init(level: .modify, instruction: "Quarter grapes and cherry tomatoes lengthwise; halve or smash blueberries and edamame.") }
            if age < 60 { return .init(level: .modify, instruction: "Halve lengthwise and supervise closely.") }
            return .init(level: .ok, instruction: "Whole is fine for most kids 5+ when seated and supervised.")
        case .wholeNuts:
            if age < 48 { return .init(level: .avoid, instruction: "No whole or chopped nuts. Blend, finely grind, or crush to a powder and stir into oatmeal or yogurt.") }
            if age < 60 { return .init(level: .modify, instruction: "Finely chopped nuts only, seated and supervised.") }
            return .init(level: .ok, instruction: "Whole nuts are fine from about age 5 with supervision.")
        case .nutButter:
            if age < 12 { return .init(level: .modify, instruction: "Thin with water or yogurt and spread a whisper-thin layer.") }
            return .init(level: .modify, instruction: "Thin smear only. Never serve a spoonful or a thick glob.")
        case .toughMeat:
            if age < 24 { return .init(level: .modify, instruction: "Shred finely or serve ground meat stirred into a moist sauce.") }
            if age < 48 { return .init(level: .modify, instruction: "Shred or finely chop (shred chicken thighs instead of cubing breast); slice deli meat into thin strips.") }
            return .init(level: .ok, instruction: "Cut into small, thin bites across the grain.")
        case .hardRawProduce:
            if age < 48 { return .init(level: .modify, instruction: "Steam until soft, or grate or slice paper-thin. Peel apples, pears and cucumbers.") }
            if age < 60 { return .init(level: .modify, instruction: "Thin slices or matchsticks; avoid hard round coins.") }
            return .init(level: .ok, instruction: "Raw is fine in thin slices with supervision.")
        case .firmCubes:
            if age < 24 { return .init(level: .modify, instruction: "Shred, or slice cheese into thin strips.") }
            if age < 48 { return .init(level: .modify, instruction: "Cut into small ½-inch cubes or thin sticks.") }
            return .init(level: .ok, instruction: "Bite-size cubes are fine.")
        case .fishBones:
            return .init(level: .modify, instruction: "Flake into small pieces and check carefully for pin bones.")
        case .honey:
            if age < 12 { return .init(level: .avoid, instruction: "No honey before 12 months (infant botulism risk).") }
            return .init(level: .ok, instruction: "Fine after 12 months.")
        case .sausage:
            if age < 48 { return .init(level: .modify, instruction: "Quarter lengthwise, then chop into small pieces. Never serve round coins.") }
            if age < 60 { return .init(level: .modify, instruction: "Halve lengthwise and slice thin.") }
            return .init(level: .ok, instruction: "Thin slices are fine with supervision.")
        case .driedFruit:
            if age < 48 { return .init(level: .modify, instruction: "Chop finely, plump in warm water, or blend into the dish.") }
            return .init(level: .ok, instruction: "Fine in small amounts with supervision.")
        }
    }

    /// Hazards in a meal that need action (modify / avoid) at this age, most serious first.
    static func callouts(for meal: MealItem, ageInMonths: Int) -> [SafetyCallout] {
        callouts(for: meal.sortedIngredients.map { (id: $0.id.uuidString, name: $0.name, hazard: $0.hazard) }, ageInMonths: ageInMonths)
    }

    static func callouts(for items: [(id: String, name: String, hazard: ChokingHazard?)], ageInMonths: Int) -> [SafetyCallout] {
        items.compactMap { item -> SafetyCallout? in
            guard let hazard = item.hazard else { return nil }
            let guidance = Self.guidance(for: hazard, ageInMonths: ageInMonths)
            guard guidance.level != .ok else { return nil }
            return SafetyCallout(id: item.id, ingredientName: item.name, hazard: hazard, guidance: guidance)
        }
        .sorted { $0.guidance.level > $1.guidance.level }
    }

    static func allergenConflicts(in meal: MealItem, for child: ChildProfile?) -> [Allergen] {
        guard let child, !child.allergies.isEmpty else { return [] }
        let present = Set((meal.ingredients ?? []).flatMap(\.allergens))
        return child.allergies.filter { present.contains($0) }
    }
}

// MARK: - Daily Targets

enum DailyTargets {
    static let proteinVarieties = 4
    static let healthyFatGrams = 35.0

    /// Approximate daily iron recommendation by age.
    static func ironMilligrams(ageInMonths: Int) -> Double {
        switch ageInMonths {
        case ..<12: 11
        case ..<48: 7
        default: 10
        }
    }
}

// MARK: - "Safe Food" Guarantee (Division of Responsibility)

@MainActor
enum SafeFoodPlanner {
    static func safeFoods(in meal: MealItem, for child: ChildProfile) -> [Ingredient] {
        meal.sortedIngredients.filter { child.isSafeFood($0) }
    }

    /// Safe foods the child can have (no allergen conflicts).
    static func eligibleSafeFoods(for child: ChildProfile) -> [Ingredient] {
        (child.safeFoods ?? [])
            .filter { Set($0.allergens).isDisjoint(with: child.allergies) }
            .sorted { $0.name < $1.name }
    }

    static func add(_ food: Ingredient, to meal: MealItem) {
        guard !(meal.ingredients ?? []).contains(where: { $0.id == food.id }) else { return }
        meal.ingredients?.append(food)
    }

    /// Adds a safe-food side to every meal that lacks one, rotating so the same food isn't
    /// repeated all day. Returns the number of meals changed.
    @discardableResult
    static func guarantee(days: [MealPlanDay], child: ChildProfile) -> Int {
        let options = eligibleSafeFoods(for: child)
        guard !options.isEmpty else { return 0 }
        var changed = 0
        for day in days {
            var usage: [UUID: Int] = [:]
            for meal in day.sortedMeals {
                for food in safeFoods(in: meal, for: child) { usage[food.id, default: 0] += 1 }
            }
            for meal in day.sortedMeals where safeFoods(in: meal, for: child).isEmpty {
                guard let pick = options.min(by: { usage[$0.id, default: 0] < usage[$1.id, default: 0] }) else { continue }
                add(pick, to: meal)
                usage[pick.id, default: 0] += 1
                changed += 1
            }
        }
        return changed
    }
}

// MARK: - Smart Protein Swaps

@MainActor
enum ProteinSwapEngine {
    /// Same-group alternatives, preferring what's already in the pantry and similar protein.
    static func alternatives(for ingredient: Ingredient, in all: [Ingredient]) -> [Ingredient] {
        guard let group = ingredient.swapGroup else { return [] }
        return all
            .filter { $0.swapGroup == group && $0.id != ingredient.id }
            .sorted {
                ($0.inPantry ? 0 : 1, abs($0.proteinPerServing - ingredient.proteinPerServing))
                    < ($1.inPantry ? 0 : 1, abs($1.proteinPerServing - ingredient.proteinPerServing))
            }
    }

    static func swap(_ old: Ingredient, with new: Ingredient, in meal: MealItem) {
        guard var list = meal.ingredients, let index = list.firstIndex(where: { $0.id == old.id }) else { return }
        list.remove(at: index)
        if !list.contains(where: { $0.id == new.id }) { list.append(new) }
        meal.ingredients = list
        meal.macros.proteinGrams = max(0, meal.macros.proteinGrams + new.proteinPerServing - old.proteinPerServing)
    }

    /// Swaps an ingredient everywhere it's used in the plan (e.g. salmon is sold out).
    static func swapEverywhere(_ old: Ingredient, with new: Ingredient) {
        for meal in old.meals ?? [] { Self.swap(old, with: new, in: meal) }
    }
}

// MARK: - Fridge Forager (offline, rule-based)

@MainActor
enum FridgeForager {
    struct Match: Identifiable {
        let recipe: LibraryRecipe
        let matchedNames: [String]
        var id: String { recipe.id }
    }

    struct PlateIdea {
        let title: String
        let minutes: Int
        let steps: [String]
    }

    /// Library recipes that use the picked items and avoid the child's allergens,
    /// best matches and quickest first.
    static func matches(
        for picks: [Ingredient],
        in library: RecipeLibrary,
        avoiding allergies: [Allergen],
        maxMinutes: Int = 20,
        limit: Int = 20
    ) -> [Match] {
        let pickedKeys = Set(picks.compactMap(\.catalogKey))
        guard !pickedKeys.isEmpty else { return [] }
        let blocked = Set(allergies)
        return library.browsable
            .filter { $0.prepTimeMinutes <= maxMinutes && library.allergens(for: $0).isDisjoint(with: blocked) }
            .compactMap { recipe -> Match? in
                let hits = recipe.ingredientKeys.filter { pickedKeys.contains($0) }
                guard !hits.isEmpty else { return nil }
                return Match(recipe: recipe, matchedNames: hits.compactMap { library.ingredientsByKey[$0]?.shortName })
            }
            .sorted {
                ($1.matchedNames.count, $0.recipe.prepTimeMinutes) < ($0.matchedNames.count, $1.recipe.prepTimeMinutes)
            }
            .prefix(limit)
            .map { $0 }
    }

    /// Composes a balanced, toddler-safe plate from up to three picked items.
    static func plate(from picks: [Ingredient], ageInMonths: Int, safeFood: Ingredient?) -> PlateIdea? {
        guard !picks.isEmpty else { return nil }
        var steps = picks.map(method(for:))
        for pick in picks {
            guard let hazard = pick.hazard else { continue }
            let guidance = SafetyEngine.guidance(for: hazard, ageInMonths: ageInMonths)
            if guidance.level != .ok { steps.append("Safety (\(pick.name)): \(guidance.instruction)") }
        }
        if let safeFood, !picks.contains(where: { $0.id == safeFood.id }) {
            steps.append("Add a familiar safe food on the side: \(safeFood.name).")
        }
        if !picks.contains(where: \.isProteinStaple) {
            steps.append("Boost protein: add a dollop of Greek yogurt or a sliced hard-boiled egg.")
        }
        let shortNames = picks.map { $0.name.components(separatedBy: CharacterSet(charactersIn: "(/,")).first?.trimmingCharacters(in: .whitespaces) ?? $0.name }
        return PlateIdea(
            title: shortNames.joined(separator: " + ") + " Plate",
            minutes: min(15, 4 + picks.count * 3),
            steps: steps
        )
    }

    private static func method(for ingredient: Ingredient) -> String {
        let name = ingredient.name
        switch ingredient.category {
        case .poultryAndMeat:
            return "Use cooked \(name) (leftovers or rotisserie); shred into thin strands."
        case .seafood:
            return "Flake \(name) and mix with a spoon of Greek yogurt or a little olive oil."
        case .eggsAndDairy:
            if name.lowercased().contains("egg") { return "Soft-scramble the eggs over low heat until just set." }
            return "Serve \(name) as a creamy dip or spread."
        case .plantBasedPantry:
            return ingredient.isProteinStaple
                ? "Warm \(name) and mash lightly with a fork."
                : "Warm or toast \(name) and cut into finger strips."
        case .snacksAndBoosters:
            return "Use \(name) as a booster: thin smear, or blend into the dish."
        case .produce:
            return "Steam \(name) until fork-soft, then cut into finger-size pieces."
        }
    }
}
