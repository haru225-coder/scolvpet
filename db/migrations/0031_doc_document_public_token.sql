-- Public customer-facing share token for issued contracts/receipts.
BEGIN;

ALTER TABLE doc_document
  ADD COLUMN IF NOT EXISTS public_token varchar(64);

CREATE UNIQUE INDEX IF NOT EXISTS ux_doc_document_public_token
  ON doc_document (public_token)
  WHERE public_token IS NOT NULL;

COMMIT;
