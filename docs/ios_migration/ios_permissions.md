# iOS 权限审计

## 结论

Flutter `Info.plist` 与原工程一致，只保留对 `43.143.47.155` 的 HTTP ATS 例外，没有任何 `NS*UsageDescription`、Background Modes 或推送声明。Flutter 最低版本已对齐 iOS 14.0，`image_picker_ios` 在当前相册调用下使用 `PHPickerViewController`，不要求应用获得完整照片库权限。

| 权限 | iOS Key | 实际使用位置 / 业务用途 | Flutter 插件建议 | 描述建议 | 是否保留 |
|---|---|---|---|---|---|
| Photo Library（系统选择器） | 当前无 | 编辑头像、相册导入照片/视频、发布组队图片、发布动态图片、认证证件图片；均用 PHPicker | `image_picker` 或 `photo_manager` 的 limited picker 路径；优先无需广泛授权的系统 picker | 若所选插件/配置强制声明：`用于选择照片或视频，完善个人资料、发布内容或保存到个人相册。` | 保留功能；是否加 Key 取决于 Flutter 插件实际实现 |
| Camera | 无 | 未发现相机采集 | 无 | 不应添加 | 不保留 |
| Microphone | 无 | “语音通话”仅播放本地 MP3 和计时，无录音 | 无 | 不应添加 | 不保留 |
| Contacts | 无 | 无通讯录调用或联系人页面 | 无 | 不应添加 | 不保留 |
| Location | 无 | 城市为手选/本地字段，不读取定位 | 无 | 不应添加 | 不保留 |
| Bluetooth | 无 | 未使用 | 无 | 不应添加 | 不保留 |
| Face ID | 无 | 未使用 LocalAuthentication | 无 | 不应添加 | 不保留 |
| Notifications | 无 | 仅应用内 `NotificationCenter`，不是系统通知 | 无 | 不应添加 | 不保留 |
| Tracking | 无 | 未使用 ATT/广告标识符 | 无 | 不应添加 | 不保留 |
| Calendar | 无 | 未使用 | 无 | 不应添加 | 不保留 |
| Speech | 无 | 未使用 | 无 | 不应添加 | 不保留 |
| Background Modes | 无 | 未声明/未使用 | 无 | 不适用 | 不保留 |

## 相关但不是权限的配置

- `NSAppTransportSecurity/NSExceptionDomains/43.143.47.155/NSExceptionAllowsInsecureHTTPLoads = true` 仅为隐私和用户协议 HTTP 页面服务。Flutter 若仍访问该地址需复制等价例外，但上线前应优先迁移 HTTPS。
- AVPlayer/AVAudioPlayer 播放 bundle 媒体无需相机/麦克风权限。
- PHPicker 返回用户主动选择的资源，不等价于遍历照片库。

已复核生成的 iOS 插件源码：当前只调用 gallery 路径，iOS 14+ 使用 PHPicker；未调用 camera，故不增加照片、相机或麦克风 Usage Description。若未来降低最低系统版本或启用相机，必须重新审计。
