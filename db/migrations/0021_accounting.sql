-- T-P1-04 accounting categories and records (minimal finance ledger).
BEGIN;

CREATE TYPE accounting_entry_type AS ENUM ('income', 'expense');

CREATE TABLE accounting_category (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  entry_type accounting_entry_type NOT NULL,
  name varchar(80) NOT NULL,
  sort_order integer NOT NULL DEFAULT 0,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_accounting_category_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT uq_accounting_category_owner_type_name UNIQUE (owner_id, entry_type, name),
  CONSTRAINT fk_accounting_category_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT
);

CREATE INDEX ix_accounting_category_owner_type
  ON accounting_category (owner_id, entry_type, sort_order, name);

CREATE TABLE accounting_record (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  category_id uuid,
  entry_type accounting_entry_type NOT NULL,
  amount_cents bigint NOT NULL CHECK (amount_cents > 0),
  currency varchar(8) NOT NULL DEFAULT 'CNY',
  title varchar(200) NOT NULL,
  notes text,
  contact_id uuid,
  occurred_at timestamptz NOT NULL DEFAULT now(),
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_accounting_record_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_accounting_record_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_accounting_record_category
    FOREIGN KEY (owner_id, category_id)
    REFERENCES accounting_category(owner_id, id) ON DELETE SET NULL,
  CONSTRAINT fk_accounting_record_contact
    FOREIGN KEY (owner_id, contact_id)
    REFERENCES crm_contact(owner_id, id) ON DELETE SET NULL
);

CREATE INDEX ix_accounting_record_owner_occurred
  ON accounting_record (owner_id, occurred_at DESC, id DESC);

CREATE INDEX ix_accounting_record_owner_type_occurred
  ON accounting_record (owner_id, entry_type, occurred_at DESC);

COMMIT;
