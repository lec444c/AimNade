import Foundation

enum L10n {
    enum Key {
        case maps
        case tactics
        case mapView
        case listView
        case mirage
        case mapPreviewOnly
        case mapDataPending
        case lineupCount(Int)
        case variantCount(Int)
        case settings
        case language
        case followSystem
        case simplifiedChinese
        case english
        case tacticalMap2D
        case utilityList
        case mapFeatureSubtitle
        case listFeatureSubtitle
        case searchFeatureSubtitle
        case favoritesFeatureSubtitle
        case categoryASite
        case categoryBSite
        case categoryMid
        case categoryTSide
        case categoryCTSide
        case smoke
        case flash
        case molotov
        case he
        case difficultyEasy
        case difficultyMedium
        case overview
        case name
        case type
        case side
        case category
        case difficulty
        case teachingImages
        case startPosition
        case aimPoint
        case result
        case placeholder
        case position
        case startArea
        case targetArea
        case throwMethod
        case description
        case lineupSteps
        case notes
        case about
        case appDisplayName
        case appName
        case appIntro
        case creator
        case creatorName
        case version
        case unofficialNotice
        case unofficialNoticeText
        case acknowledgements
        case acknowledgementsText
        case mapFilterAll
        case lineupVariants
        case spawnRequirement
        case close
        case search
        case searchPrompt
        case searchHint
        case searchNoResults
        case searchResultGroup
        case searchResultVariant
        case favorites
        case favoriteGroups
        case favoriteVariants
        case addFavorite
        case removeFavorite
        case emptyFavorites
        case emptyFavoritesMessage
        case emptyUtilities
        case emptyUtilitiesMessage
        case variantSubtitle
        case groupSubtitle
    }

    static func text(_ key: Key, for languageManager: LanguageManager) -> String {
        switch languageManager.contentLanguage {
        case .system, .en:
            return englishText(key)
        case .zhHans:
            return chineseText(key)
        }
    }

    private static func englishText(_ key: Key) -> String {
        switch key {
        case .maps:
            return "Maps"
        case .tactics:
            return "Tactics"
        case .mapView:
            return "Map"
        case .listView:
            return "List"
        case .mirage:
            return "Mirage"
        case .mapPreviewOnly:
            return "Map Preview"
        case .mapDataPending:
            return "Lineup data will be added later."
        case .lineupCount(let count):
            return "\(count) utility lineups"
        case .variantCount(let count):
            return "\(count) options"
        case .settings:
            return "Settings"
        case .language:
            return "Language"
        case .followSystem:
            return "Follow System"
        case .simplifiedChinese:
            return "简体中文"
        case .english:
            return "English"
        case .tacticalMap2D:
            return "2D Tactical Map"
        case .utilityList:
            return "Utility List"
        case .mapFeatureSubtitle:
            return "Browse utility targets on a clean tactical map."
        case .listFeatureSubtitle:
            return "Study lineups by site, mid, and side."
        case .searchFeatureSubtitle:
            return "Find utility by name, area, or type."
        case .favoritesFeatureSubtitle:
            return "Open saved groups and variants."
        case .categoryASite:
            return "A Site"
        case .categoryBSite:
            return "B Site"
        case .categoryMid:
            return "Mid"
        case .categoryTSide:
            return "T Side"
        case .categoryCTSide:
            return "CT Side"
        case .smoke:
            return "Smoke"
        case .flash:
            return "Flash"
        case .molotov:
            return "Molotov"
        case .he:
            return "HE"
        case .difficultyEasy:
            return "Easy"
        case .difficultyMedium:
            return "Medium"
        case .overview:
            return "Overview"
        case .name:
            return "Name"
        case .type:
            return "Type"
        case .side:
            return "Side"
        case .category:
            return "Category"
        case .difficulty:
            return "Difficulty"
        case .teachingImages:
            return "Images"
        case .startPosition:
            return "Start Position"
        case .aimPoint:
            return "Aim Point"
        case .result:
            return "Result"
        case .placeholder:
            return "Placeholder"
        case .position:
            return "Position"
        case .startArea:
            return "Start Area"
        case .targetArea:
            return "Target Area"
        case .throwMethod:
            return "Throw Method"
        case .description:
            return "Description"
        case .lineupSteps:
            return "Lineup Steps"
        case .notes:
            return "Notes"
        case .about:
            return "About"
        case .appDisplayName:
            return "AimNade"
        case .appName:
            return "App Name"
        case .appIntro:
            return "AimNade is a 2D tactical utility tool for Counter-Strike players. It helps players learn common lineups through map references, categorized lists, start position images, aim point images, and result references."
        case .creator:
            return "Creator"
        case .creatorName:
            return "b1skelA"
        case .version:
            return "Version"
        case .unofficialNotice:
            return "Unofficial Notice"
        case .unofficialNoticeText:
            return "This is an unofficial fan-made tactical tool. It is not affiliated with Valve or Counter-Strike."
        case .acknowledgements:
            return "Acknowledgements"
        case .acknowledgementsText:
            return "Thanks to the Counter-Strike community for lineup tutorials and tactical knowledge sharing."
        case .mapFilterAll:
            return "All"
        case .lineupVariants:
            return "Lineup Options"
        case .spawnRequirement:
            return "Spawn / Body Position"
        case .close:
            return "Close"
        case .search:
            return "Search"
        case .searchPrompt:
            return "Search locations, utility, or areas"
        case .searchHint:
            return "Search by utility name, variant, area, type, start position, or target."
        case .searchNoResults:
            return "No results found."
        case .searchResultGroup:
            return "Lineup Group"
        case .searchResultVariant:
            return "Lineup Option"
        case .favorites:
            return "Favorites"
        case .favoriteGroups:
            return "Favorite Lineup Groups"
        case .favoriteVariants:
            return "Favorite Lineup Options"
        case .addFavorite:
            return "Add Favorite"
        case .removeFavorite:
            return "Remove Favorite"
        case .emptyFavorites:
            return "No favorites yet."
        case .emptyFavoritesMessage:
            return "Tap the star on a lineup or variant to save it here."
        case .emptyUtilities:
            return "No utilities yet."
        case .emptyUtilitiesMessage:
            return "Try another filter or add more local lineup data later."
        case .variantSubtitle:
            return "Lineup Option"
        case .groupSubtitle:
            return "Lineup Group"
        }
    }

    private static func chineseText(_ key: Key) -> String {
        switch key {
        case .maps:
            return "地图"
        case .tactics:
            return "战术"
        case .mapView:
            return "地图"
        case .listView:
            return "列表"
        case .mirage:
            return "Mirage"
        case .mapPreviewOnly:
            return "地图预览"
        case .mapDataPending:
            return "道具数据待后续添加。"
        case .lineupCount(let count):
            return "\(count) 个道具点位"
        case .variantCount(let count):
            return "\(count) 个丢法"
        case .settings:
            return "设置"
        case .language:
            return "语言"
        case .followSystem:
            return "Follow System"
        case .simplifiedChinese:
            return "简体中文"
        case .english:
            return "English"
        case .tacticalMap2D:
            return "2D 战术地图"
        case .utilityList:
            return "道具列表"
        case .mapFeatureSubtitle:
            return "在简洁地图上浏览道具目标点。"
        case .listFeatureSubtitle:
            return "按包点、中路和阵营学习道具。"
        case .searchFeatureSubtitle:
            return "按名称、区域或类型快速查找。"
        case .favoritesFeatureSubtitle:
            return "查看已收藏的道具组和丢法。"
        case .categoryASite:
            return "A 包点"
        case .categoryBSite:
            return "B 包点"
        case .categoryMid:
            return "中路"
        case .categoryTSide:
            return "T 方"
        case .categoryCTSide:
            return "CT 方"
        case .smoke:
            return "烟"
        case .flash:
            return "闪"
        case .molotov:
            return "火"
        case .he:
            return "雷"
        case .difficultyEasy:
            return "简单"
        case .difficultyMedium:
            return "中等"
        case .overview:
            return "概览"
        case .name:
            return "名称"
        case .type:
            return "类型"
        case .side:
            return "阵营"
        case .category:
            return "分类"
        case .difficulty:
            return "难度"
        case .teachingImages:
            return "教学图片"
        case .startPosition:
            return "站位图"
        case .aimPoint:
            return "瞄点图"
        case .result:
            return "落点效果"
        case .placeholder:
            return "暂无图片"
        case .position:
            return "位置"
        case .startArea:
            return "起始位置"
        case .targetArea:
            return "目标位置"
        case .throwMethod:
            return "投掷方式"
        case .description:
            return "说明"
        case .lineupSteps:
            return "投掷步骤"
        case .notes:
            return "备注"
        case .about:
            return "关于"
        case .appDisplayName:
            return "AimNade"
        case .appName:
            return "App 名称"
        case .appIntro:
            return "AimNade 是一个面向 CS 玩家制作的 2D 战术道具工具。你可以通过地图参考、分类列表、站位图、瞄点图和落点效果快速学习常用道具。"
        case .creator:
            return "制作者"
        case .creatorName:
            return "乐扣"
        case .version:
            return "版本号"
        case .unofficialNotice:
            return "非官方声明"
        case .unofficialNoticeText:
            return "本 App 是玩家自制的非官方战术工具，与 Valve 或 Counter-Strike 官方无关。"
        case .acknowledgements:
            return "鸣谢"
        case .acknowledgementsText:
            return "感谢所有 CS 玩家社区的道具教学与战术分享。"
        case .mapFilterAll:
            return "全部"
        case .lineupVariants:
            return "道具丢法"
        case .spawnRequirement:
            return "适用出生点 / 身位"
        case .close:
            return "关闭"
        case .search:
            return "搜索"
        case .searchPrompt:
            return "搜索点位、道具或区域"
        case .searchHint:
            return "可搜索道具名称、丢法、区域、类型、站位或目标点。"
        case .searchNoResults:
            return "没有找到结果。"
        case .searchResultGroup:
            return "道具组"
        case .searchResultVariant:
            return "丢法"
        case .favorites:
            return "收藏"
        case .favoriteGroups:
            return "收藏道具组"
        case .favoriteVariants:
            return "收藏丢法"
        case .addFavorite:
            return "添加收藏"
        case .removeFavorite:
            return "取消收藏"
        case .emptyFavorites:
            return "暂无收藏"
        case .emptyFavoritesMessage:
            return "点击道具组或丢法右上角的星标即可收藏。"
        case .emptyUtilities:
            return "暂无道具"
        case .emptyUtilitiesMessage:
            return "可以切换筛选条件，或后续继续添加本地道具数据。"
        case .variantSubtitle:
            return "丢法"
        case .groupSubtitle:
            return "道具组"
        }
    }
}
