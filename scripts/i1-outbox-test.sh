#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
API_PORT="${I1_OUTBOX_API_PORT:-18180}"
API_URL="http://127.0.0.1:$API_PORT"
PHONE="+8613800138120"
CODE="${SMS_MOCK_CODE:-123456}"
BASE=""
DATA=""
API_PID=""
API_BIN=""
API_LOG="/tmp/scolvpet-i1-outbox-api.log"
PROBE=""
PROBE_TEMP=0

cleanup() {
  if [[ -n "$API_PID" ]]; then
    kill "$API_PID" >/dev/null 2>&1 || true
    wait "$API_PID" >/dev/null 2>&1 || true
  fi
  if [[ -n "$API_BIN" ]]; then rm -f "$API_BIN"; fi
  if [[ -n "$DATA" ]]; then pg_ctl -D "$DATA" stop -m fast >/dev/null 2>&1 || true; fi
  if [[ -n "$BASE" ]]; then rm -rf "$BASE"; fi
  if [[ "$PROBE_TEMP" == "1" && -n "$PROBE" ]]; then rm -f "$PROBE"; fi
}
trap cleanup EXIT

if [[ -n "${DATABASE_URL:-}" ]]; then
  DB_URL="$DATABASE_URL"
else
  BASE="$(mktemp -d /tmp/scolvpet-i1-outbox.XXXXXX)"
  DATA="$BASE/data"
  PORT="${I1_OUTBOX_DB_PORT:-$((56500 + RANDOM % 300))}"
  initdb -D "$DATA" --no-locale --encoding=UTF8 --auth=trust >/dev/null
  pg_ctl -D "$DATA" -o "-p $PORT" -l "$BASE/postgres.log" start >/dev/null
  until pg_isready -h 127.0.0.1 -p "$PORT" >/dev/null 2>&1; do sleep 0.2; done
  createdb -h 127.0.0.1 -p "$PORT" scolvpet_outbox
  DB_URL="postgres://$(whoami)@127.0.0.1:$PORT/scolvpet_outbox?sslmode=disable"
  DATABASE_URL="$DB_URL" "$ROOT/db/scripts/migrate.sh" --seed >/dev/null
fi

API_BIN="$(mktemp /tmp/scolvpet-i1-outbox-api.XXXXXX)"
(
  cd "$ROOT/api"
  "$ROOT/scripts/with-timeout.sh" 120 go build -o "$API_BIN" ./cmd/server
)
(
  export DATABASE_URL="$DB_URL"
  export API_ADDR=":$API_PORT"
  export SMS_MOCK_CODE="$CODE"
  export OUTBOX_WORKER_DISABLED=1
  exec "$API_BIN" >"$API_LOG" 2>&1
) &
API_PID="$!"
for attempt in {1..100}; do
  if curl -fsS "$API_URL/readyz" >/dev/null 2>&1; then break; fi
  if ! kill -0 "$API_PID" >/dev/null 2>&1; then
    tail -n 40 "$API_LOG" >&2 || true
    exit 1
  fi
  sleep 0.3
done
curl -fsS "$API_URL/readyz" >/dev/null

CODE_RESPONSE="$(curl -fsS -X POST "$API_URL/v1/auth/verification-codes" \
  -H 'Content-Type: application/json' -H 'Idempotency-Key: i1-outbox-code-0001' \
  -d "{\"phone\":\"$PHONE\",\"purpose\":\"login\"}")"
VERIFICATION_ID="$(printf '%s' "$CODE_RESPONSE" | jq -r '.data.verification_id')"
SESSION="$(curl -fsS -X POST "$API_URL/v1/auth/sessions" \
  -H 'Content-Type: application/json' -H 'Idempotency-Key: i1-outbox-login-0001' \
  -d "{\"phone\":\"$PHONE\",\"verification_id\":\"$VERIFICATION_ID\",\"code\":\"$CODE\",\"device\":{\"platform\":\"ios\",\"app_version\":\"0.1.0\"}}")"
TOKEN="$(printf '%s' "$SESSION" | jq -r '.data.access_token')"
TEMPLATES="$(curl -fsS "$API_URL/v1/species-rule-templates" -H "Authorization: Bearer $TOKEN")"
TEMPLATE_ID="$(printf '%s' "$TEMPLATES" | jq -r '.data[0].id')"
RULE_PAYLOAD="$(jq -cn --arg id "$TEMPLATE_ID" '{source_template_id:$id,species_code:"mesocricetus_auratus",gestation_min_days:16,gestation_max_days:18,weaning_target_days:21,sexing_target_days:28,separation_target_days:35,pairing_max_minutes:15,post_breeding_rest_days:0,profile_creation_deadline_days:0,weight_reference:{unit:"g"},source_note:"outbox probe",effective_at:"2026-07-16T00:00:00Z"}')"
curl -fsS -X POST "$API_URL/v1/species-rule-versions" \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -H 'Idempotency-Key: i1-outbox-rule-0001' -d "$RULE_PAYLOAD" >/dev/null

MESSAGE_ID="$(psql -XAt "$DB_URL" -c "select id from outbox_message where status='pending' order by created_at desc limit 1;")"
[[ -n "$MESSAGE_ID" ]] || { printf 'outbox message missing\n' >&2; exit 1; }

if [[ -n "$BASE" ]]; then
  PROBE="$BASE/outbox-probe"
else
  PROBE="$(mktemp /tmp/scolvpet-outbox-probe.XXXXXX)"
  PROBE_TEMP=1
fi
(cd "$ROOT/api" && go build -o "$PROBE" ./cmd/outbox-probe)

psql -XAt "$DB_URL" -c "update outbox_message set status='pending', attempt_count=0, max_attempts=12, available_at=now(), locked_at=null, locked_by=null where id='$MESSAGE_ID';" >/dev/null
OUTBOX_LEASE_SECONDS=60 OUTBOX_PUBLISHER_MODE=success OUTBOX_PUBLISHER_SLEEP_MS=500 DATABASE_URL="$DB_URL" "$PROBE" &
FIRST_PID="$!"
sleep 0.05
OUTBOX_LEASE_SECONDS=60 OUTBOX_PUBLISHER_MODE=success DATABASE_URL="$DB_URL" "$PROBE" &
SECOND_PID="$!"
wait "$FIRST_PID"
wait "$SECOND_PID"
CLAIM_STATE="$(psql -XAt "$DB_URL" -c "select status || ':' || attempt_count from outbox_message where id='$MESSAGE_ID';")"
[[ "$CLAIM_STATE" == "published:1" ]] || { printf 'claim concurrency failed: %s\n' "$CLAIM_STATE" >&2; exit 1; }

psql -XAt "$DB_URL" -c "update outbox_message set status='pending', attempt_count=0, max_attempts=12, available_at=now(), locked_at=null, locked_by=null where id='$MESSAGE_ID';" >/dev/null
OUTBOX_LEASE_SECONDS=60 OUTBOX_PUBLISHER_MODE=fail DATABASE_URL="$DB_URL" "$PROBE"
FAIL_STATE="$(psql -XAt "$DB_URL" -c "select status || ':' || attempt_count from outbox_message where id='$MESSAGE_ID';")"
[[ "$FAIL_STATE" == "failed:1" ]] || { printf 'failure retry state failed: %s\n' "$FAIL_STATE" >&2; exit 1; }

psql -XAt "$DB_URL" -c "update outbox_message set status='pending', attempt_count=0, max_attempts=1, available_at=now(), locked_at=null, locked_by=null where id='$MESSAGE_ID';" >/dev/null
OUTBOX_LEASE_SECONDS=60 OUTBOX_PUBLISHER_MODE=fail DATABASE_URL="$DB_URL" "$PROBE"
DEAD_STATE="$(psql -XAt "$DB_URL" -c "select status || ':' || attempt_count from outbox_message where id='$MESSAGE_ID';")"
[[ "$DEAD_STATE" == "dead_letter:1" ]] || { printf 'dead-letter state failed: %s\n' "$DEAD_STATE" >&2; exit 1; }

psql -XAt "$DB_URL" -c "update outbox_message set status='processing', attempt_count=0, max_attempts=12, locked_at=now()-interval '5 minutes', locked_by='crashed-worker' where id='$MESSAGE_ID';" >/dev/null
OUTBOX_LEASE_SECONDS=1 OUTBOX_PUBLISHER_MODE=success DATABASE_URL="$DB_URL" "$PROBE"
STALE_STATE="$(psql -XAt "$DB_URL" -c "select status || ':' || attempt_count from outbox_message where id='$MESSAGE_ID';")"
[[ "$STALE_STATE" == "published:1" ]] || { printf 'stale lease recovery failed: %s\n' "$STALE_STATE" >&2; exit 1; }

printf 'outbox reliability verified: claim=%s retry=%s dead_letter=%s stale_recovery=%s\n' "$CLAIM_STATE" "$FAIL_STATE" "$DEAD_STATE" "$STALE_STATE"
