-- Generated from specs/database/schema.sql; do not edit this migration by hand.
BEGIN;

CREATE TABLE care_task (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  task_type care_task_type NOT NULL,
  target_type care_task_target_type NOT NULL,
  target_id uuid NOT NULL,
  title varchar(240) NOT NULL,
  description text,
  scheduled_at timestamptz NOT NULL,
  calculation_timezone varchar(64) NOT NULL DEFAULT 'Asia/Shanghai',
  priority task_priority NOT NULL DEFAULT 'normal',
  status task_status NOT NULL DEFAULT 'pending',
  assignee_id uuid REFERENCES account(id) ON DELETE SET NULL,
  stage_total integer,
  stage_done integer,
  recurrence_rule jsonb NOT NULL DEFAULT '{}'::jsonb,
  rule_code varchar(120),
  rule_version varchar(80),
  source_event_id uuid,
  dedupe_key varchar(200) NOT NULL,
  snoozed_until timestamptz,
  completed_at timestamptz,
  cancelled_at timestamptz,
  cancellation_reason text,
  superseded_by_id uuid,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_by uuid REFERENCES account(id) ON DELETE SET NULL,
  updated_by uuid REFERENCES account(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_care_task_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_care_task_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_care_task_source_event
    FOREIGN KEY (owner_id, source_event_id)
    REFERENCES domain_event(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_care_task_superseded_by
    FOREIGN KEY (owner_id, superseded_by_id)
    REFERENCES care_task(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT uq_care_task_dedupe UNIQUE (owner_id, dedupe_key),
  CONSTRAINT ck_care_task_stage CHECK (
    (stage_total IS NULL AND stage_done IS NULL)
    OR (stage_total > 0 AND stage_done BETWEEN 0 AND stage_total)
  ),
  CONSTRAINT ck_care_task_completed CHECK (
    status <> 'completed' OR completed_at IS NOT NULL
  ),
  CONSTRAINT ck_care_task_snoozed CHECK (
    status <> 'snoozed' OR snoozed_until IS NOT NULL
  ),
  CONSTRAINT ck_care_task_cancelled CHECK (
    status <> 'cancelled' OR cancelled_at IS NOT NULL
  ),
  CONSTRAINT ck_care_task_superseded CHECK (
    status <> 'superseded' OR superseded_by_id IS NOT NULL
  )
);

CREATE INDEX ix_care_task_calendar
  ON care_task (owner_id, status, scheduled_at, priority)
  WHERE status IN ('pending', 'in_progress', 'snoozed');

CREATE INDEX ix_care_task_target
  ON care_task (owner_id, target_type, target_id, scheduled_at DESC);

CREATE TABLE care_task_subject (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  care_task_id uuid NOT NULL,
  subject_type care_task_subject_type NOT NULL,
  subject_id uuid NOT NULL,
  completed_at timestamptz,
  completed_by uuid REFERENCES account(id) ON DELETE SET NULL,
  completion_record_refs jsonb NOT NULL DEFAULT '[]'::jsonb,
  exception_reason text,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_care_task_subject_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_care_task_subject_task
    FOREIGN KEY (owner_id, care_task_id)
    REFERENCES care_task(owner_id, id) ON DELETE CASCADE,
  CONSTRAINT uq_care_task_subject UNIQUE (owner_id, care_task_id, subject_type, subject_id)
);

CREATE INDEX ix_care_task_subject_incomplete
  ON care_task_subject (owner_id, care_task_id, subject_type, subject_id)
  WHERE completed_at IS NULL;

CREATE TABLE reminder_delivery (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  care_task_id uuid NOT NULL,
  async_job_id uuid,
  channel delivery_channel NOT NULL,
  status delivery_status NOT NULL DEFAULT 'queued',
  dedupe_key varchar(220) NOT NULL,
  scheduled_at timestamptz NOT NULL,
  attempt_count integer NOT NULL DEFAULT 0 CHECK (attempt_count >= 0),
  next_attempt_at timestamptz,
  delivered_at timestamptz,
  read_at timestamptz,
  error_code varchar(120),
  error_detail text,
  provider_message_id varchar(200),
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_reminder_delivery_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_reminder_delivery_task
    FOREIGN KEY (owner_id, care_task_id)
    REFERENCES care_task(owner_id, id) ON DELETE CASCADE,
  CONSTRAINT fk_reminder_delivery_async_job
    FOREIGN KEY (owner_id, async_job_id)
    REFERENCES async_job(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT uq_reminder_delivery_dedupe UNIQUE (owner_id, channel, dedupe_key),
  CONSTRAINT ck_reminder_delivery_delivered CHECK (
    status NOT IN ('succeeded', 'read') OR delivered_at IS NOT NULL
  ),
  CONSTRAINT ck_reminder_delivery_read CHECK (
    status <> 'read' OR read_at IS NOT NULL
  )
);

CREATE INDEX ix_reminder_delivery_claim
  ON reminder_delivery (status, scheduled_at, next_attempt_at)
  WHERE status IN ('queued', 'failed');

CREATE TABLE media_link (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  media_asset_id uuid NOT NULL,
  media_variant_id uuid,
  target_type media_target_type NOT NULL,
  target_id uuid NOT NULL,
  role media_link_role NOT NULL,
  sort_order integer NOT NULL DEFAULT 0,
  caption text,
  is_public boolean NOT NULL DEFAULT false,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_by uuid REFERENCES account(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  CONSTRAINT uq_media_link_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_media_link_asset
    FOREIGN KEY (owner_id, media_asset_id)
    REFERENCES media_asset(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_media_link_variant
    FOREIGN KEY (owner_id, media_variant_id)
    REFERENCES media_variant(owner_id, id) ON DELETE RESTRICT
);

CREATE UNIQUE INDEX ux_media_link_active
  ON media_link (
    owner_id, media_asset_id, COALESCE(media_variant_id, '00000000-0000-0000-0000-000000000000'::uuid),
    target_type, target_id, role
  ) WHERE deleted_at IS NULL;

CREATE INDEX ix_media_link_target
  ON media_link (owner_id, target_type, target_id, role, sort_order)
  WHERE deleted_at IS NULL;

CREATE TABLE share_page (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  target_type share_target_type NOT NULL,
  target_id uuid NOT NULL,
  token_hash bytea NOT NULL,
  token_prefix varchar(16) NOT NULL,
  selected_fields jsonb NOT NULL DEFAULT '[]'::jsonb,
  presentation jsonb NOT NULL DEFAULT '{}'::jsonb,
  public_cache_ttl_seconds smallint NOT NULL DEFAULT 60,
  expires_at timestamptz,
  revoked_at timestamptz,
  revoked_by uuid REFERENCES account(id) ON DELETE SET NULL,
  revoke_reason text,
  cache_purge_requested_at timestamptz,
  cache_purged_at timestamptz,
  last_accessed_at timestamptz,
  access_count bigint NOT NULL DEFAULT 0 CHECK (access_count >= 0),
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_by uuid REFERENCES account(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_share_page_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_share_page_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT uq_share_page_token_hash UNIQUE (token_hash),
  CONSTRAINT ck_share_page_expiry CHECK (expires_at IS NULL OR expires_at > created_at),
  CONSTRAINT ck_share_page_revoke CHECK (
    revoked_at IS NULL OR revoked_at >= created_at
  ),
  CONSTRAINT ck_share_page_cache_ttl CHECK (
    public_cache_ttl_seconds BETWEEN 0 AND 60
  ),
  CONSTRAINT ck_share_page_cache_purge CHECK (
    cache_purged_at IS NULL
    OR (cache_purge_requested_at IS NOT NULL AND cache_purged_at >= cache_purge_requested_at)
  )
);

CREATE INDEX ix_share_page_target
  ON share_page (owner_id, target_type, target_id, created_at DESC);

COMMIT;
