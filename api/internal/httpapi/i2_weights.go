package httpapi

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strings"

	"github.com/google/uuid"

	"github.com/scolvpet/scolvpet/api/internal/i2core"
)

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
			"client_item_id":    request.Items[index].ClientItemID,
			"status":            status,
			"resource":          i2WeightRecordJSON(record),
			"generated_task_id": nil,
			"error":             nil,
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
