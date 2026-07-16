-- I2 incremental database hardening. Frozen migrations 0004-0009 remain unchanged.
BEGIN;

-- ---------------------------------------------------------------------------
-- Stable owner-scoped business keys and nonblank identifiers
-- ---------------------------------------------------------------------------

CREATE UNIQUE INDEX IF NOT EXISTS ux_hamster_owner_internal_code
  ON hamster (owner_id, internal_code);

CREATE UNIQUE INDEX IF NOT EXISTS ux_enclosure_owner_code
  ON enclosure (owner_id, code);

CREATE UNIQUE INDEX IF NOT EXISTS ux_litter_owner_code
  ON litter (owner_id, code);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'hamster'::regclass AND conname = 'ck_hamster_internal_code_nonblank'
  ) THEN
    ALTER TABLE hamster
      ADD CONSTRAINT ck_hamster_internal_code_nonblank
      CHECK (btrim(internal_code) <> '');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'enclosure'::regclass AND conname = 'ck_enclosure_code_nonblank'
  ) THEN
    ALTER TABLE enclosure
      ADD CONSTRAINT ck_enclosure_code_nonblank
      CHECK (btrim(code) <> '');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'litter'::regclass AND conname = 'ck_litter_code_nonblank'
  ) THEN
    ALTER TABLE litter
      ADD CONSTRAINT ck_litter_code_nonblank
      CHECK (btrim(code) <> '');
  END IF;
END;
$$;

-- MVP has one account actor per owner. Audit/operator references must not point
-- at another owner's account even though account(id) alone is globally valid.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'hamster'::regclass AND conname = 'ck_hamster_actor_owner'
  ) THEN
    ALTER TABLE hamster
      ADD CONSTRAINT ck_hamster_actor_owner CHECK (
        (created_by IS NULL OR created_by = owner_id)
        AND (updated_by IS NULL OR updated_by = owner_id)
      );
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'enclosure'::regclass AND conname = 'ck_enclosure_actor_owner'
  ) THEN
    ALTER TABLE enclosure
      ADD CONSTRAINT ck_enclosure_actor_owner CHECK (
        (created_by IS NULL OR created_by = owner_id)
        AND (updated_by IS NULL OR updated_by = owner_id)
      );
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'enclosure_stay'::regclass AND conname = 'ck_enclosure_stay_operator_owner'
  ) THEN
    ALTER TABLE enclosure_stay
      ADD CONSTRAINT ck_enclosure_stay_operator_owner
      CHECK (operator_id = owner_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'litter'::regclass AND conname = 'ck_litter_actor_owner'
  ) THEN
    ALTER TABLE litter
      ADD CONSTRAINT ck_litter_actor_owner CHECK (
        (created_by IS NULL OR created_by = owner_id)
        AND (updated_by IS NULL OR updated_by = owner_id)
      );
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'relationship_assertion'::regclass
      AND conname = 'ck_relationship_assertion_actor_owner'
  ) THEN
    ALTER TABLE relationship_assertion
      ADD CONSTRAINT ck_relationship_assertion_actor_owner CHECK (
        (created_by IS NULL OR created_by = owner_id)
        AND (reviewed_by IS NULL OR reviewed_by = owner_id)
      );
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'pedigree_parentage'::regclass
      AND conname = 'ck_pedigree_parentage_actor_owner'
  ) THEN
    ALTER TABLE pedigree_parentage
      ADD CONSTRAINT ck_pedigree_parentage_actor_owner CHECK (
        (created_by IS NULL OR created_by = owner_id)
        AND (updated_by IS NULL OR updated_by = owner_id)
      );
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'litter_parent'::regclass AND conname = 'ck_litter_parent_actor_owner'
  ) THEN
    ALTER TABLE litter_parent
      ADD CONSTRAINT ck_litter_parent_actor_owner CHECK (
        (created_by IS NULL OR created_by = owner_id)
        AND (updated_by IS NULL OR updated_by = owner_id)
      );
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'litter_member'::regclass AND conname = 'ck_litter_member_actor_owner'
  ) THEN
    ALTER TABLE litter_member
      ADD CONSTRAINT ck_litter_member_actor_owner CHECK (
        (created_by IS NULL OR created_by = owner_id)
        AND (updated_by IS NULL OR updated_by = owner_id)
      );
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'weight_record'::regclass AND conname = 'ck_weight_record_operator_owner'
  ) THEN
    ALTER TABLE weight_record
      ADD CONSTRAINT ck_weight_record_operator_owner
      CHECK (operator_id = owner_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'import_job'::regclass AND conname = 'ck_import_job_actor_owner'
  ) THEN
    ALTER TABLE import_job
      ADD CONSTRAINT ck_import_job_actor_owner
      CHECK (created_by IS NULL OR created_by = owner_id);
  END IF;
END;
$$;

-- ---------------------------------------------------------------------------
-- Enclosure period conflicts
-- ---------------------------------------------------------------------------

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'enclosure_stay'::regclass
      AND conname = 'ex_enclosure_stay_hamster_period'
  ) THEN
    ALTER TABLE enclosure_stay
      ADD CONSTRAINT ex_enclosure_stay_hamster_period
      EXCLUDE USING gist (
        owner_id WITH =,
        hamster_id WITH =,
        tstzrange(started_at, ended_at, '[)') WITH &&
      ) WHERE (deleted_at IS NULL)
      DEFERRABLE INITIALLY IMMEDIATE;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'enclosure_stay'::regclass
      AND conname = 'ex_enclosure_stay_single_period'
  ) THEN
    ALTER TABLE enclosure_stay
      ADD CONSTRAINT ex_enclosure_stay_single_period
      EXCLUDE USING gist (
        owner_id WITH =,
        enclosure_id WITH =,
        tstzrange(started_at, ended_at, '[)') WITH &&
      ) WHERE (deleted_at IS NULL AND purpose <> 'pairing_temp')
      DEFERRABLE INITIALLY IMMEDIATE;
  END IF;
END;
$$;

-- ---------------------------------------------------------------------------
-- Historical litter semantics and derived count cache
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION validate_litter_origin_immutable()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF OLD.origin IS DISTINCT FROM NEW.origin THEN
    RAISE EXCEPTION USING
      ERRCODE = '55000',
      MESSAGE = 'litter origin is immutable; use a correction record instead';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_litter_origin_immutable ON litter;
CREATE TRIGGER trg_litter_origin_immutable
  BEFORE UPDATE OF origin ON litter
  FOR EACH ROW EXECUTE FUNCTION validate_litter_origin_immutable();

CREATE OR REPLACE FUNCTION refresh_litter_count_cache(p_litter_id uuid)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  litter_origin_value litter_origin;
  litter_owner_id uuid;
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
  SELECT owner_id, origin
    INTO litter_owner_id, litter_origin_value
  FROM litter
  WHERE id = p_litter_id;

  IF NOT FOUND THEN
    RETURN;
  END IF;

  SELECT
    COALESCE(sum(delta) FILTER (WHERE event_type = 'initial_alive'), 0)::integer,
    COALESCE(sum(delta) FILTER (WHERE event_type = 'discovered'), 0)::integer,
    COALESCE(-sum(delta) FILTER (WHERE event_type = 'death'), 0)::integer,
    COALESCE(-sum(delta) FILTER (WHERE event_type = 'transferred_out'), 0)::integer,
    COALESCE(sum(delta) FILTER (WHERE event_type = 'correction'), 0)::integer
  INTO v_initial, v_discovered, v_deceased, v_transferred, v_correction
  FROM litter_count_event
  WHERE owner_id = litter_owner_id AND litter_id = p_litter_id;

  SELECT
    count(*) FILTER (
      WHERE profile_status = 'unindividualized' AND outcome_status = 'alive'
    )::integer,
    count(*) FILTER (
      WHERE profile_status = 'individualized' AND outcome_status = 'alive'
    )::integer
  INTO v_unindividualized, v_individualized
  FROM pup_identity
  WHERE owner_id = litter_owner_id
    AND litter_id = p_litter_id
    AND deleted_at IS NULL;

  SELECT count(*)::integer INTO v_imported_formal
  FROM litter_member
  WHERE owner_id = litter_owner_id
    AND litter_id = p_litter_id
    AND member_type = 'hamster'
    AND origin_pup_identity_id IS NULL
    AND status = 'accepted'
    AND valid_to IS NULL;

  IF litter_origin_value = 'import' THEN
    v_initial := v_imported_formal;
    v_discovered := 0;
    v_deceased := 0;
    v_transferred := 0;
    v_correction := 0;
    v_unindividualized := 0;
    v_individualized := v_imported_formal;
    v_current := v_imported_formal;
  ELSE
    v_individualized := v_individualized + v_imported_formal;
    v_current := v_initial + v_discovered - v_deceased - v_transferred + v_correction;
  END IF;

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

  SELECT count(DISTINCT role)::integer, count(DISTINCT parent_id)::integer
    INTO v_parent_roles, v_parent_count
  FROM litter_parent
  WHERE owner_id = litter_record.owner_id
    AND litter_id = p_litter_id
    AND status = 'accepted'
    AND valid_to IS NULL;

  IF litter_record.origin = 'import' THEN
    IF EXISTS (
      SELECT 1 FROM pup_identity
      WHERE owner_id = litter_record.owner_id
        AND litter_id = p_litter_id
        AND deleted_at IS NULL
    ) THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'imported historical litter cannot contain pup identities';
    END IF;

    IF v_imported_formal <= 0 THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'imported historical litter requires at least one formal member';
    END IF;

    IF v_initial_event_count > 1
      OR v_discovered <> 0 OR v_deceased <> 0 OR v_transferred <> 0 OR v_correction <> 0
      OR (v_initial_event_count = 1 AND v_initial <> v_imported_formal) THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'historical litter count events must be absent or match the imported member count';
    END IF;

    IF v_parent_roles <> v_parent_count THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'historical litter sire and dam must be distinct when both are known';
    END IF;

    IF litter_record.initial_alive_count <> v_imported_formal
      OR litter_record.discovered_count <> 0
      OR litter_record.deceased_count <> 0
      OR litter_record.transferred_out_count <> 0
      OR litter_record.correction_delta <> 0
      OR litter_record.current_managed_count <> v_imported_formal
      OR litter_record.unindividualized_alive_count <> 0
      OR litter_record.individualized_alive_count <> v_imported_formal THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'historical litter cache is inconsistent with imported formal members';
    END IF;

    RETURN;
  END IF;

  IF v_initial_event_count <> 1 THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'effective breeding litter must have exactly one initial_alive event';
  END IF;

  v_expected := v_initial + v_discovered - v_deceased - v_transferred + v_correction;
  v_individualized := v_individualized + v_imported_formal;

  IF v_initial <= 0 THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'effective breeding litter initial_alive count must be greater than zero';
  END IF;

  IF v_expected < 0 OR v_expected <> v_unindividualized + v_individualized THEN
    RAISE EXCEPTION USING
      ERRCODE = '23514',
      MESSAGE = format(
        'litter count mismatch: expected=%s, unindividualized=%s, individualized=%s',
        v_expected, v_unindividualized, v_individualized
      );
  END IF;

  IF v_imported_formal > 0 THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'breeding litter formal members require origin pup identities';
  END IF;

  IF v_unindividualized > 0 AND v_individualized > 0 THEN
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

  IF v_parent_roles <> 2 OR v_parent_count <> 2 THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'effective breeding litter must have distinct active sire and dam relationships';
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION deferred_assert_litter_balance_from_relation()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  new_litter_id uuid;
  old_litter_id uuid;
BEGIN
  IF TG_OP <> 'DELETE' THEN
    new_litter_id := NEW.litter_id;
    PERFORM assert_litter_balance(new_litter_id);
  END IF;

  IF TG_OP <> 'INSERT' THEN
    old_litter_id := OLD.litter_id;
    IF old_litter_id IS DISTINCT FROM new_litter_id THEN
      PERFORM assert_litter_balance(old_litter_id);
    END IF;
  END IF;

  IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_litter_balance_parent ON litter_parent;
CREATE CONSTRAINT TRIGGER trg_litter_balance_parent
  AFTER INSERT OR UPDATE OR DELETE ON litter_parent
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION deferred_assert_litter_balance_from_relation();

DROP TRIGGER IF EXISTS trg_litter_balance_member ON litter_member;
CREATE CONSTRAINT TRIGGER trg_litter_balance_member
  AFTER INSERT OR UPDATE OR DELETE ON litter_member
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION deferred_assert_litter_balance_from_relation();

-- Existing imported litters, if any, are normalized to the member-derived cache
-- before the new assertions are validated.
DO $$
DECLARE
  litter_id_value uuid;
BEGIN
  FOR litter_id_value IN
    SELECT id FROM litter WHERE origin = 'import' AND deleted_at IS NULL
  LOOP
    PERFORM refresh_litter_count_cache(litter_id_value);
    PERFORM assert_litter_balance(litter_id_value);
  END LOOP;
END;
$$;

-- ---------------------------------------------------------------------------
-- Pedigree role, self-loop and cycle guards
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION prevent_pedigree_cycle()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  parent_sex sex_code;
BEGIN
  IF NEW.status <> 'accepted' OR NEW.valid_to IS NOT NULL THEN
    RETURN NEW;
  END IF;

  -- Serialize active pedigree mutations per owner so concurrent inverse edges
  -- cannot both pass the recursive cycle check.
  PERFORM pg_advisory_xact_lock(hashtextextended('pedigree:' || NEW.owner_id::text, 0));

  IF NEW.parent_id = NEW.child_id THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'pedigree parent cannot equal child';
  END IF;

  SELECT sex INTO parent_sex
  FROM hamster
  WHERE owner_id = NEW.owner_id AND id = NEW.parent_id;

  IF parent_sex IS NULL THEN
    RAISE EXCEPTION USING ERRCODE = '23503', MESSAGE = 'pedigree parent not found in owner scope';
  END IF;

  IF (NEW.role = 'sire' AND parent_sex = 'female')
    OR (NEW.role = 'dam' AND parent_sex = 'male') THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'pedigree parent sex conflicts with sire/dam role';
  END IF;

  IF parent_sex = 'unknown'
    AND NOT (NEW.evidence_payload @> '{"sex_role_reviewed": true}'::jsonb) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'unknown pedigree parent sex requires sex_role_reviewed evidence';
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

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'relationship_assertion'::regclass
      AND conname = 'ck_relationship_assertion_distinct_targets'
  ) THEN
    ALTER TABLE relationship_assertion
      ADD CONSTRAINT ck_relationship_assertion_distinct_targets CHECK (
        subject_type = 'external_reference'
        OR related_type = 'external_reference'
        OR subject_type <> related_type
        OR subject_id <> related_id
      );
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION assert_imported_litter_links(p_litter_id uuid)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  litter_record litter%ROWTYPE;
BEGIN
  SELECT * INTO litter_record FROM litter WHERE id = p_litter_id;
  IF NOT FOUND OR litter_record.origin <> 'import'
    OR litter_record.deleted_at IS NOT NULL OR litter_record.state = 'voided' THEN
    RETURN;
  END IF;

  IF EXISTS (
    SELECT 1
    FROM litter_member lm
    JOIN litter_parent lp
      ON lp.owner_id = lm.owner_id
     AND lp.litter_id = lm.litter_id
     AND lp.status = 'accepted'
     AND lp.valid_to IS NULL
    WHERE lm.owner_id = litter_record.owner_id
      AND lm.litter_id = litter_record.id
      AND lm.member_type = 'hamster'
      AND lm.status = 'accepted'
      AND lm.valid_to IS NULL
      AND NOT EXISTS (
        SELECT 1
        FROM pedigree_parentage pp
        WHERE pp.owner_id = lm.owner_id
          AND pp.parent_id = lp.parent_id
          AND pp.child_id = lm.hamster_id
          AND pp.role = lp.role
          AND pp.status = 'accepted'
          AND pp.valid_to IS NULL
      )
  ) THEN
    RAISE EXCEPTION USING
      ERRCODE = '23514',
      MESSAGE = 'historical litter members must inherit every known litter parent edge';
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION deferred_assert_imported_litter_links()
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

  PERFORM assert_imported_litter_links(target_litter_id);
  IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION deferred_assert_imported_litter_links_from_relation()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  new_litter_id uuid;
  old_litter_id uuid;
BEGIN
  IF TG_OP <> 'DELETE' THEN
    new_litter_id := NEW.litter_id;
    PERFORM assert_imported_litter_links(new_litter_id);
  END IF;

  IF TG_OP <> 'INSERT' THEN
    old_litter_id := OLD.litter_id;
    IF old_litter_id IS DISTINCT FROM new_litter_id THEN
      PERFORM assert_imported_litter_links(old_litter_id);
    END IF;
  END IF;

  IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_imported_litter_links_litter ON litter;
CREATE CONSTRAINT TRIGGER trg_imported_litter_links_litter
  AFTER INSERT OR UPDATE ON litter
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION deferred_assert_imported_litter_links();

DROP TRIGGER IF EXISTS trg_imported_litter_links_member ON litter_member;
CREATE CONSTRAINT TRIGGER trg_imported_litter_links_member
  AFTER INSERT OR UPDATE OR DELETE ON litter_member
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION deferred_assert_imported_litter_links_from_relation();

DROP TRIGGER IF EXISTS trg_imported_litter_links_parent ON litter_parent;
CREATE CONSTRAINT TRIGGER trg_imported_litter_links_parent
  AFTER INSERT OR UPDATE OR DELETE ON litter_parent
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION deferred_assert_imported_litter_links_from_relation();

CREATE OR REPLACE FUNCTION deferred_assert_imported_litter_links_from_parentage()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  target_litter_id uuid;
  new_owner_id uuid;
  new_parent_id uuid;
  new_child_id uuid;
  old_owner_id uuid;
  old_parent_id uuid;
  old_child_id uuid;
BEGIN
  IF TG_OP <> 'DELETE' THEN
    new_owner_id := NEW.owner_id;
    new_parent_id := NEW.parent_id;
    new_child_id := NEW.child_id;
  END IF;

  IF TG_OP <> 'INSERT' THEN
    old_owner_id := OLD.owner_id;
    old_parent_id := OLD.parent_id;
    old_child_id := OLD.child_id;
  END IF;

  FOR target_litter_id IN
    SELECT DISTINCT l.id
    FROM litter l
    LEFT JOIN litter_member lm
      ON lm.owner_id = l.owner_id
     AND lm.litter_id = l.id
     AND lm.status = 'accepted'
     AND lm.valid_to IS NULL
    LEFT JOIN litter_parent lp
      ON lp.owner_id = l.owner_id
     AND lp.litter_id = l.id
     AND lp.status = 'accepted'
     AND lp.valid_to IS NULL
    WHERE l.origin = 'import'
      AND l.deleted_at IS NULL
      AND (
        (l.owner_id = new_owner_id
          AND (lm.hamster_id = new_child_id OR lp.parent_id = new_parent_id))
        OR
        (l.owner_id = old_owner_id
          AND (lm.hamster_id = old_child_id OR lp.parent_id = old_parent_id))
      )
  LOOP
    PERFORM assert_imported_litter_links(target_litter_id);
  END LOOP;

  IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_imported_litter_links_parentage ON pedigree_parentage;
CREATE CONSTRAINT TRIGGER trg_imported_litter_links_parentage
  AFTER INSERT OR UPDATE OR DELETE ON pedigree_parentage
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION deferred_assert_imported_litter_links_from_parentage();

-- Re-run litter-member consistency when any target or lifecycle field changes.
DROP TRIGGER IF EXISTS trg_litter_member_consistency ON litter_member;
CREATE TRIGGER trg_litter_member_consistency
  BEFORE INSERT OR UPDATE OF owner_id, litter_id, member_type, pup_identity_id,
    hamster_id, origin_pup_identity_id, status, valid_to
  ON litter_member
  FOR EACH ROW EXECUTE FUNCTION validate_litter_member_consistency();

-- ---------------------------------------------------------------------------
-- Weight facts
-- ---------------------------------------------------------------------------

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'weight_record'::regclass
      AND conname = 'ck_weight_record_change_from_birth'
  ) THEN
    ALTER TABLE weight_record
      ADD CONSTRAINT ck_weight_record_change_from_birth CHECK (
        (birth_weight_g IS NULL AND change_from_birth_g IS NULL)
        OR (
          birth_weight_g IS NOT NULL
          AND change_from_birth_g IS NOT DISTINCT FROM weight_g - birth_weight_g
        )
      );
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'weight_record'::regclass
      AND conname = 'ck_weight_record_change_from_previous'
  ) THEN
    ALTER TABLE weight_record
      ADD CONSTRAINT ck_weight_record_change_from_previous CHECK (
        (previous_weight_g IS NULL AND change_from_previous_g IS NULL)
        OR (
          previous_weight_g IS NOT NULL
          AND change_from_previous_g IS NOT DISTINCT FROM weight_g - previous_weight_g
        )
      );
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'weight_record'::regclass
      AND conname = 'ck_weight_record_alert_flags_array'
  ) THEN
    ALTER TABLE weight_record
      ADD CONSTRAINT ck_weight_record_alert_flags_array
      CHECK (jsonb_typeof(alert_flags) = 'array');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'weight_record'::regclass
      AND conname = 'ck_weight_record_acquisition_key_nonblank'
  ) THEN
    ALTER TABLE weight_record
      ADD CONSTRAINT ck_weight_record_acquisition_key_nonblank
      CHECK (acquisition_key IS NULL OR btrim(acquisition_key) <> '');
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION validate_weight_record_context()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  subject_organization_id uuid;
  corrected_record weight_record%ROWTYPE;
BEGIN
  CASE NEW.subject_type
    WHEN 'hamster' THEN
      SELECT organization_id INTO subject_organization_id
      FROM hamster
      WHERE owner_id = NEW.owner_id AND id = NEW.hamster_id;
    WHEN 'pup_identity' THEN
      SELECT l.organization_id INTO subject_organization_id
      FROM pup_identity p
      JOIN litter l ON l.owner_id = p.owner_id AND l.id = p.litter_id
      WHERE p.owner_id = NEW.owner_id AND p.id = NEW.pup_identity_id;
    WHEN 'litter' THEN
      SELECT organization_id INTO subject_organization_id
      FROM litter
      WHERE owner_id = NEW.owner_id AND id = NEW.litter_id;
  END CASE;

  IF subject_organization_id IS NULL THEN
    RAISE EXCEPTION USING ERRCODE = '23503', MESSAGE = 'weight subject not found in owner scope';
  END IF;

  IF subject_organization_id IS DISTINCT FROM NEW.organization_id THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'weight subject belongs to another organization';
  END IF;

  IF NEW.corrects_weight_record_id IS NOT NULL THEN
    SELECT * INTO corrected_record
    FROM weight_record
    WHERE owner_id = NEW.owner_id AND id = NEW.corrects_weight_record_id;

    IF corrected_record.id IS NULL THEN
      RAISE EXCEPTION USING ERRCODE = '23503', MESSAGE = 'corrected weight record not found in owner scope';
    END IF;

    IF ROW(
      corrected_record.subject_type,
      corrected_record.hamster_id,
      corrected_record.pup_identity_id,
      corrected_record.litter_id
    ) IS DISTINCT FROM ROW(
      NEW.subject_type,
      NEW.hamster_id,
      NEW.pup_identity_id,
      NEW.litter_id
    ) THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'weight correction must keep the same subject';
    END IF;

    IF NEW.recorded_at < corrected_record.recorded_at THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'weight correction cannot predate the corrected record';
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_weight_record_context ON weight_record;
CREATE TRIGGER trg_weight_record_context
  BEFORE INSERT ON weight_record
  FOR EACH ROW EXECUTE FUNCTION validate_weight_record_context();

-- ---------------------------------------------------------------------------
-- Import job ownership, row/job consistency and litter-group atomicity
-- ---------------------------------------------------------------------------

ALTER TABLE import_row
  ADD COLUMN IF NOT EXISTS atomic_group_key varchar(200),
  ADD COLUMN IF NOT EXISTS atomic_group_fingerprint char(64);

CREATE INDEX IF NOT EXISTS ix_import_row_atomic_group
  ON import_row (owner_id, import_job_id, atomic_group_key, status, row_number)
  WHERE atomic_group_key IS NOT NULL;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'import_row'::regclass AND conname = 'ck_import_row_atomic_group'
  ) THEN
    ALTER TABLE import_row
      ADD CONSTRAINT ck_import_row_atomic_group CHECK (
        (atomic_group_key IS NULL AND atomic_group_fingerprint IS NULL)
        OR (
          btrim(atomic_group_key) <> ''
          AND atomic_group_fingerprint ~ '^[0-9a-f]{64}$'
        )
      );
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'import_row'::regclass AND conname = 'ck_import_row_target_pair'
  ) THEN
    ALTER TABLE import_row
      ADD CONSTRAINT ck_import_row_target_pair CHECK (
        (target_table IS NULL) = (target_id IS NULL)
      );
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'import_row'::regclass AND conname = 'uq_import_row_owner_job_id'
  ) THEN
    ALTER TABLE import_row
      ADD CONSTRAINT uq_import_row_owner_job_id
      UNIQUE (owner_id, import_job_id, id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'import_issue'::regclass AND conname = 'fk_import_issue_job_row'
  ) THEN
    ALTER TABLE import_issue
      ADD CONSTRAINT fk_import_issue_job_row
      FOREIGN KEY (owner_id, import_job_id, import_row_id)
      REFERENCES import_row(owner_id, import_job_id, id)
      ON DELETE CASCADE;
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION validate_import_job_context()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  async_record async_job%ROWTYPE;
BEGIN
  SELECT * INTO async_record
  FROM async_job
  WHERE owner_id = NEW.owner_id AND id = NEW.async_job_id;

  IF async_record.id IS NULL THEN
    RAISE EXCEPTION USING ERRCODE = '23503', MESSAGE = 'import async job not found in owner scope';
  END IF;

  IF async_record.job_type <> 'import'
    OR async_record.organization_id IS DISTINCT FROM NEW.organization_id THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'import job must use an import async job from the same organization';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_import_job_context ON import_job;
CREATE TRIGGER trg_import_job_context
  BEFORE INSERT OR UPDATE OF owner_id, organization_id, async_job_id
  ON import_job
  FOR EACH ROW EXECUTE FUNCTION validate_import_job_context();

CREATE OR REPLACE FUNCTION validate_import_row_context()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  job_template import_template_type;
  expected_target_table text;
BEGIN
  SELECT template_type INTO job_template
  FROM import_job
  WHERE owner_id = NEW.owner_id AND id = NEW.import_job_id;

  IF job_template IS NULL THEN
    RAISE EXCEPTION USING ERRCODE = '23503', MESSAGE = 'import row job not found in owner scope';
  END IF;

  IF NEW.atomic_group_key IS NOT NULL AND job_template <> 'hamster' THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'atomic litter groups are only valid for hamster imports';
  END IF;

  expected_target_table := CASE job_template
    WHEN 'hamster' THEN 'hamster'
    WHEN 'enclosure' THEN 'enclosure'
    WHEN 'weight' THEN 'weight_record'
  END;

  IF NEW.target_table IS NOT NULL THEN
    IF NEW.target_table <> expected_target_table THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'import row target table does not match template type';
    END IF;

    IF NOT owned_target_exists(NEW.owner_id, NEW.target_table, NEW.target_id) THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'import row target is outside owner scope or missing';
    END IF;
  END IF;

  IF NEW.status = 'imported' AND NEW.target_id IS NULL THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'imported row requires an owner-scoped target';
  END IF;

  IF NEW.status IN ('imported', 'skipped', 'failed') AND NEW.processed_at IS NULL THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'terminal import row requires processed_at';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_import_row_context ON import_row;
CREATE TRIGGER trg_import_row_context
  BEFORE INSERT OR UPDATE OF owner_id, import_job_id, atomic_group_key,
    atomic_group_fingerprint, status, target_table, target_id, processed_at
  ON import_row
  FOR EACH ROW EXECUTE FUNCTION validate_import_row_context();

CREATE OR REPLACE FUNCTION assert_import_atomic_group(
  p_owner_id uuid,
  p_import_job_id uuid,
  p_atomic_group_key text
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  v_total integer;
  v_fingerprints integer;
  v_imported integer;
  v_success_terminal integer;
BEGIN
  IF p_atomic_group_key IS NULL THEN
    RETURN;
  END IF;

  SELECT
    count(*)::integer,
    count(DISTINCT atomic_group_fingerprint)::integer,
    count(*) FILTER (WHERE status = 'imported')::integer,
    count(*) FILTER (WHERE status IN ('imported', 'skipped'))::integer
  INTO v_total, v_fingerprints, v_imported, v_success_terminal
  FROM import_row
  WHERE owner_id = p_owner_id
    AND import_job_id = p_import_job_id
    AND atomic_group_key = p_atomic_group_key;

  IF v_total = 0 THEN
    RETURN;
  END IF;

  IF v_fingerprints <> 1 THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'atomic import group has inconsistent core facts';
  END IF;

  IF v_imported > 0 AND v_success_terminal <> v_total THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'atomic import group cannot be partially applied';
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION deferred_assert_import_atomic_group()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF TG_OP <> 'DELETE' AND NEW.atomic_group_key IS NOT NULL THEN
    PERFORM assert_import_atomic_group(NEW.owner_id, NEW.import_job_id, NEW.atomic_group_key);
  END IF;

  IF TG_OP <> 'INSERT' AND OLD.atomic_group_key IS NOT NULL
    AND (
      TG_OP = 'DELETE'
      OR ROW(OLD.owner_id, OLD.import_job_id, OLD.atomic_group_key)
        IS DISTINCT FROM ROW(NEW.owner_id, NEW.import_job_id, NEW.atomic_group_key)
    ) THEN
    PERFORM assert_import_atomic_group(OLD.owner_id, OLD.import_job_id, OLD.atomic_group_key);
  END IF;

  IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_import_row_atomic_group ON import_row;
CREATE CONSTRAINT TRIGGER trg_import_row_atomic_group
  AFTER INSERT OR UPDATE OR DELETE ON import_row
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION deferred_assert_import_atomic_group();

CREATE OR REPLACE FUNCTION assert_import_job_consistency(p_import_job_id uuid)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  job_record import_job%ROWTYPE;
  v_total integer;
  v_pending integer;
  v_valid integer;
  v_invalid integer;
  v_imported integer;
  v_skipped integer;
  v_failed integer;
BEGIN
  SELECT * INTO job_record FROM import_job WHERE id = p_import_job_id;
  IF NOT FOUND THEN
    RETURN;
  END IF;

  SELECT
    count(*)::integer,
    count(*) FILTER (WHERE status = 'pending')::integer,
    count(*) FILTER (WHERE status = 'valid')::integer,
    count(*) FILTER (WHERE status = 'invalid')::integer,
    count(*) FILTER (WHERE status = 'imported')::integer,
    count(*) FILTER (WHERE status = 'skipped')::integer,
    count(*) FILTER (WHERE status = 'failed')::integer
  INTO v_total, v_pending, v_valid, v_invalid, v_imported, v_skipped, v_failed
  FROM import_row
  WHERE owner_id = job_record.owner_id AND import_job_id = job_record.id;

  IF job_record.status IN ('ready', 'applying', 'succeeded', 'partially_succeeded') THEN
    IF v_total <= 0 OR job_record.total_rows <> v_total
      OR job_record.valid_rows <> v_total - v_invalid
      OR job_record.invalid_rows <> v_invalid THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'import job precheck counters do not match its rows';
    END IF;
  END IF;

  IF job_record.status = 'ready' THEN
    IF v_valid <> v_total OR v_invalid <> 0 OR v_pending <> 0 THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'ready import job requires every row to be valid';
    END IF;
  END IF;

  IF job_record.status IN ('applying', 'succeeded', 'partially_succeeded') THEN
    IF v_invalid <> 0 OR v_pending <> 0
      OR job_record.imported_rows <> v_imported
      OR job_record.skipped_rows <> v_skipped THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'import job apply counters do not match its rows';
    END IF;
  END IF;

  IF job_record.status = 'succeeded' THEN
    IF v_valid <> 0 OR v_failed <> 0 OR v_imported + v_skipped <> v_total THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'succeeded import job requires all rows to finish successfully';
    END IF;
  ELSIF job_record.status = 'partially_succeeded' THEN
    IF v_valid <> 0 OR v_failed <= 0 OR v_imported + v_skipped <= 0
      OR v_imported + v_skipped + v_failed <> v_total THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'partially succeeded import job requires both successful and failed terminal rows';
    END IF;
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION deferred_assert_import_job_from_job()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  PERFORM assert_import_job_consistency(COALESCE(NEW.id, OLD.id));
  IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION deferred_assert_import_job_from_row()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  new_job_id uuid;
  old_job_id uuid;
BEGIN
  IF TG_OP <> 'DELETE' THEN
    new_job_id := NEW.import_job_id;
    PERFORM assert_import_job_consistency(new_job_id);
  END IF;

  IF TG_OP <> 'INSERT' THEN
    old_job_id := OLD.import_job_id;
    IF old_job_id IS DISTINCT FROM new_job_id THEN
      PERFORM assert_import_job_consistency(old_job_id);
    END IF;
  END IF;

  IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_import_job_consistency_job ON import_job;
CREATE CONSTRAINT TRIGGER trg_import_job_consistency_job
  AFTER INSERT OR UPDATE ON import_job
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION deferred_assert_import_job_from_job();

DROP TRIGGER IF EXISTS trg_import_job_consistency_row ON import_row;
CREATE CONSTRAINT TRIGGER trg_import_job_consistency_row
  AFTER INSERT OR UPDATE OR DELETE ON import_row
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION deferred_assert_import_job_from_row();

COMMENT ON COLUMN import_row.atomic_group_key IS
  'Owner/job scoped atomic application group; hamster imports use the normalized litter_code.';
COMMENT ON COLUMN import_row.atomic_group_fingerprint IS
  'SHA-256 of normalized group core facts (born_at, sire_code, dam_code).';

COMMIT;
