package store

import (
	"context"
	"fmt"
	"os"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// idempotency_record carries a 24h expires_at, but the replay lookup used to
// ignore it and no job ever pruned the table, so a key stayed pinned to its
// first stored response forever.
func TestRunIdempotentReExecutesAfterExpiry(t *testing.T) {
	databaseURL := os.Getenv("AUTH_TEST_DATABASE_URL")
	if databaseURL == "" {
		databaseURL = os.Getenv("DATABASE_URL")
	}
	if databaseURL == "" {
		t.Skip("set AUTH_TEST_DATABASE_URL or DATABASE_URL to run idempotency expiry test")
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

	var exists bool
	if err := pool.QueryRow(ctx, `
		SELECT EXISTS (
			SELECT 1 FROM information_schema.tables WHERE table_name='idempotency_record'
		)
	`).Scan(&exists); err != nil {
		t.Fatalf("check idempotency_record: %v", err)
	}
	// With DATABASE_URL set (CI), missing schema must FAIL not silent-SKIP.
	if !exists {
		t.Fatal("idempotency_record table missing; run migrations")
	}

	dataStore := New(pool)
	phone := fmt.Sprintf("+8618%013d", time.Now().UnixNano()%10000000000000)
	_, ownerID, err := dataStore.EnsureAccount(ctx, phone)
	if err != nil {
		t.Fatalf("ensure account: %v", err)
	}
	t.Cleanup(func() {
		cleanupCtx, cleanupCancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cleanupCancel()
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM idempotency_record WHERE owner_id=$1`, ownerID)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM organization_member WHERE owner_id=$1 OR account_id=$1`, ownerID)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM domain_event WHERE owner_id=$1`, ownerID)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM organization WHERE owner_id=$1`, ownerID)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM account WHERE id=$1`, ownerID)
	})

	key := "expiry-probe-" + uuid.NewString()
	payload := []byte(`{"probe":true}`)
	runs := 0
	run := func() (IdempotentResult, error) {
		return dataStore.RunIdempotent(ctx, ownerID, key, "POST", "/v1/probe", payload,
			func(_ context.Context, _ pgx.Tx) (int, any, map[string]string, error) {
				runs++
				return 201, map[string]any{"run": runs}, map[string]string{}, nil
			})
	}

	if _, err := run(); err != nil {
		t.Fatalf("first run: %v", err)
	}
	if runs != 1 {
		t.Fatalf("first run executed %d times, want 1", runs)
	}

	// Still inside the retention window: this one must replay, not re-execute.
	result, err := run()
	if err != nil {
		t.Fatalf("replay run: %v", err)
	}
	if !result.Replayed {
		t.Fatal("second run within TTL should have replayed the stored response")
	}
	if runs != 1 {
		t.Fatalf("replay re-executed the callback (%d runs)", runs)
	}

	// ck_idempotency_record_expiry requires expires_at > created_at, so age the
	// row the way real elapsed time would rather than only moving the deadline.
	if _, err := pool.Exec(ctx, `
		UPDATE idempotency_record
		SET created_at = now() - interval '48 hours',
			expires_at = now() - interval '24 hours'
		WHERE owner_id=$1 AND idempotency_key=$2
	`, ownerID, key); err != nil {
		t.Fatalf("backdate expiry: %v", err)
	}

	result, err = run()
	if err != nil {
		t.Fatalf("post-expiry run: %v", err)
	}
	if result.Replayed {
		t.Fatal("expired record was replayed instead of starting a fresh attempt")
	}
	if runs != 2 {
		t.Fatalf("expired key executed %d times, want 2", runs)
	}

	// The reclaimed row must be usable again, including its own replay window.
	result, err = run()
	if err != nil {
		t.Fatalf("post-reclaim replay: %v", err)
	}
	if !result.Replayed || runs != 2 {
		t.Fatalf("reclaimed record did not replay (replayed=%v runs=%d)", result.Replayed, runs)
	}
}
