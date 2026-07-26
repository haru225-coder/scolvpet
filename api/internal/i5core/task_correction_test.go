package i5core

import (
	"errors"
	"strings"
	"testing"

	"github.com/google/uuid"
)

// Wave 1 correction loop: a task must be cancellable and a wrong completion must
// be undoable. These freeze the state machine so a later refactor cannot quietly
// reopen a pending task or cancel a completed one.

func TestCanCancelTaskOnlyFromLiveStates(t *testing.T) {
	live := []string{"pending", "in_progress", "snoozed"}
	for _, state := range live {
		if !CanCancelTask(state) {
			t.Fatalf("state %q should be cancellable", state)
		}
	}
	terminal := []string{"completed", "cancelled", "superseded", "", "unknown"}
	for _, state := range terminal {
		if CanCancelTask(state) {
			t.Fatalf("state %q must not be cancellable directly", state)
		}
	}
}

func TestCanReopenTaskOnlyFromEndStates(t *testing.T) {
	for _, state := range []string{"completed", "cancelled"} {
		if !CanReopenTask(state) {
			t.Fatalf("state %q should be reopenable", state)
		}
	}
	for _, state := range []string{"pending", "in_progress", "snoozed", "superseded", ""} {
		if CanReopenTask(state) {
			t.Fatalf("state %q must not be reopenable", state)
		}
	}
}

// A cancelled or reopened task with no stated reason is indistinguishable from
// data loss when read back, so the service rejects it before touching the DB.
func TestCancelTaskRejectsMissingReason(t *testing.T) {
	service := &Service{}
	ctx := t.Context()
	cases := []struct {
		name  string
		input CancelTaskInput
	}{
		{"empty", CancelTaskInput{ExpectedVersion: 1, Reason: ""}},
		{"blank", CancelTaskInput{ExpectedVersion: 1, Reason: "   "}},
		{"too long", CancelTaskInput{ExpectedVersion: 1, Reason: strings.Repeat("x", 501)}},
		{"no version", CancelTaskInput{ExpectedVersion: 0, Reason: "客户退订"}},
	}
	for _, tc := range cases {
		_, err := service.CancelTask(ctx, uuid.New(), uuid.New(), WriteOptions{}, tc.input)
		if !errors.Is(err, ErrValidation) {
			t.Fatalf("%s: expected ErrValidation, got %v", tc.name, err)
		}
	}
}

func TestReopenTaskRejectsMissingReason(t *testing.T) {
	service := &Service{}
	ctx := t.Context()
	cases := []struct {
		name  string
		input ReopenTaskInput
	}{
		{"empty", ReopenTaskInput{ExpectedVersion: 2, Reason: ""}},
		{"blank", ReopenTaskInput{ExpectedVersion: 2, Reason: "\t\n"}},
		{"too long", ReopenTaskInput{ExpectedVersion: 2, Reason: strings.Repeat("x", 501)}},
		{"no version", ReopenTaskInput{ExpectedVersion: 0, Reason: "误点完成"}},
	}
	for _, tc := range cases {
		_, err := service.ReopenTask(ctx, uuid.New(), uuid.New(), WriteOptions{}, tc.input)
		if !errors.Is(err, ErrValidation) {
			t.Fatalf("%s: expected ErrValidation, got %v", tc.name, err)
		}
	}
}
