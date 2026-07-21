package i2core

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

type Page struct {
	Limit  int
	Offset int
}

type Hamster struct {
	ID                   uuid.UUID
	OwnerID              uuid.UUID
	OrganizationID       uuid.UUID
	InternalCode         string
	Name                 *string
	SpeciesRuleVersionID uuid.UUID
	VarietyCode          *string
	Sex                  string
	SexConfidence        *float64
	BirthDate            *time.Time
	SourceType           string
	LifecycleStatus      string
	BreedingStatus       string
	CurrentEnclosureID   *uuid.UUID
	CoverMediaID         *uuid.UUID
	Phenotype            map[string]any
	Tags                 []string
	Notes                *string
	Version              int
	CreatedAt            time.Time
	UpdatedAt            time.Time
}

type CreateHamsterInput struct {
	InternalCode         string
	Name                 *string
	SpeciesRuleVersionID uuid.UUID
	VarietyCode          *string
	Sex                  string
	SexConfidence        *float64
	BirthDate            *time.Time
	SourceType           string
	LifecycleStatus      string
	BreedingStatus       string
	Phenotype            map[string]any
	Tags                 []string
	Notes                *string
}

type BatchCreateHamstersInput struct {
	Hamsters []CreateHamsterInput
}

type UpdateHamsterInput struct {
	ExpectedVersion    int
	InternalCode       *string
	Name               *string
	ClearName          bool
	VarietyCode        *string
	ClearVariety       bool
	Sex                *string
	SexConfidence      *float64
	ClearSexConfidence bool
	BirthDate          *time.Time
	ClearBirthDate     bool
	CoverMediaID       *uuid.UUID
	ClearCoverMedia    bool
	Phenotype          map[string]any
	Tags               []string
	Notes              *string
	ClearNotes         bool
}

type HamsterFilter struct {
	Keyword            string
	Sex                string
	LifecycleStatus    string
	BreedingStatus     string
	VarietyCode        string
	CurrentEnclosureID *uuid.UUID
	Page               Page
}

type Enclosure struct {
	ID             uuid.UUID
	OwnerID        uuid.UUID
	OrganizationID uuid.UUID
	Code           string
	RackCode       *string
	LevelCode      *string
	Capacity       int
	State          string
	Cleanliness    string
	Dimensions     map[string]any
	Equipment      []string
	LastCleanedAt  *time.Time
	DisabledReason *string
	Version        int
	CreatedAt      time.Time
	UpdatedAt      time.Time
}

type CreateEnclosureInput struct {
	Code           string
	RackCode       *string
	LevelCode      *string
	Capacity       int
	State          string
	Cleanliness    string
	Dimensions     map[string]any
	Equipment      []string
	LastCleanedAt  *time.Time
	DisabledReason *string
}

type UpdateEnclosureInput struct {
	ExpectedVersion     int
	Code                *string
	RackCode            *string
	ClearRackCode       bool
	LevelCode           *string
	ClearLevelCode      bool
	Capacity            *int
	State               *string
	Cleanliness         *string
	Dimensions          map[string]any
	Equipment           []string
	LastCleanedAt       *time.Time
	ClearLastCleanedAt  bool
	DisabledReason      *string
	ClearDisabledReason bool
}

type EnclosureFilter struct {
	Keyword     string
	RackCode    string
	LevelCode   string
	State       string
	Cleanliness string
	Page        Page
}

type EnclosureStay struct {
	ID               uuid.UUID
	OwnerID          uuid.UUID
	EnclosureID      uuid.UUID
	HamsterID        uuid.UUID
	PairingAttemptID *uuid.UUID
	Purpose          string
	StartedAt        time.Time
	EndedAt          *time.Time
	OperatorID       uuid.UUID
	Reason           *string
	CorrectionNote   *string
	Version          int
	CreatedAt        time.Time
	UpdatedAt        time.Time
}

type AdmitHamsterInput struct {
	HamsterID                uuid.UUID
	EnclosureID              uuid.UUID
	PairingAttemptID         *uuid.UUID
	Purpose                  string
	StartedAt                time.Time
	Reason                   *string
	ExpectedHamsterVersion   int
	ExpectedEnclosureVersion int
}

type MoveHamsterInput struct {
	StayID                         uuid.UUID
	TargetEnclosureID              uuid.UUID
	PairingAttemptID               *uuid.UUID
	Purpose                        string
	MovedAt                        time.Time
	Reason                         *string
	ExpectedStayVersion            int
	ExpectedHamsterVersion         int
	ExpectedSourceEnclosureVersion int
	ExpectedTargetEnclosureVersion int
}

type EndStayInput struct {
	StayID                   uuid.UUID
	EndedAt                  time.Time
	Reason                   *string
	ExpectedStayVersion      int
	ExpectedHamsterVersion   int
	ExpectedEnclosureVersion int
}

type StayChange struct {
	Stay            EnclosureStay
	PreviousStay    *EnclosureStay
	Hamster         Hamster
	SourceEnclosure *Enclosure
	TargetEnclosure *Enclosure
}

type StayHistoryFilter struct {
	HamsterID   *uuid.UUID
	EnclosureID *uuid.UUID
	Page        Page
}

type EnclosureCleaning struct {
	ID                       uuid.UUID
	OwnerID                  uuid.UUID
	EnclosureID              uuid.UUID
	CleaningType             string
	PerformedAt              time.Time
	OperatorID               uuid.UUID
	SourceEventID            *uuid.UUID
	Supplies                 map[string]any
	Notes                    *string
	CorrectsCleaningRecordID *uuid.UUID
	CorrectionReason         *string
	CreatedAt                time.Time
}

type CreateEnclosureCleaningInput struct {
	EnclosureID              uuid.UUID
	CleaningType             string
	PerformedAt              time.Time
	Supplies                 map[string]any
	Notes                    *string
	CorrectsCleaningRecordID *uuid.UUID
	CorrectionReason         *string
	ExpectedEnclosureVersion int
}

type EnclosureCleaningChange struct {
	Cleaning  EnclosureCleaning
	Enclosure Enclosure
}

type WeightRecord struct {
	ID                     uuid.UUID
	OwnerID                uuid.UUID
	OrganizationID         uuid.UUID
	SubjectType            string
	HamsterID              *uuid.UUID
	PupIdentityID          *uuid.UUID
	LitterID               *uuid.UUID
	MeasurementKind        string
	SubjectCount           *int
	WeightG                float64
	RecordedAt             time.Time
	Source                 string
	AcquisitionKey         *string
	SpeciesRuleVersionID   *uuid.UUID
	BirthWeightG           *float64
	PreviousWeightG        *float64
	ChangeFromBirthG       *float64
	ChangeFromPreviousG    *float64
	AlertFlags             []string
	OperatorID             uuid.UUID
	CorrectsWeightRecordID *uuid.UUID
	CorrectionReason       *string
	CreatedAt              time.Time
}

type CreateWeightInput struct {
	SubjectType            string
	HamsterID              *uuid.UUID
	PupIdentityID          *uuid.UUID
	LitterID               *uuid.UUID
	MeasurementKind        string
	SubjectCount           *int
	WeightG                float64
	RecordedAt             time.Time
	Source                 string
	AcquisitionKey         *string
	CorrectsWeightRecordID *uuid.UUID
	CorrectionReason       *string
}

type WeightRecordFilter struct {
	HamsterID     *uuid.UUID
	PupIdentityID *uuid.UUID
	LitterID      *uuid.UUID
	RecordedFrom  *time.Time
	RecordedTo    *time.Time
	Page          Page
}

type BatchCreateWeightsInput struct {
	Records []CreateWeightInput
}

type Litter struct {
	ID                         uuid.UUID
	OwnerID                    uuid.UUID
	OrganizationID             uuid.UUID
	BreedingPlanID             *uuid.UUID
	SireID                     *uuid.UUID
	DamID                      *uuid.UUID
	Origin                     string
	Code                       string
	State                      string
	BornAt                     *time.Time
	EnclosureID                *uuid.UUID
	DamCondition               map[string]any
	InitialAliveCount          int
	InitialOtherCount          int
	DiscoveredCount            int
	DeceasedCount              int
	TransferredOutCount        int
	CorrectionDelta            int
	CurrentManagedCount        int
	UnindividualizedAliveCount int
	IndividualizedAliveCount   int
	WeanedAt                   *time.Time
	SexSeparatedAt             *time.Time
	ReconciledAt               *time.Time
	Notes                      *string
	Version                    int
	CreatedAt                  time.Time
	UpdatedAt                  time.Time
}

type LitterFilter struct {
	Origin string
	State  string
	Page   Page
}

type LitterParent struct {
	ID                     uuid.UUID
	OwnerID                uuid.UUID
	LitterID               uuid.UUID
	ParentID               uuid.UUID
	Role                   string
	EvidenceType           string
	EvidencePayload        map[string]any
	Confidence             float64
	Status                 string
	ValidFrom              time.Time
	ValidTo                *time.Time
	CorrectsLitterParentID *uuid.UUID
	CorrectionNote         *string
	Version                int
	CreatedAt              time.Time
	UpdatedAt              time.Time
}

type CreateLitterParentInput struct {
	LitterID              uuid.UUID
	HamsterID             uuid.UUID
	Role                  string
	EvidenceType          string
	EvidencePayload       map[string]any
	Confidence            float64
	CorrectionReason      *string
	ExpectedLitterVersion int
}

type LitterParentChange struct {
	Parent LitterParent
	Litter Litter
}

type LitterMember struct {
	ID                  uuid.UUID
	LitterID            uuid.UUID
	MemberType          string
	PupIdentityID       *uuid.UUID
	HamsterID           *uuid.UUID
	OriginPupIdentityID *uuid.UUID
	EvidenceType        string
	Confidence          float64
	Status              string
	ValidFrom           time.Time
	ValidTo             *time.Time
	Version             int
}

type LitterRelations struct {
	Litter  Litter
	Parents []LitterParent
	Members []LitterMember
}

type PedigreeParentage struct {
	ID                      uuid.UUID
	OwnerID                 uuid.UUID
	ParentID                uuid.UUID
	ChildID                 uuid.UUID
	Role                    string
	EvidenceType            string
	EvidencePayload         map[string]any
	Notes                   *string
	Confidence              float64
	Status                  string
	ValidFrom               time.Time
	ValidTo                 *time.Time
	RelationshipAssertionID *uuid.UUID
	Version                 int
	CreatedAt               time.Time
	UpdatedAt               time.Time
}

type PedigreeParentageFilter struct {
	ChildHamsterID  *uuid.UUID
	ParentHamsterID *uuid.UUID
	Page            Page
}

type CommonAncestor struct {
	HamsterID         uuid.UUID
	Paths             int
	MinimumGeneration int
}

type PedigreeGraph struct {
	RootHamsterID   uuid.UUID
	Nodes           []Hamster
	Parentages      []PedigreeParentage
	LitterParents   []LitterParent
	LitterMembers   []LitterMember
	CommonAncestors []CommonAncestor
}

type CreatePedigreeParentageInput struct {
	ParentID              uuid.UUID
	ChildID               uuid.UUID
	Role                  string
	EvidenceType          string
	EvidencePayload       map[string]any
	Confidence            float64
	ValidFrom             time.Time
	Notes                 *string
	ExpectedParentVersion int
	ExpectedChildVersion  int
}
