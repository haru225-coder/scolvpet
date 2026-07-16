package httpapi

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"sort"
	"strconv"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/scolvpet/scolvpet/api/internal/i2core"
	"github.com/scolvpet/scolvpet/api/internal/store"
)

func (s *Server) registerI2CoreRoutes(mux *http.ServeMux) {
	mux.HandleFunc("GET /v1/hamsters", s.listI2Hamsters)
	mux.HandleFunc("POST /v1/hamsters", s.createI2Hamster)
	mux.HandleFunc("POST /v1/hamsters/batch", s.batchCreateI2Hamsters)
	mux.HandleFunc("GET /v1/hamsters/{hamster_id}", s.getI2Hamster)
	mux.HandleFunc("PATCH /v1/hamsters/{hamster_id}", s.updateI2Hamster)
	mux.HandleFunc("GET /v1/hamsters/{hamster_id}/pedigree", s.getI2HamsterPedigree)

	mux.HandleFunc("GET /v1/pedigree-parentages", s.listI2PedigreeParentages)
	mux.HandleFunc("POST /v1/pedigree-parentages", s.createI2PedigreeParentage)

	mux.HandleFunc("GET /v1/enclosures", s.listI2Enclosures)
	mux.HandleFunc("POST /v1/enclosures", s.createI2Enclosure)
	mux.HandleFunc("GET /v1/enclosures/{enclosure_id}", s.getI2Enclosure)
	mux.HandleFunc("PATCH /v1/enclosures/{enclosure_id}", s.updateI2Enclosure)
	mux.HandleFunc("GET /v1/enclosures/{enclosure_id}/stays", s.listI2EnclosureStays)
	mux.HandleFunc("POST /v1/enclosures/{enclosure_id}/stays", s.createI2EnclosureStay)
	mux.HandleFunc("PATCH /v1/enclosure-stays/{stay_id}", s.updateI2EnclosureStay)
	mux.HandleFunc("GET /v1/enclosures/{enclosure_id}/cleanings", s.listI2EnclosureCleanings)
	mux.HandleFunc("POST /v1/enclosures/{enclosure_id}/cleanings", s.createI2EnclosureCleaning)
	mux.HandleFunc("GET /v1/enclosure-cleanings/{cleaning_id}", s.getI2EnclosureCleaning)

	mux.HandleFunc("GET /v1/litters", s.listI2Litters)
	mux.HandleFunc("GET /v1/litters/{litter_id}", s.getI2Litter)
	mux.HandleFunc("GET /v1/litters/{litter_id}/parents", s.listI2LitterParents)
	mux.HandleFunc("POST /v1/litters/{litter_id}/parents", s.createI2LitterParent)
	mux.HandleFunc("GET /v1/litters/{litter_id}/members", s.listI2LitterMembers)

	mux.HandleFunc("GET /v1/weight-records", s.listI2WeightRecords)
	mux.HandleFunc("POST /v1/weight-records", s.createI2WeightRecord)
	mux.HandleFunc("POST /v1/weight-records/batch", s.batchCreateI2WeightRecords)
}

func (s *Server) i2CoreService() *i2core.Service {
	return i2core.NewService(i2core.NewPostgresRepositoryFromStore(s.Store))
}

func (s *Server) authenticateI2(w http.ResponseWriter, r *http.Request) (uuid.UUID, bool) {
	ownerID, _, ok := s.authenticate(r)
	if !ok {
		writeAPIError(w, r, authRequired())
		return uuid.Nil, false
	}
	return ownerID, true
}

type i2PageRequest struct {
	Limit  int
	Offset int
}

type i2PageInfo struct {
	NextCursor *string `json:"next_cursor"`
	HasMore    bool    `json:"has_more"`
	Count      int     `json:"count"`
}

type i2EnclosureDimensionsRequest struct {
	Length int    `json:"length"`
	Width  int    `json:"width"`
	Height int    `json:"height"`
	Unit   string `json:"unit,omitempty"`
}

type i2HamsterCreateRequest struct {
	InternalCode         string     `json:"internal_code"`
	Name                 *string    `json:"name"`
	SpeciesRuleVersionID uuid.UUID  `json:"species_rule_version_id"`
	VarietyCode          *string    `json:"variety_code"`
	Sex                  string     `json:"sex"`
	SexConfidence        *float64   `json:"sex_confidence"`
	BirthDate            *string    `json:"birth_date"`
	SourceType           string     `json:"source_type"`
	CoverMediaID         *uuid.UUID `json:"cover_media_id"`
	Notes                *string    `json:"notes"`
	SireID               *uuid.UUID `json:"sire_id"`
	DamID                *uuid.UUID `json:"dam_id"`
	LitterID             *uuid.UUID `json:"litter_id"`
}

type i2HamsterBatchItemRequest struct {
	ClientItemID string                   `json:"client_item_id"`
	Hamster      i2HamsterCreateRequest `json:"hamster"`
}

type i2HamsterBatchRequest struct {
	Atomic *bool                       `json:"atomic"`
	Items  []i2HamsterBatchItemRequest `json:"items"`
}

type i2PedigreeParentageCreateRequest struct {
	ChildHamsterID  uuid.UUID `json:"child_hamster_id"`
	ParentHamsterID uuid.UUID `json:"parent_hamster_id"`
	Role            string    `json:"role"`
	EvidenceType    string    `json:"evidence_type"`
	Confidence      float64   `json:"confidence"`
	ValidFrom       string    `json:"valid_from"`
	Notes           *string   `json:"notes"`
}

type i2EnclosureCreateRequest struct {
	Code       string                        `json:"code"`
	RackCode   *string                       `json:"rack_code"`
	LevelCode  *string                       `json:"level_code"`
	Dimensions *i2EnclosureDimensionsRequest `json:"dimensions"`
	Capacity   int                           `json:"capacity"`
	Equipment  []string                      `json:"equipment"`
}

type i2EnclosureStayCreateRequest struct {
	HamsterID       uuid.UUID  `json:"hamster_id"`
	Purpose         string     `json:"purpose"`
	PairingAttemptID *uuid.UUID `json:"pairing_attempt_id"`
	StartedAt       string     `json:"started_at"`
	PreviousStayID  *uuid.UUID `json:"previous_stay_id"`
	Reason          *string    `json:"reason"`
}

type i2EnclosureCleaningCreateRequest struct {
	CleaningType             string         `json:"cleaning_type"`
	PerformedAt              string         `json:"performed_at"`
	Supplies                 map[string]any `json:"supplies"`
	Notes                    *string        `json:"notes"`
	CorrectsCleaningRecordID *uuid.UUID     `json:"corrects_cleaning_record_id"`
	CorrectionReason         *string        `json:"correction_reason"`
}

type i2LitterParentCreateRequest struct {
	HamsterID       uuid.UUID      `json:"hamster_id"`
	Role            string         `json:"role"`
	EvidenceType    string         `json:"evidence_type"`
	EvidencePayload map[string]any `json:"-"`
	Confidence      float64        `json:"confidence"`
	CorrectionReason *string       `json:"correction_reason"`
}

type i2WeightCreateRequest struct {
	HamsterID       *uuid.UUID `json:"hamster_id"`
	PupIdentityID   *uuid.UUID `json:"pup_identity_id"`
	LitterID        *uuid.UUID `json:"litter_id"`
	MeasurementKind string     `json:"measurement_kind"`
	SubjectCount    *int       `json:"subject_count"`
	WeightG         float64    `json:"weight_g"`
	RecordedAt      string     `json:"recorded_at"`
	Source          string     `json:"source"`
	DeviceReadingID *string    `json:"device_reading_id"`
	Notes           *string    `json:"notes"`
}

type i2WeightBatchItemRequest struct {
	ClientItemID string                `json:"client_item_id"`
	Record       i2WeightCreateRequest `json:"record"`
}

type i2WeightBatchRequest struct {
	TaskID json.RawMessage            `json:"task_id"`
	Items  []i2WeightBatchItemRequest `json:"items"`
}

func (s *Server) listI2Hamsters(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	page, err := parseI2Page(r)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	var enclosureID *uuid.UUID
	if value := strings.TrimSpace(r.URL.Query().Get("enclosure_id")); value != "" {
		parsed, parseErr := uuid.Parse(value)
		if parseErr != nil {
			writeI2CoreError(w, r, validationError("enclosure_id", "笼盒 ID 格式不正确"))
			return
		}
		enclosureID = &parsed
	}
	filter := i2core.HamsterFilter{
		Keyword:            strings.TrimSpace(r.URL.Query().Get("q")),
		Sex:                strings.TrimSpace(r.URL.Query().Get("sex")),
		LifecycleStatus:    strings.TrimSpace(r.URL.Query().Get("lifecycle_status")),
		CurrentEnclosureID: enclosureID,
	}
	if len(filter.Keyword) > 100 || filter.Sex != "" && !i2OneOf(filter.Sex, "male", "female", "unknown") ||
		filter.LifecycleStatus != "" && !i2OneOf(filter.LifecycleStatus, "active", "transferred", "retired", "deceased") {
		writeI2CoreError(w, r, validationError("filters", "仓鼠筛选条件格式不正确"))
		return
	}
	service := s.i2CoreService()
	items, pageInfo, err := loadI2Page(page, func(corePage i2core.Page) ([]i2core.Hamster, error) {
		filter.Page = corePage
		return service.ListHamsters(r.Context(), ownerID, filter)
	}, nil)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	writeI2List(w, r, mapI2Slice(items, i2HamsterJSON), pageInfo)
}

func (s *Server) createI2Hamster(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	var request i2HamsterCreateRequest
	payload, err := decodeI2Body(r, &request)
	if err != nil {
		writeI2CoreError(w, r, validationError("body", "仓鼠请求体格式不正确"))
		return
	}
	input, err := request.coreInput()
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	result, err := s.i2CoreService().CreateHamster(r.Context(), ownerID, i2WriteOptions(r, payload), input)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	writeI2Stored(w, r, http.StatusCreated, envelope(r, i2HamsterJSON(result.Value)), result.Replayed,
		store.FormatETag(result.Value.Version), "/v1/hamsters/"+result.Value.ID.String())
}

func (s *Server) batchCreateI2Hamsters(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	var request i2HamsterBatchRequest
	payload, err := decodeI2Body(r, &request)
	if err != nil || request.Atomic == nil || len(request.Items) < 1 || len(request.Items) > 200 {
		writeI2CoreError(w, r, validationError("body", "批量仓鼠请求体格式不正确"))
		return
	}
	inputs := make([]i2core.CreateHamsterInput, 0, len(request.Items))
	seen := make(map[string]struct{}, len(request.Items))
	for index, item := range request.Items {
		item.ClientItemID = strings.TrimSpace(item.ClientItemID)
		if item.ClientItemID == "" || len(item.ClientItemID) > 100 {
			writeI2CoreError(w, r, validationError(fmt.Sprintf("items[%d].client_item_id", index), "客户端项目 ID 格式不正确"))
			return
		}
		if _, exists := seen[item.ClientItemID]; exists {
			writeI2CoreError(w, r, validationError(fmt.Sprintf("items[%d].client_item_id", index), "客户端项目 ID 重复"))
			return
		}
		seen[item.ClientItemID] = struct{}{}
		input, inputErr := item.Hamster.coreInput()
		if inputErr != nil {
			writeI2CoreError(w, r, inputErr)
			return
		}
		inputs = append(inputs, input)
	}
	result, err := s.i2CoreService().BatchCreateHamsters(r.Context(), ownerID, i2WriteOptions(r, payload), i2core.BatchCreateHamstersInput{Hamsters: inputs})
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	responseItems := make([]any, 0, len(result.Value))
	for index, hamster := range result.Value {
		responseItems = append(responseItems, map[string]any{
			"client_item_id": request.Items[index].ClientItemID,
			"status":         "succeeded",
			"resource":       i2HamsterJSON(hamster),
			"error":          nil,
		})
	}
	data := map[string]any{
		"transaction_status": "all_succeeded",
		"succeeded_count":    len(responseItems),
		"failed_count":       0,
		"items":              responseItems,
	}
	writeI2Stored(w, r, http.StatusOK, envelope(r, data), result.Replayed, "", "")
}

func (s *Server) getI2Hamster(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	hamsterID, ok := parseI2PathUUID(w, r, "hamster_id")
	if !ok {
		return
	}
	hamster, err := s.i2CoreService().GetHamster(r.Context(), ownerID, hamsterID)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	w.Header().Set("ETag", store.FormatETag(hamster.Version))
	writeJSON(w, r, http.StatusOK, envelope(r, i2HamsterJSON(hamster)))
}

func (s *Server) updateI2Hamster(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	hamsterID, ok := parseI2PathUUID(w, r, "hamster_id")
	if !ok {
		return
	}
	expectedVersion, err := parseI2IfMatch(r)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	patch, payload, err := decodeI2MergePatch(r, map[string]bool{
		"internal_code": true, "name": true, "variety_code": true, "sex": true,
		"sex_confidence": true, "birth_date": true, "cover_media_id": true, "notes": true,
	})
	if err != nil || len(patch) == 0 {
		writeI2CoreError(w, r, validationError("body", "仓鼠更新请求体格式不正确"))
		return
	}
	input := i2core.UpdateHamsterInput{ExpectedVersion: expectedVersion}
	if raw, exists := patch["internal_code"]; exists {
		value, valueErr := i2PatchString(raw, false)
		if valueErr != nil || strings.TrimSpace(value) == "" || len(value) > 64 {
			writeI2CoreError(w, r, validationError("internal_code", "仓鼠编号格式不正确"))
			return
		}
		input.InternalCode = &value
	}
	if raw, exists := patch["name"]; exists {
		value, isNull, valueErr := i2PatchNullableString(raw, 100)
		if valueErr != nil {
			writeI2CoreError(w, r, validationError("name", "昵称格式不正确"))
			return
		}
		input.ClearName, input.Name = isNull, value
	}
	if raw, exists := patch["variety_code"]; exists {
		value, isNull, valueErr := i2PatchNullableString(raw, 80)
		if valueErr != nil {
			writeI2CoreError(w, r, validationError("variety_code", "品系代码格式不正确"))
			return
		}
		input.ClearVariety, input.VarietyCode = isNull, value
	}
	if raw, exists := patch["sex"]; exists {
		value, valueErr := i2PatchString(raw, false)
		if valueErr != nil || !i2OneOf(value, "male", "female", "unknown") {
			writeI2CoreError(w, r, validationError("sex", "性别取值不正确"))
			return
		}
		input.Sex = &value
	}
	if raw, exists := patch["sex_confidence"]; exists {
		if i2JSONNull(raw) {
			input.ClearSexConfidence = true
		} else {
			var value float64
			if json.Unmarshal(raw, &value) != nil || value < 0 || value > 1 {
				writeI2CoreError(w, r, validationError("sex_confidence", "性别置信度必须在 0 到 1 之间"))
				return
			}
			input.SexConfidence = &value
		}
	}
	if raw, exists := patch["birth_date"]; exists {
		if i2JSONNull(raw) {
			input.ClearBirthDate = true
		} else {
			value, valueErr := i2PatchString(raw, false)
			parsed, parseErr := parseI2Date(value)
			if valueErr != nil || parseErr != nil {
				writeI2CoreError(w, r, validationError("birth_date", "出生日期格式不正确"))
				return
			}
			input.BirthDate = &parsed
		}
	}
	if raw, exists := patch["cover_media_id"]; exists && !i2JSONNull(raw) {
		var ignored uuid.UUID
		if json.Unmarshal(raw, &ignored) != nil || ignored == uuid.Nil {
			writeI2CoreError(w, r, validationError("cover_media_id", "封面媒体 ID 格式不正确"))
			return
		}
	}
	if raw, exists := patch["notes"]; exists {
		value, isNull, valueErr := i2PatchNullableString(raw, 4000)
		if valueErr != nil {
			writeI2CoreError(w, r, validationError("notes", "备注格式不正确"))
			return
		}
		input.ClearNotes, input.Notes = isNull, value
	}
	result, err := s.i2CoreService().UpdateHamster(r.Context(), ownerID, hamsterID, i2WriteOptions(r, payload), input)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	writeI2Stored(w, r, http.StatusOK, envelope(r, i2HamsterJSON(result.Value)), result.Replayed,
		store.FormatETag(result.Value.Version), "")
}

func (s *Server) getI2HamsterPedigree(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	hamsterID, ok := parseI2PathUUID(w, r, "hamster_id")
	if !ok {
		return
	}
	generations := 4
	if value := strings.TrimSpace(r.URL.Query().Get("generations")); value != "" {
		parsed, err := strconv.Atoi(value)
		if err != nil || parsed < 1 || parsed > 8 {
			writeI2CoreError(w, r, validationError("generations", "家谱代数必须在 1 到 8 之间"))
			return
		}
		generations = parsed
	}
	graph, err := s.i2CoreService().GetHamsterPedigree(r.Context(), ownerID, hamsterID, generations)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, envelope(r, i2PedigreeGraphJSON(graph)))
}

func (s *Server) listI2PedigreeParentages(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	page, err := parseI2Page(r)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	childID, err := parseI2OptionalQueryUUID(r, "child_hamster_id")
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	parentID, err := parseI2OptionalQueryUUID(r, "parent_hamster_id")
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	filter := i2core.PedigreeParentageFilter{ChildHamsterID: childID, ParentHamsterID: parentID}
	service := s.i2CoreService()
	items, pageInfo, err := loadI2Page(page, func(corePage i2core.Page) ([]i2core.PedigreeParentage, error) {
		filter.Page = corePage
		return service.ListPedigreeParentages(r.Context(), ownerID, filter)
	}, nil)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	writeI2List(w, r, mapI2Slice(items, i2PedigreeParentageJSON), pageInfo)
}

func (s *Server) createI2PedigreeParentage(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	var request i2PedigreeParentageCreateRequest
	payload, err := decodeI2Body(r, &request)
	if err != nil || request.ParentHamsterID == uuid.Nil || request.ChildHamsterID == uuid.Nil || strings.TrimSpace(request.ValidFrom) == "" {
		writeI2CoreError(w, r, validationError("body", "父母关系请求体格式不正确"))
		return
	}
	validFrom, err := parseI2DateTime(request.ValidFrom)
	if err != nil {
		writeI2CoreError(w, r, validationError("valid_from", "关系生效时间格式不正确"))
		return
	}
	input := i2core.CreatePedigreeParentageInput{
		ParentID: request.ParentHamsterID, ChildID: request.ChildHamsterID, Role: request.Role,
		EvidenceType: request.EvidenceType, Confidence: request.Confidence, ValidFrom: validFrom, Notes: request.Notes,
	}
	result, err := s.i2CoreService().CreatePedigreeParentage(r.Context(), ownerID, i2WriteOptions(r, payload), input)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	writeI2Stored(w, r, http.StatusCreated, envelope(r, i2PedigreeParentageJSON(result.Value)), result.Replayed,
		store.FormatETag(result.Value.Version), "/v1/pedigree-parentages/"+result.Value.ID.String())
}

func (s *Server) listI2Enclosures(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	page, err := parseI2Page(r)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	filter := i2core.EnclosureFilter{
		State:       strings.TrimSpace(r.URL.Query().Get("state")),
		RackCode:    strings.TrimSpace(r.URL.Query().Get("rack_code")),
		Cleanliness: strings.TrimSpace(r.URL.Query().Get("cleanliness_state")),
	}
	if filter.State != "" && !i2OneOf(filter.State, "vacant", "occupied_single", "pairing_temp", "gestation", "dam_with_litter", "isolation", "cleaning_due", "disabled") ||
		filter.Cleanliness != "" && !i2OneOf(filter.Cleanliness, "clean", "partial_due", "full_due") {
		writeI2CoreError(w, r, validationError("filters", "笼盒筛选条件格式不正确"))
		return
	}
	service := s.i2CoreService()
	items, pageInfo, err := loadI2Page(page, func(corePage i2core.Page) ([]i2core.Enclosure, error) {
		filter.Page = corePage
		return service.ListEnclosures(r.Context(), ownerID, filter)
	}, nil)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	writeI2List(w, r, mapI2Slice(items, func(value i2core.Enclosure) any { return i2EnclosureJSON(value, nil, false) }), pageInfo)
}

func (s *Server) createI2Enclosure(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	var request i2EnclosureCreateRequest
	payload, err := decodeI2Body(r, &request)
	if err != nil {
		writeI2CoreError(w, r, validationError("body", "笼盒请求体格式不正确"))
		return
	}
	input, err := request.coreInput()
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	result, err := s.i2CoreService().CreateEnclosure(r.Context(), ownerID, i2WriteOptions(r, payload), input)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	writeI2Stored(w, r, http.StatusCreated, envelope(r, i2EnclosureJSON(result.Value, []i2core.EnclosureStay{}, true)), result.Replayed,
		store.FormatETag(result.Value.Version), "/v1/enclosures/"+result.Value.ID.String())
}

func (s *Server) getI2Enclosure(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	enclosureID, ok := parseI2PathUUID(w, r, "enclosure_id")
	if !ok {
		return
	}
	service := s.i2CoreService()
	enclosure, err := service.GetEnclosure(r.Context(), ownerID, enclosureID)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	stays, err := loadAllI2(func(page i2core.Page) ([]i2core.EnclosureStay, error) {
		return service.ListStayHistory(r.Context(), ownerID, i2core.StayHistoryFilter{EnclosureID: &enclosureID, Page: page})
	})
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	active := make([]i2core.EnclosureStay, 0, len(stays))
	for _, stay := range stays {
		if stay.EndedAt == nil {
			active = append(active, stay)
		}
	}
	w.Header().Set("ETag", store.FormatETag(enclosure.Version))
	writeJSON(w, r, http.StatusOK, envelope(r, i2EnclosureJSON(enclosure, active, true)))
}

func (s *Server) updateI2Enclosure(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	enclosureID, ok := parseI2PathUUID(w, r, "enclosure_id")
	if !ok {
		return
	}
	expectedVersion, err := parseI2IfMatch(r)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	patch, payload, err := decodeI2MergePatch(r, map[string]bool{
		"code": true, "rack_code": true, "level_code": true, "dimensions": true,
		"capacity": true, "equipment": true,
	})
	if err != nil || len(patch) == 0 {
		writeI2CoreError(w, r, validationError("body", "笼盒更新请求体格式不正确"))
		return
	}
	input := i2core.UpdateEnclosureInput{ExpectedVersion: expectedVersion}
	if raw, exists := patch["code"]; exists {
		value, valueErr := i2PatchString(raw, false)
		if valueErr != nil || strings.TrimSpace(value) == "" || len(value) > 64 {
			writeI2CoreError(w, r, validationError("code", "笼盒编号格式不正确"))
			return
		}
		input.Code = &value
	}
	if raw, exists := patch["rack_code"]; exists {
		value, isNull, valueErr := i2PatchNullableString(raw, 64)
		if valueErr != nil {
			writeI2CoreError(w, r, validationError("rack_code", "笼架编号格式不正确"))
			return
		}
		input.ClearRackCode, input.RackCode = isNull, value
	}
	if raw, exists := patch["level_code"]; exists {
		value, isNull, valueErr := i2PatchNullableString(raw, 64)
		if valueErr != nil {
			writeI2CoreError(w, r, validationError("level_code", "层位编号格式不正确"))
			return
		}
		input.ClearLevelCode, input.LevelCode = isNull, value
	}
	if raw, exists := patch["dimensions"]; exists {
		if i2JSONNull(raw) {
			input.Dimensions = map[string]any{}
		} else {
			var dimensions i2EnclosureDimensionsRequest
			if err := decodeI2Raw(raw, &dimensions); err != nil || !dimensions.valid() {
				writeI2CoreError(w, r, validationError("dimensions", "笼盒尺寸格式不正确"))
				return
			}
			input.Dimensions = dimensions.coreMap()
		}
	}
	if raw, exists := patch["capacity"]; exists {
		var capacity int
		if json.Unmarshal(raw, &capacity) != nil || capacity < 1 {
			writeI2CoreError(w, r, validationError("capacity", "笼盒容量必须大于 0"))
			return
		}
		input.Capacity = &capacity
	}
	if raw, exists := patch["equipment"]; exists {
		var equipment []string
		if i2JSONNull(raw) || json.Unmarshal(raw, &equipment) != nil {
			writeI2CoreError(w, r, validationError("equipment", "设施列表格式不正确"))
			return
		}
		input.Equipment = append([]string(nil), equipment...)
	}
	result, err := s.i2CoreService().UpdateEnclosure(r.Context(), ownerID, enclosureID, i2WriteOptions(r, payload), input)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	writeI2Stored(w, r, http.StatusOK, envelope(r, i2EnclosureJSON(result.Value, nil, false)), result.Replayed,
		store.FormatETag(result.Value.Version), "")
}

func (s *Server) listI2EnclosureStays(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	enclosureID, ok := parseI2PathUUID(w, r, "enclosure_id")
	if !ok {
		return
	}
	page, err := parseI2Page(r)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	var active *bool
	if value := strings.TrimSpace(r.URL.Query().Get("active")); value != "" {
		parsed, parseErr := strconv.ParseBool(value)
		if parseErr != nil {
			writeI2CoreError(w, r, validationError("active", "active 必须是布尔值"))
			return
		}
		active = &parsed
	}
	service := s.i2CoreService()
	if _, err := service.GetEnclosure(r.Context(), ownerID, enclosureID); err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	filter := i2core.StayHistoryFilter{EnclosureID: &enclosureID}
	items, pageInfo, err := loadI2Page(page, func(corePage i2core.Page) ([]i2core.EnclosureStay, error) {
		filter.Page = corePage
		return service.ListStayHistory(r.Context(), ownerID, filter)
	}, func(stay i2core.EnclosureStay) bool {
		return active == nil || *active == (stay.EndedAt == nil)
	})
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	writeI2List(w, r, mapI2Slice(items, i2EnclosureStayJSON), pageInfo)
}

func (s *Server) createI2EnclosureStay(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	enclosureID, ok := parseI2PathUUID(w, r, "enclosure_id")
	if !ok {
		return
	}
	expectedVersion, err := parseI2IfMatch(r)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	var request i2EnclosureStayCreateRequest
	payload, err := decodeI2Body(r, &request)
	if err != nil || request.HamsterID == uuid.Nil || strings.TrimSpace(request.StartedAt) == "" {
		writeI2CoreError(w, r, validationError("body", "入住请求体格式不正确"))
		return
	}
	startedAt, err := parseI2DateTime(request.StartedAt)
	if err != nil {
		writeI2CoreError(w, r, validationError("started_at", "入住时间格式不正确"))
		return
	}
	service := s.i2CoreService()
	var result i2core.WriteResult[i2core.StayChange]
	if request.PreviousStayID == nil {
		result, err = service.AdmitHamster(r.Context(), ownerID, i2WriteOptions(r, payload), i2core.AdmitHamsterInput{
			HamsterID: request.HamsterID, EnclosureID: enclosureID, PairingAttemptID: request.PairingAttemptID,
			Purpose: request.Purpose, StartedAt: startedAt, Reason: request.Reason, ExpectedEnclosureVersion: expectedVersion,
		})
	} else {
		result, err = service.MoveHamster(r.Context(), ownerID, i2WriteOptions(r, payload), i2core.MoveHamsterInput{
			StayID: *request.PreviousStayID, TargetEnclosureID: enclosureID, PairingAttemptID: request.PairingAttemptID,
			Purpose: request.Purpose, MovedAt: startedAt, Reason: request.Reason, ExpectedTargetEnclosureVersion: expectedVersion,
		})
	}
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	writeI2Stored(w, r, http.StatusCreated, envelope(r, i2EnclosureStayJSON(result.Value.Stay)), result.Replayed,
		store.FormatETag(result.Value.Stay.Version), "/v1/enclosure-stays/"+result.Value.Stay.ID.String())
}

func (s *Server) updateI2EnclosureStay(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	stayID, ok := parseI2PathUUID(w, r, "stay_id")
	if !ok {
		return
	}
	expectedVersion, err := parseI2IfMatch(r)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	patch, payload, err := decodeI2MergePatch(r, map[string]bool{"ended_at": true, "reason": true, "correction_reason": true})
	if err != nil || len(patch) == 0 {
		writeI2CoreError(w, r, validationError("body", "入住更新请求体格式不正确"))
		return
	}
	rawEndedAt, exists := patch["ended_at"]
	if !exists || i2JSONNull(rawEndedAt) {
		writeI2CoreError(w, r, validationError("ended_at", "当前核心更新需要结束时间"))
		return
	}
	endedAtValue, err := i2PatchString(rawEndedAt, false)
	if err != nil {
		writeI2CoreError(w, r, validationError("ended_at", "结束时间格式不正确"))
		return
	}
	endedAt, err := parseI2DateTime(endedAtValue)
	if err != nil {
		writeI2CoreError(w, r, validationError("ended_at", "结束时间格式不正确"))
		return
	}
	var reason *string
	for _, field := range []string{"correction_reason", "reason"} {
		if raw, exists := patch[field]; exists {
			value, _, valueErr := i2PatchNullableString(raw, 2000)
			if valueErr != nil {
				writeI2CoreError(w, r, validationError(field, "原因格式不正确"))
				return
			}
			if value != nil {
				reason = value
				break
			}
		}
	}
	result, err := s.i2CoreService().EndStay(r.Context(), ownerID, i2WriteOptions(r, payload), i2core.EndStayInput{
		StayID: stayID, EndedAt: endedAt, Reason: reason, ExpectedStayVersion: expectedVersion,
	})
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	writeI2Stored(w, r, http.StatusOK, envelope(r, i2EnclosureStayJSON(result.Value.Stay)), result.Replayed,
		store.FormatETag(result.Value.Stay.Version), "")
}

func (s *Server) listI2EnclosureCleanings(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	enclosureID, ok := parseI2PathUUID(w, r, "enclosure_id")
	if !ok {
		return
	}
	page, err := parseI2Page(r)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	service := s.i2CoreService()
	items, pageInfo, err := loadI2Page(page, func(corePage i2core.Page) ([]i2core.EnclosureCleaning, error) {
		return service.ListEnclosureCleanings(r.Context(), ownerID, enclosureID, corePage)
	}, nil)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	writeI2List(w, r, mapI2Slice(items, i2EnclosureCleaningJSON), pageInfo)
}

func (s *Server) createI2EnclosureCleaning(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	enclosureID, ok := parseI2PathUUID(w, r, "enclosure_id")
	if !ok {
		return
	}
	expectedVersion, err := parseI2IfMatch(r)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	var request i2EnclosureCleaningCreateRequest
	payload, err := decodeI2Body(r, &request)
	if err != nil || strings.TrimSpace(request.PerformedAt) == "" {
		writeI2CoreError(w, r, validationError("body", "清洁记录请求体格式不正确"))
		return
	}
	performedAt, err := parseI2DateTime(request.PerformedAt)
	if err != nil {
		writeI2CoreError(w, r, validationError("performed_at", "清洁时间格式不正确"))
		return
	}
	result, err := s.i2CoreService().CreateEnclosureCleaning(r.Context(), ownerID, i2WriteOptions(r, payload), i2core.CreateEnclosureCleaningInput{
		EnclosureID: enclosureID, CleaningType: request.CleaningType, PerformedAt: performedAt,
		Supplies: request.Supplies, Notes: request.Notes, CorrectsCleaningRecordID: request.CorrectsCleaningRecordID,
		CorrectionReason: request.CorrectionReason, ExpectedEnclosureVersion: expectedVersion,
	})
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	writeI2Stored(w, r, http.StatusCreated, envelope(r, i2EnclosureCleaningJSON(result.Value.Cleaning)), result.Replayed,
		store.FormatETag(result.Value.Enclosure.Version), "/v1/enclosure-cleanings/"+result.Value.Cleaning.ID.String())
}

func (s *Server) getI2EnclosureCleaning(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	cleaningID, ok := parseI2PathUUID(w, r, "cleaning_id")
	if !ok {
		return
	}
	cleaning, err := s.i2CoreService().GetEnclosureCleaning(r.Context(), ownerID, cleaningID)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, envelope(r, i2EnclosureCleaningJSON(cleaning)))
}

func (s *Server) listI2Litters(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	page, err := parseI2Page(r)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	state := strings.TrimSpace(r.URL.Query().Get("state"))
	if state != "" && !i2OneOf(state, "newborn", "nursing", "weaning_due", "sexing_due", "individualizing", "closed", "voided") {
		writeI2CoreError(w, r, validationError("state", "窝次状态取值不正确"))
		return
	}
	bornFrom, err := parseI2OptionalQueryDate(r, "born_from")
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	bornTo, err := parseI2OptionalQueryDate(r, "born_to")
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	if bornFrom != nil && bornTo != nil && bornTo.Before(*bornFrom) {
		writeI2CoreError(w, r, validationError("born_to", "结束日期不得早于开始日期"))
		return
	}
	location, err := i2RequestLocation(r)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	filter := i2core.LitterFilter{State: state}
	service := s.i2CoreService()
	items, pageInfo, err := loadI2Page(page, func(corePage i2core.Page) ([]i2core.Litter, error) {
		filter.Page = corePage
		return service.ListLitters(r.Context(), ownerID, filter)
	}, func(litter i2core.Litter) bool {
		if bornFrom == nil && bornTo == nil {
			return true
		}
		if litter.BornAt == nil {
			return false
		}
		date := i2DateOnly(litter.BornAt.In(location))
		return (bornFrom == nil || !date.Before(*bornFrom)) && (bornTo == nil || !date.After(*bornTo))
	})
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	writeI2List(w, r, mapI2Slice(items, i2LitterJSON), pageInfo)
}

func (s *Server) getI2Litter(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	litterID, ok := parseI2PathUUID(w, r, "litter_id")
	if !ok {
		return
	}
	litter, err := s.i2CoreService().GetLitter(r.Context(), ownerID, litterID)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	w.Header().Set("ETag", store.FormatETag(litter.Version))
	writeJSON(w, r, http.StatusOK, envelope(r, map[string]any{
		"litter":         i2LitterJSON(litter),
		"reconciliation": i2LitterReconciliationJSON(litter),
	}))
}

func (s *Server) listI2LitterParents(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	litterID, ok := parseI2PathUUID(w, r, "litter_id")
	if !ok {
		return
	}
	service := s.i2CoreService()
	items, err := loadAllI2(func(page i2core.Page) ([]i2core.LitterParent, error) {
		return service.ListLitterParents(r.Context(), ownerID, litterID, page)
	})
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, envelope(r, mapI2Slice(items, i2LitterParentJSON)))
}

func (s *Server) createI2LitterParent(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	litterID, ok := parseI2PathUUID(w, r, "litter_id")
	if !ok {
		return
	}
	expectedVersion, err := parseI2IfMatch(r)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	var request i2LitterParentCreateRequest
	payload, err := decodeI2Body(r, &request)
	if err != nil || request.HamsterID == uuid.Nil {
		writeI2CoreError(w, r, validationError("body", "窝次父母请求体格式不正确"))
		return
	}
	result, err := s.i2CoreService().CreateLitterParent(r.Context(), ownerID, i2WriteOptions(r, payload), i2core.CreateLitterParentInput{
		LitterID: litterID, HamsterID: request.HamsterID, Role: request.Role, EvidenceType: request.EvidenceType,
		EvidencePayload: request.EvidencePayload, Confidence: request.Confidence, CorrectionReason: request.CorrectionReason,
		ExpectedLitterVersion: expectedVersion,
	})
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	writeI2Stored(w, r, http.StatusCreated, envelope(r, i2LitterParentJSON(result.Value.Parent)), result.Replayed,
		store.FormatETag(result.Value.Litter.Version), "")
}

func (s *Server) listI2LitterMembers(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	litterID, ok := parseI2PathUUID(w, r, "litter_id")
	if !ok {
		return
	}
	page, err := parseI2Page(r)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	service := s.i2CoreService()
	items, pageInfo, err := loadI2Page(page, func(corePage i2core.Page) ([]i2core.LitterMember, error) {
		return service.ListLitterMembers(r.Context(), ownerID, litterID, corePage)
	}, nil)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	writeI2List(w, r, mapI2Slice(items, i2LitterMemberJSON), pageInfo)
}

func (s *Server) listI2WeightRecords(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	page, err := parseI2Page(r)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	hamsterID, err := parseI2OptionalQueryUUID(r, "hamster_id")
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	pupID, err := parseI2OptionalQueryUUID(r, "pup_identity_id")
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	litterID, err := parseI2OptionalQueryUUID(r, "litter_id")
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	recordedFrom, err := parseI2OptionalQueryDateTime(r, "recorded_from")
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	recordedTo, err := parseI2OptionalQueryDateTime(r, "recorded_to")
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	filter := i2core.WeightRecordFilter{HamsterID: hamsterID, PupIdentityID: pupID, LitterID: litterID, RecordedFrom: recordedFrom, RecordedTo: recordedTo}
	service := s.i2CoreService()
	items, pageInfo, err := loadI2Page(page, func(corePage i2core.Page) ([]i2core.WeightRecord, error) {
		filter.Page = corePage
		return service.ListWeightRecords(r.Context(), ownerID, filter)
	}, nil)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	writeI2List(w, r, mapI2Slice(items, i2WeightRecordJSON), pageInfo)
}

func (s *Server) createI2WeightRecord(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	var request i2WeightCreateRequest
	payload, err := decodeI2Body(r, &request)
	if err != nil {
		writeI2CoreError(w, r, validationError("body", "体重记录请求体格式不正确"))
		return
	}
	input, err := request.coreInput()
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	result, err := s.i2CoreService().CreateWeight(r.Context(), ownerID, i2WriteOptions(r, payload), input)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	writeI2Stored(w, r, http.StatusCreated, envelope(r, i2WeightRecordJSON(result.Value)), result.Replayed, "",
		"/v1/weight-records/"+result.Value.ID.String())
}

func (s *Server) batchCreateI2WeightRecords(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	var request i2WeightBatchRequest
	payload, err := decodeI2Body(r, &request)
	if err != nil || len(request.TaskID) == 0 || len(request.Items) < 1 || len(request.Items) > 200 {
		writeI2CoreError(w, r, validationError("body", "批量体重请求体格式不正确"))
		return
	}
	if !i2JSONNull(request.TaskID) {
		var taskID uuid.UUID
		if json.Unmarshal(request.TaskID, &taskID) != nil || taskID == uuid.Nil {
			writeI2CoreError(w, r, validationError("task_id", "任务 ID 格式不正确"))
			return
		}
	}
	inputs := make([]i2core.CreateWeightInput, 0, len(request.Items))
	seen := make(map[string]struct{}, len(request.Items))
	for index, item := range request.Items {
		item.ClientItemID = strings.TrimSpace(item.ClientItemID)
		if item.ClientItemID == "" || len(item.ClientItemID) > 100 {
			writeI2CoreError(w, r, validationError(fmt.Sprintf("items[%d].client_item_id", index), "客户端项目 ID 格式不正确"))
			return
		}
		if _, exists := seen[item.ClientItemID]; exists {
			writeI2CoreError(w, r, validationError(fmt.Sprintf("items[%d].client_item_id", index), "客户端项目 ID 重复"))
			return
		}
		seen[item.ClientItemID] = struct{}{}
		input, inputErr := item.Record.coreInput()
		if inputErr != nil {
			writeI2CoreError(w, r, inputErr)
			return
		}
		inputs = append(inputs, input)
	}
	result, err := s.i2CoreService().BatchCreateWeights(r.Context(), ownerID, i2WriteOptions(r, payload), i2core.BatchCreateWeightsInput{Records: inputs})
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	alertCount := 0
	responseItems := make([]any, 0, len(result.Value))
	for index, record := range result.Value {
		status := "succeeded"
		if len(record.AlertFlags) > 0 {
			status = "succeeded_with_warning"
			alertCount += len(record.AlertFlags)
		}
		responseItems = append(responseItems, map[string]any{
			"client_item_id":   request.Items[index].ClientItemID,
			"status":           status,
			"resource":         i2WeightRecordJSON(record),
			"generated_task_id": nil,
			"error":            nil,
		})
	}
	data := map[string]any{
		"transaction_status": "all_succeeded",
		"succeeded_count":    len(responseItems),
		"failed_count":       0,
		"alert_count":        alertCount,
		"items":              responseItems,
	}
	writeI2Stored(w, r, http.StatusOK, envelope(r, data), result.Replayed, "", "")
}

func (request i2HamsterCreateRequest) coreInput() (i2core.CreateHamsterInput, error) {
	request.InternalCode = strings.TrimSpace(request.InternalCode)
	if request.InternalCode == "" || len(request.InternalCode) > 64 || request.SpeciesRuleVersionID == uuid.Nil ||
		!i2OneOf(request.Sex, "male", "female", "unknown") || !i2OneOf(request.SourceType, "born_here", "introduced", "customer", "imported") {
		return i2core.CreateHamsterInput{}, validationError("hamster", "仓鼠必填字段或枚举值不正确")
	}
	if request.Name != nil && len(*request.Name) > 100 || request.VarietyCode != nil && len(*request.VarietyCode) > 80 ||
		request.Notes != nil && len(*request.Notes) > 4000 || request.SexConfidence != nil && (*request.SexConfidence < 0 || *request.SexConfidence > 1) {
		return i2core.CreateHamsterInput{}, validationError("hamster", "仓鼠字段长度或范围不正确")
	}
	var birthDate *time.Time
	if request.BirthDate != nil {
		parsed, err := parseI2Date(*request.BirthDate)
		if err != nil {
			return i2core.CreateHamsterInput{}, validationError("birth_date", "出生日期格式不正确")
		}
		birthDate = &parsed
	}
	return i2core.CreateHamsterInput{
		InternalCode: request.InternalCode, Name: request.Name, SpeciesRuleVersionID: request.SpeciesRuleVersionID,
		VarietyCode: request.VarietyCode, Sex: request.Sex, SexConfidence: request.SexConfidence,
		BirthDate: birthDate, SourceType: request.SourceType, Notes: request.Notes,
	}, nil
}

func (request i2EnclosureCreateRequest) coreInput() (i2core.CreateEnclosureInput, error) {
	request.Code = strings.TrimSpace(request.Code)
	if request.Code == "" || len(request.Code) > 64 || request.RackCode != nil && len(*request.RackCode) > 64 ||
		request.LevelCode != nil && len(*request.LevelCode) > 64 || request.Capacity < 0 {
		return i2core.CreateEnclosureInput{}, validationError("enclosure", "笼盒字段格式不正确")
	}
	if request.Dimensions != nil && !request.Dimensions.valid() {
		return i2core.CreateEnclosureInput{}, validationError("dimensions", "笼盒尺寸格式不正确")
	}
	size := map[string]any{}
	if request.Dimensions != nil {
		size = request.Dimensions.coreMap()
	}
	return i2core.CreateEnclosureInput{
		Code: request.Code, RackCode: request.RackCode, LevelCode: request.LevelCode, Capacity: request.Capacity,
		Dimensions: size, Equipment: append([]string(nil), request.Equipment...),
	}, nil
}

func (request i2WeightCreateRequest) coreInput() (i2core.CreateWeightInput, error) {
	recordedAt, err := parseI2DateTime(request.RecordedAt)
	if err != nil {
		return i2core.CreateWeightInput{}, validationError("recorded_at", "称重时间格式不正确")
	}
	measurementKind := strings.TrimSpace(request.MeasurementKind)
	if measurementKind == "" {
		measurementKind = "individual"
	}
	source := strings.TrimSpace(request.Source)
	if source == "" {
		return i2core.CreateWeightInput{}, validationError("source", "称重来源不能为空")
	}
	subjectType := ""
	subjects := 0
	if request.HamsterID != nil {
		subjectType, subjects = "hamster", subjects+1
	}
	if request.PupIdentityID != nil {
		subjectType, subjects = "pup_identity", subjects+1
	}
	if request.LitterID != nil {
		subjectType, subjects = "litter", subjects+1
	}
	if subjects != 1 || request.Notes != nil && len(*request.Notes) > 1000 {
		return i2core.CreateWeightInput{}, i2core.ErrInvalidWeight
	}
	return i2core.CreateWeightInput{
		SubjectType: subjectType, HamsterID: request.HamsterID, PupIdentityID: request.PupIdentityID, LitterID: request.LitterID,
		MeasurementKind: measurementKind, SubjectCount: request.SubjectCount, WeightG: request.WeightG,
		RecordedAt: recordedAt, Source: source, AcquisitionKey: request.DeviceReadingID,
	}, nil
}

func (dimensions i2EnclosureDimensionsRequest) valid() bool {
	return dimensions.Length > 0 && dimensions.Width > 0 && dimensions.Height > 0 && (dimensions.Unit == "" || dimensions.Unit == "mm")
}

func (dimensions i2EnclosureDimensionsRequest) coreMap() map[string]any {
	return map[string]any{"length": dimensions.Length, "width": dimensions.Width, "height": dimensions.Height, "unit": "mm"}
}

func decodeI2Body(r *http.Request, target any) ([]byte, error) {
	payload, err := io.ReadAll(r.Body)
	if err != nil || len(bytes.TrimSpace(payload)) == 0 {
		return nil, errors.New("empty request body")
	}
	decoder := json.NewDecoder(bytes.NewReader(payload))
	decoder.DisallowUnknownFields()
	if err := decoder.Decode(target); err != nil {
		return nil, err
	}
	if err := decoder.Decode(&struct{}{}); !errors.Is(err, io.EOF) {
		if err == nil {
			return nil, errors.New("multiple JSON values")
		}
		return nil, err
	}
	return payload, nil
}

func decodeI2Raw(raw json.RawMessage, target any) error {
	decoder := json.NewDecoder(bytes.NewReader(raw))
	decoder.DisallowUnknownFields()
	if err := decoder.Decode(target); err != nil {
		return err
	}
	if err := decoder.Decode(&struct{}{}); !errors.Is(err, io.EOF) {
		return errors.New("invalid JSON value")
	}
	return nil
}

func decodeI2MergePatch(r *http.Request, allowed map[string]bool) (map[string]json.RawMessage, []byte, error) {
	var patch map[string]json.RawMessage
	payload, err := decodeI2Body(r, &patch)
	if err != nil || patch == nil {
		return nil, nil, errors.New("invalid merge patch")
	}
	for field := range patch {
		if !allowed[field] {
			return nil, nil, fmt.Errorf("unknown field %q", field)
		}
	}
	return patch, payload, nil
}

func i2WriteOptions(r *http.Request, payload []byte) i2core.WriteOptions {
	return i2core.WriteOptions{
		IdempotencyKey: r.Header.Get("Idempotency-Key"), RequestMethod: r.Method,
		RequestPath: r.URL.Path, RequestPayload: payload,
	}
}

func parseI2PathUUID(w http.ResponseWriter, r *http.Request, name string) (uuid.UUID, bool) {
	value, err := uuid.Parse(r.PathValue(name))
	if err != nil || value == uuid.Nil {
		writeI2CoreError(w, r, i2core.ErrNotFound)
		return uuid.Nil, false
	}
	return value, true
}

func parseI2IfMatch(r *http.Request) (int, error) {
	version, err := store.ParseETag(r.Header.Get("If-Match"))
	if err != nil {
		return 0, validationError("If-Match", "If-Match 必须是当前资源版本 ETag")
	}
	return version, nil
}

func parseI2Page(r *http.Request) (i2PageRequest, error) {
	result := i2PageRequest{Limit: 50}
	if value := strings.TrimSpace(r.URL.Query().Get("limit")); value != "" {
		limit, err := strconv.Atoi(value)
		if err != nil || limit < 1 || limit > 200 {
			return i2PageRequest{}, validationError("limit", "limit 必须在 1 到 200 之间")
		}
		result.Limit = limit
	}
	if value := strings.TrimSpace(r.URL.Query().Get("cursor")); value != "" {
		offset, err := decodeI2Cursor(value)
		if err != nil {
			return i2PageRequest{}, validationError("cursor", "cursor 格式不正确")
		}
		result.Offset = offset
	}
	return result, nil
}

func encodeI2Cursor(offset int) string {
	return base64.RawURLEncoding.EncodeToString([]byte(fmt.Sprintf("offset:%d", offset)))
}

func decodeI2Cursor(value string) (int, error) {
	decoded, err := base64.RawURLEncoding.DecodeString(value)
	if err != nil || !strings.HasPrefix(string(decoded), "offset:") {
		return 0, errors.New("invalid cursor")
	}
	offset, err := strconv.Atoi(strings.TrimPrefix(string(decoded), "offset:"))
	if err != nil || offset < 0 {
		return 0, errors.New("invalid cursor")
	}
	return offset, nil
}

func loadI2Page[T any](request i2PageRequest, loader func(i2core.Page) ([]T, error), keep func(T) bool) ([]T, i2PageInfo, error) {
	if keep == nil {
		keep = func(T) bool { return true }
	}
	items := make([]T, 0, request.Limit+1)
	rawOffset := request.Offset
	nextOffset := 0
	for {
		chunk, err := loader(i2core.Page{Limit: 200, Offset: rawOffset})
		if err != nil {
			return nil, i2PageInfo{}, err
		}
		if len(chunk) == 0 {
			break
		}
		for _, item := range chunk {
			rawOffset++
			if !keep(item) {
				continue
			}
			items = append(items, item)
			if len(items) == request.Limit {
				nextOffset = rawOffset
			}
			if len(items) > request.Limit {
				cursor := encodeI2Cursor(nextOffset)
				return items[:request.Limit], i2PageInfo{NextCursor: &cursor, HasMore: true, Count: request.Limit}, nil
			}
		}
		if len(chunk) < 200 {
			break
		}
	}
	return items, i2PageInfo{HasMore: false, Count: len(items)}, nil
}

func loadAllI2[T any](loader func(i2core.Page) ([]T, error)) ([]T, error) {
	result := make([]T, 0)
	for offset := 0; ; offset += 200 {
		chunk, err := loader(i2core.Page{Limit: 200, Offset: offset})
		if err != nil {
			return nil, err
		}
		result = append(result, chunk...)
		if len(chunk) < 200 {
			return result, nil
		}
	}
}

func parseI2OptionalQueryUUID(r *http.Request, name string) (*uuid.UUID, error) {
	value := strings.TrimSpace(r.URL.Query().Get(name))
	if value == "" {
		return nil, nil
	}
	parsed, err := uuid.Parse(value)
	if err != nil || parsed == uuid.Nil {
		return nil, validationError(name, name+" 格式不正确")
	}
	return &parsed, nil
}

func parseI2OptionalQueryDate(r *http.Request, name string) (*time.Time, error) {
	value := strings.TrimSpace(r.URL.Query().Get(name))
	if value == "" {
		return nil, nil
	}
	parsed, err := parseI2Date(value)
	if err != nil {
		return nil, validationError(name, name+" 格式不正确")
	}
	return &parsed, nil
}

func parseI2OptionalQueryDateTime(r *http.Request, name string) (*time.Time, error) {
	value := strings.TrimSpace(r.URL.Query().Get(name))
	if value == "" {
		return nil, nil
	}
	parsed, err := parseI2DateTime(value)
	if err != nil {
		return nil, validationError(name, name+" 格式不正确")
	}
	return &parsed, nil
}

func parseI2Date(value string) (time.Time, error) {
	parsed, err := time.Parse("2006-01-02", strings.TrimSpace(value))
	if err != nil {
		return time.Time{}, err
	}
	return parsed.UTC(), nil
}

func parseI2DateTime(value string) (time.Time, error) {
	parsed, err := time.Parse(time.RFC3339, strings.TrimSpace(value))
	if err != nil {
		return time.Time{}, err
	}
	return parsed.UTC(), nil
}

func i2RequestLocation(r *http.Request) (*time.Location, error) {
	name := strings.TrimSpace(r.Header.Get("X-Timezone"))
	if name == "" {
		name = "Asia/Shanghai"
	}
	location, err := time.LoadLocation(name)
	if err != nil {
		return nil, validationError("X-Timezone", "时区格式不正确")
	}
	return location, nil
}

func i2PatchString(raw json.RawMessage, nullable bool) (string, error) {
	if i2JSONNull(raw) {
		if nullable {
			return "", nil
		}
		return "", errors.New("null is not allowed")
	}
	var value string
	if json.Unmarshal(raw, &value) != nil {
		return "", errors.New("not a string")
	}
	return value, nil
}

func i2PatchNullableString(raw json.RawMessage, maxLength int) (*string, bool, error) {
	if i2JSONNull(raw) {
		return nil, true, nil
	}
	var value string
	if json.Unmarshal(raw, &value) != nil || len(value) > maxLength {
		return nil, false, errors.New("invalid nullable string")
	}
	return &value, false, nil
}

func i2JSONNull(raw json.RawMessage) bool {
	return bytes.Equal(bytes.TrimSpace(raw), []byte("null"))
}

func i2OneOf(value string, allowed ...string) bool {
	for _, candidate := range allowed {
		if value == candidate {
			return true
		}
	}
	return false
}

func writeI2Stored(w http.ResponseWriter, r *http.Request, status int, payload any, replayed bool, etag, location string) {
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

func writeI2List(w http.ResponseWriter, r *http.Request, data []any, page i2PageInfo) {
	writeJSON(w, r, http.StatusOK, map[string]any{"data": data, "page": page, "meta": responseMeta(r)})
}

func writeI2CoreError(w http.ResponseWriter, r *http.Request, err error) {
	status, code, message := http.StatusInternalServerError, "INTERNAL_ERROR", "服务暂时不可用"
	fieldErrors := []any{}
	recoveryActions := []any{}
	details := map[string]any{}
	currentVersion := 0

	var typed *apiError
	if errors.As(err, &typed) {
		status, code, message = typed.Status, typed.Code, typed.Message
		for key, value := range typed.Details {
			details[key] = value
		}
		if field, ok := typed.Details["field"].(string); ok && field != "" {
			fieldErrors = append(fieldErrors, map[string]any{"field": field, "code": "invalid", "message": typed.Message})
		}
	} else {
		switch {
		case errors.Is(err, i2core.ErrNotFound):
			status, code, message = http.StatusNotFound, "RESOURCE_NOT_FOUND", "未找到指定资源"
		case errors.Is(err, i2core.ErrValidation):
			status, code, message = http.StatusUnprocessableEntity, "VALIDATION_ERROR", "请求字段或领域规则校验失败"
		case errors.Is(err, i2core.ErrDuplicate):
			status, code, message = http.StatusConflict, "DUPLICATE_RESOURCE", "资源已存在"
		case errors.Is(err, i2core.ErrVersionConflict):
			status, code, message = http.StatusConflict, "VERSION_CONFLICT", "资源已被其他操作更新"
			currentVersion = extractCurrentVersion(err.Error())
			if currentVersion > 0 {
				w.Header().Set("ETag", store.FormatETag(currentVersion))
				details["current_version"] = currentVersion
			}
		case errors.Is(err, i2core.ErrIdempotencyKeyRequired):
			status, code, message = http.StatusBadRequest, "IDEMPOTENCY_KEY_REQUIRED", "写请求需要幂等键"
		case errors.Is(err, i2core.ErrIdempotencyPayloadMismatch):
			status, code, message = http.StatusConflict, "IDEMPOTENCY_PAYLOAD_MISMATCH", "幂等键对应的载荷不一致"
		case errors.Is(err, i2core.ErrIdempotencyInProgress):
			status, code, message = http.StatusConflict, "IDEMPOTENCY_IN_PROGRESS", "相同写请求正在处理中"
		case errors.Is(err, i2core.ErrStayConflict):
			status, code, message = http.StatusConflict, "CAGE_CONFLICT", "目标笼盒在指定时段不可用"
		case errors.Is(err, i2core.ErrInvalidWeight):
			status, code, message = http.StatusUnprocessableEntity, "INVALID_WEIGHT", "体重记录的对象、克值或采集信息不正确"
		case errors.Is(err, i2core.ErrPedigreeCycle):
			status, code, message = http.StatusUnprocessableEntity, "PEDIGREE_CYCLE", "父母关系会形成祖先循环"
		default:
			writeAPIError(w, r, err)
			return
		}
	}
	errorObject := map[string]any{
		"code": code, "message": message, "field_errors": fieldErrors,
		"recovery_actions": recoveryActions, "details": details,
	}
	if currentVersion > 0 {
		errorObject["current_version"] = currentVersion
	}
	writeJSON(w, r, status, map[string]any{"error": errorObject, "meta": responseMeta(r)})
}

func mapI2Slice[T any](values []T, mapper func(T) any) []any {
	result := make([]any, 0, len(values))
	for _, value := range values {
		result = append(result, mapper(value))
	}
	return result
}

func i2HamsterJSON(hamster i2core.Hamster) any {
	return map[string]any{
		"id": hamster.ID, "owner_id": hamster.OwnerID, "internal_code": hamster.InternalCode,
		"name": hamster.Name, "species_rule_version_id": hamster.SpeciesRuleVersionID,
		"variety_code": hamster.VarietyCode, "sex": hamster.Sex, "sex_confidence": hamster.SexConfidence,
		"birth_date": i2DatePointer(hamster.BirthDate), "litter_id": nil, "source_type": hamster.SourceType,
		"lifecycle_status": hamster.LifecycleStatus, "breeding_status": hamster.BreedingStatus,
		"current_enclosure_id": hamster.CurrentEnclosureID, "cover_media_id": nil, "notes": hamster.Notes,
		"version": hamster.Version, "created_at": hamster.CreatedAt, "updated_at": hamster.UpdatedAt,
	}
}

func i2PedigreeParentageJSON(parentage i2core.PedigreeParentage) any {
	return map[string]any{
		"id": parentage.ID, "owner_id": parentage.OwnerID, "child_hamster_id": parentage.ChildID,
		"parent_hamster_id": parentage.ParentID, "role": parentage.Role, "evidence_type": parentage.EvidenceType,
		"confidence": parentage.Confidence, "valid_from": parentage.ValidFrom, "valid_to": parentage.ValidTo,
		"notes": parentage.Notes, "version": parentage.Version, "created_at": parentage.CreatedAt,
	}
}

func i2LitterParentJSON(parent i2core.LitterParent) any {
	return map[string]any{
		"id": parent.ID, "litter_id": parent.LitterID, "hamster_id": parent.ParentID, "role": parent.Role,
		"evidence_type": parent.EvidenceType, "confidence": parent.Confidence, "version": parent.Version,
		"created_at": parent.CreatedAt,
	}
}

func i2LitterMemberJSON(member i2core.LitterMember) any {
	return map[string]any{
		"id": member.ID, "litter_id": member.LitterID, "member_type": member.MemberType,
		"pup_identity_id": member.PupIdentityID, "hamster_id": member.HamsterID, "role": "offspring",
		"joined_at": member.ValidFrom, "left_at": member.ValidTo, "version": member.Version,
	}
}

func i2PedigreeGraphJSON(graph i2core.PedigreeGraph) any {
	common := make([]any, 0, len(graph.CommonAncestors))
	for _, ancestor := range graph.CommonAncestors {
		common = append(common, map[string]any{
			"hamster_id": ancestor.HamsterID, "paths": ancestor.Paths, "minimum_generation": ancestor.MinimumGeneration,
		})
	}
	return map[string]any{
		"root_hamster_id": graph.RootHamsterID,
		"nodes":           mapI2Slice(graph.Nodes, i2HamsterJSON),
		"parentages":      mapI2Slice(graph.Parentages, i2PedigreeParentageJSON),
		"litter_parents":  mapI2Slice(graph.LitterParents, i2LitterParentJSON),
		"litter_members":  mapI2Slice(graph.LitterMembers, i2LitterMemberJSON),
		"common_ancestors": common,
	}
}

func i2EnclosureJSON(enclosure i2core.Enclosure, stays []i2core.EnclosureStay, includeStays bool) any {
	result := map[string]any{
		"id": enclosure.ID, "owner_id": enclosure.OwnerID, "code": enclosure.Code,
		"rack_code": enclosure.RackCode, "level_code": enclosure.LevelCode,
		"dimensions": i2DimensionsJSON(enclosure.Dimensions), "state": enclosure.State,
		"cleanliness_state": enclosure.Cleanliness, "capacity": enclosure.Capacity,
		"equipment": i2EquipmentJSON(enclosure.Equipment), "last_cleaned_at": enclosure.LastCleanedAt,
		"version": enclosure.Version, "created_at": enclosure.CreatedAt, "updated_at": enclosure.UpdatedAt,
	}
	if includeStays {
		result["current_stays"] = mapI2Slice(stays, i2EnclosureStayJSON)
	}
	return result
}

func i2EnclosureStayJSON(stay i2core.EnclosureStay) any {
	return map[string]any{
		"id": stay.ID, "enclosure_id": stay.EnclosureID, "hamster_id": stay.HamsterID,
		"purpose": stay.Purpose, "pairing_attempt_id": stay.PairingAttemptID, "started_at": stay.StartedAt,
		"ended_at": stay.EndedAt, "reason": stay.Reason, "version": stay.Version,
	}
}

func i2EnclosureCleaningJSON(cleaning i2core.EnclosureCleaning) any {
	supplies := cleaning.Supplies
	if supplies == nil {
		supplies = map[string]any{}
	}
	return map[string]any{
		"id": cleaning.ID, "enclosure_id": cleaning.EnclosureID, "cleaning_type": cleaning.CleaningType,
		"performed_at": cleaning.PerformedAt, "supplies": supplies, "notes": cleaning.Notes,
		"corrects_cleaning_record_id": cleaning.CorrectsCleaningRecordID, "correction_reason": cleaning.CorrectionReason,
		"created_at": cleaning.CreatedAt,
	}
}

func i2LitterJSON(litter i2core.Litter) any {
	damCondition := litter.DamCondition
	if damCondition == nil {
		damCondition = map[string]any{}
	}
	return map[string]any{
		"id": litter.ID, "owner_id": litter.OwnerID, "origin": litter.Origin, "code": litter.Code,
		"breeding_plan_id": litter.BreedingPlanID, "sire_id": litter.SireID, "dam_id": litter.DamID,
		"born_at": litter.BornAt, "initial_alive_count": litter.InitialAliveCount,
		"initial_other_count": litter.InitialOtherCount, "current_managed_count": litter.CurrentManagedCount,
		"state": litter.State, "enclosure_id": litter.EnclosureID, "dam_condition": damCondition,
		"weaned_at": litter.WeanedAt, "sex_separated_at": litter.SexSeparatedAt,
		"reconciled_at": litter.ReconciledAt, "notes": litter.Notes, "version": litter.Version,
		"created_at": litter.CreatedAt, "updated_at": litter.UpdatedAt,
	}
}

func i2LitterReconciliationJSON(litter i2core.Litter) any {
	expected := litter.InitialAliveCount + litter.DiscoveredCount - litter.DeceasedCount - litter.TransferredOutCount + litter.CorrectionDelta
	difference := expected - litter.UnindividualizedAliveCount - litter.IndividualizedAliveCount
	return map[string]any{
		"initial_alive_count": litter.InitialAliveCount, "discovered_count": litter.DiscoveredCount,
		"deceased_count": litter.DeceasedCount, "transferred_count": litter.TransferredOutCount,
		"expected_managed_count": expected, "unindividualized_alive_count": litter.UnindividualizedAliveCount,
		"individualized_alive_count": litter.IndividualizedAliveCount, "difference": difference,
		"closed": difference == 0 && (litter.State == "closed" || litter.ReconciledAt != nil),
	}
}

func i2WeightRecordJSON(record i2core.WeightRecord) any {
	alerts := record.AlertFlags
	if alerts == nil {
		alerts = []string{}
	}
	return map[string]any{
		"id": record.ID, "hamster_id": record.HamsterID, "pup_identity_id": record.PupIdentityID,
		"litter_id": record.LitterID, "measurement_kind": record.MeasurementKind,
		"subject_count": record.SubjectCount, "weight_g": record.WeightG, "recorded_at": record.RecordedAt,
		"source": record.Source, "birth_weight_g": record.BirthWeightG, "previous_weight_g": record.PreviousWeightG,
		"change_from_previous_g": record.ChangeFromPreviousG, "change_from_birth_g": record.ChangeFromBirthG,
		"alert_flags": alerts, "notes": nil, "created_at": record.CreatedAt,
	}
}

func i2DatePointer(value *time.Time) any {
	if value == nil {
		return nil
	}
	return value.UTC().Format("2006-01-02")
}

func i2DateOnly(value time.Time) time.Time {
	year, month, day := value.Date()
	return time.Date(year, month, day, 0, 0, 0, 0, time.UTC)
}

func i2DimensionsJSON(values map[string]any) any {
	length, lengthOK := i2MapInt(values, "length")
	width, widthOK := i2MapInt(values, "width")
	height, heightOK := i2MapInt(values, "height")
	if !lengthOK || !widthOK || !heightOK || length < 1 || width < 1 || height < 1 {
		return nil
	}
	return map[string]any{"length": length, "width": width, "height": height, "unit": "mm"}
}

func i2MapInt(values map[string]any, key string) (int, bool) {
	value, ok := values[key]
	if !ok {
		return 0, false
	}
	switch typed := value.(type) {
	case int:
		return typed, true
	case int32:
		return int(typed), true
	case int64:
		return int(typed), true
	case float64:
		return int(typed), typed == float64(int(typed))
	case json.Number:
		parsed, err := strconv.Atoi(typed.String())
		return parsed, err == nil
	default:
		return 0, false
	}
}

func i2EquipmentJSON(values []string) []string {
	if values == nil {
		return []string{}
	}
	result := append([]string(nil), values...)
	sort.Strings(result)
	return result
}
