# 金丝熊后代推算 — 权威核心数据

## 基准文件

- **Excel 原表（人工双重核验）**：`金丝熊后代推算整理表_双重核验版.xlsx`
- **运行时 JSON（由长表导出）**：`syrian_phenotype_table_v1.json`

本目录数据是繁殖推算的**唯一核心基准**。代码查表结果必须与此一致；任何基因型/孟德尔模型只能用于解释或扩展，不得在未通过 golden test 前覆盖表内概率。

## 内容摘要

| 系列 code | 中文名 | 无序配对组数 | 非空概率条数 |
|-----------|--------|--------------|--------------|
| poly | 波利系列 | 36 | （见 JSON） |
| chocolate | 巧克力色系 | 13 | （见 JSON） |
| **合计** | | **49** | **213** |

## 变更流程

1. 先改 Excel 并完成核验（概率合计 100%、对称、与长表一致）。
2. 重新导出 JSON（或更新导表脚本后生成）。
3. 运行 `go test ./internal/geneticcore/`，golden 必须全绿。
4.  bump `version` 字段并写开发日志。

## API

- `GET /v1/genetic/phenotype-catalog` — 系列与表型列表
- `POST /v1/genetic/simulate` — `mode=phenotype_table` + `series` + `sire_phenotype` + `dam_phenotype`
