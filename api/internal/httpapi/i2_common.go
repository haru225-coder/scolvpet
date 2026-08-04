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
			var vc versionCarrier
			if errors.As(err, &vc) {
				currentVersion = vc.Version()
			}
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
	phenotype := hamster.Phenotype
	if phenotype == nil {
		phenotype = map[string]any{}
	}
	return map[string]any{
		"id": hamster.ID, "owner_id": hamster.OwnerID, "internal_code": hamster.InternalCode,
		"name": hamster.Name, "species_rule_version_id": hamster.SpeciesRuleVersionID,
		"variety_code": hamster.VarietyCode, "sex": hamster.Sex, "sex_confidence": hamster.SexConfidence,
		"birth_date": i2DatePointer(hamster.BirthDate), "litter_id": nil, "source_type": hamster.SourceType,
		"lifecycle_status": hamster.LifecycleStatus, "breeding_status": hamster.BreedingStatus,
		"current_enclosure_id": hamster.CurrentEnclosureID, "cover_media_id": hamster.CoverMediaID, "notes": hamster.Notes,
		"phenotype": phenotype,
		"version":   hamster.Version, "created_at": hamster.CreatedAt, "updated_at": hamster.UpdatedAt,
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
		"root_hamster_id":  graph.RootHamsterID,
		"nodes":            mapI2Slice(graph.Nodes, i2HamsterJSON),
		"parentages":       mapI2Slice(graph.Parentages, i2PedigreeParentageJSON),
		"litter_parents":   mapI2Slice(graph.LitterParents, i2LitterParentJSON),
		"litter_members":   mapI2Slice(graph.LitterMembers, i2LitterMemberJSON),
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
		"corrects_weight_record_id": record.CorrectsWeightRecordID, "correction_reason": record.CorrectionReason,
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
