# Flutter Foundation Report

## 基础工程

- Flutter 3.35.7 / Dart 3.9.2。
- 启动入口为 `MiTuApp`，直接进入 GetX root route，没有登录、鉴权或 session。
- `InitialBinding` 注入 JSON provider、SharedPreferences 聊天存储、User/Chat/AI repositories；`MainBinding` 只注入五 Tab controller。
- 五 Tab 通过 `IndexedStack` 保持页面状态，顺序为首页、广场、中间视频、通知、我的，默认首页。

## Theme 与国际化

- `AppColors` 来自 iOS `MTTheme`：页面米色、白色卡片、黄色强调、主/次文字、分隔线与图标色。
- 复用 token 只包含已证实的 16pt 横向间距、20pt 卡片圆角、34pt 页面标题等。
- GetX translations 支持 `zh_CN` 与 `en_US`，设备语言不支持时回退中文。

## 数据与聊天

- 用户数据：`assets/mock/users.json -> AssetJsonProvider -> UserRepository -> Domain User`。
- 聊天：fixture 只在首次初始化写入 SharedPreferences，之后保留用户新增消息。
- Chat Domain 仅包含 iOS 已有的纯文本字段；`ChatMessageMapper` 是唯一依赖 `flutter_chat_core` 的转换边界。
- AI 使用 `AiRepository -> MockAiProvider`，Flutter 工程不包含生产 endpoint 或 API Key。

## 依赖与权限

- 直接依赖：GetX、SharedPreferences、flutter_chat_core、flutter_chat_ui、Flutter localization。
- 未加入腾讯 IM/TRTC、美颜、一键登录、风控或未使用权限。
- Runner Info.plist 未添加相机、麦克风、联系人、定位、推送等描述。

## 验证基线

- `flutter analyze`：0 issue。
- `flutter test`：2 tests passed。
- iOS Debug 无签名构建成功；含中文工程路径时 CocoaPods 命令需要 UTF-8 locale。
