package httpapi

import (
	"encoding/json"
	"net/http"
	"strconv"
	"strings"

	"github.com/google/uuid"

	"github.com/scolvpet/scolvpet/api/internal/i2core"
	"github.com/scolvpet/scolvpet/api/internal/store"
)

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
