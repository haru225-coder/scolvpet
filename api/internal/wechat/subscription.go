package wechat

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"net/url"
	"strings"
	"sync"
	"time"
)

// SubscriptionSender sends one accepted mini-program subscription message.
// The access token and app secret remain inside the provider implementation.
type SubscriptionSender interface {
	SendSubscription(ctx context.Context, openID, templateID, page string, data map[string]string) (Delivery, error)
}

type Delivery struct {
	ProviderMessageID string
	SentAt            time.Time
}

type subscriptionAccessToken struct {
	Value     string
	ExpiresAt time.Time
}

// HTTPSubscriptionSender talks to the official WeChat token and subscribe/send
// endpoints. Endpoint fields are injectable for deterministic integration tests.
type HTTPSubscriptionSender struct {
	AppID            string
	Secret           string
	TokenEndpoint    string
	SendEndpoint     string
	MiniprogramState string
	Client           *http.Client
	Logger           *slog.Logger

	mu    sync.Mutex
	token subscriptionAccessToken
}

func NewHTTPSubscriptionSender(appID, secret string) (*HTTPSubscriptionSender, error) {
	appID = strings.TrimSpace(appID)
	secret = strings.TrimSpace(secret)
	if appID == "" || secret == "" {
		return nil, fmt.Errorf("wechat subscription appid and secret must be non-empty")
	}
	return &HTTPSubscriptionSender{
		AppID:            appID,
		Secret:           secret,
		TokenEndpoint:    "https://api.weixin.qq.com/cgi-bin/token",
		SendEndpoint:     "https://api.weixin.qq.com/cgi-bin/message/subscribe/send",
		MiniprogramState: "formal",
		Client:           &http.Client{Timeout: 10 * time.Second},
	}, nil
}

func (p *HTTPSubscriptionSender) SendSubscription(ctx context.Context, openID, templateID, page string, data map[string]string) (Delivery, error) {
	accessToken, err := p.accessToken(ctx)
	if err != nil {
		return Delivery{}, err
	}
	payload := map[string]any{
		"touser":      strings.TrimSpace(openID),
		"template_id": strings.TrimSpace(templateID),
		"data":        subscriptionData(data),
	}
	if strings.TrimSpace(page) != "" {
		payload["page"] = strings.TrimSpace(page)
	}
	if state := strings.TrimSpace(p.MiniprogramState); state != "" {
		payload["miniprogram_state"] = state
	}
	body, err := json.Marshal(payload)
	if err != nil {
		return Delivery{}, fmt.Errorf("wechat subscription encode: %w", err)
	}
	endpoint := strings.TrimRight(strings.TrimSpace(p.SendEndpoint), "?")
	query := url.Values{}
	query.Set("access_token", accessToken)
	request, err := http.NewRequestWithContext(ctx, http.MethodPost, endpoint+"?"+query.Encode(), strings.NewReader(string(body)))
	if err != nil {
		return Delivery{}, fmt.Errorf("wechat subscription request: %w", err)
	}
	request.Header.Set("Content-Type", "application/json")
	response, err := p.httpClient().Do(request)
	if err != nil {
		return Delivery{}, fmt.Errorf("wechat subscription send: %w", err)
	}
	defer response.Body.Close()
	responseBody, err := io.ReadAll(io.LimitReader(response.Body, 4096))
	if err != nil {
		return Delivery{}, fmt.Errorf("wechat subscription read: %w", err)
	}
	if response.StatusCode != http.StatusOK {
		return Delivery{}, fmt.Errorf("wechat subscription status %d", response.StatusCode)
	}
	var result struct {
		ErrCode int    `json:"errcode"`
		ErrMsg  string `json:"errmsg"`
		MsgID   int64  `json:"msgid"`
	}
	if err := json.Unmarshal(responseBody, &result); err != nil {
		return Delivery{}, fmt.Errorf("wechat subscription decode: %w", err)
	}
	if result.ErrCode != 0 {
		return Delivery{}, fmt.Errorf("wechat subscription errcode %d: %s", result.ErrCode, result.ErrMsg)
	}
	return Delivery{ProviderMessageID: fmt.Sprintf("wechat-%d", result.MsgID), SentAt: time.Now().UTC()}, nil
}

func (p *HTTPSubscriptionSender) accessToken(ctx context.Context) (string, error) {
	p.mu.Lock()
	if p.token.Value != "" && time.Now().Before(p.token.ExpiresAt) {
		value := p.token.Value
		p.mu.Unlock()
		return value, nil
	}
	p.mu.Unlock()

	endpoint := strings.TrimRight(strings.TrimSpace(p.TokenEndpoint), "?")
	query := url.Values{}
	query.Set("appid", p.AppID)
	query.Set("secret", p.Secret)
	query.Set("grant_type", "client_credential")
	request, err := http.NewRequestWithContext(ctx, http.MethodGet, endpoint+"?"+query.Encode(), nil)
	if err != nil {
		return "", fmt.Errorf("wechat access token request: %w", err)
	}
	response, err := p.httpClient().Do(request)
	if err != nil {
		return "", fmt.Errorf("wechat access token request: %w", err)
	}
	defer response.Body.Close()
	body, err := io.ReadAll(io.LimitReader(response.Body, 4096))
	if err != nil {
		return "", fmt.Errorf("wechat access token read: %w", err)
	}
	if response.StatusCode != http.StatusOK {
		return "", fmt.Errorf("wechat access token status %d", response.StatusCode)
	}
	var result struct {
		AccessToken string `json:"access_token"`
		ExpiresIn   int    `json:"expires_in"`
		ErrCode     int    `json:"errcode"`
		ErrMsg      string `json:"errmsg"`
	}
	if err := json.Unmarshal(body, &result); err != nil {
		return "", fmt.Errorf("wechat access token decode: %w", err)
	}
	if result.ErrCode != 0 || strings.TrimSpace(result.AccessToken) == "" {
		return "", fmt.Errorf("wechat access token errcode %d: %s", result.ErrCode, result.ErrMsg)
	}
	expiresIn := time.Duration(result.ExpiresIn) * time.Second
	if expiresIn <= 0 {
		expiresIn = 2 * time.Hour
	}
	p.mu.Lock()
	p.token = subscriptionAccessToken{Value: result.AccessToken, ExpiresAt: time.Now().Add(expiresIn - time.Minute)}
	p.mu.Unlock()
	return result.AccessToken, nil
}

func (p *HTTPSubscriptionSender) httpClient() *http.Client {
	if p.Client != nil {
		return p.Client
	}
	return &http.Client{Timeout: 10 * time.Second}
}

func subscriptionData(data map[string]string) map[string]map[string]string {
	result := make(map[string]map[string]string, len(data))
	for key, value := range data {
		result[key] = map[string]string{"value": value}
	}
	return result
}

// MockSubscriptionSender is deterministic for local development and tests.
type MockSubscriptionSender struct {
	Logger *slog.Logger
	mu     sync.Mutex
	Sent   []SubscriptionDelivery
}

type SubscriptionDelivery struct {
	OpenID     string
	TemplateID string
	Page       string
	Data       map[string]string
}

func (p *MockSubscriptionSender) SendSubscription(_ context.Context, openID, templateID, page string, data map[string]string) (Delivery, error) {
	p.mu.Lock()
	p.Sent = append(p.Sent, SubscriptionDelivery{OpenID: openID, TemplateID: templateID, Page: page, Data: data})
	count := len(p.Sent)
	p.mu.Unlock()
	if p.Logger != nil {
		p.Logger.Info("wechat subscription delivered (mock provider)", "template_id", templateID)
	}
	return Delivery{ProviderMessageID: fmt.Sprintf("mock-wechat-%d", count), SentAt: time.Now().UTC()}, nil
}
