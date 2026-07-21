package httpapi

import (
	"context"
	"encoding/json"
	"net/http"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/scolvpet/scolvpet/api/internal/aicore"
)

func (s *Server) registerP2AssistantRoutes(mux *http.ServeMux) {
	mux.HandleFunc("POST /v1/assistant/ask", s.askAssistant)
	mux.HandleFunc("GET /v1/assistant/capabilities", s.assistantCapabilities)
}

type assistantAskRequest struct {
	Question string `json:"question"`
	// PreferLLM asks Grok2API polish when AI_API_KEY/XAI_API_KEY is configured.
	PreferLLM bool `json:"prefer_llm"`
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
				aicore.IntentPlan, aicore.IntentHelp,
			},
			// OpenAPI AssistantCapabilities.mode_default 为 const "rules"；
			// LLM 是否可用只看 llm_available，勿写 agent（客户端 enum 会炸）。
			"mode_default":  "rules",
			"llm_available": llm,
			"disclaimer":    "先读取当前结构化数据再回答；新增任务等写操作需要通过确认入口执行。",
		},
		"meta": responseMeta(r),
	})
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
