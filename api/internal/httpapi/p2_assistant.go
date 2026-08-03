package httpapi

import (
	"context"
	"encoding/json"
	"errors"
	"io"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/scolvpet/scolvpet/api/internal/aicore"
)

func (s *Server) registerP2AssistantRoutes(mux *http.ServeMux) {
	mux.HandleFunc("POST /v1/assistant/ask", s.askAssistant)
	mux.HandleFunc("GET /v1/assistant/capabilities", s.assistantCapabilities)
	// Slice A: multi-turn general chat
	mux.HandleFunc("POST /v1/assistant/sessions", s.createAssistantSession)
	mux.HandleFunc("GET /v1/assistant/sessions", s.listAssistantSessions)
	mux.HandleFunc("GET /v1/assistant/sessions/{session_id}/messages", s.listAssistantMessages)
	mux.HandleFunc("POST /v1/assistant/chat", s.chatAssistant)
	// Slice C: confirm / cancel write drafts
	mux.HandleFunc("POST /v1/assistant/actions/{action_id}/confirm", s.confirmAssistantAction)
	mux.HandleFunc("POST /v1/assistant/actions/{action_id}/cancel", s.cancelAssistantAction)
}

type assistantAskRequest struct {
	Question string `json:"question"`
	// PreferLLM asks Grok2API polish when AI_API_KEY/XAI_API_KEY is configured.
	PreferLLM bool `json:"prefer_llm"`
}

type assistantChatRequest struct {
	SessionID *uuid.UUID `json:"session_id"`
	Message   string     `json:"message"`
	// PreferLLM defaults true when omitted (pointer nil → true).
	PreferLLM *bool `json:"prefer_llm"`
}

type assistantSessionCreateRequest struct {
	Title string `json:"title"`
}

func (s *Server) assistantCapabilities(w http.ResponseWriter, r *http.Request) {
	if _, ok := s.authenticateMemberOwner(w, r); !ok {
		return
	}
	llm := aicore.NewOptionalLLMFromEnv() != nil
	writeJSON(w, r, http.StatusOK, map[string]any{
		"data": map[string]any{
			"intents": []string{
				aicore.IntentOverview, aicore.IntentHamsters, aicore.IntentTasks,
				aicore.IntentOverdue, aicore.IntentBreeding, aicore.IntentUsage,
				aicore.IntentPlan, aicore.IntentHelp, "general",
			},
			// OpenAPI AssistantCapabilities.mode_default 为 const "rules"；
			// LLM 是否可用只看 llm_available，勿写 agent（客户端 enum 会炸）。
			"mode_default":  "llm",
			"llm_available": llm,
			"model":         assistantConfiguredModel(),
			"disclaimer":    "通用对话 + 本舍工具核验；写操作以确认卡为准，确认前不改库。",
		},
		"meta": responseMeta(r),
	})
}

func (s *Server) createAssistantSession(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	var request assistantSessionCreateRequest
	// 允许空 body；有 body 时再 decode（DisallowUnknownFields）。
	if r.Body != nil && r.ContentLength != 0 {
		if _, err := decodeBody(r, &request); err != nil {
			// 空的 chunked body 等同于省略 body；其他格式错误必须显式返回。
			if !errors.Is(err, io.EOF) {
				writeAPIError(w, r, validationError("body", "会话请求体格式不正确"))
				return
			}
		}
	}
	session, err := s.Store.CreateAssistantSession(r.Context(), ownerID, request.Title)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusCreated, map[string]any{"data": session, "meta": responseMeta(r)})
}

func (s *Server) listAssistantSessions(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	sessions, err := s.Store.ListAssistantSessions(r.Context(), ownerID, 20)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, map[string]any{
		"data": sessions,
		"page": map[string]any{"next_cursor": nil, "has_more": false, "count": len(sessions)},
		"meta": responseMeta(r),
	})
}

func (s *Server) listAssistantMessages(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	sessionID, err := uuid.Parse(r.PathValue("session_id"))
	if err != nil {
		writeAPIError(w, r, validationError("session_id", "会话 ID 无效"))
		return
	}
	if _, err := s.Store.GetAssistantSession(r.Context(), ownerID, sessionID); err != nil {
		writeAPIError(w, r, err)
		return
	}
	messages, err := s.Store.ListAssistantMessages(r.Context(), ownerID, sessionID, 40)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, map[string]any{
		"data": messages,
		"page": map[string]any{"next_cursor": nil, "has_more": false, "count": len(messages)},
		"meta": responseMeta(r),
	})
}

func (s *Server) chatAssistant(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	var request assistantChatRequest
	if _, err := decodeBody(r, &request); err != nil {
		writeAPIError(w, r, validationError("body", "对话请求体格式不正确"))
		return
	}
	message := strings.TrimSpace(request.Message)
	if message == "" {
		writeAPIError(w, r, validationError("message", "消息不能为空"))
		return
	}
	if len([]rune(message)) > 2000 {
		writeAPIError(w, r, validationError("message", "消息过长"))
		return
	}
	preferLLM := true
	if request.PreferLLM != nil {
		preferLLM = *request.PreferLLM
	}

	var sessionID uuid.UUID
	if request.SessionID != nil && *request.SessionID != uuid.Nil {
		session, err := s.Store.GetAssistantSession(r.Context(), ownerID, *request.SessionID)
		if err != nil {
			writeAPIError(w, r, err)
			return
		}
		sessionID = session.ID
	} else {
		title := message
		if len([]rune(title)) > 40 {
			title = string([]rune(title)[:40])
		}
		session, err := s.Store.CreateAssistantSession(r.Context(), ownerID, title)
		if err != nil {
			writeAPIError(w, r, err)
			return
		}
		sessionID = session.ID
	}

	historyRows, err := s.Store.ListAssistantMessages(r.Context(), ownerID, sessionID, 24)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	history := make([]aicore.ChatMessage, 0, len(historyRows))
	for _, row := range historyRows {
		if row.Role != "user" && row.Role != "assistant" {
			continue
		}
		history = append(history, aicore.ChatMessage{Role: row.Role, Content: row.Content})
	}

	if _, err := s.Store.InsertAssistantMessage(r.Context(), ownerID, sessionID, "user", message, nil, nil); err != nil {
		writeAPIError(w, r, err)
		return
	}

	snap, err := s.loadAssistantSnapshot(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	client := aicore.NewOptionalLLMFromEnv()
	ownerForTools := ownerID
	toolSess := assistantToolSession{SessionID: sessionID}
	answer, chatErr := client.Chat(r.Context(), aicore.ChatRequest{
		History:     history,
		UserMessage: message,
		KennelFacts: aicore.FormatKennelFacts(snap),
		PreferLLM:   preferLLM,
		Snapshot:    &snap,
		Tools:       aicore.ReadOnlyToolDefinitions(),
		RunTool: func(ctx context.Context, name string, args map[string]any) (any, error) {
			return s.runAssistantTool(ctx, ownerForTools, toolSess, name, args)
		},
	})
	if chatErr != nil && s.Logger != nil {
		s.Logger.Warn("assistant chat llm failed", "error", chatErr)
	}

	mode := answer.Mode
	assistantMsg, err := s.Store.InsertAssistantMessage(
		r.Context(), ownerID, sessionID, "assistant", answer.Answer, &mode, answer.Facts,
	)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	_ = s.Store.BindAssistantActionMessage(r.Context(), ownerID, sessionID, assistantMsg.ID)
	_ = s.Store.TouchAssistantSession(r.Context(), ownerID, sessionID, message)

	// Serialize actions with action_id for client confirm.
	actionsOut := make([]map[string]any, 0, len(answer.Actions))
	for _, a := range answer.Actions {
		item := map[string]any{
			"type": a.Type, "label": a.Label, "summary": a.Summary,
			"requires_confirmation": a.RequiresConfirmation,
			"payload":               a.Payload,
		}
		if id, ok := a.Payload["action_id"].(string); ok {
			item["action_id"] = id
		}
		actionsOut = append(actionsOut, item)
	}

	writeJSON(w, r, http.StatusOK, map[string]any{
		"data": map[string]any{
			"session_id": sessionID,
			"message_id": assistantMsg.ID,
			"answer":     answer.Answer,
			"intent":     answer.Intent,
			"mode":       answer.Mode,
			"facts":      answer.Facts,
			"actions":    actionsOut,
			"disclaimer": answer.Disclaimer,
		},
		"meta": responseMeta(r),
	})
}

// assistantActionRoute maps a confirmable assistant action to the direct API
// route whose RBAC rule governs it; confirm re-checks that rule.
func assistantActionRoute(actionType string) (string, bool) {
	switch actionType {
	case "create_task", "complete_task", "create_separation_task":
		return "/v1/tasks", true
	case "create_weight_record":
		return "/v1/weight-records", true
	case "create_hamster", "update_hamster":
		return "/v1/hamsters", true
	case "create_enclosure":
		return "/v1/enclosures", true
	case "create_crm_contact", "update_crm_contact":
		return "/v1/crm/contacts", true
	case "create_crm_reservation", "confirm_crm_reservation", "cancel_crm_reservation":
		return "/v1/crm/reservations", true
	case "create_crm_handover", "complete_crm_handover":
		return "/v1/crm/handovers", true
	case "create_accounting_record":
		return "/v1/accounting/records", true
	case "create_health_record":
		return "/v1/health-records", true
	case "record_pairing_observation":
		return "/v1/pairing-attempts", true
	case "create_contract":
		return "/v1/contracts", true
	case "create_receipt":
		return "/v1/receipts", true
	}
	return "", false
}

func (s *Server) confirmAssistantAction(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	if strings.TrimSpace(r.Header.Get("Idempotency-Key")) == "" {
		writeAPIError(w, r, validationError("Idempotency-Key", "确认写操作必须提供幂等键"))
		return
	}
	actionID, err := uuid.Parse(r.PathValue("action_id"))
	if err != nil {
		writeAPIError(w, r, validationError("action_id", "动作 ID 无效"))
		return
	}
	action, err := s.Store.GetAssistantAction(r.Context(), ownerID, actionID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	// Safe replay: already executed actions return the stored result.
	if action.Status == "executed" {
		var result any
		_ = json.Unmarshal(action.ResultJSON, &result)
		writeJSON(w, r, http.StatusOK, map[string]any{
			"data": map[string]any{
				"action_id": action.ID,
				"type":      action.Type,
				"status":    action.Status,
				"result":    result,
				"replayed":  true,
			},
			"meta": responseMeta(r),
		})
		return
	}
	if action.Status != "pending" {
		writeAPIError(w, r, validationError("status", "动作不是待确认状态"))
		return
	}
	// Confirm must not grant more than the equivalent direct write: re-run
	// the RBAC rule of the action's direct route. Unknown action types are
	// denied for non-owner roles so a new action cannot silently bypass this.
	if principal, hasPrincipal := principalFromRequest(r); hasPrincipal && principal.Role != "owner" {
		route, known := assistantActionRoute(action.Type)
		if !known || !principalCanRequest(principal.Role, http.MethodPost, route) {
			writeAPIError(w, r, permissionDenied(principal.Role))
			return
		}
	}
	// Claim before executing. A second concurrent request now observes the
	// confirmed state and cannot execute the business write a second time.
	action, err = s.Store.ClaimAssistantAction(r.Context(), ownerID, actionID)
	if err != nil {
		current, getErr := s.Store.GetAssistantAction(r.Context(), ownerID, actionID)
		if getErr == nil && current.Status == "executed" {
			var result any
			_ = json.Unmarshal(current.ResultJSON, &result)
			writeJSON(w, r, http.StatusOK, map[string]any{
				"data": map[string]any{
					"action_id": current.ID,
					"type":      current.Type,
					"status":    current.Status,
					"result":    result,
					"replayed":  true,
				},
				"meta": responseMeta(r),
			})
			return
		}
		if getErr == nil && current.Status != "pending" {
			writeAPIError(w, r, validationError("status", "动作正在执行或已完成"))
			return
		}
		writeAPIError(w, r, err)
		return
	}
	var payload map[string]any
	_ = json.Unmarshal(action.PayloadJSON, &payload)
	if payload == nil {
		payload = map[string]any{}
	}
	result, execErr := s.executeAssistantAction(r.Context(), ownerID, action.Type, payload)
	if execErr != nil {
		if s.Logger != nil {
			s.Logger.Warn("assistant action execute failed", "error", execErr, "type", action.Type)
		}
		_, _ = s.Store.MarkAssistantAction(r.Context(), ownerID, actionID, "confirmed", "failed", map[string]any{"error": execErr.Error()})
		writeAPIError(w, r, validationError("execute", "执行失败："+execErr.Error()))
		return
	}
	updated, err := s.Store.MarkAssistantAction(r.Context(), ownerID, actionID, "confirmed", "executed", result)
	if err != nil {
		// 业务已执行成功时，状态落库失败仍返回 200 + result，避免客户端以为失败后重复确认。
		if s.Logger != nil {
			s.Logger.Warn("assistant action mark executed failed", "error", err, "action_id", actionID)
		}
		writeJSON(w, r, http.StatusOK, map[string]any{
			"data": map[string]any{
				"action_id":  actionID,
				"type":       action.Type,
				"status":     "executed",
				"result":     result,
				"mark_error": err.Error(),
			},
			"meta": responseMeta(r),
		})
		return
	}
	writeJSON(w, r, http.StatusOK, map[string]any{
		"data": map[string]any{
			"action_id": updated.ID,
			"type":      updated.Type,
			"status":    updated.Status,
			"result":    result,
		},
		"meta": responseMeta(r),
	})
}

func (s *Server) cancelAssistantAction(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	actionID, err := uuid.Parse(r.PathValue("action_id"))
	if err != nil {
		writeAPIError(w, r, validationError("action_id", "动作 ID 无效"))
		return
	}
	action, err := s.Store.GetAssistantAction(r.Context(), ownerID, actionID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	if action.Status != "pending" {
		writeAPIError(w, r, validationError("status", "动作不是待确认状态"))
		return
	}
	updated, err := s.Store.MarkAssistantAction(r.Context(), ownerID, actionID, "pending", "cancelled", map[string]any{"cancelled": true})
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, map[string]any{
		"data": map[string]any{"action_id": updated.ID, "status": updated.Status},
		"meta": responseMeta(r),
	})
}

func assistantConfiguredModel() string {
	for _, key := range []string{"AI_MODEL", "XAI_MODEL"} {
		if v := strings.TrimSpace(os.Getenv(key)); v != "" {
			return v
		}
	}
	return "deepseek-v4-flash-0731"
}

func (s *Server) askAssistant(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	var request assistantAskRequest
	if _, err := decodeBody(r, &request); err != nil {
		writeAPIError(w, r, validationError("body", "提问请求体格式不正确"))
		return
	}
	question := strings.TrimSpace(request.Question)
	if question == "" {
		writeAPIError(w, r, validationError("question", "问题不能为空"))
		return
	}
	if len([]rune(question)) > 500 {
		writeAPIError(w, r, validationError("question", "问题过长"))
		return
	}
	snap, err := s.loadAssistantSnapshot(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	answer := aicore.AnswerFromSnapshot(question, snap)
	if request.PreferLLM {
		if client := aicore.NewOptionalLLMFromEnv(); client != nil {
			appContext, contextErr := s.loadAssistantAgentContext(r.Context(), ownerID, snap)
			if contextErr == nil {
				if planned, llmErr := client.RunAgent(r.Context(), question, answer, appContext); llmErr == nil {
					planned.Actions = sanitizeAssistantActions(planned.Actions, appContext)
					answer = planned
				} else if s.Logger != nil {
					s.Logger.Warn("assistant agent failed", "error", llmErr)
				}
			} else if s.Logger != nil {
				s.Logger.Warn("assistant context failed", "error", contextErr)
			}
		}
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": answer, "meta": responseMeta(r)})
}

func (s *Server) loadAssistantAgentContext(
	ctx context.Context,
	ownerID uuid.UUID,
	snap aicore.Snapshot,
) (map[string]any, error) {
	contextValue := map[string]any{
		"now": time.Now().UTC().Format(time.RFC3339),
		"overview": map[string]any{
			"organization_name": snap.OrganizationName,
			"active_hamsters":   snap.ActiveHamsters,
			"active_litters":    snap.ActiveLitters,
			"enclosures":        snap.Enclosures,
			"open_tasks":        snap.OpenTasks,
			"overdue_tasks":     snap.OverdueTasks,
			"gestating_plans":   snap.GestatingPlans,
		},
	}
	if org, err := s.Store.GetCurrentOrganization(ctx, ownerID); err == nil {
		contextValue["organization_id"] = org.ID
	}
	queries := []struct {
		key string
		sql string
	}{
		{
			key: "hamsters",
			sql: `SELECT COALESCE(jsonb_agg(row_value), '[]'::jsonb) FROM (
				SELECT jsonb_build_object(
					'id', id, 'name', name, 'internal_code', internal_code,
					'sex', sex, 'lifecycle_status', lifecycle_status,
					'current_enclosure_id', current_enclosure_id
				) AS row_value
				FROM hamster WHERE owner_id=$1 AND deleted_at IS NULL
				ORDER BY updated_at DESC LIMIT 50
			) rows`,
		},
		{
			key: "enclosures",
			sql: `SELECT COALESCE(jsonb_agg(row_value), '[]'::jsonb) FROM (
				SELECT jsonb_build_object(
					'id', id, 'code', code, 'state', state,
					'cleanliness', cleanliness, 'capacity', capacity
				) AS row_value
				FROM enclosure WHERE owner_id=$1 AND deleted_at IS NULL
				ORDER BY updated_at DESC LIMIT 50
			) rows`,
		},
		{
			key: "tasks",
			sql: `SELECT COALESCE(jsonb_agg(row_value), '[]'::jsonb) FROM (
				SELECT jsonb_build_object(
					'id', id, 'task_type', task_type, 'target_type', target_type,
					'target_id', target_id, 'title', title, 'scheduled_at', scheduled_at,
					'priority', priority, 'status', status
				) AS row_value
				FROM care_task WHERE owner_id=$1
					AND status IN ('pending','in_progress','snoozed')
				ORDER BY scheduled_at ASC LIMIT 50
			) rows`,
		},
	}
	for _, query := range queries {
		var raw []byte
		if err := s.Store.Pool.QueryRow(ctx, query.sql, ownerID).Scan(&raw); err != nil {
			return nil, err
		}
		var values []map[string]any
		if err := json.Unmarshal(raw, &values); err != nil {
			return nil, err
		}
		contextValue[query.key] = values
	}
	return contextValue, nil
}

func sanitizeAssistantActions(
	actions []aicore.AgentAction,
	appContext map[string]any,
) []aicore.AgentAction {
	validTargets := map[string]map[string]bool{
		"hamster": {}, "enclosure": {}, "organization": {},
	}
	if value, ok := appContext["organization_id"].(string); ok && value != "" {
		validTargets["organization"][value] = true
	}
	for _, key := range []string{"hamsters", "enclosures"} {
		targetType := strings.TrimSuffix(key, "s")
		if rows, ok := appContext[key].([]map[string]any); ok {
			for _, row := range rows {
				if id, ok := row["id"].(string); ok {
					validTargets[targetType][id] = true
				}
			}
		}
	}
	result := make([]aicore.AgentAction, 0, 3)
	for _, action := range actions {
		if len(result) == 3 {
			break
		}
		action.Type = strings.TrimSpace(action.Type)
		action.Label = strings.TrimSpace(action.Label)
		action.Summary = strings.TrimSpace(action.Summary)
		if action.Label == "" || action.Summary == "" {
			continue
		}
		switch action.Type {
		case "open_tasks", "open_data_center", "open_growth":
			action.RequiresConfirmation = false
			action.Payload = nil
			result = append(result, action)
		case "open_hamster":
			id, _ := action.Payload["hamster_id"].(string)
			if validTargets["hamster"][id] {
				action.RequiresConfirmation = false
				result = append(result, action)
			}
		case "open_enclosure":
			id, _ := action.Payload["enclosure_id"].(string)
			if validTargets["enclosure"][id] {
				action.RequiresConfirmation = false
				result = append(result, action)
			}
		case "task_draft":
			targetType, _ := action.Payload["target_type"].(string)
			targetID, _ := action.Payload["target_id"].(string)
			if !validTargets[targetType][targetID] {
				continue
			}
			taskType, _ := action.Payload["task_type"].(string)
			if !containsString([]string{
				"custom", "enclosure_cleaning", "medication", "follow_up",
				"pup_weight_check", "profile_creation",
			}, taskType) {
				action.Payload["task_type"] = "custom"
			}
			priority, _ := action.Payload["priority"].(string)
			if !containsString([]string{"low", "normal", "high", "urgent"}, priority) {
				action.Payload["priority"] = "normal"
			}
			scheduledAt, _ := action.Payload["scheduled_at"].(string)
			if parsed, err := time.Parse(time.RFC3339, scheduledAt); err != nil || parsed.Before(time.Now().Add(-time.Minute)) {
				action.Payload["scheduled_at"] = time.Now().Add(time.Hour).UTC().Format(time.RFC3339)
			}
			action.RequiresConfirmation = true
			result = append(result, action)
		}
	}
	return result
}

func containsString(values []string, target string) bool {
	for _, value := range values {
		if value == target {
			return true
		}
	}
	return false
}

func (s *Server) loadAssistantSnapshot(ctx context.Context, ownerID uuid.UUID) (aicore.Snapshot, error) {
	snap := aicore.Snapshot{
		PlanCode:    "free",
		GeneratedAt: time.Now().UTC(),
	}
	if org, err := s.Store.GetCurrentOrganization(ctx, ownerID); err == nil {
		snap.OrganizationName = org.Name
	}
	// Usage meters first.
	if usage, err := s.loadUsageMap(ctx, ownerID); err == nil {
		snap.ActiveHamsters = int64(usage["active_hamsters"])
		snap.ActiveLitters = int64(usage["active_litters"])
		snap.Enclosures = int64(usage["enclosures"])
		snap.MediaBytes = usage["media_bytes"]
	}
	// Live counts fill zeros / missing.
	var hamsters, litters, enclosures int64
	_ = s.Store.Pool.QueryRow(ctx, `
		SELECT
			(SELECT count(*) FROM hamster WHERE owner_id=$1 AND deleted_at IS NULL),
			(SELECT count(*) FROM litter WHERE owner_id=$1 AND deleted_at IS NULL),
			(SELECT count(*) FROM enclosure WHERE owner_id=$1 AND deleted_at IS NULL)
	`, ownerID).Scan(&hamsters, &litters, &enclosures)
	if snap.ActiveHamsters == 0 {
		snap.ActiveHamsters = hamsters
	}
	if snap.ActiveLitters == 0 {
		snap.ActiveLitters = litters
	}
	if snap.Enclosures == 0 {
		snap.Enclosures = enclosures
	}

	_ = s.Store.Pool.QueryRow(ctx, `
		SELECT count(*) FROM care_task
		WHERE owner_id=$1
		  AND status IN ('pending','in_progress','snoozed')
	`, ownerID).Scan(&snap.OpenTasks)

	_ = s.Store.Pool.QueryRow(ctx, `
		SELECT count(*) FROM care_task
		WHERE owner_id=$1
		  AND status IN ('pending','in_progress','snoozed')
		  AND scheduled_at < now()
	`, ownerID).Scan(&snap.OverdueTasks)

	_ = s.Store.Pool.QueryRow(ctx, `
		SELECT count(*) FROM breeding_plan
		WHERE owner_id=$1 AND deleted_at IS NULL
		  AND state IN ('pairing','post_pair','gestation','litter_nursing','weaning_due','sex_separation_due','individualizing')
	`, ownerID).Scan(&snap.GestatingPlans)

	var pro bool
	err := s.Store.Pool.QueryRow(ctx, `
		SELECT COALESCE(boolean_value, false)
		FROM entitlement
		WHERE owner_id=$1 AND entitlement_code='plan.pro' AND revoked_at IS NULL
		  AND effective_at <= now()
		  AND (expires_at IS NULL OR expires_at > now())
		LIMIT 1
	`, ownerID).Scan(&pro)
	if err == nil && pro {
		snap.PlanCode = "pro"
	}
	return snap, nil
}
