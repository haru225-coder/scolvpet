package i3core

import (
	"time"

	"github.com/google/uuid"
)

type BreedingPlan struct {
	ID                        uuid.UUID
	OwnerID                   uuid.UUID
	OrganizationID            uuid.UUID
	Name                      *string
	SireID                    uuid.UUID
	DamID                     uuid.UUID
	RuleVersionID             uuid.UUID
	State                     string
	PlannedPairingAt          *time.Time
	PlannedPairingEnclosureID *uuid.UUID
	MatingBaselineAt          *time.Time
	ExpectedBirthStart        *time.Time
	ExpectedBirthEnd          *time.Time
	ActualBirthAt             *time.Time
	ActivePairingAttemptID    *uuid.UUID
	LitterID                  *uuid.UUID
	ObjectiveTraits           map[string]any
	KinshipCheck              map[string]any
	EligibilityOverrideReason *string
	Notes                     *string
	Version                   int
	CreatedAt                 time.Time
	UpdatedAt                 time.Time
}

type PairingAttempt struct {
	ID                         uuid.UUID
	OwnerID                    uuid.UUID
	BreedingPlanID             uuid.UUID
	Sequence                   int
	SireID                     uuid.UUID
	DamID                      uuid.UUID
	EnclosureID                uuid.UUID
	StartedAt                  time.Time
	EndedAt                    *time.Time
	SeparatedAt                *time.Time
	SeparationDeadline         time.Time
	Status                     string
	Result                     *string
	ConflictLevel              *string
	SireDestinationEnclosureID *uuid.UUID
	DamDestinationEnclosureID  *uuid.UUID
	Notes                      *string
	Version                    int
	CreatedAt                  time.Time
	UpdatedAt                  time.Time
}

type MatingObservation struct {
	ID               uuid.UUID
	OwnerID          uuid.UUID
	PairingAttemptID uuid.UUID
	ObservedAt       time.Time
	Type             string
	DurationSeconds  *int
	Severity         *string
	Confidence       *float64
	MediaIDs         []uuid.UUID
	Notes            *string
	CreatedAt        time.Time
}

type PlanListFilter struct {
	State  string
	SireID *uuid.UUID
	DamID  *uuid.UUID
	Limit  int
	Offset int
}

type AttemptListFilter struct {
	Limit  int
	Offset int
}

type CreatePlanInput struct {
	Name             *string
	SireID           uuid.UUID
	DamID            uuid.UUID
	RuleVersionID    uuid.UUID
	PlannedPairingAt *time.Time
	ObjectiveTraits  map[string]any
	Notes            *string
}

type UpdatePlanInput struct {
	ExpectedVersion       int
	Name                  *string
	ClearName             bool
	SireID                *uuid.UUID
	DamID                 *uuid.UUID
	RuleVersionID         *uuid.UUID
	PlannedPairingAt      *time.Time
	ClearPlannedPairingAt bool
	ObjectiveTraits       map[string]any
	Notes                 *string
	ClearNotes            bool
}

type PublishPlanInput struct {
	ExpectedVersion       int
	PlannedPairingAt      time.Time
	PairingEnclosureID    uuid.UUID
	KinshipOverrideReason *string
}

type StartPairingInput struct {
	ExpectedVersion int
	EnclosureID     uuid.UUID
	StartedAt       time.Time
	Notes           *string
}

type RecordObservationInput struct {
	ExpectedVersion int
	ObservedAt      time.Time
	Type            string
	DurationSeconds *int
	Severity        *string
	Confidence      *float64
	MediaIDs        []uuid.UUID
	Notes           *string
}

type SeparatePairingInput struct {
	ExpectedVersion            int
	EndedAt                    time.Time
	SeparatedAt                time.Time
	Result                     string
	SireDestinationEnclosureID uuid.UUID
	DamDestinationEnclosureID  uuid.UUID
	SafetyStop                 bool
	Notes                      *string
}

type StartGestationInput struct {
	ExpectedVersion  int
	PairingAttemptID uuid.UUID
	Result           string
	BaselineAt       time.Time
	Timezone         string
	Notes            *string
}

type SeparationResult struct {
	Attempt        PairingAttempt
	Plan           BreedingPlan
	CreatedStays   []EnclosureStay
	CreatedTaskIDs []uuid.UUID
}

type EnclosureStay struct {
	ID          uuid.UUID
	OwnerID     uuid.UUID
	EnclosureID uuid.UUID
	HamsterID   uuid.UUID
	Purpose     string
	StartedAt   time.Time
	EndedAt     *time.Time
	Version     int
}

type StartPairingResult struct {
	Plan    BreedingPlan
	Attempt PairingAttempt
}
