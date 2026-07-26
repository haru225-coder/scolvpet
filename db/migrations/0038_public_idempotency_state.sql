-- Durable claim/state for public idempotency (no long-held pool connections).
BEGIN;

ALTER TABLE auth_public_idempotency
  ADD COLUMN IF NOT EXISTS state varchar(16) NOT NULL DEFAULT 'completed';

ALTER TABLE auth_public_idempotency
  ADD COLUMN IF NOT EXISTS locked_at timestamptz;

-- Processing rows may not have a final response yet.
ALTER TABLE auth_public_idempotency
  ALTER COLUMN response_status DROP NOT NULL;

ALTER TABLE auth_public_idempotency
  ALTER COLUMN response_body DROP NOT NULL;

UPDATE auth_public_idempotency
SET state = 'completed'
WHERE state IS NULL OR state = '';

COMMENT ON COLUMN auth_public_idempotency.state IS
  'processing | completed; claim-row concurrency without session advisory locks.';

COMMIT;
