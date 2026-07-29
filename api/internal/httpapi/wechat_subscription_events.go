package httpapi

import (
	"context"
	"encoding/json"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

func queueWechatSubscriptionEventTx(
	ctx context.Context,
	tx pgx.Tx,
	accountID uuid.UUID,
	eventType string,
	resourceID uuid.UUID,
	dedupeKey string,
	payload map[string]any,
	scheduledAt time.Time,
) error {
	encoded, err := json.Marshal(payload)
	if err != nil {
		return err
	}
	_, err = tx.Exec(ctx, `
		INSERT INTO breeder_wechat_subscription_event (
			account_id, event_type, resource_id, dedupe_key, payload, scheduled_at
		) VALUES ($1,$2,$3,$4,$5::jsonb,$6)
		ON CONFLICT (account_id, dedupe_key) DO NOTHING
	`, accountID, eventType, resourceID, dedupeKey, encoded, scheduledAt)
	return err
}

func queueWechatSubscriptionEvent(
	ctx context.Context,
	pool *pgxpool.Pool,
	accountID uuid.UUID,
	eventType string,
	resourceID uuid.UUID,
	dedupeKey string,
	payload map[string]any,
	scheduledAt time.Time,
) error {
	encoded, err := json.Marshal(payload)
	if err != nil {
		return err
	}
	_, err = pool.Exec(ctx, `
		INSERT INTO breeder_wechat_subscription_event (
			account_id, event_type, resource_id, dedupe_key, payload, scheduled_at
		) VALUES ($1,$2,$3,$4,$5::jsonb,$6)
		ON CONFLICT (account_id, dedupe_key) DO NOTHING
	`, accountID, eventType, resourceID, dedupeKey, encoded, scheduledAt)
	return err
}
