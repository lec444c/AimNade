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

    private var mapStyle: TacticsMapStyle {
        TacticsMapStyle.style(for: selectedMap.id)
    }

    private var sideGroups: [LineupGroup] {
        selectedMap.lineupGroups.filter { group in
            group.side.caseInsensitiveCompare(selectedSide.rawValue) == .orderedSame
        }
    }

    private var baseGroups: [LineupGroup] {
        sideGroups.filter { group in
            selectedUtilityType == nil || group.type == selectedUtilityType
        }
    }

    private var utilityCounts: [UtilityType: Int] {
        Dictionary(grouping: sideGroups, by: \.type)
            .mapValues(\.count)
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
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [
                    mapStyle.accent.opacity(0.14),
                    mapStyle.secondary.opacity(0.07),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 190)
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                MapContextHeader(
                    maps: maps,
                    selectedMapID: $selectedMapID,
                    selectedMap: selectedMap,
                    groupCount: selectedMap.lineupGroups.count,
                    variantCount: selectedMap.lineupGroups.reduce(0) { $0 + $1.variants.count },
                    style: mapStyle
                )

                if selectedMap.lineupGroups.isEmpty {
                    MapPreviewBanner(style: mapStyle)

                    TacticalMapView(
                        map: selectedMap,
                        groups: filteredGroups,
                        accentColor: mapStyle.accent,
                        showsEmptyState: false
                    )
                    .id(selectedMap.id)
                } else {
                    TacticsSearchField(text: $searchText)

                    TacticsControlPanel(
                        selectedViewMode: $selectedViewMode,
                        selectedSide: $selectedSide,
                        selectedUtilityType: $selectedUtilityType,
                        allUtilityCount: sideGroups.count,
                        utilityCounts: utilityCounts,
                        selectionColor: mapStyle.accent
                    )

                    switch selectedViewMode {
                    case .map:
                        TacticalMapView(
                            map: selectedMap,
                            groups: filteredGroups,
                            accentColor: mapStyle.accent
                        )
                        .id(selectedMap.id)
                    case .list:
                        TacticsListView(items: filteredItems)
                    }
                }
            }
        }
        .background(AppTheme.background)
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: selectedMapID) {
            selectedViewMode = .map
            selectedUtilityType = nil
            searchText = ""
        }
    }
}

private struct MapPreviewBanner: View {
    @EnvironmentObject private var languageManager: LanguageManager

    let style: TacticsMapStyle

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: style.symbol)
                .font(.headline)
                .foregroundStyle(style.accent)
                .frame(width: 34, height: 34)
                .background(style.accent.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.text(.mapPreviewOnly, for: languageManager))
                    .font(.subheadline.weight(.semibold))

                Text(L10n.text(.mapDataPending, for: languageManager))
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            Spacer(minLength: 0)
        }
        .padding(10)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(style.accent.opacity(0.18), lineWidth: 1)
        }
        .padding(.horizontal, AppTheme.pagePadding)
        .padding(.bottom, 10)
    }
}

private struct MapContextHeader: View {
    @EnvironmentObject private var languageManager: LanguageManager

    let maps: [Map]
    @Binding var selectedMapID: String
    let selectedMap: Map
    let groupCount: Int
    let variantCount: Int
    let style: TacticsMapStyle

    var body: some View {
        HStack(spacing: 12) {
            Menu {
                ForEach(maps) { map in
                    Button {
                        selectedMapID = map.id
                    } label: {
                        if map.id == selectedMap.id {
                            Label(map.name.value(for: languageManager), systemImage: "checkmark")
                        } else {
                            Label(
                                map.name.value(for: languageManager),
                                systemImage: TacticsMapStyle.style(for: map.id).symbol
                            )
                        }
                    }
                }
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(selectedMap.name.value(for: languageManager))
                            .font(.title2.bold())
                            .foregroundStyle(AppTheme.primaryText)

                        Image(systemName: "chevron.down")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(style.accent)
                    }

                    HStack(spacing: 6) {
                        Text(L10n.text(.lineupCount(groupCount), for: languageManager))
                        Text("·")
                        Text(L10n.text(.variantCount(variantCount), for: languageManager))
                    }
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(AppTheme.secondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                "\(L10n.text(.maps, for: languageManager)): \(selectedMap.name.value(for: languageManager))"
            )

            Image(systemName: style.symbol)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(style.secondary)
                .frame(width: 42, height: 42)
                .background(style.accent.opacity(0.12))
                .clipShape(Circle())
                .accessibilityHidden(true)
        }
        .padding(.horizontal, AppTheme.pagePadding)
        .padding(.top, 8)
        .padding(.bottom, 10)
    }
}

private struct TacticsSearchField: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @Binding var text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppTheme.secondaryText)

            TextField(
                L10n.text(.searchPrompt, for: languageManager),
                text: $text
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.search)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppTheme.secondaryText)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.text(.close, for: languageManager))
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(AppTheme.subtleBorder, lineWidth: 1)
        }
        .padding(.horizontal, AppTheme.pagePadding)
    }
}

private struct TacticsControlPanel: View {
    @EnvironmentObject private var languageManager: LanguageManager

    @Binding var selectedViewMode: TacticsViewMode
    @Binding var selectedSide: TacticsSide
    @Binding var selectedUtilityType: UtilityType?

    let allUtilityCount: Int
    let utilityCounts: [UtilityType: Int]
    let selectionColor: Color

    private var utilityFilters: [UtilityType?] {
        [nil] + UtilityType.allCases.map(Optional.some)
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
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

                Picker(
                    L10n.text(.side, for: languageManager),
                    selection: $selectedSide
                ) {
                    ForEach(TacticsSide.allCases) { side in
                        Text(side.shortTitle)
                            .tag(side)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 150)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(utilityFilters, id: \.self) { utilityType in
                        let count = utilityType.map { utilityCounts[$0, default: 0] }
                            ?? allUtilityCount

                        TacticsFilterChip(
                            title: utilityType?.displayName(for: languageManager)
                                ?? L10n.text(.mapFilterAll, for: languageManager),
                            count: count,
                            color: utilityType?.color ?? selectionColor,
                            selectionColor: selectionColor,
                            isSelected: selectedUtilityType == utilityType,
                            isAvailable: utilityType == nil || count > 0
                        ) {
                            selectedUtilityType = utilityType
                        }
                    }
                }
            }
        }
        .padding(.horizontal, AppTheme.pagePadding)
        .padding(.top, 10)
        .padding(.bottom, 10)
    }
}

private struct TacticsFilterChip: View {
    let title: String
    let count: Int
    let color: Color
    let selectionColor: Color
    let isSelected: Bool
    let isAvailable: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                Circle()
                    .fill(isSelected ? Color.white : color)
                    .frame(width: 7, height: 7)

                Text(title)
                    .font(.subheadline.weight(.semibold))

                Text("\(count)")
                    .font(.caption2.weight(.bold).monospacedDigit())
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        isSelected
                            ? Color.white.opacity(0.20)
                            : AppTheme.primaryText.opacity(0.07)
                    )
                    .clipShape(Capsule())
            }
            .foregroundStyle(isSelected ? Color.white : AppTheme.primaryText)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? selectionColor : AppTheme.cardBackground)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(isSelected ? Color.clear : AppTheme.subtleBorder, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .disabled(!isAvailable)
        .opacity(isAvailable ? 1 : 0.42)
    }
}

private struct TacticsMapStyle {
    let accent: Color
    let secondary: Color
    let symbol: String

    static func style(for mapID: String) -> TacticsMapStyle {
        switch mapID {
        case "ancient":
            return TacticsMapStyle(
                accent: AppTheme.ancientGreen,
                secondary: .mint,
                symbol: "leaf.fill"
            )
        case "nuke":
            return TacticsMapStyle(
                accent: AppTheme.nukeBlue,
                secondary: .cyan,
                symbol: "atom"
            )
        default:
            return TacticsMapStyle(
                accent: AppTheme.accent,
                secondary: AppTheme.tacticalOrange,
                symbol: "scope"
            )
        }
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

    var shortTitle: String { rawValue }
}

#Preview {
    NavigationStack {
        TacticsView(maps: LineupStore.maps)
            .environmentObject(LanguageManager())
            .environmentObject(DeveloperSettings())
            .environmentObject(FavoriteStore())
    }
}
