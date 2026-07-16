package i4core

import (
	"context"
	"time"

	"github.com/google/uuid"
)

type Repository interface {
	Execute(context.Context, Command, func(context.Context, Transaction) (any, error)) (CommandResult, error)
	GetLitter(context.Context, uuid.UUID, uuid.UUID) (Litter, error)
	GetIndividualizationEligibility(context.Context, uuid.UUID, uuid.UUID) (IndividualizationEligibility, error)
}

type Transaction interface {
	GetPlanForUpdate(context.Context, uuid.UUID, uuid.UUID) (BreedingPlan, error)
	GetLitterForUpdate(context.Context, uuid.UUID, uuid.UUID) (Litter, error)
	ListPupsForUpdate(context.Context, uuid.UUID, uuid.UUID) ([]PupIdentity, error)
	GetPupForUpdate(context.Context, uuid.UUID, uuid.UUID) (PupIdentity, error)
	GetEnclosureForUpdate(context.Context, uuid.UUID, uuid.UUID) (Enclosure, error)
	GetLitterParents(context.Context, uuid.UUID, uuid.UUID) (LitterParents, error)
	CreateLitter(context.Context, uuid.UUID, ConfirmBirthInput, BreedingPlan) (Litter, error)
	InsertLitterParents(context.Context, uuid.UUID, uuid.UUID, uuid.UUID, uuid.UUID) error
	InsertCountEvent(context.Context, uuid.UUID, uuid.UUID, CountEventInput, *uuid.UUID) (CountEvent, error)
	InsertPupIdentities(context.Context, uuid.UUID, uuid.UUID, []string) ([]PupIdentity, error)
	InsertPupIdentity(context.Context, uuid.UUID, uuid.UUID, string) (PupIdentity, error)
	InsertLitterPupMember(context.Context, uuid.UUID, uuid.UUID, uuid.UUID) error
	ClosePupMember(context.Context, uuid.UUID, uuid.UUID, time.Time) error
	UpdatePlanBirth(context.Context, uuid.UUID, uuid.UUID, int, ConfirmBirthInput, *uuid.UUID, string) (BreedingPlan, error)
	UpdateLitterCountProjection(context.Context, uuid.UUID, uuid.UUID, int, CountEventInput) (Litter, error)
	UpdatePupOutcome(context.Context, uuid.UUID, uuid.UUID, string, *time.Time, *uuid.UUID, *string) (PupIdentity, error)
	UpdatePupSexAndEnclosure(context.Context, uuid.UUID, uuid.UUID, string, *float64, uuid.UUID, *string) (PupIdentity, error)
	UpdateLitterWeaned(context.Context, uuid.UUID, uuid.UUID, int, time.Time) (Litter, error)
	UpdateLitterSeparated(context.Context, uuid.UUID, uuid.UUID, int, time.Time) (Litter, error)
	InsertHamster(context.Context, uuid.UUID, BreedingPlan, PupIdentity, IndividualizeItem) (Hamster, error)
	InsertLitterHamsterMember(context.Context, uuid.UUID, uuid.UUID, uuid.UUID, uuid.UUID) error
	InsertPedigreeParentage(context.Context, uuid.UUID, uuid.UUID, uuid.UUID, string) error
	UpdatePupIndividualized(context.Context, uuid.UUID, uuid.UUID, uuid.UUID) (PupIdentity, error)
	UpdateLitterIndividualized(context.Context, uuid.UUID, uuid.UUID, int, time.Time) (Litter, error)
	AppendEvent(context.Context, DomainEvent) (uuid.UUID, error)
}

type Enclosure struct {
	ID       uuid.UUID
	OwnerID  uuid.UUID
	Capacity int
	State    string
}

type LitterParents struct {
	SireID uuid.UUID
	DamID  uuid.UUID
}
