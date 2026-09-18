import SwiftUI

struct UtilityBadge: View {
    let title: String
    let color: Color
    let foregroundColor: Color

    init(
        title: String,
        color: Color = AppTheme.cardBackground,
        foregroundColor: Color = AppTheme.primaryText
    ) {
        self.title = title
        self.color = color
        self.foregroundColor = foregroundColor
    }

    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(foregroundColor)
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.18))
            .clipShape(Capsule())
    }

    static func utilityType(_ type: UtilityType, for languageManager: LanguageManager) -> UtilityBadge {
        UtilityBadge(
            title: type.displayName(for: languageManager),
            color: type.color
        )
    }

    static func side(_ side: String) -> UtilityBadge {
        UtilityBadge(
            title: side,
            color: AppTheme.accent
        )
    }

    static func category(_ category: LineupCategory, for languageManager: LanguageManager) -> UtilityBadge {
        UtilityBadge(
            title: category.displayName(for: languageManager),
            color: AppTheme.accent
        )
    }

    static func difficulty(_ difficulty: String) -> UtilityBadge {
        UtilityBadge(
            title: difficulty,
            color: AppTheme.cardBackground
        )
    }
}
