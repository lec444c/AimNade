import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String?

    init(systemImage: String, title: String, message: String? = nil) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
    }

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 36))
                .foregroundStyle(.secondary)

            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)

            if let message {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
    }
}

#Preview {
    let languageManager = LanguageManager()

    EmptyStateView(
        systemImage: "tray",
        title: L10n.text(.emptyUtilities, for: languageManager),
        message: L10n.text(.emptyUtilitiesMessage, for: languageManager)
    )
}
