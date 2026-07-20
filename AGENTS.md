# 熊舍管家 · Agent 约定

本文件约束在本仓库工作的人或 Agent。更完整的工程基线见 `docs/engineering/`。

## 复杂度收敛（必须遵守）

权威全文：[`docs/engineering/复杂度收敛约定.md`](docs/engineering/复杂度收敛约定.md)。

摘要：

1. **只删没有独立语义的层**（纯转发 / 1:1 映射 / 重复状态模板 / 测试 double 进生产树）。事务、权限、不变量、跨资源编排、幂等默认保留。
2. **新增 API** 默认 `handler → store/SQL`。仅当跨资源事务、复杂不变量、幂等编排或多入口复用时才加 service。禁止仅为分层完整新建 `*core`。现有 `*core` 不要求立刻拆掉，但**停止继续扩**。
3. **Flutter 新 feature** 禁止无语义 DTO 镜像（`GeneratedDto → FeatureModel → ViewModel` 空转）。优先用 `scolvpet_api` 生成类型 + extension。
4. **测试专用 `Memory*` / Fake** 放 `test/`（或 `test/support/`），不得进 `lib/`。生产可选后备适配器除外，且须有独立语义。
5. **根依赖** 用显式 `AppServices` 收束，不是 Service Locator，也不继续给 `ScolvPetApp` 加长参数列表。
6. **删层有限 promote**（`8197c48`）：只删无消费者、无业务规则、无真实调用路径的死接线。仍承载真实 API 或第二入口的 repository 默认保留。**不以 feature 五件套为单位批量砍；逐条调用链消灭空转。**
7. **现有代码不要求一次性整改；新代码必须遵守。** 迁移时发现旧代码很丑也先别顺手修。

执行顺序：冻结增长 → 清重复 → 机械拆文件 → 调用链试点 → 按证据规模化。

## 其他

- 不提交密钥与正式签名材料；凭据走环境变量。
- 正式 Bundle ID / 签名团队只改 `apps/mobile/android/mobile-identifiers.properties` 的 `SCOLVPET_APP_ID` 等约定入口，不散落。
- 平台版本与 CI 入口见 [`docs/engineering/工程平台基线.md`](docs/engineering/工程平台基线.md)。
