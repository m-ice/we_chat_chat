# 首页根页面迁移核对

## 范围

- iOS 真相源：`Pages/Home/MTHomeViewController.swift`、`MTHomeFeedCell.swift`、`MTHomeWaterfallCell.swift`
- Flutter：`lib/modules/home`
- 当前记录覆盖首页根页面及其所有可达业务入口。

## 对照结论

| 项目 | 结果 | 说明 |
|---|---|---|
| 页面结构 | implemented | 顶部城市、活动/附近/新人三段切换、筛选入口和三类内容区 |
| 活动列表 | implemented | 过滤过期活动；卡片封面、标题、简介、地点、日期、人数、状态按 iOS 规则展示 |
| 附近列表 | implemented | 两列瀑布式卡片、真人/视频标识和“查看 Ta 的活动”外观 |
| 新人列表 | implemented | 两列卡片及本地持久化关注/取消关注 |
| 数据来源 | implemented | iOS fixture 转为 JSON，经 Repository 注入；Widget 不持有业务数组 |
| 城市筛选 | implemented | 城市页、选择回传、首页重载及 `mt_home_selected_city` 持久化已接通 |
| 活动筛选 | implemented | 关键词、重置/确认、用户/组队详情、治理及加入入口已接通 |
| 发布及详情导航 | implemented | 组队发布/审核、用户详情、组队详情、举报与媒体预览均有真实目标页 |
| 加入活动 | implemented | 首页、筛选和话题详情均执行 VIP 门槛并写入 iOS 同语义待加入状态 |
| 运行验证 | passed | `flutter analyze` 0 issue，20 项测试通过，iOS 14 Debug 无签名构建通过；逐页人工运行验收仍待完成 |

## 动态内容与边界

- 昵称、地点、活动标题和描述使用省略策略，卡片尺寸保持稳定。
- 附近/新人使用懒加载 `GridView.builder`，活动使用 `ListView.builder`。
- 空活动列表属于当前 fixture 日期均已过期后的真实结果，不用占位业务数据伪造内容。
- 中文与英文新增文案均进入 GetX 翻译表；城市业务值固定保存为 iOS 使用的“全部”，展示时再本地化。

## 已知视觉差异

- iOS 的 `UICollectionView` waterfall delegate 固定卡片高 240；Flutter 使用等价的双列固定主轴高度网格。
- iOS 使用 SF Symbols 的旗帜、时间和下拉符号；Flutter 使用对应 Material 系统图标。
- Material 系统图标替代 SF Symbols；业务入口均已接通，不存在为未迁移页面保留的空回调或占位页。

## 人工验收待办

- 模拟器逐一核对城市切换、筛选、直接加入、VIP 门槛、发布、详情、举报及媒体预览的视觉和返回行为。
