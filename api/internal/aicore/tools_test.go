package aicore

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestChatWithToolCalls(t *testing.T) {
	round := 0
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		round++
		if round == 1 {
			_ = json.NewEncoder(w).Encode(map[string]any{
				"choices": []map[string]any{
					{
						"message": map[string]any{
							"role":    "assistant",
							"content": nil,
							"tool_calls": []map[string]any{
								{
									"id":   "call_1",
									"type": "function",
									"function": map[string]any{
										"name":      "get_overview",
										"arguments": `{}`,
									},
								},
							},
						},
						"finish_reason": "tool_calls",
					},
				},
			})
			return
		}
		_ = json.NewEncoder(w).Encode(map[string]any{
			"choices": []map[string]any{
				{
					"message": map[string]any{
						"role":    "assistant",
						"content": "根据工具结果，本舍在养 2 只。",
					},
					"finish_reason": "stop",
				},
			},
		})
	}))
	defer server.Close()

	called := false
	client := &OptionalLLMClient{
		APIKey:  "test",
		BaseURL: server.URL + "/v1",
		Model:   "grok-build-0.1",
		HTTP:    server.Client(),
	}
	answer, err := client.Chat(context.Background(), ChatRequest{
		UserMessage: "有多少只在养？",
		PreferLLM:   true,
		Tools:       ReadOnlyToolDefinitions(),
		RunTool: func(ctx context.Context, name string, args map[string]any) (any, error) {
			called = true
			if name != "get_overview" {
				t.Fatalf("tool=%s", name)
			}
			return map[string]any{"active_hamsters": 2}, nil
		},
	})
	if err != nil {
		t.Fatal(err)
	}
	if !called {
		t.Fatal("tool not called")
	}
	if answer.Mode != "llm" || !strings.Contains(answer.Answer, "2") {
		t.Fatalf("%+v", answer)
	}
	if len(answer.Facts) == 0 || !strings.Contains(answer.Facts[0].Key, "tool:") {
		t.Fatalf("facts=%+v", answer.Facts)
	}
}

func TestReadOnlyToolDefinitionsNonEmpty(t *testing.T) {
	if len(ReadOnlyToolDefinitions()) < 4 {
		t.Fatal("expected tools")
	}
}
