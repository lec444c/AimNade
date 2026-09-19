import SwiftUI

struct TacticsView: View {
    @EnvironmentObject private var languageManager: LanguageManager

    @State private var selectedMapID: String
    @State private var selectedViewMode: TacticsViewMode = .map
    @State private var selectedSide: TacticsSide = .terrorist
    @State private var selectedUtilityType: UtilityType?
    @State private var searchText = ""

    let maps: [Map]

    init(maps: [Map]) {
        self.maps = maps
        _selectedMapID = State(initialValue: maps.first?.id ?? "")
    }

    private var selectedMap: Map {
        maps.first(where: { $0.id == selectedMapID }) ?? LineupStore.mirageMap
    }

    private var baseGroups: [LineupGroup] {
        selectedMap.lineupGroups.filter { group in
            group.side.caseInsensitiveCompare(selectedSide.rawValue) == .orderedSame
                && (selectedUtilityType == nil || group.type == selectedUtilityType)
        }
    }

    private var filteredGroups: [LineupGroup] {
        baseGroups.filter { group in
            searchText.isEmpty
                || LineupSearch.matches(group: group, query: searchText)
                || group.variants.contains { variant in
                    LineupSearch.matches(variant: variant, query: searchText)
                }
        }
    }

    private var filteredItems: [TacticsLineupItem] {
        baseGroups.flatMap { group -> [TacticsLineupItem] in
            let groupMatches = searchText.isEmpty
                || LineupSearch.matches(group: group, query: searchText)

            return group.variants.compactMap { variant in
                guard groupMatches || LineupSearch.matches(variant: variant, query: searchText) else {
                    return nil
                }

                return TacticsLineupItem(group: group, variant: variant)
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            TacticsControlPanel(
                selectedViewMode: $selectedViewMode,
                selectedSide: $selectedSide,
                selectedUtilityType: $selectedUtilityType
            )

            switch selectedViewMode {
            case .map:
                TacticalMapView(map: selectedMap, groups: filteredGroups)
            case .list:
                TacticsListView(items: filteredItems)
            }
        }
        .background(AppTheme.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                mapSelector
            }
        }
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text(L10n.text(.searchPrompt, for: languageManager))
        )
    }

    private var mapSelector: some View {
        Menu {
            ForEach(maps) { map in
                Button {
                    selectedMapID = map.id
                } label: {
                    if map.id == selectedMap.id {
                        Label(map.name.value(for: languageManager), systemImage: "checkmark")
                    } else {
                        Text(map.name.value(for: languageManager))
                    }
                }
            }
        } label: {
            HStack(spacing: 5) {
                Text(selectedMap.name.value(for: languageManager))
                    .font(.headline)
                Image(systemName: "chevron.down")
                    .font(.caption2.weight(.semibold))
            }
        }
        .accessibilityLabel(
            "\(L10n.text(.maps, for: languageManager)): \(selectedMap.name.value(for: languageManager))"
        )
    }
}

private struct TacticsControlPanel: View {
    @EnvironmentObject private var languageManager: LanguageManager

    @Binding var selectedViewMode: TacticsViewMode
    @Binding var selectedSide: TacticsSide
    @Binding var selectedUtilityType: UtilityType?

    private var utilityFilters: [UtilityType?] {
        [nil] + UtilityType.allCases.map(Optional.some)
    }

    var body: some View {
        VStack(spacing: 12) {
            Picker(
                L10n.text(.tactics, for: languageManager),
                selection: $selectedViewMode
            ) {
                ForEach(TacticsViewMode.allCases) { mode in
                    Text(mode.title(for: languageManager))
                        .tag(mode)
                }
            }
            .pickerStyle(.segmented)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(utilityFilters, id: \.self) { utilityType in
                        TacticsFilterChip(
                            title: utilityType?.displayName(for: languageManager)
                                ?? L10n.text(.mapFilterAll, for: languageManager),
                            isSelected: selectedUtilityType == utilityType
                        ) {
                            selectedUtilityType = utilityType
                        }
                    }
                }
            }

            HStack(spacing: 12) {
                Text(L10n.text(.side, for: languageManager))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.secondaryText)

                Picker(
                    L10n.text(.side, for: languageManager),
                    selection: $selectedSide
                ) {
                    ForEach(TacticsSide.allCases) { side in
                        Text(side.title(for: languageManager))
                            .tag(side)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .padding(.horizontal, AppTheme.pagePadding)
        .padding(.top, 8)
        .padding(.bottom, 10)
    }
}

private struct TacticsFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(isSelected ? Color.white : AppTheme.primaryText)
                .padding(.horizontal, 13)
                .padding(.vertical, 7)
                .background(isSelected ? AppTheme.accent : AppTheme.cardBackground)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private enum TacticsViewMode: CaseIterable, Hashable, Identifiable {
    case map
    case list

    var id: Self { self }

    func title(for languageManager: LanguageManager) -> String {
        switch self {
        case .map:
            return L10n.text(.mapView, for: languageManager)
        case .list:
            return L10n.text(.listView, for: languageManager)
        }
    }
}

private enum TacticsSide: String, CaseIterable, Hashable, Identifiable {
    case terrorist = "T"
    case counterTerrorist = "CT"

    var id: Self { self }

    func title(for languageManager: LanguageManager) -> String {
        switch self {
        case .terrorist:
            return LineupCategory.tSide.displayName(for: languageManager)
        case .counterTerrorist:
            return LineupCategory.ctSide.displayName(for: languageManager)
        }
    }
}

#Preview {
    NavigationStack {
        TacticsView(maps: LineupStore.maps)
            .environmentObject(LanguageManager())
            .environmentObject(DeveloperSettings())
            .environmentObject(FavoriteStore())
    }
}
