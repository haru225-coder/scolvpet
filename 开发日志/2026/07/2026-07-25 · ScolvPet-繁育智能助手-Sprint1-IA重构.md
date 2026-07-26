# 2026-07-25 · ScolvPet 繁育智能助手 Sprint 1（IA 重构）

## 背景

产品重新定位：从「宠舍管理 SaaS / 工作台 ERP」切到「金丝熊繁育智能助手」。  
任务书：`docs/27-ScolvPet-繁育智能助手-产品重构任务书-v2.md`（仓库 `Documents/scolvpet`）。

原则：

- **不推倒重做**：保留 geneticcore / 谱系 API / 档案能力
- **禁止**改品种规则、毛色规则、基因推算逻辑
- 先砍外围第一感知，把模拟与血统推到用户脸上

## Sprint 1 交付

### 底栏

| 旧 | 新 |
|----|----|
| 工作台 | 首页 |
| 仓鼠 | 模拟 |
| 繁育 | 仓鼠 |

- 模拟 = `GeneticHubPage` 一级 Tab（长生命周期 `GeneticController`）
- 原「繁育」进度/窝次/计划 → 首页「更多工具 → 繁育进度」二级 push

### 首页「我的繁育空间」

1. **🔮 繁育模拟** 主卡（开始模拟 → 切到模拟 Tab）
2. **🧬 我的血统库**（快照内有父母关系的个体预览 → 血统档案）
3. **🐹 我的仓鼠**（个体档案列表 + 新建）
4. **📋 客户预约**（降权）
5. 更多工具：繁育进度 / 窝次 / 任务 / 笼舍（能力不删）

已退场为主内容：今日待办、经营概览、繁育动态（聚合函数仍保留给测试/二级场景）。

### 文案包装

- 遗传推算页标题 → **繁育模拟**
- 谱系页标题 → **血统档案**
- 个体档案分段「谱系」→「血统」

## 主要改动文件

- `apps/mobile/lib/features/shell/home_overview.dart`
- `apps/mobile/lib/ui/shell/home_shell.dart`
- `apps/mobile/lib/features/genetic/genetic_pages.dart`
- `apps/mobile/lib/features/pedigree/pedigree_pages.dart`
- `apps/mobile/lib/features/i2/hamster_detail_page.dart`（文案）
- 对应测试：`home_overview_test` / `widget_test` / `pedigree_test` / `today_care_queue_test`

## 验证

```text
flutter test test/home_overview_test.dart test/widget_test.dart \
  test/pedigree_test.dart test/today_care_queue_test.dart test/genetic_test.dart
→ 22 tests passed
```

**状态：已验证**（上述单元/Widget 测试）。真机 E2E 未跑，待确认。

## 未做（后续 Sprint）

| Sprint | 内容 |
|--------|------|
| 2 | 模拟结果「为什么？」说明、血统树视觉强化 |
| 3 | 小程序连接模拟结果 / 血统展示页 |
| P1 | 个体档案区块顺序：血统 / 繁育价值前置 |

## 验收对照（Sprint 1 信息架构层）

1. 能否预测配对结果？→ 首页主卡 + 底栏「模拟」✅  
2. 能否看到血统？→ 首页血统库 + 血统档案页 ✅  
3. 是否仍像管理软件？→ 经营/待办已退场；若仍偏 ERP 需 Sprint 2 视觉与结果说明加固
