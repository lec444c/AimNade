# AimNade Project Status

> 本文件是 Codex 与 DSH 共用的进度快照，每次完成任务后必须更新（规则见 `AGENTS.md` 第 10 节）。
> 最后更新：2026-09-21
> 本轮任务前基线：`d688cdb`（`Blend tactics header into system background`，已推送至 `origin/main`）
> 最近一次验证：Debug 构建通过；iPhone 17 / iOS 26.5 模拟器浅色/深色模式首页检查通过。

---

## Current Version

| 项 | 值 | 来源 |
|---|---|---|
| Marketing Version | `1.0` | `project.pbxproj` |
| Build Version | `1` | `project.pbxproj` |
| Bundle Identifier | `com.example.AimNade` | `project.pbxproj`，仍为模板标识 |
| 显示名 | `AimNade` | `en.lproj` / `zh-Hans.lproj` |
| Deployment Target | iOS 17.0 | `IPHONEOS_DEPLOYMENT_TARGET` |
| 阶段 | 三地图本地 MVP | Mirage 有占位道具流程，Ancient / Nuke 为地图预览 |

## Current Goal

当前 MVP 的主要交互已收敛为“列表学习，地图参考”：

1. Mirage 默认从分类列表进入道具学习流程。
2. Mirage / Ancient / Nuke 的 2D 地图保留平移、双指缩放和双击缩放，作为清晰的地图结构参考。
3. 搜索、收藏、道具组详情、方案详情、本地化与深色模式继续正常工作；阵营和道具类型筛选仅在存在多个实际选项时出现。
4. 下一个交付优先级是让 Mirage JSON 加载失败可观察，保留防崩溃 fallback。

## Completed

### 工程基线

- 单一 Target / Scheme `AimNade`，Swift 5 + SwiftUI，iOS 17.0，支持 iPhone 与 iPad。
- 零第三方依赖，无网络、账号、后端或数据库。
- App Icon 已配置；Accent Color 为 `#3A7AFE`，`AppTheme.accent` 继续来自 `Color.accentColor`。
- 当前没有测试 Target，Debug 构建是主要自动化验证。

### 数据与内容

- `Map → LineupGroup → LineupVariant` 三级 `Codable` 模型。
- Mirage 从 `AimNade/Data/lineups_mirage.json` 加载 3 个道具组 / 6 个投掷方案；均为 T 方 Smoke 占位数据。
- 每个方案保留名称、身位要求、起始/目标区域、投掷方式、说明、难度和三张教学图资源名。
- Ancient / Nuke 仅有用户提供的中文标注地图，`lineupGroups` 为空，未伪造战术内容。
- JSON 的 ID 唯一、枚举取值可解码，40 个双语对象均含非空 `en` / `zhHans`。

### 主界面与导航

- 根导航为战术 / 收藏 / 设置三个 Tab，每个 Tab 有独立 `NavigationStack`。
- 战术页顶部整块地图上下文均可打开 Mirage / Ancient / Nuke 选择器，并显示当前地图的道具组与方案数量。
- Mirage 默认进入列表；列表按区域分组，每行展示“起点 → 目标点”、身位要求、类型、阵营、难度和收藏入口。
- Mirage 可手动切换到地图视图；Ancient / Nuke 因暂无道具数据，直接显示专属主题的地图预览。
- 地图可平移、双指缩放和双击缩放，`TacticalMapView` 仅负责图片呈现与缩放。

### 搜索、筛选、详情与收藏

- 战术页内联搜索可匹配道具组与方案的 ID、名称、区域、投掷方式、说明与难度等字段。
- T / CT 与道具类型筛选根据当前数据自适应：只有存在多个可选值时才显示，并展示可用数量。
- 道具组详情、投掷方案详情、投掷步骤、教学图折叠区、全屏分页与图片缩放已实现。
- `FavoriteStore` 管理道具组和单个方案的收藏 ID，使用 `UserDefaults` 持久化。

### 设置、本地化与设计系统

- 设置页包含跟随系统 / 简体中文 / 英文三档语言选择和关于页入口。
- `L10n.Key` 共 81 个，英文与简体中文分支均完整；`LocalizedText` 承载 JSON 业务内容。
- `AppTheme` 统一管理品牌蓝、战术橙、Ancient 绿、Nuke 蓝、语义色、圆角和间距。
- 界面使用系统语义色适配浅色/深色模式；关键入口有辅助功能标签。

## In Progress

- 当前没有功能开发进行中。下一项建议任务是 JSON 加载失败可观察化。

### 工作区边界

任务前已存在且本轮不应混入提交的内容：

```text
 M AimNade.xcodeproj/project.pbxproj   # Xcode 27 自动升级噪声
 M AimNade.xcodeproj/xcshareddata/xcschemes/AimNade.xcscheme
?? CODEX.md
?? 图库/
```

- Scheme、`CODEX.md` 与 `图库/` 保持本地原状。
- `project.pbxproj` 的 Xcode 27 升级字段和段落重排不纳入本轮提交。

## Next

1. **JSON 加载失败可观察化**：Debug 输出具体 load/decode 错误；UI 区分 Mirage 加载失败与 Ancient / Nuke 正常空数据预览；保留 fallback 防止崩溃。
2. **占位内容显式标记**：确认是否为数据模型增加可选 `isPlaceholder` 字段，并在 UI 中传达内容可信度。
3. **自动化验证**：建立测试 Target，优先覆盖 JSON 解码、搜索匹配、收藏持久化和数据 ID 唯一性。
4. 录入已核验的 Mirage 道具数据，优先补足 B 包点、CT 方与 Flash / Molotov / HE 类别。
5. 补齐 18 张教学图，记录来源、授权和游戏内核验方式。
6. 验证 iPad、横屏、Dynamic Type、VoiceOver 与真机手势。
7. 在数据来源、核验方式与素材授权明确后，再为 Ancient / Nuke 增加道具内容。

## V1 Scope

**V1 内置 Mirage、Ancient、Nuke 三张 2D 地图；道具学习内容当前仅位于 Mirage。**

包含：

- Mirage 分类列表、搜索、阵营/道具筛选与详情学习流程。
- Mirage / Ancient / Nuke 可缩放 2D 地图参考。
- 站位图 / 瞄点图 / 结果图三张教学图结构。
- 道具组与方案收藏、详情页、设置页、关于页。
- 简体中文与英文。

## Not Planned For V1

- 3D 地图或 3D 视角
- 视频教学
- 登录 / 账号体系
- 后端服务 / 云同步
- 用户投稿 / UGC

## Important Architecture

### 入口与状态

- `AimNade/AimNadeApp.swift` 是 `@main` 入口，注入 `LanguageManager` 与 `FavoriteStore`。
- `TacticsView` 管理当前地图、地图/列表模式、T/CT、道具类型与搜索词。
- `TacticalMapView` 是纯地图参考组件，内含简化的 `UIScrollView` 缩放桥接。
- `MapListView.swift` 已实现但不接入根导航；三张地图在战术页顶部统一切换。

### 数据模型

- `Map { id, name, imageName, lineupGroups }`
- `LineupGroup { id, mapId, targetName, type, side, category, isFeatured, variants }`
- `LineupVariant { id, name, spawnRequirement, startArea, targetArea, throwMethod, description, difficulty, positionImageName, aimImageName, resultImageName }`
- `difficulty` 是 `String`；当前已本地化 `Easy` / `Medium`，未知值会原样显示。

### 数据流

`LineupStore.maps` 提供三张 `Map` → `TacticsView` 管理当前上下文。Mirage 的内容链路为 `lineups_mirage.json` → `LineupStore.mirageMap` → 内存搜索/筛选 → 列表/详情。Ancient / Nuke 是代码定义的空 `Map`，只引用 Asset Catalog 中的地图图片。

### 文件规模

- 22 个 Swift 文件，共 2814 行 Swift。
- 关键文件：`TacticalMapView.swift` 169 行，`TacticsView.swift` 468 行，`LineupModels.swift` 135 行，`L10n.swift` 430 行，`lineups_mirage.json` 238 行。

## Important Rules

1. 以当前源码、JSON、资源和 Git 历史为真相源，不依赖旧对话记忆。
2. 开始任务前读取 `AGENTS.md` 与本文件；完成开发任务后更新本文件并检查 README。
3. 不编造真实 CS 道具数据；占位内容必须明确标注。
4. 不破坏搜索、收藏、地图参考、列表、详情、设置、关于与本地化流程。
5. 不引入网络、账号、数据库或第三方依赖，除非需求明确要求。
6. 只提交本任务文件；不混入 Xcode 升级噪声、Scheme 本地改动、`CODEX.md` 或用户素材目录。

## Known Issues

1. Mirage 内容仍是未经实战核验的占位/示例数据：3 组 / 6 方案，全部为 T 方 Smoke。
2. 18 张教学图资源全部缺失，详情页目前显示占位图。
3. Ancient / Nuke 地图的中文标注已烘焙在 JPEG 中，切换英文时不会变化；发布前仍需确认授权。
4. `LineupStore` 在 JSON 缺失或解码失败时会静默回退空 Mirage，当前缺少可观察的错误状态。
5. Bundle Identifier 仍为 `com.example.AimNade`，正式发布前需更换。
6. 无测试 Target，暂无 JSON 解码、搜索、收藏持久化或 UI 回归覆盖。
7. `CODEX.md` 仍是未跟踪的本地文件，其内容可能落后于当前导航与数据模型。

## Last Work

### 2026-09-21 — 战术首页信息层级优化

- 地图标题、统计信息与右侧主题图标组成完整的地图选择入口，扩大可点击范围并保持原生 `Menu` 交互。
- 阵营与道具类型控件由当前地图数据驱动，仅在存在多个实际选择时出现；当前单一 T 方烟雾弹占位内容保留搜索与地图/列表切换，首页更专注于可用内容。
- 列表分区数量改为紧邻标题的胶囊标记；投掷卡副标题显示身位要求，减少重复信息并提高浏览价值。
- 道具类型图标改为轻量圆角方形色块，在列表与详情之间保持统一。
- README 已同步按内容呈现筛选控件的实际行为。
- 验证：Debug 构建通过；iPhone 17 / iOS 26.5 模拟器分别检查浅色与深色首页。

### 2026-09-20 — 战术页顶部渐变衔接

- 战术页背景从系统动态背景色平滑过渡到当前地图主题色，并将背景层延伸进顶部安全区，消除状态栏与内容区之间的硬切边界。
- 仅修改 `TacticsView.swift` 的背景渐变，未改动导航、数据、筛选、列表卡片或本地化。
- 验证：Debug 构建通过；iPhone 17 / iOS 26.5 模拟器分别检查了浅色与深色模式，顶部衔接连续。
- README 已检查，本轮仅是视觉细节调整，无需更新功能或架构说明。

### 2026-09-20 — 列表优先与地图参考收敛

- Mirage 的默认模式设为列表，在地图切换时，有道具内容的地图进入列表，空数据地图进入地图预览。
- `TacticalMapView` 收敛为 169 行的纯地图显示/缩放组件，保留地图平移、双指缩放和双击缩放。
- `MapMarkerView` 收敛为列表和详情共用的道具图标，保持搜索、筛选、收藏和详情流程不变。
- `Map` / `LineupGroup` / `LineupVariant` 与 `lineups_mirage.json` 已与当前列表/详情学习流程对齐。
- 设置页现仅包含语言与关于页；App 入口仅注入 `LanguageManager` 与 `FavoriteStore`。
- 本地化清单收敛为 81 个实际使用/保留的 key，英文、简体中文与 `docs/LOCALIZATION.md` 已对齐。
- README 与 `AGENTS.md` 已同步当前产品交互、数据 schema、持久化边界与文件规模。
- 验证：JSON 格式与 schema 检查通过；Debug 构建通过；iPhone 17 / iOS 26.5 模拟器启动正常，Mirage 首页默认列表可见 3 组 / 6 方案。

## Next Agent Handoff

### 建议的下一个任务：JSON 加载失败可观察化

**原因**：当前 `LineupStore` 在 JSON 缺失或解码失败时静默回退空 Mirage，真实数据错误会看起来像“没有内容”。

**建议边界**：

- 保留 fallback，继续确保 App 不因本地 JSON 错误崩溃。
- Debug 输出文件名与具体解码错误。
- UI 将 Mirage 加载失败与 Ancient / Nuke 正常空数据预览区分开。
- 不改 JSON schema，不增加网络、后端、数据库或第三方依赖。
- 同时验证正常 JSON、缺失文件和解码失败三条路径。

### 内容填充前置

- 真实 Mirage / Ancient / Nuke 道具数据必须有可核验来源与游戏内复验。
- 教学图资源名须与 JSON 完全一致；添加前确认来源与授权。
- 任务前已存在的 `project.pbxproj` / Scheme 噪声、`CODEX.md` 与 `图库/` 不得混入无关提交。
