package httpapi

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"log/slog"

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
