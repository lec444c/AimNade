import SwiftUI

struct LineupSearchView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var searchText = ""

    let map: Map

    private var results: [LineupSearchResult] {
        LineupSearch.results(for: searchText, in: map)
    }

    var body: some View {
        List {
            if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(L10n.text(.searchHint, for: languageManager))
                    .foregroundStyle(AppTheme.secondaryText)
            } else if results.isEmpty {
                EmptyStateView(
                    systemImage: "magnifyingglass",
                    title: L10n.text(.searchNoResults, for: languageManager)
                )
            } else {
                ForEach(results) { result in
                    NavigationLink {
                        destination(for: result)
                    } label: {
                        SearchResultRow(result: result)
                            .environmentObject(languageManager)
                    }
                    .searchCardRowStyle()
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(AppTheme.background)
        .navigationTitle(L10n.text(.search, for: languageManager))
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text(L10n.text(.searchPrompt, for: languageManager))
        )
    }

    @ViewBuilder
    private func destination(for result: LineupSearchResult) -> some View {
        switch result {
        case .group(let group):
            LineupGroupDetailView(group: group)
        case .variant(let group, let variant):
            LineupDetailView(group: group, variant: variant)
        }
    }
}

private struct SearchResultRow: View {
    @EnvironmentObject private var languageManager: LanguageManager

    let result: LineupSearchResult

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                MapMarkerView(type: result.utilityType, markerSize: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(result.title(for: languageManager))
                        .font(.headline)

                    Text(result.kindTitle(for: languageManager))
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }

            Text(result.subtitle(for: languageManager))
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .padding(AppTheme.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
    }
}

private extension View {
    func searchCardRowStyle() -> some View {
        self
            .listRowInsets(
                EdgeInsets(
                    top: 6,
                    leading: AppTheme.pagePadding,
                    bottom: 6,
                    trailing: AppTheme.pagePadding
                )
            )
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }
}

private enum LineupSearchResult: Identifiable {
    case group(LineupGroup)
    case variant(LineupGroup, LineupVariant)

    var id: String {
        switch self {
        case .group(let group):
            return group.id
        case .variant(let group, let variant):
            return "\(group.id)-\(variant.id)"
        }
    }

    var utilityType: UtilityType {
        switch self {
        case .group(let group), .variant(let group, _):
            return group.type
        }
    }

    func title(for languageManager: LanguageManager) -> String {
        switch self {
        case .group(let group):
            return group.targetName.value(for: languageManager)
        case .variant(_, let variant):
            return variant.name.value(for: languageManager)
        }
    }

    func kindTitle(for languageManager: LanguageManager) -> String {
        switch self {
        case .group:
            return L10n.text(.searchResultGroup, for: languageManager)
        case .variant:
            return L10n.text(.searchResultVariant, for: languageManager)
        }
    }

    func subtitle(for languageManager: LanguageManager) -> String {
        switch self {
        case .group(let group):
            return [
                group.type.displayName(for: languageManager),
                group.category.displayName(for: languageManager),
                group.side
            ].joined(separator: " · ")
        case .variant(let group, let variant):
            return [
                group.targetName.value(for: languageManager),
                variant.startArea.value(for: languageManager),
                variant.targetArea.value(for: languageManager),
                variant.difficultyDisplayName(for: languageManager)
            ].joined(separator: " · ")
        }
    }
}

private enum LineupSearch {
    static func results(for query: String, in map: Map) -> [LineupSearchResult] {
        let normalizedQuery = normalized(query)
        guard !normalizedQuery.isEmpty else {
            return []
        }

        var results: [LineupSearchResult] = []

        for group in map.lineupGroups {
            if matches(query: normalizedQuery, terms: groupSearchTerms(for: group)) {
                results.append(.group(group))
            }

            for variant in group.variants {
                if matches(query: normalizedQuery, terms: variantSearchTerms(for: variant)) {
                    results.append(.variant(group, variant))
                }
            }
        }

        return results
    }

    private static func groupSearchTerms(for group: LineupGroup) -> [String] {
        [
            group.id,
            group.mapId,
            group.targetName.en,
            group.targetName.zhHans,
            group.type.rawValue,
            group.side
        ] + group.type.searchTerms + group.category.searchTerms
    }

    private static func variantSearchTerms(for variant: LineupVariant) -> [String] {
        [
            variant.id,
            variant.name.en,
            variant.name.zhHans,
            variant.spawnRequirement.en,
            variant.spawnRequirement.zhHans,
            variant.startArea.en,
            variant.startArea.zhHans,
            variant.targetArea.en,
            variant.targetArea.zhHans,
            variant.throwMethod.en,
            variant.throwMethod.zhHans,
            variant.description.en,
            variant.description.zhHans,
            variant.difficulty
        ]
    }

    private static func matches(query: String, terms: [String]) -> Bool {
        let compactQuery = compacted(query)

        return terms.contains { term in
            let normalizedTerm = normalized(term)
            return normalizedTerm.contains(query) || compacted(normalizedTerm).contains(compactQuery)
        }
    }

    private static func normalized(_ text: String) -> String {
        text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .lowercased()
    }

    private static func compacted(_ text: String) -> String {
        text.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
    }
}

private extension UtilityType {
    var searchTerms: [String] {
        switch self {
        case .smoke:
            return ["Smoke", "烟"]
        case .flash:
            return ["Flash", "闪"]
        case .molotov:
            return ["Molotov", "火"]
        case .he:
            return ["HE", "Grenade", "雷"]
        }
    }
}

private extension LineupCategory {
    var searchTerms: [String] {
        switch self {
        case .aSite:
            return ["A Site", "A 包点"]
        case .bSite:
            return ["B Site", "B 包点"]
        case .mid:
            return ["Mid", "中路"]
        case .tSide:
            return ["T Side", "T 方"]
        case .ctSide:
            return ["CT Side", "CT 方"]
        }
    }
}

#Preview {
    NavigationStack {
        LineupSearchView(map: LineupStore.mirageMap)
            .environmentObject(LanguageManager())
            .environmentObject(FavoriteStore())
    }
}
