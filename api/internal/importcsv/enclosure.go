package importcsv

import (
	"fmt"
	"strings"
	"time"
)

type enclosureInput struct {
	row            ParsedRow
	code           string
	rackCode       string
	levelCode      string
	capacity       int
	state          string
	cleanliness    string
	lastCleanedAt  string
	disabledReason string
	existing       *EnclosureRecord
	resourceID     string
}

func (state *preflightState) preflightEnclosures() {
	byCode := make(map[string][]EnclosureRecord)
	for _, enclosure := range state.snapshot.Enclosures {
		if enclosure.OwnerID == state.request.OwnerID {
			byCode[enclosure.Code] = append(byCode[enclosure.Code], enclosure)
		}
	}
	inputs := make([]*enclosureInput, 0, len(state.request.File.Rows))
	batchByCode := make(map[string][]*enclosureInput)
	for _, row := range state.request.File.Rows {
		input := &enclosureInput{
			row:            row,
			code:           strings.TrimSpace(row.Mapped["code"]),
			rackCode:       strings.TrimSpace(row.Mapped["rack_code"]),
			levelCode:      strings.TrimSpace(row.Mapped["level_code"]),
			state:          strings.TrimSpace(row.Mapped["state"]),
			cleanliness:    strings.TrimSpace(row.Mapped["cleanliness"]),
			lastCleanedAt:  strings.TrimSpace(row.Mapped["last_cleaned_at"]),
			disabledReason: strings.TrimSpace(row.Mapped["disabled_reason"]),
		}
		if input.code != "" {
			batchByCode[input.code] = append(batchByCode[input.code], input)
		}
		capacity, err := parsePositiveInt(row.Mapped["capacity"], 1)
		if err != nil {
			state.addRowIssue(row.RowNumber, "capacity", "INVALID_CAPACITY", "笼盒容量必须是正整数", SeverityBlocking, row.Mapped["capacity"], "填写大于 0 的整数")
		} else {
			input.capacity = capacity
			state.setMappedValue(row.RowNumber, "capacity", capacity)
		}
		if input.state != "" && !validEnum(input.state, "vacant", "occupied_single", "pairing_temp", "gestation", "dam_with_litter", "isolation", "cleaning_due", "disabled") {
			state.addRowIssue(row.RowNumber, "state", "INVALID_ENUM", "未知笼盒状态", SeverityBlocking, input.state, "使用 OpenAPI enclosure_state 枚举")
		}
		if input.cleanliness != "" && !validEnum(input.cleanliness, "clean", "partial_due", "full_due") {
			state.addRowIssue(row.RowNumber, "cleanliness", "INVALID_ENUM", "未知清洁状态", SeverityBlocking, input.cleanliness, "使用 clean、partial_due 或 full_due")
		}
		if input.lastCleanedAt != "" {
			parsed, parseErr := parseTimeValue(input.lastCleanedAt, state.request.Options.Timezone)
			if parseErr != nil {
				state.addRowIssue(row.RowNumber, "last_cleaned_at", "INVALID_DATETIME", parseErr.Error(), SeverityBlocking, input.lastCleanedAt, "使用 ISO 8601 或 YYYY-MM-DD HH:mm:ss")
			} else {
				input.lastCleanedAt = canonicalTime(parsed)
				state.setMappedValue(row.RowNumber, "last_cleaned_at", parsed)
			}
		}
		if matches := byCode[input.code]; input.code != "" {
			switch len(matches) {
			case 0:
				input.resourceID = state.engine.newID()
			case 1:
				existing := matches[0]
				input.existing = &existing
				input.resourceID = existing.ID
			default:
				state.addRowIssue(row.RowNumber, "code", "ENCLOSURE_REFERENCE_AMBIGUOUS", "owner 范围内存在多个同编号笼盒", SeverityBlocking, input.code, "先合并或停用重复编号记录")
			}
		}
		inputs = append(inputs, input)
	}
	for code, duplicates := range batchByCode {
		if len(duplicates) <= 1 {
			continue
		}
		for _, duplicate := range duplicates {
			state.addRowIssue(duplicate.row.RowNumber, "code", "DUPLICATE_ENCLOSURE_CODE", "同一批次笼盒编号重复", SeverityBlocking, code, "每个编号只保留一行")
		}
	}
	for _, input := range inputs {
		if state.rowHasBlocking(input.row.RowNumber) || input.code == "" {
			continue
		}
		if input.existing == nil {
			enclosureState := input.state
			if enclosureState == "" {
				enclosureState = "vacant"
			}
			cleanliness := input.cleanliness
			if cleanliness == "" {
				cleanliness = "clean"
			}
			var lastCleanedAt = timeFromCanonical(input.lastCleanedAt)
			state.addOperation(Operation{
				Kind:      OperationCreateEnclosure,
				RowNumber: input.row.RowNumber,
				Enclosure: &EnclosureWrite{
					ID:             input.resourceID,
					OwnerID:        state.request.OwnerID,
					OrganizationID: state.request.OrganizationID,
					Code:           input.code,
					RackCode:       input.rackCode,
					LevelCode:      input.levelCode,
					Capacity:       input.capacity,
					State:          enclosureState,
					Cleanliness:    cleanliness,
					LastCleanedAt:  lastCleanedAt,
					DisabledReason: input.disabledReason,
				},
			})
			state.planRow(input.row.RowNumber, ActionCreate, input.resourceID)
			continue
		}
		existing := input.existing
		if input.row.Mapped["capacity"] != "" && input.capacity != existing.Capacity {
			state.addRowIssue(input.row.RowNumber, "capacity", "CORE_FIELD_CONFLICT", "CSV 容量与现有笼盒核心事实冲突", SeverityBlocking, input.row.Mapped["capacity"], "通过笼盒容量调整流程处理")
		}
		if input.state != "" && input.state != existing.State {
			state.addRowIssue(input.row.RowNumber, "state", "CORE_FIELD_CONFLICT", "CSV 状态与现有笼盒核心事实冲突", SeverityBlocking, input.state, "通过入住、清洁或停用流程改变状态")
		}
		if state.rowHasBlocking(input.row.RowNumber) {
			continue
		}
		changes := make(map[string]FieldChange)
		addStringChange(changes, "rack_code", existing.RackCode, input.rackCode)
		addStringChange(changes, "level_code", existing.LevelCode, input.levelCode)
		addStringChange(changes, "cleanliness", existing.Cleanliness, input.cleanliness)
		addStringChange(changes, "disabled_reason", existing.DisabledReason, input.disabledReason)
		if input.lastCleanedAt != "" {
			current := canonicalTime(existing.LastCleanedAt)
			if current != input.lastCleanedAt {
				changes["last_cleaned_at"] = FieldChange{Current: existing.LastCleanedAt, Proposed: timeFromCanonical(input.lastCleanedAt), Reason: changeReason(current)}
			}
		}
		if len(changes) == 0 {
			state.planRow(input.row.RowNumber, ActionSkip, existing.ID)
			continue
		}
		if state.request.Options.ExistingFieldPolicy == ExistingFieldRejectUpdates {
			state.addRowIssue(input.row.RowNumber, "", "EXISTING_UPDATE_REJECTED", "当前预检策略拒绝已有资源更新", SeverityBlocking, input.code, "改用 preserve_non_null 后逐项确认")
			continue
		}
		state.addCandidate(UpdateCandidate{
			RowNumber:       input.row.RowNumber,
			ResourceType:    "enclosure",
			ResourceID:      existing.ID,
			ExpectedVersion: existing.Version,
			Fields:          changes,
		})
		state.planRow(input.row.RowNumber, ActionUpdateCandidate, existing.ID)
	}
}

func addStringChange(changes map[string]FieldChange, field, current, proposed string) {
	if proposed == "" || current == proposed {
		return
	}
	changes[field] = FieldChange{Current: current, Proposed: proposed, Reason: changeReason(current)}
}

func changeReason(current string) string {
	if current == "" {
		return "fill_empty"
	}
	return "overwrite_non_core"
}

func timeFromCanonical(value string) *time.Time {
	if value == "" {
		return nil
	}
	parsed, err := time.Parse(time.RFC3339Nano, value)
	if err != nil {
		panic(fmt.Sprintf("importcsv: 非法内部时间 %q", value))
	}
	return &parsed
}
