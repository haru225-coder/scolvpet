package wechat

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync"
	"sync/atomic"
	"testing"
	"time"
)

func TestHTTPProviderPhoneNumberExchangesStableTokenWithJSONPost(t *testing.T) {
	var tokenCalls atomic.Int32
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		switch r.URL.Path {
		case "/stable-token":
			tokenCalls.Add(1)
			if r.Method != http.MethodPost {
				t.Fatalf("stable token method=%s, want POST", r.Method)
			}
			var body struct {
				GrantType    string `json:"grant_type"`
				AppID        string `json:"appid"`
				Secret       string `json:"secret"`
				ForceRefresh bool   `json:"force_refresh"`
			}
			if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
				t.Fatalf("decode stable token request: %v", err)
			}
			if body.GrantType != "client_credential" || body.AppID != "wx-test-appid" || body.Secret != "test-secret" || body.ForceRefresh {
				t.Fatalf("stable token body=%+v", body)
			}
			_, _ = w.Write([]byte(`{"access_token":"stable-token","expires_in":7200}`))
		case "/phone":
			if r.Method != http.MethodPost || r.URL.Query().Get("access_token") != "stable-token" {
				t.Fatalf("phone request method=%s query=%v", r.Method, r.URL.Query())
			}
			var body struct {
				Code string `json:"code"`
			}
			if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
				t.Fatalf("decode phone request: %v", err)
			}
			if body.Code != "phone-code-1" {
				t.Fatalf("phone code=%q", body.Code)
			}
			_, _ = w.Write([]byte(`{"errcode":0,"phone_info":{"countryCode":"86","purePhoneNumber":"13800138000"}}`))
		default:
			http.NotFound(w, r)
		}
	}))
	defer server.Close()

	provider := newPhoneHTTPProvider(t, server.URL)
	phone, err := provider.PhoneNumber(context.Background(), "phone-code-1")
	if err != nil {
		t.Fatalf("PhoneNumber: %v", err)
	}
	if phone.CountryCode != "86" || phone.Number != "+8613800138000" {
		t.Fatalf("phone=%+v", phone)
	}
	if got := tokenCalls.Load(); got != 1 {
		t.Fatalf("stable token calls=%d, want 1", got)
	}
}

func TestHTTPProviderPhoneNumberSingleflightsStableTokenRefresh(t *testing.T) {
	var tokenCalls atomic.Int32
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		switch r.URL.Path {
		case "/stable-token":
			tokenCalls.Add(1)
			time.Sleep(25 * time.Millisecond)
			_, _ = w.Write([]byte(`{"access_token":"stable-token","expires_in":7200}`))
		case "/phone":
			_, _ = w.Write([]byte(`{"errcode":0,"phone_info":{"countryCode":"86","purePhoneNumber":"13800138000"}}`))
		default:
			http.NotFound(w, r)
		}
	}))
	defer server.Close()

	provider := newPhoneHTTPProvider(t, server.URL)
	start := make(chan struct{})
	errs := make(chan error, 5)
	var group sync.WaitGroup
	for index := 0; index < 5; index++ {
		group.Add(1)
		go func() {
			defer group.Done()
			<-start
			_, err := provider.PhoneNumber(context.Background(), "phone-code")
			errs <- err
		}()
	}
	close(start)
	group.Wait()
	close(errs)
	for err := range errs {
		if err != nil {
			t.Fatalf("PhoneNumber: %v", err)
		}
	}
	if got := tokenCalls.Load(); got != 1 {
		t.Fatalf("stable token calls=%d, want 1", got)
	}
}

func TestHTTPProviderPhoneNumberRefreshesWhenStableTokenHasOnlyFiveMinutesLeft(t *testing.T) {
	var tokenCalls atomic.Int32
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		switch r.URL.Path {
		case "/stable-token":
			call := tokenCalls.Add(1)
			if call == 1 {
				_, _ = w.Write([]byte(`{"access_token":"token-1","expires_in":300}`))
				return
			}
			_, _ = w.Write([]byte(`{"access_token":"token-2","expires_in":7200}`))
		case "/phone":
			_, _ = w.Write([]byte(`{"errcode":0,"phone_info":{"countryCode":"86","purePhoneNumber":"13800138000"}}`))
		default:
			http.NotFound(w, r)
		}
	}))
	defer server.Close()

	provider := newPhoneHTTPProvider(t, server.URL)
	if _, err := provider.PhoneNumber(context.Background(), "phone-code-1"); err != nil {
		t.Fatalf("first PhoneNumber: %v", err)
	}
	if _, err := provider.PhoneNumber(context.Background(), "phone-code-2"); err != nil {
		t.Fatalf("second PhoneNumber: %v", err)
	}
	if got := tokenCalls.Load(); got != 2 {
		t.Fatalf("stable token calls=%d, want 2 when TTL is 300 seconds", got)
	}
}

func TestHTTPProviderPhoneNumberRetriesOnlyAfterExplicitTokenInvalid(t *testing.T) {
	var tokenCalls atomic.Int32
	var phoneCalls atomic.Int32
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		switch r.URL.Path {
		case "/stable-token":
			call := tokenCalls.Add(1)
			var request struct {
				ForceRefresh bool `json:"force_refresh"`
			}
			if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
				t.Fatalf("decode stable token request: %v", err)
			}
			if (call == 1 && request.ForceRefresh) || (call == 2 && !request.ForceRefresh) {
				t.Fatalf("stable token call %d force_refresh=%t", call, request.ForceRefresh)
			}
			_, _ = w.Write([]byte(`{"access_token":"token-` + string(rune('0'+call)) + `","expires_in":7200}`))
		case "/phone":
			phoneCalls.Add(1)
			if r.URL.Query().Get("access_token") == "token-1" {
				_, _ = w.Write([]byte(`{"errcode":40001}`))
				return
			}
			_, _ = w.Write([]byte(`{"errcode":0,"phone_info":{"countryCode":"86","purePhoneNumber":"13800138000"}}`))
		default:
			http.NotFound(w, r)
		}
	}))
	defer server.Close()

	provider := newPhoneHTTPProvider(t, server.URL)
	phone, err := provider.PhoneNumber(context.Background(), "phone-code")
	if err != nil {
		t.Fatalf("PhoneNumber: %v", err)
	}
	if phone.Number != "+8613800138000" || tokenCalls.Load() != 2 || phoneCalls.Load() != 2 {
		t.Fatalf("phone=%+v token_calls=%d phone_calls=%d", phone, tokenCalls.Load(), phoneCalls.Load())
	}
}

func TestHTTPProviderPhoneNumberNeverRetriesAnUncertainExchange(t *testing.T) {
	var phoneCalls atomic.Int32
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case "/stable-token":
			w.Header().Set("Content-Type", "application/json")
			_, _ = w.Write([]byte(`{"access_token":"stable-token","expires_in":7200}`))
		case "/phone":
			phoneCalls.Add(1)
			w.WriteHeader(http.StatusBadGateway)
		default:
			http.NotFound(w, r)
		}
	}))
	defer server.Close()

	provider := newPhoneHTTPProvider(t, server.URL)
	if _, err := provider.PhoneNumber(context.Background(), "phone-code"); err == nil {
		t.Fatal("expected failed phone exchange")
	}
	if got := phoneCalls.Load(); got != 1 {
		t.Fatalf("phone code was replayed %d times after an uncertain exchange, want 1", got)
	}
}

func TestHTTPProviderPhoneNumberErrorsDoNotExposeCredentials(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		switch r.URL.Path {
		case "/stable-token":
			_, _ = w.Write([]byte(`{"access_token":"stable-token-secret","expires_in":7200}`))
		case "/phone":
			_, _ = w.Write([]byte(`{"errcode":40029,"errmsg":"phone-code-should-not-appear +8613800138000 stable-token-secret test-secret"}`))
		default:
			http.NotFound(w, r)
		}
	}))
	defer server.Close()

	provider := newPhoneHTTPProvider(t, server.URL)
	_, err := provider.PhoneNumber(context.Background(), "phone-code-should-not-appear")
	if err == nil {
		t.Fatal("expected phone exchange failure")
	}
	for _, secret := range []string{"phone-code-should-not-appear", "stable-token-secret", "test-secret", "+8613800138000"} {
		if strings.Contains(err.Error(), secret) {
			t.Fatalf("error leaks credential %q: %v", secret, err)
		}
	}
}

func TestMockProviderPhoneNumberReturnsMainlandFixture(t *testing.T) {
	phone, err := (MockProvider{}).PhoneNumber(context.Background(), "phone-code")
	if err != nil {
		t.Fatalf("mock PhoneNumber: %v", err)
	}
	if phone.CountryCode != "86" || phone.Number != "+8613800138000" {
		t.Fatalf("mock phone=%+v", phone)
	}
}

func newPhoneHTTPProvider(t *testing.T, baseURL string) *HTTPProvider {
	t.Helper()
	provider, err := NewHTTPProvider("wx-test-appid", "test-secret")
	if err != nil {
		t.Fatalf("NewHTTPProvider: %v", err)
	}
	provider.StableTokenEndpoint = baseURL + "/stable-token"
	provider.PhoneEndpoint = baseURL + "/phone"
	return provider
}
