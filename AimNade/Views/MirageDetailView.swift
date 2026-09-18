import SwiftUI

struct MirageDetailView: View {
    @EnvironmentObject private var languageManager: LanguageManager

    let map: Map

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                featureLink(
                    title: L10n.text(.tacticalMap2D, for: languageManager),
                    subtitle: L10n.text(.mapFeatureSubtitle, for: languageManager),
                    systemImage: "map",
                    color: .blue
                ) {
                    TacticalMapView(map: map)
                }

                featureLink(
                    title: L10n.text(.utilityList, for: languageManager),
                    subtitle: L10n.text(.listFeatureSubtitle, for: languageManager),
                    systemImage: "list.bullet",
                    color: .green
                ) {
                    UtilityListView(map: map)
                }

                featureLink(
                    title: L10n.text(.search, for: languageManager),
                    subtitle: L10n.text(.searchFeatureSubtitle, for: languageManager),
                    systemImage: "magnifyingglass",
                    color: .orange
                ) {
                    LineupSearchView(map: map)
                }

                featureLink(
                    title: L10n.text(.favorites, for: languageManager),
                    subtitle: L10n.text(.favoritesFeatureSubtitle, for: languageManager),
                    systemImage: "star",
                    color: .yellow
                ) {
                    FavoritesView(map: map)
                }
            }
            .padding(AppTheme.pagePadding)
        }
        .background(AppTheme.background)
        .navigationTitle(map.name.value(for: languageManager))
    }

    private func featureLink<Destination: View>(
        title: String,
        subtitle: String,
        systemImage: String,
        color: Color,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        NavigationLink {
            destination()
        } label: {
            FeatureCard(
                systemImage: systemImage,
                title: title,
                subtitle: subtitle,
                color: color
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        MirageDetailView(map: LineupStore.mirageMap)
            .environmentObject(LanguageManager())
            .environmentObject(FavoriteStore())
    }
}
