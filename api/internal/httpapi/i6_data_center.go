package httpapi

import (
	"errors"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/scolvpet/scolvpet/api/internal/i6data"
	"github.com/scolvpet/scolvpet/api/internal/store"
)

// registerI6DataRoutes is intentionally separate from Server.Handler so the
// I6 slice can be registered and tested independently while server.go remains
// owned by the integration agent.
func (s *Server) registerI6DataRoutes(mux *http.ServeMux) {
	mux.HandleFunc("GET /v1/data-center/summary", s.getI6DataCenterSummary)
	mux.HandleFunc("GET /v1/data-center/export-jobs", s.listI6ExportJobs)
	mux.HandleFunc("POST /v1/data-center/export-jobs", s.createI6ExportJob)
	mux.HandleFunc("GET /v1/data-center/export-jobs/{job_id}", s.getI6ExportJob)
	mux.HandleFunc("GET /v1/data-center/export-jobs/{job_id}/download", s.downloadI6ExportJob)
	mux.HandleFunc("POST /v1/data-center/export-jobs/{job_id}/retry", s.retryI6ExportJob)
	mux.HandleFunc("GET /v1/data-center/backup-jobs", s.listI6BackupJobs)
	mux.HandleFunc("POST /v1/data-center/backup-jobs", s.createI6BackupJob)
	mux.HandleFunc("GET /v1/data-center/backup-jobs/{job_id}", s.getI6BackupJob)
	mux.HandleFunc("GET /v1/data-center/backup-jobs/{job_id}/download", s.downloadI6BackupJob)
	mux.HandleFunc("POST /v1/data-center/backup-jobs/{job_id}/retry", s.retryI6BackupJob)
	mux.HandleFunc("GET /v1/usage/current", s.getI6CurrentUsage)
	mux.HandleFunc("GET /v1/usage/snapshots", s.listI6UsageSnapshots)
}

func (s *Server) i6DataService() *i6data.Service { return i6data.NewService(s.Store) }

func (s *Server) authenticateI6(w http.ResponseWriter, r *http.Request) (uuid.UUID, bool) {
	ownerID, _, ok := s.authenticate(r)
	if !ok {
		writeAPIError(w, r, authRequired())
		return uuid.Nil, false
	}
	return ownerID, true
}

func (s *Server) getI6DataCenterSummary(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI6(w, r)
	if !ok {
		return
	}
	summary, err := s.i6DataService().Summary(r.Context(), ownerID)
	if err != nil {
		writeI6Error(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, envelope(r, summary))
}

func (s *Server) listI6ExportJobs(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI6(w, r)
	if !ok {
		return
	}
	page, err := parseI2Page(r)
	if err != nil {
		writeI6Error(w, r, err)
		return
	}
	result, err := s.i6DataService().ListExportJobs(r.Context(), ownerID, i6data.Page{Limit: page.Limit, Offset: page.Offset})
	if err != nil {
		writeI6Error(w, r, err)
		return
	}
	writeI6List(w, r, exportJobJSONSlice(result.Items), page, result.HasMore)
}

func (s *Server) createI6ExportJob(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI6(w, r)
	if !ok {
		return
	}
	var input i6data.ExportJobInput
	payload, err := decodeBody(r, &input)
	if err != nil {
		writeI6Error(w, r, validationError("body", "导出任务请求体格式不正确"))
		return
	}
	result, err := s.i6DataService().CreateExportJob(r.Context(), ownerID, r.Header.Get("Idempotency-Key"), r.URL.Path, payload, input)
	if err != nil {
		writeI6Error(w, r, err)
		return
	}
	writeI6Stored(w, r, result.Status, envelope(r, exportJobJSON(result.Value)), result)
}

func (s *Server) getI6ExportJob(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI6(w, r)
	if !ok {
		return
	}
	jobID, err := i6JobID(r)
	if err != nil {
		writeI6Error(w, r, i6data.ErrNotFound)
		return
	}
	job, err := s.i6DataService().GetExportJob(r.Context(), ownerID, jobID)
	if err != nil {
		writeI6Error(w, r, err)
		return
	}
	w.Header().Set("ETag", store.FormatETag(job.Version))
	writeJSON(w, r, http.StatusOK, envelope(r, exportJobJSON(job)))
}

func (s *Server) downloadI6ExportJob(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI6(w, r)
	if !ok {
		return
	}
	jobID, err := i6JobID(r)
	if err != nil {
		writeI6Error(w, r, i6data.ErrNotFound)
		return
	}
	job, err := s.i6DataService().DownloadExportJob(r.Context(), ownerID, jobID)
	if err != nil {
		writeI6Error(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, envelope(r, downloadJSON(r, "export", job.ID, job.ExpiresAt, job.FileName, job.SizeBytes, job.SHA256)))
}

func (s *Server) retryI6ExportJob(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI6(w, r)
	if !ok {
		return
	}
	jobID, err := i6JobID(r)
	if err != nil {
		writeI6Error(w, r, i6data.ErrNotFound)
		return
	}
	var input i6data.RetryJobInput
	payload, err := decodeBody(r, &input)
	if err != nil {
		writeI6Error(w, r, validationError("body", "重试请求体格式不正确"))
		return
	}
	result, err := s.i6DataService().RetryExportJob(r.Context(), ownerID, jobID, r.Header.Get("Idempotency-Key"), r.URL.Path, r.Header.Get("If-Match"), payload, input)
	if err != nil {
		writeI6Error(w, r, err)
		return
	}
	writeI6Stored(w, r, result.Status, envelope(r, exportJobJSON(result.Value)), result)
}

func (s *Server) listI6BackupJobs(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI6(w, r)
	if !ok {
		return
	}
	page, err := parseI2Page(r)
	if err != nil {
		writeI6Error(w, r, err)
		return
	}
	result, err := s.i6DataService().ListBackupJobs(r.Context(), ownerID, i6data.Page{Limit: page.Limit, Offset: page.Offset})
	if err != nil {
		writeI6Error(w, r, err)
		return
	}
	writeI6List(w, r, backupJobJSONSlice(result.Items), page, result.HasMore)
}

func (s *Server) createI6BackupJob(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI6(w, r)
	if !ok {
		return
	}
	var input i6data.BackupJobInput
	payload, err := decodeBody(r, &input)
	if err != nil {
		writeI6Error(w, r, validationError("body", "备份任务请求体格式不正确"))
		return
	}
	result, err := s.i6DataService().CreateBackupJob(r.Context(), ownerID, r.Header.Get("Idempotency-Key"), r.URL.Path, payload, input)
	if err != nil {
		writeI6Error(w, r, err)
		return
	}
	writeI6Stored(w, r, result.Status, envelope(r, backupJobJSON(result.Value)), result)
}

func (s *Server) getI6BackupJob(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI6(w, r)
	if !ok {
		return
	}
	jobID, err := i6JobID(r)
	if err != nil {
		writeI6Error(w, r, i6data.ErrNotFound)
		return
	}
	job, err := s.i6DataService().GetBackupJob(r.Context(), ownerID, jobID)
	if err != nil {
		writeI6Error(w, r, err)
		return
	}
	w.Header().Set("ETag", store.FormatETag(job.Version))
	writeJSON(w, r, http.StatusOK, envelope(r, backupJobJSON(job)))
}

func (s *Server) downloadI6BackupJob(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI6(w, r)
	if !ok {
		return
	}
	jobID, err := i6JobID(r)
	if err != nil {
		writeI6Error(w, r, i6data.ErrNotFound)
		return
	}
	job, err := s.i6DataService().DownloadBackupJob(r.Context(), ownerID, jobID)
	if err != nil {
		writeI6Error(w, r, err)
		return
	}
	fileName := "backup-" + job.ID.String() + ".zip"
	writeJSON(w, r, http.StatusOK, envelope(r, downloadJSON(r, "backup", job.ID, job.ExpiresAt, &fileName, job.SizeBytes, job.SHA256)))
}

func (s *Server) retryI6BackupJob(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI6(w, r)
	if !ok {
		return
	}
	jobID, err := i6JobID(r)
	if err != nil {
		writeI6Error(w, r, i6data.ErrNotFound)
		return
	}
	var input i6data.RetryJobInput
	payload, err := decodeBody(r, &input)
	if err != nil {
		writeI6Error(w, r, validationError("body", "重试请求体格式不正确"))
		return
	}
	result, err := s.i6DataService().RetryBackupJob(r.Context(), ownerID, jobID, r.Header.Get("Idempotency-Key"), r.URL.Path, r.Header.Get("If-Match"), payload, input)
	if err != nil {
		writeI6Error(w, r, err)
		return
	}
	writeI6Stored(w, r, result.Status, envelope(r, backupJobJSON(result.Value)), result)
}

func (s *Server) getI6CurrentUsage(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI6(w, r)
	if !ok {
		return
	}
	usage, err := s.i6DataService().CurrentUsage(r.Context(), ownerID)
	if err != nil {
		writeI6Error(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, envelope(r, usage))
}

func (s *Server) listI6UsageSnapshots(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI6(w, r)
	if !ok {
		return
	}
	page, err := parseI2Page(r)
	if err != nil {
		writeI6Error(w, r, err)
		return
	}
	from, err := parseI6DateQuery(r.URL.Query().Get("from"), false)
	if err != nil {
		writeI6Error(w, r, validationError("from", "from 必须是日期"))
		return
	}
	to, err := parseI6DateQuery(r.URL.Query().Get("to"), true)
	if err != nil {
		writeI6Error(w, r, validationError("to", "to 必须是日期"))
		return
	}
	result, err := s.i6DataService().ListUsageSnapshots(r.Context(), ownerID, i6data.Page{Limit: page.Limit, Offset: page.Offset}, from, to)
	if err != nil {
		writeI6Error(w, r, err)
		return
	}
	items := make([]any, 0, len(result.Items))
	for _, item := range result.Items {
		items = append(items, item)
	}
	writeI6List(w, r, items, page, result.HasMore)
}

func i6JobID(r *http.Request) (uuid.UUID, error) { return uuid.Parse(r.PathValue("job_id")) }

func writeI6Stored(w http.ResponseWriter, r *http.Request, status int, payload any, result any) {
	w.Header().Set("Idempotency-Key", r.Header.Get("Idempotency-Key"))
	w.Header().Set("Idempotency-Replayed", "false")
	if stored, ok := result.(i6data.WriteResult[i6data.ExportJob]); ok {
		w.Header().Set("Idempotency-Replayed", strconv.FormatBool(stored.Replayed))
		for key, value := range stored.Headers {
			w.Header().Set(key, value)
		}
	} else if stored, ok := result.(i6data.WriteResult[i6data.BackupJob]); ok {
		w.Header().Set("Idempotency-Replayed", strconv.FormatBool(stored.Replayed))
		for key, value := range stored.Headers {
			w.Header().Set(key, value)
		}
	}
	writeJSON(w, r, status, payload)
}

func writeI6List(w http.ResponseWriter, r *http.Request, data any, page i2PageRequest, hasMore bool) {
	var next *string
	if hasMore {
		cursor := encodeI2Cursor(page.Offset + page.Limit)
		next = &cursor
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": data, "page": map[string]any{"next_cursor": next, "has_more": hasMore, "count": sliceLen(data)}, "meta": responseMeta(r)})
}

func sliceLen(value any) int {
	switch values := value.(type) {
	case []any:
		return len(values)
	case []i6data.ExportJob:
		return len(values)
	case []i6data.BackupJob:
		return len(values)
	default:
		return 0
	}
}

func writeI6Error(w http.ResponseWriter, r *http.Request, err error) {
	if err == nil {
		return
	}
	if errors.Is(err, i6data.ErrNotFound) || errors.Is(err, store.ErrNotFound) {
		writeAPIError(w, r, &apiError{Status: http.StatusNotFound, Code: "RESOURCE_NOT_FOUND", Message: "资源不存在"})
		return
	}
	if errors.Is(err, i6data.ErrDownloadUnavailable) {
		writeAPIError(w, r, &apiError{Status: http.StatusConflict, Code: "STATE_CONFLICT", Message: "任务尚未生成可下载文件"})
		return
	}
	if errors.Is(err, i6data.ErrValidation) {
		writeAPIError(w, r, &apiError{Status: http.StatusUnprocessableEntity, Code: "VALIDATION_ERROR", Message: "请求字段或领域规则校验失败"})
		return
	}
	if errors.Is(err, i6data.ErrVersionConflict) {
		var vc versionCarrier
		current := 0
		if errors.As(err, &vc) {
			current = vc.Version()
		}
		if current > 0 {
			w.Header().Set("ETag", store.FormatETag(current))
		}
		writeAPIError(w, r, &apiError{Status: http.StatusConflict, Code: "VERSION_CONFLICT", Message: "资源版本已变化，请刷新后重试", Details: map[string]any{"current_version": current}})
		return
	}
	if errors.Is(err, i6data.ErrConflict) {
		writeAPIError(w, r, &apiError{Status: http.StatusConflict, Code: "STATE_CONFLICT", Message: "当前状态不允许执行该动作"})
		return
	}
	writeAPIError(w, r, err)
}

func exportJobJSONSlice(items []i6data.ExportJob) []any {
	result := make([]any, 0, len(items))
	for _, item := range items {
		result = append(result, exportJobJSON(item))
	}
	return result
}

func backupJobJSONSlice(items []i6data.BackupJob) []any {
	result := make([]any, 0, len(items))
	for _, item := range items {
		result = append(result, backupJobJSON(item))
	}
	return result
}

func exportJobJSON(job i6data.ExportJob) map[string]any {
	return map[string]any{"id": job.ID, "job_type": job.JobType, "status": job.Status, "progress_percent": job.ProgressPercent, "current_step": job.CurrentStep, "error": job.Error, "retryable": job.Retryable, "attempt": job.Attempt, "result": job.Result, "expires_at": job.ExpiresAt, "version": job.Version, "created_at": job.CreatedAt, "updated_at": job.UpdatedAt, "datasets": job.Datasets, "export_format": job.ExportFormat, "snapshot_at": job.SnapshotAt, "file_name": job.FileName, "size_bytes": job.SizeBytes, "sha256": job.SHA256}
}

func backupJobJSON(job i6data.BackupJob) map[string]any {
	return map[string]any{"id": job.ID, "job_type": job.JobType, "status": job.Status, "progress_percent": job.ProgressPercent, "current_step": job.CurrentStep, "error": job.Error, "retryable": job.Retryable, "attempt": job.Attempt, "result": job.Result, "expires_at": job.ExpiresAt, "version": job.Version, "created_at": job.CreatedAt, "updated_at": job.UpdatedAt, "includes_structured_data": true, "includes_media_manifest": true, "includes_checksums": true, "size_bytes": job.SizeBytes, "sha256": job.SHA256, "integrity_status": job.IntegrityStatus, "restore_readiness": job.RestoreReadiness, "verified_at": job.VerifiedAt}
}

func downloadJSON(r *http.Request, kind string, id uuid.UUID, expires *time.Time, fileName *string, size *int64, sha *string) map[string]any {
	until := time.Now().UTC().Add(15 * time.Minute)
	if expires != nil {
		until = *expires
	}
	name := id.String() + ".bin"
	if fileName != nil && strings.TrimSpace(*fileName) != "" {
		name = *fileName
	}
	return map[string]any{"download_url": i6DownloadURL(r, kind, id, until), "expires_at": until, "file_name": name, "size_bytes": *size, "sha256": *sha}
}

func i6DownloadURL(r *http.Request, kind string, id uuid.UUID, expires time.Time) string {
	scheme := "http"
	if r.TLS != nil {
		scheme = "https"
	}
	host := r.Host
	if host == "" {
		host = "localhost"
	}
	u := url.URL{Scheme: scheme, Host: host, Path: "/v1/data-center/" + kind + "-jobs/" + id.String() + "/download"}
	q := u.Query()
	q.Set("expires", strconv.FormatInt(expires.Unix(), 10))
	u.RawQuery = q.Encode()
	return u.String()
}

func parseI6DateQuery(value string, end bool) (*time.Time, error) {
	if strings.TrimSpace(value) == "" {
		return nil, nil
	}
	date, err := time.Parse("2006-01-02", value)
	if err != nil {
		return nil, err
	}
	if end {
		date = date.AddDate(0, 0, 1)
	}
	date = date.UTC()
	return &date, nil
}
