-- T-P2-02 lightweight miniprogram publish pipeline (sandbox audit chain).
BEGIN;

CREATE TYPE miniprogram_release_status AS ENUM (
  'draft',
  'submitted',
  'auditing',
  'approved',
  'rejected',
  'published',
  'rolled_back'
);

CREATE TABLE miniprogram_config (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  display_name varchar(80) NOT NULL DEFAULT '熊舍小程序',
  app_id varchar(64),
  bound_public_slug varchar(64),
  enabled boolean NOT NULL DEFAULT true,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_miniprogram_config_owner UNIQUE (owner_id),
  CONSTRAINT uq_miniprogram_config_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_miniprogram_config_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT
);

CREATE TABLE miniprogram_release (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  version_label varchar(32) NOT NULL,
  status miniprogram_release_status NOT NULL DEFAULT 'draft',
  title varchar(120) NOT NULL,
  summary text,
  public_slug varchar(64),
  audit_note text,
  submitted_at timestamptz,
  audited_at timestamptz,
  published_at timestamptz,
  rolled_back_at timestamptz,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_miniprogram_release_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT uq_miniprogram_release_owner_label UNIQUE (owner_id, version_label),
  CONSTRAINT fk_miniprogram_release_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT
);

CREATE INDEX ix_miniprogram_release_owner_status
  ON miniprogram_release (owner_id, status, created_at DESC);

-- At most one published release per owner (partial unique).
CREATE UNIQUE INDEX ux_miniprogram_release_one_published
  ON miniprogram_release (owner_id)
  WHERE status = 'published';

COMMIT;
