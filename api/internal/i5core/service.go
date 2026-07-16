package i5core

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
)

type Service struct {
	repository *PostgresRepository
}

func NewService(repository *PostgresRepository) *Service {
	return &Service{repository: repository}
}

func (s *Service) ListHealthRecords(ctx context.Context, ownerID uuid.UUID, filter HealthRecordFilter) ([]HealthRecord, error) {
	filter.Page = normalizePage(filter.Page)
	return s.repository.listHealthRecords(ctx, ownerID, filter)
}

func (s *Service) GetHealthRecord(ctx context.Context, ownerID, recordID uuid.UUID) (HealthRecord, error) {
	return s.repository.getHealthRecord(ctx, ownerID, recordID)
}

func (s *Service) CreateHealthRecord(ctx context.Context, ownerID uuid.UUID, options WriteOptions, input CreateHealthRecordInput) (WriteResult[HealthRecord], error) {
	if err := validateHealthRecord(input); err != nil {
		return WriteResult[HealthRecord]{}, err
	}
	payload := options.RequestPayload
	if len(payload) == 0 {
		payload, _ = json.Marshal(input)
	}
	result, err := s.repository.execute(ctx, command{
		OwnerID: ownerID, IdempotencyKey: options.IdempotencyKey, Method: options.RequestMethod,
		Path: options.RequestPath, Payload: payload, SuccessStatus: 201,
	}, func(ctx context.Context, tx pgx.Tx) (any, error) {
		return insertHealthRecordTx(ctx, tx, ownerID, input)
	})
	if err != nil {
		return WriteResult[HealthRecord]{}, err
	}
	var record HealthRecord
	if err := json.Unmarshal(result.Body, &record); err != nil {
		return WriteResult[HealthRecord]{}, err
	}
	return WriteResult[HealthRecord]{Value: record, Replayed: result.Replayed}, nil
}

func (s *Service) ListTasks(ctx context.Context, ownerID uuid.UUID, filter CareTaskFilter) ([]CareTask, error) {
	filter.Page = normalizePage(filter.Page)
	return s.repository.listTasks(ctx, ownerID, filter)
}

func (s *Service) GetTask(ctx context.Context, ownerID, taskID uuid.UUID) (CareTask, error) {
	return s.repository.getTask(ctx, ownerID, taskID)
}

func (s *Service) CreateTask(ctx context.Context, ownerID uuid.UUID, options WriteOptions, input CreateCareTaskInput) (WriteResult[CareTask], error) {
	if err := validateCareTask(input); err != nil {
		return WriteResult[CareTask]{}, err
	}
	payload := options.RequestPayload
	if len(payload) == 0 {
		payload, _ = json.Marshal(input)
	}
	result, err := s.repository.execute(ctx, command{
		OwnerID: ownerID, IdempotencyKey: options.IdempotencyKey, Method: options.RequestMethod,
		Path: options.RequestPath, Payload: payload, SuccessStatus: 201,
	}, func(ctx context.Context, tx pgx.Tx) (any, error) {
		return insertCareTaskTx(ctx, tx, ownerID, options.IdempotencyKey, input)
	})
	if err != nil {
		return WriteResult[CareTask]{}, err
	}
	var task CareTask
	if err := json.Unmarshal(result.Body, &task); err != nil {
		return WriteResult[CareTask]{}, err
	}
	return WriteResult[CareTask]{Value: task, Replayed: result.Replayed}, nil
}

func (s *Service) CompleteTask(ctx context.Context, ownerID, taskID uuid.UUID, options WriteOptions, input CompleteTaskInput) (WriteResult[CompleteTaskResult], error) {
	if err := validateCompleteTask(input); err != nil {
		return WriteResult[CompleteTaskResult]{}, err
	}
	payload := options.RequestPayload
	if len(payload) == 0 {
		payload, _ = json.Marshal(input)
	}
	result, err := s.repository.execute(ctx, command{
		OwnerID: ownerID, IdempotencyKey: options.IdempotencyKey, Method: options.RequestMethod,
		Path: options.RequestPath, Payload: payload, SuccessStatus: 200,
	}, func(ctx context.Context, tx pgx.Tx) (any, error) {
		return completeCareTaskTx(ctx, tx, ownerID, taskID, input, options.IdempotencyKey)
	})
	if err != nil {
		return WriteResult[CompleteTaskResult]{}, err
	}
	var completed CompleteTaskResult
	if err := json.Unmarshal(result.Body, &completed); err != nil {
		return WriteResult[CompleteTaskResult]{}, err
	}
	return WriteResult[CompleteTaskResult]{Value: completed, Replayed: result.Replayed}, nil
}

func (s *Service) ListReminders(ctx context.Context, ownerID uuid.UUID, filter ReminderFilter) ([]Reminder, error) {
	filter.Page = normalizePage(filter.Page)
	return s.repository.listReminders(ctx, ownerID, filter)
}

func (s *Service) GetReminder(ctx context.Context, ownerID, reminderID uuid.UUID) (Reminder, error) {
	return s.repository.getReminder(ctx, ownerID, reminderID)
}

func validateHealthRecord(input CreateHealthRecordInput) error {
	count := 0
	for _, subject := range []*uuid.UUID{input.HamsterID, input.PupIdentityID, input.LitterID, input.EnclosureID} {
		if subject != nil && *subject != uuid.Nil {
			count++
		}
	}
	if count != 1 {
		return fmt.Errorf("%w: exactly one health record subject is required", ErrValidation)
	}
	if !oneOf(input.Type, "daily_check", "anomaly", "medication", "follow_up", "isolation", "death") {
		return fmt.Errorf("%w: invalid health record type", ErrValidation)
	}
	if input.ObservedAt.IsZero() || input.Notes != nil && len(*input.Notes) > 4000 {
		return fmt.Errorf("%w: invalid health record fields", ErrValidation)
	}
	if input.Severity != nil && !oneOf(*input.Severity, "info", "low", "medium", "high", "critical") {
		return fmt.Errorf("%w: invalid severity", ErrValidation)
	}
	if input.FollowUpAt != nil && input.FollowUpAt.Before(input.ObservedAt) {
		return fmt.Errorf("%w: follow_up_at must not precede observed_at", ErrValidation)
	}
	return nil
}

func validateCareTask(input CreateCareTaskInput) error {
	if !oneOf(input.TaskType, "pair_prep", "pairing_timeout", "separate_now", "gestation_window_open", "gestation_window_close", "gestation_window", "no_birth_review", "litter_observation", "pup_weight_check", "pup_weight_drop", "weaning_due", "weaning", "sex_separation_due", "sex_separation", "sex_recheck", "profile_creation_due", "profile_creation", "cleaning", "enclosure_cleaning", "medication", "follow_up", "custom") {
		return fmt.Errorf("%w: invalid task_type", ErrValidation)
	}
	if !oneOf(input.TargetType, "organization", "hamster", "litter", "enclosure", "breeding_plan", "pairing_attempt", "pup_identity") || input.TargetID == uuid.Nil {
		return fmt.Errorf("%w: invalid task target", ErrValidation)
	}
	if input.ScheduledAt.IsZero() || !oneOf(input.Priority, "low", "normal", "high", "urgent", "critical") {
		return fmt.Errorf("%w: invalid task fields", ErrValidation)
	}
	if input.Title != nil && len(*input.Title) > 240 || input.Notes != nil && len(*input.Notes) > 4000 {
		return fmt.Errorf("%w: task text is too long", ErrValidation)
	}
	seen := map[uuid.UUID]struct{}{}
	for _, subjectID := range input.SubjectIDs {
		if subjectID == uuid.Nil {
			return fmt.Errorf("%w: invalid task subject", ErrValidation)
		}
		if _, exists := seen[subjectID]; exists {
			return fmt.Errorf("%w: duplicate task subject", ErrValidation)
		}
		seen[subjectID] = struct{}{}
	}
	return nil
}

func validateCompleteTask(input CompleteTaskInput) error {
	if input.ExpectedVersion < 1 || input.CompletedAt.IsZero() || len(input.SubjectResults) == 0 {
		return fmt.Errorf("%w: completed_at, version and subject_results are required", ErrValidation)
	}
	if input.Notes != nil && len(*input.Notes) > 2000 {
		return fmt.Errorf("%w: completion notes are too long", ErrValidation)
	}
	seen := map[uuid.UUID]struct{}{}
	for _, result := range input.SubjectResults {
		if result.SubjectID == uuid.Nil || result.Status != "completed" && result.Status != "excepted" {
			return fmt.Errorf("%w: invalid subject result", ErrValidation)
		}
		if _, exists := seen[result.SubjectID]; exists {
			return fmt.Errorf("%w: duplicate subject result", ErrValidation)
		}
		seen[result.SubjectID] = struct{}{}
		if result.Status == "excepted" && (result.ExceptionReason == nil || strings.TrimSpace(*result.ExceptionReason) == "") {
			return fmt.Errorf("%w: exception reason is required", ErrValidation)
		}
	}
	return nil
}

func normalizePage(page Page) Page {
	if page.Limit < 1 || page.Limit > 200 {
		page.Limit = 50
	}
	if page.Offset < 0 {
		page.Offset = 0
	}
	return page
}

func oneOf(value string, allowed ...string) bool {
	for _, candidate := range allowed {
		if value == candidate {
			return true
		}
	}
	return false
}
