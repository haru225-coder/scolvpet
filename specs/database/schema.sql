-- 熊舍管家 MVP PostgreSQL 15+ Schema
-- 设计基线：docs/superpowers/specs/2026-07-16-熊舍管家-mvp-design.md
-- 时间统一存为 timestamptz；对象存储字段只保存 object_key，不保存 URL 或二进制内容。

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE TYPE dictionary_scope AS ENUM ('system', 'owner');
CREATE TYPE account_status AS ENUM ('active', 'suspended', 'closed');
CREATE TYPE organization_mode AS ENUM ('personal', 'professional');
CREATE TYPE species_rule_status AS ENUM ('draft', 'published', 'retired');
CREATE TYPE sex_code AS ENUM ('male', 'female', 'unknown');
CREATE TYPE hamster_source_type AS ENUM ('born_here', 'introduced', 'customer', 'imported');
CREATE TYPE hamster_lifecycle_status AS ENUM ('active', 'transferred', 'retired', 'deceased');
CREATE TYPE hamster_breeding_status AS ENUM ('candidate', 'active', 'resting', 'retired');
CREATE TYPE enclosure_state AS ENUM (
  'vacant', 'occupied_single', 'pairing_temp', 'gestation',
  'dam_with_litter', 'isolation', 'cleaning_due', 'disabled'
);
CREATE TYPE cleanliness_state AS ENUM ('clean', 'partial_due', 'full_due');
CREATE TYPE enclosure_stay_purpose AS ENUM (
  'single', 'pairing_temp', 'gestation', 'isolation', 'dam_with_litter'
);
CREATE TYPE enclosure_cleaning_type AS ENUM ('partial', 'full', 'disinfection');
CREATE TYPE breeding_plan_state AS ENUM (
  'draft', 'pair_ready', 'pairing', 'post_pair', 'gestation',
  'litter_nursing', 'weaning_due',
  'sex_separation_due', 'individualizing', 'completed',
  'no_litter_outcome', 'hold', 'unsuccessful', 'cancelled'
);
CREATE TYPE pairing_attempt_status AS ENUM ('active', 'separated', 'safety_hold', 'cancelled');
CREATE TYPE pairing_result AS ENUM ('effective', 'uncertain', 'ineffective', 'safety_stop');
CREATE TYPE mating_observation_type AS ENUM (
  'contact', 'chase', 'conflict', 'mating', 'separated', 'other'
);
CREATE TYPE severity_level AS ENUM ('info', 'low', 'medium', 'high', 'critical');
CREATE TYPE litter_state AS ENUM (
  'newborn', 'nursing', 'weaning_due', 'sexing_due',
  'individualizing', 'closed', 'voided'
);
CREATE TYPE litter_origin AS ENUM ('breeding', 'import');
CREATE TYPE litter_count_event_type AS ENUM (
  'initial_alive', 'discovered', 'death', 'transferred_out', 'correction'
);
CREATE TYPE pup_profile_status AS ENUM ('unindividualized', 'individualized', 'voided');
CREATE TYPE pup_outcome_status AS ENUM ('alive', 'deceased', 'transferred_out');
CREATE TYPE relationship_evidence_type AS ENUM (
  'system', 'litter_inferred', 'manual', 'imported', 'document', 'dna'
);
CREATE TYPE relationship_status AS ENUM ('pending', 'accepted', 'rejected', 'superseded');
CREATE TYPE parent_role AS ENUM ('sire', 'dam');
CREATE TYPE relationship_assertion_kind AS ENUM (
  'parentage', 'litter_parent', 'litter_member', 'sibling'
);
CREATE TYPE relationship_subject_type AS ENUM (
  'hamster', 'litter', 'pup_identity', 'external_reference'
);
CREATE TYPE litter_member_type AS ENUM ('pup_identity', 'hamster');
CREATE TYPE measurement_source AS ENUM ('manual', 'bluetooth_scale', 'import');
CREATE TYPE weight_subject_type AS ENUM ('hamster', 'pup_identity', 'litter');
CREATE TYPE weight_measurement_kind AS ENUM ('individual', 'litter_total', 'litter_average');
CREATE TYPE health_subject_type AS ENUM ('hamster', 'pup_identity', 'litter', 'enclosure');
CREATE TYPE health_record_type AS ENUM (
  'daily_check', 'anomaly', 'medication', 'follow_up', 'isolation', 'death'
);
CREATE TYPE care_task_type AS ENUM (
  'pair_prep', 'pairing_timeout', 'separate_now',
  'gestation_window_open', 'gestation_window_close', 'no_birth_review',
  'litter_observation', 'pup_weight_check', 'pup_weight_drop',
  'weaning_due', 'sex_separation_due', 'sex_recheck',
  'profile_creation_due', 'cleaning', 'medication', 'follow_up', 'custom'
);
CREATE TYPE care_task_target_type AS ENUM (
  'organization', 'hamster', 'litter', 'enclosure',
  'breeding_plan', 'pairing_attempt', 'pup_identity'
);
CREATE TYPE care_task_subject_type AS ENUM ('hamster', 'pup_identity');
CREATE TYPE task_priority AS ENUM ('low', 'normal', 'high', 'urgent', 'critical');
CREATE TYPE task_status AS ENUM (
  'pending', 'in_progress', 'completed', 'snoozed', 'cancelled', 'superseded'
);
CREATE TYPE delivery_channel AS ENUM ('in_app', 'local_notification', 'app_push', 'service_account');
CREATE TYPE delivery_status AS ENUM ('queued', 'sending', 'succeeded', 'failed', 'read', 'cancelled');
CREATE TYPE outbox_status AS ENUM ('pending', 'processing', 'published', 'failed', 'dead_letter');
CREATE TYPE async_job_type AS ENUM (
  'import', 'export', 'backup', 'media_transform', 'usage_snapshot', 'share_render'
);
CREATE TYPE async_job_status AS ENUM ('queued', 'running', 'succeeded', 'failed', 'cancelled');
CREATE TYPE media_kind AS ENUM ('image', 'video', 'document');
CREATE TYPE media_upload_status AS ENUM (
  'pending_upload', 'uploaded', 'processing', 'ready', 'failed', 'quarantined'
);
CREATE TYPE media_variant_kind AS ENUM (
  'thumbnail', 'preview', 'image_edit', 'video_transcode', 'video_cover', 'share_render'
);
CREATE TYPE media_variant_status AS ENUM ('queued', 'processing', 'ready', 'failed');
CREATE TYPE media_target_type AS ENUM (
  'hamster', 'litter', 'health_record', 'mating_observation',
  'pairing_attempt', 'breeding_plan', 'enclosure', 'domain_event', 'share_page'
);
CREATE TYPE media_link_role AS ENUM ('cover', 'gallery', 'attachment', 'timeline', 'share');
CREATE TYPE share_target_type AS ENUM ('hamster', 'litter');
CREATE TYPE import_template_type AS ENUM ('hamster', 'enclosure', 'weight');
CREATE TYPE import_job_status AS ENUM (
  'uploaded', 'mapping', 'prechecking', 'ready', 'applying',
  'succeeded', 'partially_succeeded', 'failed', 'cancelled'
);
CREATE TYPE import_row_status AS ENUM ('pending', 'valid', 'invalid', 'imported', 'skipped', 'failed');
CREATE TYPE import_issue_severity AS ENUM ('warning', 'error');
CREATE TYPE export_format AS ENUM ('csv', 'json', 'pdf', 'zip');
CREATE TYPE export_scope AS ENUM (
  'hamsters', 'enclosures', 'breeding', 'litters',
  'weights', 'health', 'pedigree', 'full'
);
CREATE TYPE backup_kind AS ENUM ('full', 'incremental');
CREATE TYPE entitlement_value_type AS ENUM ('boolean', 'integer', 'decimal', 'json');
CREATE TYPE usage_metric AS ENUM (
  'active_hamsters', 'active_litters', 'enclosures',
  'media_bytes', 'video_minutes', 'backup_bytes'
);
CREATE TYPE idempotency_status AS ENUM ('processing', 'completed', 'failed');

CREATE TABLE account (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  phone_country_code varchar(8) NOT NULL DEFAULT '+86',
  phone_number varchar(32) NOT NULL,
  status account_status NOT NULL DEFAULT 'active',
  display_name varchar(120),
  locale varchar(16) NOT NULL DEFAULT 'zh-CN',
  timezone varchar(64) NOT NULL DEFAULT 'Asia/Shanghai',
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  CONSTRAINT ck_account_phone CHECK (phone_number ~ '^[0-9]{6,20}$')
);

CREATE UNIQUE INDEX ux_account_phone_active
  ON account (phone_country_code, phone_number)
  WHERE deleted_at IS NULL;

CREATE TABLE organization (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  code varchar(64) NOT NULL,
  name varchar(160) NOT NULL,
  mode organization_mode NOT NULL DEFAULT 'personal',
  timezone varchar(64) NOT NULL DEFAULT 'Asia/Shanghai',
  weight_unit varchar(8) NOT NULL DEFAULT 'g',
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_by uuid REFERENCES account(id) ON DELETE SET NULL,
  updated_by uuid REFERENCES account(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  CONSTRAINT uq_organization_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT ck_organization_weight_unit CHECK (weight_unit = 'g')
);

CREATE UNIQUE INDEX ux_organization_owner_code_active
  ON organization (owner_id, code)
  WHERE deleted_at IS NULL;

CREATE TABLE species_rule_version (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid REFERENCES account(id) ON DELETE RESTRICT,
  scope dictionary_scope NOT NULL,
  copied_from_id uuid REFERENCES species_rule_version(id) ON DELETE RESTRICT,
  species_code varchar(64) NOT NULL,
  variety_scope jsonb NOT NULL DEFAULT '[]'::jsonb,
  display_name varchar(160) NOT NULL,
  version_no integer NOT NULL CHECK (version_no > 0),
  status species_rule_status NOT NULL DEFAULT 'draft',
  gestation_min_days integer NOT NULL CHECK (gestation_min_days >= 0),
  gestation_max_days integer NOT NULL CHECK (gestation_max_days >= gestation_min_days),
  pairing_max_minutes integer CHECK (pairing_max_minutes > 0),
  weaning_target_days integer NOT NULL CHECK (weaning_target_days >= 0),
  sexing_target_days integer NOT NULL CHECK (sexing_target_days >= 0),
  separation_target_days integer NOT NULL CHECK (separation_target_days >= 0),
  post_breeding_rest_days integer CHECK (post_breeding_rest_days >= 0),
  profile_creation_deadline_days integer CHECK (profile_creation_deadline_days >= 0),
  weight_reference jsonb NOT NULL DEFAULT '{}'::jsonb,
  reminder_rules jsonb NOT NULL DEFAULT '{}'::jsonb,
  source_note text NOT NULL,
  checksum varchar(128) NOT NULL,
  effective_at timestamptz NOT NULL,
  retired_at timestamptz,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_by uuid REFERENCES account(id) ON DELETE SET NULL,
  updated_by uuid REFERENCES account(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT ck_species_rule_scope_owner CHECK (
    (scope = 'system' AND owner_id IS NULL)
    OR (scope = 'owner' AND owner_id IS NOT NULL)
  ),
  CONSTRAINT ck_species_rule_retired_at CHECK (retired_at IS NULL OR retired_at >= effective_at)
);

CREATE UNIQUE INDEX ux_species_rule_system_version
  ON species_rule_version (species_code, version_no)
  WHERE scope = 'system';

CREATE UNIQUE INDEX ux_species_rule_owner_version
  ON species_rule_version (owner_id, species_code, version_no)
  WHERE scope = 'owner';

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

CREATE TABLE breeding_plan (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  name varchar(160),
  sire_id uuid NOT NULL,
  dam_id uuid NOT NULL,
  species_rule_version_id uuid NOT NULL REFERENCES species_rule_version(id) ON DELETE RESTRICT,
  state breeding_plan_state NOT NULL DEFAULT 'draft',
  planned_pairing_at timestamptz,
  mating_baseline_at timestamptz,
  expected_birth_start date,
  expected_birth_end date,
  actual_birth_at timestamptz,
  birth_result_alive_count integer CHECK (birth_result_alive_count >= 0),
  birth_result_other_count integer CHECK (birth_result_other_count >= 0),
  birth_result_reason text,
  birth_dam_condition jsonb NOT NULL DEFAULT '{}'::jsonb,
  objective_traits jsonb NOT NULL DEFAULT '{}'::jsonb,
  kinship_check jsonb NOT NULL DEFAULT '{}'::jsonb,
  eligibility_override_reason text,
  date_correction_note text,
  notes text,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_by uuid REFERENCES account(id) ON DELETE SET NULL,
  updated_by uuid REFERENCES account(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  CONSTRAINT uq_breeding_plan_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_breeding_plan_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_breeding_plan_sire
    FOREIGN KEY (owner_id, sire_id)
    REFERENCES hamster(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_breeding_plan_dam
    FOREIGN KEY (owner_id, dam_id)
    REFERENCES hamster(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT ck_breeding_plan_parents CHECK (sire_id <> dam_id),
  CONSTRAINT ck_breeding_plan_birth_window CHECK (
    expected_birth_start IS NULL OR expected_birth_end IS NULL
    OR expected_birth_start <= expected_birth_end
  ),
  CONSTRAINT ck_breeding_plan_no_litter_outcome CHECK (
    state <> 'no_litter_outcome'
    OR (
      actual_birth_at IS NOT NULL
      AND birth_result_alive_count = 0
      AND birth_result_other_count IS NOT NULL
      AND NULLIF(btrim(birth_result_reason), '') IS NOT NULL
    )
  )
);

CREATE INDEX ix_breeding_plan_state_time
  ON breeding_plan (owner_id, state, planned_pairing_at)
  WHERE deleted_at IS NULL;

CREATE TABLE pairing_attempt (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  breeding_plan_id uuid NOT NULL,
  attempt_no integer NOT NULL CHECK (attempt_no > 0),
  sire_id uuid NOT NULL,
  dam_id uuid NOT NULL,
  pairing_enclosure_id uuid NOT NULL,
  status pairing_attempt_status NOT NULL DEFAULT 'active',
  started_at timestamptz NOT NULL,
  separation_deadline timestamptz NOT NULL,
  ended_at timestamptz,
  separated_at timestamptz,
  result pairing_result,
  conflict_level severity_level,
  sire_destination_enclosure_id uuid,
  dam_destination_enclosure_id uuid,
  evidence_note text,
  notes text,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_by uuid REFERENCES account(id) ON DELETE SET NULL,
  updated_by uuid REFERENCES account(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  CONSTRAINT uq_pairing_attempt_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_pairing_attempt_plan
    FOREIGN KEY (owner_id, breeding_plan_id)
    REFERENCES breeding_plan(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_pairing_attempt_sire
    FOREIGN KEY (owner_id, sire_id)
    REFERENCES hamster(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_pairing_attempt_dam
    FOREIGN KEY (owner_id, dam_id)
    REFERENCES hamster(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_pairing_attempt_enclosure
    FOREIGN KEY (owner_id, pairing_enclosure_id)
    REFERENCES enclosure(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_pairing_attempt_sire_destination
    FOREIGN KEY (owner_id, sire_destination_enclosure_id)
    REFERENCES enclosure(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_pairing_attempt_dam_destination
    FOREIGN KEY (owner_id, dam_destination_enclosure_id)
    REFERENCES enclosure(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT uq_pairing_attempt_sequence UNIQUE (owner_id, breeding_plan_id, attempt_no),
  CONSTRAINT ck_pairing_attempt_parents CHECK (sire_id <> dam_id),
  CONSTRAINT ck_pairing_attempt_deadline CHECK (separation_deadline > started_at),
  CONSTRAINT ck_pairing_attempt_end CHECK (ended_at IS NULL OR ended_at >= started_at),
  CONSTRAINT ck_pairing_attempt_separated_at CHECK (
    separated_at IS NULL OR separated_at >= started_at
  ),
  CONSTRAINT ck_pairing_attempt_closed CHECK (
    status <> 'separated'
    OR (
      ended_at IS NOT NULL AND separated_at IS NOT NULL AND result IS NOT NULL
      AND sire_destination_enclosure_id IS NOT NULL
      AND dam_destination_enclosure_id IS NOT NULL
    )
  ),
  CONSTRAINT ck_pairing_attempt_destinations CHECK (
    sire_destination_enclosure_id IS NULL OR dam_destination_enclosure_id IS NULL
    OR sire_destination_enclosure_id <> dam_destination_enclosure_id
  )
);

CREATE UNIQUE INDEX ux_pairing_attempt_active_plan
  ON pairing_attempt (owner_id, breeding_plan_id)
  WHERE status IN ('active', 'safety_hold') AND deleted_at IS NULL;

CREATE INDEX ix_pairing_attempt_participants
  ON pairing_attempt (owner_id, sire_id, dam_id, status)
  WHERE deleted_at IS NULL;

CREATE TABLE enclosure_stay (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  enclosure_id uuid NOT NULL,
  hamster_id uuid NOT NULL,
  pairing_attempt_id uuid,
  purpose enclosure_stay_purpose NOT NULL,
  started_at timestamptz NOT NULL,
  ended_at timestamptz,
  operator_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  reason text,
  correction_note text,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  CONSTRAINT uq_enclosure_stay_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_enclosure_stay_enclosure
    FOREIGN KEY (owner_id, enclosure_id)
    REFERENCES enclosure(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_enclosure_stay_hamster
    FOREIGN KEY (owner_id, hamster_id)
    REFERENCES hamster(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_enclosure_stay_pairing
    FOREIGN KEY (owner_id, pairing_attempt_id)
    REFERENCES pairing_attempt(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT ck_enclosure_stay_time CHECK (ended_at IS NULL OR ended_at > started_at),
  CONSTRAINT ck_enclosure_stay_pairing_reference CHECK (
    (purpose = 'pairing_temp' AND pairing_attempt_id IS NOT NULL)
    OR (purpose <> 'pairing_temp' AND pairing_attempt_id IS NULL)
  )
);

CREATE INDEX ix_enclosure_stay_enclosure_period
  ON enclosure_stay USING gist (
    owner_id, enclosure_id, tstzrange(started_at, ended_at, '[)')
  ) WHERE deleted_at IS NULL;

CREATE INDEX ix_enclosure_stay_hamster_period
  ON enclosure_stay USING gist (
    owner_id, hamster_id, tstzrange(started_at, ended_at, '[)')
  ) WHERE deleted_at IS NULL;

CREATE TABLE enclosure_cleaning_record (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  enclosure_id uuid NOT NULL,
  cleaning_type enclosure_cleaning_type NOT NULL,
  performed_at timestamptz NOT NULL,
  operator_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  source_event_id uuid,
  supplies jsonb NOT NULL DEFAULT '{}'::jsonb,
  notes text,
  corrects_cleaning_record_id uuid,
  correction_reason text,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_enclosure_cleaning_record_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_enclosure_cleaning_record_enclosure
    FOREIGN KEY (owner_id, enclosure_id)
    REFERENCES enclosure(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_enclosure_cleaning_record_event
    FOREIGN KEY (owner_id, source_event_id)
    REFERENCES domain_event(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_enclosure_cleaning_record_correction
    FOREIGN KEY (owner_id, corrects_cleaning_record_id)
    REFERENCES enclosure_cleaning_record(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT ck_enclosure_cleaning_record_correction CHECK (
    corrects_cleaning_record_id IS NULL OR correction_reason IS NOT NULL
  )
);

CREATE INDEX ix_enclosure_cleaning_time
  ON enclosure_cleaning_record (owner_id, enclosure_id, performed_at DESC);

CREATE TABLE mating_observation (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  pairing_attempt_id uuid NOT NULL,
  observed_at timestamptz NOT NULL,
  observation_type mating_observation_type NOT NULL,
  duration_seconds integer CHECK (duration_seconds >= 0),
  severity severity_level,
  confidence numeric(5,4),
  note text,
  operator_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  CONSTRAINT uq_mating_observation_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_mating_observation_pairing
    FOREIGN KEY (owner_id, pairing_attempt_id)
    REFERENCES pairing_attempt(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT ck_mating_observation_confidence CHECK (
    confidence IS NULL OR confidence BETWEEN 0 AND 1
  )
);

CREATE INDEX ix_mating_observation_attempt_time
  ON mating_observation (owner_id, pairing_attempt_id, observed_at DESC)
  WHERE deleted_at IS NULL;

CREATE TABLE litter (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  breeding_plan_id uuid,
  origin litter_origin NOT NULL DEFAULT 'breeding',
  code varchar(80) NOT NULL,
  state litter_state NOT NULL DEFAULT 'newborn',
  born_at timestamptz,
  enclosure_id uuid,
  dam_condition jsonb NOT NULL DEFAULT '{}'::jsonb,
  initial_alive_count integer NOT NULL DEFAULT 0,
  initial_other_count integer NOT NULL DEFAULT 0,
  discovered_count integer NOT NULL DEFAULT 0,
  deceased_count integer NOT NULL DEFAULT 0,
  transferred_out_count integer NOT NULL DEFAULT 0,
  correction_delta integer NOT NULL DEFAULT 0,
  current_managed_count integer NOT NULL DEFAULT 0,
  unindividualized_alive_count integer NOT NULL DEFAULT 0,
  individualized_alive_count integer NOT NULL DEFAULT 0,
  weaning_completed_at timestamptz,
  sex_separation_completed_at timestamptz,
  reconciled_at timestamptz,
  notes text,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_by uuid REFERENCES account(id) ON DELETE SET NULL,
  updated_by uuid REFERENCES account(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  CONSTRAINT uq_litter_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_litter_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_litter_plan
    FOREIGN KEY (owner_id, breeding_plan_id)
    REFERENCES breeding_plan(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_litter_enclosure
    FOREIGN KEY (owner_id, enclosure_id)
    REFERENCES enclosure(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT ck_litter_counts_nonnegative CHECK (
    initial_alive_count >= 0 AND initial_other_count >= 0
    AND discovered_count >= 0 AND deceased_count >= 0
    AND transferred_out_count >= 0 AND current_managed_count >= 0
    AND unindividualized_alive_count >= 0 AND individualized_alive_count >= 0
  ),
  CONSTRAINT ck_litter_origin CHECK (
    (origin = 'breeding' AND breeding_plan_id IS NOT NULL
      AND born_at IS NOT NULL AND enclosure_id IS NOT NULL)
    OR
    (origin = 'import' AND breeding_plan_id IS NULL
      AND state = 'closed' AND enclosure_id IS NULL)
  )
);

CREATE UNIQUE INDEX ux_litter_owner_code_active
  ON litter (owner_id, code)
  WHERE deleted_at IS NULL;

CREATE UNIQUE INDEX ux_litter_one_effective_per_plan
  ON litter (owner_id, breeding_plan_id)
  WHERE breeding_plan_id IS NOT NULL AND state <> 'voided' AND deleted_at IS NULL;

CREATE INDEX ix_litter_state_born_at
  ON litter (owner_id, state, born_at DESC)
  WHERE deleted_at IS NULL;

CREATE TABLE pup_identity (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  litter_id uuid NOT NULL,
  temporary_code varchar(80) NOT NULL,
  sex sex_code NOT NULL DEFAULT 'unknown',
  sex_confidence numeric(5,4),
  profile_status pup_profile_status NOT NULL DEFAULT 'unindividualized',
  outcome_status pup_outcome_status NOT NULL DEFAULT 'alive',
  weaned_at timestamptz,
  current_enclosure_id uuid,
  individualized_hamster_id uuid,
  phenotype_summary jsonb NOT NULL DEFAULT '{}'::jsonb,
  destination_code varchar(80),
  status_reason text,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_by uuid REFERENCES account(id) ON DELETE SET NULL,
  updated_by uuid REFERENCES account(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  CONSTRAINT uq_pup_identity_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_pup_identity_litter
    FOREIGN KEY (owner_id, litter_id)
    REFERENCES litter(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_pup_identity_enclosure
    FOREIGN KEY (owner_id, current_enclosure_id)
    REFERENCES enclosure(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_pup_identity_hamster
    FOREIGN KEY (owner_id, individualized_hamster_id)
    REFERENCES hamster(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT ck_pup_identity_sex_confidence CHECK (
    sex_confidence IS NULL OR sex_confidence BETWEEN 0 AND 1
  ),
  CONSTRAINT ck_pup_identity_individualization CHECK (
    (profile_status = 'individualized' AND individualized_hamster_id IS NOT NULL)
    OR (profile_status <> 'individualized' AND individualized_hamster_id IS NULL)
  )
);

CREATE UNIQUE INDEX ux_pup_identity_temp_code_active
  ON pup_identity (owner_id, litter_id, temporary_code)
  WHERE deleted_at IS NULL;

CREATE UNIQUE INDEX ux_pup_identity_hamster_one_to_one
  ON pup_identity (owner_id, individualized_hamster_id)
  WHERE individualized_hamster_id IS NOT NULL AND deleted_at IS NULL;

CREATE INDEX ix_pup_identity_litter_status
  ON pup_identity (owner_id, litter_id, profile_status, outcome_status)
  WHERE deleted_at IS NULL;

CREATE TABLE relationship_assertion (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  assertion_kind relationship_assertion_kind NOT NULL,
  subject_type relationship_subject_type NOT NULL,
  subject_id uuid,
  related_type relationship_subject_type NOT NULL,
  related_id uuid,
  relationship_role varchar(80),
  raw_reference jsonb NOT NULL DEFAULT '{}'::jsonb,
  evidence_type relationship_evidence_type NOT NULL,
  evidence_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  confidence numeric(5,4),
  status relationship_status NOT NULL DEFAULT 'pending',
  valid_from timestamptz NOT NULL DEFAULT now(),
  valid_to timestamptz,
  corrects_assertion_id uuid,
  review_note text,
  reviewed_by uuid REFERENCES account(id) ON DELETE SET NULL,
  reviewed_at timestamptz,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_by uuid REFERENCES account(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_relationship_assertion_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_relationship_assertion_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_relationship_assertion_correction
    FOREIGN KEY (owner_id, corrects_assertion_id)
    REFERENCES relationship_assertion(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT ck_relationship_assertion_confidence CHECK (
    confidence IS NULL OR confidence BETWEEN 0 AND 1
  ),
  CONSTRAINT ck_relationship_assertion_validity CHECK (
    valid_to IS NULL OR valid_to > valid_from
  ),
  CONSTRAINT ck_relationship_assertion_reference CHECK (
    ((subject_type = 'external_reference' AND subject_id IS NULL)
      OR (subject_type <> 'external_reference' AND subject_id IS NOT NULL))
    AND
    ((related_type = 'external_reference' AND related_id IS NULL)
      OR (related_type <> 'external_reference' AND related_id IS NOT NULL))
  )
);

CREATE INDEX ix_relationship_assertion_review
  ON relationship_assertion (owner_id, status, assertion_kind, created_at)
  WHERE status = 'pending';

CREATE TABLE pedigree_parentage (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  parent_id uuid NOT NULL,
  child_id uuid NOT NULL,
  role parent_role NOT NULL,
  evidence_type relationship_evidence_type NOT NULL,
  evidence_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  confidence numeric(5,4) NOT NULL DEFAULT 1,
  status relationship_status NOT NULL DEFAULT 'accepted',
  valid_from timestamptz NOT NULL DEFAULT now(),
  valid_to timestamptz,
  relationship_assertion_id uuid,
  corrects_parentage_id uuid,
  correction_note text,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_by uuid REFERENCES account(id) ON DELETE SET NULL,
  updated_by uuid REFERENCES account(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_pedigree_parentage_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_pedigree_parentage_parent
    FOREIGN KEY (owner_id, parent_id)
    REFERENCES hamster(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_pedigree_parentage_child
    FOREIGN KEY (owner_id, child_id)
    REFERENCES hamster(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_pedigree_parentage_assertion
    FOREIGN KEY (owner_id, relationship_assertion_id)
    REFERENCES relationship_assertion(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_pedigree_parentage_correction
    FOREIGN KEY (owner_id, corrects_parentage_id)
    REFERENCES pedigree_parentage(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT ck_pedigree_parentage_distinct CHECK (parent_id <> child_id),
  CONSTRAINT ck_pedigree_parentage_confidence CHECK (confidence BETWEEN 0 AND 1),
  CONSTRAINT ck_pedigree_parentage_validity CHECK (valid_to IS NULL OR valid_to > valid_from)
);

CREATE UNIQUE INDEX ux_pedigree_parentage_active_role
  ON pedigree_parentage (owner_id, child_id, role)
  WHERE status = 'accepted' AND valid_to IS NULL;

CREATE INDEX ix_pedigree_parentage_parent_active
  ON pedigree_parentage (owner_id, parent_id, child_id)
  WHERE status = 'accepted' AND valid_to IS NULL;

CREATE TABLE litter_parent (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  litter_id uuid NOT NULL,
  parent_id uuid NOT NULL,
  role parent_role NOT NULL,
  evidence_type relationship_evidence_type NOT NULL DEFAULT 'litter_inferred',
  evidence_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  confidence numeric(5,4) NOT NULL DEFAULT 1,
  status relationship_status NOT NULL DEFAULT 'accepted',
  valid_from timestamptz NOT NULL DEFAULT now(),
  valid_to timestamptz,
  relationship_assertion_id uuid,
  corrects_litter_parent_id uuid,
  correction_note text,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_by uuid REFERENCES account(id) ON DELETE SET NULL,
  updated_by uuid REFERENCES account(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_litter_parent_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_litter_parent_litter
    FOREIGN KEY (owner_id, litter_id)
    REFERENCES litter(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_litter_parent_hamster
    FOREIGN KEY (owner_id, parent_id)
    REFERENCES hamster(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_litter_parent_assertion
    FOREIGN KEY (owner_id, relationship_assertion_id)
    REFERENCES relationship_assertion(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_litter_parent_correction
    FOREIGN KEY (owner_id, corrects_litter_parent_id)
    REFERENCES litter_parent(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT ck_litter_parent_confidence CHECK (confidence BETWEEN 0 AND 1),
  CONSTRAINT ck_litter_parent_validity CHECK (valid_to IS NULL OR valid_to > valid_from)
);

CREATE UNIQUE INDEX ux_litter_parent_active_role
  ON litter_parent (owner_id, litter_id, role)
  WHERE status = 'accepted' AND valid_to IS NULL;

CREATE TABLE litter_member (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  litter_id uuid NOT NULL,
  member_type litter_member_type NOT NULL,
  pup_identity_id uuid,
  hamster_id uuid,
  origin_pup_identity_id uuid,
  evidence_type relationship_evidence_type NOT NULL DEFAULT 'litter_inferred',
  evidence_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  confidence numeric(5,4) NOT NULL DEFAULT 1,
  status relationship_status NOT NULL DEFAULT 'accepted',
  valid_from timestamptz NOT NULL DEFAULT now(),
  valid_to timestamptz,
  relationship_assertion_id uuid,
  corrects_litter_member_id uuid,
  correction_note text,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_by uuid REFERENCES account(id) ON DELETE SET NULL,
  updated_by uuid REFERENCES account(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_litter_member_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_litter_member_litter
    FOREIGN KEY (owner_id, litter_id)
    REFERENCES litter(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_litter_member_pup
    FOREIGN KEY (owner_id, pup_identity_id)
    REFERENCES pup_identity(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_litter_member_hamster
    FOREIGN KEY (owner_id, hamster_id)
    REFERENCES hamster(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_litter_member_origin_pup
    FOREIGN KEY (owner_id, origin_pup_identity_id)
    REFERENCES pup_identity(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_litter_member_assertion
    FOREIGN KEY (owner_id, relationship_assertion_id)
    REFERENCES relationship_assertion(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_litter_member_correction
    FOREIGN KEY (owner_id, corrects_litter_member_id)
    REFERENCES litter_member(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT ck_litter_member_target CHECK (
    (member_type = 'pup_identity' AND pup_identity_id IS NOT NULL
      AND hamster_id IS NULL AND origin_pup_identity_id IS NULL)
    OR
    (member_type = 'hamster' AND hamster_id IS NOT NULL AND pup_identity_id IS NULL)
  ),
  CONSTRAINT ck_litter_member_confidence CHECK (confidence BETWEEN 0 AND 1),
  CONSTRAINT ck_litter_member_validity CHECK (valid_to IS NULL OR valid_to > valid_from)
);

CREATE UNIQUE INDEX ux_litter_member_active_pup
  ON litter_member (owner_id, pup_identity_id)
  WHERE pup_identity_id IS NOT NULL AND status = 'accepted' AND valid_to IS NULL;

CREATE UNIQUE INDEX ux_litter_member_active_hamster
  ON litter_member (owner_id, hamster_id)
  WHERE hamster_id IS NOT NULL AND status = 'accepted' AND valid_to IS NULL;

CREATE UNIQUE INDEX ux_litter_member_origin_pup
  ON litter_member (owner_id, origin_pup_identity_id)
  WHERE origin_pup_identity_id IS NOT NULL AND status = 'accepted' AND valid_to IS NULL;

CREATE TABLE litter_count_event (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  litter_id uuid NOT NULL,
  pup_identity_id uuid,
  event_type litter_count_event_type NOT NULL,
  delta integer NOT NULL,
  occurred_at timestamptz NOT NULL,
  reason text,
  operator_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  source_event_id uuid,
  corrects_count_event_id uuid,
  idempotency_key varchar(160) NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_litter_count_event_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_litter_count_event_litter
    FOREIGN KEY (owner_id, litter_id)
    REFERENCES litter(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_litter_count_event_pup
    FOREIGN KEY (owner_id, pup_identity_id)
    REFERENCES pup_identity(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_litter_count_event_domain_event
    FOREIGN KEY (owner_id, source_event_id)
    REFERENCES domain_event(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_litter_count_event_correction
    FOREIGN KEY (owner_id, corrects_count_event_id)
    REFERENCES litter_count_event(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT uq_litter_count_event_idempotency UNIQUE (owner_id, idempotency_key),
  CONSTRAINT ck_litter_count_event_delta CHECK (
    (event_type = 'initial_alive' AND delta > 0)
    OR (event_type = 'discovered' AND delta > 0)
    OR (event_type IN ('death', 'transferred_out') AND delta < 0)
    OR (event_type = 'correction' AND delta <> 0)
  ),
  CONSTRAINT ck_litter_count_event_reason CHECK (
    event_type = 'initial_alive' OR reason IS NOT NULL
  )
);

CREATE UNIQUE INDEX ux_litter_count_initial
  ON litter_count_event (owner_id, litter_id)
  WHERE event_type = 'initial_alive';

CREATE INDEX ix_litter_count_event_time
  ON litter_count_event (owner_id, litter_id, occurred_at, created_at);

CREATE TABLE weight_record (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  subject_type weight_subject_type NOT NULL,
  hamster_id uuid,
  pup_identity_id uuid,
  litter_id uuid,
  measurement_kind weight_measurement_kind NOT NULL,
  subject_count integer,
  weight_g numeric(10,2) NOT NULL CHECK (weight_g > 0),
  recorded_at timestamptz NOT NULL,
  source measurement_source NOT NULL,
  acquisition_key varchar(160),
  species_rule_version_id uuid REFERENCES species_rule_version(id) ON DELETE RESTRICT,
  birth_weight_g numeric(10,2) CHECK (birth_weight_g > 0),
  previous_weight_g numeric(10,2) CHECK (previous_weight_g > 0),
  change_from_birth_g numeric(10,2),
  change_from_previous_g numeric(10,2),
  alert_flags jsonb NOT NULL DEFAULT '[]'::jsonb,
  operator_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  corrects_weight_record_id uuid,
  correction_reason text,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_weight_record_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_weight_record_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_weight_record_hamster
    FOREIGN KEY (owner_id, hamster_id)
    REFERENCES hamster(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_weight_record_pup
    FOREIGN KEY (owner_id, pup_identity_id)
    REFERENCES pup_identity(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_weight_record_litter
    FOREIGN KEY (owner_id, litter_id)
    REFERENCES litter(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_weight_record_correction
    FOREIGN KEY (owner_id, corrects_weight_record_id)
    REFERENCES weight_record(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT ck_weight_record_subject CHECK (
    (subject_type = 'hamster' AND hamster_id IS NOT NULL
      AND pup_identity_id IS NULL AND litter_id IS NULL
      AND measurement_kind = 'individual' AND subject_count IS NULL)
    OR
    (subject_type = 'pup_identity' AND pup_identity_id IS NOT NULL
      AND hamster_id IS NULL AND litter_id IS NULL
      AND measurement_kind = 'individual' AND subject_count IS NULL)
    OR
    (subject_type = 'litter' AND litter_id IS NOT NULL
      AND hamster_id IS NULL AND pup_identity_id IS NULL
      AND measurement_kind IN ('litter_total', 'litter_average')
      AND subject_count IS NOT NULL AND subject_count > 0)
  ),
  CONSTRAINT ck_weight_record_correction CHECK (
    corrects_weight_record_id IS NULL OR correction_reason IS NOT NULL
  )
);

CREATE UNIQUE INDEX ux_weight_record_acquisition
  ON weight_record (owner_id, acquisition_key)
  WHERE acquisition_key IS NOT NULL;

CREATE INDEX ix_weight_record_hamster_time
  ON weight_record (owner_id, hamster_id, recorded_at DESC)
  WHERE hamster_id IS NOT NULL;

CREATE INDEX ix_weight_record_pup_time
  ON weight_record (owner_id, pup_identity_id, recorded_at DESC)
  WHERE pup_identity_id IS NOT NULL;

CREATE INDEX ix_weight_record_litter_time
  ON weight_record (owner_id, litter_id, recorded_at DESC)
  WHERE litter_id IS NOT NULL;

CREATE TABLE health_record (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  subject_type health_subject_type NOT NULL,
  hamster_id uuid,
  pup_identity_id uuid,
  litter_id uuid,
  enclosure_id uuid,
  record_type health_record_type NOT NULL,
  observed_at timestamptz NOT NULL,
  structured_checks jsonb NOT NULL DEFAULT '{}'::jsonb,
  severity severity_level,
  medication jsonb NOT NULL DEFAULT '{}'::jsonb,
  follow_up_at timestamptz,
  notes text,
  operator_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  corrects_health_record_id uuid,
  correction_reason text,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_health_record_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_health_record_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_health_record_hamster
    FOREIGN KEY (owner_id, hamster_id)
    REFERENCES hamster(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_health_record_pup
    FOREIGN KEY (owner_id, pup_identity_id)
    REFERENCES pup_identity(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_health_record_litter
    FOREIGN KEY (owner_id, litter_id)
    REFERENCES litter(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_health_record_enclosure
    FOREIGN KEY (owner_id, enclosure_id)
    REFERENCES enclosure(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_health_record_correction
    FOREIGN KEY (owner_id, corrects_health_record_id)
    REFERENCES health_record(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT ck_health_record_subject CHECK (
    (subject_type = 'hamster' AND hamster_id IS NOT NULL
      AND pup_identity_id IS NULL AND litter_id IS NULL AND enclosure_id IS NULL)
    OR
    (subject_type = 'pup_identity' AND pup_identity_id IS NOT NULL
      AND hamster_id IS NULL AND litter_id IS NULL AND enclosure_id IS NULL)
    OR
    (subject_type = 'litter' AND litter_id IS NOT NULL
      AND hamster_id IS NULL AND pup_identity_id IS NULL AND enclosure_id IS NULL)
    OR
    (subject_type = 'enclosure' AND enclosure_id IS NOT NULL
      AND hamster_id IS NULL AND pup_identity_id IS NULL AND litter_id IS NULL)
  ),
  CONSTRAINT ck_health_record_follow_up CHECK (
    follow_up_at IS NULL OR follow_up_at >= observed_at
  ),
  CONSTRAINT ck_health_record_correction CHECK (
    corrects_health_record_id IS NULL OR correction_reason IS NOT NULL
  )
);

CREATE INDEX ix_health_record_hamster_time
  ON health_record (owner_id, hamster_id, observed_at DESC)
  WHERE hamster_id IS NOT NULL;

CREATE INDEX ix_health_record_pup_time
  ON health_record (owner_id, pup_identity_id, observed_at DESC)
  WHERE pup_identity_id IS NOT NULL;

CREATE INDEX ix_health_record_litter_time
  ON health_record (owner_id, litter_id, observed_at DESC)
  WHERE litter_id IS NOT NULL;

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

CREATE TABLE idempotency_record (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  idempotency_key varchar(200) NOT NULL,
  request_method varchar(12) NOT NULL,
  request_path varchar(500) NOT NULL,
  request_hash varchar(64) NOT NULL,
  status idempotency_status NOT NULL DEFAULT 'processing',
  resource_type varchar(80),
  resource_id uuid,
  response_status integer,
  response_body jsonb,
  locked_at timestamptz NOT NULL DEFAULT now(),
  completed_at timestamptz,
  expires_at timestamptz NOT NULL,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_idempotency_record_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT uq_idempotency_record_key UNIQUE (owner_id, idempotency_key),
  CONSTRAINT ck_idempotency_record_response CHECK (
    status = 'processing' OR response_status IS NOT NULL
  ),
  CONSTRAINT ck_idempotency_record_expiry CHECK (expires_at > created_at)
);

CREATE INDEX ix_idempotency_record_expiry
  ON idempotency_record (expires_at);

-- ---------------------------------------------------------------------------
-- 通用审计、乐观锁与不可变事实
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION bump_row_version()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.version := OLD.version + 1;
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;

DO $$
DECLARE
  target_table text;
BEGIN
  FOREACH target_table IN ARRAY ARRAY[
    'account', 'organization', 'species_rule_version', 'outbox_message',
    'async_job', 'media_asset', 'media_variant', 'enclosure', 'hamster',
    'breeding_plan', 'pairing_attempt', 'enclosure_stay', 'mating_observation',
    'litter', 'pup_identity', 'relationship_assertion', 'pedigree_parentage',
    'litter_parent', 'litter_member', 'care_task', 'care_task_subject',
    'reminder_delivery', 'media_link', 'share_page', 'import_job', 'import_row',
    'export_job', 'backup_job', 'entitlement', 'usage_meter', 'idempotency_record'
  ]
  LOOP
    EXECUTE format(
      'CREATE TRIGGER %I BEFORE UPDATE ON %I FOR EACH ROW EXECUTE FUNCTION bump_row_version()',
      'trg_' || target_table || '_version',
      target_table
    );
  END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION reject_fact_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  RAISE EXCEPTION USING
    ERRCODE = '55000',
    MESSAGE = format('%I is append-only; write a correction fact instead', TG_TABLE_NAME);
END;
$$;

CREATE TRIGGER trg_domain_event_immutable
  BEFORE UPDATE OR DELETE ON domain_event
  FOR EACH ROW EXECUTE FUNCTION reject_fact_mutation();

CREATE TRIGGER trg_litter_count_event_immutable
  BEFORE UPDATE OR DELETE ON litter_count_event
  FOR EACH ROW EXECUTE FUNCTION reject_fact_mutation();

CREATE TRIGGER trg_weight_record_immutable
  BEFORE UPDATE OR DELETE ON weight_record
  FOR EACH ROW EXECUTE FUNCTION reject_fact_mutation();

CREATE TRIGGER trg_health_record_immutable
  BEFORE UPDATE OR DELETE ON health_record
  FOR EACH ROW EXECUTE FUNCTION reject_fact_mutation();

CREATE TRIGGER trg_enclosure_cleaning_record_immutable
  BEFORE UPDATE OR DELETE ON enclosure_cleaning_record
  FOR EACH ROW EXECUTE FUNCTION reject_fact_mutation();

CREATE TRIGGER trg_import_issue_immutable
  BEFORE UPDATE OR DELETE ON import_issue
  FOR EACH ROW EXECUTE FUNCTION reject_fact_mutation();

CREATE TRIGGER trg_usage_snapshot_immutable
  BEFORE UPDATE OR DELETE ON usage_snapshot
  FOR EACH ROW EXECUTE FUNCTION reject_fact_mutation();

-- ---------------------------------------------------------------------------
-- 系统/舍主规则版本归属
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION validate_species_rule_owner()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  rule_owner uuid;
  rule_scope dictionary_scope;
BEGIN
  IF NEW.species_rule_version_id IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT owner_id, scope
    INTO rule_owner, rule_scope
  FROM species_rule_version
  WHERE id = NEW.species_rule_version_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION USING ERRCODE = '23503', MESSAGE = 'species rule version not found';
  END IF;

  IF rule_scope = 'owner' AND rule_owner IS DISTINCT FROM NEW.owner_id THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'owner rule belongs to another owner';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_hamster_species_rule_owner
  BEFORE INSERT OR UPDATE OF owner_id, species_rule_version_id ON hamster
  FOR EACH ROW EXECUTE FUNCTION validate_species_rule_owner();

CREATE TRIGGER trg_breeding_plan_species_rule_owner
  BEFORE INSERT OR UPDATE OF owner_id, species_rule_version_id ON breeding_plan
  FOR EACH ROW EXECUTE FUNCTION validate_species_rule_owner();

CREATE TRIGGER trg_weight_record_species_rule_owner
  BEFORE INSERT ON weight_record
  FOR EACH ROW EXECUTE FUNCTION validate_species_rule_owner();

CREATE OR REPLACE FUNCTION validate_species_rule_copy_owner()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  source_owner uuid;
  source_scope dictionary_scope;
BEGIN
  IF NEW.copied_from_id IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT owner_id, scope INTO source_owner, source_scope
  FROM species_rule_version
  WHERE id = NEW.copied_from_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION USING ERRCODE = '23503', MESSAGE = 'copied species rule version not found';
  END IF;

  IF NEW.scope <> 'owner' OR NEW.owner_id IS NULL THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'only owner rules may copy another rule version';
  END IF;

  IF source_scope = 'owner' AND source_owner IS DISTINCT FROM NEW.owner_id THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'cannot copy another owner species rule';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_species_rule_copy_owner
  BEFORE INSERT OR UPDATE OF owner_id, scope, copied_from_id ON species_rule_version
  FOR EACH ROW EXECUTE FUNCTION validate_species_rule_copy_owner();

-- ---------------------------------------------------------------------------
-- 多态目标的 owner_id 一致性
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION owned_target_exists(
  p_owner_id uuid,
  p_target_type text,
  p_target_id uuid
)
RETURNS boolean
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  found_target boolean;
BEGIN
  CASE p_target_type
    WHEN 'organization' THEN
      SELECT EXISTS (SELECT 1 FROM organization WHERE owner_id = p_owner_id AND id = p_target_id)
        INTO found_target;
    WHEN 'hamster' THEN
      SELECT EXISTS (SELECT 1 FROM hamster WHERE owner_id = p_owner_id AND id = p_target_id)
        INTO found_target;
    WHEN 'litter' THEN
      SELECT EXISTS (SELECT 1 FROM litter WHERE owner_id = p_owner_id AND id = p_target_id)
        INTO found_target;
    WHEN 'enclosure' THEN
      SELECT EXISTS (SELECT 1 FROM enclosure WHERE owner_id = p_owner_id AND id = p_target_id)
        INTO found_target;
    WHEN 'breeding_plan' THEN
      SELECT EXISTS (SELECT 1 FROM breeding_plan WHERE owner_id = p_owner_id AND id = p_target_id)
        INTO found_target;
    WHEN 'pairing_attempt' THEN
      SELECT EXISTS (SELECT 1 FROM pairing_attempt WHERE owner_id = p_owner_id AND id = p_target_id)
        INTO found_target;
    WHEN 'pup_identity' THEN
      SELECT EXISTS (SELECT 1 FROM pup_identity WHERE owner_id = p_owner_id AND id = p_target_id)
        INTO found_target;
    WHEN 'health_record' THEN
      SELECT EXISTS (SELECT 1 FROM health_record WHERE owner_id = p_owner_id AND id = p_target_id)
        INTO found_target;
    WHEN 'mating_observation' THEN
      SELECT EXISTS (SELECT 1 FROM mating_observation WHERE owner_id = p_owner_id AND id = p_target_id)
        INTO found_target;
    WHEN 'domain_event' THEN
      SELECT EXISTS (SELECT 1 FROM domain_event WHERE owner_id = p_owner_id AND id = p_target_id)
        INTO found_target;
    WHEN 'share_page' THEN
      SELECT EXISTS (SELECT 1 FROM share_page WHERE owner_id = p_owner_id AND id = p_target_id)
        INTO found_target;
    WHEN 'weight_record' THEN
      SELECT EXISTS (SELECT 1 FROM weight_record WHERE owner_id = p_owner_id AND id = p_target_id)
        INTO found_target;
    WHEN 'relationship_assertion' THEN
      SELECT EXISTS (SELECT 1 FROM relationship_assertion WHERE owner_id = p_owner_id AND id = p_target_id)
        INTO found_target;
    ELSE
      found_target := false;
  END CASE;

  RETURN COALESCE(found_target, false);
END;
$$;

CREATE OR REPLACE FUNCTION validate_relationship_assertion_targets()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.subject_type <> 'external_reference'
    AND NOT owned_target_exists(NEW.owner_id, NEW.subject_type::text, NEW.subject_id) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'relationship assertion subject is outside owner scope or missing';
  END IF;

  IF NEW.related_type <> 'external_reference'
    AND NOT owned_target_exists(NEW.owner_id, NEW.related_type::text, NEW.related_id) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'relationship assertion related target is outside owner scope or missing';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_relationship_assertion_targets
  BEFORE INSERT OR UPDATE OF owner_id, subject_type, subject_id, related_type, related_id
  ON relationship_assertion
  FOR EACH ROW EXECUTE FUNCTION validate_relationship_assertion_targets();

CREATE OR REPLACE FUNCTION validate_care_task_target()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NOT owned_target_exists(NEW.owner_id, NEW.target_type::text, NEW.target_id) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'care task target is outside owner scope or missing';
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_care_task_target_owner
  BEFORE INSERT OR UPDATE OF owner_id, target_type, target_id ON care_task
  FOR EACH ROW EXECUTE FUNCTION validate_care_task_target();

CREATE OR REPLACE FUNCTION validate_care_task_subject_target()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NOT owned_target_exists(NEW.owner_id, NEW.subject_type::text, NEW.subject_id) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'care task subject is outside owner scope or missing';
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_care_task_subject_owner
  BEFORE INSERT OR UPDATE OF owner_id, subject_type, subject_id ON care_task_subject
  FOR EACH ROW EXECUTE FUNCTION validate_care_task_subject_target();

CREATE OR REPLACE FUNCTION validate_media_link_target()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  variant_asset_id uuid;
BEGIN
  IF NOT owned_target_exists(NEW.owner_id, NEW.target_type::text, NEW.target_id) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'media target is outside owner scope or missing';
  END IF;

  IF NEW.media_variant_id IS NOT NULL THEN
    SELECT media_asset_id INTO variant_asset_id
    FROM media_variant
    WHERE owner_id = NEW.owner_id AND id = NEW.media_variant_id;

    IF variant_asset_id IS DISTINCT FROM NEW.media_asset_id THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'media variant does not belong to media asset';
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_media_link_target_owner
  BEFORE INSERT OR UPDATE OF owner_id, target_type, target_id, media_asset_id, media_variant_id
  ON media_link
  FOR EACH ROW EXECUTE FUNCTION validate_media_link_target();

CREATE OR REPLACE FUNCTION validate_share_page_target()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NOT owned_target_exists(NEW.owner_id, NEW.target_type::text, NEW.target_id) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'share target is outside owner scope or missing';
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_share_page_target_owner
  BEFORE INSERT OR UPDATE OF owner_id, target_type, target_id ON share_page
  FOR EACH ROW EXECUTE FUNCTION validate_share_page_target();

-- ---------------------------------------------------------------------------
-- 配对与笼盒并发约束
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION validate_pairing_attempt_participants()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  plan_sire uuid;
  plan_dam uuid;
BEGIN
  SELECT sire_id, dam_id
    INTO plan_sire, plan_dam
  FROM breeding_plan
  WHERE owner_id = NEW.owner_id AND id = NEW.breeding_plan_id;

  IF plan_sire IS DISTINCT FROM NEW.sire_id OR plan_dam IS DISTINCT FROM NEW.dam_id THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'pairing participants must match breeding plan parents';
  END IF;

  PERFORM 1
  FROM hamster
  WHERE owner_id = NEW.owner_id AND id IN (NEW.sire_id, NEW.dam_id)
  ORDER BY id
  FOR UPDATE;

  IF NEW.status IN ('active', 'safety_hold') AND EXISTS (
    SELECT 1
    FROM pairing_attempt pa
    WHERE pa.owner_id = NEW.owner_id
      AND pa.id <> NEW.id
      AND pa.deleted_at IS NULL
      AND pa.status IN ('active', 'safety_hold')
      AND (
        pa.sire_id IN (NEW.sire_id, NEW.dam_id)
        OR pa.dam_id IN (NEW.sire_id, NEW.dam_id)
      )
  ) THEN
    RAISE EXCEPTION USING ERRCODE = '23P01', MESSAGE = 'hamster already participates in another active pairing attempt';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_pairing_attempt_participants
  BEFORE INSERT OR UPDATE OF owner_id, breeding_plan_id, sire_id, dam_id, status
  ON pairing_attempt
  FOR EACH ROW EXECUTE FUNCTION validate_pairing_attempt_participants();

CREATE OR REPLACE FUNCTION validate_enclosure_stay_period()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  enclosure_capacity integer;
  overlapping_count integer;
  pairing_record pairing_attempt%ROWTYPE;
BEGIN
  IF NEW.deleted_at IS NOT NULL THEN
    RETURN NEW;
  END IF;

  SELECT capacity INTO enclosure_capacity
  FROM enclosure
  WHERE owner_id = NEW.owner_id AND id = NEW.enclosure_id
  FOR UPDATE;

  PERFORM 1 FROM hamster
  WHERE owner_id = NEW.owner_id AND id = NEW.hamster_id
  FOR UPDATE;

  IF EXISTS (
    SELECT 1
    FROM enclosure_stay es
    WHERE es.owner_id = NEW.owner_id
      AND es.hamster_id = NEW.hamster_id
      AND es.id <> NEW.id
      AND es.deleted_at IS NULL
      AND tstzrange(es.started_at, es.ended_at, '[)')
          && tstzrange(NEW.started_at, NEW.ended_at, '[)')
  ) THEN
    RAISE EXCEPTION USING ERRCODE = '23P01', MESSAGE = 'hamster has an overlapping enclosure stay';
  END IF;

  SELECT count(*) INTO overlapping_count
  FROM enclosure_stay es
  WHERE es.owner_id = NEW.owner_id
    AND es.enclosure_id = NEW.enclosure_id
    AND es.id <> NEW.id
    AND es.deleted_at IS NULL
    AND tstzrange(es.started_at, es.ended_at, '[)')
        && tstzrange(NEW.started_at, NEW.ended_at, '[)');

  IF NEW.purpose = 'pairing_temp' THEN
    SELECT * INTO pairing_record
    FROM pairing_attempt
    WHERE owner_id = NEW.owner_id AND id = NEW.pairing_attempt_id
    FOR UPDATE;

    IF pairing_record.id IS NULL
      OR pairing_record.pairing_enclosure_id <> NEW.enclosure_id
      OR NEW.hamster_id NOT IN (pairing_record.sire_id, pairing_record.dam_id)
      OR pairing_record.status NOT IN ('active', 'safety_hold') THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'pairing stay is not authorized by an active pairing attempt';
    END IF;

    IF EXISTS (
      SELECT 1
      FROM enclosure_stay es
      WHERE es.owner_id = NEW.owner_id
        AND es.enclosure_id = NEW.enclosure_id
        AND es.id <> NEW.id
        AND es.deleted_at IS NULL
        AND tstzrange(es.started_at, es.ended_at, '[)')
            && tstzrange(NEW.started_at, NEW.ended_at, '[)')
        AND (es.purpose <> 'pairing_temp' OR es.pairing_attempt_id <> NEW.pairing_attempt_id)
    ) THEN
      RAISE EXCEPTION USING ERRCODE = '23P01', MESSAGE = 'pairing enclosure overlaps another occupancy';
    END IF;

    IF overlapping_count >= LEAST(enclosure_capacity, 2) THEN
      RAISE EXCEPTION USING ERRCODE = '23P01', MESSAGE = 'pairing enclosure capacity exceeded';
    END IF;
  ELSIF overlapping_count > 0 THEN
    RAISE EXCEPTION USING ERRCODE = '23P01', MESSAGE = 'enclosure has an overlapping occupancy';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_enclosure_stay_period
  BEFORE INSERT OR UPDATE OF owner_id, enclosure_id, hamster_id, pairing_attempt_id,
    purpose, started_at, ended_at, deleted_at
  ON enclosure_stay
  FOR EACH ROW EXECUTE FUNCTION validate_enclosure_stay_period();

-- ---------------------------------------------------------------------------
-- 谱系循环、关系纠正与个体化一致性
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION validate_breeding_plan_parents()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  sire_record hamster%ROWTYPE;
  dam_record hamster%ROWTYPE;
BEGIN
  SELECT * INTO sire_record
  FROM hamster
  WHERE owner_id = NEW.owner_id AND id = NEW.sire_id;

  SELECT * INTO dam_record
  FROM hamster
  WHERE owner_id = NEW.owner_id AND id = NEW.dam_id;

  IF sire_record.id IS NULL OR dam_record.id IS NULL THEN
    RAISE EXCEPTION USING ERRCODE = '23503', MESSAGE = 'breeding plan parent not found in owner scope';
  END IF;

  IF sire_record.organization_id <> NEW.organization_id
    OR dam_record.organization_id <> NEW.organization_id THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'breeding plan parents must belong to plan organization';
  END IF;

  IF NEW.state <> 'draft' THEN
    IF sire_record.sex = 'female' OR dam_record.sex = 'male' THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'breeding plan parent sex conflicts with sire/dam role';
    END IF;

    IF (sire_record.sex = 'unknown' OR dam_record.sex = 'unknown')
      AND NULLIF(btrim(NEW.eligibility_override_reason), '') IS NULL THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'unknown parent sex requires an explicit eligibility override reason';
    END IF;

    IF sire_record.lifecycle_status <> 'active' OR dam_record.lifecycle_status <> 'active' THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'breeding plan parents must be active';
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_breeding_plan_parent_guard
  BEFORE INSERT OR UPDATE OF owner_id, organization_id, sire_id, dam_id, state,
    eligibility_override_reason
  ON breeding_plan
  FOR EACH ROW EXECUTE FUNCTION validate_breeding_plan_parents();

CREATE OR REPLACE FUNCTION prevent_pedigree_cycle()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.status <> 'accepted' OR NEW.valid_to IS NOT NULL THEN
    RETURN NEW;
  END IF;

  IF NEW.parent_id = NEW.child_id THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'pedigree parent cannot equal child';
  END IF;

  IF EXISTS (
    WITH RECURSIVE descendants(hamster_id) AS (
      SELECT pp.child_id
      FROM pedigree_parentage pp
      WHERE pp.owner_id = NEW.owner_id
        AND pp.parent_id = NEW.child_id
        AND pp.status = 'accepted'
        AND pp.valid_to IS NULL
        AND pp.id <> NEW.id
      UNION
      SELECT pp.child_id
      FROM pedigree_parentage pp
      JOIN descendants d ON pp.parent_id = d.hamster_id
      WHERE pp.owner_id = NEW.owner_id
        AND pp.status = 'accepted'
        AND pp.valid_to IS NULL
        AND pp.id <> NEW.id
    )
    SELECT 1 FROM descendants WHERE hamster_id = NEW.parent_id
  ) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'pedigree cycle detected';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_pedigree_parentage_cycle
  BEFORE INSERT OR UPDATE OF owner_id, parent_id, child_id, status, valid_to
  ON pedigree_parentage
  FOR EACH ROW EXECUTE FUNCTION prevent_pedigree_cycle();

CREATE OR REPLACE FUNCTION validate_litter_parent_role()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  litter_record litter%ROWTYPE;
  parent_sex sex_code;
  expected_parent_id uuid;
BEGIN
  SELECT * INTO litter_record
  FROM litter
  WHERE owner_id = NEW.owner_id AND id = NEW.litter_id;

  SELECT sex INTO parent_sex
  FROM hamster
  WHERE owner_id = NEW.owner_id AND id = NEW.parent_id;

  IF litter_record.id IS NULL OR parent_sex IS NULL THEN
    RAISE EXCEPTION USING ERRCODE = '23503', MESSAGE = 'litter or parent not found in owner scope';
  END IF;

  IF (NEW.role = 'sire' AND parent_sex = 'female')
    OR (NEW.role = 'dam' AND parent_sex = 'male') THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'litter parent sex conflicts with sire/dam role';
  END IF;

  IF parent_sex = 'unknown'
    AND NOT (NEW.evidence_payload @> '{"sex_role_reviewed": true}'::jsonb) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'unknown litter parent sex requires sex_role_reviewed evidence';
  END IF;

  IF litter_record.origin = 'breeding' THEN
    SELECT CASE NEW.role WHEN 'sire' THEN sire_id ELSE dam_id END
      INTO expected_parent_id
    FROM breeding_plan
    WHERE owner_id = NEW.owner_id AND id = litter_record.breeding_plan_id;

    IF expected_parent_id IS DISTINCT FROM NEW.parent_id THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'breeding litter parent must match breeding plan parent';
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_litter_parent_role
  BEFORE INSERT OR UPDATE OF owner_id, litter_id, parent_id, role, evidence_payload
  ON litter_parent
  FOR EACH ROW EXECUTE FUNCTION validate_litter_parent_role();

CREATE OR REPLACE FUNCTION validate_litter_member_consistency()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  member_litter_id uuid;
  member_litter_origin litter_origin;
BEGIN
  SELECT origin INTO member_litter_origin
  FROM litter
  WHERE owner_id = NEW.owner_id AND id = NEW.litter_id;

  IF member_litter_origin IS NULL THEN
    RAISE EXCEPTION USING ERRCODE = '23503', MESSAGE = 'litter member litter not found in owner scope';
  END IF;

  IF NEW.pup_identity_id IS NOT NULL THEN
    SELECT litter_id INTO member_litter_id
    FROM pup_identity
    WHERE owner_id = NEW.owner_id AND id = NEW.pup_identity_id;

    IF member_litter_id IS DISTINCT FROM NEW.litter_id THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'pup identity belongs to another litter';
    END IF;
  END IF;

  IF NEW.origin_pup_identity_id IS NOT NULL THEN
    SELECT litter_id INTO member_litter_id
    FROM pup_identity
    WHERE owner_id = NEW.owner_id AND id = NEW.origin_pup_identity_id;

    IF member_litter_id IS DISTINCT FROM NEW.litter_id THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'origin pup identity belongs to another litter';
    END IF;
  END IF;

  IF member_litter_origin = 'import'
    AND (NEW.member_type <> 'hamster' OR NEW.origin_pup_identity_id IS NOT NULL) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'imported historical litter accepts formal hamster members only';
  END IF;

  IF member_litter_origin = 'breeding'
    AND NEW.member_type = 'hamster'
    AND NEW.origin_pup_identity_id IS NULL THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'breeding litter hamster member requires origin pup identity';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_litter_member_consistency
  BEFORE INSERT OR UPDATE OF owner_id, litter_id, pup_identity_id, origin_pup_identity_id
  ON litter_member
  FOR EACH ROW EXECUTE FUNCTION validate_litter_member_consistency();

CREATE OR REPLACE FUNCTION validate_pup_individualization_transition()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  litter_record litter%ROWTYPE;
  hamster_record hamster%ROWTYPE;
  plan_rule_id uuid;
BEGIN
  IF TG_OP = 'UPDATE'
    AND OLD.profile_status = 'individualized'
    AND NEW.profile_status <> 'individualized' THEN
    RAISE EXCEPTION USING ERRCODE = '55000', MESSAGE = 'individualized pup identity cannot return to an unindividualized state';
  END IF;

  IF NEW.profile_status <> 'individualized'
    OR (TG_OP = 'UPDATE' AND OLD.profile_status = 'individualized') THEN
    RETURN NEW;
  END IF;

  SELECT * INTO litter_record
  FROM litter
  WHERE owner_id = NEW.owner_id AND id = NEW.litter_id;

  SELECT * INTO hamster_record
  FROM hamster
  WHERE owner_id = NEW.owner_id AND id = NEW.individualized_hamster_id;

  IF litter_record.id IS NULL OR hamster_record.id IS NULL THEN
    RAISE EXCEPTION USING ERRCODE = '23503', MESSAGE = 'individualization litter or hamster not found in owner scope';
  END IF;

  IF litter_record.origin <> 'breeding' OR litter_record.state <> 'individualizing' THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'pup identities may be individualized only in an individualizing breeding litter';
  END IF;

  IF NEW.outcome_status <> 'alive' OR NEW.weaned_at IS NULL
    OR NEW.sex = 'unknown' OR NEW.current_enclosure_id IS NULL
    OR litter_record.sex_separation_completed_at IS NULL THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'pup identity is not eligible for individualization';
  END IF;

  IF hamster_record.organization_id <> litter_record.organization_id
    OR hamster_record.sex <> NEW.sex
    OR hamster_record.current_enclosure_id IS DISTINCT FROM NEW.current_enclosure_id
    OR hamster_record.source_type <> 'born_here' THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'individualized hamster does not match pup identity facts';
  END IF;

  IF litter_record.born_at IS NOT NULL
    AND hamster_record.birth_date IS DISTINCT FROM litter_record.born_at::date THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'individualized hamster birth date must match litter';
  END IF;

  SELECT species_rule_version_id INTO plan_rule_id
  FROM breeding_plan
  WHERE owner_id = NEW.owner_id AND id = litter_record.breeding_plan_id;

  IF hamster_record.species_rule_version_id IS DISTINCT FROM plan_rule_id THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'individualized hamster species rule must match breeding plan snapshot';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_pup_identity_individualization_guard
  BEFORE INSERT OR UPDATE OF owner_id, litter_id, profile_status, outcome_status,
    weaned_at, sex, current_enclosure_id, individualized_hamster_id
  ON pup_identity
  FOR EACH ROW EXECUTE FUNCTION validate_pup_individualization_transition();

CREATE OR REPLACE FUNCTION prevent_pup_identity_rekey()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.owner_id <> OLD.owner_id
    OR NEW.litter_id <> OLD.litter_id
    OR NEW.temporary_code <> OLD.temporary_code THEN
    RAISE EXCEPTION USING ERRCODE = '55000', MESSAGE = 'pup identity owner, litter and temporary code are immutable';
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_pup_identity_rekey
  BEFORE UPDATE ON pup_identity
  FOR EACH ROW EXECUTE FUNCTION prevent_pup_identity_rekey();

CREATE OR REPLACE FUNCTION reject_pup_identity_delete()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  RAISE EXCEPTION USING ERRCODE = '55000', MESSAGE = 'pup identity cannot be hard-deleted; use voided status and correction event';
END;
$$;

CREATE TRIGGER trg_pup_identity_no_delete
  BEFORE DELETE ON pup_identity
  FOR EACH ROW EXECUTE FUNCTION reject_pup_identity_delete();

-- ---------------------------------------------------------------------------
-- 窝次数量流水与身份闭合
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION refresh_litter_count_cache(p_litter_id uuid)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  v_initial integer;
  v_discovered integer;
  v_deceased integer;
  v_transferred integer;
  v_correction integer;
  v_unindividualized integer;
  v_individualized integer;
  v_imported_formal integer;
  v_current integer;
BEGIN
  SELECT
    COALESCE(sum(delta) FILTER (WHERE event_type = 'initial_alive'), 0)::integer,
    COALESCE(sum(delta) FILTER (WHERE event_type = 'discovered'), 0)::integer,
    COALESCE(-sum(delta) FILTER (WHERE event_type = 'death'), 0)::integer,
    COALESCE(-sum(delta) FILTER (WHERE event_type = 'transferred_out'), 0)::integer,
    COALESCE(sum(delta) FILTER (WHERE event_type = 'correction'), 0)::integer
  INTO v_initial, v_discovered, v_deceased, v_transferred, v_correction
  FROM litter_count_event
  WHERE litter_id = p_litter_id;

  SELECT
    count(*) FILTER (
      WHERE profile_status = 'unindividualized' AND outcome_status = 'alive'
    )::integer,
    count(*) FILTER (
      WHERE profile_status = 'individualized' AND outcome_status = 'alive'
    )::integer
  INTO v_unindividualized, v_individualized
  FROM pup_identity
  WHERE litter_id = p_litter_id AND deleted_at IS NULL;

  SELECT count(*)::integer INTO v_imported_formal
  FROM litter_member
  WHERE litter_id = p_litter_id
    AND member_type = 'hamster'
    AND origin_pup_identity_id IS NULL
    AND status = 'accepted'
    AND valid_to IS NULL;

  v_individualized := v_individualized + v_imported_formal;

  v_current := v_initial + v_discovered - v_deceased - v_transferred + v_correction;

  IF v_current < 0 THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'litter managed count cannot be negative';
  END IF;

  UPDATE litter
  SET initial_alive_count = v_initial,
      discovered_count = v_discovered,
      deceased_count = v_deceased,
      transferred_out_count = v_transferred,
      correction_delta = v_correction,
      current_managed_count = v_current,
      unindividualized_alive_count = v_unindividualized,
      individualized_alive_count = v_individualized
  WHERE id = p_litter_id;
END;
$$;

CREATE OR REPLACE FUNCTION refresh_litter_count_cache_trigger()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  new_litter_id uuid;
  old_litter_id uuid;
BEGIN
  IF TG_OP <> 'DELETE' THEN
    new_litter_id := NEW.litter_id;
    PERFORM refresh_litter_count_cache(new_litter_id);
  END IF;

  IF TG_OP <> 'INSERT' THEN
    old_litter_id := OLD.litter_id;
    IF old_litter_id IS DISTINCT FROM new_litter_id THEN
      PERFORM refresh_litter_count_cache(old_litter_id);
    END IF;
  END IF;

  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_litter_count_event_refresh
  AFTER INSERT ON litter_count_event
  FOR EACH ROW EXECUTE FUNCTION refresh_litter_count_cache_trigger();

CREATE TRIGGER trg_pup_identity_count_refresh
  AFTER INSERT OR UPDATE ON pup_identity
  FOR EACH ROW EXECUTE FUNCTION refresh_litter_count_cache_trigger();

CREATE TRIGGER trg_litter_member_count_refresh
  AFTER INSERT OR UPDATE OR DELETE ON litter_member
  FOR EACH ROW EXECUTE FUNCTION refresh_litter_count_cache_trigger();

CREATE OR REPLACE FUNCTION assert_litter_balance(p_litter_id uuid)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  litter_record litter%ROWTYPE;
  v_initial_event_count integer;
  v_initial integer;
  v_discovered integer;
  v_deceased integer;
  v_transferred integer;
  v_correction integer;
  v_expected integer;
  v_unindividualized integer;
  v_individualized integer;
  v_imported_formal integer;
  v_parent_roles integer;
  v_parent_count integer;
BEGIN
  SELECT * INTO litter_record FROM litter WHERE id = p_litter_id;
  IF NOT FOUND OR litter_record.state = 'voided' OR litter_record.deleted_at IS NOT NULL THEN
    RETURN;
  END IF;

  SELECT
    count(*) FILTER (WHERE event_type = 'initial_alive')::integer,
    COALESCE(sum(delta) FILTER (WHERE event_type = 'initial_alive'), 0)::integer,
    COALESCE(sum(delta) FILTER (WHERE event_type = 'discovered'), 0)::integer,
    COALESCE(-sum(delta) FILTER (WHERE event_type = 'death'), 0)::integer,
    COALESCE(-sum(delta) FILTER (WHERE event_type = 'transferred_out'), 0)::integer,
    COALESCE(sum(delta) FILTER (WHERE event_type = 'correction'), 0)::integer
  INTO v_initial_event_count, v_initial, v_discovered, v_deceased, v_transferred, v_correction
  FROM litter_count_event
  WHERE owner_id = litter_record.owner_id AND litter_id = p_litter_id;

  IF v_initial_event_count <> 1 THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'effective litter must have exactly one initial_alive event';
  END IF;

  v_expected := v_initial + v_discovered - v_deceased - v_transferred + v_correction;

  SELECT
    count(*) FILTER (
      WHERE profile_status = 'unindividualized' AND outcome_status = 'alive'
    )::integer,
    count(*) FILTER (
      WHERE profile_status = 'individualized' AND outcome_status = 'alive'
    )::integer
  INTO v_unindividualized, v_individualized
  FROM pup_identity
  WHERE owner_id = litter_record.owner_id
    AND litter_id = p_litter_id
    AND deleted_at IS NULL;

  SELECT count(*)::integer INTO v_imported_formal
  FROM litter_member
  WHERE owner_id = litter_record.owner_id
    AND litter_id = p_litter_id
    AND member_type = 'hamster'
    AND origin_pup_identity_id IS NULL
    AND status = 'accepted'
    AND valid_to IS NULL;

  v_individualized := v_individualized + v_imported_formal;

  IF v_initial <= 0 THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'effective litter initial_alive count must be greater than zero';
  END IF;

  IF v_expected < 0 OR v_expected <> v_unindividualized + v_individualized THEN
    RAISE EXCEPTION USING
      ERRCODE = '23514',
      MESSAGE = format(
        'litter count mismatch: expected=%s, unindividualized=%s, individualized=%s',
        v_expected, v_unindividualized, v_individualized
      );
  END IF;

  IF litter_record.origin = 'breeding' AND v_imported_formal > 0 THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'breeding litter formal members require origin pup identities';
  END IF;

  IF litter_record.origin = 'import' AND EXISTS (
    SELECT 1 FROM pup_identity
    WHERE owner_id = litter_record.owner_id
      AND litter_id = p_litter_id
      AND deleted_at IS NULL
  ) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'imported historical litter cannot contain pup identities';
  END IF;

  IF litter_record.origin = 'breeding'
    AND v_unindividualized > 0 AND v_individualized > 0 THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'partial individualization is not supported';
  END IF;

  IF litter_record.initial_alive_count <> v_initial
    OR litter_record.discovered_count <> v_discovered
    OR litter_record.deceased_count <> v_deceased
    OR litter_record.transferred_out_count <> v_transferred
    OR litter_record.correction_delta <> v_correction
    OR litter_record.current_managed_count <> v_expected
    OR litter_record.unindividualized_alive_count <> v_unindividualized
    OR litter_record.individualized_alive_count <> v_individualized THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'litter count cache is inconsistent with immutable facts';
  END IF;

  SELECT count(DISTINCT role)::integer, count(DISTINCT parent_id)::integer
    INTO v_parent_roles, v_parent_count
  FROM litter_parent
  WHERE owner_id = litter_record.owner_id
    AND litter_id = p_litter_id
    AND status = 'accepted'
    AND valid_to IS NULL;

  IF v_parent_roles <> 2 OR v_parent_count <> 2 THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'effective litter must have distinct active sire and dam relationships';
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION deferred_assert_litter_balance()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  target_litter_id uuid;
BEGIN
  IF TG_TABLE_NAME = 'litter' THEN
    target_litter_id := COALESCE(NEW.id, OLD.id);
  ELSE
    target_litter_id := COALESCE(NEW.litter_id, OLD.litter_id);
  END IF;

  PERFORM assert_litter_balance(target_litter_id);
  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  END IF;
  RETURN NEW;
END;
$$;

CREATE CONSTRAINT TRIGGER trg_litter_balance_litter
  AFTER INSERT OR UPDATE ON litter
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION deferred_assert_litter_balance();

CREATE CONSTRAINT TRIGGER trg_litter_balance_event
  AFTER INSERT ON litter_count_event
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION deferred_assert_litter_balance();

CREATE CONSTRAINT TRIGGER trg_litter_balance_pup
  AFTER INSERT OR UPDATE ON pup_identity
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION deferred_assert_litter_balance();

CREATE CONSTRAINT TRIGGER trg_litter_balance_parent
  AFTER INSERT OR UPDATE OR DELETE ON litter_parent
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION deferred_assert_litter_balance();

CREATE OR REPLACE FUNCTION assert_pup_identity_links(p_pup_identity_id uuid)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  pup_record pup_identity%ROWTYPE;
  missing_parent_count integer;
BEGIN
  SELECT * INTO pup_record
  FROM pup_identity
  WHERE id = p_pup_identity_id;

  IF NOT FOUND OR pup_record.deleted_at IS NOT NULL OR pup_record.profile_status = 'voided' THEN
    RETURN;
  END IF;

  IF pup_record.profile_status = 'unindividualized'
    AND pup_record.outcome_status = 'alive'
    AND NOT EXISTS (
      SELECT 1 FROM litter_member lm
      WHERE lm.owner_id = pup_record.owner_id
        AND lm.litter_id = pup_record.litter_id
        AND lm.member_type = 'pup_identity'
        AND lm.pup_identity_id = pup_record.id
        AND lm.status = 'accepted'
        AND lm.valid_to IS NULL
    ) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'living unindividualized pup requires an active litter membership';
  END IF;

  IF pup_record.profile_status = 'individualized' THEN
    IF EXISTS (
      SELECT 1 FROM litter_member lm
      WHERE lm.owner_id = pup_record.owner_id
        AND lm.litter_id = pup_record.litter_id
        AND lm.member_type = 'pup_identity'
        AND lm.pup_identity_id = pup_record.id
        AND lm.status = 'accepted'
        AND lm.valid_to IS NULL
    ) THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'individualized pup cannot retain an active temporary litter membership';
    END IF;

    IF NOT EXISTS (
      SELECT 1 FROM litter_member lm
      WHERE lm.owner_id = pup_record.owner_id
        AND lm.litter_id = pup_record.litter_id
        AND lm.member_type = 'hamster'
        AND lm.hamster_id = pup_record.individualized_hamster_id
        AND lm.origin_pup_identity_id = pup_record.id
        AND lm.status = 'accepted'
        AND lm.valid_to IS NULL
    ) THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'individualized pup requires a one-to-one hamster litter membership';
    END IF;

    SELECT count(*)::integer INTO missing_parent_count
    FROM litter_parent lp
    WHERE lp.owner_id = pup_record.owner_id
      AND lp.litter_id = pup_record.litter_id
      AND lp.status = 'accepted'
      AND lp.valid_to IS NULL
      AND NOT EXISTS (
        SELECT 1 FROM pedigree_parentage pp
        WHERE pp.owner_id = lp.owner_id
          AND pp.parent_id = lp.parent_id
          AND pp.child_id = pup_record.individualized_hamster_id
          AND pp.role = lp.role
          AND pp.status = 'accepted'
          AND pp.valid_to IS NULL
      );

    IF missing_parent_count > 0 THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'individualized hamster is missing inherited pedigree parentage';
    END IF;
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION deferred_assert_pup_links_from_pup()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  PERFORM assert_pup_identity_links(COALESCE(NEW.id, OLD.id));
  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  END IF;
  RETURN NEW;
END;
$$;

CREATE CONSTRAINT TRIGGER trg_pup_links_pup
  AFTER INSERT OR UPDATE ON pup_identity
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION deferred_assert_pup_links_from_pup();

CREATE OR REPLACE FUNCTION deferred_assert_pup_links_from_member()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  target_pup_id uuid;
BEGIN
  target_pup_id := COALESCE(
    NEW.pup_identity_id, NEW.origin_pup_identity_id,
    OLD.pup_identity_id, OLD.origin_pup_identity_id
  );
  IF target_pup_id IS NOT NULL THEN
    PERFORM assert_pup_identity_links(target_pup_id);
  END IF;
  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  END IF;
  RETURN NEW;
END;
$$;

CREATE CONSTRAINT TRIGGER trg_pup_links_member
  AFTER INSERT OR UPDATE OR DELETE ON litter_member
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION deferred_assert_pup_links_from_member();

CREATE OR REPLACE FUNCTION deferred_assert_pup_links_from_parentage()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  target_child_id uuid;
  target_pup_id uuid;
BEGIN
  target_child_id := COALESCE(NEW.child_id, OLD.child_id);
  SELECT id INTO target_pup_id
  FROM pup_identity
  WHERE owner_id = COALESCE(NEW.owner_id, OLD.owner_id)
    AND individualized_hamster_id = target_child_id
    AND deleted_at IS NULL;

  IF target_pup_id IS NOT NULL THEN
    PERFORM assert_pup_identity_links(target_pup_id);
  END IF;
  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  END IF;
  RETURN NEW;
END;
$$;

CREATE CONSTRAINT TRIGGER trg_pup_links_parentage
  AFTER INSERT OR UPDATE OR DELETE ON pedigree_parentage
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION deferred_assert_pup_links_from_parentage();

CREATE OR REPLACE FUNCTION deferred_assert_pup_links_from_litter_parent()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  target_litter_id uuid;
  pup_id uuid;
BEGIN
  target_litter_id := COALESCE(NEW.litter_id, OLD.litter_id);
  FOR pup_id IN
    SELECT id FROM pup_identity
    WHERE litter_id = target_litter_id
      AND profile_status = 'individualized'
      AND deleted_at IS NULL
  LOOP
    PERFORM assert_pup_identity_links(pup_id);
  END LOOP;
  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  END IF;
  RETURN NEW;
END;
$$;

CREATE CONSTRAINT TRIGGER trg_pup_links_litter_parent
  AFTER INSERT OR UPDATE OR DELETE ON litter_parent
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION deferred_assert_pup_links_from_litter_parent();

CREATE OR REPLACE FUNCTION validate_litter_count_event_context()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  litter_born_at timestamptz;
  pup_litter_id uuid;
BEGIN
  SELECT born_at INTO litter_born_at
  FROM litter
  WHERE owner_id = NEW.owner_id AND id = NEW.litter_id;

  IF NEW.occurred_at < litter_born_at THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'litter count event cannot occur before birth';
  END IF;

  IF NEW.pup_identity_id IS NOT NULL THEN
    SELECT litter_id INTO pup_litter_id
    FROM pup_identity
    WHERE owner_id = NEW.owner_id AND id = NEW.pup_identity_id;

    IF pup_litter_id IS DISTINCT FROM NEW.litter_id THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'count event pup identity belongs to another litter';
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_litter_count_event_context
  BEFORE INSERT ON litter_count_event
  FOR EACH ROW EXECUTE FUNCTION validate_litter_count_event_context();

-- N>0 与 N=0 生产结果在提交时必须形成互斥且完整的事实分支。
CREATE OR REPLACE FUNCTION assert_breeding_plan_birth_branch(p_plan_id uuid)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  plan_record breeding_plan%ROWTYPE;
  v_litter_count integer;
  v_litter_initial integer;
  v_litter_other integer;
  v_live_event_count integer;
  v_no_live_event_count integer;
BEGIN
  SELECT * INTO plan_record FROM breeding_plan WHERE id = p_plan_id;
  IF NOT FOUND OR plan_record.deleted_at IS NOT NULL THEN
    RETURN;
  END IF;

  SELECT count(*)::integer,
         COALESCE(max(initial_alive_count), 0)::integer,
         COALESCE(max(initial_other_count), 0)::integer
    INTO v_litter_count, v_litter_initial, v_litter_other
  FROM litter
  WHERE owner_id = plan_record.owner_id
    AND breeding_plan_id = p_plan_id
    AND state <> 'voided'
    AND deleted_at IS NULL;

  SELECT
    count(*) FILTER (WHERE event_type = 'BIRTH_CONFIRMED')::integer,
    count(*) FILTER (WHERE event_type = 'BIRTH_CONFIRMED_NO_LIVE_PUPS')::integer
    INTO v_live_event_count, v_no_live_event_count
  FROM domain_event
  WHERE owner_id = plan_record.owner_id
    AND aggregate_type = 'breeding_plan'
    AND aggregate_id = p_plan_id
    AND reverted_at IS NULL;

  IF plan_record.state = 'no_litter_outcome' THEN
    IF v_litter_count <> 0 OR v_live_event_count <> 0 OR v_no_live_event_count <> 1 THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'no_litter_outcome must have one no-live-pups event and no litter';
    END IF;
  ELSIF plan_record.state IN (
    'litter_nursing', 'weaning_due', 'sex_separation_due', 'individualizing', 'completed'
  ) OR v_litter_count > 0 OR v_live_event_count > 0 THEN
    IF v_litter_count <> 1 OR v_live_event_count <> 1 OR v_no_live_event_count <> 0
      OR plan_record.actual_birth_at IS NULL
      OR plan_record.birth_result_alive_count IS NULL
      OR plan_record.birth_result_alive_count <= 0
      OR plan_record.birth_result_alive_count <> v_litter_initial
      OR plan_record.birth_result_other_count IS DISTINCT FROM v_litter_other THEN
      RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'live-birth branch must have one litter, one birth event and matching positive count';
    END IF;
  ELSIF v_no_live_event_count > 0 THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'no-live-pups event requires no_litter_outcome state';
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION deferred_assert_breeding_plan_birth_branch()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  target_plan_id uuid;
BEGIN
  IF TG_TABLE_NAME = 'breeding_plan' THEN
    target_plan_id := COALESCE(NEW.id, OLD.id);
  ELSIF TG_TABLE_NAME = 'litter' THEN
    target_plan_id := COALESCE(NEW.breeding_plan_id, OLD.breeding_plan_id);
  ELSIF COALESCE(NEW.aggregate_type, OLD.aggregate_type) = 'breeding_plan'
    AND COALESCE(NEW.event_type, OLD.event_type) IN ('BIRTH_CONFIRMED', 'BIRTH_CONFIRMED_NO_LIVE_PUPS') THEN
    target_plan_id := COALESCE(NEW.aggregate_id, OLD.aggregate_id);
  END IF;

  IF target_plan_id IS NOT NULL THEN
    PERFORM assert_breeding_plan_birth_branch(target_plan_id);
  END IF;
  IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
END;
$$;

CREATE CONSTRAINT TRIGGER trg_breeding_plan_birth_branch_plan
  AFTER INSERT OR UPDATE ON breeding_plan
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION deferred_assert_breeding_plan_birth_branch();

CREATE CONSTRAINT TRIGGER trg_breeding_plan_birth_branch_litter
  AFTER INSERT OR UPDATE OR DELETE ON litter
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION deferred_assert_breeding_plan_birth_branch();

CREATE CONSTRAINT TRIGGER trg_breeding_plan_birth_branch_event
  AFTER INSERT OR UPDATE OR DELETE ON domain_event
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION deferred_assert_breeding_plan_birth_branch();

-- 逐只任务的 stage_total/stage_done 是 care_task_subject 的缓存投影。
CREATE OR REPLACE FUNCTION refresh_care_task_progress(p_task_id uuid)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  v_total integer;
  v_done integer;
BEGIN
  SELECT count(*)::integer,
         count(*) FILTER (WHERE completed_at IS NOT NULL)::integer
    INTO v_total, v_done
  FROM care_task_subject
  WHERE care_task_id = p_task_id;

  UPDATE care_task
  SET stage_total = CASE WHEN v_total = 0 THEN NULL ELSE v_total END,
      stage_done = CASE WHEN v_total = 0 THEN NULL ELSE v_done END
  WHERE id = p_task_id;
END;
$$;

CREATE OR REPLACE FUNCTION refresh_care_task_progress_trigger()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  new_task_id uuid;
  old_task_id uuid;
BEGIN
  IF TG_OP <> 'DELETE' THEN
    new_task_id := NEW.care_task_id;
    PERFORM refresh_care_task_progress(new_task_id);
  END IF;

  IF TG_OP <> 'INSERT' THEN
    old_task_id := OLD.care_task_id;
    IF old_task_id IS DISTINCT FROM new_task_id THEN
      PERFORM refresh_care_task_progress(old_task_id);
    END IF;
  END IF;

  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_care_task_subject_progress
  AFTER INSERT OR UPDATE OR DELETE ON care_task_subject
  FOR EACH ROW EXECUTE FUNCTION refresh_care_task_progress_trigger();

CREATE INDEX ix_usage_snapshot_owner_time
  ON usage_snapshot (owner_id, snapshot_at DESC, metric);

CREATE INDEX ix_usage_meter_measured
  ON usage_meter (owner_id, measured_at DESC);

COMMENT ON TABLE pedigree_parentage IS
  '正式父母有向边；hamster 不保存 father_id/mother_id 作为唯一事实源。';
COMMENT ON TABLE relationship_assertion IS
  '导入或人工补录的关系断言；通过审核后投影为正式谱系/窝次关系。';
COMMENT ON TABLE litter_count_event IS
  '不可覆盖数量流水；initial/discovered 为正，death/transferred_out 为负，correction 为有原因的差值。';
COMMENT ON FUNCTION assert_litter_balance(uuid) IS
  '提交时验证 initial + discovered - death - transferred + correction = 未个体化存活 + 已个体化存活。';
COMMENT ON TABLE idempotency_record IS
  '通用写接口 Idempotency-Key 记录；相同 owner/key 复用首次响应。';
COMMENT ON COLUMN share_page.token_hash IS
  '仅保存随机公开令牌的摘要，原始令牌只在创建响应中返回一次。';

COMMIT;
