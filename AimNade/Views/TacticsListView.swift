import SwiftUI

struct TacticsLineupItem: Identifiable {
    let group: LineupGroup
    let variant: LineupVariant

    var id: String { variant.id }
}

struct TacticsListView: View {
    @EnvironmentObject private var languageManager: LanguageManager

    let items: [TacticsLineupItem]

    var body: some View {
        List {
            if items.isEmpty {
                EmptyStateView(
                    systemImage: "line.3.horizontal.decrease.circle",
                    title: L10n.text(.emptyUtilities, for: languageManager),
                    message: L10n.text(.emptyUtilitiesMessage, for: languageManager)
                )
            } else {
                ForEach(LineupCategory.allCases, id: \.self) { category in
                    let categoryItems = items.filter { $0.group.category == category }

                    if !categoryItems.isEmpty {
                        Section(category.displayName(for: languageManager)) {
                            ForEach(categoryItems) { item in
                                TacticsLineupRow(item: item)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(AppTheme.background)
    }
}

private struct TacticsLineupRow: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var favoriteStore: FavoriteStore

    let item: TacticsLineupItem

    var body: some View {
        HStack(spacing: 10) {
            NavigationLink {
                LineupDetailView(group: item.group, variant: item.variant)
            } label: {
                HStack(spacing: 12) {
                    MapMarkerView(type: item.group.type, markerSize: 30)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(routeTitle)
                            .font(.headline)
                            .lineLimit(1)

                        Text(item.variant.name.value(for: languageManager))
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.secondaryText)
                            .lineLimit(1)

                        HStack(spacing: 6) {
                            UtilityBadge.utilityType(item.group.type, for: languageManager)
                            UtilityBadge.side(item.group.side)
                        }
                    }
                }
            }

            Button {
                favoriteStore.toggleVariant(item.variant)
            } label: {
                Image(
                    systemName: favoriteStore.isFavoriteVariant(item.variant)
                        ? "star.fill"
                        : "star"
                )
                .foregroundStyle(AppTheme.accent)
                .frame(width: 32, height: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                L10n.text(
                    favoriteStore.isFavoriteVariant(item.variant) ? .removeFavorite : .addFavorite,
                    for: languageManager
                )
            )
        }
        .padding(.vertical, 4)
    }

    private var routeTitle: String {
        "\(item.variant.startArea.value(for: languageManager)) → \(item.variant.targetArea.value(for: languageManager))"
    }
}

#Preview {
    NavigationStack {
        TacticsListView(
            items: LineupStore.mirageMap.lineupGroups.flatMap { group in
                group.variants.map { variant in
                    TacticsLineupItem(group: group, variant: variant)
                }
            }
        )
            .environmentObject(LanguageManager())
            .environmentObject(FavoriteStore())
    }
}
