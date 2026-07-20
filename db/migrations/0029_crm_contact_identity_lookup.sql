-- T1-01a: crm_contact identity lookup indexes (phone / wechat dedupe path).
-- Not UNIQUE: historical duplicates may exist; resolve picks latest non-archived.
BEGIN;

CREATE INDEX IF NOT EXISTS ix_crm_contact_owner_phone
  ON crm_contact (owner_id, phone)
  WHERE phone IS NOT NULL AND phone <> '';

CREATE INDEX IF NOT EXISTS ix_crm_contact_owner_wechat
  ON crm_contact (owner_id, wechat)
  WHERE wechat IS NOT NULL AND wechat <> '';

COMMIT;
