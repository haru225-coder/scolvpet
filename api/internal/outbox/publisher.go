package outbox

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"time"
)

// HTTPPublisher forwards domain events to an external delivery endpoint.
// The endpoint is intentionally transport-agnostic so it can front a queue,
// webhook consumer, or a managed event bridge.
type HTTPPublisher struct {
	Endpoint string
	Token    string
	Client   *http.Client
}

func NewHTTPPublisher(endpoint, token string) (*HTTPPublisher, error) {
	parsed, err := url.Parse(strings.TrimSpace(endpoint))
	if err != nil || parsed.Host == "" || (parsed.Scheme != "http" && parsed.Scheme != "https") {
		return nil, fmt.Errorf("outbox publisher endpoint must be an absolute http(s) URL")
	}
	if strings.TrimSpace(token) == "" {
		return nil, fmt.Errorf("outbox publisher token must not be empty")
	}
	return &HTTPPublisher{
		Endpoint: parsed.String(),
		Token:    token,
		Client:   &http.Client{Timeout: 10 * time.Second},
	}, nil
}

func (p *HTTPPublisher) Publish(ctx context.Context, topic string, payload []byte) error {
	if strings.TrimSpace(topic) == "" {
		return fmt.Errorf("outbox publisher topic must not be empty")
	}
	if !json.Valid(payload) {
		return fmt.Errorf("outbox publisher payload must be valid JSON")
	}
	body, err := json.Marshal(struct {
		Topic   string          `json:"topic"`
		Payload json.RawMessage `json:"payload"`
	}{Topic: topic, Payload: json.RawMessage(payload)})
	if err != nil {
		return fmt.Errorf("outbox publisher encode request: %w", err)
	}
	request, err := http.NewRequestWithContext(ctx, http.MethodPost, p.Endpoint, bytes.NewReader(body))
	if err != nil {
		return fmt.Errorf("outbox publisher create request: %w", err)
	}
	request.Header.Set("Content-Type", "application/json")
	request.Header.Set("Authorization", "Bearer "+p.Token)
	client := p.Client
	if client == nil {
		client = &http.Client{Timeout: 10 * time.Second}
	}
	response, err := client.Do(request)
	if err != nil {
		return fmt.Errorf("outbox publisher request: %w", err)
	}
	defer response.Body.Close()
	if response.StatusCode >= http.StatusOK && response.StatusCode < http.StatusMultipleChoices {
		return nil
	}
	responseBody, _ := io.ReadAll(io.LimitReader(response.Body, 512))
	return fmt.Errorf("outbox publisher returned status %d: %s", response.StatusCode, strings.TrimSpace(string(responseBody)))
}
