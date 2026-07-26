# 2026-07-25 · ScolvPet Wave1 血统纠错闭环

## 目标

P0-3：血统不能只 create，要能 **替换 / 解除**，并写纠错原因（审计链，不物理删除）。

## 服务端

- `CreatePedigreeParentage`：若 child+role 已有 active 边：
  - 无 `correction_reason` → `ErrDuplicate`
  - 有原因 → supersede 旧边 + insert 新边（`corrects_parentage_id` / `correction_note`）
- 新能力 `EndPedigreeParentage`：`POST /v1/pedigree-parentages/end`
- OpenAPI 已补 `correction_reason` 与 end 操作；conformance PASS
- 单测：`TestI2PedigreeReplaceAndEndRequireCorrectionReason` + 原有 cycle/graph 测试 PASS

## Flutter

- Repository：`createParentage(correctionReason?)`、`endParentage`
- Controller：`fillSlot` 支持替换；`endSlot` 解除
- UI：已填格子 → 操作表「查看 / 替换 / 解除」；替换与解除强制原因 sheet

## 验证

```text
go test ./internal/i2core -run TestI2Pedigree  → ok
node tools/check-openapi-route-conformance.mjs → PASS
flutter test test/pedigree_test.dart → 10 passed
```

**状态：已验证**（API 单测 + Flutter 单测）。真机与 DB E2E 待确认。

## 未做（Wave1 其余）

- 健康 / 体重 / 任务纠错入口
- CRM 联系人编辑
- 财务冲销
