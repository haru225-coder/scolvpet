-- I6 data-center REST contract extensions. The base job and usage tables are
-- created by 0008_data_center_usage.sql; this migration adds the fields needed
-- to preserve the REST request snapshot without changing existing rows.
BEGIN;

ALTER TABLE export_job
  ADD COLUMN IF NOT EXISTS datasets jsonb NOT NULL DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS timezone varchar(64) NOT NULL DEFAULT 'Asia/Shanghai',
  ADD COLUMN IF NOT EXISTS snapshot_at timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS file_name varchar(512);

ALTER TABLE export_job
  ADD CONSTRAINT ck_export_job_datasets_array
  CHECK (jsonb_typeof(datasets) = 'array');

CREATE INDEX IF NOT EXISTS ix_export_job_owner_snapshot
  ON export_job (owner_id, snapshot_at DESC);

COMMIT;
