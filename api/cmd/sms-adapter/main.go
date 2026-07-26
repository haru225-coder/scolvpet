// sms-adapter bridges the core sms.HTTPProvider webhook contract to the
// Aliyun Dysmsapi SendSms RPC API (docs/30 P3, plan A: the core stays on the
// http provider contract, this thin adapter runs next to it on the VPS).
//
// Contract in:  POST {path} {"phone":"+86...","code":"123456","expires_in_seconds":300}
//
//	Authorization: Bearer $SMS_ADAPTER_TOKEN — 2xx means accepted.
//
// Contract out: Aliyun SendSms with TemplateParam {"code": ...}.
//
// The verification code must never be logged; phones are masked in logs.
package main

import (
	"context"
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha1"
	"crypto/subtle"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"net/url"
	"os"
	"regexp"
	"sort"
	"strings"
	"time"
)

type adapterConfig struct {
	Addr         string
	Token        string
	DryRun       bool
	AccessKeyID  string
	AccessSecret string
	SignName     string
	TemplateCode string
	RegionID     string
	Endpoint     string
}

func loadConfig(lookup func(string) (string, bool)) (adapterConfig, error) {
	get := func(key, fallback string) string {
		if value, ok := lookup(key); ok {
			return strings.TrimSpace(value)
		}
		return fallback
	}
	config := adapterConfig{
		Addr:         get("SMS_ADAPTER_ADDR", "127.0.0.1:9481"),
		Token:        get("SMS_ADAPTER_TOKEN", ""),
		DryRun:       get("SMS_ADAPTER_DRY_RUN", "0") == "1",
		AccessKeyID:  get("ALIYUN_ACCESS_KEY_ID", ""),
		AccessSecret: get("ALIYUN_ACCESS_KEY_SECRET", ""),
		SignName:     get("ALIYUN_SMS_SIGN_NAME", ""),
		TemplateCode: get("ALIYUN_SMS_TEMPLATE_CODE", ""),
		RegionID:     get("ALIYUN_REGION_ID", "cn-hangzhou"),
		Endpoint:     get("ALIYUN_SMS_ENDPOINT", "https://dysmsapi.aliyuncs.com/"),
	}
	if config.Token == "" {
		return adapterConfig{}, fmt.Errorf("SMS_ADAPTER_TOKEN is required (bearer shared with SMS_HTTP_TOKEN)")
	}
	if !config.DryRun {
		missing := []string{}
		for key, value := range map[string]string{
			"ALIYUN_ACCESS_KEY_ID":     config.AccessKeyID,
			"ALIYUN_ACCESS_KEY_SECRET": config.AccessSecret,
			"ALIYUN_SMS_SIGN_NAME":     config.SignName,
			"ALIYUN_SMS_TEMPLATE_CODE": config.TemplateCode,
		} {
			if value == "" {
				missing = append(missing, key)
			}
		}
		if len(missing) > 0 {
			sort.Strings(missing)
			return adapterConfig{}, fmt.Errorf("missing vendor config (set SMS_ADAPTER_DRY_RUN=1 to run without): %s", strings.Join(missing, ", "))
		}
	}
	return config, nil
}

type sendRequest struct {
	Phone            string `json:"phone"`
	Code             string `json:"code"`
	ExpiresInSeconds int    `json:"expires_in_seconds"`
}

var (
	phonePattern = regexp.MustCompile(`^\+86[0-9]{6,20}$`)
	codePattern  = regexp.MustCompile(`^[0-9]{4,8}$`)
)

type adapter struct {
	config adapterConfig
	logger *slog.Logger
	client *http.Client
}

func maskPhone(phone string) string {
	if len(phone) <= 4 {
		return "****"
	}
	return "****" + phone[len(phone)-4:]
}

func (a *adapter) handleSend(w http.ResponseWriter, r *http.Request) {
	auth := strings.TrimSpace(r.Header.Get("Authorization"))
	expected := "Bearer " + a.config.Token
	if subtle.ConstantTimeCompare([]byte(auth), []byte(expected)) != 1 {
		http.Error(w, `{"error":"unauthorized"}`, http.StatusUnauthorized)
		return
	}
	var request sendRequest
	body, err := io.ReadAll(io.LimitReader(r.Body, 4096))
	if err != nil || json.Unmarshal(body, &request) != nil {
		http.Error(w, `{"error":"invalid body"}`, http.StatusUnprocessableEntity)
		return
	}
	if !phonePattern.MatchString(request.Phone) || !codePattern.MatchString(request.Code) {
		http.Error(w, `{"error":"invalid phone or code shape"}`, http.StatusUnprocessableEntity)
		return
	}
	if a.config.DryRun {
		a.logger.Info("dry-run send", "phone", maskPhone(request.Phone))
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"status":"dry_run"}`))
		return
	}
	if err := a.sendAliyun(r.Context(), request.Phone, request.Code); err != nil {
		// Vendor code only — the verification code must never appear here.
		a.logger.Error("vendor send failed", "phone", maskPhone(request.Phone), "error", err.Error())
		http.Error(w, `{"error":"vendor send failed"}`, http.StatusBadGateway)
		return
	}
	a.logger.Info("sent", "phone", maskPhone(request.Phone))
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write([]byte(`{"status":"sent"}`))
}

// --- Aliyun Dysmsapi RPC signature (no SDK dependency) ---

// percentEncode implements Aliyun's RFC3986-style encoding: encodeURIComponent
// plus space→%20, *→%2A, %7E→~.
func percentEncode(value string) string {
	encoded := url.QueryEscape(value)
	encoded = strings.ReplaceAll(encoded, "+", "%20")
	encoded = strings.ReplaceAll(encoded, "*", "%2A")
	encoded = strings.ReplaceAll(encoded, "%7E", "~")
	return encoded
}

func canonicalQuery(params map[string]string) string {
	keys := make([]string, 0, len(params))
	for key := range params {
		keys = append(keys, key)
	}
	sort.Strings(keys)
	pairs := make([]string, 0, len(keys))
	for _, key := range keys {
		pairs = append(pairs, percentEncode(key)+"="+percentEncode(params[key]))
	}
	return strings.Join(pairs, "&")
}

func stringToSign(method string, params map[string]string) string {
	return method + "&" + percentEncode("/") + "&" + percentEncode(canonicalQuery(params))
}

func sign(secret, toSign string) string {
	mac := hmac.New(sha1.New, []byte(secret+"&"))
	mac.Write([]byte(toSign))
	return base64.StdEncoding.EncodeToString(mac.Sum(nil))
}

func nonce() string {
	buf := make([]byte, 16)
	if _, err := rand.Read(buf); err != nil {
		return fmt.Sprintf("%d", time.Now().UnixNano())
	}
	return hex.EncodeToString(buf)
}

func (a *adapter) aliyunParams(phone, code string, now time.Time) (map[string]string, error) {
	templateParam, err := json.Marshal(map[string]string{"code": code})
	if err != nil {
		return nil, err
	}
	return map[string]string{
		"AccessKeyId":      a.config.AccessKeyID,
		"Action":           "SendSms",
		"Format":           "JSON",
		"PhoneNumbers":     strings.TrimPrefix(phone, "+86"),
		"RegionId":         a.config.RegionID,
		"SignName":         a.config.SignName,
		"SignatureMethod":  "HMAC-SHA1",
		"SignatureNonce":   nonce(),
		"SignatureVersion": "1.0",
		"TemplateCode":     a.config.TemplateCode,
		"TemplateParam":    string(templateParam),
		"Timestamp":        now.UTC().Format("2006-01-02T15:04:05Z"),
		"Version":          "2017-05-25",
	}, nil
}

type aliyunResponse struct {
	Code    string `json:"Code"`
	Message string `json:"Message"`
	BizID   string `json:"BizId"`
}

func (a *adapter) sendAliyun(ctx context.Context, phone, code string) error {
	params, err := a.aliyunParams(phone, code, time.Now())
	if err != nil {
		return err
	}
	params["Signature"] = sign(a.config.AccessSecret, stringToSign(http.MethodPost, params))
	form := url.Values{}
	for key, value := range params {
		form.Set(key, value)
	}
	request, err := http.NewRequestWithContext(ctx, http.MethodPost, a.config.Endpoint, strings.NewReader(form.Encode()))
	if err != nil {
		return err
	}
	request.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	response, err := a.client.Do(request)
	if err != nil {
		return fmt.Errorf("aliyun request: %w", err)
	}
	defer response.Body.Close()
	payload, _ := io.ReadAll(io.LimitReader(response.Body, 4096))
	var parsed aliyunResponse
	if err := json.Unmarshal(payload, &parsed); err != nil {
		return fmt.Errorf("aliyun response status %d: unparseable body", response.StatusCode)
	}
	if parsed.Code != "OK" {
		return fmt.Errorf("aliyun rejected: %s (%s)", parsed.Code, parsed.Message)
	}
	return nil
}

func (a *adapter) handler() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /healthz", func(w http.ResponseWriter, _ *http.Request) {
		mode := "aliyun"
		if a.config.DryRun {
			mode = "dry_run"
		}
		w.Header().Set("Content-Type", "application/json")
		_, _ = fmt.Fprintf(w, `{"status":"ok","service":"scolvpet-sms-adapter","mode":%q}`, mode)
	})
	mux.HandleFunc("POST /send", a.handleSend)
	mux.HandleFunc("POST /{$}", a.handleSend)
	return mux
}

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
	config, err := loadConfig(os.LookupEnv)
	if err != nil {
		logger.Error("config invalid", "error", err)
		os.Exit(1)
	}
	instance := &adapter{config: config, logger: logger, client: &http.Client{Timeout: 10 * time.Second}}
	logger.Info("sms adapter listening", "addr", config.Addr, "dry_run", config.DryRun)
	server := &http.Server{Addr: config.Addr, Handler: instance.handler(), ReadHeaderTimeout: 5 * time.Second}
	if err := server.ListenAndServe(); err != nil {
		logger.Error("server stopped", "error", err)
		os.Exit(1)
	}
}
