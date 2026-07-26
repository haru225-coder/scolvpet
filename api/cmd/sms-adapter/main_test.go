package main

import (
	"crypto/hmac"
	"crypto/sha1"
	"encoding/base64"
	"encoding/json"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"testing"
	"time"
)

func testConfig() adapterConfig {
	return adapterConfig{
		Addr:         "127.0.0.1:0",
		Token:        "adapter-secret",
		AccessKeyID:  "testkeyid",
		AccessSecret: "testsecret",
		SignName:     "测试签名",
		TemplateCode: "SMS_0000",
		RegionID:     "cn-hangzhou",
		Endpoint:     "https://dysmsapi.aliyuncs.com/",
	}
}

func newTestAdapter(config adapterConfig) *adapter {
	return &adapter{config: config, logger: slog.New(slog.NewTextHandler(testWriter{}, nil)), client: &http.Client{Timeout: 2 * time.Second}}
}

type testWriter struct{}

func (testWriter) Write(p []byte) (int, error) { return len(p), nil }

func TestLoadConfigFailsClosed(t *testing.T) {
	env := map[string]string{}
	lookup := func(key string) (string, bool) { value, ok := env[key]; return value, ok }
	if _, err := loadConfig(lookup); err == nil || !strings.Contains(err.Error(), "SMS_ADAPTER_TOKEN") {
		t.Fatalf("missing token must fail: %v", err)
	}
	env["SMS_ADAPTER_TOKEN"] = "tok"
	if _, err := loadConfig(lookup); err == nil || !strings.Contains(err.Error(), "ALIYUN_ACCESS_KEY_ID") {
		t.Fatalf("missing vendor config must fail with the missing keys listed: %v", err)
	}
	env["SMS_ADAPTER_DRY_RUN"] = "1"
	config, err := loadConfig(lookup)
	if err != nil || !config.DryRun {
		t.Fatalf("dry-run must not require vendor config: %v", err)
	}
}

func TestHandleSendAuthAndValidation(t *testing.T) {
	config := testConfig()
	config.DryRun = true
	server := httptest.NewServer(newTestAdapter(config).handler())
	defer server.Close()

	post := func(token, body string) *http.Response {
		request, _ := http.NewRequest(http.MethodPost, server.URL+"/send", strings.NewReader(body))
		if token != "" {
			request.Header.Set("Authorization", "Bearer "+token)
		}
		response, err := http.DefaultClient.Do(request)
		if err != nil {
			t.Fatalf("request: %v", err)
		}
		return response
	}

	if response := post("", `{}`); response.StatusCode != http.StatusUnauthorized {
		t.Fatalf("missing bearer: %d", response.StatusCode)
	}
	if response := post("wrong", `{}`); response.StatusCode != http.StatusUnauthorized {
		t.Fatalf("wrong bearer: %d", response.StatusCode)
	}
	if response := post("adapter-secret", `{"phone":"13800138000","code":"123456"}`); response.StatusCode != http.StatusUnprocessableEntity {
		t.Fatalf("non-canonical phone must be rejected: %d", response.StatusCode)
	}
	if response := post("adapter-secret", `{"phone":"+8613800138000","code":"abc"}`); response.StatusCode != http.StatusUnprocessableEntity {
		t.Fatalf("non-numeric code must be rejected: %d", response.StatusCode)
	}
	response := post("adapter-secret", `{"phone":"+8613800138000","code":"123456","expires_in_seconds":300}`)
	if response.StatusCode != http.StatusOK {
		t.Fatalf("dry-run happy path: %d", response.StatusCode)
	}
}

func TestAliyunRequestShape(t *testing.T) {
	var received url.Values
	vendor := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_ = r.ParseForm()
		received = r.PostForm
		_, _ = w.Write([]byte(`{"Code":"OK","Message":"OK","BizId":"biz-1"}`))
	}))
	defer vendor.Close()

	config := testConfig()
	config.Endpoint = vendor.URL
	instance := newTestAdapter(config)
	server := httptest.NewServer(instance.handler())
	defer server.Close()

	request, _ := http.NewRequest(http.MethodPost, server.URL+"/send", strings.NewReader(`{"phone":"+8613800138000","code":"654321","expires_in_seconds":300}`))
	request.Header.Set("Authorization", "Bearer adapter-secret")
	response, err := http.DefaultClient.Do(request)
	if err != nil || response.StatusCode != http.StatusOK {
		t.Fatalf("send: %v %d", err, response.StatusCode)
	}

	if received.Get("PhoneNumbers") != "13800138000" {
		t.Fatalf("PhoneNumbers must strip +86, got %q", received.Get("PhoneNumbers"))
	}
	var templateParam map[string]string
	if err := json.Unmarshal([]byte(received.Get("TemplateParam")), &templateParam); err != nil || templateParam["code"] != "654321" {
		t.Fatalf("TemplateParam must carry the code: %q", received.Get("TemplateParam"))
	}
	if received.Get("Signature") == "" || received.Get("SignatureNonce") == "" {
		t.Fatal("signature fields missing")
	}
	if received.Get("Action") != "SendSms" || received.Get("Version") != "2017-05-25" {
		t.Fatalf("rpc action fields wrong: %v", received)
	}
	// Recompute the signature from the received params to pin the algorithm.
	params := map[string]string{}
	for key := range received {
		if key != "Signature" {
			params[key] = received.Get(key)
		}
	}
	mac := hmac.New(sha1.New, []byte("testsecret&"))
	mac.Write([]byte(stringToSign(http.MethodPost, params)))
	expected := base64.StdEncoding.EncodeToString(mac.Sum(nil))
	if received.Get("Signature") != expected {
		t.Fatalf("signature mismatch: got %q want %q", received.Get("Signature"), expected)
	}
}

func TestVendorRejectionMapsToBadGateway(t *testing.T) {
	vendor := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write([]byte(`{"Code":"isv.BUSINESS_LIMIT_CONTROL","Message":"limited"}`))
	}))
	defer vendor.Close()

	config := testConfig()
	config.Endpoint = vendor.URL
	server := httptest.NewServer(newTestAdapter(config).handler())
	defer server.Close()

	request, _ := http.NewRequest(http.MethodPost, server.URL+"/send", strings.NewReader(`{"phone":"+8613800138000","code":"654321"}`))
	request.Header.Set("Authorization", "Bearer adapter-secret")
	response, err := http.DefaultClient.Do(request)
	if err != nil {
		t.Fatalf("send: %v", err)
	}
	if response.StatusCode != http.StatusBadGateway {
		t.Fatalf("vendor rejection must map to 502, got %d", response.StatusCode)
	}
}

// The canonical string format is where signature bugs live; pin it exactly.
func TestStringToSignCanonicalForm(t *testing.T) {
	params := map[string]string{
		"Action":        "SendSms",
		"TemplateParam": `{"code":"1234"}`,
		"SignName":      "测试 签名*~",
	}
	got := stringToSign(http.MethodPost, params)
	want := "POST&%2F&Action%3DSendSms" +
		"%26SignName%3D%25E6%25B5%258B%25E8%25AF%2595%2520%25E7%25AD%25BE%25E5%2590%258D%252A~" +
		"%26TemplateParam%3D%257B%2522code%2522%253A%25221234%2522%257D"
	if got != want {
		t.Fatalf("canonical form drift:\n got %s\nwant %s", got, want)
	}
}
