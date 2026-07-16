package importcsv

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
	"github.com/jackc/pgx/v5/pgxpool"

	basestore "github.com/scolvpet/scolvpet/api/internal/store"
)

var (
	ErrImportJobNotFound = errors.New("import job not found")
	ErrImportJobNotReady = errors.New("import job is not ready to commit")
)

type PostgresStore struct {
	pool *pgxpool.Pool
}

var _ Store = (*PostgresStore)(nil)

type LocalJobRequest struct {
	OwnerID          string
	OrganizationID   string
	OperatorID       string
	OriginalFilename string
	BatchKey         string
	CSV              []byte
	ParseOptions     ParseOptions
}

type LocalJob struct {
	ID             string
	AsyncJobID     string
	OwnerID        string
	OrganizationID string
	OperatorID     string
	BatchKey       string
	File           *ParsedFile
	ImportStatus   ImportJobStatus
	Replayed       bool
}

func NewPostgresStore(pool *pgxpool.Pool) *PostgresStore {
	return &PostgresStore{pool: pool}
}

func NewPostgresStoreFromStore(source *basestore.Store) *PostgresStore {
	if source == nil {
		return &PostgresStore{}
	}
	return NewPostgresStore(source.Pool)
}

func (store *PostgresStore) Pool() *pgxpool.Pool {
	return store.pool
}

func (store *PostgresStore) Snapshot(ctx context.Context, ownerID string) (Snapshot, error) {
	if store.pool == nil {
		return Snapshot{}, errors.New("importcsv: pgxpool 为空")
	}
	ownerUUID, err := uuid.Parse(ownerID)
	if err != nil {
		return Snapshot{}, fmt.Errorf("解析 owner_id: %w", err)
	}
	tx, err := store.pool.BeginTx(ctx, pgx.TxOptions{IsoLevel: pgx.RepeatableRead, AccessMode: pgx.ReadOnly})
	if err != nil {
		return Snapshot{}, err
	}
	defer func() { _ = tx.Rollback(ctx) }()
	snapshot := Snapshot{OwnerID: ownerID, WeightAcquisitionKeys: make(map[string]string)}
	var organizationID uuid.UUID
	err = tx.QueryRow(ctx, `
		SELECT id FROM organization
		WHERE owner_id=$1 AND deleted_at IS NULL
		ORDER BY created_at LIMIT 1
	`, ownerUUID).Scan(&organizationID)
	if errors.Is(err, pgx.ErrNoRows) {
		return Snapshot{}, ErrImportJobNotFound
	}
	if err != nil {
		return Snapshot{}, err
	}
	snapshot.OrganizationID = organizationID.String()
	if err := loadHamsterSnapshot(ctx, tx, ownerUUID, &snapshot); err != nil {
		return Snapshot{}, err
	}
	if err := loadEnclosureSnapshot(ctx, tx, ownerUUID, &snapshot); err != nil {
		return Snapshot{}, err
	}
	if err := loadLitterSnapshot(ctx, tx, ownerUUID, &snapshot); err != nil {
		return Snapshot{}, err
	}
	if err := loadParentageSnapshot(ctx, tx, ownerUUID, &snapshot); err != nil {
		return Snapshot{}, err
	}
	if err := loadWeightKeys(ctx, tx, ownerUUID, &snapshot); err != nil {
		return Snapshot{}, err
	}
	if err := tx.Commit(ctx); err != nil {
		return Snapshot{}, err
	}
	return snapshot, nil
}

func (store *PostgresStore) WithTransaction(ctx context.Context, fn func(Tx) error) error {
	if store.pool == nil {
		return errors.New("importcsv: pgxpool 为空")
	}
	tx, err := store.pool.BeginTx(ctx, pgx.TxOptions{IsoLevel: pgx.Serializable})
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback(ctx) }()
	adapter := &postgresTx{tx: tx}
	if err := fn(adapter); err != nil {
		return err
	}
	return tx.Commit(ctx)
}

func (store *PostgresStore) CreateLocalJob(ctx context.Context, request LocalJobRequest) (LocalJob, error) {
	if store.pool == nil {
		return LocalJob{}, errors.New("importcsv: pgxpool 为空")
	}
	if len(request.BatchKey) < 8 || len(request.BatchKey) > 128 {
		return LocalJob{}, errors.New("importcsv: batch_key 长度必须为 8-128")
	}
	file, err := Parse(request.CSV, request.ParseOptions)
	if err != nil {
		return LocalJob{}, err
	}
	ownerID, err := uuid.Parse(request.OwnerID)
	if err != nil {
		return LocalJob{}, fmt.Errorf("解析 owner_id: %w", err)
	}
	organizationID, err := optionalUUID(request.OrganizationID)
	if err != nil {
		return LocalJob{}, fmt.Errorf("解析 organization_id: %w", err)
	}
	operatorID, err := optionalUUID(request.OperatorID)
	if err != nil {
		return LocalJob{}, fmt.Errorf("解析 operator_id: %w", err)
	}
	if operatorID == nil {
		operatorID = &ownerID
	}
	filename := strings.TrimSpace(request.OriginalFilename)
	if filename == "" {
		filename = string(file.Template) + ".csv"
	}
	tx, err := store.pool.Begin(ctx)
	if err != nil {
		return LocalJob{}, err
	}
	defer func() { _ = tx.Rollback(ctx) }()
	if _, err := tx.Exec(ctx, `SELECT pg_advisory_xact_lock(hashtextextended($1, 0))`, request.OwnerID+":"+request.BatchKey); err != nil {
		return LocalJob{}, err
	}
	if organizationID == nil {
		var resolved uuid.UUID
		if err := tx.QueryRow(ctx, `
			SELECT id FROM organization WHERE owner_id=$1 AND deleted_at IS NULL
			ORDER BY created_at LIMIT 1
		`, ownerID).Scan(&resolved); err != nil {
			return LocalJob{}, err
		}
		organizationID = &resolved
	}
	var existingJobID, existingAsyncID uuid.UUID
	var existingHash string
	var existingTemplate TemplateType
	var existingStatus ImportJobStatus
	err = tx.QueryRow(ctx, `
		SELECT id, async_job_id, file_sha256, template_type, status
		FROM import_job WHERE owner_id=$1 AND idempotency_batch_key=$2
	`, ownerID, request.BatchKey).Scan(&existingJobID, &existingAsyncID, &existingHash, &existingTemplate, &existingStatus)
	if err == nil {
		if existingHash != file.FileSHA256 || existingTemplate != file.Template {
			return LocalJob{}, ErrBatchKeyConflict
		}
		if err := tx.Commit(ctx); err != nil {
			return LocalJob{}, err
		}
		return LocalJob{
			ID: existingJobID.String(), AsyncJobID: existingAsyncID.String(), OwnerID: request.OwnerID,
			OrganizationID: organizationID.String(), OperatorID: operatorID.String(), BatchKey: request.BatchKey,
			File: file, ImportStatus: existingStatus, Replayed: true,
		}, nil
	}
	if !errors.Is(err, pgx.ErrNoRows) {
		return LocalJob{}, err
	}
	requestPayload := jsonValue(map[string]any{
		"mode": "local_bytes", "filename": filename, "file_sha256": file.FileSHA256,
		"template_type": file.Template, "encoding": file.Encoding, "delimiter": string(file.Delimiter),
	})
	var asyncJobID uuid.UUID
	err = tx.QueryRow(ctx, `
		INSERT INTO async_job (
			owner_id, organization_id, job_type, status, progress_percent,
			request_payload, idempotency_key, started_at, created_by
		) VALUES ($1,$2,'import','running',5,$3,$4,now(),$5)
		RETURNING id
	`, ownerID, *organizationID, requestPayload, "import-local:"+request.BatchKey, *operatorID).Scan(&asyncJobID)
	if err != nil {
		return LocalJob{}, err
	}
	mapping := jsonValue(file.Mapping)
	var jobID uuid.UUID
	err = tx.QueryRow(ctx, `
		INSERT INTO import_job (
			owner_id, organization_id, async_job_id, template_type, status,
			source_object_key, original_filename, file_sha256, file_encoding,
			delimiter, column_mapping, idempotency_batch_key, created_by
		) VALUES ($1,$2,$3,$4,'uploaded',$5,$6,$7,$8,$9,$10,$11,$12)
		RETURNING id
	`, ownerID, *organizationID, asyncJobID, file.Template, "local-bytes:"+file.FileSHA256,
		filename, file.FileSHA256, file.Encoding, string(file.Delimiter), mapping, request.BatchKey, *operatorID).Scan(&jobID)
	if err != nil {
		return LocalJob{}, err
	}
	if err := tx.Commit(ctx); err != nil {
		return LocalJob{}, err
	}
	return LocalJob{
		ID: jobID.String(), AsyncJobID: asyncJobID.String(), OwnerID: request.OwnerID,
		OrganizationID: organizationID.String(), OperatorID: operatorID.String(), BatchKey: request.BatchKey,
		File: file, ImportStatus: ImportJobUploaded,
	}, nil
}

func (store *PostgresStore) PreflightLocal(ctx context.Context, job LocalJob, options PreflightOptions, engineOptions ...EngineOption) (*PreflightReport, error) {
	engine := New(store, engineOptions...)
	report, err := engine.Preflight(ctx, PreflightRequest{
		JobID: job.ID, AsyncJobID: job.AsyncJobID, OwnerID: job.OwnerID,
		OrganizationID: job.OrganizationID, OperatorID: job.OperatorID, File: job.File, Options: options,
	})
	if err != nil {
		return nil, err
	}
	if err := store.SavePreflight(ctx, job.OwnerID, job.ID, job.File, report); err != nil {
		return nil, err
	}
	return report, nil
}

func (store *PostgresStore) CommitLocal(ctx context.Context, job LocalJob, report *PreflightReport, approvals []ApprovedUpdate, engineOptions ...EngineOption) (CommitReceipt, error) {
	if report != nil {
		report.JobID = job.ID
		report.AsyncJobID = job.AsyncJobID
	}
	return New(store, engineOptions...).Commit(ctx, CommitRequest{
		OwnerID: job.OwnerID, BatchKey: job.BatchKey, Report: report, ApprovedUpdates: approvals,
	})
}

func (store *PostgresStore) SavePreflight(ctx context.Context, ownerID, jobID string, file *ParsedFile, report *PreflightReport) error {
	if store.pool == nil {
		return errors.New("importcsv: pgxpool 为空")
	}
	if file == nil || report == nil {
		return errors.New("importcsv: file/report 为空")
	}
	ownerUUID, err := uuid.Parse(ownerID)
	if err != nil {
		return err
	}
	jobUUID, err := uuid.Parse(jobID)
	if err != nil {
		return err
	}
	tx, err := store.pool.Begin(ctx)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback(ctx) }()
	var asyncJobID uuid.UUID
	var storedHash string
	var storedTemplate TemplateType
	var storedStatus ImportJobStatus
	err = tx.QueryRow(ctx, `
		SELECT async_job_id, file_sha256, template_type, status
		FROM import_job WHERE owner_id=$1 AND id=$2 FOR UPDATE
	`, ownerUUID, jobUUID).Scan(&asyncJobID, &storedHash, &storedTemplate, &storedStatus)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrImportJobNotFound
	}
	if err != nil {
		return err
	}
	if storedHash != file.FileSHA256 || storedHash != report.FileSHA256 || storedTemplate != file.Template {
		return ErrStalePreflight
	}
	if storedStatus == ImportJobApplying || storedStatus == ImportJobSucceeded || storedStatus == ImportJobPartiallySucceeded {
		return fmt.Errorf("%w: status=%s", ErrImportJobNotReady, storedStatus)
	}
	if _, err := tx.Exec(ctx, `DELETE FROM import_issue WHERE owner_id=$1 AND import_job_id=$2`, ownerUUID, jobUUID); err != nil {
		return err
	}
	if _, err := tx.Exec(ctx, `DELETE FROM import_row WHERE owner_id=$1 AND import_job_id=$2`, ownerUUID, jobUUID); err != nil {
		return err
	}
	results := make(map[int]RowResult, len(report.Rows))
	for _, row := range report.Rows {
		results[row.RowNumber] = row
	}
	rowIDs := make(map[int]uuid.UUID, len(file.Rows))
	for _, parsed := range file.Rows {
		result := results[parsed.RowNumber]
		status := RowValid
		if result.Status == RowInvalid {
			status = RowInvalid
		}
		var atomicGroupKey any
		var atomicGroupFingerprint any
		if file.Template == TemplateHamster {
			if litterCode := strings.TrimSpace(parsed.Mapped["litter_code"]); litterCode != "" {
				atomicGroupKey = litterCode
				atomicGroupFingerprint = atomicFingerprint(report.Plan.PlanHash, litterCode)
			}
		}
		rowKey := fmt.Sprintf("import:%s:%d:%s", jobID, parsed.RowNumber, shortHash(parsed.RowSHA256))
		var rowID uuid.UUID
		err := tx.QueryRow(ctx, `
			INSERT INTO import_row (
				owner_id, import_job_id, row_number, raw_data, normalized_data,
				row_sha256, idempotency_key, status, atomic_group_key,
				atomic_group_fingerprint, result_payload, processed_at
			) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,now())
			RETURNING id
		`, ownerUUID, jobUUID, parsed.RowNumber, jsonValue(parsed.Raw), jsonValue(result.MappedValues),
			parsed.RowSHA256, rowKey, status, atomicGroupKey, atomicGroupFingerprint, jsonValue(result)).Scan(&rowID)
		if err != nil {
			return err
		}
		rowIDs[parsed.RowNumber] = rowID
	}
	for _, issue := range report.Issues {
		var rowID any
		if existing, ok := rowIDs[issue.RowNumber]; ok {
			rowID = existing
		}
		severity := "warning"
		if issue.Severity == SeverityBlocking {
			severity = "error"
		}
		var rawValue any
		if issue.OriginalValue != nil {
			rawValue = fmt.Sprint(issue.OriginalValue)
		}
		details := map[string]any{"api_severity": issue.Severity}
		if issue.GroupKey != "" {
			details["group_key"] = issue.GroupKey
		}
		_, err := tx.Exec(ctx, `
			INSERT INTO import_issue (
				owner_id, import_job_id, import_row_id, severity, issue_code,
				field_name, raw_value, message, recovery_action, details
			) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
		`, ownerUUID, jobUUID, rowID, severity, issue.Code, nullString(issue.ColumnName), rawValue,
			issue.Message, nullString(issue.Suggestion), jsonValue(details))
		if err != nil {
			return err
		}
	}
	status := ImportJobFailed
	asyncStatus := JobFailed
	progress := 100
	var finishedAt any = time.Now()
	if report.ReadyToCommit {
		status = ImportJobReady
		asyncStatus = JobRunning
		progress = 50
		finishedAt = nil
	}
	conflictPolicy := jsonValue(map[string]any{
		"preflight_version": report.PreflightVersion,
		"plan_hash":         report.Plan.PlanHash,
		"update_candidates": report.UpdateCandidates,
		"operations":        report.Plan.Operations,
	})
	_, err = tx.Exec(ctx, `
		UPDATE import_job SET
			status=$3, file_encoding=$4, delimiter=$5, column_mapping=$6,
			conflict_policy=$7, total_rows=$8, valid_rows=$9, invalid_rows=$10,
			prechecked_at=now(), updated_at=now()
		WHERE owner_id=$1 AND id=$2
	`, ownerUUID, jobUUID, status, file.Encoding, string(file.Delimiter), jsonValue(file.Mapping), conflictPolicy,
		report.TotalRows, report.ValidRows, report.InvalidRows)
	if err != nil {
		return err
	}
	_, err = tx.Exec(ctx, `
		UPDATE async_job SET status=$3, progress_percent=$4, result_payload=$5,
			finished_at=$6, error_code=$7, error_detail=$8, updated_at=now()
		WHERE owner_id=$1 AND id=$2
	`, ownerUUID, asyncJobID, asyncStatus, progress, jsonValue(map[string]any{
		"preflight_version": report.PreflightVersion, "blocking_issue_count": report.BlockingIssueCount,
	}), finishedAt, nullable(report.ReadyToCommit, "IMPORT_PREFLIGHT_BLOCKED"), nullable(report.ReadyToCommit, "CSV 预检存在阻塞问题"))
	if err != nil {
		return err
	}
	if err := tx.Commit(ctx); err != nil {
		return err
	}
	report.JobID = jobID
	report.AsyncJobID = asyncJobID.String()
	return nil
}

func (store *PostgresStore) LoadPreflight(ctx context.Context, ownerID, jobID string) (*PreflightReport, error) {
	if store.pool == nil {
		return nil, errors.New("importcsv: pgxpool 为空")
	}
	ownerUUID, err := uuid.Parse(ownerID)
	if err != nil {
		return nil, err
	}
	jobUUID, err := uuid.Parse(jobID)
	if err != nil {
		return nil, err
	}
	var asyncJobID, organizationID uuid.UUID
	var template TemplateType
	var status ImportJobStatus
	var fileHash string
	var totalRows, validRows, invalidRows int
	var policy []byte
	err = store.pool.QueryRow(ctx, `
		SELECT async_job_id, organization_id, template_type, status, file_sha256,
			total_rows, valid_rows, invalid_rows, conflict_policy
		FROM import_job WHERE owner_id=$1 AND id=$2
	`, ownerUUID, jobUUID).Scan(&asyncJobID, &organizationID, &template, &status, &fileHash,
		&totalRows, &validRows, &invalidRows, &policy)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrImportJobNotFound
	}
	if err != nil {
		return nil, err
	}
	var audit struct {
		PreflightVersion int               `json:"preflight_version"`
		PlanHash         string            `json:"plan_hash"`
		UpdateCandidates []UpdateCandidate `json:"update_candidates"`
		Operations       []Operation       `json:"operations"`
	}
	if err := json.Unmarshal(policy, &audit); err != nil {
		return nil, fmt.Errorf("解析预检审计: %w", err)
	}
	report := &PreflightReport{
		JobID: jobID, AsyncJobID: asyncJobID.String(), OwnerID: ownerID,
		OrganizationID: organizationID.String(), Template: template, FileSHA256: fileHash,
		PreflightVersion: audit.PreflightVersion, UpdateCandidates: audit.UpdateCandidates,
		TotalRows: totalRows, ValidRows: validRows, InvalidRows: invalidRows,
		ReadyToCommit: status == ImportJobReady,
	}
	rows, err := store.pool.Query(ctx, `
		SELECT result_payload FROM import_row
		WHERE owner_id=$1 AND import_job_id=$2 ORDER BY row_number
	`, ownerUUID, jobUUID)
	if err != nil {
		return nil, err
	}
	for rows.Next() {
		var raw []byte
		if err := rows.Scan(&raw); err != nil {
			rows.Close()
			return nil, err
		}
		var row RowResult
		if err := json.Unmarshal(raw, &row); err != nil {
			rows.Close()
			return nil, err
		}
		report.Rows = append(report.Rows, row)
	}
	if err := rows.Err(); err != nil {
		rows.Close()
		return nil, err
	}
	rows.Close()
	issueRows, err := store.pool.Query(ctx, `
		SELECT COALESCE(ir.row_number,1), ii.field_name, ii.issue_code, ii.message,
			ii.severity, ii.raw_value, ii.recovery_action, ii.details
		FROM import_issue ii
		LEFT JOIN import_row ir ON ir.owner_id=ii.owner_id AND ir.import_job_id=ii.import_job_id AND ir.id=ii.import_row_id
		WHERE ii.owner_id=$1 AND ii.import_job_id=$2
		ORDER BY COALESCE(ir.row_number,1), ii.created_at, ii.id
	`, ownerUUID, jobUUID)
	if err != nil {
		return nil, err
	}
	defer issueRows.Close()
	for issueRows.Next() {
		var issue Issue
		var fieldName, rawValue, recovery *string
		var databaseSeverity string
		var details []byte
		if err := issueRows.Scan(&issue.RowNumber, &fieldName, &issue.Code, &issue.Message,
			&databaseSeverity, &rawValue, &recovery, &details); err != nil {
			return nil, err
		}
		if fieldName != nil {
			issue.ColumnName = *fieldName
		}
		if rawValue != nil {
			issue.OriginalValue = *rawValue
		}
		if recovery != nil {
			issue.Suggestion = *recovery
		}
		issue.Severity = SeverityWarning
		if databaseSeverity == "error" {
			issue.Severity = SeverityBlocking
			report.BlockingIssueCount++
		}
		var detailValues map[string]any
		if json.Unmarshal(details, &detailValues) == nil {
			if groupKey, ok := detailValues["group_key"].(string); ok {
				issue.GroupKey = groupKey
			}
		}
		report.Issues = append(report.Issues, issue)
	}
	if err := issueRows.Err(); err != nil {
		return nil, err
	}
	plannedRows := make([]PlannedRow, 0, len(report.Rows))
	for _, row := range report.Rows {
		plannedRows = append(plannedRows, PlannedRow{RowNumber: row.RowNumber, Action: row.Action, ResourceID: row.ResourceID})
		if hasWarning(row.Issues) {
			report.WarningRows++
		}
	}
	report.Plan = CommitPlan{
		OwnerID: ownerID, OrganizationID: organizationID.String(), Template: template,
		FileSHA256: fileHash, PreflightVersion: audit.PreflightVersion,
		PlanHash: audit.PlanHash, Operations: audit.Operations, Rows: plannedRows,
	}
	for _, operation := range audit.Operations {
		if operation.Kind == OperationCreateLitter {
			report.HistoricalLittersToCreate++
		}
	}
	return report, nil
}

func (store *PostgresStore) LoadCommittedReceipt(ctx context.Context, ownerID, batchKey string) (CommitReceipt, bool, error) {
	if store.pool == nil {
		return CommitReceipt{}, false, errors.New("importcsv: pgxpool 为空")
	}
	ownerUUID, err := uuid.Parse(ownerID)
	if err != nil {
		return CommitReceipt{}, false, err
	}
	var status ImportJobStatus
	var payload []byte
	err = store.pool.QueryRow(ctx, `
		SELECT ij.status, aj.result_payload
		FROM import_job ij JOIN async_job aj ON aj.owner_id=ij.owner_id AND aj.id=ij.async_job_id
		WHERE ij.owner_id=$1 AND ij.idempotency_batch_key=$2
	`, ownerUUID, batchKey).Scan(&status, &payload)
	if errors.Is(err, pgx.ErrNoRows) {
		return CommitReceipt{}, false, nil
	}
	if err != nil {
		return CommitReceipt{}, false, err
	}
	if status != ImportJobSucceeded && status != ImportJobPartiallySucceeded {
		return CommitReceipt{}, false, nil
	}
	var receipt CommitReceipt
	if err := json.Unmarshal(payload, &receipt); err != nil {
		return CommitReceipt{}, false, err
	}
	receipt.Replayed = true
	return receipt, true, nil
}

func loadHamsterSnapshot(ctx context.Context, tx pgx.Tx, ownerID uuid.UUID, snapshot *Snapshot) error {
	rows, err := tx.Query(ctx, `
		SELECT id, owner_id, internal_code, COALESCE(name,''), species_rule_version_id,
			COALESCE(variety_code,''), sex, birth_date, source_type, lifecycle_status,
			breeding_status, current_enclosure_id, tags, COALESCE(notes,''), version
		FROM hamster WHERE owner_id=$1 AND deleted_at IS NULL
	`, ownerID)
	if err != nil {
		return err
	}
	defer rows.Close()
	for rows.Next() {
		var item HamsterRecord
		var id, itemOwner, ruleID uuid.UUID
		var enclosureID *uuid.UUID
		var tags []byte
		if err := rows.Scan(&id, &itemOwner, &item.InternalCode, &item.Name, &ruleID,
			&item.VarietyCode, &item.Sex, &item.BirthDate, &item.SourceType, &item.LifecycleStatus,
			&item.BreedingStatus, &enclosureID, &tags, &item.Notes, &item.Version); err != nil {
			return err
		}
		item.ID, item.OwnerID, item.SpeciesRuleVersionID = id.String(), itemOwner.String(), ruleID.String()
		if enclosureID != nil {
			item.CurrentEnclosureID = enclosureID.String()
		}
		_ = json.Unmarshal(tags, &item.Tags)
		snapshot.Hamsters = append(snapshot.Hamsters, item)
	}
	return rows.Err()
}

func loadEnclosureSnapshot(ctx context.Context, tx pgx.Tx, ownerID uuid.UUID, snapshot *Snapshot) error {
	rows, err := tx.Query(ctx, `
		SELECT id, owner_id, code, COALESCE(rack_code,''), COALESCE(level_code,''), capacity,
			state, cleanliness, last_cleaned_at, COALESCE(disabled_reason,''), version
		FROM enclosure WHERE owner_id=$1 AND deleted_at IS NULL
	`, ownerID)
	if err != nil {
		return err
	}
	defer rows.Close()
	for rows.Next() {
		var item EnclosureRecord
		var id, itemOwner uuid.UUID
		if err := rows.Scan(&id, &itemOwner, &item.Code, &item.RackCode, &item.LevelCode,
			&item.Capacity, &item.State, &item.Cleanliness, &item.LastCleanedAt, &item.DisabledReason, &item.Version); err != nil {
			return err
		}
		item.ID, item.OwnerID = id.String(), itemOwner.String()
		snapshot.Enclosures = append(snapshot.Enclosures, item)
	}
	if err := rows.Err(); err != nil {
		return err
	}
	stayRows, err := tx.Query(ctx, `
		SELECT id, owner_id, enclosure_id, hamster_id, started_at, ended_at
		FROM enclosure_stay WHERE owner_id=$1 AND deleted_at IS NULL
	`, ownerID)
	if err != nil {
		return err
	}
	defer stayRows.Close()
	for stayRows.Next() {
		var item EnclosureStayRecord
		var id, itemOwner, enclosureID, hamsterID uuid.UUID
		if err := stayRows.Scan(&id, &itemOwner, &enclosureID, &hamsterID, &item.StartedAt, &item.EndedAt); err != nil {
			return err
		}
		item.ID, item.OwnerID, item.EnclosureID, item.HamsterID = id.String(), itemOwner.String(), enclosureID.String(), hamsterID.String()
		snapshot.EnclosureStays = append(snapshot.EnclosureStays, item)
	}
	return stayRows.Err()
}

func loadLitterSnapshot(ctx context.Context, tx pgx.Tx, ownerID uuid.UUID, snapshot *Snapshot) error {
	rows, err := tx.Query(ctx, `
		SELECT l.id, l.owner_id, l.code, l.born_at,
			(SELECT lp.parent_id FROM litter_parent lp WHERE lp.owner_id=l.owner_id AND lp.litter_id=l.id AND lp.role='sire' AND lp.status='accepted' AND lp.valid_to IS NULL LIMIT 1),
			(SELECT lp.parent_id FROM litter_parent lp WHERE lp.owner_id=l.owner_id AND lp.litter_id=l.id AND lp.role='dam' AND lp.status='accepted' AND lp.valid_to IS NULL LIMIT 1)
		FROM litter l WHERE l.owner_id=$1 AND l.deleted_at IS NULL
	`, ownerID)
	if err != nil {
		return err
	}
	defer rows.Close()
	byID := make(map[string]int)
	for rows.Next() {
		var item LitterRecord
		var id, itemOwner uuid.UUID
		var sireID, damID *uuid.UUID
		if err := rows.Scan(&id, &itemOwner, &item.Code, &item.BornAt, &sireID, &damID); err != nil {
			return err
		}
		item.ID, item.OwnerID = id.String(), itemOwner.String()
		if sireID != nil {
			item.SireID = sireID.String()
		}
		if damID != nil {
			item.DamID = damID.String()
		}
		byID[item.ID] = len(snapshot.Litters)
		snapshot.Litters = append(snapshot.Litters, item)
	}
	if err := rows.Err(); err != nil {
		return err
	}
	members, err := tx.Query(ctx, `
		SELECT litter_id, hamster_id FROM litter_member
		WHERE owner_id=$1 AND member_type='hamster' AND hamster_id IS NOT NULL
			AND status='accepted' AND valid_to IS NULL
	`, ownerID)
	if err != nil {
		return err
	}
	defer members.Close()
	for members.Next() {
		var litterID, hamsterID uuid.UUID
		if err := members.Scan(&litterID, &hamsterID); err != nil {
			return err
		}
		if index, ok := byID[litterID.String()]; ok {
			snapshot.Litters[index].MemberIDs = append(snapshot.Litters[index].MemberIDs, hamsterID.String())
		}
	}
	return members.Err()
}

func loadParentageSnapshot(ctx context.Context, tx pgx.Tx, ownerID uuid.UUID, snapshot *Snapshot) error {
	rows, err := tx.Query(ctx, `
		SELECT parent_id, child_id, role FROM pedigree_parentage
		WHERE owner_id=$1 AND status='accepted' AND valid_to IS NULL
	`, ownerID)
	if err != nil {
		return err
	}
	defer rows.Close()
	for rows.Next() {
		var parentID, childID uuid.UUID
		var item ParentageRecord
		if err := rows.Scan(&parentID, &childID, &item.Role); err != nil {
			return err
		}
		item.ParentID, item.ChildID = parentID.String(), childID.String()
		snapshot.Parentages = append(snapshot.Parentages, item)
	}
	return rows.Err()
}

func loadWeightKeys(ctx context.Context, tx pgx.Tx, ownerID uuid.UUID, snapshot *Snapshot) error {
	rows, err := tx.Query(ctx, `
		SELECT acquisition_key, id FROM weight_record
		WHERE owner_id=$1 AND acquisition_key IS NOT NULL
	`, ownerID)
	if err != nil {
		return err
	}
	defer rows.Close()
	for rows.Next() {
		var key string
		var id uuid.UUID
		if err := rows.Scan(&key, &id); err != nil {
			return err
		}
		snapshot.WeightAcquisitionKeys[key] = id.String()
	}
	return rows.Err()
}

func optionalUUID(value string) (*uuid.UUID, error) {
	if strings.TrimSpace(value) == "" {
		return nil, nil
	}
	parsed, err := uuid.Parse(value)
	if err != nil {
		return nil, err
	}
	return &parsed, nil
}

func jsonValue(value any) []byte {
	encoded, _ := json.Marshal(value)
	return encoded
}

func nullString(value string) any {
	if strings.TrimSpace(value) == "" {
		return nil
	}
	return value
}

func nullable(success bool, failureValue string) any {
	if success {
		return nil
	}
	return failureValue
}

func shortHash(value string) string {
	if len(value) <= 24 {
		return value
	}
	return value[:24]
}

func atomicFingerprint(planHash, groupKey string) string {
	digest := sha256.Sum256([]byte(planHash + "\x00" + groupKey))
	return hex.EncodeToString(digest[:])
}

func targetTableForTemplate(template TemplateType) string {
	switch template {
	case TemplateHamster:
		return "hamster"
	case TemplateEnclosure:
		return "enclosure"
	case TemplateWeight:
		return "weight_record"
	default:
		return ""
	}
}

func hasWarning(issues []Issue) bool {
	for _, issue := range issues {
		if issue.Severity == SeverityWarning {
			return true
		}
	}
	return false
}
