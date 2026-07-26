package i5core

import (
	"time"

	"github.com/google/uuid"
)

type Page struct {
	Limit  int
	Offset int
}

type WriteOptions struct {
	IdempotencyKey string
	RequestMethod  string
	RequestPath    string
	RequestPayload []byte
}

type WriteResult[T any] struct {
	Value    T
	Replayed bool
}

type HealthRecord struct {
	ID               uuid.UUID      `json:"id"`
	OwnerID          uuid.UUID      `json:"-"`
	OrganizationID   uuid.UUID      `json:"-"`
	SubjectType      string         `json:"-"`
	HamsterID        *uuid.UUID     `json:"hamster_id,omitempty"`
	PupIdentityID    *uuid.UUID     `json:"-"`
	LitterID         *uuid.UUID     `json:"litter_id,omitempty"`
	EnclosureID      *uuid.UUID     `json:"-"`
	Type             string         `json:"type"`
	ObservedAt       time.Time      `json:"observed_at"`
	StructuredChecks map[string]any `json:"structured_checks"`
	Severity         *string        `json:"severity,omitempty"`
	Medication       map[string]any `json:"medication"`
	FollowUpAt       *time.Time     `json:"follow_up_at,omitempty"`
	Notes            *string        `json:"notes,omitempty"`
	Version          int            `json:"version"`
	CreatedAt        time.Time      `json:"created_at"`
	UpdatedAt        time.Time      `json:"updated_at"`
}

type HealthRecordFilter struct {
	HamsterID *uuid.UUID
	LitterID  *uuid.UUID
	Type      string
	Page      Page
}

type CreateHealthRecordInput struct {
	HamsterID        *uuid.UUID
	PupIdentityID    *uuid.UUID
	LitterID         *uuid.UUID
	EnclosureID      *uuid.UUID
	Type             string
	ObservedAt       time.Time
	StructuredChecks map[string]any
	Severity         *string
	Medication       map[string]any
	FollowUpAt       *time.Time
	Notes            *string
}

type CareTask struct {
	ID                  uuid.UUID   `json:"id"`
	OwnerID             uuid.UUID   `json:"-"`
	OrganizationID      uuid.UUID   `json:"-"`
	TaskType            string      `json:"task_type"`
	TargetType          string      `json:"target_type"`
	TargetID            uuid.UUID   `json:"target_id"`
	Title               *string     `json:"title,omitempty"`
	Notes               *string     `json:"notes,omitempty"`
	ScheduledAt         time.Time   `json:"scheduled_at"`
	Priority            string      `json:"priority"`
	State               string      `json:"state"`
	SubjectIDs          []uuid.UUID `json:"subject_ids"`
	CompletedSubjectIDs []uuid.UUID `json:"completed_subject_ids"`
	StageTotal          int         `json:"stage_total"`
	StageDone           int         `json:"stage_done"`
	SourceEventID       *uuid.UUID  `json:"source_event_id,omitempty"`
	CompletedAt         *time.Time  `json:"-"`
	Version             int         `json:"version"`
	CreatedAt           time.Time   `json:"-"`
	UpdatedAt           time.Time   `json:"-"`
}

type CareTaskFilter struct {
	State      string
	Priority   string
	TargetType string
	DueBefore  *time.Time
	Page       Page
}

type CreateCareTaskInput struct {
	TaskType    string
	TargetType  string
	TargetID    uuid.UUID
	Title       *string
	ScheduledAt time.Time
	Priority    string
	SubjectIDs  []uuid.UUID
	Notes       *string
}

type TaskSubjectResult struct {
	SubjectID          uuid.UUID
	Status             string
	CompletionRecordID *uuid.UUID
	ExceptionReason    *string
}

type CompleteTaskInput struct {
	ExpectedVersion int
	CompletedAt     time.Time
	SubjectResults  []TaskSubjectResult
	Notes           *string
}

// CanCancelTask reports whether a task in the given state may be cancelled.
// A finished task must be reopened first — cancelling it outright would
// silently drop completion evidence that is already recorded.
func CanCancelTask(state string) bool {
	return state == "pending" || state == "in_progress" || state == "snoozed"
}

// CanReopenTask reports whether a task may be returned to pending. Only an end
// state can be undone; reopening a pending task would be a no-op that still
// bumps the version and confuses concurrent clients.
func CanReopenTask(state string) bool {
	return state == "completed" || state == "cancelled"
}

// CancelTaskInput ends a task that will never be carried out. The reason is
// mandatory: a cancelled task with no explanation is indistinguishable from
// data loss when read back later.
type CancelTaskInput struct {
	ExpectedVersion int
	Reason          string
}

// ReopenTaskInput undoes a completion or a cancellation, returning the task to
// pending so the operator can redo it. Subject-level completion is cleared too.
type ReopenTaskInput struct {
	ExpectedVersion int
	Reason          string
}

type CompletedTaskItem struct {
	SubjectID          uuid.UUID  `json:"subject_id"`
	Status             string     `json:"status"`
	CompletionRecordID *uuid.UUID `json:"completion_record_id,omitempty"`
}

type CompleteTaskResult struct {
	Task        CareTask            `json:"task"`
	ItemResults []CompletedTaskItem `json:"item_results"`
	AutoClosed  bool                `json:"auto_closed"`
}

type Reminder struct {
	ID          uuid.UUID  `json:"id"`
	OwnerID     uuid.UUID  `json:"-"`
	CareTaskID  uuid.UUID  `json:"task_id"`
	Channel     string     `json:"channel"`
	Status      string     `json:"status"`
	DedupeKey   string     `json:"dedupe_key"`
	ScheduledAt time.Time  `json:"scheduled_at"`
	AttemptedAt *time.Time `json:"attempted_at,omitempty"`
	DeliveredAt *time.Time `json:"delivered_at,omitempty"`
	ReadAt      *time.Time `json:"read_at,omitempty"`
	FailureCode *string    `json:"failure_code,omitempty"`
	Version     int        `json:"-"`
}

type ReminderFilter struct {
	State    string
	RuleCode string
	Page     Page
}
