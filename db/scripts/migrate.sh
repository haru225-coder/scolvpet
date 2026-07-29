#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DATABASE_URL="${DATABASE_URL:-postgres://scolvpet:scolvpet@127.0.0.1:55432/scolvpet?sslmode=disable}"
MIGRATIONS_DIR="${MIGRATIONS_DIR:-$ROOT/db/migrations}"
# Dockerized staging hosts may not install the PostgreSQL client on the host.
# Set PSQL_DOCKER_CONTAINER=scolvpet-db to run the exact same migration flow
# through the database container while keeping the normal host/CI path intact.
PSQL_DOCKER_CONTAINER="${PSQL_DOCKER_CONTAINER:-}"
PSQL_USER="${PSQL_USER:-scolvpet}"
PSQL_DATABASE="${PSQL_DATABASE:-scolvpet}"

psql_exec() {
  if [[ -n "$PSQL_DOCKER_CONTAINER" ]]; then
    docker exec -i "$PSQL_DOCKER_CONTAINER" psql -U "$PSQL_USER" -d "$PSQL_DATABASE" "$@"
  else
    psql "$@" "$DATABASE_URL"
  fi
}

checksum_file() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    sha256sum "$1" | awk '{print $1}'
  fi
}

psql_exec -X -v ON_ERROR_STOP=1 <<'SQL'
CREATE SCHEMA IF NOT EXISTS scolvpet_meta;
CREATE TABLE IF NOT EXISTS scolvpet_meta.schema_migrations (
  migration_name text PRIMARY KEY,
  checksum char(64) NOT NULL,
  applied_at timestamptz NOT NULL DEFAULT now()
);
SQL

for migration in "$MIGRATIONS_DIR"/*.sql; do
  [[ -f "$migration" ]] || continue
  name="${migration##*/}"
  checksum="$(checksum_file "$migration")"
  applied="$(psql_exec -XAt -v ON_ERROR_STOP=1 -c "SELECT checksum FROM scolvpet_meta.schema_migrations WHERE migration_name = '$name';")"
  if [[ -n "$applied" ]]; then
    if [[ "$applied" != "$checksum" ]]; then
      printf 'migration checksum drift: %s expected=%s actual=%s\n' "$name" "$applied" "$checksum" >&2
      exit 1
    fi
    printf 'skipping %s (already applied)\n' "$name"
    continue
  fi

  printf 'applying %s\n' "$name"
  temp_sql="$(mktemp "${TMPDIR:-/tmp}/scolvpet-migration.XXXXXX")"
  trap 'rm -f "$temp_sql"' EXIT
  {
    printf 'BEGIN;\n'
    sed -e '/^[[:space:]]*BEGIN;[[:space:]]*$/d' -e '/^[[:space:]]*COMMIT;[[:space:]]*$/d' "$migration"
    printf '\nINSERT INTO scolvpet_meta.schema_migrations (migration_name, checksum) VALUES (:'"'"'migration_name'"'"', :'"'"'checksum'"'"');\n'
    printf 'COMMIT;\n'
  } > "$temp_sql"
  if [[ -n "$PSQL_DOCKER_CONTAINER" ]]; then
    psql_exec -X -v ON_ERROR_STOP=1 -v migration_name="$name" -v checksum="$checksum" < "$temp_sql"
  else
    psql_exec -X -v ON_ERROR_STOP=1 -v migration_name="$name" -v checksum="$checksum" -f "$temp_sql"
  fi
  rm -f "$temp_sql"
  trap - EXIT
done

if [[ "${1:-}" == "--seed" ]]; then
  printf 'applying seed/dev.sql\n'
  if [[ -n "$PSQL_DOCKER_CONTAINER" ]]; then
    psql_exec -X -v ON_ERROR_STOP=1 < "$ROOT/db/seed/dev.sql"
  else
    psql_exec -X -v ON_ERROR_STOP=1 -f "$ROOT/db/seed/dev.sql"
  fi
fi
