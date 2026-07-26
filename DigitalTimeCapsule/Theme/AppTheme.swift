import SwiftUI

enum AppTheme {
    static let background = Color(red: 0.04, green: 0.04, blue: 0.05)
    static let surface = Color(red: 0.10, green: 0.10, blue: 0.12)
    static let surfaceElevated = Color(red: 0.15, green: 0.15, blue: 0.17)
    static let accent = Color(red: 1.0, green: 0.42, blue: 0.0)
    static let accentSoft = Color(red: 1.0, green: 0.30, blue: 0.10)
    static let seal = Color(red: 0.15, green: 0.82, blue: 0.76)
    static let textPrimary = Color.white
    static let textSecondary = Color(red: 0.63, green: 0.63, blue: 0.68)
    static let cardStroke = Color.white.opacity(0.07)

    static let cornerLarge: CGFloat = 20
    static let cornerMedium: CGFloat = 14
    static let cornerSmall: CGFloat = 10
    static let tabBarHeight: CGFloat = 84
}

extension Font {
    static func rounded(_ size: CGFloat, _ weight: Font.Weight) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}
