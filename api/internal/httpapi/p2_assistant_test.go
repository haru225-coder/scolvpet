package httpapi

import (
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/scolvpet/scolvpet/api/internal/auth"
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
	} {
		recorder := httptest.NewRecorder()
		request := httptest.NewRequest(path.method, path.path, nil)
		mux.ServeHTTP(recorder, request)
		if recorder.Code != http.StatusUnauthorized {
			t.Fatalf("%s %s expected 401, got %d", path.method, path.path, recorder.Code)
		}
	}
}
