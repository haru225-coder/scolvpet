package i4core

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/scolvpet/scolvpet/api/internal/store"
)

type PostgresRepository struct{ pool *pgxpool.Pool }
type postgresTransaction struct{ tx pgx.Tx }

func NewPostgresRepository(pool *pgxpool.Pool) *PostgresRepository {
	return &PostgresRepository{pool: pool}
}
func NewPostgresRepositoryFromStore(source *store.Store) *PostgresRepository {
	return NewPostgresRepository(source.Pool)
}

func (r *PostgresRepository) Execute(ctx context.Context, command Command, fn func(context.Context, Transaction) (any, error)) (CommandResult, error) {
	if strings.TrimSpace(command.IdempotencyKey) == "" {
		return CommandResult{}, ErrIdempotencyKeyRequired
	}
	if r == nil || r.pool == nil {
		return CommandResult{}, errors.New("i4 postgres repository is not configured")
	}
	hash := sha256.Sum256([]byte(command.Method + "\n" + command.Path + "\n" + string(command.Payload)))
	hashHex := hex.EncodeToString(hash[:])
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return CommandResult{}, err
	}
	defer func() { _ = tx.Rollback(ctx) }()
	var existingHash, status string
	var responseStatus *int
	var responseBody []byte
	err = tx.QueryRow(ctx, `SELECT request_hash, status, response_status, response_body FROM idempotency_record WHERE owner_id=$1 AND idempotency_key=$2 FOR UPDATE`, command.OwnerID, command.IdempotencyKey).Scan(&existingHash, &status, &responseStatus, &responseBody)
	if err == nil {
		if existingHash != hashHex {
			return CommandResult{}, ErrIdempotencyPayloadMismatch
		}
		if status == "processing" || responseStatus == nil || responseBody == nil {
			return CommandResult{}, ErrIdempotencyInProgress
		}
		if err := tx.Commit(ctx); err != nil {
			return CommandResult{}, mapPostgresError(err)
		}
		body, err := decodeStoredBody(responseBody)
		if err != nil {
			return CommandResult{}, err
		}
		return CommandResult{Body: body, Status: *responseStatus, Replayed: true}, nil
	}
	if !errors.Is(err, pgx.ErrNoRows) {
		return CommandResult{}, mapPostgresError(err)
	}
	_, err = tx.Exec(ctx, `INSERT INTO idempotency_record (owner_id, idempotency_key, request_method, request_path, request_hash, status, expires_at) VALUES ($1,$2,$3,$4,$5,'processing',now()+interval '24 hours')`, command.OwnerID, command.IdempotencyKey, strings.ToUpper(command.Method), command.Path, hashHex)
	if err != nil {
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) && pgErr.Code == "23505" {
			return CommandResult{}, ErrIdempotencyInProgress
		}
		return CommandResult{}, mapPostgresError(err)
	}
	body, err := fn(ctx, &postgresTransaction{tx: tx})
	if err != nil {
		return CommandResult{}, err
	}
	bodyBytes, err := json.Marshal(body)
	if err != nil {
		return CommandResult{}, err
	}
	stored, err := json.Marshal(map[string]any{"body": json.RawMessage(bodyBytes)})
	if err != nil {
		return CommandResult{}, err
	}
	if _, err := tx.Exec(ctx, `UPDATE idempotency_record SET status='completed', response_status=$3, response_body=$4, completed_at=now(), updated_at=now() WHERE owner_id=$1 AND idempotency_key=$2`, command.OwnerID, command.IdempotencyKey, command.SuccessStatus, stored); err != nil {
		return CommandResult{}, mapPostgresError(err)
	}
	if err := tx.Commit(ctx); err != nil {
		return CommandResult{}, mapPostgresError(err)
	}
	return CommandResult{Body: bodyBytes, Status: command.SuccessStatus}, nil
}

func decodeStoredBody(raw []byte) ([]byte, error) {
	var stored struct {
		Body json.RawMessage `json:"body"`
	}
	if err := json.Unmarshal(raw, &stored); err != nil {
		return nil, err
	}
	return stored.Body, nil
}

func (r *PostgresRepository) GetLitter(ctx context.Context, ownerID, litterID uuid.UUID) (Litter, error) {
	if r == nil || r.pool == nil {
		return Litter{}, errors.New("i4 postgres repository is not configured")
	}
	return scanLitter(r.pool.QueryRow(ctx, litterSelect+` WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL`, ownerID, litterID))
}

func (r *PostgresRepository) GetIndividualizationEligibility(ctx context.Context, ownerID, litterID uuid.UUID) (IndividualizationEligibility, error) {
	litter, err := r.GetLitter(ctx, ownerID, litterID)
	if err != nil {
		return IndividualizationEligibility{}, err
	}
	rows, err := r.pool.Query(ctx, pupSelect+` WHERE owner_id=$1 AND litter_id=$2 AND deleted_at IS NULL ORDER BY id`, ownerID, litterID)
	if err != nil {
		return IndividualizationEligibility{}, mapPostgresError(err)
	}
	defer rows.Close()
	pups := make([]PupIdentity, 0)
	for rows.Next() {
		pup, scanErr := scanPup(rows)
		if scanErr != nil {
			return IndividualizationEligibility{}, scanErr
		}
		pups = append(pups, pup)
	}
	if err := rows.Err(); err != nil {
		return IndividualizationEligibility{}, mapPostgresError(err)
	}
	return computeEligibility(litter, pups, time.Now().UTC()), nil
}

func (t *postgresTransaction) GetPlanForUpdate(ctx context.Context, ownerID, planID uuid.UUID) (BreedingPlan, error) {
	return scanPlan(t.tx.QueryRow(ctx, planSelect+` WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL FOR UPDATE`, ownerID, planID))
}

func (t *postgresTransaction) GetLitterForUpdate(ctx context.Context, ownerID, litterID uuid.UUID) (Litter, error) {
	return scanLitter(t.tx.QueryRow(ctx, litterSelect+` WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL FOR UPDATE`, ownerID, litterID))
}

func (t *postgresTransaction) ListPupsForUpdate(ctx context.Context, ownerID, litterID uuid.UUID) ([]PupIdentity, error) {
	rows, err := t.tx.Query(ctx, pupSelect+` WHERE owner_id=$1 AND litter_id=$2 AND deleted_at IS NULL ORDER BY id FOR UPDATE`, ownerID, litterID)
	if err != nil {
		return nil, mapPostgresError(err)
	}
	defer rows.Close()
	items := make([]PupIdentity, 0)
	for rows.Next() {
		item, scanErr := scanPup(rows)
		if scanErr != nil {
			return nil, scanErr
		}
		items = append(items, item)
	}
	return items, mapPostgresError(rows.Err())
}

func (t *postgresTransaction) GetPupForUpdate(ctx context.Context, ownerID, pupID uuid.UUID) (PupIdentity, error) {
	return scanPup(t.tx.QueryRow(ctx, pupSelect+` WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL FOR UPDATE`, ownerID, pupID))
}

func (t *postgresTransaction) GetEnclosureForUpdate(ctx context.Context, ownerID, enclosureID uuid.UUID) (Enclosure, error) {
	var item Enclosure
	err := t.tx.QueryRow(ctx, `SELECT id, owner_id, capacity, state FROM enclosure WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL FOR UPDATE`, ownerID, enclosureID).Scan(&item.ID, &item.OwnerID, &item.Capacity, &item.State)
	if errors.Is(err, pgx.ErrNoRows) {
		return Enclosure{}, ErrNotFound
	}
	return item, mapPostgresError(err)
}

func (t *postgresTransaction) GetLitterParents(ctx context.Context, ownerID, litterID uuid.UUID) (LitterParents, error) {
	var parents LitterParents
	rows, err := t.tx.Query(ctx, `SELECT role, parent_id FROM litter_parent WHERE owner_id=$1 AND litter_id=$2 AND status='accepted' AND valid_to IS NULL`, ownerID, litterID)
	if err != nil {
		return parents, mapPostgresError(err)
	}
	defer rows.Close()
	for rows.Next() {
		var role string
		var id uuid.UUID
		if err := rows.Scan(&role, &id); err != nil {
			return parents, err
		}
		switch role {
		case "sire":
			parents.SireID = id
		case "dam":
			parents.DamID = id
		}
	}
	if err := rows.Err(); err != nil {
		return parents, mapPostgresError(err)
	}
	if parents.SireID == uuid.Nil || parents.DamID == uuid.Nil {
		return parents, ErrNotFound
	}
	return parents, nil
}

func (t *postgresTransaction) CreateLitter(ctx context.Context, ownerID uuid.UUID, input ConfirmBirthInput, plan BreedingPlan) (Litter, error) {
	code := "L-" + input.BornAt.UTC().Format("20060102") + "-" + plan.ID.String()[:8]
	row := t.tx.QueryRow(ctx, `INSERT INTO litter (owner_id, organization_id, breeding_plan_id, origin, code, state, born_at, enclosure_id, dam_condition, initial_alive_count, initial_other_count, current_managed_count, unindividualized_alive_count, notes, created_by, updated_by) VALUES ($1,$2,$3,'breeding',$4,'nursing',$5,$6,$7,$8,$9,$8,$8,$10,$1,$1) RETURNING `+litterColumns, ownerID, plan.OrganizationID, plan.ID, code, input.BornAt, input.EnclosureID, jsonBytes(input.DamCondition), input.InitialAliveCount, input.InitialOtherCount, input.Notes)
	return scanLitter(row)
}

func (t *postgresTransaction) InsertLitterParents(ctx context.Context, ownerID, litterID, sireID, damID uuid.UUID) error {
	for role, parent := range map[string]uuid.UUID{"sire": sireID, "dam": damID} {
		if _, err := t.tx.Exec(ctx, `INSERT INTO litter_parent (owner_id, litter_id, parent_id, role, evidence_type, confidence, status, created_by, updated_by) VALUES ($1,$2,$3,$4,'litter_inferred',1,'accepted',$1,$1)`, ownerID, litterID, parent, role); err != nil {
			return mapPostgresError(err)
		}
	}
	return nil
}

func (t *postgresTransaction) InsertCountEvent(ctx context.Context, ownerID, litterID uuid.UUID, input CountEventInput, pupID *uuid.UUID) (CountEvent, error) {
	id := uuid.New()
	key := input.IdempotencyKey
	if key == "" {
		key = "i4-count-" + id.String()
	}
	var reason *string
	if strings.TrimSpace(input.Reason) != "" {
		reason = &input.Reason
	}
	var item CountEvent
	err := t.tx.QueryRow(ctx, `INSERT INTO litter_count_event (id, owner_id, litter_id, pup_identity_id, event_type, delta, occurred_at, reason, operator_id, idempotency_key) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$2,$9) RETURNING id, litter_id, pup_identity_id, event_type, delta, occurred_at, reason`, id, ownerID, litterID, pupID, input.EventType, input.Delta, input.OccurredAt, reason, key).Scan(&item.ID, &item.LitterID, &item.PupIdentityID, &item.EventType, &item.Delta, &item.OccurredAt, &item.Reason)
	return item, mapPostgresError(err)
}

func (t *postgresTransaction) InsertPupIdentities(ctx context.Context, ownerID, litterID uuid.UUID, codes []string) ([]PupIdentity, error) {
	items := make([]PupIdentity, 0, len(codes))
	for _, code := range codes {
		item, err := t.InsertPupIdentity(ctx, ownerID, litterID, code)
		if err != nil {
			return nil, err
		}
		items = append(items, item)
	}
	return items, nil
}

func (t *postgresTransaction) InsertPupIdentity(ctx context.Context, ownerID, litterID uuid.UUID, code string) (PupIdentity, error) {
	row := t.tx.QueryRow(ctx, `INSERT INTO pup_identity (owner_id, litter_id, temporary_code, created_by, updated_by) VALUES ($1,$2,$3,$1,$1) RETURNING `+pupColumns, ownerID, litterID, code)
	return scanPup(row)
}

func (t *postgresTransaction) InsertLitterPupMember(ctx context.Context, ownerID, litterID, pupID uuid.UUID) error {
	_, err := t.tx.Exec(ctx, `INSERT INTO litter_member (owner_id, litter_id, member_type, pup_identity_id, evidence_type, confidence, status, created_by, updated_by) VALUES ($1,$2,'pup_identity',$3,'litter_inferred',1,'accepted',$1,$1)`, ownerID, litterID, pupID)
	return mapPostgresError(err)
}

func (t *postgresTransaction) ClosePupMember(ctx context.Context, ownerID, pupID uuid.UUID, at time.Time) error {
	_, err := t.tx.Exec(ctx, `UPDATE litter_member SET status='superseded', valid_to=$3, updated_at=now(), updated_by=$1 WHERE owner_id=$1 AND pup_identity_id=$2 AND status='accepted' AND valid_to IS NULL`, ownerID, pupID, at)
	return mapPostgresError(err)
}

func (t *postgresTransaction) UpdatePlanBirth(ctx context.Context, ownerID, planID uuid.UUID, version int, input ConfirmBirthInput, litterID *uuid.UUID, state string) (BreedingPlan, error) {
	row := t.tx.QueryRow(ctx, `UPDATE breeding_plan SET state=$4, actual_birth_at=$5, birth_result_alive_count=$6, birth_result_other_count=$7, birth_result_reason=$8, birth_dam_condition=$9, litter_id=$10, version=version+1, updated_at=now(), updated_by=$1 WHERE owner_id=$1 AND id=$2 AND version=$3 RETURNING `+planColumns, ownerID, planID, version, state, input.BornAt, input.InitialAliveCount, input.InitialOtherCount, input.OutcomeReason, jsonBytes(input.DamCondition), litterID)
	return scanPlan(row)
}

func (t *postgresTransaction) UpdateLitterCountProjection(ctx context.Context, ownerID, litterID uuid.UUID, version int, input CountEventInput) (Litter, error) {
	row := t.tx.QueryRow(ctx, `UPDATE litter SET discovered_count=discovered_count+CASE WHEN $4='discovered' THEN $5 ELSE 0 END, deceased_count=deceased_count+CASE WHEN $4='death' THEN -$5 ELSE 0 END, transferred_out_count=transferred_out_count+CASE WHEN $4='transferred_out' THEN -$5 ELSE 0 END, correction_delta=correction_delta+CASE WHEN $4='correction' THEN $5 ELSE 0 END, current_managed_count=initial_alive_count+discovered_count+CASE WHEN $4='discovered' THEN $5 ELSE 0 END-deceased_count-CASE WHEN $4='death' THEN -$5 ELSE 0 END-transferred_out_count-CASE WHEN $4='transferred_out' THEN -$5 ELSE 0 END+correction_delta+CASE WHEN $4='correction' THEN $5 ELSE 0 END, unindividualized_alive_count=(SELECT count(*) FROM pup_identity p WHERE p.owner_id=litter.owner_id AND p.litter_id=litter.id AND p.outcome_status='alive' AND p.profile_status='unindividualized' AND p.deleted_at IS NULL), individualized_alive_count=(SELECT count(*) FROM pup_identity p WHERE p.owner_id=litter.owner_id AND p.litter_id=litter.id AND p.outcome_status='alive' AND p.profile_status='individualized' AND p.deleted_at IS NULL), version=version+1, updated_at=now(), updated_by=$1 WHERE owner_id=$1 AND id=$2 AND version=$3 RETURNING `+litterColumns, ownerID, litterID, version, input.EventType, input.Delta)
	return scanLitter(row)
}

func (t *postgresTransaction) UpdatePupOutcome(ctx context.Context, ownerID, pupID uuid.UUID, outcome string, weanedAt *time.Time, enclosureID *uuid.UUID, reason *string) (PupIdentity, error) {
	row := t.tx.QueryRow(ctx, `UPDATE pup_identity SET outcome_status=$3, weaned_at=COALESCE($4,weaned_at), current_enclosure_id=$5, status_reason=$6, version=version+1, updated_at=now(), updated_by=$1 WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL RETURNING `+pupColumns, ownerID, pupID, outcome, weanedAt, enclosureID, reason)
	return scanPup(row)
}

func (t *postgresTransaction) UpdatePupSexAndEnclosure(ctx context.Context, ownerID, pupID uuid.UUID, sex string, confidence *float64, enclosureID uuid.UUID, reason *string) (PupIdentity, error) {
	row := t.tx.QueryRow(ctx, `UPDATE pup_identity SET sex=$3, sex_confidence=$4, current_enclosure_id=$5, status_reason=$6, version=version+1, updated_at=now(), updated_by=$1 WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL RETURNING `+pupColumns, ownerID, pupID, sex, confidence, enclosureID, reason)
	return scanPup(row)
}

func (t *postgresTransaction) UpdateLitterWeaned(ctx context.Context, ownerID, litterID uuid.UUID, version int, at time.Time) (Litter, error) {
	row := t.tx.QueryRow(ctx, `UPDATE litter SET state='sexing_due', weaning_completed_at=$4, version=version+1, updated_at=now(), updated_by=$1 WHERE owner_id=$1 AND id=$2 AND version=$3 RETURNING `+litterColumns, ownerID, litterID, version, at)
	return scanLitter(row)
}

func (t *postgresTransaction) UpdateLitterSeparated(ctx context.Context, ownerID, litterID uuid.UUID, version int, at time.Time) (Litter, error) {
	row := t.tx.QueryRow(ctx, `UPDATE litter SET state='individualizing', sex_separation_completed_at=$4, version=version+1, updated_at=now(), updated_by=$1 WHERE owner_id=$1 AND id=$2 AND version=$3 RETURNING `+litterColumns, ownerID, litterID, version, at)
	return scanLitter(row)
}

func (t *postgresTransaction) InsertHamster(ctx context.Context, ownerID uuid.UUID, plan BreedingPlan, pup PupIdentity, input IndividualizeItem) (Hamster, error) {
	var birthDate *time.Time
	if plan.ActualBirthAt != nil {
		value := plan.ActualBirthAt.UTC()
		birthDate = &value
	}
	row := t.tx.QueryRow(ctx, `INSERT INTO hamster (owner_id, organization_id, internal_code, name, species_rule_version_id, variety_code, sex, sex_confidence, birth_date, source_type, lifecycle_status, breeding_status, current_enclosure_id, notes, created_by, updated_by) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,'born_here','active','candidate',$10,$11,$1,$1) RETURNING `+hamsterColumns, ownerID, plan.OrganizationID, input.InternalCode, input.Name, plan.RuleVersionID, input.VarietyCode, pup.Sex, pup.SexConfidence, birthDate, pup.CurrentEnclosureID, input.Notes)
	return scanHamster(row)
}

func (t *postgresTransaction) InsertLitterHamsterMember(ctx context.Context, ownerID, litterID, hamsterID, originPupID uuid.UUID) error {
	_, err := t.tx.Exec(ctx, `INSERT INTO litter_member (owner_id, litter_id, member_type, hamster_id, origin_pup_identity_id, evidence_type, confidence, status, created_by, updated_by) VALUES ($1,$2,'hamster',$3,$4,'litter_inferred',1,'accepted',$1,$1)`, ownerID, litterID, hamsterID, originPupID)
	return mapPostgresError(err)
}

func (t *postgresTransaction) InsertPedigreeParentage(ctx context.Context, ownerID, parentID, childID uuid.UUID, role string) error {
	_, err := t.tx.Exec(ctx, `INSERT INTO pedigree_parentage (owner_id, parent_id, child_id, role, evidence_type, confidence, status, created_by, updated_by) VALUES ($1,$2,$3,$4,'litter_inferred',1,'accepted',$1)`, ownerID, parentID, childID, role)
	return mapPostgresError(err)
}

func (t *postgresTransaction) UpdatePupIndividualized(ctx context.Context, ownerID, pupID, hamsterID uuid.UUID) (PupIdentity, error) {
	row := t.tx.QueryRow(ctx, `UPDATE pup_identity SET profile_status='individualized', individualized_hamster_id=$3, version=version+1, updated_at=now(), updated_by=$1 WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL RETURNING `+pupColumns, ownerID, pupID, hamsterID)
	return scanPup(row)
}

func (t *postgresTransaction) UpdateLitterIndividualized(ctx context.Context, ownerID, litterID uuid.UUID, version int, at time.Time) (Litter, error) {
	row := t.tx.QueryRow(ctx, `UPDATE litter SET state='closed', reconciled_at=$4, unindividualized_alive_count=0, individualized_alive_count=(SELECT count(*) FROM pup_identity p WHERE p.owner_id=litter.owner_id AND p.litter_id=litter.id AND p.outcome_status='alive' AND p.profile_status='individualized' AND p.deleted_at IS NULL), version=version+1, updated_at=now(), updated_by=$1 WHERE owner_id=$1 AND id=$2 AND version=$3 RETURNING `+litterColumns, ownerID, litterID, version, at)
	litter, err := scanLitter(row)
	if err != nil {
		return Litter{}, err
	}
	if _, err := t.tx.Exec(ctx, `UPDATE breeding_plan SET state='completed', version=version+1, updated_at=now(), updated_by=$1 WHERE owner_id=$1 AND id=$2 AND state='individualizing'`, ownerID, *litter.BreedingPlanID); err != nil {
		return Litter{}, mapPostgresError(err)
	}
	return litter, nil
}

func (t *postgresTransaction) AppendEvent(ctx context.Context, event DomainEvent) (uuid.UUID, error) {
	if event.ID == uuid.Nil {
		event.ID = uuid.New()
	}
	if event.OccurredAt.IsZero() {
		event.OccurredAt = time.Now().UTC()
	}
	var version int
	if err := t.tx.QueryRow(ctx, `SELECT COALESCE(MAX(event_version),0)+1 FROM domain_event WHERE owner_id=$1 AND aggregate_type=$2 AND aggregate_id=$3`, event.OwnerID, event.AggregateType, event.AggregateID).Scan(&version); err != nil {
		return uuid.Nil, mapPostgresError(err)
	}
	if _, err := t.tx.Exec(ctx, `INSERT INTO domain_event (id, owner_id, organization_id, aggregate_type, aggregate_id, event_type, event_version, actor_id, occurred_at, payload, idempotency_key) VALUES ($1,$2,$3,$4,$5,$6,$7,$2,$8,$9,$10)`, event.ID, event.OwnerID, event.OrganizationID, event.AggregateType, event.AggregateID, event.EventType, version, event.OccurredAt, jsonBytes(event.Payload), event.IdempotencyKey); err != nil {
		return uuid.Nil, mapPostgresError(err)
	}
	if _, err := t.tx.Exec(ctx, `INSERT INTO outbox_message (owner_id, domain_event_id, topic, partition_key, payload) VALUES ($1,$2,$3,$4,$5)`, event.OwnerID, event.ID, "domain."+event.EventType, event.AggregateID.String(), jsonBytes(event.Payload)); err != nil {
		return uuid.Nil, mapPostgresError(err)
	}
	return event.ID, nil
}

const planColumns = `id, owner_id, organization_id, sire_id, dam_id, species_rule_version_id, state, actual_birth_at, birth_result_alive_count, birth_result_other_count, birth_result_reason, birth_dam_condition, litter_id, version, created_at, updated_at`
const planSelect = `SELECT ` + planColumns + ` FROM breeding_plan`
const litterColumns = `id, owner_id, organization_id, breeding_plan_id, origin, code, state, born_at, enclosure_id, dam_condition, initial_alive_count, initial_other_count, discovered_count, deceased_count, transferred_out_count, correction_delta, current_managed_count, unindividualized_alive_count, individualized_alive_count, weaning_completed_at, sex_separation_completed_at, reconciled_at, version, created_at, updated_at`
const litterSelect = `SELECT ` + litterColumns + ` FROM litter`
const pupColumns = `id, owner_id, litter_id, temporary_code, sex, sex_confidence, profile_status, outcome_status, weaned_at, current_enclosure_id, individualized_hamster_id, phenotype_summary, destination_code, status_reason, version, created_at, updated_at`
const pupSelect = `SELECT ` + pupColumns + ` FROM pup_identity`
const hamsterColumns = `id, owner_id, organization_id, internal_code, name, species_rule_version_id, variety_code, sex, sex_confidence, birth_date, source_type, lifecycle_status, breeding_status, current_enclosure_id, notes, version, created_at, updated_at`

type rowScanner interface{ Scan(...any) error }

func scanPlan(row rowScanner) (BreedingPlan, error) {
	var item BreedingPlan
	var condition []byte
	err := row.Scan(&item.ID, &item.OwnerID, &item.OrganizationID, &item.SireID, &item.DamID, &item.RuleVersionID, &item.State, &item.ActualBirthAt, &item.BirthAliveCount, &item.BirthOtherCount, &item.BirthResultReason, &condition, &item.LitterID, &item.Version, &item.CreatedAt, &item.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return BreedingPlan{}, ErrNotFound
	}
	if err != nil {
		return BreedingPlan{}, mapPostgresError(err)
	}
	item.DamCondition = decodeJSONMap(condition)
	return item, nil
}
func scanLitter(row rowScanner) (Litter, error) {
	var item Litter
	var condition []byte
	err := row.Scan(&item.ID, &item.OwnerID, &item.OrganizationID, &item.BreedingPlanID, &item.Origin, &item.Code, &item.State, &item.BornAt, &item.EnclosureID, &condition, &item.InitialAliveCount, &item.InitialOtherCount, &item.DiscoveredCount, &item.DeceasedCount, &item.TransferredOutCount, &item.CorrectionDelta, &item.CurrentManagedCount, &item.UnindividualizedCount, &item.IndividualizedCount, &item.WeaningCompletedAt, &item.SexSeparatedAt, &item.ReconciledAt, &item.Version, &item.CreatedAt, &item.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return Litter{}, ErrNotFound
	}
	if err != nil {
		return Litter{}, mapPostgresError(err)
	}
	item.DamCondition = decodeJSONMap(condition)
	return item, nil
}
func scanPup(row rowScanner) (PupIdentity, error) {
	var item PupIdentity
	var phenotype []byte
	err := row.Scan(&item.ID, &item.OwnerID, &item.LitterID, &item.TemporaryCode, &item.Sex, &item.SexConfidence, &item.ProfileStatus, &item.OutcomeStatus, &item.WeanedAt, &item.CurrentEnclosureID, &item.IndividualizedHamster, &phenotype, &item.DestinationCode, &item.StatusReason, &item.Version, &item.CreatedAt, &item.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return PupIdentity{}, ErrNotFound
	}
	if err != nil {
		return PupIdentity{}, mapPostgresError(err)
	}
	item.PhenotypeSummary = decodeJSONMap(phenotype)
	return item, nil
}
func scanHamster(row rowScanner) (Hamster, error) {
	var item Hamster
	err := row.Scan(&item.ID, &item.OwnerID, &item.OrganizationID, &item.InternalCode, &item.Name, &item.SpeciesRuleVersionID, &item.VarietyCode, &item.Sex, &item.SexConfidence, &item.BirthDate, &item.SourceType, &item.LifecycleStatus, &item.BreedingStatus, &item.CurrentEnclosureID, &item.Notes, &item.Version, &item.CreatedAt, &item.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return Hamster{}, ErrNotFound
	}
	return item, mapPostgresError(err)
}
func decodeJSONMap(raw []byte) map[string]any {
	var value map[string]any
	if len(raw) > 0 {
		_ = json.Unmarshal(raw, &value)
	}
	if value == nil {
		value = map[string]any{}
	}
	return value
}
func jsonBytes(value any) []byte {
	raw, _ := json.Marshal(value)
	if len(raw) == 0 {
		return []byte(`{}`)
	}
	return raw
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
		case "23505":
			return ErrConflict
		case "23503":
			return ErrNotFound
		case "23514":
			return ErrValidation
		}
	}
	return err
}
