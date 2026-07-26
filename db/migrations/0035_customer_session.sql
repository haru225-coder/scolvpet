-- Customer-side verified sessions (miniprogram / public customer portal).
BEGIN;

CREATE TABLE IF NOT EXISTS customer_session (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  phone varchar(32) NOT NULL,
  token_sha256 varchar(64) NOT NULL UNIQUE,
  expires_at timestamptz NOT NULL,
  revoked_at timestamptz,
  last_used_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT ck_customer_session_phone CHECK (phone ~ '^\+86[0-9]{6,20}$')
);

CREATE INDEX IF NOT EXISTS ix_customer_session_phone_active
  ON customer_session (phone, expires_at)
  WHERE revoked_at IS NULL;

COMMENT ON TABLE customer_session IS
  '客户侧短信验证会话；与 staff account bearer 分离。';

COMMIT;
