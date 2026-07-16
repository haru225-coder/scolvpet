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
	"github.com/jackc/pgx/v5/pgconn"

	"github.com/scolvpet/scolvpet/api/internal/i3core"
	"github.com/scolvpet/scolvpet/api/internal/store"
)

func (s *Server) registerI3Routes(mux *http.ServeMux) {
	mux.HandleFunc("GET /v1/breeding-plans", s.listI3BreedingPlans)
	mux.HandleFunc("POST /v1/breeding-plans", s.createI3BreedingPlan)
	mux.HandleFunc("GET /v1/breeding-plans/{plan_id}", s.getI3BreedingPlan)
	mux.HandleFunc("PATCH /v1/breeding-plans/{plan_id}", s.updateI3BreedingPlan)
	mux.HandleFunc("POST /v1/breeding-plans/{plan_id}/publish", s.publishI3BreedingPlan)
	mux.HandleFunc("POST /v1/breeding-plans/{plan_id}/start-pairing", s.startI3Pairing)
	mux.HandleFunc("GET /v1/breeding-plans/{plan_id}/pairing-attempts", s.listI3PairingAttempts)
	mux.HandleFunc("GET /v1/pairing-attempts/{attempt_id}", s.getI3PairingAttempt)
	mux.HandleFunc("POST /v1/pairing-attempts/{attempt_id}/record-observation", s.recordI3Observation)
	mux.HandleFunc("POST /v1/pairing-attempts/{attempt_id}/separate", s.separateI3Pairing)
	mux.HandleFunc("POST /v1/breeding-plans/{plan_id}/start-gestation", s.startI3Gestation)
}

func (s *Server) i3CoreService() *i3core.Service {
	return i3core.NewService(s.Store)
}

func (s *Server) authenticateI3(w http.ResponseWriter, r *http.Request) (uuid.UUID, bool) {
	ownerID, _, ok := s.authenticate(r)
	if !ok {
		writeAPIError(w, r, authRequired())
		return uuid.Nil, false
	}
	return ownerID, true
}

type i3PlanCreateRequest struct {
	Name             *string        `json:"name"`
	SireID           uuid.UUID      `json:"sire_id"`
	DamID            uuid.UUID      `json:"dam_id"`
	RuleVersionID    uuid.UUID      `json:"rule_version_id"`
	PlannedPairingAt *string        `json:"planned_pairing_at"`
	ObjectiveTraits  map[string]any `json:"objective_traits"`
	Notes            *string        `json:"notes"`
}

type i3PublishRequest struct {
	PlannedPairingAt      string    `json:"planned_pairing_at"`
	PairingEnclosureID    uuid.UUID `json:"pairing_enclosure_id"`
	Timezone              string    `json:"timezone"`
	KinshipOverrideReason *string   `json:"kinship_override_reason"`
}

type i3StartPairingRequest struct {
	EnclosureID uuid.UUID `json:"enclosure_id"`
	StartedAt   string    `json:"started_at"`
	Timezone    string    `json:"timezone"`
	Notes       *string   `json:"notes"`
}

type i3ObservationRequest struct {
	ObservedAt      string      `json:"observed_at"`
	Type            string      `json:"type"`
	DurationSeconds *int        `json:"duration_seconds"`
	Severity        *string     `json:"severity"`
	Confidence      *float64    `json:"confidence"`
	MediaIDs        []uuid.UUID `json:"media_ids"`
	Notes           *string     `json:"notes"`
}

type i3SeparateRequest struct {
	EndedAt                    string    `json:"ended_at"`
	SeparatedAt                string    `json:"separated_at"`
	Result                     string    `json:"result"`
	SireDestinationEnclosureID uuid.UUID `json:"sire_destination_enclosure_id"`
	DamDestinationEnclosureID  uuid.UUID `json:"dam_destination_enclosure_id"`
	SafetyStop                 bool      `json:"safety_stop"`
	Timezone                   string    `json:"timezone"`
	Notes                      *string   `json:"notes"`
}

type i3GestationRequest struct {
	PairingAttemptID uuid.UUID `json:"pairing_attempt_id"`
	Result           string    `json:"result"`
	BaselineAt       string    `json:"baseline_at"`
	Timezone         string    `json:"timezone"`
	Notes            *string   `json:"notes"`
}

func (s *Server) listI3BreedingPlans(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI3(w, r)
	if !ok {
		return
	}
	page, err := parseI2Page(r)
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	filter := i3core.PlanListFilter{Limit: page.Limit, Offset: page.Offset, State: strings.TrimSpace(r.URL.Query().Get("state"))}
	if filter.State != "" && !i3PlanState(filter.State) {
		writeI3Error(w, r, &i3core.ValidationError{Field: "state", Message: "繁育计划状态不正确"})
		return
	}
	if filter.SireID, err = i3OptionalUUIDQuery(r, "sire_id"); err != nil {
		writeI3Error(w, r, err)
		return
	}
	if filter.DamID, err = i3OptionalUUIDQuery(r, "dam_id"); err != nil {
		writeI3Error(w, r, err)
		return
	}
	plans, hasMore, err := s.i3CoreService().ListPlans(r.Context(), ownerID, filter)
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	data := make([]any, 0, len(plans))
	for _, plan := range plans {
		data = append(data, i3core.PlanJSON(plan))
	}
	pageInfo := i2PageInfo{HasMore: hasMore, Count: len(data)}
	if hasMore {
		cursor := encodeI2Cursor(page.Offset + len(plans))
		pageInfo.NextCursor = &cursor
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": data, "page": pageInfo, "meta": responseMeta(r)})
}

func (s *Server) createI3BreedingPlan(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI3(w, r)
	if !ok {
		return
	}
	var request i3PlanCreateRequest
	payload, err := decodeBody(r, &request)
	if err != nil {
		writeI3Error(w, r, &i3core.ValidationError{Field: "body", Message: "繁育计划请求体格式不正确"})
		return
	}
	input, err := request.createInput()
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	result, err := s.Store.RunIdempotent(r.Context(), ownerID, r.Header.Get("Idempotency-Key"), http.MethodPost, r.URL.Path, payload,
		func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
			plan, txErr := s.i3CoreService().CreatePlanTx(ctx, tx, ownerID, input, r.Header.Get("Idempotency-Key"))
			if txErr != nil {
				return 0, nil, nil, txErr
			}
			return http.StatusCreated, envelope(r, i3core.PlanJSON(plan)), map[string]string{
				"ETag": store.FormatETag(plan.Version), "Location": "/v1/breeding-plans/" + plan.ID.String(),
			}, nil
		})
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	writeStored(w, r, result)
}

func (s *Server) getI3BreedingPlan(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI3(w, r)
	if !ok {
		return
	}
	planID, err := i3PathUUID(r, "plan_id")
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	plan, err := s.i3CoreService().GetPlan(r.Context(), ownerID, planID)
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	w.Header().Set("ETag", store.FormatETag(plan.Version))
	writeJSON(w, r, http.StatusOK, envelope(r, i3core.PlanJSON(plan)))
}

func (s *Server) updateI3BreedingPlan(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI3(w, r)
	if !ok {
		return
	}
	planID, err := i3PathUUID(r, "plan_id")
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	input, payload, err := decodeI3PlanPatch(r)
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	input.ExpectedVersion, err = store.ParseETag(r.Header.Get("If-Match"))
	if err != nil {
		writeI3Error(w, r, &i3core.ValidationError{Field: "If-Match", Message: "If-Match 必须是当前资源版本 ETag"})
		return
	}
	result, err := s.Store.RunIdempotent(r.Context(), ownerID, r.Header.Get("Idempotency-Key"), http.MethodPatch, r.URL.Path, payload,
		func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
			plan, txErr := s.i3CoreService().UpdatePlanTx(ctx, tx, ownerID, planID, input, r.Header.Get("Idempotency-Key"))
			if txErr != nil {
				return 0, nil, nil, txErr
			}
			return http.StatusOK, envelope(r, i3core.PlanJSON(plan)), map[string]string{"ETag": store.FormatETag(plan.Version)}, nil
		})
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	writeStored(w, r, result)
}

func (s *Server) publishI3BreedingPlan(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI3(w, r)
	if !ok {
		return
	}
	planID, err := i3PathUUID(r, "plan_id")
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	var request i3PublishRequest
	payload, err := decodeBody(r, &request)
	if err != nil {
		writeI3Error(w, r, &i3core.ValidationError{Field: "body", Message: "发布请求体格式不正确"})
		return
	}
	plannedAt, err := parseI3DateTime(request.PlannedPairingAt, "planned_pairing_at")
	if err != nil || request.PairingEnclosureID == uuid.Nil || strings.TrimSpace(request.Timezone) == "" {
		writeI3Error(w, r, &i3core.ValidationError{Field: "publish", Message: "发布需要计划时间、配对笼和时区"})
		return
	}
	if _, err := time.LoadLocation(request.Timezone); err != nil {
		writeI3Error(w, r, &i3core.ValidationError{Field: "timezone", Message: "时区格式不正确"})
		return
	}
	expected, err := parseI3IfMatch(r)
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	input := i3core.PublishPlanInput{ExpectedVersion: expected, PlannedPairingAt: plannedAt, PairingEnclosureID: request.PairingEnclosureID, KinshipOverrideReason: request.KinshipOverrideReason}
	result, err := s.Store.RunIdempotent(r.Context(), ownerID, r.Header.Get("Idempotency-Key"), http.MethodPost, r.URL.Path, payload,
		func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
			plan, tasks, txErr := s.i3CoreService().PublishPlanTx(ctx, tx, ownerID, planID, input, r.Header.Get("Idempotency-Key"))
			if txErr != nil {
				return 0, nil, nil, txErr
			}
			return http.StatusOK, envelope(r, map[string]any{"breeding_plan": i3core.PlanJSON(plan), "created_tasks": tasks}), map[string]string{"ETag": store.FormatETag(plan.Version)}, nil
		})
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	writeStored(w, r, result)
}

func (s *Server) startI3Pairing(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI3(w, r)
	if !ok {
		return
	}
	planID, err := i3PathUUID(r, "plan_id")
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	var request i3StartPairingRequest
	payload, err := decodeBody(r, &request)
	if err != nil {
		writeI3Error(w, r, &i3core.ValidationError{Field: "body", Message: "开始配对请求体格式不正确"})
		return
	}
	startedAt, err := parseI3DateTime(request.StartedAt, "started_at")
	if err != nil || request.EnclosureID == uuid.Nil || strings.TrimSpace(request.Timezone) == "" {
		writeI3Error(w, r, &i3core.ValidationError{Field: "start_pairing", Message: "开始配对需要笼盒、开始时间和时区"})
		return
	}
	if _, err := time.LoadLocation(request.Timezone); err != nil {
		writeI3Error(w, r, &i3core.ValidationError{Field: "timezone", Message: "时区格式不正确"})
		return
	}
	expected, err := parseI3IfMatch(r)
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	input := i3core.StartPairingInput{ExpectedVersion: expected, EnclosureID: request.EnclosureID, StartedAt: startedAt, Notes: request.Notes}
	result, err := s.Store.RunIdempotent(r.Context(), ownerID, r.Header.Get("Idempotency-Key"), http.MethodPost, r.URL.Path, payload,
		func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
			started, txErr := s.i3CoreService().StartPairingTx(ctx, tx, ownerID, planID, input, r.Header.Get("Idempotency-Key"))
			if txErr != nil {
				return 0, nil, nil, txErr
			}
			return http.StatusOK, envelope(r, map[string]any{"breeding_plan": i3core.PlanJSON(started.Plan), "pairing_attempt": i3core.AttemptJSON(started.Attempt)}), map[string]string{"ETag": store.FormatETag(started.Plan.Version)}, nil
		})
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	writeStored(w, r, result)
}

func (s *Server) listI3PairingAttempts(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI3(w, r)
	if !ok {
		return
	}
	planID, err := i3PathUUID(r, "plan_id")
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	page, err := parseI2Page(r)
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	attempts, hasMore, err := s.i3CoreService().ListAttempts(r.Context(), ownerID, planID, i3core.AttemptListFilter{Limit: page.Limit, Offset: page.Offset})
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	data := make([]any, 0, len(attempts))
	for _, attempt := range attempts {
		data = append(data, i3core.AttemptJSON(attempt))
	}
	pageInfo := i2PageInfo{HasMore: hasMore, Count: len(data)}
	if hasMore {
		cursor := encodeI2Cursor(page.Offset + len(attempts))
		pageInfo.NextCursor = &cursor
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": data, "page": pageInfo, "meta": responseMeta(r)})
}

func (s *Server) getI3PairingAttempt(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI3(w, r)
	if !ok {
		return
	}
	attemptID, err := i3PathUUID(r, "attempt_id")
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	attempt, err := s.i3CoreService().GetAttempt(r.Context(), ownerID, attemptID)
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	w.Header().Set("ETag", store.FormatETag(attempt.Version))
	writeJSON(w, r, http.StatusOK, envelope(r, i3core.AttemptJSON(attempt)))
}

func (s *Server) recordI3Observation(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI3(w, r)
	if !ok {
		return
	}
	attemptID, err := i3PathUUID(r, "attempt_id")
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	var request i3ObservationRequest
	payload, err := decodeBody(r, &request)
	if err != nil {
		writeI3Error(w, r, &i3core.ValidationError{Field: "body", Message: "观察请求体格式不正确"})
		return
	}
	observedAt, err := parseI3DateTime(request.ObservedAt, "observed_at")
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	expected, err := parseI3IfMatch(r)
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	if request.MediaIDs == nil {
		request.MediaIDs = []uuid.UUID{}
	}
	input := i3core.RecordObservationInput{ExpectedVersion: expected, ObservedAt: observedAt, Type: request.Type,
		DurationSeconds: request.DurationSeconds, Severity: request.Severity, Confidence: request.Confidence,
		MediaIDs: request.MediaIDs, Notes: request.Notes}
	result, err := s.Store.RunIdempotent(r.Context(), ownerID, r.Header.Get("Idempotency-Key"), http.MethodPost, r.URL.Path, payload,
		func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
			observation, version, baseline, txErr := s.i3CoreService().RecordObservationTx(ctx, tx, ownerID, attemptID, input, r.Header.Get("Idempotency-Key"))
			if txErr != nil {
				return 0, nil, nil, txErr
			}
			return http.StatusCreated, envelope(r, map[string]any{"observation": i3core.ObservationJSON(observation), "pairing_attempt_version": version, "baseline_candidate_at": baseline}), map[string]string{
				"ETag": store.FormatETag(version), "Location": "/v1/pairing-attempts/" + attemptID.String(),
			}, nil
		})
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	writeStored(w, r, result)
}

func (s *Server) separateI3Pairing(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI3(w, r)
	if !ok {
		return
	}
	attemptID, err := i3PathUUID(r, "attempt_id")
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	var request i3SeparateRequest
	payload, err := decodeBody(r, &request)
	if err != nil {
		writeI3Error(w, r, &i3core.ValidationError{Field: "body", Message: "分笼请求体格式不正确"})
		return
	}
	endedAt, err := parseI3DateTime(request.EndedAt, "ended_at")
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	separatedAt, err := parseI3DateTime(request.SeparatedAt, "separated_at")
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	if strings.TrimSpace(request.Timezone) == "" {
		writeI3Error(w, r, &i3core.ValidationError{Field: "timezone", Message: "时区不能为空"})
		return
	}
	if _, err := time.LoadLocation(request.Timezone); err != nil {
		writeI3Error(w, r, &i3core.ValidationError{Field: "timezone", Message: "时区格式不正确"})
		return
	}
	expected, err := parseI3IfMatch(r)
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	input := i3core.SeparatePairingInput{ExpectedVersion: expected, EndedAt: endedAt, SeparatedAt: separatedAt,
		Result: request.Result, SireDestinationEnclosureID: request.SireDestinationEnclosureID,
		DamDestinationEnclosureID: request.DamDestinationEnclosureID, SafetyStop: request.SafetyStop, Notes: request.Notes}
	result, err := s.Store.RunIdempotent(r.Context(), ownerID, r.Header.Get("Idempotency-Key"), http.MethodPost, r.URL.Path, payload,
		func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
			separated, txErr := s.i3CoreService().SeparatePairingTx(ctx, tx, ownerID, attemptID, input, r.Header.Get("Idempotency-Key"))
			if txErr != nil {
				return 0, nil, nil, txErr
			}
			stays := make([]any, 0, len(separated.CreatedStays))
			for _, stay := range separated.CreatedStays {
				stays = append(stays, i3core.StayJSON(stay))
			}
			return http.StatusOK, envelope(r, map[string]any{"pairing_attempt": i3core.AttemptJSON(separated.Attempt), "breeding_plan": i3core.PlanJSON(separated.Plan), "created_stays": stays, "created_task_ids": separated.CreatedTaskIDs}), map[string]string{"ETag": store.FormatETag(separated.Attempt.Version)}, nil
		})
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	writeStored(w, r, result)
}

func (s *Server) startI3Gestation(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI3(w, r)
	if !ok {
		return
	}
	planID, err := i3PathUUID(r, "plan_id")
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	var request i3GestationRequest
	payload, err := decodeBody(r, &request)
	if err != nil {
		writeI3Error(w, r, &i3core.ValidationError{Field: "body", Message: "孕期请求体格式不正确"})
		return
	}
	baselineAt, err := parseI3DateTime(request.BaselineAt, "baseline_at")
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	if request.PairingAttemptID == uuid.Nil || strings.TrimSpace(request.Timezone) == "" {
		writeI3Error(w, r, &i3core.ValidationError{Field: "gestation", Message: "孕期请求需要配对尝试和时区"})
		return
	}
	expected, err := parseI3IfMatch(r)
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	input := i3core.StartGestationInput{ExpectedVersion: expected, PairingAttemptID: request.PairingAttemptID, Result: request.Result, BaselineAt: baselineAt, Timezone: request.Timezone, Notes: request.Notes}
	result, err := s.Store.RunIdempotent(r.Context(), ownerID, r.Header.Get("Idempotency-Key"), http.MethodPost, r.URL.Path, payload,
		func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
			plan, reminders, txErr := s.i3CoreService().StartGestationTx(ctx, tx, ownerID, planID, input, r.Header.Get("Idempotency-Key"))
			if txErr != nil {
				return 0, nil, nil, txErr
			}
			return http.StatusOK, envelope(r, map[string]any{"breeding_plan": i3core.PlanJSON(plan), "created_reminders": reminders}), map[string]string{"ETag": store.FormatETag(plan.Version)}, nil
		})
	if err != nil {
		writeI3Error(w, r, err)
		return
	}
	writeStored(w, r, result)
}

func (request i3PlanCreateRequest) createInput() (i3core.CreatePlanInput, error) {
	input := i3core.CreatePlanInput{Name: request.Name, SireID: request.SireID, DamID: request.DamID, RuleVersionID: request.RuleVersionID, ObjectiveTraits: request.ObjectiveTraits, Notes: request.Notes}
	if request.PlannedPairingAt != nil {
		value, err := parseI3DateTime(*request.PlannedPairingAt, "planned_pairing_at")
		if err != nil {
			return i3core.CreatePlanInput{}, err
		}
		input.PlannedPairingAt = &value
	}
	return input, nil
}

func decodeI3PlanPatch(r *http.Request) (i3core.UpdatePlanInput, []byte, error) {
	var patch map[string]json.RawMessage
	payload, err := decodeBody(r, &patch)
	if err != nil || len(patch) == 0 {
		return i3core.UpdatePlanInput{}, payload, &i3core.ValidationError{Field: "body", Message: "更新请求必须是非空 merge patch"}
	}
	allowed := map[string]bool{"name": true, "sire_id": true, "dam_id": true, "rule_version_id": true, "planned_pairing_at": true, "objective_traits": true, "notes": true}
	for field := range patch {
		if !allowed[field] {
			return i3core.UpdatePlanInput{}, payload, &i3core.ValidationError{Field: field, Message: "字段不允许更新"}
		}
	}
	var input i3core.UpdatePlanInput
	if raw, ok := patch["name"]; ok {
		if string(raw) == "null" {
			input.ClearName = true
		} else if err := json.Unmarshal(raw, &input.Name); err != nil {
			return i3core.UpdatePlanInput{}, payload, &i3core.ValidationError{Field: "name", Message: "name 格式不正确"}
		}
	}
	if raw, ok := patch["sire_id"]; ok {
		value, err := i3JSONUUID(raw, "sire_id")
		if err != nil {
			return i3core.UpdatePlanInput{}, payload, err
		}
		input.SireID = &value
	}
	if raw, ok := patch["dam_id"]; ok {
		value, err := i3JSONUUID(raw, "dam_id")
		if err != nil {
			return i3core.UpdatePlanInput{}, payload, err
		}
		input.DamID = &value
	}
	if raw, ok := patch["rule_version_id"]; ok {
		value, err := i3JSONUUID(raw, "rule_version_id")
		if err != nil {
			return i3core.UpdatePlanInput{}, payload, err
		}
		input.RuleVersionID = &value
	}
	if raw, ok := patch["planned_pairing_at"]; ok {
		if string(raw) == "null" {
			input.ClearPlannedPairingAt = true
		} else {
			var value string
			if json.Unmarshal(raw, &value) != nil {
				return i3core.UpdatePlanInput{}, payload, &i3core.ValidationError{Field: "planned_pairing_at", Message: "计划时间格式不正确"}
			}
			parsed, err := parseI3DateTime(value, "planned_pairing_at")
			if err != nil {
				return i3core.UpdatePlanInput{}, payload, err
			}
			input.PlannedPairingAt = &parsed
		}
	}
	if raw, ok := patch["objective_traits"]; ok {
		if json.Unmarshal(raw, &input.ObjectiveTraits) != nil || input.ObjectiveTraits == nil {
			return i3core.UpdatePlanInput{}, payload, &i3core.ValidationError{Field: "objective_traits", Message: "objective_traits 必须是对象"}
		}
	}
	if raw, ok := patch["notes"]; ok {
		if string(raw) == "null" {
			input.ClearNotes = true
		} else if json.Unmarshal(raw, &input.Notes) != nil {
			return i3core.UpdatePlanInput{}, payload, &i3core.ValidationError{Field: "notes", Message: "notes 格式不正确"}
		}
	}
	return input, payload, nil
}

func i3PathUUID(r *http.Request, name string) (uuid.UUID, error) {
	value, err := uuid.Parse(r.PathValue(name))
	if err != nil || value == uuid.Nil {
		return uuid.Nil, i3core.ErrNotFound
	}
	return value, nil
}

func i3OptionalUUIDQuery(r *http.Request, name string) (*uuid.UUID, error) {
	value := strings.TrimSpace(r.URL.Query().Get(name))
	if value == "" {
		return nil, nil
	}
	parsed, err := uuid.Parse(value)
	if err != nil || parsed == uuid.Nil {
		return nil, &i3core.ValidationError{Field: name, Message: name + " 格式不正确"}
	}
	return &parsed, nil
}

func parseI3DateTime(value, field string) (time.Time, error) {
	parsed, err := time.Parse(time.RFC3339, strings.TrimSpace(value))
	if err != nil {
		return time.Time{}, &i3core.ValidationError{Field: field, Message: field + " 必须是 RFC3339 时间"}
	}
	return parsed.UTC(), nil
}

func parseI3IfMatch(r *http.Request) (int, error) {
	version, err := store.ParseETag(r.Header.Get("If-Match"))
	if err != nil {
		return 0, &i3core.ValidationError{Field: "If-Match", Message: "If-Match 必须是当前资源版本 ETag"}
	}
	return version, nil
}

func i3JSONUUID(raw json.RawMessage, field string) (uuid.UUID, error) {
	var value string
	if json.Unmarshal(raw, &value) != nil {
		return uuid.Nil, &i3core.ValidationError{Field: field, Message: field + " 必须是 UUID"}
	}
	parsed, err := uuid.Parse(value)
	if err != nil || parsed == uuid.Nil {
		return uuid.Nil, &i3core.ValidationError{Field: field, Message: field + " 必须是 UUID"}
	}
	return parsed, nil
}

func i3PlanState(value string) bool {
	return oneOfI3(value, "draft", "pair_ready", "pairing", "post_pair", "gestation", "litter_nursing", "weaning_due", "sex_separation_due", "individualizing", "completed", "no_litter_outcome", "hold", "unsuccessful", "cancelled")
}

func oneOfI3(value string, choices ...string) bool {
	for _, choice := range choices {
		if value == choice {
			return true
		}
	}
	return false
}

func writeI3Error(w http.ResponseWriter, r *http.Request, err error) {
	if err == nil {
		return
	}
	var typedAPI *apiError
	if errors.As(err, &typedAPI) {
		writeAPIError(w, r, err)
		return
	}
	status, code, message := http.StatusInternalServerError, "INTERNAL_ERROR", "服务暂时不可用"
	details := map[string]any{}
	if errors.Is(err, i3core.ErrNotFound) || errors.Is(err, store.ErrNotFound) || errors.Is(err, pgx.ErrNoRows) {
		status, code, message = http.StatusNotFound, "RESOURCE_NOT_FOUND", "未找到指定繁育资源"
	} else if errors.Is(err, i3core.ErrValidation) {
		status, code, message = http.StatusUnprocessableEntity, "VALIDATION_ERROR", "请求字段或繁育规则校验失败"
		var validation *i3core.ValidationError
		if errors.As(err, &validation) {
			details["field"] = validation.Field
			message = validation.Message
		}
	} else if errors.Is(err, i3core.ErrVersionConflict) || errors.Is(err, store.ErrVersionConflict) {
		status, code, message = http.StatusConflict, "VERSION_CONFLICT", "资源版本已变化，请刷新后重试"
		var version *i3core.VersionError
		if errors.As(err, &version) {
			details["current_version"] = version.Current
			w.Header().Set("ETag", store.FormatETag(version.Current))
		}
	} else if errors.Is(err, i3core.ErrConflict) {
		status, code, message = http.StatusConflict, "CONFLICT", "繁育资源当前状态冲突"
	} else {
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) {
			switch pgErr.Code {
			case "23505", "23P01":
				status, code, message = http.StatusConflict, "CONFLICT", "繁育资源当前状态冲突"
			case "23503", "23514", "22P02", "22007":
				status, code, message = http.StatusUnprocessableEntity, "VALIDATION_ERROR", "请求字段或繁育规则校验失败"
			}
		}
	}
	writeJSON(w, r, status, map[string]any{"error": map[string]any{
		"code": code, "message": message, "field_errors": []any{}, "recovery_actions": []any{}, "details": details,
	}, "meta": responseMeta(r)})
}
