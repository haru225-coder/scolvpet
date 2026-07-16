package httpapi

import (
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"io"
	"net/http"
	"strings"
	"sync"
	"time"

	"github.com/google/uuid"

	"github.com/scolvpet/scolvpet/api/internal/importcsv"
	"github.com/scolvpet/scolvpet/api/internal/store"
)

type i2ImportUpload struct {
	ID        uuid.UUID
	OwnerID   uuid.UUID
	FileName  string
	SizeBytes int
	SHA256    string
	Bytes     []byte
	Uploaded  bool
	ExpiresAt time.Time
	Version   int
	CreatedAt time.Time
}

type i2ImportSession struct {
	Job       importcsv.LocalJob
	CSV       []byte
	FileName  string
	Version   int
	Phase     string
	Report    *importcsv.PreflightReport
	Receipt   *importcsv.CommitReceipt
	Template  importcsv.TemplateType
	Mapping   map[string]string
	CreatedAt time.Time
	UpdatedAt time.Time
}

var (
	i2ImportUploads   = map[uuid.UUID]*i2ImportUpload{}
	i2ImportSessions  = map[string]*i2ImportSession{}
	i2ImportStateLock sync.Mutex
)

func (s *Server) registerI2ImportRoutes(mux *http.ServeMux) {
	mux.HandleFunc("GET /v1/data-center/import-templates/{template_type}", s.getI2ImportTemplate)
	mux.HandleFunc("POST /v1/data-center/import-uploads", s.createI2ImportUpload)
	mux.HandleFunc("PUT /v1/data-center/import-uploads/{upload_id}/content", s.putI2ImportUploadContent)
	mux.HandleFunc("GET /v1/data-center/import-jobs", s.listI2ImportJobs)
	mux.HandleFunc("POST /v1/data-center/import-jobs", s.createI2ImportJob)
	mux.HandleFunc("GET /v1/data-center/import-jobs/{job_id}", s.getI2ImportJob)
	mux.HandleFunc("PUT /v1/data-center/import-jobs/{job_id}/mapping", s.setI2ImportMapping)
	mux.HandleFunc("POST /v1/data-center/import-jobs/{job_id}/preflight", s.preflightI2ImportJob)
	mux.HandleFunc("POST /v1/data-center/import-jobs/{job_id}/commit", s.commitI2ImportJob)
	mux.HandleFunc("GET /v1/data-center/import-jobs/{job_id}/rows", s.listI2ImportRows)
}

func (s *Server) importCSVStore() *importcsv.PostgresStore {
	return importcsv.NewPostgresStoreFromStore(s.Store)
}

func (s *Server) getI2ImportTemplate(w http.ResponseWriter, r *http.Request) {
	if _, ok := s.authenticateI2(w, r); !ok {
		return
	}
	templateType := importcsv.TemplateType(strings.TrimSpace(r.PathValue("template_type")))
	template, ok := importcsv.TemplateFor(templateType)
	if !ok {
		writeI2CoreError(w, r, validationError("template_type", "不支持的导入模板类型"))
		return
	}
	fields := make([]any, 0, len(template.Fields))
	for _, field := range template.Fields {
		fields = append(fields, map[string]any{
			"key": field.Name, "label": field.Name, "required": field.Required,
			"data_type": "string", "example": nil,
		})
	}
	writeJSON(w, r, http.StatusOK, envelope(r, map[string]any{
		"template_type": template.Type,
		"version":       "v1",
		"file_name":     string(template.Type) + "-template.csv",
		"download_url":  "/v1/data-center/import-templates/" + string(template.Type),
		"fields":        fields,
	}))
}

func (s *Server) createI2ImportUpload(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	var request struct {
		FileName  string `json:"file_name"`
		SizeBytes int    `json:"size_bytes"`
		SHA256    string `json:"sha256"`
	}
	payload, err := decodeI2Body(r, &request)
	_ = payload
	if err != nil || !strings.HasSuffix(strings.ToLower(request.FileName), ".csv") || request.SizeBytes < 1 || len(request.SHA256) != 64 {
		writeI2CoreError(w, r, validationError("body", "导入上传请求体格式不正确"))
		return
	}
	uploadID := uuid.New()
	expiresAt := time.Now().UTC().Add(30 * time.Minute)
	session := &i2ImportUpload{
		ID: uploadID, OwnerID: ownerID, FileName: request.FileName, SizeBytes: request.SizeBytes,
		SHA256: strings.ToLower(request.SHA256), ExpiresAt: expiresAt, Version: 1, CreatedAt: time.Now().UTC(),
	}
	i2ImportStateLock.Lock()
	i2ImportUploads[uploadID] = session
	i2ImportStateLock.Unlock()

	scheme := "http"
	if r.TLS != nil {
		scheme = "https"
	}
	host := r.Host
	if host == "" {
		host = "127.0.0.1"
	}
	uploadURL := fmt.Sprintf("%s://%s/v1/data-center/import-uploads/%s/content", scheme, host, uploadID)
	writeI2Stored(w, r, http.StatusCreated, envelope(r, map[string]any{
		"id": uploadID, "upload_url": uploadURL, "method": "PUT",
		"headers":    map[string]string{"Content-Type": "text/csv"},
		"object_key": "local-import/" + uploadID.String(),
		"expires_at": expiresAt, "version": 1,
	}), false, "", "/v1/data-center/import-uploads/"+uploadID.String())
}

func (s *Server) putI2ImportUploadContent(w http.ResponseWriter, r *http.Request) {
	uploadID, err := uuid.Parse(strings.TrimSpace(r.PathValue("upload_id")))
	if err != nil {
		writeI2CoreError(w, r, validationError("upload_id", "上传 ID 格式不正确"))
		return
	}
	body, err := io.ReadAll(io.LimitReader(r.Body, 104857600))
	if err != nil {
		writeI2CoreError(w, r, validationError("body", "读取上传内容失败"))
		return
	}
	sum := sha256.Sum256(body)
	hash := hex.EncodeToString(sum[:])

	i2ImportStateLock.Lock()
	defer i2ImportStateLock.Unlock()
	upload, ok := i2ImportUploads[uploadID]
	if !ok || time.Now().After(upload.ExpiresAt) {
		writeI2CoreError(w, r, notFoundError("upload", "导入上传会话不存在或已过期"))
		return
	}
	if upload.SizeBytes > 0 && len(body) != upload.SizeBytes && upload.SizeBytes != len(body) {
		// size is advisory; only reject empty
	}
	if len(body) == 0 {
		writeI2CoreError(w, r, validationError("body", "CSV 内容不能为空"))
		return
	}
	if upload.SHA256 != "" && !strings.EqualFold(upload.SHA256, hash) {
		writeI2CoreError(w, r, validationError("sha256", "上传内容与声明的 SHA-256 不一致"))
		return
	}
	upload.Bytes = append([]byte(nil), body...)
	upload.Uploaded = true
	upload.SHA256 = hash
	upload.SizeBytes = len(body)
	w.WriteHeader(http.StatusNoContent)
}

func (s *Server) listI2ImportJobs(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	page, err := parseI2Page(r)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	i2ImportStateLock.Lock()
	defer i2ImportStateLock.Unlock()
	items := make([]any, 0)
	for _, session := range i2ImportSessions {
		if session.Job.OwnerID != ownerID.String() {
			continue
		}
		items = append(items, i2ImportJobJSON(session))
	}
	start := page.Offset
	if start > len(items) {
		start = len(items)
	}
	end := start + page.Limit
	if end > len(items) {
		end = len(items)
	}
	pageInfo := i2PageInfo{Count: end - start, HasMore: end < len(items)}
	if pageInfo.HasMore {
		cursor := encodeI2Cursor(end)
		pageInfo.NextCursor = &cursor
	}
	writeI2List(w, r, items[start:end], pageInfo)
}

func (s *Server) createI2ImportJob(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	var request struct {
		UploadID        uuid.UUID `json:"upload_id"`
		TemplateType    string    `json:"template_type"`
		TemplateVersion string    `json:"template_version"`
		SourceEncoding  *string   `json:"source_encoding"`
		Timezone        string    `json:"timezone"`
	}
	payload, err := decodeI2Body(r, &request)
	if err != nil || request.UploadID == uuid.Nil || strings.TrimSpace(request.TemplateType) == "" {
		writeI2CoreError(w, r, validationError("body", "创建导入任务请求体格式不正确"))
		return
	}
	_ = payload

	i2ImportStateLock.Lock()
	upload, ok := i2ImportUploads[request.UploadID]
	if !ok || upload.OwnerID != ownerID || !upload.Uploaded || len(upload.Bytes) == 0 {
		i2ImportStateLock.Unlock()
		writeI2CoreError(w, r, validationError("upload_id", "上传尚未完成或不存在"))
		return
	}
	csvBytes := append([]byte(nil), upload.Bytes...)
	fileName := upload.FileName
	i2ImportStateLock.Unlock()

	templateType := importcsv.TemplateType(request.TemplateType)
	if _, ok := importcsv.TemplateFor(templateType); !ok {
		writeI2CoreError(w, r, validationError("template_type", "不支持的导入模板类型"))
		return
	}
	batchKey := r.Header.Get("Idempotency-Key")
	if len(batchKey) < 8 {
		batchKey = "import-" + uuid.NewString()
	}
	job, err := s.importCSVStore().CreateLocalJob(r.Context(), importcsv.LocalJobRequest{
		OwnerID: ownerID.String(), OperatorID: ownerID.String(), OriginalFilename: fileName,
		BatchKey: batchKey, CSV: csvBytes, ParseOptions: importcsv.ParseOptions{Template: templateType},
	})
	if err != nil {
		writeI2ImportError(w, r, err)
		return
	}
	now := time.Now().UTC()
	session := &i2ImportSession{
		Job: job, CSV: csvBytes, FileName: fileName, Version: 1, Phase: "mapping",
		Template: job.File.Template, Mapping: cloneStringMap(job.File.Mapping),
		CreatedAt: now, UpdatedAt: now,
	}
	i2ImportStateLock.Lock()
	i2ImportSessions[job.ID] = session
	i2ImportStateLock.Unlock()

	writeI2Stored(w, r, http.StatusAccepted, envelope(r, i2ImportJobJSON(session)), job.Replayed,
		store.FormatETag(session.Version), "/v1/data-center/import-jobs/"+job.ID)
}

func (s *Server) getI2ImportJob(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	session, ok := s.loadI2ImportSession(ownerID, r.PathValue("job_id"))
	if !ok {
		writeI2CoreError(w, r, notFoundError("import_job", "导入任务不存在"))
		return
	}
	w.Header().Set("ETag", store.FormatETag(session.Version))
	writeJSON(w, r, http.StatusOK, envelope(r, i2ImportJobJSON(session)))
}

func (s *Server) setI2ImportMapping(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	expectedVersion, err := parseI2IfMatch(r)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	var request struct {
		Timezone string `json:"timezone"`
		Mappings []struct {
			SourceColumn     string `json:"source_column"`
			TargetField      string `json:"target_field"`
			EmptyValuePolicy string `json:"empty_value_policy"`
		} `json:"mappings"`
	}
	payload, err := decodeI2Body(r, &request)
	_ = payload
	if err != nil || len(request.Mappings) == 0 {
		writeI2CoreError(w, r, validationError("body", "映射请求体格式不正确"))
		return
	}
	session, ok := s.loadI2ImportSession(ownerID, r.PathValue("job_id"))
	if !ok {
		writeI2CoreError(w, r, notFoundError("import_job", "导入任务不存在"))
		return
	}
	if expectedVersion > 0 && session.Version != expectedVersion {
		writeI2CoreError(w, r, versionConflictError(session.Version))
		return
	}
	mapping := make(map[string]string, len(request.Mappings))
	for _, item := range request.Mappings {
		if strings.TrimSpace(item.SourceColumn) == "" || strings.TrimSpace(item.TargetField) == "" {
			writeI2CoreError(w, r, validationError("mappings", "映射字段不能为空"))
			return
		}
		mapping[item.SourceColumn] = item.TargetField
	}
	file, err := importcsv.Parse(session.CSV, importcsv.ParseOptions{Template: session.Template, Mapping: mapping})
	if err != nil {
		writeI2ImportError(w, r, err)
		return
	}
	i2ImportStateLock.Lock()
	session.Job.File = file
	session.Mapping = cloneStringMap(file.Mapping)
	session.Version++
	session.Phase = "preflight"
	session.UpdatedAt = time.Now().UTC()
	i2ImportStateLock.Unlock()

	writeI2Stored(w, r, http.StatusOK, envelope(r, i2ImportJobJSON(session)), false,
		store.FormatETag(session.Version), "")
}

func (s *Server) preflightI2ImportJob(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	expectedVersion, err := parseI2IfMatch(r)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	var request struct {
		StrictReferences        bool   `json:"strict_references"`
		DuplicatePolicy         string `json:"duplicate_policy"`
		HistoricalLitterPolicy  string `json:"historical_litter_policy"`
		ParentageConflictPolicy string `json:"parentage_conflict_policy"`
		ExistingFieldPolicy     string `json:"existing_field_policy"`
	}
	payload, err := decodeI2Body(r, &request)
	_ = payload
	if err != nil {
		writeI2CoreError(w, r, validationError("body", "预检请求体格式不正确"))
		return
	}
	session, ok := s.loadI2ImportSession(ownerID, r.PathValue("job_id"))
	if !ok {
		writeI2CoreError(w, r, notFoundError("import_job", "导入任务不存在"))
		return
	}
	if expectedVersion > 0 && session.Version != expectedVersion {
		writeI2CoreError(w, r, versionConflictError(session.Version))
		return
	}
	options := importcsv.PreflightOptions{
		HistoricalLitterPolicy: importcsv.HistoricalLitterPolicy(request.HistoricalLitterPolicy),
		ExistingFieldPolicy:    importcsv.ExistingFieldPolicy(request.ExistingFieldPolicy),
	}
	if options.HistoricalLitterPolicy == "" {
		options.HistoricalLitterPolicy = importcsv.HistoricalLitterCreateIfComplete
	}
	if options.ExistingFieldPolicy == "" {
		options.ExistingFieldPolicy = importcsv.ExistingFieldPreserveNonNull
	}
	_ = request.StrictReferences
	_ = request.ParentageConflictPolicy
	_ = request.DuplicatePolicy
	report, err := s.importCSVStore().PreflightLocal(r.Context(), session.Job, options)
	if err != nil {
		writeI2ImportError(w, r, err)
		return
	}
	i2ImportStateLock.Lock()
	session.Report = report
	session.Version++
	if report.ReadyToCommit {
		session.Phase = "ready_to_commit"
	} else {
		session.Phase = "preflight"
	}
	session.UpdatedAt = time.Now().UTC()
	i2ImportStateLock.Unlock()

	writeI2Stored(w, r, http.StatusAccepted, envelope(r, i2ImportJobJSON(session)), false,
		store.FormatETag(session.Version), "")
}

func (s *Server) commitI2ImportJob(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	expectedVersion, err := parseI2IfMatch(r)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	var request struct {
		PreflightVersion     int    `json:"preflight_version"`
		BatchKey             string `json:"batch_key"`
		PartialFailurePolicy string `json:"partial_failure_policy"`
		ApprovedUpdates      []struct {
			RowNumber       int      `json:"row_number"`
			ResourceID      string   `json:"resource_id"`
			ExpectedVersion int      `json:"expected_version"`
			Fields          []string `json:"fields"`
		} `json:"approved_updates"`
	}
	payload, err := decodeI2Body(r, &request)
	_ = payload
	if err != nil || request.PreflightVersion < 1 || len(request.BatchKey) < 8 {
		writeI2CoreError(w, r, validationError("body", "提交请求体格式不正确"))
		return
	}
	session, ok := s.loadI2ImportSession(ownerID, r.PathValue("job_id"))
	if !ok {
		writeI2CoreError(w, r, notFoundError("import_job", "导入任务不存在"))
		return
	}
	if expectedVersion > 0 && session.Version != expectedVersion {
		writeI2CoreError(w, r, versionConflictError(session.Version))
		return
	}
	if session.Report == nil {
		loaded, loadErr := s.importCSVStore().LoadPreflight(r.Context(), ownerID.String(), session.Job.ID)
		if loadErr != nil {
			writeI2ImportError(w, r, loadErr)
			return
		}
		session.Report = loaded
	}
	if session.Report.PreflightVersion != request.PreflightVersion {
		writeI2CoreError(w, r, validationError("preflight_version", "预检版本已过期，请重新预检"))
		return
	}
	approvals := make([]importcsv.ApprovedUpdate, 0, len(request.ApprovedUpdates))
	for _, item := range request.ApprovedUpdates {
		approvals = append(approvals, importcsv.ApprovedUpdate{
			RowNumber: item.RowNumber, ResourceID: item.ResourceID,
			ExpectedVersion: item.ExpectedVersion, Fields: append([]string(nil), item.Fields...),
		})
	}
	job := session.Job
	// The import job's creation idempotency key is the persisted lookup key used
	// by the PostgreSQL commit transaction. Keep it stable across the later
	// commit request; request.BatchKey remains a required client-side batch token.
	job.BatchKey = i2CommitBatchKey(session, request.BatchKey)
	receipt, err := s.importCSVStore().CommitLocal(r.Context(), job, session.Report, approvals)
	if err != nil {
		writeI2ImportError(w, r, err)
		return
	}
	i2ImportStateLock.Lock()
	session.Receipt = &receipt
	session.Version++
	session.Phase = "completed"
	session.UpdatedAt = time.Now().UTC()
	i2ImportStateLock.Unlock()

	writeI2Stored(w, r, http.StatusAccepted, envelope(r, i2ImportJobJSON(session)), receipt.Replayed,
		store.FormatETag(session.Version), "")
}

func i2CommitBatchKey(session *i2ImportSession, requested string) string {
	if session != nil && strings.TrimSpace(session.Job.BatchKey) != "" {
		return session.Job.BatchKey
	}
	return requested
}

func (s *Server) listI2ImportRows(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	session, ok := s.loadI2ImportSession(ownerID, r.PathValue("job_id"))
	if !ok {
		writeI2CoreError(w, r, notFoundError("import_job", "导入任务不存在"))
		return
	}
	rows := []importcsv.RowResult{}
	if session.Receipt != nil {
		rows = session.Receipt.Rows
	} else if session.Report != nil {
		rows = session.Report.Rows
	}
	page, err := parseI2Page(r)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	start := page.Offset
	if start > len(rows) {
		start = len(rows)
	}
	end := start + page.Limit
	if end > len(rows) {
		end = len(rows)
	}
	items := make([]any, 0, end-start)
	for _, row := range rows[start:end] {
		items = append(items, i2ImportRowJSON(row))
	}
	pageInfo := i2PageInfo{Count: len(items), HasMore: end < len(rows)}
	if pageInfo.HasMore {
		cursor := encodeI2Cursor(end)
		pageInfo.NextCursor = &cursor
	}
	writeI2List(w, r, items, pageInfo)
}

func (s *Server) loadI2ImportSession(ownerID uuid.UUID, jobID string) (*i2ImportSession, bool) {
	i2ImportStateLock.Lock()
	defer i2ImportStateLock.Unlock()
	session, ok := i2ImportSessions[strings.TrimSpace(jobID)]
	if !ok || session.Job.OwnerID != ownerID.String() {
		return nil, false
	}
	return session, true
}

func i2ImportJobJSON(session *i2ImportSession) map[string]any {
	status := "queued"
	progress := 5
	phase := session.Phase
	totalRows, validRows, warningRows, invalidRows, importedRows, blocking := 0, 0, 0, 0, 0, 0
	var preflightVersion any
	sourceColumns := []string{}
	mapping := map[string]string{}
	if session.Job.File != nil {
		sourceColumns = append([]string(nil), session.Job.File.Headers...)
		mapping = cloneStringMap(session.Job.File.Mapping)
		totalRows = len(session.Job.File.Rows)
	}
	if len(session.Mapping) > 0 {
		mapping = cloneStringMap(session.Mapping)
	}
	if session.Report != nil {
		preflightVersion = session.Report.PreflightVersion
		totalRows = session.Report.TotalRows
		validRows = session.Report.ValidRows
		warningRows = session.Report.WarningRows
		invalidRows = session.Report.InvalidRows
		blocking = session.Report.BlockingIssueCount
		if session.Report.ReadyToCommit {
			status = "succeeded"
			progress = 80
			phase = "ready_to_commit"
		} else {
			status = "failed"
			progress = 50
			phase = "preflight"
		}
	}
	if session.Receipt != nil {
		status = string(session.Receipt.Status)
		if status == "" {
			status = "succeeded"
		}
		progress = 100
		phase = "completed"
		importedRows = 0
		for _, row := range session.Receipt.Rows {
			if row.Status == importcsv.RowImported {
				importedRows++
			}
		}
	}
	now := session.UpdatedAt
	if now.IsZero() {
		now = time.Now().UTC()
	}
	created := session.CreatedAt
	if created.IsZero() {
		created = now
	}
	return map[string]any{
		"id": session.Job.ID, "job_type": "import", "status": status, "progress_percent": progress,
		"current_step": phase, "error": nil, "retryable": status == "failed", "attempt": 1,
		"result": map[string]any{}, "expires_at": nil, "version": session.Version,
		"created_at": created, "updated_at": now, "template_type": session.Template, "phase": phase,
		"source_encoding": "utf-8", "source_columns": sourceColumns, "mapping": mapping,
		"preflight_version": preflightVersion, "total_rows": totalRows, "valid_rows": validRows,
		"warning_rows": warningRows, "invalid_rows": invalidRows, "imported_rows": importedRows,
		"historical_litters_to_create": 0, "relationship_assertions_to_create": 0,
		"blocking_issue_count": blocking,
	}
}

func i2ImportRowJSON(row importcsv.RowResult) map[string]any {
	issues := make([]any, 0, len(row.Issues))
	for _, issue := range row.Issues {
		issues = append(issues, map[string]any{
			"row_number": issue.RowNumber, "code": issue.Code, "message": issue.Message,
			"severity": issue.Severity, "column_name": issue.ColumnName, "suggestion": issue.Suggestion,
		})
	}
	mapped := map[string]any{}
	for key, value := range row.MappedValues {
		mapped[key] = value
	}
	return map[string]any{
		"row_number": row.RowNumber, "status": row.Status, "mapped_values": mapped,
		"resource_id": row.ResourceID, "issues": issues,
	}
}

func writeI2ImportError(w http.ResponseWriter, r *http.Request, err error) {
	switch {
	case errors.Is(err, importcsv.ErrImportJobNotFound):
		writeI2CoreError(w, r, notFoundError("import_job", "导入任务不存在"))
	case errors.Is(err, importcsv.ErrImportJobNotReady):
		writeI2CoreError(w, r, validationError("import_job", "导入任务当前状态不可提交"))
	case errors.Is(err, importcsv.ErrBlockingIssues):
		writeI2CoreError(w, r, validationError("preflight", "导入预检仍有阻塞问题"))
	case errors.Is(err, importcsv.ErrBatchKeyConflict):
		writeI2CoreError(w, r, &apiError{Status: http.StatusConflict, Code: "IDEMPOTENCY_PAYLOAD_MISMATCH", Message: "幂等批次号已用于不同导入内容"})
	case errors.Is(err, importcsv.ErrInvalidApproval):
		writeI2CoreError(w, r, validationError("approved_updates", "更新确认与预检候选不匹配"))
	case errors.Is(err, importcsv.ErrStalePreflight):
		writeI2CoreError(w, r, validationError("preflight_version", "预检计划已失效，请重新预检"))
	default:
		writeI2CoreError(w, r, err)
	}
}

func notFoundError(field, message string) error {
	return &apiError{Status: http.StatusNotFound, Code: "RESOURCE_NOT_FOUND", Message: message, Details: map[string]any{"field": field}}
}

func versionConflictError(current int) error {
	return &apiError{
		Status: http.StatusConflict, Code: "VERSION_CONFLICT", Message: "资源已被其他操作更新",
		Details: map[string]any{"current_version": current},
	}
}

func cloneStringMap(values map[string]string) map[string]string {
	if values == nil {
		return map[string]string{}
	}
	result := make(map[string]string, len(values))
	for key, value := range values {
		result[key] = value
	}
	return result
}
