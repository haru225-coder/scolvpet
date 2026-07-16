package httpapi

import (
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/scolvpet/scolvpet/api/internal/auth"
)

func TestI4RoutesRequireAuth(t *testing.T) {
	server := NewServer(nil, auth.New("test", "123456"), slog.Default())
	mux := http.NewServeMux()
	server.registerI4Routes(mux)
	routes := []struct {
		method string
		path   string
	}{
		{http.MethodPost, "/v1/breeding-plans/00000000-0000-0000-0000-000000000001/confirm-birth"},
		{http.MethodPost, "/v1/litters/00000000-0000-0000-0000-000000000001/count-events"},
		{http.MethodPost, "/v1/litters/00000000-0000-0000-0000-000000000001/wean"},
		{http.MethodPost, "/v1/litters/00000000-0000-0000-0000-000000000001/sex-and-separate"},
		{http.MethodGet, "/v1/litters/00000000-0000-0000-0000-000000000001/individualization-eligibility"},
		{http.MethodPost, "/v1/litters/00000000-0000-0000-0000-000000000001/individualize"},
	}
	for _, route := range routes {
		recorder := httptest.NewRecorder()
		request := httptest.NewRequest(route.method, route.path, nil)
		mux.ServeHTTP(recorder, request)
		if recorder.Code != http.StatusUnauthorized {
			t.Fatalf("%s %s expected 401, got %d", route.method, route.path, recorder.Code)
		}
	}
}
