-- T-P1-07 server push device registry and message queue (minimal).
BEGIN;

CREATE TYPE push_platform AS ENUM ('ios', 'android', 'web', 'unknown');
CREATE TYPE push_provider AS ENUM ('apns', 'fcm', 'log');
CREATE TYPE push_message_status AS ENUM (
  'queued',
  'sending',
  'sent',
  'failed',
  'dead_letter'
);

CREATE TABLE push_device (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  platform push_platform NOT NULL DEFAULT 'unknown',
  provider push_provider NOT NULL DEFAULT 'log',
  token varchar(512) NOT NULL,
  device_name varchar(120),
  app_version varchar(40),
  enabled boolean NOT NULL DEFAULT true,
  last_seen_at timestamptz NOT NULL DEFAULT now(),
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_push_device_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT uq_push_device_owner_token UNIQUE (owner_id, token),
  CONSTRAINT fk_push_device_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT
);

CREATE INDEX ix_push_device_owner_enabled
  ON push_device (owner_id, enabled, last_seen_at DESC);

CREATE TABLE push_message (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  title varchar(200) NOT NULL,
  body text NOT NULL,
  data jsonb NOT NULL DEFAULT '{}'::jsonb,
  status push_message_status NOT NULL DEFAULT 'queued',
  target_device_id uuid,
  provider push_provider NOT NULL DEFAULT 'log',
  provider_message_id varchar(200),
  attempt_count integer NOT NULL DEFAULT 0 CHECK (attempt_count >= 0),
  last_error text,
  sent_at timestamptz,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_push_message_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_push_message_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_push_message_device
    FOREIGN KEY (owner_id, target_device_id)
    REFERENCES push_device(owner_id, id) ON DELETE SET NULL
);

CREATE INDEX ix_push_message_owner_created
  ON push_message (owner_id, created_at DESC);

CREATE INDEX ix_push_message_claim
  ON push_message (status, created_at)
  WHERE status IN ('queued', 'failed');

COMMIT;
