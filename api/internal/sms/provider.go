package sms

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

type HTTPProvider struct {
	Endpoint string
	Token    string
	Client   *http.Client
}

func NewHTTPProvider(endpoint, token string) (*HTTPProvider, error) {
	parsed, err := url.Parse(strings.TrimSpace(endpoint))
	if err != nil || parsed.Host == "" || (parsed.Scheme != "http" && parsed.Scheme != "https") {
		return nil, fmt.Errorf("sms endpoint must be an absolute http(s) URL")
	}
	return &HTTPProvider{
		Endpoint: parsed.String(),
		Token:    token,
		Client:   &http.Client{Timeout: 10 * time.Second},
	}, nil
}

func (p *HTTPProvider) SendCode(ctx context.Context, phone, code string) error {
	payload, err := json.Marshal(map[string]any{
		"phone":              phone,
		"code":               code,
		"expires_in_seconds": 300,
	})
	if err != nil {
		return err
	}
	request, err := http.NewRequestWithContext(ctx, http.MethodPost, p.Endpoint, bytes.NewReader(payload))
	if err != nil {
		return err
	}
	request.Header.Set("Content-Type", "application/json")
	if p.Token != "" {
		request.Header.Set("Authorization", "Bearer "+p.Token)
	}
	client := p.Client
	if client == nil {
		client = &http.Client{Timeout: 10 * time.Second}
	}
	response, err := client.Do(request)
	if err != nil {
		return fmt.Errorf("sms provider request: %w", err)
	}
	defer response.Body.Close()
	if response.StatusCode >= http.StatusOK && response.StatusCode < http.StatusMultipleChoices {
		return nil
	}
	body, _ := io.ReadAll(io.LimitReader(response.Body, 512))
	return fmt.Errorf("sms provider returned status %d: %s", response.StatusCode, strings.TrimSpace(string(body)))
}
