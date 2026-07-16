-- Generated from specs/database/schema.sql; do not edit this migration by hand.
BEGIN;

CREATE TABLE import_job (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  async_job_id uuid NOT NULL,
  template_type import_template_type NOT NULL,
  status import_job_status NOT NULL DEFAULT 'uploaded',
  source_object_key text NOT NULL,
  original_filename varchar(512) NOT NULL,
  file_sha256 varchar(64) NOT NULL,
  file_encoding varchar(40),
  delimiter varchar(8),
  column_mapping jsonb NOT NULL DEFAULT '{}'::jsonb,
  conflict_policy jsonb NOT NULL DEFAULT '{}'::jsonb,
  idempotency_batch_key varchar(160) NOT NULL,
  total_rows integer NOT NULL DEFAULT 0 CHECK (total_rows >= 0),
  valid_rows integer NOT NULL DEFAULT 0 CHECK (valid_rows >= 0),
  invalid_rows integer NOT NULL DEFAULT 0 CHECK (invalid_rows >= 0),
  imported_rows integer NOT NULL DEFAULT 0 CHECK (imported_rows >= 0),
  skipped_rows integer NOT NULL DEFAULT 0 CHECK (skipped_rows >= 0),
  prechecked_at timestamptz,
  applied_at timestamptz,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_by uuid REFERENCES account(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_import_job_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_import_job_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_import_job_async_job
    FOREIGN KEY (owner_id, async_job_id)
    REFERENCES async_job(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT uq_import_job_async_job UNIQUE (owner_id, async_job_id),
  CONSTRAINT uq_import_job_batch UNIQUE (owner_id, idempotency_batch_key),
  CONSTRAINT ck_import_job_row_totals CHECK (
    valid_rows + invalid_rows <= total_rows
    AND imported_rows + skipped_rows <= total_rows
  ),
  CONSTRAINT ck_import_job_precheck_gate CHECK (
    status NOT IN ('ready', 'applying', 'succeeded', 'partially_succeeded')
    OR prechecked_at IS NOT NULL
  ),
  CONSTRAINT ck_import_job_apply_gate CHECK (
    status NOT IN ('applying', 'succeeded', 'partially_succeeded')
    OR invalid_rows = 0
  ),
  CONSTRAINT ck_import_job_applied_at CHECK (
    status NOT IN ('succeeded', 'partially_succeeded')
    OR applied_at IS NOT NULL
  )
);

CREATE INDEX ix_import_job_owner_time
  ON import_job (owner_id, created_at DESC, status);

CREATE TABLE import_row (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  import_job_id uuid NOT NULL,
  row_number integer NOT NULL CHECK (row_number > 0),
  raw_data jsonb NOT NULL,
  normalized_data jsonb NOT NULL DEFAULT '{}'::jsonb,
  row_sha256 varchar(64) NOT NULL,
  idempotency_key varchar(200) NOT NULL,
  status import_row_status NOT NULL DEFAULT 'pending',
  target_table varchar(80),
  target_id uuid,
  result_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  processed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_import_row_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_import_row_job
    FOREIGN KEY (owner_id, import_job_id)
    REFERENCES import_job(owner_id, id) ON DELETE CASCADE,
  CONSTRAINT uq_import_row_number UNIQUE (owner_id, import_job_id, row_number),
  CONSTRAINT uq_import_row_idempotency UNIQUE (owner_id, idempotency_key)
);

CREATE INDEX ix_import_row_status
  ON import_row (owner_id, import_job_id, status, row_number);

CREATE TABLE import_issue (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  import_job_id uuid NOT NULL,
  import_row_id uuid,
  severity import_issue_severity NOT NULL,
  issue_code varchar(120) NOT NULL,
  field_name varchar(160),
  raw_value text,
  message text NOT NULL,
  recovery_action text,
  details jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_import_issue_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_import_issue_job
    FOREIGN KEY (owner_id, import_job_id)
    REFERENCES import_job(owner_id, id) ON DELETE CASCADE,
  CONSTRAINT fk_import_issue_row
    FOREIGN KEY (owner_id, import_row_id)
    REFERENCES import_row(owner_id, id) ON DELETE CASCADE
);

CREATE INDEX ix_import_issue_job_row
  ON import_issue (owner_id, import_job_id, import_row_id, severity, issue_code);

CREATE TABLE export_job (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  async_job_id uuid NOT NULL,
  scope export_scope NOT NULL,
  format export_format NOT NULL,
  filters jsonb NOT NULL DEFAULT '{}'::jsonb,
  object_key text,
  sha256 varchar(64),
  byte_size bigint CHECK (byte_size >= 0),
  expires_at timestamptz,
  completed_at timestamptz,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_by uuid REFERENCES account(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_export_job_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_export_job_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_export_job_async_job
    FOREIGN KEY (owner_id, async_job_id)
    REFERENCES async_job(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT uq_export_job_async_job UNIQUE (owner_id, async_job_id)
);

CREATE INDEX ix_export_job_owner_time
  ON export_job (owner_id, created_at DESC);

CREATE TABLE backup_job (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  async_job_id uuid NOT NULL,
  backup_kind backup_kind NOT NULL DEFAULT 'full',
  base_backup_job_id uuid,
  manifest_version varchar(40) NOT NULL,
  manifest jsonb NOT NULL DEFAULT '{}'::jsonb,
  object_key text,
  sha256 varchar(64),
  byte_size bigint CHECK (byte_size >= 0),
  media_item_count integer NOT NULL DEFAULT 0 CHECK (media_item_count >= 0),
  verified_at timestamptz,
  is_restorable boolean NOT NULL DEFAULT false,
  expires_at timestamptz,
  completed_at timestamptz,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_by uuid REFERENCES account(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_backup_job_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_backup_job_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_backup_job_async_job
    FOREIGN KEY (owner_id, async_job_id)
    REFERENCES async_job(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_backup_job_base
    FOREIGN KEY (owner_id, base_backup_job_id)
    REFERENCES backup_job(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT uq_backup_job_async_job UNIQUE (owner_id, async_job_id),
  CONSTRAINT ck_backup_job_base CHECK (
    backup_kind = 'full' OR base_backup_job_id IS NOT NULL
  )
);

CREATE INDEX ix_backup_job_owner_time
  ON backup_job (owner_id, created_at DESC);

CREATE TABLE entitlement (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  entitlement_code varchar(120) NOT NULL,
  value_type entitlement_value_type NOT NULL,
  boolean_value boolean,
  integer_value bigint,
  decimal_value numeric(20,4),
  json_value jsonb,
  source varchar(80) NOT NULL DEFAULT 'system',
  effective_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz,
  revoked_at timestamptz,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_entitlement_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT ck_entitlement_value CHECK (
    (value_type = 'boolean' AND boolean_value IS NOT NULL
      AND integer_value IS NULL AND decimal_value IS NULL AND json_value IS NULL)
    OR
    (value_type = 'integer' AND boolean_value IS NULL
      AND integer_value IS NOT NULL AND decimal_value IS NULL AND json_value IS NULL)
    OR
    (value_type = 'decimal' AND boolean_value IS NULL
      AND integer_value IS NULL AND decimal_value IS NOT NULL AND json_value IS NULL)
    OR
    (value_type = 'json' AND boolean_value IS NULL
      AND integer_value IS NULL AND decimal_value IS NULL AND json_value IS NOT NULL)
  ),
  CONSTRAINT ck_entitlement_validity CHECK (
    expires_at IS NULL OR expires_at > effective_at
  )
);

CREATE UNIQUE INDEX ux_entitlement_active_code
  ON entitlement (owner_id, entitlement_code)
  WHERE revoked_at IS NULL;

CREATE TABLE usage_meter (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  metric usage_metric NOT NULL,
  current_value numeric(24,4) NOT NULL DEFAULT 0 CHECK (current_value >= 0),
  measured_at timestamptz NOT NULL DEFAULT now(),
  source_event_id uuid,
  calculation_detail jsonb NOT NULL DEFAULT '{}'::jsonb,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_usage_meter_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_usage_meter_source_event
    FOREIGN KEY (owner_id, source_event_id)
    REFERENCES domain_event(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT uq_usage_meter_metric UNIQUE (owner_id, metric)
);

CREATE TABLE usage_snapshot (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  metric usage_metric NOT NULL,
  value numeric(24,4) NOT NULL CHECK (value >= 0),
  snapshot_at timestamptz NOT NULL,
  period_start timestamptz,
  period_end timestamptz,
  calculation_detail jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_usage_snapshot_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT uq_usage_snapshot_metric_time UNIQUE (owner_id, metric, snapshot_at),
  CONSTRAINT ck_usage_snapshot_period CHECK (
    period_start IS NULL OR period_end IS NULL OR period_start < period_end
  )
);

COMMIT;
