# Flutter I1 客户端

## 运行

```bash
cd ../..
make flutter-pub-get
cd apps/mobile
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8080
```

地址约定：模拟器或 Mac 桌面运行可以使用 `127.0.0.1`；真机上的 `127.0.0.1` 指向手机自身，必须改成 Mac 在同一局域网内可访问的地址，例如：

```bash
flutter build ios --release --dart-define=API_BASE_URL=http://192.168.31.58:8080
```

发布前请先用手机访问同一地址的 `/healthz`，再安装 Release 包。

临时 VPS 验收：LA1 使用 `p.scolv.com`，API 基址为 `https://p.scolv.com:8443`：

```bash
flutter build ios --release --dart-define=API_BASE_URL=https://p.scolv.com:8443
```

> **正式发布禁止裸 `flutter build`**：`app_config.dart` 的编译期默认值指向 staging
> （`p.scolv.com`），只有仓库根的 `make release-android` / `make release-ios` 会
> fail-closed 校验并注入 `API_BASE_URL` 与 `PUBLIC_SITE_HOST`，绕过它们打的包
> 会把 staging 主机烧进产物。

仓库根目录提供带超时保护的 `make flutter-pub-get`、`make flutter-analyze`、`make flutter-test` 和 `make flutter-build-android`；默认 Flutter 命令超时 900 秒、Android 构建超时 1800 秒，Gradle 网络连接/读取超时 60000 毫秒。

应用层通过 `generated/dart/scolvpet_api` 的 `DefaultApi` 访问 `/v1`。安全令牌写入 `flutter_secure_storage`，壳层/账号/熊舍/规则写入只读缓存；离线时主壳可浏览，业务写入口关闭。

工程固定 Flutter 3.44.0 stable（bundled Dart 3.12.0），已包含 Android/iOS 平台目录。临时开发标识为 `cn.scolvpet.dev`，正式 Bundle ID/applicationId 与签名团队待确认。
