import Foundation

enum LineupSearch {
    static func matches(group: LineupGroup, query: String) -> Bool {
        let normalizedQuery = normalized(query)
        guard !normalizedQuery.isEmpty else {
            return true
        }

        return matches(query: normalizedQuery, terms: groupSearchTerms(for: group))
    }

    static func matches(variant: LineupVariant, query: String) -> Bool {
        let normalizedQuery = normalized(query)
        guard !normalizedQuery.isEmpty else {
            return true
        }

        return matches(query: normalizedQuery, terms: variantSearchTerms(for: variant))
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
