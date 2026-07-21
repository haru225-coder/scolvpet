package store

import (
	"context"
	"encoding/json"
	"errors"
	"strings"
	"time"
	"unicode/utf8"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
)

// AssistantSession is a multi-turn chat thread owned by one account.
type AssistantSession struct {
	ID        uuid.UUID `json:"id"`
	OwnerID   uuid.UUID `json:"owner_id"`
	Title     string    `json:"title"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// AssistantMessage is one stored chat message.
type AssistantMessage struct {
	ID        uuid.UUID       `json:"id"`
	OwnerID   uuid.UUID       `json:"owner_id"`
	SessionID uuid.UUID       `json:"session_id"`
	Role      string          `json:"role"`
	Content   string          `json:"content"`
	Mode      *string         `json:"mode,omitempty"`
	FactsJSON json.RawMessage `json:"facts_json"`
	CreatedAt time.Time       `json:"created_at"`
}

func (s *Store) CreateAssistantSession(ctx context.Context, ownerID uuid.UUID, title string) (AssistantSession, error) {
	title = strings.TrimSpace(title)
	if utf8.RuneCountInString(title) > 200 {
		title = string([]rune(title)[:200])
	}
	var session AssistantSession
	err := s.Pool.QueryRow(ctx, `
		INSERT INTO assistant_session (owner_id, title)
		VALUES ($1, $2)
		RETURNING id, owner_id, title, created_at, updated_at
	`, ownerID, title).Scan(&session.ID, &session.OwnerID, &session.Title, &session.CreatedAt, &session.UpdatedAt)
	return session, err
}

func (s *Store) GetAssistantSession(ctx context.Context, ownerID, sessionID uuid.UUID) (AssistantSession, error) {
	var session AssistantSession
	err := s.Pool.QueryRow(ctx, `
		SELECT id, owner_id, title, created_at, updated_at
		FROM assistant_session
		WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
	`, ownerID, sessionID).Scan(&session.ID, &session.OwnerID, &session.Title, &session.CreatedAt, &session.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return AssistantSession{}, ErrNotFound
	}
	return session, err
}

func (s *Store) ListAssistantSessions(ctx context.Context, ownerID uuid.UUID, limit int) ([]AssistantSession, error) {
	if limit <= 0 || limit > 50 {
		limit = 20
	}
	rows, err := s.Pool.Query(ctx, `
		SELECT id, owner_id, title, created_at, updated_at
		FROM assistant_session
		WHERE owner_id=$1 AND deleted_at IS NULL
		ORDER BY updated_at DESC
		LIMIT $2
	`, ownerID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]AssistantSession, 0)
	for rows.Next() {
		var session AssistantSession
		if err := rows.Scan(&session.ID, &session.OwnerID, &session.Title, &session.CreatedAt, &session.UpdatedAt); err != nil {
			return nil, err
		}
		out = append(out, session)
	}
	return out, rows.Err()
}

func (s *Store) TouchAssistantSession(ctx context.Context, ownerID, sessionID uuid.UUID, title string) error {
	title = strings.TrimSpace(title)
	if title == "" {
		_, err := s.Pool.Exec(ctx, `
			UPDATE assistant_session SET updated_at=now()
			WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
		`, ownerID, sessionID)
		return err
	}
	if utf8.RuneCountInString(title) > 200 {
		title = string([]rune(title)[:200])
	}
	_, err := s.Pool.Exec(ctx, `
		UPDATE assistant_session
		SET updated_at=now(),
		    title=CASE WHEN title='' OR title IS NULL THEN $3 ELSE title END
		WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
	`, ownerID, sessionID, title)
	return err
}

func (s *Store) InsertAssistantMessage(
	ctx context.Context,
	ownerID, sessionID uuid.UUID,
	role, content string,
	mode *string,
	facts any,
) (AssistantMessage, error) {
	factsJSON, err := json.Marshal(facts)
	if err != nil || facts == nil {
		factsJSON = []byte("[]")
	}
	var msg AssistantMessage
	err = s.Pool.QueryRow(ctx, `
		INSERT INTO assistant_message (owner_id, session_id, role, content, mode, facts_json)
		VALUES ($1, $2, $3, $4, $5, $6::jsonb)
		RETURNING id, owner_id, session_id, role, content, mode, facts_json, created_at
	`, ownerID, sessionID, role, content, mode, string(factsJSON)).Scan(
		&msg.ID, &msg.OwnerID, &msg.SessionID, &msg.Role, &msg.Content, &msg.Mode, &msg.FactsJSON, &msg.CreatedAt,
	)
	return msg, err
}

func (s *Store) ListAssistantMessages(ctx context.Context, ownerID, sessionID uuid.UUID, limit int) ([]AssistantMessage, error) {
	if limit <= 0 || limit > 100 {
		limit = 40
	}
	rows, err := s.Pool.Query(ctx, `
		SELECT id, owner_id, session_id, role, content, mode, facts_json, created_at
		FROM assistant_message
		WHERE owner_id=$1 AND session_id=$2
		ORDER BY created_at DESC, id DESC
		LIMIT $3
	`, ownerID, sessionID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]AssistantMessage, 0)
	for rows.Next() {
		var msg AssistantMessage
		if err := rows.Scan(&msg.ID, &msg.OwnerID, &msg.SessionID, &msg.Role, &msg.Content, &msg.Mode, &msg.FactsJSON, &msg.CreatedAt); err != nil {
			return nil, err
		}
		out = append(out, msg)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	// Fetch the newest window, but return it in conversation order so callers
	// can feed it directly to the model or render it without reordering.
	for left, right := 0, len(out)-1; left < right; left, right = left+1, right-1 {
		out[left], out[right] = out[right], out[left]
	}
	return out, nil
}

// AssistantAction is a pending or executed write proposed by the assistant.
type AssistantAction struct {
	ID                   uuid.UUID       `json:"id"`
	OwnerID              uuid.UUID       `json:"owner_id"`
	SessionID            uuid.UUID       `json:"session_id"`
	MessageID            *uuid.UUID      `json:"message_id,omitempty"`
	Type                 string          `json:"type"`
	Label                string          `json:"label"`
	Summary              string          `json:"summary"`
	PayloadJSON          json.RawMessage `json:"payload_json"`
	RequiresConfirmation bool            `json:"requires_confirmation"`
	Status               string          `json:"status"`
	ResultJSON           json.RawMessage `json:"result_json"`
	CreatedAt            time.Time       `json:"created_at"`
	ExecutedAt           *time.Time      `json:"executed_at,omitempty"`
}

func (s *Store) InsertAssistantAction(
	ctx context.Context,
	ownerID, sessionID uuid.UUID,
	messageID *uuid.UUID,
	actionType, label, summary string,
	payload any,
	requiresConfirmation bool,
) (AssistantAction, error) {
	payloadJSON, err := json.Marshal(payload)
	if err != nil || payload == nil {
		payloadJSON = []byte("{}")
	}
	var action AssistantAction
	err = s.Pool.QueryRow(ctx, `
		INSERT INTO assistant_action (
			owner_id, session_id, message_id, type, label, summary,
			payload_json, requires_confirmation, status
		) VALUES ($1,$2,$3,$4,$5,$6,$7::jsonb,$8,'pending')
		RETURNING id, owner_id, session_id, message_id, type, label, summary,
		          payload_json, requires_confirmation, status, result_json, created_at, executed_at
	`, ownerID, sessionID, messageID, actionType, label, summary, string(payloadJSON), requiresConfirmation).Scan(
		&action.ID, &action.OwnerID, &action.SessionID, &action.MessageID,
		&action.Type, &action.Label, &action.Summary, &action.PayloadJSON,
		&action.RequiresConfirmation, &action.Status, &action.ResultJSON,
		&action.CreatedAt, &action.ExecutedAt,
	)
	return action, err
}

func (s *Store) GetAssistantAction(ctx context.Context, ownerID, actionID uuid.UUID) (AssistantAction, error) {
	var action AssistantAction
	err := s.Pool.QueryRow(ctx, `
		SELECT id, owner_id, session_id, message_id, type, label, summary,
		       payload_json, requires_confirmation, status, result_json, created_at, executed_at
		FROM assistant_action
		WHERE owner_id=$1 AND id=$2
	`, ownerID, actionID).Scan(
		&action.ID, &action.OwnerID, &action.SessionID, &action.MessageID,
		&action.Type, &action.Label, &action.Summary, &action.PayloadJSON,
		&action.RequiresConfirmation, &action.Status, &action.ResultJSON,
		&action.CreatedAt, &action.ExecutedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return AssistantAction{}, ErrNotFound
	}
	return action, err
}

func (s *Store) BindAssistantActionMessage(ctx context.Context, ownerID, sessionID, messageID uuid.UUID) error {
	_, err := s.Pool.Exec(ctx, `
		UPDATE assistant_action
		SET message_id=$3
		WHERE owner_id=$1 AND session_id=$2 AND message_id IS NULL AND status='pending'
	`, ownerID, sessionID, messageID)
	return err
}

func (s *Store) MarkAssistantAction(
	ctx context.Context,
	ownerID, actionID uuid.UUID,
	fromStatus, toStatus string,
	result any,
) (AssistantAction, error) {
	resultJSON, err := json.Marshal(result)
	if err != nil || result == nil {
		resultJSON = []byte("{}")
	}
	setExecuted := toStatus == "executed" || toStatus == "failed"
	tag, err := s.Pool.Exec(ctx, `
		UPDATE assistant_action
		SET status=$4,
		    result_json=$5::jsonb,
		    executed_at=CASE WHEN $6::bool THEN now() ELSE executed_at END
		WHERE owner_id=$1 AND id=$2 AND status=$3
	`, ownerID, actionID, fromStatus, toStatus, resultJSON, setExecuted)
	if err != nil {
		return AssistantAction{}, err
	}
	if tag.RowsAffected() == 0 {
		return AssistantAction{}, ErrNotFound
	}
	return s.GetAssistantAction(ctx, ownerID, actionID)
}

// ClaimAssistantAction atomically moves a pending action into the in-flight
// confirmed state. This closes the concurrent double-confirm window before the
// underlying business write is executed.
func (s *Store) ClaimAssistantAction(ctx context.Context, ownerID, actionID uuid.UUID) (AssistantAction, error) {
	var action AssistantAction
	err := s.Pool.QueryRow(ctx, `
		UPDATE assistant_action
		SET status='confirmed'
		WHERE owner_id=$1 AND id=$2 AND status='pending'
		RETURNING id, owner_id, session_id, message_id, type, label, summary,
		          payload_json, requires_confirmation, status, result_json, created_at, executed_at
	`, ownerID, actionID).Scan(
		&action.ID, &action.OwnerID, &action.SessionID, &action.MessageID,
		&action.Type, &action.Label, &action.Summary, &action.PayloadJSON,
		&action.RequiresConfirmation, &action.Status, &action.ResultJSON,
		&action.CreatedAt, &action.ExecutedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return AssistantAction{}, ErrNotFound
	}
	return action, err
}
