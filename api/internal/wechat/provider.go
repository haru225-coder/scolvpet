// Package wechat wraps the WeChat mini-program code2Session exchange behind a
// provider interface, mirroring the sms package: an http implementation for
// production and a mock for development/CI, so P2 identity work never blocks
// on the real AppID approval.
package wechat

import "context"

// Session is the result of exchanging a wx.login js_code.
type Session struct {
	OpenID     string
	UnionID    string
	SessionKey string
}

// Provider exchanges a wx.login js_code for the customer's WeChat identity.
// The AppID/Secret stay server-side inside the implementation; SessionKey must
// never be returned to any client.
type Provider interface {
	Code2Session(ctx context.Context, jsCode string) (Session, error)
}
