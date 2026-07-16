-- Authentication challenges and refresh sessions are durable across restarts.
BEGIN;

CREATE TABLE IF NOT EXISTS verification_challenge (
  id uuid PRIMARY KEY,
  phone varchar(32) NOT NULL,
  purpose varchar(32) NOT NULL,
  code_sha256 varchar(64) NOT NULL,
  attempts integer NOT NULL DEFAULT 0 CHECK (attempts >= 0),
  expires_at timestamptz NOT NULL,
  consumed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT ck_verification_challenge_phone CHECK (phone ~ '^\+86[0-9]{6,20}$'),
  CONSTRAINT ck_verification_challenge_purpose CHECK (purpose = 'login')
);

CREATE INDEX IF NOT EXISTS ix_verification_challenge_phone_created
  ON verification_challenge (phone, created_at DESC);

CREATE TABLE IF NOT EXISTS auth_refresh_session (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  token_sha256 varchar(64) NOT NULL UNIQUE,
  expires_at timestamptz NOT NULL,
  consumed_at timestamptz,
  revoked_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  last_used_at timestamptz,
  CONSTRAINT uq_auth_refresh_session_owner_id UNIQUE (owner_id, id)
);

CREATE INDEX IF NOT EXISTS ix_auth_refresh_session_owner_active
  ON auth_refresh_session (owner_id, expires_at)
  WHERE consumed_at IS NULL AND revoked_at IS NULL;

COMMIT;
