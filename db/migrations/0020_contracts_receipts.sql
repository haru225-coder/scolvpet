-- T-P1-03 contract / receipt templates and issued documents (minimal).
BEGIN;

CREATE TYPE doc_template_kind AS ENUM ('contract', 'receipt');
CREATE TYPE doc_document_status AS ENUM ('draft', 'issued', 'archived');

CREATE TABLE doc_template (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  kind doc_template_kind NOT NULL,
  name varchar(200) NOT NULL,
  body_text text NOT NULL,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_doc_template_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_doc_template_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT
);

CREATE INDEX ix_doc_template_owner_kind
  ON doc_template (owner_id, kind, updated_at DESC);

CREATE TABLE doc_document (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES account(id) ON DELETE RESTRICT,
  organization_id uuid NOT NULL,
  template_id uuid NOT NULL,
  kind doc_template_kind NOT NULL,
  contact_id uuid,
  handover_id uuid,
  title varchar(200) NOT NULL,
  body_filled text NOT NULL,
  amount_cents bigint,
  currency varchar(8) NOT NULL DEFAULT 'CNY',
  status doc_document_status NOT NULL DEFAULT 'draft',
  issued_at timestamptz,
  notes text,
  version integer NOT NULL DEFAULT 1 CHECK (version > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_doc_document_owner_id_id UNIQUE (owner_id, id),
  CONSTRAINT fk_doc_document_organization
    FOREIGN KEY (owner_id, organization_id)
    REFERENCES organization(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_doc_document_template
    FOREIGN KEY (owner_id, template_id)
    REFERENCES doc_template(owner_id, id) ON DELETE RESTRICT,
  CONSTRAINT fk_doc_document_contact
    FOREIGN KEY (owner_id, contact_id)
    REFERENCES crm_contact(owner_id, id) ON DELETE SET NULL,
  CONSTRAINT fk_doc_document_handover
    FOREIGN KEY (owner_id, handover_id)
    REFERENCES crm_handover(owner_id, id) ON DELETE SET NULL,
  CONSTRAINT ck_doc_document_amount CHECK (
    (kind = 'receipt' AND amount_cents IS NOT NULL AND amount_cents >= 0)
    OR (kind = 'contract')
  ),
  CONSTRAINT ck_doc_document_issued CHECK (
    (status = 'issued' AND issued_at IS NOT NULL)
    OR (status <> 'issued')
  )
);

CREATE INDEX ix_doc_document_owner_kind_status
  ON doc_document (owner_id, kind, status, updated_at DESC);

COMMIT;
