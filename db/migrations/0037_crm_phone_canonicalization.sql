-- Canonicalize existing crm_contact.phone to +86########### where possible.
BEGIN;

-- Normalize pure 11-digit CN mobiles.
UPDATE crm_contact
SET phone = '+86' || phone,
    updated_at = now()
WHERE phone ~ '^[1][3-9][0-9]{9}$';

-- Normalize 86xxxxxxxxxxx without plus.
UPDATE crm_contact
SET phone = '+' || phone,
    updated_at = now()
WHERE phone ~ '^86[1][3-9][0-9]{9}$';

-- Strip spaces/dashes then re-apply for simple residual forms is skipped:
-- keep deterministic regex-only transforms for safe backfill.

COMMENT ON COLUMN crm_contact.phone IS
  'Preferred canonical form: +86 + 11-digit CN mobile. Historical non-mobile values may remain.';

COMMIT;
