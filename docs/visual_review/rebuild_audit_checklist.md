# “微撩重构”视觉审核清单

状态：**等待主控通知实现完成**  
Figma 文件：`sZdTOBC0a94JYUYKgAJr8e`  
基准视口：375 × 812 pt，竖屏，浅色模式，中文，系统文字缩放 100%

本阶段仅建立审核基线和截图命名规范，不读取或修改应用实现。所有页面当前均为 `PENDING`。

## 截图命名规范

统一格式：

```text
rebuild_{序号}_{页面slug}_{node-id}__{来源}__375x812__{状态}[__scroll-{序号}].png
```

字段规则：

- `序号`：两位数，与下方清单一致，确保文件自然排序。
- `页面slug`：只用小写英文字母、数字和连字符。
- `node-id`：将 Figma 的冒号改为连字符，例如 `2200:656` → `2200-656`。
- `来源`：`figma` 或 `app`。同一页面、同一状态必须成对存在。
- `375x812`：始终记录逻辑视口；iPhone 13 mini 模拟器原始图即使为 1080 × 2340 px，也不得写成物理像素尺寸。
- `状态`：`default`、`empty`、`long-copy`、`selected`、`keyboard`、`loading`、`error`、`submitted` 等小写短语。
- 长页或滚动页追加 `__scroll-02`、`__scroll-03`；首屏不加 `scroll-01`。
- 禁止 `final2`、`new`、`最新`、`截图1` 等无法追溯的命名。

示例：

```text
rebuild_01_publish_2200-656__figma__375x812__default.png
rebuild_01_publish_2200-656__app__375x812__default.png
rebuild_01_publish_2200-656__app__375x812__long-copy.png
rebuild_03_activity-detail_2166-18360__app__375x812__default__scroll-02.png
```

截图统一保存到：

```text
docs/visual_review/screenshots/rebuild/
```

## 22 页默认态清单

| # | 页面 | Figma 节点 | slug | Figma 默认态文件 | App 默认态文件 | 必补状态 | 状态 |
|---:|---|---|---|---|---|---|---|
| 01 | 发布 | `2200:656` | `publish` | `rebuild_01_publish_2200-656__figma__375x812__default.png` | `rebuild_01_publish_2200-656__app__375x812__default.png` | `long-copy`、`keyboard`、`submitted` | PENDING |
| 02 | 发布-选择活动类型 | `2241:9566` | `publish-activity-type` | `rebuild_02_publish-activity-type_2241-9566__figma__375x812__default.png` | `rebuild_02_publish-activity-type_2241-9566__app__375x812__default.png` | `selected`、`long-copy` | PENDING |
| 03 | 活动详情 | `2166:18360` | `activity-detail` | `rebuild_03_activity-detail_2166-18360__figma__375x812__default.png` | `rebuild_03_activity-detail_2166-18360__app__375x812__default.png` | `long-copy`、`scroll-02`、`scroll-03` | PENDING |
| 04 | 广场-视频 | `2166:18784` | `square-video` | `rebuild_04_square-video_2166-18784__figma__375x812__default.png` | `rebuild_04_square-video_2166-18784__app__375x812__default.png` | `loading`、`paused`、`error`、`empty` | PENDING |
| 05 | 个人主页 | `2213:1272` | `user-profile` | `rebuild_05_user-profile_2213-1272__figma__375x812__default.png` | `rebuild_05_user-profile_2213-1272__app__375x812__default.png` | `long-copy`、`empty`、`scroll-02` | PENDING |
| 06 | 聊天 | `2085:16397` | `chat` | `rebuild_06_chat_2085-16397__figma__375x812__default.png` | `rebuild_06_chat_2085-16397__app__375x812__default.png` | `empty`、`long-copy`、`keyboard`、`loading` | PENDING |
| 07 | 系统消息 | `2259:9753` | `system-messages` | `rebuild_07_system-messages_2259-9753__figma__375x812__default.png` | `rebuild_07_system-messages_2259-9753__app__375x812__default.png` | `empty`、`long-copy`、`unread` | PENDING |
| 08 | 亲密关系 | `2259:9824` | `close-relationships` | `rebuild_08_close-relationships_2259-9824__figma__375x812__default.png` | `rebuild_08_close-relationships_2259-9824__app__375x812__default.png` | `empty`、`unread` | PENDING |
| 09 | 谁看过我 | `2259:9890` | `profile-viewers` | `rebuild_09_profile-viewers_2259-9890__figma__375x812__default.png` | `rebuild_09_profile-viewers_2259-9890__app__375x812__default.png` | `empty`、`unread`、`scroll-02` | PENDING |
| 10 | 通话记录 | `2259:9948` | `call-history` | `rebuild_10_call-history_2259-9948__figma__375x812__default.png` | `rebuild_10_call-history_2259-9948__app__375x812__default.png` | `empty`、`missed`、`scroll-02` | PENDING |
| 11 | 充值页 | `2179:19110` | `recharge` | `rebuild_11_recharge_2179-19110__figma__375x812__default.png` | `rebuild_11_recharge_2179-19110__app__375x812__default.png` | `selected`、`loading`、`error` | PENDING |
| 12 | 编辑资料 | `2179:19376` | `edit-profile` | `rebuild_12_edit-profile_2179-19376__figma__375x812__default.png` | `rebuild_12_edit-profile_2179-19376__app__375x812__default.png` | `long-copy`、`keyboard`、`scroll-02` | PENDING |
| 13 | 我的动态 | `2259:10006` | `my-posts` | `rebuild_13_my-posts_2259-10006__figma__375x812__default.png` | `rebuild_13_my-posts_2259-10006__app__375x812__default.png` | `empty`、`long-copy`、`scroll-02` | PENDING |
| 14 | 在线客服 | `2259:10100` | `customer-service` | `rebuild_14_customer-service_2259-10100__figma__375x812__default.png` | `rebuild_14_customer-service_2259-10100__app__375x812__default.png` | `empty`、`keyboard`、`loading`、`error` | PENDING |
| 15 | 发布动态 | `2259:10188` | `publish-post` | `rebuild_15_publish-post_2259-10188__figma__375x812__default.png` | `rebuild_15_publish-post_2259-10188__app__375x812__default.png` | `long-copy`、`keyboard`、`selected`、`submitted` | PENDING |
| 16 | 更多 | `2259:10276` | `more` | `rebuild_16_more_2259-10276__figma__375x812__default.png` | `rebuild_16_more_2259-10276__app__375x812__default.png` | `selected` | PENDING |
| 17 | 举报 | `2259:11663` | `report` | `rebuild_17_report_2259-11663__figma__375x812__default.png` | `rebuild_17_report_2259-11663__app__375x812__default.png` | `selected`、`long-copy`、`submitted` | PENDING |
| 18 | 我的相册 | `2259:11719` | `album` | `rebuild_18_album_2259-11719__figma__375x812__default.png` | `rebuild_18_album_2259-11719__app__375x812__default.png` | `empty`、`selected`、`scroll-02` | PENDING |
| 19 | 兴趣 | `2290:1427` | `interests` | `rebuild_19_interests_2290-1427__figma__375x812__default.png` | `rebuild_19_interests_2290-1427__app__375x812__default.png` | `empty`、`selected`、`max-selected`、`scroll-02` | PENDING |
| 20 | 个性化标签 | `2290:1546` | `personality-tags` | `rebuild_20_personality-tags_2290-1546__figma__375x812__default.png` | `rebuild_20_personality-tags_2290-1546__app__375x812__default.png` | `empty`、`selected`、`max-selected`、`scroll-02` | PENDING |
| 21 | 昵称 | `2290:1652` | `nickname` | `rebuild_21_nickname_2290-1652__figma__375x812__default.png` | `rebuild_21_nickname_2290-1652__app__375x812__default.png` | `empty`、`long-copy`、`keyboard`、`error` | PENDING |
| 22 | 简介 | `2290:1763` | `bio` | `rebuild_22_bio_2290-1763__figma__375x812__default.png` | `rebuild_22_bio_2290-1763__app__375x812__default.png` | `empty`、`long-copy`、`keyboard`、`error` | PENDING |

## 每张图的审核维度

每个页面逐项记录 `PASS / P0 / P1 / P2 / N/A`，禁止只写“差不多”或“略有差异”。

| 维度 | 必查值 |
|---|---|
| 结构 | 页面层级、模块数量、顺序、列表密度、浮层/弹窗层级、固定与滚动区域 |
| 间距 | 左右边距、区块间距、行高、卡片尺寸、圆角、分隔线、按钮触达区域；偏差以 pt 记录 |
| 字体 | 字号、字重、行高、字色、对齐、最大行数、省略方式、数字与中英文基线 |
| 颜色 | 页面背景、卡片、边框、阴影、渐变、选中/禁用/错误状态；记录目标与实测色值 |
| 图标资源 | 是否使用正确资产、on/off 映射、尺寸、裁切、抗锯齿、透明边、图片顺序与 `BoxFit` |
| 安全区 | 状态栏前景可读、顶部起点、Home Indicator、底栏/键盘避让，不允许内容被遮挡 |
| 长文案与空态 | 长标题、长简介、多行消息、计数器、空列表、加载和错误状态是否有溢出/跳变 |
| 交互入口 | 返回、保存、发布、选择、举报、充值、拨打/聊天等入口是否存在、可见且位置命中设计 |

## 严重度定义

- **P0**：页面无法进入、崩溃/白屏；主流程入口缺失或不可点击；状态栏/底栏导致关键内容不可读；严重溢出或遮挡使任务无法完成；错误页面被路由到另一个业务页面。
- **P1**：参考结构块缺失；首屏内容密度明显不同；关键按钮、弹窗或选中态不一致；使用错误图标/图片；间距偏差超过 8 pt；长文案或空态稳定复现破版；核心文案/数据 fixture 与指定参考态不一致。
- **P2**：不影响任务完成的局部差异；通常为 1–8 pt 的对齐/圆角偏差、轻微字体或色值偏差、不同像素倍率导致的边缘抗锯齿。
- 同一问题影响多个页面时，登记一次共享根因并列出所有受影响页；不得重复计数掩盖共享缺陷。

## 实现完成后的取证顺序

1. 确认主控明确通知实现冻结，记录提交或工作树时间点；不在并行写入期间采集“最终图”。
2. 导出 22 个 Figma 默认态；需要状态对照时，按相同命名补充 Figma 状态图。
3. 使用同一台 375 × 812 逻辑视口模拟器逐页进入，等待图片与字体稳定至少 2 秒后截图。
4. 默认态先完成 22 对，再采集本表“必补状态”；禁止以线上随机数据作为 golden 基线。
5. 每张 App 图核对原始尺寸、页面路由和选中态，再填写八维结果、匹配度和 P0/P1/P2。
6. 生成总报告时分别给出：逐页百分比、共享问题、页面问题、负责人模块、截图绝对路径、未覆盖状态。

## 当前边界

- 未读取或修改 `lib/**`、`assets/**`、`pubspec.yaml`、`test/**`。
- 未触碰首页与共享封装。
- 未提前判断任何页面通过或失败；实现完成前不生成伪“final”截图。
