-- Generated from specs/database/schema.sql; do not edit this migration by hand.
BEGIN;

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

COMMIT;
