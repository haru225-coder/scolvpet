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
	case "list_crm_handovers":
		return s.toolListCrmHandovers(ctx, ownerID, args)
	case "list_accounting_summary":
		return s.toolListAccountingSummary(ctx, ownerID, args)
	case "list_accounting_records":
		return s.toolListAccountingRecords(ctx, ownerID, args)
	case "search_docs":
		return s.toolSearchDocs(ctx, ownerID, args)
	case "list_recent_weights":
		return s.toolListRecentWeights(ctx, ownerID, args)
	case "list_health_records":
		return s.toolListHealthRecords(ctx, ownerID, args)
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
	case "create_crm_reservation":
		return s.toolDraftCreateCrmReservation(ctx, ownerID, sess, args)
	case "confirm_crm_reservation":
		return s.toolDraftConfirmCrmReservation(ctx, ownerID, sess, args)
	case "create_crm_handover":
		return s.toolDraftCreateCrmHandover(ctx, ownerID, sess, args)
	case "complete_crm_handover":
		return s.toolDraftCompleteCrmHandover(ctx, ownerID, sess, args)
	case "create_accounting_record":
		return s.toolDraftCreateAccountingRecord(ctx, ownerID, sess, args)
	case "create_health_record":
		return s.toolDraftCreateHealthRecord(ctx, ownerID, sess, args)
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
	case "create_crm_reservation":
		return s.executeCreateCrmReservation(ctx, ownerID, payload)
	case "confirm_crm_reservation":
		return s.executeConfirmCrmReservation(ctx, ownerID, payload)
	case "create_crm_handover":
		return s.executeCreateCrmHandover(ctx, ownerID, payload)
	case "complete_crm_handover":
		return s.executeCompleteCrmHandover(ctx, ownerID, payload)
	case "create_accounting_record":
		return s.executeCreateAccountingRecord(ctx, ownerID, payload)
	case "create_health_record":
		return s.executeCreateHealthRecord(ctx, ownerID, payload)
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

func (s *Server) executeCreateCrmReservation(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (any, error) {
	contactID, err := uuid.Parse(stringArgMap(payload, "contact_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid contact_id")
	}
	var contactStatus, contactName string
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT status::text, name FROM crm_contact WHERE owner_id=$1 AND id=$2
	`, ownerID, contactID).Scan(&contactStatus, &contactName)
	if err != nil {
		return nil, fmt.Errorf("contact not found")
	}
	if contactStatus == "archived" {
		return nil, fmt.Errorf("archived contact cannot reserve")
	}
	title := stringArgMap(payload, "title")
	if title == "" {
		title = "预订"
	}
	notes := stringArgMap(payload, "notes")
	var hamsterID *uuid.UUID
	if raw := stringArgMap(payload, "hamster_id"); raw != "" {
		hid, parseErr := uuid.Parse(raw)
		if parseErr != nil {
			return nil, fmt.Errorf("invalid hamster_id")
		}
		var lifecycle string
		err = s.Store.Pool.QueryRow(ctx, `
			SELECT lifecycle_status::text FROM hamster
			WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
		`, ownerID, hid).Scan(&lifecycle)
		if err != nil {
			return nil, fmt.Errorf("hamster not found")
		}
		if lifecycle != "active" {
			return nil, fmt.Errorf("hamster not reservable")
		}
		var open bool
		err = s.Store.Pool.QueryRow(ctx, `
			SELECT EXISTS(
				SELECT 1 FROM crm_reservation
				WHERE owner_id=$1 AND hamster_id=$2
				  AND (
				    status = 'confirmed'
				    OR (status = 'held' AND (hold_expires_at IS NULL OR hold_expires_at > now()))
				  )
			)
		`, ownerID, hid).Scan(&open)
		if err != nil {
			return nil, err
		}
		if open {
			return nil, fmt.Errorf("hamster already reserved")
		}
		hamsterID = &hid
	}
	orgID, err := s.currentOrganizationID(ctx, ownerID)
	if err != nil {
		return nil, err
	}
	holdExpires := time.Now().UTC().Add(30 * time.Minute)
	var id uuid.UUID
	err = s.Store.Pool.QueryRow(ctx, `
		INSERT INTO crm_reservation (
			owner_id, organization_id, contact_id, hamster_id, title, status, notes, hold_expires_at
		) VALUES ($1,$2,$3,$4,$5,'held',NULLIF($6,''),$7)
		RETURNING id
	`, ownerID, orgID, contactID, hamsterID, title, notes, holdExpires).Scan(&id)
	if err != nil {
		return nil, err
	}
	out := map[string]any{
		"reservation_id": id.String(),
		"contact_id":     contactID.String(),
		"contact_name":   contactName,
		"title":          title,
		"status":         "held",
	}
	if hamsterID != nil {
		out["hamster_id"] = hamsterID.String()
	}
	return out, nil
}

func (s *Server) executeCreateCrmHandover(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (any, error) {
	contactID, err := uuid.Parse(stringArgMap(payload, "contact_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid contact_id")
	}
	var contactStatus string
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT status::text FROM crm_contact WHERE owner_id=$1 AND id=$2
	`, ownerID, contactID).Scan(&contactStatus)
	if err != nil {
		return nil, fmt.Errorf("contact not found")
	}
	if contactStatus == "archived" {
		return nil, fmt.Errorf("archived contact cannot handover")
	}
	var reservationID *uuid.UUID
	var hamsterID *uuid.UUID
	if raw := stringArgMap(payload, "reservation_id"); raw != "" {
		rid, parseErr := uuid.Parse(raw)
		if parseErr != nil {
			return nil, fmt.Errorf("invalid reservation_id")
		}
		var resContact uuid.UUID
		var resHamster *uuid.UUID
		var resStatus string
		err = s.Store.Pool.QueryRow(ctx, `
			SELECT contact_id, hamster_id, status::text
			FROM crm_reservation WHERE owner_id=$1 AND id=$2
		`, ownerID, rid).Scan(&resContact, &resHamster, &resStatus)
		if err != nil {
			return nil, fmt.Errorf("reservation not found")
		}
		if resContact != contactID {
			return nil, fmt.Errorf("reservation contact mismatch")
		}
		if resStatus != "held" && resStatus != "confirmed" {
			return nil, fmt.Errorf("reservation not open for handover")
		}
		var exists bool
		err = s.Store.Pool.QueryRow(ctx, `
			SELECT EXISTS(
				SELECT 1 FROM crm_handover
				WHERE owner_id=$1 AND reservation_id=$2 AND status <> 'cancelled'
			)
		`, ownerID, rid).Scan(&exists)
		if err != nil {
			return nil, err
		}
		if exists {
			return nil, fmt.Errorf("reservation already has handover")
		}
		reservationID = &rid
		hamsterID = resHamster
	}
	if raw := stringArgMap(payload, "hamster_id"); raw != "" {
		hid, parseErr := uuid.Parse(raw)
		if parseErr != nil {
			return nil, fmt.Errorf("invalid hamster_id")
		}
		hamsterID = &hid
	}
	if hamsterID == nil {
		return nil, fmt.Errorf("hamster_id required (or via reservation)")
	}
	var lifecycle string
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT lifecycle_status::text FROM hamster
		WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
	`, ownerID, *hamsterID).Scan(&lifecycle)
	if err != nil {
		return nil, fmt.Errorf("hamster not found")
	}
	if lifecycle != "active" {
		return nil, fmt.Errorf("hamster not active")
	}
	scheduledAt := time.Now().UTC()
	if raw := stringArgMap(payload, "scheduled_at"); raw != "" {
		if parsed, parseErr := time.Parse(time.RFC3339, raw); parseErr == nil {
			scheduledAt = parsed.UTC()
		}
	}
	notes := stringArgMap(payload, "notes")
	orgID, err := s.currentOrganizationID(ctx, ownerID)
	if err != nil {
		return nil, err
	}
	var id uuid.UUID
	err = s.Store.Pool.QueryRow(ctx, `
		INSERT INTO crm_handover (
			owner_id, organization_id, contact_id, reservation_id, hamster_id, status, scheduled_at, notes
		) VALUES ($1,$2,$3,$4,$5,'scheduled',$6,NULLIF($7,''))
		RETURNING id
	`, ownerID, orgID, contactID, reservationID, hamsterID, scheduledAt, notes).Scan(&id)
	if err != nil {
		return nil, err
	}
	out := map[string]any{
		"handover_id":  id.String(),
		"contact_id":   contactID.String(),
		"hamster_id":   hamsterID.String(),
		"status":       "scheduled",
		"scheduled_at": scheduledAt.Format(time.RFC3339),
	}
	if reservationID != nil {
		out["reservation_id"] = reservationID.String()
	}
	return out, nil
}

func (s *Server) executeCreateAccountingRecord(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (any, error) {
	entryType := stringArgMap(payload, "entry_type")
	if entryType != "income" && entryType != "expense" {
		return nil, fmt.Errorf("entry_type must be income or expense")
	}
	amountCents := int64(0)
	switch v := payload["amount_cents"].(type) {
	case float64:
		amountCents = int64(v)
	case int:
		amountCents = int64(v)
	case int64:
		amountCents = v
	default:
		return nil, fmt.Errorf("invalid amount_cents")
	}
	if amountCents <= 0 {
		return nil, fmt.Errorf("amount_cents must be > 0")
	}
	title := stringArgMap(payload, "title")
	if title == "" {
		return nil, fmt.Errorf("title required")
	}
	currency := stringArgMap(payload, "currency")
	if currency == "" {
		currency = "CNY"
	}
	notes := stringArgMap(payload, "notes")
	var contactID *uuid.UUID
	if raw := stringArgMap(payload, "contact_id"); raw != "" {
		cid, parseErr := uuid.Parse(raw)
		if parseErr != nil {
			return nil, fmt.Errorf("invalid contact_id")
		}
		var n int
		err := s.Store.Pool.QueryRow(ctx, `
			SELECT count(*) FROM crm_contact WHERE owner_id=$1 AND id=$2
		`, ownerID, cid).Scan(&n)
		if err != nil || n == 0 {
			return nil, fmt.Errorf("contact not found")
		}
		contactID = &cid
	}
	occurredAt := time.Now().UTC()
	if raw := stringArgMap(payload, "occurred_at"); raw != "" {
		if parsed, err := time.Parse(time.RFC3339, raw); err == nil {
			occurredAt = parsed.UTC()
		} else if parsed, err := time.ParseInLocation("2006-01-02", raw, time.Local); err == nil {
			occurredAt = parsed.UTC()
		}
	}
	orgID, err := s.currentOrganizationID(ctx, ownerID)
	if err != nil {
		return nil, err
	}
	var id uuid.UUID
	err = s.Store.Pool.QueryRow(ctx, `
		INSERT INTO accounting_record (
			owner_id, organization_id, category_id, entry_type, amount_cents, currency,
			title, notes, contact_id, occurred_at
		) VALUES ($1,$2,NULL,$3::accounting_entry_type,$4,$5,$6,NULLIF($7,''),$8,$9)
		RETURNING id
	`, ownerID, orgID, entryType, amountCents, currency, title, notes, contactID, occurredAt).Scan(&id)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"record_id":    id.String(),
		"entry_type":   entryType,
		"amount_cents": amountCents,
		"title":        title,
		"currency":     currency,
		"occurred_at":  occurredAt.Format(time.RFC3339),
	}, nil
}

func (s *Server) executeCreateHealthRecord(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (any, error) {
	hamsterID, err := uuid.Parse(stringArgMap(payload, "hamster_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid hamster_id")
	}
	var n int
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT count(*) FROM hamster WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
	`, ownerID, hamsterID).Scan(&n)
	if err != nil || n == 0 {
		return nil, fmt.Errorf("hamster not found")
	}
	recType := stringArgMap(payload, "type")
	switch recType {
	case "daily_check", "anomaly", "medication", "follow_up", "isolation", "death":
	default:
		return nil, fmt.Errorf("invalid health record type")
	}
	observedAt := time.Now().UTC()
	if raw := stringArgMap(payload, "observed_at"); raw != "" {
		if parsed, parseErr := time.Parse(time.RFC3339, raw); parseErr == nil {
			observedAt = parsed.UTC()
		}
	}
	input := i5core.CreateHealthRecordInput{
		HamsterID:  &hamsterID,
		Type:       recType,
		ObservedAt: observedAt,
	}
	if notes := stringArgMap(payload, "notes"); notes != "" {
		input.Notes = &notes
	}
	if sev := stringArgMap(payload, "severity"); sev != "" {
		switch sev {
		case "info", "low", "medium", "high", "critical":
			input.Severity = &sev
		default:
			return nil, fmt.Errorf("invalid severity")
		}
	}
	idem := "assistant-health-" + uuid.NewString()
	result, err := s.i5CoreService().CreateHealthRecord(ctx, ownerID, i5core.WriteOptions{
		IdempotencyKey: idem, RequestMethod: "POST", RequestPath: "/v1/assistant/actions/confirm",
	}, input)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"health_record_id": result.Value.ID.String(),
		"hamster_id":       hamsterID.String(),
		"type":             recType,
		"observed_at":      observedAt.Format(time.RFC3339),
	}, nil
}

func (s *Server) executeConfirmCrmReservation(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (any, error) {
	reservationID, err := uuid.Parse(stringArgMap(payload, "reservation_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid reservation_id")
	}
	var title, status string
	var version int
	var holdExpires *time.Time
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT title, status::text, version, hold_expires_at
		FROM crm_reservation WHERE owner_id=$1 AND id=$2
	`, ownerID, reservationID).Scan(&title, &status, &version, &holdExpires)
	if err != nil {
		return nil, fmt.Errorf("reservation not found")
	}
	if status != "held" {
		return nil, fmt.Errorf("only held reservations can be confirmed")
	}
	if holdExpires != nil && !holdExpires.After(time.Now().UTC()) {
		return nil, fmt.Errorf("reservation hold expired")
	}
	tag, err := s.Store.Pool.Exec(ctx, `
		UPDATE crm_reservation
		SET status='confirmed'::crm_reservation_status, version=version+1, updated_at=now()
		WHERE owner_id=$1 AND id=$2 AND version=$3 AND status='held'
	`, ownerID, reservationID, version)
	if err != nil {
		return nil, err
	}
	if tag.RowsAffected() != 1 {
		return nil, fmt.Errorf("reservation confirm conflict")
	}
	return map[string]any{
		"reservation_id": reservationID.String(),
		"title":          title,
		"status":         "confirmed",
	}, nil
}

func (s *Server) executeCompleteCrmHandover(ctx context.Context, ownerID uuid.UUID, payload map[string]any) (any, error) {
	handoverID, err := uuid.Parse(stringArgMap(payload, "handover_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid handover_id")
	}
	tx, err := s.Store.Pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)

	current, err := getCrmHandoverTx(ctx, tx, ownerID, handoverID, true)
	if err != nil {
		return nil, fmt.Errorf("handover not found")
	}
	if current.Status != "scheduled" {
		return nil, fmt.Errorf("only scheduled handovers can be completed")
	}
	if current.HamsterID == nil {
		return nil, fmt.Errorf("handover missing hamster")
	}
	if current.Reservation != nil {
		reservation, err := getCrmReservationTx(ctx, tx, ownerID, *current.Reservation, true)
		if err != nil {
			return nil, fmt.Errorf("reservation not found")
		}
		if reservation.Status != "confirmed" || reservation.ContactID != current.ContactID ||
			reservation.HamsterID == nil || *reservation.HamsterID != *current.HamsterID {
			return nil, fmt.Errorf("handover reservation mismatch")
		}
		tag, err := tx.Exec(ctx, `
			UPDATE crm_reservation
			SET status='handed_over', version=version+1, updated_at=now()
			WHERE owner_id=$1 AND id=$2 AND version=$3 AND status='confirmed'
		`, ownerID, reservation.ID, reservation.Version)
		if err != nil {
			return nil, err
		}
		if tag.RowsAffected() != 1 {
			return nil, fmt.Errorf("reservation update conflict")
		}
	}
	tag, err := tx.Exec(ctx, `
		UPDATE hamster
		SET lifecycle_status='transferred', version=version+1, updated_at=now()
		WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL AND lifecycle_status='active'
	`, ownerID, *current.HamsterID)
	if err != nil {
		return nil, err
	}
	if tag.RowsAffected() != 1 {
		return nil, fmt.Errorf("hamster not transferable")
	}
	tag, err = tx.Exec(ctx, `
		UPDATE crm_handover
		SET status='completed', completed_at=now(), version=version+1, updated_at=now()
		WHERE owner_id=$1 AND id=$2 AND version=$3 AND status='scheduled'
	`, ownerID, handoverID, current.Version)
	if err != nil {
		return nil, err
	}
	if tag.RowsAffected() != 1 {
		return nil, fmt.Errorf("handover complete conflict")
	}
	if _, err := tx.Exec(ctx, `
		UPDATE crm_contact
		SET status='active', version=version+1, updated_at=now()
		WHERE owner_id=$1 AND id=$2 AND status='lead'
	`, ownerID, current.ContactID); err != nil {
		return nil, err
	}
	if err := insertHandoverIncomeIfNeeded(ctx, tx, ownerID, current); err != nil {
		return nil, err
	}
	if err := tx.Commit(ctx); err != nil {
		return nil, err
	}
	return map[string]any{
		"handover_id": handoverID.String(),
		"status":      "completed",
		"hamster_id":  current.HamsterID.String(),
		"contact_id":  current.ContactID.String(),
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

func (s *Server) toolListCrmHandovers(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	limit := toolLimit(args, 15, 1, 30)
	status := stringArgMap(args, "status")
	query := `
		SELECT h.id::text, h.status::text, h.scheduled_at, h.completed_at,
		       h.contact_id::text, c.name, h.hamster_id::text, h.reservation_id::text,
		       CASE WHEN hamster.id IS NULL THEN NULL ELSE COALESCE(NULLIF(hamster.name,''), hamster.internal_code) END
		FROM crm_handover h
		JOIN crm_contact c ON c.owner_id=h.owner_id AND c.id=h.contact_id
		LEFT JOIN hamster ON hamster.owner_id=h.owner_id AND hamster.id=h.hamster_id AND hamster.deleted_at IS NULL
		WHERE h.owner_id=$1 AND h.status <> 'cancelled'`
	qargs := []any{ownerID}
	if status != "" {
		query += ` AND h.status::text=$2`
		qargs = append(qargs, status)
		query += ` ORDER BY h.scheduled_at DESC LIMIT $3`
		qargs = append(qargs, limit)
	} else {
		query += ` ORDER BY h.scheduled_at DESC LIMIT $2`
		qargs = append(qargs, limit)
	}
	rows, err := s.Store.Pool.Query(ctx, query, qargs...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]map[string]any, 0)
	for rows.Next() {
		var id, st, contactID, contactName string
		var scheduled, completed any
		var hamsterID, reservationID, hamsterName *string
		if err := rows.Scan(&id, &st, &scheduled, &completed, &contactID, &contactName, &hamsterID, &reservationID, &hamsterName); err != nil {
			return nil, err
		}
		item := map[string]any{
			"id": id, "status": st, "scheduled_at": scheduled,
			"contact_id": contactID, "contact_name": contactName,
		}
		if completed != nil {
			item["completed_at"] = completed
		}
		if hamsterID != nil {
			item["hamster_id"] = *hamsterID
		}
		if reservationID != nil {
			item["reservation_id"] = *reservationID
		}
		if hamsterName != nil {
			item["hamster_name"] = *hamsterName
		}
		out = append(out, item)
	}
	return map[string]any{"count": len(out), "handovers": out}, rows.Err()
}

func (s *Server) toolDraftCreateCrmReservation(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
	if sess.SessionID == uuid.Nil {
		return nil, fmt.Errorf("session required for write draft")
	}
	contactID, err := uuid.Parse(stringArgMap(args, "contact_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid contact_id")
	}
	var contactName, contactStatus string
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT name, status::text FROM crm_contact WHERE owner_id=$1 AND id=$2
	`, ownerID, contactID).Scan(&contactName, &contactStatus)
	if err != nil {
		return nil, fmt.Errorf("contact not found")
	}
	if contactStatus == "archived" {
		return nil, fmt.Errorf("archived contact cannot reserve")
	}
	title := stringArgMap(args, "title")
	if title == "" {
		title = "预订"
	}
	payload := map[string]any{
		"contact_id": contactID.String(), "title": title, "contact_name": contactName,
	}
	if notes := stringArgMap(args, "notes"); notes != "" {
		payload["notes"] = notes
	}
	if raw := stringArgMap(args, "hamster_id"); raw != "" {
		hid, parseErr := uuid.Parse(raw)
		if parseErr != nil {
			return nil, fmt.Errorf("invalid hamster_id")
		}
		var n int
		err = s.Store.Pool.QueryRow(ctx, `
			SELECT count(*) FROM hamster WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
		`, ownerID, hid).Scan(&n)
		if err != nil || n == 0 {
			return nil, fmt.Errorf("hamster not found")
		}
		payload["hamster_id"] = hid.String()
	}
	summary := fmt.Sprintf("新建预订「%s」→ 客户 %s", title, contactName)
	if hid, ok := payload["hamster_id"].(string); ok {
		summary += " · 仓鼠 " + hid[:8]
	}
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "create_crm_reservation", "确认新建预订", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "create_crm_reservation",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}

func (s *Server) toolDraftCreateCrmHandover(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
	if sess.SessionID == uuid.Nil {
		return nil, fmt.Errorf("session required for write draft")
	}
	contactID, err := uuid.Parse(stringArgMap(args, "contact_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid contact_id")
	}
	var contactName, contactStatus string
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT name, status::text FROM crm_contact WHERE owner_id=$1 AND id=$2
	`, ownerID, contactID).Scan(&contactName, &contactStatus)
	if err != nil {
		return nil, fmt.Errorf("contact not found")
	}
	if contactStatus == "archived" {
		return nil, fmt.Errorf("archived contact cannot handover")
	}
	hamsterRaw := stringArgMap(args, "hamster_id")
	reservationRaw := stringArgMap(args, "reservation_id")
	if hamsterRaw == "" && reservationRaw == "" {
		return nil, fmt.Errorf("hamster_id or reservation_id required")
	}
	payload := map[string]any{
		"contact_id": contactID.String(), "contact_name": contactName,
	}
	if hamsterRaw != "" {
		hid, parseErr := uuid.Parse(hamsterRaw)
		if parseErr != nil {
			return nil, fmt.Errorf("invalid hamster_id")
		}
		var n int
		err = s.Store.Pool.QueryRow(ctx, `
			SELECT count(*) FROM hamster WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
		`, ownerID, hid).Scan(&n)
		if err != nil || n == 0 {
			return nil, fmt.Errorf("hamster not found")
		}
		payload["hamster_id"] = hid.String()
	}
	if reservationRaw != "" {
		rid, parseErr := uuid.Parse(reservationRaw)
		if parseErr != nil {
			return nil, fmt.Errorf("invalid reservation_id")
		}
		var n int
		err = s.Store.Pool.QueryRow(ctx, `
			SELECT count(*) FROM crm_reservation WHERE owner_id=$1 AND id=$2
		`, ownerID, rid).Scan(&n)
		if err != nil || n == 0 {
			return nil, fmt.Errorf("reservation not found")
		}
		payload["reservation_id"] = rid.String()
	}
	scheduledAt := time.Now().UTC()
	if raw := stringArgMap(args, "scheduled_at"); raw != "" {
		if parsed, parseErr := time.Parse(time.RFC3339, raw); parseErr == nil {
			scheduledAt = parsed.UTC()
		}
	}
	payload["scheduled_at"] = scheduledAt.Format(time.RFC3339)
	if notes := stringArgMap(args, "notes"); notes != "" {
		payload["notes"] = notes
	}
	summary := fmt.Sprintf("新建交付 → 客户 %s @ %s", contactName, scheduledAt.Format(time.RFC3339))
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "create_crm_handover", "确认新建交付", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "create_crm_handover",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}

func (s *Server) toolDraftCreateAccountingRecord(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
	if sess.SessionID == uuid.Nil {
		return nil, fmt.Errorf("session required for write draft")
	}
	entryType := stringArgMap(args, "entry_type")
	if entryType != "income" && entryType != "expense" {
		return nil, fmt.Errorf("entry_type must be income or expense")
	}
	amountCents := int64(0)
	switch v := args["amount_cents"].(type) {
	case float64:
		amountCents = int64(v)
	case int:
		amountCents = int64(v)
	case int64:
		amountCents = v
	default:
		return nil, fmt.Errorf("invalid amount_cents")
	}
	if amountCents <= 0 {
		return nil, fmt.Errorf("amount_cents must be > 0")
	}
	title := stringArgMap(args, "title")
	if title == "" {
		return nil, fmt.Errorf("title required")
	}
	currency := stringArgMap(args, "currency")
	if currency == "" {
		currency = "CNY"
	}
	payload := map[string]any{
		"entry_type": entryType, "amount_cents": amountCents, "title": title, "currency": currency,
	}
	if notes := stringArgMap(args, "notes"); notes != "" {
		payload["notes"] = notes
	}
	if raw := stringArgMap(args, "contact_id"); raw != "" {
		cid, parseErr := uuid.Parse(raw)
		if parseErr != nil {
			return nil, fmt.Errorf("invalid contact_id")
		}
		var n int
		err := s.Store.Pool.QueryRow(ctx, `
			SELECT count(*) FROM crm_contact WHERE owner_id=$1 AND id=$2
		`, ownerID, cid).Scan(&n)
		if err != nil || n == 0 {
			return nil, fmt.Errorf("contact not found")
		}
		payload["contact_id"] = cid.String()
	}
	if raw := stringArgMap(args, "occurred_at"); raw != "" {
		payload["occurred_at"] = raw
	}
	typeLabel := "收入"
	if entryType == "expense" {
		typeLabel = "支出"
	}
	summary := fmt.Sprintf("记账%s %.2f %s「%s」", typeLabel, float64(amountCents)/100.0, currency, title)
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "create_accounting_record", "确认记账", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "create_accounting_record",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}

func (s *Server) toolDraftCreateHealthRecord(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
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
	recType := stringArgMap(args, "type")
	switch recType {
	case "daily_check", "anomaly", "medication", "follow_up", "isolation", "death":
	default:
		return nil, fmt.Errorf("invalid health record type")
	}
	observedAt := time.Now().UTC()
	if raw := stringArgMap(args, "observed_at"); raw != "" {
		if parsed, parseErr := time.Parse(time.RFC3339, raw); parseErr == nil {
			observedAt = parsed.UTC()
		}
	}
	payload := map[string]any{
		"hamster_id": hamsterID.String(), "type": recType,
		"observed_at": observedAt.Format(time.RFC3339), "name": name,
	}
	if notes := stringArgMap(args, "notes"); notes != "" {
		payload["notes"] = notes
	}
	if sev := stringArgMap(args, "severity"); sev != "" {
		switch sev {
		case "info", "low", "medium", "high", "critical":
			payload["severity"] = sev
		default:
			return nil, fmt.Errorf("invalid severity")
		}
	}
	summary := fmt.Sprintf("健康记录 %s → %s @ %s", recType, firstNonEmptyName(name, hamsterID.String()[:8]), observedAt.Format(time.RFC3339))
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "create_health_record", "确认健康记录", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "create_health_record",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}

func (s *Server) toolListAccountingRecords(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	limit := toolLimit(args, 15, 1, 30)
	entryType := stringArgMap(args, "entry_type")
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
	query := `
		SELECT r.id::text, r.entry_type::text, r.amount_cents, r.currency, r.title,
		       COALESCE(r.notes,''), r.occurred_at, COALESCE(ct.name,'')
		FROM accounting_record r
		LEFT JOIN crm_contact ct ON ct.owner_id=r.owner_id AND ct.id=r.contact_id
		WHERE r.owner_id=$1 AND r.occurred_at >= now() - ($2 * interval '1 day')`
	qargs := []any{ownerID, days}
	argN := 3
	if entryType != "" {
		if entryType != "income" && entryType != "expense" {
			return nil, fmt.Errorf("entry_type must be income or expense")
		}
		query += fmt.Sprintf(` AND r.entry_type=$%d::accounting_entry_type`, argN)
		qargs = append(qargs, entryType)
		argN++
	}
	query += fmt.Sprintf(` ORDER BY r.occurred_at DESC, r.id DESC LIMIT $%d`, argN)
	qargs = append(qargs, limit)
	rows, err := s.Store.Pool.Query(ctx, query, qargs...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]map[string]any, 0)
	for rows.Next() {
		var id, et, currency, title, notes, contactName string
		var amount int64
		var occurred any
		if err := rows.Scan(&id, &et, &amount, &currency, &title, &notes, &occurred, &contactName); err != nil {
			return nil, err
		}
		item := map[string]any{
			"id": id, "entry_type": et, "amount_cents": amount, "currency": currency,
			"title": title, "occurred_at": occurred, "amount_yuan": float64(amount) / 100.0,
		}
		if notes != "" {
			item["notes"] = notes
		}
		if contactName != "" {
			item["contact_name"] = contactName
		}
		out = append(out, item)
	}
	return map[string]any{"count": len(out), "days": days, "records": out}, rows.Err()
}

func (s *Server) toolListHealthRecords(ctx context.Context, ownerID uuid.UUID, args map[string]any) (any, error) {
	limit := toolLimit(args, 15, 1, 30)
	recType := stringArgMap(args, "type")
	hamsterRaw := stringArgMap(args, "hamster_id")
	query := `
		SELECT hr.id::text, hr.record_type::text, hr.observed_at, hr.severity::text,
		       COALESCE(hr.notes,''), hr.hamster_id::text,
		       COALESCE(h.name,''), COALESCE(h.internal_code,'')
		FROM health_record hr
		LEFT JOIN hamster h ON h.owner_id=hr.owner_id AND h.id=hr.hamster_id AND h.deleted_at IS NULL
		WHERE hr.owner_id=$1`
	qargs := []any{ownerID}
	argN := 2
	if hamsterRaw != "" {
		hid, err := uuid.Parse(hamsterRaw)
		if err != nil {
			return nil, fmt.Errorf("invalid hamster_id")
		}
		query += fmt.Sprintf(` AND hr.hamster_id=$%d`, argN)
		qargs = append(qargs, hid)
		argN++
	}
	if recType != "" {
		switch recType {
		case "daily_check", "anomaly", "medication", "follow_up", "isolation", "death":
		default:
			return nil, fmt.Errorf("invalid health record type")
		}
		query += fmt.Sprintf(` AND hr.record_type::text=$%d`, argN)
		qargs = append(qargs, recType)
		argN++
	}
	query += fmt.Sprintf(` ORDER BY hr.observed_at DESC LIMIT $%d`, argN)
	qargs = append(qargs, limit)
	rows, err := s.Store.Pool.Query(ctx, query, qargs...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]map[string]any, 0)
	for rows.Next() {
		var id, typ, notes, name, code string
		var observed any
		var severity, hamsterID *string
		if err := rows.Scan(&id, &typ, &observed, &severity, &notes, &hamsterID, &name, &code); err != nil {
			return nil, err
		}
		item := map[string]any{
			"id": id, "type": typ, "observed_at": observed,
			"hamster_name": name, "internal_code": code,
		}
		if severity != nil && *severity != "" {
			item["severity"] = *severity
		}
		if notes != "" {
			item["notes"] = notes
		}
		if hamsterID != nil {
			item["hamster_id"] = *hamsterID
		}
		out = append(out, item)
	}
	return map[string]any{"count": len(out), "records": out}, rows.Err()
}

func (s *Server) toolDraftConfirmCrmReservation(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
	if sess.SessionID == uuid.Nil {
		return nil, fmt.Errorf("session required for write draft")
	}
	reservationID, err := uuid.Parse(stringArgMap(args, "reservation_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid reservation_id")
	}
	var title, status, contactName string
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT r.title, r.status::text, c.name
		FROM crm_reservation r
		JOIN crm_contact c ON c.owner_id=r.owner_id AND c.id=r.contact_id
		WHERE r.owner_id=$1 AND r.id=$2
	`, ownerID, reservationID).Scan(&title, &status, &contactName)
	if err != nil {
		return nil, fmt.Errorf("reservation not found")
	}
	if status != "held" {
		return nil, fmt.Errorf("only held reservations can be confirmed (current=%s)", status)
	}
	payload := map[string]any{
		"reservation_id": reservationID.String(),
		"title":          title,
		"contact_name":   contactName,
		"current_status": status,
	}
	summary := fmt.Sprintf("确认预订「%s」→ 客户 %s", title, contactName)
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "confirm_crm_reservation", "确认预订", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "confirm_crm_reservation",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}

func (s *Server) toolDraftCompleteCrmHandover(ctx context.Context, ownerID uuid.UUID, sess assistantToolSession, args map[string]any) (any, error) {
	if sess.SessionID == uuid.Nil {
		return nil, fmt.Errorf("session required for write draft")
	}
	handoverID, err := uuid.Parse(stringArgMap(args, "handover_id"))
	if err != nil {
		return nil, fmt.Errorf("invalid handover_id")
	}
	var status, contactName string
	var hamsterID *uuid.UUID
	var hamsterLabel *string
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT h.status::text, c.name, h.hamster_id,
		       CASE WHEN hamster.id IS NULL THEN NULL ELSE COALESCE(NULLIF(hamster.name,''), hamster.internal_code) END
		FROM crm_handover h
		JOIN crm_contact c ON c.owner_id=h.owner_id AND c.id=h.contact_id
		LEFT JOIN hamster ON hamster.owner_id=h.owner_id AND hamster.id=h.hamster_id AND hamster.deleted_at IS NULL
		WHERE h.owner_id=$1 AND h.id=$2
	`, ownerID, handoverID).Scan(&status, &contactName, &hamsterID, &hamsterLabel)
	if err != nil {
		return nil, fmt.Errorf("handover not found")
	}
	if status != "scheduled" {
		return nil, fmt.Errorf("only scheduled handovers can be completed (current=%s)", status)
	}
	payload := map[string]any{
		"handover_id": handoverID.String(), "contact_name": contactName, "current_status": status,
	}
	if hamsterID != nil {
		payload["hamster_id"] = hamsterID.String()
	}
	if hamsterLabel != nil {
		payload["hamster_name"] = *hamsterLabel
	}
	label := contactName
	if hamsterLabel != nil {
		label = contactName + " / " + *hamsterLabel
	}
	summary := fmt.Sprintf("完成交付 → %s（将转出仓鼠）", label)
	action, err := s.Store.InsertAssistantAction(ctx, ownerID, sess.SessionID, nil, "complete_crm_handover", "确认完成交付", summary, payload, true)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"pending_confirmation": true,
		"action_id":            action.ID.String(),
		"type":                 "complete_crm_handover",
		"label":                action.Label,
		"summary":              action.Summary,
		"payload":              payload,
		"status":               "pending",
	}, nil
}
