package aicore

import (
	"context"
	"encoding/json"
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
