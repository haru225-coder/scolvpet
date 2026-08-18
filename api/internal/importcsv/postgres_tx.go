package importcsv

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	basestore "github.com/scolvpet/scolvpet/api/internal/store"
)

type postgresTx struct {
	tx         pgx.Tx
	currentJob *postgresImportJob
}

var _ Tx = (*postgresTx)(nil)

type postgresImportJob struct {
	ID         uuid.UUID
	AsyncJobID uuid.UUID
	OwnerID    uuid.UUID
	BatchKey   string
	FileSHA256 string
	Status     ImportJobStatus
}

func (tx *postgresTx) FindCommit(ctx context.Context, ownerID, batchKey string) (CommitReceipt, bool, error) {
	ownerUUID, err := uuid.Parse(ownerID)
	if err != nil {
		return CommitReceipt{}, false, err
	}
	var job postgresImportJob
	var resultPayload []byte
	err = tx.tx.QueryRow(ctx, `
		SELECT ij.id, ij.async_job_id, ij.owner_id, ij.idempotency_batch_key,
			ij.file_sha256, ij.status, aj.result_payload
		FROM import_job ij
		JOIN async_job aj ON aj.owner_id=ij.owner_id AND aj.id=ij.async_job_id
		WHERE ij.owner_id=$1 AND ij.idempotency_batch_key=$2
		FOR UPDATE OF ij, aj
	`, ownerUUID, batchKey).Scan(&job.ID, &job.AsyncJobID, &job.OwnerID, &job.BatchKey, &job.FileSHA256, &job.Status, &resultPayload)
	if errors.Is(err, pgx.ErrNoRows) {
		return CommitReceipt{}, false, ErrImportJobNotFound
	}
	if err != nil {
		return CommitReceipt{}, false, err
	}
	tx.currentJob = &job
	if job.Status == ImportJobSucceeded || job.Status == ImportJobPartiallySucceeded {
		var receipt CommitReceipt
		if err := json.Unmarshal(resultPayload, &receipt); err != nil {
			return CommitReceipt{}, false, fmt.Errorf("解析已提交 receipt: %w", err)
		}
		if receipt.JobID == "" {
			receipt.JobID = job.ID.String()
		}
		if receipt.AsyncJobID == "" {
			receipt.AsyncJobID = job.AsyncJobID.String()
		}
		return receipt, true, nil
	}
	if job.Status != ImportJobReady {
		return CommitReceipt{}, false, fmt.Errorf("%w: status=%s", ErrImportJobNotReady, job.Status)
	}
	if _, err := tx.tx.Exec(ctx, `
		UPDATE import_job SET status='applying', updated_at=now()
		WHERE owner_id=$1 AND id=$2
	`, job.OwnerID, job.ID); err != nil {
		return CommitReceipt{}, false, err
	}
	if _, err := tx.tx.Exec(ctx, `
		UPDATE async_job SET status='running', progress_percent=75,
			started_at=COALESCE(started_at,now()), finished_at=NULL,
			error_code=NULL, error_detail=NULL, updated_at=now()
		WHERE owner_id=$1 AND id=$2
	`, job.OwnerID, job.AsyncJobID); err != nil {
		return CommitReceipt{}, false, err
	}
	return CommitReceipt{}, false, nil
}

func (tx *postgresTx) Apply(ctx context.Context, operation Operation) error {
	switch operation.Kind {
	case OperationCreateHamster:
		return tx.createHamster(ctx, operation.Hamster)
	case OperationUpdateHamster:
		return tx.updateHamster(ctx, operation.HamsterUpdate)
	case OperationCreateEnclosure:
		return tx.createEnclosure(ctx, operation.Enclosure)
	case OperationUpdateEnclosure:
		return tx.updateEnclosure(ctx, operation.EnclosureUpdate)
	case OperationCreateEnclosureStay:
		return tx.createEnclosureStay(ctx, operation.EnclosureStay)
	case OperationCreateLitter:
		return tx.createLitter(ctx, operation.Litter)
	case OperationCreateLitterParent:
		return tx.createLitterParent(ctx, operation.LitterParent)
	case OperationCreateLitterMember:
		return tx.createLitterMember(ctx, operation.LitterMember)
	case OperationCreatePedigreeParentage:
		return tx.createPedigreeParentage(ctx, operation.PedigreeParentage)
	case OperationCreateWeightRecord:
		return tx.createWeightRecord(ctx, operation.WeightRecord)
	default:
		return fmt.Errorf("importcsv: 未支持的 PostgreSQL operation %q", operation.Kind)
	}
}

func (tx *postgresTx) SaveCommit(ctx context.Context, receipt CommitReceipt) error {
	if tx.currentJob == nil {
		return ErrImportJobNotReady
	}
	job := tx.currentJob
	if job.FileSHA256 != receipt.FileSHA256 {
		return ErrBatchKeyConflict
	}
	receipt.JobID = job.ID.String()
	receipt.AsyncJobID = job.AsyncJobID.String()
	imported, skipped := 0, 0
	for _, row := range receipt.Rows {
		switch row.Status {
		case RowImported:
			imported++
		case RowSkipped:
			skipped++
		}
		var targetID any
		if parsed, err := uuid.Parse(row.ResourceID); err == nil {
			targetID = parsed
		}
		command, err := tx.tx.Exec(ctx, `
			UPDATE import_row SET status=$4, target_table=$5, target_id=$6,
				result_payload=$7, processed_at=now(), updated_at=now()
			WHERE owner_id=$1 AND import_job_id=$2 AND row_number=$3
		`, job.OwnerID, job.ID, row.RowNumber, row.Status, targetTableForTemplate(receipt.Template), targetID, jsonValue(row))
		if err != nil {
			return err
		}
		if command.RowsAffected() != 1 {
			return fmt.Errorf("importcsv: import_row %d 不存在", row.RowNumber)
		}
	}
	conflictPolicy := jsonValue(map[string]any{
		"preflight_version":      receipt.PreflightVersion,
		"plan_hash":              receipt.PlanHash,
		"approved_updates":       receipt.ApprovedUpdates,
		"partial_failure_policy": "rollback_all",
	})
	command, err := tx.tx.Exec(ctx, `
		UPDATE import_job SET status='succeeded', imported_rows=$3, skipped_rows=$4,
			conflict_policy=conflict_policy || $5::jsonb, applied_at=$6, updated_at=now()
		WHERE owner_id=$1 AND id=$2 AND status='applying' AND invalid_rows=0
	`, job.OwnerID, job.ID, imported, skipped, conflictPolicy, receipt.CommittedAt)
	if err != nil {
		return err
	}
	if command.RowsAffected() != 1 {
		return ErrImportJobNotReady
	}
	_, err = tx.tx.Exec(ctx, `
		UPDATE async_job SET status='succeeded', progress_percent=100,
			result_payload=$3, finished_at=$4, error_code=NULL, error_detail=NULL, updated_at=now()
		WHERE owner_id=$1 AND id=$2
	`, job.OwnerID, job.AsyncJobID, jsonValue(receipt), receipt.CommittedAt)
	return err
}

func (tx *postgresTx) createHamster(ctx context.Context, value *HamsterWrite) error {
	if value == nil {
		return errors.New("create_hamster payload 为空")
	}
	id, ownerID, organizationID, ruleID, err := parseFourUUIDs(value.ID, value.OwnerID, value.OrganizationID, value.SpeciesRuleVersionID)
	if err != nil {
		return err
	}
	currentEnclosureID, err := optionalUUID(value.CurrentEnclosureID)
	if err != nil {
		return err
	}
	_, err = tx.tx.Exec(ctx, `
		INSERT INTO hamster (
			id, owner_id, organization_id, internal_code, name, species_rule_version_id,
			variety_code, sex, birth_date, source_type, lifecycle_status, breeding_status,
			current_enclosure_id, tags, notes, created_by, updated_by
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$2,$2)
	`, id, ownerID, organizationID, value.InternalCode, nullString(value.Name), ruleID,
		nullString(value.VarietyCode), value.Sex, value.BirthDate, value.SourceType,
		value.LifecycleStatus, value.BreedingStatus, currentEnclosureID, jsonValue(value.Tags), nullString(value.Notes))
	return err
}

func (tx *postgresTx) updateHamster(ctx context.Context, value *ResourceUpdate) error {
	if value == nil {
		return errors.New("update_hamster payload 为空")
	}
	ownerID, resourceID, err := parseTwoUUIDs(value.OwnerID, value.ID)
	if err != nil {
		return err
	}
	sets := make([]string, 0, len(value.Fields)+1)
	args := []any{ownerID, resourceID, value.ExpectedVersion}
	for field, proposed := range value.Fields {
		var databaseValue any
		switch field {
		case "name", "variety_code", "notes":
			databaseValue = nullString(fmt.Sprint(proposed))
		case "tags":
			databaseValue = jsonValue(proposed)
		case "birth_date":
			parsed, parseErr := valueAsTime(proposed)
			if parseErr != nil {
				return parseErr
			}
			databaseValue = parsed
		default:
			return fmt.Errorf("update_hamster 不允许字段 %q", field)
		}
		args = append(args, databaseValue)
		sets = append(sets, fmt.Sprintf("%s=$%d", field, len(args)))
	}
	if len(sets) == 0 {
		return nil
	}
	sets = append(sets, "updated_by=$1")
	query := `UPDATE hamster SET ` + strings.Join(sets, ",") + `
		WHERE owner_id=$1 AND id=$2 AND version=$3 AND deleted_at IS NULL`
	command, err := tx.tx.Exec(ctx, query, args...)
	if err != nil {
		return err
	}
	if command.RowsAffected() != 1 {
		return &basestore.VersionError{Current: value.ExpectedVersion}
	}
	return nil
}

func (tx *postgresTx) createEnclosure(ctx context.Context, value *EnclosureWrite) error {
	if value == nil {
		return errors.New("create_enclosure payload 为空")
	}
	id, ownerID, organizationID, err := parseThreeUUIDs(value.ID, value.OwnerID, value.OrganizationID)
	if err != nil {
		return err
	}
	_, err = tx.tx.Exec(ctx, `
		INSERT INTO enclosure (
			id, owner_id, organization_id, code, rack_code, level_code, capacity,
			state, cleanliness, last_cleaned_at, disabled_reason, created_by, updated_by
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$2,$2)
	`, id, ownerID, organizationID, value.Code, nullString(value.RackCode), nullString(value.LevelCode),
		value.Capacity, value.State, value.Cleanliness, value.LastCleanedAt, nullString(value.DisabledReason))
	return err
}

func (tx *postgresTx) updateEnclosure(ctx context.Context, value *ResourceUpdate) error {
	if value == nil {
		return errors.New("update_enclosure payload 为空")
	}
	ownerID, resourceID, err := parseTwoUUIDs(value.OwnerID, value.ID)
	if err != nil {
		return err
	}
	sets := make([]string, 0, len(value.Fields)+1)
	args := []any{ownerID, resourceID, value.ExpectedVersion}
	for field, proposed := range value.Fields {
		var databaseValue any
		switch field {
		case "rack_code", "level_code", "disabled_reason":
			databaseValue = nullString(fmt.Sprint(proposed))
		case "cleanliness":
			databaseValue = fmt.Sprint(proposed)
		case "last_cleaned_at":
			parsed, parseErr := valueAsTime(proposed)
			if parseErr != nil {
				return parseErr
			}
			databaseValue = parsed
		default:
			return fmt.Errorf("update_enclosure 不允许字段 %q", field)
		}
		args = append(args, databaseValue)
		sets = append(sets, fmt.Sprintf("%s=$%d", field, len(args)))
	}
	if len(sets) == 0 {
		return nil
	}
	sets = append(sets, "updated_by=$1")
	query := `UPDATE enclosure SET ` + strings.Join(sets, ",") + `
		WHERE owner_id=$1 AND id=$2 AND version=$3 AND deleted_at IS NULL`
	command, err := tx.tx.Exec(ctx, query, args...)
	if err != nil {
		return err
	}
	if command.RowsAffected() != 1 {
		return &basestore.VersionError{Current: value.ExpectedVersion}
	}
	return nil
}

func (tx *postgresTx) createEnclosureStay(ctx context.Context, value *EnclosureStayWrite) error {
	if value == nil {
		return errors.New("create_enclosure_stay payload 为空")
	}
	id, ownerID, enclosureID, hamsterID, err := parseFourUUIDs(value.ID, value.OwnerID, value.EnclosureID, value.HamsterID)
	if err != nil {
		return err
	}
	operatorID, err := uuid.Parse(value.OperatorID)
	if err != nil {
		return err
	}
	var currentEnclosureID *uuid.UUID
	if err := tx.tx.QueryRow(ctx, `
		SELECT current_enclosure_id FROM hamster
		WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL FOR UPDATE
	`, ownerID, hamsterID).Scan(&currentEnclosureID); err != nil {
		return err
	}
	if currentEnclosureID != nil && *currentEnclosureID != enclosureID {
		return fmt.Errorf("hamster already occupies another enclosure")
	}
	var capacity int
	var enclosureState string
	if err := tx.tx.QueryRow(ctx, `
		SELECT capacity, state FROM enclosure
		WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL FOR UPDATE
	`, ownerID, enclosureID).Scan(&capacity, &enclosureState); err != nil {
		return err
	}
	if enclosureState == "disabled" {
		return fmt.Errorf("enclosure is disabled")
	}
	var overlapping int
	if err := tx.tx.QueryRow(ctx, `
		SELECT count(*) FROM enclosure_stay
		WHERE owner_id=$1 AND enclosure_id=$2 AND deleted_at IS NULL
			AND tstzrange(started_at, ended_at, '[)') && tstzrange($3, NULL, '[)')
	`, ownerID, enclosureID, value.StartedAt).Scan(&overlapping); err != nil {
		return err
	}
	var existingStay bool
	if err := tx.tx.QueryRow(ctx, `
		SELECT EXISTS (
			SELECT 1 FROM enclosure_stay
			WHERE owner_id=$1 AND enclosure_id=$2 AND hamster_id=$3
				AND ended_at IS NULL AND deleted_at IS NULL
		)
	`, ownerID, enclosureID, hamsterID).Scan(&existingStay); err != nil {
		return err
	}
	effectiveCapacity := capacity
	if value.Purpose == "single" {
		effectiveCapacity = 1
	}
	if !existingStay && overlapping >= effectiveCapacity {
		return fmt.Errorf("enclosure capacity conflict")
	}
	if !existingStay {
		if _, err := tx.tx.Exec(ctx, `
			INSERT INTO enclosure_stay (
				id, owner_id, enclosure_id, hamster_id, purpose, started_at,
				operator_id, reason
			) VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
		`, id, ownerID, enclosureID, hamsterID, value.Purpose, value.StartedAt, operatorID, nullString(value.Reason)); err != nil {
			return err
		}
	}
	if currentEnclosureID == nil {
		command, err := tx.tx.Exec(ctx, `
			UPDATE hamster SET current_enclosure_id=$3, updated_by=$1
			WHERE owner_id=$1 AND id=$2 AND current_enclosure_id IS NULL AND deleted_at IS NULL
		`, ownerID, hamsterID, enclosureID)
		if err != nil {
			return err
		}
		if command.RowsAffected() != 1 {
			return fmt.Errorf("hamster enclosure changed during import")
		}
	}
	_, err = tx.tx.Exec(ctx, `
		UPDATE enclosure SET state=CASE WHEN state='vacant' THEN 'occupied_single' ELSE state END,
			updated_by=$1 WHERE owner_id=$1 AND id=$2
	`, ownerID, enclosureID)
	return err
}

func (tx *postgresTx) createLitter(ctx context.Context, value *LitterWrite) error {
	if value == nil || value.Origin != "import" || value.State != "closed" || strings.TrimSpace(value.Code) == "" {
		return errors.New("create_litter 必须是 origin=import/state=closed 且 code 非空")
	}
	id, ownerID, organizationID, err := parseThreeUUIDs(value.ID, value.OwnerID, value.OrganizationID)
	if err != nil {
		return err
	}
	damCondition := value.DamCondition
	if damCondition == nil {
		damCondition = map[string]any{}
	}
	_, err = tx.tx.Exec(ctx, `
		INSERT INTO litter (
			id, owner_id, organization_id, breeding_plan_id, origin, code, state,
			born_at, enclosure_id, dam_condition, initial_alive_count,
			initial_other_count, current_managed_count, created_by, updated_by
		) VALUES ($1,$2,$3,NULL,'import',$4,'closed',$5,NULL,$6,$7,$8,$9,$2,$2)
	`, id, ownerID, organizationID, value.Code, value.BornAt, jsonValue(damCondition),
		value.InitialAliveCount, value.InitialOtherCount, value.CurrentManagedCount)
	return err
}

func (tx *postgresTx) createLitterParent(ctx context.Context, value *LitterParentWrite) error {
	if value == nil {
		return errors.New("create_litter_parent payload 为空")
	}
	id, ownerID, litterID, parentID, err := parseFourUUIDs(value.ID, value.OwnerID, value.LitterID, value.ParentID)
	if err != nil {
		return err
	}
	_, err = tx.tx.Exec(ctx, `
		INSERT INTO litter_parent (
			id, owner_id, litter_id, parent_id, role, evidence_type,
			evidence_payload, confidence, status, valid_from, created_by, updated_by
		) VALUES ($1,$2,$3,$4,$5,$6,$7,1,'accepted',now(),$2,$2)
	`, id, ownerID, litterID, parentID, value.Role, value.Evidence, jsonValue(map[string]any{"source": "csv_import"}))
	return err
}

func (tx *postgresTx) createLitterMember(ctx context.Context, value *LitterMemberWrite) error {
	if value == nil {
		return errors.New("create_litter_member payload 为空")
	}
	id, ownerID, litterID, hamsterID, err := parseFourUUIDs(value.ID, value.OwnerID, value.LitterID, value.HamsterID)
	if err != nil {
		return err
	}
	_, err = tx.tx.Exec(ctx, `
		INSERT INTO litter_member (
			id, owner_id, litter_id, member_type, hamster_id, evidence_type,
			evidence_payload, confidence, status, valid_from, created_by, updated_by
		) VALUES ($1,$2,$3,'hamster',$4,$5,$6,1,'accepted',now(),$2,$2)
	`, id, ownerID, litterID, hamsterID, value.Evidence, jsonValue(map[string]any{"source": "csv_import"}))
	return err
}

func (tx *postgresTx) createPedigreeParentage(ctx context.Context, value *PedigreeParentageWrite) error {
	if value == nil {
		return errors.New("create_pedigree_parentage payload 为空")
	}
	id, ownerID, parentID, childID, err := parseFourUUIDs(value.ID, value.OwnerID, value.ParentID, value.ChildID)
	if err != nil {
		return err
	}
	if _, err := tx.tx.Exec(ctx, `SELECT pg_advisory_xact_lock(hashtextextended($1, 0))`, value.OwnerID); err != nil {
		return err
	}
	var cycle bool
	err = tx.tx.QueryRow(ctx, `
		SELECT $2::uuid=$3::uuid OR EXISTS (
			WITH RECURSIVE descendants(hamster_id) AS (
				SELECT child_id FROM pedigree_parentage
				WHERE owner_id=$1 AND parent_id=$3::uuid AND status='accepted' AND valid_to IS NULL
				UNION
				SELECT pp.child_id FROM pedigree_parentage pp
				JOIN descendants d ON pp.parent_id=d.hamster_id
				WHERE pp.owner_id=$1 AND pp.status='accepted' AND pp.valid_to IS NULL
			)
			SELECT 1 FROM descendants WHERE hamster_id=$2::uuid
		)
	`, ownerID, parentID, childID).Scan(&cycle)
	if err != nil {
		return err
	}
	if cycle {
		return fmt.Errorf("pedigree cycle detected")
	}
	_, err = tx.tx.Exec(ctx, `
		INSERT INTO pedigree_parentage (
			id, owner_id, parent_id, child_id, role, evidence_type, evidence_payload,
			confidence, status, valid_from, created_by, updated_by
		) VALUES ($1,$2,$3,$4,$5,$6,$7,1,'accepted',now(),$2,$2)
	`, id, ownerID, parentID, childID, value.Role, value.Evidence, jsonValue(map[string]any{"source": "csv_import"}))
	return err
}

func (tx *postgresTx) createWeightRecord(ctx context.Context, value *WeightRecordWrite) error {
	if value == nil {
		return errors.New("create_weight_record payload 为空")
	}
	id, ownerID, organizationID, operatorID, err := parseFourUUIDs(value.ID, value.OwnerID, value.OrganizationID, value.OperatorID)
	if err != nil {
		return err
	}
	hamsterID, err := optionalUUID(value.HamsterID)
	if err != nil {
		return err
	}
	litterID, err := optionalUUID(value.LitterID)
	if err != nil {
		return err
	}
	var speciesRuleID *uuid.UUID
	switch value.SubjectType {
	case "hamster":
		if hamsterID == nil || litterID != nil || value.MeasurementKind != "individual" || value.SubjectCount != nil {
			return errors.New("非法 hamster weight subject")
		}
		if err := tx.tx.QueryRow(ctx, `
			SELECT species_rule_version_id FROM hamster
			WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
		`, ownerID, *hamsterID).Scan(&speciesRuleID); err != nil {
			return err
		}
	case "litter":
		if litterID == nil || hamsterID != nil || !validEnum(value.MeasurementKind, "litter_total", "litter_average") || value.SubjectCount == nil || *value.SubjectCount <= 0 {
			return errors.New("非法 litter weight subject")
		}
		if err := tx.tx.QueryRow(ctx, `
			SELECT bp.species_rule_version_id
			FROM litter l LEFT JOIN breeding_plan bp ON bp.owner_id=l.owner_id AND bp.id=l.breeding_plan_id
			WHERE l.owner_id=$1 AND l.id=$2 AND l.deleted_at IS NULL
		`, ownerID, *litterID).Scan(&speciesRuleID); err != nil {
			return err
		}
	default:
		return errors.New("未知 weight subject_type")
	}
	_, err = tx.tx.Exec(ctx, `
		INSERT INTO weight_record (
			id, owner_id, organization_id, subject_type, hamster_id, litter_id,
			measurement_kind, subject_count, weight_g, recorded_at, source,
			acquisition_key, species_rule_version_id, alert_flags, operator_id
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,'import',$11,$12,$13,$14)
	`, id, ownerID, organizationID, value.SubjectType, hamsterID, litterID,
		value.MeasurementKind, value.SubjectCount, value.WeightG, value.RecordedAt,
		nullString(value.AcquisitionKey), speciesRuleID, jsonValue([]string{}), operatorID)
	return err
}

func parseFourUUIDs(first, second, third, fourth string) (uuid.UUID, uuid.UUID, uuid.UUID, uuid.UUID, error) {
	values := []string{first, second, third, fourth}
	parsed := make([]uuid.UUID, len(values))
	for index, value := range values {
		current, err := uuid.Parse(value)
		if err != nil {
			return uuid.Nil, uuid.Nil, uuid.Nil, uuid.Nil, err
		}
		parsed[index] = current
	}
	return parsed[0], parsed[1], parsed[2], parsed[3], nil
}

func parseThreeUUIDs(first, second, third string) (uuid.UUID, uuid.UUID, uuid.UUID, error) {
	one, two, three, _, err := parseFourUUIDs(first, second, third, uuid.Nil.String())
	return one, two, three, err
}

func parseTwoUUIDs(first, second string) (uuid.UUID, uuid.UUID, error) {
	one, two, _, err := parseThreeUUIDs(first, second, uuid.Nil.String())
	return one, two, err
}

func valueAsTime(value any) (*time.Time, error) {
	switch current := value.(type) {
	case nil:
		return nil, nil
	case time.Time:
		return &current, nil
	case *time.Time:
		return current, nil
	case string:
		parsed, err := time.Parse(time.RFC3339Nano, current)
		if err != nil {
			return nil, err
		}
		return &parsed, nil
	default:
		return nil, fmt.Errorf("无法转换时间值 %T", value)
	}
}
