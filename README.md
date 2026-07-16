# 熊舍管家 I1 工程

这是熊舍管家 MVP I1 的可运行单仓工程：Go + PostgreSQL 模块化单体 API、Flutter 移动端、独立 Node SSR Web、版本化数据库迁移和 OpenAPI `dart-dio` 客户端生成链。

## 本地启动

1. 复制 `.env.example` 为 `.env`，只填本机占位配置。
2. 准备 PostgreSQL 15+，执行 `make db-verify` 验证全新库；已有库执行 `make db-seed`。
3. 在 `api/` 执行 `go run ./cmd/server`，默认监听 `:8080`。
4. 在 `apps/web/` 执行 `npm install && npm run dev`，默认监听 `:3000`。
5. 使用 Flutter 3.44.0 stable（Dart 3.12.0），在仓库根目录执行 `make flutter-pub-get` 后进入 `apps/mobile/` 执行 `flutter run`；Android/iOS 开发标识统一为 `cn.scolvpet.dev`，正式值只在 `apps/mobile/android/mobile-identifiers.properties` 的 `SCOLVPET_APP_ID` 单点替换。依赖获取、分析、测试和 Android 构建使用带超时保护的 Make 入口。

I1 演示链：申请模拟验证码 → 验证码登录 → 创建个人熊舍 → 复制系统规则 → 进入五导航 → 退出并重新登录恢复 owner 上下文。开发模拟短信码由 `SMS_MOCK_CODE` 控制，默认值为 `123456`。

## 运行环境门禁

默认 `APP_ENV=development`，保留本地数据库、模拟短信和本地对象存储，供开发与演示使用。设置 `APP_ENV=production` 后，API 会在连接数据库前检查显式数据库地址、非开发密钥、`SMS_PROVIDER=http`、HTTPS 短信 webhook、`OBJECT_STORE_PROVIDER=s3/minio`、HTTPS Outbox Publisher 和 Outbox worker。HTTP provider 发送 `POST` JSON：`{"phone":"+8613800138000","code":"654321","expires_in_seconds":300}`，并使用 `Authorization: Bearer SMS_HTTP_TOKEN`。

生产对象存储配置为 `OBJECT_STORE_ENDPOINT`、`OBJECT_STORE_BUCKET`、`OBJECT_STORE_REGION`、`OBJECT_STORE_ACCESS_KEY` 和 `OBJECT_STORE_SECRET_KEY`；`OBJECT_STORE_PATH_STYLE=true` 适合 MinIO，MinIO 默认启用 path-style，S3 默认使用 virtual-hosted-style。入口会将构造出的 ObjectStore 注入 API Server，开发环境仍使用 `IMPORT_OBJECT_STORE_DIR` 指向的 local 实现。
生产 Outbox 配置为 `OUTBOX_PUBLISHER_MODE=http`、`OUTBOX_PUBLISHER_ENDPOINT` 和 `OUTBOX_PUBLISHER_TOKEN`；Publisher 将 topic 与 JSON payload 发送到 HTTPS endpoint，非 2xx 响应会进入重试/死信流程。

## 校验

`make ci` 运行迁移复跑/checksum、OpenAPI lint、API/Outbox、Web、Flutter analyze/test、Android debug 构建和生成客户端漂移检查。GitHub Actions 另按 lint/test/build 分 job，并检查 iOS 26.5 simulator runtime。Android 最低 API 为 21，iOS 最低版本为 13.0；正式 Bundle ID、签名团队、keystore/profile 与真机安装仍待确认。完整基线见 [`docs/engineering/工程平台基线.md`](docs/engineering/工程平台基线.md)。
