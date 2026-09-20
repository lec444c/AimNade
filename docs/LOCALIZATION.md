# AimNade 本地化开发规范

> 审计基线：2026-09-20。当前 `L10n.Key` 共 81 个，英文与简体中文分支均为 81/81 覆盖。

## 支持语言与语言选择

AimNade 支持 English 和简体中文，并提供“跟随系统”选项。

- `LanguageManager` 使用 `UserDefaults` 保存 `system` / `zhHans` / `en` 三档选择。
- 跟随系统时，首选语言以 `zh` 开头则使用简体中文，其余语言回退到英文。
- 固定 UI 文案统一通过 `L10n.text(_:for:)` 读取。
- JSON 业务内容通过 `LocalizedText { en, zhHans }` 读取。
- App 显示名由 `en.lproj/InfoPlist.strings` 与 `zh-Hans.lproj/InfoPlist.strings` 管理，当前两处均为 `AimNade`。

## 文案职责边界

### 必须使用 `L10n.Key`

- 页面与 Section 标题。
- 按钮、菜单、筛选器、搜索框、空状态与提示文案。
- 分类、道具类型、难度等固定枚举显示名。
- VoiceOver 等用户可见的辅助功能文案。

### 必须使用 `LocalizedText`

- 地图、道具组和投掷方案等随内容数据变化的名称。
- 投掷说明、站位要求、起止区域等教程业务文本。
- Mirage 的内容来自 `lineups_mirage.json`；Ancient / Nuke 当前仅在 `LineupStore` 中提供双语地图名，尚无道具内容。

### 不进入本地化系统

- 图片资源名、SF Symbols 名称、数据 ID 与 JSON 字段名。
- 代码变量名与枚举 case。
- `T` / `CT` 等游戏通用短标识。

> Ancient / Nuke 当前地图 JPEG 的中文标注已烘焙在图片中，切换英文不会改变图片内文字。这是资源限制，不属于 `L10n` 缺失；正式发布前还需确认图片授权并决定是否替换为可本地化资源。

## 新增或修改文案

1. 在 `L10n.Key` 增加或确认 key；需要数量时使用关联值，例如 `lineupCount(Int)`。
2. 在 `englishText(_:)` 与 `chineseText(_:)` 同步增加对应分支。
3. View 中通过 `L10n.text(_:for:)` 使用，不直接写固定中文或英文。
4. 数据内容继续使用 `LocalizedText`，不要把教程内容迁入 `L10n`。
5. 完成后执行本文末尾的覆盖、硬编码与构建检查。

## 当前 Key 清单（81）

以下清单与 `AimNade/Localization/L10n.swift` 对齐。关联值只在文档中标出参数类型。

<!-- key-inventory:start -->

### 导航、地图上下文与语言（14）

`maps`, `tactics`, `mapView`, `listView`, `mirage`, `mapPreviewOnly`, `mapDataPending`, `lineupCount(Int)`, `variantCount(Int)`, `settings`, `language`, `followSystem`, `simplifiedChinese`, `english`

### 功能入口文案（6）

`tacticalMap2D`, `utilityList`, `mapFeatureSubtitle`, `listFeatureSubtitle`, `searchFeatureSubtitle`, `favoritesFeatureSubtitle`

### 分类、道具类型与难度（11）

`categoryASite`, `categoryBSite`, `categoryMid`, `categoryTSide`, `categoryCTSide`, `smoke`, `flash`, `molotov`, `he`, `difficultyEasy`, `difficultyMedium`

### 详情与教学内容结构（18）

`overview`, `name`, `type`, `side`, `category`, `difficulty`, `teachingImages`, `startPosition`, `aimPoint`, `result`, `placeholder`, `position`, `startArea`, `targetArea`, `throwMethod`, `description`, `lineupSteps`, `notes`

### 关于页（11）

`about`, `appDisplayName`, `appName`, `appIntro`, `creator`, `creatorName`, `version`, `unofficialNotice`, `unofficialNoticeText`, `acknowledgements`, `acknowledgementsText`

### 列表筛选与详情（3）

`mapFilterAll`, `lineupVariants`, `spawnRequirement`

### 搜索（7）

`close`, `search`, `searchPrompt`, `searchHint`, `searchNoResults`, `searchResultGroup`, `searchResultVariant`

### 收藏、空状态与条目类型（11）

`favorites`, `favoriteGroups`, `favoriteVariants`, `addFavorite`, `removeFavorite`, `emptyFavorites`, `emptyFavoritesMessage`, `emptyUtilities`, `emptyUtilitiesMessage`, `variantSubtitle`, `groupSubtitle`

<!-- key-inventory:end -->

## 当前未引用的 Key

以下 11 个 key 在当前 Swift 调用点中没有引用，主要来自旧功能入口或旧独立搜索页：

`tacticalMap2D`, `utilityList`, `mapFeatureSubtitle`, `listFeatureSubtitle`, `searchFeatureSubtitle`, `favoritesFeatureSubtitle`, `mirage`, `searchHint`, `searchNoResults`, `searchResultGroup`, `searchResultVariant`

它们仍具备完整双语分支，但不代表对应旧界面仍存在。不要在普通本地化任务中顺手删除；如需清理，应单独确认全部调用面和文档影响。

## 审计与验证

### 1. 检查固定 UI 文案

```bash
rg -n 'Text\("[^"\\]*[A-Za-z\p{Han}]|Label\("[^"\\]*[A-Za-z\p{Han}]|Section\("[^"\\]*[A-Za-z\p{Han}]|navigationTitle\("[^"\\]*[A-Za-z\p{Han}]|Button\("[^"\\]*[A-Za-z\p{Han}]|TextField\("[^"\\]*[A-Za-z\p{Han}]' \
  AimNade/AimNadeApp.swift AimNade/Views --glob '*.swift'
```

结果为空才表示没有发现这一类直接硬编码。仍需人工检查插值、辅助功能文案和其他构造方式。

### 2. 检查 JSON 双语内容

```bash
jq -e '[.. | objects | select(has("en") or has("zhHans"))]
  | all(has("en") and has("zhHans") and (.en | length > 0) and (.zhHans | length > 0))' \
  AimNade/Data/lineups_mirage.json
```

### 3. 构建

```bash
xcodebuild -project AimNade.xcodeproj -scheme AimNade \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -configuration Debug build
```

当前没有测试 Target。涉及用户可见文案时，还应手动检查英文、简体中文与跟随系统三档语言。
