package i6data

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"math"
	"strconv"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/scolvpet/scolvpet/api/internal/store"
)

type Service struct {
	store *store.Store
	pool  *pgxpool.Pool
}

func NewService(s *store.Store) *Service {
	if s == nil {
		return &Service{}
	}
	return &Service{store: s, pool: s.Pool}
}

func NewServiceFromPool(pool *pgxpool.Pool) *Service {
	return &Service{pool: pool}
}

func (s *Service) ensureReady() error {
	if s.store == nil || s.pool == nil {
		return errors.New("i6 data store is unavailable")
	}
	return nil
}

func (s *Service) CreateExportJob(ctx context.Context, ownerID uuid.UUID, key, path string, payload []byte, input ExportJobInput) (WriteResult[ExportJob], error) {
	if err := ValidateExportJobInput(input); err != nil {
		return WriteResult[ExportJob]{}, err
	}
	if err := s.ensureReady(); err != nil {
		return WriteResult[ExportJob]{}, err
	}
	result, err := s.store.RunIdempotent(ctx, ownerID, key, "POST", path, payload, func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
		job, err := insertExportJobTx(ctx, tx, ownerID, key, input)
		if err != nil {
			return 0, nil, nil, err
		}
		return 202, job, map[string]string{
			"ETag":     store.FormatETag(job.Version),
			"Location": "/v1/data-center/export-jobs/" + job.ID.String(),
		}, nil
	})
	if err != nil {
		return WriteResult[ExportJob]{}, err
	}
	var job ExportJob
	if err := json.Unmarshal(result.Body, &job); err != nil {
		return WriteResult[ExportJob]{}, err
	}
	return WriteResult[ExportJob]{Value: job, Replayed: result.Replayed, Status: result.Status, Headers: result.Headers}, nil
}

func (s *Service) CreateBackupJob(ctx context.Context, ownerID uuid.UUID, key, path string, payload []byte, input BackupJobInput) (WriteResult[BackupJob], error) {
	if err := ValidateBackupJobInput(input); err != nil {
		return WriteResult[BackupJob]{}, err
	}
	if err := s.ensureReady(); err != nil {
		return WriteResult[BackupJob]{}, err
	}
	result, err := s.store.RunIdempotent(ctx, ownerID, key, "POST", path, payload, func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
		job, err := insertBackupJobTx(ctx, tx, ownerID, key, input)
		if err != nil {
			return 0, nil, nil, err
		}
		return 202, job, map[string]string{
			"ETag":     store.FormatETag(job.Version),
			"Location": "/v1/data-center/backup-jobs/" + job.ID.String(),
		}, nil
	})
	if err != nil {
		return WriteResult[BackupJob]{}, err
	}
	var job BackupJob
	if err := json.Unmarshal(result.Body, &job); err != nil {
		return WriteResult[BackupJob]{}, err
	}
	return WriteResult[BackupJob]{Value: job, Replayed: result.Replayed, Status: result.Status, Headers: result.Headers}, nil
}

func (s *Service) RetryExportJob(ctx context.Context, ownerID, jobID uuid.UUID, key, path, ifMatch string, payload []byte, input RetryJobInput) (WriteResult[ExportJob], error) {
	return s.retryExportJob(ctx, ownerID, jobID, key, path, ifMatch, payload, input)
}

func (s *Service) RetryBackupJob(ctx context.Context, ownerID, jobID uuid.UUID, key, path, ifMatch string, payload []byte, input RetryJobInput) (WriteResult[BackupJob], error) {
	return s.retryBackupJob(ctx, ownerID, jobID, key, path, ifMatch, payload, input)
}

func (s *Service) ListExportJobs(ctx context.Context, ownerID uuid.UUID, page Page) (ListResult[ExportJob], error) {
	if err := s.ensureReady(); err != nil {
		return ListResult[ExportJob]{}, err
	}
	page = normalizePage(page)
	rows, err := s.pool.Query(ctx, exportJobQuery+` WHERE e.owner_id=$1 ORDER BY e.created_at DESC, e.id DESC LIMIT $2 OFFSET $3`, ownerID, page.Limit+1, page.Offset)
	if err != nil {
		return ListResult[ExportJob]{}, err
	}
	defer rows.Close()
	items := make([]ExportJob, 0, page.Limit+1)
	for rows.Next() {
		job, err := scanExportJob(rows)
		if err != nil {
			return ListResult[ExportJob]{}, err
		}
		items = append(items, job)
	}
	if err := rows.Err(); err != nil {
		return ListResult[ExportJob]{}, err
	}
	return trimPage(items, page.Limit), nil
}

func (s *Service) GetExportJob(ctx context.Context, ownerID, jobID uuid.UUID) (ExportJob, error) {
	if err := s.ensureReady(); err != nil {
		return ExportJob{}, err
	}
	job, err := scanExportJob(s.pool.QueryRow(ctx, exportJobQuery+` WHERE e.owner_id=$1 AND e.id=$2`, ownerID, jobID))
	if errors.Is(err, pgx.ErrNoRows) {
		return ExportJob{}, ErrNotFound
	}
	return job, err
}

func (s *Service) ListBackupJobs(ctx context.Context, ownerID uuid.UUID, page Page) (ListResult[BackupJob], error) {
	if err := s.ensureReady(); err != nil {
		return ListResult[BackupJob]{}, err
	}
	page = normalizePage(page)
	rows, err := s.pool.Query(ctx, backupJobQuery+` WHERE b.owner_id=$1 ORDER BY b.created_at DESC, b.id DESC LIMIT $2 OFFSET $3`, ownerID, page.Limit+1, page.Offset)
	if err != nil {
		return ListResult[BackupJob]{}, err
	}
	defer rows.Close()
	items := make([]BackupJob, 0, page.Limit+1)
	for rows.Next() {
		job, err := scanBackupJob(rows)
		if err != nil {
			return ListResult[BackupJob]{}, err
		}
		items = append(items, job)
	}
	if err := rows.Err(); err != nil {
		return ListResult[BackupJob]{}, err
	}
	return trimPage(items, page.Limit), nil
}

func (s *Service) GetBackupJob(ctx context.Context, ownerID, jobID uuid.UUID) (BackupJob, error) {
	if err := s.ensureReady(); err != nil {
		return BackupJob{}, err
	}
	job, err := scanBackupJob(s.pool.QueryRow(ctx, backupJobQuery+` WHERE b.owner_id=$1 AND b.id=$2`, ownerID, jobID))
	if errors.Is(err, pgx.ErrNoRows) {
		return BackupJob{}, ErrNotFound
	}
	return job, err
}

func (s *Service) DownloadExportJob(ctx context.Context, ownerID, jobID uuid.UUID) (ExportJob, error) {
	job, err := s.GetExportJob(ctx, ownerID, jobID)
	if err != nil {
		return ExportJob{}, err
	}
	if job.Status != "succeeded" || job.ObjectKey == nil || job.SHA256 == nil || job.SizeBytes == nil {
		return ExportJob{}, ErrDownloadUnavailable
	}
	if job.ExpiresAt != nil && time.Now().UTC().After(*job.ExpiresAt) {
		return ExportJob{}, ErrDownloadUnavailable
	}
	return job, nil
}

func (s *Service) DownloadBackupJob(ctx context.Context, ownerID, jobID uuid.UUID) (BackupJob, error) {
	job, err := s.GetBackupJob(ctx, ownerID, jobID)
	if err != nil {
		return BackupJob{}, err
	}
	if job.Status != "succeeded" || job.ObjectKey == nil || job.SHA256 == nil || job.SizeBytes == nil {
		return BackupJob{}, ErrDownloadUnavailable
	}
	if job.ExpiresAt != nil && time.Now().UTC().After(*job.ExpiresAt) {
		return BackupJob{}, ErrDownloadUnavailable
	}
	return job, nil
}

func (s *Service) CurrentUsage(ctx context.Context, ownerID uuid.UUID) (Usage, error) {
	if err := s.ensureReady(); err != nil {
		return Usage{}, err
	}
	metrics, err := s.currentMetrics(ctx, ownerID)
	if err != nil {
		return Usage{}, err
	}
	return Usage{
		Metrics: metrics, MeteringStatus: "current",
		Entitlement: Entitlement{PlanCode: "free", Enforcement: "none", EffectiveAt: time.Now().UTC()},
	}, nil
}

func (s *Service) ListUsageSnapshots(ctx context.Context, ownerID uuid.UUID, page Page, from, to *time.Time) (ListResult[UsageSnapshot], error) {
	if err := s.ensureReady(); err != nil {
		return ListResult[UsageSnapshot]{}, err
	}
	page = normalizePage(page)
	args := []any{ownerID}
	where := ` WHERE owner_id=$1`
	if from != nil {
		args = append(args, *from)
		where += fmt.Sprintf(" AND COALESCE(period_end, snapshot_at) >= $%d", len(args))
	}
	if to != nil {
		args = append(args, *to)
		where += fmt.Sprintf(" AND COALESCE(period_start, snapshot_at) < $%d", len(args))
	}
	args = append(args, page.Limit+1, page.Offset)
	query := `WITH periods AS (
		SELECT min(id) AS id, COALESCE(period_start, snapshot_at) AS period_start,
		       COALESCE(period_end, snapshot_at) AS period_end, min(created_at) AS created_at
		FROM usage_snapshot` + where + `
		GROUP BY COALESCE(period_start, snapshot_at), COALESCE(period_end, snapshot_at)
		ORDER BY period_end DESC, period_start DESC
		LIMIT $` + strconv.Itoa(len(args)-1) + ` OFFSET $` + strconv.Itoa(len(args)) + `
	), metric_rows AS (
		SELECT p.id, p.period_start, p.period_end, p.created_at, s.metric::text,
		       s.value::float8, s.snapshot_at
		FROM periods p JOIN usage_snapshot s ON s.owner_id=$1
		 AND COALESCE(s.period_start, s.snapshot_at)=p.period_start
		 AND COALESCE(s.period_end, s.snapshot_at)=p.period_end
	)
	SELECT id, period_start, period_end, created_at, metric, value, snapshot_at
	FROM metric_rows ORDER BY period_end DESC, period_start DESC, metric`
	rows, err := s.pool.Query(ctx, query, args...)
	if err != nil {
		return ListResult[UsageSnapshot]{}, err
	}
	defer rows.Close()
	grouped := make([]UsageSnapshot, 0, page.Limit+1)
	index := map[string]int{}
	for rows.Next() {
		var id uuid.UUID
		var start, end, created, measured time.Time
		var metric string
		var value float64
		if err := rows.Scan(&id, &start, &end, &created, &metric, &value, &measured); err != nil {
			return ListResult[UsageSnapshot]{}, err
		}
		key := start.UTC().Format(time.RFC3339Nano) + "/" + end.UTC().Format(time.RFC3339Nano)
		idx, ok := index[key]
		if !ok {
			idx = len(grouped)
			index[key] = idx
			grouped = append(grouped, UsageSnapshot{ID: id, PeriodStart: start, PeriodEnd: end, CreatedAt: created, Metrics: make([]UsageMetric, 0, len(UsageMetrics))})
		}
		grouped[idx].Metrics = append(grouped[idx].Metrics, UsageMetric{Metric: metric, Used: value, Unit: usageUnit(metric), MeasuredAt: measured})
	}
	if err := rows.Err(); err != nil {
		return ListResult[UsageSnapshot]{}, err
	}
	return trimPage(grouped, page.Limit), nil
}

func (s *Service) Summary(ctx context.Context, ownerID uuid.UUID) (Summary, error) {
	usage, err := s.CurrentUsage(ctx, ownerID)
	if err != nil {
		return Summary{}, err
	}
	exports, err := s.ListExportJobs(ctx, ownerID, Page{Limit: 5})
	if err != nil {
		return Summary{}, err
	}
	backups, err := s.ListBackupJobs(ctx, ownerID, Page{Limit: 5})
	if err != nil {
		return Summary{}, err
	}
	imports, err := s.listRecentImports(ctx, ownerID)
	if err != nil {
		return Summary{}, err
	}
	return Summary{RecentImports: imports, RecentExports: exports.Items, RecentBackups: backups.Items, Usage: usage.Metrics, UsageStatus: usage.MeteringStatus}, nil
}

func normalizePage(page Page) Page {
	if page.Limit < 1 || page.Limit > 200 {
		page.Limit = 50
	}
	if page.Offset < 0 {
		page.Offset = 0
	}
	return page
}

func trimPage[T any](items []T, limit int) ListResult[T] {
	result := ListResult[T]{Items: items, HasMore: false}
	if len(items) > limit {
		result.HasMore = true
		result.Items = items[:limit]
	}
	return result
}

func (s *Service) currentMetrics(ctx context.Context, ownerID uuid.UUID) ([]UsageMetric, error) {
	rows, err := s.pool.Query(ctx, `SELECT metric::text, current_value::float8, measured_at FROM usage_meter WHERE owner_id=$1`, ownerID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	values := make(map[string]UsageMetric, len(UsageMetrics))
	now := time.Now().UTC()
	for rows.Next() {
		var metric string
		var used float64
		var measured time.Time
		if err := rows.Scan(&metric, &used, &measured); err != nil {
			return nil, err
		}
		values[metric] = UsageMetric{Metric: metric, Used: used, Unit: usageUnit(metric), MeasuredAt: measured}
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	result := make([]UsageMetric, 0, len(UsageMetrics))
	for _, metric := range UsageMetrics {
		item, ok := values[metric]
		if !ok {
			item = UsageMetric{Metric: metric, Unit: usageUnit(metric), MeasuredAt: now}
		}
		result = append(result, item)
	}
	return result, nil
}

func (s *Service) listRecentImports(ctx context.Context, ownerID uuid.UUID) ([]map[string]any, error) {
	rows, err := s.pool.Query(ctx, `SELECT ij.id, a.id, a.status::text, a.progress_percent::float8,
		ij.template_type::text, a.version, a.created_at, a.updated_at, a.attempt_count,
		COALESCE(a.result_payload, '{}'::jsonb), COALESCE(a.error_code, ''), COALESCE(a.error_detail, ''),
		ij.total_rows, ij.valid_rows, ij.invalid_rows, ij.imported_rows
		FROM import_job ij JOIN async_job a ON a.owner_id=ij.owner_id AND a.id=ij.async_job_id
		WHERE ij.owner_id=$1 ORDER BY ij.created_at DESC, ij.id DESC LIMIT 5`, ownerID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	items := make([]map[string]any, 0, 5)
	for rows.Next() {
		var id, asyncID uuid.UUID
		var status, template, errorCode, errorDetail string
		var progress float64
		var version, attempts, total, valid, invalid, imported int
		var created, updated time.Time
		var resultPayload []byte
		if err := rows.Scan(&id, &asyncID, &status, &progress, &template, &version, &created, &updated, &attempts, &resultPayload, &errorCode, &errorDetail, &total, &valid, &invalid, &imported); err != nil {
			return nil, err
		}
		var result map[string]any
		_ = json.Unmarshal(resultPayload, &result)
		if result == nil {
			result = map[string]any{}
		}
		item := map[string]any{
			"id": id, "job_type": "import", "status": status, "progress_percent": int(math.Round(progress)),
			"current_step": nil, "error": nil, "retryable": status == "failed", "attempt": attempts + 1,
			"result": result, "expires_at": nil, "version": version, "created_at": created, "updated_at": updated,
			"template_type": template, "phase": importPhase(status), "source_encoding": nil, "source_columns": []string{},
			"mapping": map[string]string{}, "preflight_version": nil, "total_rows": total, "valid_rows": valid,
			"warning_rows": 0, "invalid_rows": invalid, "imported_rows": imported,
			"historical_litters_to_create": 0, "relationship_assertions_to_create": 0, "blocking_issue_count": invalid,
			"async_job_id": asyncID,
		}
		if errorCode != "" || errorDetail != "" {
			item["error"] = map[string]any{"code": errorCode, "message": errorDetail}
		}
		items = append(items, item)
	}
	return items, rows.Err()
}

func importPhase(status string) string {
	switch status {
	case "queued", "running":
		return "importing"
	case "succeeded", "failed", "cancelled":
		return "completed"
	default:
		return "detecting"
	}
}

func insertExportJobTx(ctx context.Context, tx pgx.Tx, ownerID uuid.UUID, key string, input ExportJobInput) (ExportJob, error) {
	org, err := store.EnsureOrganizationTx(ctx, tx, ownerID)
	if err != nil {
		return ExportJob{}, err
	}
	payload, err := json.Marshal(input)
	if err != nil {
		return ExportJob{}, err
	}
	asyncID := uuid.New()
	if _, err := tx.Exec(ctx, `INSERT INTO async_job (id, owner_id, organization_id, job_type, request_payload, idempotency_key, created_by)
		VALUES ($1,$2,$3,'export',$4,$5,$2)`, asyncID, ownerID, uuid.MustParse(org.ID), payload, key); err != nil {
		return ExportJob{}, err
	}
	datasets, _ := json.Marshal(input.Datasets)
	scope := input.Datasets[0]
	if len(input.Datasets) > 1 {
		scope = "full"
	}
	jobID := uuid.New()
	snapshotAt := time.Now().UTC()
	if _, err := tx.Exec(ctx, `INSERT INTO export_job
		(id, owner_id, organization_id, async_job_id, scope, format, filters, datasets, timezone, snapshot_at, created_by)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$2)`, jobID, ownerID, uuid.MustParse(org.ID), asyncID, scope, exportDBFormat(input.Format), jsonObject(input.Filters), datasets, input.Timezone, snapshotAt); err != nil {
		return ExportJob{}, err
	}
	if err := appendEventTx(ctx, tx, ownerID, uuid.MustParse(org.ID), jobID, "export_job", "EXPORT_JOB_CREATED", map[string]any{"async_job_id": asyncID, "datasets": input.Datasets, "format": input.Format}, key); err != nil {
		return ExportJob{}, err
	}
	return ExportJob{ID: jobID, OwnerID: ownerID, AsyncJobID: asyncID, JobType: "export", Status: "queued", ProgressPercent: 0, Retryable: false, Attempt: 1, Result: map[string]any{}, Version: 1, CreatedAt: snapshotAt, UpdatedAt: snapshotAt, Datasets: input.Datasets, ExportFormat: input.Format, SnapshotAt: snapshotAt}, nil
}

func insertBackupJobTx(ctx context.Context, tx pgx.Tx, ownerID uuid.UUID, key string, input BackupJobInput) (BackupJob, error) {
	org, err := store.EnsureOrganizationTx(ctx, tx, ownerID)
	if err != nil {
		return BackupJob{}, err
	}
	payload, err := json.Marshal(input)
	if err != nil {
		return BackupJob{}, err
	}
	asyncID, jobID := uuid.New(), uuid.New()
	if _, err := tx.Exec(ctx, `INSERT INTO async_job (id, owner_id, organization_id, job_type, request_payload, idempotency_key, created_by)
		VALUES ($1,$2,$3,'backup',$4,$5,$2)`, asyncID, ownerID, uuid.MustParse(org.ID), payload, key); err != nil {
		return BackupJob{}, err
	}
	created := time.Now().UTC()
	if _, err := tx.Exec(ctx, `INSERT INTO backup_job
		(id, owner_id, organization_id, async_job_id, backup_kind, manifest_version, manifest, created_by)
		VALUES ($1,$2,$3,$4,'full','i6-v1',$5,$2)`, jobID, ownerID, uuid.MustParse(org.ID), asyncID, jsonObject(map[string]any{"include_media_manifest": true, "include_checksums": true})); err != nil {
		return BackupJob{}, err
	}
	if err := appendEventTx(ctx, tx, ownerID, uuid.MustParse(org.ID), jobID, "backup_job", "BACKUP_JOB_CREATED", map[string]any{"async_job_id": asyncID, "encryption_hint": input.EncryptionHint}, key); err != nil {
		return BackupJob{}, err
	}
	return BackupJob{ID: jobID, OwnerID: ownerID, AsyncJobID: asyncID, JobType: "backup", Status: "queued", ProgressPercent: 0, Retryable: false, Attempt: 1, Result: map[string]any{}, Version: 1, CreatedAt: created, UpdatedAt: created, IncludesStructuredData: true, IncludesMediaManifest: true, IncludesChecksums: true, IntegrityStatus: "pending", RestoreReadiness: "not_ready"}, nil
}

func (s *Service) retryExportJob(ctx context.Context, ownerID, jobID uuid.UUID, key, path, ifMatch string, payload []byte, input RetryJobInput) (WriteResult[ExportJob], error) {
	if err := ValidateRetryJobInput(input); err != nil {
		return WriteResult[ExportJob]{}, err
	}
	if err := s.ensureReady(); err != nil {
		return WriteResult[ExportJob]{}, err
	}
	result, err := s.store.RunIdempotent(ctx, ownerID, key, "POST", path, payload, func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
		job, err := retryExportJobTx(ctx, tx, ownerID, jobID, key, ifMatch, input)
		if err != nil {
			return 0, nil, nil, err
		}
		return 202, job, map[string]string{"ETag": store.FormatETag(job.Version)}, nil
	})
	if err != nil {
		return WriteResult[ExportJob]{}, err
	}
	var job ExportJob
	if err := json.Unmarshal(result.Body, &job); err != nil {
		return WriteResult[ExportJob]{}, err
	}
	return WriteResult[ExportJob]{Value: job, Replayed: result.Replayed, Status: result.Status, Headers: result.Headers}, nil
}

func (s *Service) retryBackupJob(ctx context.Context, ownerID, jobID uuid.UUID, key, path, ifMatch string, payload []byte, input RetryJobInput) (WriteResult[BackupJob], error) {
	if err := ValidateRetryJobInput(input); err != nil {
		return WriteResult[BackupJob]{}, err
	}
	if err := s.ensureReady(); err != nil {
		return WriteResult[BackupJob]{}, err
	}
	result, err := s.store.RunIdempotent(ctx, ownerID, key, "POST", path, payload, func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
		job, err := retryBackupJobTx(ctx, tx, ownerID, jobID, key, ifMatch, input)
		if err != nil {
			return 0, nil, nil, err
		}
		return 202, job, map[string]string{"ETag": store.FormatETag(job.Version)}, nil
	})
	if err != nil {
		return WriteResult[BackupJob]{}, err
	}
	var job BackupJob
	if err := json.Unmarshal(result.Body, &job); err != nil {
		return WriteResult[BackupJob]{}, err
	}
	return WriteResult[BackupJob]{Value: job, Replayed: result.Replayed, Status: result.Status, Headers: result.Headers}, nil
}

func retryExportJobTx(ctx context.Context, tx pgx.Tx, ownerID, jobID uuid.UUID, key, ifMatch string, input RetryJobInput) (ExportJob, error) {
	version, err := store.ParseETag(ifMatch)
	if err != nil {
		return ExportJob{}, fmt.Errorf("%w: current=0", ErrVersionConflict)
	}
	var asyncID, orgID uuid.UUID
	var status string
	var currentVersion int
	var requestPayload []byte
	var datasets []byte
	var dbFormat, timezone string
	var filters []byte
	var snapshotAt time.Time
	if err := tx.QueryRow(ctx, `SELECT e.async_job_id, e.organization_id, a.status::text, e.version, a.request_payload,
		e.datasets, e.format::text, e.filters, e.timezone, e.snapshot_at
		FROM export_job e JOIN async_job a ON a.owner_id=e.owner_id AND a.id=e.async_job_id
		WHERE e.owner_id=$1 AND e.id=$2 FOR UPDATE`, ownerID, jobID).Scan(&asyncID, &orgID, &status, &currentVersion, &requestPayload, &datasets, &dbFormat, &filters, &timezone, &snapshotAt); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return ExportJob{}, ErrNotFound
		}
		return ExportJob{}, err
	}
	if version != currentVersion {
		return ExportJob{}, fmt.Errorf("%w: current=%d", ErrVersionConflict, currentVersion)
	}
	if status != "failed" {
		return ExportJob{}, fmt.Errorf("%w: export job status is %s", ErrConflict, status)
	}
	newAsync, newJob := uuid.New(), uuid.New()
	if _, err := tx.Exec(ctx, `INSERT INTO async_job (id, owner_id, organization_id, job_type, request_payload, idempotency_key, created_by)
		VALUES ($1,$2,$3,'export',$4,$5,$2)`, newAsync, ownerID, orgID, requestPayload, key); err != nil {
		return ExportJob{}, err
	}
	if _, err := tx.Exec(ctx, `INSERT INTO export_job
		(id, owner_id, organization_id, async_job_id, scope, format, filters, datasets, timezone, snapshot_at, created_by)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$2)`, newJob, ownerID, orgID, newAsync, exportScopeFromJSON(datasets), dbFormat, filters, datasets, timezone, snapshotAt); err != nil {
		return ExportJob{}, err
	}
	if err := appendEventTx(ctx, tx, ownerID, orgID, newJob, "export_job", "EXPORT_JOB_RETRIED", map[string]any{"previous_job_id": jobID, "reason": input.Reason, "previous_async_job_id": asyncID}, key); err != nil {
		return ExportJob{}, err
	}
	now := time.Now().UTC()
	var decoded []string
	_ = json.Unmarshal(datasets, &decoded)
	format := "json"
	if dbFormat == "zip" {
		format = "csv_zip"
	}
	return ExportJob{ID: newJob, OwnerID: ownerID, AsyncJobID: newAsync, JobType: "export", Status: "queued", ProgressPercent: 0, Attempt: 1, Result: map[string]any{}, Version: 1, CreatedAt: now, UpdatedAt: now, Datasets: decoded, ExportFormat: format, SnapshotAt: snapshotAt}, nil
}

func retryBackupJobTx(ctx context.Context, tx pgx.Tx, ownerID, jobID uuid.UUID, key, ifMatch string, input RetryJobInput) (BackupJob, error) {
	version, err := store.ParseETag(ifMatch)
	if err != nil {
		return BackupJob{}, fmt.Errorf("%w: current=0", ErrVersionConflict)
	}
	var orgID, asyncID uuid.UUID
	var status string
	var currentVersion int
	var requestPayload, manifest []byte
	var manifestVersion string
	if err := tx.QueryRow(ctx, `SELECT b.organization_id, b.async_job_id, a.status::text, b.version, a.request_payload, b.manifest_version, b.manifest
		FROM backup_job b JOIN async_job a ON a.owner_id=b.owner_id AND a.id=b.async_job_id
		WHERE b.owner_id=$1 AND b.id=$2 FOR UPDATE`, ownerID, jobID).Scan(&orgID, &asyncID, &status, &currentVersion, &requestPayload, &manifestVersion, &manifest); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return BackupJob{}, ErrNotFound
		}
		return BackupJob{}, err
	}
	if version != currentVersion {
		return BackupJob{}, fmt.Errorf("%w: current=%d", ErrVersionConflict, currentVersion)
	}
	if status != "failed" {
		return BackupJob{}, fmt.Errorf("%w: backup job status is %s", ErrConflict, status)
	}
	newAsync, newJob := uuid.New(), uuid.New()
	if _, err := tx.Exec(ctx, `INSERT INTO async_job (id, owner_id, organization_id, job_type, request_payload, idempotency_key, created_by)
		VALUES ($1,$2,$3,'backup',$4,$5,$2)`, newAsync, ownerID, orgID, requestPayload, key); err != nil {
		return BackupJob{}, err
	}
	if _, err := tx.Exec(ctx, `INSERT INTO backup_job
		(id, owner_id, organization_id, async_job_id, backup_kind, base_backup_job_id, manifest_version, manifest, created_by)
		VALUES ($1,$2,$3,$4,'full',$5,$6,$7,$2)`, newJob, ownerID, orgID, newAsync, jobID, manifestVersion, manifest); err != nil {
		return BackupJob{}, err
	}
	if err := appendEventTx(ctx, tx, ownerID, orgID, newJob, "backup_job", "BACKUP_JOB_RETRIED", map[string]any{"previous_job_id": jobID, "reason": input.Reason, "previous_async_job_id": asyncID}, key); err != nil {
		return BackupJob{}, err
	}
	now := time.Now().UTC()
	return BackupJob{ID: newJob, OwnerID: ownerID, AsyncJobID: newAsync, JobType: "backup", Status: "queued", ProgressPercent: 0, Attempt: 1, Result: map[string]any{}, Version: 1, CreatedAt: now, UpdatedAt: now, IncludesStructuredData: true, IncludesMediaManifest: true, IncludesChecksums: true, IntegrityStatus: "pending", RestoreReadiness: "not_ready"}, nil
}

const exportJobQuery = `SELECT e.id, e.owner_id, e.async_job_id, a.status::text, a.progress_percent::float8,
	 a.error_code, a.error_detail, a.attempt_count, a.result_payload, a.version, a.created_at, a.updated_at,
	 e.version, e.datasets, e.format::text, e.snapshot_at, e.file_name, e.byte_size, e.sha256, e.object_key, e.expires_at
	 FROM export_job e JOIN async_job a ON a.owner_id=e.owner_id AND a.id=e.async_job_id`

const backupJobQuery = `SELECT b.id, b.owner_id, b.async_job_id, a.status::text, a.progress_percent::float8,
	 a.error_code, a.error_detail, a.attempt_count, a.result_payload, a.version, a.created_at, a.updated_at,
	 b.version, b.byte_size, b.sha256, b.object_key, b.verified_at, b.is_restorable, b.expires_at
	 FROM backup_job b JOIN async_job a ON a.owner_id=b.owner_id AND a.id=b.async_job_id`

type rowScanner interface{ Scan(...any) error }

func scanExportJob(row rowScanner) (ExportJob, error) {
	var job ExportJob
	var progress float64
	var errorCode, errorDetail string
	var attempts int
	var resultPayload, datasets []byte
	var asyncVersion, exportVersion int
	var fileName, sha, objectKey *string
	var size *int64
	var expires *time.Time
	if err := row.Scan(&job.ID, &job.OwnerID, &job.AsyncJobID, &job.Status, &progress, &errorCode, &errorDetail, &attempts, &resultPayload, &asyncVersion, &job.CreatedAt, &job.UpdatedAt, &exportVersion, &datasets, &job.ExportFormat, &job.SnapshotAt, &fileName, &size, &sha, &objectKey, &expires); err != nil {
		return ExportJob{}, err
	}
	job.Version = exportVersion
	job.ProgressPercent = int(math.Round(progress))
	job.Attempt = attempts + 1
	job.Result = decodeMap(resultPayload)
	_ = json.Unmarshal(datasets, &job.Datasets)
	if job.Datasets == nil {
		job.Datasets = []string{scopeToDataset(job.ExportFormat)}
	}
	if job.ExportFormat == "zip" {
		job.ExportFormat = "csv_zip"
	}
	job.FileName, job.SizeBytes, job.SHA256, job.ObjectKey, job.ExpiresAt = fileName, size, sha, objectKey, expires
	job.Retryable = job.Status == "failed"
	if errorCode != "" || errorDetail != "" {
		job.Error = map[string]any{"code": errorCode, "message": errorDetail}
	}
	return job, nil
}

func scanBackupJob(row rowScanner) (BackupJob, error) {
	var job BackupJob
	var progress float64
	var errorCode, errorDetail string
	var attempts int
	var resultPayload []byte
	var asyncVersion, backupVersion int
	var sha, objectKey *string
	var size *int64
	var verified, expires *time.Time
	if err := row.Scan(&job.ID, &job.OwnerID, &job.AsyncJobID, &job.Status, &progress, &errorCode, &errorDetail, &attempts, &resultPayload, &asyncVersion, &job.CreatedAt, &job.UpdatedAt, &backupVersion, &size, &sha, &objectKey, &verified, &job.Restorable, &expires); err != nil {
		return BackupJob{}, err
	}
	job.Version = backupVersion
	job.ProgressPercent = int(math.Round(progress))
	job.Attempt = attempts + 1
	job.Result = decodeMap(resultPayload)
	job.SizeBytes, job.SHA256, job.ObjectKey, job.VerifiedAt, job.ExpiresAt = size, sha, objectKey, verified, expires
	job.IncludesStructuredData, job.IncludesMediaManifest, job.IncludesChecksums = true, true, true
	job.IntegrityStatus = "pending"
	job.RestoreReadiness = "not_ready"
	if job.Status == "failed" {
		job.IntegrityStatus, job.RestoreReadiness, job.Retryable = "failed", "blocked", true
	} else if job.Status == "succeeded" {
		if job.VerifiedAt != nil {
			job.IntegrityStatus = "verified"
		}
		if job.Restorable {
			job.RestoreReadiness = "downloadable_restore_basis"
		}
	}
	if errorCode != "" || errorDetail != "" {
		job.Error = map[string]any{"code": errorCode, "message": errorDetail}
	}
	return job, nil
}

func decodeMap(data []byte) map[string]any {
	var result map[string]any
	_ = json.Unmarshal(data, &result)
	if result == nil {
		result = map[string]any{}
	}
	return result
}

func exportDBFormat(format string) string {
	if format == "csv_zip" {
		return "zip"
	}
	return format
}

func exportScopeFromJSON(data []byte) string {
	var datasets []string
	_ = json.Unmarshal(data, &datasets)
	if len(datasets) == 0 {
		return "full"
	}
	if len(datasets) > 1 {
		return "full"
	}
	return datasets[0]
}

func scopeToDataset(scope string) string {
	if scope == "zip" || scope == "json" || scope == "full" {
		return "hamsters"
	}
	return scope
}

func jsonObject(value map[string]any) []byte {
	if value == nil {
		return []byte(`{}`)
	}
	data, _ := json.Marshal(value)
	return data
}

func appendEventTx(ctx context.Context, tx pgx.Tx, ownerID, organizationID, aggregateID uuid.UUID, aggregateType, eventType string, payload map[string]any, idempotencyKey string) error {
	var version int
	if err := tx.QueryRow(ctx, `SELECT COALESCE(max(event_version),0)+1 FROM domain_event WHERE owner_id=$1 AND aggregate_type=$2 AND aggregate_id=$3`, ownerID, aggregateType, aggregateID).Scan(&version); err != nil {
		return err
	}
	var eventID uuid.UUID
	data, _ := json.Marshal(payload)
	if err := tx.QueryRow(ctx, `INSERT INTO domain_event (owner_id, organization_id, aggregate_type, aggregate_id, event_type, event_version, actor_id, occurred_at, payload, idempotency_key)
		VALUES ($1,$2,$3,$4,$5,$6,$1,now(),$7,$8) RETURNING id`, ownerID, organizationID, aggregateType, aggregateID, eventType, version, data, idempotencyKey).Scan(&eventID); err != nil {
		return err
	}
	outboxPayload, _ := json.Marshal(map[string]any{"event_id": eventID, "event_type": eventType, "aggregate_type": aggregateType, "aggregate_id": aggregateID, "payload": payload})
	_, err := tx.Exec(ctx, `INSERT INTO outbox_message (owner_id, domain_event_id, topic, partition_key, payload) VALUES ($1,$2,$3,$4,$5)`, ownerID, eventID, "domain."+strings.ToLower(aggregateType), aggregateID.String(), outboxPayload)
	return err
}

func hashPayload(data []byte) string {
	digest := sha256.Sum256(data)
	return hex.EncodeToString(digest[:])
}
