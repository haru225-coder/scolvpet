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

// B 端微信登录的 DB-free 合同测试：涉及身份表、票据表和会话表的完整链路
// 由集成环境覆盖；这里固定客户端依赖的校验、降级和未登录边界。

func newBreederWechatTestServer(provider wechat.Provider) (*Server, *http.ServeMux) {
	server := NewServer(nil, auth.New("test", "123456"), slog.Default())
	server.Wechat = provider
	mux := http.NewServeMux()
	mux.HandleFunc("POST /v1/auth/wechat-sessions", server.createBreederWechatSession)
	mux.HandleFunc("POST /v1/auth/wechat-bindings", server.createBreederWechatBinding)
	mux.HandleFunc("DELETE /v1/auth/wechat-bindings/current", server.deleteBreederWechatBinding)
	return server, mux
}

func TestBreederWechatSessionRejectsMissingJsCode(t *testing.T) {
	_, mux := newBreederWechatTestServer(wechat.MockProvider{})
	for _, body := range []string{`{}`, `{"js_code":""}`, `{"js_code":"   "}`, `not-json`} {
		recorder := postJSON(mux, "/v1/auth/wechat-sessions", body)
		if recorder.Code != http.StatusUnprocessableEntity {
			t.Fatalf("body %q expected 422, got %d", body, recorder.Code)
		}
	}
}

func TestBreederWechatBindingRejectsIncompleteRequests(t *testing.T) {
	_, mux := newBreederWechatTestServer(wechat.MockProvider{})
	cases := []struct {
		name string
		body string
	}{
		{"empty", `{}`},
		{"ticket without bwt prefix", `{"wechat_ticket":"abc","phone":"+8613800138000","verification_id":"018f47a2-96a7-7e37-a202-cefdc69456ce","code":"123456"}`},
		{"bad phone", `{"wechat_ticket":"bwt_x","phone":"12345","verification_id":"018f47a2-96a7-7e37-a202-cefdc69456ce","code":"123456"}`},
		{"nil verification id", `{"wechat_ticket":"bwt_x","phone":"+8613800138000","verification_id":"00000000-0000-0000-0000-000000000000","code":"123456"}`},
		{"bad code", `{"wechat_ticket":"bwt_x","phone":"+8613800138000","verification_id":"018f47a2-96a7-7e37-a202-cefdc69456ce","code":"xx"}`},
	}
	for _, tc := range cases {
		recorder := postJSON(mux, "/v1/auth/wechat-bindings", tc.body)
		if recorder.Code != http.StatusUnprocessableEntity {
			t.Fatalf("%s: expected 422, got %d", tc.name, recorder.Code)
		}
	}
}

func TestBreederWechatUnbindRequiresBearer(t *testing.T) {
	_, mux := newBreederWechatTestServer(wechat.MockProvider{})
	recorder := httptest.NewRecorder()
	mux.ServeHTTP(recorder, httptest.NewRequest(http.MethodDelete, "/v1/auth/wechat-bindings/current", nil))
	if recorder.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401 without a Bearer token, got %d", recorder.Code)
	}
}

func TestBreederWechatSessionWithoutProviderDegrades(t *testing.T) {
	_, mux := newBreederWechatTestServer(nil)
	recorder := postJSON(mux, "/v1/auth/wechat-sessions", `{"js_code":"anything"}`)
	if recorder.Code != http.StatusServiceUnavailable {
		t.Fatalf("expected 503 when no provider is wired, got %d", recorder.Code)
	}
	if !strings.Contains(recorder.Body.String(), "WECHAT_UNAVAILABLE") {
		t.Fatalf("response should expose the stable error code: %s", recorder.Body.String())
	}
}
