# iOS 导航与事件图

## 启动和 Tab

```text
AppDelegate
└─ MTTabBarController
   ├─ [0 首页] MTNavigationController -> MTHomeViewController
   ├─ [1 广场] MTNavigationController -> MTTopicViewController
   ├─ [2 中心] MTNavigationController -> MTCenterTabViewController
   ├─ [3 通知] MTNavigationController -> MTMessageViewController
   └─ [4 我的] MTNavigationController -> MTProfileViewController
```

所有非根页面 push 时隐藏 TabBar。自定义导航栏返回：导航栈大于 1 时 pop；被 present 的 `MTBaseViewController` dismiss。支持系统边缘返回手势。

## 首页

```text
MTHomeViewController
├─ 城市 -> MTHomeCityPickerViewController -> pop + Notification 刷新
├─ 筛选 -> MTHomeActivityFilterViewController
│  ├─ 用户/组队帖 -> MTUserDetailViewController / MTTeamPostDetailViewController
│  └─ 更多 -> 举报 / 拉黑 / 屏蔽 ActionSheet
├─ 发布 -> MTTeamPublishViewController
│  ├─ 协议 -> MTUserAgreementViewController / MTPrivacyPolicyViewController
│  ├─ 下一步 -> MTTeamPublishReviewViewController
│  └─ 发布成功 -> pop 到首页 + Notification 刷新
├─ Feed 用户 -> MTUserDetailViewController
├─ Feed 组队帖 -> MTTeamPostDetailViewController
│  ├─ 发起人 -> MTUserDetailViewController
│  └─ 教程/指南 -> MTGuideArticleViewController
├─ 图集图片 -> MTImagePreviewViewController（present）
├─ 图集视频 -> AVPlayerViewController（present）
├─ 真人视频 -> MTRealPersonVideoViewController
└─ 更多 -> FigureReportViewController / 本地拉黑 / 本地屏蔽
```

`MTUserDetailViewController` 可进入文本聊天 `MTChatViewController`、模拟语音通话 `MTVoiceCallViewController`、图片/视频预览、举报页；更多菜单也可拉黑/屏蔽。组队邀请会写入聊天会话。

## 广场

```text
MTTopicViewController
├─ 推荐 / 关注 Tab（同页切换）
├─ 发布 -> MTMyWorldPublishViewController
│  └─ 协议 -> 用户协议 / 隐私政策
├─ 话题卡 -> MTTopicDetailViewController
│  ├─ 组队帖 -> MTTeamPostDetailViewController
│  └─ 用户 -> MTUserDetailViewController
├─ 动态头像 -> MTUserDetailViewController
├─ 动态图片 -> MTImagePreviewViewController（present）
└─ 更多 -> 举报 / 拉黑 / 屏蔽 ActionSheet
```

## 中心视频流

```text
MTCenterTabViewController
├─ 搜索 -> MTCenterSearchViewController -> MTUserDetailViewController
└─ 内嵌 MTRealPersonVideoViewController
   ├─ 头像 -> MTUserDetailViewController
   └─ 更多 -> 举报 / 拉黑 / 屏蔽
```

## 消息

```text
MTMessageViewController
└─ 会话 -> MTChatViewController
   ├─ 文本发送 -> MTChatStore 本地持久化
   └─ 助手会话 -> MTZhipuAIService -> 回复落本地
```

## 我的

```text
MTProfileViewController
├─ 编辑 -> MTEditProfileViewController
│  ├─ 兴趣 -> MTEditInterestViewController
│  └─ 个性标签 -> MTEditPersonalityTagViewController
├─ 微撩币 -> MTCoinsViewController -> StoreKit 购买
├─ VIP -> MTVIPSubscriptionViewController
│  └─ 自动续费协议 -> MTVIPAutoRenewAgreementViewController
├─ 真人认证 -> MTRealPersonVerifyViewController
├─ 相册 -> MTAlbumViewController -> MTAlbumPreviewViewController
├─ 我的世界 -> MTMyWorldViewController
│  ├─ 发布 -> MTMyWorldPublishViewController
│  └─ 图片 -> MTImagePreviewViewController
├─ 客服 -> MTCustomerServiceViewController
├─ 隐私 -> MTPrivacyPolicyViewController
└─ 用户协议 -> MTUserAgreementViewController
```

## 非 push 导航与事件

- Present：系统照片选择器、图片预览、AVPlayer、ActionSheet/Alert。
- Tab 切换：五个 Tab 由系统 UITabBar 切换；首页内部 pager 切换活动/附近/新人。源码另有一次 `selectedIndex = 0` 用于返回首页根状态。
- Notification：`mtHomeSelectedCityDidChange`、`mtTeamPublishDidChange`、`mtMyWorldDidChange`、`mtProfileEditDidChange`、`mtAlbumDidChange`、`mtMembershipWalletDidChange`；另有键盘 frame 和播放器循环通知。
- Closure/Delegate：Cell 点击（用户、封面、关注、加入、点赞、更多、删除）、城市选择回调、图片选择 delegate、Table/Collection/Scroll delegate、TextField/TextView delegate。
- URL Scheme / Universal Link / Deep Link：未发现注册或处理代码。
- Push Notification：未发现注册、device token、接收或路由代码。
