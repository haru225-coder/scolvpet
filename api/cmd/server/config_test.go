package main

import (
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
		"APP_ENV":                   "production",
		"DATABASE_URL":              "postgres://db.example/scolvpet?sslmode=require",
		"JWT_SECRET":                "production-secret-from-secret-manager",
		"SMS_PROVIDER":              "http",
		"SMS_HTTP_ENDPOINT":         "https://sms.example.test/send",
		"SMS_HTTP_TOKEN":            "token-from-secret-manager",
		"OBJECT_STORE_PROVIDER":     "s3",
		"OBJECT_STORE_ENDPOINT":     "https://s3.us-east-1.amazonaws.com",
		"OBJECT_STORE_BUCKET":       "scolvpet-production",
		"OBJECT_STORE_REGION":       "us-east-1",
		"OBJECT_STORE_ACCESS_KEY":   "access-key-from-secret-manager",
		"OBJECT_STORE_SECRET_KEY":   "secret-key-from-secret-manager",
		"OUTBOX_PUBLISHER_MODE":     "http",
		"OUTBOX_PUBLISHER_ENDPOINT": "https://events.example.test/publish",
		"OUTBOX_PUBLISHER_TOKEN":    "publisher-token-from-secret-manager",
	}
	_, err := loadRuntimeConfigFrom(mapLookup(values))
	if err != nil {
		t.Fatalf("configured production providers were rejected: %v", err)
	}
}

func TestLoadRuntimeConfigMinIODefaultsToPathStyle(t *testing.T) {
	values := map[string]string{
		"APP_ENV":                   "production",
		"DATABASE_URL":              "postgres://db.example/scolvpet?sslmode=require",
		"JWT_SECRET":                "production-secret-from-secret-manager",
		"SMS_PROVIDER":              "http",
		"SMS_HTTP_ENDPOINT":         "https://sms.example.test/send",
		"SMS_HTTP_TOKEN":            "token-from-secret-manager",
		"OBJECT_STORE_PROVIDER":     "minio",
		"OBJECT_STORE_ENDPOINT":     "http://minio.internal:9000",
		"OBJECT_STORE_BUCKET":       "scolvpet-production",
		"OBJECT_STORE_REGION":       "us-east-1",
		"OBJECT_STORE_ACCESS_KEY":   "minio-access",
		"OBJECT_STORE_SECRET_KEY":   "minio-secret",
		"OUTBOX_PUBLISHER_MODE":     "http",
		"OUTBOX_PUBLISHER_ENDPOINT": "https://events.example.test/publish",
		"OUTBOX_PUBLISHER_TOKEN":    "publisher-token",
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
