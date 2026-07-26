package httpapi

import (
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/scolvpet/scolvpet/api/internal/auth"
)

func TestSandboxActivateRouteHiddenInProduction(t *testing.T) {
	server := NewServer(nil, auth.New("test", "123456"), slog.Default())
	server.Environment = "production"
	mux := http.NewServeMux()
	server.registerP1EntitlementRoutes(mux)

	recorder := httptest.NewRecorder()
	request := httptest.NewRequest(http.MethodPost, "/v1/entitlements/sandbox/activate", nil)
	mux.ServeHTTP(recorder, request)
	// Unregistered route → 404/405 from ServeMux, never reaches handler.
	if recorder.Code == http.StatusOK || recorder.Code == http.StatusUnauthorized {
		t.Fatalf("production must not register sandbox activate; got %d", recorder.Code)
	}
}

func TestSandboxActivateRoutePresentInDevelopment(t *testing.T) {
	server := NewServer(nil, auth.New("test", "123456"), slog.Default())
	server.Environment = "development"
	mux := http.NewServeMux()
	server.registerP1EntitlementRoutes(mux)

	recorder := httptest.NewRecorder()
	request := httptest.NewRequest(http.MethodPost, "/v1/entitlements/sandbox/activate", nil)
	mux.ServeHTTP(recorder, request)
	if recorder.Code != http.StatusUnauthorized {
		t.Fatalf("development sandbox route should require auth, got %d", recorder.Code)
	}
}
