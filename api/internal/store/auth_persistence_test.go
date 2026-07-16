package store

import (
	"context"
	"fmt"
	"os"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/scolvpet/scolvpet/api/internal/auth"
)

func TestPostgresAuthPersistenceSurvivesServiceRecreation(t *testing.T) {
	databaseURL := os.Getenv("AUTH_TEST_DATABASE_URL")
	if databaseURL == "" {
		databaseURL = os.Getenv("DATABASE_URL")
	}
	if databaseURL == "" {
		t.Skip("set AUTH_TEST_DATABASE_URL or DATABASE_URL to run PostgreSQL auth persistence smoke")
	}
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	pool, err := pgxpool.New(ctx, databaseURL)
	if err != nil {
		t.Fatalf("connect postgres: %v", err)
	}
	t.Cleanup(pool.Close)
	if err := pool.Ping(ctx); err != nil {
		t.Fatalf("ping postgres: %v", err)
	}

	phoneNumber := fmt.Sprintf("%019d", time.Now().UnixNano())
	phone := "+86" + phoneNumber
	var ownerID uuid.UUID
	if err := pool.QueryRow(ctx, `
		INSERT INTO account (phone_number, display_name) VALUES ($1, 'auth persistence smoke')
		RETURNING id
	`, phoneNumber).Scan(&ownerID); err != nil {
		t.Fatalf("insert account: %v", err)
	}
	t.Cleanup(func() {
		cleanupCtx, cleanupCancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cleanupCancel()
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM verification_challenge WHERE phone=$1`, phone)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM auth_refresh_session WHERE owner_id=$1`, ownerID)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM account WHERE id=$1`, ownerID)
	})

	persistence := New(pool)
	firstService := auth.NewWithPersistence("test-secret", "654321", persistence)
	challenge, err := firstService.RequestCode(ctx, phone)
	if err != nil {
		t.Fatalf("request code: %v", err)
	}
	if err := firstService.VerifyCode(ctx, challenge.ID, phone, "000000"); err != auth.ErrInvalidCode {
		t.Fatalf("wrong code error: %v", err)
	}
	if err := firstService.VerifyCode(ctx, challenge.ID, phone, "654321"); err != nil {
		t.Fatalf("verify correct code: %v", err)
	}

	accessToken, refreshToken, err := firstService.CreateSession(ctx, ownerID)
	if err != nil {
		t.Fatalf("create session: %v", err)
	}
	if accessToken == "" || refreshToken == "" {
		t.Fatal("expected signed access and refresh tokens")
	}

	secondService := auth.NewWithPersistence("test-secret", "654321", persistence)
	gotOwner, err := secondService.OwnerForRefresh(ctx, refreshToken)
	if err != nil || gotOwner != ownerID {
		t.Fatalf("refresh owner after service recreation: owner=%s err=%v", gotOwner, err)
	}
	_, nextRefreshToken, err := secondService.Refresh(ctx, refreshToken)
	if err != nil || nextRefreshToken == "" {
		t.Fatalf("refresh after service recreation: token=%q err=%v", nextRefreshToken, err)
	}
	if _, _, err := secondService.Refresh(ctx, refreshToken); err != auth.ErrInvalidRefresh {
		t.Fatalf("consumed refresh token error: %v", err)
	}
	thirdService := auth.NewWithPersistence("test-secret", "654321", persistence)
	if gotOwner, err := thirdService.OwnerForRefresh(ctx, refreshToken); err != nil || gotOwner != ownerID {
		t.Fatalf("consumed refresh replay owner: owner=%s err=%v", gotOwner, err)
	}
	if gotOwner, err := thirdService.OwnerForRefresh(ctx, nextRefreshToken); err != nil || gotOwner != ownerID {
		t.Fatalf("rotated refresh owner: owner=%s err=%v", gotOwner, err)
	}
}
