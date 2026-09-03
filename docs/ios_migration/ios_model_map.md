# iOS 核心数据模型映射

## 说明

HandyJSON 模型字段有默认值，JSON 缺字段时不会表现为 Swift Optional；Codable 模型的可空性按解码代码记录。JSON Key 未自定义时与字段名相同。Flutter 名称是建议的 Domain/DTO 名称，尚未实现。

## User / Profile

| iOS Model | 字段（类型；可空） | JSON Key / 来源 | 使用页面 | Flutter 对应 |
|---|---|---|---|---|
| `MTUserModel` | `id Int`、`nickname String`、`age Int`、`gender String`、`hobbies [String]`、`avatar String`、`intro String`、`realPersonVerified Bool`、`verificationImages [String]`、`verificationVideo String`（均非空、缺失用默认值）；`moments MTUserMoment?`、`teamPost MTUserTeamPost?` | 同名 Key；`figfureUser.json` | 首页、广场、详情、聊天、资料 | `UserDto` -> `User` |
| `MTUserMoment` | `images [String]`、`content String`、`time String`，非空默认 | 同名 Key；嵌套 JSON | 广场、用户详情 | `MomentDto` -> `FeedPost` |
| `MTUserTeamPost` | `images [String]`、`activity/location/date/content String`，非空默认；计算属性 `mtIsExpired` | 同名 Key；嵌套 JSON | 首页、话题、组队详情 | `TeamPostDto` -> `TeamPost` |
| `MTCityUserModel` | `id Int`、`nickname/avatar/city/intent/occupation/intro/videoPath String`、`age Int`、`hobbies/galleryImages [String]`、`videoVerified/realPersonVerified/isOnline Bool`，非空默认；`moments MTUserMoment?` | 同名 Key；`cityUsers.json` | 附近、同城、真人视频、搜索 | `CityUserDto` -> `User` + `UserMedia` |
| `MTCityGalleryItem` | enum：`image(path String)` / `video(path String)` | 由 `MTCityUserModel` 计算，不直接 JSON | 同城/用户图集 | `GalleryItem` sealed type |
| `MTProfileEditModel` | `mtNickname String`、`mtBio String`、`mtAvatarAssetName String`、`mtInterests [String]`、`mtPersonalityTags [String]`，均非空且有默认值 | 同名 Key；UserDefaults `mt_profile_edit_model` | 我的、编辑资料 | `EditableProfileDto` -> `Profile` |

## Feed / 组队 / 话题

| iOS Model | 字段（类型；可空） | JSON Key / 来源 | 使用页面 | Flutter 对应 |
|---|---|---|---|---|
| `MTPublishedTeamPostModel` | `mtId String`、`mtActivity/location/date/content/contact String`、`mtImageRelativePaths [String]`、`mtCreatedAt Double`、`mtReviewStatus enum`；contact/images/status 解码时可缺，默认空/`pending` | 同名 Key；UserDefaults `mt_published_team_posts` | 发布、首页、话题 | `PublishedTeamPostDto` -> `TeamPost` |
| `MTTeamPublishReviewStatus` | `mtPending` / `mtApproved` | raw String | Feed 可见性 | `ReviewStatus` |
| `MTMyWorldPostModel` | `mtId/content String`、`mtImageRelativePaths [String]`、`mtTopics [String]`、`mtCreatedAt Double`、`mtReviewStatus enum`；兼容旧 Key `mtImageRelativePath`；topics/status 可缺 | UserDefaults `mt_my_world_posts` | 我的世界、广场 | `MyWorldPostDto` -> `FeedPost` |
| `MTMyWorldReviewStatus` | `mtPending` / `mtApproved` | raw String | 待审核胶囊 | `ReviewStatus` |
| `MTSquareFeedItem` | `mtPostId String`、`mtUser MTUserModel`、`mtContent String`、`mtImagePaths [String]`、`mtTime String`、`mtUsesSandboxImages Bool` | 运行时聚合用户 moment + 我的世界 | 广场/话题 | `FeedPost` view data |
| `MTTopicItemModel` | `mtTopicId/title/subtitle/category String`、`mtCoverPath String?` | 从组队帖运行时去重聚合 | 话题栏/话题详情 | `Topic` |
| `MTGuideArticleItem` | `mtTitle/summary/body String`、`mtReadMinutes Int` | 代码内按活动类型生成 | 组队详情/文章 | `GuideArticle` |

## IM

| iOS Model | 字段（类型；可空） | JSON Key / 来源 | 使用页面 | Flutter 对应 |
|---|---|---|---|---|
| `MTChatMessageModel` | `mtId String`、`mtText String`、`mtIsFromMe Bool`、`mtTimestamp Double`，全部必需 | 同名 Key；UserDefaults `mt_chat_messages_{userId}` | 聊天、AI 请求 | `LocalMessageDto` -> `AppMessage` -> chat mapper |
| `MTChatPeerSnapshot` | `mtUserId Int`、`mtNickname String`、`mtAvatar String`，全部必需 | 同名 Key；UserDefaults `mt_chat_peer_snapshots` | 会话 peer 恢复 | `ConversationPeerDto` |
| `MTMessageItemModel` | `mtUser`、`mtPreview String`、`mtTime String`、`mtUnreadCount Int`、`mtIsTeamAssistant Bool` | 运行时由 ChatStore 聚合 | 会话列表 | `ConversationSummary` |

当前工程不存在独立 `Conversation` 持久模型，只存 peer ID 数组与每个 peer 的消息数组；不存在 Group、Contact、Comment、业务 Notification 模型。`TODO(iOS_VERIFY):` 如果这些模型在后端或其他 Target 中，请补充源码/协议后再建 Flutter 模型。

## 相册、认证、会员

| iOS Model | 字段（类型；可空） | JSON Key / 来源 | 使用页面 | Flutter 对应 |
|---|---|---|---|---|
| `MTAlbumItemModel` | `mtId String`、`mtRelativePath String`、`mtKind enum(photo/video)`、`mtCreatedAt Double` | UserDefaults `mt_album_store_model` + Documents | 相册/预览 | `AlbumItemDto` -> `AlbumItem` |
| `MTAlbumStoreModel` | `mtPhotos [MTAlbumItemModel]`、`mtVideos [...]`，默认空 | 同上 | 相册服务 | `AlbumStoreDto` |
| `MTRealPersonVerifyRecord` | `mtStatus enum`、`mtRealName String`、`mtIdNumber String`、`mtPhone String`、身份证/手持照路径 String、提交时间 Double | UserDefaults（认证服务私有 Key）+ Documents | 真人认证 | `VerificationRecordDto` -> `VerificationRecord` |
| `MTRealPersonVerifyStatus` | `mtPending` / `mtApproved` | raw String | 认证页面模式 | `VerificationStatus` |
| `MTMembershipRecord` | `mtProductId String`、`mtExpireAt Double` | UserDefaults `mt_membership_record` | VIP、钱包 | `MembershipRecordDto` |
| `MTStoreProduct` | weekly/quarterly/yearly VIP，60/320/820 coin；计算 productId、价格、期限、币数 | 代码常量 + StoreKit SKProduct | 购买页 | `StoreProduct` / store adapter DTO |

## 领域规则必须保留

- `MTUserTeamPost.mtIsExpired`：日期格式 `yyyy-MM-dd`，早于本地“今天”才过期；无效日期不视为过期。
- 当前用户默认 ID 2；已发布组队帖用当前用户组装并置顶，先移除 JSON 中当前用户的重复帖。
- 拉黑与屏蔽集合取并集后从首页、广场、视频等数据源过滤。
- 组队发布需要活动、地点、日期、正文、联系方式全部非空；图片可空；状态默认 pending。
- 动态发布只强制正文非空；图片、话题可空；状态默认 pending。
- 消息字段不足以表达送达/失败/已读；Flutter 不应虚构状态。可在 Domain 预留兼容演进字段，但默认语义必须明确为“本地已写入”。
