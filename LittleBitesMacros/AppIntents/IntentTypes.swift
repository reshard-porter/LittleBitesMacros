import AppIntents
import Foundation

extension MealSlot: AppEnum {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Meal"
    static let caseDisplayRepresentations: [MealSlot: DisplayRepresentation] = [
        .breakfast: DisplayRepresentation(title: "breakfast", synonyms: ["morning meal"]),
        .morningSnack: DisplayRepresentation(title: "morning snack", synonyms: ["AM snack", "first snack"]),
        .lunch: DisplayRepresentation(title: "lunch"),
        .afternoonSnack: DisplayRepresentation(title: "afternoon snack", synonyms: ["PM snack", "snack"]),
        .dinner: DisplayRepresentation(title: "dinner", synonyms: ["supper", "tea"]),
    ]
}

extension ExposureStage: AppEnum {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Reaction"
    static let caseDisplayRepresentations: [ExposureStage: DisplayRepresentation] = [
        .offered: DisplayRepresentation(title: "was offered", synonyms: ["offered", "saw"]),
        .touched: DisplayRepresentation(title: "touched", synonyms: ["touched it", "played with"]),
        .smelled: DisplayRepresentation(title: "smelled", synonyms: ["smelled it", "sniffed"]),
        .licked: DisplayRepresentation(title: "licked", synonyms: ["licked it"]),
        .tasted: DisplayRepresentation(title: "ate a bite of", synonyms: ["tasted", "ate a bite", "tried"]),
        .accepted: DisplayRepresentation(title: "loved", synonyms: ["loved it", "ate", "liked"]),
    ]
}

enum PlanDayOption: String, AppEnum {
    case today, tomorrow

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Day"
    static let caseDisplayRepresentations: [PlanDayOption: DisplayRepresentation] = [
        .today: "today",
        .tomorrow: "tomorrow",
    ]

    var date: Date {
        Calendar.current.date(byAdding: .day, value: self == .tomorrow ? 1 : 0, to: .now) ?? .now
    }
}

// MARK: - Grocery Item Entity

/// A grocery item Siri can add to the list. Backed by the bundled ingredient catalog, with a
/// lactose-free variant for dairy staples and a custom fallback for anything else.
struct GroceryItemEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Grocery Item"
    static let defaultQuery = GroceryItemQuery()

    /// `<catalogKey>`, `<catalogKey>|lf` for a lactose-free variant, or `custom:<name>`.
    let id: String
    let name: String
    let synonyms: [String]

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: LocalizedStringResource(stringLiteral: name),
            synonyms: synonyms.map { LocalizedStringResource(stringLiteral: $0) }
        )
    }

    var catalogKey: String? {
        guard !id.hasPrefix("custom:") else { return nil }
        return id.components(separatedBy: "|").first
    }

    var isLactoseFree: Bool { id.hasSuffix("|lf") }

    var customName: String? {
        id.hasPrefix("custom:") ? String(id.dropFirst("custom:".count)) : nil
    }

    static func catalogEntities() -> [GroceryItemEntity] {
        RecipeLibrary.shared.ingredients.flatMap { entry -> [GroceryItemEntity] in
            let base = GroceryItemEntity(id: entry.key, name: entry.shortName.capitalizedFirst, synonyms: [entry.name])
            guard entry.hasLactoseFreeOption else { return [base] }
            let lactoseFree = GroceryItemEntity(
                id: entry.key + "|lf",
                name: "Lactose-free \(entry.shortName)",
                synonyms: ["lactose free \(entry.shortName)", "dairy-free \(entry.shortName)"]
            )
            return [base, lactoseFree]
        }
    }

    static func custom(_ text: String) -> GroceryItemEntity {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return GroceryItemEntity(id: "custom:" + cleaned, name: cleaned.capitalizedFirst, synonyms: [])
    }
}

struct GroceryItemQuery: EntityStringQuery {
    func entities(for identifiers: [String]) async throws -> [GroceryItemEntity] {
        let catalog = Dictionary(GroceryItemEntity.catalogEntities().map { ($0.id, $0) }, uniquingKeysWith: { a, _ in a })
        return identifiers.compactMap { id in
            if let entity = catalog[id] { return entity }
            if id.hasPrefix("custom:") { return GroceryItemEntity.custom(String(id.dropFirst("custom:".count))) }
            return nil
        }
    }

    func entities(matching string: String) async throws -> [GroceryItemEntity] {
        let query = string.lowercased()
        let wantsLactoseFree = query.contains("lactose") || query.contains("dairy free") || query.contains("dairy-free")
        let words = query
            .components(separatedBy: CharacterSet.letters.inverted)
            .filter { $0.count >= 3 && !["lactose", "free", "dairy", "the", "some", "and"].contains($0) }

        let scored = GroceryItemEntity.catalogEntities()
            .filter { $0.isLactoseFree == wantsLactoseFree }
            .map { entity -> (GroceryItemEntity, Int) in
                let haystack = ([entity.name] + entity.synonyms).joined(separator: " ").lowercased()
                return (entity, words.filter { haystack.contains($0) }.count)
            }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
            .prefix(5)
            .map(\.0)

        return scored.isEmpty ? [GroceryItemEntity.custom(string)] : Array(scored)
    }

    func suggestedEntities() async throws -> [GroceryItemEntity] {
        GroceryItemEntity.catalogEntities()
    }
}

extension String {
    var capitalizedFirst: String {
        guard let first else { return self }
        return first.uppercased() + dropFirst()
    }
}
