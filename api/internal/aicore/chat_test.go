package aicore

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"
)

func TestChatFallsBackWithoutKey(t *testing.T) {
	var client *OptionalLLMClient
	snap := Snapshot{OrganizationName: "测试舍", ActiveHamsters: 3, GeneratedAt: time.Now().UTC()}
	answer, err := client.Chat(context.Background(), ChatRequest{
		UserMessage: "现在有多少只在养？",
		PreferLLM:   true,
		Snapshot:    &snap,
	})
	if err != nil {
		t.Fatal(err)
	}
	if answer.Mode != "rules" || !strings.Contains(answer.Answer, "3") {
		t.Fatalf("answer=%+v", answer)
	}
}

func TestChatUsesLLMWhenConfigured(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/v1/chat/completions" {
			http.NotFound(w, r)
			return
		}
		_ = json.NewEncoder(w).Encode(map[string]any{
			"choices": []map[string]any{
				{"message": map[string]string{"content": "你好，我是熊舍管家助手。"}},
			},
		})
	}))
	defer server.Close()

	client := &OptionalLLMClient{
		APIKey:  "test",
		BaseURL: server.URL + "/v1",
		Model:   "grok-build-0.1",
		HTTP:    server.Client(),
	}
	answer, err := client.Chat(context.Background(), ChatRequest{
		UserMessage: "你好",
		PreferLLM:   true,
		KennelFacts: "在养=1",
	})
	if err != nil {
		t.Fatal(err)
	}
	if answer.Mode != "llm" || !strings.Contains(answer.Answer, "熊舍") {
		t.Fatalf("answer=%+v", answer)
	}
}

func TestFormatKennelFacts(t *testing.T) {
	s := FormatKennelFacts(Snapshot{OrganizationName: "云朵", ActiveHamsters: 2, GeneratedAt: time.Unix(0, 0).UTC()})
	if !strings.Contains(s, "云朵") || !strings.Contains(s, "在养=2") {
		t.Fatal(s)
	}
}

func TestGeneralChatSystemPromptIsAgentic(t *testing.T) {
	p := generalChatSystemPrompt("在养=3", true)
	if strings.Contains(p, "只读助手") || strings.Contains(p, "Grok Build") {
		t.Fatalf("prompt still sounds read-only/legacy: %s", p)
	}
	if !strings.Contains(p, "get_overview") || !strings.Contains(p, "待确认") {
		t.Fatalf("prompt missing tool guidance: %s", p)
	}
	// Domain-oriented prompt should stay compact (not dump every tool twice).
	if len(p) > 2800 {
		t.Fatalf("prompt too long (%d chars); keep scenario map compact", len(p))
	}
	for _, need := range []string{"CRM", "财务", "单据", "繁育", "任务"} {
		if !strings.Contains(p, need) {
			t.Fatalf("prompt missing domain cue %q", need)
		}
	}
}

func TestSynthesizeFromTools(t *testing.T) {
	ans := synthesizeFromTools(
		[]Fact{{Key: "tool:get_overview", Label: "工具 get_overview", Value: `{"open_tasks":2}`, Source: "tool"}},
		[]AgentAction{{Type: "create_task", Label: "创建任务", Summary: "给布丁建清洁任务", RequiresConfirmation: true}},
	)
	if ans.Mode != "llm" || !strings.Contains(ans.Answer, "待确认") {
		t.Fatalf("%+v", ans)
	}
}

func toolCallMessage(name, id string) map[string]any {
	return map[string]any{
		"content": "",
		"tool_calls": []map[string]any{
			{"id": id, "type": "function", "function": map[string]any{"name": name, "arguments": "{}"}},
		},
	}
}

// TestGeneralChatSurfacesToolErrorFact verifies that a failing tool call is
// recorded as a structured tool_error fact and the conversation still lands
// on an LLM answer instead of failing the whole turn.
func TestGeneralChatSurfacesToolErrorFact(t *testing.T) {
	var rounds int
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		rounds++
		if rounds == 1 {
			_ = json.NewEncoder(w).Encode(map[string]any{
				"choices": []map[string]any{{"message": toolCallMessage("get_overview", "call_1")}},
			})
			return
		}
		_ = json.NewEncoder(w).Encode(map[string]any{
			"choices": []map[string]any{{"message": map[string]string{"content": "查询失败了，请稍后再试。"}}},
		})
	}))
	defer server.Close()

	client := &OptionalLLMClient{
		APIKey:  "test",
		BaseURL: server.URL + "/v1",
		Model:   "deepseek-v4-flash-0731",
		HTTP:    server.Client(),
	}
	answer, err := client.Chat(context.Background(), ChatRequest{
		UserMessage: "查一下概况",
		PreferLLM:   true,
		Tools:       ReadOnlyToolDefinitions(),
		RunTool: func(ctx context.Context, name string, args map[string]any) (any, error) {
			return nil, fmt.Errorf("get_overview 查询失败: 数据库连接超时")
		},
	})
	if err != nil {
		t.Fatal(err)
	}
	// 注：answer 文案来自 mock 固定返回，本测试的核心断言是下方
	// tool_error fact 已进入 Answer.Facts（工具失败的结构化透出链路）。
	if answer.Mode != "llm" || !strings.Contains(answer.Answer, "稍后再试") {
		t.Fatalf("answer=%+v", answer)
	}
	var found bool
	for _, f := range answer.Facts {
		if strings.HasPrefix(f.Key, "tool_error:") && strings.Contains(f.Value, "连接超时") {
			found = true
		}
	}
	if !found {
		t.Fatalf("facts missing tool_error entry: %+v", answer.Facts)
	}
}

// TestGeneralChatWindsDownToolLoop verifies the wind-down branch: when the
// model keeps requesting tools, the final rounds drop tools and force a
// synthesis, falling back to partial tool facts instead of "tool loop exceeded".
func TestGeneralChatWindsDownToolLoop(t *testing.T) {
	type recorded struct {
		hasTools bool
		messages []map[string]any
	}
	var reqs []recorded
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var payload map[string]any
		_ = json.NewDecoder(r.Body).Decode(&payload)
		_, hasTools := payload["tools"]
		rawMsgs, _ := payload["messages"].([]any)
		var msgs []map[string]any
		for _, m := range rawMsgs {
			if mm, ok := m.(map[string]any); ok {
				msgs = append(msgs, mm)
			}
		}
		reqs = append(reqs, recorded{hasTools: hasTools, messages: msgs})
		_ = json.NewEncoder(w).Encode(map[string]any{
			"choices": []map[string]any{{"message": toolCallMessage("get_overview", "call_1")}},
		})
	}))
	defer server.Close()

	client := &OptionalLLMClient{
		APIKey:  "test",
		BaseURL: server.URL + "/v1",
		Model:   "deepseek-v4-flash-0731",
		HTTP:    server.Client(),
	}
	answer, err := client.Chat(context.Background(), ChatRequest{
		UserMessage: "查一下概况",
		PreferLLM:   true,
		Tools:       ReadOnlyToolDefinitions(),
		RunTool: func(ctx context.Context, name string, args map[string]any) (any, error) {
			return map[string]any{"active_hamsters": 3}, nil
		},
	})
	if err != nil {
		t.Fatal(err)
	}
	// The loop must wind down to a synthesized answer instead of failing.
	if answer.Mode != "llm" || !strings.Contains(answer.Answer, "已查到本舍相关数据") {
		t.Fatalf("expected synthesis fallback, got %+v", answer)
	}
	// At least one final round must be tool-less, with an explicit wind-down cue.
	var sawNoTools, sawWindDown bool
	for _, req := range reqs {
		if !req.hasTools {
			sawNoTools = true
		}
		for _, m := range req.messages {
			if content, _ := m["content"].(string); strings.Contains(content, "不要再调用工具") {
				sawWindDown = true
			}
		}
	}
	if !sawNoTools || !sawWindDown {
		t.Fatalf("expected wind-down round; sawNoTools=%v sawWindDown=%v reqs=%d", sawNoTools, sawWindDown, len(reqs))
	}
}
