package i5core

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

	"github.com/scolvpet/scolvpet/api/internal/store"
)

type PostgresRepository struct {
	pool *pgxpool.Pool
}

type command struct {
	OwnerID        uuid.UUID
	IdempotencyKey string
	Method         string
	Path           string
	Payload        []byte
	SuccessStatus  int
}

type commandResult struct {
	Body     []byte
	Status   int
	Replayed bool
}

type storedResponse struct {
	Body json.RawMessage `json:"body"`
}

func NewPostgresRepository(pool *pgxpool.Pool) *PostgresRepository {
	return &PostgresRepository{pool: pool}
}

func NewPostgresRepositoryFromStore(source *store.Store) *PostgresRepository {
	return NewPostgresRepository(source.Pool)
}

func (r *PostgresRepository) execute(ctx context.Context, cmd command, fn func(context.Context, pgx.Tx) (any, error)) (commandResult, error) {
	if strings.TrimSpace(cmd.IdempotencyKey) == "" {
		return commandResult{}, ErrIdempotencyKeyRequired
	}
	hash := sha256.Sum256([]byte(canonicalRequest(cmd.Method, cmd.Path, cmd.Payload)))
	hashHex := hex.EncodeToString(hash[:])
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return commandResult{}, err
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
	`, cmd.OwnerID, cmd.IdempotencyKey).Scan(&existingHash, &status, &responseStatus, &responseBody)
	if err == nil {
		if existingHash != hashHex {
			return commandResult{}, ErrIdempotencyPayloadMismatch
		}
		if status == "processing" || responseStatus == nil || responseBody == nil {
			return commandResult{}, ErrIdempotencyInProgress
		}
		if err := tx.Commit(ctx); err != nil {
			return commandResult{}, err
		}
		return commandResult{Body: decodeStoredResponse(responseBody), Status: *responseStatus, Replayed: true}, nil
	}
	if !errors.Is(err, pgx.ErrNoRows) {
		return commandResult{}, mapPostgresError(err)
	}

	_, err = tx.Exec(ctx, `
		INSERT INTO idempotency_record
		(owner_id, idempotency_key, request_method, request_path, request_hash, status, expires_at)
		VALUES ($1,$2,$3,$4,$5,'processing',now()+interval '24 hours')
	`, cmd.OwnerID, cmd.IdempotencyKey, strings.ToUpper(cmd.Method), cmd.Path, hashHex)
	if err != nil {
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) && pgErr.Code == "23505" {
			return commandResult{}, ErrIdempotencyInProgress
		}
		return commandResult{}, mapPostgresError(err)
	}

	body, err := fn(ctx, tx)
	if err != nil {
		return commandResult{}, err
	}
	bodyBytes, err := json.Marshal(body)
	if err != nil {
		return commandResult{}, err
	}
	storedBytes, err := json.Marshal(storedResponse{Body: bodyBytes})
	if err != nil {
		return commandResult{}, err
	}
	_, err = tx.Exec(ctx, `
		UPDATE idempotency_record
		SET status='completed', response_status=$3, response_body=$4, completed_at=now(), updated_at=now()
		WHERE owner_id=$1 AND idempotency_key=$2
	`, cmd.OwnerID, cmd.IdempotencyKey, cmd.SuccessStatus, storedBytes)
	if err != nil {
		return commandResult{}, mapPostgresError(err)
	}
	if err := tx.Commit(ctx); err != nil {
		return commandResult{}, err
	}
	return commandResult{Body: bodyBytes, Status: cmd.SuccessStatus}, nil
}

func (r *PostgresRepository) listHealthRecords(ctx context.Context, ownerID uuid.UUID, filter HealthRecordFilter) ([]HealthRecord, error) {
	query := healthRecordSelect + ` WHERE owner_id=$1`
	args := []any{ownerID}
	if filter.HamsterID != nil {
		args = append(args, *filter.HamsterID)
		query += fmt.Sprintf(" AND hamster_id=$%d", len(args))
	}
	if filter.LitterID != nil {
		args = append(args, *filter.LitterID)
		query += fmt.Sprintf(" AND litter_id=$%d", len(args))
	}
	if filter.Type != "" {
		args = append(args, filter.Type)
		query += fmt.Sprintf(" AND record_type=$%d", len(args))
	}
	args = append(args, filter.Page.Limit, filter.Page.Offset)
	query += fmt.Sprintf(" ORDER BY observed_at DESC, created_at DESC, id DESC LIMIT $%d OFFSET $%d", len(args)-1, len(args))
	rows, err := r.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, mapPostgresError(err)
	}
	defer rows.Close()
	result := make([]HealthRecord, 0)
	for rows.Next() {
		record, scanErr := scanHealthRecord(rows)
		if scanErr != nil {
			return nil, scanErr
		}
		result = append(result, record)
	}
	return result, mapPostgresError(rows.Err())
}

func (r *PostgresRepository) getHealthRecord(ctx context.Context, ownerID, recordID uuid.UUID) (HealthRecord, error) {
	record, err := scanHealthRecord(r.pool.QueryRow(ctx, healthRecordSelect+` WHERE owner_id=$1 AND id=$2`, ownerID, recordID))
	return record, mapPostgresError(err)
}

func (r *PostgresRepository) listTasks(ctx context.Context, ownerID uuid.UUID, filter CareTaskFilter) ([]CareTask, error) {
	query := careTaskSelect + ` WHERE t.owner_id=$1`
	args := []any{ownerID}
	if filter.State != "" {
		args = append(args, filter.State)
		query += fmt.Sprintf(" AND t.status=$%d", len(args))
	}
	if filter.Priority != "" {
		args = append(args, filter.Priority)
		query += fmt.Sprintf(" AND t.priority=$%d", len(args))
	}
	if filter.TargetType != "" {
		args = append(args, filter.TargetType)
		query += fmt.Sprintf(" AND t.target_type=$%d", len(args))
	}
	if filter.DueBefore != nil {
		args = append(args, *filter.DueBefore)
		query += fmt.Sprintf(" AND t.scheduled_at <= $%d", len(args))
	}
	args = append(args, filter.Page.Limit, filter.Page.Offset)
	query += fmt.Sprintf(" ORDER BY t.scheduled_at ASC, t.created_at DESC, t.id DESC LIMIT $%d OFFSET $%d", len(args)-1, len(args))
	rows, err := r.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, mapPostgresError(err)
	}
	defer rows.Close()
	result := make([]CareTask, 0)
	for rows.Next() {
		task, scanErr := scanCareTask(rows)
		if scanErr != nil {
			return nil, scanErr
		}
		result = append(result, task)
	}
	return result, mapPostgresError(rows.Err())
}

func (r *PostgresRepository) getTask(ctx context.Context, ownerID, taskID uuid.UUID) (CareTask, error) {
	task, err := scanCareTask(r.pool.QueryRow(ctx, careTaskSelect+` WHERE t.owner_id=$1 AND t.id=$2`, ownerID, taskID))
	return task, mapPostgresError(err)
}

func (r *PostgresRepository) listReminders(ctx context.Context, ownerID uuid.UUID, filter ReminderFilter) ([]Reminder, error) {
	query := reminderSelect + ` WHERE r.owner_id=$1`
	args := []any{ownerID}
	if filter.State != "" {
		state := normalizeReminderState(filter.State)
		args = append(args, state)
		query += fmt.Sprintf(" AND r.status=$%d", len(args))
	}
	if filter.RuleCode != "" {
		args = append(args, filter.RuleCode)
		query += fmt.Sprintf(" AND t.rule_code=$%d", len(args))
	}
	args = append(args, filter.Page.Limit, filter.Page.Offset)
	query += fmt.Sprintf(" ORDER BY r.scheduled_at ASC, r.created_at DESC, r.id DESC LIMIT $%d OFFSET $%d", len(args)-1, len(args))
	rows, err := r.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, mapPostgresError(err)
	}
	defer rows.Close()
	result := make([]Reminder, 0)
	for rows.Next() {
		reminder, scanErr := scanReminder(rows)
		if scanErr != nil {
			return nil, scanErr
		}
		result = append(result, reminder)
	}
	return result, mapPostgresError(rows.Err())
}

func (r *PostgresRepository) getReminder(ctx context.Context, ownerID, reminderID uuid.UUID) (Reminder, error) {
	reminder, err := scanReminder(r.pool.QueryRow(ctx, reminderSelect+` WHERE r.owner_id=$1 AND r.id=$2`, ownerID, reminderID))
	return reminder, mapPostgresError(err)
}

const healthRecordSelect = `
	SELECT id, owner_id, organization_id, subject_type, hamster_id, pup_identity_id,
		litter_id, enclosure_id, record_type, observed_at, structured_checks, severity,
		medication, follow_up_at, notes, operator_id, corrects_health_record_id,
		correction_reason, version, created_at, updated_at
	FROM health_record`

const careTaskSelect = `
	SELECT t.id, t.owner_id, t.organization_id, t.task_type, t.target_type, t.target_id,
		t.title, t.description, t.scheduled_at, t.priority, t.status,
		COALESCE((SELECT jsonb_agg(s.subject_id ORDER BY s.created_at)
			FROM care_task_subject s WHERE s.owner_id=t.owner_id AND s.care_task_id=t.id), '[]'::jsonb),
		COALESCE((SELECT jsonb_agg(s.subject_id ORDER BY s.created_at)
			FROM care_task_subject s WHERE s.owner_id=t.owner_id AND s.care_task_id=t.id
			AND s.completed_at IS NOT NULL), '[]'::jsonb),
		t.stage_total, t.stage_done, t.source_event_id, t.completed_at,
		t.version, t.created_at, t.updated_at
	FROM care_task t`

const reminderSelect = `
	SELECT r.id, r.owner_id, r.care_task_id, r.channel, r.status, r.dedupe_key,
		r.scheduled_at, r.next_attempt_at, r.delivered_at, r.read_at, r.error_code,
		r.version
	FROM reminder_delivery r
	JOIN care_task t ON t.owner_id=r.owner_id AND t.id=r.care_task_id`

func scanHealthRecord(row pgx.Row) (HealthRecord, error) {
	var record HealthRecord
	var structured, medication []byte
	var operatorID uuid.UUID
	var correctionID *uuid.UUID
	var correctionReason *string
	err := row.Scan(
		&record.ID, &record.OwnerID, &record.OrganizationID, &record.SubjectType,
		&record.HamsterID, &record.PupIdentityID, &record.LitterID, &record.EnclosureID,
		&record.Type, &record.ObservedAt, &structured, &record.Severity, &medication,
		&record.FollowUpAt, &record.Notes, &operatorID, &correctionID, &correctionReason,
		&record.Version, &record.CreatedAt, &record.UpdatedAt,
	)
	if err != nil {
		return HealthRecord{}, mapPostgresError(err)
	}
	if err := json.Unmarshal(structured, &record.StructuredChecks); err != nil {
		return HealthRecord{}, err
	}
	if err := json.Unmarshal(medication, &record.Medication); err != nil {
		return HealthRecord{}, err
	}
	if record.StructuredChecks == nil {
		record.StructuredChecks = map[string]any{}
	}
	if record.Medication == nil {
		record.Medication = map[string]any{}
	}
	return record, nil
}

func scanCareTask(row pgx.Row) (CareTask, error) {
	var task CareTask
	var description *string
	var subjects, completedSubjects []byte
	var stageTotal, stageDone *int32
	err := row.Scan(
		&task.ID, &task.OwnerID, &task.OrganizationID, &task.TaskType, &task.TargetType,
		&task.TargetID, &task.Title, &description, &task.ScheduledAt, &task.Priority, &task.State,
		&subjects, &completedSubjects, &stageTotal, &stageDone, &task.SourceEventID,
		&task.CompletedAt, &task.Version, &task.CreatedAt, &task.UpdatedAt,
	)
	if err != nil {
		return CareTask{}, mapPostgresError(err)
	}
	if err := json.Unmarshal(subjects, &task.SubjectIDs); err != nil {
		return CareTask{}, err
	}
	if err := json.Unmarshal(completedSubjects, &task.CompletedSubjectIDs); err != nil {
		return CareTask{}, err
	}
	if description != nil {
		task.Notes = description
	}
	if stageTotal != nil {
		task.StageTotal = int(*stageTotal)
	}
	if stageDone != nil {
		task.StageDone = int(*stageDone)
	}
	if task.SubjectIDs == nil {
		task.SubjectIDs = []uuid.UUID{}
	}
	if task.CompletedSubjectIDs == nil {
		task.CompletedSubjectIDs = []uuid.UUID{}
	}
	return task, nil
}

func scanReminder(row pgx.Row) (Reminder, error) {
	var reminder Reminder
	err := row.Scan(&reminder.ID, &reminder.OwnerID, &reminder.CareTaskID, &reminder.Channel,
		&reminder.Status, &reminder.DedupeKey, &reminder.ScheduledAt, &reminder.AttemptedAt,
		&reminder.DeliveredAt, &reminder.ReadAt, &reminder.FailureCode, &reminder.Version)
	return reminder, mapPostgresError(err)
}

func insertHealthRecordTx(ctx context.Context, tx pgx.Tx, ownerID uuid.UUID, input CreateHealthRecordInput) (HealthRecord, error) {
	organizationID, err := organizationIDTx(ctx, tx, ownerID)
	if err != nil {
		return HealthRecord{}, err
	}
	record, err := scanHealthRecord(tx.QueryRow(ctx, `
		INSERT INTO health_record (
			owner_id, organization_id, subject_type, hamster_id, pup_identity_id, litter_id,
			enclosure_id, record_type, observed_at, structured_checks, severity, medication,
			follow_up_at, notes, operator_id
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$1)
		RETURNING id, owner_id, organization_id, subject_type, hamster_id, pup_identity_id,
			litter_id, enclosure_id, record_type, observed_at, structured_checks, severity,
			medication, follow_up_at, notes, operator_id, corrects_health_record_id,
			correction_reason, version, created_at, updated_at
	`, ownerID, organizationID, healthSubjectType(input), input.HamsterID, input.PupIdentityID,
		input.LitterID, input.EnclosureID, input.Type, input.ObservedAt, jsonBytes(input.StructuredChecks),
		input.Severity, jsonBytes(input.Medication), input.FollowUpAt, input.Notes))
	if err != nil {
		return HealthRecord{}, err
	}
	return record, appendEventTx(ctx, tx, ownerID, organizationID, "health_record", record.ID, "HEALTH_RECORD_CREATED", map[string]any{"type": record.Type}, "")
}

func insertCareTaskTx(ctx context.Context, tx pgx.Tx, ownerID uuid.UUID, key string, input CreateCareTaskInput) (CareTask, error) {
	organizationID, err := organizationIDTx(ctx, tx, ownerID)
	if err != nil {
		return CareTask{}, err
	}
	title := input.Title
	if title == nil {
		defaultTitle := "手工任务"
		title = &defaultTitle
	}
	dedupeKey := "manual:" + key
	var taskID uuid.UUID
	err = tx.QueryRow(ctx, `
		INSERT INTO care_task (
			owner_id, organization_id, task_type, target_type, target_id, title,
			description, scheduled_at, priority, dedupe_key, created_by, updated_by
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$1,$1)
		RETURNING id
	`, ownerID, organizationID, input.TaskType, input.TargetType, input.TargetID, title, input.Notes,
		input.ScheduledAt, input.Priority, dedupeKey).Scan(&taskID)
	if err != nil {
		return CareTask{}, mapPostgresError(err)
	}
	for _, subjectID := range input.SubjectIDs {
		subjectType, subjectErr := resolveTaskSubjectTypeTx(ctx, tx, ownerID, subjectID)
		if subjectErr != nil {
			return CareTask{}, subjectErr
		}
		if _, err := tx.Exec(ctx, `
			INSERT INTO care_task_subject (owner_id, care_task_id, subject_type, subject_id)
			VALUES ($1,$2,$3,$4)
		`, ownerID, taskID, subjectType, subjectID); err != nil {
			return CareTask{}, mapPostgresError(err)
		}
	}
	_, err = tx.Exec(ctx, `
		INSERT INTO reminder_delivery (owner_id, care_task_id, channel, status, dedupe_key, scheduled_at, next_attempt_at)
		VALUES ($1,$2,'in_app','queued',$3,$4,$4)
		ON CONFLICT (owner_id, channel, dedupe_key) DO NOTHING
	`, ownerID, taskID, "task:"+taskID.String(), input.ScheduledAt)
	if err != nil {
		return CareTask{}, mapPostgresError(err)
	}
	task, err := scanCareTask(tx.QueryRow(ctx, careTaskSelect+` WHERE t.owner_id=$1 AND t.id=$2`, ownerID, taskID))
	if err != nil {
		return CareTask{}, err
	}
	if err := appendEventTx(ctx, tx, ownerID, organizationID, "care_task", task.ID, "CARE_TASK_CREATED", map[string]any{"task_type": task.TaskType, "target_id": task.TargetID}, key); err != nil {
		return CareTask{}, err
	}
	return task, nil
}

func completeCareTaskTx(ctx context.Context, tx pgx.Tx, ownerID, taskID uuid.UUID, input CompleteTaskInput, key string) (CompleteTaskResult, error) {
	task, err := scanCareTask(tx.QueryRow(ctx, careTaskSelect+` WHERE t.owner_id=$1 AND t.id=$2 FOR UPDATE`, ownerID, taskID))
	if err != nil {
		return CompleteTaskResult{}, err
	}
	if task.Version != input.ExpectedVersion {
		return CompleteTaskResult{}, fmt.Errorf("%w: current=%d", ErrVersionConflict, task.Version)
	}
	seen := make(map[uuid.UUID]struct{}, len(input.SubjectResults))
	items := make([]CompletedTaskItem, 0, len(input.SubjectResults))
	for _, result := range input.SubjectResults {
		if _, exists := seen[result.SubjectID]; exists {
			return CompleteTaskResult{}, fmt.Errorf("%w: duplicate subject result", ErrValidation)
		}
		seen[result.SubjectID] = struct{}{}
		if result.Status != "completed" && result.Status != "excepted" {
			return CompleteTaskResult{}, fmt.Errorf("%w: invalid subject result status", ErrValidation)
		}
		if result.Status == "excepted" && (result.ExceptionReason == nil || strings.TrimSpace(*result.ExceptionReason) == "") {
			return CompleteTaskResult{}, fmt.Errorf("%w: exception reason is required", ErrValidation)
		}
		refs := []uuid.UUID{}
		if result.CompletionRecordID != nil {
			refs = append(refs, *result.CompletionRecordID)
		}
		var updatedID uuid.UUID
		err = tx.QueryRow(ctx, `
			UPDATE care_task_subject
			SET completed_at=$5, completed_by=$1, completion_record_refs=$6,
				exception_reason=$7, version=version+1, updated_at=now()
			WHERE owner_id=$1 AND care_task_id=$2 AND subject_id=$3
			RETURNING subject_id
		`, ownerID, taskID, result.SubjectID, input.CompletedAt, jsonBytes(refs), result.ExceptionReason).Scan(&updatedID)
		if errors.Is(err, pgx.ErrNoRows) {
			return CompleteTaskResult{}, ErrNotFound
		}
		if err != nil {
			return CompleteTaskResult{}, mapPostgresError(err)
		}
		status := "succeeded"
		if result.Status == "excepted" {
			status = "succeeded_with_exception"
		}
		items = append(items, CompletedTaskItem{SubjectID: updatedID, Status: status, CompletionRecordID: result.CompletionRecordID})
	}
	var allDone bool
	err = tx.QueryRow(ctx, `
		SELECT COALESCE(bool_and(completed_at IS NOT NULL), true)
		FROM care_task_subject WHERE owner_id=$1 AND care_task_id=$2
	`, ownerID, taskID).Scan(&allDone)
	if err != nil {
		return CompleteTaskResult{}, mapPostgresError(err)
	}
	status := "in_progress"
	if allDone {
		status = "completed"
	}
	updated, err := scanCareTask(tx.QueryRow(ctx, careTaskSelect+` WHERE t.owner_id=$1 AND t.id=$2`, ownerID, taskID))
	if err != nil {
		return CompleteTaskResult{}, err
	}
	updated, err = scanCareTask(tx.QueryRow(ctx, `
		UPDATE care_task
		SET status=$4, completed_at=CASE WHEN $4='completed' THEN $5 ELSE NULL END,
			version=version+1, updated_by=$1, updated_at=now()
		WHERE owner_id=$1 AND id=$2 AND version=$3
		RETURNING id, owner_id, organization_id, task_type, target_type, target_id,
			title, description, scheduled_at, priority, status,
			COALESCE((SELECT jsonb_agg(s.subject_id ORDER BY s.created_at) FROM care_task_subject s WHERE s.owner_id=care_task.owner_id AND s.care_task_id=care_task.id), '[]'::jsonb),
			COALESCE((SELECT jsonb_agg(s.subject_id ORDER BY s.created_at) FROM care_task_subject s WHERE s.owner_id=care_task.owner_id AND s.care_task_id=care_task.id AND s.completed_at IS NOT NULL), '[]'::jsonb),
			stage_total, stage_done, source_event_id, completed_at, version, created_at, updated_at
	`, ownerID, taskID, input.ExpectedVersion, status, input.CompletedAt))
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return CompleteTaskResult{}, fmt.Errorf("%w: current=%d", ErrVersionConflict, task.Version)
		}
		return CompleteTaskResult{}, mapPostgresError(err)
	}
	if err := appendEventTx(ctx, tx, ownerID, updated.OrganizationID, "care_task", taskID, "CARE_TASK_COMPLETED", map[string]any{"auto_closed": allDone}, key); err != nil {
		return CompleteTaskResult{}, err
	}
	return CompleteTaskResult{Task: updated, ItemResults: items, AutoClosed: allDone}, nil
}

func organizationIDTx(ctx context.Context, tx pgx.Tx, ownerID uuid.UUID) (uuid.UUID, error) {
	var organizationID uuid.UUID
	err := tx.QueryRow(ctx, `SELECT id FROM organization WHERE owner_id=$1 AND deleted_at IS NULL ORDER BY created_at LIMIT 1`, ownerID).Scan(&organizationID)
	return organizationID, mapPostgresError(err)
}

func resolveTaskSubjectTypeTx(ctx context.Context, tx pgx.Tx, ownerID, subjectID uuid.UUID) (string, error) {
	var subjectType string
	err := tx.QueryRow(ctx, `
		SELECT subject_type FROM (
			SELECT 'hamster'::text AS subject_type FROM hamster WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
			UNION ALL
			SELECT 'pup_identity'::text AS subject_type FROM pup_identity WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
		) subjects LIMIT 1
	`, ownerID, subjectID).Scan(&subjectType)
	return subjectType, mapPostgresError(err)
}

func appendEventTx(ctx context.Context, tx pgx.Tx, ownerID, organizationID uuid.UUID, aggregateType string, aggregateID uuid.UUID, eventType string, payload map[string]any, idempotencyKey string) error {
	var version int
	if err := tx.QueryRow(ctx, `SELECT COALESCE(max(event_version),0)+1 FROM domain_event WHERE owner_id=$1 AND aggregate_type=$2 AND aggregate_id=$3`, ownerID, aggregateType, aggregateID).Scan(&version); err != nil {
		return mapPostgresError(err)
	}
	var eventID uuid.UUID
	if err := tx.QueryRow(ctx, `
		INSERT INTO domain_event (owner_id, organization_id, aggregate_type, aggregate_id, event_type, event_version, actor_id, occurred_at, payload, idempotency_key)
		VALUES ($1,$2,$3,$4,$5,$6,$1,now(),$7,$8) RETURNING id
	`, ownerID, organizationID, aggregateType, aggregateID, eventType, version, jsonBytes(payload), nullableString(idempotencyKey)).Scan(&eventID); err != nil {
		return mapPostgresError(err)
	}
	_, err := tx.Exec(ctx, `
		INSERT INTO outbox_message (owner_id, domain_event_id, topic, partition_key, payload)
		VALUES ($1,$2,$3,$4,$5)
	`, ownerID, eventID, "domain."+strings.ToLower(aggregateType), aggregateID.String(), jsonBytes(map[string]any{
		"event_id": eventID, "event_type": eventType, "aggregate_type": aggregateType, "aggregate_id": aggregateID, "payload": payload,
	}))
	return mapPostgresError(err)
}

func healthSubjectType(input CreateHealthRecordInput) string {
	if input.HamsterID != nil {
		return "hamster"
	}
	if input.PupIdentityID != nil {
		return "pup_identity"
	}
	if input.LitterID != nil {
		return "litter"
	}
	return "enclosure"
}

func normalizeReminderState(value string) string {
	switch value {
	case "pending":
		return "queued"
	case "sent":
		return "succeeded"
	default:
		return value
	}
}

func nullableString(value string) *string {
	if value == "" {
		return nil
	}
	return &value
}

func jsonBytes(value any) []byte {
	if value == nil {
		return []byte(`{}`)
	}
	b, _ := json.Marshal(value)
	if string(b) == "null" {
		return []byte(`{}`)
	}
	return b
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

func decodeStoredResponse(raw []byte) []byte {
	var stored storedResponse
	if json.Unmarshal(raw, &stored) == nil && stored.Body != nil {
		return stored.Body
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
	if !errors.As(err, &pgErr) {
		return err
	}
	switch pgErr.Code {
	case "23505":
		return fmt.Errorf("%w: %s", ErrDuplicate, pgErr.ConstraintName)
	case "23503":
		return ErrNotFound
	case "23514":
		return fmt.Errorf("%w: %s", ErrValidation, pgErr.Message)
	case "40001":
		return ErrVersionConflict
	default:
		return err
	}
}

func parseTime(value string) (time.Time, error) {
	return time.Parse(time.RFC3339, value)
}
