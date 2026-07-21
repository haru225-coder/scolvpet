\set ON_ERROR_STOP on
\pset pager off
\pset format unaligned
\pset fieldsep '|'

-- Read-only report for comparing an existing Assistant schema with migration 0033.
-- Usage:
--   psql -X -v ON_ERROR_STOP=1 "$DATABASE_URL" \
--     -f db/scripts/audit-assistant-0033.sql
--
-- The report intentionally performs no migration or schema-metadata write.
\set expected_0033_checksum 'd607f8f0e1f857d8ed46b6cc1269a5b5d1566b52fe608131087661e9475959a3'

BEGIN TRANSACTION READ ONLY;

SELECT
  'AUDIT_CONTEXT',
  current_database(),
  current_user,
  current_setting('server_version'),
  current_setting('transaction_read_only');

SELECT
  'LEDGER_SUMMARY',
  count(*),
  min(migration_name),
  max(migration_name)
FROM scolvpet_meta.schema_migrations;

SELECT
  'MIGRATION_0033',
  :'expected_0033_checksum',
  coalesce(
    (
      SELECT checksum
      FROM scolvpet_meta.schema_migrations
      WHERE migration_name = '0033_assistant_chat.sql'
    ),
    'MISSING'
  ),
  CASE
    WHEN NOT EXISTS (
      SELECT 1
      FROM scolvpet_meta.schema_migrations
      WHERE migration_name = '0033_assistant_chat.sql'
    ) THEN 'MISSING'
    WHEN (
      SELECT checksum
      FROM scolvpet_meta.schema_migrations
      WHERE migration_name = '0033_assistant_chat.sql'
    ) = :'expected_0033_checksum' THEN 'MATCH'
    ELSE 'CHECKSUM_DRIFT'
  END;

SELECT
  'TABLE',
  expected.table_name,
  CASE WHEN actual.oid IS NULL THEN 'MISSING' ELSE 'PRESENT' END
FROM (
  VALUES
    ('assistant_session'),
    ('assistant_message'),
    ('assistant_action')
) AS expected(table_name)
LEFT JOIN pg_class actual
  ON actual.relnamespace = 'public'::regnamespace
 AND actual.relname = expected.table_name
 AND actual.relkind = 'r'
ORDER BY expected.table_name;

SELECT
  'COLUMN',
  table_name,
  ordinal_position,
  column_name,
  data_type,
  coalesce(character_maximum_length::text, ''),
  is_nullable,
  coalesce(column_default, '')
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN (
    'assistant_session',
    'assistant_message',
    'assistant_action'
  )
ORDER BY table_name, ordinal_position;

SELECT
  'CONSTRAINT',
  relation.relname,
  constraint_row.conname,
  constraint_row.contype,
  pg_get_constraintdef(constraint_row.oid, true)
FROM pg_constraint constraint_row
JOIN pg_class relation ON relation.oid = constraint_row.conrelid
JOIN pg_namespace namespace_row ON namespace_row.oid = relation.relnamespace
WHERE namespace_row.nspname = 'public'
  AND relation.relname IN (
    'assistant_session',
    'assistant_message',
    'assistant_action'
  )
ORDER BY relation.relname, constraint_row.conname;

SELECT
  'INDEX',
  tablename,
  indexname,
  indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename IN (
    'assistant_session',
    'assistant_message',
    'assistant_action'
  )
ORDER BY tablename, indexname;

SELECT
  'OBJECT_COUNTS',
  (
    SELECT count(*)
    FROM pg_class
    WHERE relnamespace = 'public'::regnamespace
      AND relkind = 'r'
      AND relname IN (
        'assistant_session',
        'assistant_message',
        'assistant_action'
      )
  ) AS tables,
  (
    SELECT count(*)
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name IN (
        'assistant_session',
        'assistant_message',
        'assistant_action'
      )
  ) AS columns,
  (
    SELECT count(*)
    FROM pg_constraint constraint_row
    JOIN pg_class relation ON relation.oid = constraint_row.conrelid
    WHERE relation.relnamespace = 'public'::regnamespace
      AND relation.relname IN (
        'assistant_session',
        'assistant_message',
        'assistant_action'
      )
  ) AS constraints,
  (
    SELECT count(*)
    FROM pg_indexes
    WHERE schemaname = 'public'
      AND tablename IN (
        'assistant_session',
        'assistant_message',
        'assistant_action'
      )
  ) AS indexes;

COMMIT;
