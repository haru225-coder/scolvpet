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

func TestVersionErrorSupportsErrorsIs(t *testing.T) {
	err := &VersionError{Current: 3}
	if !errors.Is(err, ErrVersionConflict) {
		t.Fatal("version error does not unwrap to ErrVersionConflict")
	}
}
