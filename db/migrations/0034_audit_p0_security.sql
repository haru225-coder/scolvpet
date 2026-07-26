-- P0 security/reservation closeout: hold expiry, access JTI revoke, SMS cooldown.
BEGIN;

-- Public reservation hold auto-release.
ALTER TABLE crm_reservation
  ADD COLUMN IF NOT EXISTS hold_expires_at timestamptz;

COMMENT ON COLUMN crm_reservation.hold_expires_at IS
  'held 状态自动释放截止时间；confirmed/handed_over 可为空。';

CREATE INDEX IF NOT EXISTS ix_crm_reservation_hold_expires
  ON crm_reservation (hold_expires_at)
  WHERE status = 'held' AND hold_expires_at IS NOT NULL;

-- Persistent access-token JTI revocation (survives process restart).
CREATE TABLE IF NOT EXISTS auth_access_revocation (
  jti varchar(64) PRIMARY KEY,
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE CASCADE,
  expires_at timestamptz NOT NULL,
  revoked_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_auth_access_revocation_expires
  ON auth_access_revocation (expires_at);

-- SMS / public abuse counters (durable cooldown).
CREATE TABLE IF NOT EXISTS auth_rate_limit (
  bucket_key varchar(200) PRIMARY KEY,
  hit_count integer NOT NULL DEFAULT 0 CHECK (hit_count >= 0),
  window_started_at timestamptz NOT NULL DEFAULT now(),
  last_hit_at timestamptz NOT NULL DEFAULT now(),
  blocked_until timestamptz
);

CREATE INDEX IF NOT EXISTS ix_auth_rate_limit_blocked
  ON auth_rate_limit (blocked_until)
  WHERE blocked_until IS NOT NULL;

-- Public (pre-account) write idempotency, e.g. SMS verification.
CREATE TABLE IF NOT EXISTS auth_public_idempotency (
  idempotency_key varchar(200) PRIMARY KEY,
  request_hash varchar(64) NOT NULL,
  response_status integer NOT NULL,
  response_body jsonb NOT NULL,
  expires_at timestamptz NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_auth_public_idempotency_expires
  ON auth_public_idempotency (expires_at);

COMMIT;
