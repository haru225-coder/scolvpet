package importcsv

import (
	"context"
	"errors"
	"os"
	"path/filepath"
	"testing"
	"time"
)

const (
	testOwner = "owner-1"
	testOrg   = "org-1"
	testRule  = "rule-1"
	testUser  = "operator-1"
)

func TestLegalHamsterCSVBuildsAndCommitsAtomicHistoricalLitterPlan(t *testing.T) {
	store := newFakeStore(baseSnapshot())
	engine := testEngine(store)
	file := mustParseFixture(t, "legal-hamster.csv")
	report, err := engine.Preflight(context.Background(), PreflightRequest{
		OwnerID:        testOwner,
		OrganizationID: testOrg,
		OperatorID:     testUser,
		File:           file,
		Options:        PreflightOptions{SpeciesRuleVersionID: testRule},
	})
	if err != nil {
		t.Fatalf("Preflight: %v", err)
	}
	if !report.ReadyToCommit || report.BlockingIssueCount != 0 {
		t.Fatalf("report not ready: %+v", report.Issues)
	}
	if report.HistoricalLittersToCreate != 1 {
		t.Fatalf("historical litters = %d", report.HistoricalLittersToCreate)
	}
	wantCounts := map[OperationKind]int{
		OperationCreateHamster:           2,
		OperationCreateLitter:            1,
		OperationCreateLitterParent:      2,
		OperationCreateLitterMember:      2,
		OperationCreatePedigreeParentage: 4,
		OperationCreateEnclosureStay:     2,
	}
	for kind, want := range wantCounts {
		if got := operationCount(report.Plan.Operations, kind); got != want {
			t.Fatalf("%s operations = %d, want %d", kind, got, want)
		}
	}
	var litter *LitterWrite
	for _, operation := range report.Plan.Operations {
		if operation.Kind == OperationCreateLitter {
			litter = operation.Litter
			break
		}
	}
	if litter == nil || litter.Code != "L-2026-01" || litter.Origin != "import" || litter.State != "closed" || litter.BreedingPlanID != "" || litter.EnclosureID != "" || litter.SireID != "sire-1" || litter.DamID != "dam-1" {
		t.Fatalf("historical litter contract mismatch: %+v", litter)
	}
	receipt, err := engine.Commit(context.Background(), CommitRequest{OwnerID: testOwner, BatchKey: "batch-legal-001", Report: report})
	if err != nil {
		t.Fatalf("Commit: %v", err)
	}
	if receipt.Status != JobSucceeded || receipt.ImportStatus != ImportJobSucceeded || receipt.AppliedOperations != len(report.Plan.Operations) {
		t.Fatalf("receipt = %+v", receipt)
	}
	for _, row := range receipt.Rows {
		if row.Status != RowImported {
			t.Fatalf("row %d status = %s", row.RowNumber, row.Status)
		}
	}
}

func TestDirtyCSVCollectsAllErrorsAndBlocksWholeLitterGroups(t *testing.T) {
	snapshot := baseSnapshot()
	birth := mustDate("2025-01-01")
	snapshot.Hamsters = append(snapshot.Hamsters,
		HamsterRecord{ID: "existing-1", OwnerID: testOwner, InternalCode: "EXIST-001", SpeciesRuleVersionID: testRule, Sex: "male", BirthDate: &birth, SourceType: "imported", LifecycleStatus: "active", BreedingStatus: "candidate", CurrentEnclosureID: "cage-2", Version: 3},
		HamsterRecord{ID: "amb-1", OwnerID: testOwner, InternalCode: "AMB-SIRE", SpeciesRuleVersionID: testRule, Sex: "male", Version: 1},
		HamsterRecord{ID: "amb-2", OwnerID: testOwner, InternalCode: "AMB-SIRE", SpeciesRuleVersionID: testRule, Sex: "male", Version: 1},
	)
	store := newFakeStore(snapshot)
	engine := testEngine(store)
	report, err := engine.Preflight(context.Background(), PreflightRequest{
		OwnerID:        testOwner,
		OrganizationID: testOrg,
		OperatorID:     testUser,
		File:           mustParseFixture(t, "dirty-hamster.csv"),
		Options:        PreflightOptions{SpeciesRuleVersionID: testRule},
	})
	if err != nil {
		t.Fatalf("Preflight: %v", err)
	}
	if report.ReadyToCommit || report.InvalidRows != 4 {
		t.Fatalf("ready=%v invalid=%d issues=%+v", report.ReadyToCommit, report.InvalidRows, report.Issues)
	}
	for _, code := range []string{"DUPLICATE_INTERNAL_CODE", "PARENT_NOT_FOUND", "PARENT_AMBIGUOUS", "LITTER_FACT_CONFLICT", "CORE_FIELD_CONFLICT", "ENCLOSURE_CONFLICT", "LITTER_GROUP_BLOCKED"} {
		if !reportHasIssue(report, code) {
			t.Errorf("missing issue code %s", code)
		}
	}
	for _, rowNumber := range []int{2, 3} {
		if !rowHasIssue(report, rowNumber, "LITTER_GROUP_BLOCKED") {
			t.Errorf("row %d was not group-blocked", rowNumber)
		}
	}
	_, err = engine.Commit(context.Background(), CommitRequest{OwnerID: testOwner, BatchKey: "batch-dirty-001", Report: report})
	if !errors.Is(err, ErrBlockingIssues) {
		t.Fatalf("Commit error = %v, want ErrBlockingIssues", err)
	}
	if store.transactionCalls != 0 {
		t.Fatalf("blocking guard opened %d transactions", store.transactionCalls)
	}
}

func TestPedigreeCycleAcrossSameBatchIsFullyReported(t *testing.T) {
	file, err := Parse([]byte("internal_code,sex,sire_code\nA,male,B\nB,male,A\n"), ParseOptions{Template: TemplateHamster})
	if err != nil {
		t.Fatalf("Parse: %v", err)
	}
	store := newFakeStore(baseSnapshot())
	report, err := testEngine(store).Preflight(context.Background(), PreflightRequest{
		OwnerID: testOwner, OrganizationID: testOrg, OperatorID: testUser, File: file,
		Options: PreflightOptions{SpeciesRuleVersionID: testRule},
	})
	if err != nil {
		t.Fatalf("Preflight: %v", err)
	}
	if report.InvalidRows != 2 || !rowHasIssue(report, 2, "PEDIGREE_CYCLE") || !rowHasIssue(report, 3, "PEDIGREE_CYCLE") {
		t.Fatalf("cycle issues = %+v", report.Issues)
	}
}

func TestParentLookupIsStrictlyOwnerScoped(t *testing.T) {
	snapshot := baseSnapshot()
	snapshot.Hamsters = append(snapshot.Hamsters, HamsterRecord{ID: "foreign-parent", OwnerID: "owner-2", InternalCode: "FOREIGN-SIRE", SpeciesRuleVersionID: testRule, Sex: "male"})
	file, err := Parse([]byte("internal_code,sex,sire_code\nCHILD-1,female,FOREIGN-SIRE\n"), ParseOptions{Template: TemplateHamster})
	if err != nil {
		t.Fatalf("Parse: %v", err)
	}
	report, err := testEngine(newFakeStore(snapshot)).Preflight(context.Background(), PreflightRequest{
		OwnerID: testOwner, OrganizationID: testOrg, OperatorID: testUser, File: file,
		Options: PreflightOptions{SpeciesRuleVersionID: testRule},
	})
	if err != nil {
		t.Fatalf("Preflight: %v", err)
	}
	if !rowHasIssue(report, 2, "PARENT_NOT_FOUND") {
		t.Fatalf("foreign owner reference was visible: %+v", report.Issues)
	}
}

func TestUnknownHistoricalLitterAllowsNullableParentsAndEnclosure(t *testing.T) {
	file, err := Parse([]byte("internal_code,sex,born_at,litter_code\nORPHAN-1,unknown,2026-04-01,L-UNKNOWN\n"), ParseOptions{Template: TemplateHamster})
	if err != nil {
		t.Fatalf("Parse: %v", err)
	}
	report, err := testEngine(newFakeStore(baseSnapshot())).Preflight(context.Background(), PreflightRequest{
		OwnerID: testOwner, OrganizationID: testOrg, OperatorID: testUser, File: file,
		Options: PreflightOptions{SpeciesRuleVersionID: testRule},
	})
	if err != nil || !report.ReadyToCommit {
		t.Fatalf("Preflight err=%v issues=%+v", err, report.Issues)
	}
	var litter *LitterWrite
	for _, operation := range report.Plan.Operations {
		if operation.Kind == OperationCreateLitter {
			litter = operation.Litter
		}
	}
	if litter == nil || litter.Origin != "import" || litter.State != "closed" || litter.Code != "L-UNKNOWN" || litter.SireID != "" || litter.DamID != "" || litter.EnclosureID != "" || litter.BreedingPlanID != "" {
		t.Fatalf("nullable historical litter = %+v", litter)
	}
}

func TestNonCoreApprovedUpdatesAndIdempotentReplay(t *testing.T) {
	snapshot := baseSnapshot()
	snapshot.Hamsters = append(snapshot.Hamsters, HamsterRecord{
		ID: "hamster-existing", OwnerID: testOwner, InternalCode: "H-UPDATE", Name: "旧名", SpeciesRuleVersionID: testRule,
		Sex: "female", SourceType: "imported", LifecycleStatus: "active", BreedingStatus: "candidate", Version: 7,
	})
	file, err := Parse([]byte("internal_code,name,notes\nH-UPDATE,新名,补充备注\n"), ParseOptions{Template: TemplateHamster})
	if err != nil {
		t.Fatalf("Parse: %v", err)
	}
	store := newFakeStore(snapshot)
	engine := testEngine(store)
	report, err := engine.Preflight(context.Background(), PreflightRequest{
		OwnerID: testOwner, OrganizationID: testOrg, OperatorID: testUser, File: file,
		Options: PreflightOptions{SpeciesRuleVersionID: testRule},
	})
	if err != nil || !report.ReadyToCommit {
		t.Fatalf("Preflight: err=%v issues=%+v", err, report.Issues)
	}
	if len(report.UpdateCandidates) != 1 || len(report.UpdateCandidates[0].Fields) != 2 {
		t.Fatalf("candidates = %+v", report.UpdateCandidates)
	}
	approval := ApprovedUpdate{RowNumber: 2, ResourceID: "hamster-existing", ExpectedVersion: 7, Fields: []string{"notes"}}
	receipt, err := engine.Commit(context.Background(), CommitRequest{OwnerID: testOwner, BatchKey: "batch-update-001", Report: report, ApprovedUpdates: []ApprovedUpdate{approval}})
	if err != nil {
		t.Fatalf("Commit: %v", err)
	}
	if receipt.Rows[0].Status != RowImported || operationCount(store.applied, OperationUpdateHamster) != 1 {
		t.Fatalf("receipt=%+v operations=%+v", receipt, store.applied)
	}
	update := store.applied[0].HamsterUpdate
	if update == nil || len(update.Fields) != 1 || update.Fields["notes"] != "补充备注" {
		t.Fatalf("approved update = %+v", update)
	}
	replayed, err := engine.Commit(context.Background(), CommitRequest{OwnerID: testOwner, BatchKey: "batch-update-001", Report: report, ApprovedUpdates: []ApprovedUpdate{approval}})
	if err != nil || !replayed.Replayed {
		t.Fatalf("replay receipt=%+v err=%v", replayed, err)
	}
	_, err = engine.Commit(context.Background(), CommitRequest{
		OwnerID: testOwner, BatchKey: "batch-update-001", Report: report,
		ApprovedUpdates: []ApprovedUpdate{{RowNumber: 2, ResourceID: "hamster-existing", ExpectedVersion: 7, Fields: []string{"name"}}},
	})
	if !errors.Is(err, ErrBatchKeyConflict) {
		t.Fatalf("changed replay error = %v", err)
	}
}

func TestCommitFailureRollsBackWholePlan(t *testing.T) {
	store := newFakeStore(baseSnapshot())
	store.failKind = OperationCreateLitterMember
	engine := testEngine(store)
	report, err := engine.Preflight(context.Background(), PreflightRequest{
		OwnerID: testOwner, OrganizationID: testOrg, OperatorID: testUser, File: mustParseFixture(t, "legal-hamster.csv"),
		Options: PreflightOptions{SpeciesRuleVersionID: testRule},
	})
	if err != nil || !report.ReadyToCommit {
		t.Fatalf("Preflight err=%v issues=%+v", err, report.Issues)
	}
	if _, err := engine.Commit(context.Background(), CommitRequest{OwnerID: testOwner, BatchKey: "batch-rollback-1", Report: report}); err == nil {
		t.Fatal("Commit unexpectedly succeeded")
	}
	if len(store.applied) != 0 || len(store.commits) != 0 {
		t.Fatalf("transaction leaked applied=%d commits=%d", len(store.applied), len(store.commits))
	}
	store.failKind = ""
	if _, err := engine.Commit(context.Background(), CommitRequest{OwnerID: testOwner, BatchKey: "batch-rollback-1", Report: report}); err != nil {
		t.Fatalf("retry after rollback: %v", err)
	}
	if len(store.applied) != len(report.Plan.Operations) {
		t.Fatalf("applied=%d want=%d", len(store.applied), len(report.Plan.Operations))
	}
}

func TestWeightTemplateSupportsLitterAggregateAndCollectsInvalidWeights(t *testing.T) {
	snapshot := baseSnapshot()
	born := mustDate("2026-05-01")
	snapshot.Litters = append(snapshot.Litters, LitterRecord{ID: "litter-existing", OwnerID: testOwner, Code: "L-WEIGHT", BornAt: &born})
	store := newFakeStore(snapshot)
	engine := testEngine(store)
	valid, err := Parse([]byte("subject_type,litter_code,measurement_kind,subject_count,weight_g,recorded_at\nlitter,L-WEIGHT,litter_average,4,18.25,2026-07-01 08:00\n"), ParseOptions{})
	if err != nil {
		t.Fatalf("Parse valid: %v", err)
	}
	report, err := engine.Preflight(context.Background(), PreflightRequest{OwnerID: testOwner, OrganizationID: testOrg, OperatorID: testUser, File: valid})
	if err != nil || !report.ReadyToCommit {
		t.Fatalf("Preflight valid err=%v issues=%+v", err, report.Issues)
	}
	if len(report.Plan.Operations) != 1 {
		t.Fatalf("operations = %+v", report.Plan.Operations)
	}
	weight := report.Plan.Operations[0].WeightRecord
	if weight == nil || weight.SubjectType != "litter" || weight.MeasurementKind != "litter_average" || weight.SubjectCount == nil || *weight.SubjectCount != 4 || weight.LitterID != "litter-existing" {
		t.Fatalf("weight plan = %+v", weight)
	}
	invalid, err := Parse([]byte("hamster_code,weight_g,recorded_at\nSIRE-001,0,not-a-date\nMISSING,abc,2026-07-01\nDAM-001,5000.01,2026-07-01\n"), ParseOptions{})
	if err != nil {
		t.Fatalf("Parse invalid: %v", err)
	}
	badReport, err := engine.Preflight(context.Background(), PreflightRequest{OwnerID: testOwner, OrganizationID: testOrg, OperatorID: testUser, File: invalid})
	if err != nil {
		t.Fatalf("Preflight invalid: %v", err)
	}
	if badReport.InvalidRows != 3 || !reportHasIssue(badReport, "INVALID_WEIGHT") || !reportHasIssue(badReport, "INVALID_DATETIME") || !reportHasIssue(badReport, "HAMSTER_NOT_FOUND") {
		t.Fatalf("invalid weight issues = %+v", badReport.Issues)
	}
}

func TestEnclosureTemplateBuildsCreatePlan(t *testing.T) {
	file, err := Parse([]byte("code;rack_code;level_code;capacity;state;cleanliness\nC-NEW;R1;L2;3;vacant;clean\n"), ParseOptions{})
	if err != nil {
		t.Fatalf("Parse: %v", err)
	}
	report, err := testEngine(newFakeStore(baseSnapshot())).Preflight(context.Background(), PreflightRequest{OwnerID: testOwner, OrganizationID: testOrg, OperatorID: testUser, File: file})
	if err != nil || !report.ReadyToCommit {
		t.Fatalf("Preflight err=%v issues=%+v", err, report.Issues)
	}
	if len(report.Plan.Operations) != 1 || report.Plan.Operations[0].Kind != OperationCreateEnclosure || report.Plan.Operations[0].Enclosure.Capacity != 3 {
		t.Fatalf("enclosure plan = %+v", report.Plan.Operations)
	}
}

func baseSnapshot() Snapshot {
	return Snapshot{
		OwnerID:        testOwner,
		OrganizationID: testOrg,
		Hamsters: []HamsterRecord{
			{ID: "sire-1", OwnerID: testOwner, InternalCode: "SIRE-001", SpeciesRuleVersionID: testRule, Sex: "male", SourceType: "imported", LifecycleStatus: "active", BreedingStatus: "active", Version: 1},
			{ID: "dam-1", OwnerID: testOwner, InternalCode: "DAM-001", SpeciesRuleVersionID: testRule, Sex: "female", SourceType: "imported", LifecycleStatus: "active", BreedingStatus: "active", Version: 1},
		},
		Enclosures: []EnclosureRecord{
			{ID: "cage-1", OwnerID: testOwner, Code: "CAGE-001", Capacity: 2, State: "vacant", Cleanliness: "clean", Version: 1},
			{ID: "cage-2", OwnerID: testOwner, Code: "CAGE-002", Capacity: 2, State: "vacant", Cleanliness: "clean", Version: 1},
		},
		WeightAcquisitionKeys: make(map[string]string),
	}
}

func testEngine(store Store) *Engine {
	sequence := 0
	return New(store,
		WithClock(func() time.Time { return time.Date(2026, 7, 16, 12, 0, 0, 0, time.FixedZone("CST", 8*60*60)) }),
		WithIDGenerator(func() string {
			sequence++
			return "generated-" + time.Unix(int64(sequence), 0).UTC().Format("150405")
		}),
	)
}

func mustParseFixture(t *testing.T, name string) *ParsedFile {
	t.Helper()
	path := filepath.Join("..", "..", "testdata", "i2-csv", name)
	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("read fixture: %v", err)
	}
	file, err := Parse(data, ParseOptions{})
	if err != nil {
		t.Fatalf("Parse fixture: %v", err)
	}
	return file
}

func mustDate(value string) time.Time {
	parsed, err := time.Parse("2006-01-02", value)
	if err != nil {
		panic(err)
	}
	return parsed
}

func reportHasIssue(report *PreflightReport, code string) bool {
	for _, issue := range report.Issues {
		if issue.Code == code {
			return true
		}
	}
	return false
}

func rowHasIssue(report *PreflightReport, rowNumber int, code string) bool {
	for _, row := range report.Rows {
		if row.RowNumber != rowNumber {
			continue
		}
		return hasIssueCode(row.Issues, code)
	}
	return false
}
