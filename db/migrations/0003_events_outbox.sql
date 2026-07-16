-- Generated from specs/database/schema.sql; do not edit this migration by hand.
BEGIN;

CREATE TABLE domain_event (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  aggregate_type varchar(80) NOT NULL,
  aggregate_id uuid NOT NULL,
  event_type varchar(120) NOT NULL,
  event_version integer NOT NULL CHECK (event_version > 0),
  actor_id uuid REFERENCES account(id) ON DELETE SET NULL,
  occurred_at timestamptz NOT NULL,
  recorded_at timestamptz NOT NULL DEFAULT now(),
  payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  idempotency_key varchar(160),
  correlation_id uuid,
  causation_id uuid,
  corrects_event_id uuid,
  reverted_at timestamptz,
  CONSTRAINT uq_domain_event_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_domain_event_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_domain_event_causation
    FOREIGN KEY (owner_id, causation_id)
    REFERENCES domain_event(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_domain_event_correction
    FOREIGN KEY (owner_id, corrects_event_id)
    REFERENCES domain_event(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT uq_domain_event_aggregate_version
    UNIQUE (owner_id, aggregate_type, aggregate_id, event_version)
);

CREATE UNIQUE INDEX ux_domain_event_idempotency
  ON domain_event (owner_id, idempotency_key)
  WHERE idempotency_key IS NOT NULL;

CREATE UNIQUE INDEX ux_domain_event_confirm_birth
  ON domain_event (owner_id, aggregate_id)
  WHERE aggregate_type = 'breeding_plan'
    AND event_type IN ('BIRTH_CONFIRMED', 'BIRTH_CONFIRMED_NO_LIVE_PUPS')
    AND reverted_at IS NULL;

CREATE INDEX ix_domain_event_aggregate_time
  ON domain_event (owner_id, aggregate_type, aggregate_id, occurred_at DESC);

CREATE TABLE outbox_message (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  domain_event_id uuid NOT NULL,
  topic varchar(160) NOT NULL,
  partition_key varchar(160) NOT NULL,
  payload jsonb NOT NULL,
  status outbox_status NOT NULL DEFAULT 'pending',
  priority smallint NOT NULL DEFAULT 100,
  available_at timestamptz NOT NULL DEFAULT now(),
  attempt_count integer NOT NULL DEFAULT 0 CHECK (attempt_count >= 0),
  max_attempts integer NOT NULL DEFAULT 12 CHECK (max_attempts > 0),
  locked_at timestamptz,
  locked_by varchar(160),
  published_at timestamptz,
  last_error text,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_outbox_message_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_outbox_domain_event
    FOREIGN KEY (owner_id, domain_event_id)
    REFERENCES domain_event(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT uq_outbox_domain_event UNIQUE (owner_id, domain_event_id)
);

CREATE INDEX ix_outbox_claim
  ON outbox_message (status, available_at, priority, created_at)
  WHERE status IN ('pending', 'failed');

COMMIT;
