package httpapi

import (
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/scolvpet/scolvpet/api/internal/auth"
)

func TestRegisterI3RoutesRequireAuthentication(t *testing.T) {
	server := NewServer(nil, auth.New("test", "123456"), slog.Default())
	mux := http.NewServeMux()
	server.registerI3Routes(mux)
	paths := []string{
		"/v1/breeding-plans",
		"/v1/breeding-plans/00000000-0000-0000-0000-000000000001",
		"/v1/breeding-plans/00000000-0000-0000-0000-000000000001/publish",
		"/v1/breeding-plans/00000000-0000-0000-0000-000000000001/start-pairing",
		"/v1/pairing-attempts/00000000-0000-0000-0000-000000000001",
		"/v1/pairing-attempts/00000000-0000-0000-0000-000000000001/record-observation",
	}
	for _, path := range paths {
		recorder := httptest.NewRecorder()
		method := http.MethodGet
		if strings.Contains(path, "/publish") || strings.Contains(path, "/start-pairing") || strings.Contains(path, "/record-observation") {
			method = http.MethodPost
		}
		request := httptest.NewRequest(method, path, nil)
		mux.ServeHTTP(recorder, request)
		if recorder.Code != http.StatusUnauthorized {
			t.Fatalf("%s expected 401, got %d", path, recorder.Code)
		}
	}
}

func TestDecodeI3PlanPatch(t *testing.T) {
	request := httptest.NewRequest(http.MethodPatch, "/v1/breeding-plans/id", strings.NewReader(`{
		"name":"新计划",
		"planned_pairing_at":"2026-07-18T12:00:00Z",
		"objective_traits":{"coat":"silver"},
		"notes":null
	}`))
	input, payload, err := decodeI3PlanPatch(request)
	if err != nil {
		t.Fatalf("decode patch: %v", err)
	}
	if len(payload) == 0 || input.Name == nil || *input.Name != "新计划" || !input.ClearNotes || input.PlannedPairingAt == nil {
		t.Fatalf("decoded patch = %#v", input)
	}
	if input.ObjectiveTraits["coat"] != "silver" {
		t.Fatalf("objective traits = %#v", input.ObjectiveTraits)
	}
}

func TestI3DateTimeRequiresRFC3339(t *testing.T) {
	if _, err := parseI3DateTime("2026-07-18", "planned_pairing_at"); err == nil {
		t.Fatal("expected RFC3339 validation error")
	}
	if parsed, err := parseI3DateTime("2026-07-18T12:00:00+08:00", "planned_pairing_at"); err != nil || parsed.Location() != time.UTC {
		t.Fatalf("parsed = %v, err = %v", parsed, err)
	}
}
