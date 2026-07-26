-- Bind issued documents to a specific reservation for customer isolation.
BEGIN;

ALTER TABLE doc_document
  ADD COLUMN IF NOT EXISTS reservation_id uuid;

ALTER TABLE doc_document
  DROP CONSTRAINT IF EXISTS fk_doc_document_reservation;

ALTER TABLE doc_document
  ADD CONSTRAINT fk_doc_document_reservation
  FOREIGN KEY (owner_id, reservation_id)
  REFERENCES crm_reservation (owner_id, id)
  ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS ix_doc_document_owner_reservation
  ON doc_document (owner_id, reservation_id)
  WHERE reservation_id IS NOT NULL;

COMMENT ON COLUMN doc_document.reservation_id IS
  'Optional binding to crm_reservation for customer document isolation.';

COMMIT;
