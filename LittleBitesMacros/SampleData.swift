import Foundation
import SwiftData
import SwiftUI

/// Seeds the ingredient catalog, the 5-day 3-year-old meal plan, and a child profile on first
/// launch, all from the bundled `RecipeLibrary.json`.
@MainActor
enum SampleData {
    static func seedIfNeeded(context: ModelContext) {
        let existing = (try? context.fetchCount(FetchDescriptor<MealPlanDay>())) ?? 0
        guard existing == 0 else { return }
        seed(into: context, includeDemoLogs: false)
    }

    static func seed(into context: ModelContext, includeDemoLogs: Bool) {
        let library = RecipeLibrary.shared
        let resolver = IngredientResolver(context: context)

        // Insert the full catalog so swaps, the forager and safe-food pickers have everything.
        for entry in library.ingredients {
            _ = resolver.ingredient(forKey: entry.key)
        }

        // MARK: Days, meals & batch prep

        let start = Calendar.current.startOfDay(for: .now)
        var mealsByPosition: [String: MealItem] = [:]
        var days: [MealPlanDay] = []

        for planDay in library.defaultPlan.sorted(by: { $0.dayIndex < $1.dayIndex }) {
            let date = Calendar.current.date(byAdding: .day, value: planDay.dayIndex - 1, to: start) ?? start
            let day = MealPlanDay(dayIndex: planDay.dayIndex, date: date)
            context.insert(day)

            for planned in planDay.meals {
                guard let recipe = library.recipe(id: planned.recipeID) else { continue }
                let meal = PlanBuilder.makeMeal(from: recipe, slot: planned.slot, resolver: resolver, context: context)
                meal.day = day
                mealsByPosition["\(planDay.dayIndex)-\(planned.slot.rawValue)"] = meal
            }

            day.batchPrepTasks = planDay.prepTasks.enumerated().map { order, item in
                let task = PrepTask(title: item.title, detail: item.detail, order: order)
                context.insert(task)
                return task
            }
            days.append(day)
        }

        // MARK: Leftover chaining ("Cook Once, Serve Twice")

        for link in library.leftoverLinks {
            guard let source = mealsByPosition["\(link.fromDay)-\(link.fromSlot.rawValue)"],
                  let target = mealsByPosition["\(link.toDay)-\(link.toSlot.rawValue)"] else { continue }
            source.spawnsLeftoverForMealID = target.id
            target.isLeftoverFromMealID = source.id
        }

        // MARK: Child profile

        let birthDate = Calendar.current.date(byAdding: .month, value: -36, to: .now) ?? .now
        let child = ChildProfile(name: "Your Little One", birthDate: birthDate,
                                 texturePreferences: [.fingerFood, .dippers, .softScoopable])
        context.insert(child)
        child.safeFoods = library.defaultSafeFoods.compactMap { resolver.ingredient(forKey: $0) }

        SafeFoodPlanner.guarantee(days: days, child: child)

        if includeDemoLogs {
            let demo: [(String, [ExposureStage])] = [
                ("broccoli", [.offered, .offered, .touched, .smelled, .licked]),
                ("salmon", [.offered, .touched, .tasted, .tasted, .accepted]),
                ("avocado", [.offered, .touched]),
            ]
            for (key, stages) in demo {
                for (index, stage) in stages.enumerated() {
                    let entry = FoodExposureLog(
                        date: Calendar.current.date(byAdding: .day, value: -(stages.count - index), to: .now) ?? .now,
                        reaction: stage
                    )
                    context.insert(entry)
                    entry.ingredient = resolver.ingredient(forKey: key)
                    entry.child = child
                }
            }
        }

        try? context.save()
    }
}

// MARK: - Previews

struct SampleDataPreview: PreviewModifier {
    static func makeSharedContext() async throws -> ModelContainer {
        let container = try ModelContainer(
            for: Schema(AppSchema.models),
            configurations: ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        )
        await MainActor.run {
            SampleData.seed(into: container.mainContext, includeDemoLogs: true)
        }
        return container
    }

    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    static var sampleData: Self { .modifier(SampleDataPreview()) }
}
