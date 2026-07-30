package wechat

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"sync"
	"time"

	"golang.org/x/sync/singleflight"
)

const (
	defaultCode2SessionEndpoint = "https://api.weixin.qq.com/sns/jscode2session"
	defaultStableTokenEndpoint  = "https://api.weixin.qq.com/cgi-bin/stable_token"
	defaultPhoneEndpoint        = "https://api.weixin.qq.com/wxa/business/getuserphonenumber"
)

// HTTPProvider calls the real WeChat code2Session API. AppID/Secret never
// leave this process; SessionKey is kept in the returned Session only and must
// never be serialized to any client.
type HTTPProvider struct {
	AppID               string
	Secret              string
	Endpoint            string
	StableTokenEndpoint string
	PhoneEndpoint       string
	Client              *http.Client

	stableTokenMu     sync.Mutex
	stableToken       cachedStableToken
	stableTokenFlight singleflight.Group
}

func NewHTTPProvider(appID, secret string) (*HTTPProvider, error) {
	appID = strings.TrimSpace(appID)
	secret = strings.TrimSpace(secret)
	if appID == "" || secret == "" {
		return nil, fmt.Errorf("wechat appid and secret must be non-empty")
	}
	return &HTTPProvider{
		AppID:               appID,
		Secret:              secret,
		Endpoint:            defaultCode2SessionEndpoint,
		StableTokenEndpoint: defaultStableTokenEndpoint,
		PhoneEndpoint:       defaultPhoneEndpoint,
		Client:              &http.Client{Timeout: 10 * time.Second},
	}, nil
}

func (p *HTTPProvider) httpClient() *http.Client {
	if p.Client != nil {
		return p.Client
	}
	return &http.Client{Timeout: 10 * time.Second}
}

// code2SessionResponse is the WeChat response body. WeChat returns HTTP 200
// even on failure and signals errors through errcode/errmsg.
type code2SessionResponse struct {
	OpenID     string `json:"openid"`
	UnionID    string `json:"unionid"`
	SessionKey string `json:"session_key"`
	ErrCode    int    `json:"errcode"`
	ErrMsg     string `json:"errmsg"`
}

func (p *HTTPProvider) Code2Session(ctx context.Context, jsCode string) (Session, error) {
	endpoint := p.Endpoint
	if endpoint == "" {
		endpoint = defaultCode2SessionEndpoint
	}
	query := url.Values{}
	query.Set("appid", p.AppID)
	query.Set("secret", p.Secret)
	query.Set("js_code", jsCode)
	query.Set("grant_type", "authorization_code")
	request, err := http.NewRequestWithContext(ctx, http.MethodGet, endpoint+"?"+query.Encode(), nil)
	if err != nil {
		return Session{}, err
	}
	client := p.Client
	if client == nil {
		client = &http.Client{Timeout: 10 * time.Second}
	}
	response, err := client.Do(request)
	if err != nil {
		return Session{}, fmt.Errorf("wechat code2session request: %w", err)
	}
	defer response.Body.Close()
	body, err := io.ReadAll(io.LimitReader(response.Body, 4096))
	if err != nil {
		return Session{}, fmt.Errorf("wechat code2session read: %w", err)
	}
	if response.StatusCode != http.StatusOK {
		return Session{}, fmt.Errorf("wechat code2session status %d", response.StatusCode)
	}
	var parsed code2SessionResponse
	if err := json.Unmarshal(body, &parsed); err != nil {
		return Session{}, fmt.Errorf("wechat code2session decode: %w", err)
	}
	if parsed.ErrCode != 0 {
		// Never include js_code or secret in the error surface.
		return Session{}, fmt.Errorf("wechat code2session errcode %d: %s", parsed.ErrCode, parsed.ErrMsg)
	}
	if parsed.OpenID == "" {
		return Session{}, fmt.Errorf("wechat code2session returned empty openid")
	}
	return Session{OpenID: parsed.OpenID, UnionID: parsed.UnionID, SessionKey: parsed.SessionKey}, nil
}
