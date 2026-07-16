package importcsv

import (
	"fmt"
	"strings"
	"time"
)

type hamsterInput struct {
	row                  ParsedRow
	code                 string
	resourceID           string
	existing             *HamsterRecord
	name                 string
	speciesRuleVersionID string
	varietyCode          string
	sex                  string
	birthDate            *time.Time
	sourceType           string
	lifecycleStatus      string
	breedingStatus       string
	litterCode           string
	litterID             string
	sireCode             string
	sireID               string
	damCode              string
	damID                string
	enclosureCode        string
	enclosureID          string
	enclosureStartedAt   *time.Time
	tags                 []string
	notes                string
	coreFill             map[string]any
	nonCoreChanges       map[string]FieldChange
}

type parentReference struct {
	id  string
	sex string
}

func (state *preflightState) preflightHamsters() {
	hamstersByCode := make(map[string][]HamsterRecord)
	hamstersByID := make(map[string]HamsterRecord)
	for _, hamster := range state.snapshot.Hamsters {
		if hamster.OwnerID != state.request.OwnerID {
			continue
		}
		hamstersByCode[hamster.InternalCode] = append(hamstersByCode[hamster.InternalCode], hamster)
		hamstersByID[hamster.ID] = hamster
	}
	enclosuresByCode := make(map[string][]EnclosureRecord)
	enclosuresByID := make(map[string]EnclosureRecord)
	for _, enclosure := range state.snapshot.Enclosures {
		if enclosure.OwnerID != state.request.OwnerID {
			continue
		}
		enclosuresByCode[enclosure.Code] = append(enclosuresByCode[enclosure.Code], enclosure)
		enclosuresByID[enclosure.ID] = enclosure
	}
	littersByCode := make(map[string][]LitterRecord)
	littersByID := make(map[string]LitterRecord)
	memberLitter := make(map[string]string)
	for _, litter := range state.snapshot.Litters {
		if litter.OwnerID != state.request.OwnerID {
			continue
		}
		littersByCode[litter.Code] = append(littersByCode[litter.Code], litter)
		littersByID[litter.ID] = litter
		for _, memberID := range litter.MemberIDs {
			memberLitter[memberID] = litter.ID
		}
	}
	existingParents := make(map[string]map[string]string)
	existingEdges := make(map[string]struct{})
	graph := make(map[string][]string)
	for _, parentage := range state.snapshot.Parentages {
		if _, ok := hamstersByID[parentage.ChildID]; !ok {
			continue
		}
		if _, ok := hamstersByID[parentage.ParentID]; !ok {
			continue
		}
		if existingParents[parentage.ChildID] == nil {
			existingParents[parentage.ChildID] = make(map[string]string)
		}
		existingParents[parentage.ChildID][parentage.Role] = parentage.ParentID
		existingEdges[parentEdgeKey(parentage.ParentID, parentage.ChildID, parentage.Role)] = struct{}{}
		graph[parentage.ChildID] = append(graph[parentage.ChildID], parentage.ParentID)
	}

	inputs := make([]*hamsterInput, 0, len(state.request.File.Rows))
	batchByCode := make(map[string][]*hamsterInput)
	groups := make(map[string][]*hamsterInput)
	for _, row := range state.request.File.Rows {
		input := &hamsterInput{
			row:                  row,
			code:                 strings.TrimSpace(row.Mapped["internal_code"]),
			name:                 strings.TrimSpace(row.Mapped["name"]),
			speciesRuleVersionID: strings.TrimSpace(row.Mapped["species_rule_version_id"]),
			varietyCode:          strings.TrimSpace(row.Mapped["variety_code"]),
			sex:                  strings.TrimSpace(row.Mapped["sex"]),
			sourceType:           strings.TrimSpace(row.Mapped["source_type"]),
			lifecycleStatus:      strings.TrimSpace(row.Mapped["lifecycle_status"]),
			breedingStatus:       strings.TrimSpace(row.Mapped["breeding_status"]),
			litterCode:           strings.TrimSpace(row.Mapped["litter_code"]),
			sireCode:             strings.TrimSpace(row.Mapped["sire_code"]),
			damCode:              strings.TrimSpace(row.Mapped["dam_code"]),
			enclosureCode:        strings.TrimSpace(row.Mapped["enclosure_code"]),
			notes:                strings.TrimSpace(row.Mapped["notes"]),
			coreFill:             make(map[string]any),
			nonCoreChanges:       make(map[string]FieldChange),
		}
		if row.Mapped["tags"] != "" {
			input.tags = splitTags(row.Mapped["tags"])
			state.setMappedValue(row.RowNumber, "tags", input.tags)
		}
		if input.code != "" {
			batchByCode[input.code] = append(batchByCode[input.code], input)
			matches := hamstersByCode[input.code]
			switch len(matches) {
			case 0:
				input.resourceID = state.engine.newID()
			case 1:
				existing := matches[0]
				input.existing = &existing
				input.resourceID = existing.ID
			default:
				state.addRowIssue(row.RowNumber, "internal_code", "HAMSTER_REFERENCE_AMBIGUOUS", "owner 范围内存在多个同编号仓鼠", SeverityBlocking, input.code, "先合并或停用重复编号记录")
			}
		}
		if input.litterCode != "" {
			groups[input.litterCode] = append(groups[input.litterCode], input)
		}
		if input.speciesRuleVersionID == "" {
			if input.existing != nil {
				input.speciesRuleVersionID = input.existing.SpeciesRuleVersionID
			} else {
				input.speciesRuleVersionID = state.request.Options.SpeciesRuleVersionID
			}
		}
		if input.speciesRuleVersionID == "" {
			state.addRowIssue(row.RowNumber, "species_rule_version_id", "SPECIES_RULE_REQUIRED", "新仓鼠缺少物种规则版本", SeverityBlocking, row.Mapped["species_rule_version_id"], "在 CSV 或预检选项中指定 species_rule_version_id")
		}
		if input.sex != "" && !validEnum(input.sex, "male", "female", "unknown") {
			state.addRowIssue(row.RowNumber, "sex", "INVALID_ENUM", "未知仓鼠性别", SeverityBlocking, input.sex, "使用 male、female 或 unknown")
		}
		if input.sourceType != "" && !validEnum(input.sourceType, "born_here", "introduced", "customer", "imported") {
			state.addRowIssue(row.RowNumber, "source_type", "INVALID_ENUM", "未知仓鼠来源类型", SeverityBlocking, input.sourceType, "使用 OpenAPI source_type 枚举")
		}
		if input.lifecycleStatus != "" && !validEnum(input.lifecycleStatus, "active", "transferred", "retired", "deceased") {
			state.addRowIssue(row.RowNumber, "lifecycle_status", "INVALID_ENUM", "未知生命周期状态", SeverityBlocking, input.lifecycleStatus, "使用 active、transferred、retired 或 deceased")
		}
		if input.breedingStatus != "" && !validEnum(input.breedingStatus, "candidate", "active", "resting", "retired") {
			state.addRowIssue(row.RowNumber, "breeding_status", "INVALID_ENUM", "未知繁育状态", SeverityBlocking, input.breedingStatus, "使用 candidate、active、resting 或 retired")
		}
		if bornAt := strings.TrimSpace(row.Mapped["born_at"]); bornAt != "" {
			parsed, err := parseTimeValue(bornAt, state.request.Options.Timezone)
			if err != nil {
				state.addRowIssue(row.RowNumber, "born_at", "INVALID_DATETIME", err.Error(), SeverityBlocking, bornAt, "使用 ISO 8601 或 YYYY-MM-DD")
			} else {
				input.birthDate = parsed
				state.setMappedValue(row.RowNumber, "born_at", parsed)
			}
		}
		if startedAt := strings.TrimSpace(row.Mapped["enclosure_started_at"]); startedAt != "" {
			parsed, err := parseTimeValue(startedAt, state.request.Options.Timezone)
			if err != nil {
				state.addRowIssue(row.RowNumber, "enclosure_started_at", "INVALID_DATETIME", err.Error(), SeverityBlocking, startedAt, "使用 ISO 8601 或 YYYY-MM-DD HH:mm:ss")
			} else {
				input.enclosureStartedAt = parsed
				state.setMappedValue(row.RowNumber, "enclosure_started_at", parsed)
			}
		}
		inputs = append(inputs, input)
	}
	for code, duplicates := range batchByCode {
		if len(duplicates) <= 1 {
			continue
		}
		for _, duplicate := range duplicates {
			state.addRowIssue(duplicate.row.RowNumber, "internal_code", "DUPLICATE_INTERNAL_CODE", "同一批次 internal_code 重复", SeverityBlocking, code, "每个仓鼠编号只保留一行")
		}
	}

	groupLitters := make(map[string]*LitterRecord)
	groupLitterIDs := make(map[string]string)
	for litterCode, group := range groups {
		rowNumbers := hamsterRows(group)
		birthDates := uniqueTimes(group)
		sireCodes := uniqueInputStrings(group, func(input *hamsterInput) string { return input.sireCode })
		damCodes := uniqueInputStrings(group, func(input *hamsterInput) string { return input.damCode })
		speciesRules := uniqueInputStrings(group, func(input *hamsterInput) string { return input.speciesRuleVersionID })
		if len(birthDates) > 1 {
			state.addGroupIssue(rowNumbers, litterCode, "born_at", "LITTER_FACT_CONFLICT", "同一 litter_code 的出生日期不一致", birthDates, "统一同窝成员出生日期")
		}
		if len(sireCodes) > 1 {
			state.addGroupIssue(rowNumbers, litterCode, "sire_code", "LITTER_FACT_CONFLICT", "同一 litter_code 的父本编号不一致", sireCodes, "统一同窝父本编号")
		}
		if len(damCodes) > 1 {
			state.addGroupIssue(rowNumbers, litterCode, "dam_code", "LITTER_FACT_CONFLICT", "同一 litter_code 的母本编号不一致", damCodes, "统一同窝母本编号")
		}
		if len(speciesRules) > 1 {
			state.addGroupIssue(rowNumbers, litterCode, "species_rule_version_id", "LITTER_FACT_CONFLICT", "同一 litter_code 的物种规则版本不一致", speciesRules, "统一同窝物种规则版本")
		}
		var groupBirth *time.Time
		if len(birthDates) == 1 {
			groupBirth = firstInputTime(group)
		}
		groupSire := firstNonEmptyInput(group, func(input *hamsterInput) string { return input.sireCode })
		groupDam := firstNonEmptyInput(group, func(input *hamsterInput) string { return input.damCode })
		for _, input := range group {
			if input.birthDate == nil {
				input.birthDate = groupBirth
			}
			if input.sireCode == "" {
				input.sireCode = groupSire
			}
			if input.damCode == "" {
				input.damCode = groupDam
			}
		}
		matches := littersByCode[litterCode]
		switch len(matches) {
		case 0:
			if state.request.Options.HistoricalLitterPolicy == HistoricalLitterRequireExisting {
				state.addGroupIssue(rowNumbers, litterCode, "litter_code", "LITTER_NOT_FOUND", "历史窝次不存在且策略要求引用已有窝次", litterCode, "先创建窝次或使用 create_if_complete")
			} else {
				groupLitterIDs[litterCode] = state.engine.newID()
			}
		case 1:
			existing := matches[0]
			groupLitters[litterCode] = &existing
			groupLitterIDs[litterCode] = existing.ID
			if groupBirth != nil && existing.BornAt == nil {
				state.addGroupIssue(rowNumbers, litterCode, "born_at", "LITTER_FACT_CONFLICT", "CSV 提供了出生日期，但已有窝次缺少该核心事实", canonicalTime(groupBirth), "通过出生事实纠错流程补齐窝次日期")
			} else if groupBirth != nil && !sameDate(groupBirth, existing.BornAt) {
				state.addGroupIssue(rowNumbers, litterCode, "born_at", "LITTER_FACT_CONFLICT", "CSV 出生日期与已有窝次不一致", canonicalTime(groupBirth), "通过出生事实纠错流程处理")
			}
			for _, input := range group {
				if input.birthDate == nil {
					input.birthDate = existing.BornAt
				}
				if input.sireCode == "" && existing.SireID != "" {
					input.sireID = existing.SireID
				}
				if input.damCode == "" && existing.DamID != "" {
					input.damID = existing.DamID
				}
			}
		default:
			state.addGroupIssue(rowNumbers, litterCode, "litter_code", "LITTER_REFERENCE_AMBIGUOUS", "owner 范围内窝次编号不唯一", litterCode, "先合并重复窝次编号")
		}
	}

	resolveParent := func(code string) (parentReference, string) {
		if code == "" {
			return parentReference{}, ""
		}
		if batch := batchByCode[code]; len(batch) > 0 {
			if len(batch) != 1 || batch[0].resourceID == "" {
				return parentReference{}, "ambiguous"
			}
			sex := batch[0].sex
			if sex == "" && batch[0].existing != nil {
				sex = batch[0].existing.Sex
			}
			if sex == "" {
				sex = "unknown"
			}
			return parentReference{id: batch[0].resourceID, sex: sex}, ""
		}
		matches := hamstersByCode[code]
		switch len(matches) {
		case 0:
			return parentReference{}, "missing"
		case 1:
			return parentReference{id: matches[0].ID, sex: matches[0].Sex}, ""
		default:
			return parentReference{}, "ambiguous"
		}
	}
	for _, input := range inputs {
		if input.litterCode != "" {
			input.litterID = groupLitterIDs[input.litterCode]
		}
		if input.sireCode != "" {
			reference, problem := resolveParent(input.sireCode)
			switch problem {
			case "missing":
				state.addRowIssue(input.row.RowNumber, "sire_code", "PARENT_NOT_FOUND", "owner 和同批次范围内未找到父本编号", SeverityBlocking, input.sireCode, "先导入父本或修正编号")
			case "ambiguous":
				state.addRowIssue(input.row.RowNumber, "sire_code", "PARENT_AMBIGUOUS", "父本编号解析到多个候选", SeverityBlocking, input.sireCode, "保证 owner 范围编号唯一")
			default:
				input.sireID = reference.id
				if reference.sex != "male" {
					state.addRowIssue(input.row.RowNumber, "sire_code", "PARENT_ROLE_MISMATCH", "父本性别必须为 male", SeverityBlocking, input.sireCode, "修正父本性别或父本编号")
				}
			}
		}
		if input.damCode != "" {
			reference, problem := resolveParent(input.damCode)
			switch problem {
			case "missing":
				state.addRowIssue(input.row.RowNumber, "dam_code", "PARENT_NOT_FOUND", "owner 和同批次范围内未找到母本编号", SeverityBlocking, input.damCode, "先导入母本或修正编号")
			case "ambiguous":
				state.addRowIssue(input.row.RowNumber, "dam_code", "PARENT_AMBIGUOUS", "母本编号解析到多个候选", SeverityBlocking, input.damCode, "保证 owner 范围编号唯一")
			default:
				input.damID = reference.id
				if reference.sex != "female" {
					state.addRowIssue(input.row.RowNumber, "dam_code", "PARENT_ROLE_MISMATCH", "母本性别必须为 female", SeverityBlocking, input.damCode, "修正母本性别或母本编号")
				}
			}
		}
		if input.sireID != "" && input.sireID == input.damID {
			state.addRowIssue(input.row.RowNumber, "sire_code", "PARENTS_MUST_DIFFER", "父本与母本不能是同一个体", SeverityBlocking, input.sireCode, "填写不同的父本和母本编号")
		}
		if input.sireID != "" {
			graph[input.resourceID] = append(graph[input.resourceID], input.sireID)
		}
		if input.damID != "" {
			graph[input.resourceID] = append(graph[input.resourceID], input.damID)
		}
	}

	for litterCode, group := range groups {
		existing := groupLitters[litterCode]
		if existing == nil {
			continue
		}
		rowNumbers := hamsterRows(group)
		groupSireID := firstNonEmptyInput(group, func(input *hamsterInput) string { return input.sireID })
		groupDamID := firstNonEmptyInput(group, func(input *hamsterInput) string { return input.damID })
		if existing.SireID != "" && groupSireID != "" && existing.SireID != groupSireID {
			state.addGroupIssue(rowNumbers, litterCode, "sire_code", "LITTER_FACT_CONFLICT", "CSV 父本与已有窝次不一致", groupSireID, "通过谱系纠错流程处理")
		}
		if existing.DamID != "" && groupDamID != "" && existing.DamID != groupDamID {
			state.addGroupIssue(rowNumbers, litterCode, "dam_code", "LITTER_FACT_CONFLICT", "CSV 母本与已有窝次不一致", groupDamID, "通过谱系纠错流程处理")
		}
	}

	cycles := cycleNodes(graph)
	for _, input := range inputs {
		if cycles[input.resourceID] && (input.sireID != "" || input.damID != "") {
			state.addRowIssue(input.row.RowNumber, "", "PEDIGREE_CYCLE", "导入后的谱系图会形成祖先循环", inputCycleSeverity(), input.code, "修正父母编号后重新预检")
		}
		state.validateExistingHamster(input, existingParents, memberLitter)
		state.resolveHamsterEnclosure(input, enclosuresByCode)
	}
	state.validateEnclosureCapacity(inputs, enclosuresByID)
	state.propagateLitterGroupBlocks(groups)

	createdLitters := make(map[string]bool)
	createdLitterParents := make(map[string]bool)
	createdLitterMembers := make(map[string]bool)
	createdParentages := make(map[string]bool)
	for _, input := range inputs {
		if state.rowHasBlocking(input.row.RowNumber) {
			continue
		}
		action := ActionSkip
		if input.existing == nil {
			sex := input.sex
			if sex == "" {
				sex = "unknown"
			}
			sourceType := input.sourceType
			if sourceType == "" {
				sourceType = "imported"
			}
			lifecycle := input.lifecycleStatus
			if lifecycle == "" {
				lifecycle = "active"
			}
			breeding := input.breedingStatus
			if breeding == "" {
				breeding = "candidate"
			}
			state.addOperation(Operation{
				Kind:      OperationCreateHamster,
				RowNumber: input.row.RowNumber,
				Hamster: &HamsterWrite{
					ID:                   input.resourceID,
					OwnerID:              state.request.OwnerID,
					OrganizationID:       state.request.OrganizationID,
					InternalCode:         input.code,
					Name:                 input.name,
					SpeciesRuleVersionID: input.speciesRuleVersionID,
					VarietyCode:          input.varietyCode,
					Sex:                  sex,
					BirthDate:            input.birthDate,
					SourceType:           sourceType,
					LifecycleStatus:      lifecycle,
					BreedingStatus:       breeding,
					CurrentEnclosureID:   input.enclosureID,
					Tags:                 input.tags,
					Notes:                input.notes,
				},
			})
			action = ActionCreate
		} else if len(input.coreFill) > 0 {
			state.addOperation(Operation{
				Kind:      OperationUpdateHamster,
				RowNumber: input.row.RowNumber,
				HamsterUpdate: &ResourceUpdate{
					ID:              input.existing.ID,
					OwnerID:         state.request.OwnerID,
					ExpectedVersion: input.existing.Version,
					Fields:          input.coreFill,
				},
			})
			action = ActionAppendFacts
		}
		if len(input.nonCoreChanges) > 0 {
			state.addCandidate(UpdateCandidate{
				RowNumber:       input.row.RowNumber,
				ResourceType:    "hamster",
				ResourceID:      input.resourceID,
				ExpectedVersion: input.existing.Version,
				Fields:          input.nonCoreChanges,
			})
			if action == ActionSkip {
				action = ActionUpdateCandidate
			}
		}
		if input.litterCode != "" && input.litterID != "" {
			existingLitter := groupLitters[input.litterCode]
			if existingLitter == nil && !createdLitters[input.litterID] {
				state.addOperation(Operation{
					Kind:      OperationCreateLitter,
					RowNumber: input.row.RowNumber,
					Litter: &LitterWrite{
						ID:             input.litterID,
						OwnerID:        state.request.OwnerID,
						OrganizationID: state.request.OrganizationID,
						Code:           input.litterCode,
						Origin:         "import",
						State:          "closed",
						BornAt:         input.birthDate,
						SireID:         input.sireID,
						DamID:          input.damID,
						DamCondition:   map[string]any{},
					},
				})
				createdLitters[input.litterID] = true
				state.report.HistoricalLittersToCreate++
				action = maxRowAction(action, ActionAppendFacts)
			}
			for role, parentID := range map[string]string{"sire": input.sireID, "dam": input.damID} {
				if parentID == "" {
					continue
				}
				if existingLitter != nil && ((role == "sire" && existingLitter.SireID == parentID) || (role == "dam" && existingLitter.DamID == parentID)) {
					continue
				}
				key := input.litterID + ":" + role
				if createdLitterParents[key] {
					continue
				}
				state.addOperation(Operation{
					Kind:      OperationCreateLitterParent,
					RowNumber: input.row.RowNumber,
					LitterParent: &LitterParentWrite{
						ID:       state.engine.newID(),
						OwnerID:  state.request.OwnerID,
						LitterID: input.litterID,
						ParentID: parentID,
						Role:     role,
						Evidence: "imported",
					},
				})
				createdLitterParents[key] = true
			}
			memberKey := input.litterID + ":" + input.resourceID
			alreadyMember := existingLitter != nil && containsString(existingLitter.MemberIDs, input.resourceID)
			if !alreadyMember && !createdLitterMembers[memberKey] {
				state.addOperation(Operation{
					Kind:      OperationCreateLitterMember,
					RowNumber: input.row.RowNumber,
					LitterMember: &LitterMemberWrite{
						ID:        state.engine.newID(),
						OwnerID:   state.request.OwnerID,
						LitterID:  input.litterID,
						HamsterID: input.resourceID,
						Evidence:  "imported",
					},
				})
				createdLitterMembers[memberKey] = true
				action = maxRowAction(action, ActionAppendFacts)
			}
		}
		for role, parentID := range map[string]string{"sire": input.sireID, "dam": input.damID} {
			if parentID == "" {
				continue
			}
			edgeKey := parentEdgeKey(parentID, input.resourceID, role)
			if _, exists := existingEdges[edgeKey]; exists || createdParentages[edgeKey] {
				continue
			}
			state.addOperation(Operation{
				Kind:      OperationCreatePedigreeParentage,
				RowNumber: input.row.RowNumber,
				PedigreeParentage: &PedigreeParentageWrite{
					ID:       state.engine.newID(),
					OwnerID:  state.request.OwnerID,
					ParentID: parentID,
					ChildID:  input.resourceID,
					Role:     role,
					Evidence: "imported",
				},
			})
			createdParentages[edgeKey] = true
			action = maxRowAction(action, ActionAppendFacts)
		}
		if input.enclosureID != "" && (input.existing == nil || input.existing.CurrentEnclosureID == "") {
			state.addOperation(Operation{
				Kind:      OperationCreateEnclosureStay,
				RowNumber: input.row.RowNumber,
				EnclosureStay: &EnclosureStayWrite{
					ID:          state.engine.newID(),
					OwnerID:     state.request.OwnerID,
					EnclosureID: input.enclosureID,
					HamsterID:   input.resourceID,
					Purpose:     "single",
					StartedAt:   *input.enclosureStartedAt,
					OperatorID:  state.request.OperatorID,
					Reason:      "csv_import",
				},
			})
			action = maxRowAction(action, ActionAppendFacts)
		}
		state.planRow(input.row.RowNumber, action, input.resourceID)
	}
}

func (state *preflightState) validateExistingHamster(input *hamsterInput, existingParents map[string]map[string]string, memberLitter map[string]string) {
	if input.existing == nil {
		return
	}
	existing := input.existing
	if input.row.Mapped["species_rule_version_id"] != "" && input.speciesRuleVersionID != existing.SpeciesRuleVersionID {
		state.addRowIssue(input.row.RowNumber, "species_rule_version_id", "CORE_FIELD_CONFLICT", "物种规则版本与现有仓鼠核心事实冲突", SeverityBlocking, input.speciesRuleVersionID, "通过独立档案纠错流程处理")
	}
	if input.sex != "" && input.sex != existing.Sex {
		state.addRowIssue(input.row.RowNumber, "sex", "CORE_FIELD_CONFLICT", "性别与现有仓鼠核心事实冲突", SeverityBlocking, input.sex, "通过性别复核流程处理")
	}
	if input.birthDate != nil {
		if existing.BirthDate != nil && !sameDate(input.birthDate, existing.BirthDate) {
			state.addRowIssue(input.row.RowNumber, "born_at", "CORE_FIELD_CONFLICT", "出生日期与现有仓鼠核心事实冲突", SeverityBlocking, canonicalTime(input.birthDate), "通过出生事实纠错流程处理")
		} else if existing.BirthDate == nil {
			input.coreFill["birth_date"] = input.birthDate
		}
	}
	for field, proposed := range map[string]string{
		"source_type":      input.sourceType,
		"lifecycle_status": input.lifecycleStatus,
		"breeding_status":  input.breedingStatus,
	} {
		if proposed == "" {
			continue
		}
		current := map[string]string{
			"source_type":      existing.SourceType,
			"lifecycle_status": existing.LifecycleStatus,
			"breeding_status":  existing.BreedingStatus,
		}[field]
		if current != proposed {
			state.addRowIssue(input.row.RowNumber, field, "CORE_FIELD_CONFLICT", "CSV 值与现有仓鼠核心事实冲突", SeverityBlocking, proposed, "通过对应业务流程处理")
		}
	}
	if input.litterID != "" {
		if currentLitter := memberLitter[existing.ID]; currentLitter != "" && currentLitter != input.litterID {
			state.addRowIssue(input.row.RowNumber, "litter_code", "CORE_FIELD_CONFLICT", "仓鼠已属于其他出生窝次", SeverityBlocking, input.litterCode, "通过谱系/出生事实纠错流程处理")
		}
	}
	for role, parentID := range map[string]string{"sire": input.sireID, "dam": input.damID} {
		if parentID == "" {
			continue
		}
		if current := existingParents[existing.ID][role]; current != "" && current != parentID {
			state.addRowIssue(input.row.RowNumber, role+"_code", "CORE_FIELD_CONFLICT", "父母关系与已有已接受谱系边冲突", SeverityBlocking, parentID, "通过谱系纠错流程处理")
		}
	}
	addStringChange(input.nonCoreChanges, "name", existing.Name, input.name)
	addStringChange(input.nonCoreChanges, "variety_code", existing.VarietyCode, input.varietyCode)
	addStringChange(input.nonCoreChanges, "notes", existing.Notes, input.notes)
	if input.row.Mapped["tags"] != "" && !equalStrings(existing.Tags, input.tags) {
		input.nonCoreChanges["tags"] = FieldChange{Current: existing.Tags, Proposed: input.tags, Reason: changeReason(strings.Join(existing.Tags, ","))}
	}
	if len(input.nonCoreChanges) > 0 && state.request.Options.ExistingFieldPolicy == ExistingFieldRejectUpdates {
		state.addRowIssue(input.row.RowNumber, "", "EXISTING_UPDATE_REJECTED", "当前预检策略拒绝已有资源更新", SeverityBlocking, input.code, "改用 preserve_non_null 后逐项确认")
		input.nonCoreChanges = nil
	}
}

func (state *preflightState) resolveHamsterEnclosure(input *hamsterInput, enclosuresByCode map[string][]EnclosureRecord) {
	if input.enclosureCode == "" {
		return
	}
	matches := enclosuresByCode[input.enclosureCode]
	switch len(matches) {
	case 0:
		state.addRowIssue(input.row.RowNumber, "enclosure_code", "ENCLOSURE_NOT_FOUND", "owner 范围内未找到笼盒编号", SeverityBlocking, input.enclosureCode, "先导入笼盒或修正编号")
		return
	case 1:
		input.enclosureID = matches[0].ID
		if matches[0].State == "disabled" {
			state.addRowIssue(input.row.RowNumber, "enclosure_code", "ENCLOSURE_CONFLICT", "停用笼盒不可创建有效入住", SeverityBlocking, input.enclosureCode, "选择可用笼盒")
		}
	default:
		state.addRowIssue(input.row.RowNumber, "enclosure_code", "ENCLOSURE_REFERENCE_AMBIGUOUS", "owner 范围内笼盒编号不唯一", SeverityBlocking, input.enclosureCode, "先合并重复笼盒编号")
		return
	}
	if input.existing != nil && input.existing.CurrentEnclosureID != "" && input.existing.CurrentEnclosureID != input.enclosureID {
		state.addRowIssue(input.row.RowNumber, "enclosure_code", "ENCLOSURE_CONFLICT", "仓鼠当前已在其他笼盒", SeverityBlocking, input.enclosureCode, "先通过移笼流程结束现有入住")
	}
	if input.enclosureStartedAt == nil {
		now := state.engine.now()
		input.enclosureStartedAt = &now
		state.setMappedValue(input.row.RowNumber, "enclosure_started_at", now)
		state.addRowIssue(input.row.RowNumber, "enclosure_started_at", "ENCLOSURE_STARTED_AT_DEFAULTED", "未填写入住时间，计划使用提交预检时间", SeverityWarning, nil, "如需历史时间请在 CSV 中填写")
	}
}

func (state *preflightState) validateEnclosureCapacity(inputs []*hamsterInput, enclosuresByID map[string]EnclosureRecord) {
	occupants := make(map[string]map[string]struct{})
	for _, hamster := range state.snapshot.Hamsters {
		if hamster.OwnerID != state.request.OwnerID || hamster.CurrentEnclosureID == "" {
			continue
		}
		if occupants[hamster.CurrentEnclosureID] == nil {
			occupants[hamster.CurrentEnclosureID] = make(map[string]struct{})
		}
		occupants[hamster.CurrentEnclosureID][hamster.ID] = struct{}{}
	}
	plannedRows := make(map[string][]int)
	for _, input := range inputs {
		if input.enclosureID == "" || state.rowHasBlocking(input.row.RowNumber) {
			continue
		}
		if occupants[input.enclosureID] == nil {
			occupants[input.enclosureID] = make(map[string]struct{})
		}
		if _, already := occupants[input.enclosureID][input.resourceID]; !already {
			occupants[input.enclosureID][input.resourceID] = struct{}{}
			plannedRows[input.enclosureID] = append(plannedRows[input.enclosureID], input.row.RowNumber)
		}
	}
	for enclosureID, rowNumbers := range plannedRows {
		enclosure := enclosuresByID[enclosureID]
		// CSV 历史导入的入住统一按 single 处理；数据库单住排斥约束要求一笼一鼠。
		capacity := 1
		if enclosure.Capacity > 0 && enclosure.Capacity < capacity {
			capacity = enclosure.Capacity
		}
		if len(occupants[enclosureID]) <= capacity {
			continue
		}
		for _, rowNumber := range rowNumbers {
			state.addRowIssue(rowNumber, "enclosure_code", "ENCLOSURE_CONFLICT", fmt.Sprintf("单住约束下一笼一鼠，导入后在住数为 %d（笼盒 %s 标称容量 %d）", len(occupants[enclosureID]), enclosure.Code, enclosure.Capacity), SeverityBlocking, enclosure.Code, "为每只仓鼠分配独立笼盒，或先结束现有入住")
		}
	}
}

func (state *preflightState) propagateLitterGroupBlocks(groups map[string][]*hamsterInput) {
	for litterCode, group := range groups {
		blocked := false
		for _, input := range group {
			if state.rowHasBlocking(input.row.RowNumber) {
				blocked = true
				break
			}
		}
		if !blocked {
			continue
		}
		for _, input := range group {
			if hasIssueCode(state.report.Rows[state.rowIndexes[input.row.RowNumber]].Issues, "LITTER_GROUP_BLOCKED") {
				continue
			}
			state.addIssue(Issue{
				RowNumber:     input.row.RowNumber,
				ColumnName:    "litter_code",
				Code:          "LITTER_GROUP_BLOCKED",
				Message:       "同窝组存在阻塞问题，整组不生成提交操作",
				Severity:      SeverityBlocking,
				OriginalValue: litterCode,
				Suggestion:    "修复该 litter_code 组的全部阻塞问题",
				GroupKey:      litterCode,
			})
		}
	}
}

func hamsterRows(inputs []*hamsterInput) []int {
	rows := make([]int, 0, len(inputs))
	for _, input := range inputs {
		rows = append(rows, input.row.RowNumber)
	}
	return rows
}

func uniqueTimes(inputs []*hamsterInput) []string {
	seen := make(map[string]struct{})
	result := make([]string, 0)
	for _, input := range inputs {
		if input.birthDate == nil {
			continue
		}
		value := input.birthDate.Format("2006-01-02")
		if _, ok := seen[value]; ok {
			continue
		}
		seen[value] = struct{}{}
		result = append(result, value)
	}
	return result
}

func uniqueInputStrings(inputs []*hamsterInput, getter func(*hamsterInput) string) []string {
	seen := make(map[string]struct{})
	result := make([]string, 0)
	for _, input := range inputs {
		value := getter(input)
		if value == "" {
			continue
		}
		if _, ok := seen[value]; ok {
			continue
		}
		seen[value] = struct{}{}
		result = append(result, value)
	}
	return result
}

func firstInputTime(inputs []*hamsterInput) *time.Time {
	for _, input := range inputs {
		if input.birthDate != nil {
			return input.birthDate
		}
	}
	return nil
}

func firstNonEmptyInput(inputs []*hamsterInput, getter func(*hamsterInput) string) string {
	for _, input := range inputs {
		if value := getter(input); value != "" {
			return value
		}
	}
	return ""
}

func parentEdgeKey(parentID, childID, role string) string {
	return parentID + ":" + childID + ":" + role
}

func containsString(values []string, expected string) bool {
	for _, value := range values {
		if value == expected {
			return true
		}
	}
	return false
}

func hasIssueCode(issues []Issue, code string) bool {
	for _, issue := range issues {
		if issue.Code == code {
			return true
		}
	}
	return false
}

func maxRowAction(current, candidate RowAction) RowAction {
	priority := map[RowAction]int{ActionSkip: 0, ActionUpdateCandidate: 1, ActionAppendFacts: 2, ActionCreate: 3}
	if priority[candidate] > priority[current] {
		return candidate
	}
	return current
}

func inputCycleSeverity() Severity {
	return SeverityBlocking
}
