# 2026-07-26 · ScolvPet 审计 §8-A 回收（声明不实 + 推迟项）

## 目标

回收 `docs/31` 收口审计的 A 组三项：两条声明不实 + P1-2 推迟项。

## 完成

- **`33d6495` 小程序门禁**：`build-miniprogram.sh` 补 AppID 校验（`wx` 前缀 + 18 位 + 16 位小写 hex），
  production 构建 fail-closed；`release_gate.test.mjs` 坏值 fixture 由 5 组扩到 8 组。
- **`e45ecf6` 生产就绪对齐**：
  - `.env.production.example` 补 `WECHAT_PROVIDER=http`、`WECHAT_APPID/SECRET` 转为必填项，修过期注释；
  - `/readyz` 增加 `environment` 与 `checks`（sms_provider / sms_mock_code_set / wechat_provider），
    由 main.go 从 runtime config 注入，`Ready` 为 nil 时保持旧响应形态（单测不受影响）；
    docs/30 原文的 "CORS origin" 检查项无对应物——Go API 无 CORS 层（Caddy 前置），落为上述三项；
  - smoke 脚本：HTTP 段在 `environment=production` 时断言三项 checks（旧二进制无该字段则跳过，向后兼容）；
    静态段补 `WECHAT_PROVIDER=http` 断言。

## 验证

```text
go build/vet + 触及包测试                        → 全绿（gofmt：本次触及文件零漂移）
make miniprogram-test                            → 15/15（含新增 3 组坏值）
smoke 静态断言 正/反例 + 模板自检                 → PASS / 精确报错 exit 1 / 模板 PASS
smoke HTTP 断言（本地假服务端 good/bad readyz）   → PASS / 精确报错 exit 1
```

**状态：已验证**（本地）。**待确认**：真实部署环境跑 smoke（LA1 尚未部署新二进制，见 docs/31 §6）。

## 备注

审计 §8-A 三项全部关闭。B 组（安全遗留 5 项 + iOS 构建守卫 + LA1 部署对账）待开。
