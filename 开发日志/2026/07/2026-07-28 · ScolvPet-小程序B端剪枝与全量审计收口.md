# ScolvPet 小程序 B 端剪枝与全量审计收口

日期：2026-07-28

状态：已写入 / 本地门禁已验证 / 正式 AppID 与真机待确认

## 变更账

### 三轮剪枝

1. 删除 `enclosures` 三页及全部入口、权限、AI 深链、测试断言和文档残留；「个体与笼舍」统一为「个体档案」。
2. 硬删 `members`、`public-site`、`growth`、`stud` 四个分包及其 API 实例、能力位、深链、迁移测试和 README 声明，B 端分包由 15 个降至 10 个。
3. 今日页经营入口收敛为 `ENTRIES` + `EntrySection()` 单一真源；「CRM / 合同 / 财务」改为「CRM 客户」；清理 `dist/`、`.swc/`、`.DS_Store`、`__MACOSX`，死代码扫描未发现死文件。

### 两轮审计修复

- 发布安全：运行时配置三层 fail-closed；开发登录入口要求开发环境且凭据非空；新增构建时生产配置门禁；开启 `urlCheck`、关闭 sourcemap；release gate 缺根脚本时显式 skip。
- 页面与类型：补齐 9 个 `index.config.ts`；新增最小 API 信封类型并消除隐式 `any`；B 端 TS/TSX、mp-ui、测试恢复严格 ESLint，C 端原生页保留兼容口径。
- 会话与存储：会话增加 30 天上限；今日页新增退出入口；退出清空离线快照；快照增加 7 天 TTL、40 条上限；抽出 `src/utils/storage.ts` 解开潜在循环依赖。
- 权限：财务与导入能力加入 owner-only 硬约束，优先于角色和服务端能力回退。
- 审计返修：删除 `assertBuildConfig()` 空分支，`urlCheck` 改为严格 `=== true`；清理 4 个死 import。

### 回 monorepo 后补抓并修复

- Downloads 最终版本接回 monorepo 后，生成客户端的 `ResponseMeta` 暴露出 6 个 `ApiEnvelope.meta` 类型不兼容；将最小信封的 `meta` 收敛为 `unknown`，`tsc --noEmit` 恢复零错误。
- 根发布脚本原先会重建旧版 `config.js`，导致 `--restore` 丢失新版 fail-closed 逻辑；改为同时备份配置和项目文件，只替换四个注入常量，并按字节恢复原文件。

## 验证账

- `npx tsc --noEmit`：通过，0 错误。
- `npm run lint`：通过，0 error / 124 warning；warning 均来自已按约定记账的显式 `any`。
- `npm test`：Vitest 38 通过 / 1 个静态预览条件跳过 / 0 失败。
- `node --test test/*.test.mjs`：18 通过 / 0 跳过 / 0 失败，其中 release gate 4/4 通过。
- `make miniprogram-next-build`：Taro 构建通过；主包 0.857MB，10 个分包最大 0.035MB，总包 1.053MB；dist smoke 37/37 通过。

## 保留项

- `finance`、`crm/create`、`reminders` 的 `If-Match` 是否必需，继续以 `specs/api/openapi.yaml` 为真源核对，避免无依据加头造成 412。
- PDF 下载为二进制传输边界，保留现有受控 direct URL 例外。
- `wx800bb867809615fd` 仅在 B 端工程出现；仓库根工程为 `wxe3315289b4e66b67`，远端知识库未检索到前者登记，正式归属待确认。
- 微信开发者工具与真机预览待确认。
