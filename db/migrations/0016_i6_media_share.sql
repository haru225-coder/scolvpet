BEGIN;

CREATE TABLE IF NOT EXISTS media_upload_session (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  kind media_kind NOT NULL,
  status media_upload_status NOT NULL DEFAULT 'pending_upload',
  object_key text NOT NULL,
  original_filename varchar(512) NOT NULL,
  mime_type varchar(160) NOT NULL,
  byte_size bigint NOT NULL CHECK (byte_size > 0),
  sha256 varchar(64) NOT NULL,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  expires_at timestamptz NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_media_upload_session_owner_id UNIQUE (owner_id, id),
  CONSTRAINT fk_media_upload_session_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_media_upload_session_object_key
  ON media_upload_session (owner_id, object_key);

CREATE INDEX IF NOT EXISTS ix_media_upload_session_expiry
  ON media_upload_session (owner_id, expires_at)
  WHERE status = 'pending_upload';

COMMIT;
