-- 通用 AI 助手 Slice A：多轮会话与消息落库（tool/confirm 表预留 action 字段）。
BEGIN;

CREATE TABLE assistant_session (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  title varchar(200) NOT NULL DEFAULT '',
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  CONSTRAINT uq_assistant_session_owner_id_id UNIQUE (owner_id, id)
);

CREATE INDEX ix_assistant_session_owner_updated
  ON assistant_session (owner_id, updated_at DESC)
  WHERE deleted_at IS NULL;

CREATE TABLE assistant_message (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  session_id uuid NOT NULL,
  role varchar(16) NOT NULL,
  content text NOT NULL,
  mode varchar(16),
  facts_json jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT fk_assistant_message_session
    FOREIGN KEY (owner_id, session_id)
    REFERENCES assistant_session (owner_id, id) ON DELETE CASCADE,
  CONSTRAINT ck_assistant_message_role
    CHECK (role IN ('user', 'assistant', 'system')),
  CONSTRAINT ck_assistant_message_mode
    CHECK (mode IS NULL OR mode IN ('rules', 'llm')),
  CONSTRAINT ck_assistant_message_facts
    CHECK (jsonb_typeof(facts_json) = 'array')
);

CREATE INDEX ix_assistant_message_session_created
  ON assistant_message (owner_id, session_id, created_at ASC);

CREATE TABLE assistant_action (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  session_id uuid NOT NULL,
  message_id uuid,
  type varchar(64) NOT NULL,
  label varchar(200) NOT NULL DEFAULT '',
  summary text NOT NULL DEFAULT '',
  payload_json jsonb NOT NULL DEFAULT '{}'::jsonb,
  requires_confirmation boolean NOT NULL DEFAULT true,
  status varchar(16) NOT NULL DEFAULT 'pending',
  result_json jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  executed_at timestamptz,
  CONSTRAINT fk_assistant_action_session
    FOREIGN KEY (owner_id, session_id)
    REFERENCES assistant_session (owner_id, id) ON DELETE CASCADE,
  CONSTRAINT ck_assistant_action_status
    CHECK (status IN ('pending', 'confirmed', 'cancelled', 'executed', 'failed')),
  CONSTRAINT ck_assistant_action_payload
    CHECK (jsonb_typeof(payload_json) = 'object')
);

CREATE INDEX ix_assistant_action_owner_status
  ON assistant_action (owner_id, status, created_at DESC);

COMMIT;
