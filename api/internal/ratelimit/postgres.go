// Package ratelimit contains the durable request throttling boundary used by
// public and authentication endpoints.
package ratelimit

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var ErrRateLimited = errors.New("rate limited")

// Postgres implements a per-key cooldown plus a durable fixed-window counter.
// Row locking makes the counter safe across API processes without Redis.
type Postgres struct {
	Pool *pgxpool.Pool
}

func NewPostgres(pool *pgxpool.Pool) *Postgres {
	return &Postgres{Pool: pool}
}

// CheckAndHit atomically consumes one hit. It returns Retry-After seconds when
// the request is blocked and ErrRateLimited as the error.
func (p *Postgres) CheckAndHit(
	ctx context.Context,
	bucketKey string,
	cooldown time.Duration,
	maxPerWindow int,
	window time.Duration,
	now time.Time,
) (int, error) {
	if p == nil || p.Pool == nil {
		return 0, fmt.Errorf("ratelimit postgres pool is nil")
	}
	if maxPerWindow < 1 {
		maxPerWindow = 1
	}
	if window <= 0 {
		window = time.Hour
	}

	tx, err := p.Pool.Begin(ctx)
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
		return retryAfter(*blockedUntil, now), ErrRateLimited
	}
	if !lastHit.IsZero() && now.Sub(lastHit) < cooldown {
		return retryAfter(lastHit.Add(cooldown), now), ErrRateLimited
	}
	if windowStarted.IsZero() || now.Sub(windowStarted) >= window {
		windowStarted = now
		hitCount = 0
	}
	if hitCount >= maxPerWindow {
		until := now.Add(window)
		if _, err := tx.Exec(ctx, `
			UPDATE auth_rate_limit
			SET blocked_until=$2, last_hit_at=$3
			WHERE bucket_key=$1
		`, bucketKey, until, now); err != nil {
			return 0, err
		}
		if err := tx.Commit(ctx); err != nil {
			return 0, err
		}
		return int(window.Seconds()), ErrRateLimited
	}
	hitCount++
	if _, err := tx.Exec(ctx, `
		UPDATE auth_rate_limit
		SET hit_count=$2, window_started_at=$3, last_hit_at=$4, blocked_until=NULL
		WHERE bucket_key=$1
	`, bucketKey, hitCount, windowStarted, now); err != nil {
		return 0, err
	}
	return 0, tx.Commit(ctx)
}

func retryAfter(until, now time.Time) int {
	seconds := int(until.Sub(now).Seconds()) + 1
	if seconds < 1 {
		return 1
	}
	return seconds
}
