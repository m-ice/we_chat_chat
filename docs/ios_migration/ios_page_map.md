# iOS 页面映射

状态以当前 Flutter 实现为准；`implemented / no` 表示实现及自动化/构建检查已完成，但尚未完成逐页模拟器人工验收。

## 根页面

| iOS 页面 / 文件 | 入口 / 上级 | 下级页面 | 数据来源与主要状态 | 用户操作 | Flutter 模块 | 状态 / 备注 |
|---|---|---|---|---|---|---|
| `MTHomeViewController` `Pages/Home/MTHomeViewController.swift` | Tab 0 / App root | 城市、筛选、发布、用户、组队详情、真人视频、举报、媒体预览 | UserData、CityData、发布服务、城市和过滤 Store；活动/附近/新人 | 切子 Tab、滚动、筛选、发布、加入、关注、举报/拉黑/屏蔽 | `modules/home` | implemented |
| `MTTopicViewController` `Pages/Topic/MTTopicViewController.swift` | Tab 1 / App root | 话题详情、用户详情、发布动态、举报、预览 | SquareFeed、UserData、MyWorld、关注/点赞/过滤 Store；推荐/关注、分类 | 关注、点赞、发布、看图、治理操作 | `modules/discover` | implemented / no |
| `MTCenterTabViewController` `Pages/Home/MTCenterTabViewController.swift` | Tab 2 / App root | 搜索、内嵌真人视频 | RealPersonData、城市/过滤 Store；当前视频 | 搜索、纵向切视频、点赞/收藏/更多 | `modules/discover/video` | implemented / no；Tab 无标题 |
| `MTMessageViewController` `Pages/Message/MTMessageViewController.swift` | Tab 3 / App root | 聊天 | ChatStore；会话数组，助手固定置顶 | 选择会话 | `modules/chat/conversations` | implemented / no；Tab 名“通知”，页名“消息” |
| `MTProfileViewController` `Pages/Profile/MTProfileViewController.swift` | Tab 4 / App root | 编辑、币、VIP、认证、相册、我的世界、客服、协议 | ProfileEdit、UserData、Wallet；资料/余额/VIP | 菜单导航 | `modules/profile` | implemented / no |

## 首页、用户与组队

| iOS 页面 / 文件 | 入口 / 上级 | 下级页面 | 数据来源与主要状态 | 用户操作 | Flutter 模块 | 状态 / 备注 |
|---|---|---|---|---|---|---|
| `MTHomeCityPickerViewController` | 首页城市按钮 | pop 首页 | CityOptions/CityService；搜索结果、选中城市 | 搜索、选城市 | `home/city_picker` | implemented；Widget 闭环已验证，真实模拟器重启持久化待复核 |
| `MTHomeActivityFilterViewController` | 首页筛选 | 用户详情、组队详情、举报 | ActivityFilterService；关键词/结果/空态 | 搜索、重置、确认、选择、治理 | `home/activity_filter` | implemented / no；筛选只作用本页，下级详情/治理及直接加入已接线 |
| `MTTeamPublishViewController` | 首页发布 | 发布确认、协议/隐私 | TeamPublishService；表单、图片、协议勾选 | 填活动/地点/日期/正文/联系方式、选图 | `home/team_publish` | implemented / no；非会员发布时弹 VIP，未认证二次确认 |
| `MTTeamPublishReviewViewController` | 发布页下一步 | 成功后回首页 | 上一页表单快照、TeamPublishService | 检查并提交 | `home/team_publish_review` | implemented / no；结果固定 pending，不提前模拟审核通过 |
| `MTTeamPostDetailViewController` | 首页/筛选/话题的组队帖 | 用户详情、文章 | User + TeamPost + ContentProvider；过期/申请状态 | 看发起人、申请加入、看教程 | `home/team_post_detail` | implemented / no；VIP 门槛与持久化已接线 |
| `MTUserDetailViewController` | 多处用户头像/卡片 | 聊天、语音通话、举报、媒体预览 | UserData/City 转换、Wallet、ChatStore、过滤 Store；关注/邀请/会员/币 | 关注、聊天、通话、邀请、预览、治理 | `profile/user_detail` | implemented / no；首页附近/新人入口已验证 |
| `MTRealPersonVideoViewController` | 首页推荐/中心内嵌 | 用户详情、举报 | RealPersonData + AVPlayer；当前 index、点赞、收藏 | 上下滑、播放、点赞、收藏、治理 | `discover/video_feed` | implemented / no |
| `MTCenterSearchViewController` | 中心 Tab 搜索按钮 | 用户详情 | RealPersonData；关键词、结果/空态 | 输入/搜索/选择用户 | `discover/user_search` | implemented / no |
| `MTGuideArticleViewController` | 组队详情文章 | 无 | 代码内 GuideArticle | 阅读 | `home/guide_article` | implemented / no |
| `FigureReportViewController` | 用户/Feed 更多菜单 | pop | 被举报用户；原因选择、补充文本 | 选原因、提交 | `shared/report` | implemented / no；保持 iOS 的仅成功提示、不持久化/不上报 |
| `MTVoiceCallViewController` | 用户详情 | pop | peer + 本地 MP3；通话状态/计时 | 接通/挂断/静音等 UI | `chat/voice_call` | implemented / no；保持 30 秒模拟通话而非 RTC |
| `MTCityViewController` | 当前未发现入口 | 用户详情、媒体预览 | CityData、选中城市、过滤 Store | 浏览、聊天、预览 | — | not_migrated_no_entry；当前 Target 全局调用链无入口 |

## 广场与动态

| iOS 页面 / 文件 | 入口 / 上级 | 下级页面 | 数据来源与主要状态 | 用户操作 | Flutter 模块 | 状态 / 备注 |
|---|---|---|---|---|---|---|
| `MTTopicDetailViewController` | 广场话题卡 | 组队详情、用户详情、举报 | UserData topic feed + 过滤 Store；Feed/空态 | 选帖子、关注/治理 | `discover/topic_detail` | implemented / no |
| `MTMyWorldPublishViewController` | 广场发布、我的世界空态/按钮 | 协议/隐私，成功 pop | MyWorldService；正文、图片、话题、协议 | 输入、选图/删图、选话题、发布 | `discover/post_publish` | implemented / no |
| `MTMyWorldViewController` | 我的菜单 | 发布、图片预览 | MyWorldService；列表/空态 | 发布、删除、预览 | `profile/my_world` | implemented / no |

## 消息

| iOS 页面 / 文件 | 入口 / 上级 | 下级页面 | 数据来源与主要状态 | 用户操作 | Flutter 模块 | 状态 / 备注 |
|---|---|---|---|---|---|---|
| `MTChatViewController` | 会话、用户详情、邀请产生会话 | 无 | ChatStore/UserDefaults、智谱 API；消息、键盘、是否等待回复 | 发送纯文本 | `chat/thread` | implemented / no；一发一回、本地历史与 AI Mock 已实现，模拟器交互待验收 |

## 我的与系统内容

| iOS 页面 / 文件 | 入口 / 上级 | 下级页面 | 数据来源与主要状态 | 用户操作 | Flutter 模块 | 状态 / 备注 |
|---|---|---|---|---|---|---|
| `MTEditProfileViewController` | 我的资料卡 | 兴趣、个性标签 | ProfileEditService + Documents；头像/昵称/简介/标签 | 选头像、编辑、保存 | `profile/edit` | implemented / no |
| `MTEditInterestViewController` | 编辑资料 | pop | 固定兴趣选项；多选 | 选标签并保存 | `profile/edit_interest` | implemented / no |
| `MTEditPersonalityTagViewController` | 编辑资料 | pop | 固定个性选项；多选 | 选标签并保存 | `profile/edit_personality` | implemented / no |
| `MTVIPSubscriptionViewController` | 我的/VIP 门槛 Alert | 自动续费协议 | StoreKit、Wallet、Profile；商品选择/价格/会员状态 | 选套餐、购买、恢复 | `profile/membership` | implemented / no；StoreKit 客户端已构建，商店配置和服务端收据校验待验证 |
| `MTCoinsViewController` | 我的/余额不足 Alert | 无 | StoreKit、Wallet；余额/商品价格 | 购买币 | `profile/wallet` | implemented / no；消耗品购买、交付去重和 iOS 持久化键已实现 |
| `MTRealPersonVerifyViewController` | 我的 | 系统照片选择器 | VerifyService + Documents；表单/pending 模式 | 填实名资料、选证件图、提交 | `profile/verification` | implemented / no；无服务端审核闭环 |
| `MTAlbumViewController` | 我的 | 相册预览、系统照片选择器 | AlbumService + Documents；照片/视频 Tab、选择态 | 导入、选择删除、打开 | `profile/album` | implemented / no |
| `MTAlbumPreviewViewController` | 相册 item | pop | AlbumItem + 本地文件 | 播放/查看、删除 | `profile/album_preview` | implemented / no |
| `MTCustomerServiceViewController` | 我的 | 无 | 页面临时表单 | 填标题/描述/联系方式、提交 | `profile/customer_service` | implemented / no；提交仅本地成功提示 |
| `MTPrivacyPolicyViewController` | 我的/发布协议链接 | WebView | HTTP 网页 | 阅读 | `settings/legal` | implemented / no |
| `MTUserAgreementViewController` | 我的/发布协议链接 | WebView | HTTP 网页 | 阅读 | `settings/legal` | implemented / no |
| `MTVIPAutoRenewAgreementViewController` | VIP 页 | 无 | 内嵌 HTML | 阅读 | `settings/legal` | implemented / no；HTML 作为 Flutter asset 加载 |
| `MTImagePreviewViewController` | 多页面图片点击 | dismiss | 图片数组、初始 index | 横向翻页、关闭 | `shared/media_preview` | implemented / no；支持 asset 与 Documents 本地文件 |

## 未发现的要求域

未发现 Login、注册、忘记密码、Group、Contacts、Comment、系统通知中心、设置总页、黑名单管理页、账号注销页。不得从通用社交 App 模板补建；相关上线缺口见 `app_store_gap.md`。
