# AimNade 本地化开发规范

## 支持语言

AimNade 支持 English 和简体中文。用户选择语言由 `LanguageManager` 管理，页面显示文本统一通过 `L10n.text(_:for:)` 读取。

## UI 文本规则

- SwiftUI 页面里的固定 UI 文字必须使用 `L10n.Key`，不能直接写死中文或英文。
- 页面标题、按钮、列表入口、Section 标题、占位文案、分类名称、道具类型显示都属于 UI 文本。
- 新增页面时，先在 `L10n.Key` 添加 key，再在 English 和简体中文分支补齐文案，最后在 View 中调用 `L10n.text`。
- 如果一个文案只有英文显示，例如地图名 `Mirage`，也要保留为本地化 key，英文和中文都返回 `Mirage`。

## 不放入 UI 本地化 key 的内容

- 道具教程内容从数据读取，例如 `UtilityLineup.name`、`description`、`throwMethod`。
- 图片资源名继续使用英文，例如 `mirage_window_smoke_position`。
- 代码变量名、数据 id、枚举 case 不汉化。

## 当前核心 key

- `maps`: 地图 / Maps
- `mirage`: Mirage / Mirage
- `tacticalMap2D`: 2D 战术地图 / 2D Tactical Map
- `utilityList`: 道具列表 / Utility List
- `categoryASite`: A 包点 / A Site
- `categoryBSite`: B 包点 / B Site
- `categoryMid`: 中路 / Mid
- `categoryTSide`: T 方 / T Side
- `categoryCTSide`: CT 方 / CT Side
- `smoke`: 烟 / Smoke
- `flash`: 闪 / Flash
- `molotov`: 火 / Molotov
- `he`: 雷 / HE
- `teachingImages`: 教学图片 / Teaching Images
- `startPosition`: 站位图 / Start Position
- `aimPoint`: 瞄点图 / Aim Point
- `result`: 落点效果 / Result
- `overview`: 概览 / Overview
- `name`: 名称 / Name
- `type`: 类型 / Type
- `side`: 阵营 / Side
- `category`: 分类 / Category
- `difficulty`: 难度 / Difficulty
- `position`: 位置 / Position
- `startArea`: 起始位置 / Start Area
- `targetArea`: 目标位置 / Target Area
- `throwMethod`: 投掷方式 / Throw Method
- `description`: 说明 / Description
- `developerMode`: 开发者模式 / Developer Mode
- `developerMapHint`: 拖动道具点调整地图坐标。 / Drag utility points to adjust map coordinates.
- `liveCoordinates`: 实时坐标 / Live Coordinates
- `lastEditedCoordinate`: 最近调整 / Last Edited
- `noEditedCoordinate`: 还没有调整点位。 / No edited coordinate yet.
- `copyCoordinates`: 复制坐标 / Copy Coordinates
- `copyJSON`: 复制 JSON / Copy JSON
- `coordinatesCopied`: 坐标已复制。 / Coordinates copied.
- `jsonCopied`: JSON 已复制。 / JSON copied.
- `startPoint`: 站位 / Start
- `targetPoint`: 目标 / Target
- `about`: 关于 / About
- `appDisplayName`: AimNade / AimNade
- `appName`: App 名称 / App Name
- `appIntro`: App 简介文案
- `creator`: 制作者 / Creator
- `creatorName`: 乐扣 / b1skelA
- `version`: 版本号 / Version
- `unofficialNotice`: 非官方声明 / Unofficial Notice
- `unofficialNoticeText`: 非官方声明文案
- `acknowledgements`: 鸣谢 / Acknowledgements
- `acknowledgementsText`: 鸣谢文案
- `mapFilterArea`: 区域 / Area
- `mapFilterUtilityType`: 道具类型 / Utility Type
- `mapFilterFeatured`: 推荐 / Featured
- `mapFilterAll`: 全部 / All
- `clusteredUtilities`: 道具 / Utilities
- `lineupVariants`: 道具丢法 / Lineup Variants
- `variantCount`: 变体数量文案
- `spawnRequirement`: 适用出生点 / 身位 / Spawn / Body Position
- `targetPoints`: 目标点 / Target Points
- `variantStartPoints`: 变体站位点 / Variant Start Points
- `lineConnections`: 站位到目标连线 / Line Connections

## 检查方式

提交前搜索 SwiftUI 文件中的 `Text("`、`Label("`、`Section("`、`navigationTitle("`。如果是固定 UI 文字，必须改成 `L10n.text(...)`。
