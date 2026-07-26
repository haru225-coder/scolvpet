package store

import (
	"context"
	"crypto/sha256"
	"crypto/subtle"
	"encoding/hex"
	"encoding/json"
	"errors"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/scolvpet/scolvpet/api/internal/auth"
)

func (s *Store) CreateVerificationChallenge(ctx context.Context, id uuid.UUID, phone, codeHash string, expiresAt time.Time) error {
	_, err := s.Pool.Exec(ctx, `
		INSERT INTO verification_challenge (id, phone, purpose, code_sha256, expires_at)
		VALUES ($1, $2, 'login', $3, $4)
	`, id, phone, codeHash, expiresAt)
	return err
}

func (s *Store) DeleteVerificationChallenge(ctx context.Context, id uuid.UUID) error {
	_, err := s.Pool.Exec(ctx, `DELETE FROM verification_challenge WHERE id=$1`, id)
	return err
}

func (s *Store) VerifyVerificationChallenge(ctx context.Context, id uuid.UUID, phone, codeHash string, now time.Time) error {
	tx, err := s.Pool.Begin(ctx)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback(ctx) }()

	var storedPhone, storedHash string
	var attempts int
	var expiresAt time.Time
	var consumedAt *time.Time
	err = tx.QueryRow(ctx, `
		SELECT phone, code_sha256, attempts, expires_at, consumed_at
		FROM verification_challenge
		WHERE id=$1
		FOR UPDATE
	`, id).Scan(&storedPhone, &storedHash, &attempts, &expiresAt, &consumedAt)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return auth.ErrVerification
		}
		return err
	}
	if storedPhone != phone || consumedAt != nil || !now.Before(expiresAt) {
		return auth.ErrVerification
	}
	if attempts >= 5 {
		return auth.ErrInvalidCode
	}

	attempts++
	if subtle.ConstantTimeCompare([]byte(storedHash), []byte(codeHash)) != 1 {
		if _, err := tx.Exec(ctx, `UPDATE verification_challenge SET attempts=$2 WHERE id=$1`, id, attempts); err != nil {
			return err
		}
		if err := tx.Commit(ctx); err != nil {
			return err
		}
		return auth.ErrInvalidCode
	}
	if _, err := tx.Exec(ctx, `
		UPDATE verification_challenge
		SET attempts=$2, consumed_at=$3
		WHERE id=$1
	`, id, attempts, now); err != nil {
		return err
	}
	return tx.Commit(ctx)
}

func (s *Store) CreateRefreshSession(ctx context.Context, tokenHash string, ownerID uuid.UUID, expiresAt time.Time) error {
	_, err := s.Pool.Exec(ctx, `
		INSERT INTO auth_refresh_session (owner_id, token_sha256, expires_at)
		VALUES ($1, $2, $3)
	`, ownerID, tokenHash, expiresAt)
	return err
}

func (s *Store) LookupRefreshSession(ctx context.Context, tokenHash string, now time.Time) (uuid.UUID, error) {
	_, err := s.Pool.Exec(ctx, `
		DELETE FROM auth_refresh_session
		WHERE expires_at <= $1 AND revoked_at IS NULL AND consumed_at IS NULL
	`, now)
	if err != nil {
		return uuid.Nil, err
	}
	return lookupRefreshSession(ctx, s.Pool, tokenHash, now)
}

// LookupRefreshSessionTx reads the session on a transaction the caller already
// owns, so a handler inside an idempotency transaction never waits on a second
// pooled connection. The opportunistic cleanup of LookupRefreshSession is left
// out on purpose: writing to shared rows inside the caller's transaction would
// widen its lock footprint, and OwnerForRefresh already runs that sweep earlier
// in the same request.
func (s *Store) LookupRefreshSessionTx(
	ctx context.Context,
	tx pgx.Tx,
	tokenHash string,
	now time.Time,
) (uuid.UUID, error) {
	return lookupRefreshSession(ctx, tx, tokenHash, now)
}

type refreshSessionQueryer interface {
	QueryRow(ctx context.Context, sql string, args ...any) pgx.Row
}

func lookupRefreshSession(
	ctx context.Context,
	queryer refreshSessionQueryer,
	tokenHash string,
	now time.Time,
) (uuid.UUID, error) {
	var ownerID uuid.UUID
	var expiresAt time.Time
	var revokedAt *time.Time
	err := queryer.QueryRow(ctx, `
		SELECT owner_id, expires_at, revoked_at
		FROM auth_refresh_session
		WHERE token_sha256=$1
	`, tokenHash).Scan(&ownerID, &expiresAt, &revokedAt)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return uuid.Nil, auth.ErrInvalidRefresh
		}
		return uuid.Nil, err
	}
	if revokedAt != nil || !now.Before(expiresAt) {
		return uuid.Nil, auth.ErrInvalidRefresh
	}
	return ownerID, nil
}

func (s *Store) RotateRefreshSession(ctx context.Context, tokenHash, nextTokenHash string, ownerID uuid.UUID, expiresAt, now time.Time) error {
	tx, err := s.Pool.Begin(ctx)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback(ctx) }()

	if err := rotateRefreshSession(ctx, tx, tokenHash, nextTokenHash, ownerID, expiresAt, now); err != nil {
		return err
	}
	return tx.Commit(ctx)
}

// RotateRefreshSessionTx rotates on the caller's transaction; see
// LookupRefreshSessionTx for why the refresh path must not open its own.
func (s *Store) RotateRefreshSessionTx(
	ctx context.Context,
	tx pgx.Tx,
	tokenHash, nextTokenHash string,
	ownerID uuid.UUID,
	expiresAt, now time.Time,
) error {
	return rotateRefreshSession(ctx, tx, tokenHash, nextTokenHash, ownerID, expiresAt, now)
}

func rotateRefreshSession(
	ctx context.Context,
	tx pgx.Tx,
	tokenHash, nextTokenHash string,
	ownerID uuid.UUID,
	expiresAt, now time.Time,
) error {
	var currentOwner uuid.UUID
	err := tx.QueryRow(ctx, `
		UPDATE auth_refresh_session
		SET consumed_at=$3, last_used_at=$3
		WHERE token_sha256=$1 AND owner_id=$2
		  AND consumed_at IS NULL AND revoked_at IS NULL AND expires_at > $3
		RETURNING owner_id
	`, tokenHash, ownerID, now).Scan(&currentOwner)
	if errors.Is(err, pgx.ErrNoRows) {
		return auth.ErrInvalidRefresh
	}
	if err != nil {
		return err
	}
	if currentOwner != ownerID {
		return auth.ErrInvalidRefresh
	}
	_, err = tx.Exec(ctx, `
		INSERT INTO auth_refresh_session (owner_id, token_sha256, expires_at)
		VALUES ($1, $2, $3)
	`, ownerID, nextTokenHash, expiresAt)
	return err
}

func (s *Store) RevokeRefreshSession(ctx context.Context, tokenHash string, now time.Time) error {
	_, err := s.Pool.Exec(ctx, `
		UPDATE auth_refresh_session
		SET revoked_at=$2, last_used_at=$2
		WHERE token_sha256=$1
		  AND revoked_at IS NULL
		  AND (consumed_at IS NULL OR consumed_at IS NOT NULL)
	`, tokenHash, now)
	return err
}

func (s *Store) RevokeAllRefreshSessionsForOwner(ctx context.Context, ownerID uuid.UUID, now time.Time) error {
	_, err := s.Pool.Exec(ctx, `
		UPDATE auth_refresh_session
		SET revoked_at=$2, last_used_at=$2
		WHERE owner_id=$1
		  AND revoked_at IS NULL
		  AND expires_at > $2
	`, ownerID, now)
	return err
}

func (s *Store) RevokeAccessToken(ctx context.Context, tokenHash string, ownerID uuid.UUID, expiresAt time.Time) error {
	_, err := s.Pool.Exec(ctx, `
		INSERT INTO revoked_token (token_sha256, owner_id, expires_at)
		VALUES ($1, $2, $3)
		ON CONFLICT (token_sha256) DO UPDATE
		SET expires_at = GREATEST(revoked_token.expires_at, EXCLUDED.expires_at),
		    revoked_at = now()
	`, tokenHash, ownerID, expiresAt)
	return err
}

func (s *Store) IsAccessTokenRevoked(ctx context.Context, tokenHash string, now time.Time) (bool, error) {
	// best-effort cleanup of expired rows
	_, _ = s.Pool.Exec(ctx, `DELETE FROM revoked_token WHERE expires_at <= $1`, now)
	var exists bool
	err := s.Pool.QueryRow(ctx, `
		SELECT EXISTS(
			SELECT 1 FROM revoked_token
			WHERE token_sha256=$1 AND expires_at > $2
		)
	`, tokenHash, now).Scan(&exists)
	return exists, err
}

// RunPublicIdempotent stores pre-account write responses (no owner_id FK).
// Durable claim/state machine: never holds a pool connection across fn().
// fn may freely use the pool (rate-limit, SMS challenge) without starvation.
//
// TTL should be ~challenge lifetime (5m) for verification codes.
func (s *Store) RunPublicIdempotent(
	ctx context.Context,
	key, method, path string,
	payload []byte,
	fn func(context.Context) (status int, body any, err error),
) (IdempotentResult, error) {
	return s.RunPublicIdempotentTTL(ctx, key, method, path, payload, 5*time.Minute, fn)
}

func (s *Store) RunPublicIdempotentTTL(
	ctx context.Context,
	key, method, path string,
	payload []byte,
	ttl time.Duration,
	fn func(context.Context) (status int, body any, err error),
) (IdempotentResult, error) {
	if strings.TrimSpace(key) == "" {
		return IdempotentResult{}, ErrIdempotencyKeyRequired
	}
	if ttl <= 0 {
		ttl = 5 * time.Minute
	}
	hash := sha256.Sum256([]byte(method + "\n" + path + "\n" + string(payload)))
	hashHex := hex.EncodeToString(hash[:])
	staleAfter := 30 * time.Second

	// Durable claim / processing state machine:
	// 1) short DB claim (INSERT or stale takeover)
	// 2) RELEASE pool connection
	// 3) run fn() which may freely use the pool again
	// 4) short DB mark completed
	// Never hold Pool.Acquire across fn() — that starves MaxConns under nested DB.
	for attempt := 0; attempt < 3; attempt++ {
		now := time.Now().UTC()
		expires := now.Add(ttl)
		if attempt == 0 {
			_, _ = s.Pool.Exec(ctx, `DELETE FROM auth_public_idempotency WHERE expires_at <= $1`, now)
		}

		claimed, replay, err := s.tryClaimPublicIdempotency(ctx, key, hashHex, expires, now, staleAfter)
		if err != nil {
			return IdempotentResult{}, err
		}
		if replay != nil {
			return *replay, nil
		}
		if !claimed {
			// Wait without holding a connection; owner may delete on failure → re-claim.
			result, waitErr := s.waitPublicIdempotency(ctx, key, hashHex, 12*time.Second)
			if errors.Is(waitErr, errPublicIdempotencyOwnerGone) {
				continue
			}
			return result, waitErr
		}

		// We own the claim — side effects MUST NOT run while holding a dedicated pool conn.
		status, body, err := fn(ctx)
		if err != nil {
			_, _ = s.Pool.Exec(ctx, `
				DELETE FROM auth_public_idempotency
				WHERE idempotency_key=$1 AND state='processing'
			`, key)
			return IdempotentResult{}, err
		}
		raw, err := json.Marshal(body)
		if err != nil {
			_, _ = s.Pool.Exec(ctx, `
				DELETE FROM auth_public_idempotency
				WHERE idempotency_key=$1 AND state='processing'
			`, key)
			return IdempotentResult{}, err
		}
		tag, err := s.Pool.Exec(ctx, `
			UPDATE auth_public_idempotency
			SET state='completed',
			    response_status=$2,
			    response_body=$3::jsonb,
			    expires_at=$4,
			    locked_at=NULL
			WHERE idempotency_key=$1 AND state='processing'
		`, key, status, raw, expires)
		if err != nil {
			return IdempotentResult{}, err
		}
		if tag.RowsAffected() == 0 {
			// Lost claim (stale takeover); prefer stored completed response if any.
			if result, waitErr := s.waitPublicIdempotency(ctx, key, hashHex, 2*time.Second); waitErr == nil {
				return result, nil
			}
			return IdempotentResult{Status: status, Body: raw, Headers: map[string]string{}, Replayed: false}, nil
		}
		return IdempotentResult{Status: status, Body: raw, Headers: map[string]string{}, Replayed: false}, nil
	}
	return IdempotentResult{}, ErrIdempotencyInProgress
}

// errPublicIdempotencyOwnerGone means the processing claim vanished (owner failed);
// caller should re-attempt claim rather than surface in-progress.
var errPublicIdempotencyOwnerGone = errors.New("public idempotency owner gone")

func (s *Store) tryClaimPublicIdempotency(
	ctx context.Context,
	key, hashHex string,
	expires, now time.Time,
	staleAfter time.Duration,
) (claimed bool, replay *IdempotentResult, err error) {
	// Fresh claim — single short statement, connection returned to pool immediately after.
	tag, err := s.Pool.Exec(ctx, `
		INSERT INTO auth_public_idempotency (
			idempotency_key, request_hash, state, response_status, response_body, expires_at, locked_at
		) VALUES ($1, $2, 'processing', NULL, NULL, $3, $4)
		ON CONFLICT (idempotency_key) DO NOTHING
	`, key, hashHex, expires, now)
	if err != nil {
		return false, nil, err
	}
	if tag.RowsAffected() == 1 {
		return true, nil, nil
	}

	// Existing row: completed → replay; processing fresh → wait; processing stale → takeover.
	var state, existingHash string
	var responseStatus *int
	var responseBody []byte
	var lockedAt *time.Time
	err = s.Pool.QueryRow(ctx, `
		SELECT state, request_hash, response_status, response_body, locked_at
		FROM auth_public_idempotency
		WHERE idempotency_key=$1
	`, key).Scan(&state, &existingHash, &responseStatus, &responseBody, &lockedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		tag, err = s.Pool.Exec(ctx, `
			INSERT INTO auth_public_idempotency (
				idempotency_key, request_hash, state, response_status, response_body, expires_at, locked_at
			) VALUES ($1, $2, 'processing', NULL, NULL, $3, $4)
			ON CONFLICT (idempotency_key) DO NOTHING
		`, key, hashHex, expires, now)
		if err != nil {
			return false, nil, err
		}
		return tag.RowsAffected() == 1, nil, nil
	}
	if err != nil {
		return false, nil, err
	}
	if existingHash != hashHex {
		return false, nil, ErrIdempotencyPayloadMismatch
	}
	if state == "completed" && responseStatus != nil && len(responseBody) > 0 {
		return false, &IdempotentResult{
			Status: *responseStatus, Body: responseBody, Headers: map[string]string{}, Replayed: true,
		}, nil
	}
	// Take over stale processing (owner crashed / hung past staleAfter).
	if state == "processing" && (lockedAt == nil || now.Sub(*lockedAt) >= staleAfter) {
		tag, err = s.Pool.Exec(ctx, `
			UPDATE auth_public_idempotency
			SET locked_at=$2, expires_at=$3, request_hash=$4
			WHERE idempotency_key=$1
			  AND state='processing'
			  AND (locked_at IS NULL OR locked_at <= $5)
		`, key, now, expires, hashHex, now.Add(-staleAfter))
		if err != nil {
			return false, nil, err
		}
		return tag.RowsAffected() == 1, nil, nil
	}
	return false, nil, nil
}

func (s *Store) waitPublicIdempotency(
	ctx context.Context,
	key, hashHex string,
	timeout time.Duration,
) (IdempotentResult, error) {
	deadline := time.Now().Add(timeout)
	if dl, ok := ctx.Deadline(); ok && dl.Before(deadline) {
		deadline = dl
	}
	for {
		var state, existingHash string
		var responseStatus *int
		var responseBody []byte
		err := s.Pool.QueryRow(ctx, `
			SELECT state, request_hash, response_status, response_body
			FROM auth_public_idempotency
			WHERE idempotency_key=$1
		`, key).Scan(&state, &existingHash, &responseStatus, &responseBody)
		if errors.Is(err, pgx.ErrNoRows) {
			// Owner failed and deleted claim — re-enter claim loop.
			return IdempotentResult{}, errPublicIdempotencyOwnerGone
		}
		if err != nil {
			return IdempotentResult{}, err
		}
		if existingHash != hashHex {
			return IdempotentResult{}, ErrIdempotencyPayloadMismatch
		}
		if state == "completed" && responseStatus != nil && len(responseBody) > 0 {
			return IdempotentResult{Status: *responseStatus, Body: responseBody, Headers: map[string]string{}, Replayed: true}, nil
		}
		if time.Now().After(deadline) {
			return IdempotentResult{}, ErrIdempotencyInProgress
		}
		select {
		case <-ctx.Done():
			return IdempotentResult{}, ctx.Err()
		case <-time.After(25 * time.Millisecond):
		}
	}
}

// CheckAndHitRateLimit enforces per-bucket cooldown and window caps.
// When blocked, returns (retryAfterSeconds, auth.ErrRateLimited).
func (s *Store) CheckAndHitRateLimit(
	ctx context.Context,
	bucketKey string,
	cooldown time.Duration,
	maxPerWindow int,
	window time.Duration,
	now time.Time,
) (int, error) {
	tx, err := s.Pool.Begin(ctx)
	if err != nil {
		return 0, err
	}
	defer func() { _ = tx.Rollback(ctx) }()

	var hitCount int
	var windowStarted, lastHit time.Time
	var blockedUntil *time.Time
	err = tx.QueryRow(ctx, `
		SELECT hit_count, window_started_at, last_hit_at, blocked_until
		FROM auth_rate_limit
		WHERE bucket_key=$1
		FOR UPDATE
	`, bucketKey).Scan(&hitCount, &windowStarted, &lastHit, &blockedUntil)
	if errors.Is(err, pgx.ErrNoRows) {
		_, err = tx.Exec(ctx, `
			INSERT INTO auth_rate_limit (bucket_key, hit_count, window_started_at, last_hit_at)
			VALUES ($1, 1, $2, $2)
		`, bucketKey, now)
		if err != nil {
			return 0, err
		}
		return 0, tx.Commit(ctx)
	}
	if err != nil {
		return 0, err
	}
	if blockedUntil != nil && now.Before(*blockedUntil) {
		retry := int(blockedUntil.Sub(now).Seconds()) + 1
		if retry < 1 {
			retry = 1
		}
		return retry, auth.ErrRateLimited
	}
	if !lastHit.IsZero() && now.Sub(lastHit) < cooldown {
		retry := int(cooldown.Seconds()) - int(now.Sub(lastHit).Seconds())
		if retry < 1 {
			retry = 1
		}
		return retry, auth.ErrRateLimited
	}
	if windowStarted.IsZero() || now.Sub(windowStarted) >= window {
		windowStarted = now
		hitCount = 0
	}
	if hitCount >= maxPerWindow {
		until := now.Add(window)
		_, err = tx.Exec(ctx, `
			UPDATE auth_rate_limit
			SET blocked_until=$2, last_hit_at=$3
			WHERE bucket_key=$1
		`, bucketKey, until, now)
		if err != nil {
			return 0, err
		}
		if err := tx.Commit(ctx); err != nil {
			return 0, err
		}
		return int(window.Seconds()), auth.ErrRateLimited
	}
	hitCount++
	_, err = tx.Exec(ctx, `
		UPDATE auth_rate_limit
		SET hit_count=$2, window_started_at=$3, last_hit_at=$4, blocked_until=NULL
		WHERE bucket_key=$1
	`, bucketKey, hitCount, windowStarted, now)
	if err != nil {
		return 0, err
	}
	return 0, tx.Commit(ctx)
}
