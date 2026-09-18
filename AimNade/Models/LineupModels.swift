import Foundation
import SwiftUI

struct Map: Identifiable, Hashable, Codable {
    let id: String
    let name: LocalizedText
    let imageName: String
    let lineupGroups: [LineupGroup]
}

struct LineupGroup: Identifiable, Hashable, Codable {
    let id: String
    let mapId: String
    let targetName: LocalizedText
    let type: UtilityType
    let side: String
    let category: LineupCategory
    let targetMapX: Double
    let targetMapY: Double
    let isFeatured: Bool
    let variants: [LineupVariant]

    var targetCoordinate: CGPoint {
        CGPoint(x: targetMapX, y: targetMapY)
    }
}

struct LineupVariant: Identifiable, Hashable, Codable {
    let id: String
    let name: LocalizedText
    let spawnRequirement: LocalizedText
    let startArea: LocalizedText
    let targetArea: LocalizedText
    let throwMethod: LocalizedText
    let description: LocalizedText
    let difficulty: String
    let startMapX: Double
    let startMapY: Double
    let targetMapX: Double
    let targetMapY: Double
    let positionImageName: String
    let aimImageName: String
    let resultImageName: String

    var startCoordinate: CGPoint {
        CGPoint(x: startMapX, y: startMapY)
    }

    var targetCoordinate: CGPoint {
        CGPoint(x: targetMapX, y: targetMapY)
    }

    func difficultyDisplayName(for languageManager: LanguageManager) -> String {
        switch difficulty {
        case "Easy":
            return L10n.text(.difficultyEasy, for: languageManager)
        case "Medium":
            return L10n.text(.difficultyMedium, for: languageManager)
        default:
            return difficulty
        }
    }
}

enum LineupCategory: String, CaseIterable, Hashable, Codable {
    case aSite
    case bSite
    case mid
    case tSide
    case ctSide

    func displayName(for languageManager: LanguageManager) -> String {
        L10n.text(localizationKey, for: languageManager)
    }

    private var localizationKey: L10n.Key {
        switch self {
        case .aSite:
            return .categoryASite
        case .bSite:
            return .categoryBSite
        case .mid:
            return .categoryMid
        case .tSide:
            return .categoryTSide
        case .ctSide:
            return .categoryCTSide
        }
    }
}

enum UtilityType: String, CaseIterable, Hashable, Codable {
    case smoke = "Smoke"
    case flash = "Flash"
    case molotov = "Molotov"
    case he = "HE"

    var symbol: String {
        switch self {
        case .smoke:
            return "S"
        case .flash:
            return "F"
        case .molotov:
            return "M"
        case .he:
            return "H"
        }
    }

    var color: Color {
        switch self {
        case .smoke:
            return AppTheme.smokeColor
        case .flash:
            return AppTheme.flashColor
        case .molotov:
            return AppTheme.molotovColor
        case .he:
            return AppTheme.heColor
        }
    }

    func displayName(for languageManager: LanguageManager) -> String {
        L10n.text(localizationKey, for: languageManager)
    }

    private var localizationKey: L10n.Key {
        switch self {
        case .smoke:
            return .smoke
        case .flash:
            return .flash
        case .molotov:
            return .molotov
        case .he:
            return .he
        }
    }
}
