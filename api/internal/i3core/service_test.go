package i3core

import (
	"errors"
	"testing"
	"time"

	"github.com/google/uuid"
)

func TestPlanJSONFormatsBirthWindowAsDate(t *testing.T) {
	start := time.Date(2026, 7, 20, 0, 0, 0, 0, time.UTC)
	end := time.Date(2026, 7, 23, 0, 0, 0, 0, time.UTC)
	plan := BreedingPlan{ID: uuid.New(), OwnerID: uuid.New(), SireID: uuid.New(), DamID: uuid.New(), RuleVersionID: uuid.New(), State: "gestation", ExpectedBirthStart: &start, ExpectedBirthEnd: &end, ObjectiveTraits: map[string]any{}}
	payload := PlanJSON(plan)
	if payload["expected_birth_start"] != "2026-07-20" || payload["expected_birth_end"] != "2026-07-23" {
		t.Fatalf("birth window payload = %#v", payload)
	}
}

func TestPlanJSONOmitsEmptyOrIncompleteKinshipCheck(t *testing.T) {
	plan := BreedingPlan{
		ID: uuid.New(), OwnerID: uuid.New(), SireID: uuid.New(), DamID: uuid.New(),
		RuleVersionID: uuid.New(), State: "draft",
		KinshipCheck: map[string]any{}, // draft default in DB
	}
	if got := PlanJSON(plan)["kinship_check"]; got != nil {
		t.Fatalf("empty kinship_check want nil, got %#v", got)
	}

	plan.KinshipCheck = map[string]any{"status": "clear", "checked_at": time.Now().UTC()}
	if got := PlanJSON(plan)["kinship_check"]; got != nil {
		t.Fatalf("incomplete kinship_check want nil, got %#v", got)
	}

	plan.KinshipCheck = map[string]any{
		"checked_at":            time.Date(2026, 7, 21, 0, 0, 0, 0, time.UTC),
		"common_ancestor_count": 0,
		"risk_level":            "none",
		"rule_version":          "i3-default",
	}
	got, ok := PlanJSON(plan)["kinship_check"].(map[string]any)
	if !ok || got["risk_level"] != "none" {
		t.Fatalf("complete kinship_check not preserved: %#v", PlanJSON(plan)["kinship_check"])
	}
}

func TestVersionErrorSupportsErrorsIs(t *testing.T) {
	err := &VersionError{Current: 3}
	if !errors.Is(err, ErrVersionConflict) {
		t.Fatal("version error does not unwrap to ErrVersionConflict")
	}
}
