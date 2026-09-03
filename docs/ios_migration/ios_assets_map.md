# iOS 静态资源映射

## 迁移规则与结论

- 只迁移当前 Target 的业务代码或完整 fixture 实际引用的资源；Pod、无入口 city Tab 图标和废弃样本不进入 Flutter 包。
- 图片均保持原位图内容，Flutter 文件名按业务分类；JSON 中的原相对路径仅转换为 Flutter asset path。
- 原 `figfureUser.json` 的 10 人和 `cityUsers.json` 的 12 人已完整迁移，没有用合成昵称或改写正文替代原 fixture。
- `pubspec.yaml` 按实际目录声明，动态 JSON 引用的文件通过 Repository 测试逐个 `rootBundle.load` 校验。

## App / common

| iOS Asset | Flutter 目标 | 状态 |
|---|---|---|
| `AppIcon.appiconset/logo.png` | `ios/Runner/Assets.xcassets/AppIcon.appiconset` | verified；完整尺寸集，所有 PNG 无 alpha |
| `applogo` | `assets/images/avatar/img_avatar_assistant.png` | verified；助手头像 |
| `userDefault` | `assets/images/placeholder/img_avatar_default.png` | verified；默认头像 |
| `AccentColor` colorset | Flutter Theme token | not_required；无独立位图 |

## Tab / navigation / profile

| iOS Asset | Flutter 目录 | 状态 |
|---|---|---|
| `tab_1_n/s`、`tab_2_n/s`、`tab_center_n/s`、`tab_3_n/s`、`tab_4_n/s` | `assets/icons/tabbar/` | verified；五 Tab normal/selected 共 10 张 |
| `tab_city_n/s` | — | not_migrated_no_entry；对应 Controller 无入口 |
| `home_shaixuan` | `assets/icons/navigation/ic_filter.png` | verified |
| `home_renzheng` | `assets/icons/status/ic_verified.png` | verified；用户详情认证标题使用 |
| `mine_customer`、`mine_minevip`、`mine_photo`、`mine_private`、`mine_renzheng`、`mine_users`、`mine_weiliao`、`mine_world` | `assets/icons/profile/` | verified；个人中心八项菜单使用 |

## 用户与内容图

| iOS 来源 | Flutter 目标 | 状态 |
|---|---|---|
| `figureMutu/1,2,4,5,6,7` 头像与 show 图 | `assets/images/avatar/img_feed_user_*.png`、`assets/images/content/img_feed_user_*_*.png` | verified；覆盖原用户 ID 1、2、3、4、6、7 |
| `new_header_1_women` … `new_header_4_man` 及 show 图 | 同目录 ID 8–11 文件 | verified；原昵称、字段与内容已恢复 |
| `new_city_1/2_headerimage`、`new_city_1/2_show_*` | `img_city_user_101/102*` | verified；保留原资源名与实际文件名对调后的业务语义 |
| `tian_1` … `tian_8` | `assets/images/avatar/img_verified_user_01…08.png` | verified；真人视频流头像 |

## 音视频

| iOS Resource | Flutter 目标 | 状态 |
|---|---|---|
| `tian_show_1.mp4` … `tian_show_8.mp4` | `assets/videos/verified/user_01…08.mp4` | verified |
| `new_city_1_video.mov` | `assets/videos/city/user_101.mov` | verified；未转码 |
| `mituteamCall.mp3` | `assets/audio/call/mitu_call.mp3` | verified |

## 本地数据与法律文本

| 来源 | Flutter 目标 | 状态 |
|---|---|---|
| `figureMutu/figfureUser.json` | `assets/mock/users.json` | verified；10/10 用户 |
| `figureMutu/cityUsers.json` | `assets/mock/city_users.json` | verified；12/12 用户 |
| 真人视频 Controller 内置数据 | `assets/mock/verified_users.json` | implemented；8 位用户与八段视频对应 |
| iOS 城市常量 | `assets/mock/home_cities.txt` | verified；保持中文 contains 搜索 |
| iOS 默认聊天数据 | `assets/mock/chat_messages.json` | implemented；Domain/DTO 转换读取 |
| `MTVIPAutoRenewAgreementViewController` 内嵌 HTML | `assets/legal/vip_auto_renew.html` | verified；Flutter WebView asset 加载 |

## 未打包资源

- 原工程中无业务引用的 city Tab 图标、旧样本、Pods 资源和 SDK 资源不复制。
- Flutter 当前资产目录中的文件均由生产代码、完整 JSON fixture 或 AppIcon catalog 使用；不存在专用测试占位资源。
