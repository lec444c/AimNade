import SwiftUI

struct UtilityListView: View {
    @EnvironmentObject private var languageManager: LanguageManager

    let map: Map

    private var groups: [LineupGroup] {
        map.lineupGroups
    }

    var body: some View {
        List {
            if groups.isEmpty {
                EmptyStateView(
                    systemImage: "tray",
                    title: L10n.text(.emptyUtilities, for: languageManager),
                    message: L10n.text(.emptyUtilitiesMessage, for: languageManager)
                )
            } else {
                ForEach(LineupCategory.allCases, id: \.self) { category in
                    let categoryGroups = groups.filter { group in
                        group.category == category
                    }

                    if !categoryGroups.isEmpty {
                        Section(category.displayName(for: languageManager)) {
                            ForEach(categoryGroups) { group in
                                NavigationLink {
                                    LineupGroupDetailView(group: group)
                                } label: {
                                    UtilityListRow(group: group)
                                        .environmentObject(languageManager)
                                }
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(AppTheme.background)
        .navigationTitle(L10n.text(.utilityList, for: languageManager))
    }
}

private struct UtilityListRow: View {
    @EnvironmentObject private var languageManager: LanguageManager

    let group: LineupGroup

    var body: some View {
        HStack(spacing: 12) {
            MapMarkerView(type: group.type, markerSize: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(group.targetName.value(for: languageManager))
                    .font(.headline)
                HStack(spacing: 6) {
                    UtilityBadge.utilityType(group.type, for: languageManager)
                    UtilityBadge.category(group.category, for: languageManager)
                }
                Text(L10n.text(.variantCount(group.variants.count), for: languageManager))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, AppTheme.smallCornerRadius - 6)
        }
    }
}

#Preview {
    NavigationStack {
        UtilityListView(map: LineupStore.mirageMap)
            .environmentObject(LanguageManager())
            .environmentObject(FavoriteStore())
    }
}
