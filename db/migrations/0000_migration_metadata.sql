-- Versioned migration metadata lives outside public so the source schema count remains unchanged.
BEGIN;

CREATE SCHEMA IF NOT EXISTS scolvpet_meta;

CREATE TABLE IF NOT EXISTS scolvpet_meta.schema_migrations (
  migration_name text PRIMARY KEY,
  checksum char(64) NOT NULL,
  applied_at timestamptz NOT NULL DEFAULT now()
);

COMMIT;
