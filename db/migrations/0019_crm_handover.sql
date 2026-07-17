-- T-P1-02 customer / reservation / handover (minimal CRM).
BEGIN;

CREATE TYPE crm_contact_status AS ENUM ('lead', 'active', 'archived');
CREATE TYPE crm_reservation_status AS ENUM (
  'held',
  'confirmed',
  'cancelled',
  'handed_over'
);
CREATE TYPE crm_handover_status AS ENUM ('scheduled', 'completed', 'cancelled');

CREATE TABLE crm_contact (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  name varchar(120) NOT NULL,
  phone varchar(32),
  wechat varchar(64),
  notes text,
  status crm_contact_status NOT NULL DEFAULT 'lead',
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_crm_contact_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_crm_contact_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT
);

CREATE INDEX ix_crm_contact_owner_status
  ON crm_contact (owner_id, status, updated_at DESC);

CREATE TABLE crm_reservation (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  contact_id uuid NOT NULL,
  hamster_id uuid,
  title varchar(200) NOT NULL,
  status crm_reservation_status NOT NULL DEFAULT 'held',
  reserved_at timestamptz NOT NULL DEFAULT now(),
  notes text,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_crm_reservation_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_crm_reservation_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_crm_reservation_contact
    FOREIGN KEY (owner_id, contact_id)
    REFERENCES crm_contact(owner_id, id) ON DELETE RESTRICT
);

CREATE INDEX ix_crm_reservation_owner_status
  ON crm_reservation (owner_id, status, reserved_at DESC);

CREATE TABLE crm_handover (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  contact_id uuid NOT NULL,
  reservation_id uuid,
  hamster_id uuid,
  status crm_handover_status NOT NULL DEFAULT 'scheduled',
  scheduled_at timestamptz NOT NULL DEFAULT now(),
  completed_at timestamptz,
  notes text,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_crm_handover_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_crm_handover_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_crm_handover_contact
    FOREIGN KEY (owner_id, contact_id)
    REFERENCES crm_contact(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_crm_handover_reservation
    FOREIGN KEY (owner_id, reservation_id)
    REFERENCES crm_reservation(owner_id, id) ON DELETE SET NULL,
  CONSTRAINT ck_crm_handover_completed CHECK (
    (status = 'completed' AND completed_at IS NOT NULL)
    OR (status <> 'completed')
  )
);

CREATE INDEX ix_crm_handover_owner_status
  ON crm_handover (owner_id, status, scheduled_at DESC);

COMMIT;
