package store

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/scolvpet/scolvpet/api/internal/domain"
)

var (
	ErrNotFound                   = errors.New("resource not found")
	ErrIdempotencyKeyRequired     = errors.New("idempotency key required")
	ErrIdempotencyPayloadMismatch = errors.New("idempotency payload mismatch")
	ErrIdempotencyInProgress      = errors.New("idempotency request in progress")
	ErrDuplicate                  = errors.New("duplicate resource")
	ErrUniqueViolation            = errors.New("unique constraint violation")
)

// VersionError 携带冲突时的期望版本号,是 ErrVersionConflict 的类型化形态。
// 产出端返回 *VersionError；消费端用 errors.Is / Version() 读 current，
// 不再走 "%w: current=" 字符串嗅探。
type VersionError struct{ Current int }

func (e *VersionError) Error() string {
	return fmt.Sprintf("version conflict: current=%d", e.Current)
}

// Version 返回冲突时的期望版本号,供消费端读取 typed 字段。
func (e *VersionError) Version() int { return e.Current }

// Is 让任意 *VersionError 与哨兵 ErrVersionConflict 互相视为同一错误,
// 兼容新旧两种产出形式。
func (e *VersionError) Is(target error) bool {
	_, ok := target.(*VersionError)
	return ok
}

// ErrVersionConflict 是版本冲突哨兵。在 P1 改造完成前,现有产出端仍以本
// 哨兵作为 %w 参数;之后将改为填充 Current 的 *VersionError。
var ErrVersionConflict = &VersionError{}

// MapPostgresError 将 pgconn.PgError 的唯一约束冲突(SQLSTATE 23505)与
// 排他约束冲突(23P01)统一包装为 ErrUniqueViolation,其余错误原样返回。
// 这是 store 层唯一键冲突的最小映射入口,供 httpapi 层收口时消费。
func MapPostgresError(err error) error {
	if err == nil {
		return nil
	}
	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) {
		switch pgErr.Code {
		case "23505", "23P01":
			return fmt.Errorf("%w: %s", ErrUniqueViolation, pgErr.Message)
		}
	}
	return err
}

type Store struct {
	Pool *pgxpool.Pool
}

type IdempotentResult struct {
	Status   int
	Body     []byte
	Headers  map[string]string
	Replayed bool
}

type IdempotentFn func(context.Context, pgx.Tx) (status int, body any, headers map[string]string, err error)

type storedResponse struct {
	Body    json.RawMessage   `json:"body"`
	Headers map[string]string `json:"headers,omitempty"`
}

type OrganizationUpdate struct {
	Name     *string `json:"name,omitempty"`
	Mode     *string `json:"mode,omitempty"`
	Timezone *string `json:"timezone,omitempty"`
}

type RuleCopyRequest struct {
	SourceTemplateID            *uuid.UUID     `json:"source_template_id"`
	SpeciesCode                 string         `json:"species_code"`
	VarietyScope                []string       `json:"variety_scope"`
	GestationMinDays            int            `json:"gestation_min_days"`
	GestationMaxDays            int            `json:"gestation_max_days"`
	PairingMaxMinutes           *int           `json:"pairing_max_minutes"`
	WeaningTargetDays           int            `json:"weaning_target_days"`
	SexingTargetDays            int            `json:"sexing_target_days"`
	SeparationTargetDays        int            `json:"separation_target_days"`
	PostBreedingRestDays        *int           `json:"post_breeding_rest_days"`
	ProfileCreationDeadlineDays *int           `json:"profile_creation_deadline_days"`
	WeightReference             map[string]any `json:"weight_reference"`
	SourceNote                  string         `json:"source_note"`
	EffectiveAt                 time.Time      `json:"effective_at"`
}

type SessionData struct {
	Account      domain.Account      `json:"account"`
	Organization domain.Organization `json:"current_organization"`
	OwnerID      uuid.UUID           `json:"-"`
}

func New(pool *pgxpool.Pool) *Store {
	return &Store{Pool: pool}
}

func (s *Store) Ping(ctx context.Context) error {
	return s.Pool.Ping(ctx)
}

// CleanupExpiredAuthArtifacts deletes rows that only had a replay/limit
// window: expired idempotency records (member + public) and rate-limit
// buckets whose window closed long ago. Without this the three tables grow
// without bound (docs/31 §5.12).
func (s *Store) CleanupExpiredAuthArtifacts(ctx context.Context) (int64, error) {
	var total int64
	for _, query := range []string{
		`DELETE FROM idempotency_record WHERE expires_at IS NOT NULL AND expires_at <= now()`,
		`DELETE FROM auth_public_idempotency WHERE expires_at <= now()`,
		`DELETE FROM auth_rate_limit WHERE window_started_at <= now() - interval '48 hours'`,
		`DELETE FROM revoked_token WHERE expires_at <= now()`,
	} {
		tag, err := s.Pool.Exec(ctx, query)
		if err != nil {
			return total, err
		}
		total += tag.RowsAffected()
	}
	return total, nil
}

func (s *Store) EnsureAccount(ctx context.Context, phone string) (domain.Account, uuid.UUID, error) {
	var account domain.Account
	var ownerID uuid.UUID
	var country, number string
	var displayName *string
	err := s.Pool.QueryRow(ctx, `
		INSERT INTO account (phone_country_code, phone_number, display_name)
		VALUES ($1, $2, $3)
		ON CONFLICT (phone_country_code, phone_number) WHERE deleted_at IS NULL
		DO UPDATE SET updated_at = now()
		RETURNING id, phone_country_code, phone_number, display_name
	`, "+86", strings.TrimPrefix(phone, "+86"), nil).Scan(&ownerID, &country, &number, &displayName)
	if err != nil {
		return domain.Account{}, uuid.Nil, err
	}
	account = accountView(ownerID, country, number, displayName)
	return account, ownerID, nil
}

// FindAccountByPhone looks up an existing account without creating one.
func (s *Store) FindAccountByPhone(ctx context.Context, phone string) (domain.Account, uuid.UUID, bool, error) {
	var ownerID uuid.UUID
	var country, number string
	var displayName *string
	err := s.Pool.QueryRow(ctx, `
		SELECT id, phone_country_code, phone_number, display_name
		FROM account
		WHERE phone_country_code=$1 AND phone_number=$2 AND deleted_at IS NULL
	`, "+86", strings.TrimPrefix(phone, "+86")).Scan(&ownerID, &country, &number, &displayName)
	if errors.Is(err, pgx.ErrNoRows) {
		return domain.Account{}, uuid.Nil, false, nil
	}
	if err != nil {
		return domain.Account{}, uuid.Nil, false, err
	}
	return accountView(ownerID, country, number, displayName), ownerID, true, nil
}

func (s *Store) GetAccount(ctx context.Context, ownerID uuid.UUID) (domain.Account, error) {
	var country, number string
	var displayName *string
	var id uuid.UUID
	err := s.Pool.QueryRow(ctx, `
		SELECT id, phone_country_code, phone_number, display_name
		FROM account WHERE id=$1 AND deleted_at IS NULL
	`, ownerID).Scan(&id, &country, &number, &displayName)
	if errors.Is(err, pgx.ErrNoRows) {
		return domain.Account{}, ErrNotFound
	}
	if err != nil {
		return domain.Account{}, err
	}
	return accountView(id, country, number, displayName), nil
}

func (s *Store) EnsureOrganization(ctx context.Context, ownerID uuid.UUID) (domain.Organization, error) {
	tx, err := s.Pool.Begin(ctx)
	if err != nil {
		return domain.Organization{}, err
	}
	org, err := ensureOrganizationTx(ctx, tx, ownerID)
	if err != nil {
		_ = tx.Rollback(ctx)
		return domain.Organization{}, err
	}
	if err := tx.Commit(ctx); err != nil {
		return domain.Organization{}, err
	}
	return org, nil
}

func EnsureOrganizationTx(ctx context.Context, tx pgx.Tx, ownerID uuid.UUID) (domain.Organization, error) {
	return ensureOrganizationTx(ctx, tx, ownerID)
}

func (s *Store) GetCurrentOrganization(ctx context.Context, ownerID uuid.UUID) (domain.Organization, error) {
	return getOrganization(ctx, s.Pool, ownerID)
}

func (s *Store) RunIdempotent(ctx context.Context, ownerID uuid.UUID, key, method, path string, payload []byte, fn IdempotentFn) (IdempotentResult, error) {
	if strings.TrimSpace(key) == "" {
		return IdempotentResult{}, ErrIdempotencyKeyRequired
	}
	hash := sha256.Sum256([]byte(canonicalRequest(method, path, payload)))
	hashHex := hex.EncodeToString(hash[:])
	tx, err := s.Pool.Begin(ctx)
	if err != nil {
		return IdempotentResult{}, err
	}
	defer func() { _ = tx.Rollback(ctx) }()

	var existingHash, status string
	var responseStatus *int
	var responseBody []byte
	var expired bool
	err = tx.QueryRow(ctx, `
		SELECT request_hash, status, response_status, response_body, expires_at <= now()
		FROM idempotency_record
		WHERE owner_id=$1 AND idempotency_key=$2
		FOR UPDATE
	`, ownerID, key).Scan(&existingHash, &status, &responseStatus, &responseBody, &expired)
	reclaimed := false
	switch {
	case err == nil && !expired:
		if existingHash != hashHex {
			return IdempotentResult{}, ErrIdempotencyPayloadMismatch
		}
		if status == "processing" {
			return IdempotentResult{}, ErrIdempotencyInProgress
		}
		if responseStatus == nil || responseBody == nil {
			return IdempotentResult{}, ErrIdempotencyInProgress
		}
		if err := tx.Commit(ctx); err != nil {
			return IdempotentResult{}, err
		}
		body, headers := decodeStoredResponse(responseBody)
		return IdempotentResult{Status: *responseStatus, Body: body, Headers: headers, Replayed: true}, nil
	case err == nil:
		// Past its retention window the stored response is no longer a valid
		// replay source, so the key starts a fresh attempt instead.
		if _, execErr := tx.Exec(ctx, `
			UPDATE idempotency_record
			SET request_method=$3, request_path=$4, request_hash=$5, status='processing',
				response_status=NULL, response_body=NULL, completed_at=NULL,
				locked_at=now(), expires_at=now()+interval '24 hours', updated_at=now()
			WHERE owner_id=$1 AND idempotency_key=$2
		`, ownerID, key, method, path, hashHex); execErr != nil {
			return IdempotentResult{}, execErr
		}
		reclaimed = true
	case !errors.Is(err, pgx.ErrNoRows):
		return IdempotentResult{}, err
	}

	if !reclaimed {
		_, err = tx.Exec(ctx, `
			INSERT INTO idempotency_record
			(owner_id, idempotency_key, request_method, request_path, request_hash, status, expires_at)
			VALUES ($1,$2,$3,$4,$5,'processing',now()+interval '24 hours')
		`, ownerID, key, method, path, hashHex)
		if err != nil {
			var pgErr *pgconn.PgError
			if errors.As(err, &pgErr) && pgErr.Code == "23505" {
				return IdempotentResult{}, ErrIdempotencyInProgress
			}
			return IdempotentResult{}, err
		}
	}

	statusCode, body, headers, err := fn(ctx, tx)
	if err != nil {
		return IdempotentResult{}, err
	}
	bodyBytes, err := json.Marshal(body)
	if err != nil {
		return IdempotentResult{}, err
	}
	storedBytes, err := json.Marshal(storedResponse{Body: bodyBytes, Headers: headers})
	if err != nil {
		return IdempotentResult{}, err
	}
	_, err = tx.Exec(ctx, `
		UPDATE idempotency_record
		SET status='completed', response_status=$3, response_body=$4, completed_at=now(), updated_at=now()
		WHERE owner_id=$1 AND idempotency_key=$2
	`, ownerID, key, statusCode, storedBytes)
	if err != nil {
		return IdempotentResult{}, err
	}
	if err := tx.Commit(ctx); err != nil {
		return IdempotentResult{}, err
	}
	return IdempotentResult{Status: statusCode, Body: bodyBytes, Headers: headers}, nil
}

func (s *Store) UpdateOrganization(ctx context.Context, ownerID uuid.UUID, key, ifMatch string, payload []byte, update OrganizationUpdate, makeBody func(domain.Organization) any, requestPath string) (IdempotentResult, error) {
	return s.RunIdempotent(ctx, ownerID, key, "PATCH", requestPath, payload, func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
		org, err := getOrganization(ctx, tx, ownerID)
		if err != nil {
			return 0, nil, nil, err
		}
		version, err := ParseETag(ifMatch)
		if err != nil || version != org.Version {
			return 0, nil, nil, &VersionError{Current: org.Version}
		}
		name, mode, timezone := org.Name, org.Mode, org.Timezone
		if update.Name != nil {
			name = strings.TrimSpace(*update.Name)
		}
		if update.Mode != nil {
			mode = *update.Mode
		}
		if update.Timezone != nil {
			timezone = *update.Timezone
		}
		updated, err := updateOrganizationTx(ctx, tx, ownerID, org.ID, version, name, mode, timezone)
		if err != nil {
			return 0, nil, nil, err
		}
		if err := appendEvent(ctx, tx, ownerID, uuid.MustParse(updated.ID), "organization", uuid.MustParse(updated.ID), "ORGANIZATION_UPDATED", map[string]any{"name": updated.Name, "mode": updated.Mode, "timezone": updated.Timezone}, key); err != nil {
			return 0, nil, nil, err
		}
		return 200, makeBody(updated), map[string]string{"ETag": FormatETag(updated.Version)}, nil
	})
}

func (s *Store) ListRules(ctx context.Context, ownerID *uuid.UUID) ([]domain.SpeciesRuleVersion, error) {
	query := `
		SELECT id, owner_id, scope, copied_from_id, species_code, variety_scope,
		       display_name, version_no, gestation_min_days, gestation_max_days,
		       pairing_max_minutes, weaning_target_days, sexing_target_days,
		       separation_target_days, post_breeding_rest_days,
		       profile_creation_deadline_days, weight_reference, source_note,
		       version, effective_at, (status='published')
		FROM species_rule_version
		WHERE scope='system'
	`
	args := []any{}
	if ownerID != nil {
		query = `
			SELECT id, owner_id, scope, copied_from_id, species_code, variety_scope,
			       display_name, version_no, gestation_min_days, gestation_max_days,
			       pairing_max_minutes, weaning_target_days, sexing_target_days,
			       separation_target_days, post_breeding_rest_days,
			       profile_creation_deadline_days, weight_reference, source_note,
			       version, effective_at, (status='published')
			FROM species_rule_version
			WHERE scope='owner' AND owner_id=$1
		`
		args = append(args, *ownerID)
	}
	query += ` ORDER BY species_code, version_no`
	rows, err := s.Pool.Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanRules(rows)
}

func (s *Store) GetRule(ctx context.Context, ownerID, ruleID uuid.UUID) (domain.SpeciesRuleVersion, error) {
	row := s.Pool.QueryRow(ctx, `
		SELECT id, owner_id, scope, copied_from_id, species_code, variety_scope,
		       display_name, version_no, gestation_min_days, gestation_max_days,
		       pairing_max_minutes, weaning_target_days, sexing_target_days,
		       separation_target_days, post_breeding_rest_days,
		       profile_creation_deadline_days, weight_reference, source_note,
		       version, effective_at, (status='published')
		FROM species_rule_version
		WHERE id=$1 AND (scope='system' OR (scope='owner' AND owner_id=$2))
	`, ruleID, ownerID)
	rule, err := scanRule(row)
	if errors.Is(err, pgx.ErrNoRows) {
		return domain.SpeciesRuleVersion{}, ErrNotFound
	}
	return rule, err
}

func (s *Store) CopyRule(ctx context.Context, ownerID uuid.UUID, key string, request RuleCopyRequest, payload []byte, makeBody func(domain.SpeciesRuleVersion) any, requestPath string) (IdempotentResult, error) {
	return s.RunIdempotent(ctx, ownerID, key, "POST", requestPath, payload, func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
		org, err := ensureOrganizationTx(ctx, tx, ownerID)
		if err != nil {
			return 0, nil, nil, err
		}
		var templateID uuid.UUID
		if request.SourceTemplateID != nil {
			templateID = *request.SourceTemplateID
		} else {
			err = tx.QueryRow(ctx, `SELECT id FROM species_rule_version WHERE scope='system' AND status='published' ORDER BY species_code, version_no LIMIT 1`).Scan(&templateID)
			if err != nil {
				return 0, nil, nil, err
			}
		}
		var template domain.SpeciesRuleVersion
		row := tx.QueryRow(ctx, `
			SELECT id, owner_id, scope, copied_from_id, species_code, variety_scope,
			       display_name, version_no, gestation_min_days, gestation_max_days,
			       pairing_max_minutes, weaning_target_days, sexing_target_days,
			       separation_target_days, post_breeding_rest_days,
			       profile_creation_deadline_days, weight_reference, source_note,
			       version, effective_at, (status='published')
			FROM species_rule_version WHERE id=$1 AND scope='system'
		`, templateID)
		template, err = scanRule(row)
		if errors.Is(err, pgx.ErrNoRows) {
			return 0, nil, nil, ErrNotFound
		}
		if err != nil {
			return 0, nil, nil, err
		}
		request = mergeRuleCopyDefaults(request, template)
		var ruleID uuid.UUID
		var versionNo int
		err = tx.QueryRow(ctx, `
			SELECT COALESCE(max(version_no),0)+1 FROM species_rule_version
			WHERE owner_id=$1 AND species_code=$2
		`, ownerID, request.SpeciesCode).Scan(&versionNo)
		if err != nil {
			return 0, nil, nil, err
		}
		checksum := sha256.Sum256([]byte(fmt.Sprintf("%s:%s:%d", ownerID, request.SpeciesCode, versionNo)))
		err = tx.QueryRow(ctx, `
			INSERT INTO species_rule_version (
				owner_id, scope, copied_from_id, species_code, variety_scope, display_name,
				version_no, status, gestation_min_days, gestation_max_days, pairing_max_minutes,
				weaning_target_days, sexing_target_days, separation_target_days,
				post_breeding_rest_days, profile_creation_deadline_days, weight_reference,
				reminder_rules, source_note, checksum, effective_at, created_by, updated_by
			) VALUES ($1,'owner',$2,$3,$4,$5,$6,'published',$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1,$1)
			RETURNING id
		`, ownerID, templateID, request.SpeciesCode, toJSON(request.VarietyScope), template.DisplayName,
			versionNo, request.GestationMinDays, request.GestationMaxDays, request.PairingMaxMinutes,
			request.WeaningTargetDays, request.SexingTargetDays, request.SeparationTargetDays,
			request.PostBreedingRestDays, request.ProfileCreationDeadlineDays, toJSON(request.WeightReference),
			toJSON(map[string]any{"pairing_timeout": true}), request.SourceNote, hex.EncodeToString(checksum[:]), request.EffectiveAt).Scan(&ruleID)
		if err != nil {
			return 0, nil, nil, err
		}
		if err := appendEvent(ctx, tx, ownerID, orgID(org.ID), "species_rule_version", ruleID, "SPECIES_RULE_VERSION_CREATED", map[string]any{"source_template_id": templateID, "version_no": versionNo}, key); err != nil {
			return 0, nil, nil, err
		}
		created, err := scanRule(tx.QueryRow(ctx, `
			SELECT id, owner_id, scope, copied_from_id, species_code, variety_scope,
			       display_name, version_no, gestation_min_days, gestation_max_days,
			       pairing_max_minutes, weaning_target_days, sexing_target_days,
			       separation_target_days, post_breeding_rest_days,
			       profile_creation_deadline_days, weight_reference, source_note,
			       version, effective_at, (status='published')
			FROM species_rule_version WHERE id=$1
		`, ruleID))
		if err != nil {
			return 0, nil, nil, err
		}
		return 201, makeBody(created), map[string]string{"ETag": FormatETag(created.Version), "Location": "/v1/species-rule-versions/" + created.ID}, nil
	})
}

func ensureOrganizationTx(ctx context.Context, tx pgx.Tx, ownerID uuid.UUID) (domain.Organization, error) {
	org, err := getOrganization(ctx, tx, ownerID)
	if err == nil {
		return org, nil
	}
	if !errors.Is(err, ErrNotFound) {
		return domain.Organization{}, err
	}
	code := "owner-" + strings.ReplaceAll(ownerID.String()[:8], "-", "")
	var id uuid.UUID
	err = tx.QueryRow(ctx, `
		INSERT INTO organization (owner_id, code, name, mode, timezone, weight_unit, created_by, updated_by)
		VALUES ($1,$2,'我的熊舍','personal','Asia/Shanghai','g',$1,$1)
		RETURNING id
	`, ownerID, code).Scan(&id)
	if err != nil {
		return domain.Organization{}, err
	}
	org, err = getOrganization(ctx, tx, ownerID)
	if err != nil {
		return domain.Organization{}, err
	}
	if err := appendEvent(ctx, tx, ownerID, id, "organization", id, "ORGANIZATION_CREATED", map[string]any{"name": org.Name}, "organization-provision"); err != nil {
		return domain.Organization{}, err
	}
	return org, nil
}

func getOrganization(ctx context.Context, q interface {
	QueryRow(context.Context, string, ...any) pgx.Row
}, ownerID uuid.UUID) (domain.Organization, error) {
	var org domain.Organization
	var id, owner uuid.UUID
	err := q.QueryRow(ctx, `
		SELECT id, owner_id, name, mode, timezone, weight_unit, version, created_at, updated_at
		FROM organization WHERE owner_id=$1 AND deleted_at IS NULL ORDER BY created_at LIMIT 1
	`, ownerID).Scan(&id, &owner, &org.Name, &org.Mode, &org.Timezone, &org.WeightUnit, &org.Version, &org.CreatedAt, &org.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return domain.Organization{}, ErrNotFound
	}
	if err != nil {
		return domain.Organization{}, err
	}
	org.ID, org.OwnerID = id.String(), owner.String()
	return org, nil
}

func updateOrganizationTx(ctx context.Context, tx pgx.Tx, ownerID uuid.UUID, organizationID string, version int, name, mode, timezone string) (domain.Organization, error) {
	var org domain.Organization
	var id, owner uuid.UUID
	err := tx.QueryRow(ctx, `
		UPDATE organization
		SET name=$4, mode=$5, timezone=$6, updated_by=$1
		WHERE owner_id=$1 AND id=$2 AND version=$3 AND deleted_at IS NULL
		RETURNING id, owner_id, name, mode, timezone, weight_unit, version, created_at, updated_at
	`, ownerID, uuid.MustParse(organizationID), version, name, mode, timezone).Scan(&id, &owner, &org.Name, &org.Mode, &org.Timezone, &org.WeightUnit, &org.Version, &org.CreatedAt, &org.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return domain.Organization{}, ErrVersionConflict
	}
	if err != nil {
		return domain.Organization{}, err
	}
	org.ID, org.OwnerID = id.String(), owner.String()
	return org, nil
}

func appendEvent(ctx context.Context, tx pgx.Tx, ownerID, organizationID uuid.UUID, aggregateType string, aggregateID uuid.UUID, eventType string, payload map[string]any, idempotencyKey string) error {
	var version int
	if err := tx.QueryRow(ctx, `
		SELECT COALESCE(max(event_version),0)+1 FROM domain_event
		WHERE owner_id=$1 AND aggregate_type=$2 AND aggregate_id=$3
	`, ownerID, aggregateType, aggregateID).Scan(&version); err != nil {
		return err
	}
	var eventID uuid.UUID
	if err := tx.QueryRow(ctx, `
		INSERT INTO domain_event (owner_id, organization_id, aggregate_type, aggregate_id, event_type, event_version, actor_id, occurred_at, payload, idempotency_key)
		VALUES ($1,$2,$3,$4,$5,$6,$1,now(),$7,$8)
		RETURNING id
	`, ownerID, organizationID, aggregateType, aggregateID, eventType, version, toJSON(payload), idempotencyKey).Scan(&eventID); err != nil {
		return err
	}
	_, err := tx.Exec(ctx, `
		INSERT INTO outbox_message (owner_id, domain_event_id, topic, partition_key, payload)
		VALUES ($1,$2,$3,$4,$5)
	`, ownerID, eventID, "domain."+strings.ToLower(aggregateType), aggregateID.String(), toJSON(map[string]any{
		"event_id": eventID, "event_type": eventType, "aggregate_type": aggregateType, "aggregate_id": aggregateID,
		"payload": payload,
	}))
	return err
}

func scanRules(rows pgx.Rows) ([]domain.SpeciesRuleVersion, error) {
	result := make([]domain.SpeciesRuleVersion, 0)
	for rows.Next() {
		rule, err := scanRule(rows)
		if err != nil {
			return nil, err
		}
		result = append(result, rule)
	}
	return result, rows.Err()
}

func scanRule(row pgx.Row) (domain.SpeciesRuleVersion, error) {
	var rule domain.SpeciesRuleVersion
	var id uuid.UUID
	var ownerID, copiedFromID *uuid.UUID
	var varietyJSON, weightJSON []byte
	var versionNo int
	var statusPublished bool
	err := row.Scan(&id, &ownerID, &rule.Scope, &copiedFromID, &rule.SpeciesCode, &varietyJSON,
		&rule.DisplayName, &versionNo, &rule.GestationMinDays, &rule.GestationMaxDays,
		&rule.PairingMaxMinutes, &rule.WeaningTargetDays, &rule.SexingTargetDays,
		&rule.SeparationTargetDays, &rule.PostBreedingRestDays, &rule.ProfileCreationDeadlineDays,
		&weightJSON, &rule.SourceNote, &rule.Version, &rule.EffectiveAt, &statusPublished)
	if err != nil {
		return rule, err
	}
	rule.ID = id.String()
	rule.OwnerID = uuidPtrString(ownerID)
	rule.SourceTemplateID = uuidPtrString(copiedFromID)
	rule.VarietyScope = decodeStringArray(varietyJSON)
	rule.WeightReference = decodeObject(weightJSON)
	rule.Frozen = statusPublished
	return rule, nil
}

func mergeRuleCopyDefaults(request RuleCopyRequest, template domain.SpeciesRuleVersion) RuleCopyRequest {
	if len(request.VarietyScope) == 0 {
		request.VarietyScope = template.VarietyScope
	}
	if request.PairingMaxMinutes == nil {
		request.PairingMaxMinutes = template.PairingMaxMinutes
	}
	if request.PostBreedingRestDays == nil {
		value := template.PostBreedingRestDays
		request.PostBreedingRestDays = &value
	}
	if request.ProfileCreationDeadlineDays == nil {
		value := template.ProfileCreationDeadlineDays
		request.ProfileCreationDeadlineDays = &value
	}
	return request
}

func canonicalRequest(method, path string, payload []byte) string {
	var decoded any
	if err := json.Unmarshal(payload, &decoded); err != nil {
		decoded = strings.TrimSpace(string(payload))
	}
	normalized, err := json.Marshal(decoded)
	if err != nil {
		normalized = []byte(strings.TrimSpace(string(payload)))
	}
	return strings.ToUpper(strings.TrimSpace(method)) + "\n" + strings.TrimSpace(path) + "\n" + string(normalized)
}

func decodeStoredResponse(raw []byte) ([]byte, map[string]string) {
	var object map[string]json.RawMessage
	if json.Unmarshal(raw, &object) == nil {
		if body, ok := object["body"]; ok {
			var wrapper storedResponse
			if json.Unmarshal(raw, &wrapper) == nil {
				if wrapper.Headers == nil {
					wrapper.Headers = map[string]string{}
				}
				return body, wrapper.Headers
			}
		}
	}
	return raw, map[string]string{}
}

func accountView(id uuid.UUID, country, number string, displayName *string) domain.Account {
	masked := number
	if len(number) >= 7 {
		masked = number[:3] + "****" + number[len(number)-4:]
	}
	return domain.Account{ID: id.String(), PhoneMasked: country + masked, DisplayName: displayName}
}

func uuidPtrString(value *uuid.UUID) *string {
	if value == nil {
		return nil
	}
	result := value.String()
	return &result
}

func decodeStringArray(value []byte) []string {
	var result []string
	if len(value) > 0 {
		_ = json.Unmarshal(value, &result)
	}
	if result == nil {
		return []string{}
	}
	return result
}

func decodeObject(value []byte) map[string]any {
	result := map[string]any{}
	if len(value) > 0 {
		_ = json.Unmarshal(value, &result)
	}
	return result
}

func toJSON(value any) []byte {
	result, _ := json.Marshal(value)
	return result
}

func orgID(value string) uuid.UUID {
	return uuid.MustParse(value)
}

func ParseETag(value string) (int, error) {
	value = strings.TrimSpace(value)
	value = strings.TrimPrefix(value, "W/")
	if len(value) < 3 || value[0] != '"' || value[len(value)-1] != '"' {
		return 0, errors.New("invalid etag")
	}
	var version int
	if _, err := fmt.Sscanf(value, `"%d"`, &version); err != nil || version < 1 {
		return 0, errors.New("invalid etag")
	}
	return version, nil
}

func FormatETag(version int) string {
	return fmt.Sprintf(`"%d"`, version)
}
