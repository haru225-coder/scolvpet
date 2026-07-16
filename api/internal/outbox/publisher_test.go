package outbox

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestHTTPPublisherSendsTopicPayloadAndBearerToken(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost || r.Header.Get("Authorization") != "Bearer test-token" {
			t.Fatalf("method=%s authorization=%q", r.Method, r.Header.Get("Authorization"))
		}
		var request struct {
			Topic   string          `json:"topic"`
			Payload json.RawMessage `json:"payload"`
		}
		if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
			t.Fatalf("decode request: %v", err)
		}
		if request.Topic != "domain.test" || string(request.Payload) != `{"id":1}` {
			t.Fatalf("request=%s %s", request.Topic, request.Payload)
		}
		w.WriteHeader(http.StatusAccepted)
	}))
	defer server.Close()

	publisher, err := NewHTTPPublisher(server.URL, "test-token")
	if err != nil {
		t.Fatalf("new publisher: %v", err)
	}
	if err := publisher.Publish(context.Background(), "domain.test", []byte(`{"id":1}`)); err != nil {
		t.Fatalf("publish: %v", err)
	}
}

func TestHTTPPublisherReturnsUpstreamError(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusBadGateway)
		_, _ = w.Write([]byte("queue unavailable"))
	}))
	defer server.Close()

	publisher, err := NewHTTPPublisher(server.URL, "test-token")
	if err != nil {
		t.Fatalf("new publisher: %v", err)
	}
	err = publisher.Publish(context.Background(), "domain.test", []byte(`{"id":1}`))
	if err == nil || !strings.Contains(err.Error(), "502") || !strings.Contains(err.Error(), "queue unavailable") {
		t.Fatalf("publisher error: %v", err)
	}
}

func TestNewHTTPPublisherValidatesConfiguration(t *testing.T) {
	if _, err := NewHTTPPublisher("queue.internal/events", "token"); err == nil {
		t.Fatal("expected absolute URL validation error")
	}
	if _, err := NewHTTPPublisher("https://queue.internal/events", ""); err == nil {
		t.Fatal("expected token validation error")
	}
}
