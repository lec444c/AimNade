# AGENTS.md — AimNade 仓库工作指南（Codex / DSH 共用）

本文件是**长期约束**，对所有在本仓库工作的 AI Agent（Codex、DSH 等）生效。它只规定"什么能做、什么不能做、改动如何交接"，不描述进度快照。

- 进度快照 → `PROJECT_STATUS.md`（每次完成任务后必须更新）
- 项目介绍 → `README.md`（每次开发任务结束时检查，相关内容有变化时同步更新）
- 完整架构与功能清单 → `CODEX.md`
- 本地化规范 → `docs/LOCALIZATION.md`

---

## 1. 项目身份

- **项目名 / 产品名**：AimNade。显示名由 `AimNade/en.lproj/InfoPlist.strings` 与 `AimNade/zh-Hans.lproj/InfoPlist.strings` 的 `CFBundleDisplayName` 决定（当前两处均为 `AimNade`），`project.pbxproj` 中另有 `INFOPLIST_KEY_CFBundleDisplayName = AimNade`。
- **Xcode 工程 / Target / Scheme 名**：`AimNade`。
- **仓库根目录**：本文件所在目录，也是 git toplevel。Swift 源码在子目录 `AimNade/`。
- **定位**：Counter-Strike 战术道具（lineup）学习类 iOS App。本地数据驱动，无网络、无账号、无后端。

## 2. 技术栈

- **语言 / UI**：Swift 5 + SwiftUI。
- **最低版本**：iOS 17.0（`IPHONEOS_DEPLOYMENT_TARGET = 17.0`）。
- **设备**：iPhone + iPad（`TARGETED_DEVICE_FAMILY = "1,2"`）。
- **工程形态**：纯 `.xcodeproj`，**单一 target `AimNade`**。
- **第三方依赖**：**零**（无 SPM / CocoaPods / Carthage）。不要引入依赖，除非需求明确要求。
- **UIKit**：仅用于 SwiftUI 无法合理覆盖的场景，通过 `UIViewRepresentable` 接入——地图缩放、教学图片缩放、剪贴板导出。
- **持久化**：仅 `UserDefaults`（语言偏好、收藏 ID、开发者模式开关）。不引入数据库。
- **网络**：无。不引入任何网络请求。
- **测试 Target**：**当前不存在**，因此没有 `xcodebuild test`。构建通过是当前唯一的自动化验证手段。

## 3. V1 范围（硬约束）

**V1 只做 Mirage 这一张地图。**

V1 要做：

- 2D 战术地图（点位、过滤、聚类、缩放）。
- 截图教学：每个投掷方案用「站位图 / 瞄点图 / 结果图」三张截图讲解。
- 分类列表、搜索、收藏、详情页、关于页。
- 简体中文 + 英文双语。

V1 **明确不做**（不要主动实现，也不要为它们预留过度抽象）：

- ❌ 3D 地图或 3D 视角
- ❌ 视频教学
- ❌ 登录 / 账号体系
- ❌ 后端服务 / 云同步
- ❌ 用户投稿 / UGC

> 注意：`UtilityType` 与 `LineupCategory` 已包含 Flash / Molotov / HE 与 B 包点 / CT 方等 V1 之外的取值。**枚举已支持 ≠ 内容已存在**，不要据此认为功能已完成。

### 已确认的架构决定（不要当作"待修的 bug"）

| 现状 | 决定 | 触发重新评估的条件 |
|---|---|---|
| `LineupStore.maps` 只含 Mirage；`MapListView` 未接入根导航 | **刻意设计**。V1 只做 Mirage，用户不需要地图列表前置 | **开始增加第二张地图时**才提升优先级，届时应把 `MirageDetailView` 等命名泛化为 `MapDetailView` |
| `LineupStore` 在 JSON 失败时回退空 `Map` | 保留 fallback（防 crash）**没有问题**；但"静默"需要改 | 后续任务：Debug 输出明确错误 + Release 显示 empty state |
| `docs/LOCALIZATION.md` key 清单滞后 34 个 | **本轮不补**，不做零散修补 | 一次专项 localization audit 统一对齐 |

## 4. 命名与本地化规则

- **UI 支持简体中文与英文**，外加"跟随系统"一档。
- 固定 UI 文案**必须**接入现有本地化系统：`L10n.Key` → 英文分支 → 简体中文分支，三处同步。**禁止**在 View 中硬写用户可见文本。
- JSON 中的业务内容使用 `LocalizedText`（`en` / `zhHans`），**不**放进 `L10n`。
- **图片资源名、代码变量名、数据 ID 一律使用英文**，不汉化。
- `L10n.Key` 当前有 95 个 case。`docs/LOCALIZATION.md` 的"当前核心 key"清单只登记了 61 个，**新增文案时以 `L10n.swift` 为准**，不要照抄清单。
- 提交前自检：在 `Views/` 下搜索 `Text("`、`Label("`、`Section("`、`navigationTitle("`，确认没有硬编码的固定文案（纯数字插值、已本地化的插值属合规）。

## 5. 数据规则

- **唯一内容数据源**：`AimNade/Data/lineups_mirage.json`，由 `LineupStore` 从 App Bundle 读取。
- JSON 结构必须与 `AimNade/Models/LineupModels.swift` 中的 `Map` / `LineupGroup` / `LineupVariant` 保持一致（`Codable`，字段名必须逐字匹配，缺失的可选字段会导致解码整体失败）。
- 改动数据后必须检查：**ID 唯一性**、坐标取值范围（`0…1` 归一化）、枚举取值（`UtilityType` / `LineupCategory` / `difficulty`）、以及引用的图片资源名是否真实存在。
- `LineupStore` 在 JSON 缺失或解码失败时会**静默回退为空 `Map`，不会向用户报错**。改动 JSON 后必须在 App 内确认内容可见，**不能只看构建是否通过**。
  - 保留 fallback 以防止 App crash 是可以接受的；**但"静默失败"不是最终设计**（已确认的决定）。改进方向：Debug 环境输出明确的 JSON decode / load 错误，Release / UI 层显示合理的 empty state。**不要通过静默 fallback 长期掩盖数据错误**，也不要把它当作已完成的错误处理。
  - V1 只支持 Mirage 是刻意设计，`Data/` 下只有 `lineups_mirage.json`。
- **不编造真实 CS 道具数据**。
  - 当前仓库内的 Mirage 内容属于**占位/示例数据**：数值坐标是手工挑的，教学图片资源尚不存在，内容未与真实游戏对拍。**在文档与回复中必须如此标注，不得描述为"已核实的真实道具数据"。**
  - 允许新增明确标记的占位数据；一旦录入真实数据，必须在提交信息 / `PROJECT_STATUS.md` 中写明来源与核验方式。
  - 当前 JSON schema **没有** `isPlaceholder` 之类的标记字段。是否新增属于数据模型变更，需按第 7 节流程处理（见 `PROJECT_STATUS.md` 的待确认项）。

## 6. 改动前必做

1. **先检查已有实现**，避免重复造组件或重复实现功能。改任何东西之前先 `grep` 全仓确认是否已存在同类 View / 组件 / 工具函数。
2. 分析影响范围：相关模型、数据、页面、导航、本地化、资源、持久化行为。
3. **不删除既有功能**。若必须替换或废弃，先说明原因、影响面与迁移方案。
4. **不擅自大规模重构数据模型**（`LineupModels.swift`）。模型变更会影响 JSON、搜索、收藏 ID、地图坐标与所有详情页。
5. **必须保持现有功能兼容**：搜索、收藏、2D 地图、道具列表、道具组详情、投掷方案详情、设置、关于页。改完要确认这些路径没有被破坏。
6. **不允许在没有明确理由时修改无关文件**。特别不要提交只由 Xcode 版本升级产生的工程文件噪声。

### 现有可复用资产（优先复用，不要重建）

| 资产 | 位置 | 说明 |
|---|---|---|
| `AppTheme` | `Theme/AppTheme.swift` | 颜色、圆角、间距的唯一来源 |
| `FeatureCard` | `Views/Components/FeatureCard.swift` | 首页功能卡片 |
| `MapMarkerView` | `Views/Components/MapMarkerView.swift` | 道具圆点标记（含开发者坐标浮层） |
| `UtilityBadge` | `Views/Components/UtilityBadge.swift` | 类型 / 阵营 / 分类 / 难度徽章 |
| `EmptyStateView` | `Views/EmptyStateView.swift` | 统一空状态 |
| `ZoomableScrollView` | `Views/TacticalMapView.swift` | 地图缩放容器（`UIViewRepresentable`） |
| `ZoomableImageView` | `Views/LineupDetailView.swift` | 教学图缩放（`UIViewRepresentable`） |
| `L10n` / `LocalizedText` / `LanguageManager` | `Localization/` | 本地化三件套 |
| `FavoriteStore` | `Models/FavoriteStore.swift` | 收藏状态 + UserDefaults 持久化 |
| `DeveloperSettings` | `Models/DeveloperSettings.swift` | 开发者模式开关 |

## 7. 安全与边界

- 开发者模式中的坐标拖动**只存在于页面 `@State` 中**，不会写回 JSON。不要把它当作已持久化数据，**也不要擅自为它添加写回逻辑**。
- 保持本地优先设计：不引入网络、账号、数据库或第三方依赖。
- 不要继续把不相关职责堆进单个巨型 View。`Views/TacticalMapView.swift`（1114 行，内含 17 个内部类型）已知需要拆分，**新增逻辑优先考虑独立组件**。
- `Views/MapListView.swift` 已实现但**未接入根导航**；`AimNadeApp.swift` 的 `NavigationStack` 直接进入 `MirageDetailView`。**这是已确认的刻意设计**（V1 只做 Mirage，用户不需要地图列表前置）。**不要顺手"修好"它**；只有任务明确要求"开始增加第二张地图"时才提升优先级。

## 8. 常用命令

```bash
# 构建（当前基线是 BUILD SUCCEEDED）
xcodebuild -project AimNade.xcodeproj -scheme AimNade \
  -destination 'platform=iOS Simulator,name=iPhone 17' -configuration Debug build

# 查看可用模拟器
xcodebuild -project AimNade.xcodeproj -scheme AimNade -showdestinations
```

改动后至少跑一次构建命令；由于没有测试，构建通过是当前唯一可自动化的验证手段。

最近一次验证的工具链：**Xcode 27.0（Build 27A266a）+ iOS 26.5 模拟器**，在 `737fdaf` 上得到 `BUILD SUCCEEDED`。换用**更旧**的 Xcode 打开工程会再次改写 `project.pbxproj` 的 `LastUpgradeCheck` 等字段，因此看到这类 diff 时先确认是不是工具链差异，而不是功能改动。

## 9. 工程文件注意事项

用新版 Xcode 打开工程会自动改写 `AimNade.xcodeproj/project.pbxproj`（`LastUpgradeCheck`、`LastUpgradeVersion`、`STRING_CATALOG_GENERATE_SYMBOLS`、`CLANG_ANALYZER_LOCALIZABILITY_NONLOCALIZED`，以及 group / `PBXVariantGroup` 段落顺序）。这类改动与功能无关。提交前请确认 diff 只包含你真正想提交的内容，**不要把无关的工程文件抖动混进功能提交**。

## 10. 完成任务后的交接义务

1. **必须更新 `PROJECT_STATUS.md`**，至少同步：`Completed` / `In Progress` / `Next` / `Known Issues` / `Last Work` / `Next Agent Handoff`。
2. **一个任务尽量对应一个清晰的 Git commit**，提交信息说明改了什么、为什么改。合并提交（merge）不要夹带功能改动。
3. **不要提交**：`xcuserdata`、DerivedData、编辑器临时文件、只由 Xcode 版本升级产生的工程文件噪声。`.gitignore` 已忽略 `.DS_Store` / `xcuserdata/` / `*.xcuserstate`。
4. **只提交本任务明确涉及的文件**。提交前先 `git status` 检查，不要顺手带上其他未跟踪文件或本地修改（例如 `project.pbxproj` / `.xcscheme` 的升级噪声）。
5. 报告改动时说明改了哪些文件以及各文件的主要变化；不确定的地方明确标注"待确认"，**不要把计划中的功能写成已完成**。

### README 同步维护（Codex / DSH 共用）

- **每次开发任务结束、提交前，必须检查 `README.md` 是否仍与当前仓库一致**。以下任一项发生变化时，在同一任务、同一提交中更新对应章节：用户可见功能、V1 范围、技术栈或依赖、最低系统要求、工程 / Scheme 名、运行与构建命令、主要目录和数据模型、素材与占位数据状态、影响使用的已知限制。
- 以当前代码、JSON、资源和工程配置为依据；涉及内容数量时重新核对数据，涉及构建环境时只写实际验证结果。已实现、占位 / 未核验、计划中三类内容必须区分。
- **README 使用中文，保留必要的英文标识符和命令**，面向用户和开发者说明当前项目；任务过程、commit / push 状态、详细优先级及验证记录写入 `PROJECT_STATUS.md`，不在 README 堆积日志。
- 无相关变化时不要为留痕而改动 README；在 `PROJECT_STATUS.md` 的本次 `Last Work` 中记录“README 已检查，无需更新”及简要原因。有变化时记录同步的章节及核验方式。
- 提交前检查文档内链接、路径和命令，并移除本次变更导致的过期描述；最终回复说明 README 已更新或无需更新。
- 用户指定只读时只报告文档差异，不修改 README 或状态文档；不要借同步文档扩大功能修改范围。

## 11. 文档索引

| 文件 | 用途 | 纳入 git | 状态 |
|---|---|---|---|
| `AGENTS.md` | 本文件：长期约束与交接机制 | ✅ 已提交 | 维护中 |
| `PROJECT_STATUS.md` | 当前进度快照（**每次任务后更新**） | ✅ 已提交 | 维护中 |
| `CODEX.md` | 完整架构、功能清单、路线图 | ❌ **未跟踪** | 已核对，与源码一致；纳管与否待定 |
| `docs/LOCALIZATION.md` | 本地化规范 + 核心 key 清单 | ✅ 已跟踪 | 规范有效；key 清单滞后 34 个，待专项 audit |
| `README.md` | 中文项目介绍、功能、结构与运行指南（**不作为 AI 进度日志**） | ✅ 已跟踪 | 按第 10 节随相关变更同步维护 |

> 进度记录的**唯一**去处是 `PROJECT_STATUS.md`。不要把进度写进 `README.md`，也不要在 `CODEX.md` 里维护状态。
