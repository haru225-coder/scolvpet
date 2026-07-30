package main

import (
	"fmt"
	"net/netip"
	"net/url"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/scolvpet/scolvpet/api/internal/objectstore"
	"github.com/scolvpet/scolvpet/api/internal/worker"
)

const (
	defaultDatabaseURL                = "postgres://scolvpet:scolvpet@127.0.0.1:55432/scolvpet?sslmode=disable"
	defaultJWTSecret                  = "local-development-secret"
	defaultSMSMockCode                = "123456"
	defaultWechatPhoneGlobalPerMinute = 600
	defaultWechatPhoneGlobalPerDay    = 100000
)

type runtimeConfig struct {
	Environment                 string
	DatabaseURL                 string
	APIAddr                     string
	JWTSecret                   string
	SMSProvider                 string
	SMSMockCode                 string
	SMSHTTPEndpoint             string
	SMSHTTPToken                string
	WechatProvider              string
	WechatSubscriptionProvider  string
	WechatSubscriptionState     string
	WechatAppID                 string
	WechatSecret                string
	WechatTaskTemplateID        string
	WechatReservationTemplateID string
	WechatPhoneGlobalPerMinute  int
	WechatPhoneGlobalPerDay     int
	ObjectStoreProvider         string
	ObjectStoreLocalRoot        string
	ObjectStoreEndpoint         string
	ObjectStoreBucket           string
	ObjectStoreRegion           string
	ObjectStoreAccessKey        string
	ObjectStoreSecretKey        string
	ObjectStorePathStyle        bool
	DBMaxConns                  int
	DBMinConns                  int
	OutboxLeaseSeconds          int
	OutboxPublisherMode         string
	OutboxPublisherEndpoint     string
	OutboxPublisherToken        string
	OutboxWorkerDisabled        bool
	MediaWorkerIntervalSecs     int
	MediaWorkerDisabled         bool
	MediaCWebPPath              string
	MediaFFmpegPath             string
	MediaFFprobePath            string
	MediaCodecTimeoutSecs       int
	MediaCodecMaxInputBytes     int64
	MediaCodecMaxOutputBytes    int64
	TrustedProxyCIDRs           []netip.Prefix
}

// defaultTrustedProxyCIDRs trusts loopback and private ranges, matching the
// compose deployment where Caddy reaches the API over the docker bridge.
// Override with TRUSTED_PROXY_CIDRS (comma-separated CIDRs; empty string
// disables forwarded-header trust entirely).
const defaultTrustedProxyCIDRs = "127.0.0.0/8,::1/128,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"

func trustedProxyCIDRsFrom(lookup envLookup) ([]netip.Prefix, error) {
	raw, ok := lookup("TRUSTED_PROXY_CIDRS")
	if !ok {
		raw = defaultTrustedProxyCIDRs
	}
	var prefixes []netip.Prefix
	for _, part := range strings.Split(raw, ",") {
		part = strings.TrimSpace(part)
		if part == "" {
			continue
		}
		prefix, err := netip.ParsePrefix(part)
		if err != nil {
			return nil, fmt.Errorf("TRUSTED_PROXY_CIDRS entry %q is not a valid CIDR: %w", part, err)
		}
		prefixes = append(prefixes, prefix)
	}
	return prefixes, nil
}

type envLookup func(string) (string, bool)

func loadRuntimeConfig() (runtimeConfig, error) {
	return loadRuntimeConfigFrom(os.LookupEnv)
}

func loadRuntimeConfigFrom(lookup envLookup) (runtimeConfig, error) {
	environment := strings.ToLower(strings.TrimSpace(envOrDefault(lookup, "APP_ENV", "development")))
	if environment != "development" && environment != "test" && environment != "staging" && environment != "production" {
		return runtimeConfig{}, fmt.Errorf("APP_ENV must be one of development, test, staging, production; got %q", environment)
	}

	smsProvider := envOrDefault(lookup, "SMS_PROVIDER", "")
	smsMockCode := envOrDefault(lookup, "SMS_MOCK_CODE", "")
	objectStoreProvider := strings.ToLower(strings.TrimSpace(envOrDefault(lookup, "OBJECT_STORE_PROVIDER", "")))
	if environment != "production" {
		if smsProvider == "" {
			smsProvider = "mock"
		}
		if smsMockCode == "" {
			smsMockCode = defaultSMSMockCode
		}
		if objectStoreProvider == "" {
			objectStoreProvider = "local"
		}
	}
	if objectStoreProvider != "" && objectStoreProvider != "local" && objectStoreProvider != "s3" && objectStoreProvider != "minio" {
		return runtimeConfig{}, fmt.Errorf("OBJECT_STORE_PROVIDER must be one of local, s3, minio; got %q", objectStoreProvider)
	}
	wechatProvider := strings.ToLower(strings.TrimSpace(envOrDefault(lookup, "WECHAT_PROVIDER", "mock")))
	if wechatProvider != "mock" && wechatProvider != "http" {
		return runtimeConfig{}, fmt.Errorf("WECHAT_PROVIDER must be one of mock, http; got %q", wechatProvider)
	}
	wechatSubscriptionProvider := strings.ToLower(strings.TrimSpace(envOrDefault(lookup, "WECHAT_SUBSCRIPTION_PROVIDER", wechatProvider)))
	if wechatSubscriptionProvider != "mock" && wechatSubscriptionProvider != "http" {
		return runtimeConfig{}, fmt.Errorf("WECHAT_SUBSCRIPTION_PROVIDER must be one of mock, http; got %q", wechatSubscriptionProvider)
	}
	wechatSubscriptionState := strings.ToLower(strings.TrimSpace(envOrDefault(lookup, "WECHAT_SUBSCRIPTION_STATE", "formal")))
	if wechatSubscriptionState != "developer" && wechatSubscriptionState != "trial" && wechatSubscriptionState != "formal" {
		return runtimeConfig{}, fmt.Errorf("WECHAT_SUBSCRIPTION_STATE must be one of developer, trial, formal; got %q", wechatSubscriptionState)
	}
	outboxPublisherMode := strings.ToLower(strings.TrimSpace(envOrDefault(lookup, "OUTBOX_PUBLISHER_MODE", "success")))
	if outboxPublisherMode != "success" && outboxPublisherMode != "fail" && outboxPublisherMode != "http" {
		return runtimeConfig{}, fmt.Errorf("OUTBOX_PUBLISHER_MODE must be one of success, fail, http; got %q", outboxPublisherMode)
	}
	pathStyle, err := objectStorePathStyleFrom(lookup, objectStoreProvider)
	if err != nil {
		return runtimeConfig{}, err
	}
	trustedProxies, err := trustedProxyCIDRsFrom(lookup)
	if err != nil {
		return runtimeConfig{}, err
	}
	wechatPhoneGlobalPerMinute := getenvIntFrom(lookup, "WECHAT_PHONE_GLOBAL_PER_MINUTE", defaultWechatPhoneGlobalPerMinute)
	wechatPhoneGlobalPerDay := getenvIntFrom(lookup, "WECHAT_PHONE_GLOBAL_PER_DAY", defaultWechatPhoneGlobalPerDay)

	config := runtimeConfig{
		Environment:                 environment,
		DatabaseURL:                 envOrDefault(lookup, "DATABASE_URL", defaultDatabaseURL),
		APIAddr:                     envOrDefault(lookup, "API_ADDR", ":8080"),
		JWTSecret:                   envOrDefault(lookup, "JWT_SECRET", defaultJWTSecret),
		SMSProvider:                 strings.ToLower(strings.TrimSpace(smsProvider)),
		SMSMockCode:                 smsMockCode,
		SMSHTTPEndpoint:             strings.TrimSpace(envOrDefault(lookup, "SMS_HTTP_ENDPOINT", "")),
		SMSHTTPToken:                envOrDefault(lookup, "SMS_HTTP_TOKEN", ""),
		WechatProvider:              wechatProvider,
		WechatSubscriptionProvider:  wechatSubscriptionProvider,
		WechatSubscriptionState:     strings.TrimSpace(wechatSubscriptionState),
		WechatAppID:                 strings.TrimSpace(envOrDefault(lookup, "WECHAT_APPID", "")),
		WechatSecret:                strings.TrimSpace(envOrDefault(lookup, "WECHAT_SECRET", "")),
		WechatTaskTemplateID:        strings.TrimSpace(envOrDefault(lookup, "WECHAT_TASK_TEMPLATE_ID", "")),
		WechatReservationTemplateID: strings.TrimSpace(envOrDefault(lookup, "WECHAT_RESERVATION_TEMPLATE_ID", "")),
		WechatPhoneGlobalPerMinute:  wechatPhoneGlobalPerMinute,
		WechatPhoneGlobalPerDay:     wechatPhoneGlobalPerDay,
		ObjectStoreProvider:         strings.ToLower(strings.TrimSpace(objectStoreProvider)),
		ObjectStoreLocalRoot:        envOrDefault(lookup, "IMPORT_OBJECT_STORE_DIR", ""),
		ObjectStoreEndpoint:         strings.TrimRight(strings.TrimSpace(envOrDefault(lookup, "OBJECT_STORE_ENDPOINT", "")), "/"),
		ObjectStoreBucket:           strings.TrimSpace(envOrDefault(lookup, "OBJECT_STORE_BUCKET", "")),
		ObjectStoreRegion:           strings.TrimSpace(envOrDefault(lookup, "OBJECT_STORE_REGION", "")),
		ObjectStoreAccessKey:        envOrDefault(lookup, "OBJECT_STORE_ACCESS_KEY", ""),
		ObjectStoreSecretKey:        envOrDefault(lookup, "OBJECT_STORE_SECRET_KEY", ""),
		ObjectStorePathStyle:        pathStyle,
		DBMaxConns:                  getenvIntFrom(lookup, "DB_MAX_CONNS", 8),
		DBMinConns:                  getenvIntFrom(lookup, "DB_MIN_CONNS", 1),
		OutboxLeaseSeconds:          getenvIntFrom(lookup, "OUTBOX_WORKER_LEASE_SECONDS", 60),
		OutboxPublisherMode:         outboxPublisherMode,
		OutboxPublisherEndpoint:     strings.TrimRight(strings.TrimSpace(envOrDefault(lookup, "OUTBOX_PUBLISHER_ENDPOINT", "")), "/"),
		OutboxPublisherToken:        envOrDefault(lookup, "OUTBOX_PUBLISHER_TOKEN", ""),
		OutboxWorkerDisabled:        envOrDefault(lookup, "OUTBOX_WORKER_DISABLED", "0") == "1",
		MediaWorkerIntervalSecs:     getenvIntFrom(lookup, "MEDIA_WORKER_INTERVAL_SECONDS", 2),
		MediaWorkerDisabled:         envOrDefault(lookup, "MEDIA_WORKER_DISABLED", "0") == "1",
		MediaCWebPPath:              envOrDefault(lookup, "MEDIA_CWEBP_PATH", "cwebp"),
		MediaFFmpegPath:             envOrDefault(lookup, "MEDIA_FFMPEG_PATH", "ffmpeg"),
		MediaFFprobePath:            envOrDefault(lookup, "MEDIA_FFPROBE_PATH", "ffprobe"),
		MediaCodecTimeoutSecs:       getenvIntFrom(lookup, "MEDIA_CODEC_TIMEOUT_SECONDS", 120),
		MediaCodecMaxInputBytes:     int64(getenvIntFrom(lookup, "MEDIA_CODEC_MAX_INPUT_BYTES", 512<<20)),
		MediaCodecMaxOutputBytes:    int64(getenvIntFrom(lookup, "MEDIA_CODEC_MAX_OUTPUT_BYTES", 512<<20)),
		TrustedProxyCIDRs:           trustedProxies,
	}

	if environment == "production" {
		if err := validateProductionConfig(lookup, config); err != nil {
			return runtimeConfig{}, err
		}
	}
	return config, nil
}

func validateProductionConfig(lookup envLookup, config runtimeConfig) error {
	issues := make([]string, 0, 8)
	if value, ok := lookup("DATABASE_URL"); !ok || strings.TrimSpace(value) == "" {
		issues = append(issues, "DATABASE_URL must be explicitly set")
	}
	if value, ok := lookup("JWT_SECRET"); !ok || strings.TrimSpace(value) == "" || strings.TrimSpace(value) == defaultJWTSecret {
		issues = append(issues, "JWT_SECRET must be explicitly set to a non-development secret")
	}
	if config.SMSProvider != "http" {
		issues = append(issues, "SMS_PROVIDER must be http for the production webhook adapter")
	} else {
		if config.SMSHTTPEndpoint == "" {
			issues = append(issues, "SMS_HTTP_ENDPOINT must be explicitly set")
		} else if !strings.HasPrefix(strings.ToLower(config.SMSHTTPEndpoint), "https://") {
			issues = append(issues, "SMS_HTTP_ENDPOINT must use https in production")
		}
		if config.SMSHTTPToken == "" {
			issues = append(issues, "SMS_HTTP_TOKEN must be explicitly set")
		}
	}
	if config.SMSMockCode != "" {
		issues = append(issues, "SMS_MOCK_CODE must be empty in production")
	}
	if config.WechatProvider != "http" {
		issues = append(issues, "WECHAT_PROVIDER must be http for the production code2Session exchange")
	} else {
		if config.WechatAppID == "" {
			issues = append(issues, "WECHAT_APPID must be explicitly set")
		}
		if config.WechatSecret == "" {
			issues = append(issues, "WECHAT_SECRET must be explicitly set")
		}
	}
	if _, err := requiredPositiveIntFrom(lookup, "WECHAT_PHONE_GLOBAL_PER_MINUTE"); err != nil {
		issues = append(issues, err.Error())
	}
	if _, err := requiredPositiveIntFrom(lookup, "WECHAT_PHONE_GLOBAL_PER_DAY"); err != nil {
		issues = append(issues, err.Error())
	}
	if config.WechatSubscriptionProvider != "http" {
		issues = append(issues, "WECHAT_SUBSCRIPTION_PROVIDER must be http for production subscription delivery")
	}
	if config.WechatTaskTemplateID == "" {
		issues = append(issues, "WECHAT_TASK_TEMPLATE_ID must be explicitly set")
	}
	if config.WechatReservationTemplateID == "" {
		issues = append(issues, "WECHAT_RESERVATION_TEMPLATE_ID must be explicitly set")
	}
	if config.ObjectStoreProvider != "s3" && config.ObjectStoreProvider != "minio" {
		issues = append(issues, "OBJECT_STORE_PROVIDER must be s3 or minio in production")
	} else {
		if config.ObjectStoreEndpoint == "" {
			issues = append(issues, "OBJECT_STORE_ENDPOINT must be explicitly set")
		} else if endpoint, err := url.Parse(config.ObjectStoreEndpoint); err != nil || endpoint.Scheme == "" || endpoint.Host == "" || endpoint.User != nil || (endpoint.Scheme != "http" && endpoint.Scheme != "https") {
			issues = append(issues, "OBJECT_STORE_ENDPOINT must be an absolute HTTP(S) URL without embedded credentials")
		} else if config.ObjectStoreProvider == "s3" && endpoint.Scheme != "https" {
			issues = append(issues, "OBJECT_STORE_ENDPOINT must use https for OBJECT_STORE_PROVIDER=s3")
		}
		if config.ObjectStoreBucket == "" {
			issues = append(issues, "OBJECT_STORE_BUCKET must be explicitly set")
		} else if strings.ContainsAny(config.ObjectStoreBucket, "/\\") {
			issues = append(issues, "OBJECT_STORE_BUCKET must not contain a path separator")
		}
		if config.ObjectStoreRegion == "" {
			issues = append(issues, "OBJECT_STORE_REGION must be explicitly set")
		}
		if config.ObjectStoreAccessKey == "" {
			issues = append(issues, "OBJECT_STORE_ACCESS_KEY must be explicitly set")
		}
		if config.ObjectStoreSecretKey == "" {
			issues = append(issues, "OBJECT_STORE_SECRET_KEY must be explicitly set")
		}
	}
	if config.OutboxWorkerDisabled {
		issues = append(issues, "OUTBOX_WORKER_DISABLED=1 disables the event worker")
	}
	if config.MediaWorkerDisabled {
		issues = append(issues, "MEDIA_WORKER_DISABLED=1 disables the media worker")
	}
	if config.OutboxPublisherMode != "http" {
		if config.OutboxPublisherMode == "fail" {
			issues = append(issues, "OUTBOX_PUBLISHER_MODE=fail selects the failure probe")
		} else {
			issues = append(issues, "OUTBOX_PUBLISHER_MODE must be http in production")
		}
	} else {
		if config.OutboxPublisherEndpoint == "" {
			issues = append(issues, "OUTBOX_PUBLISHER_ENDPOINT must be explicitly set")
		} else if endpoint, err := url.Parse(config.OutboxPublisherEndpoint); err != nil || endpoint.Scheme != "https" || endpoint.Host == "" || endpoint.User != nil {
			issues = append(issues, "OUTBOX_PUBLISHER_ENDPOINT must be an absolute https URL without embedded credentials")
		}
		if config.OutboxPublisherToken == "" {
			issues = append(issues, "OUTBOX_PUBLISHER_TOKEN must be explicitly set")
		}
	}
	if len(issues) > 0 {
		return fmt.Errorf("production config rejected: %s", strings.Join(issues, "; "))
	}
	return nil
}

func objectStorePathStyleFrom(lookup envLookup, provider string) (bool, error) {
	defaultValue := provider == "minio"
	value, ok := lookup("OBJECT_STORE_PATH_STYLE")
	if !ok || strings.TrimSpace(value) == "" {
		return defaultValue, nil
	}
	parsed, err := strconv.ParseBool(strings.TrimSpace(value))
	if err != nil {
		return false, fmt.Errorf("OBJECT_STORE_PATH_STYLE must be true or false; got %q", value)
	}
	return parsed, nil
}

func newObjectStore(config runtimeConfig) (objectstore.ObjectStore, error) {
	switch config.ObjectStoreProvider {
	case "local":
		root := strings.TrimSpace(config.ObjectStoreLocalRoot)
		if root == "" {
			root = os.TempDir() + "/scolvpet-imports"
		}
		return objectstore.NewLocalFS(root)
	case "s3", "minio":
		return objectstore.NewS3(objectstore.S3Config{
			Endpoint:        config.ObjectStoreEndpoint,
			Bucket:          config.ObjectStoreBucket,
			Region:          config.ObjectStoreRegion,
			AccessKeyID:     config.ObjectStoreAccessKey,
			SecretAccessKey: config.ObjectStoreSecretKey,
			PathStyle:       config.ObjectStorePathStyle,
		})
	default:
		return nil, fmt.Errorf("unsupported object store provider %q", config.ObjectStoreProvider)
	}
}

func mediaCodecConfig(config runtimeConfig) worker.CodecConfig {
	timeout := time.Duration(config.MediaCodecTimeoutSecs) * time.Second
	if timeout <= 0 {
		timeout = 2 * time.Minute
	}
	return worker.CodecConfig{
		CWebPPath:      config.MediaCWebPPath,
		FFmpegPath:     config.MediaFFmpegPath,
		FFprobePath:    config.MediaFFprobePath,
		Timeout:        timeout,
		MaxInputBytes:  config.MediaCodecMaxInputBytes,
		MaxOutputBytes: config.MediaCodecMaxOutputBytes,
	}
}

func envOrDefault(lookup envLookup, key, fallback string) string {
	if value, ok := lookup(key); ok && value != "" {
		return value
	}
	return fallback
}

func getenvIntFrom(lookup envLookup, key string, fallback int) int {
	value, ok := lookup(key)
	if !ok || value == "" {
		return fallback
	}
	parsed, err := strconv.Atoi(value)
	if err != nil || parsed < 1 {
		return fallback
	}
	return parsed
}

func requiredPositiveIntFrom(lookup envLookup, key string) (int, error) {
	value, ok := lookup(key)
	if !ok || strings.TrimSpace(value) == "" {
		return 0, fmt.Errorf("%s must be explicitly set to a positive integer", key)
	}
	parsed, err := strconv.Atoi(strings.TrimSpace(value))
	if err != nil || parsed < 1 {
		return 0, fmt.Errorf("%s must be a positive integer", key)
	}
	return parsed, nil
}
