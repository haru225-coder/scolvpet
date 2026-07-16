-- I4 窝仔运行态约束：数量投影、个体化查询和 owner 范围索引。
BEGIN;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'ck_litter_count_projection_i4'
      AND conrelid = 'litter'::regclass
  ) THEN
    ALTER TABLE litter
      ADD CONSTRAINT ck_litter_count_projection_i4 CHECK (
        current_managed_count = initial_alive_count + discovered_count
          - deceased_count - transferred_out_count + correction_delta
      );
  END IF;
END;
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'ck_litter_individualization_projection_i4'
      AND conrelid = 'litter'::regclass
  ) THEN
    ALTER TABLE litter
      ADD CONSTRAINT ck_litter_individualization_projection_i4 CHECK (
        unindividualized_alive_count >= 0
        AND individualized_alive_count >= 0
        AND unindividualized_alive_count + individualized_alive_count <= current_managed_count
      );
  END IF;
END;
$$;

CREATE INDEX IF NOT EXISTS ix_i4_pup_eligibility
  ON pup_identity (owner_id, litter_id, outcome_status, profile_status, sex, current_enclosure_id)
  WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS ix_i4_litter_member_origin
  ON litter_member (owner_id, litter_id, origin_pup_identity_id, status, valid_to)
  WHERE status = 'accepted' AND valid_to IS NULL;

CREATE INDEX IF NOT EXISTS ix_i4_count_event_projection
  ON litter_count_event (owner_id, litter_id, event_type, occurred_at, created_at);

CREATE UNIQUE INDEX IF NOT EXISTS ux_i4_birth_event_per_plan
  ON domain_event (owner_id, aggregate_id)
  WHERE aggregate_type = 'breeding_plan'
    AND event_type IN ('BIRTH_CONFIRMED', 'BIRTH_CONFIRMED_NO_LIVE_PUPS')
    AND reverted_at IS NULL;

COMMIT;
