package worker

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/scolvpet/scolvpet/api/internal/wechat"
)

// SubscriptionWorker delivers queued B-side WeChat subscription events. One
// event is fanned out to every currently accepted template, so the product can
// keep task and reservation template IDs configurable in the mini-program.
type SubscriptionWorker struct {
	Pool                  *pgxpool.Pool
	Sender                wechat.SubscriptionSender
	Logger                *slog.Logger
	ID                    string
	LeaseDuration         time.Duration
	TaskTemplateID        string
	ReservationTemplateID string
}

type subscriptionEvent struct {
	ID           uuid.UUID
	AccountID    uuid.UUID
	EventType    string
	ResourceID   uuid.UUID
	Payload      []byte
	AttemptCount int
	MaxAttempts  int
}

type acceptedSubscription struct {
	ID         uuid.UUID
	OpenID     string
	TemplateID string
	Page       string
}

func NewSubscriptionWorker(pool *pgxpool.Pool, sender wechat.SubscriptionSender, logger *slog.Logger) *SubscriptionWorker {
	return &SubscriptionWorker{
		Pool:          pool,
		Sender:        sender,
		Logger:        logger,
		ID:            "wechat-subscription-" + uuid.NewString(),
		LeaseDuration: time.Minute,
	}
}

func (w *SubscriptionWorker) Run(ctx context.Context, interval time.Duration) {
	if interval < time.Millisecond {
		interval = time.Second
	}
	ticker := time.NewTicker(interval)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			if err := w.RunOnce(ctx); err != nil && w.Logger != nil {
				w.Logger.Error("wechat subscription worker cycle failed", "error", err)
			}
		}
	}
}

func (w *SubscriptionWorker) RunOnce(ctx context.Context) error {
	if w.Pool == nil {
		return errors.New("wechat subscription worker database pool is nil")
	}
	if w.Sender == nil {
		return errors.New("wechat subscription worker sender is nil")
	}
	if err := w.recoverStale(ctx); err != nil {
		return err
	}
	event, err := w.claim(ctx)
	if err != nil || event == nil {
		return err
	}
	return w.process(ctx, *event)
}

func (w *SubscriptionWorker) recoverStale(ctx context.Context) error {
	seconds := int64(w.LeaseDuration / time.Second)
	if seconds < 1 {
		seconds = 1
	}
	_, err := w.Pool.Exec(ctx, `
		UPDATE breeder_wechat_subscription_event
		SET status='failed', next_attempt_at=now(), locked_at=NULL, locked_by=NULL,
			last_error=concat_ws('; ', NULLIF(last_error, ''), 'stale processing lease reclaimed'),
			version=version+1, updated_at=now()
		WHERE status='sending' AND locked_at IS NOT NULL
		  AND locked_at <= now() - make_interval(secs => $1)
	`, seconds)
	return err
}

func (w *SubscriptionWorker) claim(ctx context.Context) (*subscriptionEvent, error) {
	tx, err := w.Pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer func() { _ = tx.Rollback(ctx) }()

	event := &subscriptionEvent{}
	err = tx.QueryRow(ctx, `
		SELECT id, account_id, event_type, resource_id, payload, attempt_count, max_attempts
		FROM breeder_wechat_subscription_event
		WHERE status IN ('queued','failed')
		  AND scheduled_at <= now()
		  AND (next_attempt_at IS NULL OR next_attempt_at <= now())
		  AND attempt_count < max_attempts
		ORDER BY scheduled_at, created_at, id
		FOR UPDATE SKIP LOCKED
		LIMIT 1
	`).Scan(&event.ID, &event.AccountID, &event.EventType, &event.ResourceID, &event.Payload, &event.AttemptCount, &event.MaxAttempts)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	event.AttemptCount++
	if _, err := tx.Exec(ctx, `
		UPDATE breeder_wechat_subscription_event
		SET status='sending', attempt_count=$2, locked_at=now(), locked_by=$3,
			last_error=NULL, version=version+1, updated_at=now()
		WHERE id=$1 AND account_id=$4
	`, event.ID, event.AttemptCount, w.ID, event.AccountID); err != nil {
		return nil, err
	}
	if err := tx.Commit(ctx); err != nil {
		return nil, err
	}
	return event, nil
}

func (w *SubscriptionWorker) process(ctx context.Context, event subscriptionEvent) error {
	if event.EventType == "task_reminder" {
		var status string
		err := w.Pool.QueryRow(ctx, `
			SELECT status::text FROM care_task WHERE owner_id=$1 AND id=$2
		`, event.AccountID, event.ResourceID).Scan(&status)
		if errors.Is(err, pgx.ErrNoRows) {
			return w.cancel(ctx, event, "关联照护任务已删除")
		}
		if err != nil {
			return w.fail(ctx, event, err)
		}
		if status == "completed" || status == "cancelled" || status == "superseded" {
			return w.cancel(ctx, event, "照护任务已结束")
		}
	}

	subscriptions, err := w.acceptedSubscriptions(ctx, event.AccountID, event.EventType)
	if err != nil {
		return w.fail(ctx, event, err)
	}
	if len(subscriptions) == 0 {
		return w.cancel(ctx, event, "当前没有有效的微信订阅授权")
	}
	data, err := subscriptionEventData(event.EventType, event.Payload)
	if err != nil {
		return w.fail(ctx, event, err)
	}

	var lastProviderID string
	var lastErr error
	sent := 0
	for _, subscription := range subscriptions {
		delivery, sendErr := w.Sender.SendSubscription(ctx, subscription.OpenID, subscription.TemplateID, subscription.Page, data)
		if sendErr != nil {
			lastErr = sendErr
			continue
		}
		sent++
		lastProviderID = delivery.ProviderMessageID
		_, _ = w.Pool.Exec(ctx, `
			UPDATE breeder_wechat_subscription
			SET last_sent_at=$3, version=version+1, updated_at=now()
			WHERE account_id=$1 AND id=$2
		`, event.AccountID, subscription.ID, delivery.SentAt)
	}
	if sent == 0 {
		if lastErr == nil {
			lastErr = errors.New("all accepted subscription deliveries failed")
		}
		return w.fail(ctx, event, lastErr)
	}
	if lastErr != nil {
		return w.fail(ctx, event, fmt.Errorf("partial subscription delivery: %w", lastErr))
	}
	return w.finish(ctx, event, lastProviderID)
}

func (w *SubscriptionWorker) acceptedSubscriptions(ctx context.Context, accountID uuid.UUID, eventType string) ([]acceptedSubscription, error) {
	query := `
		SELECT s.id, s.openid, s.template_id, COALESCE(s.page, '')
		FROM breeder_wechat_subscription s
		JOIN breeder_wechat_identity i
		  ON i.account_id=s.account_id AND i.openid=s.openid AND i.revoked_at IS NULL
		WHERE s.account_id=$1 AND s.status='accept'
	`
	args := []any{accountID}
	if templateID := w.templateIDForEvent(eventType); templateID != "" {
		query += ` AND s.template_id=$2`
		args = append(args, templateID)
	}
	query += ` ORDER BY s.updated_at DESC, s.id`
	rows, err := w.Pool.Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	result := make([]acceptedSubscription, 0)
	for rows.Next() {
		var item acceptedSubscription
		if err := rows.Scan(&item.ID, &item.OpenID, &item.TemplateID, &item.Page); err != nil {
			return nil, err
		}
		result = append(result, item)
	}
	return result, rows.Err()
}

func (w *SubscriptionWorker) templateIDForEvent(eventType string) string {
	switch eventType {
	case "task_reminder":
		return strings.TrimSpace(w.TaskTemplateID)
	case "reservation_status":
		return strings.TrimSpace(w.ReservationTemplateID)
	default:
		return ""
	}
}

func (w *SubscriptionWorker) finish(ctx context.Context, event subscriptionEvent, providerID string) error {
	_, err := w.Pool.Exec(ctx, `
		UPDATE breeder_wechat_subscription_event
		SET status='succeeded', delivered_at=now(), provider_message_id=$3,
			locked_at=NULL, locked_by=NULL, last_error=NULL, version=version+1, updated_at=now()
		WHERE id=$1 AND account_id=$2 AND status='sending' AND locked_by=$4
	`, event.ID, event.AccountID, providerID, w.ID)
	return err
}

func (w *SubscriptionWorker) cancel(ctx context.Context, event subscriptionEvent, reason string) error {
	_, err := w.Pool.Exec(ctx, `
		UPDATE breeder_wechat_subscription_event
		SET status='cancelled', locked_at=NULL, locked_by=NULL, last_error=$3,
			version=version+1, updated_at=now()
		WHERE id=$1 AND account_id=$2 AND status='sending' AND locked_by=$4
	`, event.ID, event.AccountID, reason, w.ID)
	return err
}

func (w *SubscriptionWorker) fail(ctx context.Context, event subscriptionEvent, cause error) error {
	_, err := w.Pool.Exec(ctx, `
		UPDATE breeder_wechat_subscription_event
		SET status='failed', next_attempt_at=now()+make_interval(mins => LEAST(60, attempt_count * 5)),
			locked_at=NULL, locked_by=NULL, last_error=$3, version=version+1, updated_at=now()
		WHERE id=$1 AND account_id=$2 AND status='sending' AND locked_by=$4
	`, event.ID, event.AccountID, cause.Error(), w.ID)
	if err != nil {
		return fmt.Errorf("record subscription delivery failure: %w", err)
	}
	return cause
}

func subscriptionEventData(eventType string, raw []byte) (map[string]string, error) {
	var payload map[string]any
	if err := json.Unmarshal(raw, &payload); err != nil {
		return nil, fmt.Errorf("decode subscription event payload: %w", err)
	}
	title := limitSubscriptionValue(subscriptionStringValue(payload["title"]), 20)
	if title == "" {
		title = "ScolvPet 业务提醒"
	}
	switch eventType {
	case "task_reminder":
		scheduledAt := subscriptionStringValue(payload["scheduled_at"])
		description := limitSubscriptionValue(subscriptionStringValue(payload["description"]), 20)
		if description == "" {
			description = "请打开小程序处理"
		}
		return map[string]string{"thing1": title, "time2": scheduledAt, "thing3": description}, nil
	case "reservation_status":
		status := reservationStatusLabel(subscriptionStringValue(payload["status"]))
		updatedAt := subscriptionStringValue(payload["updated_at"])
		return map[string]string{"thing1": title, "phrase2": status, "time3": updatedAt}, nil
	default:
		return nil, fmt.Errorf("unsupported subscription event type %q", eventType)
	}
}

func subscriptionStringValue(value any) string {
	if value == nil {
		return ""
	}
	return strings.TrimSpace(fmt.Sprint(value))
}

func limitSubscriptionValue(value string, max int) string {
	runes := []rune(strings.TrimSpace(value))
	if len(runes) <= max {
		return string(runes)
	}
	return string(runes[:max])
}

func reservationStatusLabel(status string) string {
	switch strings.TrimSpace(status) {
	case "confirmed":
		return "已确认"
	case "cancelled":
		return "已取消"
	case "held":
		return "待确认"
	case "handed_over":
		return "已交付"
	default:
		return limitSubscriptionValue(status, 20)
	}
}
