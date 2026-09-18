import SwiftUI

@main
struct AimNadeApp: App {
    @StateObject private var languageManager = LanguageManager()
    @StateObject private var developerSettings = DeveloperSettings()
    @StateObject private var favoriteStore = FavoriteStore()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MirageDetailView(map: LineupStore.mirageMap)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            NavigationLink {
                                SettingsView()
                            } label: {
                                Image(systemName: "gearshape")
                            }
                            .accessibilityLabel(L10n.text(.settings, for: languageManager))
                        }
                    }
            }
            .environmentObject(languageManager)
            .environmentObject(developerSettings)
            .environmentObject(favoriteStore)
        }
    }
}
