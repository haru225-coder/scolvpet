package httpapi

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/scolvpet/scolvpet/api/internal/domain"
	"github.com/scolvpet/scolvpet/api/internal/i2core"
	"github.com/scolvpet/scolvpet/api/internal/i3core"
	"github.com/scolvpet/scolvpet/api/internal/i5core"
)

// assistantToolSession is request-scoped context for write drafts (Slice C).
type assistantToolSession struct {
	SessionID uuid.UUID
}

// runAssistantTool executes read tools and write-draft tools with owner isolation.
func (s *Server) runAssistantTool(
	ctx context.Context,
	ownerID uuid.UUID,
	sess assistantToolSession,
	name string,
	args map[string]any,
) (any, error) {
	if s.Store == nil || s.Store.Pool == nil {
		return nil, fmt.Errorf("数据库不可用")
	}
	result, err := s.dispatchAssistantTool(ctx, ownerID, sess, name, args)
	if err != nil {
		mapped := mapAssistantToolError(err)
		// 仅未识别的未知错误（收敛为通用文案）需要告警；常见业务错误
		// 映射后用户侧可见，无需刷日志。
		if errors.Is(mapped, errOperationFailed) {
			s.Logger.Warn("assistant tool failed", "tool", name, "owner", ownerID.String(), "error", err)
		}
		return nil, mapped
	}
	return result, nil
}

// errOperationFailed 是兜底哨兵：仅真正的 unknown 错误（无 code、无已知
// 关键词、非中文文案）收敛到这里；业务/状态错误必须走 code 通道或显式映射。
var errOperationFailed = errors.New("操作失败，请稍后重试")

// toolErrorCN 把类型化错误 code 渲染为用户可见中文文案。
// params 里的状态值经 statusCN 中文化，禁止把英文原文拼进文案。
// 迁移说明：httpapi 只做 code → 本地化文案，不做任何关键词嗅探；
// containsCJK 与关键词 switch 是过渡层，迁移完成后删除。
var toolErrorCN = map[string]func(params map[string]any) string{
	domain.ErrTaskNotOpen: func(p map[string]any) string {
		return fmt.Sprintf("该任务当前为「%s」，无法执行此操作", statusCN(p["status"]))
	},
	domain.ErrPairingNotOpenForObservation: func(p map[string]any) string {
		return fmt.Sprintf("该配对记录当前为「%s」，无法记录观察", statusCN(p["status"]))
	},
	domain.ErrReservationNotHeld: func(p map[string]any) string {
		if _, ok := p["current"]; ok {
			return fmt.Sprintf("当前预订状态为「%s」，仅「已保留」的预订可以确认", statusCN(p["current"]))
		}
		return "仅「已保留」的预订可以确认"
	},
	domain.ErrReservationHoldExpired: func(map[string]any) string {
		return "预订保留已过期，请重新发起预订"
	},
	domain.ErrReservationNotCancellable: func(p map[string]any) string {
		return fmt.Sprintf("当前预订状态为「%s」，无法取消", statusCN(p["status"]))
	},
	domain.ErrHandoverNotScheduled: func(p map[string]any) string {
		if _, ok := p["current"]; ok {
			return fmt.Sprintf("当前交付状态为「%s」，仅「已排期」的交付可以完成", statusCN(p["current"]))
		}
		return "仅「已排期」的交付可以完成"
	},
	domain.ErrReservationNotOpenForHandover: func(p map[string]any) string {
		return fmt.Sprintf("当前预订状态为「%s」，无法安排交付", statusCN(p["current"]))
	},
	domain.ErrReservationAlreadyHasHandover: func(map[string]any) string {
		return "该预订已有关联交付记录"
	},
	domain.ErrArchivedContactCannotReserve: func(map[string]any) string {
		return "已归档客户不能新增预订"
	},
	domain.ErrArchivedContactCannotHandover: func(map[string]any) string {
		return "已归档客户不能发起交付"
	},
	domain.ErrHamsterNotReservable: func(map[string]any) string {
		return "该仓鼠当前不可预订"
	},
	domain.ErrHamsterAlreadyReserved: func(map[string]any) string {
		return "该仓鼠已有有效预订"
	},
	domain.ErrHamsterNotActive: func(map[string]any) string {
		return "该仓鼠不在活跃状态"
	},
	domain.ErrHamsterNotTransferable: func(map[string]any) string {
		return "该仓鼠当前不可转移"
	},
	domain.ErrHandoverMissingHamster: func(map[string]any) string {
		return "交付记录缺少仓鼠信息"
	},
	domain.ErrNoSpeciesRule: func(map[string]any) string {
		return "未配置可用的品种规则"
	},
	domain.ErrNoDocTemplate: func(p map[string]any) string {
		return fmt.Sprintf("暂无「%s」模板，请先在 App 创建", kindCN(p["kind"]))
	},
	domain.ErrObservedAtOutsideWindow: func(map[string]any) string {
		return "观察时间超出配对窗口"
	},
	domain.ErrInvalidSex: func(map[string]any) string {
		return "性别必须为「公 / 母 / 未定」"
	},
	domain.ErrNoFieldsToUpdate: func(map[string]any) string {
		return "没有可更新的字段"
	},
	domain.ErrInvalidEntryType: func(map[string]any) string {
		return "收支类型必须为「收入 / 支出」"
	},
	domain.ErrAmountNegative: func(map[string]any) string {
		return "金额不能为负数"
	},
	domain.ErrAmountNotPositive: func(map[string]any) string {
		return "金额必须大于 0"
	},
	domain.ErrInvalidDocStatus: func(map[string]any) string {
		return "单据状态必须为「草稿 / 已签发 / 已撤销」"
	},
	domain.ErrInvalidDocKind: func(map[string]any) string {
		return "单据类型必须为「合同 / 回执」"
	},
	domain.ErrInvalidObservationType: func(map[string]any) string {
		return "观察类型必须为「接触 / 追逐 / 冲突 / 交配 / 已分离 / 其他」"
	},
	domain.ErrOperationConflict: func(map[string]any) string {
		return "操作冲突，数据已被他人修改，请刷新后再试"
	},
	domain.ErrReservationMismatch: func(map[string]any) string {
		return "预订关联的客户或仓鼠与本次操作不一致"
	},
}

// statusCN 把数据库枚举状态值翻译为中文展示；未知值回退「未知状态」，
// 避免把英文原文透给用户。
func statusCN(v any) string {
	switch s, _ := v.(string); s {
	case "pending":
		return "待处理"
	case "in_progress":
		return "进行中"
	case "completed":
		return "已完成"
	case "snoozed":
		return "已顺延"
	case "cancelled", "canceled":
		return "已取消"
	case "superseded":
		return "已替代"
	case "held":
		return "已保留"
	case "confirmed":
		return "已确认"
	case "handed_over":
		return "已交付"
	case "scheduled":
		return "已排期"
	case "lead":
		return "潜在客户"
	case "active":
		return "进行中"
	case "archived":
		return "已归档"
	case "transferred":
		return "已转移"
	case "retired":
		return "已退役"
	case "deceased":
		return "已离世"
	case "separated":
		return "已分离"
	case "safety_hold":
		return "安全保留"
	case "expired":
		return "已过期"
	case "draft":
		return "草稿"
	case "issued":
		return "已签发"
	case "revoked":
		return "已撤销"
	default:
		return "未知状态"
	}
}

// kindCN 把文档模板类型翻译为中文。
func kindCN(v any) string {
	switch k, _ := v.(string); k {
	case "contract":
		return "合同"
	case "receipt":
		return "回执"
	default:
		return "未知类型"
	}
}

func mapAssistantToolError(err error) error {
	if err == nil {
		return nil
	}
	// 类型化错误优先：code → 中文文案（含结构化状态参数）。
	var toolErr *domain.ToolError
	if errors.As(err, &toolErr) {
		if render, ok := toolErrorCN[toolErr.Code]; ok {
			return errors.New(render(toolErr.Params))
		}
		// 未注册的 code：不应出现；收敛为兜底（runAssistantTool 会 Warn 原始错误）。
		return errOperationFailed
	}
	msg := err.Error()
	// 过渡层：已含中文的文案（含内嵌数据的中文模板）视为用户友好，直接保留——
	// 放在 switch 之前，避免中文模板内嵌的英文关键词（如查询词恰为
	// "conflict"）被误映射改写。「英文模板+中文数据」的误判场景已由
	// 源头中文化（resolveOpenTaskForComplete）消除。
	if containsCJK(msg) {
		return err
	}
	// 过渡层：常见英文错误关键词映射为用户友好中文（存量错误迁移
	// 到 code 通道后删除）。不拼接英文原文——验收要求 C 端无英文原文。
	switch {
	case strings.Contains(msg, "not found"):
		return fmt.Errorf("找不到对应记录，请检查名称或编号后重试")
	case strings.Contains(msg, "session required"):
		return fmt.Errorf("写操作需要有效会话，请重新打开助手后再试")
	case strings.Contains(msg, "required"):
		return fmt.Errorf("缺少必要参数，请补充完整后再试")
	case strings.Contains(msg, "invalid"):
		return fmt.Errorf("参数无效，请检查输入后重试")
	case strings.Contains(msg, "conflict"):
		return fmt.Errorf("操作冲突，请刷新后再试")
	case strings.Contains(msg, "unknown tool"):
		return fmt.Errorf("不支持的工具，请换个说法重试")
	case strings.Contains(msg, "unsupported action"):
		return fmt.Errorf("不支持的确认动作")
	}
	// 未知英文错误不把内部细节透给用户（原始错误已记录到服务端日志）。
	return errOperationFailed
}

// containsCJK reports whether s contains any CJK unified ideograph (U+4E00–U+9FFF).
func containsCJK(s string) bool {
	for _, r := range s {
		if r >= 0x4E00 && r <= 0x9FFF {
			return true
		}
	}
	return false
}

func (s *Server) dispatchAssistantTool(
	ctx context.Context,
	ownerID uuid.UUID,
	sess assistantToolSession,
	name string,
	args map[string]any,
) (any, error) {
	switch name {
	case "get_overview":
		snap, err := s.loadAssistantSnapshot(ctx, ownerID)
		if err != nil {
			return nil, err
		}
		return map[string]any{
			"organization_name": snap.OrganizationName,
			"active_hamsters":   snap.ActiveHamsters,
			"enclosures":        snap.Enclosures,
			"active_litters":    snap.ActiveLitters,
			"open_tasks":        snap.OpenTasks,
			"overdue_tasks":     snap.OverdueTasks,
			"gestating_plans":   snap.GestatingPlans,
			"media_bytes":       snap.MediaBytes,
			"plan_code":         snap.PlanCode,
		}, nil
	case "search_hamsters":
		return s.toolSearchHamsters(ctx, ownerID, args)
	case "list_tasks":
		return s.toolListTasks(ctx, ownerID, args)
	case "list_enclosures":
		return s.toolListEnclosures(ctx, ownerID, args)
	case "list_breeding_plans":
		return s.toolListBreedingPlans(ctx, ownerID, args)
	case "get_breeding_plan":
		return s.toolGetBreedingPlan(ctx, ownerID, args)
	case "list_pairing_attempts":
		return s.toolListPairingAttempts(ctx, ownerID, args)
	case "list_litters":
		return s.toolListLitters(ctx, ownerID, args)
	case "get_hamster":
		return s.toolGetHamster(ctx, ownerID, args)
	case "list_crm_contacts":
		return s.toolListCrmContacts(ctx, ownerID, args)
	case "get_crm_contact":
		return s.toolGetCrmContact(ctx, ownerID, args)
	case "list_crm_reservations":
		return s.toolListCrmReservations(ctx, ownerID, args)
	case "get_crm_reservation":
		return s.toolGetCrmReservation(ctx, ownerID, args)
	case "list_crm_handovers":
		return s.toolListCrmHandovers(ctx, ownerID, args)
	case "get_crm_handover":
		return s.toolGetCrmHandover(ctx, ownerID, args)
	case "list_accounting_summary":
		return s.toolListAccountingSummary(ctx, ownerID, args)
	case "list_accounting_records":
		return s.toolListAccountingRecords(ctx, ownerID, args)
	case "search_docs":
		return s.toolSearchDocs(ctx, ownerID, args)
	case "get_doc":
		return s.toolGetDoc(ctx, ownerID, args)
	case "list_doc_templates":
		return s.toolListDocTemplates(ctx, ownerID, args)
	case "list_recent_weights":
		return s.toolListRecentWeights(ctx, ownerID, args)
	case "list_health_records":
		return s.toolListHealthRecords(ctx, ownerID, args)
	case "create_task":
		return s.toolDraftCreateTask(ctx, ownerID, sess, args)
	case "complete_task":
		return s.toolDraftCompleteTask(ctx, ownerID, sess, args)
	case "create_weight_record":
		return s.toolDraftCreateWeight(ctx, ownerID, sess, args)
	case "create_hamster":
		return s.toolDraftCreateHamster(ctx, ownerID, sess, args)
	case "update_hamster":
		return s.toolDraftUpdateHamster(ctx, ownerID, sess, args)
	case "create_enclosure":
		return s.toolDraftCreateEnclosure(ctx, ownerID, sess, args)
	case "create_crm_contact":
		return s.toolDraftCreateCrmContact(ctx, ownerID, sess, args)
	case "update_crm_contact":
		return s.toolDraftUpdateCrmContact(ctx, ownerID, sess, args)
	case "create_crm_reservation":
		return s.toolDraftCreateCrmReservation(ctx, ownerID, sess, args)
	case "confirm_crm_reservation":
		return s.toolDraftConfirmCrmReservation(ctx, ownerID, sess, args)
	case "cancel_crm_reservation":
		return s.toolDraftCancelCrmReservation(ctx, ownerID, sess, args)
	case "create_crm_handover":
		return s.toolDraftCreateCrmHandover(ctx, ownerID, sess, args)
	case "complete_crm_handover":
		return s.toolDraftCompleteCrmHandover(ctx, ownerID, sess, args)
	case "create_accounting_record":
		return s.toolDraftCreateAccountingRecord(ctx, ownerID, sess, args)
	case "create_health_record":
		return s.toolDraftCreateHealthRecord(ctx, ownerID, sess, args)
	case "record_pairing_observation":
		return s.toolDraftRecordPairingObservation(ctx, ownerID, sess, args)
	case "create_separation_task":
		return s.toolDraftCreateSeparationTask(ctx, ownerID, sess, args)
	case "create_contract":
		return s.toolDraftCreateContract(ctx, ownerID, sess, args)
	case "create_receipt":
		return s.toolDraftCreateReceipt(ctx, ownerID, sess, args)
	default:
		return nil, fmt.Errorf("unknown tool %s", name)
	}
}

func (s *Server) toolDraftCreateTask(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
	if sess.SessionID == uuid.Nil {
		return nil, fmt.Errorf("session required for write draft")
	}
	targetType := stringArgMap(args, "target_type")
	targetIDStr := stringArgMap(args, "target_id")
	title := stringArgMap(args, "title")
	if targetType == "" || targetIDStr == "" || title == "" {
		return nil, fmt.Errorf("target_type, target_id, title required")
	}
	targetID, err := uuid.Parse(targetIDStr)
	if err != nil {
		return nil, fmt.Errorf("invalid target_id")
	}
	taskType := stringArgMap(args, "task_type")
	if taskType == "" {
		taskType = "custom"
	}
	priority := stringArgMap(args, "priority")
	if priority == "" {
		priority = "normal"
	}
	scheduledAt := time.Now().UTC().Add(time.Hour)
	if raw := stringArgMap(args, "scheduled_at"); raw != "" {
		if parsed, err := time.Parse(time.RFC3339, raw); err == nil {
			scheduledAt = parsed.UTC()
		}
	}
	payload := map[string]any{
		"task_type": taskType, "target_type": targetType, "target_id": targetID.String(),
		"title": title, "scheduled_at": scheduledAt.Format(time.RFC3339), "priority": priority,
	}
	if notes := stringArgMap(args, "notes"); notes != "" {
		payload["notes"] = notes
	}
	// ownership probe for hamster/enclosure targets
	if targetType == "hamster" {
		var n int
		_ = s.Store.Pool.QueryRow(ctx, `SELECT count(*) FROM hamster WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL`, ownerID, targetID).Scan(&n)
		if n == 0 {
			return nil, fmt.Errorf("hamster not found")
		}
	}
	summary := fmt.Sprintf("创建任务「%s」→ %s %s @ %s", title, targetType, targetID.String()[:8], scheduledAt.Format(time.RFC3339))
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "create_task", "确认创建任务", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "create_task",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}

func (s *Server) toolDraftCompleteTask(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
	if sess.SessionID == uuid.Nil {
		return nil, fmt.Errorf("session required for write draft")
	}
	taskID, title, status, err := s.resolveOpenTaskForComplete(ctx, ownerID, args)
	if err != nil {
		return nil, err
	}
	if status != "pending" && status != "in_progress" && status != "snoozed" {
		return nil, domain.NewToolError(domain.ErrTaskNotOpen, map[string]any{"status": status})
	}
	payload := map[string]any{"task_id": taskID.String(), "title": title, "current_status": status}
	summary := fmt.Sprintf("完成任务「%s」(%s)", firstNonEmptyName(title, taskID.String()[:8]), taskID.String()[:8])
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "complete_task", "确认完成任务", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "complete_task",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}

// resolveOpenTaskForComplete picks a task by task_id, or by unique open-title query.
func (s *Server) resolveOpenTaskForComplete(ctx context.Context, ownerID uuid.UUID, args map[string]any) (uuid.UUID, string, string, error) {
	if raw := stringArgMap(args, "task_id"); raw != "" {
		taskID, err := uuid.Parse(raw)
		if err != nil {
			return uuid.Nil, "", "", fmt.Errorf("invalid task_id")
		}
		var title, status string
		err = s.Store.Pool.QueryRow(ctx, `
			SELECT COALESCE(title,''), status::text FROM care_task WHERE owner_id=$1 AND id=$2
		`, ownerID, taskID).Scan(&title, &status)
		if err != nil {
			return uuid.Nil, "", "", fmt.Errorf("task not found")
		}
		return taskID, title, status, nil
	}
	q := stringArgMap(args, "query")
	if q == "" {
		return uuid.Nil, "", "", fmt.Errorf("task_id or query required")
	}
	rows, err := s.Store.Pool.Query(ctx, `
		SELECT id, COALESCE(title,''), status::text
		FROM care_task
		WHERE owner_id=$1
		  AND status IN ('pending','in_progress','snoozed')
		  AND (COALESCE(title,'') ILIKE $2 OR task_type::text ILIKE $2)
		ORDER BY scheduled_at ASC NULLS LAST
		LIMIT 5
	`, ownerID, "%"+q+"%")
	if err != nil {
		return uuid.Nil, "", "", err
	}
	defer rows.Close()
	type hit struct {
		id     uuid.UUID
		title  string
		status string
	}
	hits := make([]hit, 0, 5)
	for rows.Next() {
		var h hit
		if err := rows.Scan(&h.id, &h.title, &h.status); err != nil {
			return uuid.Nil, "", "", err
		}
		hits = append(hits, h)
	}
	if err := rows.Err(); err != nil {
		return uuid.Nil, "", "", err
	}
	if len(hits) == 0 {
		return uuid.Nil, "", "", fmt.Errorf("没有匹配的未完成任务（查询词：%s），可先 list_tasks 查看全部任务", q)
	}
	if len(hits) > 1 {
		// Prefer exact title match if unique.
		exact := make([]hit, 0)
		for _, h := range hits {
			if strings.EqualFold(h.title, q) {
				exact = append(exact, h)
			}
		}
		if len(exact) == 1 {
			return exact[0].id, exact[0].title, exact[0].status, nil
		}
		return uuid.Nil, "", "", fmt.Errorf("查询词「%s」匹配到 %d 个未完成任务，请先 list_tasks 再 complete_task(task_id)", q, len(hits))
	}
	return hits[0].id, hits[0].title, hits[0].status, nil
}

func (s *Server) toolDraftCreateWeight(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
	if sess.SessionID == uuid.Nil {
		return nil, fmt.Errorf("session required for write draft")
	}
	hamsterID, err := uuid.Parse(stringArgMap(args, "hamster_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid hamster_id")
	}
	var name string
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT COALESCE(name,'') FROM hamster WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
	`, ownerID, hamsterID).Scan(&name)
	if err != nil {
		return nil, fmt.Errorf("hamster not found")
	}
	weightG, ok := args["weight_g"].(float64)
	if !ok || weightG <= 0 || weightG > 5000 {
		return nil, fmt.Errorf("invalid weight_g")
	}
	recordedAt := time.Now().UTC()
	if raw := stringArgMap(args, "recorded_at"); raw != "" {
		if parsed, err := time.Parse(time.RFC3339, raw); err == nil {
			recordedAt = parsed.UTC()
		}
	}
	payload := map[string]any{
		"hamster_id": hamsterID.String(), "weight_g": weightG,
		"recorded_at": recordedAt.Format(time.RFC3339), "name": name,
	}
	summary := fmt.Sprintf("登记 %s 体重 %.1fg @ %s", firstNonEmptyName(name, hamsterID.String()[:8]), weightG, recordedAt.Format(time.RFC3339))
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "create_weight_record", "确认登记体重", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "create_weight_record",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}

func stringArgMap(args map[string]any, key string) string {
	v, ok := args[key]
	if !ok {
		return ""
	}
	s, _ := v.(string)
	return strings.TrimSpace(s)
}

func firstNonEmptyName(values ...string) string {
	for _, v := range values {
		if strings.TrimSpace(v) != "" {
			return strings.TrimSpace(v)
		}
	}
	return ""
}

func (s *Server) toolDraftCreateHamster(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
	if sess.SessionID == uuid.Nil {
		return nil, fmt.Errorf("session required for write draft")
	}
	code := stringArgMap(args, "internal_code")
	if code == "" {
		return nil, fmt.Errorf("internal_code required")
	}
	name := stringArgMap(args, "name")
	sex := stringArgMap(args, "sex")
	if sex == "" {
		sex = "unknown"
	}
	if sex != "male" && sex != "female" && sex != "unknown" {
		return nil, domain.NewToolError(domain.ErrInvalidSex, nil)
	}
	ruleID, err := s.resolveDefaultSpeciesRule(ctx, ownerID, stringArgMap(args, "species_rule_version_id"))
	if err != nil {
		return nil, err
	}
	payload := map[string]any{
		"internal_code": code, "sex": sex,
		"species_rule_version_id": ruleID.String(),
	}
	if name != "" {
		payload["name"] = name
	}
	if notes := stringArgMap(args, "notes"); notes != "" {
		payload["notes"] = notes
	}
	labelName := firstNonEmptyName(name, code)
	summary := fmt.Sprintf("新建仓鼠「%s」编号 %s 性别 %s", labelName, code, sex)
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "create_hamster", "确认新建仓鼠", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "create_hamster",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}

func (s *Server) toolDraftUpdateHamster(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
	if sess.SessionID == uuid.Nil {
		return nil, fmt.Errorf("session required for write draft")
	}
	hamsterID, err := uuid.Parse(stringArgMap(args, "hamster_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid hamster_id")
	}
	var name, code string
	var version int
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT COALESCE(name,''), internal_code, version
		FROM hamster WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
	`, ownerID, hamsterID).Scan(&name, &code, &version)
	if err != nil {
		return nil, fmt.Errorf("hamster not found")
	}
	payload := map[string]any{
		"hamster_id": hamsterID.String(), "expected_version": version,
		"current_name": name, "internal_code": code,
	}
	changed := make([]string, 0, 3)
	if v := stringArgMap(args, "name"); v != "" {
		payload["name"] = v
		changed = append(changed, "name="+v)
	}
	if v := stringArgMap(args, "sex"); v != "" {
		if v != "male" && v != "female" && v != "unknown" {
			return nil, domain.NewToolError(domain.ErrInvalidSex, nil)
		}
		payload["sex"] = v
		changed = append(changed, "sex="+v)
	}
	if v := stringArgMap(args, "notes"); v != "" {
		payload["notes"] = v
		changed = append(changed, "notes")
	}
	if len(changed) == 0 {
		return nil, domain.NewToolError(domain.ErrNoFieldsToUpdate, nil)
	}
	summary := fmt.Sprintf("更新仓鼠 %s：%s", firstNonEmptyName(name, code), strings.Join(changed, ", "))
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "update_hamster", "确认更新仓鼠", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "update_hamster",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}

func (s *Server) toolDraftCreateEnclosure(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
	if sess.SessionID == uuid.Nil {
		return nil, fmt.Errorf("session required for write draft")
	}
	code := stringArgMap(args, "code")
	if code == "" {
		return nil, fmt.Errorf("code required")
	}
	capacity := 1
	if v, ok := args["capacity"].(float64); ok {
		capacity = int(v)
	}
	if capacity < 1 {
		capacity = 1
	}
	if capacity > 20 {
		capacity = 20
	}
	payload := map[string]any{"code": code, "capacity": capacity}
	summary := fmt.Sprintf("新建笼盒「%s」容量 %d", code, capacity)
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "create_enclosure", "确认新建笼盒", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "create_enclosure",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}

func (s *Server) resolveDefaultSpeciesRule(ctx context.Context, ownerID uuid.UUID, explicit string) (uuid.UUID, error) {
	if explicit != "" {
		id, err := uuid.Parse(explicit)
		if err != nil {
			return uuid.Nil, fmt.Errorf("invalid species_rule_version_id")
		}
		return id, nil
	}
	var id uuid.UUID
	err := s.Store.Pool.QueryRow(ctx, `
		SELECT id FROM species_rule_version
		WHERE (owner_id=$1 OR scope='system') AND status IN ('published','draft')
		ORDER BY CASE WHEN owner_id=$1 THEN 0 ELSE 1 END,
		         CASE WHEN status='published' THEN 0 ELSE 1 END,
		         version_no DESC NULLS LAST, created_at DESC
		LIMIT 1
	`, ownerID).Scan(&id)
	if err != nil {
		// last resort any system rule
		err = s.Store.Pool.QueryRow(ctx, `
			SELECT id FROM species_rule_version WHERE scope='system' ORDER BY created_at DESC LIMIT 1
		`).Scan(&id)
		if err != nil {
			return uuid.Nil, domain.NewToolError(domain.ErrNoSpeciesRule, nil)
		}
	}
	return id, nil
}

func (s *Server) executeAssistantAction(ctx context.Context, ownerID uuid.UUID, actionType string, payload map[string]any) (any, error) {
	switch actionType {
	case "create_task", "create_separation_task":
		return s.executeCreateTask(ctx, ownerID, payload)
	case "complete_task":
		return s.executeCompleteTask(ctx, ownerID, payload)
	case "create_weight_record":
		return s.executeCreateWeight(ctx, ownerID, payload)
	case "create_hamster":
		return s.executeCreateHamster(ctx, ownerID, payload)
	case "update_hamster":
		return s.executeUpdateHamster(ctx, ownerID, payload)
	case "create_enclosure":
		return s.executeCreateEnclosure(ctx, ownerID, payload)
	case "create_crm_contact":
		return s.executeCreateCrmContact(ctx, ownerID, payload)
	case "update_crm_contact":
		return s.executeUpdateCrmContact(ctx, ownerID, payload)
	case "create_crm_reservation":
		return s.executeCreateCrmReservation(ctx, ownerID, payload)
	case "confirm_crm_reservation":
		return s.executeConfirmCrmReservation(ctx, ownerID, payload)
	case "cancel_crm_reservation":
		return s.executeCancelCrmReservation(ctx, ownerID, payload)
	case "create_crm_handover":
		return s.executeCreateCrmHandover(ctx, ownerID, payload)
	case "complete_crm_handover":
		return s.executeCompleteCrmHandover(ctx, ownerID, payload)
	case "create_accounting_record":
		return s.executeCreateAccountingRecord(ctx, ownerID, payload)
	case "create_health_record":
		return s.executeCreateHealthRecord(ctx, ownerID, payload)
	case "record_pairing_observation":
		return s.executeRecordPairingObservation(ctx, ownerID, payload)
	case "create_contract":
		return s.executeCreateContract(ctx, ownerID, payload)
	case "create_receipt":
		return s.executeCreateReceipt(ctx, ownerID, payload)
	default:
		return nil, fmt.Errorf("unsupported action type %s", actionType)
	}
}

func (s *Server) executeRecordPairingObservation(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (any, error) {
	attemptID, err := uuid.Parse(stringArgMap(payload, "attempt_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid attempt_id")
	}
	obsType := stringArgMap(payload, "type")
	switch obsType {
	case "contact", "chase", "conflict", "mating", "separated", "other":
	default:
		return nil, domain.NewToolError(domain.ErrInvalidObservationType, nil)
	}
	// Load current version for optimistic concurrency (If-Match equivalent).
	var version int
	var status string
	var startedAt, deadline time.Time
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT version, status::text, started_at, separation_deadline
		FROM pairing_attempt
		WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
	`, ownerID, attemptID).Scan(&version, &status, &startedAt, &deadline)
	if err != nil {
		return nil, fmt.Errorf("pairing attempt not found")
	}
	if status != "active" && status != "safety_hold" {
		return nil, domain.NewToolError(domain.ErrPairingNotOpenForObservation, map[string]any{"status": status})
	}
	observedAt := time.Now().UTC()
	if raw := stringArgMap(payload, "observed_at"); raw != "" {
		if parsed, parseErr := time.Parse(time.RFC3339, raw); parseErr == nil {
			observedAt = parsed.UTC()
		}
	}
	if observedAt.Before(startedAt) || observedAt.After(deadline) {
		// Clamp to window rather than hard-fail for slightly skewed client clocks near now.
		if time.Since(observedAt).Abs() < 2*time.Minute {
			if observedAt.Before(startedAt) {
				observedAt = startedAt
			}
			if observedAt.After(deadline) {
				observedAt = deadline
			}
		} else {
			return nil, domain.NewToolError(domain.ErrObservedAtOutsideWindow, nil)
		}
	}
	input := i3core.RecordObservationInput{
		ExpectedVersion: version,
		ObservedAt:      observedAt,
		Type:            obsType,
	}
	if notes := stringArgMap(payload, "notes"); notes != "" {
		input.Notes = &notes
	}
	if sev := stringArgMap(payload, "severity"); sev != "" {
		switch sev {
		case "info", "low", "medium", "high", "critical":
			input.Severity = &sev
		default:
			return nil, fmt.Errorf("invalid severity")
		}
	}
	if v, ok := payload["duration_seconds"]; ok {
		switch n := v.(type) {
		case float64:
			d := int(n)
			if d < 0 {
				return nil, fmt.Errorf("invalid duration_seconds")
			}
			input.DurationSeconds = &d
		case int:
			if n < 0 {
				return nil, fmt.Errorf("invalid duration_seconds")
			}
			input.DurationSeconds = &n
		}
	}
	tx, err := s.Store.Pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	idem := "assistant-obs-" + uuid.NewString()
	observation, newVersion, baseline, err := s.i3CoreService().RecordObservationTx(ctx, tx, ownerID, attemptID, input, idem)
	if err != nil {
		return nil, err
	}
	if err := tx.Commit(ctx); err != nil {
		return nil, err
	}
	out := map[string]any{
		"observation_id":          observation.ID.String(),
		"attempt_id":              attemptID.String(),
		"type":                    obsType,
		"observed_at":             observedAt.Format(time.RFC3339),
		"pairing_attempt_version": newVersion,
	}
	if baseline != nil {
		out["baseline_candidate_at"] = baseline.UTC().Format(time.RFC3339)
	}
	return out, nil
}

func (s *Server) resolveDocTemplateID(ctx context.Context, ownerID uuid.UUID, kind, explicit string) (uuid.UUID, string, error) {
	if explicit != "" {
		id, err := uuid.Parse(explicit)
		if err != nil {
			return uuid.Nil, "", fmt.Errorf("invalid template_id")
		}
		tpl, err := s.getDocTemplate(ctx, ownerID, id, kind)
		if err != nil {
			return uuid.Nil, "", fmt.Errorf("template not found")
		}
		return tpl.ID, tpl.Name, nil
	}
	var id uuid.UUID
	var name string
	err := s.Store.Pool.QueryRow(ctx, `
		SELECT id, name FROM doc_template
		WHERE owner_id=$1 AND kind=$2::doc_template_kind
		ORDER BY updated_at DESC, id DESC
		LIMIT 1
	`, ownerID, kind).Scan(&id, &name)
	if err != nil {
		return uuid.Nil, "", domain.NewToolError(domain.ErrNoDocTemplate, map[string]any{"kind": kind})
	}
	return id, name, nil
}

func (s *Server) bindAssistantDocParties(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (documentPartyBound, error) {
	contactRaw := stringArgMap(payload, "contact_id")
	reservationRaw := stringArgMap(payload, "reservation_id")
	handoverRaw := stringArgMap(payload, "handover_id")
	if contactRaw == "" && reservationRaw == "" && handoverRaw == "" {
		return documentPartyBound{}, fmt.Errorf("contact_id, reservation_id, or handover_id required")
	}
	var contactID *string
	if contactRaw != "" {
		if _, err := uuid.Parse(contactRaw); err != nil {
			return documentPartyBound{}, fmt.Errorf("invalid contact_id")
		}
		contactID = &contactRaw
	}
	var reservationID *uuid.UUID
	if reservationRaw != "" {
		id, err := uuid.Parse(reservationRaw)
		if err != nil {
			return documentPartyBound{}, fmt.Errorf("invalid reservation_id")
		}
		reservationID = &id
	}
	var handoverID *uuid.UUID
	if handoverRaw != "" {
		id, err := uuid.Parse(handoverRaw)
		if err != nil {
			return documentPartyBound{}, fmt.Errorf("invalid handover_id")
		}
		handoverID = &id
	}
	return s.bindDocumentParties(ctx, ownerID, documentPartyInput{
		ReservationID: reservationID,
		ContactID:     contactID,
		HandoverID:    handoverID,
	})
}

func (s *Server) executeCreateContract(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (any, error) {
	templateID, templateName, err := s.resolveDocTemplateID(ctx, ownerID, "contract", stringArgMap(payload, "template_id"))
	if err != nil {
		return nil, err
	}
	tpl, err := s.getDocTemplate(ctx, ownerID, templateID, "contract")
	if err != nil {
		return nil, fmt.Errorf("template not found")
	}
	bound, err := s.bindAssistantDocParties(ctx, ownerID, payload)
	if err != nil {
		return nil, err
	}
	title := stringArgMap(payload, "title")
	if title == "" {
		if bound.HamsterName != "" {
			title = "交接协议 · " + bound.HamsterName
		} else {
			title = templateName
			if title == "" {
				title = tpl.Name
			}
		}
	}
	notes := stringArgMap(payload, "notes")
	var notesPtr *string
	if notes != "" {
		notesPtr = &notes
	}
	filled := fillDocTemplate(tpl.Body, map[string]string{
		"contact_name": bound.ContactName,
		"title":        title,
		"hamster_name": bound.HamsterName,
		"amount":       "",
		"date":         time.Now().In(time.Local).Format("2006-01-02"),
		"notes":        notes,
	})
	orgID, err := s.currentOrganizationID(ctx, ownerID)
	if err != nil {
		return nil, err
	}
	var id uuid.UUID
	err = s.Store.Pool.QueryRow(ctx, `
		INSERT INTO doc_document (
			owner_id, organization_id, template_id, kind, contact_id, handover_id, reservation_id,
			title, body_filled, currency, notes
		) VALUES ($1,$2,$3,'contract',$4,$5,$6,$7,$8,'CNY',$9)
		RETURNING id
	`, ownerID, orgID, templateID, bound.ContactID, bound.HandoverID, bound.ReservationID, title, filled, notesPtr).Scan(&id)
	if err != nil {
		return nil, err
	}
	out := map[string]any{
		"document_id": id.String(), "kind": "contract", "title": title, "status": "draft",
		"template_id": templateID.String(), "contact_name": bound.ContactName,
	}
	if bound.ContactID != nil {
		out["contact_id"] = bound.ContactID.String()
	}
	return out, nil
}

func (s *Server) executeCreateReceipt(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (any, error) {
	amountCents := int64(0)
	switch v := payload["amount_cents"].(type) {
	case float64:
		amountCents = int64(v)
	case int:
		amountCents = int64(v)
	case int64:
		amountCents = v
	default:
		return nil, fmt.Errorf("invalid amount_cents")
	}
	if amountCents < 0 {
		return nil, domain.NewToolError(domain.ErrAmountNegative, nil)
	}
	currency := stringArgMap(payload, "currency")
	if currency == "" {
		currency = "CNY"
	}
	templateID, templateName, err := s.resolveDocTemplateID(ctx, ownerID, "receipt", stringArgMap(payload, "template_id"))
	if err != nil {
		return nil, err
	}
	tpl, err := s.getDocTemplate(ctx, ownerID, templateID, "receipt")
	if err != nil {
		return nil, fmt.Errorf("template not found")
	}
	bound, err := s.bindAssistantDocParties(ctx, ownerID, payload)
	if err != nil {
		return nil, err
	}
	title := stringArgMap(payload, "title")
	if title == "" {
		if bound.HamsterName != "" {
			title = "收款回执 · " + bound.HamsterName
		} else {
			title = templateName
			if title == "" {
				title = tpl.Name
			}
		}
	}
	notes := stringArgMap(payload, "notes")
	var notesPtr *string
	if notes != "" {
		notesPtr = &notes
	}
	amountYuan := fmt.Sprintf("%.2f", float64(amountCents)/100.0)
	filled := fillDocTemplate(tpl.Body, map[string]string{
		"contact_name": bound.ContactName,
		"title":        title,
		"hamster_name": bound.HamsterName,
		"amount":       amountYuan + " " + currency,
		"date":         time.Now().In(time.Local).Format("2006-01-02"),
		"notes":        notes,
	})
	orgID, err := s.currentOrganizationID(ctx, ownerID)
	if err != nil {
		return nil, err
	}
	var id uuid.UUID
	err = s.Store.Pool.QueryRow(ctx, `
		INSERT INTO doc_document (
			owner_id, organization_id, template_id, kind, contact_id, handover_id, reservation_id,
			title, body_filled, amount_cents, currency, notes
		) VALUES ($1,$2,$3,'receipt',$4,$5,$6,$7,$8,$9,$10,$11)
		RETURNING id
	`, ownerID, orgID, templateID, bound.ContactID, bound.HandoverID, bound.ReservationID, title, filled, amountCents, currency, notesPtr).Scan(&id)
	if err != nil {
		return nil, err
	}
	out := map[string]any{
		"document_id": id.String(), "kind": "receipt", "title": title, "status": "draft",
		"amount_cents": amountCents, "currency": currency,
		"template_id": templateID.String(), "contact_name": bound.ContactName,
	}
	if bound.ContactID != nil {
		out["contact_id"] = bound.ContactID.String()
	}
	return out, nil
}

func (s *Server) executeCreateCrmContact(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (any, error) {
	name := stringArgMap(payload, "name")
	if name == "" {
		return nil, fmt.Errorf("name required")
	}
	status := stringArgMap(payload, "status")
	if status == "" {
		status = "lead"
	}
	orgID, err := s.currentOrganizationID(ctx, ownerID)
	if err != nil {
		return nil, err
	}
	phone := stringArgMap(payload, "phone")
	wechat := stringArgMap(payload, "wechat")
	notes := stringArgMap(payload, "notes")
	var id uuid.UUID
	err = s.Store.Pool.QueryRow(ctx, `
		INSERT INTO crm_contact (owner_id, organization_id, name, phone, wechat, notes, status)
		VALUES ($1,$2,$3,NULLIF($4,''),NULLIF($5,''),NULLIF($6,''),$7::crm_contact_status)
		RETURNING id
	`, ownerID, orgID, name, phone, wechat, notes, status).Scan(&id)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"contact_id": id.String(),
		"name":       name,
		"status":     status,
	}, nil
}

func (s *Server) executeUpdateCrmContact(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (any, error) {
	contactID, err := uuid.Parse(stringArgMap(payload, "contact_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid contact_id")
	}
	var curName, curPhone, curWechat, curNotes, curStatus string
	var version int
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT name, COALESCE(phone,''), COALESCE(wechat,''), COALESCE(notes,''), status::text, version
		FROM crm_contact WHERE owner_id=$1 AND id=$2
	`, ownerID, contactID).Scan(&curName, &curPhone, &curWechat, &curNotes, &curStatus, &version)
	if err != nil {
		return nil, fmt.Errorf("contact not found")
	}
	name := curName
	phone := curPhone
	wechat := curWechat
	notes := curNotes
	status := curStatus
	if v, ok := payload["name"]; ok {
		if s, _ := v.(string); strings.TrimSpace(s) != "" {
			name = strings.TrimSpace(s)
		}
	}
	if _, ok := payload["phone"]; ok {
		phone = stringArgMap(payload, "phone")
	}
	if _, ok := payload["wechat"]; ok {
		wechat = stringArgMap(payload, "wechat")
	}
	if _, ok := payload["notes"]; ok {
		notes = stringArgMap(payload, "notes")
	}
	if v := stringArgMap(payload, "status"); v != "" {
		if v != "lead" && v != "active" && v != "archived" {
			return nil, fmt.Errorf("invalid status")
		}
		status = v
	}
	tag, err := s.Store.Pool.Exec(ctx, `
		UPDATE crm_contact
		SET name=$3, phone=NULLIF($4,''), wechat=NULLIF($5,''), notes=NULLIF($6,''),
		    status=$7::crm_contact_status, version=version+1, updated_at=now()
		WHERE owner_id=$1 AND id=$2 AND version=$8
	`, ownerID, contactID, name, phone, wechat, notes, status, version)
	if err != nil {
		return nil, err
	}
	if tag.RowsAffected() != 1 {
		return nil, domain.NewToolError(domain.ErrOperationConflict, nil)
	}
	return map[string]any{
		"contact_id": contactID.String(),
		"name":       name,
		"phone":      phone,
		"wechat":     wechat,
		"status":     status,
	}, nil
}

func (s *Server) executeCreateCrmReservation(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (any, error) {
	contactID, err := uuid.Parse(stringArgMap(payload, "contact_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid contact_id")
	}
	var contactStatus, contactName string
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT status::text, name FROM crm_contact WHERE owner_id=$1 AND id=$2
	`, ownerID, contactID).Scan(&contactStatus, &contactName)
	if err != nil {
		return nil, fmt.Errorf("contact not found")
	}
	if contactStatus == "archived" {
		return nil, domain.NewToolError(domain.ErrArchivedContactCannotReserve, nil)
	}
	title := stringArgMap(payload, "title")
	if title == "" {
		title = "预订"
	}
	notes := stringArgMap(payload, "notes")
	var hamsterID *uuid.UUID
	if raw := stringArgMap(payload, "hamster_id"); raw != "" {
		hid, parseErr := uuid.Parse(raw)
		if parseErr != nil {
			return nil, fmt.Errorf("invalid hamster_id")
		}
		var lifecycle string
		err = s.Store.Pool.QueryRow(ctx, `
			SELECT lifecycle_status::text FROM hamster
			WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
		`, ownerID, hid).Scan(&lifecycle)
		if err != nil {
			return nil, fmt.Errorf("hamster not found")
		}
		if lifecycle != "active" {
			return nil, domain.NewToolError(domain.ErrHamsterNotReservable, nil)
		}
		var open bool
		err = s.Store.Pool.QueryRow(ctx, `
			SELECT EXISTS(
				SELECT 1 FROM crm_reservation
				WHERE owner_id=$1 AND hamster_id=$2
				  AND (
				    status = 'confirmed'
				    OR (status = 'held' AND (hold_expires_at IS NULL OR hold_expires_at > now()))
				  )
			)
		`, ownerID, hid).Scan(&open)
		if err != nil {
			return nil, err
		}
		if open {
			return nil, domain.NewToolError(domain.ErrHamsterAlreadyReserved, nil)
		}
		hamsterID = &hid
	}
	orgID, err := s.currentOrganizationID(ctx, ownerID)
	if err != nil {
		return nil, err
	}
	holdExpires := time.Now().UTC().Add(30 * time.Minute)
	var id uuid.UUID
	err = s.Store.Pool.QueryRow(ctx, `
		INSERT INTO crm_reservation (
			owner_id, organization_id, contact_id, hamster_id, title, status, notes, hold_expires_at
		) VALUES ($1,$2,$3,$4,$5,'held',NULLIF($6,''),$7)
		RETURNING id
	`, ownerID, orgID, contactID, hamsterID, title, notes, holdExpires).Scan(&id)
	if err != nil {
		return nil, err
	}
	out := map[string]any{
		"reservation_id": id.String(),
		"contact_id":     contactID.String(),
		"contact_name":   contactName,
		"title":          title,
		"status":         "held",
	}
	if hamsterID != nil {
		out["hamster_id"] = hamsterID.String()
	}
	return out, nil
}

func (s *Server) executeCreateCrmHandover(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (any, error) {
	contactID, err := uuid.Parse(stringArgMap(payload, "contact_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid contact_id")
	}
	var contactStatus string
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT status::text FROM crm_contact WHERE owner_id=$1 AND id=$2
	`, ownerID, contactID).Scan(&contactStatus)
	if err != nil {
		return nil, fmt.Errorf("contact not found")
	}
	if contactStatus == "archived" {
		return nil, domain.NewToolError(domain.ErrArchivedContactCannotHandover, nil)
	}
	var reservationID *uuid.UUID
	var hamsterID *uuid.UUID
	if raw := stringArgMap(payload, "reservation_id"); raw != "" {
		rid, parseErr := uuid.Parse(raw)
		if parseErr != nil {
			return nil, fmt.Errorf("invalid reservation_id")
		}
		var resContact uuid.UUID
		var resHamster *uuid.UUID
		var resStatus string
		err = s.Store.Pool.QueryRow(ctx, `
			SELECT contact_id, hamster_id, status::text
			FROM crm_reservation WHERE owner_id=$1 AND id=$2
		`, ownerID, rid).Scan(&resContact, &resHamster, &resStatus)
		if err != nil {
			return nil, fmt.Errorf("reservation not found")
		}
		if resContact != contactID {
			return nil, domain.NewToolError(domain.ErrReservationMismatch, nil)
		}
		if resStatus != "held" && resStatus != "confirmed" {
			return nil, domain.NewToolError(domain.ErrReservationNotOpenForHandover, map[string]any{"current": resStatus})
		}
		var exists bool
		err = s.Store.Pool.QueryRow(ctx, `
			SELECT EXISTS(
				SELECT 1 FROM crm_handover
				WHERE owner_id=$1 AND reservation_id=$2 AND status <> 'cancelled'
			)
		`, ownerID, rid).Scan(&exists)
		if err != nil {
			return nil, err
		}
		if exists {
			return nil, domain.NewToolError(domain.ErrReservationAlreadyHasHandover, nil)
		}
		reservationID = &rid
		hamsterID = resHamster
	}
	if raw := stringArgMap(payload, "hamster_id"); raw != "" {
		hid, parseErr := uuid.Parse(raw)
		if parseErr != nil {
			return nil, fmt.Errorf("invalid hamster_id")
		}
		hamsterID = &hid
	}
	if hamsterID == nil {
		return nil, fmt.Errorf("hamster_id required (or via reservation)")
	}
	var lifecycle string
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT lifecycle_status::text FROM hamster
		WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
	`, ownerID, *hamsterID).Scan(&lifecycle)
	if err != nil {
		return nil, fmt.Errorf("hamster not found")
	}
	if lifecycle != "active" {
		return nil, domain.NewToolError(domain.ErrHamsterNotActive, nil)
	}
	scheduledAt := time.Now().UTC()
	if raw := stringArgMap(payload, "scheduled_at"); raw != "" {
		if parsed, parseErr := time.Parse(time.RFC3339, raw); parseErr == nil {
			scheduledAt = parsed.UTC()
		}
	}
	notes := stringArgMap(payload, "notes")
	orgID, err := s.currentOrganizationID(ctx, ownerID)
	if err != nil {
		return nil, err
	}
	var id uuid.UUID
	err = s.Store.Pool.QueryRow(ctx, `
		INSERT INTO crm_handover (
			owner_id, organization_id, contact_id, reservation_id, hamster_id, status, scheduled_at, notes
		) VALUES ($1,$2,$3,$4,$5,'scheduled',$6,NULLIF($7,''))
		RETURNING id
	`, ownerID, orgID, contactID, reservationID, hamsterID, scheduledAt, notes).Scan(&id)
	if err != nil {
		return nil, err
	}
	out := map[string]any{
		"handover_id":  id.String(),
		"contact_id":   contactID.String(),
		"hamster_id":   hamsterID.String(),
		"status":       "scheduled",
		"scheduled_at": scheduledAt.Format(time.RFC3339),
	}
	if reservationID != nil {
		out["reservation_id"] = reservationID.String()
	}
	return out, nil
}

func (s *Server) executeCreateAccountingRecord(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (any, error) {
	entryType := stringArgMap(payload, "entry_type")
	if entryType != "income" && entryType != "expense" {
		return nil, domain.NewToolError(domain.ErrInvalidEntryType, nil)
	}
	amountCents := int64(0)
	switch v := payload["amount_cents"].(type) {
	case float64:
		amountCents = int64(v)
	case int:
		amountCents = int64(v)
	case int64:
		amountCents = v
	default:
		return nil, fmt.Errorf("invalid amount_cents")
	}
	if amountCents <= 0 {
		return nil, domain.NewToolError(domain.ErrAmountNotPositive, nil)
	}
	title := stringArgMap(payload, "title")
	if title == "" {
		return nil, fmt.Errorf("title required")
	}
	currency := stringArgMap(payload, "currency")
	if currency == "" {
		currency = "CNY"
	}
	notes := stringArgMap(payload, "notes")
	var contactID *uuid.UUID
	if raw := stringArgMap(payload, "contact_id"); raw != "" {
		cid, parseErr := uuid.Parse(raw)
		if parseErr != nil {
			return nil, fmt.Errorf("invalid contact_id")
		}
		var n int
		err := s.Store.Pool.QueryRow(ctx, `
			SELECT count(*) FROM crm_contact WHERE owner_id=$1 AND id=$2
		`, ownerID, cid).Scan(&n)
		if err != nil || n == 0 {
			return nil, fmt.Errorf("contact not found")
		}
		contactID = &cid
	}
	occurredAt := time.Now().UTC()
	if raw := stringArgMap(payload, "occurred_at"); raw != "" {
		if parsed, err := time.Parse(time.RFC3339, raw); err == nil {
			occurredAt = parsed.UTC()
		} else if parsed, err := time.ParseInLocation("2006-01-02", raw, time.Local); err == nil {
			occurredAt = parsed.UTC()
		}
	}
	orgID, err := s.currentOrganizationID(ctx, ownerID)
	if err != nil {
		return nil, err
	}
	var id uuid.UUID
	err = s.Store.Pool.QueryRow(ctx, `
		INSERT INTO accounting_record (
			owner_id, organization_id, category_id, entry_type, amount_cents, currency,
			title, notes, contact_id, occurred_at
		) VALUES ($1,$2,NULL,$3::accounting_entry_type,$4,$5,$6,NULLIF($7,''),$8,$9)
		RETURNING id
	`, ownerID, orgID, entryType, amountCents, currency, title, notes, contactID, occurredAt).Scan(&id)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"record_id":    id.String(),
		"entry_type":   entryType,
		"amount_cents": amountCents,
		"title":        title,
		"currency":     currency,
		"occurred_at":  occurredAt.Format(time.RFC3339),
	}, nil
}

func (s *Server) executeCreateHealthRecord(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (any, error) {
	hamsterID, err := uuid.Parse(stringArgMap(payload, "hamster_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid hamster_id")
	}
	var n int
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT count(*) FROM hamster WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
	`, ownerID, hamsterID).Scan(&n)
	if err != nil || n == 0 {
		return nil, fmt.Errorf("hamster not found")
	}
	recType := stringArgMap(payload, "type")
	switch recType {
	case "daily_check", "anomaly", "medication", "follow_up", "isolation", "death":
	default:
		return nil, fmt.Errorf("invalid health record type")
	}
	observedAt := time.Now().UTC()
	if raw := stringArgMap(payload, "observed_at"); raw != "" {
		if parsed, parseErr := time.Parse(time.RFC3339, raw); parseErr == nil {
			observedAt = parsed.UTC()
		}
	}
	input := i5core.CreateHealthRecordInput{
		HamsterID:  &hamsterID,
		Type:       recType,
		ObservedAt: observedAt,
	}
	if notes := stringArgMap(payload, "notes"); notes != "" {
		input.Notes = &notes
	}
	if sev := stringArgMap(payload, "severity"); sev != "" {
		switch sev {
		case "info", "low", "medium", "high", "critical":
			input.Severity = &sev
		default:
			return nil, fmt.Errorf("invalid severity")
		}
	}
	idem := "assistant-health-" + uuid.NewString()
	result, err := s.i5CoreService().CreateHealthRecord(ctx, ownerID, i5core.WriteOptions{
		IdempotencyKey: idem, RequestMethod: "POST", RequestPath: "/v1/assistant/actions/confirm",
	}, input)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"health_record_id": result.Value.ID.String(),
		"hamster_id":       hamsterID.String(),
		"type":             recType,
		"observed_at":      observedAt.Format(time.RFC3339),
	}, nil
}

func (s *Server) executeConfirmCrmReservation(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (any, error) {
	reservationID, err := uuid.Parse(stringArgMap(payload, "reservation_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid reservation_id")
	}
	var title, status string
	var version int
	var holdExpires *time.Time
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT title, status::text, version, hold_expires_at
		FROM crm_reservation WHERE owner_id=$1 AND id=$2
	`, ownerID, reservationID).Scan(&title, &status, &version, &holdExpires)
	if err != nil {
		return nil, fmt.Errorf("reservation not found")
	}
	if status != "held" {
		return nil, domain.NewToolError(domain.ErrReservationNotHeld, nil)
	}
	if holdExpires != nil && !holdExpires.After(time.Now().UTC()) {
		return nil, domain.NewToolError(domain.ErrReservationHoldExpired, nil)
	}
	tag, err := s.Store.Pool.Exec(ctx, `
		UPDATE crm_reservation
		SET status='confirmed'::crm_reservation_status, version=version+1, updated_at=now()
		WHERE owner_id=$1 AND id=$2 AND version=$3 AND status='held'
	`, ownerID, reservationID, version)
	if err != nil {
		return nil, err
	}
	if tag.RowsAffected() != 1 {
		return nil, domain.NewToolError(domain.ErrOperationConflict, nil)
	}
	return map[string]any{
		"reservation_id": reservationID.String(),
		"title":          title,
		"status":         "confirmed",
	}, nil
}

func (s *Server) executeCancelCrmReservation(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (any, error) {
	reservationID, err := uuid.Parse(stringArgMap(payload, "reservation_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid reservation_id")
	}
	var title, status string
	var version int
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT title, status::text, version
		FROM crm_reservation WHERE owner_id=$1 AND id=$2
	`, ownerID, reservationID).Scan(&title, &status, &version)
	if err != nil {
		return nil, fmt.Errorf("reservation not found")
	}
	if status != "held" && status != "confirmed" {
		return nil, domain.NewToolError(domain.ErrReservationNotCancellable, map[string]any{"status": status})
	}
	tag, err := s.Store.Pool.Exec(ctx, `
		UPDATE crm_reservation
		SET status='cancelled'::crm_reservation_status, version=version+1, updated_at=now()
		WHERE owner_id=$1 AND id=$2 AND version=$3 AND status IN ('held','confirmed')
	`, ownerID, reservationID, version)
	if err != nil {
		return nil, err
	}
	if tag.RowsAffected() != 1 {
		return nil, domain.NewToolError(domain.ErrOperationConflict, nil)
	}
	return map[string]any{
		"reservation_id": reservationID.String(),
		"title":          title,
		"status":         "cancelled",
		"previous":       status,
	}, nil
}

func (s *Server) executeCompleteCrmHandover(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (any, error) {
	handoverID, err := uuid.Parse(stringArgMap(payload, "handover_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid handover_id")
	}
	tx, err := s.Store.Pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)

	current, err := getCrmHandoverTx(ctx, tx, ownerID, handoverID, true)
	if err != nil {
		return nil, fmt.Errorf("handover not found")
	}
	if current.Status != "scheduled" {
		return nil, domain.NewToolError(domain.ErrHandoverNotScheduled, nil)
	}
	if current.HamsterID == nil {
		return nil, domain.NewToolError(domain.ErrHandoverMissingHamster, nil)
	}
	if current.Reservation != nil {
		reservation, err := getCrmReservationTx(ctx, tx, ownerID, *current.Reservation, true)
		if err != nil {
			return nil, fmt.Errorf("reservation not found")
		}
		if reservation.Status != "confirmed" || reservation.ContactID != current.ContactID ||
			reservation.HamsterID == nil || *reservation.HamsterID != *current.HamsterID {
			return nil, domain.NewToolError(domain.ErrReservationMismatch, nil)
		}
		tag, err := tx.Exec(ctx, `
			UPDATE crm_reservation
			SET status='handed_over', version=version+1, updated_at=now()
			WHERE owner_id=$1 AND id=$2 AND version=$3 AND status='confirmed'
		`, ownerID, reservation.ID, reservation.Version)
		if err != nil {
			return nil, err
		}
		if tag.RowsAffected() != 1 {
			return nil, domain.NewToolError(domain.ErrOperationConflict, nil)
		}
	}
	tag, err := tx.Exec(ctx, `
		UPDATE hamster
		SET lifecycle_status='transferred', version=version+1, updated_at=now()
		WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL AND lifecycle_status='active'
	`, ownerID, *current.HamsterID)
	if err != nil {
		return nil, err
	}
	if tag.RowsAffected() != 1 {
		return nil, domain.NewToolError(domain.ErrHamsterNotTransferable, nil)
	}
	tag, err = tx.Exec(ctx, `
		UPDATE crm_handover
		SET status='completed', completed_at=now(), version=version+1, updated_at=now()
		WHERE owner_id=$1 AND id=$2 AND version=$3 AND status='scheduled'
	`, ownerID, handoverID, current.Version)
	if err != nil {
		return nil, err
	}
	if tag.RowsAffected() != 1 {
		return nil, domain.NewToolError(domain.ErrOperationConflict, nil)
	}
	if _, err := tx.Exec(ctx, `
		UPDATE crm_contact
		SET status='active', version=version+1, updated_at=now()
		WHERE owner_id=$1 AND id=$2 AND status='lead'
	`, ownerID, current.ContactID); err != nil {
		return nil, err
	}
	if err := insertHandoverIncomeIfNeeded(ctx, tx, ownerID, current); err != nil {
		return nil, err
	}
	if err := tx.Commit(ctx); err != nil {
		return nil, err
	}
	return map[string]any{
		"handover_id": handoverID.String(),
		"status":      "completed",
		"hamster_id":  current.HamsterID.String(),
		"contact_id":  current.ContactID.String(),
	}, nil
}

func (s *Server) executeCreateHamster(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (any, error) {
	code := stringArgMap(payload, "internal_code")
	ruleID, err := uuid.Parse(stringArgMap(payload, "species_rule_version_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid species_rule_version_id")
	}
	sex := stringArgMap(payload, "sex")
	if sex == "" {
		sex = "unknown"
	}
	input := i2core.CreateHamsterInput{
		InternalCode:         code,
		SpeciesRuleVersionID: ruleID,
		Sex:                  sex,
		SourceType:           "introduced",
	}
	if name := stringArgMap(payload, "name"); name != "" {
		input.Name = &name
	}
	if notes := stringArgMap(payload, "notes"); notes != "" {
		input.Notes = &notes
	}
	idem := "assistant-create-hamster-" + uuid.NewString()
	result, err := s.i2CoreService().CreateHamster(ctx, ownerID, i2core.WriteOptions{
		IdempotencyKey: idem, RequestMethod: "POST", RequestPath: "/v1/assistant/actions/confirm",
	}, input)
	if err != nil {
		return nil, err
	}
	outName := ""
	if result.Value.Name != nil {
		outName = *result.Value.Name
	}
	return map[string]any{
		"hamster_id":    result.Value.ID.String(),
		"internal_code": result.Value.InternalCode,
		"name":          outName,
	}, nil
}

func (s *Server) executeUpdateHamster(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (any, error) {
	hamsterID, err := uuid.Parse(stringArgMap(payload, "hamster_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid hamster_id")
	}
	version := 0
	switch v := payload["expected_version"].(type) {
	case float64:
		version = int(v)
	case int:
		version = v
	}
	if version < 1 {
		return nil, fmt.Errorf("invalid expected_version")
	}
	input := i2core.UpdateHamsterInput{ExpectedVersion: version}
	if name := stringArgMap(payload, "name"); name != "" {
		input.Name = &name
	}
	if sex := stringArgMap(payload, "sex"); sex != "" {
		input.Sex = &sex
	}
	if notes := stringArgMap(payload, "notes"); notes != "" {
		input.Notes = &notes
	}
	idem := "assistant-update-hamster-" + uuid.NewString()
	result, err := s.i2CoreService().UpdateHamster(ctx, ownerID, hamsterID, i2core.WriteOptions{
		IdempotencyKey: idem, RequestMethod: "PATCH", RequestPath: "/v1/assistant/actions/confirm",
	}, input)
	if err != nil {
		return nil, err
	}
	outName := ""
	if result.Value.Name != nil {
		outName = *result.Value.Name
	}
	return map[string]any{
		"hamster_id": result.Value.ID.String(),
		"name":       outName,
		"version":    result.Value.Version,
	}, nil
}

func (s *Server) executeCreateEnclosure(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (any, error) {
	code := stringArgMap(payload, "code")
	capacity := 1
	if v, ok := payload["capacity"].(float64); ok {
		capacity = int(v)
	}
	if capacity < 1 {
		capacity = 1
	}
	input := i2core.CreateEnclosureInput{
		Code: code, Capacity: capacity, State: "vacant", Cleanliness: "clean",
	}
	idem := "assistant-create-enclosure-" + uuid.NewString()
	result, err := s.i2CoreService().CreateEnclosure(ctx, ownerID, i2core.WriteOptions{
		IdempotencyKey: idem, RequestMethod: "POST", RequestPath: "/v1/assistant/actions/confirm",
	}, input)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"enclosure_id": result.Value.ID.String(),
		"code":         result.Value.Code,
		"capacity":     result.Value.Capacity,
	}, nil
}

func (s *Server) executeCreateTask(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (any, error) {
	targetID, err := uuid.Parse(stringArgMap(payload, "target_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid target_id")
	}
	title := stringArgMap(payload, "title")
	taskType := stringArgMap(payload, "task_type")
	if taskType == "" {
		taskType = "custom"
	}
	targetType := stringArgMap(payload, "target_type")
	priority := stringArgMap(payload, "priority")
	if priority == "" {
		priority = "normal"
	}
	scheduledAt := time.Now().UTC().Add(time.Hour)
	if raw := stringArgMap(payload, "scheduled_at"); raw != "" {
		if parsed, err := time.Parse(time.RFC3339, raw); err == nil {
			scheduledAt = parsed.UTC()
		}
	}
	var titlePtr *string
	if title != "" {
		titlePtr = &title
	}
	var notesPtr *string
	if notes := stringArgMap(payload, "notes"); notes != "" {
		notesPtr = &notes
	}
	input := i5core.CreateCareTaskInput{
		TaskType: taskType, TargetType: targetType, TargetID: targetID,
		Title: titlePtr, ScheduledAt: scheduledAt, Priority: priority, Notes: notesPtr,
	}
	idem := "assistant-create-task-" + uuid.NewString()
	result, err := s.i5CoreService().CreateTask(ctx, ownerID, i5core.WriteOptions{
		IdempotencyKey: idem, RequestMethod: "POST", RequestPath: "/v1/assistant/actions/confirm",
	}, input)
	if err != nil {
		return nil, err
	}
	titleOut := ""
	if result.Value.Title != nil {
		titleOut = *result.Value.Title
	}
	return map[string]any{
		"task_id": result.Value.ID.String(),
		"title":   titleOut,
		"state":   result.Value.State,
	}, nil
}

func (s *Server) executeCompleteTask(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (any, error) {
	taskID, err := uuid.Parse(stringArgMap(payload, "task_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid task_id")
	}
	task, err := s.i5CoreService().GetTask(ctx, ownerID, taskID)
	if err != nil {
		return nil, err
	}
	subjectResults := make([]i5core.TaskSubjectResult, 0, len(task.SubjectIDs))
	for _, sid := range task.SubjectIDs {
		subjectResults = append(subjectResults, i5core.TaskSubjectResult{
			SubjectID: sid, Status: "completed",
		})
	}
	if len(subjectResults) == 0 {
		// fallback: complete against target itself
		subjectResults = []i5core.TaskSubjectResult{{SubjectID: task.TargetID, Status: "completed"}}
	}
	idem := "assistant-complete-task-" + uuid.NewString()
	result, err := s.i5CoreService().CompleteTask(ctx, ownerID, taskID, i5core.WriteOptions{
		IdempotencyKey: idem, RequestMethod: "POST", RequestPath: "/v1/assistant/actions/confirm",
	}, i5core.CompleteTaskInput{
		ExpectedVersion: task.Version,
		CompletedAt:     time.Now().UTC(),
		SubjectResults:  subjectResults,
	})
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"task_id":     result.Value.Task.ID.String(),
		"state":       result.Value.Task.State,
		"auto_closed": result.Value.AutoClosed,
	}, nil
}

func (s *Server) executeCreateWeight(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (any, error) {
	hamsterID, err := uuid.Parse(stringArgMap(payload, "hamster_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid hamster_id")
	}
	weightG, ok := payload["weight_g"].(float64)
	if !ok {
		return nil, fmt.Errorf("invalid weight_g")
	}
	recordedAt := time.Now().UTC()
	if raw := stringArgMap(payload, "recorded_at"); raw != "" {
		if parsed, err := time.Parse(time.RFC3339, raw); err == nil {
			recordedAt = parsed.UTC()
		}
	}
	input := i2core.CreateWeightInput{
		SubjectType:     "hamster",
		HamsterID:       &hamsterID,
		MeasurementKind: "individual",
		WeightG:         weightG,
		RecordedAt:      recordedAt,
		Source:          "manual",
	}
	idem := "assistant-weight-" + uuid.NewString()
	result, err := s.i2CoreService().CreateWeight(ctx, ownerID, i2core.WriteOptions{
		IdempotencyKey: idem, RequestMethod: "POST", RequestPath: "/v1/assistant/actions/confirm",
	}, input)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"weight_record_id": result.Value.ID.String(),
		"weight_g":         result.Value.WeightG,
	}, nil
}

func toolLimit(args map[string]any, def, min, max int) int {
	limit := def
	if v, ok := args["limit"].(float64); ok {
		limit = int(v)
	}
	if limit < min {
		return min
	}
	if limit > max {
		return max
	}
	return limit
}

func (s *Server) toolSearchHamsters(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	q := ""
	if v, ok := args["query"].(string); ok {
		q = strings.TrimSpace(v)
	}
	limit := toolLimit(args, 10, 1, 20)
	var (
		query string
		qargs []any
	)
	if q == "" {
		query = `
			SELECT id::text, COALESCE(name,''), COALESCE(internal_code,''), sex::text,
			       lifecycle_status::text, current_enclosure_id::text
			FROM hamster
			WHERE owner_id=$1 AND deleted_at IS NULL
			ORDER BY updated_at DESC
			LIMIT $2`
		qargs = []any{ownerID, limit}
	} else {
		query = `
			SELECT id::text, COALESCE(name,''), COALESCE(internal_code,''), sex::text,
			       lifecycle_status::text, current_enclosure_id::text
			FROM hamster
			WHERE owner_id=$1 AND deleted_at IS NULL
			  AND (name ILIKE $2 OR internal_code ILIKE $2)
			ORDER BY updated_at DESC
			LIMIT $3`
		qargs = []any{ownerID, "%" + q + "%", limit}
	}
	rows, err := s.Store.Pool.Query(ctx, query, qargs...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]map[string]any, 0)
	for rows.Next() {
		var id, name, code, sex, status string
		var enclosure *string
		if err := rows.Scan(&id, &name, &code, &sex, &status, &enclosure); err != nil {
			return nil, err
		}
		item := map[string]any{
			"id": id, "name": name, "internal_code": code,
			"sex": sex, "lifecycle_status": status,
		}
		if enclosure != nil {
			item["current_enclosure_id"] = *enclosure
		}
		out = append(out, item)
	}
	return map[string]any{"count": len(out), "hamsters": out}, rows.Err()
}

func (s *Server) toolListTasks(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	limit := toolLimit(args, 15, 1, 30)
	overdueOnly, _ := args["overdue_only"].(bool)
	q := stringArgMap(args, "query")
	sql := `
		SELECT id::text, task_type::text, COALESCE(title,''),
		       status::text, scheduled_at, priority::text,
		       target_type::text, target_id::text
		FROM care_task
		WHERE owner_id=$1
		  AND status IN ('pending','in_progress','snoozed')
	`
	qargs := []any{ownerID}
	argN := 2
	if overdueOnly {
		sql += ` AND scheduled_at < now()`
	}
	if q != "" {
		sql += fmt.Sprintf(` AND (COALESCE(title,'') ILIKE $%d OR task_type::text ILIKE $%d)`, argN, argN)
		qargs = append(qargs, "%"+q+"%")
		argN++
	}
	sql += fmt.Sprintf(` ORDER BY scheduled_at ASC NULLS LAST LIMIT $%d`, argN)
	qargs = append(qargs, limit)
	rows, err := s.Store.Pool.Query(ctx, sql, qargs...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]map[string]any, 0)
	now := time.Now().UTC()
	for rows.Next() {
		var id, taskType, title, status, priority, targetType, targetID string
		var scheduled time.Time
		if err := rows.Scan(&id, &taskType, &title, &status, &scheduled, &priority, &targetType, &targetID); err != nil {
			return nil, err
		}
		item := map[string]any{
			"id": id, "task_type": taskType, "title": title,
			"status": status, "scheduled_at": scheduled, "priority": priority,
			"target_type": targetType, "target_id": targetID,
			"overdue": scheduled.Before(now),
		}
		out = append(out, item)
	}
	return map[string]any{"count": len(out), "tasks": out}, rows.Err()
}

func (s *Server) toolListEnclosures(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	limit := toolLimit(args, 20, 1, 30)
	rows, err := s.Store.Pool.Query(ctx, `
		SELECT id::text, COALESCE(code,''), state::text,
		       cleanliness::text, COALESCE(capacity,0)
		FROM enclosure
		WHERE owner_id=$1 AND deleted_at IS NULL
		ORDER BY updated_at DESC
		LIMIT $2
	`, ownerID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]map[string]any, 0)
	for rows.Next() {
		var id, code, state, clean string
		var capacity int
		if err := rows.Scan(&id, &code, &state, &clean, &capacity); err != nil {
			return nil, err
		}
		out = append(out, map[string]any{
			"id": id, "code": code, "state": state,
			"cleanliness": clean, "capacity": capacity,
		})
	}
	return map[string]any{"count": len(out), "enclosures": out}, rows.Err()
}

func (s *Server) toolListBreedingPlans(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	limit := toolLimit(args, 15, 1, 20)
	state := stringArgMap(args, "state")
	query := `
		SELECT p.id::text, p.state::text, COALESCE(p.name,''),
		       p.planned_pairing_at, p.mating_baseline_at,
		       p.expected_birth_start, p.expected_birth_end,
		       p.sire_id::text, p.dam_id::text,
		       COALESCE(NULLIF(sire.name,''), sire.internal_code, ''),
		       COALESCE(NULLIF(dam.name,''), dam.internal_code, ''),
		       p.created_at
		FROM breeding_plan p
		LEFT JOIN hamster sire ON sire.owner_id=p.owner_id AND sire.id=p.sire_id AND sire.deleted_at IS NULL
		LEFT JOIN hamster dam ON dam.owner_id=p.owner_id AND dam.id=p.dam_id AND dam.deleted_at IS NULL
		WHERE p.owner_id=$1 AND p.deleted_at IS NULL`
	qargs := []any{ownerID}
	if state != "" {
		query += ` AND p.state::text=$2`
		qargs = append(qargs, state)
		query += ` ORDER BY p.updated_at DESC LIMIT $3`
		qargs = append(qargs, limit)
	} else {
		query += ` ORDER BY p.updated_at DESC LIMIT $2`
		qargs = append(qargs, limit)
	}
	rows, err := s.Store.Pool.Query(ctx, query, qargs...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]map[string]any, 0)
	now := time.Now().UTC()
	for rows.Next() {
		var id, st, name, sireID, damID, sireName, damName string
		var pairing, baseline, birthStart, birthEnd, created any
		if err := rows.Scan(&id, &st, &name, &pairing, &baseline, &birthStart, &birthEnd, &sireID, &damID, &sireName, &damName, &created); err != nil {
			return nil, err
		}
		item := map[string]any{
			"id": id, "state": st, "name": name,
			"sire_id": sireID, "dam_id": damID,
			"sire_name": sireName, "dam_name": damName,
			"created_at": created,
		}
		if pairing != nil {
			item["planned_pairing_at"] = pairing
		}
		if baseline != nil {
			item["mating_baseline_at"] = baseline
		}
		if birthStart != nil {
			item["expected_birth_start"] = birthStart
		}
		if birthEnd != nil {
			item["expected_birth_end"] = birthEnd
		}
		// Hint if currently inside expected birth window.
		if bs, ok := birthStart.(time.Time); ok {
			if be, ok2 := birthEnd.(time.Time); ok2 {
				item["in_birth_window"] = !now.Before(bs) && !now.After(be)
			}
		}
		out = append(out, item)
	}
	return map[string]any{"count": len(out), "plans": out}, rows.Err()
}

func (s *Server) toolGetBreedingPlan(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	planID, err := uuid.Parse(stringArgMap(args, "plan_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid plan_id")
	}
	var (
		id, state, name, sireID, damID, sireName, damName string
		pairing, baseline, birthStart, birthEnd, actualBirth, created any
		activeAttempt, litterID *string
		notes *string
	)
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT p.id::text, p.state::text, COALESCE(p.name,''),
		       p.planned_pairing_at, p.mating_baseline_at,
		       p.expected_birth_start, p.expected_birth_end, p.actual_birth_at,
		       p.sire_id::text, p.dam_id::text,
		       COALESCE(NULLIF(sire.name,''), sire.internal_code, ''),
		       COALESCE(NULLIF(dam.name,''), dam.internal_code, ''),
		       p.notes, p.created_at,
		       (SELECT pa.id::text FROM pairing_attempt pa
		         WHERE pa.owner_id=p.owner_id AND pa.breeding_plan_id=p.id
		           AND pa.status IN ('active','safety_hold') AND pa.deleted_at IS NULL
		         ORDER BY pa.attempt_no DESC LIMIT 1),
		       (SELECT l.id::text FROM litter l
		         WHERE l.owner_id=p.owner_id AND l.breeding_plan_id=p.id
		           AND l.state <> 'voided' AND l.deleted_at IS NULL
		         ORDER BY l.created_at DESC LIMIT 1)
		FROM breeding_plan p
		LEFT JOIN hamster sire ON sire.owner_id=p.owner_id AND sire.id=p.sire_id AND sire.deleted_at IS NULL
		LEFT JOIN hamster dam ON dam.owner_id=p.owner_id AND dam.id=p.dam_id AND dam.deleted_at IS NULL
		WHERE p.owner_id=$1 AND p.id=$2 AND p.deleted_at IS NULL
	`, ownerID, planID).Scan(
		&id, &state, &name, &pairing, &baseline, &birthStart, &birthEnd, &actualBirth,
		&sireID, &damID, &sireName, &damName, &notes, &created, &activeAttempt, &litterID,
	)
	if err != nil {
		return nil, fmt.Errorf("breeding plan not found")
	}
	item := map[string]any{
		"id": id, "state": state, "name": name,
		"sire_id": sireID, "dam_id": damID,
		"sire_name": sireName, "dam_name": damName,
		"created_at": created,
	}
	if pairing != nil {
		item["planned_pairing_at"] = pairing
	}
	if baseline != nil {
		item["mating_baseline_at"] = baseline
	}
	if birthStart != nil {
		item["expected_birth_start"] = birthStart
	}
	if birthEnd != nil {
		item["expected_birth_end"] = birthEnd
	}
	if actualBirth != nil {
		item["actual_birth_at"] = actualBirth
	}
	if notes != nil && *notes != "" {
		item["notes"] = *notes
	}
	if activeAttempt != nil {
		item["active_pairing_attempt_id"] = *activeAttempt
	}
	if litterID != nil {
		item["litter_id"] = *litterID
	}
	now := time.Now().UTC()
	if bs, ok := birthStart.(time.Time); ok {
		if be, ok2 := birthEnd.(time.Time); ok2 {
			item["in_birth_window"] = !now.Before(bs) && !now.After(be)
			if now.Before(bs) {
				item["days_to_birth_window"] = int(bs.Sub(now).Hours() / 24)
			}
		}
	}
	return item, nil
}

func (s *Server) toolListPairingAttempts(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	limit := toolLimit(args, 15, 1, 20)
	status := stringArgMap(args, "status")
	planRaw := stringArgMap(args, "plan_id")
	query := `
		SELECT pa.id::text, pa.breeding_plan_id::text, pa.attempt_no, pa.status::text,
		       COALESCE(pa.result::text,''), pa.started_at, pa.separated_at, pa.separation_deadline,
		       pa.sire_id::text, pa.dam_id::text,
		       COALESCE(NULLIF(sire.name,''), sire.internal_code, ''),
		       COALESCE(NULLIF(dam.name,''), dam.internal_code, ''),
		       COALESCE(p.name,'')
		FROM pairing_attempt pa
		JOIN breeding_plan p ON p.owner_id=pa.owner_id AND p.id=pa.breeding_plan_id
		LEFT JOIN hamster sire ON sire.owner_id=pa.owner_id AND sire.id=pa.sire_id AND sire.deleted_at IS NULL
		LEFT JOIN hamster dam ON dam.owner_id=pa.owner_id AND dam.id=pa.dam_id AND dam.deleted_at IS NULL
		WHERE pa.owner_id=$1 AND pa.deleted_at IS NULL`
	qargs := []any{ownerID}
	argN := 2
	if status != "" {
		query += fmt.Sprintf(` AND pa.status::text=$%d`, argN)
		qargs = append(qargs, status)
		argN++
	}
	if planRaw != "" {
		pid, err := uuid.Parse(planRaw)
		if err != nil {
			return nil, fmt.Errorf("invalid plan_id")
		}
		query += fmt.Sprintf(` AND pa.breeding_plan_id=$%d`, argN)
		qargs = append(qargs, pid)
		argN++
	}
	query += fmt.Sprintf(` ORDER BY pa.started_at DESC NULLS LAST LIMIT $%d`, argN)
	qargs = append(qargs, limit)
	rows, err := s.Store.Pool.Query(ctx, query, qargs...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]map[string]any, 0)
	now := time.Now().UTC()
	for rows.Next() {
		var id, planID, st, result, sireID, damID, sireName, damName, planName string
		var attemptNo int
		var started, separated, deadline any
		if err := rows.Scan(&id, &planID, &attemptNo, &st, &result, &started, &separated, &deadline, &sireID, &damID, &sireName, &damName, &planName); err != nil {
			return nil, err
		}
		item := map[string]any{
			"id": id, "plan_id": planID, "attempt_no": attemptNo, "status": st,
			"sire_id": sireID, "dam_id": damID, "sire_name": sireName, "dam_name": damName,
			"plan_name": planName, "started_at": started,
		}
		if result != "" {
			item["result"] = result
		}
		if separated != nil {
			item["separated_at"] = separated
		}
		if deadline != nil {
			item["separation_deadline"] = deadline
			if dl, ok := deadline.(time.Time); ok && st == "active" {
				item["past_separation_deadline"] = now.After(dl)
			}
		}
		out = append(out, item)
	}
	return map[string]any{"count": len(out), "attempts": out}, rows.Err()
}

func (s *Server) toolListLitters(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	limit := toolLimit(args, 15, 1, 20)
	rows, err := s.Store.Pool.Query(ctx, `
		SELECT id::text, COALESCE(code,''), state::text,
		       born_at, current_managed_count, created_at
		FROM litter
		WHERE owner_id=$1 AND deleted_at IS NULL
		ORDER BY updated_at DESC
		LIMIT $2
	`, ownerID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]map[string]any, 0)
	for rows.Next() {
		var id, code, state string
		var born, created any
		var managed int
		if err := rows.Scan(&id, &code, &state, &born, &managed, &created); err != nil {
			return nil, err
		}
		out = append(out, map[string]any{
			"id": id, "code": code, "state": state,
			"born_at": born, "current_managed_count": managed, "created_at": created,
		})
	}
	return map[string]any{"count": len(out), "litters": out}, rows.Err()
}

func (s *Server) toolGetHamster(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	id, err := uuid.Parse(stringArgMap(args, "hamster_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid hamster_id")
	}
	var name, code, sex, status string
	var enclosure *string
	var birth any
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT COALESCE(name,''), COALESCE(internal_code,''), sex::text,
		       lifecycle_status::text, current_enclosure_id::text, birth_date
		FROM hamster
		WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
	`, ownerID, id).Scan(&name, &code, &sex, &status, &enclosure, &birth)
	if err != nil {
		return nil, fmt.Errorf("hamster not found")
	}
	item := map[string]any{
		"id": id.String(), "name": name, "internal_code": code,
		"sex": sex, "lifecycle_status": status, "birth_date": birth,
	}
	if enclosure != nil {
		item["current_enclosure_id"] = *enclosure
	}
	return item, nil
}

func (s *Server) toolListCrmContacts(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	q := stringArgMap(args, "query")
	limit := toolLimit(args, 15, 1, 30)
	var (
		query string
		qargs []any
	)
	if q == "" {
		query = `
			SELECT id::text, name, COALESCE(phone,''), COALESCE(wechat,''), status::text, updated_at
			FROM crm_contact
			WHERE owner_id=$1
			ORDER BY updated_at DESC
			LIMIT $2`
		qargs = []any{ownerID, limit}
	} else {
		query = `
			SELECT id::text, name, COALESCE(phone,''), COALESCE(wechat,''), status::text, updated_at
			FROM crm_contact
			WHERE owner_id=$1
			  AND (name ILIKE $2 OR COALESCE(phone,'') ILIKE $2 OR COALESCE(wechat,'') ILIKE $2)
			ORDER BY updated_at DESC
			LIMIT $3`
		qargs = []any{ownerID, "%" + q + "%", limit}
	}
	rows, err := s.Store.Pool.Query(ctx, query, qargs...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]map[string]any, 0)
	for rows.Next() {
		var id, name, phone, wechat, status string
		var updated any
		if err := rows.Scan(&id, &name, &phone, &wechat, &status, &updated); err != nil {
			return nil, err
		}
		out = append(out, map[string]any{
			"id": id, "name": name, "phone": phone, "wechat": wechat,
			"status": status, "updated_at": updated,
		})
	}
	return map[string]any{"count": len(out), "contacts": out}, rows.Err()
}

func (s *Server) toolGetCrmContact(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	contactID, err := uuid.Parse(stringArgMap(args, "contact_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid contact_id")
	}
	var name, phone, wechat, notes, status string
	var version int
	var updated any
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT name, COALESCE(phone,''), COALESCE(wechat,''), COALESCE(notes,''),
		       status::text, version, updated_at
		FROM crm_contact WHERE owner_id=$1 AND id=$2
	`, ownerID, contactID).Scan(&name, &phone, &wechat, &notes, &status, &version, &updated)
	if err != nil {
		return nil, fmt.Errorf("contact not found")
	}
	item := map[string]any{
		"id": contactID.String(), "name": name, "phone": phone, "wechat": wechat,
		"status": status, "version": version, "updated_at": updated,
	}
	if notes != "" {
		item["notes"] = notes
	}
	// Recent open reservations.
	resRows, err := s.Store.Pool.Query(ctx, `
		SELECT r.id::text, r.title, r.status::text, r.reserved_at, r.hamster_id::text
		FROM crm_reservation r
		WHERE r.owner_id=$1 AND r.contact_id=$2
		  AND r.status IN ('held','confirmed')
		ORDER BY r.reserved_at DESC
		LIMIT 5
	`, ownerID, contactID)
	if err != nil {
		return nil, err
	}
	reservations := make([]map[string]any, 0)
	for resRows.Next() {
		var id, title, st string
		var reserved any
		var hamsterID *string
		if err := resRows.Scan(&id, &title, &st, &reserved, &hamsterID); err != nil {
			resRows.Close()
			return nil, err
		}
		r := map[string]any{"id": id, "title": title, "status": st, "reserved_at": reserved}
		if hamsterID != nil {
			r["hamster_id"] = *hamsterID
		}
		reservations = append(reservations, r)
	}
	resRows.Close()
	if err := resRows.Err(); err != nil {
		return nil, err
	}
	// Recent non-cancelled handovers.
	hoRows, err := s.Store.Pool.Query(ctx, `
		SELECT h.id::text, h.status::text, h.scheduled_at, h.hamster_id::text, h.reservation_id::text
		FROM crm_handover h
		WHERE h.owner_id=$1 AND h.contact_id=$2 AND h.status <> 'cancelled'
		ORDER BY h.scheduled_at DESC
		LIMIT 5
	`, ownerID, contactID)
	if err != nil {
		return nil, err
	}
	handovers := make([]map[string]any, 0)
	for hoRows.Next() {
		var id, st string
		var scheduled any
		var hamsterID, reservationID *string
		if err := hoRows.Scan(&id, &st, &scheduled, &hamsterID, &reservationID); err != nil {
			hoRows.Close()
			return nil, err
		}
		h := map[string]any{"id": id, "status": st, "scheduled_at": scheduled}
		if hamsterID != nil {
			h["hamster_id"] = *hamsterID
		}
		if reservationID != nil {
			h["reservation_id"] = *reservationID
		}
		handovers = append(handovers, h)
	}
	hoRows.Close()
	if err := hoRows.Err(); err != nil {
		return nil, err
	}
	item["open_reservations"] = reservations
	item["recent_handovers"] = handovers
	item["open_reservation_count"] = len(reservations)
	item["recent_handover_count"] = len(handovers)
	return item, nil
}

func (s *Server) toolListCrmReservations(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	limit := toolLimit(args, 15, 1, 30)
	status := stringArgMap(args, "status")
	query := `
		SELECT r.id::text, r.title, r.status::text, r.reserved_at, r.contact_id::text,
		       c.name, r.hamster_id::text
		FROM crm_reservation r
		JOIN crm_contact c ON c.owner_id=r.owner_id AND c.id=r.contact_id
		WHERE r.owner_id=$1`
	qargs := []any{ownerID}
	if status != "" {
		query += ` AND r.status::text=$2`
		qargs = append(qargs, status)
		query += ` ORDER BY r.reserved_at DESC LIMIT $3`
		qargs = append(qargs, limit)
	} else {
		query += ` ORDER BY r.reserved_at DESC LIMIT $2`
		qargs = append(qargs, limit)
	}
	rows, err := s.Store.Pool.Query(ctx, query, qargs...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]map[string]any, 0)
	for rows.Next() {
		var id, title, st, contactID, contactName string
		var reserved any
		var hamsterID *string
		if err := rows.Scan(&id, &title, &st, &reserved, &contactID, &contactName, &hamsterID); err != nil {
			return nil, err
		}
		item := map[string]any{
			"id": id, "title": title, "status": st, "reserved_at": reserved,
			"contact_id": contactID, "contact_name": contactName,
		}
		if hamsterID != nil {
			item["hamster_id"] = *hamsterID
		}
		out = append(out, item)
	}
	return map[string]any{"count": len(out), "reservations": out}, rows.Err()
}

func (s *Server) toolGetCrmReservation(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	reservationID, err := uuid.Parse(stringArgMap(args, "reservation_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid reservation_id")
	}
	var title, status, contactID, contactName string
	var reserved any
	var notes *string
	var hamsterID, hamsterName *string
	var holdExpires *time.Time
	var version int
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT r.title, r.status::text, r.reserved_at, r.notes, r.version, r.hold_expires_at,
		       r.contact_id::text, c.name, r.hamster_id::text,
		       CASE WHEN h.id IS NULL THEN NULL ELSE COALESCE(NULLIF(h.name,''), h.internal_code) END
		FROM crm_reservation r
		JOIN crm_contact c ON c.owner_id=r.owner_id AND c.id=r.contact_id
		LEFT JOIN hamster h ON h.owner_id=r.owner_id AND h.id=r.hamster_id AND h.deleted_at IS NULL
		WHERE r.owner_id=$1 AND r.id=$2
	`, ownerID, reservationID).Scan(
		&title, &status, &reserved, &notes, &version, &holdExpires,
		&contactID, &contactName, &hamsterID, &hamsterName,
	)
	if err != nil {
		return nil, fmt.Errorf("reservation not found")
	}
	item := map[string]any{
		"id": reservationID.String(), "title": title, "status": status,
		"reserved_at": reserved, "version": version,
		"contact_id": contactID, "contact_name": contactName,
	}
	if notes != nil && *notes != "" {
		item["notes"] = *notes
	}
	if hamsterID != nil {
		item["hamster_id"] = *hamsterID
	}
	if hamsterName != nil {
		item["hamster_name"] = *hamsterName
	}
	if holdExpires != nil {
		item["hold_expires_at"] = holdExpires.UTC().Format(time.RFC3339)
		item["hold_expired"] = !holdExpires.After(time.Now().UTC())
	}
	// Linked non-cancelled handover if any.
	var handoverID, handoverStatus *string
	var scheduled any
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT id::text, status::text, scheduled_at
		FROM crm_handover
		WHERE owner_id=$1 AND reservation_id=$2 AND status <> 'cancelled'
		ORDER BY scheduled_at DESC
		LIMIT 1
	`, ownerID, reservationID).Scan(&handoverID, &handoverStatus, &scheduled)
	if err == nil && handoverID != nil {
		item["handover"] = map[string]any{
			"id": *handoverID, "status": *handoverStatus, "scheduled_at": scheduled,
		}
	}
	return item, nil
}

func (s *Server) toolGetCrmHandover(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	handoverID, err := uuid.Parse(stringArgMap(args, "handover_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid handover_id")
	}
	var status, contactID, contactName string
	var scheduled, completed any
	var notes *string
	var reservationID, hamsterID, hamsterName *string
	var version int
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT h.status::text, h.scheduled_at, h.completed_at, h.notes, h.version,
		       h.contact_id::text, c.name, h.reservation_id::text, h.hamster_id::text,
		       CASE WHEN hamster.id IS NULL THEN NULL ELSE COALESCE(NULLIF(hamster.name,''), hamster.internal_code) END
		FROM crm_handover h
		JOIN crm_contact c ON c.owner_id=h.owner_id AND c.id=h.contact_id
		LEFT JOIN hamster ON hamster.owner_id=h.owner_id AND hamster.id=h.hamster_id AND hamster.deleted_at IS NULL
		WHERE h.owner_id=$1 AND h.id=$2
	`, ownerID, handoverID).Scan(
		&status, &scheduled, &completed, &notes, &version,
		&contactID, &contactName, &reservationID, &hamsterID, &hamsterName,
	)
	if err != nil {
		return nil, fmt.Errorf("handover not found")
	}
	item := map[string]any{
		"id": handoverID.String(), "status": status, "scheduled_at": scheduled,
		"version": version, "contact_id": contactID, "contact_name": contactName,
	}
	if completed != nil {
		item["completed_at"] = completed
	}
	if notes != nil && *notes != "" {
		item["notes"] = *notes
	}
	if reservationID != nil {
		item["reservation_id"] = *reservationID
	}
	if hamsterID != nil {
		item["hamster_id"] = *hamsterID
	}
	if hamsterName != nil {
		item["hamster_name"] = *hamsterName
	}
	return item, nil
}

func (s *Server) toolListAccountingSummary(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	days := 30
	if v, ok := args["days"].(float64); ok {
		days = int(v)
		if days < 1 {
			days = 1
		}
		if days > 366 {
			days = 366
		}
	}
	var incomeCents, expenseCents int64
	var incomeN, expenseN int
	err := s.Store.Pool.QueryRow(ctx, `
		SELECT
		  COALESCE(SUM(CASE WHEN entry_type='income' THEN amount_cents ELSE 0 END),0),
		  COALESCE(SUM(CASE WHEN entry_type='expense' THEN amount_cents ELSE 0 END),0),
		  COALESCE(SUM(CASE WHEN entry_type='income' THEN 1 ELSE 0 END),0),
		  COALESCE(SUM(CASE WHEN entry_type='expense' THEN 1 ELSE 0 END),0)
		FROM accounting_record
		WHERE owner_id=$1 AND occurred_at >= now() - ($2 * interval '1 day')
	`, ownerID, days).Scan(&incomeCents, &expenseCents, &incomeN, &expenseN)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"days":                 days,
		"income_cents":         incomeCents,
		"expense_cents":        expenseCents,
		"net_cents":            incomeCents - expenseCents,
		"income_count":         incomeN,
		"expense_count":        expenseN,
		"income_yuan":          float64(incomeCents) / 100.0,
		"expense_yuan":         float64(expenseCents) / 100.0,
		"net_yuan":             float64(incomeCents-expenseCents) / 100.0,
	}, nil
}

func (s *Server) toolSearchDocs(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	q := stringArgMap(args, "query")
	kind := stringArgMap(args, "kind")
	status := stringArgMap(args, "status")
	contactRaw := stringArgMap(args, "contact_id")
	limit := toolLimit(args, 15, 1, 30)
	query := `
		SELECT d.id::text, d.kind::text, d.title, d.status::text, d.amount_cents, d.currency,
		       COALESCE(c.name, ''), d.contact_id::text, d.issued_at, d.updated_at
		FROM doc_document d
		LEFT JOIN crm_contact c ON c.owner_id=d.owner_id AND c.id=d.contact_id
		WHERE d.owner_id=$1 AND d.status <> 'archived'`
	qargs := []any{ownerID}
	argN := 2
	if kind == "contract" || kind == "receipt" {
		query += fmt.Sprintf(` AND d.kind::text=$%d`, argN)
		qargs = append(qargs, kind)
		argN++
	}
	if status != "" {
		if status != "draft" && status != "issued" && status != "revoked" {
			return nil, domain.NewToolError(domain.ErrInvalidDocStatus, nil)
		}
		query += fmt.Sprintf(` AND d.status::text=$%d`, argN)
		qargs = append(qargs, status)
		argN++
	}
	if contactRaw != "" {
		cid, err := uuid.Parse(contactRaw)
		if err != nil {
			return nil, fmt.Errorf("invalid contact_id")
		}
		query += fmt.Sprintf(` AND d.contact_id=$%d`, argN)
		qargs = append(qargs, cid)
		argN++
	}
	if q != "" {
		query += fmt.Sprintf(` AND d.title ILIKE $%d`, argN)
		qargs = append(qargs, "%"+q+"%")
		argN++
	}
	query += fmt.Sprintf(` ORDER BY d.updated_at DESC LIMIT $%d`, argN)
	qargs = append(qargs, limit)
	rows, err := s.Store.Pool.Query(ctx, query, qargs...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]map[string]any, 0)
	for rows.Next() {
		var id, k, title, st, currency, contactName string
		var contactID *string
		var amount *int64
		var issued, updated any
		if err := rows.Scan(&id, &k, &title, &st, &amount, &currency, &contactName, &contactID, &issued, &updated); err != nil {
			return nil, err
		}
		item := map[string]any{
			"id": id, "kind": k, "title": title, "status": st,
			"currency": currency, "contact_name": contactName,
			"issued_at": issued, "updated_at": updated,
		}
		if amount != nil {
			item["amount_cents"] = *amount
			item["amount_yuan"] = float64(*amount) / 100.0
		}
		if contactID != nil {
			item["contact_id"] = *contactID
		}
		out = append(out, item)
	}
	return map[string]any{"count": len(out), "documents": out}, rows.Err()
}

func (s *Server) toolGetDoc(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	docID, err := uuid.Parse(stringArgMap(args, "document_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid document_id")
	}
	kind := stringArgMap(args, "kind")
	query := `
		SELECT d.id::text, d.kind::text, d.title, d.status::text, d.body_filled,
		       d.amount_cents, d.currency, d.template_id::text,
		       d.contact_id::text, COALESCE(c.name,''),
		       d.handover_id::text, d.reservation_id::text,
		       d.issued_at, d.notes, d.version, d.updated_at,
		       d.public_token
		FROM doc_document d
		LEFT JOIN crm_contact c ON c.owner_id=d.owner_id AND c.id=d.contact_id
		WHERE d.owner_id=$1 AND d.id=$2`
	qargs := []any{ownerID, docID}
	if kind == "contract" || kind == "receipt" {
		query += ` AND d.kind::text=$3`
		qargs = append(qargs, kind)
	}
	var (
		id, k, title, status, body, currency, templateID string
		contactName                                      string
		contactID, handoverID, reservationID             *string
		amount                                           *int64
		issued                                           any
		notes                                            *string
		version                                          int
		updated                                          any
		publicToken                                      *string
	)
	err = s.Store.Pool.QueryRow(ctx, query, qargs...).Scan(
		&id, &k, &title, &status, &body, &amount, &currency, &templateID,
		&contactID, &contactName, &handoverID, &reservationID,
		&issued, &notes, &version, &updated, &publicToken,
	)
	if err != nil {
		return nil, fmt.Errorf("document not found")
	}
	// Truncate body for LLM context.
	bodyPreview := body
	if len(bodyPreview) > 1200 {
		bodyPreview = bodyPreview[:1200] + "…"
	}
	item := map[string]any{
		"id": id, "kind": k, "title": title, "status": status,
		"body_preview": bodyPreview, "currency": currency,
		"template_id": templateID, "contact_name": contactName,
		"version": version, "updated_at": updated,
	}
	if amount != nil {
		item["amount_cents"] = *amount
		item["amount_yuan"] = float64(*amount) / 100.0
	}
	if contactID != nil {
		item["contact_id"] = *contactID
	}
	if handoverID != nil {
		item["handover_id"] = *handoverID
	}
	if reservationID != nil {
		item["reservation_id"] = *reservationID
	}
	if issued != nil {
		item["issued_at"] = issued
	}
	if notes != nil && *notes != "" {
		item["notes"] = *notes
	}
	if publicToken != nil && status == "issued" {
		item["has_public_share"] = true
	}
	return item, nil
}

func (s *Server) toolListDocTemplates(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	kind := stringArgMap(args, "kind")
	if kind != "contract" && kind != "receipt" {
		return nil, domain.NewToolError(domain.ErrInvalidDocKind, nil)
	}
	limit := toolLimit(args, 15, 1, 30)
	rows, err := s.Store.Pool.Query(ctx, `
		SELECT id::text, name, version, updated_at,
		       LEFT(body_text, 200)
		FROM doc_template
		WHERE owner_id=$1 AND kind=$2::doc_template_kind
		ORDER BY updated_at DESC, id DESC
		LIMIT $3
	`, ownerID, kind, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]map[string]any, 0)
	for rows.Next() {
		var id, name, preview string
		var version int
		var updated any
		if err := rows.Scan(&id, &name, &version, &updated, &preview); err != nil {
			return nil, err
		}
		out = append(out, map[string]any{
			"id": id, "name": name, "kind": kind, "version": version,
			"updated_at": updated, "body_preview": preview,
		})
	}
	return map[string]any{"count": len(out), "kind": kind, "templates": out}, rows.Err()
}

func (s *Server) toolListRecentWeights(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	limit := toolLimit(args, 10, 1, 30)
	hamsterRaw := stringArgMap(args, "hamster_id")
	var (
		query string
		qargs []any
	)
	if hamsterRaw == "" {
		query = `
			SELECT w.id::text, w.hamster_id::text, w.weight_g, w.recorded_at,
			       COALESCE(h.name,''), COALESCE(h.internal_code,'')
			FROM weight_record w
			LEFT JOIN hamster h ON h.owner_id=w.owner_id AND h.id=w.hamster_id
			WHERE w.owner_id=$1 AND w.hamster_id IS NOT NULL
			ORDER BY w.recorded_at DESC
			LIMIT $2`
		qargs = []any{ownerID, limit}
	} else {
		hid, err := uuid.Parse(hamsterRaw)
		if err != nil {
			return nil, fmt.Errorf("invalid hamster_id")
		}
		query = `
			SELECT w.id::text, w.hamster_id::text, w.weight_g, w.recorded_at,
			       COALESCE(h.name,''), COALESCE(h.internal_code,'')
			FROM weight_record w
			LEFT JOIN hamster h ON h.owner_id=w.owner_id AND h.id=w.hamster_id
			WHERE w.owner_id=$1 AND w.hamster_id=$2
			ORDER BY w.recorded_at DESC
			LIMIT $3`
		qargs = []any{ownerID, hid, limit}
	}
	rows, err := s.Store.Pool.Query(ctx, query, qargs...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]map[string]any, 0)
	for rows.Next() {
		var id, hamsterID, name, code string
		var weight float64
		var recorded any
		if err := rows.Scan(&id, &hamsterID, &weight, &recorded, &name, &code); err != nil {
			return nil, err
		}
		out = append(out, map[string]any{
			"id": id, "hamster_id": hamsterID, "weight_g": weight,
			"recorded_at": recorded, "hamster_name": name, "internal_code": code,
		})
	}
	return map[string]any{"count": len(out), "weights": out}, rows.Err()
}

func (s *Server) toolDraftCreateCrmContact(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
	if sess.SessionID == uuid.Nil {
		return nil, fmt.Errorf("session required for write draft")
	}
	name := stringArgMap(args, "name")
	if name == "" {
		return nil, fmt.Errorf("name required")
	}
	status := stringArgMap(args, "status")
	if status == "" {
		status = "lead"
	}
	if status != "lead" && status != "active" && status != "archived" {
		return nil, fmt.Errorf("invalid status")
	}
	payload := map[string]any{"name": name, "status": status}
	if phone := stringArgMap(args, "phone"); phone != "" {
		payload["phone"] = phone
	}
	if wechat := stringArgMap(args, "wechat"); wechat != "" {
		payload["wechat"] = wechat
	}
	if notes := stringArgMap(args, "notes"); notes != "" {
		payload["notes"] = notes
	}
	summary := fmt.Sprintf("新建客户「%s」(%s)", name, status)
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "create_crm_contact", "确认新建客户", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "create_crm_contact",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}

func (s *Server) toolDraftUpdateCrmContact(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
	if sess.SessionID == uuid.Nil {
		return nil, fmt.Errorf("session required for write draft")
	}
	contactID, err := uuid.Parse(stringArgMap(args, "contact_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid contact_id")
	}
	var curName, curStatus string
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT name, status::text FROM crm_contact WHERE owner_id=$1 AND id=$2
	`, ownerID, contactID).Scan(&curName, &curStatus)
	if err != nil {
		return nil, fmt.Errorf("contact not found")
	}
	payload := map[string]any{
		"contact_id": contactID.String(), "current_name": curName, "current_status": curStatus,
	}
	changed := make([]string, 0, 5)
	if v := stringArgMap(args, "name"); v != "" {
		payload["name"] = v
		changed = append(changed, "name="+v)
	}
	if _, ok := args["phone"]; ok {
		payload["phone"] = stringArgMap(args, "phone")
		changed = append(changed, "phone")
	}
	if _, ok := args["wechat"]; ok {
		payload["wechat"] = stringArgMap(args, "wechat")
		changed = append(changed, "wechat")
	}
	if _, ok := args["notes"]; ok {
		payload["notes"] = stringArgMap(args, "notes")
		changed = append(changed, "notes")
	}
	if v := stringArgMap(args, "status"); v != "" {
		if v != "lead" && v != "active" && v != "archived" {
			return nil, fmt.Errorf("invalid status")
		}
		payload["status"] = v
		changed = append(changed, "status="+v)
	}
	if len(changed) == 0 {
		return nil, domain.NewToolError(domain.ErrNoFieldsToUpdate, nil)
	}
	summary := fmt.Sprintf("更新客户「%s」：%s", curName, strings.Join(changed, ", "))
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "update_crm_contact", "确认更新客户", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "update_crm_contact",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}

func (s *Server) toolListCrmHandovers(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	limit := toolLimit(args, 15, 1, 30)
	status := stringArgMap(args, "status")
	query := `
		SELECT h.id::text, h.status::text, h.scheduled_at, h.completed_at,
		       h.contact_id::text, c.name, h.hamster_id::text, h.reservation_id::text,
		       CASE WHEN hamster.id IS NULL THEN NULL ELSE COALESCE(NULLIF(hamster.name,''), hamster.internal_code) END
		FROM crm_handover h
		JOIN crm_contact c ON c.owner_id=h.owner_id AND c.id=h.contact_id
		LEFT JOIN hamster ON hamster.owner_id=h.owner_id AND hamster.id=h.hamster_id AND hamster.deleted_at IS NULL
		WHERE h.owner_id=$1 AND h.status <> 'cancelled'`
	qargs := []any{ownerID}
	if status != "" {
		query += ` AND h.status::text=$2`
		qargs = append(qargs, status)
		query += ` ORDER BY h.scheduled_at DESC LIMIT $3`
		qargs = append(qargs, limit)
	} else {
		query += ` ORDER BY h.scheduled_at DESC LIMIT $2`
		qargs = append(qargs, limit)
	}
	rows, err := s.Store.Pool.Query(ctx, query, qargs...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]map[string]any, 0)
	for rows.Next() {
		var id, st, contactID, contactName string
		var scheduled, completed any
		var hamsterID, reservationID, hamsterName *string
		if err := rows.Scan(&id, &st, &scheduled, &completed, &contactID, &contactName, &hamsterID, &reservationID, &hamsterName); err != nil {
			return nil, err
		}
		item := map[string]any{
			"id": id, "status": st, "scheduled_at": scheduled,
			"contact_id": contactID, "contact_name": contactName,
		}
		if completed != nil {
			item["completed_at"] = completed
		}
		if hamsterID != nil {
			item["hamster_id"] = *hamsterID
		}
		if reservationID != nil {
			item["reservation_id"] = *reservationID
		}
		if hamsterName != nil {
			item["hamster_name"] = *hamsterName
		}
		out = append(out, item)
	}
	return map[string]any{"count": len(out), "handovers": out}, rows.Err()
}

func (s *Server) toolDraftCreateCrmReservation(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
	if sess.SessionID == uuid.Nil {
		return nil, fmt.Errorf("session required for write draft")
	}
	contactID, err := uuid.Parse(stringArgMap(args, "contact_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid contact_id")
	}
	var contactName, contactStatus string
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT name, status::text FROM crm_contact WHERE owner_id=$1 AND id=$2
	`, ownerID, contactID).Scan(&contactName, &contactStatus)
	if err != nil {
		return nil, fmt.Errorf("contact not found")
	}
	if contactStatus == "archived" {
		return nil, domain.NewToolError(domain.ErrArchivedContactCannotReserve, nil)
	}
	title := stringArgMap(args, "title")
	if title == "" {
		title = "预订"
	}
	payload := map[string]any{
		"contact_id": contactID.String(), "title": title, "contact_name": contactName,
	}
	if notes := stringArgMap(args, "notes"); notes != "" {
		payload["notes"] = notes
	}
	if raw := stringArgMap(args, "hamster_id"); raw != "" {
		hid, parseErr := uuid.Parse(raw)
		if parseErr != nil {
			return nil, fmt.Errorf("invalid hamster_id")
		}
		var n int
		err = s.Store.Pool.QueryRow(ctx, `
			SELECT count(*) FROM hamster WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
		`, ownerID, hid).Scan(&n)
		if err != nil || n == 0 {
			return nil, fmt.Errorf("hamster not found")
		}
		payload["hamster_id"] = hid.String()
	}
	summary := fmt.Sprintf("新建预订「%s」→ 客户 %s", title, contactName)
	if hid, ok := payload["hamster_id"].(string); ok {
		summary += " · 仓鼠 " + hid[:8]
	}
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "create_crm_reservation", "确认新建预订", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "create_crm_reservation",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}

func (s *Server) toolDraftCreateCrmHandover(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
	if sess.SessionID == uuid.Nil {
		return nil, fmt.Errorf("session required for write draft")
	}
	contactID, err := uuid.Parse(stringArgMap(args, "contact_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid contact_id")
	}
	var contactName, contactStatus string
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT name, status::text FROM crm_contact WHERE owner_id=$1 AND id=$2
	`, ownerID, contactID).Scan(&contactName, &contactStatus)
	if err != nil {
		return nil, fmt.Errorf("contact not found")
	}
	if contactStatus == "archived" {
		return nil, domain.NewToolError(domain.ErrArchivedContactCannotHandover, nil)
	}
	hamsterRaw := stringArgMap(args, "hamster_id")
	reservationRaw := stringArgMap(args, "reservation_id")
	if hamsterRaw == "" && reservationRaw == "" {
		return nil, fmt.Errorf("hamster_id or reservation_id required")
	}
	payload := map[string]any{
		"contact_id": contactID.String(), "contact_name": contactName,
	}
	if hamsterRaw != "" {
		hid, parseErr := uuid.Parse(hamsterRaw)
		if parseErr != nil {
			return nil, fmt.Errorf("invalid hamster_id")
		}
		var n int
		err = s.Store.Pool.QueryRow(ctx, `
			SELECT count(*) FROM hamster WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
		`, ownerID, hid).Scan(&n)
		if err != nil || n == 0 {
			return nil, fmt.Errorf("hamster not found")
		}
		payload["hamster_id"] = hid.String()
	}
	if reservationRaw != "" {
		rid, parseErr := uuid.Parse(reservationRaw)
		if parseErr != nil {
			return nil, fmt.Errorf("invalid reservation_id")
		}
		var n int
		err = s.Store.Pool.QueryRow(ctx, `
			SELECT count(*) FROM crm_reservation WHERE owner_id=$1 AND id=$2
		`, ownerID, rid).Scan(&n)
		if err != nil || n == 0 {
			return nil, fmt.Errorf("reservation not found")
		}
		payload["reservation_id"] = rid.String()
	}
	scheduledAt := time.Now().UTC()
	if raw := stringArgMap(args, "scheduled_at"); raw != "" {
		if parsed, parseErr := time.Parse(time.RFC3339, raw); parseErr == nil {
			scheduledAt = parsed.UTC()
		}
	}
	payload["scheduled_at"] = scheduledAt.Format(time.RFC3339)
	if notes := stringArgMap(args, "notes"); notes != "" {
		payload["notes"] = notes
	}
	summary := fmt.Sprintf("新建交付 → 客户 %s @ %s", contactName, scheduledAt.Format(time.RFC3339))
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "create_crm_handover", "确认新建交付", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "create_crm_handover",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}

func (s *Server) toolDraftCreateAccountingRecord(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
	if sess.SessionID == uuid.Nil {
		return nil, fmt.Errorf("session required for write draft")
	}
	entryType := stringArgMap(args, "entry_type")
	if entryType != "income" && entryType != "expense" {
		return nil, domain.NewToolError(domain.ErrInvalidEntryType, nil)
	}
	amountCents := int64(0)
	switch v := args["amount_cents"].(type) {
	case float64:
		amountCents = int64(v)
	case int:
		amountCents = int64(v)
	case int64:
		amountCents = v
	default:
		return nil, fmt.Errorf("invalid amount_cents")
	}
	if amountCents <= 0 {
		return nil, domain.NewToolError(domain.ErrAmountNotPositive, nil)
	}
	title := stringArgMap(args, "title")
	if title == "" {
		return nil, fmt.Errorf("title required")
	}
	currency := stringArgMap(args, "currency")
	if currency == "" {
		currency = "CNY"
	}
	payload := map[string]any{
		"entry_type": entryType, "amount_cents": amountCents, "title": title, "currency": currency,
	}
	if notes := stringArgMap(args, "notes"); notes != "" {
		payload["notes"] = notes
	}
	if raw := stringArgMap(args, "contact_id"); raw != "" {
		cid, parseErr := uuid.Parse(raw)
		if parseErr != nil {
			return nil, fmt.Errorf("invalid contact_id")
		}
		var n int
		err := s.Store.Pool.QueryRow(ctx, `
			SELECT count(*) FROM crm_contact WHERE owner_id=$1 AND id=$2
		`, ownerID, cid).Scan(&n)
		if err != nil || n == 0 {
			return nil, fmt.Errorf("contact not found")
		}
		payload["contact_id"] = cid.String()
	}
	if raw := stringArgMap(args, "occurred_at"); raw != "" {
		payload["occurred_at"] = raw
	}
	typeLabel := "收入"
	if entryType == "expense" {
		typeLabel = "支出"
	}
	summary := fmt.Sprintf("记账%s %.2f %s「%s」", typeLabel, float64(amountCents)/100.0, currency, title)
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "create_accounting_record", "确认记账", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "create_accounting_record",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}

func (s *Server) toolDraftCreateHealthRecord(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
	if sess.SessionID == uuid.Nil {
		return nil, fmt.Errorf("session required for write draft")
	}
	hamsterID, err := uuid.Parse(stringArgMap(args, "hamster_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid hamster_id")
	}
	var name string
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT COALESCE(name,'') FROM hamster WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
	`, ownerID, hamsterID).Scan(&name)
	if err != nil {
		return nil, fmt.Errorf("hamster not found")
	}
	recType := stringArgMap(args, "type")
	switch recType {
	case "daily_check", "anomaly", "medication", "follow_up", "isolation", "death":
	default:
		return nil, fmt.Errorf("invalid health record type")
	}
	observedAt := time.Now().UTC()
	if raw := stringArgMap(args, "observed_at"); raw != "" {
		if parsed, parseErr := time.Parse(time.RFC3339, raw); parseErr == nil {
			observedAt = parsed.UTC()
		}
	}
	payload := map[string]any{
		"hamster_id": hamsterID.String(), "type": recType,
		"observed_at": observedAt.Format(time.RFC3339), "name": name,
	}
	if notes := stringArgMap(args, "notes"); notes != "" {
		payload["notes"] = notes
	}
	if sev := stringArgMap(args, "severity"); sev != "" {
		switch sev {
		case "info", "low", "medium", "high", "critical":
			payload["severity"] = sev
		default:
			return nil, fmt.Errorf("invalid severity")
		}
	}
	summary := fmt.Sprintf("健康记录 %s → %s @ %s", recType, firstNonEmptyName(name, hamsterID.String()[:8]), observedAt.Format(time.RFC3339))
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "create_health_record", "确认健康记录", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "create_health_record",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}

func (s *Server) toolDraftRecordPairingObservation(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
	if sess.SessionID == uuid.Nil {
		return nil, fmt.Errorf("session required for write draft")
	}
	attemptID, err := uuid.Parse(stringArgMap(args, "attempt_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid attempt_id")
	}
	obsType := stringArgMap(args, "type")
	switch obsType {
	case "contact", "chase", "conflict", "mating", "separated", "other":
	default:
		return nil, domain.NewToolError(domain.ErrInvalidObservationType, nil)
	}
	var status string
	var attemptNo int
	var planName string
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT pa.status::text, pa.attempt_no, COALESCE(p.name,'')
		FROM pairing_attempt pa
		JOIN breeding_plan p ON p.owner_id=pa.owner_id AND p.id=pa.breeding_plan_id
		WHERE pa.owner_id=$1 AND pa.id=$2 AND pa.deleted_at IS NULL
	`, ownerID, attemptID).Scan(&status, &attemptNo, &planName)
	if err != nil {
		return nil, fmt.Errorf("pairing attempt not found")
	}
	if status != "active" && status != "safety_hold" {
		return nil, domain.NewToolError(domain.ErrPairingNotOpenForObservation, map[string]any{"status": status})
	}
	observedAt := time.Now().UTC()
	if raw := stringArgMap(args, "observed_at"); raw != "" {
		if parsed, parseErr := time.Parse(time.RFC3339, raw); parseErr == nil {
			observedAt = parsed.UTC()
		}
	}
	payload := map[string]any{
		"attempt_id": attemptID.String(), "type": obsType,
		"observed_at": observedAt.Format(time.RFC3339),
		"attempt_no":  attemptNo, "plan_name": planName,
	}
	if notes := stringArgMap(args, "notes"); notes != "" {
		payload["notes"] = notes
	}
	if sev := stringArgMap(args, "severity"); sev != "" {
		switch sev {
		case "info", "low", "medium", "high", "critical":
			payload["severity"] = sev
		default:
			return nil, fmt.Errorf("invalid severity")
		}
	}
	if v, ok := args["duration_seconds"]; ok {
		switch n := v.(type) {
		case float64:
			if int(n) < 0 {
				return nil, fmt.Errorf("invalid duration_seconds")
			}
			payload["duration_seconds"] = int(n)
		case int:
			if n < 0 {
				return nil, fmt.Errorf("invalid duration_seconds")
			}
			payload["duration_seconds"] = n
		}
	}
	label := planName
	if label == "" {
		label = attemptID.String()[:8]
	}
	summary := fmt.Sprintf("配对观察 %s → 计划「%s」第%d次 @ %s", obsType, label, attemptNo, observedAt.Format(time.RFC3339))
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "record_pairing_observation", "确认记录配对观察", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "record_pairing_observation",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}

func (s *Server) toolDraftCreateSeparationTask(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
	if sess.SessionID == uuid.Nil {
		return nil, fmt.Errorf("session required for write draft")
	}
	attemptRaw := stringArgMap(args, "attempt_id")
	planRaw := stringArgMap(args, "plan_id")
	if attemptRaw == "" && planRaw == "" {
		return nil, fmt.Errorf("attempt_id or plan_id required")
	}
	var (
		targetType string
		targetID   uuid.UUID
		label      string
	)
	if attemptRaw != "" {
		aid, err := uuid.Parse(attemptRaw)
		if err != nil {
			return nil, fmt.Errorf("invalid attempt_id")
		}
		var status, planName string
		var attemptNo int
		err = s.Store.Pool.QueryRow(ctx, `
			SELECT pa.status::text, pa.attempt_no, COALESCE(p.name,'')
			FROM pairing_attempt pa
			JOIN breeding_plan p ON p.owner_id=pa.owner_id AND p.id=pa.breeding_plan_id
			WHERE pa.owner_id=$1 AND pa.id=$2 AND pa.deleted_at IS NULL
		`, ownerID, aid).Scan(&status, &attemptNo, &planName)
		if err != nil {
			return nil, fmt.Errorf("pairing attempt not found")
		}
		targetType = "pairing_attempt"
		targetID = aid
		label = fmt.Sprintf("配对尝试#%d %s", attemptNo, planName)
		if status != "active" && status != "safety_hold" {
			// still allow reminder for recently active attempts
			label += " (" + status + ")"
		}
	} else {
		pid, err := uuid.Parse(planRaw)
		if err != nil {
			return nil, fmt.Errorf("invalid plan_id")
		}
		var planName, state string
		err = s.Store.Pool.QueryRow(ctx, `
			SELECT COALESCE(name,''), state::text
			FROM breeding_plan WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
		`, ownerID, pid).Scan(&planName, &state)
		if err != nil {
			return nil, fmt.Errorf("breeding plan not found")
		}
		targetType = "breeding_plan"
		targetID = pid
		label = firstNonEmptyName(planName, pid.String()[:8]) + " (" + state + ")"
	}
	scheduledAt := time.Now().UTC().Add(30 * time.Minute)
	if raw := stringArgMap(args, "scheduled_at"); raw != "" {
		if parsed, err := time.Parse(time.RFC3339, raw); err == nil {
			scheduledAt = parsed.UTC()
		}
	}
	priority := stringArgMap(args, "priority")
	if priority == "" {
		priority = "high"
	}
	switch priority {
	case "low", "normal", "high", "urgent", "critical":
	default:
		return nil, fmt.Errorf("invalid priority")
	}
	title := "分笼提醒：" + label
	payload := map[string]any{
		"task_type":    "separate_now",
		"target_type":  targetType,
		"target_id":    targetID.String(),
		"title":        title,
		"scheduled_at": scheduledAt.Format(time.RFC3339),
		"priority":     priority,
	}
	if notes := stringArgMap(args, "notes"); notes != "" {
		payload["notes"] = notes
	}
	summary := fmt.Sprintf("创建分笼任务「%s」@ %s", title, scheduledAt.Format(time.RFC3339))
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "create_separation_task", "确认创建分笼任务", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "create_separation_task",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}

func (s *Server) toolDraftCreateContract(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
	if sess.SessionID == uuid.Nil {
		return nil, fmt.Errorf("session required for write draft")
	}
	if stringArgMap(args, "contact_id") == "" && stringArgMap(args, "reservation_id") == "" && stringArgMap(args, "handover_id") == "" {
		return nil, fmt.Errorf("contact_id, reservation_id, or handover_id required")
	}
	// Validate parties early so draft summary is accurate.
	bound, err := s.bindAssistantDocParties(ctx, ownerID, args)
	if err != nil {
		return nil, err
	}
	templateID, templateName, err := s.resolveDocTemplateID(ctx, ownerID, "contract", stringArgMap(args, "template_id"))
	if err != nil {
		return nil, err
	}
	title := stringArgMap(args, "title")
	if title == "" {
		if bound.HamsterName != "" {
			title = "交接协议 · " + bound.HamsterName
		} else {
			title = templateName
		}
	}
	payload := map[string]any{
		"title": title, "template_id": templateID.String(), "template_name": templateName,
		"contact_name": bound.ContactName,
	}
	if bound.ContactID != nil {
		payload["contact_id"] = bound.ContactID.String()
	}
	if bound.ReservationID != nil {
		payload["reservation_id"] = bound.ReservationID.String()
	}
	if bound.HandoverID != nil {
		payload["handover_id"] = bound.HandoverID.String()
	}
	if notes := stringArgMap(args, "notes"); notes != "" {
		payload["notes"] = notes
	}
	summary := fmt.Sprintf("新建合同草稿「%s」→ %s（模板 %s）", title, firstNonEmptyName(bound.ContactName, "未命名客户"), templateName)
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "create_contract", "确认新建合同草稿", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "create_contract",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}

func (s *Server) toolDraftCreateReceipt(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
	if sess.SessionID == uuid.Nil {
		return nil, fmt.Errorf("session required for write draft")
	}
	if stringArgMap(args, "contact_id") == "" && stringArgMap(args, "reservation_id") == "" && stringArgMap(args, "handover_id") == "" {
		return nil, fmt.Errorf("contact_id, reservation_id, or handover_id required")
	}
	amountCents := int64(0)
	switch v := args["amount_cents"].(type) {
	case float64:
		amountCents = int64(v)
	case int:
		amountCents = int64(v)
	case int64:
		amountCents = v
	default:
		return nil, fmt.Errorf("amount_cents required")
	}
	if amountCents < 0 {
		return nil, domain.NewToolError(domain.ErrAmountNegative, nil)
	}
	currency := stringArgMap(args, "currency")
	if currency == "" {
		currency = "CNY"
	}
	bound, err := s.bindAssistantDocParties(ctx, ownerID, args)
	if err != nil {
		return nil, err
	}
	templateID, templateName, err := s.resolveDocTemplateID(ctx, ownerID, "receipt", stringArgMap(args, "template_id"))
	if err != nil {
		return nil, err
	}
	title := stringArgMap(args, "title")
	if title == "" {
		if bound.HamsterName != "" {
			title = "收款回执 · " + bound.HamsterName
		} else {
			title = templateName
		}
	}
	payload := map[string]any{
		"title": title, "template_id": templateID.String(), "template_name": templateName,
		"amount_cents": amountCents, "currency": currency, "contact_name": bound.ContactName,
	}
	if bound.ContactID != nil {
		payload["contact_id"] = bound.ContactID.String()
	}
	if bound.ReservationID != nil {
		payload["reservation_id"] = bound.ReservationID.String()
	}
	if bound.HandoverID != nil {
		payload["handover_id"] = bound.HandoverID.String()
	}
	if notes := stringArgMap(args, "notes"); notes != "" {
		payload["notes"] = notes
	}
	summary := fmt.Sprintf("新建回执草稿「%s」%.2f %s → %s", title, float64(amountCents)/100.0, currency, firstNonEmptyName(bound.ContactName, "未命名客户"))
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "create_receipt", "确认新建回执草稿", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "create_receipt",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}

func (s *Server) toolListAccountingRecords(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	limit := toolLimit(args, 15, 1, 30)
	entryType := stringArgMap(args, "entry_type")
	days := 30
	if v, ok := args["days"].(float64); ok {
		days = int(v)
		if days < 1 {
			days = 1
		}
		if days > 366 {
			days = 366
		}
	}
	query := `
		SELECT r.id::text, r.entry_type::text, r.amount_cents, r.currency, r.title,
		       COALESCE(r.notes,''), r.occurred_at, COALESCE(ct.name,'')
		FROM accounting_record r
		LEFT JOIN crm_contact ct ON ct.owner_id=r.owner_id AND ct.id=r.contact_id
		WHERE r.owner_id=$1 AND r.occurred_at >= now() - ($2 * interval '1 day')`
	qargs := []any{ownerID, days}
	argN := 3
	if entryType != "" {
		if entryType != "income" && entryType != "expense" {
			return nil, domain.NewToolError(domain.ErrInvalidEntryType, nil)
		}
		query += fmt.Sprintf(` AND r.entry_type=$%d::accounting_entry_type`, argN)
		qargs = append(qargs, entryType)
		argN++
	}
	query += fmt.Sprintf(` ORDER BY r.occurred_at DESC, r.id DESC LIMIT $%d`, argN)
	qargs = append(qargs, limit)
	rows, err := s.Store.Pool.Query(ctx, query, qargs...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]map[string]any, 0)
	for rows.Next() {
		var id, et, currency, title, notes, contactName string
		var amount int64
		var occurred any
		if err := rows.Scan(&id, &et, &amount, &currency, &title, &notes, &occurred, &contactName); err != nil {
			return nil, err
		}
		item := map[string]any{
			"id": id, "entry_type": et, "amount_cents": amount, "currency": currency,
			"title": title, "occurred_at": occurred, "amount_yuan": float64(amount) / 100.0,
		}
		if notes != "" {
			item["notes"] = notes
		}
		if contactName != "" {
			item["contact_name"] = contactName
		}
		out = append(out, item)
	}
	return map[string]any{"count": len(out), "days": days, "records": out}, rows.Err()
}

func (s *Server) toolListHealthRecords(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	limit := toolLimit(args, 15, 1, 30)
	recType := stringArgMap(args, "type")
	hamsterRaw := stringArgMap(args, "hamster_id")
	query := `
		SELECT hr.id::text, hr.record_type::text, hr.observed_at, hr.severity::text,
		       COALESCE(hr.notes,''), hr.hamster_id::text,
		       COALESCE(h.name,''), COALESCE(h.internal_code,'')
		FROM health_record hr
		LEFT JOIN hamster h ON h.owner_id=hr.owner_id AND h.id=hr.hamster_id AND h.deleted_at IS NULL
		WHERE hr.owner_id=$1`
	qargs := []any{ownerID}
	argN := 2
	if hamsterRaw != "" {
		hid, err := uuid.Parse(hamsterRaw)
		if err != nil {
			return nil, fmt.Errorf("invalid hamster_id")
		}
		query += fmt.Sprintf(` AND hr.hamster_id=$%d`, argN)
		qargs = append(qargs, hid)
		argN++
	}
	if recType != "" {
		switch recType {
		case "daily_check", "anomaly", "medication", "follow_up", "isolation", "death":
		default:
			return nil, fmt.Errorf("invalid health record type")
		}
		query += fmt.Sprintf(` AND hr.record_type::text=$%d`, argN)
		qargs = append(qargs, recType)
		argN++
	}
	query += fmt.Sprintf(` ORDER BY hr.observed_at DESC LIMIT $%d`, argN)
	qargs = append(qargs, limit)
	rows, err := s.Store.Pool.Query(ctx, query, qargs...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]map[string]any, 0)
	for rows.Next() {
		var id, typ, notes, name, code string
		var observed any
		var severity, hamsterID *string
		if err := rows.Scan(&id, &typ, &observed, &severity, &notes, &hamsterID, &name, &code); err != nil {
			return nil, err
		}
		item := map[string]any{
			"id": id, "type": typ, "observed_at": observed,
			"hamster_name": name, "internal_code": code,
		}
		if severity != nil && *severity != "" {
			item["severity"] = *severity
		}
		if notes != "" {
			item["notes"] = notes
		}
		if hamsterID != nil {
			item["hamster_id"] = *hamsterID
		}
		out = append(out, item)
	}
	return map[string]any{"count": len(out), "records": out}, rows.Err()
}

func (s *Server) toolDraftConfirmCrmReservation(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
	if sess.SessionID == uuid.Nil {
		return nil, fmt.Errorf("session required for write draft")
	}
	reservationID, err := uuid.Parse(stringArgMap(args, "reservation_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid reservation_id")
	}
	var title, status, contactName string
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT r.title, r.status::text, c.name
		FROM crm_reservation r
		JOIN crm_contact c ON c.owner_id=r.owner_id AND c.id=r.contact_id
		WHERE r.owner_id=$1 AND r.id=$2
	`, ownerID, reservationID).Scan(&title, &status, &contactName)
	if err != nil {
		return nil, fmt.Errorf("reservation not found")
	}
	if status != "held" {
		return nil, domain.NewToolError(domain.ErrReservationNotHeld, map[string]any{"current": status})
	}
	payload := map[string]any{
		"reservation_id": reservationID.String(),
		"title":          title,
		"contact_name":   contactName,
		"current_status": status,
	}
	summary := fmt.Sprintf("确认预订「%s」→ 客户 %s", title, contactName)
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "confirm_crm_reservation", "确认预订", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "confirm_crm_reservation",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}

func (s *Server) toolDraftCancelCrmReservation(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
	if sess.SessionID == uuid.Nil {
		return nil, fmt.Errorf("session required for write draft")
	}
	reservationID, err := uuid.Parse(stringArgMap(args, "reservation_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid reservation_id")
	}
	var title, status, contactName string
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT r.title, r.status::text, c.name
		FROM crm_reservation r
		JOIN crm_contact c ON c.owner_id=r.owner_id AND c.id=r.contact_id
		WHERE r.owner_id=$1 AND r.id=$2
	`, ownerID, reservationID).Scan(&title, &status, &contactName)
	if err != nil {
		return nil, fmt.Errorf("reservation not found")
	}
	if status != "held" && status != "confirmed" {
		return nil, domain.NewToolError(domain.ErrReservationNotCancellable, map[string]any{"status": status})
	}
	payload := map[string]any{
		"reservation_id": reservationID.String(),
		"title":          title,
		"contact_name":   contactName,
		"current_status": status,
	}
	summary := fmt.Sprintf("取消预订「%s」→ 客户 %s（当前 %s）", title, contactName, status)
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "cancel_crm_reservation", "确认取消预订", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "cancel_crm_reservation",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}

func (s *Server) toolDraftCompleteCrmHandover(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
	if sess.SessionID == uuid.Nil {
		return nil, fmt.Errorf("session required for write draft")
	}
	handoverID, err := uuid.Parse(stringArgMap(args, "handover_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid handover_id")
	}
	var status, contactName string
	var hamsterID *uuid.UUID
	var hamsterLabel *string
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT h.status::text, c.name, h.hamster_id,
		       CASE WHEN hamster.id IS NULL THEN NULL ELSE COALESCE(NULLIF(hamster.name,''), hamster.internal_code) END
		FROM crm_handover h
		JOIN crm_contact c ON c.owner_id=h.owner_id AND c.id=h.contact_id
		LEFT JOIN hamster ON hamster.owner_id=h.owner_id AND hamster.id=h.hamster_id AND hamster.deleted_at IS NULL
		WHERE h.owner_id=$1 AND h.id=$2
	`, ownerID, handoverID).Scan(&status, &contactName, &hamsterID, &hamsterLabel)
	if err != nil {
		return nil, fmt.Errorf("handover not found")
	}
	if status != "scheduled" {
		return nil, domain.NewToolError(domain.ErrHandoverNotScheduled, map[string]any{"current": status})
	}
	payload := map[string]any{
		"handover_id": handoverID.String(), "contact_name": contactName, "current_status": status,
	}
	if hamsterID != nil {
		payload["hamster_id"] = hamsterID.String()
	}
	if hamsterLabel != nil {
		payload["hamster_name"] = *hamsterLabel
	}
	label := contactName
	if hamsterLabel != nil {
		label = contactName + " / " + *hamsterLabel
	}
	summary := fmt.Sprintf("完成交付 → %s（将转出仓鼠）", label)
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "complete_crm_handover", "确认完成交付", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "complete_crm_handover",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}
