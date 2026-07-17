package httpapi

import (
	"context"
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
	// PreferLLM asks xAI polish when XAI_API_KEY is configured.
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
			"mode_default": "rules",
			"llm_available": llm,
			"disclaimer":   "只读：不修改业务数据；LLM 仅润色，不新增事实。",
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
			if polished, llmErr := client.Polish(r.Context(), question, answer); llmErr == nil {
				answer = polished
			} else if s.Logger != nil {
				s.Logger.Warn("assistant llm polish failed", "error", llmErr)
			}
		}
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": answer, "meta": responseMeta(r)})
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
