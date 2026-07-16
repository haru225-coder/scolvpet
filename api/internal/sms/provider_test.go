package sms

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestHTTPProviderSendsContractPayloadAndBearerToken(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost || r.Header.Get("Authorization") != "Bearer test-token" {
			t.Fatalf("request method=%s authorization=%q", r.Method, r.Header.Get("Authorization"))
		}
		var payload map[string]any
		if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
			t.Fatalf("decode payload: %v", err)
		}
		if payload["phone"] != "+8613800138000" || payload["code"] != "654321" || payload["expires_in_seconds"] != float64(300) {
			t.Fatalf("payload: %#v", payload)
		}
		w.WriteHeader(http.StatusAccepted)
	}))
	defer server.Close()

	provider, err := NewHTTPProvider(server.URL, "test-token")
	if err != nil {
		t.Fatalf("new provider: %v", err)
	}
	if err := provider.SendCode(context.Background(), "+8613800138000", "654321"); err != nil {
		t.Fatalf("send code: %v", err)
	}
}

func TestHTTPProviderReturnsStatusAndBody(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusBadGateway)
		_, _ = w.Write([]byte("upstream down"))
	}))
	defer server.Close()

	provider, err := NewHTTPProvider(server.URL, "")
	if err != nil {
		t.Fatalf("new provider: %v", err)
	}
	err = provider.SendCode(context.Background(), "+8613800138000", "654321")
	if err == nil || !strings.Contains(err.Error(), "502") || !strings.Contains(err.Error(), "upstream down") {
		t.Fatalf("provider error: %v", err)
	}
}

func TestHTTPProviderRequiresAbsoluteHTTPURL(t *testing.T) {
	if _, err := NewHTTPProvider("sms-provider.local/send", "token"); err == nil {
		t.Fatal("expected absolute URL validation error")
	}
}
