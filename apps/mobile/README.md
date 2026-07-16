# Flutter I1 客户端

## 运行

```bash
cd ../..
make flutter-pub-get
cd apps/mobile
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8080
```

仓库根目录提供带超时保护的 `make flutter-pub-get`、`make flutter-analyze`、`make flutter-test` 和 `make flutter-build-android`；默认 Flutter 命令超时 900 秒、Android 构建超时 1800 秒，Gradle 网络连接/读取超时 60000 毫秒。

应用层通过 `generated/dart/scolvpet_api` 的 `DefaultApi` 访问 `/v1`。安全令牌写入 `flutter_secure_storage`，壳层/账号/熊舍/规则写入只读缓存；离线时主壳可浏览，业务写入口关闭。

工程固定 Flutter 3.44.0 stable（bundled Dart 3.12.0），已包含 Android/iOS 平台目录。临时开发标识为 `cn.scolvpet.dev`，正式 Bundle ID/applicationId 与签名团队待确认。
