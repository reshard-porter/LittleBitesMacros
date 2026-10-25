import SwiftData
import SwiftUI

@main
struct LittleBitesApp: App {
    @State private var router = AppRouter()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        AppModelContainer.prepare()
        WidgetSnapshotWriter.refresh(context: AppModelContainer.shared.mainContext)
        LittleBitesShortcuts.updateAppShortcutParameters()
        CookingTimerStore.shared.clearIfExpired()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(router)
                .onOpenURL { router.handle($0) }
        }
        .modelContainer(AppModelContainer.shared)
        .onChange(of: scenePhase) { _, phase in
            if phase == .background {
                WidgetSnapshotWriter.refresh(context: AppModelContainer.shared.mainContext)
            }
        }
    }
}

struct ContentView: View {
    @Environment(AppRouter.self) private var router
    @Query private var ingredients: [Ingredient]

    private var toBuyCount: Int {
        ingredients.filter { ($0.mealCount > 0 || $0.isOnShoppingList) && !$0.inPantry }.count
    }

    var body: some View {
        @Bindable var router = router
        TabView(selection: $router.selectedTab) {
            Tab("Today & Plan", systemImage: "calendar", value: AppTab.plan) {
                MealPlanView()
            }
            Tab("Smart Shop", systemImage: "cart.fill", value: AppTab.shop) {
                GroceryListView()
            }
            .badge(toBuyCount)
            Tab("Fridge & Recipes", systemImage: "refrigerator.fill", value: AppTab.recipes) {
                RecipesView()
            }
            Tab("Toddler Tracker", systemImage: "face.smiling.fill", value: AppTab.tracker) {
                ToddlerTrackerView()
            }
        }
        .tint(.sage)
    }
}

#Preview(traits: .sampleData) {
    ContentView()
        .environment(AppRouter())
}
