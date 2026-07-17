// Package pushcore provides pluggable push providers for T-P1-07.
// Real APNs/FCM adapters plug in later; LogSender is the default.
package pushcore

import (
	"context"
	"fmt"
	"log/slog"
	"strings"
	"sync"
	"time"
)

// DeliveryRequest is one fan-out attempt to a device token.
type DeliveryRequest struct {
	OwnerID  string
	DeviceID string
	Platform string
	Provider string
	Token    string
	Title    string
	Body     string
	Data     map[string]string
}

// DeliveryResult is provider response metadata.
type DeliveryResult struct {
	ProviderMessageID string
	Provider          string
	SentAt            time.Time
}

// Sender delivers push notifications.
type Sender interface {
	Send(ctx context.Context, req DeliveryRequest) (DeliveryResult, error)
}

// LogSender records deliveries in-memory and logs them (dev / CI default).
type LogSender struct {
	Logger *slog.Logger
	mu     sync.Mutex
	Sent   []DeliveryRequest
}

func NewLogSender(logger *slog.Logger) *LogSender {
	return &LogSender{Logger: logger}
}

func (s *LogSender) Send(ctx context.Context, req DeliveryRequest) (DeliveryResult, error) {
	_ = ctx
	if strings.TrimSpace(req.Token) == "" {
		return DeliveryResult{}, fmt.Errorf("empty push token")
	}
	s.mu.Lock()
	s.Sent = append(s.Sent, req)
	n := len(s.Sent)
	s.mu.Unlock()
	if s.Logger != nil {
		s.Logger.Info("push delivered (log provider)",
			"owner_id", req.OwnerID,
			"device_id", req.DeviceID,
			"platform", req.Platform,
			"title", req.Title,
			"token_suffix", tokenSuffix(req.Token),
		)
	}
	return DeliveryResult{
		ProviderMessageID: fmt.Sprintf("log-%d-%d", n, time.Now().UnixNano()),
		Provider:          "log",
		SentAt:            time.Now().UTC(),
	}, nil
}

// SelectProvider maps platform to preferred provider when none given.
func SelectProvider(platform, explicit string) string {
	if explicit != "" {
		return explicit
	}
	switch platform {
	case "ios":
		return "apns"
	case "android":
		return "fcm"
	default:
		return "log"
	}
}

// ResolveSender returns a concrete sender. Without credentials, always log.
// Env hooks (future): FCM_SERVER_KEY / APNS_KEY_PATH switch real providers.
func ResolveSender(logger *slog.Logger) Sender {
	// PARTIAL: production APNs/FCM not wired; keep log path until secrets exist.
	return NewLogSender(logger)
}

func tokenSuffix(token string) string {
	if len(token) <= 8 {
		return token
	}
	return token[len(token)-8:]
}
