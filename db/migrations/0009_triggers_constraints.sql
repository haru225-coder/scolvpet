-- Generated from specs/database/schema.sql; do not edit this migration by hand.
BEGIN;

CREATE TABLE idempotency_record (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  idempotency_key varchar(200) NOT NULL,
  request_method varchar(12) NOT NULL,
  request_path varchar(500) NOT NULL,
  request_hash varchar(64) NOT NULL,
  status idempotency_status NOT NULL DEFAULT 'processing',
  resource_type varchar(80),
  resource_id uuid,
  response_status integer,
  response_body jsonb,
  locked_at timestamptz NOT NULL DEFAULT now(),
  completed_at timestamptz,
  expires_at timestamptz NOT NULL,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_idempotency_record_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT uq_idempotency_record_key UNIQUE (owner_id, idempotency_key),
  CONSTRAINT ck_idempotency_record_response CHECK (
    status = 'processing' OR response_status IS NOT NULL
  ),
  CONSTRAINT ck_idempotency_record_expiry CHECK (expires_at > created_at)
);

CREATE INDEX ix_idempotency_record_expiry
  ON idempotency_record (expires_at);

-- ---------------------------------------------------------------------------
-- 通用审计、乐观锁与不可变事实
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION bump_row_version()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.version := OLD.version + 1;
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;

DO $$
DECLARE
  target_table text;
BEGIN
  FOREACH target_table IN ARRAY ARRAY[
    'account', 'organization', 'species_rule_version', 'outbox_message',
    'async_job', 'media_asset', 'media_variant', 'enclosure', 'hamster',
    'breeding_plan', 'pairing_attempt', 'enclosure_stay', 'mating_observation',
    'litter', 'pup_identity', 'relationship_assertion', 'pedigree_parentage',
    'litter_parent', 'litter_member', 'care_task', 'care_task_subject',
    'reminder_delivery', 'media_link', 'share_page', 'import_job', 'import_row',
    'export_job', 'backup_job', 'entitlement', 'usage_meter', 'idempotency_record'
  ]
  LOOP
    EXECUTE format(
      'CREATE TRIGGER %I BEFORE UPDATE ON %I FOR EACH ROW EXECUTE FUNCTION bump_row_version()',
      'trg_' || target_table || '_version',
      target_table
    );
  END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION reject_fact_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  RAISE EXCEPTION USING
    ERRCODE = '55000',
    MESSAGE = format('%I is append-only; write a correction fact instead', TG_TABLE_NAME);
END;
$$;

CREATE TRIGGER trg_domain_event_immutable
  BEFORE UPDATE OR DELETE ON domain_event
  FOR EACH ROW EXECUTE FUNCTION reject_fact_mutation();

CREATE TRIGGER trg_litter_count_event_immutable
  BEFORE UPDATE OR DELETE ON litter_count_event
  FOR EACH ROW EXECUTE FUNCTION reject_fact_mutation();

CREATE TRIGGER trg_weight_record_immutable
  BEFORE UPDATE OR DELETE ON weight_record
  FOR EACH ROW EXECUTE FUNCTION reject_fact_mutation();

CREATE TRIGGER trg_health_record_immutable
  BEFORE UPDATE OR DELETE ON health_record
  FOR EACH ROW EXECUTE FUNCTION reject_fact_mutation();

CREATE TRIGGER trg_enclosure_cleaning_record_immutable
  BEFORE UPDATE OR DELETE ON enclosure_cleaning_record
  FOR EACH ROW EXECUTE FUNCTION reject_fact_mutation();

CREATE TRIGGER trg_import_issue_immutable
  BEFORE UPDATE OR DELETE ON import_issue
  FOR EACH ROW EXECUTE FUNCTION reject_fact_mutation();

CREATE TRIGGER trg_usage_snapshot_immutable
  BEFORE UPDATE OR DELETE ON usage_snapshot
  FOR EACH ROW EXECUTE FUNCTION reject_fact_mutation();

-- ---------------------------------------------------------------------------
-- 系统/舍主规则版本归属
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION validate_species_rule_owner()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  rule_owner uuid;
  rule_scope dictionary_scope;
BEGIN
  IF NEW.species_rule_version_id IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT owner_id, scope
    INTO rule_owner, rule_scope
  FROM species_rule_version
  WHERE id = NEW.species_rule_version_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION USING ERRCODE = '23503', MESSAGE = 'species rule version not found';
  END IF;

  IF rule_scope = 'owner' AND rule_owner IS DISTINCT FROM NEW.owner_id THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'owner rule belongs to another owner';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_hamster_species_rule_owner
  BEFORE INSERT OR UPDATE OF owner_id, species_rule_version_id ON hamster
  FOR EACH ROW EXECUTE FUNCTION validate_species_rule_owner();

CREATE TRIGGER trg_breeding_plan_species_rule_owner
  BEFORE INSERT OR UPDATE OF owner_id, species_rule_version_id ON breeding_plan
  FOR EACH ROW EXECUTE FUNCTION validate_species_rule_owner();

CREATE TRIGGER trg_weight_record_species_rule_owner
  BEFORE INSERT ON weight_record
  FOR EACH ROW EXECUTE FUNCTION validate_species_rule_owner();

CREATE OR REPLACE FUNCTION validate_species_rule_copy_owner()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  source_owner uuid;
  source_scope dictionary_scope;
BEGIN
  IF NEW.copied_from_id IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT owner_id, scope INTO source_owner, source_scope
  FROM species_rule_version
  WHERE id = NEW.copied_from_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION USING ERRCODE = '23503', MESSAGE = 'copied species rule version not found';
  END IF;

  IF NEW.scope <> 'owner' OR NEW.owner_id IS NULL THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'only owner rules may copy another rule version';
  END IF;

  IF source_scope = 'owner' AND source_owner IS DISTINCT FROM NEW.owner_id THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'cannot copy another owner species rule';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_species_rule_copy_owner
  BEFORE INSERT OR UPDATE OF owner_id, scope, copied_from_id ON species_rule_version
  FOR EACH ROW EXECUTE FUNCTION validate_species_rule_copy_owner();

-- ---------------------------------------------------------------------------
-- 多态目标的 owner_id 一致性
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION owned_target_exists(
  p_owner_id uuid,
  p_target_type text,
  p_target_id uuid
)
RETURNS boolean
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  found_target boolean;
BEGIN
  CASE p_target_type
    WHEN 'organization' THEN
      SELECT EXISTS (SELECT 1 FROM organization WHERE owner_id = p_owner_id AND id = p_target_id)
        INTO found_target;
    WHEN 'hamster' THEN
      SELECT EXISTS (SELECT 1 FROM hamster WHERE owner_id = p_owner_id AND id = p_target_id)
        INTO found_target;
    WHEN 'litter' THEN
      SELECT EXISTS (SELECT 1 FROM litter WHERE owner_id = p_owner_id AND id = p_target_id)
        INTO found_target;
    WHEN 'enclosure' THEN
      SELECT EXISTS (SELECT 1 FROM enclosure WHERE owner_id = p_owner_id AND id = p_target_id)
        INTO found_target;
    WHEN 'breeding_plan' THEN
      SELECT EXISTS (SELECT 1 FROM breeding_plan WHERE owner_id = p_owner_id AND id = p_target_id)
        INTO found_target;
    WHEN 'pairing_attempt' THEN
      SELECT EXISTS (SELECT 1 FROM pairing_attempt WHERE owner_id = p_owner_id AND id = p_target_id)
        INTO found_target;
    WHEN 'pup_identity' THEN
      SELECT EXISTS (SELECT 1 FROM pup_identity WHERE owner_id = p_owner_id AND id = p_target_id)
        INTO found_target;
    WHEN 'health_record' THEN
      SELECT EXISTS (SELECT 1 FROM health_record WHERE owner_id = p_owner_id AND id = p_target_id)
        INTO found_target;
    WHEN 'mating_observation' THEN
      SELECT EXISTS (SELECT 1 FROM mating_observation WHERE owner_id = p_owner_id AND id = p_target_id)
        INTO found_target;
    WHEN 'domain_event' THEN
      SELECT EXISTS (SELECT 1 FROM domain_event WHERE owner_id = p_owner_id AND id = p_target_id)
        INTO found_target;
    WHEN 'share_page' THEN
      SELECT EXISTS (SELECT 1 FROM share_page WHERE owner_id = p_owner_id AND id = p_target_id)
        INTO found_target;
    WHEN 'weight_record' THEN
      SELECT EXISTS (SELECT 1 FROM weight_record WHERE owner_id = p_owner_id AND id = p_target_id)
        INTO found_target;
    WHEN 'relationship_assertion' THEN
      SELECT EXISTS (SELECT 1 FROM relationship_assertion WHERE owner_id = p_owner_id AND id = p_target_id)
        INTO found_target;
    ELSE
      found_target := false;
  END CASE;

  RETURN COALESCE(found_target, false);
END;
$$;

CREATE OR REPLACE FUNCTION validate_relationship_assertion_targets()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.subject_type <> 'external_reference'
    AND NOT owned_target_exists(NEW.owner_id, NEW.subject_type::text, NEW.subject_id) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'relationship assertion subject is outside owner scope or missing';
  END IF;

  IF NEW.related_type <> 'external_reference'
    AND NOT owned_target_exists(NEW.owner_id, NEW.related_type::text, NEW.related_id) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'relationship assertion related target is outside owner scope or missing';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_relationship_assertion_targets
  BEFORE INSERT OR UPDATE OF owner_id, subject_type, subject_id, related_type, related_id
  ON relationship_assertion
  FOR EACH ROW EXECUTE FUNCTION validate_relationship_assertion_targets();

CREATE OR REPLACE FUNCTION validate_care_task_target()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NOT owned_target_exists(NEW.owner_id, NEW.target_type::text, NEW.target_id) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'care task target is outside owner scope or missing';
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_care_task_target_owner
  BEFORE INSERT OR UPDATE OF owner_id, target_type, target_id ON care_task
  FOR EACH ROW EXECUTE FUNCTION validate_care_task_target();

CREATE OR REPLACE FUNCTION validate_care_task_subject_target()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NOT owned_target_exists(NEW.owner_id, NEW.subject_type::text, NEW.subject_id) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'care task subject is outside owner scope or missing';
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_care_task_subject_owner
  BEFORE INSERT OR UPDATE OF owner_id, subject_type, subject_id ON care_task_subject
  FOR EACH ROW EXECUTE FUNCTION validate_care_task_subject_target();

CREATE OR REPLACE FUNCTION validate_media_link_target()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  variant_asset_id uuid;
BEGIN
  IF NOT owned_target_exists(NEW.owner_id, NEW.target_type::text, NEW.target_id) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'media target is outside owner scope or missing';
  END IF;

  IF NEW.media_variant_id IS NOT NULL THEN
    SELECT media_asset_id INTO variant_asset_id
    FROM media_variant
    WHERE owner_id = NEW.owner_id AND id = NEW.media_variant_id;

    IF variant_asset_id IS DISTINCT FROM NEW.media_asset_id THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'media variant does not belong to media asset';
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_media_link_target_owner
  BEFORE INSERT OR UPDATE OF owner_id, target_type, target_id, media_asset_id, media_variant_id
  ON media_link
  FOR EACH ROW EXECUTE FUNCTION validate_media_link_target();

CREATE OR REPLACE FUNCTION validate_share_page_target()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NOT owned_target_exists(NEW.owner_id, NEW.target_type::text, NEW.target_id) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'share target is outside owner scope or missing';
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_share_page_target_owner
  BEFORE INSERT OR UPDATE OF owner_id, target_type, target_id ON share_page
  FOR EACH ROW EXECUTE FUNCTION validate_share_page_target();

-- ---------------------------------------------------------------------------
-- 配对与笼盒并发约束
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION validate_pairing_attempt_participants()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  plan_sire uuid;
  plan_dam uuid;
BEGIN
  SELECT sire_id, dam_id
    INTO plan_sire, plan_dam
  FROM breeding_plan
  WHERE owner_id = NEW.owner_id AND id = NEW.breeding_plan_id;

  IF plan_sire IS DISTINCT FROM NEW.sire_id OR plan_dam IS DISTINCT FROM NEW.dam_id THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'pairing participants must match breeding plan parents';
  END IF;

  PERFORM 1
  FROM hamster
  WHERE owner_id = NEW.owner_id AND id IN (NEW.sire_id, NEW.dam_id)
  ORDER BY id
  FOR UPDATE;

  IF NEW.status IN ('active', 'safety_hold') AND EXISTS (
    SELECT 1
    FROM pairing_attempt pa
    WHERE pa.owner_id = NEW.owner_id
      AND pa.id <> NEW.id
      AND pa.deleted_at IS NULL
      AND pa.status IN ('active', 'safety_hold')
      AND (
        pa.sire_id IN (NEW.sire_id, NEW.dam_id)
        OR pa.dam_id IN (NEW.sire_id, NEW.dam_id)
      )
  ) THEN
    RAISE EXCEPTION USING ERRCODE = '23P01', MESSAGE = 'hamster already participates in another active pairing attempt';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_pairing_attempt_participants
  BEFORE INSERT OR UPDATE OF owner_id, breeding_plan_id, sire_id, dam_id, status
  ON pairing_attempt
  FOR EACH ROW EXECUTE FUNCTION validate_pairing_attempt_participants();

CREATE OR REPLACE FUNCTION validate_enclosure_stay_period()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  enclosure_capacity integer;
  overlapping_count integer;
  pairing_record pairing_attempt%ROWTYPE;
BEGIN
  IF NEW.deleted_at IS NOT NULL THEN
    RETURN NEW;
  END IF;

  SELECT capacity INTO enclosure_capacity
  FROM enclosure
  WHERE owner_id = NEW.owner_id AND id = NEW.enclosure_id
  FOR UPDATE;

  PERFORM 1 FROM hamster
  WHERE owner_id = NEW.owner_id AND id = NEW.hamster_id
  FOR UPDATE;

  IF EXISTS (
    SELECT 1
    FROM enclosure_stay es
    WHERE es.owner_id = NEW.owner_id
      AND es.hamster_id = NEW.hamster_id
      AND es.id <> NEW.id
      AND es.deleted_at IS NULL
      AND tstzrange(es.started_at, es.ended_at, '[)')
          && tstzrange(NEW.started_at, NEW.ended_at, '[)')
  ) THEN
    RAISE EXCEPTION USING ERRCODE = '23P01', MESSAGE = 'hamster has an overlapping enclosure stay';
  END IF;

  SELECT count(*) INTO overlapping_count
  FROM enclosure_stay es
  WHERE es.owner_id = NEW.owner_id
    AND es.enclosure_id = NEW.enclosure_id
    AND es.id <> NEW.id
    AND es.deleted_at IS NULL
    AND tstzrange(es.started_at, es.ended_at, '[)')
        && tstzrange(NEW.started_at, NEW.ended_at, '[)');

  IF NEW.purpose = 'pairing_temp' THEN
    SELECT * INTO pairing_record
    FROM pairing_attempt
    WHERE owner_id = NEW.owner_id AND id = NEW.pairing_attempt_id
    FOR UPDATE;

    IF pairing_record.id IS NULL
      OR pairing_record.pairing_enclosure_id <> NEW.enclosure_id
      OR NEW.hamster_id NOT IN (pairing_record.sire_id, pairing_record.dam_id)
      OR pairing_record.status NOT IN ('active', 'safety_hold') THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'pairing stay is not authorized by an active pairing attempt';
    END IF;

    IF EXISTS (
      SELECT 1
      FROM enclosure_stay es
      WHERE es.owner_id = NEW.owner_id
        AND es.enclosure_id = NEW.enclosure_id
        AND es.id <> NEW.id
        AND es.deleted_at IS NULL
        AND tstzrange(es.started_at, es.ended_at, '[)')
            && tstzrange(NEW.started_at, NEW.ended_at, '[)')
        AND (es.purpose <> 'pairing_temp' OR es.pairing_attempt_id <> NEW.pairing_attempt_id)
    ) THEN
      RAISE EXCEPTION USING ERRCODE = '23P01', MESSAGE = 'pairing enclosure overlaps another occupancy';
    END IF;

    IF overlapping_count >= LEAST(enclosure_capacity, 2) THEN
      RAISE EXCEPTION USING ERRCODE = '23P01', MESSAGE = 'pairing enclosure capacity exceeded';
    END IF;
  ELSIF overlapping_count > 0 THEN
    RAISE EXCEPTION USING ERRCODE = '23P01', MESSAGE = 'enclosure has an overlapping occupancy';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_enclosure_stay_period
  BEFORE INSERT OR UPDATE OF owner_id, enclosure_id, hamster_id, pairing_attempt_id,
    purpose, started_at, ended_at, deleted_at
  ON enclosure_stay
  FOR EACH ROW EXECUTE FUNCTION validate_enclosure_stay_period();

-- ---------------------------------------------------------------------------
-- 谱系循环、关系纠正与个体化一致性
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION validate_breeding_plan_parents()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  sire_record hamster%ROWTYPE;
  dam_record hamster%ROWTYPE;
BEGIN
  SELECT * INTO sire_record
  FROM hamster
  WHERE owner_id = NEW.owner_id AND id = NEW.sire_id;

  SELECT * INTO dam_record
  FROM hamster
  WHERE owner_id = NEW.owner_id AND id = NEW.dam_id;

  IF sire_record.id IS NULL OR dam_record.id IS NULL THEN
    RAISE EXCEPTION USING ERRCODE = '23503', MESSAGE = 'breeding plan parent not found in owner scope';
  END IF;

  IF sire_record.organization_id <> NEW.organization_id
    OR dam_record.organization_id <> NEW.organization_id THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'breeding plan parents must belong to plan organization';
  END IF;

  IF NEW.state <> 'draft' THEN
    IF sire_record.sex = 'female' OR dam_record.sex = 'male' THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'breeding plan parent sex conflicts with sire/dam role';
    END IF;

    IF (sire_record.sex = 'unknown' OR dam_record.sex = 'unknown')
      AND NULLIF(btrim(NEW.eligibility_override_reason), '') IS NULL THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'unknown parent sex requires an explicit eligibility override reason';
    END IF;

    IF sire_record.lifecycle_status <> 'active' OR dam_record.lifecycle_status <> 'active' THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'breeding plan parents must be active';
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_breeding_plan_parent_guard
  BEFORE INSERT OR UPDATE OF owner_id, organization_id, sire_id, dam_id, state,
    eligibility_override_reason
  ON breeding_plan
  FOR EACH ROW EXECUTE FUNCTION validate_breeding_plan_parents();

CREATE OR REPLACE FUNCTION prevent_pedigree_cycle()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.status <> 'accepted' OR NEW.valid_to IS NOT NULL THEN
    RETURN NEW;
  END IF;

  IF NEW.parent_id = NEW.child_id THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'pedigree parent cannot equal child';
  END IF;

  IF EXISTS (
    WITH RECURSIVE descendants(hamster_id) AS (
      SELECT pp.child_id
      FROM pedigree_parentage pp
      WHERE pp.owner_id = NEW.owner_id
        AND pp.parent_id = NEW.child_id
        AND pp.status = 'accepted'
        AND pp.valid_to IS NULL
        AND pp.id <> NEW.id
      UNION
      SELECT pp.child_id
      FROM pedigree_parentage pp
      JOIN descendants d ON pp.parent_id = d.hamster_id
      WHERE pp.owner_id = NEW.owner_id
        AND pp.status = 'accepted'
        AND pp.valid_to IS NULL
        AND pp.id <> NEW.id
    )
    SELECT 1 FROM descendants WHERE hamster_id = NEW.parent_id
  ) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'pedigree cycle detected';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_pedigree_parentage_cycle
  BEFORE INSERT OR UPDATE OF owner_id, parent_id, child_id, status, valid_to
  ON pedigree_parentage
  FOR EACH ROW EXECUTE FUNCTION prevent_pedigree_cycle();

CREATE OR REPLACE FUNCTION validate_litter_parent_role()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  litter_record litter%ROWTYPE;
  parent_sex sex_code;
  expected_parent_id uuid;
BEGIN
  SELECT * INTO litter_record
  FROM litter
  WHERE owner_id = NEW.owner_id AND id = NEW.litter_id;

  SELECT sex INTO parent_sex
  FROM hamster
  WHERE owner_id = NEW.owner_id AND id = NEW.parent_id;

  IF litter_record.id IS NULL OR parent_sex IS NULL THEN
    RAISE EXCEPTION USING ERRCODE = '23503', MESSAGE = 'litter or parent not found in owner scope';
  END IF;

  IF (NEW.role = 'sire' AND parent_sex = 'female')
    OR (NEW.role = 'dam' AND parent_sex = 'male') THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'litter parent sex conflicts with sire/dam role';
  END IF;

  IF parent_sex = 'unknown'
    AND NOT (NEW.evidence_payload @> '{"sex_role_reviewed": true}'::jsonb) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'unknown litter parent sex requires sex_role_reviewed evidence';
  END IF;

  IF litter_record.origin = 'breeding' THEN
    SELECT CASE NEW.role WHEN 'sire' THEN sire_id ELSE dam_id END
      INTO expected_parent_id
    FROM breeding_plan
    WHERE owner_id = NEW.owner_id AND id = litter_record.breeding_plan_id;

    IF expected_parent_id IS DISTINCT FROM NEW.parent_id THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'breeding litter parent must match breeding plan parent';
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_litter_parent_role
  BEFORE INSERT OR UPDATE OF owner_id, litter_id, parent_id, role, evidence_payload
  ON litter_parent
  FOR EACH ROW EXECUTE FUNCTION validate_litter_parent_role();

CREATE OR REPLACE FUNCTION validate_litter_member_consistency()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  member_litter_id uuid;
  member_litter_origin litter_origin;
BEGIN
  SELECT origin INTO member_litter_origin
  FROM litter
  WHERE owner_id = NEW.owner_id AND id = NEW.litter_id;

  IF member_litter_origin IS NULL THEN
    RAISE EXCEPTION USING ERRCODE = '23503', MESSAGE = 'litter member litter not found in owner scope';
  END IF;

  IF NEW.pup_identity_id IS NOT NULL THEN
    SELECT litter_id INTO member_litter_id
    FROM pup_identity
    WHERE owner_id = NEW.owner_id AND id = NEW.pup_identity_id;

    IF member_litter_id IS DISTINCT FROM NEW.litter_id THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'pup identity belongs to another litter';
    END IF;
  END IF;

  IF NEW.origin_pup_identity_id IS NOT NULL THEN
    SELECT litter_id INTO member_litter_id
    FROM pup_identity
    WHERE owner_id = NEW.owner_id AND id = NEW.origin_pup_identity_id;

    IF member_litter_id IS DISTINCT FROM NEW.litter_id THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'origin pup identity belongs to another litter';
    END IF;
  END IF;

  IF member_litter_origin = 'import'
    AND (NEW.member_type <> 'hamster' OR NEW.origin_pup_identity_id IS NOT NULL) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'imported historical litter accepts formal hamster members only';
  END IF;

  IF member_litter_origin = 'breeding'
    AND NEW.member_type = 'hamster'
    AND NEW.origin_pup_identity_id IS NULL THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'breeding litter hamster member requires origin pup identity';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_litter_member_consistency
  BEFORE INSERT OR UPDATE OF owner_id, litter_id, pup_identity_id, origin_pup_identity_id
  ON litter_member
  FOR EACH ROW EXECUTE FUNCTION validate_litter_member_consistency();

CREATE OR REPLACE FUNCTION validate_pup_individualization_transition()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  litter_record litter%ROWTYPE;
  hamster_record hamster%ROWTYPE;
  plan_rule_id uuid;
BEGIN
  IF TG_OP = 'UPDATE'
    AND OLD.profile_status = 'individualized'
    AND NEW.profile_status <> 'individualized' THEN
    RAISE EXCEPTION USING ERRCODE = '55000', MESSAGE = 'individualized pup identity cannot return to an unindividualized state';
  END IF;

  IF NEW.profile_status <> 'individualized'
    OR (TG_OP = 'UPDATE' AND OLD.profile_status = 'individualized') THEN
    RETURN NEW;
  END IF;

  SELECT * INTO litter_record
  FROM litter
  WHERE owner_id = NEW.owner_id AND id = NEW.litter_id;

  SELECT * INTO hamster_record
  FROM hamster
  WHERE owner_id = NEW.owner_id AND id = NEW.individualized_hamster_id;

  IF litter_record.id IS NULL OR hamster_record.id IS NULL THEN
    RAISE EXCEPTION USING ERRCODE = '23503', MESSAGE = 'individualization litter or hamster not found in owner scope';
  END IF;

  IF litter_record.origin <> 'breeding' OR litter_record.state <> 'individualizing' THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'pup identities may be individualized only in an individualizing breeding litter';
  END IF;

  IF NEW.outcome_status <> 'alive' OR NEW.weaned_at IS NULL
    OR NEW.sex = 'unknown' OR NEW.current_enclosure_id IS NULL
    OR litter_record.sex_separation_completed_at IS NULL THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'pup identity is not eligible for individualization';
  END IF;

  IF hamster_record.organization_id <> litter_record.organization_id
    OR hamster_record.sex <> NEW.sex
    OR hamster_record.current_enclosure_id IS DISTINCT FROM NEW.current_enclosure_id
    OR hamster_record.source_type <> 'born_here' THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'individualized hamster does not match pup identity facts';
  END IF;

  IF litter_record.born_at IS NOT NULL
    AND hamster_record.birth_date IS DISTINCT FROM litter_record.born_at::date THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'individualized hamster birth date must match litter';
  END IF;

  SELECT species_rule_version_id INTO plan_rule_id
  FROM breeding_plan
  WHERE owner_id = NEW.owner_id AND id = litter_record.breeding_plan_id;

  IF hamster_record.species_rule_version_id IS DISTINCT FROM plan_rule_id THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'individualized hamster species rule must match breeding plan snapshot';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_pup_identity_individualization_guard
  BEFORE INSERT OR UPDATE OF owner_id, litter_id, profile_status, outcome_status,
    weaned_at, sex, current_enclosure_id, individualized_hamster_id
  ON pup_identity
  FOR EACH ROW EXECUTE FUNCTION validate_pup_individualization_transition();

CREATE OR REPLACE FUNCTION prevent_pup_identity_rekey()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.owner_id <> OLD.owner_id
    OR NEW.litter_id <> OLD.litter_id
    OR NEW.temporary_code <> OLD.temporary_code THEN
    RAISE EXCEPTION USING ERRCODE = '55000', MESSAGE = 'pup identity owner, litter and temporary code are immutable';
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_pup_identity_rekey
  BEFORE UPDATE ON pup_identity
  FOR EACH ROW EXECUTE FUNCTION prevent_pup_identity_rekey();

CREATE OR REPLACE FUNCTION reject_pup_identity_delete()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  RAISE EXCEPTION USING ERRCODE = '55000', MESSAGE = 'pup identity cannot be hard-deleted; use voided status and correction event';
END;
$$;

CREATE TRIGGER trg_pup_identity_no_delete
  BEFORE DELETE ON pup_identity
  FOR EACH ROW EXECUTE FUNCTION reject_pup_identity_delete();

-- ---------------------------------------------------------------------------
-- 窝次数量流水与身份闭合
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION refresh_litter_count_cache(p_litter_id uuid)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  v_initial integer;
  v_discovered integer;
  v_deceased integer;
  v_transferred integer;
  v_correction integer;
  v_unindividualized integer;
  v_individualized integer;
  v_imported_formal integer;
  v_current integer;
BEGIN
  SELECT
    COALESCE(sum(delta) FILTER (WHERE event_type = 'initial_alive'), 0)::integer,
    COALESCE(sum(delta) FILTER (WHERE event_type = 'discovered'), 0)::integer,
    COALESCE(-sum(delta) FILTER (WHERE event_type = 'death'), 0)::integer,
    COALESCE(-sum(delta) FILTER (WHERE event_type = 'transferred_out'), 0)::integer,
    COALESCE(sum(delta) FILTER (WHERE event_type = 'correction'), 0)::integer
  INTO v_initial, v_discovered, v_deceased, v_transferred, v_correction
  FROM litter_count_event
  WHERE litter_id = p_litter_id;

  SELECT
    count(*) FILTER (
      WHERE profile_status = 'unindividualized' AND outcome_status = 'alive'
    )::integer,
    count(*) FILTER (
      WHERE profile_status = 'individualized' AND outcome_status = 'alive'
    )::integer
  INTO v_unindividualized, v_individualized
  FROM pup_identity
  WHERE litter_id = p_litter_id AND deleted_at IS NULL;

  SELECT count(*)::integer INTO v_imported_formal
  FROM litter_member
  WHERE litter_id = p_litter_id
    AND member_type = 'hamster'
    AND origin_pup_identity_id IS NULL
    AND status = 'accepted'
    AND valid_to IS NULL;

  v_individualized := v_individualized + v_imported_formal;

  v_current := v_initial + v_discovered - v_deceased - v_transferred + v_correction;

  IF v_current < 0 THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'litter managed count cannot be negative';
  END IF;

  UPDATE litter
  SET initial_alive_count = v_initial,
      discovered_count = v_discovered,
      deceased_count = v_deceased,
      transferred_out_count = v_transferred,
      correction_delta = v_correction,
      current_managed_count = v_current,
      unindividualized_alive_count = v_unindividualized,
      individualized_alive_count = v_individualized
  WHERE id = p_litter_id;
END;
$$;

CREATE OR REPLACE FUNCTION refresh_litter_count_cache_trigger()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  new_litter_id uuid;
  old_litter_id uuid;
BEGIN
  IF TG_OP <> 'DELETE' THEN
    new_litter_id := NEW.litter_id;
    PERFORM refresh_litter_count_cache(new_litter_id);
  END IF;

  IF TG_OP <> 'INSERT' THEN
    old_litter_id := OLD.litter_id;
    IF old_litter_id IS DISTINCT FROM new_litter_id THEN
      PERFORM refresh_litter_count_cache(old_litter_id);
    END IF;
  END IF;

  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_litter_count_event_refresh
  AFTER INSERT ON litter_count_event
  FOR EACH ROW EXECUTE FUNCTION refresh_litter_count_cache_trigger();

CREATE TRIGGER trg_pup_identity_count_refresh
  AFTER INSERT OR UPDATE ON pup_identity
  FOR EACH ROW EXECUTE FUNCTION refresh_litter_count_cache_trigger();

CREATE TRIGGER trg_litter_member_count_refresh
  AFTER INSERT OR UPDATE OR DELETE ON litter_member
  FOR EACH ROW EXECUTE FUNCTION refresh_litter_count_cache_trigger();

CREATE OR REPLACE FUNCTION assert_litter_balance(p_litter_id uuid)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  litter_record litter%ROWTYPE;
  v_initial_event_count integer;
  v_initial integer;
  v_discovered integer;
  v_deceased integer;
  v_transferred integer;
  v_correction integer;
  v_expected integer;
  v_unindividualized integer;
  v_individualized integer;
  v_imported_formal integer;
  v_parent_roles integer;
  v_parent_count integer;
BEGIN
  SELECT * INTO litter_record FROM litter WHERE id = p_litter_id;
  IF NOT FOUND OR litter_record.state = 'voided' OR litter_record.deleted_at IS NOT NULL THEN
    RETURN;
  END IF;

  SELECT
    count(*) FILTER (WHERE event_type = 'initial_alive')::integer,
    COALESCE(sum(delta) FILTER (WHERE event_type = 'initial_alive'), 0)::integer,
    COALESCE(sum(delta) FILTER (WHERE event_type = 'discovered'), 0)::integer,
    COALESCE(-sum(delta) FILTER (WHERE event_type = 'death'), 0)::integer,
    COALESCE(-sum(delta) FILTER (WHERE event_type = 'transferred_out'), 0)::integer,
    COALESCE(sum(delta) FILTER (WHERE event_type = 'correction'), 0)::integer
  INTO v_initial_event_count, v_initial, v_discovered, v_deceased, v_transferred, v_correction
  FROM litter_count_event
  WHERE owner_id = litter_record.owner_id AND litter_id = p_litter_id;

  IF v_initial_event_count <> 1 THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'effective litter must have exactly one initial_alive event';
  END IF;

  v_expected := v_initial + v_discovered - v_deceased - v_transferred + v_correction;

  SELECT
    count(*) FILTER (
      WHERE profile_status = 'unindividualized' AND outcome_status = 'alive'
    )::integer,
    count(*) FILTER (
      WHERE profile_status = 'individualized' AND outcome_status = 'alive'
    )::integer
  INTO v_unindividualized, v_individualized
  FROM pup_identity
  WHERE owner_id = litter_record.owner_id
    AND litter_id = p_litter_id
    AND deleted_at IS NULL;

  SELECT count(*)::integer INTO v_imported_formal
  FROM litter_member
  WHERE owner_id = litter_record.owner_id
    AND litter_id = p_litter_id
    AND member_type = 'hamster'
    AND origin_pup_identity_id IS NULL
    AND status = 'accepted'
    AND valid_to IS NULL;

  v_individualized := v_individualized + v_imported_formal;

  IF v_initial <= 0 THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'effective litter initial_alive count must be greater than zero';
  END IF;

  IF v_expected < 0 OR v_expected <> v_unindividualized + v_individualized THEN
    RAISE EXCEPTION USING
      ERRCODE = '23514',
      MESSAGE = format(
        'litter count mismatch: expected=%s, unindividualized=%s, individualized=%s',
        v_expected, v_unindividualized, v_individualized
      );
  END IF;

  IF litter_record.origin = 'breeding' AND v_imported_formal > 0 THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'breeding litter formal members require origin pup identities';
  END IF;

  IF litter_record.origin = 'import' AND EXISTS (
    SELECT 1 FROM pup_identity
    WHERE owner_id = litter_record.owner_id
      AND litter_id = p_litter_id
      AND deleted_at IS NULL
  ) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'imported historical litter cannot contain pup identities';
  END IF;

  IF litter_record.origin = 'breeding'
    AND v_unindividualized > 0 AND v_individualized > 0 THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'partial individualization is not supported';
  END IF;

  IF litter_record.initial_alive_count <> v_initial
    OR litter_record.discovered_count <> v_discovered
    OR litter_record.deceased_count <> v_deceased
    OR litter_record.transferred_out_count <> v_transferred
    OR litter_record.correction_delta <> v_correction
    OR litter_record.current_managed_count <> v_expected
    OR litter_record.unindividualized_alive_count <> v_unindividualized
    OR litter_record.individualized_alive_count <> v_individualized THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'litter count cache is inconsistent with immutable facts';
  END IF;

  SELECT count(DISTINCT role)::integer, count(DISTINCT parent_id)::integer
    INTO v_parent_roles, v_parent_count
  FROM litter_parent
  WHERE owner_id = litter_record.owner_id
    AND litter_id = p_litter_id
    AND status = 'accepted'
    AND valid_to IS NULL;

  IF v_parent_roles <> 2 OR v_parent_count <> 2 THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'effective litter must have distinct active sire and dam relationships';
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION deferred_assert_litter_balance()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  target_litter_id uuid;
BEGIN
  IF TG_TABLE_NAME = 'litter' THEN
    target_litter_id := COALESCE(NEW.id, OLD.id);
  ELSE
    target_litter_id := COALESCE(NEW.litter_id, OLD.litter_id);
  END IF;

  PERFORM assert_litter_balance(target_litter_id);
  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  END IF;
  RETURN NEW;
END;
$$;

CREATE CONSTRAINT TRIGGER trg_litter_balance_litter
  AFTER INSERT OR UPDATE ON litter
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION deferred_assert_litter_balance();

CREATE CONSTRAINT TRIGGER trg_litter_balance_event
  AFTER INSERT ON litter_count_event
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION deferred_assert_litter_balance();

CREATE CONSTRAINT TRIGGER trg_litter_balance_pup
  AFTER INSERT OR UPDATE ON pup_identity
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION deferred_assert_litter_balance();

CREATE CONSTRAINT TRIGGER trg_litter_balance_parent
  AFTER INSERT OR UPDATE OR DELETE ON litter_parent
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION deferred_assert_litter_balance();

CREATE OR REPLACE FUNCTION assert_pup_identity_links(p_pup_identity_id uuid)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  pup_record pup_identity%ROWTYPE;
  missing_parent_count integer;
BEGIN
  SELECT * INTO pup_record
  FROM pup_identity
  WHERE id = p_pup_identity_id;

  IF NOT FOUND OR pup_record.deleted_at IS NOT NULL OR pup_record.profile_status = 'voided' THEN
    RETURN;
  END IF;

  IF pup_record.profile_status = 'unindividualized'
    AND pup_record.outcome_status = 'alive'
    AND NOT EXISTS (
      SELECT 1 FROM litter_member lm
      WHERE lm.owner_id = pup_record.owner_id
        AND lm.litter_id = pup_record.litter_id
        AND lm.member_type = 'pup_identity'
        AND lm.pup_identity_id = pup_record.id
        AND lm.status = 'accepted'
        AND lm.valid_to IS NULL
    ) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'living unindividualized pup requires an active litter membership';
  END IF;

  IF pup_record.profile_status = 'individualized' THEN
    IF EXISTS (
      SELECT 1 FROM litter_member lm
      WHERE lm.owner_id = pup_record.owner_id
        AND lm.litter_id = pup_record.litter_id
        AND lm.member_type = 'pup_identity'
        AND lm.pup_identity_id = pup_record.id
        AND lm.status = 'accepted'
        AND lm.valid_to IS NULL
    ) THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'individualized pup cannot retain an active temporary litter membership';
    END IF;

    IF NOT EXISTS (
      SELECT 1 FROM litter_member lm
      WHERE lm.owner_id = pup_record.owner_id
        AND lm.litter_id = pup_record.litter_id
        AND lm.member_type = 'hamster'
        AND lm.hamster_id = pup_record.individualized_hamster_id
        AND lm.origin_pup_identity_id = pup_record.id
        AND lm.status = 'accepted'
        AND lm.valid_to IS NULL
    ) THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'individualized pup requires a one-to-one hamster litter membership';
    END IF;

    SELECT count(*)::integer INTO missing_parent_count
    FROM litter_parent lp
    WHERE lp.owner_id = pup_record.owner_id
      AND lp.litter_id = pup_record.litter_id
      AND lp.status = 'accepted'
      AND lp.valid_to IS NULL
      AND NOT EXISTS (
        SELECT 1 FROM pedigree_parentage pp
        WHERE pp.owner_id = lp.owner_id
          AND pp.parent_id = lp.parent_id
          AND pp.child_id = pup_record.individualized_hamster_id
          AND pp.role = lp.role
          AND pp.status = 'accepted'
          AND pp.valid_to IS NULL
      );

    IF missing_parent_count > 0 THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'individualized hamster is missing inherited pedigree parentage';
    END IF;
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION deferred_assert_pup_links_from_pup()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  PERFORM assert_pup_identity_links(COALESCE(NEW.id, OLD.id));
  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  END IF;
  RETURN NEW;
END;
$$;

CREATE CONSTRAINT TRIGGER trg_pup_links_pup
  AFTER INSERT OR UPDATE ON pup_identity
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION deferred_assert_pup_links_from_pup();

CREATE OR REPLACE FUNCTION deferred_assert_pup_links_from_member()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  target_pup_id uuid;
BEGIN
  target_pup_id := COALESCE(
    NEW.pup_identity_id, NEW.origin_pup_identity_id,
    OLD.pup_identity_id, OLD.origin_pup_identity_id
  );
  IF target_pup_id IS NOT NULL THEN
    PERFORM assert_pup_identity_links(target_pup_id);
  END IF;
  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  END IF;
  RETURN NEW;
END;
$$;

CREATE CONSTRAINT TRIGGER trg_pup_links_member
  AFTER INSERT OR UPDATE OR DELETE ON litter_member
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION deferred_assert_pup_links_from_member();

CREATE OR REPLACE FUNCTION deferred_assert_pup_links_from_parentage()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  target_child_id uuid;
  target_pup_id uuid;
BEGIN
  target_child_id := COALESCE(NEW.child_id, OLD.child_id);
  SELECT id INTO target_pup_id
  FROM pup_identity
  WHERE owner_id = COALESCE(NEW.owner_id, OLD.owner_id)
    AND individualized_hamster_id = target_child_id
    AND deleted_at IS NULL;

  IF target_pup_id IS NOT NULL THEN
    PERFORM assert_pup_identity_links(target_pup_id);
  END IF;
  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  END IF;
  RETURN NEW;
END;
$$;

CREATE CONSTRAINT TRIGGER trg_pup_links_parentage
  AFTER INSERT OR UPDATE OR DELETE ON pedigree_parentage
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION deferred_assert_pup_links_from_parentage();

CREATE OR REPLACE FUNCTION deferred_assert_pup_links_from_litter_parent()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  target_litter_id uuid;
  pup_id uuid;
BEGIN
  target_litter_id := COALESCE(NEW.litter_id, OLD.litter_id);
  FOR pup_id IN
    SELECT id FROM pup_identity
    WHERE litter_id = target_litter_id
      AND profile_status = 'individualized'
      AND deleted_at IS NULL
  LOOP
    PERFORM assert_pup_identity_links(pup_id);
  END LOOP;
  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  END IF;
  RETURN NEW;
END;
$$;

CREATE CONSTRAINT TRIGGER trg_pup_links_litter_parent
  AFTER INSERT OR UPDATE OR DELETE ON litter_parent
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION deferred_assert_pup_links_from_litter_parent();

CREATE OR REPLACE FUNCTION validate_litter_count_event_context()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  litter_born_at timestamptz;
  pup_litter_id uuid;
BEGIN
  SELECT born_at INTO litter_born_at
  FROM litter
  WHERE owner_id = NEW.owner_id AND id = NEW.litter_id;

  IF NEW.occurred_at < litter_born_at THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'litter count event cannot occur before birth';
  END IF;

  IF NEW.pup_identity_id IS NOT NULL THEN
    SELECT litter_id INTO pup_litter_id
    FROM pup_identity
    WHERE owner_id = NEW.owner_id AND id = NEW.pup_identity_id;

    IF pup_litter_id IS DISTINCT FROM NEW.litter_id THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'count event pup identity belongs to another litter';
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_litter_count_event_context
  BEFORE INSERT ON litter_count_event
  FOR EACH ROW EXECUTE FUNCTION validate_litter_count_event_context();

-- N>0 与 N=0 生产结果在提交时必须形成互斥且完整的事实分支。
CREATE OR REPLACE FUNCTION assert_breeding_plan_birth_branch(p_plan_id uuid)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  plan_record breeding_plan%ROWTYPE;
  v_litter_count integer;
  v_litter_initial integer;
  v_litter_other integer;
  v_live_event_count integer;
  v_no_live_event_count integer;
BEGIN
  SELECT * INTO plan_record FROM breeding_plan WHERE id = p_plan_id;
  IF NOT FOUND OR plan_record.deleted_at IS NOT NULL THEN
    RETURN;
  END IF;

  SELECT count(*)::integer,
         COALESCE(max(initial_alive_count), 0)::integer,
         COALESCE(max(initial_other_count), 0)::integer
    INTO v_litter_count, v_litter_initial, v_litter_other
  FROM litter
  WHERE owner_id = plan_record.owner_id
    AND breeding_plan_id = p_plan_id
    AND state <> 'voided'
    AND deleted_at IS NULL;

  SELECT
    count(*) FILTER (WHERE event_type = 'BIRTH_CONFIRMED')::integer,
    count(*) FILTER (WHERE event_type = 'BIRTH_CONFIRMED_NO_LIVE_PUPS')::integer
    INTO v_live_event_count, v_no_live_event_count
  FROM domain_event
  WHERE owner_id = plan_record.owner_id
    AND aggregate_type = 'breeding_plan'
    AND aggregate_id = p_plan_id
    AND reverted_at IS NULL;

  IF plan_record.state = 'no_litter_outcome' THEN
    IF v_litter_count <> 0 OR v_live_event_count <> 0 OR v_no_live_event_count <> 1 THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'no_litter_outcome must have one no-live-pups event and no litter';
    END IF;
  ELSIF plan_record.state IN (
    'litter_nursing', 'weaning_due', 'sex_separation_due', 'individualizing', 'completed'
  ) OR v_litter_count > 0 OR v_live_event_count > 0 THEN
    IF v_litter_count <> 1 OR v_live_event_count <> 1 OR v_no_live_event_count <> 0
      OR plan_record.actual_birth_at IS NULL
      OR plan_record.birth_result_alive_count IS NULL
      OR plan_record.birth_result_alive_count <= 0
      OR plan_record.birth_result_alive_count <> v_litter_initial
      OR plan_record.birth_result_other_count IS DISTINCT FROM v_litter_other THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'live-birth branch must have one litter, one birth event and matching positive count';
    END IF;
  ELSIF v_no_live_event_count > 0 THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'no-live-pups event requires no_litter_outcome state';
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION deferred_assert_breeding_plan_birth_branch()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  target_plan_id uuid;
BEGIN
  IF TG_TABLE_NAME = 'breeding_plan' THEN
    target_plan_id := COALESCE(NEW.id, OLD.id);
  ELSIF TG_TABLE_NAME = 'litter' THEN
    target_plan_id := COALESCE(NEW.breeding_plan_id, OLD.breeding_plan_id);
  ELSIF COALESCE(NEW.aggregate_type, OLD.aggregate_type) = 'breeding_plan'
    AND COALESCE(NEW.event_type, OLD.event_type) IN ('BIRTH_CONFIRMED', 'BIRTH_CONFIRMED_NO_LIVE_PUPS') THEN
    target_plan_id := COALESCE(NEW.aggregate_id, OLD.aggregate_id);
  END IF;

  IF target_plan_id IS NOT NULL THEN
    PERFORM assert_breeding_plan_birth_branch(target_plan_id);
  END IF;
  IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
END;
$$;

CREATE CONSTRAINT TRIGGER trg_breeding_plan_birth_branch_plan
  AFTER INSERT OR UPDATE ON breeding_plan
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION deferred_assert_breeding_plan_birth_branch();

CREATE CONSTRAINT TRIGGER trg_breeding_plan_birth_branch_litter
  AFTER INSERT OR UPDATE OR DELETE ON litter
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION deferred_assert_breeding_plan_birth_branch();

CREATE CONSTRAINT TRIGGER trg_breeding_plan_birth_branch_event
  AFTER INSERT OR UPDATE OR DELETE ON domain_event
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION deferred_assert_breeding_plan_birth_branch();

-- 逐只任务的 stage_total/stage_done 是 care_task_subject 的缓存投影。
CREATE OR REPLACE FUNCTION refresh_care_task_progress(p_task_id uuid)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  v_total integer;
  v_done integer;
BEGIN
  SELECT count(*)::integer,
         count(*) FILTER (WHERE completed_at IS NOT NULL)::integer
    INTO v_total, v_done
  FROM care_task_subject
  WHERE care_task_id = p_task_id;

  UPDATE care_task
  SET stage_total = CASE WHEN v_total = 0 THEN NULL ELSE v_total END,
      stage_done = CASE WHEN v_total = 0 THEN NULL ELSE v_done END
  WHERE id = p_task_id;
END;
$$;

CREATE OR REPLACE FUNCTION refresh_care_task_progress_trigger()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  new_task_id uuid;
  old_task_id uuid;
BEGIN
  IF TG_OP <> 'DELETE' THEN
    new_task_id := NEW.care_task_id;
    PERFORM refresh_care_task_progress(new_task_id);
  END IF;

  IF TG_OP <> 'INSERT' THEN
    old_task_id := OLD.care_task_id;
    IF old_task_id IS DISTINCT FROM new_task_id THEN
      PERFORM refresh_care_task_progress(old_task_id);
    END IF;
  END IF;

  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_care_task_subject_progress
  AFTER INSERT OR UPDATE OR DELETE ON care_task_subject
  FOR EACH ROW EXECUTE FUNCTION refresh_care_task_progress_trigger();

CREATE INDEX ix_usage_snapshot_owner_time
  ON usage_snapshot (owner_id, snapshot_at DESC, metric);

CREATE INDEX ix_usage_meter_measured
  ON usage_meter (owner_id, measured_at DESC);

COMMENT ON TABLE pedigree_parentage IS
  '正式父母有向边；hamster 不保存 father_id/mother_id 作为唯一事实源。';
COMMENT ON TABLE relationship_assertion IS
  '导入或人工补录的关系断言；通过审核后投影为正式谱系/窝次关系。';
COMMENT ON TABLE litter_count_event IS
  '不可覆盖数量流水；initial/discovered 为正，death/transferred_out 为负，correction 为有原因的差值。';
COMMENT ON FUNCTION assert_litter_balance(uuid) IS
  '提交时验证 initial + discovered - death - transferred + correction = 未个体化存活 + 已个体化存活。';
COMMENT ON TABLE idempotency_record IS
  '通用写接口 Idempotency-Key 记录；相同 owner/key 复用首次响应。';
COMMENT ON COLUMN share_page.token_hash IS
  '仅保存随机公开令牌的摘要，原始令牌只在创建响应中返回一次。';

COMMIT;
