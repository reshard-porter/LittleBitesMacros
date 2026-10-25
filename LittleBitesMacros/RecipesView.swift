import SwiftData
import SwiftUI

// MARK: - Fridge & Recipes Tab

struct RecipesView: View {
    @State private var showForager = false

    var body: some View {
        NavigationStack {
            RecipeLibraryBrowser(target: nil) {
                foragerBanner
            }
            .navigationTitle("Fridge & Recipes")
            .sheet(isPresented: $showForager) { FridgeForagerView() }
        }
    }

    private var foragerBanner: some View {
        Button { showForager = true } label: {
            HStack(spacing: 14) {
                Image(systemName: "refrigerator.fill")
                    .font(.largeTitle)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Fridge Forager")
                        .font(.headline)
                    Text("Pick up to 3 things in your fridge. Get toddler-safe meals in under 15 minutes.")
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
            }
            .foregroundStyle(Color.white)
            .padding(18)
            .background(
                LinearGradient(colors: [.sage, .sage.opacity(0.75)], startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 22, style: .continuous)
            )
        }
        .buttonStyle(.plain)
    }
}

/// Where a picked recipe should go, when the library is opened from a plan slot.
struct PlanTarget: Identifiable, Hashable {
    let dayIndex: Int
    let slot: MealSlot
    var id: String { "\(dayIndex)-\(slot.rawValue)" }
}

// MARK: - Library Browser

struct RecipeLibraryBrowser<Header: View>: View {
    let target: PlanTarget?
    var onPlaced: (() -> Void)?
    @ViewBuilder var header: () -> Header

    @Environment(\.modelContext) private var context
    @Query private var favorites: [FavoriteRecipe]
    @Query private var children: [ChildProfile]

    @State private var search = ""
    @State private var slotFilter: SlotFilter
    @State private var filters: Set<RecipeFilter> = []
    @State private var cuisine: String?
    @State private var sort: RecipeSort = .alphabetical
    @State private var selected: LibraryRecipe?
    @State private var favoriteToggles = 0

    private let library = RecipeLibrary.shared

    init(target: PlanTarget?, onPlaced: (() -> Void)? = nil, @ViewBuilder header: @escaping () -> Header) {
        self.target = target
        self.onPlaced = onPlaced
        self.header = header
        _slotFilter = State(initialValue: target.map { SlotFilter(slot: $0.slot) } ?? .all)
    }

    enum SlotFilter: String, CaseIterable, Identifiable {
        case all = "All", breakfast = "Breakfast", snacks = "Snacks", lunch = "Lunch", dinner = "Dinner"
        var id: String { rawValue }

        init(slot: MealSlot) {
            switch slot {
            case .breakfast: self = .breakfast
            case .morningSnack, .afternoonSnack: self = .snacks
            case .lunch: self = .lunch
            case .dinner: self = .dinner
            }
        }

        func matches(_ recipe: LibraryRecipe) -> Bool {
            switch self {
            case .all: true
            case .breakfast: recipe.slots.contains(.breakfast)
            case .snacks: recipe.isSnack
            case .lunch: recipe.slots.contains(.lunch)
            case .dinner: recipe.slots.contains(.dinner)
            }
        }
    }

    enum RecipeFilter: String, CaseIterable, Identifiable {
        case favorites = "Favorites"
        case allergySafe = "Allergy-Safe"
        case quick = "Under 15 mins"
        case leftover = "Leftover Friendly"
        case finger = "Finger Food"
        case highProtein = "High Protein"
        case iron = "High Iron"

        var id: String { rawValue }

        var symbol: String {
            switch self {
            case .favorites: "heart.fill"
            case .allergySafe: "checkmark.shield"
            case .quick: "clock"
            case .leftover: "arrow.triangle.branch"
            case .finger: "hand.raised.fill"
            case .highProtein: "bolt.heart.fill"
            case .iron: "drop.fill"
            }
        }
    }

    enum RecipeSort: String, CaseIterable, Identifiable {
        case alphabetical = "A–Z"
        case quickest = "Quickest"
        case protein = "Most Protein"
        case iron = "Most Iron"
        var id: String { rawValue }
    }

    private var child: ChildProfile? { children.first }
    private var favoriteIDs: Set<String> { Set(favorites.map(\.recipeID)) }

    private var results: [LibraryRecipe] {
        let favs = favoriteIDs
        let blocked = Set(child?.allergies ?? [])
        let filtered = library.browsable.filter { recipe in
            guard slotFilter.matches(recipe) else { return false }
            if let cuisine, recipe.cuisine != cuisine { return false }
            for filter in filters {
                switch filter {
                case .favorites: if !favs.contains(recipe.id) { return false }
                case .allergySafe: if !library.allergens(for: recipe).isDisjoint(with: blocked) { return false }
                case .quick: if recipe.prepTimeMinutes > 15 { return false }
                case .leftover: if !recipe.batchFriendly { return false }
                case .finger: if !recipe.textures.contains(.fingerFood) { return false }
                case .highProtein: if recipe.macros.proteinGrams < 15 { return false }
                case .iron: if recipe.macros.ironMilligrams < 2 { return false }
                }
            }
            return search.isEmpty || library.matches(recipe, search: search)
        }
        switch sort {
        case .alphabetical: return filtered
        case .quickest: return filtered.sorted { $0.prepTimeMinutes < $1.prepTimeMinutes }
        case .protein: return filtered.sorted { $0.macros.proteinGrams > $1.macros.proteinGrams }
        case .iron: return filtered.sorted { $0.macros.ironMilligrams > $1.macros.ironMilligrams }
        }
    }

    var body: some View {
        let results = self.results
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                header()

                Picker("Meal", selection: $slotFilter.animation(.snappy)) {
                    ForEach(SlotFilter.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(RecipeFilter.allCases) { filter in
                            FilterPill(title: filter.rawValue, symbol: filter.symbol, isOn: filters.contains(filter)) {
                                withAnimation(.snappy) {
                                    if filters.contains(filter) { filters.remove(filter) } else { filters.insert(filter) }
                                }
                            }
                        }
                    }
                }

                HStack {
                    Text("\(results.count) recipes")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .contentTransition(.numericText())
                    Spacer()
                    Menu {
                        Picker("Cuisine", selection: $cuisine) {
                            Text("All Cuisines").tag(String?.none)
                            ForEach(library.cuisines, id: \.self) { Text($0).tag(String?.some($0)) }
                        }
                    } label: {
                        Label(cuisine ?? "Cuisine", systemImage: "globe")
                            .font(.subheadline)
                    }
                    Menu {
                        Picker("Sort", selection: $sort) {
                            ForEach(RecipeSort.allCases) { Text($0.rawValue).tag($0) }
                        }
                    } label: {
                        Label(sort.rawValue, systemImage: "arrow.up.arrow.down")
                            .font(.subheadline)
                    }
                }
                .tint(.sage)

                if results.isEmpty {
                    ContentUnavailableView("No Matching Recipes", systemImage: "magnifyingglass",
                                           description: Text("Try removing a filter or searching for an ingredient."))
                } else {
                    ForEach(results) { recipe in
                        Button { selected = recipe } label: {
                            LibraryRecipeRow(
                                recipe: recipe,
                                isFavorite: favoriteIDs.contains(recipe.id),
                                allergenConflicts: library.allergens(for: recipe).intersection(child?.allergies ?? []),
                                onToggleFavorite: { toggleFavorite(recipe) }
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        .background(Color.appBackground)
        .searchable(text: $search, prompt: "Search 400+ recipes or ingredients")
        .sheet(item: $selected) { recipe in
            LibraryRecipeDetailView(recipe: recipe, target: target, onPlaced: onPlaced)
        }
        .sensoryFeedback(.selection, trigger: filters)
        .sensoryFeedback(.success, trigger: favoriteToggles)
    }

    private func toggleFavorite(_ recipe: LibraryRecipe) {
        withAnimation(.snappy) {
            if let existing = favorites.first(where: { $0.recipeID == recipe.id }) {
                context.delete(existing)
            } else {
                context.insert(FavoriteRecipe(recipeID: recipe.id))
                favoriteToggles += 1
            }
        }
    }
}

extension RecipeLibraryBrowser where Header == EmptyView {
    init(target: PlanTarget?, onPlaced: (() -> Void)? = nil) {
        self.init(target: target, onPlaced: onPlaced) { EmptyView() }
    }
}

// MARK: - Row

private struct LibraryRecipeRow: View {
    let recipe: LibraryRecipe
    let isFavorite: Bool
    let allergenConflicts: Set<Allergen>
    let onToggleFavorite: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Label(recipe.slots.map(\.shortTitle).uniqued().joined(separator: " · "), systemImage: recipe.primarySlot.symbol)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.sage)
                    Text(recipe.title)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Button(action: onToggleFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundStyle(isFavorite ? Color.caution : Color.secondary)
                        .contentTransition(.symbolEffect(.replace))
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
            }
            FlowLayout(spacing: 6) {
                Chip("\(recipe.prepTimeMinutes) min", symbol: "clock", tint: .secondary)
                Chip("\(Int(recipe.macros.proteinGrams))g protein", symbol: "bolt.heart.fill", tint: .sage)
                Chip("\(recipe.macros.ironMilligrams.formatted(.number.precision(.fractionLength(1))))mg iron", symbol: "drop.fill", tint: .caution)
                Chip(recipe.cuisine, symbol: "globe", tint: .secondary)
                if recipe.batchFriendly {
                    Chip("Leftover Friendly", symbol: "arrow.triangle.branch", tint: .apricot)
                }
            }
            if !allergenConflicts.isEmpty {
                Label("Contains \(allergenConflicts.map(\.label).sorted().formatted(.list(type: .and)))", systemImage: "allergens")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.caution)
            }
        }
        .card()
    }
}

extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

// MARK: - Recipe Detail

struct LibraryRecipeDetailView: View {
    let recipe: LibraryRecipe
    let target: PlanTarget?
    var onPlaced: (() -> Void)?

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var children: [ChildProfile]
    @Query(sort: \MealPlanDay.dayIndex) private var days: [MealPlanDay]
    @Query private var pantryItems: [Ingredient]

    @State private var showAddSheet = false
    @State private var didPlace = false

    private let library = RecipeLibrary.shared
    private var child: ChildProfile? { children.first }
    private var ageInMonths: Int { child?.ageInMonths ?? 36 }

    private var inPantryKeys: Set<String> {
        Set(pantryItems.filter(\.inPantry).compactMap(\.catalogKey))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    macros
                    let conflicts = library.allergens(for: recipe).intersection(child?.allergies ?? [])
                    if !conflicts.isEmpty {
                        Label("Contains \(conflicts.map(\.label).sorted().formatted(.list(type: .and))), which is on \(child?.name ?? "your child")'s allergy list.",
                              systemImage: "allergens")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.caution)
                            .card()
                    }
                    ingredientList
                    stepList
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
            .safeAreaInset(edge: .bottom) {
                Button(action: addTapped) {
                    Label(addButtonTitle, systemImage: "calendar.badge.plus")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 52)
                }
                .buttonStyle(.borderedProminent)
                .tint(.sage)
                .padding(.horizontal)
                .padding(.bottom, 8)
                .background(.bar)
            }
            .sheet(isPresented: $showAddSheet, onDismiss: {
                if didPlace { dismiss() }
            }) {
                AddToPlanSheet(recipe: recipe, days: days, child: child) { didPlace = true }
            }
            .sensoryFeedback(.success, trigger: didPlace)
        }
    }

    private var addButtonTitle: String {
        guard let target else { return "Add to Meal Plan" }
        return "Use for Day \(target.dayIndex) \(target.slot.title)"
    }

    private func addTapped() {
        guard let target, let day = days.first(where: { $0.dayIndex == target.dayIndex }) else {
            showAddSheet = true
            return
        }
        PlanBuilder.place(recipe, in: day, slot: target.slot, child: child, context: context)
        didPlace = true
        if let onPlaced { onPlaced() } else { dismiss() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(recipe.slots.map(\.title).uniqued().joined(separator: " · "), systemImage: recipe.primarySlot.symbol)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.sage)
            Text(recipe.title)
                .font(.title2.weight(.bold))
            FlowLayout(spacing: 6) {
                Chip("\(recipe.prepTimeMinutes) min", symbol: "clock", tint: .secondary)
                Chip(recipe.cuisine, symbol: "globe", tint: .secondary)
                if recipe.batchFriendly { Chip("Leftover Friendly", symbol: "arrow.triangle.branch", tint: .apricot) }
                ForEach(recipe.textures) { Chip($0.title, symbol: $0.symbol, tint: .secondary) }
            }
        }
    }

    private var macros: some View {
        HStack(spacing: 10) {
            macroTile("Protein", "\(Int(recipe.macros.proteinGrams))g", .sage)
            macroTile("Fats", "\(Int(recipe.macros.healthyFatGrams))g", .apricot)
            macroTile("Carbs", "\(Int(recipe.macros.complexCarbGrams))g", .secondary)
            macroTile("Iron", "\(recipe.macros.ironMilligrams.formatted(.number.precision(.fractionLength(1))))mg", .caution)
        }
    }

    private func macroTile(_ title: String, _ value: String, _ tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value).font(.headline).foregroundStyle(tint).minimumScaleFactor(0.7).lineLimit(1)
            Text(title).font(.caption2).foregroundStyle(.secondary)
        }
        .card(padding: 10)
    }

    private var ingredientList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ingredients").font(.headline)
            ForEach(library.ingredients(for: recipe)) { item in
                HStack(spacing: 10) {
                    Image(systemName: item.category.symbol)
                        .foregroundStyle(Color.sage)
                        .frame(width: 24)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                        if let note = item.toddlerSafetyNote {
                            Text(note).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    if inPantryKeys.contains(item.key) {
                        Label("In pantry", systemImage: "refrigerator.fill")
                            .labelStyle(.iconOnly)
                            .foregroundStyle(Color.sage)
                    }
                }
            }
        }
        .card()
    }

    private var stepList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Toddler Prep for \(child?.name ?? "Your Child") (\(child?.ageDescription ?? "3 yrs"))")
                .font(.headline)
            ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 10) {
                    Text("\(index + 1)")
                        .font(.caption.weight(.bold))
                        .frame(width: 24, height: 24)
                        .background(Color.sage.opacity(0.15), in: Circle())
                        .foregroundStyle(Color.sage)
                    Text(step).fixedSize(horizontal: false, vertical: true)
                }
            }
            ForEach(library.safetyCallouts(for: recipe, ageInMonths: ageInMonths)) { SafetyCalloutRow(callout: $0) }
        }
        .card()
    }
}

// MARK: - Add to Plan

struct AddToPlanSheet: View {
    let recipe: LibraryRecipe
    let days: [MealPlanDay]
    let child: ChildProfile?
    let onPlaced: () -> Void

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var dayIndex: Int
    @State private var slot: MealSlot
    @State private var planLeftovers: Bool

    init(recipe: LibraryRecipe, days: [MealPlanDay], child: ChildProfile?, onPlaced: @escaping () -> Void) {
        self.recipe = recipe
        self.days = days
        self.child = child
        self.onPlaced = onPlaced
        let today = days.first { Calendar.current.isDateInToday($0.date) }?.dayIndex ?? days.first?.dayIndex ?? 1
        _dayIndex = State(initialValue: today)
        _slot = State(initialValue: recipe.primarySlot)
        _planLeftovers = State(initialValue: recipe.batchFriendly && recipe.primarySlot == .dinner)
    }

    private var selectedDay: MealPlanDay? { days.first { $0.dayIndex == dayIndex } }
    private var nextDay: MealPlanDay? { days.first { $0.dayIndex == dayIndex + 1 } }
    private var canChainLeftovers: Bool { slot == .dinner && nextDay != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("When") {
                    Picker("Day", selection: $dayIndex) {
                        ForEach(days) { day in
                            Text("Day \(day.dayIndex) · \(day.date.formatted(.dateTime.weekday(.abbreviated).day()))")
                                .tag(day.dayIndex)
                        }
                    }
                    Picker("Meal", selection: $slot) {
                        ForEach(MealSlot.allCases) { Label($0.title, systemImage: $0.symbol).tag($0) }
                    }
                }

                if canChainLeftovers {
                    Section {
                        Toggle(isOn: $planLeftovers) {
                            Label("Cook Once, Serve Twice", systemImage: "arrow.triangle.branch")
                        }
                        .tint(.sage)
                    } footer: {
                        Text("Also plans leftovers for Day \(dayIndex + 1) lunch and adds a reminder to cook extra.")
                    }
                }

                if let existing = selectedDay?.sortedMeals.first(where: { $0.mealSlot == slot }) {
                    Section("This Replaces") {
                        Label(existing.title, systemImage: "arrow.2.squarepath")
                            .foregroundStyle(.secondary)
                    }
                }

                if !slot.matches(recipe) {
                    Section {
                        Label("This recipe is usually served for \(recipe.primarySlot.title.lowercased()).", systemImage: "info.circle")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Add to Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        guard let day = selectedDay else { return }
                        PlanBuilder.place(
                            recipe, in: day, slot: slot,
                            leftoversFor: canChainLeftovers && planLeftovers ? nextDay : nil,
                            child: child, context: context
                        )
                        onPlaced()
                        dismiss()
                    }
                    .disabled(selectedDay == nil)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

private extension MealSlot {
    func matches(_ recipe: LibraryRecipe) -> Bool { recipe.slots.contains(self) }
}

// MARK: - Fridge Forager

struct FridgeForagerView: View {
    @Query(sort: \Ingredient.name) private var ingredients: [Ingredient]
    @Query private var children: [ChildProfile]
    @Environment(\.dismiss) private var dismiss
    @State private var picks: [Ingredient] = []
    @State private var selectedRecipe: LibraryRecipe?
    @State private var pantryOnly = false
    @State private var search = ""

    private let maxPicks = 3
    private var child: ChildProfile? { children.first }

    private var choices: [Ingredient] {
        ingredients.filter {
            (!pantryOnly || $0.inPantry) && (search.isEmpty || $0.name.localizedCaseInsensitiveContains(search))
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if !picks.isEmpty {
                        FlowLayout(spacing: 8) {
                            ForEach(picks) { item in
                                FilterPill(title: item.name, symbol: "xmark.circle.fill", isOn: true) {
                                    withAnimation(.snappy) { toggle(item) }
                                }
                            }
                        }
                    }

                    if let idea = FridgeForager.plate(
                        from: picks,
                        ageInMonths: child?.ageInMonths ?? 36,
                        safeFood: child.flatMap { SafeFoodPlanner.eligibleSafeFoods(for: $0).first }
                    ) {
                        plateCard(idea)
                    }

                    let matches = FridgeForager.matches(for: picks, in: RecipeLibrary.shared, avoiding: child?.allergies ?? [])
                    if !matches.isEmpty {
                        Text("Quick Recipes That Use Them").font(.headline)
                        ForEach(matches) { match in
                            Button { selectedRecipe = match.recipe } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(match.recipe.title).font(.subheadline.weight(.semibold))
                                    Text("Uses \(match.matchedNames.formatted(.list(type: .and))) · \(match.recipe.prepTimeMinutes) min")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .card(padding: 14)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Text(picks.count < maxPicks ? "Choose up to \(maxPicks - picks.count) more" : "Ready! Remove one to swap")
                        .font(.headline)
                    Toggle("Only show what's in my pantry", isOn: $pantryOnly.animation(.snappy))
                        .tint(.sage)
                        .font(.subheadline)

                    FlowLayout(spacing: 8) {
                        ForEach(choices) { item in
                            let isPicked = picks.contains { $0.id == item.id }
                            FilterPill(title: item.name, symbol: item.inPantry ? "refrigerator.fill" : nil, isOn: isPicked) {
                                withAnimation(.snappy) { toggle(item) }
                            }
                            .disabled(!isPicked && picks.count >= maxPicks)
                            .opacity(!isPicked && picks.count >= maxPicks ? 0.4 : 1)
                        }
                    }
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("Fridge Forager")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $search, prompt: "Find an ingredient")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
            .sheet(item: $selectedRecipe) { LibraryRecipeDetailView(recipe: $0, target: nil) }
            .sensoryFeedback(.selection, trigger: picks.count)
        }
    }

    private func toggle(_ item: Ingredient) {
        if let index = picks.firstIndex(where: { $0.id == item.id }) {
            picks.remove(at: index)
        } else if picks.count < maxPicks {
            picks.append(item)
        }
    }

    private func plateCard(_ idea: FridgeForager.PlateIdea) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Quick Plate", systemImage: "sparkles")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.apricot)
                Spacer()
                Text("~\(idea.minutes) min")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            Text(idea.title).font(.title3.weight(.bold))
            ForEach(Array(idea.steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(index + 1).").font(.subheadline.weight(.bold)).foregroundStyle(Color.sage)
                    Text(step).font(.subheadline).fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .card()
    }
}

#Preview(traits: .sampleData) {
    RecipesView()
}
