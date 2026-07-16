package httpapi

import (
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/scolvpet/scolvpet/api/internal/auth"
)

func TestI5RoutesRequireAuthWhenRegisteredIndependently(t *testing.T) {
	server := NewServer(nil, auth.New("test", "123456"), slog.Default())
	mux := http.NewServeMux()
	server.registerI5Routes(mux)
	paths := []struct {
		method string
		path   string
	}{
		{http.MethodGet, "/v1/health-records"},
		{http.MethodPost, "/v1/health-records"},
		{http.MethodGet, "/v1/tasks"},
		{http.MethodPost, "/v1/tasks"},
		{http.MethodGet, "/v1/reminders"},
	}
	for _, test := range paths {
		recorder := httptest.NewRecorder()
		request := httptest.NewRequest(test.method, test.path, nil)
		mux.ServeHTTP(recorder, request)
		if recorder.Code != http.StatusUnauthorized {
			t.Fatalf("%s %s expected 401, got %d", test.method, test.path, recorder.Code)
		}
	}
}

func TestI5TaskTypeAndReminderStatusMappings(t *testing.T) {
	if got := normalizeI5TaskType("weaning"); got != "weaning_due" {
		t.Fatalf("task type mapping = %q", got)
	}
	if got := normalizeI5ReminderStatus("queued"); got != "pending" {
		t.Fatalf("reminder status mapping = %q", got)
	}
	if got := normalizeI5ReminderChannel("local_notification"); got != "local" {
		t.Fatalf("reminder channel mapping = %q", got)
	}
}
