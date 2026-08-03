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
	case "get_hamster":
		return s.toolGetHamster(ctx, ownerID, args)
	case "list_crm_contacts":
		return s.toolListCrmContacts(ctx, ownerID, args)
	case "list_crm_reservations":
		return s.toolListCrmReservations(ctx, ownerID, args)
	case "list_accounting_summary":
		return s.toolListAccountingSummary(ctx, ownerID, args)
	case "search_docs":
		return s.toolSearchDocs(ctx, ownerID, args)
	case "list_recent_weights":
		return s.toolListRecentWeights(ctx, ownerID, args)
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
	case "create_crm_contact":
		return s.toolDraftCreateCrmContact(ctx, ownerID, sess, args)
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
	case "create_crm_contact":
		return s.executeCreateCrmContact(ctx, ownerID, payload)
	default:
		return nil, fmt.Errorf("unsupported action type %s", actionType)
	}
}

func (s *Server) executeCreateCrmContact(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (any, error) {
	name := stringArgMap(payload, "name")
	if name == "" {
		return nil, fmt.Errorf("name required")
	}
	status := stringArgMap(payload, "status")
	if status == "" {
		status = "lead"
	}
	orgID, err := s.currentOrganizationID(ctx, ownerID)
	if err != nil {
		return nil, err
	}
	phone := stringArgMap(payload, "phone")
	wechat := stringArgMap(payload, "wechat")
	notes := stringArgMap(payload, "notes")
	var id uuid.UUID
	err = s.Store.Pool.QueryRow(ctx, `
		INSERT INTO crm_contact (owner_id, organization_id, name, phone, wechat, notes, status)
		VALUES ($1,$2,$3,NULLIF($4,''),NULLIF($5,''),NULLIF($6,''),$7::crm_contact_status)
		RETURNING id
	`, ownerID, orgID, name, phone, wechat, notes, status).Scan(&id)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"contact_id": id.String(),
		"name":       name,
		"status":     status,
	}, nil
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

func (s *Server) toolGetHamster(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	id, err := uuid.Parse(stringArgMap(args, "hamster_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid hamster_id")
	}
	var name, code, sex, status string
	var enclosure *string
	var birth any
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT COALESCE(name,''), COALESCE(internal_code,''), sex::text,
		       lifecycle_status::text, current_enclosure_id::text, birth_date
		FROM hamster
		WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
	`, ownerID, id).Scan(&name, &code, &sex, &status, &enclosure, &birth)
	if err != nil {
		return nil, fmt.Errorf("hamster not found")
	}
	item := map[string]any{
		"id": id.String(), "name": name, "internal_code": code,
		"sex": sex, "lifecycle_status": status, "birth_date": birth,
	}
	if enclosure != nil {
		item["current_enclosure_id"] = *enclosure
	}
	return item, nil
}

func (s *Server) toolListCrmContacts(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	q := stringArgMap(args, "query")
	limit := toolLimit(args, 15, 1, 30)
	var (
		query string
		qargs []any
	)
	if q == "" {
		query = `
			SELECT id::text, name, COALESCE(phone,''), COALESCE(wechat,''), status::text, updated_at
			FROM crm_contact
			WHERE owner_id=$1
			ORDER BY updated_at DESC
			LIMIT $2`
		qargs = []any{ownerID, limit}
	} else {
		query = `
			SELECT id::text, name, COALESCE(phone,''), COALESCE(wechat,''), status::text, updated_at
			FROM crm_contact
			WHERE owner_id=$1
			  AND (name ILIKE $2 OR COALESCE(phone,'') ILIKE $2 OR COALESCE(wechat,'') ILIKE $2)
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
		var id, name, phone, wechat, status string
		var updated any
		if err := rows.Scan(&id, &name, &phone, &wechat, &status, &updated); err != nil {
			return nil, err
		}
		out = append(out, map[string]any{
			"id": id, "name": name, "phone": phone, "wechat": wechat,
			"status": status, "updated_at": updated,
		})
	}
	return map[string]any{"count": len(out), "contacts": out}, rows.Err()
}

func (s *Server) toolListCrmReservations(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	limit := toolLimit(args, 15, 1, 30)
	status := stringArgMap(args, "status")
	query := `
		SELECT r.id::text, r.title, r.status::text, r.reserved_at, r.contact_id::text,
		       c.name, r.hamster_id::text
		FROM crm_reservation r
		JOIN crm_contact c ON c.owner_id=r.owner_id AND c.id=r.contact_id
		WHERE r.owner_id=$1`
	qargs := []any{ownerID}
	if status != "" {
		query += ` AND r.status::text=$2`
		qargs = append(qargs, status)
		query += ` ORDER BY r.reserved_at DESC LIMIT $3`
		qargs = append(qargs, limit)
	} else {
		query += ` ORDER BY r.reserved_at DESC LIMIT $2`
		qargs = append(qargs, limit)
	}
	rows, err := s.Store.Pool.Query(ctx, query, qargs...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]map[string]any, 0)
	for rows.Next() {
		var id, title, st, contactID, contactName string
		var reserved any
		var hamsterID *string
		if err := rows.Scan(&id, &title, &st, &reserved, &contactID, &contactName, &hamsterID); err != nil {
			return nil, err
		}
		item := map[string]any{
			"id": id, "title": title, "status": st, "reserved_at": reserved,
			"contact_id": contactID, "contact_name": contactName,
		}
		if hamsterID != nil {
			item["hamster_id"] = *hamsterID
		}
		out = append(out, item)
	}
	return map[string]any{"count": len(out), "reservations": out}, rows.Err()
}

func (s *Server) toolListAccountingSummary(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	days := 30
	if v, ok := args["days"].(float64); ok {
		days = int(v)
		if days < 1 {
			days = 1
		}
		if days > 366 {
			days = 366
		}
	}
	var incomeCents, expenseCents int64
	var incomeN, expenseN int
	err := s.Store.Pool.QueryRow(ctx, `
		SELECT
		  COALESCE(SUM(CASE WHEN entry_type='income' THEN amount_cents ELSE 0 END),0),
		  COALESCE(SUM(CASE WHEN entry_type='expense' THEN amount_cents ELSE 0 END),0),
		  COALESCE(SUM(CASE WHEN entry_type='income' THEN 1 ELSE 0 END),0),
		  COALESCE(SUM(CASE WHEN entry_type='expense' THEN 1 ELSE 0 END),0)
		FROM accounting_record
		WHERE owner_id=$1 AND occurred_at >= now() - ($2 * interval '1 day')
	`, ownerID, days).Scan(&incomeCents, &expenseCents, &incomeN, &expenseN)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"days":                 days,
		"income_cents":         incomeCents,
		"expense_cents":        expenseCents,
		"net_cents":            incomeCents - expenseCents,
		"income_count":         incomeN,
		"expense_count":        expenseN,
		"income_yuan":          float64(incomeCents) / 100.0,
		"expense_yuan":         float64(expenseCents) / 100.0,
		"net_yuan":             float64(incomeCents-expenseCents) / 100.0,
	}, nil
}

func (s *Server) toolSearchDocs(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	q := stringArgMap(args, "query")
	kind := stringArgMap(args, "kind")
	limit := toolLimit(args, 15, 1, 30)
	query := `
		SELECT d.id::text, d.kind::text, d.title, d.status::text, d.amount_cents, d.currency,
		       COALESCE(c.name, ''), d.issued_at, d.updated_at
		FROM doc_document d
		LEFT JOIN crm_contact c ON c.owner_id=d.owner_id AND c.id=d.contact_id
		WHERE d.owner_id=$1 AND d.status <> 'archived'`
	qargs := []any{ownerID}
	argN := 2
	if kind == "contract" || kind == "receipt" {
		query += fmt.Sprintf(` AND d.kind::text=$%d`, argN)
		qargs = append(qargs, kind)
		argN++
	}
	if q != "" {
		query += fmt.Sprintf(` AND d.title ILIKE $%d`, argN)
		qargs = append(qargs, "%"+q+"%")
		argN++
	}
	query += fmt.Sprintf(` ORDER BY d.updated_at DESC LIMIT $%d`, argN)
	qargs = append(qargs, limit)
	rows, err := s.Store.Pool.Query(ctx, query, qargs...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]map[string]any, 0)
	for rows.Next() {
		var id, k, title, status, currency, contactName string
		var amount *int64
		var issued, updated any
		if err := rows.Scan(&id, &k, &title, &status, &amount, &currency, &contactName, &issued, &updated); err != nil {
			return nil, err
		}
		item := map[string]any{
			"id": id, "kind": k, "title": title, "status": status,
			"currency": currency, "contact_name": contactName,
			"issued_at": issued, "updated_at": updated,
		}
		if amount != nil {
			item["amount_cents"] = *amount
		}
		out = append(out, item)
	}
	return map[string]any{"count": len(out), "documents": out}, rows.Err()
}

func (s *Server) toolListRecentWeights(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	limit := toolLimit(args, 10, 1, 30)
	hamsterRaw := stringArgMap(args, "hamster_id")
	var (
		query string
		qargs []any
	)
	if hamsterRaw == "" {
		query = `
			SELECT w.id::text, w.hamster_id::text, w.weight_g, w.recorded_at,
			       COALESCE(h.name,''), COALESCE(h.internal_code,'')
			FROM weight_record w
			LEFT JOIN hamster h ON h.owner_id=w.owner_id AND h.id=w.hamster_id
			WHERE w.owner_id=$1 AND w.hamster_id IS NOT NULL
			ORDER BY w.recorded_at DESC
			LIMIT $2`
		qargs = []any{ownerID, limit}
	} else {
		hid, err := uuid.Parse(hamsterRaw)
		if err != nil {
			return nil, fmt.Errorf("invalid hamster_id")
		}
		query = `
			SELECT w.id::text, w.hamster_id::text, w.weight_g, w.recorded_at,
			       COALESCE(h.name,''), COALESCE(h.internal_code,'')
			FROM weight_record w
			LEFT JOIN hamster h ON h.owner_id=w.owner_id AND h.id=w.hamster_id
			WHERE w.owner_id=$1 AND w.hamster_id=$2
			ORDER BY w.recorded_at DESC
			LIMIT $3`
		qargs = []any{ownerID, hid, limit}
	}
	rows, err := s.Store.Pool.Query(ctx, query, qargs...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]map[string]any, 0)
	for rows.Next() {
		var id, hamsterID, name, code string
		var weight float64
		var recorded any
		if err := rows.Scan(&id, &hamsterID, &weight, &recorded, &name, &code); err != nil {
			return nil, err
		}
		out = append(out, map[string]any{
			"id": id, "hamster_id": hamsterID, "weight_g": weight,
			"recorded_at": recorded, "hamster_name": name, "internal_code": code,
		})
	}
	return map[string]any{"count": len(out), "weights": out}, rows.Err()
}

func (s *Server) toolDraftCreateCrmContact(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
	if sess.SessionID == uuid.Nil {
		return nil, fmt.Errorf("session required for write draft")
	}
	name := stringArgMap(args, "name")
	if name == "" {
		return nil, fmt.Errorf("name required")
	}
	status := stringArgMap(args, "status")
	if status == "" {
		status = "lead"
	}
	if status != "lead" && status != "active" && status != "archived" {
		return nil, fmt.Errorf("invalid status")
	}
	payload := map[string]any{"name": name, "status": status}
	if phone := stringArgMap(args, "phone"); phone != "" {
		payload["phone"] = phone
	}
	if wechat := stringArgMap(args, "wechat"); wechat != "" {
		payload["wechat"] = wechat
	}
	if notes := stringArgMap(args, "notes"); notes != "" {
		payload["notes"] = notes
	}
	summary := fmt.Sprintf("新建客户「%s」(%s)", name, status)
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "create_crm_contact", "确认新建客户", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "create_crm_contact",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}
