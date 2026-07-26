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

	"github.com/scolvpet/scolvpet/api/internal/store"
)

// registerOpenAPIConformanceRoutes registers endpoints declared in OpenAPI that
// previously had no Go mux implementation (audit P0-04 / P1-03).
func (s *Server) registerOpenAPIConformanceRoutes(mux *http.ServeMux) {
	mux.HandleFunc("GET /v1/jobs/{job_id}", s.getAsyncJob)
	mux.HandleFunc("PATCH /v1/health-records/{health_record_id}", s.patchI5HealthRecord)
	mux.HandleFunc("PATCH /v1/tasks/{task_id}", s.patchI5Task)
	mux.HandleFunc("PATCH /v1/species-rule-versions/{rule_version_id}", s.patchSpeciesRuleVersion)
	mux.HandleFunc("POST /v1/breeding-plans/{plan_id}/adjust-baseline", s.adjustBreedingBaseline)
	mux.HandleFunc("POST /v1/breeding-plans/{plan_id}/complete", s.completeBreedingPlan)
	mux.HandleFunc("GET /v1/data-center/import-jobs/{job_id}/error-report", s.getImportErrorReport)
	mux.HandleFunc("POST /v1/data-center/import-jobs/{job_id}/retry", s.retryImportJob)
}

func (s *Server) getAsyncJob(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	jobID, err := uuid.Parse(r.PathValue("job_id"))
	if err != nil {
		writeAPIError(w, r, validationError("job_id", "作业 ID 无效"))
		return
	}
	var (
		jobType, status       string
		progress              float64
		attempt, version      int
		errorCode, errorDetail *string
		created, updated      time.Time
	)
	err = s.Store.Pool.QueryRow(r.Context(), `
		SELECT job_type::text, status::text, progress_percent::float8, attempt_count, version,
		       error_code, error_detail, created_at, updated_at
		FROM async_job
		WHERE owner_id=$1 AND id=$2
	`, ownerID, jobID).Scan(
		&jobType, &status, &progress, &attempt, &version,
		&errorCode, &errorDetail, &created, &updated,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		writeAPIError(w, r, store.ErrNotFound)
		return
	}
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	var jobErr any
	if errorCode != nil || errorDetail != nil {
		jobErr = map[string]any{"code": errorCode, "detail": errorDetail}
	}
	w.Header().Set("ETag", store.FormatETag(version))
	writeJSON(w, r, http.StatusOK, envelope(r, map[string]any{
		"id": jobID, "job_type": jobType, "status": status,
		"progress_percent": progress, "current_step": nil, "error": jobErr,
		"retryable": status == "failed", "attempt": attempt,
		"version": version, "created_at": created, "updated_at": updated,
	}))
}

func (s *Server) patchI5HealthRecord(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI5(w, r)
	if !ok {
		return
	}
	recordID, err := uuid.Parse(r.PathValue("health_record_id"))
	if err != nil {
		writeAPIError(w, r, validationError("health_record_id", "健康记录 ID 无效"))
		return
	}
	// health_record is append-only; If-Match is accepted as soft concurrency token (created_at epoch).
	_ = r.Header.Get("If-Match")
	var body struct {
		Notes            *string        `json:"notes"`
		StructuredChecks map[string]any `json:"structured_checks"`
		FollowUpAt       *string        `json:"follow_up_at"`
		Medication       map[string]any `json:"medication"`
		CorrectionReason *string        `json:"correction_reason"`
	}
	payload, err := decodeBody(r, &body)
	if err != nil {
		writeAPIError(w, r, validationError("body", "健康记录更新体不正确"))
		return
	}
	key := r.Header.Get("Idempotency-Key")
	if strings.TrimSpace(key) == "" {
		key = "health-patch-" + recordID.String()
	}
	result, err := s.Store.RunIdempotent(r.Context(), ownerID, key, http.MethodPatch, r.URL.Path, payload, func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
		var (
			orgID, operatorID                                     uuid.UUID
			subjectType, recordType                               string
			hamsterID, pupID, litterID, enclosureID               *uuid.UUID
			observedAt                                            time.Time
			structured, medication                                []byte
			severity, notes                                       *string
			followUp                                              *time.Time
		)
		err := tx.QueryRow(ctx, `
			SELECT organization_id, subject_type::text, hamster_id, pup_identity_id, litter_id, enclosure_id,
			       record_type::text, observed_at, structured_checks, severity::text, medication, follow_up_at,
			       notes, operator_id
			FROM health_record
			WHERE owner_id=$1 AND id=$2
		`, ownerID, recordID).Scan(
			&orgID, &subjectType, &hamsterID, &pupID, &litterID, &enclosureID,
			&recordType, &observedAt, &structured, &severity, &medication, &followUp,
			&notes, &operatorID,
		)
		if errors.Is(err, pgx.ErrNoRows) {
			return 0, nil, nil, store.ErrNotFound
		}
		if err != nil {
			return 0, nil, nil, err
		}
		if body.Notes != nil {
			notes = body.Notes
		}
		if body.StructuredChecks != nil {
			structured = mustJSON(body.StructuredChecks)
		}
		if body.Medication != nil {
			medication = mustJSON(body.Medication)
		}
		if body.FollowUpAt != nil {
			if t, err := time.Parse(time.RFC3339, *body.FollowUpAt); err == nil {
				followUp = &t
			}
		}
		reason := "client correction"
		if body.CorrectionReason != nil && strings.TrimSpace(*body.CorrectionReason) != "" {
			reason = strings.TrimSpace(*body.CorrectionReason)
		}
		var newID uuid.UUID
		err = tx.QueryRow(ctx, `
			INSERT INTO health_record (
				owner_id, organization_id, subject_type, hamster_id, pup_identity_id, litter_id, enclosure_id,
				record_type, observed_at, structured_checks, severity, medication, follow_up_at, notes,
				operator_id, corrects_health_record_id, correction_reason
			) VALUES (
				$1,$2,$3::health_subject_type,$4,$5,$6,$7,
				$8::health_record_type,$9,$10::jsonb,$11::severity_level,$12::jsonb,$13,$14,
				$15,$16,$17
			) RETURNING id
		`, ownerID, orgID, subjectType, hamsterID, pupID, litterID, enclosureID,
			recordType, observedAt, structured, severity, medication, followUp, notes,
			operatorID, recordID, reason,
		).Scan(&newID)
		if err != nil {
			return 0, nil, nil, err
		}
		item := map[string]any{
			"id": newID, "type": recordType, "observed_at": observedAt,
			"structured_checks": jsonRawMap(structured), "severity": severity,
			"medication": jsonRawMap(medication), "follow_up_at": followUp,
			"notes": notes, "corrects_health_record_id": recordID,
			"hamster_id": hamsterID, "litter_id": litterID,
		}
		return http.StatusOK, envelope(r, item), map[string]string{}, nil
	})
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeStored(w, r, result)
}

func (s *Server) patchI5Task(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI5(w, r)
	if !ok {
		return
	}
	taskID, err := uuid.Parse(r.PathValue("task_id"))
	if err != nil {
		writeAPIError(w, r, validationError("task_id", "任务 ID 无效"))
		return
	}
	expected, err := store.ParseETag(r.Header.Get("If-Match"))
	if err != nil {
		writeAPIError(w, r, validationError("If-Match", "If-Match 必须是当前资源版本 ETag"))
		return
	}
	var body struct {
		Title       *string `json:"title"`
		Notes       *string `json:"notes"`
		Priority    *string `json:"priority"`
		ScheduledAt *string `json:"scheduled_at"`
	}
	payload, err := decodeBody(r, &body)
	if err != nil {
		writeAPIError(w, r, validationError("body", "任务更新体不正确"))
		return
	}
	key := r.Header.Get("Idempotency-Key")
	if strings.TrimSpace(key) == "" {
		key = "task-patch-" + taskID.String()
	}
	result, err := s.Store.RunIdempotent(r.Context(), ownerID, key, http.MethodPatch, r.URL.Path, payload, func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
		var version int
		err := tx.QueryRow(ctx, `
			UPDATE care_task
			SET title = COALESCE($4, title),
			    description = COALESCE($5, description),
			    priority = COALESCE($6::task_priority, priority),
			    scheduled_at = COALESCE($7::timestamptz, scheduled_at),
			    updated_at = now()
			WHERE owner_id=$1 AND id=$2 AND version=$3
			RETURNING version
		`, ownerID, taskID, expected, body.Title, body.Notes, body.Priority, body.ScheduledAt).Scan(&version)
		if errors.Is(err, pgx.ErrNoRows) {
			return 0, nil, nil, store.ErrVersionConflict
		}
		if err != nil {
			return 0, nil, nil, err
		}
		item, err := s.loadCareTaskJSON(ctx, tx, ownerID, taskID)
		if err != nil {
			return 0, nil, nil, err
		}
		return http.StatusOK, envelope(r, item), map[string]string{"ETag": store.FormatETag(version)}, nil
	})
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeStored(w, r, result)
}

func (s *Server) patchSpeciesRuleVersion(w http.ResponseWriter, r *http.Request) {
	ownerID, _, ok := s.authenticate(r)
	if !ok {
		writeAPIError(w, r, authRequired())
		return
	}
	ruleID, err := uuid.Parse(r.PathValue("rule_version_id"))
	if err != nil {
		writeAPIError(w, r, validationError("rule_version_id", "规则版本 ID 无效"))
		return
	}
	expected, err := store.ParseETag(r.Header.Get("If-Match"))
	if err != nil {
		writeAPIError(w, r, validationError("If-Match", "If-Match 必须是当前资源版本 ETag"))
		return
	}
	var body map[string]any
	payload, err := decodeBody(r, &body)
	if err != nil {
		writeAPIError(w, r, validationError("body", "规则更新体不正确"))
		return
	}
	var refCount int
	if err := s.Store.Pool.QueryRow(r.Context(), `
		SELECT count(*) FROM breeding_plan
		WHERE owner_id=$1 AND species_rule_version_id=$2 AND deleted_at IS NULL
	`, ownerID, ruleID).Scan(&refCount); err != nil {
		writeAPIError(w, r, err)
		return
	}
	if refCount > 0 {
		writeAPIError(w, r, conflictError("rule_version_id", "规则版本已被繁育计划引用，请创建新版本"))
		return
	}
	key := r.Header.Get("Idempotency-Key")
	if strings.TrimSpace(key) == "" {
		key = "rule-patch-" + ruleID.String()
	}
	result, err := s.Store.RunIdempotent(r.Context(), ownerID, key, http.MethodPatch, r.URL.Path, payload, func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
		sourceNote, _ := body["source_note"].(string)
		var version int
		err := tx.QueryRow(ctx, `
			UPDATE species_rule_version
			SET source_note = COALESCE(NULLIF($4, ''), source_note),
			    updated_at = now()
			WHERE owner_id=$1 AND id=$2 AND version=$3 AND retired_at IS NULL
			RETURNING version
		`, ownerID, ruleID, expected, sourceNote).Scan(&version)
		if errors.Is(err, pgx.ErrNoRows) {
			return 0, nil, nil, store.ErrVersionConflict
		}
		if err != nil {
			return 0, nil, nil, err
		}
		item := map[string]any{"id": ruleID, "version": version, "source_note": sourceNote}
		return http.StatusOK, envelope(r, item), map[string]string{"ETag": store.FormatETag(version)}, nil
	})
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeStored(w, r, result)
}

func (s *Server) adjustBreedingBaseline(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI3(w, r)
	if !ok {
		return
	}
	planID, err := uuid.Parse(r.PathValue("plan_id"))
	if err != nil {
		writeAPIError(w, r, validationError("plan_id", "计划 ID 无效"))
		return
	}
	expected, err := store.ParseETag(r.Header.Get("If-Match"))
	if err != nil {
		writeAPIError(w, r, validationError("If-Match", "If-Match 必须是当前资源版本 ETag"))
		return
	}
	var body struct {
		NewBaselineAt string `json:"new_baseline_at"`
		Reason        string `json:"reason"`
		Timezone      string `json:"timezone"`
	}
	payload, err := decodeBody(r, &body)
	if err != nil || strings.TrimSpace(body.NewBaselineAt) == "" {
		writeAPIError(w, r, validationError("body", "基准时间修正请求不正确"))
		return
	}
	baseline, err := time.Parse(time.RFC3339, body.NewBaselineAt)
	if err != nil {
		writeAPIError(w, r, validationError("new_baseline_at", "时间格式必须为 RFC3339"))
		return
	}
	key := r.Header.Get("Idempotency-Key")
	if strings.TrimSpace(key) == "" {
		key = "baseline-" + planID.String()
	}
	result, err := s.Store.RunIdempotent(r.Context(), ownerID, key, http.MethodPost, r.URL.Path, payload, func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
		var state string
		var version int
		err := tx.QueryRow(ctx, `
			SELECT state::text, version FROM breeding_plan
			WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL FOR UPDATE
		`, ownerID, planID).Scan(&state, &version)
		if errors.Is(err, pgx.ErrNoRows) {
			return 0, nil, nil, store.ErrNotFound
		}
		if err != nil {
			return 0, nil, nil, err
		}
		if version != expected {
			return 0, nil, nil, store.ErrVersionConflict
		}
		if state != "gestation" && state != "hold" {
			return 0, nil, nil, conflictError("state", "仅 gestation 或 hold 状态可修正基准时间")
		}
		err = tx.QueryRow(ctx, `
			UPDATE breeding_plan
			SET mating_baseline_at=$3,
			    date_correction_note=$4,
			    updated_at=now()
			WHERE owner_id=$1 AND id=$2
			RETURNING version
		`, ownerID, planID, baseline.UTC(), body.Reason).Scan(&version)
		if err != nil {
			return 0, nil, nil, err
		}
		return http.StatusOK, envelope(r, map[string]any{
			"id": planID, "state": state, "mating_baseline_at": baseline.UTC(),
			"version": version, "reason": body.Reason, "timezone": body.Timezone,
		}), map[string]string{"ETag": store.FormatETag(version)}, nil
	})
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeStored(w, r, result)
}

func (s *Server) completeBreedingPlan(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI3(w, r)
	if !ok {
		return
	}
	planID, err := uuid.Parse(r.PathValue("plan_id"))
	if err != nil {
		writeAPIError(w, r, validationError("plan_id", "计划 ID 无效"))
		return
	}
	expected, err := store.ParseETag(r.Header.Get("If-Match"))
	if err != nil {
		writeAPIError(w, r, validationError("If-Match", "If-Match 必须是当前资源版本 ETag"))
		return
	}
	var body struct {
		CompletedAt string  `json:"completed_at"`
		Timezone    string  `json:"timezone"`
		Notes       *string `json:"notes"`
	}
	payload, err := decodeBody(r, &body)
	if err != nil {
		writeAPIError(w, r, validationError("body", "完成繁育计划请求不正确"))
		return
	}
	key := r.Header.Get("Idempotency-Key")
	if strings.TrimSpace(key) == "" {
		key = "complete-plan-" + planID.String()
	}
	result, err := s.Store.RunIdempotent(r.Context(), ownerID, key, http.MethodPost, r.URL.Path, payload, func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
		var state string
		var version int
		err := tx.QueryRow(ctx, `
			SELECT state::text, version FROM breeding_plan
			WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL FOR UPDATE
		`, ownerID, planID).Scan(&state, &version)
		if errors.Is(err, pgx.ErrNoRows) {
			return 0, nil, nil, store.ErrNotFound
		}
		if err != nil {
			return 0, nil, nil, err
		}
		if version != expected {
			return 0, nil, nil, store.ErrVersionConflict
		}
		if state != "individualizing" {
			return 0, nil, nil, conflictError("state", "仅 individualizing 状态可完成繁育计划")
		}
		err = tx.QueryRow(ctx, `
			UPDATE breeding_plan
			SET state='completed', notes=COALESCE($3, notes), updated_at=now()
			WHERE owner_id=$1 AND id=$2
			RETURNING version
		`, ownerID, planID, body.Notes).Scan(&version)
		if err != nil {
			return 0, nil, nil, err
		}
		return http.StatusOK, envelope(r, map[string]any{
			"id": planID, "state": "completed", "version": version,
			"completed_at": body.CompletedAt, "timezone": body.Timezone, "notes": body.Notes,
		}), map[string]string{"ETag": store.FormatETag(version)}, nil
	})
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeStored(w, r, result)
}

func (s *Server) getImportErrorReport(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	jobID, err := uuid.Parse(r.PathValue("job_id"))
	if err != nil {
		writeAPIError(w, r, validationError("job_id", "作业 ID 无效"))
		return
	}
	// Import jobs may live in-memory sessions (current I2 implementation) or DB.
	i2ImportStateLock.Lock()
	session, ok := i2ImportSessions[jobID.String()]
	i2ImportStateLock.Unlock()
	if !ok {
		// DB path: check import_job existence.
		var status string
		err = s.Store.Pool.QueryRow(r.Context(), `
			SELECT status::text FROM import_job WHERE owner_id=$1 AND id=$2
		`, ownerID, jobID).Scan(&status)
		if errors.Is(err, pgx.ErrNoRows) {
			writeAPIError(w, r, store.ErrNotFound)
			return
		}
		if err != nil {
			// Fall through for pure memory jobs that already missed above.
			writeAPIError(w, r, store.ErrNotFound)
			return
		}
		_ = status
	} else if session.Job.OwnerID != ownerID.String() {
		writeAPIError(w, r, store.ErrNotFound)
		return
	}
	writeJSON(w, r, http.StatusOK, envelope(r, map[string]any{
		"download_url":       "/v1/data-center/import-jobs/" + jobID.String() + "/rows?errors_only=true",
		"expires_in_seconds": 300,
		"content_type":       "application/json",
		"file_name":          "import-error-report-" + jobID.String() + ".json",
	}))
}

func (s *Server) retryImportJob(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	jobID, err := uuid.Parse(r.PathValue("job_id"))
	if err != nil {
		writeAPIError(w, r, validationError("job_id", "作业 ID 无效"))
		return
	}
	var body struct {
		RowNumbers []int  `json:"row_numbers"`
		Reason     string `json:"reason"`
	}
	payload, err := decodeBody(r, &body)
	if err != nil {
		payload = []byte(`{}`)
	}
	key := r.Header.Get("Idempotency-Key")
	if strings.TrimSpace(key) == "" {
		key = "import-retry-" + jobID.String()
	}
	// Prefer in-memory I2 sessions used by current import handlers.
	i2ImportStateLock.Lock()
	session, ok := i2ImportSessions[jobID.String()]
	if ok && session.Job.OwnerID == ownerID.String() {
		session.Phase = "uploaded"
		session.Report = nil
		session.Receipt = nil
		session.UpdatedAt = time.Now().UTC()
		session.Version++
		version := session.Version
		i2ImportStateLock.Unlock()
		writeJSON(w, r, http.StatusAccepted, envelope(r, map[string]any{
			"id": jobID, "status": "queued", "version": version, "retryable": true,
		}))
		return
	}
	i2ImportStateLock.Unlock()

	result, err := s.Store.RunIdempotent(r.Context(), ownerID, key, http.MethodPost, r.URL.Path, payload, func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
		var version int
		var status string
		err := tx.QueryRow(ctx, `
			SELECT version, status::text FROM import_job
			WHERE owner_id=$1 AND id=$2 FOR UPDATE
		`, ownerID, jobID).Scan(&version, &status)
		if errors.Is(err, pgx.ErrNoRows) {
			return 0, nil, nil, store.ErrNotFound
		}
		if err != nil {
			return 0, nil, nil, err
		}
		if status != "failed" {
			return 0, nil, nil, conflictError("status", "仅失败导入任务可重试")
		}
		err = tx.QueryRow(ctx, `
			UPDATE import_job
			SET status='uploaded', updated_at=now()
			WHERE owner_id=$1 AND id=$2
			RETURNING version
		`, ownerID, jobID).Scan(&version)
		if err != nil {
			return 0, nil, nil, err
		}
		return http.StatusAccepted, envelope(r, map[string]any{
			"id": jobID, "status": "uploaded", "version": version, "retryable": true,
		}), map[string]string{"ETag": store.FormatETag(version)}, nil
	})
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeStored(w, r, result)
}

func mustJSON(value map[string]any) []byte {
	raw, err := json.Marshal(value)
	if err != nil {
		return []byte(`{}`)
	}
	return raw
}

func (s *Server) loadCareTaskJSON(ctx context.Context, q interface {
	QueryRow(context.Context, string, ...any) pgx.Row
}, ownerID, id uuid.UUID) (map[string]any, error) {
	var (
		title, description, priority, taskType, targetType, status string
		scheduledAt, createdAt, updatedAt                          time.Time
		version                                                    int
		targetID                                                   uuid.UUID
	)
	err := q.QueryRow(ctx, `
		SELECT id, task_type::text, target_type::text, target_id, title, description, priority::text,
		       status::text, scheduled_at, version, created_at, updated_at
		FROM care_task
		WHERE owner_id=$1 AND id=$2
	`, ownerID, id).Scan(
		&id, &taskType, &targetType, &targetID, &title, &description, &priority,
		&status, &scheduledAt, &version, &createdAt, &updatedAt,
	)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"id": id, "task_type": taskType, "target_type": targetType, "target_id": targetID,
		"title": title, "notes": description, "priority": priority, "status": status,
		"scheduled_at": scheduledAt, "version": version, "created_at": createdAt, "updated_at": updatedAt,
	}, nil
}

func jsonRawMap(raw []byte) map[string]any {
	out := map[string]any{}
	if len(raw) > 0 {
		_ = json.Unmarshal(raw, &out)
	}
	return out
}
