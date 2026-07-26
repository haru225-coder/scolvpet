package httpapi

import (
	"log/slog"
	"net/http"
	"net/http/httptest"
	"net/netip"
	"strings"
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

func TestClientIPTrustsOnlyConfiguredProxies(t *testing.T) {
	server := NewServer(nil, auth.New("test", "123456"), slog.Default())

	spoofed := httptest.NewRequest(http.MethodPost, "/v1/auth/verification-codes", nil)
	spoofed.RemoteAddr = "203.0.113.9:4444"
	spoofed.Header.Set("X-Forwarded-For", "8.8.8.8")
	spoofed.Header.Set("X-Real-IP", "9.9.9.9")
	if got := server.clientIP(spoofed); got != "203.0.113.9" {
		t.Fatalf("untrusted peer must ignore forwarded headers, got %q", got)
	}

	server.TrustedProxies = []netip.Prefix{netip.MustParsePrefix("127.0.0.0/8")}

	proxied := httptest.NewRequest(http.MethodPost, "/v1/auth/verification-codes", nil)
	proxied.RemoteAddr = "127.0.0.1:5555"
	proxied.Header.Set("X-Forwarded-For", "8.8.8.8, 198.51.100.7")
	if got := server.clientIP(proxied); got != "198.51.100.7" {
		t.Fatalf("trusted peer must take the rightmost non-trusted hop, got %q", got)
	}

	garbage := httptest.NewRequest(http.MethodPost, "/v1/auth/verification-codes", nil)
	garbage.RemoteAddr = "127.0.0.1:5555"
	garbage.Header.Set("X-Forwarded-For", strings.Repeat("x", 300))
	if got := server.clientIP(garbage); got != "127.0.0.1" {
		t.Fatalf("unparseable forwarded chain must fall back to the peer, got %q", got)
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
