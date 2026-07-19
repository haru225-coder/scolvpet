#!/usr/bin/env bash
set -euo pipefail

: "${DATABASE_URL:?DATABASE_URL is required}"

until pg_isready -d "$DATABASE_URL" >/dev/null 2>&1; do
  sleep 2
done

/app/db/scripts/migrate.sh --seed
exec /app/scolvpet-api
