# 2026-07-26 · ScolvPet Wave1 任务与体重纠错闭环

## 目标

P0-6：任务与体重不能只 create/complete，要能**纠错**——错误任务可取消/退回待办，错误体重读数可被新记录替代。全部走审计链（原因必填，不物理删除），与 Wave1 血统纠错同一套模式。

## 服务端（上一窗口完成，本窗口收口提交）

- `POST /v1/tasks/{task_id}/cancel`、`POST /v1/tasks/{task_id}/reopen`（`i5_handlers.go`）
- 状态机：`CanCancelTask`（pending/in_progress/snoozed）、`CanReopenTask`（completed/cancelled）；
  reopen 同时清空 subject 级完成记录；事件 `CARE_TASK_CANCELLED` / reopen 事件入审计
- 体重：`WeightRecordCreateRequest` 补 `corrects_weight_record_id` + `correction_reason`，
  id 无原因 → 422（`i2_types.go`）；读取时回传纠错链（`i2_common.go`）
- OpenAPI 已补两条 task 路径与 `TaskCorrectionRequest`；conformance PASS
- 单测：`task_correction_test.go`、`i2_weight_correction_test.go`

## Flutter（本窗口）

- **共享纠错原因 sheet**：`ui/widgets/correction_reason_sheet.dart`（keyPrefix 命名空间），
  血统页原地实现重构为薄包装，widget key 保持稳定
- **任务**：Repository `cancelTask`/`reopenTask` → Controller `cancel`/`reopen` → 任务行点按弹操作表
  （开放任务「完成/取消」；已完成/已取消「退回待办」），原因必填；`CareTaskItem.canCorrect`
  镜像服务端状态机（dismissed/superseded 终态不可点）；只读成员行不可点
- **体重**：`I2WeightRecord`/`I2WeightDraft`/`buildWeightRecord`/离线草稿/真实仓储全链路补纠错字段；
  `WeightEntryPage` 纠正模式（预填原值、审计横幅、保存前强制原因、半途取消不落库）；
  详情页体重行点按进入纠正，纠错记录显示「已纠正」标记
- 测试替身 `MemoryTaskRepository`/`MemoryI2Repository` 补齐纠错语义（状态门禁、版本冲突、原因必填）

## 验证

```text
flutter analyze                                → No issues
flutter test                                   → 210 passed（新增 13：任务 7 + 体重 6）
go build/vet/test ./...                        → 全绿
node tools/check-openapi-route-conformance.mjs → PASS
```

**状态：已验证**（API 单测 + Flutter 单测 + 契约一致性）。真机与 DB E2E 待确认。

## 备注

- CORE_CODE_FREEZE 冻结域为客户预订主链/身份/幂等，本轮 i2/i5 繁育者侧纠错不在冻结清单内；
  Wave1 为冻结前已在途任务，经确认继续收口
- 并行审计（docs/29）的 P0-1 logout 修复在同一工作区，**未随本轮提交**，由审计任务自行收口

## 未做（Wave1 其余）

- 健康记录纠错入口（清洁纠错模型已有，健康记录本身没有）
- CRM 联系人编辑
- 财务冲销
- 遗传 profile 纠错
