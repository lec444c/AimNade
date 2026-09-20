import SwiftUI

@main
struct AimNadeApp: App {
    @StateObject private var languageManager = LanguageManager()
    @StateObject private var favoriteStore = FavoriteStore()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(languageManager)
                .environmentObject(favoriteStore)
        }
    }
}

private struct MainTabView: View {
    @EnvironmentObject private var languageManager: LanguageManager

    var body: some View {
        TabView {
            NavigationStack {
                TacticsView(maps: LineupStore.maps)
            }
            .tabItem {
                Label(L10n.text(.tactics, for: languageManager), systemImage: "map")
            }

            NavigationStack {
                FavoritesView(maps: LineupStore.maps)
            }
            .tabItem {
                Label(L10n.text(.favorites, for: languageManager), systemImage: "star")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label(L10n.text(.settings, for: languageManager), systemImage: "gearshape")
            }
        }
        .tint(AppTheme.accent)
    }
}
