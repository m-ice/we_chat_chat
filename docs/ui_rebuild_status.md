# 微撩 UI 重构状态

更新：2026-09-03 19:39（Asia/Shanghai）

| Page | Figma Node | Owner Session | UI Status | Logic Status | Route Status | View Review | Blocked |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 发布 | `2200:656` | UI-1 Publish Activity | ui_building | logic_pending | pending | pending | - |
| 发布-选择活动类型 | `2241:9566` | UI-1 Publish Activity | ui_building | logic_pending | pending | pending | - |
| 活动详情 | `2166:18360` | UI-1 Publish Activity | ui_building | logic_pending | pending | pending | - |
| 发布动态 | `2259:10188` | UI-1 Publish Activity | ui_building | logic_pending | pending | pending | - |
| 广场-视频 | `2166:18784` | UI-2 Video User | ui_building | logic_pending | pending | pending | - |
| 个人主页 | `2213:1272` | UI-2 Video User | ui_building | logic_pending | pending | pending | - |
| 更多 | `2259:10276` | UI-2 Video User | ui_building | logic_pending | pending | pending | - |
| 举报 | `2259:11663` | UI-2 Video User | ui_building | logic_pending | pending | pending | - |
| 聊天 | `2085:16397` | UI-3 Chat System Support | ui_building | logic_pending | pending | pending | - |
| 系统消息 | `2259:9753` | UI-3 Chat System Support | ui_building | logic_pending | pending | pending | - |
| 在线客服 | `2259:10100` | UI-3 Chat System Support | ui_building | logic_pending | pending | pending | - |
| 编辑资料 | `2179:19376` | UI-4 Profile Edit | ui_done | logic_pending | pending | pending | - |
| 我的相册 | `2259:11719` | UI-4 Profile Edit | ui_done | logic_pending | pending | pending | - |
| 兴趣 | `2290:1427` | UI-4 Profile Edit | ui_done | logic_pending | pending | pending | - |
| 个性化标签 | `2290:1546` | UI-4 Profile Edit | ui_done | logic_pending | pending | pending | - |
| 昵称 | `2290:1652` | UI-4 Profile Edit | ui_done | logic_pending | pending | pending | - |
| 搜索 | `2290:1708` | UI-4 Profile Edit | ui_done | logic_pending | pending | pending | - |
| 简介 | `2290:1763` | UI-4 Profile Edit | ui_done | logic_pending | pending | pending | - |
| 充值页 | `2179:19110` | UI-5 Profile Business | ui_done | logic_pending | pending | pending | 820 金币档设计价 ¥8、领域价 ¥68 待产品确认 |
| 亲密关系 | `2259:9824` | UI-5 Profile Business | ui_done | logic_pending | pending | pending | - |
| 谁看过我 | `2259:9890` | UI-5 Profile Business | ui_done | logic_pending | pending | pending | - |
| 通话记录 | `2259:9948` | UI-5 Profile Business | ui_done | logic_pending | pending | pending | - |
| 我的动态 | `2259:10006` | UI-5 Profile Business | ui_done | logic_pending | pending | pending | - |

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
| UI-3 | 聊天正式资源纳入 `AppImageString`；核对 `CommonDraggableFloatWidget` 对 343×52 底部组件的支持 | pending |
| UI-4 | 注册 `assets/icons/profile_edit/`，新增 `profileEditSearch`、`profileEditAlbumAdd` 并替换页面路径字面量 | pending |
| UI-4 | 新增资料编辑、相册与搜索共 9 个中英文 L10n key | pending |
| UI-4 | 从合规 JSON/Repository 注入相册与资料预选 seed，禁止回填到 View | logic_pending |
| UI-5 | 我的动态补点赞、评论、打招呼领域接口；`MyWorldPost` 补年龄、身高等展示字段 | logic_pending |
| UI-5 | 访客/亲密关系实体补未读状态；补动态空态与互动反馈 L10n | logic_pending |
| UI-5 | 820 金币档设计价格 ¥8 与领域配置 ¥68 冲突，集成阶段按既有业务配置保留并列为产品确认项 | blocked_product |
