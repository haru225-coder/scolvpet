-- B 端微信订阅消息授权与投递审计。
BEGIN;

CREATE TABLE breeder_wechat_subscription (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  openid varchar(128) NOT NULL,
  template_id varchar(128) NOT NULL,
  status varchar(16) NOT NULL DEFAULT 'reject'
    CHECK (status IN ('accept', 'reject', 'ban', 'unknown')),
  page varchar(512),
  granted_at timestamptz NOT NULL DEFAULT now(),
  last_sent_at timestamptz,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_breeder_wechat_subscription_account_template
    UNIQUE (account_id, template_id)
);

CREATE INDEX ix_breeder_wechat_subscription_delivery
  ON breeder_wechat_subscription (account_id, status, updated_at DESC);

COMMIT;
