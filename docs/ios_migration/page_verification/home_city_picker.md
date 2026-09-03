# Home City Picker 迁移核对

## 基本信息

- iOS Source: `Pages/Home/MTHomeCityPickerViewController.swift`、`Services/MTHomeCityService.swift`、`Services/MTHomeCityOptions.swift`
- Flutter Target: `lib/modules/home/city_picker`
- Entry: 首页城市按钮，`UINavigationController.pushViewController`
- Exit: 选择后先通过 closure 写入 CityService，再 pop；Flutter 等价为 Repository 写入后 `Get.back(result: city)`

## 源码能力确认

1. 城市数据来自 `MTHomeCityOptions` 的本地代码常量，并合并 `MTCityDataService` 用户城市去重。
2. 不是接口、plist 或 JSON；Flutter 将同一静态结果落为 `assets/mock/home_cities.txt`。
3. 不按省份分组。
4. 不显示字母分组；数据按 iOS `localizedStandardCompare` 的实际结果预排序。
5. 无热门城市。
6. 无最近访问。
7. 无独立“当前城市”分区；当前选中行显示 checkmark。
8. 无定位城市，无 `CLLocationManager`。
9. 有搜索框。
10. 不支持拼音搜索。
11. 仅用去除首尾空白后的中文城市名 `contains` 匹配。
12. 无右侧索引栏。
13. 无取消按钮；只有标准返回。
14. 选择后 pop。
15. 通过 `mtOnCitySelected: (String) -> Void` 回传首页。
16. `MTHomeCityService` 写入 UserDefaults key `mt_home_selected_city`。
17. App 重启后从同一 key 恢复；缺省值为“全部”。
18. 变更后通知首页重载：活动按 location/content 包含城市过滤，附近和新人按 user.city 精确过滤。

## UI 与交互

- 17pt semibold 居中标题、左返回按钮、页面背景和白色导航栏按 iOS Base Controller 还原。
- minimal 搜索框在列表上方；城市行 52pt、16pt 系统字、separator、选中 checkmark。
- `ListView.separated` 懒加载；拖动列表收起键盘；空搜索恢复全部数据。
- 无搜索无结果文案，iOS 也是空列表。

## Assets / Localization / Permissions

- 页面无自定义图片资源；返回、搜索和 checkmark 均为系统图标。
- 仅“选择城市”、“搜索城市”和加载错误进入 zh_CN/en_US；城市名作为业务数据不翻译。
- 无定位或其他权限调用；`ios_permissions.md` 无需变更，Info.plist 未新增权限。

## Known Difference / TODO(iOS_VERIFY)

- Flutter 用同一 UserDefaults key 保持业务语义；不复制 NotificationCenter 技术实现，而是使用明确字符串返回值驱动 HomeController 重载。
- `MTCityViewController` 经全局入口复核仍不可达，记录为 `not_migrated_no_entry`；本页与它没有直接导航关系。

## Verification Result

- `dart format .`：passed
- `flutter analyze`：0 issue
- `flutter test`：全量 20 tests passed，其中城市用例覆盖缺省城市、搜索、选择返回、持久化恢复和首页标题变更
- iPhone 14 simulator：Debug build/install/launch passed
- Status: `implemented / no`；真实模拟器退出并重启后的持久化交互未能在当前自动化界面中复核，不标记 verified。
