# iOS -> Flutter Migration Tracker

## Phase status

| Phase | Status | Verified | Difference / reason |
|---|---|---|---|
| iOS 工程分析 | verified | yes | 基于当前 Target 的源码、工程配置、Pods、资源和本地数据交叉检查 |
| 页面与数据模型映射 | verified | yes | 见 `docs/ios_migration`；不可确认项保留 `TODO(iOS_VERIFY)` |
| Flutter 基础架构 | verified | yes | App 启动、Domain/Data 分层；iOS Debug 无签名构建通过 |
| GetX 路由 / Binding | implemented | yes | 仅 root Route、InitialBinding、MainBinding；没有预建业务路由 |
| Theme / l10n / Assets / Mock | implemented | yes | iOS 核心 token、zh_CN/en_US、已确认资源、用户与聊天 fixture |
| 业务模块 | implemented | no | 当前 Target 中有入口且源码可确认的页面均已迁移；`MTCityViewController` 因无入口保留不迁移 |
| 全量运行验证 | implemented / manual verification pending | no | 全项目 analyze、20 项测试与 iOS 14 Debug 无签名构建已通过；仍需逐页模拟器人工验收及外部服务配置 |

## Module tracker

| iOS Source | Flutter Target | Status | Verified | Difference | Reason |
|---|---|---|---|---|---|
| `AppDelegate.swift`, `Base/MTTabBarController.swift` | `lib/app`, `lib/modules/main` | implemented | yes | Flutter 五 Tab 骨架，不含业务内容 | 顺序、标题、图标和默认 Tab 按 iOS |
| `Pages/Home/MTHomeViewController.swift`, `MTHomeFeedCell.swift`, `MTHomeWaterfallCell.swift` | `lib/modules/home` | implemented | no | 活动/附近/新人列表及关注、城市、筛选、发布、详情、举报、媒体预览已接线 | 待模拟器完整交互验收 |
| `Pages/Home/MTHomeCityPickerViewController.swift`, `Services/MTHomeCityService.swift`, `MTHomeCityOptions.swift` | `lib/modules/home/city_picker` | implemented | no | 城市搜索、选择、持久化和首页刷新闭环已实现 | Widget 闭环和 iPhone 14 Debug 启动已通过；尚未在真实模拟器交互中完成退出 App 后再启动复核 |
| `Pages/Topic/*`, `MTSquareFeedService` | `lib/modules/discover` | implemented | no | 推荐/关注、话题头/详情、动态发布聚合、关注、点赞、治理、媒体预览及中英文文案已接线 | 待模拟器视觉/滚动验收 |
| `MTCenterTabViewController`, `MTRealPersonVideoViewController`, `MTCenterSearchViewController` | `lib/modules/discover` | implemented | no | 城市/治理过滤、纵向分页、本地视频循环、内存点赞/收藏、搜索及用户入口已接线 | iOS 点赞/收藏本身不持久化；视频播放与返回暂停待模拟器验收 |
| `Pages/City/*` | — | not_migrated_no_entry | yes | 当前 Target 全局调用链仍无可达入口 | 保留源码但不凭空加入导航 |
| `Pages/Home/MTHomeActivityFilterViewController.swift` | `lib/modules/home/activity_filter` | implemented | no | 当前城市搜索、空态、重置/确认、直接加入、用户/组队详情与治理入口已实现 | 待模拟器完整交互验收 |
| `MTUserDetailViewController`, `FigureReportViewController`, `MTImagePreviewViewController` | `lib/modules/user_detail`, `lib/modules/shared` | implemented | no | 资料、邀请、聊天扣币、治理、举报与图片预览已实现 | 入口 Widget 验证通过；媒体手势待模拟器验收 |
| `MTTeamPostDetailViewController`, `MTGuideArticleViewController` | `lib/modules/home/team_detail` | implemented | no | 过期/申请状态、VIP 门槛、发起人、教程/攻略已接线 | 待模拟器完整交互验收 |
| `MTTeamPublishViewController`, `MTTeamPublishReviewViewController`, `MTTeamPublishService` | `lib/modules/home/team_publish`, `lib/data/repositories/team_publish_repository_impl.dart` | implemented | no | VIP/认证门槛、表单、三图、协议、Documents 图片与 `mt_published_team_posts` 待审核持久化已实现 | iOS 无审核状态转换事实源，待审核内容不插入首页；相册与 WebView 待模拟器验收 |
| `MTVoiceCallViewController` | `lib/modules/chat` | implemented | no | 对方回复门槛、首分钟 10 币、本地等待音与 30 秒自动结束 | iOS 原生音频构建通过；待模拟器听感验收 |
| `Pages/Message/*` | `lib/modules/chat`, `lib/domain/entities`, `lib/data/providers`, `lib/data/repositories`, `lib/data/mappers` | implemented | no | 会话列表、纯文本聊天、一发一回、助手 AI Mock、首次且仅一次赠送 100 币与本地持久化已实现 | Widget 入口、历史恢复及赠币幂等通过；待模拟器人工视觉与键盘验收 |
| `Pages/Profile/MTProfileViewController.swift` | `lib/modules/profile` | implemented | no | 资料卡、8 项菜单及编辑、钱包/VIP、认证、相册、我的世界、客服、协议入口均已接线 | 待模拟器完整交互验收 |
| `Pages/Profile/Edit/*`, `MTProfileEditService` | `lib/modules/profile` | implemented | no | 头像、昵称、简介、兴趣、个性标签与 `mt_profile_edit_model` 已接线 | 系统相册与 Documents 头像待模拟器验收 |
| `Pages/Profile/Album/*`, `MTAlbumService` | `lib/modules/profile` | implemented | no | 相片/视频分段、导入、三列网格、批量删除、预览及 `mt_album_store_model` 已接线 | Flutter 系统媒体选择器无法像 PHPicker 同时限定多选视频，当前过滤非视频结果；待模拟器验收 |
| `Pages/Profile/MyWorld/*`, `MTMyWorldService` | `lib/modules/profile` | implemented | no | 空态/列表、正文、三图、话题、协议、发布、待审核、删除及旧单图键兼容已实现 | 已与广场聚合共享，待模拟器媒体交互验收 |
| `Pages/Profile/Verify/*`, `MTRealPersonVerifyService` | `lib/modules/profile` | implemented | no | 原字段校验、双证件图、Documents 私有目录与 pending 模式已实现 | iOS 无审核转换/服务端闭环，保持待人工审核；待模拟器验收 |
| `MTPrivacyPolicyViewController`, `MTUserAgreementViewController`, `MTVIPAutoRenewAgreementViewController` | `lib/modules/shared/legal` | implemented | no | 两个 HTTP 远端页与自动续费内嵌 HTML 均已用 WebView 接线 | 网络内容、资源加载与返回行为待模拟器验收 |
| `MTVIPSubscriptionViewController`, `MTCoinsViewController`, `MTStoreTool` | `lib/modules/profile`, `lib/data/providers/store_purchase_service.dart` | implemented | no | 商品、价格、购买、恢复、交付去重与 iOS 持久化键已实现 | App Store 商品/沙盒未配置；生产收据服务端校验仍为 `TODO(iOS_VERIFY)` |
| `MTCustomerServiceViewController` | `lib/modules/profile` | implemented | no | 表单、逐字段校验、提交后清空与 iOS 一致 | iOS 提交无外部通道，正式客服接口仍为产品/后端缺口 |
| `FigureReportViewController`, filter stores | `lib/modules/shared/report`, `moderation` | implemented | no | 客户端举报表单及本地拉黑/屏蔽行为与 iOS 一致 | 正式举报上报和跨设备治理是 backend/product gap |
| `Services/*`, `Utils/MTStorageTool.swift` | `lib/data`, `lib/domain`, `lib/core` | implemented | yes | 用户、Feed、城市、社交状态、发布、资料、媒体、聊天、钱包/IAP 和 AI 边界均已接线 | 未发现的生产后端能力不伪造 |
| `Assets.xcassets`, `figureMutu`, `Resource` | `assets/*`, `ios/Runner/Assets.xcassets` | implemented | yes | 业务资源与原 1024px AppIcon 已迁移；未复制无入口 city Tab 图标 | AppIcon 已生成无 alpha 的完整尺寸集；映射见 `ios_assets_map.md` |

## Phase 2 foundation

| Foundation | Status | Verified | Notes |
|---|---|---|---|
| Flutter App Shell | implemented | yes | 五 Tab IndexedStack，真实 iOS Tab assets |
| Theme | implemented | yes | 颜色、34pt 标题、正文/辅助文本、16pt spacing、20pt radius |
| Localization | implemented | yes | GetX translations，zh_CN / en_US |
| Mock user data | implemented | yes | Repository -> AssetJsonProvider -> ISO 8601 JSON |
| Local chat storage | implemented | yes | JSON 首次初始化 -> SharedPreferences -> ChatRepository |
| Chat domain model | implemented | yes | 仅纯文本和 iOS 已证实字段 |
| flutter_chat_core mapper | implemented | yes | Domain 无插件 import；未映射已读/送达等状态 |
| AI abstraction | implemented | yes | MockAiProvider，无生产请求、无 API Key |

## Foundation verification

- `dart format .`：通过。
- `flutter pub get`：通过。
- `flutter analyze`：0 issue。
- `flutter test`：20 tests passed（当前全量）。
- `LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 flutter build ios --debug --no-codesign`：通过，产物 `build/ios/iphoneos/Runner.app`。
- CocoaPods 在非 UTF-8 shell locale 下会报 `Unicode Normalization not appropriate for ASCII-8BIT`；构建命令需使用 UTF-8 locale，项目代码无需规避处理。

## Rolling business verification

- `dart format .`：通过。
- `flutter analyze`：0 issue。
- `flutter test`：通过，覆盖三个首页子 Tab、五个主 Tab 资源及动态文本无 overflow。
- `flutter run -d 3401339F-E596-48DE-AA91-750B410D9876 --debug`：iPhone 14 模拟器 Debug 构建、安装、启动成功；检查首页根页和新人卡片图片渲染。
- 所有已实现页面仍为 `implemented / no`，表示代码、自动化测试或构建已验证，但尚未完成逐页模拟器人工验收。

## IM migration contract

```text
iOS/local/backend DTO
  -> App Domain Message (不得 import flutter_chat_core)
  -> ChatMessageMapper
  -> flutter_chat_core
  -> flutter_chat_ui + custom builders
```

首期已证实的消息类型仅 text。必须测试：助手首条欢迎、首次进入赠 100 币且只赠一次、助手固定置顶、按最后消息排序、最后一条由自己发送时禁止继续发送、AI 成功/失败、peer snapshot 恢复。未证实的群聊/附件/已读/撤回等保持 pending，不实现。

## Latest full verification

- `dart format .`：120 files，0 changed。
- `flutter analyze`：0 issue。
- `flutter test -r compact`：20 tests passed，覆盖启动与五 Tab、城市、活动筛选、社交状态、用户/组队详情、英文小屏、聊天历史与首次赠币、钱包/VIP、资料编辑、相册、组队发布、我的世界、国际化及完整 iOS 用户夹具资源。
- `LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 flutter build ios --debug --no-codesign`：通过，包含 StoreKit、媒体选择、音频、视频与 WebView 客户端插件。

## Remaining external / product decisions

- 用户确认当前工程就是完整业务事实源，或补充遗漏 Target/后端协议。
- 对 `TODO(iOS_VERIFY)` 中登录、普通消息回复、审核、同城入口、客服与举报链路给出结论。
- 决定智谱 AI 服务端代理和旧 iOS 本地数据是否需要迁移到 Flutter。
- 对正式审核、客服与举报上报接口，以及 App Store 商品/服务端收据校验给出生产配置。
