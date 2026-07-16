# 熊舍管家 I1 工程

这是熊舍管家 MVP I1 的可运行单仓工程：Go + PostgreSQL 模块化单体 API、Flutter 移动端、独立 Node SSR Web、版本化数据库迁移和 OpenAPI `dart-dio` 客户端生成链。

## 本地启动

1. 复制 `.env.example` 为 `.env`，只填本机占位配置。
2. 准备 PostgreSQL 15+，执行 `make db-verify` 验证全新库；已有库执行 `make db-seed`。
3. 在 `api/` 执行 `go run ./cmd/server`，默认监听 `:8080`。
4. 在 `apps/web/` 执行 `npm install && npm run dev`，默认监听 `:3000`。
5. 使用 Flutter 3.44.0 stable，在仓库根目录执行 `make flutter-pub-get` 后进入 `apps/mobile/` 执行 `flutter run`；临时开发标识为 `cn.scolvpet.dev`。依赖获取、分析、测试和 Android 构建使用带超时保护的 Make 入口。

I1 演示链：申请模拟验证码 → 验证码登录 → 创建个人熊舍 → 复制系统规则 → 进入五导航 → 退出并重新登录恢复 owner 上下文。开发模拟短信码由 `SMS_MOCK_CODE` 控制，默认值为 `123456`。

## 校验

`make ci` 运行迁移复跑/checksum、OpenAPI lint、API/Outbox、Web、Flutter analyze/test、Android debug 构建和生成客户端漂移检查。正式 Bundle ID、签名团队与真机安装仍待确认。
