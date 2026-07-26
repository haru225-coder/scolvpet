package wechat

import (
	"context"
	"fmt"
	"strings"
)

// MockProvider is the deterministic development/CI implementation: the same
// js_code always maps to the same openid, so tests can drive the bound /
// unbound / rebound states without the real AppID.
type MockProvider struct{}

func (MockProvider) Code2Session(_ context.Context, jsCode string) (Session, error) {
	jsCode = strings.TrimSpace(jsCode)
	if jsCode == "" {
		return Session{}, fmt.Errorf("wechat mock: js_code must be non-empty")
	}
	return Session{
		OpenID:     "mock-openid-" + jsCode,
		SessionKey: "mock-session-key-" + jsCode,
	}, nil
}
