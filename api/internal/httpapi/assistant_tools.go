package httpapi

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/scolvpet/scolvpet/api/internal/i2core"
	"github.com/scolvpet/scolvpet/api/internal/i5core"
)

// assistantToolSession is request-scoped context for write drafts (Slice C).
type assistantToolSession struct {
	SessionID uuid.UUID
}

// runAssistantTool executes read tools and write-draft tools with owner isolation.
func (s *Server) runAssistantTool(
	ctx context.Context,
	ownerID uuid.UUID,
	sess assistantToolSession,
	name string,
	args map[string]any,
) (any, error) {
	if s.Store == nil || s.Store.Pool == nil {
		return nil, fmt.Errorf("database unavailable")
	}
	switch name {
	case "get_overview":
		snap, err := s.loadAssistantSnapshot(ctx, ownerID)
		if err != nil {
			return nil, err
		}
		return map[string]any{
			"organization_name": snap.OrganizationName,
			"active_hamsters":   snap.ActiveHamsters,
			"enclosures":        snap.Enclosures,
			"active_litters":    snap.ActiveLitters,
			"open_tasks":        snap.OpenTasks,
			"overdue_tasks":     snap.OverdueTasks,
			"gestating_plans":   snap.GestatingPlans,
			"media_bytes":       snap.MediaBytes,
			"plan_code":         snap.PlanCode,
		}, nil
	case "search_hamsters":
		return s.toolSearchHamsters(ctx, ownerID, args)
	case "list_tasks":
		return s.toolListTasks(ctx, ownerID, args)
	case "list_enclosures":
		return s.toolListEnclosures(ctx, ownerID, args)
	case "list_breeding_plans":
		return s.toolListBreedingPlans(ctx, ownerID, args)
	case "list_litters":
		return s.toolListLitters(ctx, ownerID, args)
	case "create_task":
		return s.toolDraftCreateTask(ctx, ownerID, sess, args)
	case "complete_task":
		return s.toolDraftCompleteTask(ctx, ownerID, sess, args)
	case "create_weight_record":
		return s.toolDraftCreateWeight(ctx, ownerID, sess, args)
	case "create_hamster":
		return s.toolDraftCreateHamster(ctx, ownerID, sess, args)
	case "update_hamster":
		return s.toolDraftUpdateHamster(ctx, ownerID, sess, args)
	case "create_enclosure":
		return s.toolDraftCreateEnclosure(ctx, ownerID, sess, args)
	default:
		return nil, fmt.Errorf("unknown tool %s", name)
	}
}

func (s *Server) toolDraftCreateTask(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
	if sess.SessionID == uuid.Nil {
		return nil, fmt.Errorf("session required for write draft")
	}
	targetType := stringArgMap(args, "target_type")
	targetIDStr := stringArgMap(args, "target_id")
	title := stringArgMap(args, "title")
	if targetType == "" || targetIDStr == "" || title == "" {
		return nil, fmt.Errorf("target_type, target_id, title required")
	}
	targetID, err := uuid.Parse(targetIDStr)
	if err != nil {
		return nil, fmt.Errorf("invalid target_id")
	}
	taskType := stringArgMap(args, "task_type")
	if taskType == "" {
		taskType = "custom"
	}
	priority := stringArgMap(args, "priority")
	if priority == "" {
		priority = "normal"
	}
	scheduledAt := time.Now().UTC().Add(time.Hour)
	if raw := stringArgMap(args, "scheduled_at"); raw != "" {
		if parsed, err := time.Parse(time.RFC3339, raw); err == nil {
			scheduledAt = parsed.UTC()
		}
	}
	payload := map[string]any{
		"task_type": taskType, "target_type": targetType, "target_id": targetID.String(),
		"title": title, "scheduled_at": scheduledAt.Format(time.RFC3339), "priority": priority,
	}
	if notes := stringArgMap(args, "notes"); notes != "" {
		payload["notes"] = notes
	}
	// ownership probe for hamster/enclosure targets
	if targetType == "hamster" {
		var n int
		_ = s.Store.Pool.QueryRow(ctx, `SELECT count(*) FROM hamster WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL`, ownerID, targetID).Scan(&n)
		if n == 0 {
			return nil, fmt.Errorf("hamster not found")
		}
	}
	summary := fmt.Sprintf("创建任务「%s」→ %s %s @ %s", title, targetType, targetID.String()[:8], scheduledAt.Format(time.RFC3339))
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "create_task", "确认创建任务", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "create_task",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}

func (s *Server) toolDraftCompleteTask(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
	if sess.SessionID == uuid.Nil {
		return nil, fmt.Errorf("session required for write draft")
	}
	taskIDStr := stringArgMap(args, "task_id")
	taskID, err := uuid.Parse(taskIDStr)
	if err != nil {
		return nil, fmt.Errorf("invalid task_id")
	}
	var title, status string
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT COALESCE(title,''), status::text FROM care_task WHERE owner_id=$1 AND id=$2
	`, ownerID, taskID).Scan(&title, &status)
	if err != nil {
		return nil, fmt.Errorf("task not found")
	}
	payload := map[string]any{"task_id": taskID.String(), "title": title, "current_status": status}
	summary := fmt.Sprintf("完成任务「%s」(%s)", title, taskID.String()[:8])
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "complete_task", "确认完成任务", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "complete_task",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}

func (s *Server) toolDraftCreateWeight(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
	if sess.SessionID == uuid.Nil {
		return nil, fmt.Errorf("session required for write draft")
	}
	hamsterID, err := uuid.Parse(stringArgMap(args, "hamster_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid hamster_id")
	}
	var name string
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT COALESCE(name,'') FROM hamster WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
	`, ownerID, hamsterID).Scan(&name)
	if err != nil {
		return nil, fmt.Errorf("hamster not found")
	}
	weightG, ok := args["weight_g"].(float64)
	if !ok || weightG <= 0 || weightG > 5000 {
		return nil, fmt.Errorf("invalid weight_g")
	}
	recordedAt := time.Now().UTC()
	if raw := stringArgMap(args, "recorded_at"); raw != "" {
		if parsed, err := time.Parse(time.RFC3339, raw); err == nil {
			recordedAt = parsed.UTC()
		}
	}
	payload := map[string]any{
		"hamster_id": hamsterID.String(), "weight_g": weightG,
		"recorded_at": recordedAt.Format(time.RFC3339), "name": name,
	}
	summary := fmt.Sprintf("登记 %s 体重 %.1fg @ %s", firstNonEmptyName(name, hamsterID.String()[:8]), weightG, recordedAt.Format(time.RFC3339))
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "create_weight_record", "确认登记体重", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "create_weight_record",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}

func stringArgMap(args map[string]any, key string) string {
	v, ok := args[key]
	if !ok {
		return ""
	}
	s, _ := v.(string)
	return strings.TrimSpace(s)
}

func firstNonEmptyName(values ...string) string {
	for _, v := range values {
		if strings.TrimSpace(v) != "" {
			return strings.TrimSpace(v)
		}
	}
	return ""
}

func (s *Server) toolDraftCreateHamster(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
	if sess.SessionID == uuid.Nil {
		return nil, fmt.Errorf("session required for write draft")
	}
	code := stringArgMap(args, "internal_code")
	if code == "" {
		return nil, fmt.Errorf("internal_code required")
	}
	name := stringArgMap(args, "name")
	sex := stringArgMap(args, "sex")
	if sex == "" {
		sex = "unknown"
	}
	if sex != "male" && sex != "female" && sex != "unknown" {
		return nil, fmt.Errorf("sex must be male|female|unknown")
	}
	ruleID, err := s.resolveDefaultSpeciesRule(ctx, ownerID, stringArgMap(args, "species_rule_version_id"))
	if err != nil {
		return nil, err
	}
	payload := map[string]any{
		"internal_code": code, "sex": sex,
		"species_rule_version_id": ruleID.String(),
	}
	if name != "" {
		payload["name"] = name
	}
	if notes := stringArgMap(args, "notes"); notes != "" {
		payload["notes"] = notes
	}
	labelName := firstNonEmptyName(name, code)
	summary := fmt.Sprintf("新建仓鼠「%s」编号 %s 性别 %s", labelName, code, sex)
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "create_hamster", "确认新建仓鼠", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "create_hamster",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}

func (s *Server) toolDraftUpdateHamster(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
	if sess.SessionID == uuid.Nil {
		return nil, fmt.Errorf("session required for write draft")
	}
	hamsterID, err := uuid.Parse(stringArgMap(args, "hamster_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid hamster_id")
	}
	var name, code string
	var version int
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT COALESCE(name,''), internal_code, version
		FROM hamster WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
	`, ownerID, hamsterID).Scan(&name, &code, &version)
	if err != nil {
		return nil, fmt.Errorf("hamster not found")
	}
	payload := map[string]any{
		"hamster_id": hamsterID.String(), "expected_version": version,
		"current_name": name, "internal_code": code,
	}
	changed := make([]string, 0, 3)
	if v := stringArgMap(args, "name"); v != "" {
		payload["name"] = v
		changed = append(changed, "name="+v)
	}
	if v := stringArgMap(args, "sex"); v != "" {
		if v != "male" && v != "female" && v != "unknown" {
			return nil, fmt.Errorf("sex must be male|female|unknown")
		}
		payload["sex"] = v
		changed = append(changed, "sex="+v)
	}
	if v := stringArgMap(args, "notes"); v != "" {
		payload["notes"] = v
		changed = append(changed, "notes")
	}
	if len(changed) == 0 {
		return nil, fmt.Errorf("no fields to update")
	}
	summary := fmt.Sprintf("更新仓鼠 %s：%s", firstNonEmptyName(name, code), strings.Join(changed, ", "))
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "update_hamster", "确认更新仓鼠", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "update_hamster",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}

func (s *Server) toolDraftCreateEnclosure(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
	if sess.SessionID == uuid.Nil {
		return nil, fmt.Errorf("session required for write draft")
	}
	code := stringArgMap(args, "code")
	if code == "" {
		return nil, fmt.Errorf("code required")
	}
	capacity := 1
	if v, ok := args["capacity"].(float64); ok {
		capacity = int(v)
	}
	if capacity < 1 {
		capacity = 1
	}
	if capacity > 20 {
		capacity = 20
	}
	payload := map[string]any{"code": code, "capacity": capacity}
	summary := fmt.Sprintf("新建笼盒「%s」容量 %d", code, capacity)
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "create_enclosure", "确认新建笼盒", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "create_enclosure",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}

func (s *Server) resolveDefaultSpeciesRule(ctx context.Context, ownerID uuid.UUID, explicit string) (uuid.UUID, error) {
	if explicit != "" {
		id, err := uuid.Parse(explicit)
		if err != nil {
			return uuid.Nil, fmt.Errorf("invalid species_rule_version_id")
		}
		return id, nil
	}
	var id uuid.UUID
	err := s.Store.Pool.QueryRow(ctx, `
		SELECT id FROM species_rule_version
		WHERE (owner_id=$1 OR scope='system') AND status IN ('published','draft')
		ORDER BY CASE WHEN owner_id=$1 THEN 0 ELSE 1 END,
		         CASE WHEN status='published' THEN 0 ELSE 1 END,
		         version_no DESC NULLS LAST, created_at DESC
		LIMIT 1
	`, ownerID).Scan(&id)
	if err != nil {
		// last resort any system rule
		err = s.Store.Pool.QueryRow(ctx, `
			SELECT id FROM species_rule_version WHERE scope='system' ORDER BY created_at DESC LIMIT 1
		`).Scan(&id)
		if err != nil {
			return uuid.Nil, fmt.Errorf("no species rule available")
		}
	}
	return id, nil
}

func (s *Server) executeAssistantAction(ctx context.Context, ownerID uuid.UUID, actionType string, payload map[string]any) (any, error) {
	switch actionType {
	case "create_task":
		return s.executeCreateTask(ctx, ownerID, payload)
	case "complete_task":
		return s.executeCompleteTask(ctx, ownerID, payload)
	case "create_weight_record":
		return s.executeCreateWeight(ctx, ownerID, payload)
	case "create_hamster":
		return s.executeCreateHamster(ctx, ownerID, payload)
	case "update_hamster":
		return s.executeUpdateHamster(ctx, ownerID, payload)
	case "create_enclosure":
		return s.executeCreateEnclosure(ctx, ownerID, payload)
	default:
		return nil, fmt.Errorf("unsupported action type %s", actionType)
	}
}

func (s *Server) executeCreateHamster(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (any, error) {
	code := stringArgMap(payload, "internal_code")
	ruleID, err := uuid.Parse(stringArgMap(payload, "species_rule_version_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid species_rule_version_id")
	}
	sex := stringArgMap(payload, "sex")
	if sex == "" {
		sex = "unknown"
	}
	input := i2core.CreateHamsterInput{
		InternalCode:         code,
		SpeciesRuleVersionID: ruleID,
		Sex:                  sex,
		SourceType:           "introduced",
	}
	if name := stringArgMap(payload, "name"); name != "" {
		input.Name = &name
	}
	if notes := stringArgMap(payload, "notes"); notes != "" {
		input.Notes = &notes
	}
	idem := "assistant-create-hamster-" + uuid.NewString()
	result, err := s.i2CoreService().CreateHamster(ctx, ownerID, i2core.WriteOptions{
		IdempotencyKey: idem, RequestMethod: "POST", RequestPath: "/v1/assistant/actions/confirm",
	}, input)
	if err != nil {
		return nil, err
	}
	outName := ""
	if result.Value.Name != nil {
		outName = *result.Value.Name
	}
	return map[string]any{
		"hamster_id":    result.Value.ID.String(),
		"internal_code": result.Value.InternalCode,
		"name":          outName,
	}, nil
}

func (s *Server) executeUpdateHamster(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (any, error) {
	hamsterID, err := uuid.Parse(stringArgMap(payload, "hamster_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid hamster_id")
	}
	version := 0
	switch v := payload["expected_version"].(type) {
	case float64:
		version = int(v)
	case int:
		version = v
	}
	if version < 1 {
		return nil, fmt.Errorf("invalid expected_version")
	}
	input := i2core.UpdateHamsterInput{ExpectedVersion: version}
	if name := stringArgMap(payload, "name"); name != "" {
		input.Name = &name
	}
	if sex := stringArgMap(payload, "sex"); sex != "" {
		input.Sex = &sex
	}
	if notes := stringArgMap(payload, "notes"); notes != "" {
		input.Notes = &notes
	}
	idem := "assistant-update-hamster-" + uuid.NewString()
	result, err := s.i2CoreService().UpdateHamster(ctx, ownerID, hamsterID, i2core.WriteOptions{
		IdempotencyKey: idem, RequestMethod: "PATCH", RequestPath: "/v1/assistant/actions/confirm",
	}, input)
	if err != nil {
		return nil, err
	}
	outName := ""
	if result.Value.Name != nil {
		outName = *result.Value.Name
	}
	return map[string]any{
		"hamster_id": result.Value.ID.String(),
		"name":       outName,
		"version":    result.Value.Version,
	}, nil
}

func (s *Server) executeCreateEnclosure(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (any, error) {
	code := stringArgMap(payload, "code")
	capacity := 1
	if v, ok := payload["capacity"].(float64); ok {
		capacity = int(v)
	}
	if capacity < 1 {
		capacity = 1
	}
	input := i2core.CreateEnclosureInput{
		Code: code, Capacity: capacity, State: "vacant", Cleanliness: "clean",
	}
	idem := "assistant-create-enclosure-" + uuid.NewString()
	result, err := s.i2CoreService().CreateEnclosure(ctx, ownerID, i2core.WriteOptions{
		IdempotencyKey: idem, RequestMethod: "POST", RequestPath: "/v1/assistant/actions/confirm",
	}, input)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"enclosure_id": result.Value.ID.String(),
		"code":         result.Value.Code,
		"capacity":     result.Value.Capacity,
	}, nil
}

func (s *Server) executeCreateTask(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (any, error) {
	targetID, err := uuid.Parse(stringArgMap(payload, "target_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid target_id")
	}
	title := stringArgMap(payload, "title")
	taskType := stringArgMap(payload, "task_type")
	if taskType == "" {
		taskType = "custom"
	}
	targetType := stringArgMap(payload, "target_type")
	priority := stringArgMap(payload, "priority")
	if priority == "" {
		priority = "normal"
	}
	scheduledAt := time.Now().UTC().Add(time.Hour)
	if raw := stringArgMap(payload, "scheduled_at"); raw != "" {
		if parsed, err := time.Parse(time.RFC3339, raw); err == nil {
			scheduledAt = parsed.UTC()
		}
	}
	var titlePtr *string
	if title != "" {
		titlePtr = &title
	}
	var notesPtr *string
	if notes := stringArgMap(payload, "notes"); notes != "" {
		notesPtr = &notes
	}
	input := i5core.CreateCareTaskInput{
		TaskType: taskType, TargetType: targetType, TargetID: targetID,
		Title: titlePtr, ScheduledAt: scheduledAt, Priority: priority, Notes: notesPtr,
	}
	idem := "assistant-create-task-" + uuid.NewString()
	result, err := s.i5CoreService().CreateTask(ctx, ownerID, i5core.WriteOptions{
		IdempotencyKey: idem, RequestMethod: "POST", RequestPath: "/v1/assistant/actions/confirm",
	}, input)
	if err != nil {
		return nil, err
	}
	titleOut := ""
	if result.Value.Title != nil {
		titleOut = *result.Value.Title
	}
	return map[string]any{
		"task_id": result.Value.ID.String(),
		"title":   titleOut,
		"state":   result.Value.State,
	}, nil
}

func (s *Server) executeCompleteTask(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (any, error) {
	taskID, err := uuid.Parse(stringArgMap(payload, "task_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid task_id")
	}
	task, err := s.i5CoreService().GetTask(ctx, ownerID, taskID)
	if err != nil {
		return nil, err
	}
	subjectResults := make([]i5core.TaskSubjectResult, 0, len(task.SubjectIDs))
	for _, sid := range task.SubjectIDs {
		subjectResults = append(subjectResults, i5core.TaskSubjectResult{
			SubjectID: sid, Status: "completed",
		})
	}
	if len(subjectResults) == 0 {
		// fallback: complete against target itself
		subjectResults = []i5core.TaskSubjectResult{{SubjectID: task.TargetID, Status: "completed"}}
	}
	idem := "assistant-complete-task-" + uuid.NewString()
	result, err := s.i5CoreService().CompleteTask(ctx, ownerID, taskID, i5core.WriteOptions{
		IdempotencyKey: idem, RequestMethod: "POST", RequestPath: "/v1/assistant/actions/confirm",
	}, i5core.CompleteTaskInput{
		ExpectedVersion: task.Version,
		CompletedAt:     time.Now().UTC(),
		SubjectResults:  subjectResults,
	})
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"task_id":     result.Value.Task.ID.String(),
		"state":       result.Value.Task.State,
		"auto_closed": result.Value.AutoClosed,
	}, nil
}

func (s *Server) executeCreateWeight(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (any, error) {
	hamsterID, err := uuid.Parse(stringArgMap(payload, "hamster_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid hamster_id")
	}
	weightG, ok := payload["weight_g"].(float64)
	if !ok {
		return nil, fmt.Errorf("invalid weight_g")
	}
	recordedAt := time.Now().UTC()
	if raw := stringArgMap(payload, "recorded_at"); raw != "" {
		if parsed, err := time.Parse(time.RFC3339, raw); err == nil {
			recordedAt = parsed.UTC()
		}
	}
	input := i2core.CreateWeightInput{
		SubjectType:     "hamster",
		HamsterID:       &hamsterID,
		MeasurementKind: "individual",
		WeightG:         weightG,
		RecordedAt:      recordedAt,
		Source:          "manual",
	}
	idem := "assistant-weight-" + uuid.NewString()
	result, err := s.i2CoreService().CreateWeight(ctx, ownerID, i2core.WriteOptions{
		IdempotencyKey: idem, RequestMethod: "POST", RequestPath: "/v1/assistant/actions/confirm",
	}, input)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"weight_record_id": result.Value.ID.String(),
		"weight_g":         result.Value.WeightG,
	}, nil
}

func toolLimit(args map[string]any, def, min, max int) int {
	limit := def
	if v, ok := args["limit"].(float64); ok {
		limit = int(v)
	}
	if limit < min {
		return min
	}
	if limit > max {
		return max
	}
	return limit
}

func (s *Server) toolSearchHamsters(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	q := ""
	if v, ok := args["query"].(string); ok {
		q = strings.TrimSpace(v)
	}
	limit := toolLimit(args, 10, 1, 20)
	var (
		query string
		qargs []any
	)
	if q == "" {
		query = `
			SELECT id::text, COALESCE(name,''), COALESCE(internal_code,''), sex::text,
			       lifecycle_status::text, current_enclosure_id::text
			FROM hamster
			WHERE owner_id=$1 AND deleted_at IS NULL
			ORDER BY updated_at DESC
			LIMIT $2`
		qargs = []any{ownerID, limit}
	} else {
		query = `
			SELECT id::text, COALESCE(name,''), COALESCE(internal_code,''), sex::text,
			       lifecycle_status::text, current_enclosure_id::text
			FROM hamster
			WHERE owner_id=$1 AND deleted_at IS NULL
			  AND (name ILIKE $2 OR internal_code ILIKE $2)
			ORDER BY updated_at DESC
			LIMIT $3`
		qargs = []any{ownerID, "%" + q + "%", limit}
	}
	rows, err := s.Store.Pool.Query(ctx, query, qargs...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]map[string]any, 0)
	for rows.Next() {
		var id, name, code, sex, status string
		var enclosure *string
		if err := rows.Scan(&id, &name, &code, &sex, &status, &enclosure); err != nil {
			return nil, err
		}
		item := map[string]any{
			"id": id, "name": name, "internal_code": code,
			"sex": sex, "lifecycle_status": status,
		}
		if enclosure != nil {
			item["current_enclosure_id"] = *enclosure
		}
		out = append(out, item)
	}
	return map[string]any{"count": len(out), "hamsters": out}, rows.Err()
}

func (s *Server) toolListTasks(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	limit := toolLimit(args, 15, 1, 30)
	overdueOnly, _ := args["overdue_only"].(bool)
	query := `
		SELECT id::text, task_type::text, COALESCE(title,''),
		       status::text, scheduled_at, priority::text
		FROM care_task
		WHERE owner_id=$1
		  AND status IN ('pending','in_progress','snoozed')
	`
	if overdueOnly {
		query += ` AND scheduled_at < now()`
	}
	query += ` ORDER BY scheduled_at ASC NULLS LAST LIMIT $2`
	rows, err := s.Store.Pool.Query(ctx, query, ownerID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]map[string]any, 0)
	for rows.Next() {
		var id, taskType, title, status, priority string
		var scheduled any
		if err := rows.Scan(&id, &taskType, &title, &status, &scheduled, &priority); err != nil {
			return nil, err
		}
		out = append(out, map[string]any{
			"id": id, "task_type": taskType, "title": title,
			"status": status, "scheduled_at": scheduled, "priority": priority,
		})
	}
	return map[string]any{"count": len(out), "tasks": out}, rows.Err()
}

func (s *Server) toolListEnclosures(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	limit := toolLimit(args, 20, 1, 30)
	rows, err := s.Store.Pool.Query(ctx, `
		SELECT id::text, COALESCE(code,''), state::text,
		       cleanliness::text, COALESCE(capacity,0)
		FROM enclosure
		WHERE owner_id=$1 AND deleted_at IS NULL
		ORDER BY updated_at DESC
		LIMIT $2
	`, ownerID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]map[string]any, 0)
	for rows.Next() {
		var id, code, state, clean string
		var capacity int
		if err := rows.Scan(&id, &code, &state, &clean, &capacity); err != nil {
			return nil, err
		}
		out = append(out, map[string]any{
			"id": id, "code": code, "state": state,
			"cleanliness": clean, "capacity": capacity,
		})
	}
	return map[string]any{"count": len(out), "enclosures": out}, rows.Err()
}

func (s *Server) toolListBreedingPlans(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	limit := toolLimit(args, 15, 1, 20)
	rows, err := s.Store.Pool.Query(ctx, `
		SELECT id::text, state::text, COALESCE(name,''),
		       planned_pairing_at, created_at
		FROM breeding_plan
		WHERE owner_id=$1 AND deleted_at IS NULL
		ORDER BY updated_at DESC
		LIMIT $2
	`, ownerID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]map[string]any, 0)
	for rows.Next() {
		var id, state, name string
		var pairing, created any
		if err := rows.Scan(&id, &state, &name, &pairing, &created); err != nil {
			return nil, err
		}
		out = append(out, map[string]any{
			"id": id, "state": state, "name": name,
			"planned_pairing_at": pairing, "created_at": created,
		})
	}
	return map[string]any{"count": len(out), "plans": out}, rows.Err()
}

func (s *Server) toolListLitters(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	limit := toolLimit(args, 15, 1, 20)
	rows, err := s.Store.Pool.Query(ctx, `
		SELECT id::text, COALESCE(code,''), state::text,
		       born_at, current_managed_count, created_at
		FROM litter
		WHERE owner_id=$1 AND deleted_at IS NULL
		ORDER BY updated_at DESC
		LIMIT $2
	`, ownerID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]map[string]any, 0)
	for rows.Next() {
		var id, code, state string
		var born, created any
		var managed int
		if err := rows.Scan(&id, &code, &state, &born, &managed, &created); err != nil {
			return nil, err
		}
		out = append(out, map[string]any{
			"id": id, "code": code, "state": state,
			"born_at": born, "current_managed_count": managed, "created_at": created,
		})
	}
	return map[string]any{"count": len(out), "litters": out}, rows.Err()
}
