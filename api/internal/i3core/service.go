package i3core

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/scolvpet/scolvpet/api/internal/store"
)

type Service struct {
	pool *pgxpool.Pool
}

func NewService(source *store.Store) *Service {
	if source == nil {
		return &Service{}
	}
	return &Service{pool: source.Pool}
}

type rowScanner interface {
	Scan(dest ...any) error
}

const planSelect = `
	SELECT p.id, p.owner_id, p.organization_id, p.name, p.sire_id, p.dam_id,
		p.species_rule_version_id, p.state::text, p.planned_pairing_at,
		p.planned_pairing_enclosure_id, p.mating_baseline_at,
		p.expected_birth_start, p.expected_birth_end, p.actual_birth_at,
		p.objective_traits, p.kinship_check, p.eligibility_override_reason,
		p.notes, p.version, p.created_at, p.updated_at,
		(SELECT pa.id FROM pairing_attempt pa
		 WHERE pa.owner_id=p.owner_id AND pa.breeding_plan_id=p.id
		   AND pa.status IN ('active', 'safety_hold') AND pa.deleted_at IS NULL
		 ORDER BY pa.attempt_no DESC LIMIT 1),
		(SELECT l.id FROM litter l
		 WHERE l.owner_id=p.owner_id AND l.breeding_plan_id=p.id
		   AND l.state <> 'voided' AND l.deleted_at IS NULL
		 ORDER BY l.created_at DESC LIMIT 1)
	FROM breeding_plan p`

const attemptSelect = `
	SELECT id, owner_id, breeding_plan_id, attempt_no, sire_id, dam_id,
		pairing_enclosure_id, started_at, ended_at, separated_at,
		separation_deadline, status::text, result::text, conflict_level::text,
		sire_destination_enclosure_id, dam_destination_enclosure_id, notes,
		version, created_at, updated_at
	FROM pairing_attempt`

func (s *Service) ListPlans(ctx context.Context, ownerID uuid.UUID, filter PlanListFilter) ([]BreedingPlan, bool, error) {
	if s.pool == nil {
		return nil, false, errors.New("i3 database is unavailable")
	}
	if filter.Limit < 1 || filter.Limit > 200 {
		filter.Limit = 50
	}
	if filter.Offset < 0 {
		filter.Offset = 0
	}
	query := planSelect + ` WHERE p.owner_id=$1 AND p.deleted_at IS NULL`
	args := []any{ownerID}
	add := func(clause string, value any) {
		args = append(args, value)
		query += fmt.Sprintf(clause, len(args))
	}
	if filter.State != "" {
		add(` AND p.state=$%d`, filter.State)
	}
	if filter.SireID != nil {
		add(` AND p.sire_id=$%d`, *filter.SireID)
	}
	if filter.DamID != nil {
		add(` AND p.dam_id=$%d`, *filter.DamID)
	}
	args = append(args, filter.Limit+1, filter.Offset)
	query += fmt.Sprintf(` ORDER BY p.created_at DESC, p.id DESC LIMIT $%d OFFSET $%d`, len(args)-1, len(args))
	rows, err := s.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, false, mapPostgresError(err)
	}
	defer rows.Close()
	plans := make([]BreedingPlan, 0, filter.Limit)
	for rows.Next() {
		plan, scanErr := scanPlan(rows)
		if scanErr != nil {
			return nil, false, scanErr
		}
		plans = append(plans, plan)
	}
	if err := rows.Err(); err != nil {
		return nil, false, mapPostgresError(err)
	}
	hasMore := len(plans) > filter.Limit
	if hasMore {
		plans = plans[:filter.Limit]
	}
	return plans, hasMore, nil
}

func (s *Service) GetPlan(ctx context.Context, ownerID, planID uuid.UUID) (BreedingPlan, error) {
	if s.pool == nil {
		return BreedingPlan{}, errors.New("i3 database is unavailable")
	}
	plan, err := scanPlan(s.pool.QueryRow(ctx, planSelect+`
		WHERE p.owner_id=$1 AND p.id=$2 AND p.deleted_at IS NULL`, ownerID, planID))
	if err != nil {
		return BreedingPlan{}, mapPostgresError(err)
	}
	return plan, nil
}

func (s *Service) ListAttempts(ctx context.Context, ownerID, planID uuid.UUID, filter AttemptListFilter) ([]PairingAttempt, bool, error) {
	if s.pool == nil {
		return nil, false, errors.New("i3 database is unavailable")
	}
	if filter.Limit < 1 || filter.Limit > 200 {
		filter.Limit = 50
	}
	if filter.Offset < 0 {
		filter.Offset = 0
	}
	var exists bool
	if err := s.pool.QueryRow(ctx, `SELECT EXISTS (SELECT 1 FROM breeding_plan WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL)`, ownerID, planID).Scan(&exists); err != nil {
		return nil, false, mapPostgresError(err)
	}
	if !exists {
		return nil, false, ErrNotFound
	}
	rows, err := s.pool.Query(ctx, attemptSelect+`
		WHERE owner_id=$1 AND breeding_plan_id=$2 AND deleted_at IS NULL
		ORDER BY attempt_no DESC LIMIT $3 OFFSET $4`, ownerID, planID, filter.Limit+1, filter.Offset)
	if err != nil {
		return nil, false, mapPostgresError(err)
	}
	defer rows.Close()
	attempts := make([]PairingAttempt, 0, filter.Limit)
	for rows.Next() {
		attempt, scanErr := scanAttempt(rows)
		if scanErr != nil {
			return nil, false, scanErr
		}
		attempts = append(attempts, attempt)
	}
	if err := rows.Err(); err != nil {
		return nil, false, mapPostgresError(err)
	}
	hasMore := len(attempts) > filter.Limit
	if hasMore {
		attempts = attempts[:filter.Limit]
	}
	return attempts, hasMore, nil
}

func (s *Service) GetAttempt(ctx context.Context, ownerID, attemptID uuid.UUID) (PairingAttempt, error) {
	if s.pool == nil {
		return PairingAttempt{}, errors.New("i3 database is unavailable")
	}
	attempt, err := scanAttempt(s.pool.QueryRow(ctx, attemptSelect+`
		WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL`, ownerID, attemptID))
	if err != nil {
		return PairingAttempt{}, mapPostgresError(err)
	}
	return attempt, nil
}

func (s *Service) CreatePlanTx(ctx context.Context, tx pgx.Tx, ownerID uuid.UUID, input CreatePlanInput, idempotencyKey string) (BreedingPlan, error) {
	if input.SireID == uuid.Nil || input.DamID == uuid.Nil || input.RuleVersionID == uuid.Nil || input.SireID == input.DamID {
		return BreedingPlan{}, &ValidationError{Field: "parents", Message: "父本、母本和规则版本不能为空且父母不能相同"}
	}
	if err := validateText(input.Name, 120, "name"); err != nil {
		return BreedingPlan{}, err
	}
	if err := validateText(input.Notes, 4000, "notes"); err != nil {
		return BreedingPlan{}, err
	}
	organizationID, err := organizationIDTx(ctx, tx, ownerID)
	if err != nil {
		return BreedingPlan{}, err
	}
	if err := ensurePublishedRuleTx(ctx, tx, ownerID, input.RuleVersionID); err != nil {
		return BreedingPlan{}, err
	}
	var planID uuid.UUID
	err = tx.QueryRow(ctx, `
		INSERT INTO breeding_plan (
			owner_id, organization_id, name, sire_id, dam_id, species_rule_version_id,
			planned_pairing_at, objective_traits, notes, created_by, updated_by
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$1,$1)
		RETURNING id`, ownerID, organizationID, input.Name, input.SireID, input.DamID,
		input.RuleVersionID, input.PlannedPairingAt, jsonBytes(input.ObjectiveTraits), input.Notes).Scan(&planID)
	if err != nil {
		return BreedingPlan{}, mapPostgresError(err)
	}
	// The INSERT RETURNING above only returns the id; re-read inside the same transaction
	// so the response is identical to GET and includes derived active/litter fields.
	plan, err := scanPlan(tx.QueryRow(ctx, planSelect+` WHERE p.owner_id=$1 AND p.id=$2`, ownerID, planID))
	if err != nil {
		return BreedingPlan{}, mapPostgresError(err)
	}
	if err := appendEventTx(ctx, tx, ownerID, plan.OrganizationID, "breeding_plan", plan.ID, "BREEDING_PLAN_CREATED", map[string]any{
		"sire_id": plan.SireID, "dam_id": plan.DamID, "rule_version_id": plan.RuleVersionID,
	}, idempotencyKey); err != nil {
		return BreedingPlan{}, err
	}
	return plan, nil
}

func (s *Service) UpdatePlanTx(ctx context.Context, tx pgx.Tx, ownerID, planID uuid.UUID, input UpdatePlanInput, idempotencyKey string) (BreedingPlan, error) {
	if input.ExpectedVersion < 1 {
		return BreedingPlan{}, &ValidationError{Field: "If-Match", Message: "If-Match 必须是正整数版本"}
	}
	plan, err := getPlanForUpdateTx(ctx, tx, ownerID, planID)
	if err != nil {
		return BreedingPlan{}, err
	}
	if plan.Version != input.ExpectedVersion {
		return BreedingPlan{}, &VersionError{Current: plan.Version}
	}
	if plan.State != "draft" && plan.State != "pair_ready" {
		return BreedingPlan{}, &StateError{Message: "当前状态不允许编辑繁育计划资料"}
	}
	if input.SireID != nil && *input.SireID == uuid.Nil || input.DamID != nil && *input.DamID == uuid.Nil {
		return BreedingPlan{}, &ValidationError{Field: "parents", Message: "父本或母本 ID 格式不正确"}
	}
	sireID, damID, ruleID := plan.SireID, plan.DamID, plan.RuleVersionID
	if input.SireID != nil {
		sireID = *input.SireID
	}
	if input.DamID != nil {
		damID = *input.DamID
	}
	if input.RuleVersionID != nil {
		ruleID = *input.RuleVersionID
	}
	if sireID == damID {
		return BreedingPlan{}, &ValidationError{Field: "parents", Message: "父本和母本不能相同"}
	}
	if err := ensurePublishedRuleTx(ctx, tx, ownerID, ruleID); err != nil {
		return BreedingPlan{}, err
	}
	if err := validateText(input.Name, 120, "name"); err != nil {
		return BreedingPlan{}, err
	}
	if err := validateText(input.Notes, 4000, "notes"); err != nil {
		return BreedingPlan{}, err
	}
	commandTag, err := tx.Exec(ctx, `
		UPDATE breeding_plan
		SET name=$3, sire_id=$4, dam_id=$5, species_rule_version_id=$6,
			planned_pairing_at=$7, objective_traits=$8, notes=$9,
			version=version+1, updated_by=$1, updated_at=now()
		WHERE owner_id=$1 AND id=$2 AND version=$10 AND deleted_at IS NULL
		`, ownerID, planID,
		nullableString(input.Name, input.ClearName, plan.Name), sireID, damID, ruleID,
		nullableTime(input.PlannedPairingAt, input.ClearPlannedPairingAt, plan.PlannedPairingAt),
		jsonBytes(coalesceObject(input.ObjectiveTraits, plan.ObjectiveTraits)),
		nullableString(input.Notes, input.ClearNotes, plan.Notes), input.ExpectedVersion)
	if err != nil {
		return BreedingPlan{}, mapPostgresError(err)
	}
	if commandTag.RowsAffected() != 1 {
		return BreedingPlan{}, &VersionError{Current: plan.Version}
	}
	updated, err := scanPlan(tx.QueryRow(ctx, planSelect+` WHERE p.owner_id=$1 AND p.id=$2`, ownerID, planID))
	if err != nil {
		return BreedingPlan{}, mapPostgresError(err)
	}
	if err := appendEventTx(ctx, tx, ownerID, updated.OrganizationID, "breeding_plan", planID, "BREEDING_PLAN_UPDATED", map[string]any{"version": updated.Version}, idempotencyKey); err != nil {
		return BreedingPlan{}, err
	}
	return updated, nil
}

func (s *Service) PublishPlanTx(ctx context.Context, tx pgx.Tx, ownerID, planID uuid.UUID, input PublishPlanInput, idempotencyKey string) (BreedingPlan, []map[string]any, error) {
	if input.ExpectedVersion < 1 || input.PairingEnclosureID == uuid.Nil || input.PlannedPairingAt.IsZero() {
		return BreedingPlan{}, nil, &ValidationError{Field: "publish", Message: "发布需要当前版本、计划时间和配对笼"}
	}
	plan, err := getPlanForUpdateTx(ctx, tx, ownerID, planID)
	if err != nil {
		return BreedingPlan{}, nil, err
	}
	if plan.Version != input.ExpectedVersion {
		return BreedingPlan{}, nil, &VersionError{Current: plan.Version}
	}
	if plan.State != "draft" {
		return BreedingPlan{}, nil, &StateError{Message: "只有 draft 状态的繁育计划可以发布"}
	}
	if err := ensurePublishedRuleTx(ctx, tx, ownerID, plan.RuleVersionID); err != nil {
		return BreedingPlan{}, nil, err
	}
	if err := validatePairingCageTx(ctx, tx, ownerID, input.PairingEnclosureID); err != nil {
		return BreedingPlan{}, nil, err
	}
	kinship := map[string]any{"status": "clear", "checked_at": time.Now().UTC()}
	if input.KinshipOverrideReason != nil && strings.TrimSpace(*input.KinshipOverrideReason) != "" {
		if len(*input.KinshipOverrideReason) > 2000 {
			return BreedingPlan{}, nil, &ValidationError{Field: "kinship_override_reason", Message: "亲缘覆盖理由不能超过 2000 个字符"}
		}
		kinship = map[string]any{"status": "overridden", "override_reason": strings.TrimSpace(*input.KinshipOverrideReason), "checked_at": time.Now().UTC()}
	}
	commandTag, err := tx.Exec(ctx, `
		UPDATE breeding_plan
		SET state='pair_ready', planned_pairing_at=$3,
			planned_pairing_enclosure_id=$4, kinship_check=$5,
			eligibility_override_reason=$6, version=version+1,
			updated_by=$1, updated_at=now()
		WHERE owner_id=$1 AND id=$2 AND version=$7 AND deleted_at IS NULL
		`, ownerID, planID, input.PlannedPairingAt, input.PairingEnclosureID,
		jsonBytes(kinship), input.KinshipOverrideReason, input.ExpectedVersion)
	if err != nil {
		return BreedingPlan{}, nil, mapPostgresError(err)
	}
	if commandTag.RowsAffected() != 1 {
		return BreedingPlan{}, nil, &VersionError{Current: plan.Version}
	}
	updated, err := scanPlan(tx.QueryRow(ctx, planSelect+` WHERE p.owner_id=$1 AND p.id=$2`, ownerID, planID))
	if err != nil {
		return BreedingPlan{}, nil, mapPostgresError(err)
	}
	task, err := ensureTaskTx(ctx, tx, ownerID, updated.OrganizationID, "pair_prep", "breeding_plan", planID,
		"准备繁育配对", input.PlannedPairingAt.Add(-30*time.Minute), "breeding-plan:"+planID.String()+":pair_prep")
	if err != nil {
		return BreedingPlan{}, nil, err
	}
	if err := appendEventTx(ctx, tx, ownerID, updated.OrganizationID, "breeding_plan", planID, "BREEDING_PLAN_PUBLISHED", map[string]any{
		"planned_pairing_at": input.PlannedPairingAt, "pairing_enclosure_id": input.PairingEnclosureID,
	}, idempotencyKey); err != nil {
		return BreedingPlan{}, nil, err
	}
	return updated, []map[string]any{task}, nil
}

func (s *Service) StartPairingTx(ctx context.Context, tx pgx.Tx, ownerID, planID uuid.UUID, input StartPairingInput, idempotencyKey string) (StartPairingResult, error) {
	if input.ExpectedVersion < 1 || input.EnclosureID == uuid.Nil || input.StartedAt.IsZero() {
		return StartPairingResult{}, &ValidationError{Field: "start_pairing", Message: "开始配对需要当前版本、配对笼和开始时间"}
	}
	plan, err := getPlanForUpdateTx(ctx, tx, ownerID, planID)
	if err != nil {
		return StartPairingResult{}, err
	}
	if plan.Version != input.ExpectedVersion {
		return StartPairingResult{}, &VersionError{Current: plan.Version}
	}
	if plan.State != "pair_ready" {
		return StartPairingResult{}, &StateError{Message: "只有 pair_ready 状态的繁育计划可以开始配对"}
	}
	if plan.PlannedPairingEnclosureID != nil && *plan.PlannedPairingEnclosureID != input.EnclosureID {
		return StartPairingResult{}, &ValidationError{Field: "enclosure_id", Message: "开始配对的笼盒必须与发布时选择的一致"}
	}
	capacity, state, err := enclosureCapacityStateTx(ctx, tx, ownerID, input.EnclosureID)
	if err != nil {
		return StartPairingResult{}, err
	}
	if state == "disabled" || capacity < 2 {
		return StartPairingResult{}, &StateError{Message: "配对笼必须可用且容量至少为 2"}
	}
	maxMinutes, err := pairingMaxMinutesTx(ctx, tx, ownerID, plan.RuleVersionID)
	if err != nil {
		return StartPairingResult{}, err
	}
	if maxMinutes <= 0 {
		maxMinutes = 30
	}
	if !input.StartedAt.After(time.Time{}) {
		return StartPairingResult{}, &ValidationError{Field: "started_at", Message: "开始时间格式不正确"}
	}
	if err := closeOpenStaysTx(ctx, tx, ownerID, plan.SireID, input.StartedAt); err != nil {
		return StartPairingResult{}, err
	}
	if err := closeOpenStaysTx(ctx, tx, ownerID, plan.DamID, input.StartedAt); err != nil {
		return StartPairingResult{}, err
	}
	sireVersion, err := hamsterVersionTx(ctx, tx, ownerID, plan.SireID)
	if err != nil {
		return StartPairingResult{}, err
	}
	damVersion, err := hamsterVersionTx(ctx, tx, ownerID, plan.DamID)
	if err != nil {
		return StartPairingResult{}, err
	}
	if err := updateHamsterEnclosureTx(ctx, tx, ownerID, plan.SireID, sireVersion, input.EnclosureID); err != nil {
		return StartPairingResult{}, err
	}
	if err := updateHamsterEnclosureTx(ctx, tx, ownerID, plan.DamID, damVersion, input.EnclosureID); err != nil {
		return StartPairingResult{}, err
	}
	var attemptID uuid.UUID
	err = tx.QueryRow(ctx, `
		INSERT INTO pairing_attempt (
			owner_id, breeding_plan_id, attempt_no, sire_id, dam_id,
			pairing_enclosure_id, started_at, separation_deadline, notes, created_by, updated_by
		)
		SELECT $1, $2, COALESCE(MAX(attempt_no),0)+1, sire_id, dam_id, $3, $4,
			$4 + make_interval(mins => $5), $6, $1, $1
		FROM breeding_plan
		WHERE owner_id=$1 AND id=$2
		GROUP BY sire_id, dam_id
		RETURNING id`, ownerID, planID, input.EnclosureID, input.StartedAt, maxMinutes, input.Notes).Scan(&attemptID)
	if err != nil {
		return StartPairingResult{}, mapPostgresError(err)
	}
	for _, hamsterID := range []uuid.UUID{plan.SireID, plan.DamID} {
		if _, err := tx.Exec(ctx, `
			INSERT INTO enclosure_stay (
				owner_id, enclosure_id, hamster_id, pairing_attempt_id, purpose,
				started_at, operator_id
			) VALUES ($1,$2,$3,$4,'pairing_temp',$5,$1)
		`, ownerID, input.EnclosureID, hamsterID, attemptID, input.StartedAt); err != nil {
			return StartPairingResult{}, mapPostgresError(err)
		}
	}
	commandTag, err := tx.Exec(ctx, `
		UPDATE breeding_plan SET state='pairing', version=version+1, updated_by=$1, updated_at=now()
		WHERE owner_id=$1 AND id=$2 AND version=$3
		`, ownerID, planID, input.ExpectedVersion)
	if err != nil {
		return StartPairingResult{}, mapPostgresError(err)
	}
	if commandTag.RowsAffected() != 1 {
		return StartPairingResult{}, &VersionError{Current: plan.Version}
	}
	updatedPlan, err := scanPlan(tx.QueryRow(ctx, planSelect+` WHERE p.owner_id=$1 AND p.id=$2`, ownerID, planID))
	if err != nil {
		return StartPairingResult{}, mapPostgresError(err)
	}
	attempt, err := scanAttempt(tx.QueryRow(ctx, attemptSelect+` WHERE owner_id=$1 AND id=$2`, ownerID, attemptID))
	if err != nil {
		return StartPairingResult{}, mapPostgresError(err)
	}
	if err := appendEventTx(ctx, tx, ownerID, updatedPlan.OrganizationID, "breeding_plan", planID, "PAIRING_STARTED", map[string]any{
		"pairing_attempt_id": attempt.ID, "enclosure_id": input.EnclosureID, "started_at": input.StartedAt,
	}, idempotencyKey); err != nil {
		return StartPairingResult{}, err
	}
	return StartPairingResult{Plan: updatedPlan, Attempt: attempt}, nil
}

func (s *Service) RecordObservationTx(ctx context.Context, tx pgx.Tx, ownerID, attemptID uuid.UUID, input RecordObservationInput, idempotencyKey string) (MatingObservation, int, *time.Time, error) {
	if input.ExpectedVersion < 1 || input.ObservedAt.IsZero() || !oneOf(input.Type, "contact", "chase", "conflict", "mating", "separated", "other") {
		return MatingObservation{}, 0, nil, &ValidationError{Field: "observation", Message: "观察时间和观察类型不正确"}
	}
	if input.DurationSeconds != nil && *input.DurationSeconds < 0 {
		return MatingObservation{}, 0, nil, &ValidationError{Field: "duration_seconds", Message: "观察时长不能为负数"}
	}
	if input.Confidence != nil && (*input.Confidence < 0 || *input.Confidence > 1) {
		return MatingObservation{}, 0, nil, &ValidationError{Field: "confidence", Message: "置信度必须在 0 到 1 之间"}
	}
	if input.Severity != nil && !oneOf(*input.Severity, "info", "low", "medium", "high", "critical") {
		return MatingObservation{}, 0, nil, &ValidationError{Field: "severity", Message: "严重程度不正确"}
	}
	seenMedia := make(map[uuid.UUID]struct{}, len(input.MediaIDs))
	for _, mediaID := range input.MediaIDs {
		if mediaID == uuid.Nil {
			return MatingObservation{}, 0, nil, &ValidationError{Field: "media_ids", Message: "媒体 ID 不能是空 UUID"}
		}
		if _, exists := seenMedia[mediaID]; exists {
			return MatingObservation{}, 0, nil, &ValidationError{Field: "media_ids", Message: "media_ids 不能重复"}
		}
		seenMedia[mediaID] = struct{}{}
	}
	if err := validateText(input.Notes, 4000, "notes"); err != nil {
		return MatingObservation{}, 0, nil, err
	}
	attempt, err := getAttemptForUpdateTx(ctx, tx, ownerID, attemptID)
	if err != nil {
		return MatingObservation{}, 0, nil, err
	}
	if attempt.Version != input.ExpectedVersion {
		return MatingObservation{}, 0, nil, &VersionError{Current: attempt.Version}
	}
	if attempt.Status != "active" && attempt.Status != "safety_hold" {
		return MatingObservation{}, 0, nil, &StateError{Message: "当前配对尝试不在可记录观察的状态"}
	}
	if input.ObservedAt.Before(attempt.StartedAt) || input.ObservedAt.After(attempt.SeparationDeadline) {
		return MatingObservation{}, 0, nil, &ValidationError{Field: "observed_at", Message: "观察时间必须位于配对有效时间段内"}
	}
	var observationID uuid.UUID
	mediaIDs := input.MediaIDs
	if mediaIDs == nil {
		mediaIDs = []uuid.UUID{}
	}
	err = tx.QueryRow(ctx, `
		INSERT INTO mating_observation (
			owner_id, pairing_attempt_id, observed_at, observation_type,
			duration_seconds, severity, confidence, media_ids, note, operator_id
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$1)
		RETURNING id`, ownerID, attemptID, input.ObservedAt, input.Type, input.DurationSeconds,
		input.Severity, input.Confidence, jsonBytes(mediaIDs), input.Notes).Scan(&observationID)
	if err != nil {
		return MatingObservation{}, 0, nil, mapPostgresError(err)
	}
	var newVersion int
	if err := tx.QueryRow(ctx, `
		UPDATE pairing_attempt SET version=version+1, updated_by=$1, updated_at=now()
		WHERE owner_id=$1 AND id=$2 AND version=$3
		RETURNING version`, ownerID, attemptID, input.ExpectedVersion).Scan(&newVersion); err != nil {
		return MatingObservation{}, 0, nil, mapPostgresError(err)
	}
	var baseline *time.Time
	if err := tx.QueryRow(ctx, `
		SELECT MIN(observed_at) FILTER (WHERE observation_type='mating')
		FROM mating_observation
		WHERE owner_id=$1 AND pairing_attempt_id=$2 AND deleted_at IS NULL`, ownerID, attemptID).Scan(&baseline); err != nil {
		return MatingObservation{}, 0, nil, mapPostgresError(err)
	}
	observation, err := scanObservation(tx.QueryRow(ctx, `
		SELECT id, owner_id, pairing_attempt_id, observed_at, observation_type::text,
			duration_seconds, severity::text, confidence, media_ids, note, created_at
		FROM mating_observation WHERE owner_id=$1 AND id=$2`, ownerID, observationID))
	if err != nil {
		return MatingObservation{}, 0, nil, mapPostgresError(err)
	}
	plan, err := getPlanByAttemptTx(ctx, tx, ownerID, attemptID)
	if err != nil {
		return MatingObservation{}, 0, nil, err
	}
	if err := appendEventTx(ctx, tx, ownerID, plan.OrganizationID, "pairing_attempt", attemptID, "PAIRING_OBSERVATION_RECORDED", map[string]any{
		"observation_id": observation.ID, "type": observation.Type, "observed_at": observation.ObservedAt,
	}, idempotencyKey); err != nil {
		return MatingObservation{}, 0, nil, err
	}
	return observation, newVersion, baseline, nil
}

func (s *Service) SeparatePairingTx(ctx context.Context, tx pgx.Tx, ownerID, attemptID uuid.UUID, input SeparatePairingInput, idempotencyKey string) (SeparationResult, error) {
	if input.SafetyStop {
		input.Result = "safety_stop"
	}
	if input.ExpectedVersion < 1 || input.EndedAt.IsZero() || input.SeparatedAt.IsZero() || input.Result == "" ||
		input.SireDestinationEnclosureID == uuid.Nil || input.DamDestinationEnclosureID == uuid.Nil ||
		input.SireDestinationEnclosureID == input.DamDestinationEnclosureID {
		return SeparationResult{}, &ValidationError{Field: "separate", Message: "分笼请求字段不完整或目标笼盒相同"}
	}
	if !oneOf(input.Result, "effective", "uncertain", "ineffective", "safety_stop") {
		return SeparationResult{}, &ValidationError{Field: "result", Message: "配对结果不正确"}
	}
	attempt, err := getAttemptForUpdateTx(ctx, tx, ownerID, attemptID)
	if err != nil {
		return SeparationResult{}, err
	}
	if attempt.Version != input.ExpectedVersion {
		return SeparationResult{}, &VersionError{Current: attempt.Version}
	}
	if attempt.Status != "active" && attempt.Status != "safety_hold" {
		return SeparationResult{}, &StateError{Message: "当前配对尝试不能再次分笼"}
	}
	if input.EndedAt.Before(attempt.StartedAt) || input.SeparatedAt.Before(input.EndedAt) {
		return SeparationResult{}, &ValidationError{Field: "ended_at", Message: "结束和分笼时间顺序不正确"}
	}
	plan, err := getPlanForUpdateTx(ctx, tx, ownerID, attempt.BreedingPlanID)
	if err != nil {
		return SeparationResult{}, err
	}
	if plan.State != "pairing" {
		return SeparationResult{}, &StateError{Message: "繁育计划当前不在 pairing 状态"}
	}
	if err := validatePairingEnclosureTx(ctx, tx, ownerID, input.SireDestinationEnclosureID); err != nil {
		return SeparationResult{}, err
	}
	if err := validatePairingEnclosureTx(ctx, tx, ownerID, input.DamDestinationEnclosureID); err != nil {
		return SeparationResult{}, err
	}
	if _, err := tx.Exec(ctx, `
		UPDATE enclosure_stay SET ended_at=$3, version=version+1, updated_at=now()
		WHERE owner_id=$1 AND pairing_attempt_id=$2 AND purpose='pairing_temp'
		  AND ended_at IS NULL AND deleted_at IS NULL`, ownerID, attemptID, input.SeparatedAt); err != nil {
		return SeparationResult{}, mapPostgresError(err)
	}
	if err := closeOpenStaysTx(ctx, tx, ownerID, attempt.SireID, input.SeparatedAt); err != nil {
		return SeparationResult{}, err
	}
	if err := closeOpenStaysTx(ctx, tx, ownerID, attempt.DamID, input.SeparatedAt); err != nil {
		return SeparationResult{}, err
	}
	sireVersion, err := hamsterVersionTx(ctx, tx, ownerID, attempt.SireID)
	if err != nil {
		return SeparationResult{}, err
	}
	damVersion, err := hamsterVersionTx(ctx, tx, ownerID, attempt.DamID)
	if err != nil {
		return SeparationResult{}, err
	}
	if err := updateHamsterEnclosureTx(ctx, tx, ownerID, attempt.SireID, sireVersion, input.SireDestinationEnclosureID); err != nil {
		return SeparationResult{}, err
	}
	if err := updateHamsterEnclosureTx(ctx, tx, ownerID, attempt.DamID, damVersion, input.DamDestinationEnclosureID); err != nil {
		return SeparationResult{}, err
	}
	if _, err := tx.Exec(ctx, `
		UPDATE pairing_attempt
		SET ended_at=$3, separated_at=$4, result=$5, status='separated',
			sire_destination_enclosure_id=$6, dam_destination_enclosure_id=$7,
			notes=$8, version=version+1, updated_by=$1, updated_at=now()
		WHERE owner_id=$1 AND id=$2 AND version=$9`, ownerID, attemptID, input.EndedAt, input.SeparatedAt,
		input.Result, input.SireDestinationEnclosureID, input.DamDestinationEnclosureID, input.Notes, input.ExpectedVersion); err != nil {
		return SeparationResult{}, mapPostgresError(err)
	}
	sirePurpose, damPurpose := "single", "single"
	if input.Result == "effective" || input.Result == "uncertain" {
		damPurpose = "gestation"
	}
	createdStays := make([]EnclosureStay, 0, 2)
	for _, item := range []struct {
		hamsterID   uuid.UUID
		enclosureID uuid.UUID
		purpose     string
	}{{attempt.SireID, input.SireDestinationEnclosureID, sirePurpose}, {attempt.DamID, input.DamDestinationEnclosureID, damPurpose}} {
		var stayID uuid.UUID
		if err := tx.QueryRow(ctx, `
			INSERT INTO enclosure_stay (owner_id, enclosure_id, hamster_id, purpose, started_at, operator_id)
			VALUES ($1,$2,$3,$4,$5,$1) RETURNING id`, ownerID, item.enclosureID, item.hamsterID, item.purpose, input.SeparatedAt).Scan(&stayID); err != nil {
			return SeparationResult{}, mapPostgresError(err)
		}
		createdStays = append(createdStays, EnclosureStay{ID: stayID, OwnerID: ownerID, EnclosureID: item.enclosureID, HamsterID: item.hamsterID, Purpose: item.purpose, StartedAt: input.SeparatedAt, Version: 1})
	}
	if _, err := tx.Exec(ctx, `
		UPDATE breeding_plan SET state='post_pair', version=version+1, updated_by=$1, updated_at=now()
		WHERE owner_id=$1 AND id=$2 AND version=$3`, ownerID, plan.ID, plan.Version); err != nil {
		return SeparationResult{}, mapPostgresError(err)
	}
	updatedPlan, err := scanPlan(tx.QueryRow(ctx, planSelect+` WHERE p.owner_id=$1 AND p.id=$2`, ownerID, plan.ID))
	if err != nil {
		return SeparationResult{}, mapPostgresError(err)
	}
	updatedAttempt, err := scanAttempt(tx.QueryRow(ctx, attemptSelect+` WHERE owner_id=$1 AND id=$2`, ownerID, attemptID))
	if err != nil {
		return SeparationResult{}, mapPostgresError(err)
	}
	if err := appendEventTx(ctx, tx, ownerID, updatedPlan.OrganizationID, "pairing_attempt", attemptID, "PAIRING_SEPARATED", map[string]any{
		"result": input.Result, "separated_at": input.SeparatedAt,
		"sire_destination_enclosure_id": input.SireDestinationEnclosureID,
		"dam_destination_enclosure_id":  input.DamDestinationEnclosureID,
	}, idempotencyKey); err != nil {
		return SeparationResult{}, err
	}
	return SeparationResult{Attempt: updatedAttempt, Plan: updatedPlan, CreatedStays: createdStays, CreatedTaskIDs: []uuid.UUID{}}, nil
}

func (s *Service) StartGestationTx(ctx context.Context, tx pgx.Tx, ownerID, planID uuid.UUID, input StartGestationInput, idempotencyKey string) (BreedingPlan, []map[string]any, error) {
	if input.ExpectedVersion < 1 || input.PairingAttemptID == uuid.Nil || input.BaselineAt.IsZero() || !oneOf(input.Result, "effective", "uncertain") {
		return BreedingPlan{}, nil, &ValidationError{Field: "gestation", Message: "进入孕期需要当前版本、已闭环配对、结果和基准时间"}
	}
	if strings.TrimSpace(input.Timezone) == "" {
		input.Timezone = "Asia/Shanghai"
	}
	location, err := time.LoadLocation(input.Timezone)
	if err != nil {
		return BreedingPlan{}, nil, &ValidationError{Field: "timezone", Message: "时区格式不正确"}
	}
	plan, err := getPlanForUpdateTx(ctx, tx, ownerID, planID)
	if err != nil {
		return BreedingPlan{}, nil, err
	}
	if plan.Version != input.ExpectedVersion {
		return BreedingPlan{}, nil, &VersionError{Current: plan.Version}
	}
	if plan.State != "post_pair" {
		return BreedingPlan{}, nil, &StateError{Message: "只有 post_pair 状态的繁育计划可以进入孕期观察"}
	}
	attempt, err := getAttemptForUpdateTx(ctx, tx, ownerID, input.PairingAttemptID)
	if err != nil {
		return BreedingPlan{}, nil, err
	}
	if attempt.BreedingPlanID != planID || attempt.Status != "separated" || attempt.Result == nil || !oneOf(*attempt.Result, "effective", "uncertain") {
		return BreedingPlan{}, nil, &StateError{Message: "配对尝试尚未以有效或待定结果完成分笼"}
	}
	if *attempt.Result != input.Result {
		return BreedingPlan{}, nil, &ValidationError{Field: "result", Message: "孕期结果必须与分笼结果一致"}
	}
	minDays, maxDays, err := gestationWindowTx(ctx, tx, ownerID, plan.RuleVersionID)
	if err != nil {
		return BreedingPlan{}, nil, err
	}
	baselineDate := input.BaselineAt.In(location)
	start := time.Date(baselineDate.Year(), baselineDate.Month(), baselineDate.Day(), 0, 0, 0, 0, time.UTC).AddDate(0, 0, minDays)
	end := time.Date(baselineDate.Year(), baselineDate.Month(), baselineDate.Day(), 0, 0, 0, 0, time.UTC).AddDate(0, 0, maxDays)
	commandTag, err := tx.Exec(ctx, `
		UPDATE breeding_plan
		SET state='gestation', mating_baseline_at=$3,
			expected_birth_start=$4, expected_birth_end=$5,
			version=version+1, updated_by=$1, updated_at=now()
		WHERE owner_id=$1 AND id=$2 AND version=$6
		`, ownerID, planID, input.BaselineAt, start, end, input.ExpectedVersion)
	if err != nil {
		return BreedingPlan{}, nil, mapPostgresError(err)
	}
	if commandTag.RowsAffected() != 1 {
		return BreedingPlan{}, nil, &VersionError{Current: plan.Version}
	}
	updated, err := scanPlan(tx.QueryRow(ctx, planSelect+` WHERE p.owner_id=$1 AND p.id=$2`, ownerID, planID))
	if err != nil {
		return BreedingPlan{}, nil, mapPostgresError(err)
	}
	if err := appendEventTx(ctx, tx, ownerID, updated.OrganizationID, "breeding_plan", planID, "GESTATION_STARTED", map[string]any{
		"pairing_attempt_id": attempt.ID, "result": input.Result, "baseline_at": input.BaselineAt,
		"expected_birth_start": start.Format("2006-01-02"), "expected_birth_end": end.Format("2006-01-02"),
	}, idempotencyKey); err != nil {
		return BreedingPlan{}, nil, err
	}
	return updated, []map[string]any{}, nil
}

func scanPlan(row rowScanner) (BreedingPlan, error) {
	var plan BreedingPlan
	var objectiveJSON, kinshipJSON []byte
	if err := row.Scan(&plan.ID, &plan.OwnerID, &plan.OrganizationID, &plan.Name, &plan.SireID, &plan.DamID,
		&plan.RuleVersionID, &plan.State, &plan.PlannedPairingAt, &plan.PlannedPairingEnclosureID,
		&plan.MatingBaselineAt, &plan.ExpectedBirthStart, &plan.ExpectedBirthEnd, &plan.ActualBirthAt,
		&objectiveJSON, &kinshipJSON, &plan.EligibilityOverrideReason, &plan.Notes, &plan.Version,
		&plan.CreatedAt, &plan.UpdatedAt, &plan.ActivePairingAttemptID, &plan.LitterID); err != nil {
		return plan, err
	}
	plan.ObjectiveTraits = decodeObject(objectiveJSON)
	plan.KinshipCheck = decodeObject(kinshipJSON)
	return plan, nil
}

func scanAttempt(row rowScanner) (PairingAttempt, error) {
	var attempt PairingAttempt
	if err := row.Scan(&attempt.ID, &attempt.OwnerID, &attempt.BreedingPlanID, &attempt.Sequence,
		&attempt.SireID, &attempt.DamID, &attempt.EnclosureID, &attempt.StartedAt, &attempt.EndedAt,
		&attempt.SeparatedAt, &attempt.SeparationDeadline, &attempt.Status, &attempt.Result,
		&attempt.ConflictLevel, &attempt.SireDestinationEnclosureID, &attempt.DamDestinationEnclosureID,
		&attempt.Notes, &attempt.Version, &attempt.CreatedAt, &attempt.UpdatedAt); err != nil {
		return attempt, err
	}
	return attempt, nil
}

func scanObservation(row rowScanner) (MatingObservation, error) {
	var observation MatingObservation
	var mediaJSON []byte
	if err := row.Scan(&observation.ID, &observation.OwnerID, &observation.PairingAttemptID,
		&observation.ObservedAt, &observation.Type, &observation.DurationSeconds, &observation.Severity,
		&observation.Confidence, &mediaJSON, &observation.Notes, &observation.CreatedAt); err != nil {
		return observation, err
	}
	observation.MediaIDs = decodeUUIDs(mediaJSON)
	return observation, nil
}

func getPlanForUpdateTx(ctx context.Context, tx pgx.Tx, ownerID, planID uuid.UUID) (BreedingPlan, error) {
	plan, err := scanPlan(tx.QueryRow(ctx, planSelect+` WHERE p.owner_id=$1 AND p.id=$2 AND p.deleted_at IS NULL FOR UPDATE`, ownerID, planID))
	if errors.Is(err, pgx.ErrNoRows) {
		return BreedingPlan{}, ErrNotFound
	}
	if err != nil {
		return BreedingPlan{}, mapPostgresError(err)
	}
	return plan, nil
}

func getAttemptForUpdateTx(ctx context.Context, tx pgx.Tx, ownerID, attemptID uuid.UUID) (PairingAttempt, error) {
	attempt, err := scanAttempt(tx.QueryRow(ctx, attemptSelect+` WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL FOR UPDATE`, ownerID, attemptID))
	if errors.Is(err, pgx.ErrNoRows) {
		return PairingAttempt{}, ErrNotFound
	}
	if err != nil {
		return PairingAttempt{}, mapPostgresError(err)
	}
	return attempt, nil
}

func getPlanByAttemptTx(ctx context.Context, tx pgx.Tx, ownerID, attemptID uuid.UUID) (BreedingPlan, error) {
	var planID uuid.UUID
	if err := tx.QueryRow(ctx, `SELECT breeding_plan_id FROM pairing_attempt WHERE owner_id=$1 AND id=$2`, ownerID, attemptID).Scan(&planID); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return BreedingPlan{}, ErrNotFound
		}
		return BreedingPlan{}, mapPostgresError(err)
	}
	return scanPlan(tx.QueryRow(ctx, planSelect+` WHERE p.owner_id=$1 AND p.id=$2`, ownerID, planID))
}

func organizationIDTx(ctx context.Context, tx pgx.Tx, ownerID uuid.UUID) (uuid.UUID, error) {
	var organizationID uuid.UUID
	if err := tx.QueryRow(ctx, `SELECT id FROM organization WHERE owner_id=$1 AND deleted_at IS NULL ORDER BY created_at LIMIT 1`, ownerID).Scan(&organizationID); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return uuid.Nil, ErrNotFound
		}
		return uuid.Nil, mapPostgresError(err)
	}
	return organizationID, nil
}

func ensurePublishedRuleTx(ctx context.Context, tx pgx.Tx, ownerID, ruleID uuid.UUID) error {
	var exists bool
	if err := tx.QueryRow(ctx, `
		SELECT EXISTS (
			SELECT 1 FROM species_rule_version
			WHERE id=$1 AND status='published'
			  AND (scope='system' OR (scope='owner' AND owner_id=$2))
		)`, ruleID, ownerID).Scan(&exists); err != nil {
		return mapPostgresError(err)
	}
	if !exists {
		return &ValidationError{Field: "rule_version_id", Message: "规则版本不存在或尚未发布"}
	}
	return nil
}

func validatePairingEnclosureTx(ctx context.Context, tx pgx.Tx, ownerID, enclosureID uuid.UUID) error {
	capacity, state, err := enclosureCapacityStateTx(ctx, tx, ownerID, enclosureID)
	if err != nil {
		return err
	}
	if state == "disabled" || capacity < 1 {
		return &StateError{Message: "指定笼盒当前不可用"}
	}
	return nil
}

func validatePairingCageTx(ctx context.Context, tx pgx.Tx, ownerID, enclosureID uuid.UUID) error {
	capacity, state, err := enclosureCapacityStateTx(ctx, tx, ownerID, enclosureID)
	if err != nil {
		return err
	}
	if state == "disabled" || capacity < 2 {
		return &StateError{Message: "配对笼必须可用且容量至少为 2"}
	}
	return nil
}

func enclosureCapacityStateTx(ctx context.Context, tx pgx.Tx, ownerID, enclosureID uuid.UUID) (int, string, error) {
	var capacity int
	var state string
	if err := tx.QueryRow(ctx, `SELECT capacity, state::text FROM enclosure WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL FOR UPDATE`, ownerID, enclosureID).Scan(&capacity, &state); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return 0, "", ErrNotFound
		}
		return 0, "", mapPostgresError(err)
	}
	return capacity, state, nil
}

func pairingMaxMinutesTx(ctx context.Context, tx pgx.Tx, ownerID, ruleID uuid.UUID) (int, error) {
	var minutes *int
	if err := tx.QueryRow(ctx, `
		SELECT pairing_max_minutes FROM species_rule_version
		WHERE id=$1 AND status='published'
		  AND (scope='system' OR (scope='owner' AND owner_id=$2))`, ruleID, ownerID).Scan(&minutes); err != nil {
		return 0, mapPostgresError(err)
	}
	if minutes == nil {
		return 30, nil
	}
	return *minutes, nil
}

func gestationWindowTx(ctx context.Context, tx pgx.Tx, ownerID, ruleID uuid.UUID) (int, int, error) {
	var minDays, maxDays int
	if err := tx.QueryRow(ctx, `
		SELECT gestation_min_days, gestation_max_days FROM species_rule_version
		WHERE id=$1 AND status='published'
		  AND (scope='system' OR (scope='owner' AND owner_id=$2))`, ruleID, ownerID).Scan(&minDays, &maxDays); err != nil {
		return 0, 0, mapPostgresError(err)
	}
	return minDays, maxDays, nil
}

func hamsterVersionTx(ctx context.Context, tx pgx.Tx, ownerID, hamsterID uuid.UUID) (int, error) {
	var version int
	if err := tx.QueryRow(ctx, `SELECT version FROM hamster WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL FOR UPDATE`, ownerID, hamsterID).Scan(&version); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return 0, ErrNotFound
		}
		return 0, mapPostgresError(err)
	}
	return version, nil
}

func updateHamsterEnclosureTx(ctx context.Context, tx pgx.Tx, ownerID, hamsterID uuid.UUID, version int, enclosureID uuid.UUID) error {
	var next int
	if err := tx.QueryRow(ctx, `
		UPDATE hamster SET current_enclosure_id=$4, version=version+1, updated_by=$1, updated_at=now()
		WHERE owner_id=$1 AND id=$2 AND version=$3 AND deleted_at IS NULL
		RETURNING version`, ownerID, hamsterID, version, enclosureID).Scan(&next); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return &VersionError{Current: version}
		}
		return mapPostgresError(err)
	}
	return nil
}

func closeOpenStaysTx(ctx context.Context, tx pgx.Tx, ownerID, hamsterID uuid.UUID, endedAt time.Time) error {
	_, err := tx.Exec(ctx, `
		UPDATE enclosure_stay
		SET ended_at=$3, version=version+1, updated_at=now()
		WHERE owner_id=$1 AND hamster_id=$2 AND ended_at IS NULL AND deleted_at IS NULL
		  AND started_at < $3`, ownerID, hamsterID, endedAt)
	return mapPostgresError(err)
}

func ensureTaskTx(ctx context.Context, tx pgx.Tx, ownerID, organizationID uuid.UUID, taskType, targetType string, targetID uuid.UUID, title string, scheduledAt time.Time, dedupeKey string) (map[string]any, error) {
	var taskID uuid.UUID
	if err := tx.QueryRow(ctx, `
		INSERT INTO care_task (
			owner_id, organization_id, task_type, target_type, target_id, title,
			scheduled_at, dedupe_key, created_by, updated_by
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$1,$1)
		ON CONFLICT (owner_id, dedupe_key) DO UPDATE SET updated_at=care_task.updated_at
		RETURNING id`, ownerID, organizationID, taskType, targetType, targetID, title, scheduledAt, dedupeKey).Scan(&taskID); err != nil {
		return nil, mapPostgresError(err)
	}
	var taskTypeText, targetTypeText, priority, status string
	var scheduled time.Time
	var version int
	if err := tx.QueryRow(ctx, `
		SELECT task_type::text, target_type::text, priority::text, status::text,
			scheduled_at, version FROM care_task WHERE owner_id=$1 AND id=$2`, ownerID, taskID).Scan(
		&taskTypeText, &targetTypeText, &priority, &status, &scheduled, &version); err != nil {
		return nil, mapPostgresError(err)
	}
	return map[string]any{"id": taskID, "task_type": taskTypeText, "target_type": targetTypeText, "target_id": targetID,
		"title": title, "scheduled_at": scheduled, "priority": priority, "status": status,
		"stage_total": 1, "stage_done": 0, "version": version}, nil
}

func appendEventTx(ctx context.Context, tx pgx.Tx, ownerID, organizationID uuid.UUID, aggregateType string, aggregateID uuid.UUID, eventType string, payload map[string]any, idempotencyKey string) error {
	var eventVersion int
	if err := tx.QueryRow(ctx, `
		SELECT COALESCE(MAX(event_version),0)+1
		FROM domain_event WHERE owner_id=$1 AND aggregate_type=$2 AND aggregate_id=$3`, ownerID, aggregateType, aggregateID).Scan(&eventVersion); err != nil {
		return mapPostgresError(err)
	}
	var eventID uuid.UUID
	if err := tx.QueryRow(ctx, `
		INSERT INTO domain_event (
			owner_id, organization_id, aggregate_type, aggregate_id, event_type,
			event_version, actor_id, occurred_at, payload, idempotency_key
		) VALUES ($1,$2,$3,$4,$5,$6,$1,now(),$7,$8)
		RETURNING id`, ownerID, organizationID, aggregateType, aggregateID, eventType, eventVersion,
		jsonBytes(payload), idempotencyKey).Scan(&eventID); err != nil {
		return mapPostgresError(err)
	}
	_, err := tx.Exec(ctx, `
		INSERT INTO outbox_message (owner_id, domain_event_id, topic, partition_key, payload)
		VALUES ($1,$2,$3,$4,$5)`, ownerID, eventID, "domain."+strings.ToLower(aggregateType), aggregateID.String(), jsonBytes(map[string]any{
		"event_id": eventID, "event_type": eventType, "aggregate_type": aggregateType, "aggregate_id": aggregateID, "payload": payload,
	}))
	return mapPostgresError(err)
}

func validateText(value *string, max int, field string) error {
	if value != nil && len(*value) > max {
		return &ValidationError{Field: field, Message: fmt.Sprintf("%s 不能超过 %d 个字符", field, max)}
	}
	return nil
}

func nullableString(value *string, clear bool, previous *string) *string {
	if clear {
		return nil
	}
	if value != nil {
		return value
	}
	return previous
}

func nullableTime(value *time.Time, clear bool, previous *time.Time) *time.Time {
	if clear {
		return nil
	}
	if value != nil {
		return value
	}
	return previous
}

func coalesceObject(value, previous map[string]any) map[string]any {
	if value != nil {
		return value
	}
	return previous
}

func oneOf(value string, choices ...string) bool {
	for _, choice := range choices {
		if value == choice {
			return true
		}
	}
	return false
}

func jsonBytes(value any) []byte {
	if value == nil {
		return []byte(`{}`)
	}
	data, err := json.Marshal(value)
	if err != nil {
		return []byte(`{}`)
	}
	return data
}

func decodeObject(data []byte) map[string]any {
	result := map[string]any{}
	if len(data) == 0 {
		return result
	}
	_ = json.Unmarshal(data, &result)
	return result
}

func decodeUUIDs(data []byte) []uuid.UUID {
	var values []string
	if len(data) == 0 || json.Unmarshal(data, &values) != nil {
		return []uuid.UUID{}
	}
	result := make([]uuid.UUID, 0, len(values))
	for _, value := range values {
		if parsed, err := uuid.Parse(value); err == nil {
			result = append(result, parsed)
		}
	}
	return result
}

func mapPostgresError(err error) error {
	if err == nil {
		return nil
	}
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) {
		switch pgErr.Code {
		case "23505", "23P01":
			return fmt.Errorf("%w: %s", ErrConflict, pgErr.Message)
		case "23514", "23503", "22P02", "22007":
			return fmt.Errorf("%w: %s", ErrValidation, pgErr.Message)
		}
	}
	return err
}
