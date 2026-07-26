package httpapi

import (
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/scolvpet/scolvpet/api/internal/auth"
)

func TestHealthAndRequestIDMiddleware(t *testing.T) {
	server := NewServer(nil, auth.New("test", "123456"), slog.Default())
	recorder := httptest.NewRecorder()
	request := httptest.NewRequest(http.MethodGet, "/healthz", nil)
	server.Handler().ServeHTTP(recorder, request)
	if recorder.Code != http.StatusOK {
		t.Fatalf("health status: %d", recorder.Code)
	}
	if recorder.Header().Get("X-Request-ID") == "" {
		t.Fatal("request id header missing")
	}
}

func TestReadyBodyReportsProductionChecks(t *testing.T) {
	server := NewServer(nil, auth.New("test", "123456"), slog.Default())

	legacy := server.readyBody()
	if legacy["status"] != "ready" {
		t.Fatalf("legacy status: %v", legacy["status"])
	}
	if _, ok := legacy["environment"]; ok {
		t.Fatal("legacy body must not carry environment when unset")
	}
	if _, ok := legacy["checks"]; ok {
		t.Fatal("legacy body must not carry checks when unset")
	}

	server.Environment = "production"
	server.Ready = &ReadyChecks{SMSProvider: "http", SMSMockCodeSet: false, WechatProvider: "http"}
	body := server.readyBody()
	if body["environment"] != "production" {
		t.Fatalf("environment: %v", body["environment"])
	}
	checks, ok := body["checks"].(*ReadyChecks)
	if !ok {
		t.Fatalf("checks type: %T", body["checks"])
	}
	if checks.SMSProvider != "http" || checks.SMSMockCodeSet || checks.WechatProvider != "http" {
		t.Fatalf("checks: %+v", checks)
	}
}

func TestProtectedRouteRequiresBearer(t *testing.T) {
	server := NewServer(nil, auth.New("test", "123456"), slog.Default())
	recorder := httptest.NewRecorder()
	request := httptest.NewRequest(http.MethodGet, "/v1/me", nil)
	server.Handler().ServeHTTP(recorder, request)
	if recorder.Code != http.StatusUnauthorized {
		t.Fatalf("protected route status: %d", recorder.Code)
	}
}
