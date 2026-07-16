package auth

import (
	"context"
	"errors"
	"testing"

	"github.com/google/uuid"
)

type testSMSProvider struct {
	phone string
	code  string
	err   error
}

func (p *testSMSProvider) SendCode(_ context.Context, phone, code string) error {
	p.phone = phone
	p.code = code
	return p.err
}

func TestMockVerificationAndSignedSession(t *testing.T) {
	service := New("test-secret", "654321")
	challenge, err := service.RequestCode(context.Background(), "+8613800138000")
	if err != nil {
		t.Fatalf("request code: %v", err)
	}
	if err := service.VerifyCode(context.Background(), challenge.ID, challenge.Phone, "654321"); err != nil {
		t.Fatalf("verify code: %v", err)
	}
	ownerID := uuid.New()
	access, refresh, err := service.CreateSession(context.Background(), ownerID)
	if err != nil {
		t.Fatalf("create session: %v", err)
	}
	if refresh == "" {
		t.Fatal("expected refresh token")
	}
	gotOwner, err := service.ParseAccessToken(access)
	if err != nil {
		t.Fatalf("parse access token: %v", err)
	}
	if gotOwner != ownerID {
		t.Fatalf("owner mismatch: got %s want %s", gotOwner, ownerID)
	}
	service.Revoke(access)
	if _, err := service.ParseAccessToken(access); err != ErrRevokedToken {
		t.Fatalf("expected revoked token, got %v", err)
	}
}

func TestConsumedRefreshTokenStillResolvesOwnerForIdempotentReplay(t *testing.T) {
	service := New("test-secret", "654321")
	ownerID := uuid.New()
	_, refreshToken, err := service.CreateSession(context.Background(), ownerID)
	if err != nil {
		t.Fatalf("create session: %v", err)
	}
	if _, _, err := service.Refresh(context.Background(), refreshToken); err != nil {
		t.Fatalf("refresh failed: %v", err)
	}
	gotOwner, err := service.OwnerForRefresh(context.Background(), refreshToken)
	if err != nil {
		t.Fatalf("consumed refresh owner lookup failed: %v", err)
	}
	if gotOwner != ownerID {
		t.Fatalf("owner mismatch: got %s want %s", gotOwner, ownerID)
	}
	if _, _, err := service.Refresh(context.Background(), refreshToken); err != ErrInvalidRefresh {
		t.Fatalf("expected consumed token refresh to fail, got %v", err)
	}
}

func TestRequestCodeUsesProviderAndRemovesChallengeWhenSendFails(t *testing.T) {
	provider := &testSMSProvider{err: errors.New("provider unavailable")}
	service := NewWithOptions("test-secret", "654321", Options{SMSProvider: provider})
	challenge, err := service.RequestCode(context.Background(), "+8613800138000")
	if err == nil || challenge.ID != uuid.Nil {
		t.Fatalf("expected provider failure, challenge=%+v err=%v", challenge, err)
	}
	if provider.phone != "+8613800138000" || provider.code != "654321" {
		t.Fatalf("provider payload phone=%q code=%q", provider.phone, provider.code)
	}
	if err := service.VerifyCode(context.Background(), uuid.New(), provider.phone, provider.code); err != ErrVerification {
		t.Fatalf("expected missing challenge after provider failure, got %v", err)
	}
}
