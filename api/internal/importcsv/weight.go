package importcsv

import (
	"fmt"
	"strings"
	"time"
)

type weightInput struct {
	row             ParsedRow
	subjectType     string
	hamsterCode     string
	hamsterID       string
	litterCode      string
	litterID        string
	measurementKind string
	subjectCount    int
	weightG         string
	recordedAt      *time.Time
	acquisitionKey  string
	resourceID      string
	skipExistingID  string
}

func (state *preflightState) preflightWeights() {
	hamstersByCode := make(map[string][]HamsterRecord)
	for _, hamster := range state.snapshot.Hamsters {
		if hamster.OwnerID == state.request.OwnerID {
			hamstersByCode[hamster.InternalCode] = append(hamstersByCode[hamster.InternalCode], hamster)
		}
	}
	littersByCode := make(map[string][]LitterRecord)
	for _, litter := range state.snapshot.Litters {
		if litter.OwnerID == state.request.OwnerID {
			littersByCode[litter.Code] = append(littersByCode[litter.Code], litter)
		}
	}
	inputs := make([]*weightInput, 0, len(state.request.File.Rows))
	keys := make(map[string][]*weightInput)
	for _, row := range state.request.File.Rows {
		input := &weightInput{
			row:             row,
			subjectType:     strings.TrimSpace(row.Mapped["subject_type"]),
			hamsterCode:     strings.TrimSpace(row.Mapped["hamster_code"]),
			litterCode:      strings.TrimSpace(row.Mapped["litter_code"]),
			measurementKind: strings.TrimSpace(row.Mapped["measurement_kind"]),
			acquisitionKey:  strings.TrimSpace(row.Mapped["acquisition_key"]),
		}
		if input.subjectType == "" {
			switch {
			case input.hamsterCode != "" && input.litterCode == "":
				input.subjectType = "hamster"
			case input.litterCode != "" && input.hamsterCode == "":
				input.subjectType = "litter"
			}
		}
		state.setMappedValue(row.RowNumber, "subject_type", input.subjectType)
		switch input.subjectType {
		case "hamster":
			if input.hamsterCode == "" {
				state.addRowIssue(row.RowNumber, "hamster_code", "HAMSTER_REQUIRED", "hamster 称重必须填写仓鼠编号", SeverityBlocking, nil, "填写 owner 范围内仓鼠编号")
			} else {
				matches := hamstersByCode[input.hamsterCode]
				switch len(matches) {
				case 0:
					state.addRowIssue(row.RowNumber, "hamster_code", "HAMSTER_NOT_FOUND", "owner 范围内未找到仓鼠编号", SeverityBlocking, input.hamsterCode, "先导入仓鼠或修正编号")
				case 1:
					input.hamsterID = matches[0].ID
				default:
					state.addRowIssue(row.RowNumber, "hamster_code", "HAMSTER_REFERENCE_AMBIGUOUS", "owner 范围内仓鼠编号不唯一", SeverityBlocking, input.hamsterCode, "先合并重复编号记录")
				}
			}
			if input.litterCode != "" {
				state.addRowIssue(row.RowNumber, "litter_code", "WEIGHT_SUBJECT_CONFLICT", "hamster 称重不可同时填写 litter_code", SeverityBlocking, input.litterCode, "只保留 hamster_code")
			}
			if input.measurementKind == "" {
				input.measurementKind = "individual"
			}
			if input.measurementKind != "individual" {
				state.addRowIssue(row.RowNumber, "measurement_kind", "INVALID_MEASUREMENT_KIND", "hamster 称重必须使用 individual", SeverityBlocking, input.measurementKind, "填写 individual")
			}
			if row.Mapped["subject_count"] != "" {
				state.addRowIssue(row.RowNumber, "subject_count", "SUBJECT_COUNT_NOT_ALLOWED", "individual 称重不填写 subject_count", SeverityBlocking, row.Mapped["subject_count"], "清空该字段")
			}
		case "litter":
			if input.litterCode == "" {
				state.addRowIssue(row.RowNumber, "litter_code", "LITTER_REQUIRED", "litter 称重必须填写窝次编号", SeverityBlocking, nil, "填写 owner 范围内窝次编号")
			} else {
				matches := littersByCode[input.litterCode]
				switch len(matches) {
				case 0:
					state.addRowIssue(row.RowNumber, "litter_code", "LITTER_NOT_FOUND", "owner 范围内未找到窝次编号", SeverityBlocking, input.litterCode, "先导入窝次或修正编号")
				case 1:
					input.litterID = matches[0].ID
				default:
					state.addRowIssue(row.RowNumber, "litter_code", "LITTER_REFERENCE_AMBIGUOUS", "owner 范围内窝次编号不唯一", SeverityBlocking, input.litterCode, "先合并重复编号记录")
				}
			}
			if input.hamsterCode != "" {
				state.addRowIssue(row.RowNumber, "hamster_code", "WEIGHT_SUBJECT_CONFLICT", "litter 称重不可同时填写 hamster_code", SeverityBlocking, input.hamsterCode, "只保留 litter_code")
			}
			if input.measurementKind == "" {
				input.measurementKind = "litter_total"
			}
			if !validEnum(input.measurementKind, "litter_total", "litter_average") {
				state.addRowIssue(row.RowNumber, "measurement_kind", "INVALID_MEASUREMENT_KIND", "litter 称重只支持 litter_total 或 litter_average", SeverityBlocking, input.measurementKind, "填写 litter_total 或 litter_average")
			}
			count, err := parsePositiveInt(row.Mapped["subject_count"], 0)
			if err != nil || count == 0 {
				state.addRowIssue(row.RowNumber, "subject_count", "INVALID_SUBJECT_COUNT", "litter 称重必须填写大于 0 的个体数量", SeverityBlocking, row.Mapped["subject_count"], "填写本次称重包含的只数")
			} else {
				input.subjectCount = count
				state.setMappedValue(row.RowNumber, "subject_count", count)
			}
		default:
			state.addRowIssue(row.RowNumber, "subject_type", "INVALID_WEIGHT_SUBJECT", "称重对象必须是 hamster 或 litter", SeverityBlocking, input.subjectType, "填写 subject_type，或只填写一种对象编号")
		}
		state.setMappedValue(row.RowNumber, "measurement_kind", input.measurementKind)
		if row.Mapped["weight_g"] != "" {
			weight, err := normalizeDecimal(row.Mapped["weight_g"])
			if err != nil {
				state.addRowIssue(row.RowNumber, "weight_g", "INVALID_WEIGHT", err.Error(), SeverityBlocking, row.Mapped["weight_g"], "填写大于 0 且最多两位小数的克值")
			} else {
				input.weightG = weight
				state.setMappedValue(row.RowNumber, "weight_g", weight)
			}
		}
		if row.Mapped["recorded_at"] != "" {
			recordedAt, err := parseTimeValue(row.Mapped["recorded_at"], state.request.Options.Timezone)
			if err != nil {
				state.addRowIssue(row.RowNumber, "recorded_at", "INVALID_DATETIME", err.Error(), SeverityBlocking, row.Mapped["recorded_at"], "使用 ISO 8601 或 YYYY-MM-DD HH:mm:ss")
			} else {
				input.recordedAt = recordedAt
				state.setMappedValue(row.RowNumber, "recorded_at", recordedAt)
			}
		}
		if input.acquisitionKey == "" {
			input.acquisitionKey = fmt.Sprintf("import:%s:%s", state.request.File.FileSHA256, row.RowSHA256)
			state.setMappedValue(row.RowNumber, "acquisition_key", input.acquisitionKey)
		}
		keys[input.acquisitionKey] = append(keys[input.acquisitionKey], input)
		if existingID, ok := state.snapshot.WeightAcquisitionKeys[input.acquisitionKey]; ok {
			input.skipExistingID = existingID
			input.resourceID = existingID
		} else {
			input.resourceID = state.engine.newID()
		}
		inputs = append(inputs, input)
	}
	for key, duplicates := range keys {
		if len(duplicates) <= 1 {
			continue
		}
		for _, duplicate := range duplicates {
			state.addRowIssue(duplicate.row.RowNumber, "acquisition_key", "DUPLICATE_WEIGHT_ACQUISITION", "同一批次称重采集编号重复", SeverityBlocking, key, "每次称重使用唯一采集编号")
		}
	}
	for _, input := range inputs {
		if state.rowHasBlocking(input.row.RowNumber) {
			continue
		}
		if input.skipExistingID != "" {
			state.addRowIssue(input.row.RowNumber, "acquisition_key", "WEIGHT_ALREADY_IMPORTED", "相同采集编号已成功导入，本行幂等跳过", SeverityWarning, input.acquisitionKey, "无需重复提交")
			state.planRow(input.row.RowNumber, ActionSkip, input.skipExistingID)
			continue
		}
		state.addOperation(Operation{
			Kind:      OperationCreateWeightRecord,
			RowNumber: input.row.RowNumber,
			WeightRecord: &WeightRecordWrite{
				ID:              input.resourceID,
				OwnerID:         state.request.OwnerID,
				OrganizationID:  state.request.OrganizationID,
				HamsterID:       input.hamsterID,
				LitterID:        input.litterID,
				SubjectType:     input.subjectType,
				MeasurementKind: input.measurementKind,
				SubjectCount:    optionalPositiveInt(input.subjectCount),
				WeightG:         input.weightG,
				RecordedAt:      *input.recordedAt,
				Source:          "import",
				AcquisitionKey:  input.acquisitionKey,
				OperatorID:      state.request.OperatorID,
			},
		})
		state.planRow(input.row.RowNumber, ActionCreate, input.resourceID)
	}
}

func optionalPositiveInt(value int) *int {
	if value <= 0 {
		return nil
	}
	return &value
}
