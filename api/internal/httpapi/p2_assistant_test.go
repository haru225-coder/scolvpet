package httpapi

import (
	"bytes"
	"context"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/google/uuid"

	"github.com/scolvpet/scolvpet/api/internal/aicore"
	"github.com/scolvpet/scolvpet/api/internal/auth"
	"github.com/scolvpet/scolvpet/api/internal/store"
)

func TestP2AssistantRoutesRequireAuth(t *testing.T) {
	server := NewServer(nil, auth.New("test", "123456"), slog.Default())
	mux := http.NewServeMux()
	server.registerP2AssistantRoutes(mux)
	for _, path := range []struct {
		method string
		path   string
	}{
		{http.MethodPost, "/v1/assistant/ask"},
		{http.MethodGet, "/v1/assistant/capabilities"},
		{http.MethodPost, "/v1/assistant/chat"},
		{http.MethodGet, "/v1/assistant/sessions"},
		{http.MethodPost, "/v1/assistant/sessions"},
		{http.MethodPost, "/v1/assistant/actions/00000000-0000-0000-0000-000000000001/confirm"},
	} {
		recorder := httptest.NewRecorder()
		request := httptest.NewRequest(path.method, path.path, nil)
		mux.ServeHTTP(recorder, request)
		if recorder.Code != http.StatusUnauthorized {
			t.Fatalf("%s %s expected 401, got %d", path.method, path.path, recorder.Code)
		}
	}
}

func TestConfirmAssistantActionRequiresIdempotencyKey(t *testing.T) {
	server := NewServer(nil, auth.New("test", "123456"), slog.Default())
	mux := http.NewServeMux()
	server.registerP2AssistantRoutes(mux)
	ownerID := uuid.New()
	token, _, err := server.Auth.CreateSession(context.Background(), ownerID)
	if err != nil {
		t.Fatal(err)
	}
	request := httptest.NewRequest(
		http.MethodPost,
		"/v1/assistant/actions/00000000-0000-0000-0000-000000000001/confirm",
		nil,
	)
	request = request.WithContext(context.WithValue(request.Context(), requestPrincipalContextKey{}, store.Principal{
		AccountID: ownerID,
		OwnerID:   ownerID,
		Role:      "owner",
	}))
	request.Header.Set("Authorization", "Bearer "+token)
	// Intentionally omit Idempotency-Key.
	recorder := httptest.NewRecorder()
	mux.ServeHTTP(recorder, request)
	if recorder.Code != http.StatusUnprocessableEntity {
		t.Fatalf("status=%d body=%s", recorder.Code, recorder.Body.String())
	}
}

func TestCreateAssistantSessionRejectsMalformedBody(t *testing.T) {
	server := NewServer(nil, auth.New("test", "123456"), slog.Default())
	mux := http.NewServeMux()
	server.registerP2AssistantRoutes(mux)
	ownerID := uuid.New()
	request := httptest.NewRequest(http.MethodPost, "/v1/assistant/sessions", bytes.NewBufferString(`{"title":`))
	request = request.WithContext(context.WithValue(request.Context(), requestPrincipalContextKey{}, store.Principal{
		AccountID: ownerID,
		OwnerID:   ownerID,
		Role:      "owner",
	}))
	token, _, err := server.Auth.CreateSession(context.Background(), ownerID)
	if err != nil {
		t.Fatal(err)
	}
	request.Header.Set("Authorization", "Bearer "+token)
	recorder := httptest.NewRecorder()
	mux.ServeHTTP(recorder, request)
	if recorder.Code != http.StatusUnprocessableEntity {
		t.Fatalf("status=%d body=%s", recorder.Code, recorder.Body.String())
	}
}

func TestSanitizeAssistantActionsScopesTargetsAndConfirmsWrites(t *testing.T) {
	contextValue := map[string]any{
		"hamsters":        []map[string]any{{"id": "hamster-1"}},
		"enclosures":      []map[string]any{{"id": "enclosure-1"}},
		"organization_id": "organization-1",
	}
	actions := []aicore.AgentAction{
		{
			Type: "task_draft", Label: "称重", Summary: "给雪团称重",
			Payload: map[string]any{
				"task_type": "unknown", "target_type": "hamster", "target_id": "hamster-1",
				"priority": "invalid", "scheduled_at": time.Now().Add(2 * time.Hour).UTC().Format(time.RFC3339),
			},
		},
		{Type: "open_hamster", Label: "越权对象", Summary: "不存在", Payload: map[string]any{"hamster_id": "hamster-other"}},
		{Type: "open_tasks", Label: "任务列表", Summary: "查看全部任务"},
	}

	got := sanitizeAssistantActions(actions, contextValue)
	if len(got) != 2 {
		t.Fatalf("actions=%+v", got)
	}
	if !got[0].RequiresConfirmation || got[0].Payload["task_type"] != "custom" || got[0].Payload["priority"] != "normal" {
		t.Fatalf("draft=%+v", got[0])
	}
	if got[1].RequiresConfirmation || got[1].Payload != nil {
		t.Fatalf("navigation=%+v", got[1])
	}
}
