# iOS 工程迁移总览

## 分析范围与结论

- 源工程：`迷途资料/MiTuTeamBuilding`，约 97 个 Swift 文件、15,691 行应用 Swift 代码；未发现业务 Objective-C 实现、XIB、SceneDelegate、entitlements 或 Swift Package 依赖。
- 工程形态：UIKit + 纯代码布局（SnapKit），最低 iOS 14，iPhone only，Bundle ID `com.MiTuTeamBuilding.Mitu`，版本 `1.5.0 (1)`。
- `Main.storyboard` 是未被启动流程采用的模板空页面；`AppDelegate` 手工创建 `UIWindow`。`LaunchScreen.storyboard` 是空白启动页。
- 当前代码不是“登录后社交系统”：未发现登录、注册、Token、Session、手机号一键登录调用或服务端用户接口。当前用户由本地 JSON 和 UserDefaults 中的用户 ID决定，默认 ID 为 2。
- 业务数据主要来自两个 bundle JSON、本地静态图片/视频以及 UserDefaults/Documents。唯一真实业务网络调用是智谱 AI 助手；协议/隐私页加载 HTTP 网页。
- CocoaPods 声明了完整腾讯 TUI IM、音视频等依赖，但应用源码没有调用这些 SDK。迁移必须以实际源码行为为准，不能按 Pod 名称扩张功能。

## 架构

应用是轻量 MVC/Service 结构：

```text
AppDelegate
  -> MTThirdPartyBootstrap / 网络监测 / IAP 补单
  -> MTTabBarController
     -> 每个 Tab 独立 MTNavigationController
        -> UIViewController / View / Cell
           -> Service / Store
              -> bundle JSON / UserDefaults / Keychain / Documents / HTTP
```

`MTBaseViewController` 提供自定义导航栏、内容容器和返回行为；`MTTabRootViewController` 提供可滚动 Tab 根容器。没有 ViewModel、Repository、数据库或远端业务 API 层。跨页刷新通过 `NotificationCenter`，局部交互通过闭包回调。

## 启动、身份与主导航

1. `AppDelegate.didFinishLaunching` 配置 IQKeyboardManager。
2. 启动 Connectivity 与 Reachability 监听。
3. `SwiftyStoreKit.completeTransactions` 补交未完成订单。
4. 创建 UIWindow，直接把 `MTTabBarController` 设为 root。
5. 五个 Tab：`首页`、`广场`、中间真人视频流（无标题）、`通知`（页面标题实际为“消息”）、`我的`。

没有启动鉴权、引导页或登录分支。`MTUserDataService.mtCurrentUser` 从 `mt_current_user_id` 读取，默认 2；源码没有提供切换用户 UI。

## 页面模块

- 首页：城市选择、活动/附近/新人子流、活动搜索筛选、发布组队、组队详情、用户详情、真人视频、举报、语音通话、教程文章。
- 广场：推荐/关注动态、话题横栏、话题详情、关注/点赞、图片预览、发布动态、举报/拉黑/屏蔽。
- 中间 Tab：复用首页真人认证视频数据的全屏纵向视频流，含搜索入口。
- 消息：本地会话列表、文本单聊、官方 AI 助手。
- 我的：编辑资料、微撩币、VIP 内购、真人认证、相册、我的世界、客服、隐私政策、用户协议、自动续费协议。
- `MTCityViewController` 实现了“同城”页，但当前五 Tab 和已检索跳转中没有入口，属于孤立/隐藏候选页面，迁移前需产品确认。

## 数据层

- Bundle JSON：`figfureUser.json`（用户、动态、组队帖）、`cityUsers.json`（同城用户、图集、视频元数据）。HandyJSON 解码。
- UserDefaults/DefaultsKit：当前用户 ID、资料、关注/申请加入/拉黑/屏蔽/邀请、点赞、会话和消息、相册索引、动态、组队发布、认证记录、VIP/币余额等。
- KeychainSwift：封装了 String/Data 存取，但业务源码未发现调用。
- Documents：头像、相册照片/视频、动态图片、组队图片、认证图片，均保存相对路径。
- 无 Core Data、SQLite、Realm、文件数据库、远端业务 Repository 或缓存淘汰策略。

## IM 模块真实能力

当前 IM 是自研本地文本模型，不是腾讯 TUI IM：

```text
MTChatMessageModel { id, text, isFromMe, timestamp }
  -> MTChatStore（按 peer userId 写 UserDefaults）
  -> MTMessageViewController / MTChatViewController
```

- 仅单聊；无群聊、附件、语音、图片、视频、文件、引用、回复、@、撤回、删除、重试、送达/已读状态、分页历史或服务端同步。
- 未读数模型字段存在，但列表始终传 0 且 Badge 永远隐藏。
- 每个对端只允许“你发一条、对方回一条”；最后一条是自己发送时输入框禁用。
- 普通用户没有模拟/远端回复入口，因此发送后会一直等待；邀请消息也遵守同一规则。
- 官方“微撩助手”（userId -1）首次进入消息页创建欢迎消息并一次性赠送 100 币；用户发送后把完整历史传智谱 Chat Completions API，收到文本回复后落本地。
- 会话按最后消息时间排序，助手固定置顶。peer snapshot 用于原始数据集之外的用户解析。

Flutter 必须保留隔离层：

```text
Backend/Local DTO -> App Domain Message -> ChatMessageMapper
  -> flutter_chat_core -> flutter_chat_ui
```

Domain 层不能引用 `flutter_chat_core` 类型。第一版只映射 text；其他消息能力不得凭 Pod 声明补建。

## 用户、组队与 UGC

- 用户：本地用户档案、兴趣、头像、简介、真人认证展示数据。
- 组队：活动、地点、日期、正文、联系方式、图片；发布后默认 `pending`，仅 `approved` 可进入首页，但源码没有审核入口，因而新发布内容不会自动展示。
- 动态：文本、图片、话题、时间、审核状态；广场当前会读取所有本地“我的世界”帖子，没有按审核状态过滤，这与组队逻辑不一致，需按源码保持并记录风险。
- 内容治理：用户 Feed 有举报、拉黑、屏蔽；动态/我的世界支持删除自己的帖子；举报仅校验并显示提交成功，没有持久化或上传；拉黑/屏蔽只在本地过滤。
- 没有评论模型/页面、群组、联系人、通知推送、账号注销、服务端内容审核、举报处理后台或联系方式后端。

## 网络与第三方

- 智谱 AI：Alamofire POST `https://open.bigmodel.cn/api/paas/v4/chat/completions`。
- 协议网页：`http://43.143.47.155/private.html`、`http://43.143.47.155/usage.html`，Info.plist 仅为该 IP 放开 HTTP。
- IAP：SwiftyStoreKit，周/季/年 VIP 与 60/320/820 币；权益和余额本地持久化。
- 图片：本地资源与 Kingfisher 封装；当前业务数据主要为本地图。
- 其他依赖详见 `ios_dependencies.md`；腾讯 IM、TUICall、QuickPass、美颜、RiskPerception 等未发现业务调用。

## 权限与 iOS 特有实现

- 代码仅用 `PHPickerViewController` 选择照片/视频。PHPicker 在该使用方式下无需传统 Photo Library usage description；Info.plist 当前没有权限描述。
- “语音通话”页只是本地 UI、计时器和循环 MP3，不访问麦克风/相机，也未调用 TUICall。
- 真人认证从相册选择身份证图片，不调用摄像头或生物识别。
- iOS 特有：StoreKit 内购/恢复、PHPicker、WKWebView、AVPlayer/AVAudioPlayer、UIKit 自定义导航手势、ATS HTTP 例外、Documents/UserDefaults。

## Flutter 迁移难点与风险

1. 当前没有登录和后端，不能凭目标架构创建 Auth/Contacts/Group；应保留 TODO 并等待真实来源。
2. 智谱 API Key 以明文提交在客户端，必须在上线前移到服务端；不能原样搬入 Flutter。
3. 协议使用明文 HTTP/IP，存在 ATS、隐私与可用性风险，应改 HTTPS 域名，但这属于产品/服务端决策。
4. Podfile 与实际代码差距极大；照搬 Pods 会扩大包体、权限与审核风险。
5. 本地数据跨 UserDefaults/Documents 多处存储，迁移升级时需要版本化的数据导入方案，否则老用户数据丢失。
6. IM 的“一发一回”规则、助手首赠币、会话置顶必须写入 Domain 规则和测试，不应交给聊天 UI 插件决定。
7. 发布内容审核状态没有完成闭环；Flutter 只能复刻现状并标记 `TODO(iOS_VERIFY)`。
8. 全项目中文硬编码且无本地化资源；Flutter 初始架构需同时抽取 zh_CN/en_US，但英文译文属于新增内容，需要确认。
9. 大量动态高度 UIKit 页面和视频生命周期需在 Flutter 真机验证键盘、安全区、滚动复用和播放器释放。

## 待核实

- `TODO(iOS_VERIFY):` App 是否另有未提供的登录/服务端/推送 Target；当前工程中均不存在。
- `TODO(iOS_VERIFY):` `MTCityViewController`、`tab_city_n/s` 是否为废弃入口。
- `TODO(iOS_VERIFY):` 普通用户消息的对端回复来源；当前源码无实现。
- `TODO(iOS_VERIFY):` pending 组队帖/动态的审核与变更为 approved 的来源。
- `TODO(iOS_VERIFY):` 腾讯 TUI、QuickPass、美颜、RiskPerception 是否计划启用；当前只被依赖或桥接，业务零调用。
