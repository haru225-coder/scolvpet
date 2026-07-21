\set ON_ERROR_STOP on
\pset pager off

-- Repair ONLY the migration ledger for 0033_assistant_chat.sql.
-- Does NOT CREATE/ALTER assistant tables.
--
-- Preconditions:
--   1. Production already has assistant_session / assistant_message / assistant_action
--      matching migration 0033 (run audit-assistant-0033.sql first).
--   2. schema_migrations is missing 0033_assistant_chat.sql.
--   3. Schema-only backup taken and reviewed.
--
-- Usage:
--   psql -X -v ON_ERROR_STOP=1 -v confirm=YES "$DATABASE_URL" \
--     -f db/scripts/repair-ledger-0033-assistant.sql

\if :{?confirm}
\else
  \echo 'ERROR: set -v confirm=YES after audit + backup'
  \quit 1
\endif

\set expected_checksum 'd607f8f0e1f857d8ed46b6cc1269a5b5d1566b52fe608131087661e9475959a3'

BEGIN;

DO $repair$
DECLARE
  v_confirm text := :'confirm';
  v_checksum text := :'expected_checksum';
  v_tables int;
  v_ledger int;
  v_cols int;
  v_status_ck int;
BEGIN
  IF v_confirm IS DISTINCT FROM 'YES' THEN
    RAISE EXCEPTION 'refusing repair: pass -v confirm=YES after audit/backup';
  END IF;

  SELECT count(*) INTO v_tables
  FROM pg_class
  WHERE relnamespace = 'public'::regnamespace
    AND relkind = 'r'
    AND relname IN ('assistant_session', 'assistant_message', 'assistant_action');
  IF v_tables <> 3 THEN
    RAISE EXCEPTION 'refusing repair: assistant tables present=% (want 3)', v_tables;
  END IF;

  SELECT count(*) INTO v_cols
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name IN ('assistant_session', 'assistant_message', 'assistant_action');
  IF v_cols < 28 THEN
    RAISE EXCEPTION 'refusing repair: column count=% (expected >=28)', v_cols;
  END IF;

  SELECT count(*) INTO v_status_ck
  FROM pg_constraint c
  JOIN pg_class r ON r.oid = c.conrelid
  WHERE r.relnamespace = 'public'::regnamespace
    AND r.relname = 'assistant_action'
    AND c.conname = 'ck_assistant_action_status';
  IF v_status_ck <> 1 THEN
    RAISE EXCEPTION 'refusing repair: missing ck_assistant_action_status';
  END IF;

  SELECT count(*) INTO v_ledger
  FROM scolvpet_meta.schema_migrations
  WHERE migration_name = '0033_assistant_chat.sql';
  IF v_ledger > 0 THEN
    RAISE NOTICE '0033 already registered; no-op';
    RETURN;
  END IF;

  INSERT INTO scolvpet_meta.schema_migrations (migration_name, checksum)
  VALUES ('0033_assistant_chat.sql', v_checksum);

  RAISE NOTICE 'registered 0033_assistant_chat.sql checksum=%', v_checksum;
END
$repair$;

SELECT migration_name, checksum, applied_at
FROM scolvpet_meta.schema_migrations
WHERE migration_name = '0033_assistant_chat.sql';

COMMIT;
