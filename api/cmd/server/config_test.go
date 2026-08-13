package main

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/scolvpet/scolvpet/api/internal/objectstore"
)

func mapLookup(values map[string]string) envLookup {
	return func(key string) (string, bool) {
		value, ok := values[key]
		return value, ok
	}
}

func TestLoadRuntimeConfigDevelopmentDefaults(t *testing.T) {
	config, err := loadRuntimeConfigFrom(mapLookup(map[string]string{}))
	if err != nil {
		t.Fatalf("load development config: %v", err)
	}
	if config.Environment != "development" {
		t.Fatalf("environment: got %q", config.Environment)
	}
	if config.DatabaseURL != defaultDatabaseURL {
		t.Fatalf("database default: got %q", config.DatabaseURL)
	}
	if config.JWTSecret != defaultJWTSecret || config.SMSMockCode != defaultSMSMockCode {
		t.Fatalf("development auth defaults were not preserved")
	}
	if config.MediaWorkerIntervalSecs != 2 || config.MediaWorkerDisabled {
		t.Fatalf("media worker development defaults were not preserved")
	}
}

func TestLoadRuntimeConfigRejectsUnknownEnvironment(t *testing.T) {
	_, err := loadRuntimeConfigFrom(mapLookup(map[string]string{"APP_ENV": "prod"}))
	if err == nil || !strings.Contains(err.Error(), "APP_ENV must be one of") {
		t.Fatalf("expected environment validation error, got %v", err)
	}
}

func TestLoadRuntimeConfigProductionRequiresExplicitSecretsAndAdapters(t *testing.T) {
	_, err := loadRuntimeConfigFrom(mapLookup(map[string]string{"APP_ENV": "production"}))
	if err == nil {
		t.Fatal("expected production config rejection")
	}
	message := err.Error()
	for _, expected := range []string{
		"DATABASE_URL must be explicitly set",
		"JWT_SECRET must be explicitly set",
		"SMS_PROVIDER must be http for the production webhook adapter",
		"OBJECT_STORE_PROVIDER must be s3 or minio in production",
	} {
		if !strings.Contains(message, expected) {
			t.Fatalf("production error missing %q: %s", expected, message)
		}
	}
}

func TestLoadRuntimeConfigProductionRejectsUnwiredAdaptersAndDisabledWorkers(t *testing.T) {
	values := map[string]string{
		"APP_ENV":                "production",
		"DATABASE_URL":           "postgres://db.example/scolvpet?sslmode=require",
		"JWT_SECRET":             "production-secret-from-secret-manager",
		"SMS_PROVIDER":           "aliyun",
		"SMS_MOCK_CODE":          "",
		"OBJECT_STORE_PROVIDER":  "s3",
		"OUTBOX_WORKER_DISABLED": "1",
		"MEDIA_WORKER_DISABLED":  "1",
		"OUTBOX_PUBLISHER_MODE":  "fail",
	}
	_, err := loadRuntimeConfigFrom(mapLookup(values))
	if err == nil {
		t.Fatal("expected production adapter rejection")
	}
	message := err.Error()
	for _, expected := range []string{
		"SMS_PROVIDER must be http for the production webhook adapter",
		"OBJECT_STORE_ENDPOINT must be explicitly set",
		"OUTBOX_WORKER_DISABLED=1",
		"MEDIA_WORKER_DISABLED=1",
		"OUTBOX_PUBLISHER_MODE=fail",
	} {
		if !strings.Contains(message, expected) {
			t.Fatalf("production error missing %q: %s", expected, message)
		}
	}
}

func TestLoadRuntimeConfigProductionAcceptsConfiguredHTTPSMSProvider(t *testing.T) {
	values := map[string]string{
		"APP_ENV":                        "production",
		"DATABASE_URL":                   "postgres://db.example/scolvpet?sslmode=require",
		"JWT_SECRET":                     "production-secret-from-secret-manager",
		"SMS_PROVIDER":                   "http",
		"SMS_HTTP_ENDPOINT":              "https://sms.example.test/send",
		"SMS_HTTP_TOKEN":                 "token-from-secret-manager",
		"WECHAT_PROVIDER":                "http",
		"WECHAT_APPID":                   "wx1234567890abcdef",
		"WECHAT_SECRET":                  "wechat-secret-from-secret-manager",
		"WECHAT_TASK_TEMPLATE_ID":        "tmpl-task-from-config",
		"WECHAT_RESERVATION_TEMPLATE_ID": "tmpl-reservation-from-config",
		"WECHAT_PHONE_GLOBAL_PER_MINUTE": "120",
		"WECHAT_PHONE_GLOBAL_PER_DAY":    "5000",
		"OBJECT_STORE_PROVIDER":          "s3",
		"OBJECT_STORE_ENDPOINT":          "https://s3.us-east-1.amazonaws.com",
		"OBJECT_STORE_BUCKET":            "scolvpet-production",
		"OBJECT_STORE_REGION":            "us-east-1",
		"OBJECT_STORE_ACCESS_KEY":        "access-key-from-secret-manager",
		"OBJECT_STORE_SECRET_KEY":        "secret-key-from-secret-manager",
		"OUTBOX_PUBLISHER_MODE":          "http",
		"OUTBOX_PUBLISHER_ENDPOINT":      "https://events.example.test/publish",
		"OUTBOX_PUBLISHER_TOKEN":         "publisher-token-from-secret-manager",
	}
	_, err := loadRuntimeConfigFrom(mapLookup(values))
	if err != nil {
		t.Fatalf("configured production providers were rejected: %v", err)
	}
}

func TestLoadRuntimeConfigWechatDefaultsToMock(t *testing.T) {
	config, err := loadRuntimeConfigFrom(mapLookup(map[string]string{}))
	if err != nil {
		t.Fatalf("load development config: %v", err)
	}
	if config.WechatProvider != "mock" {
		t.Fatalf("wechat provider default: got %q", config.WechatProvider)
	}
}

func TestLoadRuntimeConfigRejectsUnknownWechatProvider(t *testing.T) {
	_, err := loadRuntimeConfigFrom(mapLookup(map[string]string{"WECHAT_PROVIDER": "real"}))
	if err == nil || !strings.Contains(err.Error(), "WECHAT_PROVIDER must be one of") {
		t.Fatalf("expected wechat provider validation error, got %v", err)
	}
}

func TestLoadRuntimeConfigProductionRequiresWechatHTTPProvider(t *testing.T) {
	_, err := loadRuntimeConfigFrom(mapLookup(map[string]string{"APP_ENV": "production"}))
	if err == nil {
		t.Fatal("expected production config rejection")
	}
	if !strings.Contains(err.Error(), "WECHAT_PROVIDER must be http for the production code2Session exchange") {
		t.Fatalf("production error missing wechat provider issue: %v", err)
	}
}

func TestLoadRuntimeConfigProductionRequiresWechatCredentials(t *testing.T) {
	_, err := loadRuntimeConfigFrom(mapLookup(map[string]string{
		"APP_ENV":         "production",
		"WECHAT_PROVIDER": "http",
	}))
	if err == nil {
		t.Fatal("expected production config rejection")
	}
	message := err.Error()
	for _, expected := range []string{
		"WECHAT_APPID must be explicitly set",
		"WECHAT_SECRET must be explicitly set",
	} {
		if !strings.Contains(message, expected) {
			t.Fatalf("production error missing %q: %s", expected, message)
		}
	}
}

func TestLoadRuntimeConfigProductionRequiresPositiveWechatPhoneQuotas(t *testing.T) {
	base := map[string]string{
		"APP_ENV":                        "production",
		"DATABASE_URL":                   "postgres://db.example/scolvpet?sslmode=require",
		"JWT_SECRET":                     "production-secret-from-secret-manager",
		"SMS_PROVIDER":                   "http",
		"SMS_HTTP_ENDPOINT":              "https://sms.example.test/send",
		"SMS_HTTP_TOKEN":                 "token-from-secret-manager",
		"WECHAT_PROVIDER":                "http",
		"WECHAT_APPID":                   "wx1234567890abcdef",
		"WECHAT_SECRET":                  "wechat-secret-from-secret-manager",
		"WECHAT_TASK_TEMPLATE_ID":        "tmpl-task-from-config",
		"WECHAT_RESERVATION_TEMPLATE_ID": "tmpl-reservation-from-config",
		"OBJECT_STORE_PROVIDER":          "s3",
		"OBJECT_STORE_ENDPOINT":          "https://s3.us-east-1.amazonaws.com",
		"OBJECT_STORE_BUCKET":            "scolvpet-production",
		"OBJECT_STORE_REGION":            "us-east-1",
		"OBJECT_STORE_ACCESS_KEY":        "access-key-from-secret-manager",
		"OBJECT_STORE_SECRET_KEY":        "secret-key-from-secret-manager",
		"OUTBOX_PUBLISHER_MODE":          "http",
		"OUTBOX_PUBLISHER_ENDPOINT":      "https://events.example.test/publish",
		"OUTBOX_PUBLISHER_TOKEN":         "publisher-token-from-secret-manager",
		"WECHAT_PHONE_GLOBAL_PER_MINUTE": "120",
		"WECHAT_PHONE_GLOBAL_PER_DAY":    "5000",
	}
	for _, tc := range []struct {
		name     string
		key      string
		value    string
		expected string
	}{
		{name: "missing minute quota", key: "WECHAT_PHONE_GLOBAL_PER_MINUTE", expected: "WECHAT_PHONE_GLOBAL_PER_MINUTE"},
		{name: "missing daily quota", key: "WECHAT_PHONE_GLOBAL_PER_DAY", expected: "WECHAT_PHONE_GLOBAL_PER_DAY"},
		{name: "zero minute quota", key: "WECHAT_PHONE_GLOBAL_PER_MINUTE", value: "0", expected: "WECHAT_PHONE_GLOBAL_PER_MINUTE"},
		{name: "invalid daily quota", key: "WECHAT_PHONE_GLOBAL_PER_DAY", value: "many", expected: "WECHAT_PHONE_GLOBAL_PER_DAY"},
	} {
		t.Run(tc.name, func(t *testing.T) {
			values := make(map[string]string, len(base))
			for key, value := range base {
				values[key] = value
			}
			if tc.value == "" {
				delete(values, tc.key)
			} else {
				values[tc.key] = tc.value
			}
			_, err := loadRuntimeConfigFrom(mapLookup(values))
			if err == nil || !strings.Contains(err.Error(), tc.expected) {
				t.Fatalf("production configuration should reject %s: %v", tc.name, err)
			}
		})
	}
}

func TestLoadRuntimeConfigMinIODefaultsToPathStyle(t *testing.T) {
	values := map[string]string{
		"APP_ENV":                        "production",
		"DATABASE_URL":                   "postgres://db.example/scolvpet?sslmode=require",
		"JWT_SECRET":                     "production-secret-from-secret-manager",
		"SMS_PROVIDER":                   "http",
		"SMS_HTTP_ENDPOINT":              "https://sms.example.test/send",
		"SMS_HTTP_TOKEN":                 "token-from-secret-manager",
		"WECHAT_PROVIDER":                "http",
		"WECHAT_APPID":                   "wx1234567890abcdef",
		"WECHAT_SECRET":                  "wechat-secret-from-secret-manager",
		"WECHAT_TASK_TEMPLATE_ID":        "tmpl-task-from-config",
		"WECHAT_RESERVATION_TEMPLATE_ID": "tmpl-reservation-from-config",
		"WECHAT_PHONE_GLOBAL_PER_MINUTE": "120",
		"WECHAT_PHONE_GLOBAL_PER_DAY":    "5000",
		"OBJECT_STORE_PROVIDER":          "minio",
		"OBJECT_STORE_ENDPOINT":          "http://minio.internal:9000",
		"OBJECT_STORE_BUCKET":            "scolvpet-production",
		"OBJECT_STORE_REGION":            "us-east-1",
		"OBJECT_STORE_ACCESS_KEY":        "minio-access",
		"OBJECT_STORE_SECRET_KEY":        "minio-secret",
		"OUTBOX_PUBLISHER_MODE":          "http",
		"OUTBOX_PUBLISHER_ENDPOINT":      "https://events.example.test/publish",
		"OUTBOX_PUBLISHER_TOKEN":         "publisher-token",
	}
	config, err := loadRuntimeConfigFrom(mapLookup(values))
	if err != nil {
		t.Fatalf("configured MinIO provider was rejected: %v", err)
	}
	if !config.ObjectStorePathStyle {
		t.Fatal("MinIO should default to path-style addressing")
	}
}

func TestLoadRuntimeConfigRejectsInvalidObjectStorePathStyle(t *testing.T) {
	_, err := loadRuntimeConfigFrom(mapLookup(map[string]string{
		"OBJECT_STORE_PATH_STYLE": "sometimes",
	}))
	if err == nil || !strings.Contains(err.Error(), "OBJECT_STORE_PATH_STYLE must be true or false") {
		t.Fatalf("expected path-style validation error, got %v", err)
	}
}

func TestNewObjectStoreBuildsConfiguredS3Implementation(t *testing.T) {
	configured, err := newObjectStore(runtimeConfig{
		ObjectStoreProvider:  "minio",
		ObjectStoreEndpoint:  "http://minio.example.test:9000",
		ObjectStoreBucket:    "scolvpet",
		ObjectStoreRegion:    "us-east-1",
		ObjectStoreAccessKey: "access",
		ObjectStoreSecretKey: "secret",
		ObjectStorePathStyle: true,
	})
	if err != nil {
		t.Fatalf("newObjectStore() error = %v", err)
	}
	if _, ok := configured.(*objectstore.S3ObjectStore); !ok {
		t.Fatalf("newObjectStore() type = %T, want *objectstore.S3ObjectStore", configured)
	}
}

func TestProductionEnvExampleDeclaresFailClosedKeys(t *testing.T) {
	path := filepath.Join("..", "..", "..", "deploy", "vps", ".env.production.example")
	body, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("read production env example: %v", err)
	}
	text := string(body)
	for _, key := range []string{
		"WECHAT_PHONE_GLOBAL_PER_MINUTE",
		"WECHAT_PHONE_GLOBAL_PER_DAY",
		"WECHAT_PROVIDER",
		"WECHAT_SUBSCRIPTION_PROVIDER",
		"WECHAT_TASK_TEMPLATE_ID",
		"WECHAT_RESERVATION_TEMPLATE_ID",
		"SCOLVPET_PDF_FONT_PATH",
	} {
		if !strings.Contains(text, key+"=") {
			t.Errorf("production env example missing %s=", key)
		}
	}
}
