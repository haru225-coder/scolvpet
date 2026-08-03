package httpapi

import (
	"context"
	"errors"
	"strings"
	"testing"

	"github.com/google/uuid"

	"github.com/scolvpet/scolvpet/api/internal/domain"
)

// TestMapAssistantToolErrorCodeChannel 验证类型化错误 code → 中文文案：
// 每条状态/业务错误都断言「用户可见文案含状态/原因信息」且「不含英文原文」。
func TestMapAssistantToolErrorCodeChannel(t *testing.T) {
	cases := []struct {
		name string
		code string
		params map[string]any
		want  []string // 必须全部包含
	}{
		{
			name:   "task not open with status",
			code:   domain.ErrTaskNotOpen,
			params: map[string]any{"status": "completed"},
			want:   []string{"该任务当前为", "已完成", "无法执行此操作"},
		},
		{
			name:   "task not open cancelled status",
			code:   domain.ErrTaskNotOpen,
			params: map[string]any{"status": "cancelled"},
			want:   []string{"该任务当前为", "已取消"},
		},
		{
			name:   "pairing not open for observation",
			code:   domain.ErrPairingNotOpenForObservation,
			params: map[string]any{"status": "separated"},
			want:   []string{"该配对记录当前为", "已分离", "无法记录观察"},
		},
		{
			name:   "reservation not held with current",
			code:   domain.ErrReservationNotHeld,
			params: map[string]any{"current": "confirmed"},
			want:   []string{"当前预订状态为", "已确认", "仅", "已保留", "可以确认"},
		},
		{
			name:   "reservation not held no current",
			code:   domain.ErrReservationNotHeld,
			params: nil,
			want:   []string{"仅", "已保留", "的预订可以确认"},
		},
		{
			name:   "reservation hold expired",
			code:   domain.ErrReservationHoldExpired,
			params: nil,
			want:   []string{"预订保留已过期"},
		},
		{
			name:   "reservation not cancellable",
			code:   domain.ErrReservationNotCancellable,
			params: map[string]any{"status": "handed_over"},
			want:   []string{"当前预订状态为", "已交付", "无法取消"},
		},
		{
			name:   "handover not scheduled with current",
			code:   domain.ErrHandoverNotScheduled,
			params: map[string]any{"current": "completed"},
			want:   []string{"当前交付状态为", "已完成", "仅", "已排期"},
		},
		{
			name:   "handover not scheduled no current",
			code:   domain.ErrHandoverNotScheduled,
			params: nil,
			want:   []string{"仅", "已排期", "的交付可以完成"},
		},
		{
			name:   "reservation not open for handover",
			code:   domain.ErrReservationNotOpenForHandover,
			params: map[string]any{"current": "held"},
			want:   []string{"当前预订状态为", "已保留", "无法安排交付"},
		},
		{
			name:   "reservation already has handover",
			code:   domain.ErrReservationAlreadyHasHandover,
			params: nil,
			want:   []string{"该预订已有关联交付记录"},
		},
		{
			name:   "archived contact cannot reserve",
			code:   domain.ErrArchivedContactCannotReserve,
			params: nil,
			want:   []string{"已归档客户不能新增预订"},
		},
		{
			name:   "archived contact cannot handover",
			code:   domain.ErrArchivedContactCannotHandover,
			params: nil,
			want:   []string{"已归档客户不能发起交付"},
		},
		{
			name:   "hamster not reservable",
			code:   domain.ErrHamsterNotReservable,
			params: nil,
			want:   []string{"该仓鼠当前不可预订"},
		},
		{
			name:   "hamster already reserved",
			code:   domain.ErrHamsterAlreadyReserved,
			params: nil,
			want:   []string{"该仓鼠已有有效预订"},
		},
		{
			name:   "hamster not active",
			code:   domain.ErrHamsterNotActive,
			params: nil,
			want:   []string{"该仓鼠不在活跃状态"},
		},
		{
			name:   "hamster not transferable",
			code:   domain.ErrHamsterNotTransferable,
			params: nil,
			want:   []string{"该仓鼠当前不可转移"},
		},
		{
			name:   "handover missing hamster",
			code:   domain.ErrHandoverMissingHamster,
			params: nil,
			want:   []string{"交付记录缺少仓鼠信息"},
		},
		{
			name:   "no species rule",
			code:   domain.ErrNoSpeciesRule,
			params: nil,
			want:   []string{"未配置可用的品种规则"},
		},
		{
			name:   "no doc template contract",
			code:   domain.ErrNoDocTemplate,
			params: map[string]any{"kind": "contract"},
			want:   []string{"暂无", "合同", "模板"},
		},
		{
			name:   "no doc template receipt",
			code:   domain.ErrNoDocTemplate,
			params: map[string]any{"kind": "receipt"},
			want:   []string{"暂无", "回执", "模板"},
		},
		{
			name:   "observed at outside window",
			code:   domain.ErrObservedAtOutsideWindow,
			params: nil,
			want:   []string{"观察时间超出配对窗口"},
		},
		{
			name:   "invalid sex",
			code:   domain.ErrInvalidSex,
			params: nil,
			want:   []string{"性别必须为"},
		},
		{
			name:   "no fields to update",
			code:   domain.ErrNoFieldsToUpdate,
			params: nil,
			want:   []string{"没有可更新的字段"},
		},
		{
			name:   "invalid entry type",
			code:   domain.ErrInvalidEntryType,
			params: nil,
			want:   []string{"收支类型必须为"},
		},
		{
			name:   "amount negative",
			code:   domain.ErrAmountNegative,
			params: nil,
			want:   []string{"金额不能为负数"},
		},
		{
			name:   "amount not positive",
			code:   domain.ErrAmountNotPositive,
			params: nil,
			want:   []string{"金额必须大于 0"},
		},
		{
			name:   "invalid doc status",
			code:   domain.ErrInvalidDocStatus,
			params: nil,
			want:   []string{"单据状态必须为"},
		},
		{
			name:   "invalid doc kind",
			code:   domain.ErrInvalidDocKind,
			params: nil,
			want:   []string{"单据类型必须为"},
		},
		{
			name:   "invalid observation type (conflict keyword must not be sniffed)",
			code:   domain.ErrInvalidObservationType,
			params: nil,
			want:   []string{"观察类型必须为"},
		},
		{
			name:   "operation conflict",
			code:   domain.ErrOperationConflict,
			params: nil,
			want:   []string{"操作冲突，数据已被他人修改"},
		},
		{
			name:   "reservation mismatch",
			code:   domain.ErrReservationMismatch,
			params: nil,
			want:   []string{"预订关联的客户或仓鼠与本次操作不一致"},
		},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			got := mapAssistantToolError(domain.NewToolError(tc.code, tc.params))
			if got == nil {
				t.Fatalf("code %q: want non-nil error", tc.code)
			}
			msg := got.Error()
			for _, w := range tc.want {
				if !strings.Contains(msg, w) {
					t.Fatalf("code %q: msg %q missing %q", tc.code, msg, w)
				}
			}
			// 用户可见文案不得含英文错误原文（ASCII 字母；产品名 App 除外）。
			if leaked := asciiLeak(msg); leaked != "" {
				t.Fatalf("code %q: msg %q leaks ascii text %q", tc.code, msg, leaked)
			}
			if errors.Is(got, errOperationFailed) {
				t.Fatalf("code %q: must not collapse to sentinel", tc.code)
			}
		})
	}
}

// TestMapAssistantToolErrorTransitionLayer 保留过渡层（containsCJK 透传 +
// 关键词 switch）行为，迁移到 code 通道后删除本测试。
func TestMapAssistantToolErrorTransitionLayer(t *testing.T) {
	cases := []struct {
		name string
		in   string
		want string
	}{
		{"nil passthrough", "", ""},
		{"chinese kept verbatim", "数据库不可用", "数据库不可用"},
		// 中文模板内嵌英文关键词（如用户查询词恰为 "conflict"）不得被 switch 误映射。
		{"chinese with english keyword kept", "没有匹配的未完成任务（查询词：conflict），可先 list_tasks 查看全部任务", "没有匹配的未完成任务"},
		{"not found mapped", "hamster not found", "找不到对应记录"},
		{"session required mapped", "session required for write draft", "写操作需要有效会话"},
		{"required mapped", "target_type, target_id, title required", "缺少必要参数"},
		{"invalid mapped", "invalid task_id", "参数无效"},
		{"conflict mapped", "conflict: status changed", "操作冲突"},
		{"unknown tool mapped", "unknown tool foo", "不支持的工具"},
		{"unsupported action mapped", "unsupported action type bar", "不支持的确认动作"},
		{"unknown english falls back", "internal: pgx connect failed", "操作失败，请稍后重试"},
		// 内嵌用户数据的中文模板原样保留（用户友好）。
		{"chinese template with data kept", "没有匹配的未完成任务（查询词：雪球），可先 list_tasks 查看全部任务", "没有匹配的未完成任务"},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			var err error
			if tc.in != "" {
				err = errors.New(tc.in)
			}
			got := mapAssistantToolError(err)
			if tc.want == "" {
				if got != nil {
					t.Fatalf("want nil, got %v", got)
				}
				return
			}
			if got == nil || !strings.Contains(got.Error(), tc.want) {
				t.Fatalf("in=%q want contains %q, got %v", tc.in, tc.want, got)
			}
		})
	}
}

// TestMapAssistantToolErrorUnknownIsSentinel 验证哨兵只在真正 unknown 时命中，
// 且必须是 errors.Is 可识别的哨兵（runAssistantTool 据此 Warn 原始错误）。
func TestMapAssistantToolErrorUnknownIsSentinel(t *testing.T) {
	err := mapAssistantToolError(errors.New("some unexpected english error"))
	if !errors.Is(err, errOperationFailed) {
		t.Fatalf("want errOperationFailed sentinel, got %v", err)
	}
}

// TestMapAssistantToolErrorUnmappedCodeIsSentinel 验证未注册 code 收敛为哨兵
// 而非泄漏内部 code。
func TestMapAssistantToolErrorUnmappedCodeIsSentinel(t *testing.T) {
	err := mapAssistantToolError(domain.NewToolError("code_not_registered_anywhere", nil))
	if !errors.Is(err, errOperationFailed) {
		t.Fatalf("want errOperationFailed sentinel for unmapped code, got %v", err)
	}
}

func TestContainsCJK(t *testing.T) {
	cases := []struct {
		in   string
		want bool
	}{
		{"数据库不可用", true},
		{"找不到对应记录（record not found）", true},
		{"no open task matches query", false},
		{"connection refused", false},
		{"", false},
	}
	for _, tc := range cases {
		if got := containsCJK(tc.in); got != tc.want {
			t.Fatalf("containsCJK(%q)=%v, want %v", tc.in, got, tc.want)
		}
	}
}

// TestToolErrorEndToEndCodeChannel 是 R2 code 通道的端到端样例：
// 真实源头（executeAssistantAction 的参数校验分支，不依赖 DB）返回类型化
// ToolError，经 mapAssistantToolError 后用户看到中文文案，且不含英文原文、
// 不落入哨兵。confirm 执行失败路径（p2_assistant.go）复用同一映射。
func TestToolErrorEndToEndCodeChannel(t *testing.T) {
	srv := NewServer(nil, nil, nil)
	_, err := srv.executeAssistantAction(context.Background(), uuid.New(), "record_pairing_observation", map[string]any{
		"attempt_id": uuid.NewString(),
		"type":       "not_a_real_type",
	})
	if err == nil {
		t.Fatal("want error for invalid observation type")
	}
	var toolErr *domain.ToolError
	if !errors.As(err, &toolErr) {
		t.Fatalf("want *domain.ToolError from source, got %T: %v", err, err)
	}
	if toolErr.Code != domain.ErrInvalidObservationType {
		t.Fatalf("want code %q, got %q", domain.ErrInvalidObservationType, toolErr.Code)
	}
	userMsg := mapAssistantToolError(err)
	if userMsg == nil || errors.Is(userMsg, errOperationFailed) {
		t.Fatalf("user-visible error must not be sentinel: %v", userMsg)
	}
	got := userMsg.Error()
	if !strings.Contains(got, "观察类型必须为") {
		t.Fatalf("want chinese observation-type message, got %q", got)
	}
	if asciiLeak(got) != "" {
		t.Fatalf("user message leaks english: %q", got)
	}
}

func containsASCII(s string) bool {
	for _, r := range s {
		if r >= 'A' && r <= 'Z' || r >= 'a' && r <= 'z' {
			return true
		}
	}
	return false
}

// asciiLeak 返回消息中出现的 ASCII 字母序列；产品名 App 除外
// （App 是产品名而非英文错误原文）。
func asciiLeak(s string) string {
	trimmed := strings.ReplaceAll(s, "App", "")
	var leak strings.Builder
	for _, r := range trimmed {
		if r >= 'A' && r <= 'Z' || r >= 'a' && r <= 'z' {
			leak.WriteRune(r)
		}
	}
	return leak.String()
}
