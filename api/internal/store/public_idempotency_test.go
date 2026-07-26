package store

import (
	"context"
	"fmt"
	"os"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
)

func testPool(t *testing.T) *pgxpool.Pool {
	t.Helper()
	databaseURL := os.Getenv("AUTH_TEST_DATABASE_URL")
	if databaseURL == "" {
		databaseURL = os.Getenv("DATABASE_URL")
	}
	if databaseURL == "" {
		t.Skip("set AUTH_TEST_DATABASE_URL or DATABASE_URL for public idempotency concurrency test")
	}
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	cfg, err := pgxpool.ParseConfig(databaseURL)
	if err != nil {
		t.Fatalf("parse config: %v", err)
	}
	// Force starvation scenarios to be visible when implementation is wrong.
	cfg.MaxConns = 2
	pool, err := pgxpool.NewWithConfig(ctx, cfg)
	if err != nil {
		t.Fatalf("connect: %v", err)
	}
	t.Cleanup(pool.Close)
	if err := pool.Ping(ctx); err != nil {
		t.Fatalf("ping: %v", err)
	}
	var exists bool
	if err := pool.QueryRow(ctx, `
		SELECT EXISTS (
			SELECT 1 FROM information_schema.tables
			WHERE table_name='auth_public_idempotency'
		)
	`).Scan(&exists); err != nil {
		t.Fatalf("check auth_public_idempotency: %v", err)
	}
	// With DATABASE_URL set (CI), missing schema must FAIL not silent-SKIP.
	if !exists {
		t.Fatal("auth_public_idempotency table missing; run migrations (0034+)")
	}
	var hasState bool
	if err := pool.QueryRow(ctx, `
		SELECT EXISTS (
			SELECT 1 FROM information_schema.columns
			WHERE table_name='auth_public_idempotency' AND column_name='state'
		)
	`).Scan(&hasState); err != nil {
		t.Fatalf("check state column: %v", err)
	}
	if !hasState {
		t.Fatal("auth_public_idempotency.state missing; apply migration 0038")
	}
	return pool
}

func TestRunPublicIdempotentConcurrentSendOnce(t *testing.T) {
	pool := testPool(t)
	store := New(pool)
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	key := "pub-idem-" + uuid.NewString()
	var calls atomic.Int32
	var wg sync.WaitGroup
	results := make([]IdempotentResult, 2)
	errs := make([]error, 2)
	for i := 0; i < 2; i++ {
		wg.Add(1)
		go func(idx int) {
			defer wg.Done()
			results[idx], errs[idx] = store.RunPublicIdempotent(
				ctx, key, "POST", "/v1/public/customer/verification-codes",
				[]byte(`{"phone":"+8613800138000"}`),
				func(context.Context) (int, any, error) {
					calls.Add(1)
					// Nested pool usage while claim is held must not starve.
					// This models EnforceRateLimit / CreateVerificationChallenge.
					tx, err := store.Pool.Begin(ctx)
					if err != nil {
						return 0, nil, err
					}
					defer func() { _ = tx.Rollback(ctx) }()
					var n int
					if err := tx.QueryRow(ctx, `SELECT 1`).Scan(&n); err != nil {
						return 0, nil, err
					}
					if err := tx.Commit(ctx); err != nil {
						return 0, nil, err
					}
					time.Sleep(80 * time.Millisecond)
					return 202, map[string]any{"verification_id": "v-shared"}, nil
				},
			)
		}(i)
	}
	wg.Wait()
	for i, err := range errs {
		if err != nil {
			t.Fatalf("goroutine %d: %v", i, err)
		}
	}
	if calls.Load() != 1 {
		t.Fatalf("side effect calls=%d want 1", calls.Load())
	}
	if results[0].Status != 202 || results[1].Status != 202 {
		t.Fatalf("status mismatch: %+v %+v", results[0], results[1])
	}
	// Third request must replay without re-executing side effect.
	third, err := store.RunPublicIdempotent(
		ctx, key, "POST", "/v1/public/customer/verification-codes",
		[]byte(`{"phone":"+8613800138000"}`),
		func(context.Context) (int, any, error) {
			t.Fatal("third call must not re-execute side effect")
			return 0, nil, fmt.Errorf("unreachable")
		},
	)
	if err != nil {
		t.Fatalf("third: %v", err)
	}
	if !third.Replayed {
		t.Fatal("third must be replayed")
	}
	_, _ = pool.Exec(ctx, `DELETE FROM auth_public_idempotency WHERE idempotency_key=$1`, key)
}

// TestRunPublicIdempotentSameKeyNestedDBNoStarvation is the Round-6 P0 reproducer:
// MaxConns=2, same idempotency key, concurrent waiters, callback does real pool Begin.
// The old Acquire+advisory-lock design deadlocks here; claim-row must finish both.
func TestRunPublicIdempotentSameKeyNestedDBNoStarvation(t *testing.T) {
	pool := testPool(t) // MaxConns=2
	store := New(pool)
	ctx, cancel := context.WithTimeout(context.Background(), 12*time.Second)
	defer cancel()

	key := "pub-starv-same-" + uuid.NewString()
	var calls atomic.Int32
	const n = 4
	var wg sync.WaitGroup
	errs := make([]error, n)
	for i := 0; i < n; i++ {
		wg.Add(1)
		go func(i int) {
			defer wg.Done()
			_, errs[i] = store.RunPublicIdempotent(
				ctx, key, "POST", "/v1/public/customer/verification-codes",
				[]byte(`{"phone":"+8613800138001"}`),
				func(ctx context.Context) (int, any, error) {
					calls.Add(1)
					// Hold nested work long enough that waiters would pile up under old design.
					for j := 0; j < 3; j++ {
						tx, err := store.Pool.Begin(ctx)
						if err != nil {
							return 0, nil, err
						}
						if _, err := tx.Exec(ctx, `SELECT pg_sleep(0.02)`); err != nil {
							_ = tx.Rollback(ctx)
							return 0, nil, err
						}
						if err := tx.Commit(ctx); err != nil {
							return 0, nil, err
						}
					}
					return 202, map[string]any{"ok": true}, nil
				},
			)
		}(i)
	}
	wg.Wait()
	for i, err := range errs {
		if err != nil {
			t.Fatalf("same-key starvation goroutine %d under MaxConns=2: %v", i, err)
		}
	}
	if calls.Load() != 1 {
		t.Fatalf("side effect calls=%d want 1", calls.Load())
	}
	_, _ = pool.Exec(ctx, `DELETE FROM auth_public_idempotency WHERE idempotency_key=$1`, key)
}

func TestRunPublicIdempotentNoPoolStarvationUnderNestedDB(t *testing.T) {
	pool := testPool(t) // MaxConns=2
	store := New(pool)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// Different keys + nested DB must not deadlock the tiny pool.
	var wg sync.WaitGroup
	errs := make(chan error, 4)
	for i := 0; i < 4; i++ {
		wg.Add(1)
		go func(i int) {
			defer wg.Done()
			key := fmt.Sprintf("pub-starv-%d-%s", i, uuid.NewString())
			_, err := store.RunPublicIdempotent(
				ctx, key, "POST", "/v1/public/customer/verification-codes",
				[]byte(fmt.Sprintf(`{"n":%d}`, i)),
				func(ctx context.Context) (int, any, error) {
					tx, err := store.Pool.Begin(ctx)
					if err != nil {
						return 0, nil, err
					}
					defer func() { _ = tx.Rollback(ctx) }()
					if _, err := tx.Exec(ctx, `SELECT 1`); err != nil {
						return 0, nil, err
					}
					if err := tx.Commit(ctx); err != nil {
						return 0, nil, err
					}
					return 202, map[string]any{"ok": i}, nil
				},
			)
			errs <- err
			_, _ = pool.Exec(ctx, `DELETE FROM auth_public_idempotency WHERE idempotency_key=$1`, key)
		}(i)
	}
	wg.Wait()
	close(errs)
	for err := range errs {
		if err != nil {
			t.Fatalf("starvation/timeout under MaxConns=2: %v", err)
		}
	}
}

func TestRunPublicIdempotentPayloadMismatch(t *testing.T) {
	pool := testPool(t)
	store := New(pool)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	key := "pub-mismatch-" + uuid.NewString()
	_, err := store.RunPublicIdempotent(
		ctx, key, "POST", "/path", []byte(`{"a":1}`),
		func(context.Context) (int, any, error) {
			return 202, map[string]any{"ok": true}, nil
		},
	)
	if err != nil {
		t.Fatalf("first: %v", err)
	}
	_, err = store.RunPublicIdempotent(
		ctx, key, "POST", "/path", []byte(`{"a":2}`),
		func(context.Context) (int, any, error) {
			t.Fatal("must not run")
			return 0, nil, fmt.Errorf("unreachable")
		},
	)
	if err != ErrIdempotencyPayloadMismatch {
		t.Fatalf("want payload mismatch, got %v", err)
	}
	_, _ = pool.Exec(ctx, `DELETE FROM auth_public_idempotency WHERE idempotency_key=$1`, key)
}
