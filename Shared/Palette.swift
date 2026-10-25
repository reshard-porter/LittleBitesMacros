import SwiftUI
import UIKit

/// Brand palette, shared by the app and the widget extension.
extension Color {
    /// Sage Green #4A7C59 (lifted slightly in Dark Mode for contrast).
    static let sage = Color(light: 0x4A7C59, dark: 0x6FA67F)
    /// Warm Apricot #F4A261.
    static let apricot = Color(light: 0xF4A261, dark: 0xF4A261)
    /// Soft Cream #FAF8F5 in Light Mode, rich charcoal in Dark Mode.
    static let appBackground = Color(light: 0xFAF8F5, dark: 0x1B1D1F)
    static let cardBackground = Color(light: 0xFFFFFF, dark: 0x26292C)
    static let caution = Color(light: 0xD1495B, dark: 0xF07C8A)

    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
