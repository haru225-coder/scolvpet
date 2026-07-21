package aicore

import (
	"context"
	"encoding/json"
	"io"
	"net/http"
	"strings"
	"testing"
)

func TestRunAgentParsesStructuredAction(t *testing.T) {
	httpClient := &http.Client{Transport: roundTripFunc(func(r *http.Request) (*http.Response, error) {
		if got := r.Header.Get("Authorization"); got != "Bearer test-key" {
			t.Fatalf("authorization=%q", got)
		}
		var request map[string]any
		if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
			t.Fatal(err)
		}
		if request["model"] != "test-model" {
			t.Fatalf("model=%v", request["model"])
		}
		bodyBytes, err := json.Marshal(map[string]any{
			"choices": []map[string]any{{
				"message": map[string]any{
					"content": `{"answer":"建议给雪团安排称重。","actions":[{"type":"task_draft","label":"查看称重任务","summary":"一小时后称重","requires_confirmation":true,"payload":{"task_type":"custom","target_type":"hamster","target_id":"hamster-1"}}]}`,
				},
			}},
		})
		if err != nil {
			t.Fatal(err)
		}
		return &http.Response{
			StatusCode: http.StatusOK,
			Header:     make(http.Header),
			Body:       io.NopCloser(strings.NewReader(string(bodyBytes))),
			Request:    r,
		}, nil
	})}

	client := &OptionalLLMClient{
		APIKey: "test-key", BaseURL: "https://agent.test/v1", Model: "test-model", HTTP: httpClient,
	}
	rules := Answer{Answer: "规则回答", Intent: IntentTasks, Mode: "rules"}
	answer, err := client.RunAgent(context.Background(), "安排称重", rules, map[string]any{
		"hamsters": []map[string]any{{"id": "hamster-1", "name": "雪团"}},
	})
	if err != nil {
		t.Fatal(err)
	}
	if answer.Mode != "llm" || len(answer.Actions) != 1 {
		t.Fatalf("answer=%+v", answer)
	}
	if answer.Actions[0].Payload["target_id"] != "hamster-1" {
		t.Fatalf("action=%+v", answer.Actions[0])
	}
}

type roundTripFunc func(*http.Request) (*http.Response, error)

func (fn roundTripFunc) RoundTrip(request *http.Request) (*http.Response, error) {
	return fn(request)
}
