package importcsv

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"sort"
)

var (
	ErrBlockingIssues   = errors.New("导入预检仍有阻塞问题")
	ErrBatchKeyConflict = errors.New("幂等批次号已用于不同文件或提交计划")
	ErrInvalidApproval  = errors.New("approved_updates 与预检候选不匹配")
	ErrStalePreflight   = errors.New("预检计划已失效或被篡改")
)

func (engine *Engine) Commit(ctx context.Context, request CommitRequest) (CommitReceipt, error) {
	if engine.store == nil {
		return CommitReceipt{}, errors.New("importcsv: Store 为空")
	}
	if request.Report == nil {
		return CommitReceipt{}, errors.New("importcsv: PreflightReport 为空")
	}
	if request.OwnerID == "" || request.OwnerID != request.Report.OwnerID || request.OwnerID != request.Report.Plan.OwnerID {
		return CommitReceipt{}, errors.New("importcsv: owner_id 与预检计划不一致")
	}
	if len(request.BatchKey) < 8 || len(request.BatchKey) > 128 {
		return CommitReceipt{}, errors.New("importcsv: batch_key 长度必须为 8-128")
	}
	if !request.Report.ReadyToCommit || request.Report.BlockingIssueCount > 0 {
		return CommitReceipt{}, ErrBlockingIssues
	}
	if request.Report.FileSHA256 == "" || request.Report.FileSHA256 != request.Report.Plan.FileSHA256 || request.Report.PreflightVersion != request.Report.Plan.PreflightVersion {
		return CommitReceipt{}, ErrStalePreflight
	}
	if expected := hashPlan(request.Report.Plan, request.Report.UpdateCandidates); expected != request.Report.Plan.PlanHash {
		return CommitReceipt{}, ErrStalePreflight
	}
	operations, approvedRows, finalPlanHash, err := materializeOperations(request.Report, request.ApprovedUpdates)
	if err != nil {
		return CommitReceipt{}, err
	}
	rows := committedRows(request.Report.Rows, approvedRows)
	receipt := CommitReceipt{
		JobID:             request.Report.JobID,
		AsyncJobID:        request.Report.AsyncJobID,
		OwnerID:           request.OwnerID,
		BatchKey:          request.BatchKey,
		Template:          request.Report.Template,
		FileSHA256:        request.Report.FileSHA256,
		PlanHash:          finalPlanHash,
		PreflightVersion:  request.Report.PreflightVersion,
		Status:            JobSucceeded,
		ImportStatus:      ImportJobSucceeded,
		ApprovedUpdates:   append([]ApprovedUpdate(nil), request.ApprovedUpdates...),
		Rows:              rows,
		AppliedOperations: len(operations),
		CommittedAt:       engine.now(),
	}
	var result CommitReceipt
	err = engine.store.WithTransaction(ctx, func(tx Tx) error {
		existing, found, findErr := tx.FindCommit(ctx, request.OwnerID, request.BatchKey)
		if findErr != nil {
			return fmt.Errorf("查询幂等批次: %w", findErr)
		}
		if found {
			if existing.FileSHA256 != receipt.FileSHA256 || existing.PlanHash != receipt.PlanHash || existing.PreflightVersion != receipt.PreflightVersion {
				return ErrBatchKeyConflict
			}
			existing.Replayed = true
			result = existing
			return nil
		}
		for _, operation := range operations {
			if applyErr := tx.Apply(ctx, operation); applyErr != nil {
				return fmt.Errorf("应用 %s（CSV 第 %d 行）: %w", operation.Kind, operation.RowNumber, applyErr)
			}
		}
		if saveErr := tx.SaveCommit(ctx, receipt); saveErr != nil {
			return fmt.Errorf("保存导入批次结果: %w", saveErr)
		}
		result = receipt
		return nil
	})
	if err != nil {
		return CommitReceipt{}, err
	}
	return result, nil
}

func materializeOperations(report *PreflightReport, approvals []ApprovedUpdate) ([]Operation, map[int]bool, string, error) {
	operations, err := cloneOperations(report.Plan.Operations)
	if err != nil {
		return nil, nil, "", err
	}
	candidates := make(map[string]UpdateCandidate, len(report.UpdateCandidates))
	for _, candidate := range report.UpdateCandidates {
		candidates[approvalKey(candidate.RowNumber, candidate.ResourceID, candidate.ExpectedVersion)] = candidate
	}
	approvedRows := make(map[int]bool)
	seenApprovalFields := make(map[string]bool)
	normalized := append([]ApprovedUpdate(nil), approvals...)
	sort.Slice(normalized, func(i, j int) bool {
		if normalized[i].RowNumber != normalized[j].RowNumber {
			return normalized[i].RowNumber < normalized[j].RowNumber
		}
		return normalized[i].ResourceID < normalized[j].ResourceID
	})
	for _, approval := range normalized {
		candidate, ok := candidates[approvalKey(approval.RowNumber, approval.ResourceID, approval.ExpectedVersion)]
		if !ok || len(approval.Fields) == 0 {
			return nil, nil, "", ErrInvalidApproval
		}
		fields := make(map[string]any, len(approval.Fields))
		for _, field := range approval.Fields {
			change, exists := candidate.Fields[field]
			fieldKey := approvalKey(approval.RowNumber, approval.ResourceID, approval.ExpectedVersion) + ":" + field
			if !exists || seenApprovalFields[fieldKey] {
				return nil, nil, "", ErrInvalidApproval
			}
			seenApprovalFields[fieldKey] = true
			fields[field] = change.Proposed
		}
		approvedRows[approval.RowNumber] = true
		merged := false
		for index := range operations {
			operation := &operations[index]
			if candidate.ResourceType == "hamster" && operation.Kind == OperationUpdateHamster && operation.HamsterUpdate != nil && operation.HamsterUpdate.ID == candidate.ResourceID {
				for field, value := range fields {
					operation.HamsterUpdate.Fields[field] = value
				}
				merged = true
				break
			}
			if candidate.ResourceType == "enclosure" && operation.Kind == OperationUpdateEnclosure && operation.EnclosureUpdate != nil && operation.EnclosureUpdate.ID == candidate.ResourceID {
				for field, value := range fields {
					operation.EnclosureUpdate.Fields[field] = value
				}
				merged = true
				break
			}
		}
		if merged {
			continue
		}
		update := &ResourceUpdate{ID: candidate.ResourceID, OwnerID: report.OwnerID, ExpectedVersion: candidate.ExpectedVersion, Fields: fields}
		operation := Operation{RowNumber: candidate.RowNumber}
		switch candidate.ResourceType {
		case "hamster":
			operation.Kind = OperationUpdateHamster
			operation.HamsterUpdate = update
		case "enclosure":
			operation.Kind = OperationUpdateEnclosure
			operation.EnclosureUpdate = update
		default:
			return nil, nil, "", ErrInvalidApproval
		}
		operations = append(operations, operation)
	}
	sort.SliceStable(operations, func(i, j int) bool {
		left, right := operationOrder(operations[i].Kind), operationOrder(operations[j].Kind)
		if left != right {
			return left < right
		}
		return operations[i].RowNumber < operations[j].RowNumber
	})
	payload, _ := json.Marshal(struct {
		BaseHash   string
		Operations []Operation
	}{BaseHash: report.Plan.PlanHash, Operations: operations})
	digest := sha256.Sum256(payload)
	return operations, approvedRows, hex.EncodeToString(digest[:]), nil
}

func cloneOperations(operations []Operation) ([]Operation, error) {
	payload, err := json.Marshal(operations)
	if err != nil {
		return nil, fmt.Errorf("复制提交操作: %w", err)
	}
	var cloned []Operation
	if err := json.Unmarshal(payload, &cloned); err != nil {
		return nil, fmt.Errorf("复制提交操作: %w", err)
	}
	return cloned, nil
}

func committedRows(rows []RowResult, approvedRows map[int]bool) []RowResult {
	result := make([]RowResult, len(rows))
	copy(result, rows)
	for index := range result {
		row := &result[index]
		switch row.Action {
		case ActionSkip:
			row.Status = RowSkipped
		case ActionUpdateCandidate:
			if approvedRows[row.RowNumber] {
				row.Status = RowImported
			} else {
				row.Status = RowSkipped
			}
		default:
			row.Status = RowImported
		}
	}
	return result
}

func approvalKey(rowNumber int, resourceID string, version int) string {
	return fmt.Sprintf("%d:%s:%d", rowNumber, resourceID, version)
}
