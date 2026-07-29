-- B 端微信订阅事件队列与服务端 worker 投递审计。
BEGIN;

-- WeChat subscription events are separate from in-app reminder rows because
-- reservation status changes are not care tasks and a single event may fan out
-- to multiple accepted templates.
CREATE TABLE breeder_wechat_subscription_event (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  event_type varchar(40) NOT NULL
    CHECK (event_type IN ('task_reminder', 'reservation_status')),
  resource_id uuid NOT NULL,
  dedupe_key varchar(220) NOT NULL,
  payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  status varchar(16) NOT NULL DEFAULT 'queued'
    CHECK (status IN ('queued', 'sending', 'succeeded', 'failed', 'cancelled')),
  scheduled_at timestamptz NOT NULL,
  attempt_count integer NOT NULL DEFAULT 0 CHECK (attempt_count >= 0),
  max_attempts integer NOT NULL DEFAULT 8 CHECK (max_attempts > 0),
  next_attempt_at timestamptz,
  locked_at timestamptz,
  locked_by varchar(120),
  delivered_at timestamptz,
  provider_message_id varchar(200),
  last_error text,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_breeder_wechat_subscription_event_owner_id UNIQUE (account_id, id),
  CONSTRAINT uq_breeder_wechat_subscription_event_dedupe UNIQUE (account_id, dedupe_key)
);

CREATE INDEX ix_breeder_wechat_subscription_event_claim
  ON breeder_wechat_subscription_event (status, scheduled_at, next_attempt_at)
  WHERE status IN ('queued', 'failed');

COMMIT;
