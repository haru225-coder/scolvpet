-- B 端微信身份绑定：与 customer_wechat_identity / ct_* 会话完全隔离。
-- openid 只作为微信身份索引；业务权限仍由 account + organization_member 决定。
BEGIN;

CREATE TABLE IF NOT EXISTS breeder_wechat_identity (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  openid text NOT NULL,
  unionid text NULL,
  account_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  bound_at timestamptz NOT NULL DEFAULT now(),
  last_login_at timestamptz,
  revoked_at timestamptz NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_breeder_wechat_identity_openid_active
  ON breeder_wechat_identity (openid)
  WHERE revoked_at IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_breeder_wechat_identity_account_active
  ON breeder_wechat_identity (account_id)
  WHERE revoked_at IS NULL;

CREATE INDEX IF NOT EXISTS ix_breeder_wechat_identity_account
  ON breeder_wechat_identity (account_id, revoked_at);

COMMENT ON TABLE breeder_wechat_identity IS
  'B 端微信 openid ↔ 繁育者 account 绑定；会话使用 staff Bearer，和 C 端 ct_* 隔离。';

CREATE TABLE IF NOT EXISTS breeder_wechat_bind_ticket (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  openid text NOT NULL,
  unionid text NULL,
  ticket_sha256 text UNIQUE NOT NULL,
  expires_at timestamptz NOT NULL,
  used_at timestamptz NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_breeder_wechat_bind_ticket_expires
  ON breeder_wechat_bind_ticket (expires_at);

COMMENT ON TABLE breeder_wechat_bind_ticket IS
  'B 端微信首次绑定的一次性票据；只存 sha256，原始票据只回传一次。';

COMMIT;
