# 业务模块迁移核对

## 页面范围

- 原 Target 共 37 个 `*ViewController` 类。
- `MTBaseViewController`、`MTTabRootViewController`、`MTWebContentViewController` 是基础容器，不计作独立业务页面。
- 其余 34 个页面控制器中，33 个已有 Flutter 等价页面或共享页面状态。
- `MTCityViewController` 经 push/present、Storyboard、通知、类名字符串和 Tab 配置复核均无入口，状态为 `not_migrated_no_entry`。

Flutter 不机械追求文件一一对应：三个法律 Controller 复用 `LegalWebPage`，兴趣与个性标签复用 `ProfileTagsPage`，中心视频与独立视频复用同一视频组件。

## 模块结论

| 模块 | 状态 | 已实现闭环 | 自动化证据 | 人工待验收 |
|---|---|---|---|---|
| 五 Tab | implemented / manual verification pending | 首页、广场、真人视频、通知、我的；IndexedStack 保持状态 | Widget 测试校验顺序、标题及 Tab 切换 | 真机视觉、系统返回 |
| Home / Team | implemented / manual verification pending | 城市、筛选、发布、详情、攻略、直接加入、VIP 门槛、治理、预览 | 城市/筛选/社交状态 Widget 测试；发布 Repository 测试 | 图片选择、WebView、完整返回链 |
| Square / Video | implemented / manual verification pending | 推荐/关注、话题、动态聚合、发布、点赞、关注、纵向视频、搜索、治理 | 广场入口/话题头 Widget 测试；全项目 iOS 构建 | 视频播放/暂停、手势与长列表 |
| Chat / Voice Call | implemented / manual verification pending | 会话排序、助手置顶、一发一回、历史、本地 AI Mock、扣币、模拟通话 | Mapper、会话入口及历史 Widget 测试 | 键盘、音频听感、30 秒结束 |
| Profile | implemented / manual verification pending | 编辑、标签、认证、相册、我的世界、客服、法律页、钱包/VIP | 资料、相册、动态、钱包 Repository 测试 | 系统媒体选择器及本地视频预览 |
| IAP | implemented / manual verification pending | 商品查询、购买、恢复、交易完成、客户端交付去重 | iOS StoreKit 插件编译通过；钱包逻辑测试 | Sandbox 商品、购买/恢复、服务端收据 |
| Governance / UGC | implemented / backend gap | 举报 UI、本地拉黑/屏蔽、发布 pending、自己内容删除 | 社交状态和发布持久化测试 | 正式审核、举报处理与申诉依赖后端/产品 |

## 全项目检查

- 生产 Dart 中未发现空业务回调、Coming Soon、TODO/FIXME/HACK、调试打印或密钥。
- 中文与英文语言表键集合一致；canonical iOS 业务值只在展示层翻译，持久化值不变。
- Flutter 依赖均有生产代码引用；未迁移腾讯 IM、TRTC、美颜、一键登录、定位、通讯录、推送等无业务调用能力。
- iOS 最低版本 14.0、仅 iPhone、仅竖屏；没有相机、麦克风、定位、通讯录、推送或 ATT 权限。
- HTTP ATS 例外仅限原协议地址 `43.143.47.155`；上线仍应替换为 HTTPS。
- 原 AppIcon 已生成完整无 alpha 尺寸集。

## 当前验证结果

- `flutter pub get`：passed。
- `dart format .`：120 files，0 changed。
- `flutter analyze`：0 issue。
- `flutter test -r compact`：20 tests passed。
- `LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 flutter build ios --debug --no-codesign`：passed，生成 `build/ios/iphoneos/Runner.app`。
- Simulator 原生 UI 无法在当前自动化环境完成逐页人工操作，统一记录 `manual_runtime_verification_pending`。
