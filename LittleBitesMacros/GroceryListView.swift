import SwiftData
import SwiftUI
import VisionKit

// MARK: - Categorized Smart Grocery List

struct GroceryListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Ingredient.name) private var ingredients: [Ingredient]

    @State private var selectedCategory: GroceryCategory?
    @State private var proteinOnly = false
    @State private var showPantry = true
    @State private var showAddItem = false
    @State private var showScanner = false
    @State private var checkCount = 0

    /// Everything the plan needs, plus items added by hand.
    private var listItems: [Ingredient] {
        ingredients.filter { $0.mealCount > 0 || $0.isOnShoppingList }
    }

    private var filtered: [Ingredient] {
        listItems.filter {
            (selectedCategory == nil || $0.category == selectedCategory) && (!proteinOnly || $0.isProteinStaple)
        }
    }

    private var toBuy: [Ingredient] { filtered.filter { !$0.inPantry } }
    private var stocked: [Ingredient] { filtered.filter(\.inPantry) }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    progressHeader
                    filterBar
                    Toggle(isOn: $proteinOnly.animation(.snappy)) {
                        Label("Protein Staples Only", systemImage: "bolt.heart.fill")
                    }
                    .tint(.sage)
                }

                ForEach(GroceryCategory.allCases) { category in
                    let items = toBuy.filter { $0.category == category }
                    if !items.isEmpty {
                        Section {
                            ForEach(items) { item in
                                GroceryRow(item: item, onToggle: { toggle(item) })
                                    .swipeActions(edge: .trailing) {
                                        if item.isOnShoppingList && item.mealCount == 0 {
                                            Button("Remove", systemImage: "trash", role: .destructive) { remove(item) }
                                        }
                                    }
                                    .contextMenu { swapMenu(for: item) }
                            }
                        } header: {
                            Label(category.title, systemImage: category.symbol)
                                .foregroundStyle(Color.sage)
                        }
                    }
                }

                if toBuy.isEmpty && !filtered.isEmpty {
                    Section {
                        ContentUnavailableView("All Stocked Up", systemImage: "checkmark.seal.fill",
                                               description: Text("Everything on this list is in your fridge or pantry."))
                    }
                }

                if !stocked.isEmpty {
                    Section {
                        if showPantry {
                            ForEach(stocked) { item in
                                GroceryRow(item: item, onToggle: { toggle(item) })
                                    .swipeActions(edge: .trailing) {
                                        Button("Used Up", systemImage: "arrow.uturn.backward") { toggle(item) }
                                            .tint(.apricot)
                                    }
                            }
                        }
                    } header: {
                        Button {
                            withAnimation(.snappy) { showPantry.toggle() }
                        } label: {
                            HStack {
                                Label("In My Fridge & Pantry (\(stocked.count))", systemImage: "refrigerator.fill")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .rotationEffect(.degrees(showPantry ? 90 : 0))
                            }
                            .foregroundStyle(Color.sage)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle("Smart Shop")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if DataScannerViewController.isSupported {
                        Button("Scan Receipt", systemImage: "barcode.viewfinder") { showScanner = true }
                    }
                    Button("Add Item", systemImage: "plus") { showAddItem = true }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button("Mark Everything as Needed", systemImage: "cart.badge.plus") {
                            withAnimation(.snappy) { listItems.forEach { $0.inPantry = false } }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showAddItem) { AddGroceryItemSheet() }
            .sheet(isPresented: $showScanner) {
                PantryScanSheet(candidates: listItems.filter { !$0.inPantry }) { matched in
                    withAnimation(.snappy) { matched.inPantry = true }
                    checkCount += 1
                }
            }
            .sensoryFeedback(.success, trigger: checkCount)
        }
    }

    // MARK: Subviews

    private var progressHeader: some View {
        let total = filtered.count
        let done = stocked.count
        return VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text("\(total - done) to buy")
                    .font(.title2.weight(.bold))
                Spacer()
                Text("\(done) of \(total) stocked")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            ProgressView(value: Double(done), total: Double(max(total, 1)))
                .tint(.sage)
                .animation(.smooth, value: done)
        }
        .padding(.vertical, 4)
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterPill(title: "All Aisles", isOn: selectedCategory == nil) {
                    withAnimation(.snappy) { selectedCategory = nil }
                }
                ForEach(GroceryCategory.allCases) { category in
                    FilterPill(title: category.shortTitle, symbol: category.symbol, isOn: selectedCategory == category) {
                        withAnimation(.snappy) { selectedCategory = selectedCategory == category ? nil : category }
                    }
                }
            }
            .padding(.vertical, 2)
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
    }

    @ViewBuilder
    private func swapMenu(for item: Ingredient) -> some View {
        let alternatives = ProteinSwapEngine.alternatives(for: item, in: ingredients)
        if !alternatives.isEmpty {
            Section("Swap in all meals for…") {
                ForEach(alternatives) { alt in
                    Button {
                        withAnimation(.snappy) { ProteinSwapEngine.swapEverywhere(item, with: alt) }
                    } label: {
                        Label("\(alt.name) (\(Int(alt.proteinPerServing))g protein)",
                              systemImage: alt.inPantry ? "refrigerator" : "arrow.left.arrow.right")
                    }
                }
            }
        }
        Button(item.inPantry ? "Move to Shopping List" : "Move to Pantry",
               systemImage: item.inPantry ? "cart" : "refrigerator") { toggle(item) }
    }

    // MARK: Actions

    private func toggle(_ item: Ingredient) {
        withAnimation(.snappy) { item.inPantry.toggle() }
        if item.inPantry { checkCount += 1 }
    }

    private func remove(_ item: Ingredient) {
        withAnimation {
            if item.exposureLogs?.isEmpty ?? true, item.safeForChildren?.isEmpty ?? true {
                context.delete(item)
            } else {
                item.isOnShoppingList = false
            }
        }
    }
}

// MARK: - Row

private struct GroceryRow: View {
    let item: Ingredient
    let onToggle: () -> Void

    private var subtitle: String {
        var parts: [String] = []
        if !item.quantity.isEmpty { parts.append(item.quantity) }
        if item.mealCount > 0 { parts.append("\(item.mealCount) meal\(item.mealCount == 1 ? "" : "s")") }
        if let note = item.toddlerSafetyNote { parts.append(note) }
        return parts.joined(separator: " · ")
    }

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: item.inPantry ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(item.inPantry ? Color.sage : Color.secondary)
                    .contentTransition(.symbolEffect(.replace))
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(item.name)
                            .strikethrough(item.inPantry)
                            .foregroundStyle(item.inPantry ? Color.secondary : Color.primary)
                        if item.isProteinStaple {
                            Image(systemName: "bolt.heart.fill")
                                .imageScale(.small)
                                .foregroundStyle(Color.apricot)
                                .accessibilityLabel("Protein staple")
                        }
                    }
                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                Spacer(minLength: 0)
                if item.hasLactoseFreeOption {
                    Chip("LF option", tint: .sage)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityValue(item.inPantry ? "In pantry" : "Needed")
        .accessibilityHint(item.inPantry ? "Moves back to the shopping list" : "Moves to your pantry")
    }
}

// MARK: - Add Item

private struct AddGroceryItemSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var quantity = ""
    @State private var category: GroceryCategory = .produce
    @State private var isProteinStaple = false

    var body: some View {
        NavigationStack {
            Form {
                TextField("Item name", text: $name)
                TextField("Quantity (optional)", text: $quantity)
                Picker("Aisle", selection: $category) {
                    ForEach(GroceryCategory.allCases) { Label($0.title, systemImage: $0.symbol).tag($0) }
                }
                Toggle("Protein staple", isOn: $isProteinStaple)
                    .tint(.sage)
            }
            .navigationTitle("Add to List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let item = Ingredient(name: name.trimmingCharacters(in: .whitespaces), category: category,
                                              isProteinStaple: isProteinStaple, quantity: quantity)
                        item.isOnShoppingList = true
                        context.insert(item)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Receipt / Barcode Scanning (VisionKit)

/// Scans receipt text and moves matching shopping-list items into the pantry.
private struct PantryScanSheet: View {
    let candidates: [Ingredient]
    let onMatch: (Ingredient) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var moved: [String] = []
    @State private var lastBarcode: String?

    var body: some View {
        NavigationStack {
            Group {
                if DataScannerViewController.isAvailable {
                    PantryScannerView(onRecognized: handle)
                        .ignoresSafeArea(edges: .bottom)
                        .overlay(alignment: .bottom) { resultsPanel }
                } else {
                    ContentUnavailableView("Camera Unavailable", systemImage: "camera.fill",
                                           description: Text("Allow camera access in Settings to scan receipts."))
                }
            }
            .navigationTitle("Scan Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
    }

    private var resultsPanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            if moved.isEmpty {
                Text("Point at your receipt. Matching items move to your pantry automatically.")
                    .font(.subheadline)
            } else {
                Text("Moved to pantry").font(.headline)
                ForEach(moved, id: \.self) { name in
                    Label(name, systemImage: "checkmark.circle.fill")
                        .foregroundStyle(Color.sage)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            if let lastBarcode {
                Text("Barcode \(lastBarcode) scanned. Tap the item in your list to confirm.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding()
    }

    private func handle(_ recognized: PantryScannerView.Recognized) {
        switch recognized {
        case .text(let text):
            let lowered = text.lowercased()
            for item in candidates where !moved.contains(item.name) {
                if item.keywords.contains(where: { lowered.contains($0) }) {
                    onMatch(item)
                    withAnimation(.snappy) { moved.append(item.name) }
                }
            }
        case .barcode(let payload):
            lastBarcode = payload
        }
    }
}

private struct PantryScannerView: UIViewControllerRepresentable {
    enum Recognized {
        case text(String)
        case barcode(String)
    }

    let onRecognized: @MainActor (Recognized) -> Void

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text(), .barcode()],
            qualityLevel: .balanced,
            recognizesMultipleItems: true,
            isHighFrameRateTrackingEnabled: false,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        try? scanner.startScanning()
        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}

    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        uiViewController.stopScanning()
    }

    func makeCoordinator() -> Coordinator { Coordinator(onRecognized: onRecognized) }

    @MainActor
    final class Coordinator: NSObject {
        let onRecognized: @MainActor (Recognized) -> Void

        init(onRecognized: @escaping @MainActor (Recognized) -> Void) {
            self.onRecognized = onRecognized
        }
    }
}

extension PantryScannerView.Coordinator: @preconcurrency DataScannerViewControllerDelegate {
    func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
        for item in addedItems {
            switch item {
            case .text(let text):
                onRecognized(.text(text.transcript))
            case .barcode(let barcode):
                if let payload = barcode.payloadStringValue { onRecognized(.barcode(payload)) }
            @unknown default:
                break
            }
        }
    }
}

#Preview(traits: .sampleData) {
    GroceryListView()
}
