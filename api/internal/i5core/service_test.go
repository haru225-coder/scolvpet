package i5core

import (
	"errors"
	"testing"
	"time"

	"github.com/google/uuid"
)

func TestValidateHealthRecordRequiresOneOwnerScopedSubject(t *testing.T) {
	now := time.Date(2026, 7, 16, 8, 0, 0, 0, time.UTC)
	if err := validateHealthRecord(CreateHealthRecordInput{Type: "daily_check", ObservedAt: now}); !errors.Is(err, ErrValidation) {
		t.Fatalf("missing subject error = %v", err)
	}
	hamsterID := uuid.New()
	litterID := uuid.New()
	if err := validateHealthRecord(CreateHealthRecordInput{HamsterID: &hamsterID, LitterID: &litterID, Type: "daily_check", ObservedAt: now}); !errors.Is(err, ErrValidation) {
		t.Fatalf("multiple subjects error = %v", err)
	}
	if err := validateHealthRecord(CreateHealthRecordInput{HamsterID: &hamsterID, Type: "daily_check", ObservedAt: now, FollowUpAt: ptrTime(now.Add(-time.Minute))}); !errors.Is(err, ErrValidation) {
		t.Fatalf("follow-up ordering error = %v", err)
	}
}

func TestValidateCareTaskAcceptsSubjectFreeManualTaskAndRejectsDuplicateSubjects(t *testing.T) {
	input := CreateCareTaskInput{TaskType: "custom", TargetType: "hamster", TargetID: uuid.New(), ScheduledAt: time.Now(), Priority: "normal"}
	if err := validateCareTask(input); err != nil {
		t.Fatalf("subject-free task should validate: %v", err)
	}
	subjectID := uuid.New()
	input.SubjectIDs = []uuid.UUID{subjectID, subjectID}
	if err := validateCareTask(input); !errors.Is(err, ErrValidation) {
		t.Fatalf("duplicate subjects error = %v", err)
	}
}

func TestValidateCompleteTaskRequiresVersionAndExceptionReason(t *testing.T) {
	subjectID := uuid.New()
	input := CompleteTaskInput{ExpectedVersion: 2, CompletedAt: time.Now(), SubjectResults: []TaskSubjectResult{{SubjectID: subjectID, Status: "excepted"}}}
	if err := validateCompleteTask(input); !errors.Is(err, ErrValidation) {
		t.Fatalf("missing exception reason error = %v", err)
	}
	reason := "延后观察"
	input.SubjectResults[0].ExceptionReason = &reason
	if err := validateCompleteTask(input); err != nil {
		t.Fatalf("valid exception result error = %v", err)
	}
}

func TestCanonicalRequestNormalizesJSONForIdempotency(t *testing.T) {
	left := canonicalRequest("post", "/v1/tasks", []byte(`{"b":2,"a":1}`))
	right := canonicalRequest("POST", "/v1/tasks", []byte(`{"a":1,"b":2}`))
	if left != right {
		t.Fatalf("canonical request mismatch: %q != %q", left, right)
	}
	if left == canonicalRequest("POST", "/v1/other", []byte(`{"a":1,"b":2}`)) {
		t.Fatal("path must participate in idempotency hash")
	}
}

func ptrTime(value time.Time) *time.Time {
	return &value
}
