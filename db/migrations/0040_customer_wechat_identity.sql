-- WeChat mini-program identity binding (P2): openid is the login credential,
-- phone stays the business source of truth. Unbinding keeps the row for audit
-- (revoked_at), so uniqueness only applies to active bindings.
BEGIN;

CREATE TABLE IF NOT EXISTS customer_wechat_identity (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  openid text NOT NULL,
  unionid text NULL,
  phone text NOT NULL,
  bound_at timestamptz NOT NULL DEFAULT now(),
  last_login_at timestamptz,
  revoked_at timestamptz NULL,
  CONSTRAINT ck_customer_wechat_identity_phone CHECK (phone ~ '^\+86[0-9]{6,20}$')
);

-- One active binding per openid; revoked rows stay for the audit chain.
CREATE UNIQUE INDEX IF NOT EXISTS ux_customer_wechat_identity_openid_active
  ON customer_wechat_identity (openid)
  WHERE revoked_at IS NULL;

CREATE INDEX IF NOT EXISTS ix_customer_wechat_identity_phone_active
  ON customer_wechat_identity (phone)
  WHERE revoked_at IS NULL;

COMMENT ON TABLE customer_wechat_identity IS
  '微信 openid ↔ 手机号绑定；openid 仅免重复短信验证，业务真源仍为 phone。';

-- Short-lived one-time bind tickets issued when a wx.login openid has no
-- active binding. Only the SHA-256 digest is stored; the raw wt_* ticket
-- appears exactly once in the wechat-sessions response.
CREATE TABLE IF NOT EXISTS wechat_bind_ticket (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  openid text NOT NULL,
  unionid text NULL,
  ticket_sha256 text UNIQUE NOT NULL,
  expires_at timestamptz NOT NULL,
  used_at timestamptz NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_wechat_bind_ticket_expires
  ON wechat_bind_ticket (expires_at);

COMMENT ON TABLE wechat_bind_ticket IS
  '微信绑定一次性票据；库存 sha256，10 分钟过期，used_at 标记消费。';

COMMIT;
