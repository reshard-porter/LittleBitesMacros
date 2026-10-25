import SwiftUI
import UIKit

// Palette colors (sage, apricot, appBackground, …) live in Shared/Palette.swift.

extension SafetyGuidance.Level {
    var color: Color {
        switch self {
        case .ok: .sage
        case .modify: .apricot
        case .avoid: .caution
        }
    }

    var symbol: String {
        switch self {
        case .ok: "checkmark.shield.fill"
        case .modify: "exclamationmark.triangle.fill"
        case .avoid: "xmark.octagon.fill"
        }
    }
}

// MARK: - Shared Components

struct CardBackground: ViewModifier {
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
    }
}

extension View {
    func card(padding: CGFloat = 16) -> some View { modifier(CardBackground(padding: padding)) }
}

struct Chip: View {
    let text: String
    var symbol: String?
    var tint: Color = .sage
    var filled = false

    init(_ text: String, symbol: String? = nil, tint: Color = .sage, filled: Bool = false) {
        self.text = text
        self.symbol = symbol
        self.tint = tint
        self.filled = filled
    }

    var body: some View {
        HStack(spacing: 4) {
            if let symbol { Image(systemName: symbol).imageScale(.small) }
            Text(text).lineLimit(1)
        }
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .foregroundStyle(filled ? Color.white : tint)
        .background(filled ? tint : tint.opacity(0.14), in: Capsule())
    }
}

/// A pill used for toggleable filters.
struct FilterPill: View {
    let title: String
    var symbol: String?
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Chip(title, symbol: symbol, tint: .sage, filled: isOn)
                .padding(.vertical, 2)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}

/// Wraps children onto multiple lines, like tags.
struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(maxWidth: proposal.width ?? .infinity, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(maxWidth: bounds.width, subviews: subviews)
        for (index, origin) in result.origins.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + origin.x, y: bounds.minY + origin.y),
                proposal: ProposedViewSize(width: min(result.sizes[index].width, bounds.width), height: nil)
            )
        }
    }

    private func arrange(maxWidth: CGFloat, subviews: Subviews) -> (size: CGSize, origins: [CGPoint], sizes: [CGSize]) {
        var origins: [CGPoint] = []
        var sizes: [CGSize] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var widest: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            origins.append(CGPoint(x: x, y: y))
            sizes.append(size)
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            widest = max(widest, min(x - spacing, maxWidth))
        }
        return (CGSize(width: widest, height: y + rowHeight), origins, sizes)
    }
}

struct ProgressRing: View {
    let title: String
    let valueText: String
    let progress: Double
    var tint: Color = .sage

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().stroke(tint.opacity(0.18), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: min(max(progress, 0), 1))
                    .stroke(tint, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text(valueText)
                    .font(.caption.weight(.bold))
                    .monospacedDigit()
                    .minimumScaleFactor(0.7)
                    .padding(8)
            }
            .frame(width: 78, height: 78)
            .animation(.smooth, value: progress)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(valueText)
    }
}

struct SafetyCalloutRow: View {
    let callout: SafetyCallout

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: callout.guidance.level.symbol)
                .foregroundStyle(callout.guidance.level.color)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(callout.guidance.level.label): \(callout.ingredientName)")
                    .font(.caption.weight(.bold))
                Text(callout.guidance.instruction)
                    .font(.caption)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(callout.guidance.level.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}
