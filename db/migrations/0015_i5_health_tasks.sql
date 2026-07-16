-- I5 health/task REST slice: expose version metadata for append-only health facts.
BEGIN;

ALTER TABLE health_record
  ADD COLUMN IF NOT EXISTS version integer NOT NULL DEFAULT 1;

ALTER TABLE health_record
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

CREATE INDEX IF NOT EXISTS ix_health_record_owner_time
  ON health_record (owner_id, observed_at DESC, created_at DESC);

COMMIT;
