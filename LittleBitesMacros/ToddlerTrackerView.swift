import SwiftData
import SwiftUI

/// Toddlers often need 10–15 neutral exposures before accepting a new food.
private let exposureGoal = 15

// MARK: - Toddler Food Exposure & Safety

struct ToddlerTrackerView: View {
    @Environment(\.modelContext) private var context
    @Query private var children: [ChildProfile]
    @Query(sort: \Ingredient.name) private var ingredients: [Ingredient]
    @Query(sort: \MealPlanDay.dayIndex) private var days: [MealPlanDay]

    @State private var section: TrackerSection = .exposures
    @State private var loggingIngredient: Ingredient?
    @State private var editingProfile = false
    @State private var addingSafeFood = false
    @State private var rebalanceMessage: String?

    enum TrackerSection: String, CaseIterable, Identifiable {
        case exposures = "Exposures"
        case safeFoods = "Safe Foods"
        case safety = "Safety Guide"
        var id: String { rawValue }
    }

    private var child: ChildProfile? { children.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let child {
                        ChildHeaderCard(child: child) { editingProfile = true }
                        Picker("Section", selection: $section.animation(.snappy)) {
                            ForEach(TrackerSection.allCases) { Text($0.rawValue).tag($0) }
                        }
                        .pickerStyle(.segmented)

                        switch section {
                        case .exposures: exposuresSection(child)
                        case .safeFoods: safeFoodsSection(child)
                        case .safety: SafetyGuideSection(child: child)
                        }
                    } else {
                        ContentUnavailableView {
                            Label("No Child Profile", systemImage: "face.smiling")
                        } description: {
                            Text("Add your little one to start tracking food exposures.")
                        } actions: {
                            Button("Add Child", action: createChild)
                                .buttonStyle(.borderedProminent)
                                .tint(.sage)
                        }
                    }
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("Toddler Tracker")
            .sheet(item: $loggingIngredient) { ingredient in
                if let child { ExposureLogSheet(ingredient: ingredient, child: child) }
            }
            .sheet(isPresented: $editingProfile) {
                if let child { ChildProfileEditor(child: child) }
            }
            .sheet(isPresented: $addingSafeFood) {
                if let child { SafeFoodPicker(child: child, ingredients: ingredients) }
            }
        }
    }

    private func createChild() {
        let birthDate = Calendar.current.date(byAdding: .month, value: -36, to: .now) ?? .now
        let newChild = ChildProfile(name: "Your Little One", birthDate: birthDate)
        context.insert(newChild)
        editingProfile = true
    }

    // MARK: Exposures

    /// Foods from the plan the child doesn't reliably eat yet, plus anything already being logged.
    private func journeyFoods(for child: ChildProfile) -> [Ingredient] {
        let loggedIDs = Set((child.exposureLogs ?? []).compactMap { $0.ingredient?.id })
        return ingredients
            .filter { !child.isSafeFood($0) && ($0.mealCount > 0 || loggedIDs.contains($0.id)) }
            .sorted { lhs, rhs in
                let l = child.logs(for: lhs).first?.date ?? .distantPast
                let r = child.logs(for: rhs).first?.date ?? .distantPast
                return l == r ? lhs.name < rhs.name : l > r
            }
    }

    private func todaysNewFoods(for child: ChildProfile) -> [Ingredient] {
        let today = days.first { Calendar.current.isDateInToday($0.date) } ?? days.first
        let foods = today?.sortedMeals.flatMap { $0.sortedIngredients } ?? []
        var seen = Set<UUID>()
        return foods.filter { !child.isSafeFood($0) && seen.insert($0.id).inserted }
    }

    @ViewBuilder
    private func exposuresSection(_ child: ChildProfile) -> some View {
        let logs = child.exposureLogs ?? []
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now
        let journey = journeyFoods(for: child)

        HStack(spacing: 12) {
            statTile("\(logs.filter { $0.date >= weekAgo }.count)", "Exposures\nthis week", .sage)
            statTile("\(Set(logs.compactMap { $0.ingredient?.id }).count)", "Foods\nexplored", .apricot)
            statTile("\(Set(logs.filter { $0.reaction == .accepted }.compactMap { $0.ingredient?.id }).count)", "Foods\nloved", .caution)
        }

        let todays = todaysNewFoods(for: child)
        if !todays.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("On Today's Plate")
                    .font(.headline)
                Text("Tap a food after the meal to log what happened. No pressure — every look counts.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                FlowLayout(spacing: 8) {
                    ForEach(todays) { food in
                        Button { loggingIngredient = food } label: {
                            Chip(food.name, symbol: "plus.circle.fill", tint: .sage)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .card()
        }

        VStack(alignment: .leading, spacing: 4) {
            Text("New Food Journey")
                .font(.headline)
            Text("The 15-exposure rule: neutral, repeated offers build familiarity.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }

        if journey.isEmpty {
            ContentUnavailableView("Nothing to Track", systemImage: "fork.knife",
                                   description: Text("New foods from your meal plan will show up here."))
        } else {
            LazyVStack(spacing: 10) {
                ForEach(journey) { food in
                    Button { loggingIngredient = food } label: {
                        ExposureProgressRow(ingredient: food, logs: child.logs(for: food))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func statTile(_ value: String, _ title: String, _ tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.title.weight(.bold))
                .foregroundStyle(tint)
                .contentTransition(.numericText())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .card(padding: 12)
    }

    // MARK: Safe Foods

    @ViewBuilder
    private func safeFoodsSection(_ child: ChildProfile) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Division of Responsibility", systemImage: "hand.raised.fingers.spread.fill")
                .font(.headline)
                .foregroundStyle(Color.sage)
            Text("You decide what, when and where food is served. Your child decides whether to eat and how much. Every meal in the plan includes at least one safe food so there's always something familiar on the plate.")
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
        .card()

        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Safe Foods").font(.headline)
                Spacer()
                Button("Add", systemImage: "plus") { addingSafeFood = true }
                    .buttonStyle(.bordered)
                    .tint(.sage)
            }
            let safeFoods = (child.safeFoods ?? []).sorted { $0.name < $1.name }
            if safeFoods.isEmpty {
                Text("Add foods your child reliably eats, like banana, toast strips or cheddar.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            ForEach(safeFoods) { food in
                HStack {
                    Image(systemName: "checkmark.shield.fill").foregroundStyle(Color.sage)
                    Text(food.name)
                    if !Set(food.allergens).isDisjoint(with: child.allergies) {
                        Chip("Allergen", symbol: "allergens", tint: .caution)
                    }
                    Spacer()
                    Button {
                        withAnimation(.snappy) { child.safeFoods?.removeAll { $0.id == food.id } }
                    } label: {
                        Image(systemName: "minus.circle.fill").foregroundStyle(Color.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Remove \(food.name)")
                }
                .padding(.vertical, 2)
            }

            Button {
                let changed = SafeFoodPlanner.guarantee(days: days, child: child)
                rebalanceMessage = changed == 0
                    ? "Every meal already has a safe food."
                    : "Added a safe food to \(changed) meal\(changed == 1 ? "" : "s")."
            } label: {
                Label("Check Meal Plan for Safe Foods", systemImage: "wand.and.stars")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.sage)
            .padding(.top, 4)

            if let rebalanceMessage {
                Text(rebalanceMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .card()
        .sensoryFeedback(.success, trigger: rebalanceMessage)

        VStack(alignment: .leading, spacing: 10) {
            Text("Texture Preferences").font(.headline)
            Text("Used to tag and filter meals by sensory preference.")
                .font(.caption)
                .foregroundStyle(.secondary)
            FlowLayout(spacing: 8) {
                ForEach(TextureType.allCases) { texture in
                    let isOn = child.texturePreferences.contains(texture)
                    FilterPill(title: texture.title, symbol: texture.symbol, isOn: isOn) {
                        withAnimation(.snappy) {
                            if isOn { child.texturePreferences.removeAll { $0 == texture } }
                            else { child.texturePreferences.append(texture) }
                        }
                    }
                }
            }
        }
        .card()
    }
}

// MARK: - Child Header

private struct ChildHeaderCard: View {
    let child: ChildProfile
    let onEdit: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "face.smiling.inverse")
                .font(.system(size: 40))
                .foregroundStyle(Color.apricot)
            VStack(alignment: .leading, spacing: 4) {
                Text(child.name).font(.title3.weight(.bold))
                Text("\(child.ageDescription) · \(child.safeFoods?.count ?? 0) safe foods")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if !child.allergies.isEmpty {
                    Text("Allergies: \(child.allergies.map(\.label).formatted(.list(type: .and)))")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.caution)
                }
            }
            Spacer()
            Button("Edit", action: onEdit)
                .buttonStyle(.bordered)
                .tint(.sage)
        }
        .card()
    }
}

// MARK: - Exposure Progress Row

private struct ExposureProgressRow: View {
    let ingredient: Ingredient
    let logs: [FoodExposureLog]

    var body: some View {
        let count = logs.count
        let best = logs.map(\.reaction).max()
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(ingredient.name)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                    Spacer()
                    Text("\(min(count, exposureGoal))/\(exposureGoal)")
                        .font(.caption.weight(.bold))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
                ProgressView(value: Double(min(count, exposureGoal)), total: Double(exposureGoal))
                    .tint(count >= exposureGoal ? Color.sage : Color.apricot)
                HStack(spacing: 6) {
                    ForEach(ExposureStage.allCases) { stage in
                        Image(systemName: stage.symbol)
                            .imageScale(.small)
                            .foregroundStyle(best.map { stage <= $0 } == true ? Color.sage : Color.secondary.opacity(0.4))
                    }
                    Spacer()
                    if let last = logs.first {
                        Text(last.date, format: .relative(presentation: .named))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.tertiary)
        }
        .card(padding: 14)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(ingredient.name), \(count) of \(exposureGoal) exposures, best reaction \(best?.label ?? "none yet")")
    }
}

// MARK: - Log Sheet

struct ExposureLogSheet: View {
    let ingredient: Ingredient
    let child: ChildProfile
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var note = ""
    @State private var loggedCount = 0

    private var logs: [FoodExposureLog] { child.logs(for: ingredient) }

    private var encouragement: String {
        switch logs.count {
        case 0: "First exposure! Just having it on the plate counts."
        case 1..<5: "Great start. Keep offering it calmly alongside a safe food."
        case 5..<10: "Familiarity is building. Try a new shape or a dip."
        case 10..<exposureGoal: "Almost there. Many kids accept a food around now."
        default: "15+ exposures. Consider making this a safe food!"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(min(logs.count, exposureGoal)) of \(exposureGoal) exposures")
                            .font(.headline)
                            .contentTransition(.numericText())
                        ProgressView(value: Double(min(logs.count, exposureGoal)), total: Double(exposureGoal))
                            .tint(.sage)
                        Text(encouragement)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .card()

                    if let hazard = ingredient.hazard {
                        let guidance = SafetyEngine.guidance(for: hazard, ageInMonths: child.ageInMonths)
                        if guidance.level != .ok {
                            SafetyCalloutRow(callout: SafetyCallout(id: ingredient.id.uuidString, ingredientName: ingredient.name,
                                                                    hazard: hazard, guidance: guidance))
                        }
                    }

                    Text("What happened?").font(.headline)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(ExposureStage.allCases) { stage in
                            Button { log(stage) } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: stage.symbol).font(.title)
                                    Text(stage.label).font(.subheadline.weight(.semibold))
                                }
                                .frame(maxWidth: .infinity, minHeight: 92)
                                .foregroundStyle(stage == .accepted ? Color.white : Color.sage)
                                .background(stage == .accepted ? Color.sage : Color.sage.opacity(0.12),
                                            in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    TextField("Optional note (e.g. \"liked it with ketchup\")", text: $note, axis: .vertical)
                        .textFieldStyle(.roundedBorder)

                    if !child.isSafeFood(ingredient), logs.count >= exposureGoal || logs.filter({ $0.reaction == .accepted }).count >= 2 {
                        Button {
                            withAnimation(.snappy) { child.safeFoods?.append(ingredient) }
                        } label: {
                            Label("Promote to Safe Food", systemImage: "checkmark.shield.fill")
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.apricot)
                    }

                    if !logs.isEmpty {
                        Text("History").font(.headline)
                        ForEach(logs) { entry in
                            HStack {
                                Image(systemName: entry.reaction.symbol).foregroundStyle(Color.sage)
                                VStack(alignment: .leading) {
                                    Text(entry.reaction.label).font(.subheadline.weight(.semibold))
                                    if !entry.note.isEmpty {
                                        Text(entry.note).font(.caption).foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                Text(entry.date, format: .dateTime.month(.abbreviated).day().hour().minute())
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Button {
                                    withAnimation { context.delete(entry) }
                                } label: {
                                    Image(systemName: "trash").foregroundStyle(Color.secondary)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Delete entry")
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle(ingredient.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
            .sensoryFeedback(.success, trigger: loggedCount)
        }
    }

    private func log(_ stage: ExposureStage) {
        let entry = FoodExposureLog(reaction: stage, note: note.trimmingCharacters(in: .whitespacesAndNewlines))
        context.insert(entry)
        entry.ingredient = ingredient
        entry.child = child
        withAnimation(.snappy) { loggedCount += 1 }
        note = ""
    }
}

// MARK: - Safety Guide

private struct SafetyGuideSection: View {
    let child: ChildProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Choking-Hazard Prep for \(child.ageDescription)")
                    .font(.headline)
                Text("Guidance adapts automatically as \(child.name) grows. Recipes and cooking mode use the same rules.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(ChokingHazard.allCases) { hazard in
                let guidance = SafetyEngine.guidance(for: hazard, ageInMonths: child.ageInMonths)
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: hazard.symbol)
                        .font(.title3)
                        .foregroundStyle(guidance.level.color)
                        .frame(width: 32)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(hazard.title).font(.subheadline.weight(.bold))
                            Spacer()
                            Chip(guidance.level.label, symbol: guidance.level.symbol, tint: guidance.level.color)
                        }
                        Text(hazard.examples)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(guidance.instruction)
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .card(padding: 14)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Always").font(.headline)
                ForEach([
                    "Seat your child upright at the table for every meal and snack.",
                    "Stay within arm's reach and watch while they eat.",
                    "No eating in the car, while walking, or while playing.",
                    "Learn infant and child CPR.",
                ], id: \.self) { rule in
                    Label(rule, systemImage: "checkmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(Color.primary)
                }
                Text("This is general guidance, not medical advice. Talk to your pediatrician about your child's needs.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
            .card()
        }
    }
}

// MARK: - Profile Editor

private struct ChildProfileEditor: View {
    @Bindable var child: ChildProfile
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Child") {
                    TextField("Name", text: $child.name)
                    DatePicker("Birthday", selection: $child.birthDate, in: ...Date.now, displayedComponents: .date)
                    LabeledContent("Age", value: child.ageDescription)
                }
                Section {
                    ForEach(Allergen.allCases) { allergen in
                        Toggle(allergen.label, isOn: Binding(
                            get: { child.allergies.contains(allergen) },
                            set: { isOn in
                                if isOn { child.allergies.append(allergen) }
                                else { child.allergies.removeAll { $0 == allergen } }
                            }
                        ))
                        .tint(.caution)
                    }
                } header: {
                    Text("Allergies")
                } footer: {
                    Text("Meals containing these allergens are flagged, and they're never added as safe foods.")
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
    }
}

// MARK: - Safe Food Picker

private struct SafeFoodPicker: View {
    let child: ChildProfile
    let ingredients: [Ingredient]
    @Environment(\.dismiss) private var dismiss
    @State private var search = ""

    private var candidates: [Ingredient] {
        ingredients.filter {
            !child.isSafeFood($0) && (search.isEmpty || $0.name.localizedCaseInsensitiveContains(search))
        }
    }

    var body: some View {
        NavigationStack {
            List(candidates) { food in
                Button {
                    child.safeFoods?.append(food)
                    dismiss()
                } label: {
                    HStack {
                        Label(food.name, systemImage: food.category.symbol)
                        Spacer()
                        if !Set(food.allergens).isDisjoint(with: child.allergies) {
                            Chip("Allergen", tint: .caution)
                        }
                    }
                }
                .foregroundStyle(Color.primary)
            }
            .searchable(text: $search, prompt: "Search foods")
            .navigationTitle("Add Safe Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
    }
}

#Preview(traits: .sampleData) {
    ToddlerTrackerView()
}
