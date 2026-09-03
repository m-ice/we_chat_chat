# App Store 与产品闭环缺口

本文区分 Flutter 客户端迁移结果和无法由现有客户端源码补齐的外部缺口。缺口不会通过假接口、假审核或恒真收据校验掩盖。

## Flutter migration gap

- 当前 Target 中所有有入口且源码可确认的页面、导航、本地交互和持久化均已实现。
- `MTCityViewController` 无任何可达入口，记录为 `not_migrated_no_entry`，不是迁移缺陷。
- 原生 Simulator 逐页视觉、键盘、媒体选择、视频与音频体验仍为 `manual_runtime_verification_pending`。
- 生产 App Store 商品环境不可在本地构建中验证；客户端 StoreKit 链路已经实现并通过 iOS 编译。

## Backend gap

1. AI：原 iOS 把智谱 Key 写在客户端。Flutter 未复制密钥，只提供 `AiRepository` 与本地 Mock；生产环境需要服务端代理、密钥轮换、鉴权、限流和日志脱敏。
2. IAP：Flutter 已实现商品查询、购买、恢复、交易完成和本机交付去重，但缺少服务端收据校验、订阅状态同步及跨设备权益事实源。不得用客户端恒真校验器替代。
3. UGC：组队帖、动态和真人认证提交后按 iOS 进入 pending；源码没有审核状态更新来源，需要正式审核接口与状态同步。
4. 举报/治理：举报页按 iOS 只显示成功提示；拉黑/屏蔽只在本机持久化。缺少举报上传、处理结果、跨设备黑名单和申诉接口。
5. 客服：iOS 客服表单不发送，Flutter 保持相同行为；正式版本需要真实客服提交通道。
6. 普通用户回复：本地聊天只存在当前端消息，没有对端或推送来源；生产通信需要补充后端协议。

## Product gap

- 当前源码没有登录、注册、账号设置或账号注销。如果正式产品创建账号，需要产品提供账号体系及 App 内删除账号入口。
- 真人认证敏感资料缺少保留期限、删除入口、加密/上传策略和审核说明。
- 缺少黑名单查看/解除、屏蔽管理、违规内容处理反馈和用户申诉入口。
- “语音通话”按源码只是本地等待音与 30 秒计时，需要产品明确是否继续以通话能力呈现。
- AI 助手生产版会向第三方发送对话时，需要产品/法务提供首次使用同意和隐私披露。

## App Store operational gap

- 配置并审核 `weekly6vip`、`threemonthly60vip`、`yearly200vip`、`weiliao60Coin`、`weiliao320Coin`、`weiliao820Coin`，用 Sandbox 验证价格、购买、恢复及订阅条款。
- 把隐私政策和用户协议从裸 IP HTTP 迁移到稳定 HTTPS 域名；当前 ATS 例外只为忠实兼容原源码。
- 提供与真实数据处理一致的隐私政策、App Privacy 标签、审核说明及测试账号/无需登录说明。
- 核对发布证书、签名、Provisioning Profile、商品 Agreements/Tax/Banking 和服务端通知。
- 在真实设备/模拟器人工验收媒体选择、视频、等待音、WebView、键盘和 StoreKit Sheet。

## 已由 Flutter 客户端解决

- 有入口页面、五 Tab 和下级导航均已接通，无 Coming Soon 或空业务按钮。
- 举报入口、本地拉黑/屏蔽、自己动态删除、协议、隐私、客服入口与发布 pending 状态已按 iOS 迁移。
- StoreKit 客户端交易监听、`completePurchase`、本机 purchase ID 去重、钱包 iOS key 兼容已实现。
- 未迁移 iOS 中仅声明但零业务调用的腾讯 IM/TRTC、美颜、一键登录和风控 SDK。
- 原 AppIcon、显示名、iOS 14 最低版本、iPhone 设备族、竖屏与精确 ATS 例外已配置。
- 未引入相机、麦克风、定位、通讯录、推送或 ATT 权限。

## TODO(iOS_VERIFY)

- 获取生产后端协议、审核系统、账号体系、客服通道、正式 HTTPS 法律文本和 App Store Connect 商品配置后重新验证外部闭环。
- 如果存在未提供的 Target、Storyboard 或远端配置，应重新审计其导航和业务能力；当前仓库证据中不存在。
