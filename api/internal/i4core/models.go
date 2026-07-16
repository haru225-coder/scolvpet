package i4core

import (
	"time"

	"github.com/google/uuid"
)

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

type Command struct {
	OwnerID        uuid.UUID
	IdempotencyKey string
	Method         string
	Path           string
	Payload        []byte
	SuccessStatus  int
}

type CommandResult struct {
	Body     []byte
	Status   int
	Replayed bool
}

type DomainEvent struct {
	ID             uuid.UUID
	OwnerID        uuid.UUID
	OrganizationID uuid.UUID
	AggregateType  string
	AggregateID    uuid.UUID
	EventType      string
	OccurredAt     time.Time
	Payload        map[string]any
	IdempotencyKey string
}

type BreedingPlan struct {
	ID                uuid.UUID      `json:"id"`
	OwnerID           uuid.UUID      `json:"owner_id"`
	OrganizationID    uuid.UUID      `json:"organization_id"`
	SireID            uuid.UUID      `json:"sire_id"`
	DamID             uuid.UUID      `json:"dam_id"`
	RuleVersionID     uuid.UUID      `json:"rule_version_id"`
	State             string         `json:"state"`
	ActualBirthAt     *time.Time     `json:"actual_birth_at"`
	BirthAliveCount   *int           `json:"birth_result_alive_count"`
	BirthOtherCount   *int           `json:"birth_result_other_count"`
	BirthResultReason *string        `json:"birth_result_reason"`
	DamCondition      map[string]any `json:"dam_condition"`
	LitterID          *uuid.UUID     `json:"litter_id"`
	Version           int            `json:"version"`
	CreatedAt         time.Time      `json:"created_at"`
	UpdatedAt         time.Time      `json:"updated_at"`
}

type Litter struct {
	ID                    uuid.UUID      `json:"id"`
	OwnerID               uuid.UUID      `json:"owner_id"`
	OrganizationID        uuid.UUID      `json:"organization_id"`
	BreedingPlanID        *uuid.UUID     `json:"breeding_plan_id"`
	Origin                string         `json:"origin"`
	Code                  string         `json:"code"`
	State                 string         `json:"state"`
	BornAt                *time.Time     `json:"born_at"`
	EnclosureID           *uuid.UUID     `json:"enclosure_id"`
	DamCondition          map[string]any `json:"dam_condition"`
	InitialAliveCount     int            `json:"initial_alive_count"`
	InitialOtherCount     int            `json:"initial_other_count"`
	DiscoveredCount       int            `json:"discovered_count"`
	DeceasedCount         int            `json:"deceased_count"`
	TransferredOutCount   int            `json:"transferred_out_count"`
	CorrectionDelta       int            `json:"correction_delta"`
	CurrentManagedCount   int            `json:"current_managed_count"`
	UnindividualizedCount int            `json:"unindividualized_alive_count"`
	IndividualizedCount   int            `json:"individualized_alive_count"`
	WeaningCompletedAt    *time.Time     `json:"weaned_at"`
	SexSeparatedAt        *time.Time     `json:"sex_separated_at"`
	ReconciledAt          *time.Time     `json:"reconciled_at"`
	Version               int            `json:"version"`
	CreatedAt             time.Time      `json:"created_at"`
	UpdatedAt             time.Time      `json:"updated_at"`
}

type PupIdentity struct {
	ID                    uuid.UUID      `json:"id"`
	OwnerID               uuid.UUID      `json:"owner_id"`
	LitterID              uuid.UUID      `json:"litter_id"`
	TemporaryCode         string         `json:"temporary_code"`
	Sex                   string         `json:"sex"`
	SexConfidence         *float64       `json:"sex_confidence"`
	ProfileStatus         string         `json:"profile_status"`
	OutcomeStatus         string         `json:"outcome_status"`
	WeanedAt              *time.Time     `json:"weaned_at"`
	CurrentEnclosureID    *uuid.UUID     `json:"current_enclosure_id"`
	IndividualizedHamster *uuid.UUID     `json:"hamster_id"`
	PhenotypeSummary      map[string]any `json:"phenotype_summary"`
	DestinationCode       *string        `json:"destination"`
	StatusReason          *string        `json:"status_reason"`
	Version               int            `json:"version"`
	CreatedAt             time.Time      `json:"created_at"`
	UpdatedAt             time.Time      `json:"updated_at"`
}

type CountEvent struct {
	ID            uuid.UUID  `json:"id"`
	LitterID      uuid.UUID  `json:"litter_id"`
	PupIdentityID *uuid.UUID `json:"pup_identity_id"`
	EventType     string     `json:"event_type"`
	Delta         int        `json:"delta"`
	OccurredAt    time.Time  `json:"occurred_at"`
	Reason        *string    `json:"reason"`
}

type Reconciliation struct {
	InitialAliveCount     int  `json:"initial_alive_count"`
	DiscoveredCount       int  `json:"discovered_count"`
	DeceasedCount         int  `json:"deceased_count"`
	TransferredCount      int  `json:"transferred_count"`
	ExpectedManagedCount  int  `json:"expected_managed_count"`
	UnindividualizedCount int  `json:"unindividualized_alive_count"`
	IndividualizedCount   int  `json:"individualized_alive_count"`
	Difference            int  `json:"difference"`
	Closed                bool `json:"closed"`
}

type ConfirmBirthInput struct {
	ExpectedVersion     int
	BornAt              time.Time
	EnclosureID         *uuid.UUID
	InitialAliveCount   int
	InitialOtherCount   int
	DamCondition        map[string]any
	OutcomeReason       string
	TemporaryCodePrefix string
	TemporaryCodes      []string
	Notes               *string
	Timezone            string
}

type ConfirmBirthResult struct {
	ResultType        string         `json:"result_type"`
	BreedingPlan      BreedingPlan   `json:"breeding_plan"`
	Litter            *Litter        `json:"litter,omitempty"`
	PupIdentityCount  int            `json:"pup_identity_count,omitempty"`
	PupIdentities     []PupIdentity  `json:"pup_identities,omitempty"`
	InitialCountEvent *CountEvent    `json:"initial_count_event,omitempty"`
	BirthEventID      uuid.UUID      `json:"birth_event_id"`
	EventType         string         `json:"event_type"`
	BornAt            time.Time      `json:"born_at"`
	InitialOtherCount int            `json:"initial_other_count"`
	OutcomeReason     string         `json:"outcome_reason"`
	DamCondition      map[string]any `json:"dam_condition"`
}

type CountEventInput struct {
	ExpectedVersion        int
	EventType              string
	Delta                  int
	OccurredAt             time.Time
	Reason                 string
	NewTemporaryCodes      []string
	AffectedPupIdentityIDs []uuid.UUID
	IdempotencyKey         string `json:"-"`
}

type CountEventResult struct {
	Litter               Litter         `json:"litter"`
	CountEvent           CountEvent     `json:"count_event"`
	CreatedPupIdentities []PupIdentity  `json:"created_pup_identities"`
	ClosedPupIdentityIDs []uuid.UUID    `json:"closed_pup_identity_ids"`
	Reconciliation       Reconciliation `json:"reconciliation"`
}

type WeanItem struct {
	PupIdentityID          uuid.UUID  `json:"pup_identity_id"`
	OutcomeStatus          string     `json:"outcome_status"`
	DestinationEnclosureID *uuid.UUID `json:"destination_enclosure_id"`
	Notes                  *string    `json:"notes"`
}

type WeanInput struct {
	ExpectedVersion int
	WeanedAt        time.Time
	Timezone        string
	Items           []WeanItem
}

type ActionItemResult struct {
	PupIdentityID   uuid.UUID  `json:"pup_identity_id"`
	Status          string     `json:"status"`
	EnclosureStayID *uuid.UUID `json:"enclosure_stay_id,omitempty"`
}

type WeanResult struct {
	LitterID       uuid.UUID          `json:"litter_id"`
	LitterState    string             `json:"litter_state"`
	WeanedAt       time.Time          `json:"weaned_at"`
	ProcessedCount int                `json:"processed_count"`
	ItemResults    []ActionItemResult `json:"item_results"`
	CreatedTaskIDs []uuid.UUID        `json:"created_task_ids"`
	Version        int                `json:"version"`
}

type SexAndSeparateItem struct {
	PupIdentityID          uuid.UUID `json:"pup_identity_id"`
	Sex                    string    `json:"sex"`
	SexConfidence          *float64  `json:"sex_confidence"`
	DestinationEnclosureID uuid.UUID `json:"destination_enclosure_id"`
	RequiresRecheck        bool      `json:"requires_recheck"`
	Notes                  *string   `json:"notes"`
}

type SexAndSeparateInput struct {
	ExpectedVersion int
	SeparatedAt     time.Time
	Timezone        string
	Items           []SexAndSeparateItem
}

type SexAndSeparateResult struct {
	LitterID       uuid.UUID          `json:"litter_id"`
	LitterState    string             `json:"litter_state"`
	SeparatedAt    time.Time          `json:"separated_at"`
	ProcessedCount int                `json:"processed_count"`
	UncertainCount int                `json:"uncertain_count"`
	ItemResults    []ActionItemResult `json:"item_results"`
	CreatedTaskIDs []uuid.UUID        `json:"created_task_ids"`
	Version        int                `json:"version"`
}

type EligibilityBlocker struct {
	Code            string      `json:"code"`
	Message         string      `json:"message"`
	PupIdentityIDs  []uuid.UUID `json:"pup_identity_ids"`
	RecoveryActions []string    `json:"recovery_actions"`
}

type IndividualizationEligibility struct {
	LitterID               uuid.UUID            `json:"litter_id"`
	LitterVersion          int                  `json:"litter_version"`
	EligibleSetToken       string               `json:"eligible_set_token"`
	EligiblePupIdentityIDs []uuid.UUID          `json:"eligible_pup_identity_ids"`
	EligibleCount          int                  `json:"eligible_count"`
	Blockers               []EligibilityBlocker `json:"blockers"`
	CanIndividualize       bool                 `json:"can_individualize"`
	ComputedAt             time.Time            `json:"computed_at"`
}

type IndividualizeItem struct {
	PupIdentityID uuid.UUID `json:"pup_identity_id"`
	InternalCode  string    `json:"internal_code"`
	Name          *string   `json:"name"`
	VarietyCode   *string   `json:"variety_code"`
	Notes         *string   `json:"notes"`
}

type IndividualizeInput struct {
	ExpectedVersion  int
	IndividualizedAt time.Time
	Timezone         string
	EligibleSetToken string
	Items            []IndividualizeItem
}

type Hamster struct {
	ID                   uuid.UUID  `json:"id"`
	OwnerID              uuid.UUID  `json:"owner_id"`
	OrganizationID       uuid.UUID  `json:"organization_id"`
	InternalCode         string     `json:"internal_code"`
	Name                 *string    `json:"name"`
	SpeciesRuleVersionID uuid.UUID  `json:"species_rule_version_id"`
	VarietyCode          *string    `json:"variety_code"`
	Sex                  string     `json:"sex"`
	SexConfidence        *float64   `json:"sex_confidence"`
	BirthDate            *time.Time `json:"birth_date"`
	SourceType           string     `json:"source_type"`
	LifecycleStatus      string     `json:"lifecycle_status"`
	BreedingStatus       string     `json:"breeding_status"`
	CurrentEnclosureID   *uuid.UUID `json:"current_enclosure_id"`
	Notes                *string    `json:"notes"`
	Version              int        `json:"version"`
	CreatedAt            time.Time  `json:"created_at"`
	UpdatedAt            time.Time  `json:"updated_at"`
}

type IndividualizeMapping struct {
	PupIdentityID uuid.UUID `json:"pup_identity_id"`
	Hamster       Hamster   `json:"hamster"`
}

type IndividualizeResult struct {
	LitterID                  uuid.UUID              `json:"litter_id"`
	EvaluatedEligibleSetToken string                 `json:"evaluated_eligible_set_token"`
	EvaluatedEligibleCount    int                    `json:"evaluated_eligible_count"`
	Mappings                  []IndividualizeMapping `json:"mappings"`
	CreatedLitterMemberCount  int                    `json:"created_litter_member_count"`
	CreatedParentageCount     int                    `json:"created_parentage_count"`
	Reconciliation            Reconciliation         `json:"reconciliation"`
	LitterVersion             int                    `json:"litter_version"`
}
