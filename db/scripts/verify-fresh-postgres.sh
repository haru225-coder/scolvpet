#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
if ! command -v initdb >/dev/null 2>&1 && command -v pg_config >/dev/null 2>&1; then
  PG_BIN="$(pg_config --bindir)"
  export PATH="$PG_BIN:$PATH"
fi
BASE="$(mktemp -d /tmp/scolvpet-pg15-verify.XXXXXX)"
DATA="$BASE/data"
PORT="${SCOLVPET_VERIFY_PORT:-$((55000 + RANDOM % 1000))}"
DB="scolvpet_verify"

cleanup() {
  pg_ctl -D "$DATA" stop -m fast >/dev/null 2>&1 || true
  rm -rf "$BASE"
}
trap cleanup EXIT

initdb -D "$DATA" --no-locale --encoding=UTF8 --auth=trust >/dev/null
pg_ctl -D "$DATA" -o "-p $PORT" -l "$BASE/postgres.log" start >/dev/null

until pg_isready -h 127.0.0.1 -p "$PORT" >/dev/null 2>&1; do sleep 0.2; done
createdb -h 127.0.0.1 -p "$PORT" "$DB"
DATABASE_URL="postgres://$(whoami)@127.0.0.1:$PORT/$DB?sslmode=disable" "$ROOT/db/scripts/migrate.sh" --seed

URL="postgres://$(whoami)@127.0.0.1:$PORT/$DB?sslmode=disable"
before_schema="$(psql -XAt "$URL" -c "select string_agg(migration_name || ':' || checksum, ',' order by migration_name) from scolvpet_meta.schema_migrations;")"
before_seed="$(psql -XAt "$URL" -c "select (select count(*) from account), (select count(*) from organization), (select count(*) from species_rule_version where scope='system'), (select count(*) from usage_meter);")"
DATABASE_URL="$URL" "$ROOT/db/scripts/migrate.sh" --seed >/tmp/scolvpet-migrate-replay.log
after_schema="$(psql -XAt "$URL" -c "select string_agg(migration_name || ':' || checksum, ',' order by migration_name) from scolvpet_meta.schema_migrations;")"
after_seed="$(psql -XAt "$URL" -c "select (select count(*) from account), (select count(*) from organization), (select count(*) from species_rule_version where scope='system'), (select count(*) from usage_meter);")"
[[ "$before_schema" == "$after_schema" ]] || { printf 'migration replay changed metadata\n' >&2; exit 1; }
[[ "$before_seed" == "$after_seed" ]] || { printf 'seed replay changed counts: before=%s after=%s\n' "$before_seed" "$after_seed" >&2; exit 1; }

DRIFT_DIR="$(mktemp -d /tmp/scolvpet-migration-drift.XXXXXX)"
cp "$ROOT"/db/migrations/*.sql "$DRIFT_DIR/"
printf '\n-- checksum drift probe\n' >> "$DRIFT_DIR/0001_extensions_enums.sql"
if DATABASE_URL="$URL" MIGRATIONS_DIR="$DRIFT_DIR" "$ROOT/db/scripts/migrate.sh" >/tmp/scolvpet-migrate-drift.log 2>&1; then
  printf 'checksum drift probe unexpectedly passed\n' >&2
  rm -rf "$DRIFT_DIR"
  exit 1
fi
rm -rf "$DRIFT_DIR"

TABLES="$(psql -XAt "$URL" -c "select count(*) from pg_class where relkind='r' and relnamespace='public'::regnamespace;")"
ENUMS="$(psql -XAt "$URL" -c "select count(*) from pg_type where typtype='e' and typnamespace='public'::regnamespace;")"
RULES="$(psql -XAt "$URL" -c "select count(*) from species_rule_version where scope='system';")"
META_TABLES="$(psql -XAt "$URL" -c "select count(*) from pg_class where relkind='r' and relnamespace='scolvpet_meta'::regnamespace;")"
MIGRATIONS="$(psql -XAt "$URL" -c "select count(*) from scolvpet_meta.schema_migrations;")"
LAST_MIGRATION="$(psql -XAt "$URL" -c "select max(migration_name) from scolvpet_meta.schema_migrations;")"
ASSISTANT_TABLES="$(psql -XAt "$URL" -c "select count(*) from pg_class where relkind='r' and relnamespace='public'::regnamespace and relname in ('assistant_session', 'assistant_message', 'assistant_action');")"

# Baseline after migrations 0000–0040 (I1–I6 + CRM/合同/公开主页/预订/Assistant
# and the P0 security persistence tables).
# 0032 adds hamster cover media fields; 0033 adds the three Assistant tables;
# 0034–0039 add the audit, customer, idempotency, and token-revocation tables;
# 0040 adds the WeChat identity binding and bind-ticket tables.
[[ "$TABLES" == "74" ]] || { printf 'table count mismatch: %s\n' "$TABLES" >&2; exit 1; }
[[ "$ENUMS" == "75" ]] || { printf 'enum count mismatch: %s\n' "$ENUMS" >&2; exit 1; }
[[ "$RULES" == "1" ]] || { printf 'seed rule count mismatch: %s\n' "$RULES" >&2; exit 1; }
[[ "$META_TABLES" == "1" ]] || { printf 'metadata table count mismatch: %s\n' "$META_TABLES" >&2; exit 1; }
[[ "$MIGRATIONS" == "41" ]] || { printf 'migration count mismatch: %s\n' "$MIGRATIONS" >&2; exit 1; }
[[ "$LAST_MIGRATION" == "0040_customer_wechat_identity.sql" ]] || { printf 'last migration mismatch: %s\n' "$LAST_MIGRATION" >&2; exit 1; }
[[ "$ASSISTANT_TABLES" == "3" ]] || { printf 'assistant table count mismatch: %s\n' "$ASSISTANT_TABLES" >&2; exit 1; }

printf 'fresh postgres verified: tables=%s enums=%s system_rules=%s metadata_tables=%s migrations=%s last_migration=%s assistant_tables=%s replay=stable seed_replay=idempotent checksum_drift=detected port=%s\n' "$TABLES" "$ENUMS" "$RULES" "$META_TABLES" "$MIGRATIONS" "$LAST_MIGRATION" "$ASSISTANT_TABLES" "$PORT"
