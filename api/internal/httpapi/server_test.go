package httpapi

import (
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"net/netip"
	"strings"
	"testing"

	"github.com/jackc/pgx/v5/pgconn"

	"github.com/scolvpet/scolvpet/api/internal/auth"
	"github.com/scolvpet/scolvpet/api/internal/store"
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

// writeAPIError 的唯一键冲突兜底必须由 pgconn.PgError 的 SQLSTATE(23505)
// 触发,而不是靠错误文本里出现 duplicate/unique。
func TestWriteAPIErrorMapsUniqueViolationBySQLSTATE(t *testing.T) {
	recorder := httptest.NewRecorder()
	request := httptest.NewRequest(http.MethodGet, "/v1/test", nil)
	writeAPIError(recorder, request, &pgconn.PgError{
		Code:    "23505",
		Message: `duplicate key value violates unique constraint "account_phone_key"`,
	})
	if recorder.Code != http.StatusConflict {
		t.Fatalf("SQLSTATE 23505 must map to 409 CONFLICT, got %d (body=%s)", recorder.Code, recorder.Body.String())
	}
	var payload struct {
		Error struct {
			Code string `json:"code"`
		} `json:"error"`
	}
	if err := json.Unmarshal(recorder.Body.Bytes(), &payload); err != nil {
		t.Fatalf("decode error body: %v", err)
	}
	if payload.Error.Code != "CONFLICT" {
		t.Fatalf("error code=%q, want CONFLICT", payload.Error.Code)
	}
}

// 同一段“duplicate/unique”文本若来自非 PgError,不再被嗅探为 409。
func TestWriteAPIErrorDoesNotSniffDuplicateText(t *testing.T) {
	recorder := httptest.NewRecorder()
	request := httptest.NewRequest(http.MethodGet, "/v1/test", nil)
	writeAPIError(recorder, request, errors.New(`duplicate key value violates unique constraint "account_phone_key"`))
	if recorder.Code != http.StatusInternalServerError {
		t.Fatalf("text-only duplicate must not map to 409, got %d", recorder.Code)
	}
}

// P2 typed 版本号协议:writeAPIError 通过 versionCarrier 读取 *VersionError
// 的 Current 字段(直接传入与 %w 包装两种形态),而非嗅探 "current=" 文本。
func TestWriteAPIErrorVersionConflictReadsTypedCurrent(t *testing.T) {
	cases := []struct {
		name string
		err  error
	}{
		{"direct store.VersionError", &store.VersionError{Current: 7}},
		{"wrapped store.VersionError", fmt.Errorf("%w: outbox flush failed", &store.VersionError{Current: 7})},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			recorder := httptest.NewRecorder()
			request := httptest.NewRequest(http.MethodGet, "/v1/test", nil)
			writeAPIError(recorder, request, tc.err)
			if recorder.Code != http.StatusConflict {
				t.Fatalf("status=%d, want 409 (body=%s)", recorder.Code, recorder.Body.String())
			}
			var payload struct {
				Error struct {
					Code    string `json:"code"`
					Details struct {
						CurrentVersion int `json:"current_version"`
					} `json:"details"`
				} `json:"error"`
			}
			if err := json.Unmarshal(recorder.Body.Bytes(), &payload); err != nil {
				t.Fatalf("decode error body: %v", err)
			}
			if payload.Error.Code != "VERSION_CONFLICT" {
				t.Fatalf("code=%q, want VERSION_CONFLICT", payload.Error.Code)
			}
			if payload.Error.Details.CurrentVersion != 7 {
				t.Fatalf("current_version=%d, want 7 (typed read)", payload.Error.Details.CurrentVersion)
			}
		})
	}
}
