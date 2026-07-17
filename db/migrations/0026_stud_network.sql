-- T-P2-05 cross-cattery stud listings and deal ledger (minimal network).
BEGIN;

CREATE TYPE stud_deal_status AS ENUM (
  'draft',
  'requested',
  'confirmed',
  'in_progress',
  'completed',
  'cancelled'
);

CREATE TYPE stud_deal_side AS ENUM ('provider', 'requester');

-- Published stud offers (visible to authenticated network list).
CREATE TABLE stud_listing (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  sire_hamster_id uuid,
  sire_label varchar(160) NOT NULL,
  title varchar(200) NOT NULL,
  fee_cents bigint NOT NULL DEFAULT 0 CHECK (fee_cents >= 0),
  currency varchar(8) NOT NULL DEFAULT 'CNY',
  notes text,
  published boolean NOT NULL DEFAULT true,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_stud_listing_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_stud_listing_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT
);

CREATE INDEX ix_stud_listing_published
  ON stud_listing (published, updated_at DESC)
  WHERE published = true;

CREATE INDEX ix_stud_listing_owner
  ON stud_listing (owner_id, updated_at DESC);

-- Per-owner deal ledger (each party may keep their own record; MVP one-sided OK).
CREATE TABLE stud_deal (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  listing_id uuid,
  side stud_deal_side NOT NULL,
  status stud_deal_status NOT NULL DEFAULT 'draft',
  my_hamster_label varchar(160),
  partner_cattery_name varchar(160) NOT NULL,
  partner_contact varchar(120),
  partner_animal_label varchar(160),
  fee_cents bigint NOT NULL DEFAULT 0 CHECK (fee_cents >= 0),
  currency varchar(8) NOT NULL DEFAULT 'CNY',
  notes text,
  confirmed_at timestamptz,
  started_at timestamptz,
  completed_at timestamptz,
  cancelled_at timestamptz,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_stud_deal_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_stud_deal_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT ck_stud_deal_completed CHECK (
    (status = 'completed' AND completed_at IS NOT NULL)
    OR (status <> 'completed')
  ),
  CONSTRAINT ck_stud_deal_cancelled CHECK (
    (status = 'cancelled' AND cancelled_at IS NOT NULL)
    OR (status <> 'cancelled')
  )
);

CREATE INDEX ix_stud_deal_owner_status
  ON stud_deal (owner_id, status, updated_at DESC);

COMMIT;
