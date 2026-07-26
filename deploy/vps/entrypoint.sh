#!/usr/bin/env bash
set -euo pipefail

: "${DATABASE_URL:?DATABASE_URL is required}"

until pg_isready -d "$DATABASE_URL" >/dev/null 2>&1; do
  sleep 2
done

APP_ENV_VALUE="$(printf '%s' "${APP_ENV:-development}" | tr '[:upper:]' '[:lower:]')"
SEED_FLAG="${SEED_DEV_DATA:-0}"

if [[ "$APP_ENV_VALUE" == "production" ]]; then
  # Production: migrate only — never inject demo tenants.
  /app/db/scripts/migrate.sh
elif [[ "$SEED_FLAG" == "1" || "$SEED_FLAG" == "true" ]]; then
  /app/db/scripts/migrate.sh --seed
else
  /app/db/scripts/migrate.sh
fi

exec /app/scolvpet-api
