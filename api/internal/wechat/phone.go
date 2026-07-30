package wechat

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"time"
)

const stableTokenRefreshAhead = 5 * time.Minute

type cachedStableToken struct {
	Value     string
	ExpiresAt time.Time
}

type stableTokenResponse struct {
	AccessToken string `json:"access_token"`
	ExpiresIn   int    `json:"expires_in"`
	ErrCode     int    `json:"errcode"`
}

type phoneNumberResponse struct {
	ErrCode   int `json:"errcode"`
	PhoneInfo struct {
		CountryCode     string `json:"countryCode"`
		PhoneNumber     string `json:"phoneNumber"`
		PurePhoneNumber string `json:"purePhoneNumber"`
	} `json:"phone_info"`
}

// PhoneNumber exchanges the one-shot getPhoneNumber credential without ever
// serializing it into logs or errors. A retry is allowed only after WeChat has
// explicitly confirmed that the access token (not the phone code) is invalid.
func (p *HTTPProvider) PhoneNumber(ctx context.Context, phoneCode string) (Phone, error) {
	phoneCode = strings.TrimSpace(phoneCode)
	if phoneCode == "" {
		return Phone{}, fmt.Errorf("wechat phone code must be non-empty")
	}
	token, err := p.loadStableToken(ctx, false)
	if err != nil {
		return Phone{}, err
	}
	phone, tokenInvalid, err := p.exchangePhoneNumber(ctx, token, phoneCode)
	if err == nil {
		return phone, nil
	}
	if !tokenInvalid {
		return Phone{}, err
	}

	// A known invalid token means WeChat did not ambiguously process the phone
	// credential. Clear only the matching cache entry and retry once with a new
	// token; network and phone-code failures never retry.
	p.clearStableToken(token)
	token, refreshErr := p.loadStableToken(ctx, true)
	if refreshErr != nil {
		return Phone{}, refreshErr
	}
	phone, _, err = p.exchangePhoneNumber(ctx, token, phoneCode)
	if err != nil {
		return Phone{}, err
	}
	return phone, nil
}

func (p *HTTPProvider) loadStableToken(ctx context.Context, forceRefresh bool) (string, error) {
	if !forceRefresh {
		if value, ok := p.cachedStableToken(); ok {
			return value, nil
		}
	}
	flightKey := "stable-token"
	if forceRefresh {
		flightKey = "stable-token-force-refresh"
	}
	value, err, _ := p.stableTokenFlight.Do(flightKey, func() (any, error) {
		if !forceRefresh {
			if cached, ok := p.cachedStableToken(); ok {
				return cached, nil
			}
		}
		return p.requestStableToken(ctx, forceRefresh)
	})
	if err != nil {
		return "", err
	}
	token, ok := value.(string)
	if !ok || token == "" {
		return "", fmt.Errorf("wechat stable token returned an invalid value")
	}
	return token, nil
}

func (p *HTTPProvider) cachedStableToken() (string, bool) {
	p.stableTokenMu.Lock()
	defer p.stableTokenMu.Unlock()
	if p.stableToken.Value == "" || !time.Now().Before(p.stableToken.ExpiresAt.Add(-stableTokenRefreshAhead)) {
		return "", false
	}
	return p.stableToken.Value, true
}

func (p *HTTPProvider) clearStableToken(stale string) {
	p.stableTokenMu.Lock()
	defer p.stableTokenMu.Unlock()
	if p.stableToken.Value == stale {
		p.stableToken = cachedStableToken{}
	}
}

func (p *HTTPProvider) requestStableToken(ctx context.Context, forceRefresh bool) (string, error) {
	payload, err := json.Marshal(map[string]any{
		"grant_type":    "client_credential",
		"appid":         p.AppID,
		"secret":        p.Secret,
		"force_refresh": forceRefresh,
	})
	if err != nil {
		return "", fmt.Errorf("wechat stable token encode failed")
	}
	endpoint := strings.TrimRight(strings.TrimSpace(p.StableTokenEndpoint), "?")
	if endpoint == "" {
		endpoint = defaultStableTokenEndpoint
	}
	request, err := http.NewRequestWithContext(ctx, http.MethodPost, endpoint, strings.NewReader(string(payload)))
	if err != nil {
		return "", fmt.Errorf("wechat stable token request failed")
	}
	request.Header.Set("Content-Type", "application/json")
	response, err := p.httpClient().Do(request)
	if err != nil {
		return "", fmt.Errorf("wechat stable token request failed")
	}
	defer response.Body.Close()
	body, err := io.ReadAll(io.LimitReader(response.Body, 4096))
	if err != nil {
		return "", fmt.Errorf("wechat stable token read failed")
	}
	if response.StatusCode != http.StatusOK {
		return "", fmt.Errorf("wechat stable token status %d", response.StatusCode)
	}
	var parsed stableTokenResponse
	if err := json.Unmarshal(body, &parsed); err != nil {
		return "", fmt.Errorf("wechat stable token decode failed")
	}
	if parsed.ErrCode != 0 || strings.TrimSpace(parsed.AccessToken) == "" {
		return "", fmt.Errorf("wechat stable token errcode %d", parsed.ErrCode)
	}
	expiresIn := time.Duration(parsed.ExpiresIn) * time.Second
	if expiresIn <= 0 {
		expiresIn = 2 * time.Hour
	}
	p.stableTokenMu.Lock()
	p.stableToken = cachedStableToken{Value: parsed.AccessToken, ExpiresAt: time.Now().Add(expiresIn)}
	p.stableTokenMu.Unlock()
	return parsed.AccessToken, nil
}

func (p *HTTPProvider) exchangePhoneNumber(ctx context.Context, accessToken, phoneCode string) (Phone, bool, error) {
	payload, err := json.Marshal(map[string]string{"code": phoneCode})
	if err != nil {
		return Phone{}, false, fmt.Errorf("wechat phone exchange encode failed")
	}
	endpoint := strings.TrimRight(strings.TrimSpace(p.PhoneEndpoint), "?")
	if endpoint == "" {
		endpoint = defaultPhoneEndpoint
	}
	query := url.Values{}
	query.Set("access_token", accessToken)
	request, err := http.NewRequestWithContext(ctx, http.MethodPost, endpoint+"?"+query.Encode(), strings.NewReader(string(payload)))
	if err != nil {
		return Phone{}, false, fmt.Errorf("wechat phone exchange request failed")
	}
	request.Header.Set("Content-Type", "application/json")
	response, err := p.httpClient().Do(request)
	if err != nil {
		return Phone{}, false, fmt.Errorf("wechat phone exchange request failed")
	}
	defer response.Body.Close()
	body, err := io.ReadAll(io.LimitReader(response.Body, 4096))
	if err != nil {
		return Phone{}, false, fmt.Errorf("wechat phone exchange read failed")
	}
	if response.StatusCode != http.StatusOK {
		return Phone{}, false, fmt.Errorf("wechat phone exchange status %d", response.StatusCode)
	}
	var parsed phoneNumberResponse
	if err := json.Unmarshal(body, &parsed); err != nil {
		return Phone{}, false, fmt.Errorf("wechat phone exchange decode failed")
	}
	if parsed.ErrCode != 0 {
		return Phone{}, isWechatTokenInvalid(parsed.ErrCode), fmt.Errorf("wechat phone exchange errcode %d", parsed.ErrCode)
	}
	phone, err := parseWechatPhone(parsed.PhoneInfo.CountryCode, parsed.PhoneInfo.PhoneNumber, parsed.PhoneInfo.PurePhoneNumber)
	if err != nil {
		return Phone{}, false, err
	}
	return phone, false, nil
}

func isWechatTokenInvalid(errCode int) bool {
	switch errCode {
	case 40001, 40014, 42001:
		return true
	default:
		return false
	}
}

func parseWechatPhone(countryCode, phoneNumber, purePhoneNumber string) (Phone, error) {
	countryCode = strings.TrimSpace(countryCode)
	phoneNumber = strings.TrimSpace(phoneNumber)
	purePhoneNumber = strings.TrimSpace(purePhoneNumber)
	if !digitsOnly(countryCode) {
		return Phone{}, fmt.Errorf("wechat phone response has an invalid country code")
	}
	if purePhoneNumber != "" {
		if !digitsOnly(purePhoneNumber) {
			return Phone{}, fmt.Errorf("wechat phone response has an invalid number")
		}
		return Phone{CountryCode: countryCode, Number: "+" + countryCode + purePhoneNumber}, nil
	}
	if strings.HasPrefix(phoneNumber, "+") {
		phoneNumber = strings.TrimPrefix(phoneNumber, "+")
		if !digitsOnly(phoneNumber) {
			return Phone{}, fmt.Errorf("wechat phone response has an invalid number")
		}
		return Phone{CountryCode: countryCode, Number: "+" + phoneNumber}, nil
	}
	if !digitsOnly(phoneNumber) {
		return Phone{}, fmt.Errorf("wechat phone response has an invalid number")
	}
	return Phone{CountryCode: countryCode, Number: "+" + countryCode + phoneNumber}, nil
}

func digitsOnly(value string) bool {
	if value == "" {
		return false
	}
	for _, char := range value {
		if char < '0' || char > '9' {
			return false
		}
	}
	return true
}
