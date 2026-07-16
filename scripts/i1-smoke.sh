#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
API_PORT="${I1_API_PORT:-18080}"
API_URL="http://127.0.0.1:$API_PORT"
PHONE_ONE="+8613800138100"
PHONE_TWO="+8613800138101"
CODE="${SMS_MOCK_CODE:-123456}"
BASE=""
DATA=""
API_PID=""
API_BIN=""
API_LOG="/tmp/scolvpet-i1-api.log"
REFRESH_HEADERS=""
REFRESH_REPLAY_HEADERS=""
RULE_HEADERS=""
RULE_REPLAY_HEADERS=""

cleanup() {
  if [[ -n "$API_PID" ]]; then
    kill "$API_PID" >/dev/null 2>&1 || true
    wait "$API_PID" >/dev/null 2>&1 || true
  fi
  if [[ -n "$API_BIN" ]]; then rm -f "$API_BIN"; fi
  if [[ -n "$DATA" ]]; then pg_ctl -D "$DATA" stop -m fast >/dev/null 2>&1 || true; fi
  if [[ -n "$BASE" ]]; then rm -rf "$BASE"; fi
  for file in "$REFRESH_HEADERS" "$REFRESH_REPLAY_HEADERS" "$RULE_HEADERS" "$RULE_REPLAY_HEADERS"; do
    [[ -n "$file" ]] && rm -f "$file"
  done
}
trap cleanup EXIT

if [[ -n "${DATABASE_URL:-}" ]]; then
  DB_URL="$DATABASE_URL"
else
  BASE="$(mktemp -d /tmp/scolvpet-i1-smoke.XXXXXX)"
  DATA="$BASE/data"
  PORT="${I1_DB_PORT:-$((56000 + RANDOM % 500))}"
  initdb -D "$DATA" --no-locale --encoding=UTF8 --auth=trust >/dev/null
  pg_ctl -D "$DATA" -o "-p $PORT" -l "$BASE/postgres.log" start >/dev/null
  until pg_isready -h 127.0.0.1 -p "$PORT" >/dev/null 2>&1; do sleep 0.2; done
  createdb -h 127.0.0.1 -p "$PORT" scolvpet_smoke
  DB_URL="postgres://$(whoami)@127.0.0.1:$PORT/scolvpet_smoke?sslmode=disable"
  DATABASE_URL="$DB_URL" "$ROOT/db/scripts/migrate.sh" --seed >/dev/null
fi

API_BIN="$(mktemp /tmp/scolvpet-i1-api.XXXXXX)"
(
  cd "$ROOT/api"
  "$ROOT/scripts/with-timeout.sh" 120 go build -o "$API_BIN" ./cmd/server
)
(
  export DATABASE_URL="$DB_URL"
  export API_ADDR=":$API_PORT"
  export SMS_MOCK_CODE="$CODE"
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

json_field() { jq -r "$1"; }
request_code() {
  local phone="$1" key="$2"
  curl -fsS -X POST "$API_URL/v1/auth/verification-codes" \
    -H 'Content-Type: application/json' -H "Idempotency-Key: $key" \
    -d "{\"phone\":\"$phone\",\"purpose\":\"login\"}"
}
login() {
  local phone="$1" verification_id="$2" key="$3"
  curl -fsS -X POST "$API_URL/v1/auth/sessions" \
    -H 'Content-Type: application/json' -H "Idempotency-Key: $key" \
    -d "{\"phone\":\"$phone\",\"verification_id\":\"$verification_id\",\"code\":\"$CODE\",\"device\":{\"platform\":\"ios\",\"app_version\":\"0.1.0\"}}"
}

CODE_RESPONSE="$(request_code "$PHONE_ONE" "i1-code-00000001")"
VERIFICATION_ID="$(printf '%s' "$CODE_RESPONSE" | json_field '.data.verification_id')"
CODE_REPLAY="$(request_code "$PHONE_ONE" "i1-code-00000001")"
[[ "$(printf '%s' "$CODE_RESPONSE" | jq -S -c .)" == "$(printf '%s' "$CODE_REPLAY" | jq -S -c .)" ]] || { printf 'verification idempotency replay mismatch\n' >&2; exit 1; }

SESSION_RESPONSE="$(login "$PHONE_ONE" "$VERIFICATION_ID" "i1-login-00000001")"
TOKEN="$(printf '%s' "$SESSION_RESPONSE" | json_field '.data.access_token')"
REFRESH_TOKEN="$(printf '%s' "$SESSION_RESPONSE" | json_field '.data.refresh_token')"
ORG_ID="$(printf '%s' "$SESSION_RESPONSE" | json_field '.data.current_organization.id')"
[[ -n "$TOKEN" && "$ORG_ID" != "null" ]] || { printf 'session did not restore organization\n' >&2; exit 1; }

REFRESH_HEADERS="$(mktemp /tmp/scolvpet-i1-refresh-headers.XXXXXX)"
REFRESHED="$(curl -fsS -D "$REFRESH_HEADERS" -X POST "$API_URL/v1/auth/sessions/refresh" -H 'Content-Type: application/json' -H 'Idempotency-Key: i1-refresh-00000001' -d "{\"refresh_token\":\"$REFRESH_TOKEN\"}")"
TOKEN="$(printf '%s' "$REFRESHED" | json_field '.data.access_token')"
[[ -n "$TOKEN" && "$TOKEN" != "null" ]] || { printf 'session refresh failed\n' >&2; exit 1; }
REFRESH_REPLAY_HEADERS="$(mktemp /tmp/scolvpet-i1-refresh-replay-headers.XXXXXX)"
curl -fsS -D "$REFRESH_REPLAY_HEADERS" -X POST "$API_URL/v1/auth/sessions/refresh" -H 'Content-Type: application/json' -H 'Idempotency-Key: i1-refresh-00000001' -d "{\"refresh_token\":\"$REFRESH_TOKEN\"}" >/dev/null
grep -qi '^Idempotency-Replayed: true' "$REFRESH_REPLAY_HEADERS" || { printf 'refresh replay header missing\n' >&2; exit 1; }

ME="$(curl -fsS "$API_URL/v1/me" -H "Authorization: Bearer $TOKEN")"
[[ "$(printf '%s' "$ME" | json_field '.data.current_organization.owner_id')" != "null" ]] || { printf 'owner context missing\n' >&2; exit 1; }

ORG="$(curl -fsS "$API_URL/v1/organizations/current" -H "Authorization: Bearer $TOKEN")"
ETAG="$(curl -fsSI "$API_URL/v1/organizations/current" -H "Authorization: Bearer $TOKEN" | awk -F': ' 'tolower($1)=="etag"{gsub("\r", "", $2); print $2}')"
UPDATE='{"name":"I1 演示熊舍","mode":"personal","timezone":"Asia/Shanghai"}'
UPDATED="$(curl -fsS -X PATCH "$API_URL/v1/organizations/current" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/merge-patch+json" -H "If-Match: $ETAG" -H 'Idempotency-Key: i1-org-00000001' -d "$UPDATE")"
[[ "$(printf '%s' "$UPDATED" | json_field '.data.name')" == "I1 演示熊舍" ]] || { printf 'organization update failed\n' >&2; exit 1; }

TEMPLATES="$(curl -fsS "$API_URL/v1/species-rule-templates" -H "Authorization: Bearer $TOKEN")"
TEMPLATE_ID="$(printf '%s' "$TEMPLATES" | json_field '.data[0].id')"
INVALID_RULE_STATUS="$(curl -sS -o /tmp/scolvpet-i1-invalid-rule.json -w '%{http_code}' -X POST "$API_URL/v1/species-rule-versions" -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' -H 'Idempotency-Key: i1-rule-invalid-0001' -d "{\"source_template_id\":\"$TEMPLATE_ID\"}")"
[[ "$INVALID_RULE_STATUS" == "422" ]] || { printf 'invalid rule status: %s\n' "$INVALID_RULE_STATUS" >&2; exit 1; }
RULE_PAYLOAD="$(jq -cn --arg id "$TEMPLATE_ID" '{source_template_id:$id,species_code:"mesocricetus_auratus",gestation_min_days:16,gestation_max_days:18,weaning_target_days:21,sexing_target_days:28,separation_target_days:35,pairing_max_minutes:15,post_breeding_rest_days:0,profile_creation_deadline_days:0,weight_reference:{unit:"g"},source_note:"I1 owner copy",effective_at:"2026-07-16T00:00:00Z"}')"
RULE_HEADERS="$(mktemp /tmp/scolvpet-i1-rule-headers.XXXXXX)"
RULE="$(curl -fsS -D "$RULE_HEADERS" -X POST "$API_URL/v1/species-rule-versions" -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' -H 'Idempotency-Key: i1-rule-00000001' -d "$RULE_PAYLOAD")"
RULE_ID="$(printf '%s' "$RULE" | json_field '.data.id')"
[[ -n "$RULE_ID" && "$RULE_ID" != "null" ]] || { printf 'rule copy failed\n' >&2; exit 1; }
[[ "$(printf '%s' "$RULE" | jq -e '.data.post_breeding_rest_days == 0 and .data.profile_creation_deadline_days == 0' >/dev/null; echo $?)" == "0" ]] || { printf 'optional zero values were not preserved\n' >&2; exit 1; }
RULE_REPLAY_HEADERS="$(mktemp /tmp/scolvpet-i1-rule-replay-headers.XXXXXX)"
RULE_REPLAY="$(curl -fsS -D "$RULE_REPLAY_HEADERS" -X POST "$API_URL/v1/species-rule-versions" -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' -H 'Idempotency-Key: i1-rule-00000001' -d "$RULE_PAYLOAD")"
[[ "$(printf '%s' "$RULE" | jq -S -c .)" == "$(printf '%s' "$RULE_REPLAY" | jq -S -c .)" ]] || { printf 'rule idempotency replay mismatch\n' >&2; exit 1; }
grep -qi '^Idempotency-Replayed: true' "$RULE_REPLAY_HEADERS" || { printf 'rule replay header missing\n' >&2; exit 1; }
grep -qi '^ETag:' "$RULE_REPLAY_HEADERS" || { printf 'replayed ETag missing\n' >&2; exit 1; }
grep -qi '^Location:' "$RULE_REPLAY_HEADERS" || { printf 'replayed Location missing\n' >&2; exit 1; }

MISMATCH_PAYLOAD="$(printf '%s' "$RULE_PAYLOAD" | jq '.species_code = "other"')"
MISMATCH_STATUS="$(curl -sS -o /tmp/scolvpet-i1-mismatch.json -w '%{http_code}' -X POST "$API_URL/v1/species-rule-versions" -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' -H 'Idempotency-Key: i1-rule-00000001' -d "$MISMATCH_PAYLOAD")"
[[ "$MISMATCH_STATUS" == "409" ]] || { printf 'idempotency mismatch status: %s\n' "$MISMATCH_STATUS" >&2; exit 1; }

STALE_STATUS="$(curl -sS -o /tmp/scolvpet-i1-stale.json -w '%{http_code}' -X PATCH "$API_URL/v1/organizations/current" -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/merge-patch+json' -H 'If-Match: "1"' -H 'Idempotency-Key: i1-org-00000002' -d '{"name":"stale"}')"
[[ "$STALE_STATUS" == "409" ]] || { printf 'etag conflict status: %s\n' "$STALE_STATUS" >&2; exit 1; }

CODE_TWO="$(request_code "$PHONE_TWO" "i1-code-00000002")"
VERIFICATION_TWO="$(printf '%s' "$CODE_TWO" | json_field '.data.verification_id')"
SESSION_TWO="$(login "$PHONE_TWO" "$VERIFICATION_TWO" "i1-login-00000002")"
TOKEN_TWO="$(printf '%s' "$SESSION_TWO" | json_field '.data.access_token')"
CROSS_STATUS="$(curl -sS -o /tmp/scolvpet-i1-cross.json -w '%{http_code}' "$API_URL/v1/species-rule-versions/$RULE_ID" -H "Authorization: Bearer $TOKEN_TWO")"
[[ "$CROSS_STATUS" == "404" ]] || { printf 'cross-owner status: %s\n' "$CROSS_STATUS" >&2; exit 1; }

curl -fsS -X DELETE "$API_URL/v1/auth/sessions/current" -H "Authorization: Bearer $TOKEN" -H 'Idempotency-Key: i1-logout-00000001' >/dev/null
CODE_AGAIN="$(request_code "$PHONE_ONE" "i1-code-00000003")"
VERIFICATION_AGAIN="$(printf '%s' "$CODE_AGAIN" | json_field '.data.verification_id')"
SESSION_AGAIN="$(login "$PHONE_ONE" "$VERIFICATION_AGAIN" "i1-login-00000003")"
TOKEN_AGAIN="$(printf '%s' "$SESSION_AGAIN" | json_field '.data.access_token')"
curl -fsS "$API_URL/v1/me" -H "Authorization: Bearer $TOKEN_AGAIN" >/dev/null

if [[ -n "${DATABASE_URL:-}" ]]; then
  DB_CHECK_URL="$DATABASE_URL"
else
  DB_CHECK_URL="$DB_URL"
fi
OUTBOX=0
EVENTS=0
for attempt in {1..20}; do
  OUTBOX="$(psql -XAt "$DB_CHECK_URL" -c "select count(*) from outbox_message where status='published';")"
  EVENTS="$(psql -XAt "$DB_CHECK_URL" -c "select count(*) from domain_event;")"
  if [[ "$EVENTS" -ge 3 && "$OUTBOX" -ge 2 ]]; then break; fi
  sleep 0.5
done
[[ "$EVENTS" -ge 3 ]] || { printf 'event count too low: %s\n' "$EVENTS" >&2; exit 1; }
[[ "$OUTBOX" -ge 2 ]] || { printf 'published outbox count too low: %s\n' "$OUTBOX" >&2; exit 1; }

printf 'I1 smoke verified: owner isolation, idempotency, ETag, rules, events=%s, published_outbox=%s\n' "$EVENTS" "$OUTBOX"
