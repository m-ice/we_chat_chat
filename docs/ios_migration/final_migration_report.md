# iOS → Flutter 最终迁移报告

## 1. iOS 总页面数

当前 Target 共 34 个 `*ViewController.swift` 文件。其中 3 个是基础容器（`MTBaseViewController`、`MTTabRootViewController`、`MTWebContentViewController`），其余 31 个为业务页面 Controller。

## 2. 已迁移页面

30 个有真实入口的 iOS 业务 Controller 均已有可达 Flutter 实现。Flutter 共 30 个 `*page.dart`；法律页、标签页等按共享页面与参数状态合并，并非机械一文件对一文件。

## 3. 未迁移页面

仅 `MTCityViewController` 未迁移。

## 4. 未迁移原因

对 push/present、Storyboard、Tab、通知、类名字符串及资源引用复核后，`MTCityViewController` 在当前 Target 无可达入口，最终状态为 `not_migrated_no_entry`。首页城市选择器是另一条已迁移链路。

## 5. 五 Tab 完成情况

首页、广场、真人视频、通知、我的五个 Tab 的顺序、图标、状态保持及下级导航均已实现；不存在占位根页。

## 6. 首页

活动、附近、新人、城市选择、筛选、关注、直接加入、发布、详情、用户入口、举报与媒体预览已接通。城市与筛选规则按 iOS 数据源实现并持久化。

## 7. Feed

广场推荐/关注、话题、动态聚合、点赞、关注、治理、媒体入口及纵向真人视频流已实现。iOS 本身未持久化的视频点赞/收藏保持内存语义。

## 8. Team

组队详情、过期状态、VIP 加入门槛、申请状态、发起人、教程/攻略、发布表单、三图、协议和待审核持久化已实现。源码没有审核状态转换来源，因此不伪造自动上架。

## 9. Chat

本地纯文本单聊、会话排序、助手置顶、一发一回、历史恢复、peer snapshot、邀请消息、扣币和语音呼叫模拟均已实现。首次进入消息页会且只会赠送 100 微撩币并写入助手通知。没有添加群聊、附件、已读、撤回、推送或腾讯 IM。

## 10. Profile

资料卡、资料编辑、兴趣与个性标签、认证、相册、我的世界、钱包、VIP、客服及法律入口已完成。

## 11. Settings

iOS 当前没有独立 Settings Controller、登录、退出、清缓存或账号注销链路，因此未虚构这些能力；现有个人中心真实菜单均已迁移。

## 12. IAP

商品查询、购买、恢复、交易完成、VIP/币交付和客户端交付去重已通过 `in_app_purchase` 接线。真实商品与 Sandbox 流程仍需 App Store Connect 环境验证，生产收据校验依赖服务端。

## 13. AI

助手输入、等待、结果与错误状态沿用 `AiRepository → MockAiProvider`。未复制 iOS 客户端智谱密钥；生产接入必须走服务端代理。

## 14. UGC

组队帖、我的世界、举报、本地拉黑/屏蔽和本人内容删除已实现。发布与认证保持 iOS 的 pending 语义；正式审核、举报处理、申诉和跨设备同步属于后端/产品缺口。

## 15. Assets

确认使用的业务图片、视频、等待音、法律 HTML、完整用户夹具及 AppIcon 已迁移。所有声明资源路径可加载；AppIcon 全尺寸生成且无 alpha。无入口 City Tab 图标未复制。

## 16. Permissions

iOS 最低版本 14.0，应用仅面向 iPhone 和竖屏。相册使用 iOS 14+ PHPicker 路径，无需 Photo Library Usage Description；未申请相机、麦克风、定位、联系人或推送权限。ATS 仅保留原项目 `43.143.47.155` 的精确 HTTP 例外。

## 17. Localization

所有 Flutter 系统 UI 文案已覆盖 zh_CN / en_US，语言 key 集合对称。活动、话题、兴趣、标签等持久化枚举保留中文 canonical value，仅显示时翻译；英文小屏关键页面测试无 overflow。

## 18. Persistence

城市、关注/屏蔽/加入、聊天、peer snapshot、首次赠币、钱包/VIP、IAP 交付、资料、认证、相册、组队发布、我的世界及互动状态使用 Repository 统一管理，并保持 iOS 已确认的 UserDefaults key/JSON 语义。

## 19. Dependencies

最终生产依赖均有代码引用：GetX、SharedPreferences、Chat UI/Core、IAP、音频、图片选择、Documents 路径、WebView、视频和 Flutter 本地化。未用模板依赖已删除，未迁移零调用 Pods。

## 20. Tests

`flutter test -r compact`：20 tests passed。覆盖启动/五 Tab、主要导航、城市、筛选、关注状态、详情与发布、聊天历史与首次赠币幂等、钱包/VIP、资料、相册、动态、国际化、小屏英文布局，以及 10 名首页用户、12 名城市用户、8 名真人视频用户及其动态资源加载。

## 21. Analyze

`flutter analyze`：No issues found。

## 22. iOS Build

`LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 flutter build ios --debug --no-codesign`：成功，产物为 `build/ios/iphoneos/Runner.app`。产物核验：显示名“微撩”、MinimumOSVersion 14.0、UIDeviceFamily 仅 iPhone、竖屏及精确 ATS 例外生效。

## 23. Manual Verification Pending

当前自动化环境不能操作原生 Simulator UI。逐页视觉、系统返回、键盘升降、相册选择、Documents 媒体、视频播放/暂停、音频听感、WebView 网络内容及真实 StoreKit 流程标记为 `manual_runtime_verification_pending`，未声称人工通过。

## 24. Backend Gaps

智谱 AI 服务端代理、IAP 收据验证、正式 UGC/认证审核、举报/申诉、客服投递、普通用户远端回复和跨设备同步均缺少当前源码可用的服务端事实源。

## 25. App Store Gaps

上线前仍需配置并验证 App Store Connect 商品与 Sandbox 购买/恢复，提供生产收据校验和 UGC 审核/举报/客服闭环，确认法律 URL 可用，并完成真机/模拟器人工回归。客户端未用“永远成功”逻辑掩盖这些缺口。

## 26. TODO(iOS_VERIFY)

待外部事实确认：是否还有未提供的 Target/后端协议；普通用户回复来源；pending 内容审核来源；正式客服和举报接口；旧 iOS 本地数据是否需要迁移；腾讯 TUI/TRTC、QuickPass、美颜、RiskPerception 是否计划启用。以上均不阻塞当前源码可确认的 Flutter 客户端迁移。
