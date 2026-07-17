package httpapi

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/scolvpet/scolvpet/api/internal/pushcore"
	"github.com/scolvpet/scolvpet/api/internal/store"
)

func (s *Server) registerP1PushRoutes(mux *http.ServeMux) {
	mux.HandleFunc("GET /v1/push/devices", s.listPushDevices)
	mux.HandleFunc("PUT /v1/push/devices", s.upsertPushDevice)
	mux.HandleFunc("DELETE /v1/push/devices/{device_id}", s.disablePushDevice)
	mux.HandleFunc("GET /v1/push/messages", s.listPushMessages)
	mux.HandleFunc("POST /v1/push/messages", s.createPushMessage)
}

type pushDevice struct {
	ID          uuid.UUID `json:"id"`
	Platform    string    `json:"platform"`
	Provider    string    `json:"provider"`
	Token       string    `json:"token"`
	DeviceName  *string   `json:"device_name,omitempty"`
	AppVersion  *string   `json:"app_version,omitempty"`
	Enabled     bool      `json:"enabled"`
	LastSeenAt  time.Time `json:"last_seen_at"`
	Version     int       `json:"version"`
}

type pushMessage struct {
	ID                uuid.UUID      `json:"id"`
	Title             string         `json:"title"`
	Body              string         `json:"body"`
	Data              map[string]any `json:"data"`
	Status            string         `json:"status"`
	TargetDeviceID    *uuid.UUID     `json:"target_device_id,omitempty"`
	Provider          string         `json:"provider"`
	ProviderMessageID *string        `json:"provider_message_id,omitempty"`
	AttemptCount      int            `json:"attempt_count"`
	LastError         *string        `json:"last_error,omitempty"`
	SentAt            *time.Time     `json:"sent_at,omitempty"`
	Version           int            `json:"version"`
	CreatedAt         time.Time      `json:"created_at"`
}

type upsertPushDeviceRequest struct {
	Platform   string  `json:"platform"`
	Provider   string  `json:"provider"`
	Token      string  `json:"token"`
	DeviceName *string `json:"device_name"`
	AppVersion *string `json:"app_version"`
}

type createPushMessageRequest struct {
	Title          string            `json:"title"`
	Body           string            `json:"body"`
	Data           map[string]any    `json:"data"`
	TargetDeviceID *string           `json:"target_device_id"`
	// DataString is optional flat string map for providers that need it.
	DataString map[string]string `json:"-"`
}

func (s *Server) listPushDevices(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	rows, err := s.Store.Pool.Query(r.Context(), `
		SELECT id, platform::text, provider::text, token, device_name, app_version,
			enabled, last_seen_at, version
		FROM push_device
		WHERE owner_id=$1
		ORDER BY last_seen_at DESC, id DESC
		LIMIT 100
	`, ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	defer rows.Close()
	items := make([]pushDevice, 0)
	for rows.Next() {
		var item pushDevice
		if err := rows.Scan(
			&item.ID, &item.Platform, &item.Provider, &item.Token, &item.DeviceName, &item.AppVersion,
			&item.Enabled, &item.LastSeenAt, &item.Version,
		); err != nil {
			writeAPIError(w, r, err)
			return
		}
		items = append(items, item)
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": items, "meta": responseMeta(r)})
}

func (s *Server) upsertPushDevice(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	var request upsertPushDeviceRequest
	if _, err := decodeBody(r, &request); err != nil {
		writeAPIError(w, r, validationError("body", "设备请求体格式不正确"))
		return
	}
	token := strings.TrimSpace(request.Token)
	if token == "" {
		writeAPIError(w, r, validationError("token", "推送令牌必填"))
		return
	}
	if len(token) > 512 {
		writeAPIError(w, r, validationError("token", "推送令牌过长"))
		return
	}
	platform := strings.TrimSpace(request.Platform)
	if platform == "" {
		platform = "unknown"
	}
	if !validPushPlatform(platform) {
		writeAPIError(w, r, validationError("platform", "平台无效"))
		return
	}
	provider := pushcore.SelectProvider(platform, strings.TrimSpace(request.Provider))
	// Without real credentials, force log provider for safe delivery path.
	if provider == "apns" || provider == "fcm" {
		provider = "log"
	}
	if !validPushProvider(provider) {
		writeAPIError(w, r, validationError("provider", "提供商无效"))
		return
	}
	orgID, err := s.currentOrganizationID(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	var id uuid.UUID
	err = s.Store.Pool.QueryRow(r.Context(), `
		INSERT INTO push_device (
			owner_id, organization_id, platform, provider, token, device_name, app_version,
			enabled, last_seen_at
		) VALUES ($1,$2,$3::push_platform,$4::push_provider,$5,$6,$7,true,now())
		ON CONFLICT (owner_id, token) DO UPDATE SET
			platform=EXCLUDED.platform,
			provider=EXCLUDED.provider,
			device_name=COALESCE(EXCLUDED.device_name, push_device.device_name),
			app_version=COALESCE(EXCLUDED.app_version, push_device.app_version),
			enabled=true,
			last_seen_at=now(),
			version=push_device.version+1,
			updated_at=now()
		RETURNING id
	`, ownerID, orgID, platform, provider, token, emptyToNil(request.DeviceName), emptyToNil(request.AppVersion)).Scan(&id)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	item, err := s.getPushDevice(r.Context(), ownerID, id)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": item, "meta": responseMeta(r)})
}

func (s *Server) disablePushDevice(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	deviceID, err := uuid.Parse(r.PathValue("device_id"))
	if err != nil {
		writeAPIError(w, r, validationError("device_id", "设备 ID 无效"))
		return
	}
	tag, err := s.Store.Pool.Exec(r.Context(), `
		UPDATE push_device
		SET enabled=false, version=version+1, updated_at=now()
		WHERE owner_id=$1 AND id=$2
	`, ownerID, deviceID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	if tag.RowsAffected() == 0 {
		writeAPIError(w, r, store.ErrNotFound)
		return
	}
	item, err := s.getPushDevice(r.Context(), ownerID, deviceID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": item, "meta": responseMeta(r)})
}

func (s *Server) listPushMessages(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	rows, err := s.Store.Pool.Query(r.Context(), `
		SELECT id, title, body, data, status::text, target_device_id, provider::text,
			provider_message_id, attempt_count, last_error, sent_at, version, created_at
		FROM push_message
		WHERE owner_id=$1
		ORDER BY created_at DESC, id DESC
		LIMIT 100
	`, ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	defer rows.Close()
	items := make([]pushMessage, 0)
	for rows.Next() {
		item, err := scanPushMessage(rows)
		if err != nil {
			writeAPIError(w, r, err)
			return
		}
		items = append(items, item)
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": items, "meta": responseMeta(r)})
}

func (s *Server) createPushMessage(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	var request createPushMessageRequest
	if _, err := decodeBody(r, &request); err != nil {
		writeAPIError(w, r, validationError("body", "推送请求体格式不正确"))
		return
	}
	title := strings.TrimSpace(request.Title)
	body := strings.TrimSpace(request.Body)
	if title == "" {
		writeAPIError(w, r, validationError("title", "标题必填"))
		return
	}
	if body == "" {
		writeAPIError(w, r, validationError("body", "正文必填"))
		return
	}
	data := request.Data
	if data == nil {
		data = map[string]any{}
	}
	var targetDeviceID *uuid.UUID
	if request.TargetDeviceID != nil && strings.TrimSpace(*request.TargetDeviceID) != "" {
		id, err := uuid.Parse(strings.TrimSpace(*request.TargetDeviceID))
		if err != nil {
			writeAPIError(w, r, validationError("target_device_id", "设备 ID 无效"))
			return
		}
		targetDeviceID = &id
	}
	orgID, err := s.currentOrganizationID(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	dataJSON, _ := json.Marshal(data)
	var id uuid.UUID
	err = s.Store.Pool.QueryRow(r.Context(), `
		INSERT INTO push_message (
			owner_id, organization_id, title, body, data, status, target_device_id, provider
		) VALUES ($1,$2,$3,$4,$5::jsonb,'queued',$6,'log')
		RETURNING id
	`, ownerID, orgID, title, body, dataJSON, targetDeviceID).Scan(&id)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	// Best-effort immediate dispatch (log provider). Failures stay as failed/queued audit trail.
	_ = s.dispatchPushMessage(r.Context(), ownerID, id)
	item, err := s.getPushMessage(r.Context(), ownerID, id)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusCreated, map[string]any{"data": item, "meta": responseMeta(r)})
}

func (s *Server) dispatchPushMessage(ctx context.Context, ownerID, messageID uuid.UUID) error {
	msg, err := s.getPushMessage(ctx, ownerID, messageID)
	if err != nil {
		return err
	}
	devices, err := s.listEnabledPushDevices(ctx, ownerID, msg.TargetDeviceID)
	if err != nil {
		return err
	}
	if len(devices) == 0 {
		_, _ = s.Store.Pool.Exec(ctx, `
			UPDATE push_message
			SET status='failed', last_error=$3, attempt_count=attempt_count+1,
				version=version+1, updated_at=now()
			WHERE owner_id=$1 AND id=$2
		`, ownerID, messageID, "no enabled push devices")
		return nil
	}
	sender := pushcore.ResolveSender(s.Logger)
	var lastErr error
	var lastProviderID string
	sentAny := false
	for _, device := range devices {
		dataStr := map[string]string{}
		for k, v := range msg.Data {
			dataStr[k] = toStringAny(v)
		}
		result, sendErr := sender.Send(ctx, pushcore.DeliveryRequest{
			OwnerID:  ownerID.String(),
			DeviceID: device.ID.String(),
			Platform: device.Platform,
			Provider: device.Provider,
			Token:    device.Token,
			Title:    msg.Title,
			Body:     msg.Body,
			Data:     dataStr,
		})
		if sendErr != nil {
			lastErr = sendErr
			continue
		}
		sentAny = true
		lastProviderID = result.ProviderMessageID
	}
	if !sentAny {
		errText := "all deliveries failed"
		if lastErr != nil {
			errText = lastErr.Error()
		}
		_, _ = s.Store.Pool.Exec(ctx, `
			UPDATE push_message
			SET status='failed', last_error=$3, attempt_count=attempt_count+1,
				version=version+1, updated_at=now()
			WHERE owner_id=$1 AND id=$2
		`, ownerID, messageID, errText)
		return lastErr
	}
	_, err = s.Store.Pool.Exec(ctx, `
		UPDATE push_message
		SET status='sent', provider_message_id=$3, sent_at=now(), attempt_count=attempt_count+1,
			last_error=NULL, version=version+1, updated_at=now()
		WHERE owner_id=$1 AND id=$2
	`, ownerID, messageID, lastProviderID)
	return err
}

func (s *Server) listEnabledPushDevices(ctx context.Context, ownerID uuid.UUID, target *uuid.UUID) ([]pushDevice, error) {
	query := `
		SELECT id, platform::text, provider::text, token, device_name, app_version,
			enabled, last_seen_at, version
		FROM push_device
		WHERE owner_id=$1 AND enabled=true
	`
	args := []any{ownerID}
	if target != nil {
		query += ` AND id=$2`
		args = append(args, *target)
	}
	query += ` ORDER BY last_seen_at DESC LIMIT 50`
	rows, err := s.Store.Pool.Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	items := make([]pushDevice, 0)
	for rows.Next() {
		var item pushDevice
		if err := rows.Scan(
			&item.ID, &item.Platform, &item.Provider, &item.Token, &item.DeviceName, &item.AppVersion,
			&item.Enabled, &item.LastSeenAt, &item.Version,
		); err != nil {
			return nil, err
		}
		items = append(items, item)
	}
	return items, nil
}

func (s *Server) getPushDevice(ctx context.Context, ownerID, id uuid.UUID) (pushDevice, error) {
	var item pushDevice
	err := s.Store.Pool.QueryRow(ctx, `
		SELECT id, platform::text, provider::text, token, device_name, app_version,
			enabled, last_seen_at, version
		FROM push_device
		WHERE owner_id=$1 AND id=$2
	`, ownerID, id).Scan(
		&item.ID, &item.Platform, &item.Provider, &item.Token, &item.DeviceName, &item.AppVersion,
		&item.Enabled, &item.LastSeenAt, &item.Version,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return pushDevice{}, store.ErrNotFound
	}
	return item, err
}

func (s *Server) getPushMessage(ctx context.Context, ownerID, id uuid.UUID) (pushMessage, error) {
	row := s.Store.Pool.QueryRow(ctx, `
		SELECT id, title, body, data, status::text, target_device_id, provider::text,
			provider_message_id, attempt_count, last_error, sent_at, version, created_at
		FROM push_message
		WHERE owner_id=$1 AND id=$2
	`, ownerID, id)
	return scanPushMessage(row)
}

type pushMessageScanner interface {
	Scan(dest ...any) error
}

func scanPushMessage(row pushMessageScanner) (pushMessage, error) {
	var item pushMessage
	var dataRaw []byte
	err := row.Scan(
		&item.ID, &item.Title, &item.Body, &dataRaw, &item.Status, &item.TargetDeviceID, &item.Provider,
		&item.ProviderMessageID, &item.AttemptCount, &item.LastError, &item.SentAt, &item.Version, &item.CreatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return pushMessage{}, store.ErrNotFound
	}
	if err != nil {
		return pushMessage{}, err
	}
	item.Data = map[string]any{}
	_ = json.Unmarshal(dataRaw, &item.Data)
	return item, nil
}

func validPushPlatform(value string) bool {
	switch value {
	case "ios", "android", "web", "unknown":
		return true
	default:
		return false
	}
}

func validPushProvider(value string) bool {
	switch value {
	case "apns", "fcm", "log":
		return true
	default:
		return false
	}
}
