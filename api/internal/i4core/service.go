package i4core

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"sort"
	"strings"
	"time"

	"github.com/google/uuid"
)

type Service struct{ repository Repository }

func NewService(repository Repository) *Service { return &Service{repository: repository} }

func (s *Service) ConfirmBirth(ctx context.Context, ownerID, planID uuid.UUID, options WriteOptions, input ConfirmBirthInput) (WriteResult[ConfirmBirthResult], error) {
	if err := validateConfirmBirth(ownerID, planID, &input); err != nil {
		return WriteResult[ConfirmBirthResult]{}, err
	}
	command, err := buildCommand(ownerID, options, "POST", "/v1/breeding-plans/"+planID.String()+"/confirm-birth", input, 200)
	if err != nil {
		return WriteResult[ConfirmBirthResult]{}, err
	}
	return runWrite(ctx, s.repository, command, func(ctx context.Context, tx Transaction) (ConfirmBirthResult, error) {
		plan, err := tx.GetPlanForUpdate(ctx, ownerID, planID)
		if err != nil {
			return ConfirmBirthResult{}, err
		}
		if plan.Version != input.ExpectedVersion {
			return ConfirmBirthResult{}, &VersionError{Current: plan.Version}
		}
		if plan.State != "gestation" {
			return ConfirmBirthResult{}, &StateError{Message: "confirm-birth 仅允许 gestation 状态"}
		}
		if input.InitialAliveCount == 0 {
			eventID, err := tx.AppendEvent(ctx, DomainEvent{
				OwnerID: ownerID, OrganizationID: plan.OrganizationID, AggregateType: "breeding_plan", AggregateID: plan.ID,
				EventType: "BIRTH_CONFIRMED_NO_LIVE_PUPS", OccurredAt: input.BornAt,
				Payload:        map[string]any{"born_at": input.BornAt, "initial_other_count": input.InitialOtherCount, "outcome_reason": input.OutcomeReason},
				IdempotencyKey: command.IdempotencyKey,
			})
			if err != nil {
				return ConfirmBirthResult{}, err
			}
			updated, err := tx.UpdatePlanBirth(ctx, ownerID, plan.ID, plan.Version, input, nil, "no_litter_outcome")
			if err != nil {
				return ConfirmBirthResult{}, err
			}
			return ConfirmBirthResult{
				ResultType: "no_litter_outcome", BreedingPlan: updated, BirthEventID: eventID,
				EventType: "BIRTH_CONFIRMED_NO_LIVE_PUPS", BornAt: input.BornAt,
				InitialOtherCount: input.InitialOtherCount, OutcomeReason: input.OutcomeReason, DamCondition: input.DamCondition,
			}, nil
		}

		if input.EnclosureID == nil {
			return ConfirmBirthResult{}, validationError("enclosure_id is required when initial_alive_count > 0")
		}
		if _, err := tx.GetEnclosureForUpdate(ctx, ownerID, *input.EnclosureID); err != nil {
			return ConfirmBirthResult{}, err
		}
		litter, err := tx.CreateLitter(ctx, ownerID, input, plan)
		if err != nil {
			return ConfirmBirthResult{}, err
		}
		if err := tx.InsertLitterParents(ctx, ownerID, litter.ID, plan.SireID, plan.DamID); err != nil {
			return ConfirmBirthResult{}, err
		}
		codes := input.TemporaryCodes
		if len(codes) == 0 {
			codes = make([]string, input.InitialAliveCount)
			prefix := strings.TrimSpace(input.TemporaryCodePrefix)
			if prefix == "" {
				prefix = "PUP-" + input.BornAt.UTC().Format("20060102")
			}
			for i := range codes {
				codes[i] = fmt.Sprintf("%s-%02d", prefix, i+1)
			}
		}
		pups, err := tx.InsertPupIdentities(ctx, ownerID, litter.ID, codes)
		if err != nil {
			return ConfirmBirthResult{}, err
		}
		for _, pup := range pups {
			if err := tx.InsertLitterPupMember(ctx, ownerID, litter.ID, pup.ID); err != nil {
				return ConfirmBirthResult{}, err
			}
		}
		initialEvent, err := tx.InsertCountEvent(ctx, ownerID, litter.ID, CountEventInput{
			EventType: "initial_alive", Delta: input.InitialAliveCount, OccurredAt: input.BornAt, IdempotencyKey: command.IdempotencyKey + ":initial",
		}, nil)
		if err != nil {
			return ConfirmBirthResult{}, err
		}
		eventID, err := tx.AppendEvent(ctx, DomainEvent{
			OwnerID: ownerID, OrganizationID: plan.OrganizationID, AggregateType: "breeding_plan", AggregateID: plan.ID,
			EventType: "BIRTH_CONFIRMED", OccurredAt: input.BornAt,
			Payload: map[string]any{"litter_id": litter.ID, "initial_alive_count": input.InitialAliveCount}, IdempotencyKey: command.IdempotencyKey,
		})
		if err != nil {
			return ConfirmBirthResult{}, err
		}
		updatedPlan, err := tx.UpdatePlanBirth(ctx, ownerID, plan.ID, plan.Version, input, &litter.ID, "litter_nursing")
		if err != nil {
			return ConfirmBirthResult{}, err
		}
		return ConfirmBirthResult{
			ResultType: "live_litter", BreedingPlan: updatedPlan, Litter: &litter,
			PupIdentityCount: len(pups), PupIdentities: pups, InitialCountEvent: &initialEvent,
			BirthEventID: eventID, EventType: "BIRTH_CONFIRMED", BornAt: input.BornAt,
			InitialOtherCount: input.InitialOtherCount, OutcomeReason: input.OutcomeReason, DamCondition: input.DamCondition,
		}, nil
	})
}

func (s *Service) AddCountEvent(ctx context.Context, ownerID, litterID uuid.UUID, options WriteOptions, input CountEventInput) (WriteResult[CountEventResult], error) {
	if err := validateCountEvent(ownerID, litterID, &input); err != nil {
		return WriteResult[CountEventResult]{}, err
	}
	command, err := buildCommand(ownerID, options, "POST", "/v1/litters/"+litterID.String()+"/count-events", input, 200)
	if err != nil {
		return WriteResult[CountEventResult]{}, err
	}
	input.IdempotencyKey = command.IdempotencyKey
	return runWrite(ctx, s.repository, command, func(ctx context.Context, tx Transaction) (CountEventResult, error) {
		litter, err := tx.GetLitterForUpdate(ctx, ownerID, litterID)
		if err != nil {
			return CountEventResult{}, err
		}
		if litter.Version != input.ExpectedVersion {
			return CountEventResult{}, &VersionError{Current: litter.Version}
		}
		if litter.State == "closed" || litter.State == "voided" {
			return CountEventResult{}, &StateError{Message: "已关闭窝次不能追加数量流水"}
		}
		if input.EventType == "discovered" {
			created, err := tx.InsertPupIdentities(ctx, ownerID, litter.ID, input.NewTemporaryCodes)
			if err != nil {
				return CountEventResult{}, err
			}
			for _, pup := range created {
				if err := tx.InsertLitterPupMember(ctx, ownerID, litter.ID, pup.ID); err != nil {
					return CountEventResult{}, err
				}
			}
		}
		var affected []PupIdentity
		closedIDs := make([]uuid.UUID, 0, len(input.AffectedPupIdentityIDs))
		if input.EventType == "death" || input.EventType == "transferred_out" {
			for _, pupID := range input.AffectedPupIdentityIDs {
				pup, err := tx.GetPupForUpdate(ctx, ownerID, pupID)
				if err != nil {
					return CountEventResult{}, err
				}
				if pup.LitterID != litter.ID || pup.OutcomeStatus != "alive" {
					return CountEventResult{}, validationError("affected_pup_identity_ids contains an invalid pup")
				}
				status := input.EventType
				updated, err := tx.UpdatePupOutcome(ctx, ownerID, pup.ID, status, nil, nil, &input.Reason)
				if err != nil {
					return CountEventResult{}, err
				}
				affected = append(affected, updated)
				closedIDs = append(closedIDs, pup.ID)
			}
		}
		event, err := tx.InsertCountEvent(ctx, ownerID, litter.ID, input, nil)
		if err != nil {
			return CountEventResult{}, err
		}
		updatedLitter, err := tx.UpdateLitterCountProjection(ctx, ownerID, litter.ID, litter.Version, input)
		if err != nil {
			return CountEventResult{}, err
		}
		_, err = tx.AppendEvent(ctx, DomainEvent{
			OwnerID: ownerID, OrganizationID: litter.OrganizationID, AggregateType: "litter", AggregateID: litter.ID,
			EventType: "LITTER_COUNT_ADJUSTED", OccurredAt: input.OccurredAt,
			Payload: map[string]any{"event_id": event.ID, "delta": input.Delta, "affected": len(affected)}, IdempotencyKey: command.IdempotencyKey,
		})
		if err != nil {
			return CountEventResult{}, err
		}
		reconciliation, err := s.reconciliation(ctx, tx, updatedLitter)
		if err != nil {
			return CountEventResult{}, err
		}
		return CountEventResult{Litter: updatedLitter, CountEvent: event, CreatedPupIdentities: pupsByCreated(ctx, tx, ownerID, litter.ID, input), ClosedPupIdentityIDs: closedIDs, Reconciliation: reconciliation}, nil
	})
}

func (s *Service) Wean(ctx context.Context, ownerID, litterID uuid.UUID, options WriteOptions, input WeanInput) (WriteResult[WeanResult], error) {
	if err := validateWean(ownerID, litterID, &input); err != nil {
		return WriteResult[WeanResult]{}, err
	}
	command, err := buildCommand(ownerID, options, "POST", "/v1/litters/"+litterID.String()+"/wean", input, 200)
	if err != nil {
		return WriteResult[WeanResult]{}, err
	}
	return runWrite(ctx, s.repository, command, func(ctx context.Context, tx Transaction) (WeanResult, error) {
		litter, err := tx.GetLitterForUpdate(ctx, ownerID, litterID)
		if err != nil {
			return WeanResult{}, err
		}
		if litter.Version != input.ExpectedVersion {
			return WeanResult{}, &VersionError{Current: litter.Version}
		}
		if litter.State != "weaning_due" {
			return WeanResult{}, &StateError{Message: "断奶仅允许 weaning_due 状态"}
		}
		pups, err := tx.ListPupsForUpdate(ctx, ownerID, litter.ID)
		if err != nil {
			return WeanResult{}, err
		}
		items, err := exactPupItems(pups, input.Items, true)
		if err != nil {
			return WeanResult{}, err
		}
		results := make([]ActionItemResult, 0, len(items))
		for _, item := range items {
			pup := itemsPup(item.PupIdentityID, pups)
			if item.OutcomeStatus == "alive" && item.DestinationEnclosureID == nil {
				return WeanResult{}, validationError("alive pup requires destination_enclosure_id")
			}
			if item.OutcomeStatus != "alive" && item.DestinationEnclosureID != nil {
				return WeanResult{}, validationError("non-alive pup cannot have destination_enclosure_id")
			}
			if item.OutcomeStatus != "alive" && item.OutcomeStatus != "deceased" && item.OutcomeStatus != "transferred_out" {
				return WeanResult{}, validationError("invalid outcome_status")
			}
			if item.DestinationEnclosureID != nil {
				if _, err := tx.GetEnclosureForUpdate(ctx, ownerID, *item.DestinationEnclosureID); err != nil {
					return WeanResult{}, err
				}
			}
			updated, err := tx.UpdatePupOutcome(ctx, ownerID, pup.ID, item.OutcomeStatus, &input.WeanedAt, item.DestinationEnclosureID, item.Notes)
			if err != nil {
				return WeanResult{}, err
			}
			_ = updated
			results = append(results, ActionItemResult{PupIdentityID: pup.ID, Status: "succeeded"})
		}
		updatedLitter, err := tx.UpdateLitterWeaned(ctx, ownerID, litter.ID, litter.Version, input.WeanedAt)
		if err != nil {
			return WeanResult{}, err
		}
		if _, err := tx.AppendEvent(ctx, DomainEvent{OwnerID: ownerID, OrganizationID: litter.OrganizationID, AggregateType: "litter", AggregateID: litter.ID, EventType: "WEANING_COMPLETED", OccurredAt: input.WeanedAt, Payload: map[string]any{"processed_count": len(results)}, IdempotencyKey: command.IdempotencyKey}); err != nil {
			return WeanResult{}, err
		}
		return WeanResult{LitterID: litter.ID, LitterState: updatedLitter.State, WeanedAt: input.WeanedAt, ProcessedCount: len(results), ItemResults: results, Version: updatedLitter.Version}, nil
	})
}

func (s *Service) SexAndSeparate(ctx context.Context, ownerID, litterID uuid.UUID, options WriteOptions, input SexAndSeparateInput) (WriteResult[SexAndSeparateResult], error) {
	if err := validateSexAndSeparate(ownerID, litterID, &input); err != nil {
		return WriteResult[SexAndSeparateResult]{}, err
	}
	command, err := buildCommand(ownerID, options, "POST", "/v1/litters/"+litterID.String()+"/sex-and-separate", input, 200)
	if err != nil {
		return WriteResult[SexAndSeparateResult]{}, err
	}
	return runWrite(ctx, s.repository, command, func(ctx context.Context, tx Transaction) (SexAndSeparateResult, error) {
		litter, err := tx.GetLitterForUpdate(ctx, ownerID, litterID)
		if err != nil {
			return SexAndSeparateResult{}, err
		}
		if litter.Version != input.ExpectedVersion {
			return SexAndSeparateResult{}, &VersionError{Current: litter.Version}
		}
		if litter.State != "sexing_due" {
			return SexAndSeparateResult{}, &StateError{Message: "分性分笼仅允许 sexing_due 状态"}
		}
		pups, err := tx.ListPupsForUpdate(ctx, ownerID, litter.ID)
		if err != nil {
			return SexAndSeparateResult{}, err
		}
		if len(input.Items) == 0 {
			return SexAndSeparateResult{}, validationError("items is required")
		}
		if err := validateExactAlivePups(pups, input.ItemsPupIDs()); err != nil {
			return SexAndSeparateResult{}, err
		}
		groups := map[uuid.UUID]map[string]struct{}{}
		for _, item := range input.Items {
			if item.DestinationEnclosureID == uuid.Nil {
				return SexAndSeparateResult{}, validationError("destination_enclosure_id is required")
			}
			if item.Sex != "male" && item.Sex != "female" && item.Sex != "unknown" {
				return SexAndSeparateResult{}, validationError("invalid sex")
			}
			if item.SexConfidence != nil && (*item.SexConfidence < 0 || *item.SexConfidence > 1) {
				return SexAndSeparateResult{}, validationError("sex_confidence must be between 0 and 1")
			}
			if groups[item.DestinationEnclosureID] == nil {
				groups[item.DestinationEnclosureID] = map[string]struct{}{}
			}
			if item.Sex != "unknown" {
				groups[item.DestinationEnclosureID][item.Sex] = struct{}{}
			}
		}
		for _, sexes := range groups {
			if len(sexes) > 1 {
				return SexAndSeparateResult{}, &StateError{Message: "同一笼盒不能混合已确认的公母幼崽"}
			}
		}
		results := make([]ActionItemResult, 0, len(input.Items))
		uncertain := 0
		for _, item := range input.Items {
			pup := itemsPup(item.PupIdentityID, pups)
			if _, err := tx.GetEnclosureForUpdate(ctx, ownerID, item.DestinationEnclosureID); err != nil {
				return SexAndSeparateResult{}, err
			}
			if item.RequiresRecheck || item.Sex == "unknown" {
				uncertain++
			}
			reason := item.Notes
			if item.RequiresRecheck {
				value := "sex_recheck_required"
				if reason != nil && strings.TrimSpace(*reason) != "" {
					value += ": " + strings.TrimSpace(*reason)
				}
				reason = &value
			}
			if _, err := tx.UpdatePupSexAndEnclosure(ctx, ownerID, pup.ID, item.Sex, item.SexConfidence, item.DestinationEnclosureID, reason); err != nil {
				return SexAndSeparateResult{}, err
			}
			status := "succeeded"
			if item.RequiresRecheck || item.Sex == "unknown" {
				status = "succeeded_with_warning"
			}
			results = append(results, ActionItemResult{PupIdentityID: pup.ID, Status: status})
		}
		updatedLitter, err := tx.UpdateLitterSeparated(ctx, ownerID, litter.ID, litter.Version, input.SeparatedAt)
		if err != nil {
			return SexAndSeparateResult{}, err
		}
		if _, err := tx.AppendEvent(ctx, DomainEvent{OwnerID: ownerID, OrganizationID: litter.OrganizationID, AggregateType: "litter", AggregateID: litter.ID, EventType: "SEX_SEPARATION_COMPLETED", OccurredAt: input.SeparatedAt, Payload: map[string]any{"processed_count": len(results), "uncertain_count": uncertain}, IdempotencyKey: command.IdempotencyKey}); err != nil {
			return SexAndSeparateResult{}, err
		}
		return SexAndSeparateResult{LitterID: litter.ID, LitterState: updatedLitter.State, SeparatedAt: input.SeparatedAt, ProcessedCount: len(results), UncertainCount: uncertain, ItemResults: results, Version: updatedLitter.Version}, nil
	})
}

func (s *Service) GetIndividualizationEligibility(ctx context.Context, ownerID, litterID uuid.UUID) (IndividualizationEligibility, error) {
	return s.repository.GetIndividualizationEligibility(ctx, ownerID, litterID)
}

func (s *Service) Individualize(ctx context.Context, ownerID, litterID uuid.UUID, options WriteOptions, input IndividualizeInput) (WriteResult[IndividualizeResult], error) {
	if err := validateIndividualize(ownerID, litterID, &input); err != nil {
		return WriteResult[IndividualizeResult]{}, err
	}
	command, err := buildCommand(ownerID, options, "POST", "/v1/litters/"+litterID.String()+"/individualize", input, 200)
	if err != nil {
		return WriteResult[IndividualizeResult]{}, err
	}
	return runWrite(ctx, s.repository, command, func(ctx context.Context, tx Transaction) (IndividualizeResult, error) {
		litter, err := tx.GetLitterForUpdate(ctx, ownerID, litterID)
		if err != nil {
			return IndividualizeResult{}, err
		}
		if litter.Version != input.ExpectedVersion {
			return IndividualizeResult{}, &VersionError{Current: litter.Version}
		}
		pups, err := tx.ListPupsForUpdate(ctx, ownerID, litter.ID)
		if err != nil {
			return IndividualizeResult{}, err
		}
		eligibility := computeEligibility(litter, pups, time.Now().UTC())
		if !eligibility.CanIndividualize {
			return IndividualizeResult{}, validationError("litter is not eligible for individualization")
		}
		if input.EligibleSetToken != eligibility.EligibleSetToken {
			return IndividualizeResult{}, ErrEligibilityStale
		}
		if err := validateExactUUIDSet(eligibility.EligiblePupIdentityIDs, individualizeIDs(input.Items)); err != nil {
			return IndividualizeResult{}, err
		}
		plan, err := tx.GetPlanForUpdate(ctx, ownerID, *litter.BreedingPlanID)
		if err != nil {
			return IndividualizeResult{}, err
		}
		parents, err := tx.GetLitterParents(ctx, ownerID, litter.ID)
		if err != nil {
			return IndividualizeResult{}, err
		}
		itemsByID := make(map[uuid.UUID]IndividualizeItem, len(input.Items))
		for _, item := range input.Items {
			if _, exists := itemsByID[item.PupIdentityID]; exists {
				return IndividualizeResult{}, validationError("items contains duplicate pup_identity_id")
			}
			if strings.TrimSpace(item.InternalCode) == "" || len(item.InternalCode) > 64 {
				return IndividualizeResult{}, validationError("internal_code is required")
			}
			itemsByID[item.PupIdentityID] = item
		}
		mappings := make([]IndividualizeMapping, 0, len(eligibility.EligiblePupIdentityIDs))
		for _, pupID := range eligibility.EligiblePupIdentityIDs {
			pup := itemsPup(pupID, pups)
			item := itemsByID[pupID]
			hamster, err := tx.InsertHamster(ctx, ownerID, plan, pup, item)
			if err != nil {
				return IndividualizeResult{}, err
			}
			if err := tx.ClosePupMember(ctx, ownerID, pup.ID, input.IndividualizedAt); err != nil {
				return IndividualizeResult{}, err
			}
			if err := tx.InsertLitterHamsterMember(ctx, ownerID, litter.ID, hamster.ID, pup.ID); err != nil {
				return IndividualizeResult{}, err
			}
			if err := tx.InsertPedigreeParentage(ctx, ownerID, parents.SireID, hamster.ID, "sire"); err != nil {
				return IndividualizeResult{}, err
			}
			if err := tx.InsertPedigreeParentage(ctx, ownerID, parents.DamID, hamster.ID, "dam"); err != nil {
				return IndividualizeResult{}, err
			}
			if _, err := tx.UpdatePupIndividualized(ctx, ownerID, pup.ID, hamster.ID); err != nil {
				return IndividualizeResult{}, err
			}
			mappings = append(mappings, IndividualizeMapping{PupIdentityID: pup.ID, Hamster: hamster})
		}
		updatedLitter, err := tx.UpdateLitterIndividualized(ctx, ownerID, litter.ID, litter.Version, input.IndividualizedAt)
		if err != nil {
			return IndividualizeResult{}, err
		}
		if _, err := tx.AppendEvent(ctx, DomainEvent{OwnerID: ownerID, OrganizationID: litter.OrganizationID, AggregateType: "litter", AggregateID: litter.ID, EventType: "LITTER_RECONCILED", OccurredAt: input.IndividualizedAt, Payload: map[string]any{"individualized_count": len(mappings)}, IdempotencyKey: command.IdempotencyKey}); err != nil {
			return IndividualizeResult{}, err
		}
		return IndividualizeResult{LitterID: litter.ID, EvaluatedEligibleSetToken: eligibility.EligibleSetToken, EvaluatedEligibleCount: len(mappings), Mappings: mappings, CreatedLitterMemberCount: len(mappings), CreatedParentageCount: len(mappings) * 2, Reconciliation: Reconciliation{InitialAliveCount: litter.InitialAliveCount, DiscoveredCount: litter.DiscoveredCount, DeceasedCount: litter.DeceasedCount, TransferredCount: litter.TransferredOutCount, ExpectedManagedCount: litter.CurrentManagedCount, IndividualizedCount: len(mappings), Closed: true}, LitterVersion: updatedLitter.Version}, nil
	})
}

func computeEligibility(litter Litter, pups []PupIdentity, now time.Time) IndividualizationEligibility {
	ids := make([]uuid.UUID, 0)
	blockers := make([]EligibilityBlocker, 0)
	if litter.State != "individualizing" {
		blockers = append(blockers, EligibilityBlocker{Code: "LITTER_STATE_NOT_READY", Message: "窝次尚未进入个体化阶段", RecoveryActions: []string{"完成断奶和分性分笼"}})
	}
	managedAlive := 0
	for _, pup := range pups {
		if pup.OutcomeStatus != "alive" || pup.ProfileStatus == "individualized" {
			continue
		}
		managedAlive++
		if pup.WeanedAt == nil {
			blockers = append(blockers, EligibilityBlocker{Code: "PUP_NOT_WEANED", Message: "存在尚未断奶幼崽", PupIdentityIDs: []uuid.UUID{pup.ID}, RecoveryActions: []string{"完成断奶"}})
			continue
		}
		if pup.Sex == "unknown" {
			blockers = append(blockers, EligibilityBlocker{Code: "SEX_RECHECK_REQUIRED", Message: "存在待复核性别", PupIdentityIDs: []uuid.UUID{pup.ID}, RecoveryActions: []string{"复核性别"}})
			continue
		}
		if pup.StatusReason != nil && strings.HasPrefix(*pup.StatusReason, "sex_recheck_required") {
			blockers = append(blockers, EligibilityBlocker{Code: "SEX_RECHECK_REQUIRED", Message: "存在待复核性别", PupIdentityIDs: []uuid.UUID{pup.ID}, RecoveryActions: []string{"复核性别"}})
			continue
		}
		if pup.CurrentEnclosureID == nil {
			blockers = append(blockers, EligibilityBlocker{Code: "ENCLOSURE_REQUIRED", Message: "存在没有有效笼位的幼崽", PupIdentityIDs: []uuid.UUID{pup.ID}, RecoveryActions: []string{"补录分笼"}})
			continue
		}
		ids = append(ids, pup.ID)
	}
	if managedAlive != litter.CurrentManagedCount {
		blockers = append(blockers, EligibilityBlocker{Code: "COUNT_MISMATCH", Message: "窝次数量账与在管身份不一致", RecoveryActions: []string{"补录数量流水"}})
	}
	sort.Slice(ids, func(i, j int) bool { return ids[i].String() < ids[j].String() })
	token := eligibilityToken(litter, ids)
	return IndividualizationEligibility{LitterID: litter.ID, LitterVersion: litter.Version, EligibleSetToken: token, EligiblePupIdentityIDs: ids, EligibleCount: len(ids), Blockers: blockers, CanIndividualize: len(blockers) == 0 && len(ids) > 0, ComputedAt: now}
}

func eligibilityToken(litter Litter, ids []uuid.UUID) string {
	h := sha256.New()
	fmt.Fprintf(h, "%s:%d:", litter.ID, litter.Version)
	for _, id := range ids {
		fmt.Fprintf(h, "%s,", id)
	}
	return "elig_" + hex.EncodeToString(h.Sum(nil))
}

func (s *Service) reconciliation(ctx context.Context, tx Transaction, litter Litter) (Reconciliation, error) {
	pups, err := tx.ListPupsForUpdate(ctx, litter.OwnerID, litter.ID)
	if err != nil {
		return Reconciliation{}, err
	}
	unind, indiv := 0, 0
	for _, pup := range pups {
		if pup.OutcomeStatus != "alive" {
			continue
		}
		if pup.ProfileStatus == "individualized" {
			indiv++
		} else {
			unind++
		}
	}
	expected := litter.InitialAliveCount + litter.DiscoveredCount - litter.DeceasedCount - litter.TransferredOutCount + litter.CorrectionDelta
	return Reconciliation{InitialAliveCount: litter.InitialAliveCount, DiscoveredCount: litter.DiscoveredCount, DeceasedCount: litter.DeceasedCount, TransferredCount: litter.TransferredOutCount, ExpectedManagedCount: expected, UnindividualizedCount: unind, IndividualizedCount: indiv, Difference: expected - unind - indiv, Closed: litter.State == "closed"}, nil
}

func runWrite[T any](ctx context.Context, repo Repository, command Command, fn func(context.Context, Transaction) (T, error)) (WriteResult[T], error) {
	stored, err := repo.Execute(ctx, command, func(ctx context.Context, tx Transaction) (any, error) { return fn(ctx, tx) })
	if err != nil {
		return WriteResult[T]{}, err
	}
	var value T
	if err := json.Unmarshal(stored.Body, &value); err != nil {
		return WriteResult[T]{}, err
	}
	return WriteResult[T]{Value: value, Replayed: stored.Replayed}, nil
}

func buildCommand(ownerID uuid.UUID, options WriteOptions, method, path string, input any, status int) (Command, error) {
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
	if strings.TrimSpace(options.RequestMethod) != "" {
		method = options.RequestMethod
	}
	if strings.TrimSpace(options.RequestPath) != "" {
		path = options.RequestPath
	}
	return Command{OwnerID: ownerID, IdempotencyKey: strings.TrimSpace(options.IdempotencyKey), Method: method, Path: path, Payload: payload, SuccessStatus: status}, nil
}

func validateConfirmBirth(ownerID, planID uuid.UUID, input *ConfirmBirthInput) error {
	if ownerID == uuid.Nil || planID == uuid.Nil || input.ExpectedVersion < 1 || input.BornAt.IsZero() {
		return validationError("owner_id, plan_id, expected_version and born_at are required")
	}
	if input.InitialAliveCount < 0 || input.InitialAliveCount > 100 || input.InitialOtherCount < 0 || input.InitialOtherCount > 100 {
		return validationError("birth counts must be between 0 and 100")
	}
	input.OutcomeReason = strings.TrimSpace(input.OutcomeReason)
	if input.OutcomeReason == "" {
		return validationError("outcome_reason is required")
	}
	if input.InitialAliveCount == 0 && input.EnclosureID != nil {
		return validationError("enclosure_id must be omitted when initial_alive_count is 0")
	}
	if len(input.TemporaryCodes) > 0 {
		if len(input.TemporaryCodes) != input.InitialAliveCount {
			return validationError("temporary_codes count must equal initial_alive_count")
		}
		seen := map[string]struct{}{}
		for _, code := range input.TemporaryCodes {
			code = strings.TrimSpace(code)
			if code == "" || len(code) > 64 {
				return validationError("temporary_codes contains an invalid code")
			}
			if _, ok := seen[code]; ok {
				return validationError("temporary_codes must be unique")
			}
			seen[code] = struct{}{}
		}
	}
	return nil
}

func validateCountEvent(ownerID, litterID uuid.UUID, input *CountEventInput) error {
	if ownerID == uuid.Nil || litterID == uuid.Nil || input.ExpectedVersion < 1 || input.OccurredAt.IsZero() || strings.TrimSpace(input.Reason) == "" {
		return validationError("count event owner, litter, version, occurred_at and reason are required")
	}
	if input.EventType != "discovered" && input.EventType != "death" && input.EventType != "transferred_out" && input.EventType != "correction" {
		return validationError("invalid count event type")
	}
	if input.Delta == 0 || input.EventType == "discovered" && input.Delta < 1 || (input.EventType == "death" || input.EventType == "transferred_out") && input.Delta > -1 {
		return validationError("count event delta has the wrong sign")
	}
	if input.EventType == "discovered" && len(input.NewTemporaryCodes) != input.Delta {
		return validationError("new_temporary_codes count must equal discovered delta")
	}
	if (input.EventType == "death" || input.EventType == "transferred_out") && len(input.AffectedPupIdentityIDs) != -input.Delta {
		return validationError("affected_pup_identity_ids count must equal closed delta")
	}
	return nil
}

func validateWean(ownerID, litterID uuid.UUID, input *WeanInput) error {
	if ownerID == uuid.Nil || litterID == uuid.Nil || input.ExpectedVersion < 1 || input.WeanedAt.IsZero() || len(input.Items) == 0 {
		return validationError("wean owner, litter, version, weaned_at and items are required")
	}
	return nil
}

func validateSexAndSeparate(ownerID, litterID uuid.UUID, input *SexAndSeparateInput) error {
	if ownerID == uuid.Nil || litterID == uuid.Nil || input.ExpectedVersion < 1 || input.SeparatedAt.IsZero() || len(input.Items) == 0 {
		return validationError("sex-and-separate owner, litter, version, separated_at and items are required")
	}
	return nil
}

func validateIndividualize(ownerID, litterID uuid.UUID, input *IndividualizeInput) error {
	if ownerID == uuid.Nil || litterID == uuid.Nil || input.ExpectedVersion < 1 || input.IndividualizedAt.IsZero() || strings.TrimSpace(input.EligibleSetToken) == "" || len(input.Items) == 0 {
		return validationError("individualize owner, litter, version, individualized_at, token and items are required")
	}
	return nil
}

func exactPupItems(pups []PupIdentity, items []WeanItem, requireAlive bool) ([]WeanItem, error) {
	ids := make([]uuid.UUID, 0, len(items))
	seen := map[uuid.UUID]struct{}{}
	for _, item := range items {
		if _, ok := seen[item.PupIdentityID]; ok {
			return nil, validationError("items contains duplicate pup_identity_id")
		}
		seen[item.PupIdentityID] = struct{}{}
		ids = append(ids, item.PupIdentityID)
	}
	for _, pup := range pups {
		if pup.OutcomeStatus == "alive" && pup.ProfileStatus != "individualized" {
			if _, ok := seen[pup.ID]; !ok && requireAlive {
				return nil, validationError("items must include every alive pup")
			}
		}
	}
	for _, id := range ids {
		found := false
		for _, pup := range pups {
			if pup.ID == id && pup.OutcomeStatus == "alive" && pup.ProfileStatus != "individualized" {
				found = true
				break
			}
		}
		if !found {
			return nil, validationError("items contains an invalid pup")
		}
	}
	return items, nil
}

func validateExactAlivePups(pups []PupIdentity, ids []uuid.UUID) error {
	seen := map[uuid.UUID]struct{}{}
	for _, id := range ids {
		if _, ok := seen[id]; ok {
			return validationError("items contains duplicate pup_identity_id")
		}
		seen[id] = struct{}{}
	}
	want := 0
	for _, pup := range pups {
		if pup.OutcomeStatus == "alive" && pup.ProfileStatus != "individualized" {
			want++
			if _, ok := seen[pup.ID]; !ok {
				return validationError("items must include every alive pup")
			}
		}
	}
	if want != len(ids) {
		return validationError("items contains an invalid pup")
	}
	return nil
}

func validateExactUUIDSet(expected, actual []uuid.UUID) error {
	a, b := append([]uuid.UUID(nil), expected...), append([]uuid.UUID(nil), actual...)
	sort.Slice(a, func(i, j int) bool { return a[i].String() < a[j].String() })
	sort.Slice(b, func(i, j int) bool { return b[i].String() < b[j].String() })
	if len(a) != len(b) {
		return validationError("items must exactly match eligible set")
	}
	for i := range a {
		if a[i] != b[i] {
			return validationError("items must exactly match eligible set")
		}
	}
	return nil
}

func itemsPup(id uuid.UUID, pups []PupIdentity) PupIdentity {
	for _, pup := range pups {
		if pup.ID == id {
			return pup
		}
	}
	return PupIdentity{}
}

func pupsByCreated(ctx context.Context, tx Transaction, ownerID, litterID uuid.UUID, input CountEventInput) []PupIdentity {
	if input.EventType != "discovered" {
		return nil
	}
	pups, err := tx.ListPupsForUpdate(ctx, ownerID, litterID)
	if err != nil {
		return nil
	}
	created := make([]PupIdentity, 0, len(input.NewTemporaryCodes))
	for _, code := range input.NewTemporaryCodes {
		for _, pup := range pups {
			if pup.TemporaryCode == code {
				created = append(created, pup)
				break
			}
		}
	}
	return created
}

func individualizeIDs(items []IndividualizeItem) []uuid.UUID {
	ids := make([]uuid.UUID, 0, len(items))
	for _, item := range items {
		ids = append(ids, item.PupIdentityID)
	}
	return ids
}

func (input SexAndSeparateInput) ItemsPupIDs() []uuid.UUID {
	ids := make([]uuid.UUID, 0, len(input.Items))
	for _, item := range input.Items {
		ids = append(ids, item.PupIdentityID)
	}
	return ids
}

func validationError(message string) error { return fmt.Errorf("%w: %s", ErrValidation, message) }
