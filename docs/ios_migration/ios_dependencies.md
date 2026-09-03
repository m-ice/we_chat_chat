# iOS 依赖审计

## CocoaPods / Framework

| 依赖 | 实际用途与调用位置 | Flutter 替代方案 | 必须 | 风险 |
|---|---|---|---|---|
| Alamofire | `MTZhipuAIService` 调智谱 API；`MTNetworkTool` 有通用封装 | `dio` 或 `http`，AI 应经服务端代理 | 是（有网络时） | 明文客户端 API Key 为阻断级安全风险 |
| ReachabilitySwift | `MTReachabilityTool` 独立监听 | `connectivity_plus`；实际联网仍需请求判定 | 可合并 | 与 Connectivity 重复 |
| Connectivity | `MTNetworkTool` 联网状态 | `connectivity_plus` | 是 | 网络类型不等于互联网可达 |
| SnapKit | 几乎全部 UIKit 页面布局 | Flutter 原生 layout | 是（行为迁移，不迁库） | 需逐页处理动态高度 |
| Masonry | Swift 业务无调用 | 无 | 否 | 删除，避免包体/维护成本 |
| KeychainSwift | `MTStorageTool` 封装 Keychain，但业务未调用封装入口 | `flutter_secure_storage`（仅将来有敏感凭据时） | 当前否 | 不应把普通数据迁进 Keychain |
| DeviceKit | `MTDeviceTool` 读取机型/系统/模拟器；未见关键业务使用 | `device_info_plus` | 可选 | 审核/隐私数据最小化 |
| Toast-Swift | 全局提示/loading | `Get.snackbar` 或统一 Toast 组件 | 是 | 保持提示时机和文案 |
| HandyJSON | 两个 bundle JSON 用户模型解码 | `json_serializable` / 手写 DTO | 是（替换） | 默认值语义要保留 |
| SwiftyJSON | `MTJSONTool` 字典/数组解析工具 | `dart:convert` | 可合并 | 避免双 JSON 栈 |
| Kingfisher | `MTImageDisplayView` 远程图封装；当前样本主要本地资源 | `cached_network_image`（确认真实远程图后） | 可选 | 不要为未用远端图提前加入 |
| IQKeyboardManagerSwift | App 启动启用键盘管理 | Flutter Focus/MediaQuery/viewInsets | 是（行为） | 聊天键盘交互需单独验证 |
| DefaultsKit | `MTStorageTool` 的 Codable/UserDefaults | `shared_preferences` + JSON；复杂数据建议版本化 local store | 是 | 需设计旧数据迁移 |
| SwiftyStoreKit | VIP/币商品查询、购买、恢复、补单 | `in_app_purchase` | 是 | 收据验证目前缺失；消耗币重复发放风险 |
| GradientProgressBar | `MTProgressStripView` | LinearProgressIndicator/自绘渐变 | 是（UI） | 低 |
| FURenderKit | 源码无 import/调用 | 无 | 否 | 美颜能力未启用，不迁移 |
| NTESQuickPass | 源码无调用；无登录页面 | 无 | 否 | 不得据此虚构一键登录 |
| TUIChat / TUIConversation / TUIContact / TUISearch | 源码无 TUI 调用；实际 IM 为本地自研文本 | `flutter_chat_core` + `flutter_chat_ui` 仅做 UI/状态底座 | 否（SDK 本身） | 最大误判源；不能反推群聊/联系人能力 |
| TUICallKit | 源码无调用；语音通话页为本地模拟 | 无，除非补充真实业务证据 | 否 | 不得申请麦克风/相机权限 |
| TUIPoll / TUIGroupNote / TUITranslation / ConversationGroup / ConversationMark / VoiceToText | 无调用 | 无 | 否 | 不迁移 |
| RiskPerception.xcframework | 仅 Bridging Header import，未发现初始化/调用 | 无 | 否 | 闭源 SDK、合规和架构风险 |

没有 Swift Package dependency。系统框架实际使用 UIKit、Foundation、PhotosUI、AVFoundation/AVKit、WebKit、StoreKit、UniformTypeIdentifiers。

## 构建配置

- iOS deployment target 14.0，Swift 5.0，iPhone (`TARGETED_DEVICE_FAMILY=1`)。
- CocoaPods 使用动态 frameworks，关闭 Bitcode；post_install 强制 Pods deployment target 14.0。
- App target 开启自动生成 Info.plist，同时合并手写 `MiTuTeamBuilding/Info.plist`。
- 未发现 entitlements；因此没有 Push、Associated Domains、Keychain Groups、Sign in with Apple 等能力声明。

## 迁移决策

先只引入被真实 Flutter 模块使用的依赖。聊天插件不能承担业务模型；IAP、照片选择、播放器、WebView 和持久化各自放在 Provider/Service 边界。所有“Pod 已声明但业务零调用”的依赖默认不迁移，若后续获得其他 Target/服务端协议再重新审计。

## Flutter 最终依赖

| Package | 生产用途 |
|---|---|
| `get` | 路由、Binding、Controller 响应式状态与国际化 |
| `shared_preferences` | 对齐 iOS UserDefaults 的轻量持久化 |
| `flutter_chat_core`, `flutter_chat_ui` | 文本聊天状态与自定义渲染；Domain 通过 Mapper 隔离 |
| `in_app_purchase` 3.2.2 | StoreKit 商品、购买与恢复；因当前 Xcode 15 SDK 固定兼容版本 |
| `audioplayers` | iOS 已有的本地等待音 |
| `image_picker`, `path_provider` | PHPicker 语义的相册导入和 Documents 文件保存 |
| `webview_flutter` | 隐私政策、用户协议及自动续费协议 |
| `video_player` | 真人视频流及本地视频预览 |
| `flutter_localizations` | zh_CN / en_US Flutter 本地化 |

逐包扫描均有生产代码引用；早期模板依赖 `cupertino_icons` 已移除，未引入腾讯 IM/TRTC、相机、定位、通讯录或推送依赖。
