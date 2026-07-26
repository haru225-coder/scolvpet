# 2026-07-25 · ScolvPet 繁育智能助手 Sprint 2

## 目标

在 Sprint 1 IA 重构之上：

1. **模拟结果页**可读化：可能后代 +「为什么？」说明  
2. **血统树**视觉与导航：祖代称谓、当前个体高亮、直系后代

硬约束：**不改** geneticcore / 表型表 / 基因推算逻辑，只消费权威结果做展示。

## 交付

### 模拟结果

- 结果区标题「模拟结果」；CTA「开始模拟」
- **可能后代**：毛色最可能 + 系列/品种 +（孟德尔路径）携带摘要
- **为什么？** 卡片（`buildSimulationWhyExplanation`）：
  - 父本 / 母本摘要（表型或基因型携带说明）
  - 因此：最可能后代表型 + 次级可能
  - 数据来源说明（权威表 / 历史校准 / 孟德尔）
- 各表型概率列表保留分数 fraction 展示

纯函数：`summarizeGenotypeCarries` / `buildSimulationWhyExplanation`  
文件：`features/genetic/genetic_models.dart`、`genetic_pages.dart`

### 血统树

- 标题「血统树」；关系称谓：当前个体 / 父本母本 / 爷爷奶奶外公外婆
- 当前个体节点强调（accent 底 + 更粗边）
- 连线与背景轻微品牌色
- **直系后代**区：从 edges 中 `parentId == root` 列出，点按下钻
- 纯函数：`pedigreeRelationshipLabel` / `listDirectDescendants`

文件：`features/pedigree/pedigree_models.dart`、`pedigree_pages.dart`

## 验证

```text
flutter test genetic_test pedigree_test home_overview_test widget_test
→ 24 passed
```

**状态：已验证**（单元/Widget）。真机视觉待确认。

## 未做

- Sprint 3：小程序模拟结果 / 血统展示页
- P1：个体档案区块顺序（血统 / 繁育价值前置）
- 血统树更深层 3D 布局或横向经典纸质谱系导出
