# AimNade

AimNade 是面向 Counter-Strike 玩家、以本地内容驱动的战术道具学习 iOS App。通过 2D 地图、分类列表与投掷方案详情，帮助玩家查找和学习道具点位。

当前内置 **Mirage、Ancient、Nuke** 三张 2D 地图，支持 iPhone 与 iPad。所有内容随 App 打包，收藏与偏好保存在设备本地，无需联网或登录。

> 只有 Mirage 内置道具内容，而且仍是**未经实战核验的占位 / 示例数据**：共 3 个道具组、6 个投掷方案，均为 T 方烟雾弹。18 张教学截图尚未提供。Ancient 与 Nuke 当前只提供地图预览，没有道具点位。

## 已实现功能

- **三栏主导航**：底部只保留战术、收藏、设置三个 Tab；启动后直接进入战术页，从顶部切换 Mirage / Ancient / Nuke。
- **三地图 2D 预览**：每张地图都支持平移、双指缩放和双击缩放；Mirage 使用蓝橙主题，Ancient 使用绿色主题，Nuke 使用蓝色主题。
- **Mirage 战术交互**：支持点位聚类；点击点位先显示可收藏的道具预览卡，再进入详情。Ancient / Nuke 在没有道具数据时使用简化的地图预览界面。
- **地图 / 列表双视图**：Mirage 的两种视图共享搜索、道具类型和 T / CT 阵营筛选；筛选项显示当前可用数量，列表按区域分组并直接显示“起点 → 目标点”。
- **投掷方案详情**：查看身位要求、起止区域、投掷方式、难度与说明。
- **教学图片浏览**：已实现站位图、瞄点图、结果图的折叠展示、全屏分页和缩放；当前资源缺失时使用占位图。
- **内联中英文搜索**：战术页顶部实时过滤道具名称、起点、目标点、区域与道具类型，支持大小写折叠和去空格匹配。
- **本地收藏**：可收藏整个道具组或单个投掷方案，重新启动后保留。
- **设置与关于**：支持跟随系统、简体中文、英文三档语言选择；关于页展示作者、版本、非官方声明与鸣谢。
- **主题与资源**：使用系统语义色适配浅色 / 深色模式，已配置 App Icon 与品牌强调色 `#3A7AFE`。
- **开发者模式**：显示和拖动地图坐标，复制单点坐标或坐标 JSON。编辑仅保留在当前页面状态中，**不会写回数据文件**。

筛选项已包含闪光弹、燃烧弹、手雷及其他区域，但当前示例数据不覆盖所有类别；筛选后没有结果属于正常情况。

## 技术栈

| 项目 | 当前配置 |
| --- | --- |
| 语言与界面 | Swift 5、SwiftUI |
| 最低系统 | iOS 17.0 |
| 设备 | iPhone、iPad |
| 工程 | `AimNade.xcodeproj`，单一 Target / Scheme：`AimNade` |
| 数据 | App Bundle 内的 JSON 与本地地图资源；JSON 使用 `Codable` 解码 |
| 本地存储 | `UserDefaults`：收藏、语言偏好、开发者模式开关 |
| UIKit 桥接 | 地图与图片缩放、剪贴板导出 |
| 第三方依赖 | 无，无需安装 SPM / CocoaPods / Carthage 依赖 |

## 运行与构建

需要安装 Xcode 的 macOS 开发环境。最近验证环境为 **Xcode 27.0（27A266a）+ iOS 26.5 的 iPhone 17 模拟器**；这是已验证组合，不代表最低 Xcode 版本要求。

1. 获取仓库并进入根目录。
2. 用 Xcode 打开 `AimNade.xcodeproj`。
3. 选择 `AimNade` Scheme 和已安装的 iOS 模拟器，点击运行。

也可在仓库根目录执行构建：

```bash
xcodebuild -project AimNade.xcodeproj -scheme AimNade \
  -destination 'platform=iOS Simulator,name=iPhone 17' -configuration Debug build
```

如果没有对应模拟器，先查看可用目标，再替换命令中的设备名称：

```bash
xcodebuild -project AimNade.xcodeproj -scheme AimNade -showdestinations
```

真机运行需在 Xcode 中配置自己的签名团队及可用的 Bundle Identifier。仓库当前使用 `com.example.AimNade`，正式发布前还需完成应用标识、签名及发布检查。

当前没有自动化测试 Target。构建通过不等于功能验收完成；修改后还需按影响范围手动检查地图、搜索、收藏、详情、中英切换和深色模式。

## 项目结构

```text
AimNade.xcodeproj/           Xcode 工程与共享 Scheme
AimNade/
├── AimNadeApp.swift         App 入口、根导航及共享状态注入
├── Views/                  战术主页、地图、列表、收藏、详情、设置、关于
│   └── Components/         地图标记、道具徽章等复用视图
├── Models/                 道具模型、收藏状态、开发者设置
├── Data/                   JSON 内容与 LineupStore 加载入口
├── Theme/                  AppTheme 颜色、间距与圆角
├── Localization/           固定文案、双语业务文本与语言管理
├── Assets.xcassets/        地图、头像、App Icon 与 Accent Color
├── en.lproj/               英文应用名称资源
└── zh-Hans.lproj/           简体中文应用名称资源
docs/                       专项开发文档
```

当前采用轻量分层的 SwiftUI 架构。App 根视图为 `TabView`，战术、收藏、设置各自使用独立 `NavigationStack`。`TacticsView` 统一持有当前地图、地图/列表模式、阵营、道具类型和搜索状态，再把同一份过滤结果交给地图或列表展示。

地图链路为：`LineupStore.maps` → `TacticsView` 顶部选择器 → 对应地图页面。Mirage 的道具数据链路为：`lineups_mirage.json` → `LineupStore.mirageMap` → `Map` → `LineupGroup` → `LineupVariant`。Ancient / Nuke 目前是 `lineupGroups` 为空的地图预览。`MapListView` 仍未接入根导航，地图切换不需要额外前置页。

## 内容维护与当前限制

- 当前唯一的道具内容源是 [AimNade/Data/lineups_mirage.json](AimNade/Data/lineups_mirage.json)，字段需与 [LineupModels.swift](AimNade/Models/LineupModels.swift) 保持一致。
- Ancient / Nuke 使用用户提供的中文标注 JPEG 地图，文字已烘焙进图片，因此切换到英文界面后地图标注仍为中文。正式发布前还需确认两张图片的使用授权。
- 道具组表示同一目标点的一组投掷方案；每个方案记录位置、投掷说明及三张教学图的资源名。地图坐标为 `0…1` 归一化值。
- 业务文本使用 `LocalizedText` 的 `en` / `zhHans` 字段；固定界面文案通过 `L10n` 管理。
- 教学图需加入 `Assets.xcassets`，资源名须与 JSON 完全一致。真实数据及图片应记录来源、授权情况与游戏内核验方式。
- JSON 加载失败时目前回退为空地图，尚无明确错误提示；改动数据后需实际运行确认内容可见。
- V1 范围为 Mirage / Ancient / Nuke 三张本地 2D 地图；完整道具学习内容目前仅位于 Mirage。不包含 3D、视频、账号、后端或用户投稿。

## 后续方向

下一步优先让 JSON 加载失败可被开发者和用户明确感知，再推进真实道具数据和截图填充、自动化测试及设备适配验证。本地化专项核对已完成。详细优先级、验收记录和已知问题见 [PROJECT_STATUS.md](PROJECT_STATUS.md)。

## 文档与维护约定

| 文档 | 用途 |
| --- | --- |
| [README.md](README.md) | 面向读者的当前功能、使用方式、技术栈和项目结构 |
| [AGENTS.md](AGENTS.md) | Codex / DSH 共用开发规则及任务结束检查要求 |
| [PROJECT_STATUS.md](PROJECT_STATUS.md) | 进度快照、验证结果、已知问题与下一步交接 |
| [docs/LOCALIZATION.md](docs/LOCALIZATION.md) | 本地化约定、完整 100-key 清单、职责边界与审计方法 |

每次开发任务结束时都应检查 README：涉及功能、运行方式、依赖、目录、数据状态或限制的变化，须在同一任务中同步对应章节；无相关变化时无需改写 README，在项目状态中记录检查结论即可。只读任务只报告差异。具体要求见 `AGENTS.md` 第 10 节。

README 描述当前项目，不用于记录逐次开发日志；尚未实现的能力只能列为后续方向。
