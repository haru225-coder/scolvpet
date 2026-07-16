package importcsv

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"sort"
)

type preflightState struct {
	engine      *Engine
	request     PreflightRequest
	snapshot    Snapshot
	report      PreflightReport
	rowIndexes  map[int]int
	parsedRows  map[int]ParsedRow
	operations  []Operation
	plannedRows map[int]PlannedRow
	candidates  []UpdateCandidate
}

func newPreflightState(engine *Engine, request PreflightRequest, snapshot Snapshot) (*preflightState, error) {
	template, ok := TemplateFor(request.File.Template)
	if !ok {
		return nil, fmt.Errorf("未知模板 %q", request.File.Template)
	}
	state := &preflightState{
		engine:      engine,
		request:     request,
		snapshot:    snapshot,
		rowIndexes:  make(map[int]int, len(request.File.Rows)),
		parsedRows:  make(map[int]ParsedRow, len(request.File.Rows)),
		plannedRows: make(map[int]PlannedRow, len(request.File.Rows)),
		report: PreflightReport{
			JobID:            request.JobID,
			AsyncJobID:       request.AsyncJobID,
			OwnerID:          request.OwnerID,
			OrganizationID:   request.OrganizationID,
			Template:         request.File.Template,
			FileSHA256:       request.File.FileSHA256,
			PreflightVersion: 1,
			TotalRows:        len(request.File.Rows),
		},
	}
	if len(request.File.Rows) == 0 {
		state.addIssue(Issue{
			RowNumber: 1, Code: "NO_DATA_ROWS", Message: "CSV 只有表头，没有可导入数据行",
			Severity: SeverityBlocking, Suggestion: "至少添加一行数据后重新上传",
		})
	}
	for _, parsed := range request.File.Rows {
		mapped := make(map[string]any, len(parsed.Mapped))
		for key, value := range parsed.Mapped {
			mapped[key] = value
		}
		state.rowIndexes[parsed.RowNumber] = len(state.report.Rows)
		state.parsedRows[parsed.RowNumber] = parsed
		state.report.Rows = append(state.report.Rows, RowResult{
			RowNumber:    parsed.RowNumber,
			Status:       RowPending,
			MappedValues: mapped,
		})
		for _, issue := range parsed.Issues {
			state.addIssue(issue)
		}
	}
	for _, issue := range request.File.Issues {
		state.addIssue(issue)
	}
	mappedTargets := make(map[string]struct{}, len(request.File.Mapping))
	for _, target := range request.File.Mapping {
		mappedTargets[target] = struct{}{}
	}
	for _, field := range template.Fields {
		if !field.Required {
			continue
		}
		if _, ok := mappedTargets[field.Name]; !ok {
			state.addIssue(Issue{
				RowNumber:  1,
				ColumnName: field.Name,
				Code:       "MISSING_REQUIRED_COLUMN",
				Message:    "缺少必填字段列 " + field.Name,
				Severity:   SeverityBlocking,
				Suggestion: "添加该列或在字段映射中指定来源列",
			})
			continue
		}
		for _, parsed := range request.File.Rows {
			if parsed.Mapped[field.Name] == "" {
				state.addIssue(Issue{
					RowNumber:     parsed.RowNumber,
					ColumnName:    field.Name,
					Code:          "REQUIRED_VALUE_MISSING",
					Message:       "必填字段为空",
					Severity:      SeverityBlocking,
					OriginalValue: parsed.Mapped[field.Name],
					Suggestion:    "填写有效值",
				})
			}
		}
	}
	return state, nil
}

func (state *preflightState) addIssue(issue Issue) {
	if issue.RowNumber <= 0 {
		issue.RowNumber = 1
	}
	state.report.Issues = append(state.report.Issues, issue)
	if index, ok := state.rowIndexes[issue.RowNumber]; ok {
		state.report.Rows[index].Issues = append(state.report.Rows[index].Issues, issue)
	}
}

func (state *preflightState) addRowIssue(rowNumber int, column, code, message string, severity Severity, value any, suggestion string) {
	state.addIssue(Issue{
		RowNumber:     rowNumber,
		ColumnName:    column,
		Code:          code,
		Message:       message,
		Severity:      severity,
		OriginalValue: value,
		Suggestion:    suggestion,
	})
}

func (state *preflightState) addGroupIssue(rowNumbers []int, groupKey, column, code, message string, value any, suggestion string) {
	for _, rowNumber := range rowNumbers {
		state.addIssue(Issue{
			RowNumber:     rowNumber,
			ColumnName:    column,
			Code:          code,
			Message:       message,
			Severity:      SeverityBlocking,
			OriginalValue: value,
			Suggestion:    suggestion,
			GroupKey:      groupKey,
		})
	}
}

func (state *preflightState) rowHasBlocking(rowNumber int) bool {
	index, ok := state.rowIndexes[rowNumber]
	if !ok {
		return true
	}
	for _, issue := range state.report.Rows[index].Issues {
		if issue.Severity == SeverityBlocking {
			return true
		}
	}
	return false
}

func (state *preflightState) setMappedValue(rowNumber int, field string, value any) {
	if index, ok := state.rowIndexes[rowNumber]; ok {
		state.report.Rows[index].MappedValues[field] = value
	}
}

func (state *preflightState) planRow(rowNumber int, action RowAction, resourceID string) {
	state.plannedRows[rowNumber] = PlannedRow{RowNumber: rowNumber, Action: action, ResourceID: resourceID}
}

func (state *preflightState) addOperation(operation Operation) {
	state.operations = append(state.operations, operation)
}

func (state *preflightState) addCandidate(candidate UpdateCandidate) {
	state.candidates = append(state.candidates, candidate)
}

func (state *preflightState) finish() *PreflightReport {
	warningRows := make(map[int]struct{})
	for _, issue := range state.report.Issues {
		if issue.Severity == SeverityBlocking {
			state.report.BlockingIssueCount++
		} else if _, ok := state.rowIndexes[issue.RowNumber]; ok {
			warningRows[issue.RowNumber] = struct{}{}
		}
	}
	state.report.WarningRows = len(warningRows)
	for index := range state.report.Rows {
		row := &state.report.Rows[index]
		if state.rowHasBlocking(row.RowNumber) {
			row.Status = RowInvalid
			state.report.InvalidRows++
			continue
		}
		row.Status = RowValid
		state.report.ValidRows++
		if planned, ok := state.plannedRows[row.RowNumber]; ok {
			row.Action = planned.Action
			row.ResourceID = planned.ResourceID
		} else {
			row.Action = ActionSkip
			state.planRow(row.RowNumber, ActionSkip, row.ResourceID)
		}
	}
	rows := make([]PlannedRow, 0, len(state.plannedRows))
	for _, planned := range state.plannedRows {
		rows = append(rows, planned)
	}
	sort.Slice(rows, func(i, j int) bool { return rows[i].RowNumber < rows[j].RowNumber })
	sort.SliceStable(state.operations, func(i, j int) bool {
		left, right := operationOrder(state.operations[i].Kind), operationOrder(state.operations[j].Kind)
		if left != right {
			return left < right
		}
		return state.operations[i].RowNumber < state.operations[j].RowNumber
	})
	state.report.UpdateCandidates = append([]UpdateCandidate(nil), state.candidates...)
	state.report.Plan = CommitPlan{
		OwnerID:          state.request.OwnerID,
		OrganizationID:   state.request.OrganizationID,
		Template:         state.request.File.Template,
		FileSHA256:       state.request.File.FileSHA256,
		PreflightVersion: state.report.PreflightVersion,
		Operations:       append([]Operation(nil), state.operations...),
		Rows:             rows,
	}
	state.report.Plan.PlanHash = hashPlan(state.report.Plan, state.candidates)
	state.report.ReadyToCommit = state.report.BlockingIssueCount == 0
	return &state.report
}

func hashPlan(plan CommitPlan, candidates []UpdateCandidate) string {
	plan.PlanHash = ""
	payload, _ := json.Marshal(struct {
		Plan       CommitPlan
		Candidates []UpdateCandidate
	}{Plan: plan, Candidates: candidates})
	digest := sha256.Sum256(payload)
	return hex.EncodeToString(digest[:])
}

func operationOrder(kind OperationKind) int {
	switch kind {
	case OperationCreateEnclosure:
		return 10
	case OperationCreateHamster:
		return 20
	case OperationUpdateHamster, OperationUpdateEnclosure:
		return 30
	case OperationCreateLitter:
		return 40
	case OperationCreateLitterParent:
		return 50
	case OperationCreateLitterMember:
		return 60
	case OperationCreatePedigreeParentage:
		return 70
	case OperationCreateEnclosureStay:
		return 80
	case OperationCreateWeightRecord:
		return 90
	default:
		return 100
	}
}
