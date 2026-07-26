package httpapi

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"os"
	"sync"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/scolvpet/scolvpet/api/internal/auth"
	"github.com/scolvpet/scolvpet/api/internal/store"
)

// refreshSession runs its work inside a RunIdempotent transaction, so it is
// already holding one pooled connection. Routing the rotation through
// auth.Refresh made it take the service mutex and then ask the pool for more
// connections; once concurrent refreshes reached DB_MAX_CONNS every request
// held a connection while waiting on the mutex holder, which was itself waiting
// for a connection that could never free. The pool wedged permanently and, as
// ParseAccessTokenContext shares that mutex, every authenticated request with
// it. MaxConns is pinned to the concurrency level here to hit the cliff exactly.
func TestConcurrentRefreshDoesNotExhaustPool(t *testing.T) {
	databaseURL := os.Getenv("AUTH_TEST_DATABASE_URL")
	if databaseURL == "" {
		databaseURL = os.Getenv("DATABASE_URL")
	}
	if databaseURL == "" {
		t.Skip("set AUTH_TEST_DATABASE_URL or DATABASE_URL to run refresh concurrency test")
	}
	const concurrency = 4

	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	defer cancel()
	config, err := pgxpool.ParseConfig(databaseURL)
	if err != nil {
		t.Fatalf("parse database url: %v", err)
	}
	config.MaxConns = concurrency
	pool, err := pgxpool.NewWithConfig(ctx, config)
	if err != nil {
		t.Fatalf("connect postgres: %v", err)
	}
	t.Cleanup(pool.Close)
	if err := pool.Ping(ctx); err != nil {
		t.Fatalf("ping postgres: %v", err)
	}

	dataStore := store.New(pool)
	authService := auth.NewWithPersistence("refresh-concurrency-test", "123456", dataStore)
	handler := NewServer(dataStore, authService, slog.Default()).Handler()

	seed := time.Now().UnixNano() % 1000000000
	ownerIDs := make([]uuid.UUID, 0, concurrency)
	tokens := make([]string, 0, concurrency)
	for i := 0; i < concurrency; i++ {
		phone := fmt.Sprintf("+8612%09d%02d", seed, i)
		_, ownerID, err := dataStore.EnsureAccount(ctx, phone)
		if err != nil {
			t.Fatalf("ensure account %d: %v", i, err)
		}
		ownerIDs = append(ownerIDs, ownerID)
		tx, err := pool.Begin(ctx)
		if err != nil {
			t.Fatal(err)
		}
		if _, err := store.EnsureOrganizationTx(ctx, tx, ownerID); err != nil {
			_ = tx.Rollback(ctx)
			t.Fatalf("ensure organization %d: %v", i, err)
		}
		if err := tx.Commit(ctx); err != nil {
			t.Fatal(err)
		}
		_, refreshToken, err := authService.CreateSession(ctx, ownerID)
		if err != nil {
			t.Fatalf("create session %d: %v", i, err)
		}
		tokens = append(tokens, refreshToken)
	}
	t.Cleanup(func() {
		cleanupCtx, cleanupCancel := context.WithTimeout(context.Background(), 15*time.Second)
		defer cleanupCancel()
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM auth_refresh_session WHERE owner_id = ANY($1)`, ownerIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM idempotency_record WHERE owner_id = ANY($1)`, ownerIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM organization_member WHERE owner_id = ANY($1) OR account_id = ANY($1)`, ownerIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM domain_event WHERE owner_id = ANY($1)`, ownerIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM organization WHERE owner_id = ANY($1)`, ownerIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM account WHERE id = ANY($1)`, ownerIDs)
	})

	statuses := make([]int, concurrency)
	bodies := make([]string, concurrency)
	var wg sync.WaitGroup
	start := make(chan struct{})
	for i, token := range tokens {
		wg.Add(1)
		go func(i int, token string) {
			defer wg.Done()
			<-start
			// A deadline keeps a regression from wedging the whole test binary:
			// pgxpool.Acquire honours it, so a starved request fails instead of
			// hanging forever.
			requestCtx, requestCancel := context.WithTimeout(context.Background(), 15*time.Second)
			defer requestCancel()
			body, _ := json.Marshal(map[string]string{"refresh_token": token})
			request := httptest.NewRequest(
				http.MethodPost,
				"/v1/auth/sessions/refresh",
				bytes.NewReader(body),
			).WithContext(requestCtx)
			request.Header.Set("Content-Type", "application/json")
			request.Header.Set("Idempotency-Key", fmt.Sprintf("refresh-concurrency-%d-%d", seed, i))
			recorder := httptest.NewRecorder()
			handler.ServeHTTP(recorder, request)
			statuses[i] = recorder.Code
			bodies[i] = recorder.Body.String()
		}(i, token)
	}
	close(start)
	wg.Wait()

	for i, status := range statuses {
		if status != http.StatusCreated {
			t.Fatalf("refresh %d: status=%d body=%s", i, status, bodies[i])
		}
	}
}
