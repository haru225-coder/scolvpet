-- Generated from specs/database/schema.sql; do not edit this migration by hand.
BEGIN;

CREATE TABLE async_job (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid,
  job_type async_job_type NOT NULL,
  status async_job_status NOT NULL DEFAULT 'queued',
  priority smallint NOT NULL DEFAULT 100,
  progress_percent numeric(5,2) NOT NULL DEFAULT 0,
  request_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  result_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  idempotency_key varchar(160) NOT NULL,
  attempt_count integer NOT NULL DEFAULT 0 CHECK (attempt_count >= 0),
  max_attempts integer NOT NULL DEFAULT 5 CHECK (max_attempts > 0),
  available_at timestamptz NOT NULL DEFAULT now(),
  started_at timestamptz,
  finished_at timestamptz,
  locked_at timestamptz,
  locked_by varchar(160),
  error_code varchar(120),
  error_detail text,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_by uuid REFERENCES account(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_async_job_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_async_job_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT uq_async_job_idempotency UNIQUE (owner_id, idempotency_key),
  CONSTRAINT ck_async_job_progress CHECK (progress_percent BETWEEN 0 AND 100),
  CONSTRAINT ck_async_job_time CHECK (finished_at IS NULL OR started_at IS NOT NULL)
);

CREATE INDEX ix_async_job_claim
  ON async_job (status, available_at, priority, created_at)
  WHERE status IN ('queued', 'failed');

CREATE TABLE media_asset (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  kind media_kind NOT NULL,
  status media_upload_status NOT NULL DEFAULT 'pending_upload',
  original_object_key text NOT NULL,
  original_filename varchar(512),
  mime_type varchar(160) NOT NULL,
  byte_size bigint NOT NULL CHECK (byte_size >= 0),
  width_px integer CHECK (width_px > 0),
  height_px integer CHECK (height_px > 0),
  duration_ms bigint CHECK (duration_ms >= 0),
  sha256 varchar(64) NOT NULL,
  captured_at timestamptz,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  failure_code varchar(120),
  failure_detail text,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_by uuid REFERENCES account(id) ON DELETE SET NULL,
  updated_by uuid REFERENCES account(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  CONSTRAINT uq_media_asset_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_media_asset_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT
);

CREATE UNIQUE INDEX ux_media_asset_object_key_active
  ON media_asset (owner_id, original_object_key)
  WHERE deleted_at IS NULL;

CREATE INDEX ix_media_asset_owner_kind_time
  ON media_asset (owner_id, kind, created_at DESC)
  WHERE deleted_at IS NULL;

CREATE TABLE media_variant (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  media_asset_id uuid NOT NULL,
  async_job_id uuid,
  variant_kind media_variant_kind NOT NULL,
  variant_key varchar(120) NOT NULL,
  status media_variant_status NOT NULL DEFAULT 'queued',
  object_key text,
  mime_type varchar(160),
  byte_size bigint CHECK (byte_size >= 0),
  width_px integer CHECK (width_px > 0),
  height_px integer CHECK (height_px > 0),
  duration_ms bigint CHECK (duration_ms >= 0),
  codec varchar(80),
  bitrate_kbps integer CHECK (bitrate_kbps > 0),
  sha256 varchar(64),
  edit_recipe jsonb NOT NULL DEFAULT '{}'::jsonb,
  failure_code varchar(120),
  failure_detail text,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  CONSTRAINT uq_media_variant_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_media_variant_asset
    FOREIGN KEY (owner_id, media_asset_id)
    REFERENCES media_asset(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_media_variant_async_job
    FOREIGN KEY (owner_id, async_job_id)
    REFERENCES async_job(owner_id, id) ON DELETE RESTRICT
);

CREATE UNIQUE INDEX ux_media_variant_key_active
  ON media_variant (owner_id, media_asset_id, variant_kind, variant_key)
  WHERE deleted_at IS NULL;

CREATE UNIQUE INDEX ux_media_variant_object_key_active
  ON media_variant (owner_id, object_key)
  WHERE object_key IS NOT NULL AND deleted_at IS NULL;

CREATE TABLE enclosure (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  code varchar(80) NOT NULL,
  rack_code varchar(80),
  level_code varchar(80),
  capacity integer NOT NULL DEFAULT 1 CHECK (capacity > 0),
  state enclosure_state NOT NULL DEFAULT 'vacant',
  cleanliness cleanliness_state NOT NULL DEFAULT 'clean',
  size_mm jsonb NOT NULL DEFAULT '{}'::jsonb,
  equipment jsonb NOT NULL DEFAULT '{}'::jsonb,
  last_cleaned_at timestamptz,
  disabled_reason text,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_by uuid REFERENCES account(id) ON DELETE SET NULL,
  updated_by uuid REFERENCES account(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  CONSTRAINT uq_enclosure_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_enclosure_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT
);

CREATE UNIQUE INDEX ux_enclosure_owner_code_active
  ON enclosure (owner_id, code)
  WHERE deleted_at IS NULL;

CREATE INDEX ix_enclosure_rack_level
  ON enclosure (owner_id, rack_code, level_code, code)
  WHERE deleted_at IS NULL;

CREATE TABLE hamster (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  internal_code varchar(80) NOT NULL,
  name varchar(160),
  species_rule_version_id uuid NOT NULL REFERENCES species_rule_version(id) ON DELETE RESTRICT,
  variety_code varchar(80),
  sex sex_code NOT NULL DEFAULT 'unknown',
  sex_confidence numeric(5,4),
  birth_date date,
  source_type hamster_source_type NOT NULL,
  lifecycle_status hamster_lifecycle_status NOT NULL DEFAULT 'active',
  breeding_status hamster_breeding_status NOT NULL DEFAULT 'candidate',
  current_enclosure_id uuid,
  phenotype jsonb NOT NULL DEFAULT '{}'::jsonb,
  tags jsonb NOT NULL DEFAULT '[]'::jsonb,
  notes text,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_by uuid REFERENCES account(id) ON DELETE SET NULL,
  updated_by uuid REFERENCES account(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  CONSTRAINT uq_hamster_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_hamster_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_hamster_current_enclosure
    FOREIGN KEY (owner_id, current_enclosure_id)
    REFERENCES enclosure(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT ck_hamster_sex_confidence CHECK (
    sex_confidence IS NULL OR sex_confidence BETWEEN 0 AND 1
  )
);

CREATE UNIQUE INDEX ux_hamster_internal_code_active
  ON hamster (owner_id, internal_code)
  WHERE deleted_at IS NULL;

CREATE INDEX ix_hamster_filters
  ON hamster (owner_id, lifecycle_status, breeding_status, sex, variety_code)
  WHERE deleted_at IS NULL;

CREATE INDEX ix_hamster_current_enclosure
  ON hamster (owner_id, current_enclosure_id)
  WHERE current_enclosure_id IS NOT NULL AND deleted_at IS NULL;

COMMIT;
