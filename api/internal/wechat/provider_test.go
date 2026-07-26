package wechat

import (
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestHTTPProviderSendsCode2SessionQuery(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			t.Fatalf("request method=%s", r.Method)
		}
		query := r.URL.Query()
		if query.Get("appid") != "wx-test-appid" || query.Get("secret") != "test-secret" ||
			query.Get("js_code") != "code-123" || query.Get("grant_type") != "authorization_code" {
			t.Fatalf("query: %v", query)
		}
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"openid":"o-abc","unionid":"u-abc","session_key":"sk-secret"}`))
	}))
	defer server.Close()

	provider, err := NewHTTPProvider("wx-test-appid", "test-secret")
	if err != nil {
		t.Fatalf("new provider: %v", err)
	}
	provider.Endpoint = server.URL
	session, err := provider.Code2Session(context.Background(), "code-123")
	if err != nil {
		t.Fatalf("code2session: %v", err)
	}
	if session.OpenID != "o-abc" || session.UnionID != "u-abc" || session.SessionKey != "sk-secret" {
		t.Fatalf("session: %#v", session)
	}
}

func TestHTTPProviderSurfacesWechatErrcode(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// WeChat answers HTTP 200 with an errcode body on failure.
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"errcode":40029,"errmsg":"invalid code"}`))
	}))
	defer server.Close()

	provider, err := NewHTTPProvider("wx-test-appid", "test-secret")
	if err != nil {
		t.Fatalf("new provider: %v", err)
	}
	provider.Endpoint = server.URL
	_, err = provider.Code2Session(context.Background(), "bad-code")
	if err == nil || !strings.Contains(err.Error(), "40029") || !strings.Contains(err.Error(), "invalid code") {
		t.Fatalf("provider error: %v", err)
	}
	if strings.Contains(err.Error(), "test-secret") || strings.Contains(err.Error(), "bad-code") {
		t.Fatalf("error leaks credentials: %v", err)
	}
}

func TestHTTPProviderRejectsEmptyOpenID(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"session_key":"sk"}`))
	}))
	defer server.Close()

	provider, err := NewHTTPProvider("wx-test-appid", "test-secret")
	if err != nil {
		t.Fatalf("new provider: %v", err)
	}
	provider.Endpoint = server.URL
	if _, err := provider.Code2Session(context.Background(), "code"); err == nil {
		t.Fatal("expected empty openid rejection")
	}
}

func TestHTTPProviderRejectsNonOKStatus(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusBadGateway)
	}))
	defer server.Close()

	provider, err := NewHTTPProvider("wx-test-appid", "test-secret")
	if err != nil {
		t.Fatalf("new provider: %v", err)
	}
	provider.Endpoint = server.URL
	_, err = provider.Code2Session(context.Background(), "code")
	if err == nil || !strings.Contains(err.Error(), "502") {
		t.Fatalf("provider error: %v", err)
	}
}

func TestNewHTTPProviderRequiresCredentials(t *testing.T) {
	if _, err := NewHTTPProvider("", "secret"); err == nil {
		t.Fatal("expected appid validation error")
	}
	if _, err := NewHTTPProvider("wx-appid", " "); err == nil {
		t.Fatal("expected secret validation error")
	}
}

func TestMockProviderIsDeterministic(t *testing.T) {
	first, err := MockProvider{}.Code2Session(context.Background(), "js-1")
	if err != nil {
		t.Fatalf("mock code2session: %v", err)
	}
	second, _ := MockProvider{}.Code2Session(context.Background(), "js-1")
	if first.OpenID != "mock-openid-js-1" || first.OpenID != second.OpenID {
		t.Fatalf("mock openid: %q vs %q", first.OpenID, second.OpenID)
	}
	if _, err := (MockProvider{}).Code2Session(context.Background(), "  "); err == nil {
		t.Fatal("expected empty js_code rejection")
	}
}
