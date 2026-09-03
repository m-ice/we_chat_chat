# 1.0 视觉独立审查

审查日期：2026-09-03  
结论：**P0 = 0；共享壳层可通过。像素级参考态一致性暂不签收，尚有 5 项 P1。** 5 个页面平均匹配度为 **84%**；连同 Tab 图标组件计算为 **87%**。

## 审查口径

- 实机环境：iOS 16.4，iPhone 13 mini 模拟器；逻辑视口 375 × 812 pt，原始截图 1080 × 2340 px。
- 当前图全部由同一份最终源码构建，通过 `docs/visual_review/audit_main.dart` 只切换首屏 Tab；未替换业务页面。
- Figma 节点：Home `1960:13484`、Partner `2018:14004`、Square `2103:16985`、Message `2018:14293`、Profile `2039:14772`、Tab 图标 `1876:11242`。
- Square 的 Figma 节点是 375 × 2531 长画板；匹配度针对实机 375 × 812 首屏。折叠线以下未做拼接截图，不计入百分比。
- 系统时间由模拟器生成，和 Figma 固定的 `9:41` 不同；该文本差异不计为缺陷。状态栏前景色、底部安全区和内容可读性计入。
- 评分权重：结构与首屏密度 25%、几何与安全区 25%、字体与颜色 15%、图片/裁切/图标 20%、导航状态 10%、系统可读性 5%。

## 页面结果

| 页面 / 节点 | 匹配度 | 已对齐的可量化项 | 未对齐证据 | 当前图 | Figma 图 |
|---|---:|---|---|---|---|
| Home `1960:13484` | **92%** | Hero x=16、w=343、h=177；活动卡 x=16、w=343、h=139；底栏 5 项、选中态及文字齐全 | 主标题仍是常规白字阴影，Figma 为倾斜粗体、深棕描边；CTA 两侧心形在当前图呈方块状/不清晰 | [final_home_375pt.png](screenshots/final_home_375pt.png) | [figma_home_1960-13484.png](screenshots/figma_home_1960-13484.png) |
| Partner `2018:14004` | **88%** | 顶栏三 Tab；两列卡片 x=8/191、w=175、h=238；在线标签、底部渐变与按钮位置对齐 | Figma 首四图顺序为深蓝上衣/白衫/黄衣花田/紫衣，当前为树林/招牌/深蓝上衣/黄衣花田；Figma 文案为“零度晚风 / 深圳 / 交流”，当前数据和“交谈”不同 | [final_partner_375pt.png](screenshots/final_partner_375pt.png) | [figma_partner_2018-14004.png](screenshots/figma_partner_2018-14004.png) |
| Square `2103:16985` | **80%** | 375 × 255 暖黄背景已恢复；三 Tab、搜索、343 宽圆角卡、招呼按钮、发布按钮和底栏状态对齐 | Figma 首屏完整显示 2 张卡；当前只完整显示 1 张并露出第 2 张上半部。首条由 Figma 的短文/`12小时前发布`/粉色已点赞态变为三行长文/绝对日期/灰色未点赞态，卡高和密度随之改变 | [final_square_375pt.png](screenshots/final_square_375pt.png) | [figma_square_2103-16985.png](screenshots/figma_square_2103-16985.png) |
| Message `2018:14293` | **72%** | 标题、4 个 52 × 52 快捷入口、`99+` 角标、单条 76 高会话行、底栏选中态均对齐 | Figma 首屏有 4 条会话，当前只有“微撩助手”1 条；缺 3 条造成 228 pt 的内容密度差。头像、名称、预览和时间也不是参考态 | [final_message_375pt.png](screenshots/final_message_375pt.png) | [figma_message_2018-14293.png](screenshots/figma_message_2018-14293.png) |
| Profile `2039:14772` | **90%** | 88 头像、三项快捷卡、5 行菜单、菜单顺序、底栏选中态均对齐；未出现设计外的真人认证行 | Figma 身份态为“橘子海来信 / ID: 1223332 / 蓝色西装头像”，当前为“微撩 / ID: 2 / 海边车辆头像”；其余主要是约 2–4 pt 的系统安全区差 | [final_profile_375pt.png](screenshots/final_profile_375pt.png) | [figma_profile_2039-14772.png](screenshots/figma_profile_2039-14772.png) |
| Tab 图标 `1876:11242` | **98%** | 5 组 on/off 资产、28 × 28 图标、灰色未选中/黄色选中、7 pt 顶距、4 pt 图文间距与 10 pt 标签均已落地 | Figma 组件节点本身只含图标，不含各页面的系统安全区；剩余 2% 为不同渲染倍率下的边缘抗锯齿 | 各页 `final_*.png` 底部 | [figma_tabbar_1876-11242.png](screenshots/figma_tabbar_1876-11242.png) |

## P0 / P1 清单与模块分配

### P0

无。此前状态栏在浅色背景上显示浅色图标的问题，最终构建已修复；五张 `final_*.png` 均为深色状态栏前景。共享底栏的标签、选中/未选中资产映射也已修复。

### P1

| 编号 | 问题与验收值 | 建议负责模块 |
|---|---|---|
| P1-01 | Home 主标题需与 Figma 的倾斜粗体、深棕描边一致；CTA 两侧必须显示清晰心形，不能呈方块。验收以 `figma_home_1960-13484.png` 的标题轮廓和心形为准 | `lib/modules/home/views/home_page.dart`；字体/装饰资产 |
| P1-02 | Partner 参考态需锁定前四张图片顺序，并统一参考文案“零度晚风 / 深圳 / 交流”；若线上必须展示动态数据，则另建固定 golden fixture，不用线上随机态做视觉回归 | `lib/modules/discover/views/video_feed_page.dart`；Partner 数据源/fixture |
| P1-03 | Square golden 首屏需恢复 2 张完整卡的密度；首条使用参考短文、`12小时前发布` 和粉色已点赞态。验收：375 × 812 首屏不得因样例长文只剩 1 张完整卡 | `lib/modules/discover/views/square_page.dart`、`square_controller.dart`；Square fixture/repository |
| P1-04 | Message golden 参考态需有 4 条 × 76 pt 会话行，不能只注入 1 条。验收：第 4 条分隔线约落在 y=497，且四条头像/名称/预览/时间完整可见 | `lib/modules/chat/views/conversation_page.dart`、会话数据源/fixture |
| P1-05 | Profile golden 需固定为设计身份态“橘子海来信 / ID: 1223332 / 蓝色西装头像”；若产品定义要求展示当前登录用户，则将此项转为截图 fixture 责任，不改生产数据绑定 | `lib/modules/profile/views/profile_page.dart`、`profile_controller.dart`；Profile fixture |

## 发布建议

- 若 1.0 **视觉门槛**是“无 P0、共享导航可用、主要布局无破版”，本次可通过。
- 若 1.0 门槛是“与指定 Figma 参考态像素级一致”，本次不通过；先完成 P1-01 至 P1-05，再用同一 375 × 812 fixture 重拍。
- 不应通过隐藏底栏文字、交换 selected/on 资产或使用旧构建来提高分数；最终截图已经验证这些共享项处于正确状态。

## 工程验证（不计入视觉百分比）

- `flutter analyze`：通过，0 issue。
- `flutter test`：20 passed / 1 failed。失败点为 `test/widget_test.dart:53`，`tester.getSize(heroBackground)` 抛出 `Bad state: No element`；该测试仍以 `Image + AssetImage(figma_home_hero_bg.png)` 查找 Hero 背景，当前页面结构未被该 finder 命中。真机 Hero 可见且已计入截图，但若发布门槛要求全测试通过，仍需由 Home/测试负责人同步 finder 或渲染结构。

## 截图目录

- 最终实机：`docs/visual_review/screenshots/final_home_375pt.png`、`final_partner_375pt.png`、`final_square_375pt.png`、`final_message_375pt.png`、`final_profile_375pt.png`
- Figma 参考：`docs/visual_review/screenshots/figma_home_1960-13484.png`、`figma_partner_2018-14004.png`、`figma_square_2103-16985.png`、`figma_message_2018-14293.png`、`figma_profile_2039-14772.png`、`figma_tabbar_1876-11242.png`
- `current_*.png` 是整改前/中间态，仅保留为回归证据，不参与最终评分。
