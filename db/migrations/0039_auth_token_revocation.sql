BEGIN;

-- Persistent access-token revocation. Store only the SHA-256 digest of the
-- bearer token; the raw credential never enters the database.
CREATE TABLE IF NOT EXISTS revoked_token (
  token_sha256 varchar(64) PRIMARY KEY,
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE CASCADE,
  expires_at timestamptz NOT NULL,
  revoked_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_revoked_token_expires
  ON revoked_token (expires_at);

COMMIT;
