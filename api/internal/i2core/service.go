package i2core

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/scolvpet/scolvpet/api/internal/geneticcore"
)

type Service struct {
	repository Repository
}

func NewService(repository Repository) *Service {
	return &Service{repository: repository}
}

func (s *Service) ListHamsters(ctx context.Context, ownerID uuid.UUID, filter HamsterFilter) ([]Hamster, error) {
	filter.Page = normalizePage(filter.Page)
	return s.repository.ListHamsters(ctx, ownerID, filter)
}

func (s *Service) GetHamster(ctx context.Context, ownerID, hamsterID uuid.UUID) (Hamster, error) {
	return s.repository.GetHamster(ctx, ownerID, hamsterID)
}

func (s *Service) CreateHamster(ctx context.Context, ownerID uuid.UUID, options WriteOptions, input CreateHamsterInput) (WriteResult[Hamster], error) {
	input, err := normalizeCreateHamster(input)
	if err != nil {
		return WriteResult[Hamster]{}, err
	}
	command, err := buildCommand(ownerID, options, "POST", "/i2core/hamsters", input, 201)
	if err != nil {
		return WriteResult[Hamster]{}, err
	}
	return runWrite(ctx, s.repository, command, func(ctx context.Context, tx Transaction) (Hamster, error) {
		organizationID, err := tx.OrganizationID(ctx, ownerID)
		if err != nil {
			return Hamster{}, err
		}
		exists, err := tx.SpeciesRuleExists(ctx, ownerID, input.SpeciesRuleVersionID)
		if err != nil {
			return Hamster{}, err
		}
		if !exists {
			return Hamster{}, ErrNotFound
		}
		hamster, err := tx.InsertHamster(ctx, ownerID, organizationID, input)
		if err != nil {
			return Hamster{}, err
		}
		err = tx.AppendEvent(ctx, DomainEvent{
			OwnerID: ownerID, OrganizationID: organizationID, AggregateType: "hamster", AggregateID: hamster.ID,
			EventType: "HAMSTER_CREATED", Payload: map[string]any{"internal_code": hamster.InternalCode}, IdempotencyKey: command.IdempotencyKey,
		})
		return hamster, err
	})
}

func (s *Service) BatchCreateHamsters(ctx context.Context, ownerID uuid.UUID, options WriteOptions, input BatchCreateHamstersInput) (WriteResult[[]Hamster], error) {
	if len(input.Hamsters) == 0 {
		return WriteResult[[]Hamster]{}, validationError("hamsters is required")
	}
	seen := make(map[string]struct{}, len(input.Hamsters))
	for index := range input.Hamsters {
		normalized, err := normalizeCreateHamster(input.Hamsters[index])
		if err != nil {
			return WriteResult[[]Hamster]{}, fmt.Errorf("hamsters[%d]: %w", index, err)
		}
		if _, exists := seen[normalized.InternalCode]; exists {
			return WriteResult[[]Hamster]{}, fmt.Errorf("%w: internal_code %q", ErrDuplicate, normalized.InternalCode)
		}
		seen[normalized.InternalCode] = struct{}{}
		input.Hamsters[index] = normalized
	}
	command, err := buildCommand(ownerID, options, "POST", "/i2core/hamsters/batch", input, 201)
	if err != nil {
		return WriteResult[[]Hamster]{}, err
	}
	return runWrite(ctx, s.repository, command, func(ctx context.Context, tx Transaction) ([]Hamster, error) {
		organizationID, err := tx.OrganizationID(ctx, ownerID)
		if err != nil {
			return nil, err
		}
		created := make([]Hamster, 0, len(input.Hamsters))
		for _, item := range input.Hamsters {
			exists, err := tx.SpeciesRuleExists(ctx, ownerID, item.SpeciesRuleVersionID)
			if err != nil {
				return nil, err
			}
			if !exists {
				return nil, ErrNotFound
			}
			hamster, err := tx.InsertHamster(ctx, ownerID, organizationID, item)
			if err != nil {
				return nil, err
			}
			created = append(created, hamster)
		}
		ids := make([]uuid.UUID, 0, len(created))
		for _, hamster := range created {
			ids = append(ids, hamster.ID)
		}
		err = tx.AppendEvent(ctx, DomainEvent{
			OwnerID: ownerID, OrganizationID: organizationID, AggregateType: "hamster_batch", AggregateID: uuid.New(),
			EventType: "HAMSTERS_BATCH_CREATED", Payload: map[string]any{"hamster_ids": ids}, IdempotencyKey: command.IdempotencyKey,
		})
		return created, err
	})
}

func (s *Service) UpdateHamster(ctx context.Context, ownerID, hamsterID uuid.UUID, options WriteOptions, input UpdateHamsterInput) (WriteResult[Hamster], error) {
	if input.ExpectedVersion < 1 {
		return WriteResult[Hamster]{}, validationError("expected_version must be positive")
	}
	if err := normalizeHamsterUpdate(&input); err != nil {
		return WriteResult[Hamster]{}, err
	}
	command, err := buildCommand(ownerID, options, "PATCH", "/i2core/hamsters/"+hamsterID.String(), input, 200)
	if err != nil {
		return WriteResult[Hamster]{}, err
	}
	return runWrite(ctx, s.repository, command, func(ctx context.Context, tx Transaction) (Hamster, error) {
		current, err := tx.GetHamsterForUpdate(ctx, ownerID, hamsterID)
		if err != nil {
			return Hamster{}, err
		}
		if current.Version != input.ExpectedVersion {
			return Hamster{}, versionError(current.Version)
		}
		updated, err := tx.UpdateHamster(ctx, ownerID, hamsterID, input.ExpectedVersion, input)
		if err != nil {
			return Hamster{}, err
		}
		err = tx.AppendEvent(ctx, DomainEvent{
			OwnerID: ownerID, OrganizationID: updated.OrganizationID, AggregateType: "hamster", AggregateID: hamsterID,
			EventType: "HAMSTER_UPDATED", Payload: map[string]any{"version": updated.Version}, IdempotencyKey: command.IdempotencyKey,
		})
		return updated, err
	})
}

func (s *Service) ListEnclosures(ctx context.Context, ownerID uuid.UUID, filter EnclosureFilter) ([]Enclosure, error) {
	filter.Page = normalizePage(filter.Page)
	return s.repository.ListEnclosures(ctx, ownerID, filter)
}

func (s *Service) GetEnclosure(ctx context.Context, ownerID, enclosureID uuid.UUID) (Enclosure, error) {
	return s.repository.GetEnclosure(ctx, ownerID, enclosureID)
}

func (s *Service) CreateEnclosure(ctx context.Context, ownerID uuid.UUID, options WriteOptions, input CreateEnclosureInput) (WriteResult[Enclosure], error) {
	input, err := normalizeCreateEnclosure(input)
	if err != nil {
		return WriteResult[Enclosure]{}, err
	}
	command, err := buildCommand(ownerID, options, "POST", "/i2core/enclosures", input, 201)
	if err != nil {
		return WriteResult[Enclosure]{}, err
	}
	return runWrite(ctx, s.repository, command, func(ctx context.Context, tx Transaction) (Enclosure, error) {
		organizationID, err := tx.OrganizationID(ctx, ownerID)
		if err != nil {
			return Enclosure{}, err
		}
		enclosure, err := tx.InsertEnclosure(ctx, ownerID, organizationID, input)
		if err != nil {
			return Enclosure{}, err
		}
		err = tx.AppendEvent(ctx, DomainEvent{
			OwnerID: ownerID, OrganizationID: organizationID, AggregateType: "enclosure", AggregateID: enclosure.ID,
			EventType: "ENCLOSURE_CREATED", Payload: map[string]any{"code": enclosure.Code}, IdempotencyKey: command.IdempotencyKey,
		})
		return enclosure, err
	})
}

func (s *Service) UpdateEnclosure(ctx context.Context, ownerID, enclosureID uuid.UUID, options WriteOptions, input UpdateEnclosureInput) (WriteResult[Enclosure], error) {
	if input.ExpectedVersion < 1 {
		return WriteResult[Enclosure]{}, validationError("expected_version must be positive")
	}
	if err := normalizeEnclosureUpdate(&input); err != nil {
		return WriteResult[Enclosure]{}, err
	}
	command, err := buildCommand(ownerID, options, "PATCH", "/i2core/enclosures/"+enclosureID.String(), input, 200)
	if err != nil {
		return WriteResult[Enclosure]{}, err
	}
	return runWrite(ctx, s.repository, command, func(ctx context.Context, tx Transaction) (Enclosure, error) {
		current, err := tx.GetEnclosureForUpdate(ctx, ownerID, enclosureID)
		if err != nil {
			return Enclosure{}, err
		}
		if current.Version != input.ExpectedVersion {
			return Enclosure{}, versionError(current.Version)
		}
		updated, err := tx.UpdateEnclosure(ctx, ownerID, enclosureID, input.ExpectedVersion, input)
		if err != nil {
			return Enclosure{}, err
		}
		err = tx.AppendEvent(ctx, DomainEvent{
			OwnerID: ownerID, OrganizationID: updated.OrganizationID, AggregateType: "enclosure", AggregateID: enclosureID,
			EventType: "ENCLOSURE_UPDATED", Payload: map[string]any{"version": updated.Version}, IdempotencyKey: command.IdempotencyKey,
		})
		return updated, err
	})
}

func (s *Service) AdmitHamster(ctx context.Context, ownerID uuid.UUID, options WriteOptions, input AdmitHamsterInput) (WriteResult[StayChange], error) {
	if err := validateAdmit(input); err != nil {
		return WriteResult[StayChange]{}, err
	}
	command, err := buildCommand(ownerID, options, "POST", "/i2core/enclosure-stays", input, 201)
	if err != nil {
		return WriteResult[StayChange]{}, err
	}
	return runWrite(ctx, s.repository, command, func(ctx context.Context, tx Transaction) (StayChange, error) {
		hamster, err := tx.GetHamsterForUpdate(ctx, ownerID, input.HamsterID)
		if err != nil {
			return StayChange{}, err
		}
		enclosure, err := tx.GetEnclosureForUpdate(ctx, ownerID, input.EnclosureID)
		if err != nil {
			return StayChange{}, err
		}
		if input.ExpectedHamsterVersion > 0 && hamster.Version != input.ExpectedHamsterVersion {
			return StayChange{}, versionError(hamster.Version)
		}
		if enclosure.Version != input.ExpectedEnclosureVersion {
			return StayChange{}, versionError(enclosure.Version)
		}
		if hamster.CurrentEnclosureID != nil || enclosure.State == "disabled" {
			return StayChange{}, ErrStayConflict
		}
		conflict, err := tx.FindStayConflict(ctx, ownerID, input.EnclosureID, input.HamsterID, input.StartedAt, nil, nil, input.Purpose, input.PairingAttemptID)
		if err != nil {
			return StayChange{}, err
		}
		if conflict.HamsterConflict || conflict.EnclosureConflict {
			return StayChange{}, ErrStayConflict
		}
		stay, err := tx.InsertStay(ctx, ownerID, EnclosureStay{
			EnclosureID: input.EnclosureID, HamsterID: input.HamsterID, PairingAttemptID: input.PairingAttemptID,
			Purpose: input.Purpose, StartedAt: input.StartedAt, OperatorID: ownerID, Reason: input.Reason,
		})
		if err != nil {
			return StayChange{}, err
		}
		hamster, err = tx.UpdateHamsterEnclosure(ctx, ownerID, hamster.ID, hamster.Version, &enclosure.ID)
		if err != nil {
			return StayChange{}, err
		}
		enclosure, err = tx.RefreshEnclosureState(ctx, ownerID, enclosure.ID, enclosure.Version)
		if err != nil {
			return StayChange{}, err
		}
		change := StayChange{Stay: stay, Hamster: hamster, TargetEnclosure: &enclosure}
		err = tx.AppendEvent(ctx, DomainEvent{
			OwnerID: ownerID, OrganizationID: hamster.OrganizationID, AggregateType: "hamster", AggregateID: hamster.ID,
			EventType: "HAMSTER_ADMITTED", Payload: map[string]any{"stay_id": stay.ID, "enclosure_id": enclosure.ID}, IdempotencyKey: command.IdempotencyKey,
		})
		return change, err
	})
}

func (s *Service) MoveHamster(ctx context.Context, ownerID uuid.UUID, options WriteOptions, input MoveHamsterInput) (WriteResult[StayChange], error) {
	if err := validateMove(input); err != nil {
		return WriteResult[StayChange]{}, err
	}
	command, err := buildCommand(ownerID, options, "POST", "/i2core/enclosure-stays/"+input.StayID.String()+"/move", input, 201)
	if err != nil {
		return WriteResult[StayChange]{}, err
	}
	return runWrite(ctx, s.repository, command, func(ctx context.Context, tx Transaction) (StayChange, error) {
		previous, err := tx.GetStayForUpdate(ctx, ownerID, input.StayID)
		if err != nil {
			return StayChange{}, err
		}
		if previous.EndedAt != nil || (input.ExpectedStayVersion > 0 && previous.Version != input.ExpectedStayVersion) {
			if input.ExpectedStayVersion > 0 && previous.Version != input.ExpectedStayVersion {
				return StayChange{}, versionError(previous.Version)
			}
			return StayChange{}, ErrStayConflict
		}
		if previous.EnclosureID == input.TargetEnclosureID || !input.MovedAt.After(previous.StartedAt) {
			return StayChange{}, ErrStayConflict
		}
		hamster, err := tx.GetHamsterForUpdate(ctx, ownerID, previous.HamsterID)
		if err != nil {
			return StayChange{}, err
		}
		if (input.ExpectedHamsterVersion > 0 && hamster.Version != input.ExpectedHamsterVersion) || hamster.CurrentEnclosureID == nil || *hamster.CurrentEnclosureID != previous.EnclosureID {
			if input.ExpectedHamsterVersion > 0 && hamster.Version != input.ExpectedHamsterVersion {
				return StayChange{}, versionError(hamster.Version)
			}
			return StayChange{}, ErrStayConflict
		}
		if err := tx.LockEnclosures(ctx, ownerID, previous.EnclosureID, input.TargetEnclosureID); err != nil {
			return StayChange{}, err
		}
		source, err := tx.GetEnclosureForUpdate(ctx, ownerID, previous.EnclosureID)
		if err != nil {
			return StayChange{}, err
		}
		target, err := tx.GetEnclosureForUpdate(ctx, ownerID, input.TargetEnclosureID)
		if err != nil {
			return StayChange{}, err
		}
		if input.ExpectedSourceEnclosureVersion > 0 && source.Version != input.ExpectedSourceEnclosureVersion {
			return StayChange{}, versionError(source.Version)
		}
		if target.Version != input.ExpectedTargetEnclosureVersion {
			return StayChange{}, versionError(target.Version)
		}
		if target.State == "disabled" {
			return StayChange{}, ErrStayConflict
		}
		conflict, err := tx.FindStayConflict(ctx, ownerID, target.ID, hamster.ID, input.MovedAt, nil, &previous.ID, input.Purpose, input.PairingAttemptID)
		if err != nil {
			return StayChange{}, err
		}
		if conflict.HamsterConflict || conflict.EnclosureConflict {
			return StayChange{}, ErrStayConflict
		}
		ended, err := tx.EndStay(ctx, ownerID, previous.ID, previous.Version, input.MovedAt, input.Reason)
		if err != nil {
			return StayChange{}, err
		}
		stay, err := tx.InsertStay(ctx, ownerID, EnclosureStay{
			EnclosureID: target.ID, HamsterID: hamster.ID, PairingAttemptID: input.PairingAttemptID,
			Purpose: input.Purpose, StartedAt: input.MovedAt, OperatorID: ownerID, Reason: input.Reason,
		})
		if err != nil {
			return StayChange{}, err
		}
		hamster, err = tx.UpdateHamsterEnclosure(ctx, ownerID, hamster.ID, hamster.Version, &target.ID)
		if err != nil {
			return StayChange{}, err
		}
		source, err = tx.RefreshEnclosureState(ctx, ownerID, source.ID, source.Version)
		if err != nil {
			return StayChange{}, err
		}
		target, err = tx.RefreshEnclosureState(ctx, ownerID, target.ID, target.Version)
		if err != nil {
			return StayChange{}, err
		}
		change := StayChange{Stay: stay, PreviousStay: &ended, Hamster: hamster, SourceEnclosure: &source, TargetEnclosure: &target}
		err = tx.AppendEvent(ctx, DomainEvent{
			OwnerID: ownerID, OrganizationID: hamster.OrganizationID, AggregateType: "hamster", AggregateID: hamster.ID,
			EventType: "HAMSTER_MOVED", Payload: map[string]any{"from_stay_id": ended.ID, "to_stay_id": stay.ID, "from_enclosure_id": source.ID, "to_enclosure_id": target.ID}, IdempotencyKey: command.IdempotencyKey,
		})
		return change, err
	})
}

func (s *Service) EndStay(ctx context.Context, ownerID uuid.UUID, options WriteOptions, input EndStayInput) (WriteResult[StayChange], error) {
	if input.StayID == uuid.Nil || input.EndedAt.IsZero() || input.ExpectedStayVersion < 1 {
		return WriteResult[StayChange]{}, validationError("stay_id, ended_at and expected_stay_version are required")
	}
	command, err := buildCommand(ownerID, options, "POST", "/i2core/enclosure-stays/"+input.StayID.String()+"/end", input, 200)
	if err != nil {
		return WriteResult[StayChange]{}, err
	}
	return runWrite(ctx, s.repository, command, func(ctx context.Context, tx Transaction) (StayChange, error) {
		stay, err := tx.GetStayForUpdate(ctx, ownerID, input.StayID)
		if err != nil {
			return StayChange{}, err
		}
		if input.ExpectedStayVersion > 0 && stay.Version != input.ExpectedStayVersion {
			return StayChange{}, versionError(stay.Version)
		}
		if stay.EndedAt != nil || !input.EndedAt.After(stay.StartedAt) {
			return StayChange{}, ErrStayConflict
		}
		hamster, err := tx.GetHamsterForUpdate(ctx, ownerID, stay.HamsterID)
		if err != nil {
			return StayChange{}, err
		}
		enclosure, err := tx.GetEnclosureForUpdate(ctx, ownerID, stay.EnclosureID)
		if err != nil {
			return StayChange{}, err
		}
		if input.ExpectedHamsterVersion > 0 && hamster.Version != input.ExpectedHamsterVersion {
			return StayChange{}, versionError(hamster.Version)
		}
		if input.ExpectedEnclosureVersion > 0 && enclosure.Version != input.ExpectedEnclosureVersion {
			return StayChange{}, versionError(enclosure.Version)
		}
		stay, err = tx.EndStay(ctx, ownerID, stay.ID, stay.Version, input.EndedAt, input.Reason)
		if err != nil {
			return StayChange{}, err
		}
		hamster, err = tx.UpdateHamsterEnclosure(ctx, ownerID, hamster.ID, hamster.Version, nil)
		if err != nil {
			return StayChange{}, err
		}
		enclosure, err = tx.RefreshEnclosureState(ctx, ownerID, enclosure.ID, enclosure.Version)
		if err != nil {
			return StayChange{}, err
		}
		change := StayChange{Stay: stay, Hamster: hamster, SourceEnclosure: &enclosure}
		err = tx.AppendEvent(ctx, DomainEvent{
			OwnerID: ownerID, OrganizationID: hamster.OrganizationID, AggregateType: "hamster", AggregateID: hamster.ID,
			EventType: "HAMSTER_STAY_ENDED", Payload: map[string]any{"stay_id": stay.ID, "enclosure_id": enclosure.ID}, IdempotencyKey: command.IdempotencyKey,
		})
		return change, err
	})
}

func (s *Service) ListStayHistory(ctx context.Context, ownerID uuid.UUID, filter StayHistoryFilter) ([]EnclosureStay, error) {
	filter.Page = normalizePage(filter.Page)
	return s.repository.ListStayHistory(ctx, ownerID, filter)
}

func (s *Service) ListEnclosureCleanings(ctx context.Context, ownerID, enclosureID uuid.UUID, page Page) ([]EnclosureCleaning, error) {
	return s.repository.ListEnclosureCleanings(ctx, ownerID, enclosureID, normalizePage(page))
}

func (s *Service) GetEnclosureCleaning(ctx context.Context, ownerID, cleaningID uuid.UUID) (EnclosureCleaning, error) {
	return s.repository.GetEnclosureCleaning(ctx, ownerID, cleaningID)
}

func (s *Service) CreateEnclosureCleaning(ctx context.Context, ownerID uuid.UUID, options WriteOptions, input CreateEnclosureCleaningInput) (WriteResult[EnclosureCleaningChange], error) {
	if err := normalizeCleaning(&input); err != nil {
		return WriteResult[EnclosureCleaningChange]{}, err
	}
	command, err := buildCommand(ownerID, options, "POST", "/i2core/enclosures/"+input.EnclosureID.String()+"/cleanings", input, 201)
	if err != nil {
		return WriteResult[EnclosureCleaningChange]{}, err
	}
	return runWrite(ctx, s.repository, command, func(ctx context.Context, tx Transaction) (EnclosureCleaningChange, error) {
		enclosure, err := tx.GetEnclosureForUpdate(ctx, ownerID, input.EnclosureID)
		if err != nil {
			return EnclosureCleaningChange{}, err
		}
		if enclosure.Version != input.ExpectedEnclosureVersion {
			return EnclosureCleaningChange{}, versionError(enclosure.Version)
		}
		if input.CorrectsCleaningRecordID != nil {
			corrected, err := tx.GetEnclosureCleaningForUpdate(ctx, ownerID, *input.CorrectsCleaningRecordID)
			if err != nil {
				return EnclosureCleaningChange{}, err
			}
			if corrected.EnclosureID != input.EnclosureID {
				return EnclosureCleaningChange{}, ErrNotFound
			}
		}
		cleaning, err := tx.InsertEnclosureCleaning(ctx, ownerID, input)
		if err != nil {
			return EnclosureCleaningChange{}, err
		}
		enclosure, err = tx.MarkEnclosureClean(ctx, ownerID, enclosure.ID, enclosure.Version, input.PerformedAt)
		if err != nil {
			return EnclosureCleaningChange{}, err
		}
		change := EnclosureCleaningChange{Cleaning: cleaning, Enclosure: enclosure}
		err = tx.AppendEvent(ctx, DomainEvent{
			OwnerID: ownerID, OrganizationID: enclosure.OrganizationID, AggregateType: "enclosure", AggregateID: enclosure.ID,
			EventType: "ENCLOSURE_CLEANED", Payload: map[string]any{"cleaning_id": cleaning.ID, "cleaning_type": cleaning.CleaningType, "performed_at": cleaning.PerformedAt}, IdempotencyKey: command.IdempotencyKey,
		})
		return change, err
	})
}

func (s *Service) CreateWeight(ctx context.Context, ownerID uuid.UUID, options WriteOptions, input CreateWeightInput) (WriteResult[WeightRecord], error) {
	input, err := normalizeWeight(input)
	if err != nil {
		return WriteResult[WeightRecord]{}, err
	}
	command, err := buildCommand(ownerID, options, "POST", "/i2core/weight-records", input, 201)
	if err != nil {
		return WriteResult[WeightRecord]{}, err
	}
	return runWrite(ctx, s.repository, command, func(ctx context.Context, tx Transaction) (WeightRecord, error) {
		subject, err := tx.ResolveWeightSubject(ctx, ownerID, input)
		if err != nil {
			return WeightRecord{}, err
		}
		birth, previous, err := tx.PreviousWeights(ctx, ownerID, input)
		if err != nil {
			return WeightRecord{}, err
		}
		record, err := tx.InsertWeight(ctx, ownerID, subject.OrganizationID, input, subject, birth, previous)
		if err != nil {
			return WeightRecord{}, err
		}
		err = tx.AppendEvent(ctx, DomainEvent{
			OwnerID: ownerID, OrganizationID: subject.OrganizationID, AggregateType: "weight_record", AggregateID: record.ID,
			EventType: "WEIGHT_RECORDED", Payload: map[string]any{"subject_type": record.SubjectType, "weight_g": record.WeightG}, IdempotencyKey: command.IdempotencyKey,
		})
		return record, err
	})
}

func (s *Service) ListWeightRecords(ctx context.Context, ownerID uuid.UUID, filter WeightRecordFilter) ([]WeightRecord, error) {
	filter.Page = normalizePage(filter.Page)
	if filter.RecordedFrom != nil && filter.RecordedTo != nil && filter.RecordedTo.Before(*filter.RecordedFrom) {
		return nil, validationError("recorded_to must not be before recorded_from")
	}
	return s.repository.ListWeightRecords(ctx, ownerID, filter)
}

func (s *Service) BatchCreateWeights(ctx context.Context, ownerID uuid.UUID, options WriteOptions, input BatchCreateWeightsInput) (WriteResult[[]WeightRecord], error) {
	if len(input.Records) == 0 {
		return WriteResult[[]WeightRecord]{}, validationError("records is required")
	}
	acquisitions := map[string]struct{}{}
	for index := range input.Records {
		normalized, err := normalizeWeight(input.Records[index])
		if err != nil {
			return WriteResult[[]WeightRecord]{}, fmt.Errorf("records[%d]: %w", index, err)
		}
		if normalized.AcquisitionKey != nil {
			if _, exists := acquisitions[*normalized.AcquisitionKey]; exists {
				return WriteResult[[]WeightRecord]{}, fmt.Errorf("%w: acquisition_key %q", ErrDuplicate, *normalized.AcquisitionKey)
			}
			acquisitions[*normalized.AcquisitionKey] = struct{}{}
		}
		input.Records[index] = normalized
	}
	command, err := buildCommand(ownerID, options, "POST", "/i2core/weight-records/batch", input, 201)
	if err != nil {
		return WriteResult[[]WeightRecord]{}, err
	}
	return runWrite(ctx, s.repository, command, func(ctx context.Context, tx Transaction) ([]WeightRecord, error) {
		records := make([]WeightRecord, 0, len(input.Records))
		var organizationID uuid.UUID
		for _, item := range input.Records {
			subject, err := tx.ResolveWeightSubject(ctx, ownerID, item)
			if err != nil {
				return nil, err
			}
			if organizationID == uuid.Nil {
				organizationID = subject.OrganizationID
			} else if organizationID != subject.OrganizationID {
				return nil, validationError("batch subjects must belong to one organization")
			}
			birth, previous, err := tx.PreviousWeights(ctx, ownerID, item)
			if err != nil {
				return nil, err
			}
			record, err := tx.InsertWeight(ctx, ownerID, subject.OrganizationID, item, subject, birth, previous)
			if err != nil {
				return nil, err
			}
			records = append(records, record)
		}
		ids := make([]uuid.UUID, 0, len(records))
		for _, record := range records {
			ids = append(ids, record.ID)
		}
		err = tx.AppendEvent(ctx, DomainEvent{
			OwnerID: ownerID, OrganizationID: organizationID, AggregateType: "weight_batch", AggregateID: uuid.New(),
			EventType: "WEIGHTS_BATCH_RECORDED", Payload: map[string]any{"weight_record_ids": ids}, IdempotencyKey: command.IdempotencyKey,
		})
		return records, err
	})
}

func (s *Service) ListLitters(ctx context.Context, ownerID uuid.UUID, filter LitterFilter) ([]Litter, error) {
	filter.Page = normalizePage(filter.Page)
	return s.repository.ListLitters(ctx, ownerID, filter)
}

func (s *Service) GetLitter(ctx context.Context, ownerID, litterID uuid.UUID) (Litter, error) {
	return s.repository.GetLitter(ctx, ownerID, litterID)
}

func (s *Service) GetLitterRelations(ctx context.Context, ownerID, litterID uuid.UUID) (LitterRelations, error) {
	return s.repository.GetLitterRelations(ctx, ownerID, litterID)
}

func (s *Service) ListLitterParents(ctx context.Context, ownerID, litterID uuid.UUID, page Page) ([]LitterParent, error) {
	return s.repository.ListLitterParents(ctx, ownerID, litterID, normalizePage(page))
}

func (s *Service) ListLitterMembers(ctx context.Context, ownerID, litterID uuid.UUID, page Page) ([]LitterMember, error) {
	return s.repository.ListLitterMembers(ctx, ownerID, litterID, normalizePage(page))
}

func (s *Service) CreateLitterParent(ctx context.Context, ownerID uuid.UUID, options WriteOptions, input CreateLitterParentInput) (WriteResult[LitterParentChange], error) {
	if err := normalizeLitterParent(&input); err != nil {
		return WriteResult[LitterParentChange]{}, err
	}
	command, err := buildCommand(ownerID, options, "POST", "/i2core/litters/"+input.LitterID.String()+"/parents", input, 201)
	if err != nil {
		return WriteResult[LitterParentChange]{}, err
	}
	return runWrite(ctx, s.repository, command, func(ctx context.Context, tx Transaction) (LitterParentChange, error) {
		litter, err := tx.GetLitterForUpdate(ctx, ownerID, input.LitterID)
		if err != nil {
			return LitterParentChange{}, err
		}
		if litter.Version != input.ExpectedLitterVersion {
			return LitterParentChange{}, versionError(litter.Version)
		}
		parent, err := tx.GetHamsterForUpdate(ctx, ownerID, input.HamsterID)
		if err != nil {
			return LitterParentChange{}, err
		}
		if parent.OrganizationID != litter.OrganizationID {
			return LitterParentChange{}, ErrNotFound
		}
		if (input.Role == "sire" && parent.Sex == "female") || (input.Role == "dam" && parent.Sex == "male") || parent.Sex == "unknown" {
			return LitterParentChange{}, validationError("hamster sex conflicts with litter parent role")
		}
		memberIDs, err := tx.LitterHamsterMemberIDs(ctx, ownerID, litter.ID)
		if err != nil {
			return LitterParentChange{}, err
		}
		for _, memberID := range memberIDs {
			if memberID == parent.ID {
				return LitterParentChange{}, ErrPedigreeCycle
			}
			cycle, err := tx.CheckPedigreeCycle(ctx, ownerID, parent.ID, memberID)
			if err != nil {
				return LitterParentChange{}, err
			}
			if cycle {
				return LitterParentChange{}, ErrPedigreeCycle
			}
		}
		current, err := tx.GetActiveLitterParentForUpdate(ctx, ownerID, litter.ID, input.Role)
		if err != nil {
			return LitterParentChange{}, err
		}
		var correctsID *uuid.UUID
		if current != nil {
			if input.CorrectionReason == nil {
				return LitterParentChange{}, ErrDuplicate
			}
			correctsID = &current.ID
			if err := tx.SupersedeLitterParent(ctx, ownerID, current.ID, *input.CorrectionReason); err != nil {
				return LitterParentChange{}, err
			}
		}
		created, err := tx.InsertLitterParent(ctx, ownerID, input, correctsID)
		if err != nil {
			return LitterParentChange{}, err
		}
		litter, err = tx.TouchLitter(ctx, ownerID, litter.ID, litter.Version)
		if err != nil {
			return LitterParentChange{}, err
		}
		change := LitterParentChange{Parent: created, Litter: litter}
		err = tx.AppendEvent(ctx, DomainEvent{
			OwnerID: ownerID, OrganizationID: litter.OrganizationID, AggregateType: "litter", AggregateID: litter.ID,
			EventType: "LITTER_PARENT_CREATED", Payload: map[string]any{"litter_parent_id": created.ID, "hamster_id": parent.ID, "role": created.Role}, IdempotencyKey: command.IdempotencyKey,
		})
		return change, err
	})
}

func (s *Service) ListPedigreeParentages(ctx context.Context, ownerID uuid.UUID, filter PedigreeParentageFilter) ([]PedigreeParentage, error) {
	filter.Page = normalizePage(filter.Page)
	return s.repository.ListPedigreeParentages(ctx, ownerID, filter)
}

func (s *Service) GetHamsterPedigree(ctx context.Context, ownerID, hamsterID uuid.UUID, generations int) (PedigreeGraph, error) {
	if generations == 0 {
		generations = 4
	}
	if generations < 1 || generations > 8 {
		return PedigreeGraph{}, validationError("generations must be between 1 and 8")
	}
	return s.repository.GetHamsterPedigree(ctx, ownerID, hamsterID, generations)
}

func (s *Service) CreatePedigreeParentage(ctx context.Context, ownerID uuid.UUID, options WriteOptions, input CreatePedigreeParentageInput) (WriteResult[PedigreeParentage], error) {
	if err := normalizeParentage(&input); err != nil {
		return WriteResult[PedigreeParentage]{}, err
	}
	command, err := buildCommand(ownerID, options, "POST", "/i2core/pedigree-parentages", input, 201)
	if err != nil {
		return WriteResult[PedigreeParentage]{}, err
	}
	return runWrite(ctx, s.repository, command, func(ctx context.Context, tx Transaction) (PedigreeParentage, error) {
		if input.ParentID == input.ChildID {
			return PedigreeParentage{}, ErrPedigreeCycle
		}
		parent, err := tx.GetHamsterForUpdate(ctx, ownerID, input.ParentID)
		if err != nil {
			return PedigreeParentage{}, err
		}
		child, err := tx.GetHamsterForUpdate(ctx, ownerID, input.ChildID)
		if err != nil {
			return PedigreeParentage{}, err
		}
		if input.ExpectedParentVersion > 0 && parent.Version != input.ExpectedParentVersion {
			return PedigreeParentage{}, versionError(parent.Version)
		}
		if input.ExpectedChildVersion > 0 && child.Version != input.ExpectedChildVersion {
			return PedigreeParentage{}, versionError(child.Version)
		}
		if parent.OrganizationID != child.OrganizationID {
			return PedigreeParentage{}, ErrNotFound
		}
		if (input.Role == "sire" && parent.Sex == "female") || (input.Role == "dam" && parent.Sex == "male") {
			return PedigreeParentage{}, validationError("hamster sex conflicts with parentage role")
		}
		cycle, err := tx.CheckPedigreeCycle(ctx, ownerID, input.ParentID, input.ChildID)
		if err != nil {
			return PedigreeParentage{}, err
		}
		if cycle {
			return PedigreeParentage{}, ErrPedigreeCycle
		}
		current, err := tx.GetActivePedigreeParentageForUpdate(ctx, ownerID, input.ChildID, input.Role)
		if err != nil {
			return PedigreeParentage{}, err
		}
		var correctsID *uuid.UUID
		if current != nil {
			if current.ParentID == input.ParentID {
				return *current, nil // already the active edge
			}
			if input.CorrectionReason == nil || strings.TrimSpace(*input.CorrectionReason) == "" {
				return PedigreeParentage{}, ErrDuplicate
			}
			correctsID = &current.ID
			if err := tx.SupersedePedigreeParentage(ctx, ownerID, current.ID, strings.TrimSpace(*input.CorrectionReason)); err != nil {
				return PedigreeParentage{}, err
			}
		}
		parentage, err := tx.InsertPedigreeParentage(ctx, ownerID, input, correctsID)
		if err != nil {
			return PedigreeParentage{}, err
		}
		eventType := "PEDIGREE_PARENTAGE_CREATED"
		if correctsID != nil {
			eventType = "PEDIGREE_PARENTAGE_REPLACED"
		}
		err = tx.AppendEvent(ctx, DomainEvent{
			OwnerID: ownerID, OrganizationID: child.OrganizationID, AggregateType: "hamster", AggregateID: child.ID,
			EventType: eventType, Payload: map[string]any{
				"parentage_id": parentage.ID, "parent_id": parent.ID, "role": parentage.Role,
				"corrects_parentage_id": correctsID, "correction_reason": input.CorrectionReason,
			}, IdempotencyKey: command.IdempotencyKey,
		})
		return parentage, err
	})
}

// EndPedigreeParentage supersedes the active parentage for child+role without replacement.
func (s *Service) EndPedigreeParentage(ctx context.Context, ownerID uuid.UUID, options WriteOptions, input EndPedigreeParentageInput) (WriteResult[PedigreeParentage], error) {
	role := strings.TrimSpace(strings.ToLower(input.Role))
	if role != "sire" && role != "dam" {
		return WriteResult[PedigreeParentage]{}, validationError("invalid parentage role")
	}
	reason := strings.TrimSpace(input.CorrectionReason)
	if reason == "" {
		return WriteResult[PedigreeParentage]{}, validationError("correction_reason is required to end parentage")
	}
	input.Role = role
	input.CorrectionReason = reason
	command, err := buildCommand(ownerID, options, "POST", "/i2core/pedigree-parentages/end", input, 200)
	if err != nil {
		return WriteResult[PedigreeParentage]{}, err
	}
	return runWrite(ctx, s.repository, command, func(ctx context.Context, tx Transaction) (PedigreeParentage, error) {
		child, err := tx.GetHamsterForUpdate(ctx, ownerID, input.ChildID)
		if err != nil {
			return PedigreeParentage{}, err
		}
		current, err := tx.GetActivePedigreeParentageForUpdate(ctx, ownerID, input.ChildID, input.Role)
		if err != nil {
			return PedigreeParentage{}, err
		}
		if current == nil {
			return PedigreeParentage{}, ErrNotFound
		}
		if err := tx.SupersedePedigreeParentage(ctx, ownerID, current.ID, reason); err != nil {
			return PedigreeParentage{}, err
		}
		// Re-read for response (superseded row).
		ended := *current
		now := time.Now().UTC()
		ended.Status = "superseded"
		ended.ValidTo = &now
		note := reason
		ended.Notes = &note
		err = tx.AppendEvent(ctx, DomainEvent{
			OwnerID: ownerID, OrganizationID: child.OrganizationID, AggregateType: "hamster", AggregateID: child.ID,
			EventType: "PEDIGREE_PARENTAGE_ENDED", Payload: map[string]any{
				"parentage_id": current.ID, "parent_id": current.ParentID, "role": current.Role,
				"correction_reason": reason,
			}, IdempotencyKey: command.IdempotencyKey,
		})
		return ended, err
	})
}

func runWrite[T any](ctx context.Context, repository Repository, command Command, fn func(context.Context, Transaction) (T, error)) (WriteResult[T], error) {
	stored, err := repository.Execute(ctx, command, func(ctx context.Context, tx Transaction) (any, error) {
		return fn(ctx, tx)
	})
	if err != nil {
		return WriteResult[T]{}, err
	}
	var value T
	if err := json.Unmarshal(stored.Body, &value); err != nil {
		return WriteResult[T]{}, err
	}
	return WriteResult[T]{Value: value, Replayed: stored.Replayed}, nil
}

func buildCommand(ownerID uuid.UUID, options WriteOptions, defaultMethod, defaultPath string, input any, status int) (Command, error) {
	if ownerID == uuid.Nil {
		return Command{}, validationError("owner_id is required")
	}
	if strings.TrimSpace(options.IdempotencyKey) == "" {
		return Command{}, ErrIdempotencyKeyRequired
	}
	payload := options.RequestPayload
	if len(payload) == 0 {
		var err error
		payload, err = json.Marshal(input)
		if err != nil {
			return Command{}, err
		}
	}
	method := strings.TrimSpace(options.RequestMethod)
	if method == "" {
		method = defaultMethod
	}
	path := strings.TrimSpace(options.RequestPath)
	if path == "" {
		path = defaultPath
	}
	return Command{OwnerID: ownerID, IdempotencyKey: strings.TrimSpace(options.IdempotencyKey), Method: method, Path: path, Payload: payload, SuccessStatus: status}, nil
}

func normalizeCreateHamster(input CreateHamsterInput) (CreateHamsterInput, error) {
	input.InternalCode = strings.TrimSpace(input.InternalCode)
	if input.InternalCode == "" || input.SpeciesRuleVersionID == uuid.Nil {
		return input, validationError("internal_code and species_rule_version_id are required")
	}
	input.Name = trimmedOptional(input.Name)
	input.VarietyCode = trimmedOptional(input.VarietyCode)
	input.Notes = trimmedOptional(input.Notes)
	input.Sex = defaultString(input.Sex, "unknown")
	input.SourceType = defaultString(input.SourceType, "introduced")
	input.LifecycleStatus = defaultString(input.LifecycleStatus, "active")
	input.BreedingStatus = defaultString(input.BreedingStatus, "candidate")
	if !oneOf(input.Sex, "male", "female", "unknown") || !oneOf(input.SourceType, "born_here", "introduced", "customer", "imported") ||
		!oneOf(input.LifecycleStatus, "active", "transferred", "retired", "deceased") || !oneOf(input.BreedingStatus, "candidate", "active", "resting", "retired") {
		return input, validationError("invalid hamster enum value")
	}
	if input.SexConfidence != nil && (*input.SexConfidence < 0 || *input.SexConfidence > 1) {
		return input, validationError("sex_confidence must be between 0 and 1")
	}
	if input.Phenotype == nil {
		input.Phenotype = map[string]any{}
	}
	if input.Tags == nil {
		input.Tags = []string{}
	}
	// Align variety_code / phenotype with authority core table when possible.
	if err := applyCorePhenotypeOnCreate(&input); err != nil {
		return input, err
	}
	return input, nil
}

func normalizeHamsterUpdate(input *UpdateHamsterInput) error {
	if input.InternalCode != nil {
		value := strings.TrimSpace(*input.InternalCode)
		if value == "" {
			return validationError("internal_code must not be empty")
		}
		input.InternalCode = &value
	}
	input.Name = trimmedOptional(input.Name)
	input.VarietyCode = trimmedOptional(input.VarietyCode)
	input.Notes = trimmedOptional(input.Notes)
	if input.Sex != nil {
		value := strings.TrimSpace(*input.Sex)
		if !oneOf(value, "male", "female", "unknown") {
			return validationError("invalid sex")
		}
		input.Sex = &value
	}
	if input.SexConfidence != nil && (*input.SexConfidence < 0 || *input.SexConfidence > 1) {
		return validationError("sex_confidence must be between 0 and 1")
	}
	if err := applyCorePhenotypeOnUpdate(input); err != nil {
		return err
	}
	return nil
}

// applyCorePhenotypeOnCreate aligns variety_code + phenotype JSON with the authority table.
// Accepts variety_code as "poly|蜜波利" or bare unique labels, or phenotype.{series,label}.
func applyCorePhenotypeOnCreate(input *CreateHamsterInput) error {
	series, label, err := resolveCorePhenotype(input.VarietyCode, input.Phenotype)
	if err != nil {
		return err
	}
	if series == "" {
		return nil
	}
	code := geneticcore.EncodeVarietyCode(series, label)
	input.VarietyCode = &code
	input.Phenotype = geneticcore.PhenotypeMapFromCore(series, label)
	return nil
}

func applyCorePhenotypeOnUpdate(input *UpdateHamsterInput) error {
	// Prefer explicit phenotype map, else variety_code.
	var variety *string
	if input.VarietyCode != nil {
		variety = input.VarietyCode
	}
	series, label, err := resolveCorePhenotype(variety, input.Phenotype)
	if err != nil {
		return err
	}
	if series == "" {
		return nil
	}
	code := geneticcore.EncodeVarietyCode(series, label)
	input.VarietyCode = &code
	input.ClearVariety = false
	input.Phenotype = geneticcore.PhenotypeMapFromCore(series, label)
	return nil
}

func resolveCorePhenotype(variety *string, phenotype map[string]any) (series, label string, err error) {
	// Structured phenotype first.
	if phenotype != nil {
		s, _ := phenotype[geneticcore.PhenotypeKeySeries].(string)
		l, _ := phenotype[geneticcore.PhenotypeKeyLabel].(string)
		s = strings.TrimSpace(s)
		l = strings.TrimSpace(l)
		if s != "" || l != "" {
			return geneticcore.ValidateCorePhenotype(s, l)
		}
	}
	if variety == nil || strings.TrimSpace(*variety) == "" {
		return "", "", nil
	}
	// Free-text variety: only enforce when it looks like core encoding or exact table label.
	raw := strings.TrimSpace(*variety)
	if strings.Contains(raw, geneticcore.VarietyCodeSep) {
		s, l, ok := geneticcore.DecodeVarietyCode(raw)
		if !ok {
			return "", "", validationError("variety_code is not a valid core phenotype (series|label)")
		}
		return geneticcore.ValidateCorePhenotype(s, l)
	}
	// Bare label matching authority table
	if s, l, ok := geneticcore.DecodeVarietyCode(raw); ok {
		return s, l, nil
	}
	// Non-core free text allowed for backward compatibility
	return "", "", nil
}

func normalizeCreateEnclosure(input CreateEnclosureInput) (CreateEnclosureInput, error) {
	input.Code = strings.TrimSpace(input.Code)
	if input.Code == "" {
		return input, validationError("code is required")
	}
	input.RackCode = trimmedOptional(input.RackCode)
	input.LevelCode = trimmedOptional(input.LevelCode)
	input.DisabledReason = trimmedOptional(input.DisabledReason)
	if input.Capacity == 0 {
		input.Capacity = 1
	}
	input.State = defaultString(input.State, "vacant")
	input.Cleanliness = defaultString(input.Cleanliness, "clean")
	if input.Capacity < 1 || !validEnclosureState(input.State) || !oneOf(input.Cleanliness, "clean", "partial_due", "full_due") {
		return input, validationError("invalid enclosure input")
	}
	if input.State == "disabled" && input.DisabledReason == nil {
		return input, validationError("disabled_reason is required for disabled enclosure")
	}
	if input.Dimensions == nil {
		input.Dimensions = map[string]any{}
	}
	if input.Equipment == nil {
		input.Equipment = []string{}
	}
	return input, nil
}

func normalizeEnclosureUpdate(input *UpdateEnclosureInput) error {
	if input.Code != nil {
		value := strings.TrimSpace(*input.Code)
		if value == "" {
			return validationError("code must not be empty")
		}
		input.Code = &value
	}
	input.RackCode = trimmedOptional(input.RackCode)
	input.LevelCode = trimmedOptional(input.LevelCode)
	input.DisabledReason = trimmedOptional(input.DisabledReason)
	if input.Capacity != nil && *input.Capacity < 1 {
		return validationError("capacity must be positive")
	}
	if input.State != nil {
		value := strings.TrimSpace(*input.State)
		if !validEnclosureState(value) {
			return validationError("invalid enclosure state")
		}
		input.State = &value
		if value == "disabled" && input.DisabledReason == nil && !input.ClearDisabledReason {
			return validationError("disabled_reason is required for disabled enclosure")
		}
	}
	if input.Cleanliness != nil {
		value := strings.TrimSpace(*input.Cleanliness)
		if !oneOf(value, "clean", "partial_due", "full_due") {
			return validationError("invalid cleanliness")
		}
		input.Cleanliness = &value
	}
	return nil
}

func validateAdmit(input AdmitHamsterInput) error {
	if input.HamsterID == uuid.Nil || input.EnclosureID == uuid.Nil || input.StartedAt.IsZero() || input.ExpectedEnclosureVersion < 1 {
		return validationError("hamster_id, enclosure_id, started_at and expected_enclosure_version are required")
	}
	return validateStayPurpose(input.Purpose, input.PairingAttemptID)
}

func validateMove(input MoveHamsterInput) error {
	if input.StayID == uuid.Nil || input.TargetEnclosureID == uuid.Nil || input.MovedAt.IsZero() || input.ExpectedTargetEnclosureVersion < 1 {
		return validationError("stay_id, target_enclosure_id, moved_at and expected_target_enclosure_version are required")
	}
	return validateStayPurpose(input.Purpose, input.PairingAttemptID)
}

func validateStayPurpose(purpose string, pairingAttemptID *uuid.UUID) error {
	if !oneOf(purpose, "single", "pairing_temp", "gestation", "isolation", "dam_with_litter") {
		return validationError("invalid stay purpose")
	}
	if (purpose == "pairing_temp") != (pairingAttemptID != nil) {
		return validationError("pairing_temp requires pairing_attempt_id and other purposes forbid it")
	}
	return nil
}

func normalizeWeight(input CreateWeightInput) (CreateWeightInput, error) {
	if input.WeightG <= 0 || input.WeightG > 5000 {
		return input, ErrInvalidWeight
	}
	input.SubjectType = strings.TrimSpace(input.SubjectType)
	input.MeasurementKind = defaultString(input.MeasurementKind, "individual")
	input.Source = defaultString(input.Source, "manual")
	if input.RecordedAt.IsZero() {
		input.RecordedAt = time.Now().UTC()
	}
	input.AcquisitionKey = trimmedOptional(input.AcquisitionKey)
	input.CorrectionReason = trimmedOptional(input.CorrectionReason)
	if !oneOf(input.Source, "manual", "bluetooth_scale", "import") {
		return input, ErrInvalidWeight
	}
	valid := false
	switch input.SubjectType {
	case "hamster":
		valid = input.HamsterID != nil && input.PupIdentityID == nil && input.LitterID == nil && input.MeasurementKind == "individual" && input.SubjectCount == nil
	case "pup_identity":
		valid = input.PupIdentityID != nil && input.HamsterID == nil && input.LitterID == nil && input.MeasurementKind == "individual" && input.SubjectCount == nil
	case "litter":
		valid = input.LitterID != nil && input.HamsterID == nil && input.PupIdentityID == nil && oneOf(input.MeasurementKind, "litter_total", "litter_average") && input.SubjectCount != nil && *input.SubjectCount > 0
	}
	if !valid || (input.CorrectsWeightRecordID != nil && input.CorrectionReason == nil) {
		return input, ErrInvalidWeight
	}
	return input, nil
}

func normalizeCleaning(input *CreateEnclosureCleaningInput) error {
	if input.EnclosureID == uuid.Nil || input.PerformedAt.IsZero() || input.ExpectedEnclosureVersion < 1 {
		return validationError("enclosure_id, performed_at and expected_enclosure_version are required")
	}
	input.CleaningType = strings.TrimSpace(input.CleaningType)
	if !oneOf(input.CleaningType, "partial", "full", "disinfection") {
		return validationError("invalid cleaning_type")
	}
	input.Notes = trimmedOptional(input.Notes)
	input.CorrectionReason = trimmedOptional(input.CorrectionReason)
	if input.CorrectsCleaningRecordID != nil && input.CorrectionReason == nil {
		return validationError("correction_reason is required")
	}
	if input.Supplies == nil {
		input.Supplies = map[string]any{}
	}
	return nil
}

func normalizeParentage(input *CreatePedigreeParentageInput) error {
	if input.ParentID == uuid.Nil || input.ChildID == uuid.Nil {
		return validationError("parent_id and child_id are required")
	}
	input.Role = strings.TrimSpace(input.Role)
	input.EvidenceType = defaultString(input.EvidenceType, "manual")
	switch input.EvidenceType {
	case "litter_derived":
		input.EvidenceType = "litter_inferred"
	case "breeding_plan":
		input.EvidenceType = "system"
	case "verified_document":
		input.EvidenceType = "document"
	}
	if !oneOf(input.Role, "sire", "dam") || !oneOf(input.EvidenceType, "system", "litter_inferred", "manual", "imported", "document", "dna") {
		return validationError("invalid parentage role or evidence type")
	}
	if input.Confidence < 0 || input.Confidence > 1 {
		return validationError("confidence must be between 0 and 1")
	}
	if input.EvidencePayload == nil {
		input.EvidencePayload = map[string]any{}
	}
	input.Notes = trimmedOptional(input.Notes)
	if input.Notes != nil {
		input.EvidencePayload["notes"] = *input.Notes
	}
	if input.ValidFrom.IsZero() {
		input.ValidFrom = time.Now().UTC()
	}
	return nil
}

func normalizeLitterParent(input *CreateLitterParentInput) error {
	if input.LitterID == uuid.Nil || input.HamsterID == uuid.Nil || input.ExpectedLitterVersion < 1 {
		return validationError("litter_id, hamster_id and expected_litter_version are required")
	}
	input.Role = strings.TrimSpace(input.Role)
	input.EvidenceType = strings.TrimSpace(input.EvidenceType)
	switch input.EvidenceType {
	case "breeding_plan":
		input.EvidenceType = "litter_inferred"
	case "verified_document":
		input.EvidenceType = "document"
	}
	if !oneOf(input.Role, "sire", "dam") || !oneOf(input.EvidenceType, "litter_inferred", "imported", "manual", "document") {
		return validationError("invalid litter parent role or evidence type")
	}
	if input.Confidence < 0 || input.Confidence > 1 {
		return validationError("confidence must be between 0 and 1")
	}
	input.CorrectionReason = trimmedOptional(input.CorrectionReason)
	if input.EvidencePayload == nil {
		input.EvidencePayload = map[string]any{}
	}
	return nil
}

func normalizePage(page Page) Page {
	if page.Limit <= 0 {
		page.Limit = 50
	}
	if page.Limit > 200 {
		page.Limit = 200
	}
	if page.Offset < 0 {
		page.Offset = 0
	}
	return page
}

func validationError(message string) error {
	return fmt.Errorf("%w: %s", ErrValidation, message)
}

func versionError(current int) error {
	return &VersionError{Current: current}
}

func trimmedOptional(value *string) *string {
	if value == nil {
		return nil
	}
	trimmed := strings.TrimSpace(*value)
	if trimmed == "" {
		return nil
	}
	return &trimmed
}

func defaultString(value, fallback string) string {
	value = strings.TrimSpace(value)
	if value == "" {
		return fallback
	}
	return value
}

func oneOf(value string, allowed ...string) bool {
	for _, candidate := range allowed {
		if value == candidate {
			return true
		}
	}
	return false
}

func validEnclosureState(value string) bool {
	return oneOf(value, "vacant", "occupied_single", "pairing_temp", "gestation", "dam_with_litter", "isolation", "cleaning_due", "disabled")
}

func isNotFound(err error) bool {
	return errors.Is(err, ErrNotFound)
}
