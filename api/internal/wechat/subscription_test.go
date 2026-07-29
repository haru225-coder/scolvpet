package wechat

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestHTTPSubscriptionSenderExchangesTokenAndSendsTemplateData(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		switch r.URL.Path {
		case "/token":
			if r.URL.Query().Get("appid") != "wx-app" || r.URL.Query().Get("grant_type") != "client_credential" {
				t.Fatalf("token query: %v", r.URL.Query())
			}
			_, _ = w.Write([]byte(`{"access_token":"access-token","expires_in":7200}`))
		case "/send":
			if r.URL.Query().Get("access_token") != "access-token" {
				t.Fatalf("send token query: %v", r.URL.Query())
			}
			var payload struct {
				ToUser     string                       `json:"touser"`
				TemplateID string                       `json:"template_id"`
				Page       string                       `json:"page"`
				Data       map[string]map[string]string `json:"data"`
			}
			if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
				t.Fatalf("decode send body: %v", err)
			}
			if payload.ToUser != "openid-1" || payload.TemplateID != "tmpl-1" || payload.Page != "pages/today/index" || payload.Data["thing1"]["value"] != "今日照护" {
				t.Fatalf("send payload: %#v", payload)
			}
			_, _ = w.Write([]byte(`{"errcode":0,"errmsg":"ok","msgid":12345}`))
		default:
			http.NotFound(w, r)
		}
	}))
	defer server.Close()

	sender, err := NewHTTPSubscriptionSender("wx-app", "secret")
	if err != nil {
		t.Fatalf("new sender: %v", err)
	}
	sender.TokenEndpoint = server.URL + "/token"
	sender.SendEndpoint = server.URL + "/send"
	delivery, err := sender.SendSubscription(context.Background(), "openid-1", "tmpl-1", "pages/today/index", map[string]string{"thing1": "今日照护"})
	if err != nil {
		t.Fatalf("send subscription: %v", err)
	}
	if delivery.ProviderMessageID != "wechat-12345" || !strings.HasPrefix(delivery.ProviderMessageID, "wechat-") {
		t.Fatalf("delivery: %#v", delivery)
	}
}

func TestMockSubscriptionSenderRecordsDelivery(t *testing.T) {
	sender := &MockSubscriptionSender{}
	if _, err := sender.SendSubscription(context.Background(), "openid", "tmpl", "pages/today/index", map[string]string{"thing1": "照护"}); err != nil {
		t.Fatalf("mock send: %v", err)
	}
	if len(sender.Sent) != 1 || sender.Sent[0].TemplateID != "tmpl" {
		t.Fatalf("mock deliveries: %#v", sender.Sent)
	}
}
