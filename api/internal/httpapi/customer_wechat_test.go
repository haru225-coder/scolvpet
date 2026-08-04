package httpapi

import (
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"log/slog"

	"github.com/jackc/pgx/v5/pgconn"

	"github.com/scolvpet/scolvpet/api/internal/auth"
	"github.com/scolvpet/scolvpet/api/internal/wechat"
)

// P2 WeChat identity: DB-free contract tests. Everything that reaches
// customer_wechat_identity / wechat_bind_ticket needs Postgres and lives in
// the integration suite; these freeze the validation and degradation edges a
// client depends on before any DB row is touched.

func newWechatTestServer(provider wechat.Provider) (*Server, *http.ServeMux) {
	server := NewServer(nil, auth.New("test", "123456"), slog.Default())
	server.Wechat = provider
	mux := http.NewServeMux()
	server.registerCustomerRoutes(mux)
	return server, mux
}

func postJSON(mux *http.ServeMux, path, body string) *httptest.ResponseRecorder {
	recorder := httptest.NewRecorder()
	request := httptest.NewRequest(http.MethodPost, path, strings.NewReader(body))
	request.Header.Set("Content-Type", "application/json")
	mux.ServeHTTP(recorder, request)
	return recorder
}

func TestWechatSessionRejectsMissingJsCode(t *testing.T) {
	_, mux := newWechatTestServer(wechat.MockProvider{})
	for _, body := range []string{`{}`, `{"js_code":""}`, `{"js_code":"   "}`, `not-json`} {
		recorder := postJSON(mux, "/v1/public/customer/wechat-sessions", body)
		if recorder.Code != http.StatusUnprocessableEntity {
			t.Fatalf("body %q expected 422, got %d", body, recorder.Code)
		}
	}
}

func TestWechatBindingRejectsIncompleteRequests(t *testing.T) {
	_, mux := newWechatTestServer(wechat.MockProvider{})
	cases := []struct {
		name string
		body string
	}{
		{"empty", `{}`},
		{"ticket without wt_ prefix", `{"wechat_ticket":"abc","phone":"+8613800138000","verification_id":"018f47a2-96a7-7e37-a202-cefdc69456ce","code":"123456"}`},
		{"bad phone", `{"wechat_ticket":"wt_x","phone":"12345","verification_id":"018f47a2-96a7-7e37-a202-cefdc69456ce","code":"123456"}`},
		{"nil verification id", `{"wechat_ticket":"wt_x","phone":"+8613800138000","verification_id":"00000000-0000-0000-0000-000000000000","code":"123456"}`},
		{"bad code", `{"wechat_ticket":"wt_x","phone":"+8613800138000","verification_id":"018f47a2-96a7-7e37-a202-cefdc69456ce","code":"xx"}`},
	}
	for _, tc := range cases {
		recorder := postJSON(mux, "/v1/public/customer/wechat-bindings", tc.body)
		if recorder.Code != http.StatusUnprocessableEntity {
			t.Fatalf("%s: expected 422, got %d", tc.name, recorder.Code)
		}
	}
}

func TestCustomerWechatPhoneBindingRejectsIncompleteRequests(t *testing.T) {
	_, mux := newWechatTestServer(wechat.MockProvider{})
	for _, body := range []string{
		`{}`,
		`{"wechat_ticket":"wt_ticket"}`,
		`{"phone_code":"phone-code"}`,
		`{"wechat_ticket":"ticket","phone_code":"phone-code"}`,
		`{"wechat_ticket":"wt_ticket","phone_code":"   "}`,
	} {
		recorder := postJSON(mux, "/v1/public/customer/wechat-phone-bindings", body)
		if recorder.Code != http.StatusUnprocessableEntity {
			t.Fatalf("body %q expected 422, got %d", body, recorder.Code)
		}
	}
}

func TestCustomerWechatPhoneBindingWithoutProviderDegrades(t *testing.T) {
	_, mux := newWechatTestServer(nil)
	recorder := postJSON(mux, "/v1/public/customer/wechat-phone-bindings", `{"wechat_ticket":"wt_ticket","phone_code":"phone-code"}`)
	if recorder.Code != http.StatusServiceUnavailable {
		t.Fatalf("expected 503 when no provider is wired, got %d", recorder.Code)
	}
	if code := customerWechatErrorCode(t, recorder); code != "WECHAT_PHONE_UNAVAILABLE" {
		t.Fatalf("error code=%q", code)
	}
}

func TestCustomerWechatPhoneBindingRateLimitsIPAndGlobalWechatQuota(t *testing.T) {
	server, mux := newWechatTestServer(nil)
	server.WechatPhoneGlobalPerMinute = 1000
	server.WechatPhoneGlobalPerDay = 1000
	for attempt := 0; attempt < customerWechatPhoneIPMaxPerMinute; attempt++ {
		recorder := postJSON(mux, "/v1/public/customer/wechat-phone-bindings", `{"wechat_ticket":"wt_ticket","phone_code":"phone-code"}`)
		if recorder.Code != http.StatusServiceUnavailable {
			t.Fatalf("attempt %d expected provider 503 before IP limit, got %d", attempt, recorder.Code)
		}
	}
	limited := postJSON(mux, "/v1/public/customer/wechat-phone-bindings", `{"wechat_ticket":"wt_ticket","phone_code":"phone-code"}`)
	if limited.Code != http.StatusTooManyRequests {
		t.Fatalf("IP limit expected 429, got %d", limited.Code)
	}

	globalServer, globalMux := newWechatTestServer(nil)
	globalServer.WechatPhoneGlobalPerMinute = 1
	globalServer.WechatPhoneGlobalPerDay = 1000
	first := postJSON(globalMux, "/v1/public/customer/wechat-phone-bindings", `{"wechat_ticket":"wt_ticket","phone_code":"phone-code"}`)
	if first.Code != http.StatusServiceUnavailable || customerWechatErrorCode(t, first) != "WECHAT_PHONE_UNAVAILABLE" {
		t.Fatalf("first global request=%d code=%q", first.Code, customerWechatErrorCode(t, first))
	}
	second := postJSON(globalMux, "/v1/public/customer/wechat-phone-bindings", `{"wechat_ticket":"wt_ticket","phone_code":"phone-code"}`)
	if second.Code != http.StatusServiceUnavailable || customerWechatErrorCode(t, second) != "WECHAT_PHONE_QUOTA_EXHAUSTED" {
		t.Fatalf("global quota request=%d code=%q", second.Code, customerWechatErrorCode(t, second))
	}
}

func customerWechatErrorCode(t *testing.T, recorder *httptest.ResponseRecorder) string {
	t.Helper()
	var payload struct {
		Error struct {
			Code string `json:"code"`
		} `json:"error"`
	}
	if err := json.Unmarshal(recorder.Body.Bytes(), &payload); err != nil {
		t.Fatalf("decode error response: %v body=%s", err, recorder.Body.String())
	}
	return payload.Error.Code
}

func TestWechatUnbindRequiresCustomerAuth(t *testing.T) {
	_, mux := newWechatTestServer(wechat.MockProvider{})
	recorder := httptest.NewRecorder()
	mux.ServeHTTP(recorder, httptest.NewRequest(
		http.MethodDelete, "/v1/customer/wechat-bindings/current", nil))
	if recorder.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401 without a ct_ token, got %d", recorder.Code)
	}
}

// A dead provider must degrade to the SMS flow (503), never 500: the
// mini-program treats non-2xx as "fall back", so the status here is contract.
func TestWechatSessionWithoutProviderDegrades(t *testing.T) {
	_, mux := newWechatTestServer(nil)
	recorder := postJSON(mux, "/v1/public/customer/wechat-sessions", `{"js_code":"anything"}`)
	if recorder.Code != http.StatusServiceUnavailable {
		t.Fatalf("expected 503 when no provider is wired, got %d", recorder.Code)
	}
}

// createCustomerWechatBinding 的唯一键冲突必须由 pgconn.PgError 的
// SQLSTATE(23505)+ 约束名区分,而不是靠错误文本/索引名字符串嗅探。
func TestWechatBindingUniqueViolationMapsBySQLSTATEAndConstraint(t *testing.T) {
	cases := []struct {
		name        string
		pgErr       *pgconn.PgError
		wantHandled bool
		wantStatus  int
		wantCode    string
	}{
		{
			name:        "openid active unique → 该微信已绑定手机号",
			pgErr:       &pgconn.PgError{Code: "23505", ConstraintName: "ux_customer_wechat_identity_openid_active"},
			wantHandled: true,
			wantStatus:  http.StatusUnprocessableEntity,
			wantCode:    "VALIDATION_ERROR",
		},
		{
			name:        "phone active unique → 409 PHONE_ALREADY_BOUND",
			pgErr:       &pgconn.PgError{Code: "23505", ConstraintName: "ux_customer_wechat_identity_phone_active"},
			wantHandled: true,
			wantStatus:  http.StatusConflict,
			wantCode:    "PHONE_ALREADY_BOUND",
		},
		{
			name:        "non-unique SQLSTATE not handled",
			pgErr:       &pgconn.PgError{Code: "23503", ConstraintName: "fk_customer_wechat_identity_phone"},
			wantHandled: false,
		},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			conflict := wechatIdentityConflictError(tc.pgErr)
			if !tc.wantHandled {
				if conflict != nil {
					t.Fatalf("expected no mapping, got %v", conflict)
				}
				return
			}
			if conflict == nil {
				t.Fatal("expected a mapped client error, got nil")
			}
			recorder := httptest.NewRecorder()
			writeAPIError(recorder, httptest.NewRequest(http.MethodPost, "/v1/test", nil), conflict)
			if recorder.Code != tc.wantStatus {
				t.Fatalf("status=%d want %d (body=%s)", recorder.Code, tc.wantStatus, recorder.Body.String())
			}
			if code := customerWechatErrorCode(t, recorder); code != tc.wantCode {
				t.Fatalf("error code=%q want %q", code, tc.wantCode)
			}
		})
	}
}

// 同样的文本若来自非 PgError,不再被当作唯一键冲突处理。
func TestWechatBindingUniqueViolationIsNotTextSniffed(t *testing.T) {
	conflict := wechatIdentityConflictError(errors.New(`duplicate key value violates unique constraint "ux_customer_wechat_identity_openid_active"`))
	if conflict != nil {
		t.Fatalf("text-only duplicate must not map, got %v", conflict)
	}
}
