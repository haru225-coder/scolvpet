package auth

import (
	"testing"

	"github.com/google/uuid"
)

func TestMockVerificationAndSignedSession(t *testing.T) {
	service := New("test-secret", "654321")
	challenge := service.RequestCode("+8613800138000")
	if err := service.VerifyCode(challenge.ID, challenge.Phone, "654321"); err != nil {
		t.Fatalf("verify code: %v", err)
	}
	ownerID := uuid.New()
	access, refresh := service.CreateSession(ownerID)
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
	_, refreshToken := service.CreateSession(ownerID)
	if _, _, err := service.Refresh(refreshToken); err != nil {
		t.Fatalf("refresh failed: %v", err)
	}
	gotOwner, err := service.OwnerForRefresh(refreshToken)
	if err != nil {
		t.Fatalf("consumed refresh owner lookup failed: %v", err)
	}
	if gotOwner != ownerID {
		t.Fatalf("owner mismatch: got %s want %s", gotOwner, ownerID)
	}
	if _, _, err := service.Refresh(refreshToken); err != ErrInvalidRefresh {
		t.Fatalf("expected consumed token refresh to fail, got %v", err)
	}
}
