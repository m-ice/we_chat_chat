# 微撩 UI 重构状态

更新：2026-09-04（Asia/Shanghai）

> 2026-09-04 用户明确暂停 View 审核；下表历史 `review_running` 状态统一视为 `waived_by_user`。本轮只做数据、路由、交互闭环和自动化门禁，不恢复或重排用户调整后的页面布局。

| Page | Figma Node | Owner Session | UI Status | Logic Status | Route Status | View Review | Blocked |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 发布 | `2200:656` | UI-1 Publish Activity | ui_done | local_ready | named_ready | review_running | 真实审核服务待后端 |
| 发布-选择活动类型 | `2241:9566` | UI-1 Publish Activity | ui_done | local_ready | named_ready | review_running | - |
| 活动详情 | `2166:18360` | UI-1 Publish Activity | ui_done | local_ready | named_ready | review_running | 详情“更多”最终动作待产品定义 |
| 发布动态 | `2259:10188` | UI-1 Publish Activity | ui_done | local_ready | named_ready | review_running | 真实审核服务待后端 |
| 广场-视频 | `2166:18784` | UI-2 Video User | ui_done | local_ready | named_ready | review_running | - |
| 个人主页 | `2213:1272` | UI-2 Video User | ui_done | local_ready | named_ready | review_running | 远端资料刷新待后端 |
| 更多 | `2259:10276` | UI-2 Video User | ui_done | local_ready | modal_ready | review_running | - |
| 举报 | `2259:11663` | UI-2 Video User | ui_done | local_queue_ready | named_ready | review_running | 远端举报上传未接入，当前为本机队列 |
| 聊天 | `2085:16397` | UI-3 Chat System Support | ui_done | local_ready | named_ready | review_running | 真实 RTC 待后端/产品 |
| 系统消息 | `2259:9753` | UI-3 Chat System Support | ui_done | local_ready | named_ready | review_running | - |
| 在线客服 | `2259:10100` | UI-3 Chat System Support | ui_done | local_queue_ready | named_ready | review_running | 远端客服工单服务未接入，当前仅本机待发送队列 |
| 编辑资料 | `2179:19376` | UI-4 Profile Edit | ui_done | local_ready | named_ready | review_running | - |
| 我的相册 | `2259:11719` | UI-4 Profile Edit | ui_done | local_ready | named_ready | review_running | - |
| 兴趣 | `2290:1427` | UI-4 Profile Edit | ui_done | local_ready | named_ready | review_running | - |
| 个性化标签 | `2290:1546` | UI-4 Profile Edit | ui_done | local_ready | named_ready | review_running | - |
| 昵称 | `2290:1652` | UI-4 Profile Edit | ui_done | local_ready | named_ready | review_running | - |
| 搜索 | `2290:1708` | UI-4 Profile Edit | ui_done | local_ready | named_ready | review_running | - |
| 简介 | `2290:1763` | UI-4 Profile Edit | ui_done | local_ready | named_ready | review_running | - |
| 充值页 | `2179:19110` | UI-5 Profile Business | ui_done | storekit_client_ready | named_ready | review_running | 820 金币档设计价 ¥8、领域价 ¥68；服务端票据校验待补 |
| 亲密关系 | `2259:9824` | UI-5 Profile Business | ui_done | local_ready | named_ready | review_running | - |
| 谁看过我 | `2259:9890` | UI-5 Profile Business | ui_done | local_ready | named_ready | review_running | - |
| 通话记录 | `2259:9948` | UI-5 Profile Business | ui_done | local_demo_ready | named_ready | review_running | 真实 RTC 及服务端记录待补 |
| 我的动态 | `2259:10006` | UI-5 Profile Business | ui_done | local_ready | named_ready | review_running | - |

## 文件所有权

| Session | 可修改范围 |
| --- | --- |
| UI-1 | `home/team_publish/**`、`home/team_detail/**`、`profile/views/my_world_publish_page.dart`、`assets/*/publish_activity/**` |
| UI-2 | `discover/video_feed*`、`user_detail/**`、`shared/report/**`、`shared/actions/**`、`assets/*/video_user/**` |
| UI-3 | `chat/views/chat_page.dart`、`chat/views/widgets/**`、`chat/views/system_messages_page.dart`、`profile/views/customer_service_page.dart`、`profile/controllers/customer_service_controller.dart`、`assets/*/chat_system/**` |
| UI-4 | 编辑资料/相册/标签/文本编辑 View、`discover/views/center_search_page.dart`、`assets/*/profile_edit/**` |
| UI-5 | `profile/views/coins_page.dart`、`profile/views/my_world_page.dart`、`chat/views/message_feature_pages.dart`、`assets/*/profile_business/**` |
| Master | 路由、Binding、Core、Data、Domain、L10n、Theme、pubspec、原生工程、最终集成 |

## 受保护基线

- `lib/modules/home/views/home_page.dart` 当前由用户继续修改，所有 UI Session 禁止触碰。
- `lib/main.dart`、现有 `AppImage`、`AppImageString`、`AppRefreshView`、`AppToast`、`CommonDraggableFloatWidget` 由 Master 串行集成。
- UI Session 完成前不启动完整 View Review，不以 checklist 代替页面完成度。

## Master 集成队列

| 来源 | 请求 | 状态 |
| --- | --- | --- |
| UI-3 | 聊天正式资源纳入 `AppImageString`；核对 `CommonDraggableFloatWidget` 尺寸透传 | done |
| UI-4 | 注册 `assets/icons/profile_edit/`，新增 `profileEditSearch`、`profileEditAlbumAdd` 并替换页面路径字面量 | done |
| UI-4 | 新增资料编辑、相册与搜索中英文 L10n key | done |
| UI-4 | 从合规 JSON/Repository 注入相册与个人资料 seed，禁止回填到 View | done |
| UI-5 | 我的动态补点赞、评论及持久化；自己的动态不发起打招呼 | done |
| UI-5 | 访客/亲密关系/通话/系统消息补真实未读状态与 L10n | done |
| UI-5 | 820 金币档设计价格 ¥8 与领域配置 ¥68 冲突，集成阶段按既有业务配置保留并列为产品确认项 | blocked_product |
| UI-1 | 将 `TeamFlowAssets` 正式资源收编到 `AppImageString` 并串行替换 | done |
| UI-1 | 补发布、类型计数、照片、描述、评论、打招呼、聊一聊、附近 banner、活动分类等 L10n | done |
| UI-1 | Figma 默认发布/详情参考数据由已审核 JSON seed 驱动 | done |
| UI-2 | 注册 `assets/icons/video_user/`、`assets/images/video_user/` 并收编到 `AppImageString` | done |
| UI-3 | 注册 `assets/icons/chat_system/`、`assets/images/chat_system/`，将资源收编到 `AppImageString` | done |
| UI-3 | `conversation_page.dart` 切换到新 `system_messages_page.dart`，避免与旧同名页面冲突 | done |
| UI-3 | 补系统消息、客服提交状态、聊天提示/更多/发送等 L10n | done |
| UI-3 | SupportRepository 远端上传与工单投递状态 | blocked_backend |
| UI-2 | 个人主页补 city/career/height/weight 等 JSON/Repository seed 详情 | done |
| UI-2 | 视频点赞/收藏持久化 | done |
| UI-2 | ReportRepository 远端上传 | blocked_backend |
| UI-2 | 补基本资料、活动、动态、时间、地址、感兴趣人数等 L10n | done |
| Master | 11 个用户的头像、相册、动态、活动和详情资料按稳定 ID 建模 | done |
| Master | 首页、附近、广场及个人主页按用户/活动 ID 进入各自详情 | done |
| Master | View 审核按用户最新要求停止 | waived_by_user |
