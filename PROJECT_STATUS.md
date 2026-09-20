# AimNade Project Status

> 本文件是 Codex 与 DSH 共用的**进度快照**，每次完成任务后必须更新（规则见 `AGENTS.md` 第 10 节）。
> 最后更新：2026-09-20
> 任务前基线提交：`ffe928f`（`Refactor AimNade navigation around tactics`，已推送至 `origin/main`）
> 最近一次构建验证：Mirage / Ancient / Nuke 三地图接入后 Debug `xcodebuild` → **通过（exit 0）**（Xcode 27.0 / 27A266a，iPhone 17 + iOS 26.5 模拟器）

---

## Current Version

| 项 | 值 | 来源 |
|---|---|---|
| Marketing Version | `1.0` | `project.pbxproj` 的 `MARKETING_VERSION` |
| Build Version | `1` | `project.pbxproj` 的 `CURRENT_PROJECT_VERSION` |
| Bundle Identifier | `com.example.AimNade` | `project.pbxproj`（**仍是模板默认值，未改成正式域名**，见 Known Issues） |
| 显示名 | `AimNade` | `en.lproj` / `zh-Hans.lproj` 的 `CFBundleDisplayName` |
| Deployment Target | iOS 17.0 | `IPHONEOS_DEPLOYMENT_TARGET` |
| 阶段 | 三地图本地 MVP；Mirage 有占位道具流程，Ancient / Nuke 暂为地图预览 | 本文件第 2–4 节 |

## Current Goal

把本地三地图 MVP 从"功能可用"推进到"可交付"：

1. **App Icon 与 Accent Color 已完成**（P0-1）。
2. **V1 完整产品流程检查已完成**（P0-2）：中英文、浅色/深色、空状态/有数据状态及收藏持久化已走查；修复了教学图片全屏占位页在黑色背景上对比度不足的问题。
3. **主界面/导航 UI/UX 重构已完成并通过用户审阅**：代码、文档、构建与代表性模拟器验证均已完成，已获准提交并推送。
4. **战术页视觉层级优化已完成并通过用户预览**。
5. **Mirage / Ancient / Nuke 三地图接入已完成**：Mirage 保留完整道具界面，Ancient / Nuke 使用专属主题的地图预览态，不编造道具数据。
6. **随后进行专项 localization audit**（P0-3），修正 `docs/LOCALIZATION.md` 与实际 `L10n.Key` 的差异，**不要为了补 key 重构 App**。
7. 内容填充（P1，**不阻塞交付**）：录入真实 Mirage 道具数据；补齐 18 张教学图片；未来再为 Ancient / Nuke 接入经核验的道具内容。
8. 明确标记占位/示例数据，避免被误当作已核实的真实道具数据。

完整的优先级拆分见 `## Next`。

## Completed

> 以下每一条都已对照源码确认，不是根据 README 推断。

### 工程基线

- 单一 target `AimNade`（`productType = com.apple.product-type.application`），纯 `.xcodeproj`。
- 工程、Target、Scheme、构建产物、源码目录和 `@main` 入口均统一命名为 `AimNade`。
- Swift 5 + SwiftUI，iOS 17.0，设备族 `1,2`（iPhone + iPad）。
- **零第三方依赖**（无 SPM / CocoaPods / Carthage），**无测试 target**。
- `xcodebuild ... build` 实测 `BUILD SUCCEEDED`；构建产物 `AimNade.app` 内确认打包了 `lineups_mirage.json`、`Assets.car`、`en.lproj`、`zh-Hans.lproj`，`assetutil` 确认 `mirage_map` / `ancient_map` / `nuke_map` 均已编译入包。
- 全仓无 `TODO` / `FIXME` / `HACK` 遗留标记。

### 数据层与模型

- `Models/LineupModels.swift`：`Map` → `LineupGroup` → `LineupVariant` 三级 `Codable` 模型。
- `UtilityType`（`Smoke` / `Flash` / `Molotov` / `HE`）与 `LineupCategory`（`aSite` / `bSite` / `mid` / `tSide` / `ctSide`）枚举齐备，各自带本地化显示名与配色。
- `Data/LineupStore.swift`（45 行）：从 Bundle 读 `lineups_mirage.json`，失败时回退到空 Mirage；同时登记 `lineupGroups` 为空的 Ancient / Nuke 地图预览。
- `Data/lineups_mirage.json`（268 行）：已接入 Xcode Resources 构建阶段，确认被真实打包。
- 数据自提交 `b4fb017`（`Load Mirage lineups from local JSON`，PR #35）由硬编码迁移为 JSON 驱动。
- 当前数据自检通过：ID 唯一、坐标全部落在 `0…1`、枚举取值合法。

### 2D 战术地图

- 顶部选择器可在 Mirage / Ancient / Nuke 之间切换；切换时重置地图/列表、搜索、道具类型、缩放、预览卡与开发者坐标状态，T / CT 保留为全局偏好。
- Ancient 使用绿色主题，Nuke 使用深蓝主题；两者在无道具数据时隐藏无效的搜索和筛选器，显示可缩放的大图预览与明确的数据待补提示。
- 单指平移 / 双指缩放（`UIScrollView`，通过 `ZoomableScrollView` 桥接，`minScale 1.0` / `maxScale 4.0`）+ 双击缩放（`doubleTapScale 2.5`，再双击复位）。
- 按缩放级别自适应阈值的点位聚类（`92 / 76 / 52 / 36`），聚类内弹出 `ClusterLineupSheet` 选择具体道具组。
- 战术页统一提供 T / CT 与道具类型过滤（全部 / 烟 / 闪 / 火 / 雷），地图和列表共享状态；类型筛选显示当前阵营下的可用数量，零数据类型降权显示。
- 点击点位先显示道具组预览卡，可直接收藏或继续进入详情；选中点位使用战术橙描边与强调阴影。
- Mirage 筛选后无结果时，地图右上角显示轻量空状态标签；Ancient / Nuke 的 0 数据场景由专用地图预览提示承接，不遮挡地图内容。

### 开发者模式

- `DeveloperSettings` 开关持久化到 `UserDefaults`。
- 目标点 / 变体起点 / 连接线的显示开关。
- 点位拖动（开发者模式下平移手势降级为双指，避免与拖动冲突）。
- 实时坐标显示、复制单个坐标、复制整份坐标 JSON 到剪贴板。
- **坐标编辑只存在于页面 `@State`，不写回 JSON**（已按此约束确认代码）。

### 列表、详情、搜索、收藏、设置、关于

- 根导航：`TabView` 只保留战术 / 收藏 / 设置三个用户目标，每个 Tab 有独立 `NavigationStack`；启动默认直接进入战术页。
- 战术页：`TacticsView` 统一管理当前地图、地图/列表模式、T/CT 阵营、道具类型和搜索词；顶部地图选择器列出 Mirage / Ancient / Nuke，且只在当前地图有道具数据时显示完整筛选界面。
- 道具列表：`TacticsListView` 和地图共享同一筛选状态，按 `LineupCategory` 分组，每行直接显示“起点 → 目标点”、方案名、类型、阵营和单方案收藏按钮。
- 道具组详情：`LineupGroupDetailView` 概览信息 + 方案卡片列表 + 整组收藏。
- 投掷方案详情：`LineupDetailView` 概览 / 位置 / 投掷步骤 / 教学图片折叠区 / 备注 + 单方案收藏。
- 教学图片：折叠区 + 全屏分页预览（`TabView.page`）+ 图片缩放（`ZoomableImageView`）。**结构完整，但资源缺失 → 实际显示占位图。**
- 搜索：不再是独立页面，改为战术页内联搜索框，实时同步过滤地图和列表。道具组匹配 ID / mapId / 目标名 / 类型 / 阵营 / 分类；方案匹配 ID / 名称 / 出生点·身位要求 / 起止区域 / 投掷方式 / 说明 / 难度，并保留大小写、变音符与去空格匹配。
- 收藏：`FavoriteStore` 同时维护道具组与方案两组 ID 集合，`UserDefaults` 持久化；`FavoritesView` 已改为从全部地图汇总收藏，当前实际内容仍只来自 Mirage。
- 设置：`SettingsView` 语言选择（跟随系统 / 简体中文 / 英文）+ 开发者模式开关 + 关于页入口。
- 关于：`AboutView` 作者头像（`creator_avatar`）、作者名、版本号、非官方声明、鸣谢。

### 本地化与 UI Design System

- `LanguageManager` 三档语言（跟随系统 / 简体中文 / 英文），`UserDefaults` 持久化；`L10n`（`L10n.Key` 100 个 case，中英双语分支齐全）+ `LocalizedText`（JSON 业务内容双语）。
- `Theme/AppTheme.swift`：品牌蓝、战术橙、Ancient 绿、Nuke 深蓝、语义色、圆角和间距的唯一来源。
- `AccentColor.colorset` 已配置通用 sRGB 品牌色 `#3A7AFE`；`AppTheme.accent` 继续使用 `Color.accentColor`。
- `AppIcon.appiconset/AppIcon.png` 已接入用户提供的第一版图标：1024×1024、不含透明通道，保持原画面完整；使用通用外观，iPhone / iPad 图标资源已编译打包。
- `Views/Components/`：`FeatureCard` / `MapMarkerView` / `UtilityBadge` 已抽出且在多个页面复用；`Views/EmptyStateView.swift` 统一空状态。
- 复用核实：`MapMarkerView` 被 5 个 Swift 文件引用，`UtilityBadge` 被 5 个，`EmptyStateView` 被 3 个，`AppTheme` 被 14 个。
- 界面使用系统语义色，自带深色模式；关键按钮有 `accessibilityLabel`；`Views/` 下已无硬编码的固定 UI 文案（仅剩纯数字插值与已本地化的插值）。

### 文档维护

- 中文 README 已按当前源码、数据及资源核对；`AGENTS.md` 第 10 节已规定每次开发任务结束检查 README，相关变化随任务同步。

### P0-2 产品流程检查

- 已在 iPhone 17 / iOS 26.5 模拟器走查 Mirage 首页、2D 地图、道具列表、搜索、收藏、道具组详情、投掷方案详情、教学图片占位与全屏预览、设置和关于页。
- 已覆盖简体中文/英文、浅色/深色、搜索有结果/无结果、收藏空状态/有数据状态，并验证道具组与方案收藏在 App 重启后保留。
- 首屏图标在模拟器 SpringBoard 显示正常；开发者地图控件可正常打开。
- 修复 `LineupDetailView` 全屏教学图片占位内容对比度过低：在黑色背景上统一使用半透明白色前景，浅色和深色环境均可读。
- 运行期未发现 App 崩溃。由于当前没有 UI 测试 target，导航定义通过源码检查、各目标页通过临时仓库外测试入口独立启动；上架前仍建议在真机补一次点击/返回/缩放手势烟雾测试。

## In Progress

- P0-3 localization audit 尚未开始；只对齐 `docs/LOCALIZATION.md` 与实际 100 个 `L10n.Key`，不重构 App。

### 工作区状态

本轮功能与文档由同一任务提交收口；任务结束时工作区仍保留任务前已有的工程元数据和本地文件：

```text
 M AimNade.xcodeproj/project.pbxproj
 M AimNade.xcodeproj/xcshareddata/xcschemes/AimNade.xcscheme
?? CODEX.md
?? 图库/
```

- `project.pbxproj` 与 Scheme 当前只包含任务前已有的 Xcode 27 升级元数据，本轮未修改它们。
- `CODEX.md` 仍未被 git 跟踪。
- `图库/` 是用户本地素材目录，未跟踪，本轮不纳入提交。

### 尚未收敛的能力缺口

- **18 张教学图片全部缺失**（详见 Known Issues）。**已确认不阻塞交付**：真实截图就绪前占位图可继续使用，已降级为 P1 内容填充任务。
- **内容体量小且为占位数据**：3 个道具组 / 6 个投掷方案，全部 T 方 Smoke。
- **Ancient / Nuke 尚无道具数据**：当前只提供用户提供的中文标注地图预览，不含道具组、投掷方案或教学截图。
- **JSON 加载失败路径不可见**：当前静默回退空 `Map`。已确认不是最终设计，优化方向见 `## Next` P1 第 4 项与 Known Issues 第 6 条。
- `docs/LOCALIZATION.md` 与实际本地化 key 存在差异（登记 61 / 实际 100，差 39 个）。已排为 P0-3，做一次专项 localization audit **修正文档**（不重构 App），见 `## Next` P0 第 3 项。
- 无测试覆盖。

## Next

> 范围纪律：V1 可浏览 Mirage / Ancient / Nuke 三张 2D 地图，但当前只有 Mirage 具备道具内容。以下各项都不得引入 3D、视频、登录、后端或用户投稿。
> 真实教学截图允许继续使用占位图，补齐教学图片属于 P1-10；P0-1、P0-2、主界面 UI/UX 重构、战术页视觉优化与三地图预览均已完成。当前继续 P0-3。
> P0 的三项都属于"在当前实现上做检查或配置"，**不要因此新增大功能**。

### P0 — 交付前置与完整性确认

1. ✅ **App Icon 与 Accent Color 已配置**：用户提供的第一版图标已接入 `AppIcon.appiconset`；Accent Color 为 `#3A7AFE`，构建通过。
2. ✅ **当前 V1 完整产品流程检查已完成**：现有主流程、中英文、深浅色、空状态与收藏持久化已走查；修复了全屏教学图占位页对比度问题。
   - 逐项走查：Mirage 首页 / 2D 地图 / 道具列表 / 搜索 / 收藏 / LineupGroup / LineupVariant / 教学图片占位 / About / 中英切换。
   - 检查内容：是否能正常进入、状态是否正确（含空状态）、中英两档文案是否都正确、深色模式下是否可读、有无崩溃或明显布局问题。
   - **已知可接受项**：教学图片显示占位图属预期行为，**不要把它记为新缺陷**（见第 10 项）。
   - 发现的问题按"明显问题"与"新功能需求"分类记录：明显问题可修，新功能需求只登记进本文件，不在本轮实现。
3. **专项 localization audit**：`docs/LOCALIZATION.md` 的"当前核心 key"清单只登记 61 个 key，实际 `L10n.Key` 有 100 个，**存在 39 个差异**。
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
7. ✅ **中文 README 与同步维护规则已完成（2026-09-19）**：覆盖已实现功能、技术栈、运行、目录、占位内容和限制；每次开发任务结束检查，相关变化在同一提交中同步，检查结果记录在本文件。
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

15. **为 Ancient / Nuke 接入真实道具数据**：地图资源、顶部选择器、独立主题和空数据预览态已就绪。
    - 触发条件：对应地图的数据来源、核验方式和教学素材授权均已确认。
    - 届时新增对应 JSON，保证 group / variant ID 使用地图前缀且全局唯一，再验证地图/列表/搜索/筛选/收藏随地图切换。

## V1 Scope

**V1 内置 Mirage、Ancient、Nuke 三张 2D 地图；道具学习内容当前仅位于 Mirage。**

包含：

- Mirage 2D 战术地图（点位、过滤、聚类、缩放、点击进详情）。
- Ancient / Nuke 可缩放地图预览（当前 0 道具数据）。
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

> 说明：`UtilityType` 已含 Flash / Molotov / HE，`LineupCategory` 已含 B 包点 / CT 方；这些枚举预留不代表对应内容已存在。Ancient / Nuke 已能预览也不代表已有真实道具教学。

## Important Architecture

轻量分层、View 驱动的 SwiftUI 单体架构。**没有**独立的 ViewModel / Repository / Service 协议层，不属于严格 MVVM。

### 入口与导航

- `AimNade/AimNadeApp.swift` 是 `@main` 入口。
- 注入三个全局 `ObservableObject`：`LanguageManager`、`DeveloperSettings`、`FavoriteStore`。
- 根导航：`TabView` 包含战术 / 收藏 / 设置，每个 Tab 内是独立 `NavigationStack`；战术为默认 Tab。
- `TacticsView` 是主界面，顶部 `Menu` 选择 Mirage / Ancient / Nuke。有道具数据时显示搜索、地图/列表、T/CT 与道具类型筛选；空数据地图则进入简化预览态。
- `Views/MapListView.swift` 仍未接入启动流程。三张地图继续使用战术页的顶部选择器，不需要恢复启动前置列表。

### 数据模型

- `Map { id, name: LocalizedText, imageName, lineupGroups: [LineupGroup] }`
- `LineupGroup { id, mapId, targetName, type: UtilityType, side: String, category: LineupCategory, targetMapX/Y, isFeatured, variants: [LineupVariant] }`
- `LineupVariant { id, name, spawnRequirement, startArea, targetArea, throwMethod, description, difficulty: String, startMapX/Y, targetMapX/Y, positionImageName, aimImageName, resultImageName }`
- 所有坐标都是 **`0…1` 归一化值**，通过 `fittedImageRect` 换算成屏幕坐标；JSON 字段名必须与模型逐字一致，否则整体解码失败（解码是全有或全无的）。
- `difficulty` 是 `String`（当前取值 `Easy` / `Medium`），不是枚举，未知值会原样显示。

### 数据流

`LineupStore.maps` 提供三张 `Map` → `TacticsView` 管理当前地图与状态。Mirage 的内容链路为 `lineups_mirage.json`（Bundle 资源）→ `LineupStore.mirageMap`（`static let`，进程内只读一次）→ 内存中搜索/过滤/聚类。Ancient / Nuke 是代码定义的空 `Map`，只引用 Asset Catalog 地图图片。

### 文件清单（23 个 Swift 文件，3926 行）

| 目录 | 文件 |
|---|---|
| 根 | `AimNadeApp.swift`(47) |
| `Models/` | `LineupModels.swift`(153) / `FavoriteStore.swift`(68) / `DeveloperSettings.swift`(15) |
| `Data/` | `LineupStore.swift`(45) / `lineups_mirage.json`(268) |
| `Localization/` | `L10n.swift`(525) / `LanguageManager.swift`(39) / `LocalizedText.swift`(15) |
| `Theme/` | `AppTheme.swift`(24) |
| `Views/` | `TacticalMapView.swift`(1105) / `LineupDetailView.swift`(436) / `TacticsView.swift`(460) / `LineupGroupDetailView.swift`(159) / `FavoritesView.swift`(142) / `TacticsListView.swift`(141) / `AboutView.swift`(138) / `LineupSearch.swift`(103，搜索匹配器) / `SettingsView.swift`(49) / `MapListView.swift`(45) / `EmptyStateView.swift`(44) |
| `Views/Components/` | `MapMarkerView.swift`(78) / `UtilityBadge.swift`(56) / `FeatureCard.swift`(39) |
| 本地化资源 | `en.lproj/InfoPlist.strings` / `zh-Hans.lproj/InfoPlist.strings`（均只含 `CFBundleDisplayName`） |

## Important Rules

长期约束的完整版本在 **`AGENTS.md`**，这里只列最容易被违反的几条：

1. **V1 可浏览 Mirage / Ancient / Nuke，但当前只有 Mirage 具备道具内容**；不做 3D、不做视频、不做登录、不做后端、不做用户投稿。
2. **所有新增 UI 文案必须走现有本地化系统**（`L10n.Key` + 英文 + 简体中文三处同步），禁止硬编码。
3. **图片资源名、代码变量名、数据 ID 使用英文。**
4. **不编造真实 CS 道具数据**；当前允许使用明确标记的占位数据。
5. **修改前必须先检查已有实现**，复用 `AppTheme` / `FeatureCard` / `MapMarkerView` / `UtilityBadge` / `EmptyStateView`，避免重复造组件。
6. **不擅自大规模重构数据模型**（`LineupModels.swift`）。
7. **保持搜索、收藏、地图、详情页功能兼容**，不删除既有功能。
8. **开发者模式的坐标拖动不得添加写回逻辑**。
9. **不允许在没有明确理由时修改无关文件**；不提交 Xcode 版本升级产生的工程文件噪声。
10. **一个任务对应一个清晰的 Git commit；完成后必须更新本文件，并按 `AGENTS.md` 第 10 节检查和同步 README。**

## Known Issues

### 🔴 交付前置（P0，必须先做）

1. ✅ **App Icon 已配置**：`Contents.json` 引用 `AppIcon.png`（1024×1024，不含透明通道）；模拟器 SpringBoard 已确认显示正常，真机观感仍待上架前检查。
2. ~~Accent Color 未配置~~ ✅ **已完成**：`AccentColor.colorset` 为通用 sRGB `#3A7AFE`。

### 🟠 数据与内容

3. **18 张教学图片资源 100% 缺失。** JSON 中每个 variant 声明 3 张图（`positionImageName` / `aimImageName` / `resultImageName`），3 组 × 2 方案 × 3 张 = 18 个资源名，**在 `Assets.xcassets` 中一个都不存在**。界面因此显示 `PreviewPlaceholderView` 占位。
   现有普通 imageset 共 4 个：`mirage_map`、`ancient_map`、`nuke_map`、`creator_avatar`。
   - **严重度已下调（2026-09-16）**：真实教学截图允许继续使用占位图，**此项不阻塞交付**，属 P1 内容填充任务（`## Next` P1-10）。
4. **当前 Mirage 内容是占位/示例数据**，不得描述为"已核实的真实道具数据"：数值坐标为手工挑选、教学图片不存在、内容未与真实游戏对拍、JSON 中没有任何来源或可信度标记字段。
5. 内容覆盖极小：Mirage 仅 **3 个道具组 / 6 个投掷方案，全部为 T 方 Smoke**；Ancient / Nuke 为 **0 道具数据**。Flash / Molotov / HE 三类道具与 B 包点、CT 方两个分类在代码中已支持但数据为空。
6. **JSON 加载失败是"静默失败"（已确认不是最终设计）。** `LineupStore` 在 JSON 缺失或解码失败时回退到空 `Map`，`catch` 块为空——用户只看到空列表，没有任何错误提示。
   - 保留 fallback 以防止 App crash 没有问题；**要改的是"静默"**。
   - 后续优化方向：**Debug 环境**输出明确的 JSON decode / load 错误；**Release / UI 层**显示合理的 empty state；不通过静默 fallback 长期掩盖数据错误。
   - 详见 `## Next` P1 第 4 项。资源目录 `Data/` 下只有 `lineups_mirage.json`，因此此加载路径只影响 Mirage 道具内容。
7. 无 JSON 校验、无 ID 唯一性检查、无坐标范围检查、无图片资源存在性检查。

### 🟡 代码债

8. `Views/TacticalMapView.swift` 仍有 **1105 行**、13 个内部类型，但顶层筛选与导航已移到 `TacticsView`；地图文件仍同时包含渲染 / 聚类 / 坐标换算 / 缩放容器 / 点位预览 / 开发者工具，后续仍可分段拆分。
9. `Views/MapListView.swift` 已实现但未接入根导航。**这是刻意设计**——三张地图已由战术页顶部选择器统一切换，不需要启动前置列表。
10. **无测试 target**：搜索、聚类、坐标换算、收藏持久化、JSON 解码全部没有自动化覆盖；构建通过是唯一可自动化的验证手段。
11. 地图缩放上限 4.0（`ZoomableScrollView` 的 `maxScale`），在 iPad 或大尺寸屏幕上的清晰度**待确认**。
12. `LineupModels.swift` 中定义了名为 `Map` 的结构体，与 Swift 标准库（以及部分框架）的 `Map` 同名，跨模块引用时**可能产生歧义**（当前可编译，属命名隐患）。

### 🔵 文档与工程

13. **`LOCALIZATION.md` 与实际本地化 key 存在差异，需进行一次专项 localization audit。** 具体：`docs/LOCALIZATION.md` 的"当前核心 key"清单登记 61 个，实际 `L10n.Key` 有 100 个，差 39 个；该文档也未反映当前三地图范围。
    - 已排为 **P0-3**：目标是**修正文档与实际 key 的差异**，让规范文档重新可用于交接。
    - **约束：不要为了补 key 而重构 App。** 详见 `## Next` P0 第 3 项。
14. ✅ **README 已中文化并纳入同步维护**：文档描述当前实现与占位内容，`AGENTS.md` 文档索引已同步。详细进度仍只放在本文件；后续任务在 `Last Work` 记录 README 更新或无需更新的核对结论。
15. `AGENTS.md` 与 `PROJECT_STATUS.md` 在本轮之前**均未被 git 跟踪**，有丢失风险；本轮已提交纳入（见 `## Last Work`）。
    - `CODEX.md` **仍未被跟踪**：它属于既有的项目说明书，不属于本轮交接文档范围，本轮未提交、未修改。
16. **Bundle Identifier 仍是模板默认值 `com.example.AimNade`**，未改成正式域名，**上架前必须修改**。

### ❓ 待确认

17. **是否给数据模型增加占位标记字段**（如 `LineupVariant.isPlaceholder`）？当前 schema 没有该字段，而规则要求占位数据必须明确标记。涉及 `LineupModels.swift` + JSON 变更，需先确认。
18. **地图图片与真实 CS 道具数据的来源与授权**：Ancient / Nuke JPEG 由用户提供，但尚无公开发布授权记录；两张图的中文标注已烘焙进图片，英文界面也会显示中文。上架前必须确认图片与后续教学内容的来源、授权和核验方式。
19. `CODEX.md` 是否纳入 git？它仍描述旧 Launcher 导航和旧文件名，本轮为保留既有未跟踪工作而未修改；纳管前应先与当前架构同步，并单独确认提交时机。
20. `AboutView` 显示的版本号来自 `Bundle.main` 的 `CFBundleShortVersionString`（缺失时回退 `"1.0"`）；而 App 名称走的是 `L10n` 常量而非 Bundle。是否统一为只读 Bundle 元数据，待确认。

## Last Work

### 2026-09-20 — Ancient / Nuke 地图接入与三地图主题

- 将用户提供的 Ancient（1206×1327 JPEG）与 Nuke（1206×1356 JPEG）原图接入 `Assets.xcassets`，资源名为 `ancient_map` / `nuke_map`，未裁剪、未重绘。
- `LineupStore.maps` 现包含 Mirage / Ancient / Nuke；Ancient / Nuke 使用空 `lineupGroups`，只提供真实地图图片预览，没有编造道具点位或投掷方案。
- 战术页顶部地图选择器可直接切换三图；切换时重置地图视图、搜索、道具类型、缩放、点位预览和开发者编辑状态，避免跨地图残留。
- 只有当前地图存在道具数据时才显示搜索、地图/列表、T/CT 与道具筛选；Ancient / Nuke 使用放大地图的专用预览态和双语数据待补提示。
- 每张地图有独立视觉语言：Mirage 蓝/橙 + scope，Ancient 绿 + leaf，Nuke 深蓝 + atom；Nuke 交互蓝已调深以保证白字对比度。
- 收藏页改为从 `LineupStore.maps` 汇总道具组和方案，为后续多地图内容保持兼容；当前收藏内容仍只来自 Mirage。
- 新增双语 `mapPreviewOnly` / `mapDataPending`，`L10n.Key` 总数为 100；`docs/LOCALIZATION.md` 专项 audit 差异相应为 39 个。
- 验证：`jq` 通过两个 imageset 清单；源图与入库图片 SHA-256 一致；Debug 构建通过；`assetutil` 确认三张地图已编译进 `Assets.car`；iPhone 17 / iOS 26.5 模拟器检查了三图浅色界面及 Ancient / Nuke 深色界面。
- README 与 `AGENTS.md` 已同步三地图范围、数据边界、资源限制和授权风险；`project.pbxproj` / Scheme 的任务前差异、未跟踪 `CODEX.md` 与 `图库/` 仍原样保留。

---

### 2026-09-20 — 战术页视觉层级优化

- 把战术页顶部改为地图上下文标题，直接显示当前 Mirage 的 3 个道具组和 6 个方案，并用品牌蓝到战术橙的轻量渐变建立视觉识别。
- 将搜索、地图/列表、T/CT 与道具类型筛选压缩为更紧凑的原生控件；道具筛选增加数量，当前无数据的类型降低视觉权重但不虚构内容。
- 地图容器按资源宽高比自适应，不再用多余留白填满剩余高度；保留缩放、双击、聚类和开发者坐标工具。
- 地图标记从字母改为 SF Symbols 道具图形；点击单点先显示带类型、方案数量、收藏和详情入口的预览卡，选中点使用战术橙强调。
- 列表继续复用真实 6 个方案，新增区域数量、难度徽章、卡片层级和更清晰的收藏按钮；没有新增或修改 JSON 数据。
- 验证：iPhone 17 / iOS 26.5 Debug 构建通过（exit 0）；模拟器检查中文浅色默认地图、中文浅色点位选中卡、中文列表和深色地图。仓库外临时预览入口未写入项目。
- README 已同步点位预览卡和筛选数量；`AGENTS.md` 已同步组件职责与当前文件规模。
- 用户已确认视觉预览，本轮与随后三地图接入一并收口；任务前已有的 `project.pbxproj`、Scheme、`CODEX.md` 与 `图库/` 保持原状。

---

### 2026-09-20 — 主界面与导航 UI/UX 重构

- 根导航从 Launcher 式四功能卡 + 右上角设置，改为原生 `TabView`：战术 / 收藏 / 设置；每个 Tab 使用独立 `NavigationStack`，启动默认直接进入战术。
- `TacticsView` 统一持有 `selectedMapID`、`selectedViewMode`、`selectedSide`、`selectedUtilityType`、`searchText`；地图/列表切换不会重置搜索或筛选。
- 顶部地图选择器使用 `LineupStore.maps`，当前只显示真实存在的 Mirage；未虚构第二张地图。搜索改为 `.searchable` 内联实时过滤。
- 地图引擎保留原有缩放、双击、聚类、点位导航和开发者坐标工具；只改为接收外部过滤后的 groups，并把地图容器调整为自适应战术页剩余空间。
- `TacticsListView` 按区域分组展示 6 个已有方案，每行为“起点 → 目标点”、方案名、类型、阵营和收藏按钮；直接进入方案详情。
- 搜索匹配字段保持原有范围：道具组 ID / mapId / 目标名 / 类型 / 阵营 / 分类，方案 ID / 名称 / 出生点·身位 / 起止区域 / 投掷方式 / 说明 / 难度；保留大小写、变音符与去空格匹配。
- 将 `MirageDetailView.swift`、`UtilityListView.swift`、`LineupSearchView.swift` 分别重命名为 `TacticsView.swift`、`TacticsListView.swift`、`LineupSearch.swift`，并只在 `project.pbxproj` 同步对应文件引用和构建阶段注释；任务前已有的 Xcode 27 元数据差异原样保留。
- 收藏继续复用同一个 `FavoriteStore` / `UserDefaults`，设置继续复用 `SettingsView`、`LanguageManager` 和 `DeveloperSettings`；数据模型、JSON、Assets 与 Scheme 未修改。
- 新增 3 个双语 UI key：`tactics`、`mapView`、`listView`；搜索提示改为“搜索点位、道具或区域”。`L10n.Key` 现为 98 个，P0-3 文档差异更新为 37 个。
- 验证：Debug 构建通过（Xcode 27.0 / 27A266a，iPhone 17 + iOS 26.5）；模拟器检查中文浅色地图/列表、`window` 搜索、CT 空状态、收藏 Tab，以及英文设置 Tab 和英文深色列表。临时 QA 入口位于 `/tmp`，未写入仓库。
- README 已同步三 Tab 导航、战术主页、共享筛选和内联搜索；`AGENTS.md` 已同步新根导航、地图责任边界及 key 数量。
- 未跟踪的 `CODEX.md` 仍保留任务前内容，其中旧 Launcher 导航与旧文件名已过时；本轮不修改该既有文件，纳管前需单独同步。
- 用户在完成汇报后批准进入提交与推送收口；提交范围只包含本轮 UI/UX、对应文档和 `project.pbxproj` 的 3 个文件重命名引用。任务前已有的 Xcode 27 升级元数据、`CODEX.md` 与 `图库/` 继续保留在本地。

---

### 2026-09-19 — P0-2 完整产品流程检查

- 在 iPhone 17 / iOS 26.5 模拟器覆盖首页、2D 地图、道具列表、搜索、收藏、道具组/投掷方案详情、教学图片占位与全屏预览、设置、关于页；检查中英文、浅色/深色、搜索有结果/无结果、收藏空状态/有数据状态及重启持久化。
- 修复 `AimNade/Views/LineupDetailView.swift` 中全屏教学图占位内容在黑色背景上对比度不足的问题；只调整现有共享占位组件的前景色，未引入新依赖或新抽象。
- 验证：Xcode 27.0（27A266a），iPhone 17 / iOS 26.5 模拟器 Debug 构建通过（exit 0）；修复后中文浅色全屏占位页复验通过，未发现 App 崩溃。
- 当前无 UI 测试 target，测试页面由仓库外临时入口启动，导航定义配合源码检查；上架前仍建议真机补做点击/返回/缩放手势烟雾测试。临时测试入口位于 `/tmp`，未写入或提交到仓库。
- README 已检查，无需更新：本轮未改变用户可见功能、V1 范围、技术栈、目录/数据结构或资源状态。
- `AGENTS.md` 已按用户最新要求增加交付规则：开发任务验证并提交后默认直接推送，除非用户另有明确要求。
- 提交范围仅包含 `LineupDetailView.swift`、`AGENTS.md` 和本状态文件；原有 Xcode 工程噪声、`CODEX.md` 与用户本地 `图库/` 继续保留。

---

### 2026-09-19 — 中文 README 与持续维护规则

- `README.md`：重写中文项目介绍、现有功能、技术栈、运行构建、目录与数据链路、内容限制、后续方向和文档分工。
- `AGENTS.md`：补充每次开发任务结束检查 README 的要求，明确触发更新的范围、同任务同提交同步、无变化时记录核对结果及只读任务边界；更新文档索引。
- README 核验：对照源码、工程配置、JSON 和资源目录确认 3 组 / 6 方案、18 张教学图缺失；7 个相对链接均存在，构建命令实测通过。占位数据、待核验内容和后续方向已明确区分。
- 验证：Xcode 27.0（27A266a），iPhone 17 / iOS 26.5 模拟器 Debug 构建通过（exit 0）；`git diff --check` 通过。本轮未进行交互验收。
- 仅提交上述两份文档与本状态文件。原有工程文件改动和未跟踪 `CODEX.md` 保留，不混入本次提交；不自动推送。

---

### 2026-09-19 — 配置第一版 App Icon

- 来源：用户提供的 `aimnade第一版.png`（1254×1254 PNG、不含透明通道）。桌面原图保持不变。
- 按完整画面等比例缩放为 1024×1024，保存为 `AimNade/Assets.xcassets/AppIcon.appiconset/AppIcon.png`，并在同目录 `Contents.json` 中配置 `filename`。
- 复用现有 Target 的 `AppIcon` 引用；Swift、业务 JSON、本地化及工程配置均未修改。
- 验证：Debug iPhone 17 模拟器构建通过（exit 0）；产物的 iPhone / iPad `CFBundleIcons` 指向 `AppIcon`，已生成对应图标文件。尚未进行真机主屏幕视觉验收。
- 提交范围：图标 PNG、AppIcon 资源描述、项目状态文档；原有两个工程文件改动和未跟踪的 `CODEX.md` 保留。

---

### 2026-09-19 — 统一 AimNade 工程命名

**任务**：将工程内的产品与技术命名统一为 `AimNade`。

**做了**：

- 工程、Target、Scheme、构建产物、源码目录、App 入口类型与文件统一为 `AimNade`。
- Bundle Identifier 更新为 `com.example.AimNade`。
- 更新 `AGENTS.md`、`README.md`、`PROJECT_STATUS.md`、`docs/LOCALIZATION.md` 和本地 `CODEX.md` 中的路径与构建命令。
- 保留所有业务功能、JSON 数据、本地化内容和资源内容不变。

**验证**：`xcodebuild -project AimNade.xcodeproj -scheme AimNade -destination 'platform=iOS Simulator,name=iPhone 17' -configuration Debug build` → `** BUILD SUCCEEDED **`。构建产物为 `AimNade.app`，Bundle Identifier 为 `com.example.AimNade`。

**影响**：Bundle Identifier 已变化，已有安装中的 `UserDefaults` 数据不会自动迁移到新的 App 标识。

---

### 2026-09-19 — 刷新 `README.md`（已合并至 `main`）

**任务**：把已过期的 `README.md` 重写为与当前实现一致的简短项目描述，并按交接义务同步本文件。

**做了**：

- **重写 `README.md`**：产品名 `AimNade`、功能清单（2D 地图与聚类缩放 / 道具列表 / 搜索 / 收藏 / 详情页 / 中英双语 / 开发者模式）、V1 范围（只做 Mirage）、运行与构建方式、以及 `AGENTS.md` / `PROJECT_STATUS.md` / `docs/LOCALIZATION.md` 的索引。
- 新增内容**逐条对照源码核实**，没有沿用旧描述：道具组 / 方案数量读自 `Data/lineups_mirage.json`（3 组 / 6 方案），聚类与双击缩放确认存在于 `Views/TacticalMapView.swift`，`Assets.xcassets` 下确认只有 `mirage_map` / `creator_avatar` 两个 imageset，文案措辞对照 `Localization/L10n.swift`（`appIntro` / `unofficialNoticeText`）。
- 按 `AGENTS.md` 第 5 节要求，在 README 中**显式标注当前道具数据为占位内容**，并保留"非官方"表述。
- 同步本文件四处：`## In Progress` 的工作区状态、`## Known Issues` 第 14 条、`## Next` 的 P1 第 7 项、`## Next Agent Handoff` 的当前基线。

**没有做**：

- ❌ 未修改任何 `.swift` / `.json` / `.pbxproj` / `.xcscheme` / `Assets` 内容。
- ❌ 未改 `AGENTS.md`、`docs/LOCALIZATION.md`、`CODEX.md`。

**提交**：分支 `docs/refresh-readme`，已通过 PR #37 合并至 `main`。

**验证**：改动为纯文档。**本机为 Windows，没有 Xcode，未执行 `xcodebuild`**；App 代码零改动，`737fdaf` 的 `BUILD SUCCEEDED` 基线仍适用，但**尚未在 Mac 上重新确认**。

---

### 2026-09-16 — 建立共用交接机制

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

- ❌ 未修改任何 `.swift` / `.json` / `.pbxproj` / `.xcscheme` / `Assets` 内容（`git diff --stat -- AimNade/` 为空可证；`AimNade/` 下 33 个被跟踪文件与 HEAD 逐字节一致）。
- ❌ 未修改 `README.md`、`CODEX.md`、`docs/LOCALIZATION.md`。
- ❌ 未 `git add` / 提交两个工程文件噪声，未还原任何现有改动。

**提交**：本次以 `Add shared agent handoff documentation` 为信息，**仅提交** `AGENTS.md` 与 `PROJECT_STATUS.md` 两个新文件（父提交为 `737fdaf`）。该提交已 push 到 `origin/main`，本地 `main` 与远端同步。

**验证**：`xcodebuild -project AimNade.xcodeproj -scheme AimNade -destination 'platform=iOS Simulator,name=iPhone 17' -configuration Debug build` → `** BUILD SUCCEEDED **`。改动仅限两个 Markdown 交接文件，App 代码零改动。

**后续修订（2026-09-16，仅文档）**：根据"真实教学截图允许继续使用占位图"的决定，**重新排定了 `## Next` 的优先级**：

- P0-1 从"补齐 18 张教学图片"改为"**配置正式 App Icon 与 Accent Color**"。
- 新增 P0-2"**对当前 V1 做一次完整产品流程检查**"（10 个面：Mirage 首页 / 2D 地图 / 道具列表 / 搜索 / 收藏 / LineupGroup / LineupVariant / 教学图片占位 / About / 中英切换；只检查现有实现与明显问题，不新增大功能）。
- P0-3 由"暂不补齐 key"改为"**做专项 localization audit，修正文档与实际 key 的差异**"，并明确**不要为了补 key 重构 App**。
- "补齐 18 张教学图片"与"录入真实 Mirage 道具数据"合并降级为 **P1 内容填充任务**（P1-9 / P1-10），明确**不阻塞交付**。
- 本轮**只改本文件**；未修改 App 功能代码，未修改 `AGENTS.md`（其中 §5 教学图说明与 §11 文档索引的措辞仍按上一版，可择机同步）。

## Next Agent Handoff

### 当前基线

- 分支 `main`：本轮任务前本地 `HEAD` 与 `origin/main` 同步在 `ffe928f` (`Refactor AimNade navigation around tactics`)；战术页视觉优化和三地图接入已由本轮任务提交并推送。
- Mirage 保留 3 组 / 6 方案占位数据与完整交互；Ancient / Nuke 是 0 道具数据的地图预览态，使用用户提供的中文标注 JPEG。
- 任务前已存在的 Xcode 27 升级元数据差异、未跟踪 `CODEX.md` 和用户本地 `图库/` 仍保留；不要把它们混入后续提交。
- Debug 构建通过（iPhone 17 + iOS 26.5 模拟器）；`assetutil` 确认三张地图入包；已检查三图浅色界面、Ancient / Nuke 深色界面、Mirage 点位选中卡和列表模式。

### 建议的下一个任务：P0-3 localization audit

**为什么是它**：当前主流程、三地图预览与交付资源均已完成，规范文档仍比实际 `L10n.Key` 少 39 个条目。

**执行边界**：

- 对齐 `docs/LOCALIZATION.md` 与实际 100 个 `L10n.Key`（当前登记 61，差 39）。
- 确认英文和简体中文分支覆盖一致，并检查 `Views/` 下没有新增硬编码固定文案。
- 把规范中的地图范围更新为 Mirage / Ancient / Nuke，同时保留"只有 Mirage 有道具数据"的真实边界。
- 以文档修正为主；若发现真正的代码缺口，单独记录并最小修复，不做结构性重构。

### 内容填充任务（P1，不阻塞交付）

- **录入真实 Mirage 道具数据**（取代当前占位/示例数据），并记录来源与核验方式。
- **为 Ancient / Nuke 录入真实道具数据**，仅在数据来源、核验方式和素材授权确定后启动。
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

- 在 `AimNade/Assets.xcassets/` 下新增 imageset，**资源名必须与 JSON 中声明的名字逐字一致**（拼错不会报错，只会继续显示占位图）。
- 建议先做 3 张打通链路（`mirage_window_smoke_standard_t_spawn` 的站位 / 瞄点 / 结果），在模拟器里确认 `LineupDetailView` 的折叠区、全屏分页预览、图片缩放三处都换成真图，再批量推进剩余 5 个变体。
- 新增完毕后确认 `.xcodeproj` 的 Resources 阶段仍正常（asset catalog 是整目录引用，通常无需改 pbxproj，但请验证构建）。
- **图片的来源与授权必须先确认**（见 Known Issues 第 18 条）。转发他人游戏截图有版权风险；若是自截图，请在本文件记录来源与日期。**这是真正的前置条件，不是优先级问题。**

### 不要做的事

- 不要在"产品流程检查"里夹带新功能；新需求只登记，不在本轮实现。
- 不要为了补 localization key 而重构 App 或改动界面结构。
- 不要把 `MapListView` 恢复成启动前置页——Mirage / Ancient / Nuke 已在战术页顶部统一切换。
- 不要给开发者模式的坐标拖动加写回逻辑。
- 不要通过静默 fallback 长期掩盖 JSON 数据错误。
- 不要在没有明确理由时改动 `LineupModels.swift`、`project.pbxproj` 或 `lineups_mirage.json`。
- 不要提交 `project.pbxproj` / `.xcscheme` 的 Xcode 升级噪声，也不要把 `CODEX.md` 混进无关提交。
- 不要把 `CODEX.md` 路线图里的 v1.5 / v2.0 条目（更多地图、社区功能、云同步）当作待办。
