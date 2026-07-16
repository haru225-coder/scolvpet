package i4core

import (
	"testing"
	"time"

	"github.com/google/uuid"
)

func TestConfirmBirthValidationSupportsZeroAndLiveBranches(t *testing.T) {
	ownerID, planID := uuid.New(), uuid.New()
	zero := ConfirmBirthInput{ExpectedVersion: 1, BornAt: time.Now(), InitialOtherCount: 1, OutcomeReason: "未发现活仔"}
	if err := validateConfirmBirth(ownerID, planID, &zero); err != nil {
		t.Fatalf("zero-live branch validation: %v", err)
	}
	enclosureID := uuid.New()
	live := ConfirmBirthInput{ExpectedVersion: 1, BornAt: time.Now(), EnclosureID: &enclosureID, InitialAliveCount: 2, OutcomeReason: "正常产仔"}
	if err := validateConfirmBirth(ownerID, planID, &live); err != nil {
		t.Fatalf("live branch validation: %v", err)
	}
	bad := live
	bad.TemporaryCodes = []string{"only-one"}
	if err := validateConfirmBirth(ownerID, planID, &bad); err == nil {
		t.Fatal("expected temporary code count validation")
	}
}

func TestWeanAndIndividualizeValidation(t *testing.T) {
	ownerID, litterID := uuid.New(), uuid.New()
	if err := validateWean(ownerID, litterID, &WeanInput{ExpectedVersion: 1, WeanedAt: time.Now(), Items: []WeanItem{{PupIdentityID: uuid.New(), OutcomeStatus: "alive"}}}); err != nil {
		t.Fatalf("wean validation: %v", err)
	}
	if err := validateIndividualize(ownerID, litterID, &IndividualizeInput{ExpectedVersion: 1, IndividualizedAt: time.Now(), EligibleSetToken: "elig_test_token", Items: []IndividualizeItem{{PupIdentityID: uuid.New(), InternalCode: "PUP-01"}}}); err != nil {
		t.Fatalf("individualize validation: %v", err)
	}
}

func TestIndividualizationEligibilityTokenBindsVersionAndSet(t *testing.T) {
	litterID := uuid.New()
	enclosureID := uuid.New()
	pupID := uuid.New()
	weanedAt := time.Now().UTC()
	litter := Litter{ID: litterID, State: "individualizing", Version: 4, CurrentManagedCount: 1, InitialAliveCount: 1}
	pups := []PupIdentity{{ID: pupID, LitterID: litterID, OutcomeStatus: "alive", ProfileStatus: "unindividualized", Sex: "male", WeanedAt: &weanedAt, CurrentEnclosureID: &enclosureID}}
	eligibility := computeEligibility(litter, pups, time.Now().UTC())
	if !eligibility.CanIndividualize || eligibility.EligibleCount != 1 || eligibility.EligiblePupIdentityIDs[0] != pupID {
		t.Fatalf("unexpected eligibility: %+v", eligibility)
	}
	changed := litter
	changed.Version++
	if computeEligibility(changed, pups, time.Now().UTC()).EligibleSetToken == eligibility.EligibleSetToken {
		t.Fatal("eligibility token did not change with litter version")
	}
}
