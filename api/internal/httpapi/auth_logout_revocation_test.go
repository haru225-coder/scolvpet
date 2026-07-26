package httpapi

import (
	"context"
	"fmt"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/scolvpet/scolvpet/api/internal/auth"
	"github.com/scolvpet/scolvpet/api/internal/store"
)

// A logout without an Idempotency-Key used to collapse onto the per-account key
// "logout-<owner>" with a constant payload, so every later logout replayed the
// stored 204 and skipped revocation entirely. The account stayed reachable with
// its old credentials for the full token lifetime.
func TestLogoutWithoutIdempotencyKeyRevokesEveryTime(t *testing.T) {
	databaseURL := os.Getenv("AUTH_TEST_DATABASE_URL")
	if databaseURL == "" {
		databaseURL = os.Getenv("DATABASE_URL")
	}
	if databaseURL == "" {
		t.Skip("set AUTH_TEST_DATABASE_URL or DATABASE_URL to run logout revocation test")
	}

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	pool, err := pgxpool.New(ctx, databaseURL)
	if err != nil {
		t.Fatalf("connect postgres: %v", err)
	}
	t.Cleanup(pool.Close)
	if err := pool.Ping(ctx); err != nil {
		t.Fatalf("ping postgres: %v", err)
	}

	var hasRevokedToken bool
	if err := pool.QueryRow(ctx, `
		SELECT EXISTS (
			SELECT 1 FROM information_schema.tables WHERE table_name='revoked_token'
		)
	`).Scan(&hasRevokedToken); err != nil {
		t.Fatalf("check revoked_token: %v", err)
	}
	// With DATABASE_URL set (CI), missing schema must FAIL not silent-SKIP.
	if !hasRevokedToken {
		t.Fatal("revoked_token table missing; apply migration 0039")
	}

	dataStore := store.New(pool)
	phone := fmt.Sprintf("+8619%013d", time.Now().UnixNano()%10000000000000)
	_, ownerID, err := dataStore.EnsureAccount(ctx, phone)
	if err != nil {
		t.Fatalf("ensure account: %v", err)
	}
	accountIDs := []uuid.UUID{ownerID}
	t.Cleanup(func() {
		cleanupCtx, cleanupCancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cleanupCancel()
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM revoked_token WHERE owner_id = ANY($1)`, accountIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM auth_refresh_session WHERE owner_id = ANY($1)`, accountIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM idempotency_record WHERE owner_id = ANY($1)`, accountIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM organization_member WHERE owner_id = ANY($1) OR account_id = ANY($1)`, accountIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM domain_event WHERE owner_id = ANY($1)`, accountIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM organization WHERE owner_id = ANY($1)`, accountIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM account WHERE id = ANY($1)`, accountIDs)
	})

	tx, err := pool.Begin(ctx)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := store.EnsureOrganizationTx(ctx, tx, ownerID); err != nil {
		_ = tx.Rollback(ctx)
		t.Fatalf("ensure organization: %v", err)
	}
	if err := tx.Commit(ctx); err != nil {
		t.Fatal(err)
	}

	authService := auth.NewWithPersistence("logout-revocation-test", "123456", dataStore)
	handler := NewServer(dataStore, authService, slog.Default()).Handler()

	meIsAuthorized := func(t *testing.T, accessToken string) bool {
		t.Helper()
		request := httptest.NewRequest(http.MethodGet, "/v1/me", nil)
		request.Header.Set("Authorization", "Bearer "+accessToken)
		recorder := httptest.NewRecorder()
		handler.ServeHTTP(recorder, request)
		return recorder.Code != http.StatusUnauthorized
	}

	logout := func(t *testing.T, accessToken string) {
		t.Helper()
		request := httptest.NewRequest(http.MethodDelete, "/v1/auth/sessions/current", nil)
		request.Header.Set("Authorization", "Bearer "+accessToken)
		recorder := httptest.NewRecorder()
		handler.ServeHTTP(recorder, request)
		if recorder.Code != http.StatusNoContent {
			t.Fatalf("logout status=%d body=%s", recorder.Code, recorder.Body.String())
		}
	}

	firstAccess, _, err := authService.CreateSession(ctx, ownerID)
	if err != nil {
		t.Fatalf("create first session: %v", err)
	}
	if !meIsAuthorized(t, firstAccess) {
		t.Fatal("first access token rejected before logout")
	}
	logout(t, firstAccess)
	if meIsAuthorized(t, firstAccess) {
		t.Fatal("first access token still accepted after logout")
	}

	// Same account, same path, same (absent) Idempotency-Key: the second logout
	// must revoke the new token rather than replay the first logout's 204.
	secondAccess, _, err := authService.CreateSession(ctx, ownerID)
	if err != nil {
		t.Fatalf("create second session: %v", err)
	}
	if !meIsAuthorized(t, secondAccess) {
		t.Fatal("second access token rejected before logout")
	}
	logout(t, secondAccess)
	if meIsAuthorized(t, secondAccess) {
		t.Fatal("second access token still accepted after logout: revocation was skipped")
	}
}
