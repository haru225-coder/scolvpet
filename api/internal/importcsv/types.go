package importcsv

import (
	"context"
	"time"
)

type TemplateType string

const (
	TemplateHamster   TemplateType = "hamster"
	TemplateEnclosure TemplateType = "enclosure"
	TemplateWeight    TemplateType = "weight"
)

type SourceEncoding string

const (
	EncodingUTF8    SourceEncoding = "utf-8"
	EncodingUTF8BOM SourceEncoding = "utf-8-bom"
	EncodingGB18030 SourceEncoding = "gb18030"
)

type Severity string

const (
	SeverityWarning  Severity = "warning"
	SeverityBlocking Severity = "blocking"
)

type RowStatus string

const (
	RowPending  RowStatus = "pending"
	RowValid    RowStatus = "valid"
	RowInvalid  RowStatus = "invalid"
	RowImported RowStatus = "imported"
	RowSkipped  RowStatus = "skipped"
	RowFailed   RowStatus = "failed"
)

type RowAction string

const (
	ActionCreate          RowAction = "create"
	ActionUpdateCandidate RowAction = "update_candidate"
	ActionAppendFacts     RowAction = "append_facts"
	ActionSkip            RowAction = "skip"
)

type JobStatus string

const (
	JobQueued             JobStatus = "queued"
	JobRunning            JobStatus = "running"
	JobSucceeded          JobStatus = "succeeded"
	JobPartiallySucceeded JobStatus = "partially_succeeded"
	JobFailed             JobStatus = "failed"
	JobCancelled          JobStatus = "cancelled"
)

type ImportJobStatus string

const (
	ImportJobUploaded           ImportJobStatus = "uploaded"
	ImportJobMapping            ImportJobStatus = "mapping"
	ImportJobPrechecking        ImportJobStatus = "prechecking"
	ImportJobReady              ImportJobStatus = "ready"
	ImportJobApplying           ImportJobStatus = "applying"
	ImportJobSucceeded          ImportJobStatus = "succeeded"
	ImportJobPartiallySucceeded ImportJobStatus = "partially_succeeded"
	ImportJobFailed             ImportJobStatus = "failed"
	ImportJobCancelled          ImportJobStatus = "cancelled"
)

type FieldDefinition struct {
	Name     string
	Required bool
	Core     bool
	Aliases  []string
}

type Template struct {
	Type   TemplateType
	Fields []FieldDefinition
}

type ParseOptions struct {
	Template TemplateType
	Mapping  map[string]string
}

type ParsedFile struct {
	Template            TemplateType
	Encoding            SourceEncoding
	Delimiter           rune
	Headers             []string
	CandidateMapping    map[string]string
	Mapping             map[string]string
	UnrecognizedColumns []string
	Rows                []ParsedRow
	Issues              []Issue
	FileSHA256          string
}

type ParsedRow struct {
	RowNumber int
	Raw       map[string]string
	Mapped    map[string]string
	RowSHA256 string
	Issues    []Issue
}

type Issue struct {
	RowNumber     int
	ColumnName    string
	Code          string
	Message       string
	Severity      Severity
	OriginalValue any
	Suggestion    string
	GroupKey      string
}

type RowResult struct {
	RowNumber    int
	Status       RowStatus
	Action       RowAction
	MappedValues map[string]any
	ResourceID   string
	Issues       []Issue
}

type UpdateCandidate struct {
	RowNumber       int
	ResourceType    string
	ResourceID      string
	ExpectedVersion int
	Fields          map[string]FieldChange
}

type FieldChange struct {
	Current  any
	Proposed any
	Reason   string
}

type ApprovedUpdate struct {
	RowNumber       int
	ResourceID      string
	ExpectedVersion int
	Fields          []string
}

type HistoricalLitterPolicy string

const (
	HistoricalLitterCreateIfComplete HistoricalLitterPolicy = "create_if_complete"
	HistoricalLitterRequireExisting  HistoricalLitterPolicy = "require_existing"
)

type ExistingFieldPolicy string

const (
	ExistingFieldPreserveNonNull ExistingFieldPolicy = "preserve_non_null"
	ExistingFieldRejectUpdates   ExistingFieldPolicy = "reject_updates"
)

type PreflightOptions struct {
	Timezone               string
	SpeciesRuleVersionID   string
	HistoricalLitterPolicy HistoricalLitterPolicy
	ExistingFieldPolicy    ExistingFieldPolicy
}

type PreflightRequest struct {
	JobID          string
	AsyncJobID     string
	OwnerID        string
	OrganizationID string
	OperatorID     string
	File           *ParsedFile
	Options        PreflightOptions
}

type PreflightReport struct {
	JobID                     string
	AsyncJobID                string
	OwnerID                   string
	OrganizationID            string
	Template                  TemplateType
	FileSHA256                string
	PreflightVersion          int
	Rows                      []RowResult
	Issues                    []Issue
	UpdateCandidates          []UpdateCandidate
	Plan                      CommitPlan
	TotalRows                 int
	ValidRows                 int
	WarningRows               int
	InvalidRows               int
	BlockingIssueCount        int
	HistoricalLittersToCreate int
	ReadyToCommit             bool
}

type Snapshot struct {
	OwnerID               string
	OrganizationID        string
	Hamsters              []HamsterRecord
	Enclosures            []EnclosureRecord
	EnclosureStays        []EnclosureStayRecord
	Litters               []LitterRecord
	Parentages            []ParentageRecord
	WeightAcquisitionKeys map[string]string
}

type HamsterRecord struct {
	ID                   string
	OwnerID              string
	InternalCode         string
	Name                 string
	SpeciesRuleVersionID string
	VarietyCode          string
	Sex                  string
	BirthDate            *time.Time
	SourceType           string
	LifecycleStatus      string
	BreedingStatus       string
	CurrentEnclosureID   string
	Tags                 []string
	Notes                string
	Version              int
}

type EnclosureRecord struct {
	ID             string
	OwnerID        string
	Code           string
	RackCode       string
	LevelCode      string
	Capacity       int
	State          string
	Cleanliness    string
	LastCleanedAt  *time.Time
	DisabledReason string
	Version        int
}

type EnclosureStayRecord struct {
	ID          string
	OwnerID     string
	EnclosureID string
	HamsterID   string
	StartedAt   time.Time
	EndedAt     *time.Time
}

type LitterRecord struct {
	ID        string
	OwnerID   string
	Code      string
	BornAt    *time.Time
	SireID    string
	DamID     string
	MemberIDs []string
}

type ParentageRecord struct {
	ParentID string
	ChildID  string
	Role     string
}

type OperationKind string

const (
	OperationCreateHamster           OperationKind = "create_hamster"
	OperationUpdateHamster           OperationKind = "update_hamster"
	OperationCreateEnclosure         OperationKind = "create_enclosure"
	OperationUpdateEnclosure         OperationKind = "update_enclosure"
	OperationCreateEnclosureStay     OperationKind = "create_enclosure_stay"
	OperationCreateLitter            OperationKind = "create_litter"
	OperationCreateLitterParent      OperationKind = "create_litter_parent"
	OperationCreateLitterMember      OperationKind = "create_litter_member"
	OperationCreatePedigreeParentage OperationKind = "create_pedigree_parentage"
	OperationCreateWeightRecord      OperationKind = "create_weight_record"
)

type Operation struct {
	Kind              OperationKind
	RowNumber         int
	Hamster           *HamsterWrite
	HamsterUpdate     *ResourceUpdate
	Enclosure         *EnclosureWrite
	EnclosureUpdate   *ResourceUpdate
	EnclosureStay     *EnclosureStayWrite
	Litter            *LitterWrite
	LitterParent      *LitterParentWrite
	LitterMember      *LitterMemberWrite
	PedigreeParentage *PedigreeParentageWrite
	WeightRecord      *WeightRecordWrite
}

type HamsterWrite struct {
	ID                   string
	OwnerID              string
	OrganizationID       string
	InternalCode         string
	Name                 string
	SpeciesRuleVersionID string
	VarietyCode          string
	Sex                  string
	BirthDate            *time.Time
	SourceType           string
	LifecycleStatus      string
	BreedingStatus       string
	CurrentEnclosureID   string
	Tags                 []string
	Notes                string
}

type ResourceUpdate struct {
	ID              string
	OwnerID         string
	ExpectedVersion int
	Fields          map[string]any
}

type EnclosureWrite struct {
	ID             string
	OwnerID        string
	OrganizationID string
	Code           string
	RackCode       string
	LevelCode      string
	Capacity       int
	State          string
	Cleanliness    string
	LastCleanedAt  *time.Time
	DisabledReason string
}

type EnclosureStayWrite struct {
	ID          string
	OwnerID     string
	EnclosureID string
	HamsterID   string
	Purpose     string
	StartedAt   time.Time
	OperatorID  string
	Reason      string
}

type LitterWrite struct {
	ID                  string
	OwnerID             string
	OrganizationID      string
	BreedingPlanID      string
	Code                string
	Origin              string
	State               string
	BornAt              *time.Time
	SireID              string
	DamID               string
	EnclosureID         string
	DamCondition        map[string]any
	InitialAliveCount   int
	InitialOtherCount   int
	CurrentManagedCount int
}

type LitterParentWrite struct {
	ID       string
	OwnerID  string
	LitterID string
	ParentID string
	Role     string
	Evidence string
}

type LitterMemberWrite struct {
	ID        string
	OwnerID   string
	LitterID  string
	HamsterID string
	Evidence  string
}

type PedigreeParentageWrite struct {
	ID       string
	OwnerID  string
	ParentID string
	ChildID  string
	Role     string
	Evidence string
}

type WeightRecordWrite struct {
	ID              string
	OwnerID         string
	OrganizationID  string
	HamsterID       string
	LitterID        string
	SubjectType     string
	MeasurementKind string
	SubjectCount    *int
	WeightG         string
	RecordedAt      time.Time
	Source          string
	AcquisitionKey  string
	OperatorID      string
}

type PlannedRow struct {
	RowNumber  int
	Action     RowAction
	ResourceID string
}

type CommitPlan struct {
	OwnerID          string
	OrganizationID   string
	Template         TemplateType
	FileSHA256       string
	PreflightVersion int
	PlanHash         string
	Operations       []Operation
	Rows             []PlannedRow
}

type CommitRequest struct {
	OwnerID         string
	BatchKey        string
	Report          *PreflightReport
	ApprovedUpdates []ApprovedUpdate
}

type CommitReceipt struct {
	JobID             string
	AsyncJobID        string
	OwnerID           string
	BatchKey          string
	Template          TemplateType
	FileSHA256        string
	PlanHash          string
	PreflightVersion  int
	Status            JobStatus
	ImportStatus      ImportJobStatus
	ApprovedUpdates   []ApprovedUpdate
	Rows              []RowResult
	AppliedOperations int
	CommittedAt       time.Time
	Replayed          bool
}

type Store interface {
	Snapshot(ctx context.Context, ownerID string) (Snapshot, error)
	WithTransaction(ctx context.Context, fn func(Tx) error) error
}

type Tx interface {
	FindCommit(ctx context.Context, ownerID, batchKey string) (CommitReceipt, bool, error)
	Apply(ctx context.Context, operation Operation) error
	SaveCommit(ctx context.Context, receipt CommitReceipt) error
}
