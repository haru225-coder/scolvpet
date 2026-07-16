-- I3 繁育主链增量：保存发布时选择的配对笼，并保留观察关联媒体。
BEGIN;

ALTER TABLE breeding_plan
  ADD COLUMN IF NOT EXISTS planned_pairing_enclosure_id uuid;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'fk_breeding_plan_pairing_enclosure'
      AND conrelid = 'breeding_plan'::regclass
  ) THEN
    ALTER TABLE breeding_plan
      ADD CONSTRAINT fk_breeding_plan_pairing_enclosure
      FOREIGN KEY (owner_id, planned_pairing_enclosure_id)
      REFERENCES enclosure(owner_id, id) ON DELETE RESTRICT;
  END IF;
END;
$$;

CREATE INDEX IF NOT EXISTS ix_breeding_plan_pairing_enclosure
  ON breeding_plan (owner_id, planned_pairing_enclosure_id)
  WHERE planned_pairing_enclosure_id IS NOT NULL AND deleted_at IS NULL;

ALTER TABLE mating_observation
  ADD COLUMN IF NOT EXISTS media_ids jsonb NOT NULL DEFAULT '[]'::jsonb;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'ck_mating_observation_media_ids_array'
      AND conrelid = 'mating_observation'::regclass
  ) THEN
    ALTER TABLE mating_observation
      ADD CONSTRAINT ck_mating_observation_media_ids_array
      CHECK (jsonb_typeof(media_ids) = 'array');
  END IF;
END;
$$;

COMMIT;
