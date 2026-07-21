-- Persist hamster cover media binding (was stubbed as always-null in I2 JSON).
BEGIN;

ALTER TABLE hamster
  ADD COLUMN IF NOT EXISTS cover_media_id uuid;

-- Composite FK: media must belong to same owner when set.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'fk_hamster_cover_media'
  ) THEN
    ALTER TABLE hamster
      ADD CONSTRAINT fk_hamster_cover_media
      FOREIGN KEY (owner_id, cover_media_id)
      REFERENCES media_asset (owner_id, id)
      ON DELETE SET NULL;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS ix_hamster_owner_cover_media
  ON hamster (owner_id, cover_media_id)
  WHERE cover_media_id IS NOT NULL AND deleted_at IS NULL;

COMMIT;
