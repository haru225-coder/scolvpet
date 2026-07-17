# TodayTasksWidget（iOS WidgetKit 脚手架）

T-P1-05 在 iOS 侧提供源码脚手架；**尚未**挂入 Xcode 工程的 Widget Extension target。

## 接入步骤（本机 Xcode）

1. 打开 `ios/Runner.xcworkspace`
2. File → New → Target → Widget Extension，命名 `TodayTasksWidget`
3. 将本目录 `TodayTasksWidget.swift` 纳入新 target（或替换模板文件）
4. Runner 与 Widget 均开启 App Group：`group.cn.scolvpet.dev`
5. Flutter 侧后续可把 `SharedPreferences` 改为 App Group 容器（当前 Android 已可用 FlutterSharedPreferences）

## 键名（与 Dart `TodayWidgetKeys` 对齐）

| Key | 含义 |
|-----|------|
| `today_widget_title` | 标题 |
| `today_widget_body` | 多行正文 |
| `today_widget_count_label` | 计数文案 |
| `today_widget_json` | 完整 JSON |

## 状态

- **Android**：可编译的 AppWidget 已注册，App 内任务同步后刷新
- **iOS**：源码就绪，Xcode target / App Group 为待办
