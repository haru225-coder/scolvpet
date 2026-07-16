-- I2 upload metadata is durable; object bytes live in the configured ObjectStore.
BEGIN;

CREATE TABLE IF NOT EXISTS import_upload (
  id uuid PRIMARY KEY,
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  object_key text NOT NULL,
  original_filename varchar(512) NOT NULL,
  declared_size bigint NOT NULL CHECK (declared_size > 0),
  file_sha256 varchar(64) NOT NULL,
  content_type varchar(160) NOT NULL DEFAULT 'text/csv',
  status varchar(24) NOT NULL DEFAULT 'pending_upload',
  expires_at timestamptz NOT NULL,
  uploaded_at timestamptz,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_import_upload_owner_id UNIQUE (owner_id, id),
  CONSTRAINT uq_import_upload_owner_object_key UNIQUE (owner_id, object_key),
  CONSTRAINT ck_import_upload_status CHECK (status IN ('pending_upload', 'uploaded', 'expired', 'deleted')),
  CONSTRAINT ck_import_upload_uploaded_at CHECK (status <> 'uploaded' OR uploaded_at IS NOT NULL)
);

CREATE INDEX IF NOT EXISTS ix_import_upload_expiry
  ON import_upload (expires_at, status);

COMMIT;
