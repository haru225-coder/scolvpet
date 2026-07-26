package i2core

import (
	"context"
	"time"

	"github.com/google/uuid"
)

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
	OwnerID        uuid.UUID
	OrganizationID uuid.UUID
	AggregateType  string
	AggregateID    uuid.UUID
	EventType      string
	Payload        map[string]any
	IdempotencyKey string
}

type WeightSubject struct {
	OrganizationID       uuid.UUID
	SpeciesRuleVersionID *uuid.UUID
}

type StayConflict struct {
	HamsterConflict   bool
	EnclosureConflict bool
}

type Repository interface {
	Execute(context.Context, Command, func(context.Context, Transaction) (any, error)) (CommandResult, error)
	ListHamsters(context.Context, uuid.UUID, HamsterFilter) ([]Hamster, error)
	GetHamster(context.Context, uuid.UUID, uuid.UUID) (Hamster, error)
	ListEnclosures(context.Context, uuid.UUID, EnclosureFilter) ([]Enclosure, error)
	GetEnclosure(context.Context, uuid.UUID, uuid.UUID) (Enclosure, error)
	ListStayHistory(context.Context, uuid.UUID, StayHistoryFilter) ([]EnclosureStay, error)
	ListEnclosureCleanings(context.Context, uuid.UUID, uuid.UUID, Page) ([]EnclosureCleaning, error)
	GetEnclosureCleaning(context.Context, uuid.UUID, uuid.UUID) (EnclosureCleaning, error)
	ListWeightRecords(context.Context, uuid.UUID, WeightRecordFilter) ([]WeightRecord, error)
	ListLitters(context.Context, uuid.UUID, LitterFilter) ([]Litter, error)
	GetLitter(context.Context, uuid.UUID, uuid.UUID) (Litter, error)
	GetLitterRelations(context.Context, uuid.UUID, uuid.UUID) (LitterRelations, error)
	ListLitterParents(context.Context, uuid.UUID, uuid.UUID, Page) ([]LitterParent, error)
	ListLitterMembers(context.Context, uuid.UUID, uuid.UUID, Page) ([]LitterMember, error)
	ListPedigreeParentages(context.Context, uuid.UUID, PedigreeParentageFilter) ([]PedigreeParentage, error)
	GetHamsterPedigree(context.Context, uuid.UUID, uuid.UUID, int) (PedigreeGraph, error)
}

type Transaction interface {
	OrganizationID(context.Context, uuid.UUID) (uuid.UUID, error)
	SpeciesRuleExists(context.Context, uuid.UUID, uuid.UUID) (bool, error)
	GetHamsterForUpdate(context.Context, uuid.UUID, uuid.UUID) (Hamster, error)
	InsertHamster(context.Context, uuid.UUID, uuid.UUID, CreateHamsterInput) (Hamster, error)
	UpdateHamster(context.Context, uuid.UUID, uuid.UUID, int, UpdateHamsterInput) (Hamster, error)
	UpdateHamsterEnclosure(context.Context, uuid.UUID, uuid.UUID, int, *uuid.UUID) (Hamster, error)
	GetEnclosureForUpdate(context.Context, uuid.UUID, uuid.UUID) (Enclosure, error)
	LockEnclosures(context.Context, uuid.UUID, ...uuid.UUID) error
	InsertEnclosure(context.Context, uuid.UUID, uuid.UUID, CreateEnclosureInput) (Enclosure, error)
	UpdateEnclosure(context.Context, uuid.UUID, uuid.UUID, int, UpdateEnclosureInput) (Enclosure, error)
	RefreshEnclosureState(context.Context, uuid.UUID, uuid.UUID, int) (Enclosure, error)
	GetStayForUpdate(context.Context, uuid.UUID, uuid.UUID) (EnclosureStay, error)
	FindStayConflict(context.Context, uuid.UUID, uuid.UUID, uuid.UUID, time.Time, *time.Time, *uuid.UUID, string, *uuid.UUID) (StayConflict, error)
	InsertStay(context.Context, uuid.UUID, EnclosureStay) (EnclosureStay, error)
	EndStay(context.Context, uuid.UUID, uuid.UUID, int, time.Time, *string) (EnclosureStay, error)
	GetEnclosureCleaningForUpdate(context.Context, uuid.UUID, uuid.UUID) (EnclosureCleaning, error)
	InsertEnclosureCleaning(context.Context, uuid.UUID, CreateEnclosureCleaningInput) (EnclosureCleaning, error)
	MarkEnclosureClean(context.Context, uuid.UUID, uuid.UUID, int, time.Time) (Enclosure, error)
	ResolveWeightSubject(context.Context, uuid.UUID, CreateWeightInput) (WeightSubject, error)
	PreviousWeights(context.Context, uuid.UUID, CreateWeightInput) (*float64, *float64, error)
	InsertWeight(context.Context, uuid.UUID, uuid.UUID, CreateWeightInput, WeightSubject, *float64, *float64) (WeightRecord, error)
	GetLitterForUpdate(context.Context, uuid.UUID, uuid.UUID) (Litter, error)
	GetActiveLitterParentForUpdate(context.Context, uuid.UUID, uuid.UUID, string) (*LitterParent, error)
	SupersedeLitterParent(context.Context, uuid.UUID, uuid.UUID, string) error
	LitterHamsterMemberIDs(context.Context, uuid.UUID, uuid.UUID) ([]uuid.UUID, error)
	InsertLitterParent(context.Context, uuid.UUID, CreateLitterParentInput, *uuid.UUID) (LitterParent, error)
	TouchLitter(context.Context, uuid.UUID, uuid.UUID, int) (Litter, error)
	CheckPedigreeCycle(context.Context, uuid.UUID, uuid.UUID, uuid.UUID) (bool, error)
	GetActivePedigreeParentageForUpdate(context.Context, uuid.UUID, uuid.UUID, string) (*PedigreeParentage, error)
	SupersedePedigreeParentage(context.Context, uuid.UUID, uuid.UUID, string) error
	InsertPedigreeParentage(context.Context, uuid.UUID, CreatePedigreeParentageInput, *uuid.UUID) (PedigreeParentage, error)
	AppendEvent(context.Context, DomainEvent) error
}
