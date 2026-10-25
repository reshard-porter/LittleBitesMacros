import SwiftUI
import WidgetKit

@main
struct LittleBitesWidgetBundle: WidgetBundle {
    var body: some Widget {
        TodayMenuWidget()
        CookingLiveActivity()
    }
}
