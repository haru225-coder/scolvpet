package httpapi

import (
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/scolvpet/scolvpet/api/internal/auth"
)

func TestI6DataRoutesRequireAuthentication(t *testing.T) {
	server := NewServer(nil, auth.New("test", "123456"), slog.Default())
	mux := http.NewServeMux()
	server.registerI6DataRoutes(mux)
	paths := []struct{ method, path string }{
		{http.MethodGet, "/v1/data-center/summary"},
		{http.MethodGet, "/v1/data-center/export-jobs"},
		{http.MethodPost, "/v1/data-center/export-jobs"},
		{http.MethodGet, "/v1/data-center/export-jobs/00000000-0000-0000-0000-000000000001"},
		{http.MethodGet, "/v1/data-center/export-jobs/00000000-0000-0000-0000-000000000001/download"},
		{http.MethodPost, "/v1/data-center/export-jobs/00000000-0000-0000-0000-000000000001/retry"},
		{http.MethodGet, "/v1/data-center/backup-jobs"},
		{http.MethodPost, "/v1/data-center/backup-jobs"},
		{http.MethodGet, "/v1/data-center/backup-jobs/00000000-0000-0000-0000-000000000001"},
		{http.MethodGet, "/v1/data-center/backup-jobs/00000000-0000-0000-0000-000000000001/download"},
		{http.MethodPost, "/v1/data-center/backup-jobs/00000000-0000-0000-0000-000000000001/retry"},
		{http.MethodGet, "/v1/usage/current"},
		{http.MethodGet, "/v1/usage/snapshots"},
	}
	for _, item := range paths {
		recorder := httptest.NewRecorder()
		mux.ServeHTTP(recorder, httptest.NewRequest(item.method, item.path, nil))
		if recorder.Code != http.StatusUnauthorized {
			t.Fatalf("%s %s expected 401, got %d", item.method, item.path, recorder.Code)
		}
	}
}
