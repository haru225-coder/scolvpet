package i2core

import (
	"context"
	"encoding/json"
	"errors"
	"sort"
	"strings"
	"sync"
	"time"

	"github.com/google/uuid"
)

type memoryStoredCommand struct {
	canonical string
	body      []byte
	status    int
}

type memoryRepository struct {
	mu sync.Mutex

	organizations map[uuid.UUID]uuid.UUID
	rules         map[uuid.UUID]*uuid.UUID
	hamsters      map[uuid.UUID]Hamster
	enclosures    map[uuid.UUID]Enclosure
	stays         map[uuid.UUID]EnclosureStay
	cleanings     map[uuid.UUID]EnclosureCleaning
	weights       map[uuid.UUID]WeightRecord
	litters       map[uuid.UUID]Litter
	litterParents map[uuid.UUID][]LitterParent
	litterMembers map[uuid.UUID][]LitterMember
	parentages    map[uuid.UUID]PedigreeParentage
	events        []DomainEvent
	stored        map[string]memoryStoredCommand

	failNextStayInsert bool
}

func newMemoryRepository() *memoryRepository {
	return &memoryRepository{
		organizations: map[uuid.UUID]uuid.UUID{},
		rules:         map[uuid.UUID]*uuid.UUID{},
		hamsters:      map[uuid.UUID]Hamster{},
		enclosures:    map[uuid.UUID]Enclosure{},
		stays:         map[uuid.UUID]EnclosureStay{},
		cleanings:     map[uuid.UUID]EnclosureCleaning{},
		weights:       map[uuid.UUID]WeightRecord{},
		litters:       map[uuid.UUID]Litter{},
		litterParents: map[uuid.UUID][]LitterParent{},
		litterMembers: map[uuid.UUID][]LitterMember{},
		parentages:    map[uuid.UUID]PedigreeParentage{},
		events:        []DomainEvent{},
		stored:        map[string]memoryStoredCommand{},
	}
}

func (r *memoryRepository) provision(ownerID uuid.UUID) (uuid.UUID, uuid.UUID) {
	organizationID := uuid.New()
	ruleID := uuid.New()
	r.organizations[ownerID] = organizationID
	owner := ownerID
	r.rules[ruleID] = &owner
	return organizationID, ruleID
}

func (r *memoryRepository) Execute(ctx context.Context, command Command, fn func(context.Context, Transaction) (any, error)) (CommandResult, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	key := command.OwnerID.String() + ":" + command.IdempotencyKey
	canonical := canonicalCommand(command.Method, command.Path, command.Payload)
	if existing, ok := r.stored[key]; ok {
		if existing.canonical != canonical {
			return CommandResult{}, ErrIdempotencyPayloadMismatch
		}
		return CommandResult{Body: append([]byte(nil), existing.body...), Status: existing.status, Replayed: true}, nil
	}
	clone := r.clone()
	value, err := fn(ctx, clone)
	if err != nil {
		r.failNextStayInsert = false
		return CommandResult{}, err
	}
	body, err := json.Marshal(value)
	if err != nil {
		return CommandResult{}, err
	}
	r.commit(clone)
	r.stored[key] = memoryStoredCommand{canonical: canonical, body: append([]byte(nil), body...), status: command.SuccessStatus}
	return CommandResult{Body: body, Status: command.SuccessStatus}, nil
}

func (r *memoryRepository) clone() *memoryRepository {
	clone := newMemoryRepository()
	for key, value := range r.organizations {
		clone.organizations[key] = value
	}
	for key, value := range r.rules {
		clone.rules[key] = value
	}
	for key, value := range r.hamsters {
		clone.hamsters[key] = value
	}
	for key, value := range r.enclosures {
		clone.enclosures[key] = value
	}
	for key, value := range r.stays {
		clone.stays[key] = value
	}
	for key, value := range r.cleanings {
		clone.cleanings[key] = value
	}
	for key, value := range r.weights {
		clone.weights[key] = value
	}
	for key, value := range r.litters {
		clone.litters[key] = value
	}
	for key, value := range r.litterParents {
		clone.litterParents[key] = append([]LitterParent(nil), value...)
	}
	for key, value := range r.litterMembers {
		clone.litterMembers[key] = append([]LitterMember(nil), value...)
	}
	for key, value := range r.parentages {
		clone.parentages[key] = value
	}
	clone.events = append([]DomainEvent(nil), r.events...)
	clone.failNextStayInsert = r.failNextStayInsert
	return clone
}

func (r *memoryRepository) commit(clone *memoryRepository) {
	r.organizations = clone.organizations
	r.rules = clone.rules
	r.hamsters = clone.hamsters
	r.enclosures = clone.enclosures
	r.stays = clone.stays
	r.cleanings = clone.cleanings
	r.weights = clone.weights
	r.litters = clone.litters
	r.litterParents = clone.litterParents
	r.litterMembers = clone.litterMembers
	r.parentages = clone.parentages
	r.events = clone.events
	r.failNextStayInsert = false
}

func (r *memoryRepository) ListHamsters(_ context.Context, ownerID uuid.UUID, filter HamsterFilter) ([]Hamster, error) {
	result := make([]Hamster, 0)
	for _, hamster := range r.hamsters {
		if hamster.OwnerID != ownerID || (filter.Sex != "" && hamster.Sex != filter.Sex) ||
			(filter.LifecycleStatus != "" && hamster.LifecycleStatus != filter.LifecycleStatus) ||
			(filter.BreedingStatus != "" && hamster.BreedingStatus != filter.BreedingStatus) ||
			(filter.VarietyCode != "" && value(hamster.VarietyCode) != filter.VarietyCode) ||
			(filter.CurrentEnclosureID != nil && !sameUUID(hamster.CurrentEnclosureID, filter.CurrentEnclosureID)) {
			continue
		}
		keyword := strings.ToLower(strings.TrimSpace(filter.Keyword))
		if keyword != "" && !strings.Contains(strings.ToLower(hamster.InternalCode), keyword) && !strings.Contains(strings.ToLower(value(hamster.Name)), keyword) {
			continue
		}
		result = append(result, hamster)
	}
	sort.Slice(result, func(i, j int) bool { return result[i].CreatedAt.After(result[j].CreatedAt) })
	return pageSlice(result, filter.Page), nil
}

func (r *memoryRepository) GetHamster(_ context.Context, ownerID, hamsterID uuid.UUID) (Hamster, error) {
	hamster, ok := r.hamsters[hamsterID]
	if !ok || hamster.OwnerID != ownerID {
		return Hamster{}, ErrNotFound
	}
	return hamster, nil
}

func (r *memoryRepository) ListEnclosures(_ context.Context, ownerID uuid.UUID, filter EnclosureFilter) ([]Enclosure, error) {
	result := make([]Enclosure, 0)
	for _, enclosure := range r.enclosures {
		if enclosure.OwnerID != ownerID || (filter.RackCode != "" && value(enclosure.RackCode) != filter.RackCode) ||
			(filter.LevelCode != "" && value(enclosure.LevelCode) != filter.LevelCode) ||
			(filter.State != "" && enclosure.State != filter.State) || (filter.Cleanliness != "" && enclosure.Cleanliness != filter.Cleanliness) {
			continue
		}
		result = append(result, enclosure)
	}
	return pageSlice(result, filter.Page), nil
}

func (r *memoryRepository) GetEnclosure(_ context.Context, ownerID, enclosureID uuid.UUID) (Enclosure, error) {
	enclosure, ok := r.enclosures[enclosureID]
	if !ok || enclosure.OwnerID != ownerID {
		return Enclosure{}, ErrNotFound
	}
	return enclosure, nil
}

func (r *memoryRepository) ListStayHistory(_ context.Context, ownerID uuid.UUID, filter StayHistoryFilter) ([]EnclosureStay, error) {
	result := make([]EnclosureStay, 0)
	for _, stay := range r.stays {
		if stay.OwnerID != ownerID || (filter.HamsterID != nil && stay.HamsterID != *filter.HamsterID) ||
			(filter.EnclosureID != nil && stay.EnclosureID != *filter.EnclosureID) {
			continue
		}
		result = append(result, stay)
	}
	sort.Slice(result, func(i, j int) bool { return result[i].StartedAt.After(result[j].StartedAt) })
	return pageSlice(result, filter.Page), nil
}

func (r *memoryRepository) ListEnclosureCleanings(_ context.Context, ownerID, enclosureID uuid.UUID, page Page) ([]EnclosureCleaning, error) {
	if _, err := r.GetEnclosure(context.Background(), ownerID, enclosureID); err != nil {
		return nil, err
	}
	result := make([]EnclosureCleaning, 0)
	for _, cleaning := range r.cleanings {
		if cleaning.OwnerID == ownerID && cleaning.EnclosureID == enclosureID {
			result = append(result, cleaning)
		}
	}
	sort.Slice(result, func(i, j int) bool { return result[i].PerformedAt.After(result[j].PerformedAt) })
	return pageSlice(result, page), nil
}

func (r *memoryRepository) GetEnclosureCleaning(_ context.Context, ownerID, cleaningID uuid.UUID) (EnclosureCleaning, error) {
	cleaning, ok := r.cleanings[cleaningID]
	if !ok || cleaning.OwnerID != ownerID {
		return EnclosureCleaning{}, ErrNotFound
	}
	return cleaning, nil
}

func (r *memoryRepository) ListWeightRecords(_ context.Context, ownerID uuid.UUID, filter WeightRecordFilter) ([]WeightRecord, error) {
	result := make([]WeightRecord, 0)
	for _, record := range r.weights {
		if record.OwnerID != ownerID || (filter.HamsterID != nil && !sameUUID(record.HamsterID, filter.HamsterID)) ||
			(filter.PupIdentityID != nil && !sameUUID(record.PupIdentityID, filter.PupIdentityID)) ||
			(filter.LitterID != nil && !sameUUID(record.LitterID, filter.LitterID)) ||
			(filter.RecordedFrom != nil && record.RecordedAt.Before(*filter.RecordedFrom)) ||
			(filter.RecordedTo != nil && record.RecordedAt.After(*filter.RecordedTo)) {
			continue
		}
		result = append(result, record)
	}
	sort.Slice(result, func(i, j int) bool { return result[i].RecordedAt.After(result[j].RecordedAt) })
	return pageSlice(result, filter.Page), nil
}

func (r *memoryRepository) ListLitters(_ context.Context, ownerID uuid.UUID, filter LitterFilter) ([]Litter, error) {
	result := make([]Litter, 0)
	for _, litter := range r.litters {
		if litter.OwnerID == ownerID && (filter.Origin == "" || litter.Origin == filter.Origin) && (filter.State == "" || litter.State == filter.State) {
			result = append(result, litter)
		}
	}
	return pageSlice(result, filter.Page), nil
}

func (r *memoryRepository) GetLitter(_ context.Context, ownerID, litterID uuid.UUID) (Litter, error) {
	litter, ok := r.litters[litterID]
	if !ok || litter.OwnerID != ownerID {
		return Litter{}, ErrNotFound
	}
	return litter, nil
}

func (r *memoryRepository) GetLitterRelations(ctx context.Context, ownerID, litterID uuid.UUID) (LitterRelations, error) {
	litter, err := r.GetLitter(ctx, ownerID, litterID)
	if err != nil {
		return LitterRelations{}, err
	}
	return LitterRelations{Litter: litter, Parents: append([]LitterParent(nil), r.litterParents[litterID]...), Members: append([]LitterMember(nil), r.litterMembers[litterID]...)}, nil
}

func (r *memoryRepository) ListLitterParents(ctx context.Context, ownerID, litterID uuid.UUID, page Page) ([]LitterParent, error) {
	if _, err := r.GetLitter(ctx, ownerID, litterID); err != nil {
		return nil, err
	}
	return pageSlice(append([]LitterParent(nil), r.litterParents[litterID]...), page), nil
}

func (r *memoryRepository) ListLitterMembers(ctx context.Context, ownerID, litterID uuid.UUID, page Page) ([]LitterMember, error) {
	if _, err := r.GetLitter(ctx, ownerID, litterID); err != nil {
		return nil, err
	}
	return pageSlice(append([]LitterMember(nil), r.litterMembers[litterID]...), page), nil
}

func (r *memoryRepository) ListPedigreeParentages(_ context.Context, ownerID uuid.UUID, filter PedigreeParentageFilter) ([]PedigreeParentage, error) {
	result := make([]PedigreeParentage, 0)
	for _, parentage := range r.parentages {
		if parentage.OwnerID != ownerID || (filter.ChildHamsterID != nil && parentage.ChildID != *filter.ChildHamsterID) ||
			(filter.ParentHamsterID != nil && parentage.ParentID != *filter.ParentHamsterID) {
			continue
		}
		result = append(result, parentage)
	}
	sort.Slice(result, func(i, j int) bool { return result[i].ValidFrom.After(result[j].ValidFrom) })
	return pageSlice(result, filter.Page), nil
}

func (r *memoryRepository) GetHamsterPedigree(ctx context.Context, ownerID, hamsterID uuid.UUID, generations int) (PedigreeGraph, error) {
	if _, err := r.GetHamster(ctx, ownerID, hamsterID); err != nil {
		return PedigreeGraph{}, err
	}
	pathCount := map[uuid.UUID]int{}
	minimumGeneration := map[uuid.UUID]int{}
	edges := r.effectiveEdges(ownerID)
	var walk func(uuid.UUID, int, map[uuid.UUID]struct{})
	walk = func(childID uuid.UUID, depth int, path map[uuid.UUID]struct{}) {
		if depth > generations {
			return
		}
		for _, edge := range edges {
			if edge.childID != childID {
				continue
			}
			if _, seen := path[edge.parentID]; seen {
				continue
			}
			pathCount[edge.parentID]++
			if current, ok := minimumGeneration[edge.parentID]; !ok || depth < current {
				minimumGeneration[edge.parentID] = depth
			}
			next := make(map[uuid.UUID]struct{}, len(path)+1)
			for id := range path {
				next[id] = struct{}{}
			}
			next[edge.parentID] = struct{}{}
			walk(edge.parentID, depth+1, next)
		}
	}
	walk(hamsterID, 1, map[uuid.UUID]struct{}{hamsterID: {}})
	nodeSet := map[uuid.UUID]struct{}{hamsterID: {}}
	common := make([]CommonAncestor, 0)
	for id, paths := range pathCount {
		nodeSet[id] = struct{}{}
		if paths > 1 {
			common = append(common, CommonAncestor{HamsterID: id, Paths: paths, MinimumGeneration: minimumGeneration[id]})
		}
	}
	nodes := make([]Hamster, 0, len(nodeSet))
	parentages := make([]PedigreeParentage, 0)
	for id := range nodeSet {
		nodes = append(nodes, r.hamsters[id])
	}
	for _, edge := range r.parentages {
		_, parentIncluded := nodeSet[edge.ParentID]
		_, childIncluded := nodeSet[edge.ChildID]
		if edge.OwnerID == ownerID && parentIncluded && childIncluded && edge.Status == "accepted" && edge.ValidTo == nil {
			parentages = append(parentages, edge)
		}
	}
	litterParents := make([]LitterParent, 0)
	litterMembers := make([]LitterMember, 0)
	for litterID, members := range r.litterMembers {
		include := false
		for _, member := range members {
			if member.HamsterID != nil {
				_, include = nodeSet[*member.HamsterID]
			}
			if include {
				break
			}
		}
		if !include {
			for _, parent := range r.litterParents[litterID] {
				if _, include = nodeSet[parent.ParentID]; include {
					break
				}
			}
		}
		if include {
			litterMembers = append(litterMembers, members...)
			litterParents = append(litterParents, r.litterParents[litterID]...)
		}
	}
	return PedigreeGraph{RootHamsterID: hamsterID, Nodes: nodes, Parentages: parentages, LitterParents: litterParents, LitterMembers: litterMembers, CommonAncestors: common}, nil
}

func (r *memoryRepository) OrganizationID(_ context.Context, ownerID uuid.UUID) (uuid.UUID, error) {
	organizationID, ok := r.organizations[ownerID]
	if !ok {
		return uuid.Nil, ErrNotFound
	}
	return organizationID, nil
}

func (r *memoryRepository) SpeciesRuleExists(_ context.Context, ownerID, ruleID uuid.UUID) (bool, error) {
	ruleOwner, ok := r.rules[ruleID]
	return ok && (ruleOwner == nil || *ruleOwner == ownerID), nil
}

func (r *memoryRepository) GetHamsterForUpdate(ctx context.Context, ownerID, hamsterID uuid.UUID) (Hamster, error) {
	return r.GetHamster(ctx, ownerID, hamsterID)
}

func (r *memoryRepository) InsertHamster(_ context.Context, ownerID, organizationID uuid.UUID, input CreateHamsterInput) (Hamster, error) {
	for _, existing := range r.hamsters {
		if existing.OwnerID == ownerID && existing.InternalCode == input.InternalCode {
			return Hamster{}, ErrDuplicate
		}
	}
	now := time.Now().UTC()
	hamster := Hamster{
		ID: uuid.New(), OwnerID: ownerID, OrganizationID: organizationID, InternalCode: input.InternalCode,
		Name: input.Name, SpeciesRuleVersionID: input.SpeciesRuleVersionID, VarietyCode: input.VarietyCode,
		Sex: input.Sex, SexConfidence: input.SexConfidence, BirthDate: input.BirthDate, SourceType: input.SourceType,
		LifecycleStatus: input.LifecycleStatus, BreedingStatus: input.BreedingStatus, Phenotype: input.Phenotype,
		Tags: input.Tags, Notes: input.Notes, Version: 1, CreatedAt: now, UpdatedAt: now,
	}
	r.hamsters[hamster.ID] = hamster
	return hamster, nil
}

func (r *memoryRepository) UpdateHamster(_ context.Context, ownerID, hamsterID uuid.UUID, expectedVersion int, input UpdateHamsterInput) (Hamster, error) {
	hamster, ok := r.hamsters[hamsterID]
	if !ok || hamster.OwnerID != ownerID {
		return Hamster{}, ErrNotFound
	}
	if hamster.Version != expectedVersion {
		return Hamster{}, ErrVersionConflict
	}
	if input.InternalCode != nil {
		for _, existing := range r.hamsters {
			if existing.OwnerID == ownerID && existing.ID != hamsterID && existing.InternalCode == *input.InternalCode {
				return Hamster{}, ErrDuplicate
			}
		}
		hamster.InternalCode = *input.InternalCode
	}
	if input.ClearName {
		hamster.Name = nil
	} else if input.Name != nil {
		hamster.Name = input.Name
	}
	if input.ClearVariety {
		hamster.VarietyCode = nil
	} else if input.VarietyCode != nil {
		hamster.VarietyCode = input.VarietyCode
	}
	if input.Sex != nil {
		hamster.Sex = *input.Sex
	}
	if input.ClearSexConfidence {
		hamster.SexConfidence = nil
	} else if input.SexConfidence != nil {
		hamster.SexConfidence = input.SexConfidence
	}
	if input.ClearBirthDate {
		hamster.BirthDate = nil
	} else if input.BirthDate != nil {
		hamster.BirthDate = input.BirthDate
	}
	if input.ClearCoverMedia {
		hamster.CoverMediaID = nil
	} else if input.CoverMediaID != nil {
		hamster.CoverMediaID = input.CoverMediaID
	}
	if input.Phenotype != nil {
		hamster.Phenotype = input.Phenotype
	}
	if input.Tags != nil {
		hamster.Tags = input.Tags
	}
	if input.ClearNotes {
		hamster.Notes = nil
	} else if input.Notes != nil {
		hamster.Notes = input.Notes
	}
	hamster.Version++
	hamster.UpdatedAt = time.Now().UTC()
	r.hamsters[hamsterID] = hamster
	return hamster, nil
}

func (r *memoryRepository) UpdateHamsterEnclosure(_ context.Context, ownerID, hamsterID uuid.UUID, expectedVersion int, enclosureID *uuid.UUID) (Hamster, error) {
	hamster, ok := r.hamsters[hamsterID]
	if !ok || hamster.OwnerID != ownerID {
		return Hamster{}, ErrNotFound
	}
	if hamster.Version != expectedVersion {
		return Hamster{}, ErrVersionConflict
	}
	hamster.CurrentEnclosureID = enclosureID
	hamster.Version++
	hamster.UpdatedAt = time.Now().UTC()
	r.hamsters[hamsterID] = hamster
	return hamster, nil
}

func (r *memoryRepository) GetEnclosureForUpdate(ctx context.Context, ownerID, enclosureID uuid.UUID) (Enclosure, error) {
	return r.GetEnclosure(ctx, ownerID, enclosureID)
}

func (r *memoryRepository) LockEnclosures(_ context.Context, ownerID uuid.UUID, enclosureIDs ...uuid.UUID) error {
	for _, enclosureID := range enclosureIDs {
		if enclosure, ok := r.enclosures[enclosureID]; !ok || enclosure.OwnerID != ownerID {
			return ErrNotFound
		}
	}
	return nil
}

func (r *memoryRepository) InsertEnclosure(_ context.Context, ownerID, organizationID uuid.UUID, input CreateEnclosureInput) (Enclosure, error) {
	for _, existing := range r.enclosures {
		if existing.OwnerID == ownerID && existing.Code == input.Code {
			return Enclosure{}, ErrDuplicate
		}
	}
	now := time.Now().UTC()
	enclosure := Enclosure{
		ID: uuid.New(), OwnerID: ownerID, OrganizationID: organizationID, Code: input.Code,
		RackCode: input.RackCode, LevelCode: input.LevelCode, Capacity: input.Capacity,
		State: input.State, Cleanliness: input.Cleanliness, Dimensions: input.Dimensions, Equipment: input.Equipment,
		LastCleanedAt: input.LastCleanedAt, DisabledReason: input.DisabledReason, Version: 1, CreatedAt: now, UpdatedAt: now,
	}
	r.enclosures[enclosure.ID] = enclosure
	return enclosure, nil
}

func (r *memoryRepository) UpdateEnclosure(_ context.Context, ownerID, enclosureID uuid.UUID, expectedVersion int, input UpdateEnclosureInput) (Enclosure, error) {
	enclosure, ok := r.enclosures[enclosureID]
	if !ok || enclosure.OwnerID != ownerID {
		return Enclosure{}, ErrNotFound
	}
	if enclosure.Version != expectedVersion {
		return Enclosure{}, ErrVersionConflict
	}
	if input.Code != nil {
		for _, existing := range r.enclosures {
			if existing.OwnerID == ownerID && existing.ID != enclosureID && existing.Code == *input.Code {
				return Enclosure{}, ErrDuplicate
			}
		}
		enclosure.Code = *input.Code
	}
	if input.ClearRackCode {
		enclosure.RackCode = nil
	} else if input.RackCode != nil {
		enclosure.RackCode = input.RackCode
	}
	if input.ClearLevelCode {
		enclosure.LevelCode = nil
	} else if input.LevelCode != nil {
		enclosure.LevelCode = input.LevelCode
	}
	if input.Capacity != nil {
		enclosure.Capacity = *input.Capacity
	}
	if input.State != nil {
		enclosure.State = *input.State
	}
	if input.Cleanliness != nil {
		enclosure.Cleanliness = *input.Cleanliness
	}
	if input.Dimensions != nil {
		enclosure.Dimensions = input.Dimensions
	}
	if input.Equipment != nil {
		enclosure.Equipment = input.Equipment
	}
	if input.ClearLastCleanedAt {
		enclosure.LastCleanedAt = nil
	} else if input.LastCleanedAt != nil {
		enclosure.LastCleanedAt = input.LastCleanedAt
	}
	if input.ClearDisabledReason {
		enclosure.DisabledReason = nil
	} else if input.DisabledReason != nil {
		enclosure.DisabledReason = input.DisabledReason
	}
	enclosure.Version++
	enclosure.UpdatedAt = time.Now().UTC()
	r.enclosures[enclosureID] = enclosure
	return enclosure, nil
}

func (r *memoryRepository) RefreshEnclosureState(_ context.Context, ownerID, enclosureID uuid.UUID, expectedVersion int) (Enclosure, error) {
	enclosure, ok := r.enclosures[enclosureID]
	if !ok || enclosure.OwnerID != ownerID {
		return Enclosure{}, ErrNotFound
	}
	if enclosure.Version != expectedVersion {
		return Enclosure{}, ErrVersionConflict
	}
	enclosure.State = "vacant"
	for _, stay := range r.stays {
		if stay.OwnerID == ownerID && stay.EnclosureID == enclosureID && stay.EndedAt == nil {
			enclosure.State = enclosureStateForPurpose(stay.Purpose)
			break
		}
	}
	enclosure.Version++
	enclosure.UpdatedAt = time.Now().UTC()
	r.enclosures[enclosureID] = enclosure
	return enclosure, nil
}

func (r *memoryRepository) GetStayForUpdate(_ context.Context, ownerID, stayID uuid.UUID) (EnclosureStay, error) {
	stay, ok := r.stays[stayID]
	if !ok || stay.OwnerID != ownerID {
		return EnclosureStay{}, ErrNotFound
	}
	return stay, nil
}

func (r *memoryRepository) FindStayConflict(_ context.Context, ownerID, enclosureID, hamsterID uuid.UUID, startedAt time.Time, endedAt *time.Time, excludeStayID *uuid.UUID, purpose string, pairingAttemptID *uuid.UUID) (StayConflict, error) {
	var conflict StayConflict
	overlaps := 0
	for _, stay := range r.stays {
		if stay.OwnerID != ownerID || (excludeStayID != nil && stay.ID == *excludeStayID) || !periodsOverlap(stay.StartedAt, stay.EndedAt, startedAt, endedAt) {
			continue
		}
		if stay.HamsterID == hamsterID {
			conflict.HamsterConflict = true
		}
		if stay.EnclosureID == enclosureID {
			overlaps++
			if purpose != "pairing_temp" || stay.Purpose != "pairing_temp" || !sameUUID(stay.PairingAttemptID, pairingAttemptID) {
				conflict.EnclosureConflict = true
			}
		}
	}
	if purpose == "pairing_temp" {
		enclosure, ok := r.enclosures[enclosureID]
		if !ok || pairingAttemptID == nil || overlaps >= min(enclosure.Capacity, 2) {
			conflict.EnclosureConflict = true
		}
	}
	return conflict, nil
}

func (r *memoryRepository) InsertStay(_ context.Context, ownerID uuid.UUID, stay EnclosureStay) (EnclosureStay, error) {
	if r.failNextStayInsert {
		r.failNextStayInsert = false
		return EnclosureStay{}, errors.New("injected stay insert failure")
	}
	now := time.Now().UTC()
	stay.ID = uuid.New()
	stay.OwnerID = ownerID
	stay.Version = 1
	stay.CreatedAt = now
	stay.UpdatedAt = now
	r.stays[stay.ID] = stay
	return stay, nil
}

func (r *memoryRepository) EndStay(_ context.Context, ownerID, stayID uuid.UUID, expectedVersion int, endedAt time.Time, correctionNote *string) (EnclosureStay, error) {
	stay, ok := r.stays[stayID]
	if !ok || stay.OwnerID != ownerID {
		return EnclosureStay{}, ErrNotFound
	}
	if stay.Version != expectedVersion {
		return EnclosureStay{}, ErrVersionConflict
	}
	stay.EndedAt = &endedAt
	stay.CorrectionNote = correctionNote
	stay.Version++
	stay.UpdatedAt = time.Now().UTC()
	r.stays[stayID] = stay
	return stay, nil
}

func (r *memoryRepository) GetEnclosureCleaningForUpdate(ctx context.Context, ownerID, cleaningID uuid.UUID) (EnclosureCleaning, error) {
	return r.GetEnclosureCleaning(ctx, ownerID, cleaningID)
}

func (r *memoryRepository) InsertEnclosureCleaning(_ context.Context, ownerID uuid.UUID, input CreateEnclosureCleaningInput) (EnclosureCleaning, error) {
	cleaning := EnclosureCleaning{
		ID: uuid.New(), OwnerID: ownerID, EnclosureID: input.EnclosureID, CleaningType: input.CleaningType,
		PerformedAt: input.PerformedAt, OperatorID: ownerID, Supplies: input.Supplies, Notes: input.Notes,
		CorrectsCleaningRecordID: input.CorrectsCleaningRecordID, CorrectionReason: input.CorrectionReason, CreatedAt: time.Now().UTC(),
	}
	r.cleanings[cleaning.ID] = cleaning
	return cleaning, nil
}

func (r *memoryRepository) MarkEnclosureClean(_ context.Context, ownerID, enclosureID uuid.UUID, expectedVersion int, performedAt time.Time) (Enclosure, error) {
	enclosure, ok := r.enclosures[enclosureID]
	if !ok || enclosure.OwnerID != ownerID {
		return Enclosure{}, ErrNotFound
	}
	if enclosure.Version != expectedVersion {
		return Enclosure{}, ErrVersionConflict
	}
	enclosure.Cleanliness = "clean"
	if enclosure.LastCleanedAt == nil || enclosure.LastCleanedAt.Before(performedAt) {
		enclosure.LastCleanedAt = &performedAt
	}
	enclosure.Version++
	enclosure.UpdatedAt = time.Now().UTC()
	r.enclosures[enclosureID] = enclosure
	return enclosure, nil
}

func (r *memoryRepository) ResolveWeightSubject(_ context.Context, ownerID uuid.UUID, input CreateWeightInput) (WeightSubject, error) {
	switch input.SubjectType {
	case "hamster":
		hamster, ok := r.hamsters[*input.HamsterID]
		if !ok || hamster.OwnerID != ownerID {
			return WeightSubject{}, ErrNotFound
		}
		ruleID := hamster.SpeciesRuleVersionID
		return WeightSubject{OrganizationID: hamster.OrganizationID, SpeciesRuleVersionID: &ruleID}, nil
	case "litter":
		litter, ok := r.litters[*input.LitterID]
		if !ok || litter.OwnerID != ownerID {
			return WeightSubject{}, ErrNotFound
		}
		return WeightSubject{OrganizationID: litter.OrganizationID}, nil
	case "pup_identity":
		return WeightSubject{}, ErrNotFound
	default:
		return WeightSubject{}, ErrInvalidWeight
	}
}

func (r *memoryRepository) PreviousWeights(_ context.Context, ownerID uuid.UUID, input CreateWeightInput) (*float64, *float64, error) {
	matching := make([]WeightRecord, 0)
	for _, record := range r.weights {
		if record.OwnerID == ownerID && record.SubjectType == input.SubjectType && sameWeightSubject(record, input) && !record.RecordedAt.After(input.RecordedAt) {
			matching = append(matching, record)
		}
	}
	if len(matching) == 0 {
		return nil, nil, nil
	}
	sort.Slice(matching, func(i, j int) bool { return matching[i].RecordedAt.Before(matching[j].RecordedAt) })
	birth := matching[0].WeightG
	previous := matching[len(matching)-1].WeightG
	return &birth, &previous, nil
}

func (r *memoryRepository) InsertWeight(_ context.Context, ownerID, organizationID uuid.UUID, input CreateWeightInput, subject WeightSubject, birthWeight, previousWeight *float64) (WeightRecord, error) {
	if input.AcquisitionKey != nil {
		for _, existing := range r.weights {
			if existing.OwnerID == ownerID && existing.AcquisitionKey != nil && *existing.AcquisitionKey == *input.AcquisitionKey {
				return WeightRecord{}, ErrDuplicate
			}
		}
	}
	if birthWeight == nil {
		value := input.WeightG
		birthWeight = &value
	}
	record := WeightRecord{
		ID: uuid.New(), OwnerID: ownerID, OrganizationID: organizationID, SubjectType: input.SubjectType,
		HamsterID: input.HamsterID, PupIdentityID: input.PupIdentityID, LitterID: input.LitterID,
		MeasurementKind: input.MeasurementKind, SubjectCount: input.SubjectCount, WeightG: input.WeightG,
		RecordedAt: input.RecordedAt, Source: input.Source, AcquisitionKey: input.AcquisitionKey,
		SpeciesRuleVersionID: subject.SpeciesRuleVersionID, BirthWeightG: birthWeight, PreviousWeightG: previousWeight,
		AlertFlags: []string{}, OperatorID: ownerID, CorrectsWeightRecordID: input.CorrectsWeightRecordID,
		CorrectionReason: input.CorrectionReason, CreatedAt: time.Now().UTC(),
	}
	if birthWeight != nil {
		value := input.WeightG - *birthWeight
		record.ChangeFromBirthG = &value
	}
	if previousWeight != nil {
		value := input.WeightG - *previousWeight
		record.ChangeFromPreviousG = &value
	}
	r.weights[record.ID] = record
	return record, nil
}

func (r *memoryRepository) GetLitterForUpdate(ctx context.Context, ownerID, litterID uuid.UUID) (Litter, error) {
	return r.GetLitter(ctx, ownerID, litterID)
}

func (r *memoryRepository) GetActiveLitterParentForUpdate(_ context.Context, ownerID, litterID uuid.UUID, role string) (*LitterParent, error) {
	for _, parent := range r.litterParents[litterID] {
		if parent.OwnerID == ownerID && parent.Role == role && parent.Status == "accepted" && parent.ValidTo == nil {
			copy := parent
			return &copy, nil
		}
	}
	return nil, nil
}

func (r *memoryRepository) SupersedeLitterParent(_ context.Context, ownerID, litterParentID uuid.UUID, correctionReason string) error {
	for litterID, parents := range r.litterParents {
		for index, parent := range parents {
			if parent.ID == litterParentID && parent.OwnerID == ownerID && parent.Status == "accepted" && parent.ValidTo == nil {
				now := time.Now().UTC()
				parent.Status = "superseded"
				parent.ValidTo = &now
				parent.CorrectionNote = &correctionReason
				parent.Version++
				parent.UpdatedAt = now
				parents[index] = parent
				r.litterParents[litterID] = parents
				return nil
			}
		}
	}
	return ErrNotFound
}

func (r *memoryRepository) LitterHamsterMemberIDs(_ context.Context, ownerID, litterID uuid.UUID) ([]uuid.UUID, error) {
	if litter, ok := r.litters[litterID]; !ok || litter.OwnerID != ownerID {
		return nil, ErrNotFound
	}
	result := make([]uuid.UUID, 0)
	for _, member := range r.litterMembers[litterID] {
		if member.HamsterID != nil && member.Status == "accepted" && member.ValidTo == nil {
			result = append(result, *member.HamsterID)
		}
	}
	return result, nil
}

func (r *memoryRepository) InsertLitterParent(_ context.Context, ownerID uuid.UUID, input CreateLitterParentInput, correctsID *uuid.UUID) (LitterParent, error) {
	now := time.Now().UTC()
	parent := LitterParent{
		ID: uuid.New(), OwnerID: ownerID, LitterID: input.LitterID, ParentID: input.HamsterID,
		Role: input.Role, EvidenceType: publicLitterEvidence(input.EvidenceType), EvidencePayload: input.EvidencePayload,
		Confidence: input.Confidence, Status: "accepted", ValidFrom: now, CorrectsLitterParentID: correctsID,
		CorrectionNote: input.CorrectionReason, Version: 1, CreatedAt: now, UpdatedAt: now,
	}
	r.litterParents[input.LitterID] = append(r.litterParents[input.LitterID], parent)
	return parent, nil
}

func (r *memoryRepository) TouchLitter(_ context.Context, ownerID, litterID uuid.UUID, expectedVersion int) (Litter, error) {
	litter, ok := r.litters[litterID]
	if !ok || litter.OwnerID != ownerID {
		return Litter{}, ErrNotFound
	}
	if litter.Version != expectedVersion {
		return Litter{}, ErrVersionConflict
	}
	litter.Version++
	litter.UpdatedAt = time.Now().UTC()
	for _, parent := range r.litterParents[litterID] {
		if parent.Status != "accepted" || parent.ValidTo != nil {
			continue
		}
		parentID := parent.ParentID
		if parent.Role == "sire" {
			litter.SireID = &parentID
		} else {
			litter.DamID = &parentID
		}
	}
	r.litters[litterID] = litter
	return litter, nil
}

func (r *memoryRepository) CheckPedigreeCycle(_ context.Context, ownerID, parentID, childID uuid.UUID) (bool, error) {
	queue := []uuid.UUID{childID}
	seen := map[uuid.UUID]struct{}{}
	for len(queue) > 0 {
		current := queue[0]
		queue = queue[1:]
		if current == parentID {
			return true, nil
		}
		if _, ok := seen[current]; ok {
			continue
		}
		seen[current] = struct{}{}
		for _, edge := range r.effectiveEdges(ownerID) {
			if edge.parentID == current {
				queue = append(queue, edge.childID)
			}
		}
	}
	return false, nil
}

func (r *memoryRepository) InsertPedigreeParentage(_ context.Context, ownerID uuid.UUID, input CreatePedigreeParentageInput) (PedigreeParentage, error) {
	for _, existing := range r.parentages {
		if existing.OwnerID == ownerID && existing.ChildID == input.ChildID && existing.Role == input.Role && existing.Status == "accepted" && existing.ValidTo == nil {
			return PedigreeParentage{}, ErrDuplicate
		}
	}
	now := input.ValidFrom
	parentage := PedigreeParentage{
		ID: uuid.New(), OwnerID: ownerID, ParentID: input.ParentID, ChildID: input.ChildID,
		Role: input.Role, EvidenceType: input.EvidenceType, EvidencePayload: input.EvidencePayload,
		Confidence: input.Confidence, Status: "accepted", ValidFrom: now, Version: 1, CreatedAt: now, UpdatedAt: now,
	}
	parentage.EvidenceType = publicPedigreeEvidence(parentage.EvidenceType)
	parentage.Notes = input.Notes
	r.parentages[parentage.ID] = parentage
	return parentage, nil
}

func (r *memoryRepository) AppendEvent(_ context.Context, event DomainEvent) error {
	r.events = append(r.events, event)
	return nil
}

func periodsOverlap(leftStart time.Time, leftEnd *time.Time, rightStart time.Time, rightEnd *time.Time) bool {
	leftBeforeRightEnd := rightEnd == nil || leftStart.Before(*rightEnd)
	rightBeforeLeftEnd := leftEnd == nil || rightStart.Before(*leftEnd)
	return leftBeforeRightEnd && rightBeforeLeftEnd
}

func enclosureStateForPurpose(purpose string) string {
	switch purpose {
	case "single":
		return "occupied_single"
	case "pairing_temp":
		return "pairing_temp"
	case "gestation":
		return "gestation"
	case "isolation":
		return "isolation"
	case "dam_with_litter":
		return "dam_with_litter"
	default:
		return "vacant"
	}
}

func sameUUID(left, right *uuid.UUID) bool {
	return (left == nil && right == nil) || (left != nil && right != nil && *left == *right)
}

func sameWeightSubject(record WeightRecord, input CreateWeightInput) bool {
	return sameUUID(record.HamsterID, input.HamsterID) && sameUUID(record.PupIdentityID, input.PupIdentityID) && sameUUID(record.LitterID, input.LitterID)
}

func value(pointer *string) string {
	if pointer == nil {
		return ""
	}
	return *pointer
}

func pageSlice[T any](values []T, page Page) []T {
	start := page.Offset
	if start > len(values) {
		start = len(values)
	}
	end := start + page.Limit
	if end > len(values) {
		end = len(values)
	}
	return values[start:end]
}

type memoryPedigreeEdge struct {
	parentID uuid.UUID
	childID  uuid.UUID
}

func (r *memoryRepository) effectiveEdges(ownerID uuid.UUID) []memoryPedigreeEdge {
	result := make([]memoryPedigreeEdge, 0)
	seen := map[memoryPedigreeEdge]struct{}{}
	appendEdge := func(edge memoryPedigreeEdge) {
		if _, exists := seen[edge]; exists {
			return
		}
		seen[edge] = struct{}{}
		result = append(result, edge)
	}
	for _, parentage := range r.parentages {
		if parentage.OwnerID == ownerID && parentage.Status == "accepted" && parentage.ValidTo == nil {
			appendEdge(memoryPedigreeEdge{parentID: parentage.ParentID, childID: parentage.ChildID})
		}
	}
	for litterID, parents := range r.litterParents {
		for _, parent := range parents {
			if parent.OwnerID != ownerID || parent.Status != "accepted" || parent.ValidTo != nil {
				continue
			}
			for _, member := range r.litterMembers[litterID] {
				if member.HamsterID != nil && member.Status == "accepted" && member.ValidTo == nil {
					appendEdge(memoryPedigreeEdge{parentID: parent.ParentID, childID: *member.HamsterID})
				}
			}
		}
	}
	return result
}
