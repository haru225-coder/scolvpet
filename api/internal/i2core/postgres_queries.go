package i2core

import (
	"context"
	"encoding/json"
	"fmt"
	"sort"
	"strings"

	"github.com/google/uuid"
)

const hamsterSelect = `
	SELECT id, owner_id, organization_id, internal_code, name, species_rule_version_id,
		variety_code, sex, sex_confidence, birth_date, source_type, lifecycle_status,
		breeding_status, current_enclosure_id, phenotype, tags, notes, version, created_at, updated_at
	FROM hamster`

const enclosureSelect = `
	SELECT id, owner_id, organization_id, code, rack_code, level_code, capacity,
		state, cleanliness, size_mm, equipment, last_cleaned_at, disabled_reason,
		version, created_at, updated_at
	FROM enclosure`

const staySelect = `
	SELECT id, owner_id, enclosure_id, hamster_id, pairing_attempt_id, purpose,
		started_at, ended_at, operator_id, reason, correction_note, version, created_at, updated_at
	FROM enclosure_stay`

const cleaningSelect = `
	SELECT id, owner_id, enclosure_id, cleaning_type, performed_at, operator_id,
		source_event_id, supplies, notes, corrects_cleaning_record_id, correction_reason, created_at
	FROM enclosure_cleaning_record`

const weightSelect = `
	SELECT id, owner_id, organization_id, subject_type, hamster_id, pup_identity_id,
		litter_id, measurement_kind, subject_count, weight_g, recorded_at, source,
		acquisition_key, species_rule_version_id, birth_weight_g, previous_weight_g,
		change_from_birth_g, change_from_previous_g, alert_flags, operator_id,
		corrects_weight_record_id, correction_reason, created_at
	FROM weight_record`

const parentageSelect = `
	SELECT id, owner_id, parent_id, child_id, role, evidence_type, evidence_payload,
		confidence, status, valid_from, valid_to, relationship_assertion_id,
		version, created_at, updated_at
	FROM pedigree_parentage`

const litterParentSelect = `
	SELECT id, owner_id, litter_id, parent_id, role, evidence_type, evidence_payload,
		confidence, status, valid_from, valid_to, corrects_litter_parent_id,
		correction_note, version, created_at, updated_at
	FROM litter_parent`

const litterMemberSelect = `
	SELECT id, litter_id, member_type, pup_identity_id, hamster_id, origin_pup_identity_id,
		evidence_type, confidence, status, valid_from, valid_to, version
	FROM litter_member`

const litterSelect = `
	SELECT l.id, l.owner_id, l.organization_id, l.breeding_plan_id,
		(SELECT lp.parent_id FROM litter_parent lp
		 WHERE lp.owner_id=l.owner_id AND lp.litter_id=l.id AND lp.role='sire'
		   AND lp.status='accepted' AND lp.valid_to IS NULL ORDER BY lp.created_at DESC LIMIT 1),
		(SELECT lp.parent_id FROM litter_parent lp
		 WHERE lp.owner_id=l.owner_id AND lp.litter_id=l.id AND lp.role='dam'
		   AND lp.status='accepted' AND lp.valid_to IS NULL ORDER BY lp.created_at DESC LIMIT 1),
		l.origin, l.code, l.state, l.born_at, l.enclosure_id, l.dam_condition,
		l.initial_alive_count, l.initial_other_count, l.discovered_count, l.deceased_count,
		l.transferred_out_count, l.correction_delta, l.current_managed_count,
		l.unindividualized_alive_count, l.individualized_alive_count,
		l.weaning_completed_at, l.sex_separation_completed_at, l.reconciled_at,
		l.notes, l.version, l.created_at, l.updated_at
	FROM litter l`

func (r *PostgresRepository) ListHamsters(ctx context.Context, ownerID uuid.UUID, filter HamsterFilter) ([]Hamster, error) {
	query := hamsterSelect + ` WHERE owner_id=$1 AND deleted_at IS NULL`
	args := []any{ownerID}
	appendFilter := func(clause string, value any) {
		args = append(args, value)
		query += fmt.Sprintf(clause, len(args))
	}
	if strings.TrimSpace(filter.Keyword) != "" {
		value := "%" + strings.TrimSpace(filter.Keyword) + "%"
		args = append(args, value, value)
		query += fmt.Sprintf(` AND (internal_code ILIKE $%d OR COALESCE(name,'') ILIKE $%d)`, len(args)-1, len(args))
	}
	if filter.Sex != "" {
		appendFilter(` AND sex=$%d`, filter.Sex)
	}
	if filter.LifecycleStatus != "" {
		appendFilter(` AND lifecycle_status=$%d`, filter.LifecycleStatus)
	}
	if filter.BreedingStatus != "" {
		appendFilter(` AND breeding_status=$%d`, filter.BreedingStatus)
	}
	if filter.VarietyCode != "" {
		appendFilter(` AND variety_code=$%d`, filter.VarietyCode)
	}
	if filter.CurrentEnclosureID != nil {
		appendFilter(` AND current_enclosure_id=$%d`, *filter.CurrentEnclosureID)
	}
	args = append(args, filter.Page.Limit, filter.Page.Offset)
	query += fmt.Sprintf(` ORDER BY created_at DESC, id LIMIT $%d OFFSET $%d`, len(args)-1, len(args))
	rows, err := r.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, mapPostgresError(err)
	}
	defer rows.Close()
	result := make([]Hamster, 0)
	for rows.Next() {
		hamster, err := scanHamster(rows)
		if err != nil {
			return nil, mapPostgresError(err)
		}
		result = append(result, hamster)
	}
	return result, mapPostgresError(rows.Err())
}

func (r *PostgresRepository) GetHamster(ctx context.Context, ownerID, hamsterID uuid.UUID) (Hamster, error) {
	hamster, err := scanHamster(r.pool.QueryRow(ctx, hamsterSelect+` WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL`, ownerID, hamsterID))
	return hamster, mapPostgresError(err)
}

func (r *PostgresRepository) ListEnclosures(ctx context.Context, ownerID uuid.UUID, filter EnclosureFilter) ([]Enclosure, error) {
	query := enclosureSelect + ` WHERE owner_id=$1 AND deleted_at IS NULL`
	args := []any{ownerID}
	add := func(clause string, value any) {
		args = append(args, value)
		query += fmt.Sprintf(clause, len(args))
	}
	if strings.TrimSpace(filter.Keyword) != "" {
		value := "%" + strings.TrimSpace(filter.Keyword) + "%"
		args = append(args, value, value, value)
		query += fmt.Sprintf(` AND (code ILIKE $%d OR COALESCE(rack_code,'') ILIKE $%d OR COALESCE(level_code,'') ILIKE $%d)`, len(args)-2, len(args)-1, len(args))
	}
	if filter.RackCode != "" {
		add(` AND rack_code=$%d`, filter.RackCode)
	}
	if filter.LevelCode != "" {
		add(` AND level_code=$%d`, filter.LevelCode)
	}
	if filter.State != "" {
		add(` AND state=$%d`, filter.State)
	}
	if filter.Cleanliness != "" {
		add(` AND cleanliness=$%d`, filter.Cleanliness)
	}
	args = append(args, filter.Page.Limit, filter.Page.Offset)
	query += fmt.Sprintf(` ORDER BY rack_code NULLS LAST, level_code NULLS LAST, code LIMIT $%d OFFSET $%d`, len(args)-1, len(args))
	rows, err := r.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, mapPostgresError(err)
	}
	defer rows.Close()
	result := make([]Enclosure, 0)
	for rows.Next() {
		enclosure, err := scanEnclosure(rows)
		if err != nil {
			return nil, mapPostgresError(err)
		}
		result = append(result, enclosure)
	}
	return result, mapPostgresError(rows.Err())
}

func (r *PostgresRepository) GetEnclosure(ctx context.Context, ownerID, enclosureID uuid.UUID) (Enclosure, error) {
	enclosure, err := scanEnclosure(r.pool.QueryRow(ctx, enclosureSelect+` WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL`, ownerID, enclosureID))
	return enclosure, mapPostgresError(err)
}

func (r *PostgresRepository) ListStayHistory(ctx context.Context, ownerID uuid.UUID, filter StayHistoryFilter) ([]EnclosureStay, error) {
	query := staySelect + ` WHERE owner_id=$1 AND deleted_at IS NULL`
	args := []any{ownerID}
	if filter.HamsterID != nil {
		args = append(args, *filter.HamsterID)
		query += fmt.Sprintf(` AND hamster_id=$%d`, len(args))
	}
	if filter.EnclosureID != nil {
		args = append(args, *filter.EnclosureID)
		query += fmt.Sprintf(` AND enclosure_id=$%d`, len(args))
	}
	args = append(args, filter.Page.Limit, filter.Page.Offset)
	query += fmt.Sprintf(` ORDER BY started_at DESC, created_at DESC LIMIT $%d OFFSET $%d`, len(args)-1, len(args))
	rows, err := r.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, mapPostgresError(err)
	}
	defer rows.Close()
	result := make([]EnclosureStay, 0)
	for rows.Next() {
		stay, err := scanStay(rows)
		if err != nil {
			return nil, mapPostgresError(err)
		}
		result = append(result, stay)
	}
	return result, mapPostgresError(rows.Err())
}

func (r *PostgresRepository) ListEnclosureCleanings(ctx context.Context, ownerID, enclosureID uuid.UUID, page Page) ([]EnclosureCleaning, error) {
	if _, err := r.GetEnclosure(ctx, ownerID, enclosureID); err != nil {
		return nil, err
	}
	rows, err := r.pool.Query(ctx, cleaningSelect+`
		WHERE owner_id=$1 AND enclosure_id=$2
		ORDER BY performed_at DESC, created_at DESC LIMIT $3 OFFSET $4
	`, ownerID, enclosureID, page.Limit, page.Offset)
	if err != nil {
		return nil, mapPostgresError(err)
	}
	defer rows.Close()
	result := make([]EnclosureCleaning, 0)
	for rows.Next() {
		cleaning, err := scanCleaning(rows)
		if err != nil {
			return nil, mapPostgresError(err)
		}
		result = append(result, cleaning)
	}
	return result, mapPostgresError(rows.Err())
}

func (r *PostgresRepository) GetEnclosureCleaning(ctx context.Context, ownerID, cleaningID uuid.UUID) (EnclosureCleaning, error) {
	cleaning, err := scanCleaning(r.pool.QueryRow(ctx, cleaningSelect+` WHERE owner_id=$1 AND id=$2`, ownerID, cleaningID))
	return cleaning, mapPostgresError(err)
}

func (r *PostgresRepository) ListWeightRecords(ctx context.Context, ownerID uuid.UUID, filter WeightRecordFilter) ([]WeightRecord, error) {
	query := weightSelect + ` WHERE owner_id=$1`
	args := []any{ownerID}
	add := func(clause string, value any) {
		args = append(args, value)
		query += fmt.Sprintf(clause, len(args))
	}
	if filter.HamsterID != nil {
		add(` AND hamster_id=$%d`, *filter.HamsterID)
	}
	if filter.PupIdentityID != nil {
		add(` AND pup_identity_id=$%d`, *filter.PupIdentityID)
	}
	if filter.LitterID != nil {
		add(` AND litter_id=$%d`, *filter.LitterID)
	}
	if filter.RecordedFrom != nil {
		add(` AND recorded_at>=$%d`, *filter.RecordedFrom)
	}
	if filter.RecordedTo != nil {
		add(` AND recorded_at<=$%d`, *filter.RecordedTo)
	}
	args = append(args, filter.Page.Limit, filter.Page.Offset)
	query += fmt.Sprintf(` ORDER BY recorded_at DESC, created_at DESC LIMIT $%d OFFSET $%d`, len(args)-1, len(args))
	rows, err := r.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, mapPostgresError(err)
	}
	defer rows.Close()
	result := make([]WeightRecord, 0)
	for rows.Next() {
		record, err := scanWeight(rows)
		if err != nil {
			return nil, mapPostgresError(err)
		}
		result = append(result, record)
	}
	return result, mapPostgresError(rows.Err())
}

func (r *PostgresRepository) ListLitters(ctx context.Context, ownerID uuid.UUID, filter LitterFilter) ([]Litter, error) {
	query := litterSelect + ` WHERE l.owner_id=$1 AND l.deleted_at IS NULL`
	args := []any{ownerID}
	if filter.Origin != "" {
		args = append(args, filter.Origin)
		query += fmt.Sprintf(` AND l.origin=$%d`, len(args))
	}
	if filter.State != "" {
		args = append(args, filter.State)
		query += fmt.Sprintf(` AND l.state=$%d`, len(args))
	}
	args = append(args, filter.Page.Limit, filter.Page.Offset)
	query += fmt.Sprintf(` ORDER BY l.born_at DESC NULLS LAST, l.created_at DESC LIMIT $%d OFFSET $%d`, len(args)-1, len(args))
	rows, err := r.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, mapPostgresError(err)
	}
	defer rows.Close()
	result := make([]Litter, 0)
	for rows.Next() {
		litter, err := scanLitter(rows)
		if err != nil {
			return nil, mapPostgresError(err)
		}
		result = append(result, litter)
	}
	return result, mapPostgresError(rows.Err())
}

func (r *PostgresRepository) GetLitter(ctx context.Context, ownerID, litterID uuid.UUID) (Litter, error) {
	litter, err := scanLitter(r.pool.QueryRow(ctx, litterSelect+` WHERE l.owner_id=$1 AND l.id=$2 AND l.deleted_at IS NULL`, ownerID, litterID))
	return litter, mapPostgresError(err)
}

func (r *PostgresRepository) GetLitterRelations(ctx context.Context, ownerID, litterID uuid.UUID) (LitterRelations, error) {
	litter, err := r.GetLitter(ctx, ownerID, litterID)
	if err != nil {
		return LitterRelations{}, err
	}
	parents, err := r.listLitterParents(ctx, ownerID, litterID)
	if err != nil {
		return LitterRelations{}, err
	}
	members, err := r.listLitterMembers(ctx, ownerID, litterID)
	if err != nil {
		return LitterRelations{}, err
	}
	return LitterRelations{Litter: litter, Parents: parents, Members: members}, nil
}

func (r *PostgresRepository) ListLitterParents(ctx context.Context, ownerID, litterID uuid.UUID, page Page) ([]LitterParent, error) {
	if _, err := r.GetLitter(ctx, ownerID, litterID); err != nil {
		return nil, err
	}
	rows, err := r.pool.Query(ctx, litterParentSelect+`
		WHERE owner_id=$1 AND litter_id=$2
		ORDER BY role, created_at DESC LIMIT $3 OFFSET $4
	`, ownerID, litterID, page.Limit, page.Offset)
	if err != nil {
		return nil, mapPostgresError(err)
	}
	defer rows.Close()
	result := make([]LitterParent, 0)
	for rows.Next() {
		parent, err := scanLitterParent(rows)
		if err != nil {
			return nil, mapPostgresError(err)
		}
		result = append(result, parent)
	}
	return result, mapPostgresError(rows.Err())
}

func (r *PostgresRepository) ListLitterMembers(ctx context.Context, ownerID, litterID uuid.UUID, page Page) ([]LitterMember, error) {
	if _, err := r.GetLitter(ctx, ownerID, litterID); err != nil {
		return nil, err
	}
	rows, err := r.pool.Query(ctx, litterMemberSelect+`
		WHERE owner_id=$1 AND litter_id=$2
		ORDER BY created_at LIMIT $3 OFFSET $4
	`, ownerID, litterID, page.Limit, page.Offset)
	if err != nil {
		return nil, mapPostgresError(err)
	}
	defer rows.Close()
	result := make([]LitterMember, 0)
	for rows.Next() {
		member, err := scanLitterMember(rows)
		if err != nil {
			return nil, mapPostgresError(err)
		}
		result = append(result, member)
	}
	return result, mapPostgresError(rows.Err())
}

func (r *PostgresRepository) ListPedigreeParentages(ctx context.Context, ownerID uuid.UUID, filter PedigreeParentageFilter) ([]PedigreeParentage, error) {
	query := parentageSelect + ` WHERE owner_id=$1`
	args := []any{ownerID}
	if filter.ChildHamsterID != nil {
		args = append(args, *filter.ChildHamsterID)
		query += fmt.Sprintf(` AND child_id=$%d`, len(args))
	}
	if filter.ParentHamsterID != nil {
		args = append(args, *filter.ParentHamsterID)
		query += fmt.Sprintf(` AND parent_id=$%d`, len(args))
	}
	args = append(args, filter.Page.Limit, filter.Page.Offset)
	query += fmt.Sprintf(` ORDER BY valid_from DESC, created_at DESC LIMIT $%d OFFSET $%d`, len(args)-1, len(args))
	rows, err := r.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, mapPostgresError(err)
	}
	defer rows.Close()
	result := make([]PedigreeParentage, 0)
	for rows.Next() {
		parentage, err := scanParentage(rows)
		if err != nil {
			return nil, mapPostgresError(err)
		}
		result = append(result, parentage)
	}
	return result, mapPostgresError(rows.Err())
}

func (r *PostgresRepository) GetHamsterPedigree(ctx context.Context, ownerID, hamsterID uuid.UUID, generations int) (PedigreeGraph, error) {
	if _, err := r.GetHamster(ctx, ownerID, hamsterID); err != nil {
		return PedigreeGraph{}, err
	}
	rows, err := r.pool.Query(ctx, `
		WITH RECURSIVE effective_edges(parent_id, child_id) AS (
			SELECT pp.parent_id, pp.child_id
			FROM pedigree_parentage pp
			WHERE pp.owner_id=$1 AND pp.status='accepted' AND pp.valid_to IS NULL
			UNION
			SELECT lp.parent_id, lm.hamster_id
			FROM litter_parent lp
			JOIN litter_member lm ON lm.owner_id=lp.owner_id AND lm.litter_id=lp.litter_id
			WHERE lp.owner_id=$1 AND lp.status='accepted' AND lp.valid_to IS NULL
			  AND lm.status='accepted' AND lm.valid_to IS NULL AND lm.hamster_id IS NOT NULL
		), ancestor_paths(hamster_id, depth, path) AS (
			SELECT ee.parent_id, 1, ARRAY[$2::uuid, ee.parent_id]
			FROM effective_edges ee WHERE ee.child_id=$2
			UNION ALL
			SELECT ee.parent_id, ap.depth+1, ap.path || ee.parent_id
			FROM ancestor_paths ap
			JOIN effective_edges ee ON ee.child_id=ap.hamster_id
			WHERE ap.depth<$3 AND NOT ee.parent_id=ANY(ap.path)
		)
		SELECT hamster_id, count(*)::int, min(depth)::int
		FROM ancestor_paths GROUP BY hamster_id
	`, ownerID, hamsterID, generations)
	if err != nil {
		return PedigreeGraph{}, mapPostgresError(err)
	}
	ancestorIDs := []uuid.UUID{hamsterID}
	common := make([]CommonAncestor, 0)
	for rows.Next() {
		var item CommonAncestor
		if err := rows.Scan(&item.HamsterID, &item.Paths, &item.MinimumGeneration); err != nil {
			rows.Close()
			return PedigreeGraph{}, mapPostgresError(err)
		}
		ancestorIDs = append(ancestorIDs, item.HamsterID)
		if item.Paths > 1 {
			common = append(common, item)
		}
	}
	if err := rows.Err(); err != nil {
		rows.Close()
		return PedigreeGraph{}, mapPostgresError(err)
	}
	rows.Close()
	ancestorIDs = uniqueUUIDs(ancestorIDs)

	nodes, err := r.hamstersByIDs(ctx, ownerID, ancestorIDs)
	if err != nil {
		return PedigreeGraph{}, err
	}
	parentages, err := r.parentagesForGraph(ctx, ownerID, ancestorIDs)
	if err != nil {
		return PedigreeGraph{}, err
	}
	litterIDs, err := r.litterIDsForHamsters(ctx, ownerID, ancestorIDs)
	if err != nil {
		return PedigreeGraph{}, err
	}
	litterParents, litterMembers := []LitterParent{}, []LitterMember{}
	if len(litterIDs) > 0 {
		litterParents, err = r.litterParentsByLitterIDs(ctx, ownerID, litterIDs)
		if err != nil {
			return PedigreeGraph{}, err
		}
		litterMembers, err = r.litterMembersByLitterIDs(ctx, ownerID, litterIDs)
		if err != nil {
			return PedigreeGraph{}, err
		}
	}
	sort.Slice(nodes, func(i, j int) bool {
		if nodes[i].ID == hamsterID {
			return true
		}
		if nodes[j].ID == hamsterID {
			return false
		}
		return nodes[i].InternalCode < nodes[j].InternalCode
	})
	return PedigreeGraph{RootHamsterID: hamsterID, Nodes: nodes, Parentages: parentages, LitterParents: litterParents, LitterMembers: litterMembers, CommonAncestors: common}, nil
}

func (r *PostgresRepository) hamstersByIDs(ctx context.Context, ownerID uuid.UUID, ids []uuid.UUID) ([]Hamster, error) {
	rows, err := r.pool.Query(ctx, hamsterSelect+` WHERE owner_id=$1 AND id=ANY($2::uuid[]) AND deleted_at IS NULL`, ownerID, ids)
	if err != nil {
		return nil, mapPostgresError(err)
	}
	defer rows.Close()
	result := make([]Hamster, 0, len(ids))
	for rows.Next() {
		hamster, err := scanHamster(rows)
		if err != nil {
			return nil, mapPostgresError(err)
		}
		result = append(result, hamster)
	}
	return result, mapPostgresError(rows.Err())
}

func (r *PostgresRepository) parentagesForGraph(ctx context.Context, ownerID uuid.UUID, ids []uuid.UUID) ([]PedigreeParentage, error) {
	rows, err := r.pool.Query(ctx, parentageSelect+`
		WHERE owner_id=$1 AND parent_id=ANY($2::uuid[]) AND child_id=ANY($2::uuid[])
		  AND status='accepted' AND valid_to IS NULL ORDER BY valid_from
	`, ownerID, ids)
	if err != nil {
		return nil, mapPostgresError(err)
	}
	defer rows.Close()
	result := make([]PedigreeParentage, 0)
	for rows.Next() {
		item, err := scanParentage(rows)
		if err != nil {
			return nil, mapPostgresError(err)
		}
		result = append(result, item)
	}
	return result, mapPostgresError(rows.Err())
}

func (r *PostgresRepository) litterIDsForHamsters(ctx context.Context, ownerID uuid.UUID, ids []uuid.UUID) ([]uuid.UUID, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT litter_id FROM litter_member
		WHERE owner_id=$1 AND hamster_id=ANY($2::uuid[]) AND status='accepted' AND valid_to IS NULL
		UNION
		SELECT litter_id FROM litter_parent
		WHERE owner_id=$1 AND parent_id=ANY($2::uuid[]) AND status='accepted' AND valid_to IS NULL
	`, ownerID, ids)
	if err != nil {
		return nil, mapPostgresError(err)
	}
	defer rows.Close()
	result := make([]uuid.UUID, 0)
	for rows.Next() {
		var id uuid.UUID
		if err := rows.Scan(&id); err != nil {
			return nil, mapPostgresError(err)
		}
		result = append(result, id)
	}
	return result, mapPostgresError(rows.Err())
}

func (r *PostgresRepository) litterParentsByLitterIDs(ctx context.Context, ownerID uuid.UUID, ids []uuid.UUID) ([]LitterParent, error) {
	rows, err := r.pool.Query(ctx, litterParentSelect+` WHERE owner_id=$1 AND litter_id=ANY($2::uuid[]) ORDER BY created_at`, ownerID, ids)
	if err != nil {
		return nil, mapPostgresError(err)
	}
	defer rows.Close()
	result := make([]LitterParent, 0)
	for rows.Next() {
		item, err := scanLitterParent(rows)
		if err != nil {
			return nil, mapPostgresError(err)
		}
		result = append(result, item)
	}
	return result, mapPostgresError(rows.Err())
}

func (r *PostgresRepository) litterMembersByLitterIDs(ctx context.Context, ownerID uuid.UUID, ids []uuid.UUID) ([]LitterMember, error) {
	rows, err := r.pool.Query(ctx, litterMemberSelect+` WHERE owner_id=$1 AND litter_id=ANY($2::uuid[]) ORDER BY created_at`, ownerID, ids)
	if err != nil {
		return nil, mapPostgresError(err)
	}
	defer rows.Close()
	result := make([]LitterMember, 0)
	for rows.Next() {
		item, err := scanLitterMember(rows)
		if err != nil {
			return nil, mapPostgresError(err)
		}
		result = append(result, item)
	}
	return result, mapPostgresError(rows.Err())
}

func (r *PostgresRepository) listLitterParents(ctx context.Context, ownerID, litterID uuid.UUID) ([]LitterParent, error) {
	rows, err := r.pool.Query(ctx, litterParentSelect+`
		WHERE owner_id=$1 AND litter_id=$2
		ORDER BY role, created_at
	`, ownerID, litterID)
	if err != nil {
		return nil, mapPostgresError(err)
	}
	defer rows.Close()
	result := make([]LitterParent, 0)
	for rows.Next() {
		item, err := scanLitterParent(rows)
		if err != nil {
			return nil, mapPostgresError(err)
		}
		result = append(result, item)
	}
	return result, mapPostgresError(rows.Err())
}

func (r *PostgresRepository) listLitterMembers(ctx context.Context, ownerID, litterID uuid.UUID) ([]LitterMember, error) {
	rows, err := r.pool.Query(ctx, litterMemberSelect+`
		WHERE owner_id=$1 AND litter_id=$2
		ORDER BY created_at
	`, ownerID, litterID)
	if err != nil {
		return nil, mapPostgresError(err)
	}
	defer rows.Close()
	result := make([]LitterMember, 0)
	for rows.Next() {
		item, err := scanLitterMember(rows)
		if err != nil {
			return nil, mapPostgresError(err)
		}
		result = append(result, item)
	}
	return result, mapPostgresError(rows.Err())
}

type rowScanner interface {
	Scan(...any) error
}

func scanHamster(row rowScanner) (Hamster, error) {
	var hamster Hamster
	var phenotype, tags []byte
	err := row.Scan(&hamster.ID, &hamster.OwnerID, &hamster.OrganizationID, &hamster.InternalCode,
		&hamster.Name, &hamster.SpeciesRuleVersionID, &hamster.VarietyCode, &hamster.Sex,
		&hamster.SexConfidence, &hamster.BirthDate, &hamster.SourceType, &hamster.LifecycleStatus,
		&hamster.BreedingStatus, &hamster.CurrentEnclosureID, &phenotype, &tags, &hamster.Notes,
		&hamster.Version, &hamster.CreatedAt, &hamster.UpdatedAt)
	if err != nil {
		return Hamster{}, err
	}
	hamster.Phenotype = decodeMap(phenotype)
	hamster.Tags = decodeStrings(tags)
	return hamster, nil
}

func scanEnclosure(row rowScanner) (Enclosure, error) {
	var enclosure Enclosure
	var size, equipment []byte
	err := row.Scan(&enclosure.ID, &enclosure.OwnerID, &enclosure.OrganizationID, &enclosure.Code,
		&enclosure.RackCode, &enclosure.LevelCode, &enclosure.Capacity, &enclosure.State,
		&enclosure.Cleanliness, &size, &equipment, &enclosure.LastCleanedAt,
		&enclosure.DisabledReason, &enclosure.Version, &enclosure.CreatedAt, &enclosure.UpdatedAt)
	if err != nil {
		return Enclosure{}, err
	}
	enclosure.Dimensions = decodeMap(size)
	enclosure.Equipment = decodeStrings(equipment)
	return enclosure, nil
}

func scanStay(row rowScanner) (EnclosureStay, error) {
	var stay EnclosureStay
	err := row.Scan(&stay.ID, &stay.OwnerID, &stay.EnclosureID, &stay.HamsterID,
		&stay.PairingAttemptID, &stay.Purpose, &stay.StartedAt, &stay.EndedAt,
		&stay.OperatorID, &stay.Reason, &stay.CorrectionNote, &stay.Version,
		&stay.CreatedAt, &stay.UpdatedAt)
	return stay, err
}

func scanCleaning(row rowScanner) (EnclosureCleaning, error) {
	var cleaning EnclosureCleaning
	var supplies []byte
	err := row.Scan(&cleaning.ID, &cleaning.OwnerID, &cleaning.EnclosureID, &cleaning.CleaningType,
		&cleaning.PerformedAt, &cleaning.OperatorID, &cleaning.SourceEventID, &supplies,
		&cleaning.Notes, &cleaning.CorrectsCleaningRecordID, &cleaning.CorrectionReason, &cleaning.CreatedAt)
	if err != nil {
		return EnclosureCleaning{}, err
	}
	cleaning.Supplies = decodeMap(supplies)
	return cleaning, nil
}

func scanLitter(row rowScanner) (Litter, error) {
	var litter Litter
	var damCondition []byte
	err := row.Scan(&litter.ID, &litter.OwnerID, &litter.OrganizationID, &litter.BreedingPlanID,
		&litter.SireID, &litter.DamID, &litter.Origin, &litter.Code, &litter.State,
		&litter.BornAt, &litter.EnclosureID, &damCondition, &litter.InitialAliveCount,
		&litter.InitialOtherCount, &litter.DiscoveredCount, &litter.DeceasedCount,
		&litter.TransferredOutCount, &litter.CorrectionDelta, &litter.CurrentManagedCount,
		&litter.UnindividualizedAliveCount, &litter.IndividualizedAliveCount,
		&litter.WeanedAt, &litter.SexSeparatedAt, &litter.ReconciledAt, &litter.Notes,
		&litter.Version, &litter.CreatedAt, &litter.UpdatedAt)
	if err != nil {
		return Litter{}, err
	}
	litter.DamCondition = decodeMap(damCondition)
	return litter, nil
}

func scanWeight(row rowScanner) (WeightRecord, error) {
	var record WeightRecord
	var alerts []byte
	err := row.Scan(&record.ID, &record.OwnerID, &record.OrganizationID, &record.SubjectType,
		&record.HamsterID, &record.PupIdentityID, &record.LitterID, &record.MeasurementKind,
		&record.SubjectCount, &record.WeightG, &record.RecordedAt, &record.Source,
		&record.AcquisitionKey, &record.SpeciesRuleVersionID, &record.BirthWeightG,
		&record.PreviousWeightG, &record.ChangeFromBirthG, &record.ChangeFromPreviousG,
		&alerts, &record.OperatorID, &record.CorrectsWeightRecordID, &record.CorrectionReason,
		&record.CreatedAt)
	if err != nil {
		return WeightRecord{}, err
	}
	record.AlertFlags = decodeStrings(alerts)
	return record, nil
}

func scanParentage(row rowScanner) (PedigreeParentage, error) {
	var parentage PedigreeParentage
	var evidence []byte
	err := row.Scan(&parentage.ID, &parentage.OwnerID, &parentage.ParentID, &parentage.ChildID,
		&parentage.Role, &parentage.EvidenceType, &evidence, &parentage.Confidence,
		&parentage.Status, &parentage.ValidFrom, &parentage.ValidTo,
		&parentage.RelationshipAssertionID, &parentage.Version, &parentage.CreatedAt,
		&parentage.UpdatedAt)
	if err != nil {
		return PedigreeParentage{}, err
	}
	parentage.EvidencePayload = decodeMap(evidence)
	parentage.EvidenceType = publicPedigreeEvidence(parentage.EvidenceType)
	if note, ok := parentage.EvidencePayload["notes"].(string); ok && strings.TrimSpace(note) != "" {
		parentage.Notes = &note
	}
	return parentage, nil
}

func scanLitterParent(row rowScanner) (LitterParent, error) {
	var parent LitterParent
	var evidence []byte
	err := row.Scan(&parent.ID, &parent.OwnerID, &parent.LitterID, &parent.ParentID,
		&parent.Role, &parent.EvidenceType, &evidence, &parent.Confidence, &parent.Status,
		&parent.ValidFrom, &parent.ValidTo, &parent.CorrectsLitterParentID,
		&parent.CorrectionNote, &parent.Version, &parent.CreatedAt, &parent.UpdatedAt)
	if err != nil {
		return LitterParent{}, err
	}
	parent.EvidencePayload = decodeMap(evidence)
	parent.EvidenceType = publicLitterEvidence(parent.EvidenceType)
	return parent, nil
}

func scanLitterMember(row rowScanner) (LitterMember, error) {
	var item LitterMember
	err := row.Scan(&item.ID, &item.LitterID, &item.MemberType, &item.PupIdentityID, &item.HamsterID,
		&item.OriginPupIdentityID, &item.EvidenceType, &item.Confidence, &item.Status,
		&item.ValidFrom, &item.ValidTo, &item.Version)
	return item, err
}

func decodeMap(raw []byte) map[string]any {
	result := map[string]any{}
	if len(raw) > 0 {
		_ = json.Unmarshal(raw, &result)
	}
	return result
}

func decodeStrings(raw []byte) []string {
	result := []string{}
	if len(raw) > 0 {
		_ = json.Unmarshal(raw, &result)
	}
	return result
}

func publicPedigreeEvidence(value string) string {
	switch value {
	case "system":
		return "breeding_plan"
	case "litter_inferred":
		return "litter_derived"
	case "document":
		return "verified_document"
	default:
		return value
	}
}

func publicLitterEvidence(value string) string {
	switch value {
	case "system", "litter_inferred":
		return "breeding_plan"
	case "document":
		return "verified_document"
	default:
		return value
	}
}

func uniqueUUIDs(values []uuid.UUID) []uuid.UUID {
	seen := make(map[uuid.UUID]struct{}, len(values))
	result := make([]uuid.UUID, 0, len(values))
	for _, value := range values {
		if _, ok := seen[value]; ok {
			continue
		}
		seen[value] = struct{}{}
		result = append(result, value)
	}
	return result
}
