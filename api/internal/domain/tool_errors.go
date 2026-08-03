package domain

import "fmt"

// ToolError 是助手工具链路上类型化业务错误。
// Code 为机器可读错误码（本地化文案在 httpapi 层映射），
// Params 为结构化参数（如状态值），禁止用自由文本承载语义。
type ToolError struct {
	Code   string
	Params map[string]any
}

// NewToolError 构造类型化错误；params 允许为 nil。
func NewToolError(code string, params map[string]any) *ToolError {
	if params == nil {
		params = map[string]any{}
	}
	return &ToolError{Code: code, Params: params}
}

func (e *ToolError) Error() string {
	return fmt.Sprintf("%s: %v", e.Code, e.Params)
}

// 助手工具错误码（状态类 / 业务类）。
// 新增错误一律走 code 通道；httpapi 层 code → 本地化文案。
const (
	// 任务状态不匹配（params: status）
	ErrTaskNotOpen = "task_not_open"
	// 配对记录状态不允许记录观察（params: status）
	ErrPairingNotOpenForObservation = "pairing_not_open_for_observation"
	// 仅 held 预订可确认（params: current，可选）
	ErrReservationNotHeld = "reservation_not_held"
	// 预订保留已过期
	ErrReservationHoldExpired = "reservation_hold_expired"
	// 预订状态不可取消（params: status）
	ErrReservationNotCancellable = "reservation_not_cancellable"
	// 仅 scheduled 交付可完成（params: current，可选）
	ErrHandoverNotScheduled = "handover_not_scheduled"
	// 预订状态不可安排交付
	ErrReservationNotOpenForHandover = "reservation_not_open_for_handover"
	// 预订已有关联交付
	ErrReservationAlreadyHasHandover = "reservation_already_has_handover"
	// 已归档客户不能新增预订
	ErrArchivedContactCannotReserve = "archived_contact_cannot_reserve"
	// 已归档客户不能发起交付
	ErrArchivedContactCannotHandover = "archived_contact_cannot_handover"
	// 仓鼠当前不可预订
	ErrHamsterNotReservable = "hamster_not_reservable"
	// 仓鼠已有有效预订
	ErrHamsterAlreadyReserved = "hamster_already_reserved"
	// 仓鼠不在活跃状态
	ErrHamsterNotActive = "hamster_not_active"
	// 仓鼠当前不可转移
	ErrHamsterNotTransferable = "hamster_not_transferable"
	// 交付缺少仓鼠
	ErrHandoverMissingHamster = "handover_missing_hamster"
	// 无可用品种规则
	ErrNoSpeciesRule = "no_species_rule"
	// 无指定类型模板（params: kind）
	ErrNoDocTemplate = "no_doc_template"
	// 观察时间超出配对窗口
	ErrObservedAtOutsideWindow = "observed_at_outside_pairing_window"
	// 性别取值非法
	ErrInvalidSex = "invalid_sex"
	// 没有可更新字段
	ErrNoFieldsToUpdate = "no_fields_to_update"
	// 收支类型取值非法
	ErrInvalidEntryType = "invalid_entry_type"
	// 金额不能为负
	ErrAmountNegative = "amount_cents_negative"
	// 金额必须大于 0
	ErrAmountNotPositive = "amount_cents_not_positive"
	// 单据状态取值非法
	ErrInvalidDocStatus = "invalid_doc_status"
	// 单据类型取值非法
	ErrInvalidDocKind = "invalid_doc_kind"
	// 观察类型取值非法（含 conflict 关键词，禁止走字符串嗅探）
	ErrInvalidObservationType = "invalid_observation_type"
	// 乐观锁 / 状态并发冲突，请刷新后重试（contact/reservation/handover 更新）
	ErrOperationConflict = "operation_conflict"
	// 预订关联的客户/仓鼠与操作目标不一致
	ErrReservationMismatch = "reservation_mismatch"
)
