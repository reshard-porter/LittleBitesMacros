import ActivityKit
import SwiftUI
import WidgetKit

/// Cooking Mode timer on the Lock Screen and in the Dynamic Island,
/// e.g. "Steaming broccoli · 4:00 left".
struct CookingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CookingActivityAttributes.self) { context in
            LockScreenCookingView(attributes: context.attributes, state: context.state)
                .activityBackgroundTint(Color(light: 0x24312A, dark: 0x1B2620))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.attributes.slot.shortTitle, systemImage: "frying.pan.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.apricot)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    CountdownText(state: context.state)
                        .font(.title2.weight(.bold))
                        .frame(maxWidth: 90, alignment: .trailing)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.timerLabel)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.attributes.mealTitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        ProgressView(timerInterval: context.state.startDate...context.state.endDate, countsDown: true) {
                            EmptyView()
                        } currentValueLabel: {
                            EmptyView()
                        }
                        .tint(Color.apricot)
                    }
                }
            } compactLeading: {
                Image(systemName: "frying.pan.fill")
                    .foregroundStyle(Color.apricot)
            } compactTrailing: {
                CountdownText(state: context.state)
                    .frame(maxWidth: 48)
                    .foregroundStyle(Color.apricot)
            } minimal: {
                Image(systemName: "timer")
                    .foregroundStyle(Color.apricot)
            }
            .widgetURL(URL(string: "littlebites://cooking"))
            .keylineTint(Color.apricot)
        }
    }
}

private struct CountdownText: View {
    let state: CookingActivityAttributes.ContentState

    var body: some View {
        Text(timerInterval: state.startDate...state.endDate, countsDown: true)
            .monospacedDigit()
            .multilineTextAlignment(.trailing)
    }
}

private struct LockScreenCookingView: View {
    let attributes: CookingActivityAttributes
    let state: CookingActivityAttributes.ContentState

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "frying.pan.fill")
                .font(.title2)
                .foregroundStyle(Color.apricot)
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.12), in: Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(state.timerLabel)
                    .font(.headline)
                    .lineLimit(1)
                Text(attributes.mealTitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(1)
                ProgressView(timerInterval: state.startDate...state.endDate, countsDown: true) {
                    EmptyView()
                } currentValueLabel: {
                    EmptyView()
                }
                .tint(Color.apricot)
            }
            CountdownText(state: state)
                .font(.title.weight(.bold))
                .frame(width: 96, alignment: .trailing)
        }
        .foregroundStyle(.white)
        .padding()
    }
}

#Preview("Lock Screen", as: .content, using: CookingActivityAttributes.preview) {
    CookingLiveActivity()
} contentStates: {
    CookingActivityAttributes.ContentState.preview
}

#Preview("Dynamic Island", as: .dynamicIsland(.expanded), using: CookingActivityAttributes.preview) {
    CookingLiveActivity()
} contentStates: {
    CookingActivityAttributes.ContentState.preview
}
