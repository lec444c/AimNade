import SwiftUI

struct MapListView: View {
    @EnvironmentObject private var languageManager: LanguageManager

    var body: some View {
        NavigationStack {
            List {
                ForEach(LineupStore.maps) { map in
                    NavigationLink {
                        MirageDetailView(map: map)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(map.name.value(for: languageManager))
                                .font(.headline)
                            Text(L10n.text(.lineupCount(map.lineupGroups.count), for: languageManager))
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                        .padding(.vertical, AppTheme.smallCornerRadius - 6)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .navigationTitle(L10n.text(.maps, for: languageManager))
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
    }
}

#Preview {
    MapListView()
        .environmentObject(LanguageManager())
        .environmentObject(FavoriteStore())
}
