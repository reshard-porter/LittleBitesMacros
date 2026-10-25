import SwiftData
import SwiftUI
import UIKit

// MARK: - 5-Day Meal Planner

struct MealPlanView: View {
    @Query(sort: \MealPlanDay.dayIndex) private var days: [MealPlanDay]
    @Query private var children: [ChildProfile]
    @Query private var allMeals: [MealItem]
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var context

    @State private var selectedDayIndex = 1
    @State private var pickerTarget: PlanTarget?
    @State private var confirmNewWeek = false
    @State private var didSelectToday = false
    @State private var showBatchPrep = false
    @State private var detailMeal: MealItem?
    @State private var cookingMeal: MealItem?
    @Namespace private var cookingNamespace

    private var child: ChildProfile? { children.first }
    private var ageInMonths: Int { child?.ageInMonths ?? 36 }
    private var selectedDay: MealPlanDay? { days.first { $0.dayIndex == selectedDayIndex } ?? days.first }

    private var mealsByID: [UUID: MealItem] {
        Dictionary(allMeals.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if days.isEmpty {
                        ContentUnavailableView("No Meal Plan Yet", systemImage: "calendar.badge.plus",
                                               description: Text("Your 5-day plan will appear here."))
                    } else {
                        DayCarousel(days: days, selectedDayIndex: $selectedDayIndex)

                        if let day = selectedDay {
                            NutritionRingsCard(day: day, ageInMonths: ageInMonths)
                            BatchPrepBanner(days: days) { showBatchPrep = true }

                            let mealsBySlot = Dictionary(day.sortedMeals.map { ($0.mealSlot, $0) }, uniquingKeysWith: { first, _ in first })
                            ForEach(MealSlot.allCases) { slot in
                                if let meal = mealsBySlot[slot] {
                                    MealCard(
                                        meal: meal,
                                        child: child,
                                        ageInMonths: ageInMonths,
                                        leftoverFrom: meal.isLeftoverFromMealID.flatMap { mealsByID[$0]?.scheduleLabel },
                                        leftoverFor: meal.spawnsLeftoverForMealID.flatMap { mealsByID[$0]?.scheduleLabel },
                                        onOpen: { detailMeal = meal },
                                        onCook: { cookingMeal = meal }
                                    )
                                    .matchedTransitionSource(id: meal.id, in: cookingNamespace)
                                    .contextMenu {
                                        Button("Choose a Different Recipe…", systemImage: "book") {
                                            pickerTarget = PlanTarget(dayIndex: day.dayIndex, slot: slot)
                                        }
                                        Button("Remove from Plan", systemImage: "trash", role: .destructive) {
                                            withAnimation(.snappy) { PlanBuilder.remove(meal, context: context) }
                                        }
                                    }
                                } else {
                                    EmptySlotCard(slot: slot) {
                                        pickerTarget = PlanTarget(dayIndex: day.dayIndex, slot: slot)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("Today & Plan")
            .toolbar {
                if let child {
                    ToolbarItem(placement: .topBarTrailing) {
                        Label("\(child.name) · \(child.ageDescription)", systemImage: "figure.and.child.holdinghands")
                            .labelStyle(.titleAndIcon)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Color.sage)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button("Restart Plan from Today", systemImage: "arrow.clockwise", action: restartPlan)
                        Button("Build a New Week from Recipes…", systemImage: "wand.and.stars") { confirmNewWeek = true }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(item: $detailMeal) { meal in
                MealDetailView(meal: meal)
            }
            .fullScreenCover(item: $cookingMeal) { meal in
                CookingModeView(meal: meal, ageInMonths: ageInMonths)
                    .navigationTransition(.zoom(sourceID: meal.id, in: cookingNamespace))
            }
            .sheet(isPresented: $showBatchPrep) {
                BatchPrepSheet(days: days)
            }
            .sheet(item: $pickerTarget) { target in
                NavigationStack {
                    RecipeLibraryBrowser(target: target, onPlaced: { pickerTarget = nil })
                        .navigationTitle("Day \(target.dayIndex) \(target.slot.title)")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { pickerTarget = nil } }
                        }
                }
            }
            .confirmationDialog("Build a new week?", isPresented: $confirmNewWeek, titleVisibility: .visible) {
                Button("Replace All 5 Days", role: .destructive) {
                    withAnimation(.snappy) { PlanBuilder.generateWeek(days: days, child: child, context: context) }
                }
            } message: {
                Text("Picks 25 new recipes from the library, skipping \(child?.name ?? "your child")'s allergens and chaining leftovers on days 2 and 4.")
            }
            .onAppear {
                selectToday()
                consumeDeepLink()
            }
            .onChange(of: router.requestedDayIndex) { consumeDeepLink() }
        }
    }

    private func selectToday() {
        guard !didSelectToday else { return }
        didSelectToday = true
        if let today = days.first(where: { Calendar.current.isDateInToday($0.date) }) {
            selectedDayIndex = today.dayIndex
        }
    }

    private func consumeDeepLink() {
        guard let requested = router.requestedDayIndex else { return }
        withAnimation(.snappy) { selectedDayIndex = requested }
        router.requestedDayIndex = nil
    }

    private func restartPlan() {
        let start = Calendar.current.startOfDay(for: .now)
        for day in days {
            day.date = Calendar.current.date(byAdding: .day, value: day.dayIndex - 1, to: start) ?? start
            for task in day.batchPrepTasks ?? [] { task.isDone = false }
        }
        withAnimation(.snappy) { selectedDayIndex = 1 }
        WidgetSnapshotWriter.refresh(context: context)
    }
}

// MARK: - Empty Slot

private struct EmptySlotCard: View {
    let slot: MealSlot
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: slot.symbol)
                    .font(.title3)
                    .foregroundStyle(Color.sage)
                VStack(alignment: .leading, spacing: 2) {
                    Text(slot.title).font(.subheadline.weight(.semibold))
                    Text("Choose from 400+ toddler recipes").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color.sage)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(Color.sage.opacity(0.4), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Day Carousel

private struct DayCarousel: View {
    let days: [MealPlanDay]
    @Binding var selectedDayIndex: Int

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(days) { day in
                    let isSelected = day.dayIndex == selectedDayIndex
                    let hasLeftovers = day.sortedMeals.contains(where: \.isLeftoverFriendly)
                    Button {
                        withAnimation(.snappy) { selectedDayIndex = day.dayIndex }
                    } label: {
                        VStack(spacing: 4) {
                            Text("Day \(day.dayIndex)")
                                .font(.caption2.weight(.bold))
                                .textCase(.uppercase)
                            Text(day.date, format: .dateTime.weekday(.abbreviated))
                                .font(.subheadline.weight(.semibold))
                            Text(day.date, format: .dateTime.day())
                                .font(.title2.weight(.bold))
                            Circle()
                                .fill(hasLeftovers ? Color.apricot : Color.clear)
                                .frame(width: 6, height: 6)
                        }
                        .frame(width: 72, height: 104)
                        .foregroundStyle(isSelected ? Color.white : Color.primary)
                        .background(isSelected ? Color.sage : Color.cardBackground,
                                    in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay {
                            if Calendar.current.isDateInToday(day.date) && !isSelected {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .strokeBorder(Color.sage, lineWidth: 2)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Day \(day.dayIndex), \(day.date.formatted(.dateTime.weekday(.wide)))")
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .sensoryFeedback(.selection, trigger: selectedDayIndex)
    }
}

// MARK: - Nutrition Rings

private struct NutritionRingsCard: View {
    let day: MealPlanDay
    let ageInMonths: Int

    var body: some View {
        let totals = day.totalMacros
        let ironTarget = DailyTargets.ironMilligrams(ageInMonths: ageInMonths)
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Day \(day.dayIndex) Nutrition")
                    .font(.headline)
                Spacer()
                Text("\(Int(totals.proteinGrams))g protein")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.sage)
            }
            HStack(alignment: .top) {
                ProgressRing(
                    title: "Protein\nVariety",
                    valueText: "\(day.proteinVarietyCount)/\(DailyTargets.proteinVarieties)",
                    progress: Double(day.proteinVarietyCount) / Double(DailyTargets.proteinVarieties),
                    tint: .sage
                )
                ProgressRing(
                    title: "Iron",
                    valueText: "\(totals.ironMilligrams.formatted(.number.precision(.fractionLength(1))))mg",
                    progress: totals.ironMilligrams / ironTarget,
                    tint: .caution
                )
                ProgressRing(
                    title: "Healthy\nFats",
                    valueText: "\(Int(totals.healthyFatGrams))g",
                    progress: totals.healthyFatGrams / DailyTargets.healthyFatGrams,
                    tint: .apricot
                )
            }
        }
        .card()
    }
}

// MARK: - Batch Prep

private struct BatchPrepBanner: View {
    let days: [MealPlanDay]
    let action: () -> Void

    var body: some View {
        let tasks = days.flatMap { $0.batchPrepTasks ?? [] }
        let done = tasks.filter(\.isDone).count
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "checklist")
                    .font(.title2)
                    .foregroundStyle(Color.sage)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Batch Prep Checklist")
                        .font(.subheadline.weight(.semibold))
                    ProgressView(value: Double(done), total: Double(max(tasks.count, 1)))
                        .tint(.sage)
                }
                Text("\(done)/\(tasks.count)")
                    .font(.subheadline.weight(.bold))
                    .monospacedDigit()
                Image(systemName: "chevron.up")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .card(padding: 14)
        }
        .buttonStyle(.plain)
    }
}

struct BatchPrepSheet: View {
    let days: [MealPlanDay]
    @Environment(\.dismiss) private var dismiss

    private var doneCount: Int { days.flatMap { $0.batchPrepTasks ?? [] }.filter(\.isDone).count }

    var body: some View {
        NavigationStack {
            List {
                ForEach(days.filter { !($0.batchPrepTasks ?? []).isEmpty }) { day in
                    Section {
                        ForEach(day.sortedTasks) { task in
                            Button {
                                withAnimation(.snappy) { task.isDone.toggle() }
                            } label: {
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                                        .font(.title2)
                                        .foregroundStyle(task.isDone ? Color.sage : Color.secondary)
                                        .contentTransition(.symbolEffect(.replace))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(task.title)
                                            .font(.body.weight(.semibold))
                                            .strikethrough(task.isDone)
                                        Text(task.detail)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    } header: {
                        Text(day.dayIndex == 1
                             ? "Day 1 · Weekend Prep"
                             : "Day \(day.dayIndex) · \(day.date.formatted(.dateTime.weekday(.wide)))")
                    }
                }
            }
            .navigationTitle("Batch Prep")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
            .sensoryFeedback(.success, trigger: doneCount)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Meal Card

struct MealCard: View {
    let meal: MealItem
    let child: ChildProfile?
    let ageInMonths: Int
    let leftoverFrom: String?
    let leftoverFor: String?
    var onOpen: () -> Void
    var onCook: () -> Void

    var body: some View {
        let callouts = SafetyEngine.callouts(for: meal, ageInMonths: ageInMonths)
        let allergens = SafetyEngine.allergenConflicts(in: meal, for: child)

        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(meal.mealSlot.title, systemImage: meal.mealSlot.symbol)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.sage)
                Spacer()
                Label("\(meal.prepTimeMinutes) min", systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(meal.title)
                .font(.headline)
                .multilineTextAlignment(.leading)

            FlowLayout(spacing: 6) {
                if let leftoverFrom {
                    Chip("Leftover from \(leftoverFrom)", symbol: "arrow.uturn.backward.circle.fill", tint: .apricot, filled: true)
                }
                if let leftoverFor {
                    Chip("Cook once → \(leftoverFor)", symbol: "arrow.triangle.branch", tint: .sage, filled: true)
                }
                Chip("\(Int(meal.macros.proteinGrams))g protein", symbol: "bolt.heart.fill", tint: .sage)
                ForEach(meal.textures) { texture in
                    Chip(texture.title, symbol: texture.symbol, tint: .secondary)
                }
            }

            if let child {
                SafeFoodRow(meal: meal, child: child)
            }

            if !allergens.isEmpty {
                Label("Contains \(allergens.map(\.label).formatted(.list(type: .and)))", systemImage: "allergens")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.caution)
            }

            if !callouts.isEmpty {
                VStack(spacing: 6) {
                    ForEach(callouts) { SafetyCalloutRow(callout: $0) }
                }
            }

            HStack {
                Button("Details", action: onOpen)
                    .buttonStyle(.bordered)
                    .tint(.sage)
                Spacer()
                Button(action: onCook) {
                    Label("Cooking Mode", systemImage: "frying.pan.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(.sage)
            }
            .controlSize(.regular)
        }
        .card()
        .contentShape(RoundedRectangle(cornerRadius: 22))
        .onTapGesture(perform: onOpen)
    }
}

/// Shows the meal's guaranteed safe food, or offers one if it's missing.
private struct SafeFoodRow: View {
    let meal: MealItem
    let child: ChildProfile

    var body: some View {
        let present = SafeFoodPlanner.safeFoods(in: meal, for: child)
        if let first = present.first {
            Label("Safe food: \(first.name)", systemImage: "checkmark.shield.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.sage)
        } else {
            let options = SafeFoodPlanner.eligibleSafeFoods(for: child)
            Menu {
                ForEach(options) { food in
                    Button(food.name) {
                        withAnimation(.snappy) { SafeFoodPlanner.add(food, to: meal) }
                    }
                }
            } label: {
                Label(options.isEmpty ? "No safe foods set yet" : "Add a safe food side", systemImage: "shield.lefthalf.filled.badge.checkmark")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.apricot)
            }
            .disabled(options.isEmpty)
        }
    }
}

// MARK: - Meal Detail

struct MealDetailView: View {
    let meal: MealItem
    @Query private var children: [ChildProfile]
    @Query(sort: \Ingredient.name) private var allIngredients: [Ingredient]
    @Environment(\.dismiss) private var dismiss
    @State private var isCooking = false
    @State private var swapCount = 0

    private var child: ChildProfile? { children.first }
    private var ageInMonths: Int { child?.ageInMonths ?? 36 }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    macrosGrid
                    instructions
                    ingredientsList
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    isCooking = true
                } label: {
                    Label("Start Cooking Mode", systemImage: "frying.pan.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 52)
                }
                .buttonStyle(.borderedProminent)
                .tint(.sage)
                .padding(.horizontal)
                .padding(.bottom, 8)
                .background(.bar)
            }
            .fullScreenCover(isPresented: $isCooking) {
                CookingModeView(meal: meal, ageInMonths: ageInMonths)
            }
            .sensoryFeedback(.selection, trigger: swapCount)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(meal.scheduleLabel, systemImage: meal.mealSlot.symbol)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.sage)
            Text(meal.title)
                .font(.title2.weight(.bold))
            HStack(spacing: 6) {
                Chip("\(meal.prepTimeMinutes) min", symbol: "clock", tint: .secondary)
                ForEach(meal.textures) { Chip($0.title, symbol: $0.symbol, tint: .secondary) }
            }
        }
    }

    private var macrosGrid: some View {
        Grid(horizontalSpacing: 12, verticalSpacing: 12) {
            GridRow {
                macroTile("Protein", "\(Int(meal.macros.proteinGrams))g", .sage)
                macroTile("Healthy Fats", "\(Int(meal.macros.healthyFatGrams))g", .apricot)
            }
            GridRow {
                macroTile("Complex Carbs", "\(Int(meal.macros.complexCarbGrams))g", .secondary)
                macroTile("Iron", "\(meal.macros.ironMilligrams.formatted(.number.precision(.fractionLength(1))))mg", .caution)
            }
        }
    }

    private func macroTile(_ title: String, _ value: String, _ tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value).font(.title3.weight(.bold)).foregroundStyle(tint)
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .card(padding: 12)
    }

    private var instructions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Toddler Prep for \(child?.name ?? "Your Child") (\(child?.ageDescription ?? "3 yrs"))")
                .font(.headline)
            ForEach(Array(meal.toddlerPrepInstructions.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 10) {
                    Text("\(index + 1)")
                        .font(.caption.weight(.bold))
                        .frame(width: 24, height: 24)
                        .background(Color.sage.opacity(0.15), in: Circle())
                        .foregroundStyle(Color.sage)
                    Text(step)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            ForEach(SafetyEngine.callouts(for: meal, ageInMonths: ageInMonths)) { SafetyCalloutRow(callout: $0) }
        }
        .card()
    }

    private var ingredientsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingredients")
                .font(.headline)
            ForEach(meal.sortedIngredients) { ingredient in
                let alternatives = ProteinSwapEngine.alternatives(for: ingredient, in: allIngredients)
                HStack(spacing: 12) {
                    Image(systemName: ingredient.category.symbol)
                        .foregroundStyle(Color.sage)
                        .frame(width: 24)
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(ingredient.name)
                            if child?.isSafeFood(ingredient) == true {
                                Image(systemName: "checkmark.shield.fill")
                                    .foregroundStyle(Color.sage)
                                    .accessibilityLabel("Safe food")
                            }
                        }
                        if let note = ingredient.toddlerSafetyNote {
                            Text(note).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    if ingredient.inPantry {
                        Image(systemName: "refrigerator.fill")
                            .foregroundStyle(Color.sage)
                            .accessibilityLabel("In pantry")
                    }
                    if !alternatives.isEmpty {
                        Menu {
                            Section("Swap \(ingredient.name)") {
                                ForEach(alternatives) { alt in
                                    Button {
                                        withAnimation(.snappy) {
                                            ProteinSwapEngine.swap(ingredient, with: alt, in: meal)
                                            swapCount += 1
                                        }
                                    } label: {
                                        Label("\(alt.name) · \(Int(alt.proteinPerServing))g protein",
                                              systemImage: alt.inPantry ? "refrigerator" : "cart")
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.left.arrow.right.circle.fill")
                                .font(.title3)
                                .foregroundStyle(Color.apricot)
                        }
                        .accessibilityLabel("Swap \(ingredient.name)")
                    }
                }
                Divider()
            }
        }
        .card()
    }
}

// MARK: - Cooking Mode ("Parent Mode": one-handed, high contrast, screen stays awake)

struct CookingModeView: View {
    let meal: MealItem
    let ageInMonths: Int
    @Environment(\.dismiss) private var dismiss
    @State private var stepIndex = 0
    private let timer = CookingTimerStore.shared

    private var steps: [String] {
        meal.toddlerPrepInstructions
            + SafetyEngine.callouts(for: meal, ageInMonths: ageInMonths)
                .map { "Safety check — \($0.ingredientName): \($0.guidance.instruction)" }
    }

    private var currentStep: String {
        steps.isEmpty ? "" : steps[min(stepIndex, steps.count - 1)]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(meal.mealSlot.title.uppercased())
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(Color.apricot)
                    Text(meal.title)
                        .font(.title3.weight(.bold))
                        .lineLimit(2)
                }
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title2.weight(.bold))
                        .frame(width: 56, height: 56)
                        .background(.white.opacity(0.15), in: Circle())
                }
                .accessibilityLabel("Close Cooking Mode")
            }

            if !steps.isEmpty {
                ProgressView(value: Double(stepIndex + 1), total: Double(steps.count))
                    .tint(.apricot)
                Text("Step \(stepIndex + 1) of \(steps.count)")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.7))

                ScrollView {
                    Text(currentStep)
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .id(stepIndex)
                        .transition(.push(from: .trailing))
                }
            } else {
                Spacer()
            }

            timerPanel

            HStack(spacing: 16) {
                bigButton("Back", symbol: "chevron.left", enabled: stepIndex > 0) {
                    withAnimation(.snappy) { stepIndex -= 1 }
                }
                if stepIndex < steps.count - 1 {
                    bigButton("Next", symbol: "chevron.right", enabled: true, prominent: true) {
                        withAnimation(.snappy) { stepIndex += 1 }
                    }
                } else {
                    bigButton("Done", symbol: "checkmark", enabled: true, prominent: true) { dismiss() }
                }
            }
        }
        .padding(24)
        .foregroundStyle(.white)
        .background(Color(light: 0x1B1D1F, dark: 0x000000).ignoresSafeArea())
        .sensoryFeedback(.impact(weight: .medium), trigger: stepIndex)
        .onChange(of: stepIndex) {
            if timer.mealID == meal.id { timer.updateStep(currentStep) }
        }
        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
        .statusBarHidden()
    }

    @ViewBuilder
    private var timerPanel: some View {
        let suggested = CookingTimerStore.suggestedMinutes(in: currentStep)
        HStack(spacing: 10) {
            Image(systemName: "timer").font(.title2)
            if let endDate = timer.endDate {
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    let remaining = max(0, endDate.timeIntervalSince(context.date))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(remaining > 0 ? Duration.seconds(remaining).formatted(.time(pattern: .minuteSecond)) : "Time's up!")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(remaining > 0 ? Color.white : Color.apricot)
                        Text(timer.label)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                            .lineLimit(1)
                    }
                }
                Spacer()
                Button("Stop") { timer.stop() }
                    .buttonStyle(.bordered)
                    .tint(.white)
                    .frame(minHeight: 44)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        if let suggested {
                            Button("\(suggested) min") { timer.start(minutes: suggested, meal: meal, step: currentStep) }
                                .font(.headline)
                                .buttonStyle(.borderedProminent)
                                .tint(.apricot)
                                .foregroundStyle(Color.black)
                                .frame(minHeight: 44)
                        }
                        ForEach([2, 5, 10, 15].filter { $0 != suggested }, id: \.self) { minutes in
                            Button("\(minutes)m") { timer.start(minutes: minutes, meal: meal, step: currentStep) }
                                .font(.headline)
                                .buttonStyle(.bordered)
                                .tint(.apricot)
                                .frame(minHeight: 44)
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .sensoryFeedback(.start, trigger: timer.endDate)
    }

    private func bigButton(_ title: String, symbol: String, enabled: Bool, prominent: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(.title2.weight(.bold))
                .frame(maxWidth: .infinity, minHeight: 72)
                .foregroundStyle(prominent ? Color.black : Color.white)
                .background(prominent ? Color.apricot : Color.white.opacity(0.15),
                            in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.35)
    }
}

#Preview(traits: .sampleData) {
    MealPlanView()
        .environment(AppRouter())
}
