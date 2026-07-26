package httpapi

import (
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/scolvpet/scolvpet/api/internal/i4core"
	"github.com/scolvpet/scolvpet/api/internal/store"
)

func (s *Server) registerI4Routes(mux *http.ServeMux) {
	mux.HandleFunc("POST /v1/breeding-plans/{plan_id}/confirm-birth", s.confirmI4Birth)
	mux.HandleFunc("POST /v1/litters/{litter_id}/count-events", s.createI4CountEvent)
	mux.HandleFunc("POST /v1/litters/{litter_id}/wean", s.weanI4Litter)
	mux.HandleFunc("POST /v1/litters/{litter_id}/sex-and-separate", s.sexAndSeparateI4Litter)
	mux.HandleFunc("GET /v1/litters/{litter_id}/individualization-eligibility", s.getI4Eligibility)
	mux.HandleFunc("POST /v1/litters/{litter_id}/individualize", s.individualizeI4Litter)
	mux.HandleFunc("GET /v1/litters/{litter_id}/pup-identities", s.listI4PupIdentities)
}

func (s *Server) i4CoreService() *i4core.Service {
	return i4core.NewService(i4core.NewPostgresRepositoryFromStore(s.Store))
}

func (s *Server) authenticateI4(w http.ResponseWriter, r *http.Request) (uuid.UUID, bool) {
	ownerID, _, ok := s.authenticate(r)
	if !ok {
		writeAPIError(w, r, authRequired())
		return uuid.Nil, false
	}
	return ownerID, true
}

type i4ConfirmBirthRequest struct {
	BornAt              string         `json:"born_at"`
	EnclosureID         *uuid.UUID     `json:"enclosure_id"`
	InitialAliveCount   int            `json:"initial_alive_count"`
	InitialOtherCount   int            `json:"initial_other_count"`
	DamCondition        map[string]any `json:"dam_condition"`
	OutcomeReason       string         `json:"outcome_reason"`
	TemporaryCodePrefix *string        `json:"temporary_code_prefix"`
	TemporaryCodes      []string       `json:"temporary_codes"`
	Notes               *string        `json:"notes"`
	Timezone            string         `json:"timezone"`
}

type i4CountEventRequest struct {
	EventType              string      `json:"event_type"`
	Delta                  int         `json:"delta"`
	OccurredAt             string      `json:"occurred_at"`
	Reason                 string      `json:"reason"`
	NewTemporaryCodes      []string    `json:"new_temporary_codes"`
	AffectedPupIdentityIDs []uuid.UUID `json:"affected_pup_identity_ids"`
}

type i4WeanRequest struct {
	WeanedAt string              `json:"weaned_at"`
	Timezone string              `json:"timezone"`
	Items    []i4WeanItemRequest `json:"items"`
}

type i4WeanItemRequest struct {
	PupIdentityID          uuid.UUID  `json:"pup_identity_id"`
	OutcomeStatus          string     `json:"outcome_status"`
	DestinationEnclosureID *uuid.UUID `json:"destination_enclosure_id"`
	Notes                  *string    `json:"notes"`
}

type i4SexAndSeparateRequest struct {
	SeparatedAt string                    `json:"separated_at"`
	Timezone    string                    `json:"timezone"`
	Items       []i4SexAndSeparateItemReq `json:"items"`
}

type i4SexAndSeparateItemReq struct {
	PupIdentityID          uuid.UUID `json:"pup_identity_id"`
	Sex                    string    `json:"sex"`
	SexConfidence          *float64  `json:"sex_confidence"`
	DestinationEnclosureID uuid.UUID `json:"destination_enclosure_id"`
	RequiresRecheck        bool      `json:"requires_recheck"`
	Notes                  *string   `json:"notes"`
}

type i4IndividualizeRequest struct {
	IndividualizedAt string                   `json:"individualized_at"`
	Timezone         string                   `json:"timezone"`
	EligibleSetToken string                   `json:"eligible_set_token"`
	Items            []i4IndividualizeItemReq `json:"items"`
}

type i4IndividualizeItemReq struct {
	PupIdentityID uuid.UUID `json:"pup_identity_id"`
	InternalCode  string    `json:"internal_code"`
	Name          *string   `json:"name"`
	VarietyCode   *string   `json:"variety_code"`
	Notes         *string   `json:"notes"`
}

func (s *Server) confirmI4Birth(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI4(w, r)
	if !ok {
		return
	}
	planID, err := uuid.Parse(r.PathValue("plan_id"))
	if err != nil || planID == uuid.Nil {
		writeI4Error(w, r, i4core.ErrNotFound)
		return
	}
	var request i4ConfirmBirthRequest
	payload, err := decodeI2Body(r, &request)
	if err != nil {
		writeI4Error(w, r, i4Validation("body", "产仔请求体格式不正确"))
		return
	}
	bornAt, err := time.Parse(time.RFC3339, request.BornAt)
	if err != nil {
		writeI4Error(w, r, i4Validation("born_at", "产仔时间格式不正确"))
		return
	}
	prefix := ""
	if request.TemporaryCodePrefix != nil {
		prefix = *request.TemporaryCodePrefix
	}
	version, err := parseI4IfMatch(r)
	if err != nil {
		writeI4Error(w, r, err)
		return
	}
	result, err := s.i4CoreService().ConfirmBirth(r.Context(), ownerID, planID, i4Options(r, payload), i4core.ConfirmBirthInput{
		ExpectedVersion: version, BornAt: bornAt, EnclosureID: request.EnclosureID, InitialAliveCount: request.InitialAliveCount,
		InitialOtherCount: request.InitialOtherCount, DamCondition: request.DamCondition, OutcomeReason: request.OutcomeReason,
		TemporaryCodePrefix: prefix, TemporaryCodes: request.TemporaryCodes, Notes: request.Notes, Timezone: request.Timezone,
	})
	if err != nil {
		writeI4Error(w, r, err)
		return
	}
	version = result.Value.BreedingPlan.Version
	writeI4Stored(w, r, http.StatusOK, envelope(r, result.Value), result.Replayed, version)
}

func (s *Server) createI4CountEvent(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI4(w, r)
	if !ok {
		return
	}
	litterID, err := uuid.Parse(r.PathValue("litter_id"))
	if err != nil || litterID == uuid.Nil {
		writeI4Error(w, r, i4core.ErrNotFound)
		return
	}
	var request i4CountEventRequest
	payload, err := decodeI2Body(r, &request)
	if err != nil {
		writeI4Error(w, r, i4Validation("body", "数量流水请求体格式不正确"))
		return
	}
	occurredAt, err := time.Parse(time.RFC3339, request.OccurredAt)
	if err != nil {
		writeI4Error(w, r, i4Validation("occurred_at", "发生时间格式不正确"))
		return
	}
	version, err := parseI4IfMatch(r)
	if err != nil {
		writeI4Error(w, r, err)
		return
	}
	result, err := s.i4CoreService().AddCountEvent(r.Context(), ownerID, litterID, i4Options(r, payload), i4core.CountEventInput{ExpectedVersion: version, EventType: request.EventType, Delta: request.Delta, OccurredAt: occurredAt, Reason: request.Reason, NewTemporaryCodes: request.NewTemporaryCodes, AffectedPupIdentityIDs: request.AffectedPupIdentityIDs})
	if err != nil {
		writeI4Error(w, r, err)
		return
	}
	writeI4Stored(w, r, http.StatusOK, envelope(r, result.Value), result.Replayed, result.Value.Litter.Version)
}

func (s *Server) weanI4Litter(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI4(w, r)
	if !ok {
		return
	}
	litterID, err := uuid.Parse(r.PathValue("litter_id"))
	if err != nil || litterID == uuid.Nil {
		writeI4Error(w, r, i4core.ErrNotFound)
		return
	}
	var request i4WeanRequest
	payload, err := decodeI2Body(r, &request)
	if err != nil {
		writeI4Error(w, r, i4Validation("body", "断奶请求体格式不正确"))
		return
	}
	weanedAt, err := time.Parse(time.RFC3339, request.WeanedAt)
	if err != nil {
		writeI4Error(w, r, i4Validation("weaned_at", "断奶时间格式不正确"))
		return
	}
	items := make([]i4core.WeanItem, 0, len(request.Items))
	for _, item := range request.Items {
		items = append(items, i4core.WeanItem{PupIdentityID: item.PupIdentityID, OutcomeStatus: item.OutcomeStatus, DestinationEnclosureID: item.DestinationEnclosureID, Notes: item.Notes})
	}
	version, err := parseI4IfMatch(r)
	if err != nil {
		writeI4Error(w, r, err)
		return
	}
	result, err := s.i4CoreService().Wean(r.Context(), ownerID, litterID, i4Options(r, payload), i4core.WeanInput{ExpectedVersion: version, WeanedAt: weanedAt, Timezone: request.Timezone, Items: items})
	if err != nil {
		writeI4Error(w, r, err)
		return
	}
	writeI4Stored(w, r, http.StatusOK, envelope(r, result.Value), result.Replayed, result.Value.Version)
}

func (s *Server) sexAndSeparateI4Litter(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI4(w, r)
	if !ok {
		return
	}
	litterID, err := uuid.Parse(r.PathValue("litter_id"))
	if err != nil || litterID == uuid.Nil {
		writeI4Error(w, r, i4core.ErrNotFound)
		return
	}
	var request i4SexAndSeparateRequest
	payload, err := decodeI2Body(r, &request)
	if err != nil {
		writeI4Error(w, r, i4Validation("body", "分性分笼请求体格式不正确"))
		return
	}
	separatedAt, err := time.Parse(time.RFC3339, request.SeparatedAt)
	if err != nil {
		writeI4Error(w, r, i4Validation("separated_at", "分笼时间格式不正确"))
		return
	}
	items := make([]i4core.SexAndSeparateItem, 0, len(request.Items))
	for _, item := range request.Items {
		items = append(items, i4core.SexAndSeparateItem{PupIdentityID: item.PupIdentityID, Sex: item.Sex, SexConfidence: item.SexConfidence, DestinationEnclosureID: item.DestinationEnclosureID, RequiresRecheck: item.RequiresRecheck, Notes: item.Notes})
	}
	version, err := parseI4IfMatch(r)
	if err != nil {
		writeI4Error(w, r, err)
		return
	}
	result, err := s.i4CoreService().SexAndSeparate(r.Context(), ownerID, litterID, i4Options(r, payload), i4core.SexAndSeparateInput{ExpectedVersion: version, SeparatedAt: separatedAt, Timezone: request.Timezone, Items: items})
	if err != nil {
		writeI4Error(w, r, err)
		return
	}
	writeI4Stored(w, r, http.StatusOK, envelope(r, result.Value), result.Replayed, result.Value.Version)
}

func (s *Server) getI4Eligibility(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI4(w, r)
	if !ok {
		return
	}
	litterID, err := uuid.Parse(r.PathValue("litter_id"))
	if err != nil || litterID == uuid.Nil {
		writeI4Error(w, r, i4core.ErrNotFound)
		return
	}
	result, err := s.i4CoreService().GetIndividualizationEligibility(r.Context(), ownerID, litterID)
	if err != nil {
		writeI4Error(w, r, err)
		return
	}
	w.Header().Set("ETag", store.FormatETag(result.LitterVersion))
	writeJSON(w, r, http.StatusOK, envelope(r, result))
}

func (s *Server) individualizeI4Litter(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI4(w, r)
	if !ok {
		return
	}
	litterID, err := uuid.Parse(r.PathValue("litter_id"))
	if err != nil || litterID == uuid.Nil {
		writeI4Error(w, r, i4core.ErrNotFound)
		return
	}
	var request i4IndividualizeRequest
	payload, err := decodeI2Body(r, &request)
	if err != nil {
		writeI4Error(w, r, i4Validation("body", "个体化请求体格式不正确"))
		return
	}
	individualizedAt, err := time.Parse(time.RFC3339, request.IndividualizedAt)
	if err != nil {
		writeI4Error(w, r, i4Validation("individualized_at", "个体化时间格式不正确"))
		return
	}
	items := make([]i4core.IndividualizeItem, 0, len(request.Items))
	for _, item := range request.Items {
		items = append(items, i4core.IndividualizeItem{PupIdentityID: item.PupIdentityID, InternalCode: item.InternalCode, Name: item.Name, VarietyCode: item.VarietyCode, Notes: item.Notes})
	}
	version, err := parseI4IfMatch(r)
	if err != nil {
		writeI4Error(w, r, err)
		return
	}
	result, err := s.i4CoreService().Individualize(r.Context(), ownerID, litterID, i4Options(r, payload), i4core.IndividualizeInput{ExpectedVersion: version, IndividualizedAt: individualizedAt, Timezone: request.Timezone, EligibleSetToken: request.EligibleSetToken, Items: items})
	if err != nil {
		writeI4Error(w, r, err)
		return
	}
	writeI4Stored(w, r, http.StatusOK, envelope(r, result.Value), result.Replayed, result.Value.LitterVersion)
}

func (s *Server) listI4PupIdentities(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI4(w, r)
	if !ok {
		return
	}
	litterID, err := uuid.Parse(r.PathValue("litter_id"))
	if err != nil || litterID == uuid.Nil {
		writeI4Error(w, r, i4Validation("litter_id", "窝次 ID 无效"))
		return
	}
	var litterExists bool
	if err := s.Store.Pool.QueryRow(r.Context(), `
		SELECT EXISTS(SELECT 1 FROM litter WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL)
	`, ownerID, litterID).Scan(&litterExists); err != nil {
		writeI4Error(w, r, err)
		return
	}
	if !litterExists {
		writeI4Error(w, r, i4core.ErrNotFound)
		return
	}
	outcome := strings.TrimSpace(r.URL.Query().Get("outcome_status"))
	profile := strings.TrimSpace(r.URL.Query().Get("profile_status"))
	limit := 50
	if raw := strings.TrimSpace(r.URL.Query().Get("limit")); raw != "" {
		if n, err := strconv.Atoi(raw); err == nil && n > 0 {
			limit = n
		}
		if limit > 100 {
			limit = 100
		}
	}
	query := `
		SELECT id, owner_id, litter_id, temporary_code, sex, sex_confidence, profile_status, outcome_status,
		       weaned_at, current_enclosure_id, individualized_hamster_id, phenotype_summary,
		       destination_code, status_reason, version, created_at, updated_at
		FROM pup_identity
		WHERE owner_id=$1 AND litter_id=$2 AND deleted_at IS NULL`
	args := []any{ownerID, litterID}
	argN := 3
	if outcome != "" {
		query += fmt.Sprintf(` AND outcome_status=$%d`, argN)
		args = append(args, outcome)
		argN++
	}
	if profile != "" {
		query += fmt.Sprintf(` AND profile_status=$%d`, argN)
		args = append(args, profile)
		argN++
	}
	query += fmt.Sprintf(` ORDER BY temporary_code, id LIMIT $%d`, argN)
	args = append(args, limit)
	rows, err := s.Store.Pool.Query(r.Context(), query, args...)
	if err != nil {
		writeI4Error(w, r, err)
		return
	}
	defer rows.Close()
	items := make([]any, 0)
	for rows.Next() {
		var (
			id, owner, litter                                                   uuid.UUID
			temporaryCode, sex, profileStatus, outcomeStatus                    string
			sexConfidence                                                       *float64
			weanedAt                                                            *time.Time
			enclosureID, hamsterID                                              *uuid.UUID
			phenotype                                                           []byte
			destination, reason                                                 *string
			version                                                             int
			createdAt, updatedAt                                                time.Time
		)
		if err := rows.Scan(&id, &owner, &litter, &temporaryCode, &sex, &sexConfidence, &profileStatus, &outcomeStatus, &weanedAt, &enclosureID, &hamsterID, &phenotype, &destination, &reason, &version, &createdAt, &updatedAt); err != nil {
			writeI4Error(w, r, err)
			return
		}
		pheno := map[string]any{}
		if len(phenotype) > 0 {
			_ = json.Unmarshal(phenotype, &pheno)
		}
		items = append(items, map[string]any{
			"id": id, "owner_id": owner, "litter_id": litter, "temporary_code": temporaryCode,
			"sex": sex, "sex_confidence": sexConfidence, "profile_status": profileStatus,
			"outcome_status": outcomeStatus, "weaned_at": weanedAt, "current_enclosure_id": enclosureID,
			"hamster_id": hamsterID, "phenotype_summary": pheno, "destination": destination,
			"status_reason": reason, "version": version, "created_at": createdAt, "updated_at": updatedAt,
		})
	}
	if err := rows.Err(); err != nil {
		writeI4Error(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, envelope(r, items))
}

func i4Options(r *http.Request, payload []byte) i4core.WriteOptions {
	return i4core.WriteOptions{IdempotencyKey: r.Header.Get("Idempotency-Key"), RequestMethod: r.Method, RequestPath: r.URL.Path, RequestPayload: payload}
}

func parseI4IfMatch(r *http.Request) (int, error) {
	version, err := store.ParseETag(r.Header.Get("If-Match"))
	if err != nil {
		return 0, i4Validation("If-Match", "If-Match 必须是当前资源版本 ETag")
	}
	return version, nil
}

func writeI4Stored(w http.ResponseWriter, r *http.Request, status int, payload any, replayed bool, version int) {
	w.Header().Set("Idempotency-Key", r.Header.Get("Idempotency-Key"))
	w.Header().Set("Idempotency-Replayed", fmt.Sprintf("%t", replayed))
	if version > 0 {
		w.Header().Set("ETag", store.FormatETag(version))
	}
	writeJSON(w, r, status, payload)
}

func i4Validation(field, message string) error {
	return &apiError{Status: http.StatusUnprocessableEntity, Code: "VALIDATION_ERROR", Message: message, Details: map[string]any{"field": field}}
}

func writeI4Error(w http.ResponseWriter, r *http.Request, err error) {
	status, code, message := http.StatusInternalServerError, "INTERNAL_ERROR", "服务暂时不可用"
	details := map[string]any{}
	var typed *apiError
	if errors.As(err, &typed) {
		status, code, message, details = typed.Status, typed.Code, typed.Message, typed.Details
	} else {
		switch {
		case errors.Is(err, i4core.ErrNotFound):
			status, code, message = http.StatusNotFound, "RESOURCE_NOT_FOUND", "资源不存在"
		case errors.Is(err, i4core.ErrValidation):
			status, code, message = http.StatusUnprocessableEntity, "VALIDATION_ERROR", "请求字段或领域规则校验失败"
		case errors.Is(err, i4core.ErrVersionConflict):
			status, code, message = http.StatusConflict, "VERSION_CONFLICT", "资源版本已变化，请刷新后重试"
		case errors.Is(err, i4core.ErrConflict), errors.Is(err, i4core.ErrEligibilityStale):
			status, code, message = http.StatusConflict, "CONFLICT", "资源状态已变化，请刷新后重试"
		case errors.Is(err, i4core.ErrIdempotencyKeyRequired):
			status, code, message = http.StatusBadRequest, "IDEMPOTENCY_KEY_REQUIRED", "写请求需要幂等键"
		case errors.Is(err, i4core.ErrIdempotencyPayloadMismatch):
			status, code, message = http.StatusConflict, "IDEMPOTENCY_PAYLOAD_MISMATCH", "幂等键对应的载荷不一致"
		case errors.Is(err, i4core.ErrIdempotencyInProgress):
			status, code, message = http.StatusConflict, "IDEMPOTENCY_IN_PROGRESS", "相同写请求正在处理中"
		default:
			if strings.Contains(err.Error(), "current=") {
				status, code, message = http.StatusConflict, "VERSION_CONFLICT", "资源版本已变化，请刷新后重试"
			}
		}
	}
	writeJSON(w, r, status, map[string]any{"error": map[string]any{"code": code, "message": message, "field_errors": []any{}, "recovery_actions": []any{}, "details": details}, "meta": responseMeta(r)})
}
