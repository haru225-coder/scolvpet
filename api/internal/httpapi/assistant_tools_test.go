package httpapi

import (
	"errors"
	"strings"
	"testing"
)

func TestMapAssistantToolError(t *testing.T) {
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
		// 内嵌用户数据的中文模板原样保留（用户友好）。「英文模板+中文数据」
		// 的场景已由源头中文化（resolveOpenTaskForComplete）消除，不再出现。
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

func TestMapAssistantToolErrorUnknownIsSentinel(t *testing.T) {
	err := mapAssistantToolError(errors.New("some unexpected english error"))
	if !errors.Is(err, errOperationFailed) {
		t.Fatalf("want errOperationFailed sentinel, got %v", err)
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
