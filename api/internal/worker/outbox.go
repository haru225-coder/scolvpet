package worker

import (
	"context"
	"fmt"
	"log/slog"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Worker struct {
	Pool          *pgxpool.Pool
	Logger        *slog.Logger
	ID            string
	LeaseDuration time.Duration
	Publisher     func(context.Context, string, []byte) error
}

type message struct {
	ID           uuid.UUID
	OwnerID      uuid.UUID
	Topic        string
	Payload      []byte
	AttemptCount int
	MaxAttempts  int
}

func New(pool *pgxpool.Pool, logger *slog.Logger) *Worker {
	return &Worker{
		Pool:          pool,
		Logger:        logger,
		ID:            "worker-" + uuid.NewString(),
		LeaseDuration: time.Minute,
	}
}

func (w *Worker) Run(ctx context.Context, interval time.Duration) {
	ticker := time.NewTicker(interval)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			if err := w.RunOnce(ctx); err != nil && w.Logger != nil {
				w.Logger.Error("outbox worker cycle failed", "error", err)
			}
		}
	}
}

func (w *Worker) RunOnce(ctx context.Context) error {
	if err := w.recoverStale(ctx); err != nil {
		return err
	}
	tx, err := w.Pool.Begin(ctx)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback(ctx) }()

	var item message
	err = tx.QueryRow(ctx, `
		SELECT id, owner_id, topic, payload, attempt_count, max_attempts
		FROM outbox_message
		WHERE status IN ('pending','failed')
		  AND available_at <= now()
		  AND attempt_count < max_attempts
		ORDER BY priority, created_at
		FOR UPDATE SKIP LOCKED
		LIMIT 1
	`).Scan(&item.ID, &item.OwnerID, &item.Topic, &item.Payload, &item.AttemptCount, &item.MaxAttempts)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil
		}
		return err
	}

	item.AttemptCount++
	_, err = tx.Exec(ctx, `
		UPDATE outbox_message
		SET status='processing', attempt_count=$2, locked_at=now(), locked_by=$3, updated_at=now()
		WHERE id=$1
	`, item.ID, item.AttemptCount, w.ID)
	if err != nil {
		return err
	}
	if err := tx.Commit(ctx); err != nil {
		return err
	}

	if w.Publisher != nil {
		if err := w.Publisher(ctx, item.Topic, item.Payload); err != nil {
			if failErr := w.failOwned(ctx, item, err); failErr != nil {
				return fmt.Errorf("publish failed: %w; recording failure failed: %v", err, failErr)
			}
			return err
		}
	}
	return w.finish(ctx, item)
}

func (w *Worker) recoverStale(ctx context.Context) error {
	seconds := int64(w.LeaseDuration / time.Second)
	if seconds < 1 {
		seconds = 1
	}
	_, err := w.Pool.Exec(ctx, `
		UPDATE outbox_message
		SET status=CASE WHEN attempt_count >= max_attempts THEN 'dead_letter'::outbox_status ELSE 'failed'::outbox_status END,
		    available_at=now(), locked_at=NULL, locked_by=NULL,
		    last_error=concat_ws('; ', NULLIF(last_error, ''), 'stale processing lease reclaimed'),
		    updated_at=now()
		WHERE status='processing'
		  AND locked_at IS NOT NULL
		  AND locked_at <= now() - make_interval(secs => $1)
	`, seconds)
	return err
}

func (w *Worker) finish(ctx context.Context, item message) error {
	tx, err := w.Pool.Begin(ctx)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback(ctx) }()

	result, err := tx.Exec(ctx, `
		UPDATE outbox_message
		SET status='published', published_at=now(), locked_at=NULL, locked_by=NULL, updated_at=now()
		WHERE id=$1 AND status='processing' AND locked_by=$2
	`, item.ID, w.ID)
	if err != nil {
		return err
	}
	if result.RowsAffected() != 1 {
		return fmt.Errorf("outbox lease lost for %s", item.ID)
	}
	if w.Logger != nil {
		w.Logger.Info("outbox message published", "message_id", item.ID, "topic", item.Topic, "attempt", item.AttemptCount)
	}
	return tx.Commit(ctx)
}

func (w *Worker) Fail(ctx context.Context, itemID uuid.UUID, reason error) error {
	return w.failItem(ctx, itemID, "", reason)
}

func (w *Worker) failOwned(ctx context.Context, item message, reason error) error {
	return w.failItem(ctx, item.ID, w.ID, reason)
}

func (w *Worker) failItem(ctx context.Context, itemID uuid.UUID, workerID string, reason error) error {
	tx, err := w.Pool.Begin(ctx)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback(ctx) }()
	query := `
		UPDATE outbox_message
		SET status=CASE WHEN attempt_count >= max_attempts THEN 'dead_letter'::outbox_status ELSE 'failed'::outbox_status END,
		    available_at=now()+make_interval(secs => LEAST(900, power(2, attempt_count)::int)),
		    locked_at=NULL, locked_by=NULL, last_error=$2, updated_at=now()
		WHERE id=$1 AND status='processing'`
	args := []any{itemID, fmt.Sprint(reason)}
	if workerID != "" {
		query += " AND locked_by=$3"
		args = append(args, workerID)
	}
	_, err = tx.Exec(ctx, query, args...)
	if err != nil {
		return err
	}
	return tx.Commit(ctx)
}
