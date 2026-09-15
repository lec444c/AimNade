# AimNade Project Status

> 本文件是 Codex 与 DSH 共用的**进度快照**，每次完成任务后必须更新（规则见 `AGENTS.md` 第 10 节）。
> 最后更新：2026-09-16
> 基线提交：`737fdaf`（`Add gitignore for Xcode project`，分支 `main`，与 `origin/main` 同步）
> 验证方式：全量阅读仓库源码 + 实际执行 `xcodebuild` 构建 → **BUILD SUCCEEDED**（Xcode 27.0 / 27A266a，iPhone 17 + iOS 26.5 模拟器）

---

## Current Version

| 项 | 值 | 来源 |
|---|---|---|
| Marketing Version | `1.0` | `project.pbxproj` 的 `MARKETING_VERSION` |
| Build Version | `1` | `project.pbxproj` 的 `CURRENT_PROJECT_VERSION` |
| Bundle Identifier | `com.example.CSTacticsApp` | `project.pbxproj`（**仍是模板默认值，未改成正式域名**，见 Known Issues） |
| 显示名 | `AimNade` | `en.lproj` / `zh-Hans.lproj` 的 `CFBundleDisplayName` |
| Deployment Target | iOS 17.0 | `IPHONEOS_DEPLOYMENT_TARGET` |
| 阶段 | Mirage 单地图 MVP，功能闭环；**内容与资源缺口是当前唯一的主要短板** | 本文件第 2–4 节 |

## Current Goal

把 Mirage 单地图 MVP 从"功能可用"推进到"可交付"，**优先级已在 2026-09-16 修订**（真实教学截图允许继续使用占位图）：

1. **配置正式 App Icon 与 Accent Color**（P0-1，当前最高优先级）。
2. **对当前 V1 做一次完整产品流程检查**（P0-2）：首页 / 2D 地图 / 道具列表 / 搜索 / 收藏 / LineupGroup / LineupVariant / 教学图片占位 / About / 中英切换。只检查现有实现与明显问题，**不新增大功能**。
3. **专项 localization audit**（P0-3）：修正 `docs/LOCALIZATION.md` 与实际 `L10n.Key` 的差异，**不要为了补 key 重构 App**。
4. 内容填充（P1，**不阻塞交付**）：录入真实 Mirage 道具数据；补齐 18 张教学图片（就绪前占位图可继续使用）。
5. 明确标记占位/示例数据，避免被误当作已核实的真实道具数据。

完整的优先级拆分见 `## Next`。

## Completed

> 以下每一条都已对照源码确认，不是根据 README 推断。

### 工程基线

- 单一 target `CSTacticsApp`（`productType = com.apple.product-type.application`），纯 `.xcodeproj`。
- Swift 5 + SwiftUI，iOS 17.0，设备族 `1,2`（iPhone + iPad）。
- **零第三方依赖**（无 SPM / CocoaPods / Carthage），**无测试 target**。
- `xcodebuild ... build` 实测 `BUILD SUCCEEDED`；构建产物 `CSTacticsApp.app` 内确认打包了 `lineups_mirage.json`、`Assets.car`、`en.lproj`、`zh-Hans.lproj`。
- 全仓无 `TODO` / `FIXME` / `HACK` 遗留标记。

### 数据层与模型

- `Models/LineupModels.swift`：`Map` → `LineupGroup` → `LineupVariant` 三级 `Codable` 模型。
- `UtilityType`（`Smoke` / `Flash` / `Molotov` / `HE`）与 `LineupCategory`（`aSite` / `bSite` / `mid` / `tSide` / `ctSide`）枚举齐备，各自带本地化显示名与配色。
- `Data/LineupStore.swift`（29 行）：从 Bundle 读 `lineups_mirage.json`，失败时回退到空 `Map`。
- `Data/lineups_mirage.json`（268 行）：已接入 Xcode Resources 构建阶段，确认被真实打包。
- 数据自提交 `b4fb017`（`Load Mirage lineups from local JSON`，PR #35）由硬编码迁移为 JSON 驱动。
- 当前数据自检通过：ID 唯一、坐标全部落在 `0…1`、枚举取值合法。

### 2D 战术地图

- 单指平移 / 双指缩放（`UIScrollView`，通过 `ZoomableScrollView` 桥接，`minScale 1.0` / `maxScale 4.0`）+ 双击缩放（`doubleTapScale 2.5`，再双击复位）。
- 按缩放级别自适应阈值的点位聚类（`92 / 76 / 52 / 36`），聚类内弹出 `ClusterLineupSheet` 选择具体道具组。
- 区域过滤（推荐 / A 包点 / B 包点 / 中路 / T 方 / CT 方），默认落在 **"推荐"**（只显示 `isFeatured: true`）。
- 道具类型过滤（全部 / 烟 / 闪 / 火 / 雷）。
- 点击点位 → `navigationDestination` 进入道具组详情。
- 空数据时地图上叠加 `EmptyStateView`。

### 开发者模式

- `DeveloperSettings` 开关持久化到 `UserDefaults`。
- 目标点 / 变体起点 / 连接线的显示开关。
- 点位拖动（开发者模式下平移手势降级为双指，避免与拖动冲突）。
- 实时坐标显示、复制单个坐标、复制整份坐标 JSON 到剪贴板。
- **坐标编辑只存在于页面 `@State`，不写回 JSON**（已按此约束确认代码）。

### 列表、详情、搜索、收藏、设置、关于

- 首页：`MirageDetailView` 4 张功能卡片（2D 战术地图 / 道具列表 / 搜索 / 收藏），进入后所有入口可用。
- 道具列表：`UtilityListView` 按 `LineupCategory` 分组浏览道具组，带类型/分类徽章与方案数。
- 道具组详情：`LineupGroupDetailView` 概览信息 + 方案卡片列表 + 整组收藏。
- 投掷方案详情：`LineupDetailView` 概览 / 位置 / 投掷步骤 / 教学图片折叠区 / 备注 + 单方案收藏。
- 教学图片：折叠区 + 全屏分页预览（`TabView.page`）+ 图片缩放（`ZoomableImageView`）。**结构完整，但资源缺失 → 实际显示占位图。**
- 搜索：`LineupSearchView` 中英文全文检索。道具组的检索字段为 ID / mapId / 名称 / 类型 / 阵营 / 分类；方案的检索字段为 ID / 名称 / 出生点·身位要求 / 起止区域 / 投掷方式 / 说明 / 难度。查询与字段都做大小写与变音符折叠、并支持去空格匹配（`"asite"` 能命中 `"A Site"`）——相关中英检索词表目前硬编码在 `LineupSearchView.swift` 文件的私有扩展里。结果可跳转到道具组或方案详情。
- 收藏：`FavoriteStore` 同时维护道具组与方案两组 ID 集合，`UserDefaults` 持久化；两个详情页都有星标按钮，`FavoritesView` 分区展示并复用详情页作为目标页。
- 设置：`SettingsView` 语言选择（跟随系统 / 简体中文 / 英文）+ 开发者模式开关 + 关于页入口。
- 关于：`AboutView` 作者头像（`creator_avatar`）、作者名、版本号、非官方声明、鸣谢。

### 本地化与 UI Design System

- `LanguageManager` 三档语言（跟随系统 / 简体中文 / 英文），`UserDefaults` 持久化；`L10n`（`L10n.Key` 95 个 case，中英双语分支齐全）+ `LocalizedText`（JSON 业务内容双语）。
- `Theme/AppTheme.swift`：颜色、圆角、间距的唯一来源。
- `Views/Components/`：`FeatureCard` / `MapMarkerView` / `UtilityBadge` 已抽出且在多个页面复用；`Views/EmptyStateView.swift` 统一空状态。
- 复用核实：`MapMarkerView` 被 5 个文件引用，`UtilityBadge` 被 3 个，`EmptyStateView` 被 4 个，`AppTheme` 被 14 个。
- 界面使用系统语义色，自带深色模式；关键按钮有 `accessibilityLabel`；`Views/` 下已无硬编码的固定 UI 文案（仅剩纯数字插值与已本地化的插值）。

## In Progress

### 工作区未提交改动（均为非功能改动）

```
 M CSTacticsApp.xcodeproj/project.pbxproj
 M CSTacticsApp.xcodeproj/xcshareddata/xcschemes/CSTacticsApp.xcscheme
?? AGENTS.md
?? CODEX.md
?? PROJECT_STATUS.md
```

- `project.pbxproj` / `.xcscheme` 的 diff **全部是 Xcode 27 打开工程产生的升级噪声**：`LastUpgradeCheck` 1500→2700、`LastUpgradeVersion` 1500→2700、新增 `STRING_CATALOG_GENERATE_SYMBOLS = YES` 与 `CLANG_ANALYZER_LOCALIZABILITY_NONLOCALIZED = YES`、`Localization` group 与 `PBXVariantGroup` 段落顺序调整。**未改动任何 App 行为。**
- 三个 Markdown 交接/说明文档**均未被 git 跟踪**，有丢失风险，建议纳入版本控制。
- 结论：没有"改到一半的功能代码"，当前是**干净的功能基线 + 待整理的工程文件与文档**。

### 尚未收敛的能力缺口

- **18 张教学图片全部缺失**（详见 Known Issues）。**已确认不阻塞交付**：真实截图就绪前占位图可继续使用，已降级为 P1 内容填充任务。
- **内容体量小且为占位数据**：3 个道具组 / 6 个投掷方案，全部 T 方 Smoke。
- **JSON 加载失败路径不可见**：当前静默回退空 `Map`。已确认不是最终设计，优化方向见 `## Next` P1 第 4 项与 Known Issues 第 6 条。
- `docs/LOCALIZATION.md` 与实际本地化 key 存在差异（登记 61 / 实际 95，差 34 个）。已排为 P0-3，做一次专项 localization audit **修正文档**（不重构 App），见 `## Next` P0 第 3 项。
- 无测试覆盖。

## Next

> 范围纪律：**V1 只做 Mirage**。以下各项都不得引入 3D、视频、登录、后端或用户投稿。
> **优先级已修订（2026-09-16）：真实教学截图允许继续使用占位图，因此"补齐 18 张教学图片"不再是最高优先级**，改为内容填充类收尾任务（见 P1-10）；当前最高优先级是 P0-1。
> P0 的三项都属于"在当前实现上做检查或配置"，**不要因此新增大功能**。

### P0 — 交付前置与完整性确认

1. **配置正式 App Icon 与 Accent Color**（当前最高优先级）。
   - `AppIcon.appiconset/Contents.json` 无 `filename` → 没有实际图标；`AccentColor.colorset/Contents.json` 无颜色值 → Accent Color 未生效。
   - 上架与观感的硬前置，成本极低，且**不需要改任何 Swift 代码**。
2. **对当前 V1 做一次完整产品流程检查**：只检查现有实现与明显问题，**不新增大功能**。
   - 逐项走查：Mirage 首页 / 2D 地图 / 道具列表 / 搜索 / 收藏 / LineupGroup / LineupVariant / 教学图片占位 / About / 中英切换。
   - 检查内容：是否能正常进入、状态是否正确（含空状态）、中英两档文案是否都正确、深色模式下是否可读、有无崩溃或明显布局问题。
   - **已知可接受项**：教学图片显示占位图属预期行为，**不要把它记为新缺陷**（见第 10 项）。
   - 发现的问题按"明显问题"与"新功能需求"分类记录：明显问题可修，新功能需求只登记进本文件，不在本轮实现。
3. **专项 localization audit**：`docs/LOCALIZATION.md` 的"当前核心 key"清单只登记 61 个 key，实际 `L10n.Key` 有 95 个，**存在 34 个差异**。
   - 目标：**修正文档与实际 key 的差异**，让规范文档重新可用于交接。
   - audit 范围：比对 `L10n.Key` 与实际清单、确认中英文双语分支无遗漏、确认 `Views/` 下无硬编码文案、把 V1 范围约束补进规范文档。
   - **约束：不要为了补 key 而重构 App。** 只改文档；若发现代码侧真正不一致（例如某 key 只有英文没有中文），单独记录并按需最小修复，不做结构性改动。

### P1 — 数据可靠性与内容填充

4. **JSON 加载失败的可观察化**（已确认不是最终设计，静默 fallback 不得长期掩盖数据错误）：
   - **Debug 环境**输出明确的 JSON decode / load 错误（带文件名与具体解码失败原因）。
   - **Release / UI 层**显示合理的 empty state，而不是让用户面对一个无解释的空列表。
   - 保留 fallback 本身（防止 App crash）没有问题，**要改的是"静默"**。
   - 当前 `LineupStore` 的 `catch` 块为空，未修改 Swift 代码；此项属于后续任务。
5. **建立占位数据的显式标记机制**：当前 3 组 / 6 方案属于占位/示例数据（数值坐标为手工挑选、教学图不存在、未与真实游戏对拍）。
   - 说明：教学图**允许继续使用占位图**（2026-09-16 决定），这只意味着"占位状态可以长期存在"，**不意味着这些数据可以被当作已核实的真实数据**。
   - 最低要求：在文档与提交信息中持续明确标注。
   - 可选增强：为模型增加可选字段（如 `isPlaceholder`）并在 UI 上显示提示——**属于数据模型变更，需先确认再动手**（见 Known Issues 的待确认项）。
6. 数据校验：ID 唯一性、坐标范围、图片资源存在性。
7. **更新 `README.md`**：它只用于面向开发者/用户描述项目，**不作为 AI 进度日志**；详细进度只放在本文件。当前 README 仍写"1 张地图 / 10 个静态道具点"，与真实状态不符。
   - 它属已跟踪文件，此前几轮边界是"只提交交接文档"，故一直未改。
8. 扩充 Mirage 内容：先补 B 包点、CT 方两个空洞分类，再补 Flash / Molotov / HE。**扩充前必须先确定真实数据来源与核验方式**（见 Next Agent Handoff 的风险项）。
9. **录入真实 Mirage 道具数据**：取代当前占位/示例数据，并记录来源与核验方式。
10. **补齐 18 张教学图片**（**已降级为内容填充收尾任务**，2026-09-16 决定）：真实教学截图尚未就绪期间，**占位图可以继续使用，不阻塞交付**。
    - 资源名清单（6 个前缀 × `_position` / `_aim` / `_result` = 18 个）保留在 `## Next Agent Handoff` 中，需要时可查。
    - **图片的来源与授权需先确认**（见 Known Issues 第 18 条），这是真正的前置条件，而不是优先级问题。

### P2 — 让代码可继续演进

11. 拆分 `TacticalMapView.swift`：把地图渲染、过滤、聚类、坐标换算、缩放容器、开发者工具拆成独立文件 / 类型。
12. 建立测试 target：优先覆盖 JSON 解码、搜索匹配、聚类、坐标换算、收藏持久化——全是纯函数，成本低、回归收益高。

### P3 — 体验打磨

13. 验证 iPad 布局、横屏、Dynamic Type、VoiceOver、深色模式，以及大量点位下的地图性能。
14. 完善开发者数据工作流：在保持"不写回仓库"安全边界的前提下，明确坐标导出 → 校验 → 更新 JSON 的流程。

### 条件性任务（等触发条件出现再做）

15. **把 `MapListView` 接入根导航**：**已确认是刻意设计**（V1 只做 Mirage，用户不需要先看地图列表）。
    - 触发条件：**开始增加第二张地图时**，才把它提升为正式任务。
    - 届时应一并把 `MirageDetailView` 等 Mirage 专用命名泛化为 `MapDetailView`。
    - **在此之前维持低优先级，不要顺手"修好"它。**

## V1 Scope

**V1 只做 Mirage 这一张地图。**

包含：

- 2D 战术地图（点位、过滤、聚类、缩放、点击进详情）。
- 截图教学：每个投掷方案用「站位图 / 瞄点图 / 结果图」三张截图讲解。
- 道具分类列表（按 A 包点 / B 包点 / 中路 / T 方 / CT 方分组）。
- 中英文全文搜索。
- 收藏（道具组 + 投掷方案，本地持久化）。
- 道具组详情、投掷方案详情。
- 设置页与关于页。
- 简体中文 + 英文双语。

## Not Planned For V1

- ❌ 3D 地图或 3D 视角预览
- ❌ 视频教学
- ❌ 登录 / 账号体系
- ❌ 后端服务 / 云同步
- ❌ 用户投稿 / UGC

> 说明：`UtilityType` 已含 Flash / Molotov / HE，`LineupCategory` 已含 B 包点 / CT 方，`MapListView` 已实现，`CODEX.md` 的 v1.5 / v2.0 路线图也提到更多地图与社区功能——**这些都属于枚举预留、页面预留或未来版本规划，不是 V1 范围**。不要因为它们"已经在代码里"就当成待完成的 V1 任务。

## Important Architecture

轻量分层、View 驱动的 SwiftUI 单体架构。**没有**独立的 ViewModel / Repository / Service 协议层，不属于严格 MVVM。

### 入口与导航

- `CSTacticsApp/CSTacticsAppApp.swift` 是 `@main` 入口。
- 注入三个全局 `ObservableObject`：`LanguageManager`、`DeveloperSettings`、`FavoriteStore`。
- 根导航：`NavigationStack` **直接进入 `MirageDetailView(map: LineupStore.mirageMap)`**，右上角齿轮进设置。
- `Views/MapListView.swift` 已实现地图列表页（含自己的 `NavigationStack`），但**未接入启动流程**。全仓除 pbxproj 与文档外无任何引用。

### 数据模型

- `Map { id, name: LocalizedText, imageName, lineupGroups: [LineupGroup] }`
- `LineupGroup { id, mapId, targetName, type: UtilityType, side: String, category: LineupCategory, targetMapX/Y, isFeatured, variants: [LineupVariant] }`
- `LineupVariant { id, name, spawnRequirement, startArea, targetArea, throwMethod, description, difficulty: String, startMapX/Y, targetMapX/Y, positionImageName, aimImageName, resultImageName }`
- 所有坐标都是 **`0…1` 归一化值**，通过 `fittedImageRect` 换算成屏幕坐标；JSON 字段名必须与模型逐字一致，否则整体解码失败（解码是全有或全无的）。
- `difficulty` 是 `String`（当前取值 `Easy` / `Medium`），不是枚举，未知值会原样显示。

### 数据流

`lineups_mirage.json`（Bundle 资源）→ `LineupStore.mirageMap`（`static let`，进程内只读一次）→ 各页面通过参数接收 `Map` → 搜索/过滤/聚类都在内存中对 `map.lineupGroups` 做计算。

### 文件清单（23 个 Swift 文件，3578 行）

| 目录 | 文件 |
|---|---|
| 根 | `CSTacticsAppApp.swift` |
| `Models/` | `LineupModels.swift`(140) / `FavoriteStore.swift`(68) / `DeveloperSettings.swift`(15) |
| `Data/` | `LineupStore.swift`(29) / `lineups_mirage.json`(268) |
| `Localization/` | `L10n.swift`(500) / `LanguageManager.swift`(39) / `LocalizedText.swift`(15) |
| `Theme/` | `AppTheme.swift`(19) |
| `Views/` | `TacticalMapView.swift`(1114) / `LineupDetailView.swift`(437) / `LineupSearchView.swift`(274) / `LineupGroupDetailView.swift`(159) / `FavoritesView.swift`(142) / `AboutView.swift`(138) / `UtilityListView.swift`(79) / `MirageDetailView.swift`(80) / `SettingsView.swift`(49) / `MapListView.swift`(45) / `EmptyStateView.swift`(44) |
| `Views/Components/` | `MapMarkerView.swift`(68) / `UtilityBadge.swift`(56) / `FeatureCard.swift`(39) |
| 本地化资源 | `en.lproj/InfoPlist.strings` / `zh-Hans.lproj/InfoPlist.strings`（均只含 `CFBundleDisplayName`） |

## Important Rules

长期约束的完整版本在 **`AGENTS.md`**，这里只列最容易被违反的几条：

1. **V1 只做 Mirage**；不做 3D、不做视频、不做登录、不做后端、不做用户投稿。
2. **所有新增 UI 文案必须走现有本地化系统**（`L10n.Key` + 英文 + 简体中文三处同步），禁止硬编码。
3. **图片资源名、代码变量名、数据 ID 使用英文。**
4. **不编造真实 CS 道具数据**；当前允许使用明确标记的占位数据。
5. **修改前必须先检查已有实现**，复用 `AppTheme` / `FeatureCard` / `MapMarkerView` / `UtilityBadge` / `EmptyStateView`，避免重复造组件。
6. **不擅自大规模重构数据模型**（`LineupModels.swift`）。
7. **保持搜索、收藏、地图、详情页功能兼容**，不删除既有功能。
8. **开发者模式的坐标拖动不得添加写回逻辑**。
9. **不允许在没有明确理由时修改无关文件**；不提交 Xcode 版本升级产生的工程文件噪声。
10. **一个任务对应一个清晰的 Git commit；完成后必须更新本文件。**

## Known Issues

### 🔴 交付前置（P0，必须先做）

1. **`AppIcon.appiconset/Contents.json` 无 `filename` 字段** → 没有实际 App 图标（只有一条 `{idiom: universal, platform: ios, size: 1024x1024}`）。上架硬前置，**当前最高优先级**（`## Next` P0-1）。
2. **`AccentColor.colorset/Contents.json` 无颜色值** → Accent Color 未生效（`colors` 数组只有 `{idiom: universal}`）。
   - 连带效应：`AppTheme.accent = Color.accentColor`，被 `UtilityBadge.side` / `.category`、`FilterChip` 选中态、`ClusterPoint` 背景共用——**当前实际渲染为系统默认蓝**；配置颜色后这些位置会整体变色，需回归确认（尤其深色模式）。

### 🟠 数据与内容

3. **18 张教学图片资源 100% 缺失。** JSON 中每个 variant 声明 3 张图（`positionImageName` / `aimImageName` / `resultImageName`），3 组 × 2 方案 × 3 张 = 18 个资源名，**在 `Assets.xcassets` 中一个都不存在**。界面因此显示 `PreviewPlaceholderView` 占位。
   现有 imageset 只有 2 个：`mirage_map`、`creator_avatar`。
   - **严重度已下调（2026-09-16）**：真实教学截图允许继续使用占位图，**此项不阻塞交付**，属 P1 内容填充任务（`## Next` P1-10）。
4. **当前 Mirage 内容是占位/示例数据**，不得描述为"已核实的真实道具数据"：数值坐标为手工挑选、教学图片不存在、内容未与真实游戏对拍、JSON 中没有任何来源或可信度标记字段。
5. 内容覆盖极小：仅 **3 个道具组 / 6 个投掷方案，全部为 T 方 Smoke**。Flash / Molotov / HE 三类道具与 B 包点、CT 方两个分类在代码中已支持但数据为空。
6. **JSON 加载失败是"静默失败"（已确认不是最终设计）。** `LineupStore` 在 JSON 缺失或解码失败时回退到空 `Map`，`catch` 块为空——用户只看到空列表，没有任何错误提示。
   - 保留 fallback 以防止 App crash 没有问题；**要改的是"静默"**。
   - 后续优化方向：**Debug 环境**输出明确的 JSON decode / load 错误；**Release / UI 层**显示合理的 empty state；不通过静默 fallback 长期掩盖数据错误。
   - 详见 `## Next` P1 第 4 项。测试资源目录 `Data/` 下只有 `lineups_mirage.json`（V1 只支持 Mirage 是刻意设计）。
7. 无 JSON 校验、无 ID 唯一性检查、无坐标范围检查、无图片资源存在性检查。

### 🟡 代码债

8. `Views/TacticalMapView.swift` 单文件 **1114 行**，内含 13 个 `private struct` + 3 个 `private enum` + 1 个 `Coordinator` 类（共 17 个内部类型），地图渲染 / 过滤 / 聚类 / 坐标换算 / 缩放容器 / 开发者工具全部堆在一起。
9. `Views/MapListView.swift` 已实现但未接入根导航，用户看不到地图列表。**已确认是刻意设计**——V1 只做 Mirage，不需要地图列表前置；等开始增加第二张地图时再提升优先级（见 `## Next` 条件性任务）。
10. **无测试 target**：搜索、聚类、坐标换算、收藏持久化、JSON 解码全部没有自动化覆盖；构建通过是唯一可自动化的验证手段。
11. 地图缩放上限 4.0（`ZoomableScrollView` 的 `maxScale`），在 iPad 或大尺寸屏幕上的清晰度**待确认**。
12. `LineupModels.swift` 中定义了名为 `Map` 的结构体，与 Swift 标准库（以及部分框架）的 `Map` 同名，跨模块引用时**可能产生歧义**（当前可编译，属命名隐患）。

### 🔵 文档与工程

13. **`LOCALIZATION.md` 与实际本地化 key 存在差异，需进行一次专项 localization audit。** 具体：`docs/LOCALIZATION.md` 的"当前核心 key"清单登记 61 个，实际 `L10n.Key` 有 95 个，差 34 个（搜索、收藏、设置、空状态相关）；该文档也未提及 V1 范围硬约束。
    - 已排为 **P0-3**：目标是**修正文档与实际 key 的差异**，让规范文档重新可用于交接。
    - **约束：不要为了补 key 而重构 App。** 详见 `## Next` P0 第 3 项。
14. `README.md` 定位已明确：**只用于面向开发者/用户描述项目，不作为 AI 进度日志**，详细进度只放在本文件（`PROJECT_STATUS.md`）。
    - 当前内容**已过期**：仍写"1 张地图 / 10 个静态道具点 / 每个 lineup 一个详情页"，与实际的 3 组 / 6 方案 + 搜索 + 收藏 + 本地化 + 开发者模式不符。
    - 但 `README.md` **是已跟踪文件**，修改它会越过本轮"只提交交接文档"的边界 → 本轮未改，已登记为 `## Next` P0 第 4 项。
15. `AGENTS.md` 与 `PROJECT_STATUS.md` 在本轮之前**均未被 git 跟踪**，有丢失风险；本轮已提交纳入（见 `## Last Work`）。
    - `CODEX.md` **仍未被跟踪**：它属于既有的项目说明书，不属于本轮交接文档范围，本轮未提交、未修改。
16. **Bundle Identifier 仍是模板默认值 `com.example.CSTacticsApp`**，未改成正式域名，**上架前必须修改**。

### ❓ 待确认

17. **是否给数据模型增加占位标记字段**（如 `LineupVariant.isPlaceholder`）？当前 schema 没有该字段，而规则要求占位数据必须明确标记。涉及 `LineupModels.swift` + JSON 变更，需先确认。
18. **真实 CS 道具数据的来源与授权**：图片和数据的版权归属直接决定 V1 能否安全发布，目前没有任何来源记录。
19. `CODEX.md` 是否纳入 git？它内容详实且与源码一致，但纳管决定与提交时机需要单独明确，**不要与文档清理混在同一次提交里**。
20. `AboutView` 显示的版本号来自 `Bundle.main` 的 `CFBundleShortVersionString`（缺失时回退 `"1.0"`）；而 App 名称走的是 `L10n` 常量而非 Bundle。是否统一为只读 Bundle 元数据，待确认。

## Last Work

**任务**：全面复核仓库真实状态，建立 Codex 与 DSH 共用的项目交接机制，并按确认的 5 项决定收尾。

**做了**：

- 通读仓库全部文档（`README.md`、`AGENTS.md`、`PROJECT_STATUS.md`、`CODEX.md`、`docs/LOCALIZATION.md`）、23 个 Swift 文件、`lineups_mirage.json`、全部 `Assets.xcassets/Contents.json`、`InfoPlist.strings`、`project.pbxproj`、`.gitignore`。
- 核对 git 分支 / status / 最近 15 条 commit / 工作区 diff；确认工程为单 target、无测试 target、无第三方依赖。
- 实际执行 `xcodebuild` 构建并检查产物 `.app` 内容 → `BUILD SUCCEEDED`，`lineups_mirage.json` 确认已打包。
- 用脚本独立复核数据事实：3 组 / 6 方案 / 全部 T 方 Smoke；18 个教学图资源名 18/18 缺失；ID 唯一；坐标全在 `0..1`。
- **修正**上一版 `PROJECT_STATUS.md` 中 4 处过时陈述：
  - 未跟踪文件清单漏了 `AGENTS.md`、`PROJECT_STATUS.md`（原只列 `CODEX.md`）；
  - `TacticalMapView.swift` 的"15 个 private struct"实为 13 个（内部类型共 17 个）；
  - `L10n` 的"约 287 个 case"语义模糊 → 改为 Key 95 个 + 双语 case 共 287 处；
  - 补记 `docs/LOCALIZATION.md` 的 key 清单滞后 34 个。
- **修正** `AGENTS.md` 中 2 处：本地化 key 清单不完整的说明；`TacticalMapView.swift` 精确行数与内部类型数。
- 按共用交接机制的要求，**重写** `AGENTS.md`（新增 V1 scope 硬约束、命名规则、改动前检查流程、可复用资产清单、交接义务）与 `PROJECT_STATUS.md`（改为规定的 12 节结构，新增 `V1 Scope` / `Not Planned For V1` / `Last Work` / `Next Agent Handoff`）。
- 按确认的 5 项决定落地表述：
  1. `README.md` 定位为**面向开发者/用户的项目描述**，不作为 AI 进度日志；详细进度只在本文件。README 因属已跟踪文件、本轮边界为"只提交交接文档"，故未修改，登记为下一步。
  2. `AGENTS.md` 与 `PROJECT_STATUS.md` **纳入 git**；`CODEX.md` 与两个工程文件噪声**不纳入本次提交**。
  3. `LOCALIZATION.md` 缺失的 34 个 key **本轮不补**，改为登记一次专项 localization audit。
  4. `LineupStore` 的 fallback 保留（防 crash），但**明确"静默失败不是最终设计"**，写入 Debug 报错 / Release empty state 的优化方向。
  5. `MapListView` 未接入导航**确认为刻意设计**，降为条件性任务，触发条件是"开始增加第二张地图"。

**没有做**：

- ❌ 未修改任何 `.swift` / `.json` / `.pbxproj` / `.xcscheme` / `Assets` 内容（`git diff --stat -- CSTacticsApp/` 为空可证；`CSTacticsApp/` 下 33 个被跟踪文件与 HEAD 逐字节一致）。
- ❌ 未修改 `README.md`、`CODEX.md`、`docs/LOCALIZATION.md`。
- ❌ 未 `git add` / 提交两个工程文件噪声，未还原任何现有改动。

**提交**：本次以 `Add shared agent handoff documentation` 为信息，**仅提交** `AGENTS.md` 与 `PROJECT_STATUS.md` 两个新文件（父提交为 `737fdaf`）。该提交已 push 到 `origin/main`，本地 `main` 与远端同步。

**验证**：`xcodebuild -project CSTacticsApp.xcodeproj -scheme CSTacticsApp -destination 'platform=iOS Simulator,name=iPhone 17' -configuration Debug build` → `** BUILD SUCCEEDED **`。改动仅限两个 Markdown 交接文件，App 代码零改动。

**后续修订（2026-09-16，仅文档）**：根据"真实教学截图允许继续使用占位图"的决定，**重新排定了 `## Next` 的优先级**：

- P0-1 从"补齐 18 张教学图片"改为"**配置正式 App Icon 与 Accent Color**"。
- 新增 P0-2"**对当前 V1 做一次完整产品流程检查**"（10 个面：Mirage 首页 / 2D 地图 / 道具列表 / 搜索 / 收藏 / LineupGroup / LineupVariant / 教学图片占位 / About / 中英切换；只检查现有实现与明显问题，不新增大功能）。
- P0-3 由"暂不补齐 key"改为"**做专项 localization audit，修正文档与实际 key 的差异**"，并明确**不要为了补 key 重构 App**。
- "补齐 18 张教学图片"与"录入真实 Mirage 道具数据"合并降级为 **P1 内容填充任务**（P1-9 / P1-10），明确**不阻塞交付**。
- 本轮**只改本文件**；未修改 App 功能代码，未修改 `AGENTS.md`（其中 §5 教学图说明与 §11 文档索引的措辞仍按上一版，可择机同步）。

## Next Agent Handoff

### 当前基线

- 分支 `main`：与 `origin/main` **完全同步**。交接文档提交（`Add shared agent handoff documentation`，父提交 `737fdaf`）已 push 到远端。工作区没有未推送的提交。
- 工作区：2 个 modified 的工程文件噪声（`project.pbxproj`、`CSTacticsApp.xcscheme`，Xcode 27 升级产物，**故意未提交**）+ 1 个未跟踪文件 `CODEX.md`（纳管与否待定）；**没有半成品功能代码**。
- 构建命令见 `AGENTS.md` 第 8 节，当前为 `BUILD SUCCEEDED`。

### 建议的下一个任务：配置正式 App Icon 与 Accent Color（P0-1）

**为什么是它**：它是上架与观感的硬前置条件，成本极低，且**不需要改任何 Swift 代码**——目前"有 App 但没有图标"是交付上最说不通的一处缺口。

**第一步的具体动作**：

1. 放入一张 1024×1024 的 App Icon（`CSTacticsApp/Assets.xcassets/AppIcon.appiconset/`），并在该目录 `Contents.json` 的 images 条目里补上 `"filename"` 字段（当前只有一条 `{idiom: universal, platform: ios, size: 1024x1024}`，无 `filename`）。
2. 在 `AccentColor.colorset/Contents.json` 里填入实际颜色值（当前 `colors` 数组只有 `{idiom: universal}`，所以 Accent Color 未生效）。
3. 注意副作用：`AppTheme.accent = Color.accentColor`，而 `UtilityBadge.side` / `.category` 与 `FilterChip` 的选中态、`ClusterPoint` 背景色都在用它。**当前实际渲染为系统默认蓝**，配置后会整体变色——请在模拟器里确认这些位置仍然可读（尤其深色模式）。
4. 完成后跑一次构建、在模拟器里核对，并更新本文件。

### 紧随其后：V1 完整产品流程检查（P0-2）

**为什么是它**：资源和文档的问题已经梳理清楚，接下来应该确认"现有实现到底能不能走通"，而不是继续加功能。

**逐项走查清单**（10 个面，只检查现有实现与明显问题，**不新增大功能**）：

Mirage 首页 → 2D 地图 → 道具列表 → 搜索 → 收藏 → LineupGroup → LineupVariant → 教学图片占位 → About → 中英切换

**检查要点**：

- 每个入口都能正常进入并返回，导航栈不重复、不卡死。
- 空状态正确：搜索无结果、无收藏、过滤后无点位（地图上会叠 `EmptyStateView`）都要显示合理提示，而不是空白。
- **中英两档都过一遍**（设置里切换），确认没有硬编码文案漏出、没有中英串台。
- 深色模式下文本与徽章可读。
- **已知可接受项**：教学图片显示占位图属预期行为（真实截图尚未就绪），**不要记为新缺陷**。
- 发现的问题分两类处理：**明显问题可当场修**；**属于新功能的只登记进本文件的 `## Next`**，不在本轮实现。

### 再之后：专项 localization audit（P0-3）

对齐 `docs/LOCALIZATION.md` 与实际 `L10n.Key`（登记 61 / 实际 95，差 34 个）。**只改文档，不要为了补 key 重构 App。**

### 内容填充任务（P1，不阻塞交付）

- **录入真实 Mirage 道具数据**（取代当前占位/示例数据），并记录来源与核验方式。
- **补齐 18 张教学图片**：真实截图就绪前**占位图可以继续使用**。资源名清单见下（需要时再查）。

| 道具组 | 变体 | 资源名前缀（后缀 `_position` / `_aim` / `_result`） |
|---|---|---|
| `mirage_window_smoke` | `mirage_window_smoke_standard_t_spawn` | `mirage_window_smoke` |
| | `mirage_window_smoke_left_spawn` | `mirage_window_smoke_left_spawn` |
| `mirage_ct_smoke` | `mirage_ct_smoke_t_spawn` | `mirage_ct_smoke` |
| | `mirage_ct_smoke_a_ramp` | `mirage_ct_smoke_a_ramp` |
| `mirage_jungle_smoke` | `mirage_jungle_smoke_a_ramp` | `mirage_jungle_smoke` |
| | `mirage_jungle_smoke_palace` | `mirage_jungle_smoke_palace` |

**做图片时必须注意**：

- 在 `CSTacticsApp/Assets.xcassets/` 下新增 imageset，**资源名必须与 JSON 中声明的名字逐字一致**（拼错不会报错，只会继续显示占位图）。
- 建议先做 3 张打通链路（`mirage_window_smoke_standard_t_spawn` 的站位 / 瞄点 / 结果），在模拟器里确认 `LineupDetailView` 的折叠区、全屏分页预览、图片缩放三处都换成真图，再批量推进剩余 5 个变体。
- 新增完毕后确认 `.xcodeproj` 的 Resources 阶段仍正常（asset catalog 是整目录引用，通常无需改 pbxproj，但请验证构建）。
- **图片的来源与授权必须先确认**（见 Known Issues 第 18 条）。转发他人游戏截图有版权风险；若是自截图，请在本文件记录来源与日期。**这是真正的前置条件，不是优先级问题。**

### 不要做的事

- 不要在"产品流程检查"里夹带新功能；新需求只登记，不在本轮实现。
- 不要为了补 localization key 而重构 App 或改动界面结构。
- 不要顺手接入 `MapListView` 到根导航——**已确认刻意设计**，V1 只有一张地图；等开始加第二张地图时再提升优先级。
- 不要给开发者模式的坐标拖动加写回逻辑。
- 不要通过静默 fallback 长期掩盖 JSON 数据错误。
- 不要在没有明确理由时改动 `LineupModels.swift`、`project.pbxproj` 或 `lineups_mirage.json`。
- 不要提交 `project.pbxproj` / `.xcscheme` 的 Xcode 升级噪声，也不要把 `CODEX.md` 混进无关提交。
- 不要把 `CODEX.md` 路线图里的 v1.5 / v2.0 条目（更多地图、社区功能、云同步）当作待办。
