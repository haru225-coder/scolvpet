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
	defs := ReadOnlyToolDefinitions()
	if len(defs) < 12 {
		t.Fatalf("expected expanded toolset, got %d", len(defs))
	}
	names := map[string]bool{}
	for _, d := range defs {
		names[d.Function.Name] = true
	}
	for _, need := range []string{
		"get_hamster", "list_crm_contacts", "get_crm_contact",
		"list_crm_reservations", "get_crm_reservation",
		"list_crm_handovers", "get_crm_handover",
		"list_accounting_summary", "list_accounting_records", "search_docs", "get_doc", "list_doc_templates",
		"list_recent_weights", "list_health_records",
		"list_breeding_plans", "get_breeding_plan", "list_pairing_attempts",
		"create_crm_contact", "update_crm_contact", "create_crm_reservation",
		"confirm_crm_reservation", "cancel_crm_reservation",
		"create_crm_handover", "complete_crm_handover",
		"create_accounting_record", "create_health_record",
		"record_pairing_observation", "create_separation_task",
		"create_contract", "create_receipt",
	} {
		if !names[need] {
			t.Fatalf("missing tool %s", need)
		}
	}
}
