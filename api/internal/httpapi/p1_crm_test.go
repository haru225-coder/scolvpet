package httpapi

import (
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/scolvpet/scolvpet/api/internal/auth"
)

func TestP1CrmRoutesRequireAuth(t *testing.T) {
	server := NewServer(nil, auth.New("test", "123456"), slog.Default())
	mux := http.NewServeMux()
	server.registerP1CrmRoutes(mux)
	paths := []struct {
		method string
		path   string
	}{
		{http.MethodGet, "/v1/crm/contacts"},
		{http.MethodPost, "/v1/crm/contacts"},
		{http.MethodGet, "/v1/crm/reservations"},
		{http.MethodPost, "/v1/crm/reservations"},
		{http.MethodGet, "/v1/crm/handovers"},
		{http.MethodPost, "/v1/crm/handovers"},
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
