package i2core

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"sort"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/scolvpet/scolvpet/api/internal/store"
)

type PostgresRepository struct {
	pool *pgxpool.Pool
}

type postgresTransaction struct {
	tx pgx.Tx
}

type storedCommandResponse struct {
	Body json.RawMessage `json:"body"`
}

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
	hash := sha256.Sum256([]byte(canonicalCommand(command.Method, command.Path, command.Payload)))
	hashHex := hex.EncodeToString(hash[:])
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return CommandResult{}, err
	}
	defer func() { _ = tx.Rollback(ctx) }()

	var existingHash, status string
	var responseStatus *int
	var responseBody []byte
	err = tx.QueryRow(ctx, `
		SELECT request_hash, status, response_status, response_body
		FROM idempotency_record
		WHERE owner_id=$1 AND idempotency_key=$2
		FOR UPDATE
	`, command.OwnerID, command.IdempotencyKey).Scan(&existingHash, &status, &responseStatus, &responseBody)
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
		return CommandResult{Body: decodeCommandResponse(responseBody), Status: *responseStatus, Replayed: true}, nil
	}
	if !errors.Is(err, pgx.ErrNoRows) {
		return CommandResult{}, mapPostgresError(err)
	}

	_, err = tx.Exec(ctx, `
		INSERT INTO idempotency_record
		(owner_id, idempotency_key, request_method, request_path, request_hash, status, expires_at)
		VALUES ($1,$2,$3,$4,$5,'processing',now()+interval '24 hours')
	`, command.OwnerID, command.IdempotencyKey, strings.ToUpper(command.Method), command.Path, hashHex)
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
	storedBytes, err := json.Marshal(storedCommandResponse{Body: bodyBytes})
	if err != nil {
		return CommandResult{}, err
	}
	_, err = tx.Exec(ctx, `
		UPDATE idempotency_record
		SET status='completed', response_status=$3, response_body=$4, completed_at=now(), updated_at=now()
		WHERE owner_id=$1 AND idempotency_key=$2
	`, command.OwnerID, command.IdempotencyKey, command.SuccessStatus, storedBytes)
	if err != nil {
		return CommandResult{}, mapPostgresError(err)
	}
	if err := tx.Commit(ctx); err != nil {
		return CommandResult{}, mapPostgresError(err)
	}
	return CommandResult{Body: bodyBytes, Status: command.SuccessStatus}, nil
}

func (t *postgresTransaction) OrganizationID(ctx context.Context, ownerID uuid.UUID) (uuid.UUID, error) {
	var organizationID uuid.UUID
	err := t.tx.QueryRow(ctx, `
		SELECT id FROM organization
		WHERE owner_id=$1 AND deleted_at IS NULL
		ORDER BY created_at LIMIT 1
	`, ownerID).Scan(&organizationID)
	return organizationID, mapPostgresError(err)
}

func (t *postgresTransaction) SpeciesRuleExists(ctx context.Context, ownerID, ruleID uuid.UUID) (bool, error) {
	var exists bool
	err := t.tx.QueryRow(ctx, `
		SELECT EXISTS (
			SELECT 1 FROM species_rule_version
			WHERE id=$1 AND status='published'
			  AND (scope='system' OR (scope='owner' AND owner_id=$2))
		)
	`, ruleID, ownerID).Scan(&exists)
	return exists, mapPostgresError(err)
}

func (t *postgresTransaction) GetHamsterForUpdate(ctx context.Context, ownerID, hamsterID uuid.UUID) (Hamster, error) {
	return scanHamster(t.tx.QueryRow(ctx, hamsterSelect+` WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL FOR UPDATE`, ownerID, hamsterID))
}

func (t *postgresTransaction) InsertHamster(ctx context.Context, ownerID, organizationID uuid.UUID, input CreateHamsterInput) (Hamster, error) {
	row := t.tx.QueryRow(ctx, `
		INSERT INTO hamster (
			owner_id, organization_id, internal_code, name, species_rule_version_id,
			variety_code, sex, sex_confidence, birth_date, source_type,
			lifecycle_status, breeding_status, phenotype, tags, notes, created_by, updated_by
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$1,$1)
		RETURNING id, owner_id, organization_id, internal_code, name, species_rule_version_id,
			variety_code, sex, sex_confidence, birth_date, source_type, lifecycle_status,
			breeding_status, current_enclosure_id, phenotype, tags, notes, version, created_at, updated_at
	`, ownerID, organizationID, input.InternalCode, input.Name, input.SpeciesRuleVersionID,
		input.VarietyCode, input.Sex, input.SexConfidence, input.BirthDate, input.SourceType,
		input.LifecycleStatus, input.BreedingStatus, jsonBytes(input.Phenotype), jsonBytes(input.Tags), input.Notes)
	hamster, err := scanHamster(row)
	return hamster, mapPostgresError(err)
}

func (t *postgresTransaction) UpdateHamster(ctx context.Context, ownerID, hamsterID uuid.UUID, expectedVersion int, input UpdateHamsterInput) (Hamster, error) {
	sets := []string{"updated_by=$1"}
	args := []any{ownerID, hamsterID, expectedVersion}
	add := func(column string, value any) {
		args = append(args, value)
		sets = append(sets, fmt.Sprintf("%s=$%d", column, len(args)))
	}
	if input.InternalCode != nil {
		add("internal_code", *input.InternalCode)
	}
	if input.ClearName {
		sets = append(sets, "name=NULL")
	} else if input.Name != nil {
		add("name", *input.Name)
	}
	if input.ClearVariety {
		sets = append(sets, "variety_code=NULL")
	} else if input.VarietyCode != nil {
		add("variety_code", *input.VarietyCode)
	}
	if input.Sex != nil {
		add("sex", *input.Sex)
	}
	if input.ClearSexConfidence {
		sets = append(sets, "sex_confidence=NULL")
	} else if input.SexConfidence != nil {
		add("sex_confidence", *input.SexConfidence)
	}
	if input.ClearBirthDate {
		sets = append(sets, "birth_date=NULL")
	} else if input.BirthDate != nil {
		add("birth_date", *input.BirthDate)
	}
	if input.Phenotype != nil {
		add("phenotype", jsonBytes(input.Phenotype))
	}
	if input.Tags != nil {
		add("tags", jsonBytes(input.Tags))
	}
	if input.ClearNotes {
		sets = append(sets, "notes=NULL")
	} else if input.Notes != nil {
		add("notes", *input.Notes)
	}
	query := `UPDATE hamster SET ` + strings.Join(sets, ",") + `
		WHERE owner_id=$1 AND id=$2 AND version=$3 AND deleted_at IS NULL
		RETURNING id, owner_id, organization_id, internal_code, name, species_rule_version_id,
			variety_code, sex, sex_confidence, birth_date, source_type, lifecycle_status,
			breeding_status, current_enclosure_id, phenotype, tags, notes, version, created_at, updated_at`
	hamster, err := scanHamster(t.tx.QueryRow(ctx, query, args...))
	return hamster, mapVersionedWriteError(err)
}

func (t *postgresTransaction) UpdateHamsterEnclosure(ctx context.Context, ownerID, hamsterID uuid.UUID, expectedVersion int, enclosureID *uuid.UUID) (Hamster, error) {
	hamster, err := scanHamster(t.tx.QueryRow(ctx, `
		UPDATE hamster SET current_enclosure_id=$4, updated_by=$1
		WHERE owner_id=$1 AND id=$2 AND version=$3 AND deleted_at IS NULL
		RETURNING id, owner_id, organization_id, internal_code, name, species_rule_version_id,
			variety_code, sex, sex_confidence, birth_date, source_type, lifecycle_status,
			breeding_status, current_enclosure_id, phenotype, tags, notes, version, created_at, updated_at
	`, ownerID, hamsterID, expectedVersion, enclosureID))
	return hamster, mapVersionedWriteError(err)
}

func (t *postgresTransaction) GetEnclosureForUpdate(ctx context.Context, ownerID, enclosureID uuid.UUID) (Enclosure, error) {
	return scanEnclosure(t.tx.QueryRow(ctx, enclosureSelect+` WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL FOR UPDATE`, ownerID, enclosureID))
}

func (t *postgresTransaction) LockEnclosures(ctx context.Context, ownerID uuid.UUID, enclosureIDs ...uuid.UUID) error {
	unique := make(map[uuid.UUID]struct{}, len(enclosureIDs))
	for _, enclosureID := range enclosureIDs {
		unique[enclosureID] = struct{}{}
	}
	ids := make([]uuid.UUID, 0, len(unique))
	for enclosureID := range unique {
		ids = append(ids, enclosureID)
	}
	sort.Slice(ids, func(i, j int) bool { return ids[i].String() < ids[j].String() })
	rows, err := t.tx.Query(ctx, `
		SELECT id FROM enclosure
		WHERE owner_id=$1 AND id=ANY($2::uuid[]) AND deleted_at IS NULL
		ORDER BY id FOR UPDATE
	`, ownerID, ids)
	if err != nil {
		return mapPostgresError(err)
	}
	defer rows.Close()
	count := 0
	for rows.Next() {
		count++
	}
	if err := rows.Err(); err != nil {
		return mapPostgresError(err)
	}
	if count != len(ids) {
		return ErrNotFound
	}
	return nil
}

func (t *postgresTransaction) InsertEnclosure(ctx context.Context, ownerID, organizationID uuid.UUID, input CreateEnclosureInput) (Enclosure, error) {
	enclosure, err := scanEnclosure(t.tx.QueryRow(ctx, `
		INSERT INTO enclosure (
			owner_id, organization_id, code, rack_code, level_code, capacity, state,
			cleanliness, size_mm, equipment, last_cleaned_at, disabled_reason, created_by, updated_by
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$1,$1)
		RETURNING id, owner_id, organization_id, code, rack_code, level_code, capacity,
			state, cleanliness, size_mm, equipment, last_cleaned_at, disabled_reason,
			version, created_at, updated_at
	`, ownerID, organizationID, input.Code, input.RackCode, input.LevelCode, input.Capacity, input.State,
		input.Cleanliness, jsonBytes(input.Dimensions), jsonBytes(input.Equipment), input.LastCleanedAt, input.DisabledReason))
	return enclosure, mapPostgresError(err)
}

func (t *postgresTransaction) UpdateEnclosure(ctx context.Context, ownerID, enclosureID uuid.UUID, expectedVersion int, input UpdateEnclosureInput) (Enclosure, error) {
	sets := []string{"updated_by=$1"}
	args := []any{ownerID, enclosureID, expectedVersion}
	add := func(column string, value any) {
		args = append(args, value)
		sets = append(sets, fmt.Sprintf("%s=$%d", column, len(args)))
	}
	if input.Code != nil {
		add("code", *input.Code)
	}
	if input.ClearRackCode {
		sets = append(sets, "rack_code=NULL")
	} else if input.RackCode != nil {
		add("rack_code", *input.RackCode)
	}
	if input.ClearLevelCode {
		sets = append(sets, "level_code=NULL")
	} else if input.LevelCode != nil {
		add("level_code", *input.LevelCode)
	}
	if input.Capacity != nil {
		add("capacity", *input.Capacity)
	}
	if input.State != nil {
		add("state", *input.State)
	}
	if input.Cleanliness != nil {
		add("cleanliness", *input.Cleanliness)
	}
	if input.Dimensions != nil {
		add("size_mm", jsonBytes(input.Dimensions))
	}
	if input.Equipment != nil {
		add("equipment", jsonBytes(input.Equipment))
	}
	if input.ClearLastCleanedAt {
		sets = append(sets, "last_cleaned_at=NULL")
	} else if input.LastCleanedAt != nil {
		add("last_cleaned_at", *input.LastCleanedAt)
	}
	if input.ClearDisabledReason {
		sets = append(sets, "disabled_reason=NULL")
	} else if input.DisabledReason != nil {
		add("disabled_reason", *input.DisabledReason)
	}
	query := `UPDATE enclosure SET ` + strings.Join(sets, ",") + `
		WHERE owner_id=$1 AND id=$2 AND version=$3 AND deleted_at IS NULL
		RETURNING id, owner_id, organization_id, code, rack_code, level_code, capacity,
			state, cleanliness, size_mm, equipment, last_cleaned_at, disabled_reason,
			version, created_at, updated_at`
	enclosure, err := scanEnclosure(t.tx.QueryRow(ctx, query, args...))
	return enclosure, mapVersionedWriteError(err)
}

func (t *postgresTransaction) RefreshEnclosureState(ctx context.Context, ownerID, enclosureID uuid.UUID, expectedVersion int) (Enclosure, error) {
	enclosure, err := scanEnclosure(t.tx.QueryRow(ctx, `
		UPDATE enclosure e
		SET state = COALESCE((
			SELECT CASE es.purpose
				WHEN 'single' THEN 'occupied_single'::enclosure_state
				WHEN 'pairing_temp' THEN 'pairing_temp'::enclosure_state
				WHEN 'gestation' THEN 'gestation'::enclosure_state
				WHEN 'isolation' THEN 'isolation'::enclosure_state
				WHEN 'dam_with_litter' THEN 'dam_with_litter'::enclosure_state
			END
			FROM enclosure_stay es
			WHERE es.owner_id=$1 AND es.enclosure_id=$2 AND es.ended_at IS NULL AND es.deleted_at IS NULL
			ORDER BY es.started_at DESC LIMIT 1
		), 'vacant'::enclosure_state), updated_by=$1
		WHERE e.owner_id=$1 AND e.id=$2 AND e.version=$3 AND e.deleted_at IS NULL
		RETURNING id, owner_id, organization_id, code, rack_code, level_code, capacity,
			state, cleanliness, size_mm, equipment, last_cleaned_at, disabled_reason,
			version, created_at, updated_at
	`, ownerID, enclosureID, expectedVersion))
	return enclosure, mapVersionedWriteError(err)
}

func (t *postgresTransaction) GetStayForUpdate(ctx context.Context, ownerID, stayID uuid.UUID) (EnclosureStay, error) {
	stay, err := scanStay(t.tx.QueryRow(ctx, staySelect+` WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL FOR UPDATE`, ownerID, stayID))
	return stay, mapPostgresError(err)
}

func (t *postgresTransaction) FindStayConflict(ctx context.Context, ownerID, enclosureID, hamsterID uuid.UUID, startedAt time.Time, endedAt *time.Time, excludeStayID *uuid.UUID, purpose string, pairingAttemptID *uuid.UUID) (StayConflict, error) {
	var conflict StayConflict
	err := t.tx.QueryRow(ctx, `
		SELECT EXISTS (
			SELECT 1 FROM enclosure_stay es
			WHERE es.owner_id=$1 AND es.hamster_id=$2 AND es.deleted_at IS NULL
			  AND ($5::uuid IS NULL OR es.id<>$5)
			  AND tstzrange(es.started_at, es.ended_at, '[)') && tstzrange($3, $4, '[)')
		)
	`, ownerID, hamsterID, startedAt, endedAt, excludeStayID).Scan(&conflict.HamsterConflict)
	if err != nil {
		return StayConflict{}, mapPostgresError(err)
	}
	var capacity, overlapping int
	err = t.tx.QueryRow(ctx, `
		SELECT e.capacity, count(es.id)
		FROM enclosure e
		LEFT JOIN enclosure_stay es
		  ON es.owner_id=e.owner_id AND es.enclosure_id=e.id AND es.deleted_at IS NULL
		 AND ($5::uuid IS NULL OR es.id<>$5)
		 AND tstzrange(es.started_at, es.ended_at, '[)') && tstzrange($3, $4, '[)')
		WHERE e.owner_id=$1 AND e.id=$2 AND e.deleted_at IS NULL
		GROUP BY e.capacity
	`, ownerID, enclosureID, startedAt, endedAt, excludeStayID).Scan(&capacity, &overlapping)
	if err != nil {
		return StayConflict{}, mapPostgresError(err)
	}
	if purpose != "pairing_temp" {
		conflict.EnclosureConflict = overlapping > 0
		return conflict, nil
	}
	var authorized, incompatible bool
	err = t.tx.QueryRow(ctx, `
		SELECT EXISTS (
			SELECT 1 FROM pairing_attempt pa
			WHERE pa.owner_id=$1 AND pa.id=$2 AND pa.pairing_enclosure_id=$3
			  AND $4 IN (pa.sire_id, pa.dam_id) AND pa.status IN ('active','safety_hold') AND pa.deleted_at IS NULL
		), EXISTS (
			SELECT 1 FROM enclosure_stay es
			WHERE es.owner_id=$1 AND es.enclosure_id=$3 AND es.deleted_at IS NULL
			  AND ($7::uuid IS NULL OR es.id<>$7)
			  AND tstzrange(es.started_at, es.ended_at, '[)') && tstzrange($5, $6, '[)')
			  AND (es.purpose<>'pairing_temp' OR es.pairing_attempt_id<>$2)
		)
	`, ownerID, pairingAttemptID, enclosureID, hamsterID, startedAt, endedAt, excludeStayID).Scan(&authorized, &incompatible)
	if err != nil {
		return StayConflict{}, mapPostgresError(err)
	}
	conflict.EnclosureConflict = !authorized || incompatible || overlapping >= min(capacity, 2)
	return conflict, nil
}

func (t *postgresTransaction) InsertStay(ctx context.Context, ownerID uuid.UUID, stay EnclosureStay) (EnclosureStay, error) {
	created, err := scanStay(t.tx.QueryRow(ctx, `
		INSERT INTO enclosure_stay (
			owner_id, enclosure_id, hamster_id, pairing_attempt_id, purpose,
			started_at, ended_at, operator_id, reason, correction_note
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
		RETURNING id, owner_id, enclosure_id, hamster_id, pairing_attempt_id, purpose,
			started_at, ended_at, operator_id, reason, correction_note, version, created_at, updated_at
	`, ownerID, stay.EnclosureID, stay.HamsterID, stay.PairingAttemptID, stay.Purpose,
		stay.StartedAt, stay.EndedAt, stay.OperatorID, stay.Reason, stay.CorrectionNote))
	return created, mapPostgresError(err)
}

func (t *postgresTransaction) EndStay(ctx context.Context, ownerID, stayID uuid.UUID, expectedVersion int, endedAt time.Time, correctionNote *string) (EnclosureStay, error) {
	stay, err := scanStay(t.tx.QueryRow(ctx, `
		UPDATE enclosure_stay
		SET ended_at=$4, correction_note=COALESCE($5, correction_note)
		WHERE owner_id=$1 AND id=$2 AND version=$3 AND ended_at IS NULL AND deleted_at IS NULL
		RETURNING id, owner_id, enclosure_id, hamster_id, pairing_attempt_id, purpose,
			started_at, ended_at, operator_id, reason, correction_note, version, created_at, updated_at
	`, ownerID, stayID, expectedVersion, endedAt, correctionNote))
	return stay, mapVersionedWriteError(err)
}

func (t *postgresTransaction) GetEnclosureCleaningForUpdate(ctx context.Context, ownerID, cleaningID uuid.UUID) (EnclosureCleaning, error) {
	cleaning, err := scanCleaning(t.tx.QueryRow(ctx, cleaningSelect+` WHERE owner_id=$1 AND id=$2 FOR UPDATE`, ownerID, cleaningID))
	return cleaning, mapPostgresError(err)
}

func (t *postgresTransaction) InsertEnclosureCleaning(ctx context.Context, ownerID uuid.UUID, input CreateEnclosureCleaningInput) (EnclosureCleaning, error) {
	cleaning, err := scanCleaning(t.tx.QueryRow(ctx, `
		INSERT INTO enclosure_cleaning_record (
			owner_id, enclosure_id, cleaning_type, performed_at, operator_id,
			supplies, notes, corrects_cleaning_record_id, correction_reason
		) VALUES ($1,$2,$3,$4,$1,$5,$6,$7,$8)
		RETURNING id, owner_id, enclosure_id, cleaning_type, performed_at, operator_id,
			source_event_id, supplies, notes, corrects_cleaning_record_id, correction_reason, created_at
	`, ownerID, input.EnclosureID, input.CleaningType, input.PerformedAt, jsonBytes(input.Supplies),
		input.Notes, input.CorrectsCleaningRecordID, input.CorrectionReason))
	return cleaning, mapPostgresError(err)
}

func (t *postgresTransaction) MarkEnclosureClean(ctx context.Context, ownerID, enclosureID uuid.UUID, expectedVersion int, performedAt time.Time) (Enclosure, error) {
	enclosure, err := scanEnclosure(t.tx.QueryRow(ctx, `
		UPDATE enclosure
		SET cleanliness='clean', last_cleaned_at=CASE
			WHEN last_cleaned_at IS NULL OR last_cleaned_at<$4 THEN $4 ELSE last_cleaned_at END,
			updated_by=$1
		WHERE owner_id=$1 AND id=$2 AND version=$3 AND deleted_at IS NULL
		RETURNING id, owner_id, organization_id, code, rack_code, level_code, capacity,
			state, cleanliness, size_mm, equipment, last_cleaned_at, disabled_reason,
			version, created_at, updated_at
	`, ownerID, enclosureID, expectedVersion, performedAt))
	return enclosure, mapVersionedWriteError(err)
}

func (t *postgresTransaction) ResolveWeightSubject(ctx context.Context, ownerID uuid.UUID, input CreateWeightInput) (WeightSubject, error) {
	var subject WeightSubject
	var err error
	switch input.SubjectType {
	case "hamster":
		err = t.tx.QueryRow(ctx, `
			SELECT organization_id, species_rule_version_id FROM hamster
			WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
		`, ownerID, input.HamsterID).Scan(&subject.OrganizationID, &subject.SpeciesRuleVersionID)
	case "pup_identity":
		err = t.tx.QueryRow(ctx, `
			SELECT l.organization_id, bp.species_rule_version_id
			FROM pup_identity p
			JOIN litter l ON l.owner_id=p.owner_id AND l.id=p.litter_id AND l.deleted_at IS NULL
			LEFT JOIN breeding_plan bp ON bp.owner_id=l.owner_id AND bp.id=l.breeding_plan_id
			WHERE p.owner_id=$1 AND p.id=$2 AND p.deleted_at IS NULL
		`, ownerID, input.PupIdentityID).Scan(&subject.OrganizationID, &subject.SpeciesRuleVersionID)
	case "litter":
		err = t.tx.QueryRow(ctx, `
			SELECT l.organization_id, bp.species_rule_version_id
			FROM litter l
			LEFT JOIN breeding_plan bp ON bp.owner_id=l.owner_id AND bp.id=l.breeding_plan_id
			WHERE l.owner_id=$1 AND l.id=$2 AND l.deleted_at IS NULL
		`, ownerID, input.LitterID).Scan(&subject.OrganizationID, &subject.SpeciesRuleVersionID)
	default:
		return WeightSubject{}, ErrInvalidWeight
	}
	return subject, mapPostgresError(err)
}

func (t *postgresTransaction) PreviousWeights(ctx context.Context, ownerID uuid.UUID, input CreateWeightInput) (*float64, *float64, error) {
	column, id := weightSubjectColumn(input)
	if column == "" {
		return nil, nil, ErrInvalidWeight
	}
	query := fmt.Sprintf(`
		SELECT
			(SELECT weight_g FROM weight_record WHERE owner_id=$1 AND %s=$2 AND recorded_at<=$3 ORDER BY recorded_at, created_at LIMIT 1),
			(SELECT weight_g FROM weight_record WHERE owner_id=$1 AND %s=$2 AND recorded_at<=$3 ORDER BY recorded_at DESC, created_at DESC LIMIT 1)
	`, column, column)
	var birth, previous *float64
	err := t.tx.QueryRow(ctx, query, ownerID, id, input.RecordedAt).Scan(&birth, &previous)
	return birth, previous, mapPostgresError(err)
}

func (t *postgresTransaction) InsertWeight(ctx context.Context, ownerID, organizationID uuid.UUID, input CreateWeightInput, subject WeightSubject, birthWeight, previousWeight *float64) (WeightRecord, error) {
	if birthWeight == nil {
		value := input.WeightG
		birthWeight = &value
	}
	var changeFromBirth, changeFromPrevious *float64
	if birthWeight != nil {
		value := input.WeightG - *birthWeight
		changeFromBirth = &value
	}
	if previousWeight != nil {
		value := input.WeightG - *previousWeight
		changeFromPrevious = &value
	}
	record, err := scanWeight(t.tx.QueryRow(ctx, `
		INSERT INTO weight_record (
			owner_id, organization_id, subject_type, hamster_id, pup_identity_id, litter_id,
			measurement_kind, subject_count, weight_g, recorded_at, source, acquisition_key,
			species_rule_version_id, birth_weight_g, previous_weight_g, change_from_birth_g,
			change_from_previous_g, alert_flags, operator_id, corrects_weight_record_id, correction_reason
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$1,$19,$20)
		RETURNING id, owner_id, organization_id, subject_type, hamster_id, pup_identity_id,
			litter_id, measurement_kind, subject_count, weight_g, recorded_at, source,
			acquisition_key, species_rule_version_id, birth_weight_g, previous_weight_g,
			change_from_birth_g, change_from_previous_g, alert_flags, operator_id,
			corrects_weight_record_id, correction_reason, created_at
	`, ownerID, organizationID, input.SubjectType, input.HamsterID, input.PupIdentityID, input.LitterID,
		input.MeasurementKind, input.SubjectCount, input.WeightG, input.RecordedAt, input.Source, input.AcquisitionKey,
		subject.SpeciesRuleVersionID, birthWeight, previousWeight, changeFromBirth, changeFromPrevious,
		jsonBytes([]string{}), input.CorrectsWeightRecordID, input.CorrectionReason))
	return record, mapPostgresError(err)
}

func (t *postgresTransaction) GetLitterForUpdate(ctx context.Context, ownerID, litterID uuid.UUID) (Litter, error) {
	var lockedID uuid.UUID
	err := t.tx.QueryRow(ctx, `
		SELECT id FROM litter WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL FOR UPDATE
	`, ownerID, litterID).Scan(&lockedID)
	if err != nil {
		return Litter{}, mapPostgresError(err)
	}
	litter, err := scanLitter(t.tx.QueryRow(ctx, litterSelect+` WHERE l.owner_id=$1 AND l.id=$2 AND l.deleted_at IS NULL`, ownerID, litterID))
	return litter, mapPostgresError(err)
}

func (t *postgresTransaction) GetActiveLitterParentForUpdate(ctx context.Context, ownerID, litterID uuid.UUID, role string) (*LitterParent, error) {
	parent, err := scanLitterParent(t.tx.QueryRow(ctx, litterParentSelect+`
		WHERE owner_id=$1 AND litter_id=$2 AND role=$3 AND status='accepted' AND valid_to IS NULL
		FOR UPDATE
	`, ownerID, litterID, role))
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, mapPostgresError(err)
	}
	return &parent, nil
}

func (t *postgresTransaction) SupersedeLitterParent(ctx context.Context, ownerID, litterParentID uuid.UUID, correctionReason string) error {
	result, err := t.tx.Exec(ctx, `
		UPDATE litter_parent
		SET status='superseded', valid_to=now(), correction_note=$3, updated_by=$1
		WHERE owner_id=$1 AND id=$2 AND status='accepted' AND valid_to IS NULL
	`, ownerID, litterParentID, correctionReason)
	if err != nil {
		return mapPostgresError(err)
	}
	if result.RowsAffected() != 1 {
		return ErrVersionConflict
	}
	return nil
}

func (t *postgresTransaction) LitterHamsterMemberIDs(ctx context.Context, ownerID, litterID uuid.UUID) ([]uuid.UUID, error) {
	rows, err := t.tx.Query(ctx, `
		SELECT hamster_id FROM litter_member
		WHERE owner_id=$1 AND litter_id=$2 AND hamster_id IS NOT NULL
		  AND status='accepted' AND valid_to IS NULL
		ORDER BY hamster_id
	`, ownerID, litterID)
	if err != nil {
		return nil, mapPostgresError(err)
	}
	defer rows.Close()
	result := make([]uuid.UUID, 0)
	for rows.Next() {
		var hamsterID uuid.UUID
		if err := rows.Scan(&hamsterID); err != nil {
			return nil, mapPostgresError(err)
		}
		result = append(result, hamsterID)
	}
	return result, mapPostgresError(rows.Err())
}

func (t *postgresTransaction) InsertLitterParent(ctx context.Context, ownerID uuid.UUID, input CreateLitterParentInput, correctsID *uuid.UUID) (LitterParent, error) {
	parent, err := scanLitterParent(t.tx.QueryRow(ctx, `
		INSERT INTO litter_parent (
			owner_id, litter_id, parent_id, role, evidence_type, evidence_payload,
			confidence, status, valid_from, corrects_litter_parent_id, correction_note,
			created_by, updated_by
		) VALUES ($1,$2,$3,$4,$5,$6,$7,'accepted',now(),$8,$9,$1,$1)
		RETURNING id, owner_id, litter_id, parent_id, role, evidence_type, evidence_payload,
			confidence, status, valid_from, valid_to, corrects_litter_parent_id,
			correction_note, version, created_at, updated_at
	`, ownerID, input.LitterID, input.HamsterID, input.Role, input.EvidenceType,
		jsonBytes(input.EvidencePayload), input.Confidence, correctsID, input.CorrectionReason))
	return parent, mapPostgresError(err)
}

func (t *postgresTransaction) TouchLitter(ctx context.Context, ownerID, litterID uuid.UUID, expectedVersion int) (Litter, error) {
	result, err := t.tx.Exec(ctx, `
		UPDATE litter SET updated_by=$1
		WHERE owner_id=$1 AND id=$2 AND version=$3 AND deleted_at IS NULL
	`, ownerID, litterID, expectedVersion)
	if err != nil {
		return Litter{}, mapPostgresError(err)
	}
	if result.RowsAffected() != 1 {
		return Litter{}, ErrVersionConflict
	}
	litter, err := scanLitter(t.tx.QueryRow(ctx, litterSelect+` WHERE l.owner_id=$1 AND l.id=$2 AND l.deleted_at IS NULL`, ownerID, litterID))
	return litter, mapPostgresError(err)
}

func (t *postgresTransaction) CheckPedigreeCycle(ctx context.Context, ownerID, parentID, childID uuid.UUID) (bool, error) {
	if _, err := t.tx.Exec(ctx, `SELECT pg_advisory_xact_lock(hashtextextended($1, 0))`, ownerID.String()); err != nil {
		return false, mapPostgresError(err)
	}
	var cycle bool
	err := t.tx.QueryRow(ctx, `
		SELECT EXISTS (
			WITH RECURSIVE effective_edges(parent_id, child_id) AS (
				SELECT pp.parent_id, pp.child_id
				FROM pedigree_parentage pp
				WHERE pp.owner_id=$1 AND pp.status='accepted' AND pp.valid_to IS NULL
				UNION
				SELECT lp.parent_id, lm.hamster_id
				FROM litter_parent lp
				JOIN litter_member lm ON lm.owner_id=lp.owner_id AND lm.litter_id=lp.litter_id
				WHERE lp.owner_id=$1 AND lp.status='accepted' AND lp.valid_to IS NULL
				  AND lm.status='accepted' AND lm.valid_to IS NULL AND lm.hamster_id IS NOT NULL
			), descendants(hamster_id) AS (
				SELECT ee.child_id FROM effective_edges ee WHERE ee.parent_id=$2
				UNION
				SELECT ee.child_id FROM effective_edges ee
				JOIN descendants d ON ee.parent_id=d.hamster_id
			)
			SELECT 1 FROM descendants WHERE hamster_id=$3
		)
	`, ownerID, childID, parentID).Scan(&cycle)
	return cycle, mapPostgresError(err)
}

func (t *postgresTransaction) InsertPedigreeParentage(ctx context.Context, ownerID uuid.UUID, input CreatePedigreeParentageInput) (PedigreeParentage, error) {
	parentage, err := scanParentage(t.tx.QueryRow(ctx, `
		INSERT INTO pedigree_parentage (
			owner_id, parent_id, child_id, role, evidence_type, evidence_payload,
			confidence, status, valid_from, created_by, updated_by
		) VALUES ($1,$2,$3,$4,$5,$6,$7,'accepted',$8,$1,$1)
		RETURNING id, owner_id, parent_id, child_id, role, evidence_type, evidence_payload,
			confidence, status, valid_from, valid_to, relationship_assertion_id,
			version, created_at, updated_at
	`, ownerID, input.ParentID, input.ChildID, input.Role, input.EvidenceType, jsonBytes(input.EvidencePayload), input.Confidence, input.ValidFrom))
	return parentage, mapPostgresError(err)
}

func (t *postgresTransaction) AppendEvent(ctx context.Context, event DomainEvent) error {
	var version int
	err := t.tx.QueryRow(ctx, `
		SELECT COALESCE(max(event_version),0)+1 FROM domain_event
		WHERE owner_id=$1 AND aggregate_type=$2 AND aggregate_id=$3
	`, event.OwnerID, event.AggregateType, event.AggregateID).Scan(&version)
	if err != nil {
		return mapPostgresError(err)
	}
	var eventID uuid.UUID
	err = t.tx.QueryRow(ctx, `
		INSERT INTO domain_event (
			owner_id, organization_id, aggregate_type, aggregate_id, event_type,
			event_version, actor_id, occurred_at, payload, idempotency_key
		) VALUES ($1,$2,$3,$4,$5,$6,$1,now(),$7,$8)
		RETURNING id
	`, event.OwnerID, event.OrganizationID, event.AggregateType, event.AggregateID, event.EventType,
		version, jsonBytes(event.Payload), event.IdempotencyKey).Scan(&eventID)
	if err != nil {
		return mapPostgresError(err)
	}
	_, err = t.tx.Exec(ctx, `
		INSERT INTO outbox_message (owner_id, domain_event_id, topic, partition_key, payload)
		VALUES ($1,$2,$3,$4,$5)
	`, event.OwnerID, eventID, "domain."+strings.ToLower(event.AggregateType), event.AggregateID.String(), jsonBytes(map[string]any{
		"event_id": eventID, "event_type": event.EventType, "aggregate_type": event.AggregateType,
		"aggregate_id": event.AggregateID, "payload": event.Payload,
	}))
	return mapPostgresError(err)
}

func canonicalCommand(method, path string, payload []byte) string {
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

func decodeCommandResponse(raw []byte) []byte {
	var stored storedCommandResponse
	if json.Unmarshal(raw, &stored) == nil && stored.Body != nil {
		return stored.Body
	}
	return raw
}

func mapVersionedWriteError(err error) error {
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrVersionConflict
	}
	return mapPostgresError(err)
}

func mapPostgresError(err error) error {
	if err == nil {
		return nil
	}
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	var pgErr *pgconn.PgError
	if !errors.As(err, &pgErr) {
		return err
	}
	switch pgErr.Code {
	case "23505":
		return fmt.Errorf("%w: %s", ErrDuplicate, pgErr.ConstraintName)
	case "23P01":
		return fmt.Errorf("%w: %s", ErrStayConflict, pgErr.Message)
	case "23503":
		return ErrNotFound
	case "23514":
		message := strings.ToLower(pgErr.Message + " " + pgErr.ConstraintName)
		if strings.Contains(message, "pedigree") || strings.Contains(message, "parentage_distinct") {
			return fmt.Errorf("%w: %s", ErrPedigreeCycle, pgErr.Message)
		}
		if strings.Contains(message, "weight") {
			return fmt.Errorf("%w: %s", ErrInvalidWeight, pgErr.Message)
		}
		return fmt.Errorf("%w: %s", ErrValidation, pgErr.Message)
	case "40001":
		return ErrVersionConflict
	default:
		return err
	}
}

func jsonBytes(value any) []byte {
	encoded, _ := json.Marshal(value)
	return encoded
}

func weightSubjectColumn(input CreateWeightInput) (string, any) {
	switch input.SubjectType {
	case "hamster":
		return "hamster_id", input.HamsterID
	case "pup_identity":
		return "pup_identity_id", input.PupIdentityID
	case "litter":
		return "litter_id", input.LitterID
	default:
		return "", nil
	}
}
