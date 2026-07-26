package i2core

import (
	"context"
	"errors"
	"fmt"
	"testing"
	"time"

	"github.com/google/uuid"
)

type serviceFixture struct {
	repository *memoryRepository
	service    *Service
	ownerID    uuid.UUID
	ruleID     uuid.UUID
}

func newServiceFixture(t *testing.T) serviceFixture {
	t.Helper()
	repository := newMemoryRepository()
	ownerID := uuid.New()
	_, ruleID := repository.provision(ownerID)
	return serviceFixture{repository: repository, service: NewService(repository), ownerID: ownerID, ruleID: ruleID}
}

func writeOptions(key string) WriteOptions {
	return WriteOptions{IdempotencyKey: key}
}

func (f serviceFixture) createHamster(t *testing.T, code string) Hamster {
	return f.createHamsterWithSex(t, code, "unknown")
}

func (f serviceFixture) createHamsterWithSex(t *testing.T, code, sex string) Hamster {
	t.Helper()
	result, err := f.service.CreateHamster(context.Background(), f.ownerID, writeOptions("create-hamster-"+code), CreateHamsterInput{
		InternalCode: code, SpeciesRuleVersionID: f.ruleID, Sex: sex, SourceType: "introduced",
	})
	if err != nil {
		t.Fatalf("create hamster %s: %v", code, err)
	}
	return result.Value
}

func (f serviceFixture) createEnclosure(t *testing.T, code string, cleanliness ...string) Enclosure {
	t.Helper()
	state := "clean"
	if len(cleanliness) > 0 {
		state = cleanliness[0]
	}
	result, err := f.service.CreateEnclosure(context.Background(), f.ownerID, writeOptions("create-enclosure-"+code), CreateEnclosureInput{
		Code: code, Capacity: 1, Cleanliness: state,
	})
	if err != nil {
		t.Fatalf("create enclosure %s: %v", code, err)
	}
	return result.Value
}

func TestI2HamsterAndEnclosureCodesAreOwnerUnique(t *testing.T) {
	fixture := newServiceFixture(t)
	first := fixture.createHamster(t, "HAM-001")
	fixture.createHamster(t, "HAM-002")

	_, err := fixture.service.CreateHamster(context.Background(), fixture.ownerID, writeOptions("duplicate-hamster-code"), CreateHamsterInput{
		InternalCode: "HAM-001", SpeciesRuleVersionID: fixture.ruleID,
	})
	if !errors.Is(err, ErrDuplicate) {
		t.Fatalf("duplicate hamster code: got %v", err)
	}

	duplicate := "HAM-001"
	_, err = fixture.service.UpdateHamster(context.Background(), fixture.ownerID, first.ID, writeOptions("same-code-noop"), UpdateHamsterInput{
		ExpectedVersion: first.Version, InternalCode: &duplicate,
	})
	if err != nil {
		t.Fatalf("same record may retain its code: %v", err)
	}

	_, err = fixture.service.BatchCreateHamsters(context.Background(), fixture.ownerID, writeOptions("duplicate-batch-codes"), BatchCreateHamstersInput{Hamsters: []CreateHamsterInput{
		{InternalCode: "HAM-BATCH", SpeciesRuleVersionID: fixture.ruleID},
		{InternalCode: "HAM-BATCH", SpeciesRuleVersionID: fixture.ruleID},
	}})
	if !errors.Is(err, ErrDuplicate) {
		t.Fatalf("duplicate batch code: got %v", err)
	}

	fixture.createEnclosure(t, "ENC-001")
	_, err = fixture.service.CreateEnclosure(context.Background(), fixture.ownerID, writeOptions("duplicate-enclosure-code"), CreateEnclosureInput{Code: "ENC-001"})
	if !errors.Is(err, ErrDuplicate) {
		t.Fatalf("duplicate enclosure code: got %v", err)
	}
}

func TestI2IdempotentCreateReplaysOneCommittedEvent(t *testing.T) {
	fixture := newServiceFixture(t)
	input := CreateHamsterInput{InternalCode: "HAM-IDEMPOTENT", SpeciesRuleVersionID: fixture.ruleID}
	first, err := fixture.service.CreateHamster(context.Background(), fixture.ownerID, writeOptions("hamster-idempotent"), input)
	if err != nil {
		t.Fatal(err)
	}
	second, err := fixture.service.CreateHamster(context.Background(), fixture.ownerID, writeOptions("hamster-idempotent"), input)
	if err != nil {
		t.Fatal(err)
	}
	if !second.Replayed || first.Value.ID != second.Value.ID {
		t.Fatalf("expected replay of %s, got %#v", first.Value.ID, second)
	}
	if len(fixture.repository.events) != 1 {
		t.Fatalf("expected one domain event, got %d", len(fixture.repository.events))
	}

	_, err = fixture.service.CreateHamster(context.Background(), fixture.ownerID, writeOptions("hamster-idempotent"), CreateHamsterInput{
		InternalCode: "HAM-DIFFERENT", SpeciesRuleVersionID: fixture.ruleID,
	})
	if !errors.Is(err, ErrIdempotencyPayloadMismatch) {
		t.Fatalf("payload mismatch: got %v", err)
	}
}

func TestI2EnclosureStayRejectsOverlappingOccupancy(t *testing.T) {
	fixture := newServiceFixture(t)
	first := fixture.createHamster(t, "HAM-STAY-1")
	second := fixture.createHamster(t, "HAM-STAY-2")
	enclosure := fixture.createEnclosure(t, "ENC-STAY")
	startedAt := time.Date(2026, 7, 16, 8, 0, 0, 0, time.UTC)

	admitted, err := fixture.service.AdmitHamster(context.Background(), fixture.ownerID, writeOptions("admit-first"), AdmitHamsterInput{
		HamsterID: first.ID, EnclosureID: enclosure.ID, Purpose: "single", StartedAt: startedAt,
		ExpectedHamsterVersion: first.Version, ExpectedEnclosureVersion: enclosure.Version,
	})
	if err != nil {
		t.Fatal(err)
	}
	_, err = fixture.service.AdmitHamster(context.Background(), fixture.ownerID, writeOptions("admit-overlap"), AdmitHamsterInput{
		HamsterID: second.ID, EnclosureID: enclosure.ID, Purpose: "single", StartedAt: startedAt.Add(time.Hour),
		ExpectedHamsterVersion: second.Version, ExpectedEnclosureVersion: admitted.Value.TargetEnclosure.Version,
	})
	if !errors.Is(err, ErrStayConflict) {
		t.Fatalf("overlapping enclosure stay: got %v", err)
	}
}

func TestI2MoveHamsterRollsBackWhenTargetInsertFails(t *testing.T) {
	fixture := newServiceFixture(t)
	hamster := fixture.createHamster(t, "HAM-MOVE")
	source := fixture.createEnclosure(t, "ENC-SOURCE")
	target := fixture.createEnclosure(t, "ENC-TARGET")
	startedAt := time.Date(2026, 7, 16, 9, 0, 0, 0, time.UTC)
	admitted, err := fixture.service.AdmitHamster(context.Background(), fixture.ownerID, writeOptions("admit-before-move"), AdmitHamsterInput{
		HamsterID: hamster.ID, EnclosureID: source.ID, Purpose: "single", StartedAt: startedAt,
		ExpectedHamsterVersion: hamster.Version, ExpectedEnclosureVersion: source.Version,
	})
	if err != nil {
		t.Fatal(err)
	}
	fixture.repository.failNextStayInsert = true
	_, err = fixture.service.MoveHamster(context.Background(), fixture.ownerID, writeOptions("move-injected-failure"), MoveHamsterInput{
		StayID: admitted.Value.Stay.ID, TargetEnclosureID: target.ID, Purpose: "single", MovedAt: startedAt.Add(2 * time.Hour),
		ExpectedStayVersion: admitted.Value.Stay.Version, ExpectedHamsterVersion: admitted.Value.Hamster.Version,
		ExpectedSourceEnclosureVersion: admitted.Value.TargetEnclosure.Version, ExpectedTargetEnclosureVersion: target.Version,
	})
	if err == nil {
		t.Fatal("expected injected move failure")
	}

	current, err := fixture.service.GetHamster(context.Background(), fixture.ownerID, hamster.ID)
	if err != nil {
		t.Fatal(err)
	}
	if current.CurrentEnclosureID == nil || *current.CurrentEnclosureID != source.ID {
		t.Fatalf("hamster moved despite rollback: %#v", current.CurrentEnclosureID)
	}
	stay, err := fixture.repository.GetStayForUpdate(context.Background(), fixture.ownerID, admitted.Value.Stay.ID)
	if err != nil {
		t.Fatal(err)
	}
	if stay.EndedAt != nil || stay.Version != admitted.Value.Stay.Version {
		t.Fatalf("source stay changed despite rollback: %#v", stay)
	}
	currentSource, _ := fixture.service.GetEnclosure(context.Background(), fixture.ownerID, source.ID)
	currentTarget, _ := fixture.service.GetEnclosure(context.Background(), fixture.ownerID, target.ID)
	if currentSource.State != "occupied_single" || currentTarget.State != "vacant" {
		t.Fatalf("enclosure projection changed despite rollback: source=%s target=%s", currentSource.State, currentTarget.State)
	}
}

func TestI2WeightValidationAndLitterAggregateBranch(t *testing.T) {
	fixture := newServiceFixture(t)
	hamster := fixture.createHamster(t, "HAM-WEIGHT")
	hamsterID := hamster.ID
	for index, weight := range []float64{0, -1, 5000.01} {
		_, err := fixture.service.CreateWeight(context.Background(), fixture.ownerID, writeOptions(fmt.Sprintf("invalid-weight-%d", index)), CreateWeightInput{
			SubjectType: "hamster", HamsterID: &hamsterID, WeightG: weight,
		})
		if !errors.Is(err, ErrInvalidWeight) {
			t.Fatalf("weight %v: got %v", weight, err)
		}
	}

	organizationID := fixture.repository.organizations[fixture.ownerID]
	litterID := uuid.New()
	fixture.repository.litters[litterID] = Litter{
		ID: litterID, OwnerID: fixture.ownerID, OrganizationID: organizationID, Origin: "import",
		Code: "LITTER-HISTORY", State: "closed", Version: 1, CreatedAt: time.Now(), UpdatedAt: time.Now(),
	}
	count := 3
	_, err := fixture.service.CreateWeight(context.Background(), fixture.ownerID, writeOptions("invalid-litter-weight-shape"), CreateWeightInput{
		SubjectType: "litter", LitterID: &litterID, MeasurementKind: "individual", SubjectCount: &count, WeightG: 30,
	})
	if !errors.Is(err, ErrInvalidWeight) {
		t.Fatalf("invalid litter weight shape: got %v", err)
	}

	batch, err := fixture.service.BatchCreateWeights(context.Background(), fixture.ownerID, writeOptions("valid-weight-batch"), BatchCreateWeightsInput{Records: []CreateWeightInput{
		{SubjectType: "hamster", HamsterID: &hamsterID, MeasurementKind: "individual", WeightG: 42.25, RecordedAt: time.Now(), Source: "manual"},
		{SubjectType: "litter", LitterID: &litterID, MeasurementKind: "litter_average", SubjectCount: &count, WeightG: 9.75, RecordedAt: time.Now(), Source: "manual"},
	}})
	if err != nil {
		t.Fatalf("valid individual/litter batch: %v", err)
	}
	if len(batch.Value) != 2 || batch.Value[1].MeasurementKind != "litter_average" || batch.Value[1].SubjectCount == nil || *batch.Value[1].SubjectCount != count {
		t.Fatalf("unexpected batch result: %#v", batch.Value)
	}
	listed, err := fixture.service.ListWeightRecords(context.Background(), fixture.ownerID, WeightRecordFilter{HamsterID: &hamsterID})
	if err != nil || len(listed) != 1 || listed[0].HamsterID == nil || *listed[0].HamsterID != hamsterID {
		t.Fatalf("weight list filter: %#v err=%v", listed, err)
	}
}

func TestI2PedigreeRejectsSelfAndMultiGenerationCycles(t *testing.T) {
	fixture := newServiceFixture(t)
	grandparent := fixture.createHamster(t, "HAM-GP")
	parent := fixture.createHamster(t, "HAM-P")
	child := fixture.createHamster(t, "HAM-C")

	createParentage := func(key string, parentID, childID uuid.UUID) error {
		_, err := fixture.service.CreatePedigreeParentage(context.Background(), fixture.ownerID, writeOptions(key), CreatePedigreeParentageInput{
			ParentID: parentID, ChildID: childID, Role: "sire", EvidenceType: "manual", Confidence: 1,
			ExpectedParentVersion: 1, ExpectedChildVersion: 1,
		})
		return err
	}
	if err := createParentage("pedigree-gp-p", grandparent.ID, parent.ID); err != nil {
		t.Fatal(err)
	}
	if err := createParentage("pedigree-p-c", parent.ID, child.ID); err != nil {
		t.Fatal(err)
	}
	if err := createParentage("pedigree-self", child.ID, child.ID); !errors.Is(err, ErrPedigreeCycle) {
		t.Fatalf("self parentage: got %v", err)
	}
	if err := createParentage("pedigree-cycle", child.ID, grandparent.ID); !errors.Is(err, ErrPedigreeCycle) {
		t.Fatalf("multi-generation cycle: got %v", err)
	}
}

func TestI2PedigreeReplaceAndEndRequireCorrectionReason(t *testing.T) {
	fixture := newServiceFixture(t)
	sireA := fixture.createHamsterWithSex(t, "HAM-SIRE-A", "male")
	sireB := fixture.createHamsterWithSex(t, "HAM-SIRE-B", "male")
	child := fixture.createHamsterWithSex(t, "HAM-CHILD-R", "female")
	now := time.Date(2026, 7, 25, 12, 0, 0, 0, time.UTC)

	_, err := fixture.service.CreatePedigreeParentage(context.Background(), fixture.ownerID, writeOptions("ped-first"), CreatePedigreeParentageInput{
		ParentID: sireA.ID, ChildID: child.ID, Role: "sire", EvidenceType: "manual", Confidence: 1, ValidFrom: now,
	})
	if err != nil {
		t.Fatal(err)
	}

	// Replace without reason → duplicate.
	_, err = fixture.service.CreatePedigreeParentage(context.Background(), fixture.ownerID, writeOptions("ped-replace-no-reason"), CreatePedigreeParentageInput{
		ParentID: sireB.ID, ChildID: child.ID, Role: "sire", EvidenceType: "manual", Confidence: 1, ValidFrom: now,
	})
	if !errors.Is(err, ErrDuplicate) {
		t.Fatalf("replace without reason: got %v", err)
	}

	reason := "选错父本"
	replaced, err := fixture.service.CreatePedigreeParentage(context.Background(), fixture.ownerID, writeOptions("ped-replace"), CreatePedigreeParentageInput{
		ParentID: sireB.ID, ChildID: child.ID, Role: "sire", EvidenceType: "manual", Confidence: 1, ValidFrom: now,
		CorrectionReason: &reason,
	})
	if err != nil {
		t.Fatal(err)
	}
	if replaced.Value.ParentID != sireB.ID {
		t.Fatalf("replaced parent: %#v", replaced.Value)
	}

	listed, err := fixture.service.ListPedigreeParentages(context.Background(), fixture.ownerID, PedigreeParentageFilter{ChildHamsterID: &child.ID})
	if err != nil {
		t.Fatal(err)
	}
	active := 0
	for _, p := range listed {
		if p.Status == "accepted" && p.ValidTo == nil {
			active++
			if p.ParentID != sireB.ID {
				t.Fatalf("active parent should be B: %#v", p)
			}
		}
	}
	if active != 1 {
		t.Fatalf("expected 1 active parentage, listed=%#v", listed)
	}

	ended, err := fixture.service.EndPedigreeParentage(context.Background(), fixture.ownerID, writeOptions("ped-end"), EndPedigreeParentageInput{
		ChildID: child.ID, Role: "sire", CorrectionReason: "核实后无父本记录",
	})
	if err != nil {
		t.Fatal(err)
	}
	if ended.Value.Status != "superseded" {
		t.Fatalf("ended status: %#v", ended.Value)
	}

	listed, err = fixture.service.ListPedigreeParentages(context.Background(), fixture.ownerID, PedigreeParentageFilter{ChildHamsterID: &child.ID})
	if err != nil {
		t.Fatal(err)
	}
	for _, p := range listed {
		if p.Status == "accepted" && p.ValidTo == nil {
			t.Fatalf("still active after end: %#v", p)
		}
	}
}

func TestI2PedigreeListAndGraphExposeCommonAncestor(t *testing.T) {
	fixture := newServiceFixture(t)
	grandparent := fixture.createHamsterWithSex(t, "HAM-GRAPH-GP", "male")
	sire := fixture.createHamsterWithSex(t, "HAM-GRAPH-SIRE", "male")
	dam := fixture.createHamsterWithSex(t, "HAM-GRAPH-DAM", "female")
	child := fixture.createHamsterWithSex(t, "HAM-GRAPH-CHILD", "male")
	now := time.Date(2026, 7, 16, 10, 0, 0, 0, time.UTC)
	create := func(key string, parent, descendant uuid.UUID, role string) {
		t.Helper()
		_, err := fixture.service.CreatePedigreeParentage(context.Background(), fixture.ownerID, writeOptions(key), CreatePedigreeParentageInput{
			ParentID: parent, ChildID: descendant, Role: role, EvidenceType: "manual", Confidence: 1, ValidFrom: now,
		})
		if err != nil {
			t.Fatalf("create parentage %s: %v", key, err)
		}
	}
	create("graph-gp-sire", grandparent.ID, sire.ID, "sire")
	create("graph-gp-dam", grandparent.ID, dam.ID, "sire")
	create("graph-sire-child", sire.ID, child.ID, "sire")
	create("graph-dam-child", dam.ID, child.ID, "dam")

	listed, err := fixture.service.ListPedigreeParentages(context.Background(), fixture.ownerID, PedigreeParentageFilter{ChildHamsterID: &child.ID})
	if err != nil || len(listed) != 2 {
		t.Fatalf("parentage list: %#v err=%v", listed, err)
	}
	graph, err := fixture.service.GetHamsterPedigree(context.Background(), fixture.ownerID, child.ID, 4)
	if err != nil {
		t.Fatal(err)
	}
	if len(graph.Nodes) != 4 || len(graph.Parentages) != 4 || len(graph.CommonAncestors) != 1 || graph.CommonAncestors[0].HamsterID != grandparent.ID || graph.CommonAncestors[0].Paths != 2 {
		t.Fatalf("unexpected pedigree graph: %#v", graph)
	}

	_, err = fixture.service.CreatePedigreeParentage(context.Background(), fixture.ownerID, writeOptions("graph-role-conflict"), CreatePedigreeParentageInput{
		ParentID: dam.ID, ChildID: sire.ID, Role: "sire", EvidenceType: "manual", Confidence: 1, ValidFrom: now,
	})
	if !errors.Is(err, ErrValidation) {
		t.Fatalf("sex/role conflict: got %v", err)
	}
}

func TestI2CreateAndListLitterParentsWithRoleAndCycleChecks(t *testing.T) {
	fixture := newServiceFixture(t)
	organizationID := fixture.repository.organizations[fixture.ownerID]
	member := fixture.createHamsterWithSex(t, "HAM-LITTER-MEMBER", "male")
	sire := fixture.createHamsterWithSex(t, "HAM-LITTER-SIRE", "male")
	female := fixture.createHamsterWithSex(t, "HAM-LITTER-FEMALE", "female")
	litterID := uuid.New()
	fixture.repository.litters[litterID] = Litter{
		ID: litterID, OwnerID: fixture.ownerID, OrganizationID: organizationID, Origin: "import",
		Code: "LITTER-PARENTS", State: "closed", DamCondition: map[string]any{}, Version: 1,
		CreatedAt: time.Now(), UpdatedAt: time.Now(),
	}
	fixture.repository.litterMembers[litterID] = []LitterMember{{
		ID: uuid.New(), LitterID: litterID, MemberType: "hamster", HamsterID: &member.ID,
		EvidenceType: "imported", Confidence: 1, Status: "accepted", ValidFrom: time.Now(), Version: 1,
	}}

	created, err := fixture.service.CreateLitterParent(context.Background(), fixture.ownerID, writeOptions("create-litter-sire"), CreateLitterParentInput{
		LitterID: litterID, HamsterID: sire.ID, Role: "sire", EvidenceType: "imported", Confidence: 0.9, ExpectedLitterVersion: 1,
	})
	if err != nil {
		t.Fatal(err)
	}
	if created.Value.Litter.SireID == nil || *created.Value.Litter.SireID != sire.ID || created.Value.Litter.Version != 2 {
		t.Fatalf("litter parent projection: %#v", created.Value)
	}
	parents, err := fixture.service.ListLitterParents(context.Background(), fixture.ownerID, litterID, Page{})
	if err != nil || len(parents) != 1 || parents[0].ParentID != sire.ID {
		t.Fatalf("litter parent list: %#v err=%v", parents, err)
	}
	members, err := fixture.service.ListLitterMembers(context.Background(), fixture.ownerID, litterID, Page{})
	if err != nil || len(members) != 1 || members[0].HamsterID == nil || *members[0].HamsterID != member.ID {
		t.Fatalf("litter member list: %#v err=%v", members, err)
	}
	graph, err := fixture.service.GetHamsterPedigree(context.Background(), fixture.ownerID, member.ID, 4)
	if err != nil || len(graph.Nodes) != 2 || len(graph.LitterParents) != 1 || len(graph.LitterMembers) != 1 {
		t.Fatalf("litter-derived pedigree graph: %#v err=%v", graph, err)
	}

	_, err = fixture.service.CreateLitterParent(context.Background(), fixture.ownerID, writeOptions("litter-parent-role-conflict"), CreateLitterParentInput{
		LitterID: litterID, HamsterID: female.ID, Role: "sire", EvidenceType: "manual", Confidence: 1, ExpectedLitterVersion: 2,
	})
	if !errors.Is(err, ErrValidation) {
		t.Fatalf("litter parent sex/role conflict: got %v", err)
	}
	_, err = fixture.service.CreateLitterParent(context.Background(), fixture.ownerID, writeOptions("litter-parent-self-cycle"), CreateLitterParentInput{
		LitterID: litterID, HamsterID: member.ID, Role: "sire", EvidenceType: "manual", Confidence: 1, ExpectedLitterVersion: 2,
	})
	if !errors.Is(err, ErrPedigreeCycle) {
		t.Fatalf("litter member as parent: got %v", err)
	}
}

func TestI2OwnerIsolationUsesNotFoundSemantics(t *testing.T) {
	fixture := newServiceFixture(t)
	hamster := fixture.createHamster(t, "HAM-OWNER-A")
	enclosure := fixture.createEnclosure(t, "ENC-OWNER-A")
	otherOwner := uuid.New()
	_, otherRule := fixture.repository.provision(otherOwner)

	if _, err := fixture.service.GetHamster(context.Background(), otherOwner, hamster.ID); !errors.Is(err, ErrNotFound) {
		t.Fatalf("cross-owner hamster read: got %v", err)
	}
	name := "cross owner"
	if _, err := fixture.service.UpdateHamster(context.Background(), otherOwner, hamster.ID, writeOptions("cross-owner-update"), UpdateHamsterInput{ExpectedVersion: hamster.Version, Name: &name}); !errors.Is(err, ErrNotFound) {
		t.Fatalf("cross-owner hamster update: got %v", err)
	}
	otherHamsterResult, err := fixture.service.CreateHamster(context.Background(), otherOwner, writeOptions("other-owner-hamster"), CreateHamsterInput{
		InternalCode: "HAM-OWNER-B", SpeciesRuleVersionID: otherRule,
	})
	if err != nil {
		t.Fatal(err)
	}
	_, err = fixture.service.CreatePedigreeParentage(context.Background(), otherOwner, writeOptions("cross-owner-parentage"), CreatePedigreeParentageInput{
		ParentID: hamster.ID, ChildID: otherHamsterResult.Value.ID, Role: "sire", ExpectedParentVersion: 1, ExpectedChildVersion: 1,
	})
	if !errors.Is(err, ErrNotFound) {
		t.Fatalf("cross-owner parentage: got %v", err)
	}
	if _, err := fixture.service.GetEnclosure(context.Background(), otherOwner, enclosure.ID); !errors.Is(err, ErrNotFound) {
		t.Fatalf("cross-owner enclosure read: got %v", err)
	}
}

func TestI2CleaningRecordUpdatesProjectionAndRemainsOwnerScoped(t *testing.T) {
	fixture := newServiceFixture(t)
	enclosure := fixture.createEnclosure(t, "ENC-CLEAN", "full_due")
	performedAt := time.Date(2026, 7, 16, 12, 0, 0, 0, time.UTC)
	created, err := fixture.service.CreateEnclosureCleaning(context.Background(), fixture.ownerID, writeOptions("clean-enclosure"), CreateEnclosureCleaningInput{
		EnclosureID: enclosure.ID, CleaningType: "disinfection", PerformedAt: performedAt,
		Supplies: map[string]any{"disinfectant": "fixture"}, ExpectedEnclosureVersion: enclosure.Version,
	})
	if err != nil {
		t.Fatal(err)
	}
	if created.Value.Enclosure.Cleanliness != "clean" || created.Value.Enclosure.LastCleanedAt == nil || !created.Value.Enclosure.LastCleanedAt.Equal(performedAt) {
		t.Fatalf("cleaning projection not updated: %#v", created.Value.Enclosure)
	}
	history, err := fixture.service.ListEnclosureCleanings(context.Background(), fixture.ownerID, enclosure.ID, Page{})
	if err != nil || len(history) != 1 || history[0].ID != created.Value.Cleaning.ID {
		t.Fatalf("cleaning history: %#v err=%v", history, err)
	}
	otherOwner := uuid.New()
	fixture.repository.provision(otherOwner)
	if _, err := fixture.service.GetEnclosureCleaning(context.Background(), otherOwner, created.Value.Cleaning.ID); !errors.Is(err, ErrNotFound) {
		t.Fatalf("cross-owner cleaning read: got %v", err)
	}
}

func TestI2HistoricalLitterProjectsNullableParentsAndRelations(t *testing.T) {
	fixture := newServiceFixture(t)
	organizationID := fixture.repository.organizations[fixture.ownerID]
	litterID := uuid.New()
	hamster := fixture.createHamster(t, "HAM-HISTORY-MEMBER")
	fixture.repository.litters[litterID] = Litter{
		ID: litterID, OwnerID: fixture.ownerID, OrganizationID: organizationID, Origin: "import",
		Code: "LITTER-IMPORT-001", State: "closed", DamCondition: map[string]any{}, Version: 1,
		CreatedAt: time.Now(), UpdatedAt: time.Now(),
	}
	fixture.repository.litterMembers[litterID] = []LitterMember{{
		ID: uuid.New(), LitterID: litterID, MemberType: "hamster", HamsterID: &hamster.ID,
		EvidenceType: "imported", Confidence: 1, Status: "accepted", Version: 1,
	}}

	listed, err := fixture.service.ListLitters(context.Background(), fixture.ownerID, LitterFilter{Origin: "import"})
	if err != nil || len(listed) != 1 {
		t.Fatalf("historical litter list: %#v err=%v", listed, err)
	}
	if listed[0].BreedingPlanID != nil || listed[0].SireID != nil || listed[0].DamID != nil || listed[0].BornAt != nil || listed[0].EnclosureID != nil {
		t.Fatalf("historical litter nullable fields changed: %#v", listed[0])
	}
	relations, err := fixture.service.GetLitterRelations(context.Background(), fixture.ownerID, litterID)
	if err != nil || len(relations.Parents) != 0 || len(relations.Members) != 1 || relations.Members[0].HamsterID == nil || *relations.Members[0].HamsterID != hamster.ID {
		t.Fatalf("historical litter relations: %#v err=%v", relations, err)
	}
}

func TestI2OptimisticVersionConflict(t *testing.T) {
	fixture := newServiceFixture(t)
	hamster := fixture.createHamster(t, "HAM-VERSION")
	name := "new name"
	_, err := fixture.service.UpdateHamster(context.Background(), fixture.ownerID, hamster.ID, writeOptions("stale-hamster-update"), UpdateHamsterInput{
		ExpectedVersion: hamster.Version + 1, Name: &name,
	})
	if !errors.Is(err, ErrVersionConflict) {
		t.Fatalf("stale hamster update: got %v", err)
	}
}
