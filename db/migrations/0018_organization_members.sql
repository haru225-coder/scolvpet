-- T-P1-01 multi-member RBAC roster (organization-scoped invites/roles).
BEGIN;

CREATE TYPE organization_member_role AS ENUM (
  'owner',
  'breeder',
  'caretaker',
  'staff',
  'viewer'
);

CREATE TYPE organization_member_status AS ENUM (
  'invited',
  'active',
  'revoked'
);

CREATE TABLE organization_member (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  account_id uuid REFERENCES account(id) ON DELETE SET NULL,
  phone varchar(32) NOT NULL,
  display_name varchar(120),
  role organization_member_role NOT NULL DEFAULT 'viewer',
  status organization_member_status NOT NULL DEFAULT 'invited',
  invited_at timestamptz NOT NULL DEFAULT now(),
  accepted_at timestamptz,
  revoked_at timestamptz,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_organization_member_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_organization_member_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT ck_organization_member_phone CHECK (phone ~ '^[0-9]{6,20}$'),
  CONSTRAINT ck_organization_member_revoked CHECK (
    (status = 'revoked' AND revoked_at IS NOT NULL)
    OR (status <> 'revoked' AND revoked_at IS NULL)
  )
);

CREATE UNIQUE INDEX ux_organization_member_active_phone
  ON organization_member (owner_id, organization_id, phone)
  WHERE status IN ('invited', 'active');

CREATE INDEX ix_organization_member_org_status
  ON organization_member (owner_id, organization_id, status, role);

COMMIT;
