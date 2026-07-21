package httpapi

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strings"

	"github.com/google/uuid"

	"github.com/scolvpet/scolvpet/api/internal/i2core"
	"github.com/scolvpet/scolvpet/api/internal/store"
)

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
		"phenotype": true,
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
	if raw, exists := patch["phenotype"]; exists {
		if i2JSONNull(raw) {
			input.Phenotype = map[string]any{}
		} else {
			var value map[string]any
			if json.Unmarshal(raw, &value) != nil {
				writeI2CoreError(w, r, validationError("phenotype", "表型 JSON 格式不正确"))
				return
			}
			input.Phenotype = value
		}
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
	if raw, exists := patch["cover_media_id"]; exists {
		if i2JSONNull(raw) {
			input.ClearCoverMedia = true
		} else {
			var mediaID uuid.UUID
			if json.Unmarshal(raw, &mediaID) != nil || mediaID == uuid.Nil {
				writeI2CoreError(w, r, validationError("cover_media_id", "封面媒体 ID 格式不正确"))
				return
			}
			input.CoverMediaID = &mediaID
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
