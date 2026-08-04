package httpapi

import (
	"errors"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/scolvpet/scolvpet/api/internal/i5core"
	"github.com/scolvpet/scolvpet/api/internal/store"
)

func (s *Server) registerI5Routes(mux *http.ServeMux) {
	mux.HandleFunc("GET /v1/health-records", s.listI5HealthRecords)
	mux.HandleFunc("POST /v1/health-records", s.createI5HealthRecord)
	mux.HandleFunc("GET /v1/health-records/{health_record_id}", s.getI5HealthRecord)

	mux.HandleFunc("GET /v1/tasks", s.listI5Tasks)
	mux.HandleFunc("POST /v1/tasks", s.createI5Task)
	mux.HandleFunc("GET /v1/tasks/{task_id}", s.getI5Task)
	mux.HandleFunc("POST /v1/tasks/{task_id}/complete", s.completeI5Task)
	mux.HandleFunc("POST /v1/tasks/{task_id}/cancel", s.cancelI5Task)
	mux.HandleFunc("POST /v1/tasks/{task_id}/reopen", s.reopenI5Task)

	mux.HandleFunc("GET /v1/reminders", s.listI5Reminders)
	mux.HandleFunc("GET /v1/reminders/{reminder_id}", s.getI5Reminder)
}

func (s *Server) i5CoreService() *i5core.Service {
	return i5core.NewService(i5core.NewPostgresRepositoryFromStore(s.Store))
}

func (s *Server) authenticateI5(w http.ResponseWriter, r *http.Request) (uuid.UUID, bool) {
	ownerID, _, ok := s.authenticate(r)
	if !ok {
		writeAPIError(w, r, authRequired())
		return uuid.Nil, false
	}
	return ownerID, true
}

type i5HealthRecordCreateRequest struct {
	HamsterID        *uuid.UUID     `json:"hamster_id"`
	LitterID         *uuid.UUID     `json:"litter_id"`
	Type             string         `json:"type"`
	ObservedAt       string         `json:"observed_at"`
	StructuredChecks map[string]any `json:"structured_checks"`
	Severity         *string        `json:"severity"`
	Medication       map[string]any `json:"medication"`
	FollowUpAt       *string        `json:"follow_up_at"`
	Notes            *string        `json:"notes"`
}

type i5TaskCreateRequest struct {
	TaskType    string      `json:"task_type"`
	TargetType  string      `json:"target_type"`
	TargetID    uuid.UUID   `json:"target_id"`
	Title       *string     `json:"title"`
	ScheduledAt string      `json:"scheduled_at"`
	Priority    string      `json:"priority"`
	SubjectIDs  []uuid.UUID `json:"subject_ids"`
	Notes       *string     `json:"notes"`
}

type i5TaskSubjectResultRequest struct {
	SubjectID          uuid.UUID  `json:"subject_id"`
	Status             string     `json:"status"`
	CompletionRecordID *uuid.UUID `json:"completion_record_id"`
	ExceptionReason    *string    `json:"exception_reason"`
}

type i5TaskCompleteRequest struct {
	CompletedAt    string                       `json:"completed_at"`
	SubjectResults []i5TaskSubjectResultRequest `json:"subject_results"`
	Notes          *string                      `json:"notes"`
}

func (s *Server) listI5HealthRecords(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI5(w, r)
	if !ok {
		return
	}
	page, err := parseI2Page(r)
	if err != nil {
		writeI5Error(w, r, err)
		return
	}
	hamsterID, err := parseI2OptionalQueryUUID(r, "hamster_id")
	if err != nil {
		writeI5Error(w, r, err)
		return
	}
	litterID, err := parseI2OptionalQueryUUID(r, "litter_id")
	if err != nil {
		writeI5Error(w, r, err)
		return
	}
	typeValue := strings.TrimSpace(r.URL.Query().Get("type"))
	if typeValue != "" && !i5HealthType(typeValue) {
		writeI5Error(w, r, validationError("type", "健康记录类型不正确"))
		return
	}
	items, err := s.i5CoreService().ListHealthRecords(r.Context(), ownerID, i5core.HealthRecordFilter{
		HamsterID: hamsterID, LitterID: litterID, Type: typeValue,
		Page: i5core.Page{Limit: page.Limit, Offset: page.Offset},
	})
	if err != nil {
		writeI5Error(w, r, err)
		return
	}
	writeI5List(w, r, healthRecordJSONSlice(items), page, len(items) == page.Limit && page.Limit < 200)
}

func (s *Server) createI5HealthRecord(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI5(w, r)
	if !ok {
		return
	}
	var request i5HealthRecordCreateRequest
	payload, err := decodeI2Body(r, &request)
	if err != nil {
		writeI5Error(w, r, validationError("body", "健康记录请求体格式不正确"))
		return
	}
	input, err := request.healthInput()
	if err != nil {
		writeI5Error(w, r, err)
		return
	}
	result, err := s.i5CoreService().CreateHealthRecord(r.Context(), ownerID, i5WriteOptions(r, payload), input)
	if err != nil {
		writeI5Error(w, r, err)
		return
	}
	writeI5Stored(w, r, http.StatusCreated, envelope(r, healthRecordJSONValue(result.Value)), result.Replayed,
		store.FormatETag(result.Value.Version), "/v1/health-records/"+result.Value.ID.String())
}

func (s *Server) getI5HealthRecord(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI5(w, r)
	if !ok {
		return
	}
	recordID, err := uuid.Parse(r.PathValue("health_record_id"))
	if err != nil || recordID == uuid.Nil {
		writeI5Error(w, r, i5core.ErrNotFound)
		return
	}
	record, err := s.i5CoreService().GetHealthRecord(r.Context(), ownerID, recordID)
	if err != nil {
		writeI5Error(w, r, err)
		return
	}
	w.Header().Set("ETag", store.FormatETag(record.Version))
	writeJSON(w, r, http.StatusOK, envelope(r, healthRecordJSONValue(record)))
}

func (s *Server) listI5Tasks(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI5(w, r)
	if !ok {
		return
	}
	page, err := parseI2Page(r)
	if err != nil {
		writeI5Error(w, r, err)
		return
	}
	state := strings.TrimSpace(r.URL.Query().Get("state"))
	priority := strings.TrimSpace(r.URL.Query().Get("priority"))
	targetType := strings.TrimSpace(r.URL.Query().Get("target_type"))
	if state != "" && !i5TaskState(state) || priority != "" && !i5TaskPriority(priority) || targetType != "" && !i5TaskTargetType(targetType) {
		writeI5Error(w, r, validationError("filters", "任务筛选条件不正确"))
		return
	}
	var dueBefore *time.Time
	if value := strings.TrimSpace(r.URL.Query().Get("due_before")); value != "" {
		parsed, parseErr := parseI5DateTime(value)
		if parseErr != nil {
			writeI5Error(w, r, validationError("due_before", "截止时间格式不正确"))
			return
		}
		dueBefore = &parsed
	}
	items, err := s.i5CoreService().ListTasks(r.Context(), ownerID, i5core.CareTaskFilter{
		State: state, Priority: priority, TargetType: targetType, DueBefore: dueBefore,
		Page: i5core.Page{Limit: page.Limit, Offset: page.Offset},
	})
	if err != nil {
		writeI5Error(w, r, err)
		return
	}
	writeI5List(w, r, careTaskJSONSlice(items), page, len(items) == page.Limit && page.Limit < 200)
}

func (s *Server) createI5Task(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI5(w, r)
	if !ok {
		return
	}
	var request i5TaskCreateRequest
	payload, err := decodeI2Body(r, &request)
	if err != nil {
		writeI5Error(w, r, validationError("body", "任务请求体格式不正确"))
		return
	}
	input, err := request.taskInput()
	if err != nil {
		writeI5Error(w, r, err)
		return
	}
	result, err := s.i5CoreService().CreateTask(r.Context(), ownerID, i5WriteOptions(r, payload), input)
	if err != nil {
		writeI5Error(w, r, err)
		return
	}
	writeI5Stored(w, r, http.StatusCreated, envelope(r, careTaskJSONValue(result.Value)), result.Replayed,
		store.FormatETag(result.Value.Version), "/v1/tasks/"+result.Value.ID.String())
}

func (s *Server) getI5Task(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI5(w, r)
	if !ok {
		return
	}
	taskID, err := uuid.Parse(r.PathValue("task_id"))
	if err != nil || taskID == uuid.Nil {
		writeI5Error(w, r, i5core.ErrNotFound)
		return
	}
	task, err := s.i5CoreService().GetTask(r.Context(), ownerID, taskID)
	if err != nil {
		writeI5Error(w, r, err)
		return
	}
	w.Header().Set("ETag", store.FormatETag(task.Version))
	writeJSON(w, r, http.StatusOK, envelope(r, careTaskJSONValue(task)))
}

func (s *Server) completeI5Task(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI5(w, r)
	if !ok {
		return
	}
	taskID, err := uuid.Parse(r.PathValue("task_id"))
	if err != nil || taskID == uuid.Nil {
		writeI5Error(w, r, i5core.ErrNotFound)
		return
	}
	expectedVersion, err := parseI2IfMatch(r)
	if err != nil {
		writeI5Error(w, r, err)
		return
	}
	var request i5TaskCompleteRequest
	payload, err := decodeI2Body(r, &request)
	if err != nil {
		writeI5Error(w, r, validationError("body", "任务完成请求体格式不正确"))
		return
	}
	input, err := request.completeInput(expectedVersion)
	if err != nil {
		writeI5Error(w, r, err)
		return
	}
	result, err := s.i5CoreService().CompleteTask(r.Context(), ownerID, taskID, i5WriteOptions(r, payload), input)
	if err != nil {
		writeI5Error(w, r, err)
		return
	}
	writeI5Stored(w, r, http.StatusOK, envelope(r, completeTaskJSON(result.Value)), result.Replayed,
		store.FormatETag(result.Value.Task.Version), "")
}

// i5TaskCorrectionRequest carries the mandatory reason for cancelling a task or
// undoing its completion.
type i5TaskCorrectionRequest struct {
	Reason string `json:"reason"`
}

func (s *Server) cancelI5Task(w http.ResponseWriter, r *http.Request) {
	s.correctI5Task(w, r, func(ownerID, taskID uuid.UUID, options i5core.WriteOptions, version int, reason string) (i5core.WriteResult[i5core.CareTask], error) {
		return s.i5CoreService().CancelTask(r.Context(), ownerID, taskID, options, i5core.CancelTaskInput{
			ExpectedVersion: version, Reason: reason,
		})
	})
}

func (s *Server) reopenI5Task(w http.ResponseWriter, r *http.Request) {
	s.correctI5Task(w, r, func(ownerID, taskID uuid.UUID, options i5core.WriteOptions, version int, reason string) (i5core.WriteResult[i5core.CareTask], error) {
		return s.i5CoreService().ReopenTask(r.Context(), ownerID, taskID, options, i5core.ReopenTaskInput{
			ExpectedVersion: version, Reason: reason,
		})
	})
}

func (s *Server) correctI5Task(w http.ResponseWriter, r *http.Request,
	apply func(ownerID, taskID uuid.UUID, options i5core.WriteOptions, version int, reason string) (i5core.WriteResult[i5core.CareTask], error),
) {
	ownerID, ok := s.authenticateI5(w, r)
	if !ok {
		return
	}
	taskID, err := uuid.Parse(r.PathValue("task_id"))
	if err != nil || taskID == uuid.Nil {
		writeI5Error(w, r, i5core.ErrNotFound)
		return
	}
	expectedVersion, err := parseI2IfMatch(r)
	if err != nil {
		writeI5Error(w, r, err)
		return
	}
	var request i5TaskCorrectionRequest
	payload, err := decodeI2Body(r, &request)
	if err != nil {
		writeI5Error(w, r, validationError("body", "任务纠错请求体格式不正确"))
		return
	}
	reason := strings.TrimSpace(request.Reason)
	if reason == "" || len(reason) > 500 {
		writeI5Error(w, r, validationError("reason", "必须填写 1-500 字的原因"))
		return
	}
	result, err := apply(ownerID, taskID, i5WriteOptions(r, payload), expectedVersion, reason)
	if err != nil {
		writeI5Error(w, r, err)
		return
	}
	writeI5Stored(w, r, http.StatusOK, envelope(r, careTaskJSONValue(result.Value)), result.Replayed,
		store.FormatETag(result.Value.Version), "")
}

func (s *Server) listI5Reminders(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI5(w, r)
	if !ok {
		return
	}
	page, err := parseI2Page(r)
	if err != nil {
		writeI5Error(w, r, err)
		return
	}
	state := strings.TrimSpace(r.URL.Query().Get("state"))
	if state != "" && !i5ReminderState(state) {
		writeI5Error(w, r, validationError("state", "提醒状态不正确"))
		return
	}
	items, err := s.i5CoreService().ListReminders(r.Context(), ownerID, i5core.ReminderFilter{
		State: state, RuleCode: strings.TrimSpace(r.URL.Query().Get("rule_code")),
		Page: i5core.Page{Limit: page.Limit, Offset: page.Offset},
	})
	if err != nil {
		writeI5Error(w, r, err)
		return
	}
	writeI5List(w, r, reminderJSON(items), page, len(items) == page.Limit && page.Limit < 200)
}

func (s *Server) getI5Reminder(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI5(w, r)
	if !ok {
		return
	}
	reminderID, err := uuid.Parse(r.PathValue("reminder_id"))
	if err != nil || reminderID == uuid.Nil {
		writeI5Error(w, r, i5core.ErrNotFound)
		return
	}
	reminder, err := s.i5CoreService().GetReminder(r.Context(), ownerID, reminderID)
	if err != nil {
		writeI5Error(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, envelope(r, reminderJSONValue(reminder)))
}

func (request i5HealthRecordCreateRequest) healthInput() (i5core.CreateHealthRecordInput, error) {
	observedAt, err := parseI5DateTime(request.ObservedAt)
	if err != nil {
		return i5core.CreateHealthRecordInput{}, validationError("observed_at", "发生时间格式不正确")
	}
	var followUpAt *time.Time
	if request.FollowUpAt != nil {
		parsed, parseErr := parseI5DateTime(*request.FollowUpAt)
		if parseErr != nil {
			return i5core.CreateHealthRecordInput{}, validationError("follow_up_at", "复查时间格式不正确")
		}
		followUpAt = &parsed
	}
	return i5core.CreateHealthRecordInput{
		HamsterID: request.HamsterID, LitterID: request.LitterID, Type: strings.TrimSpace(request.Type),
		ObservedAt: observedAt, StructuredChecks: request.StructuredChecks, Severity: request.Severity,
		Medication: request.Medication, FollowUpAt: followUpAt, Notes: request.Notes,
	}, nil
}

func (request i5TaskCreateRequest) taskInput() (i5core.CreateCareTaskInput, error) {
	scheduledAt, err := parseI5DateTime(request.ScheduledAt)
	if err != nil {
		return i5core.CreateCareTaskInput{}, validationError("scheduled_at", "任务时间格式不正确")
	}
	taskType := normalizeI5TaskType(strings.TrimSpace(request.TaskType))
	return i5core.CreateCareTaskInput{
		TaskType: taskType, TargetType: strings.TrimSpace(request.TargetType), TargetID: request.TargetID,
		Title: request.Title, ScheduledAt: scheduledAt, Priority: strings.TrimSpace(request.Priority),
		SubjectIDs: request.SubjectIDs, Notes: request.Notes,
	}, nil
}

func (request i5TaskCompleteRequest) completeInput(expectedVersion int) (i5core.CompleteTaskInput, error) {
	completedAt, err := parseI5DateTime(request.CompletedAt)
	if err != nil {
		return i5core.CompleteTaskInput{}, validationError("completed_at", "完成时间格式不正确")
	}
	results := make([]i5core.TaskSubjectResult, 0, len(request.SubjectResults))
	for _, result := range request.SubjectResults {
		results = append(results, i5core.TaskSubjectResult{
			SubjectID: result.SubjectID, Status: result.Status, CompletionRecordID: result.CompletionRecordID,
			ExceptionReason: result.ExceptionReason,
		})
	}
	return i5core.CompleteTaskInput{ExpectedVersion: expectedVersion, CompletedAt: completedAt, SubjectResults: results, Notes: request.Notes}, nil
}

func i5WriteOptions(r *http.Request, payload []byte) i5core.WriteOptions {
	return i5core.WriteOptions{IdempotencyKey: r.Header.Get("Idempotency-Key"), RequestMethod: r.Method, RequestPath: r.URL.Path, RequestPayload: payload}
}

func parseI5DateTime(value string) (time.Time, error) {
	parsed, err := time.Parse(time.RFC3339, strings.TrimSpace(value))
	if err != nil || parsed.IsZero() {
		return time.Time{}, fmt.Errorf("invalid RFC3339 time")
	}
	return parsed.UTC(), nil
}

func writeI5Stored(w http.ResponseWriter, r *http.Request, status int, payload any, replayed bool, etag, location string) {
	w.Header().Set("Idempotency-Key", r.Header.Get("Idempotency-Key"))
	w.Header().Set("Idempotency-Replayed", strconv.FormatBool(replayed))
	if etag != "" {
		w.Header().Set("ETag", etag)
	}
	if location != "" {
		w.Header().Set("Location", location)
	}
	writeJSON(w, r, status, payload)
}

func writeI5List(w http.ResponseWriter, r *http.Request, data []any, page i2PageRequest, hasMore bool) {
	var nextCursor *string
	if hasMore {
		cursor := encodeI2Cursor(page.Offset + page.Limit)
		nextCursor = &cursor
	}
	writeJSON(w, r, http.StatusOK, map[string]any{
		"data": data,
		"page": map[string]any{"next_cursor": nextCursor, "has_more": hasMore, "count": len(data)},
		"meta": responseMeta(r),
	})
}

func writeI5Error(w http.ResponseWriter, r *http.Request, err error) {
	if err == nil {
		return
	}
	status, code, message := http.StatusInternalServerError, "INTERNAL_ERROR", "服务暂时不可用"
	details := map[string]any{}
	var typed *apiError
	if errors.As(err, &typed) {
		writeAPIError(w, r, err)
		return
	}
	switch {
	case errors.Is(err, i5core.ErrNotFound):
		status, code, message = http.StatusNotFound, "RESOURCE_NOT_FOUND", "资源不存在"
	case errors.Is(err, i5core.ErrValidation):
		status, code, message = http.StatusUnprocessableEntity, "VALIDATION_ERROR", "请求字段或领域规则校验失败"
	case errors.Is(err, i5core.ErrDuplicate):
		status, code, message = http.StatusConflict, "DUPLICATE_RESOURCE", "资源已存在"
	case errors.Is(err, i5core.ErrIdempotencyKeyRequired):
		status, code, message = http.StatusBadRequest, "IDEMPOTENCY_KEY_REQUIRED", "写请求需要幂等键"
	case errors.Is(err, i5core.ErrIdempotencyPayloadMismatch):
		status, code, message = http.StatusConflict, "IDEMPOTENCY_PAYLOAD_MISMATCH", "幂等键对应的载荷不一致"
	case errors.Is(err, i5core.ErrIdempotencyInProgress):
		status, code, message = http.StatusConflict, "IDEMPOTENCY_IN_PROGRESS", "相同写请求正在处理中"
	case errors.Is(err, i5core.ErrVersionConflict):
		status, code, message = http.StatusConflict, "VERSION_CONFLICT", "资源版本已变化，请刷新后重试"
		var vc versionCarrier
		if errors.As(err, &vc) {
			details["current_version"] = vc.Version()
		}
	default:
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, status, map[string]any{
		"error": map[string]any{"code": code, "message": message, "field_errors": []any{}, "recovery_actions": []any{}, "details": details},
		"meta":  responseMeta(r),
	})
}

func healthRecordJSONValue(record i5core.HealthRecord) map[string]any {
	return map[string]any{
		"id": record.ID, "hamster_id": record.HamsterID, "litter_id": record.LitterID, "type": record.Type,
		"observed_at": record.ObservedAt, "structured_checks": record.StructuredChecks, "severity": record.Severity,
		"medication": record.Medication, "media_ids": []uuid.UUID{}, "follow_up_at": record.FollowUpAt,
		"notes": record.Notes, "version": record.Version, "created_at": record.CreatedAt, "updated_at": record.UpdatedAt,
	}
}

func careTaskJSONValue(task i5core.CareTask) map[string]any {
	return map[string]any{
		"id": task.ID, "task_type": task.TaskType, "target_type": task.TargetType, "target_id": task.TargetID,
		"title": task.Title, "scheduled_at": task.ScheduledAt, "priority": task.Priority, "state": task.State,
		"subject_ids": task.SubjectIDs, "completed_subject_ids": task.CompletedSubjectIDs, "stage_total": task.StageTotal,
		"stage_done": task.StageDone, "source_event_id": task.SourceEventID, "notes": task.Notes, "version": task.Version,
	}
}

func completeTaskJSON(result i5core.CompleteTaskResult) map[string]any {
	items := make([]any, 0, len(result.ItemResults))
	for _, item := range result.ItemResults {
		items = append(items, map[string]any{"subject_id": item.SubjectID, "status": item.Status, "completion_record_id": item.CompletionRecordID, "error": nil})
	}
	return map[string]any{"task": careTaskJSONValue(result.Task), "item_results": items, "auto_closed": result.AutoClosed}
}

func reminderJSON(items []i5core.Reminder) []any {
	result := make([]any, 0, len(items))
	for _, item := range items {
		result = append(result, reminderJSONValue(item))
	}
	return result
}

func reminderJSONValue(reminder i5core.Reminder) map[string]any {
	return map[string]any{
		"id": reminder.ID, "task_id": reminder.CareTaskID, "channel": normalizeI5ReminderChannel(reminder.Channel),
		"status": normalizeI5ReminderStatus(reminder.Status), "dedupe_key": reminder.DedupeKey, "scheduled_at": reminder.ScheduledAt,
		"attempted_at": reminder.AttemptedAt, "delivered_at": reminder.DeliveredAt, "failure_code": reminder.FailureCode,
	}
}

func healthRecordJSONSlice(items []i5core.HealthRecord) []any {
	result := make([]any, 0, len(items))
	for _, item := range items {
		result = append(result, healthRecordJSONValue(item))
	}
	return result
}

func careTaskJSONSlice(items []i5core.CareTask) []any {
	result := make([]any, 0, len(items))
	for _, item := range items {
		result = append(result, careTaskJSONValue(item))
	}
	return result
}

func normalizeI5TaskType(value string) string {
	switch value {
	case "gestation_window":
		return "gestation_window_open"
	case "weaning":
		return "weaning_due"
	case "sex_separation":
		return "sex_separation_due"
	case "profile_creation":
		return "profile_creation_due"
	case "enclosure_cleaning":
		return "cleaning"
	default:
		return value
	}
}

func normalizeI5ReminderChannel(value string) string {
	if value == "local_notification" {
		return "local"
	}
	if value == "service_account" {
		return "wechat_service"
	}
	return value
}

func normalizeI5ReminderStatus(value string) string {
	switch value {
	case "queued", "sending":
		return "pending"
	case "succeeded":
		return "sent"
	default:
		return value
	}
}

func i5HealthType(value string) bool {
	return i5OneOf(value, "daily_check", "anomaly", "medication", "follow_up", "isolation", "death")
}

func i5TaskState(value string) bool {
	return i5OneOf(value, "pending", "in_progress", "completed", "snoozed", "cancelled", "superseded")
}

func i5TaskPriority(value string) bool {
	return i5OneOf(value, "low", "normal", "high", "urgent", "critical")
}

func i5TaskTargetType(value string) bool {
	return i5OneOf(value, "organization", "hamster", "litter", "enclosure", "breeding_plan", "pairing_attempt", "pup_identity")
}

func i5ReminderState(value string) bool {
	return i5OneOf(value, "pending", "sent", "read", "failed", "cancelled", "superseded")
}

func i5OneOf(value string, allowed ...string) bool {
	for _, candidate := range allowed {
		if value == candidate {
			return true
		}
	}
	return false
}
