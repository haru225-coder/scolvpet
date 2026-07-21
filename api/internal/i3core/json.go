package i3core

import (
	"time"

	"github.com/google/uuid"
)

func PlanJSON(plan BreedingPlan) map[string]any {
	return map[string]any{
		"id": plan.ID, "owner_id": plan.OwnerID, "name": plan.Name,
		"sire_id": plan.SireID, "dam_id": plan.DamID, "rule_version_id": plan.RuleVersionID,
		"state": plan.State, "planned_pairing_at": plan.PlannedPairingAt,
		"mating_baseline_at":        plan.MatingBaselineAt,
		"expected_birth_start":      formatDate(plan.ExpectedBirthStart),
		"expected_birth_end":        formatDate(plan.ExpectedBirthEnd),
		"actual_birth_at":           plan.ActualBirthAt,
		"active_pairing_attempt_id": plan.ActivePairingAttemptID,
		"litter_id":                 plan.LitterID, "objective_traits": plan.ObjectiveTraits,
		// Empty/legacy {} must be null: OpenAPI KinshipCheck has required fields and the
		// generated mobile client rejects HTTP 200 bodies that still fail deserialization.
		"kinship_check": formatKinshipCheck(plan.KinshipCheck), "notes": plan.Notes,
		"version": plan.Version, "created_at": plan.CreatedAt, "updated_at": plan.UpdatedAt,
	}
}

// formatKinshipCheck emits null unless the payload has the OpenAPI-required keys.
// Draft rows store kinship_check as {} and publish used to write incomplete shapes;
// both break checked JSON decoding on the client (surface as “请求失败（200）”).
func formatKinshipCheck(value map[string]any) any {
	if len(value) == 0 {
		return nil
	}
	for _, key := range []string{"checked_at", "common_ancestor_count", "risk_level", "rule_version"} {
		if _, ok := value[key]; !ok {
			return nil
		}
	}
	return value
}

func AttemptJSON(attempt PairingAttempt) map[string]any {
	return map[string]any{
		"id": attempt.ID, "breeding_plan_id": attempt.BreedingPlanID, "sequence": attempt.Sequence,
		"enclosure_id": attempt.EnclosureID, "started_at": attempt.StartedAt,
		"ended_at": attempt.EndedAt, "separated_at": attempt.SeparatedAt,
		"separation_deadline": attempt.SeparationDeadline, "status": attempt.Status,
		"result": attempt.Result, "conflict_level": attempt.ConflictLevel,
		"sire_destination_enclosure_id": attempt.SireDestinationEnclosureID,
		"dam_destination_enclosure_id":  attempt.DamDestinationEnclosureID,
		"notes":                         attempt.Notes, "version": attempt.Version,
	}
}

func ObservationJSON(observation MatingObservation) map[string]any {
	return map[string]any{
		"id": observation.ID, "pairing_attempt_id": observation.PairingAttemptID,
		"observed_at": observation.ObservedAt, "type": observation.Type,
		"duration_seconds": observation.DurationSeconds, "severity": observation.Severity,
		"confidence": observation.Confidence, "media_ids": observation.MediaIDs,
		"notes": observation.Notes, "created_at": observation.CreatedAt,
	}
}

func StayJSON(stay EnclosureStay) map[string]any {
	return map[string]any{
		"id": stay.ID, "enclosure_id": stay.EnclosureID, "hamster_id": stay.HamsterID,
		"purpose": stay.Purpose, "started_at": stay.StartedAt, "ended_at": stay.EndedAt,
		"version": stay.Version,
	}
}

func formatDate(value *time.Time) any {
	if value == nil {
		return nil
	}
	return value.Format("2006-01-02")
}

var _ = uuid.Nil
