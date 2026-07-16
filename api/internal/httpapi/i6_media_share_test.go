package httpapi

import (
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/scolvpet/scolvpet/api/internal/auth"
)

func TestI6MediaRoutesRequireAuth(t *testing.T) {
	server := NewServer(nil, auth.New("test", "123456"), slog.Default())
	mux := http.NewServeMux()
	server.registerI6MediaRoutes(mux)
	for _, item := range []struct{ method, path string }{
		{http.MethodPost, "/v1/media/uploads/presign"},
		{http.MethodGet, "/v1/media/00000000-0000-0000-0000-000000000001"},
		{http.MethodGet, "/v1/shares"},
	} {
		recorder := httptest.NewRecorder()
		mux.ServeHTTP(recorder, httptest.NewRequest(item.method, item.path, nil))
		if recorder.Code != http.StatusUnauthorized {
			t.Fatalf("route %s %s status=%d, want 401", item.method, item.path, recorder.Code)
		}
	}
}
