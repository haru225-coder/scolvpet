#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
API_PORT="${I6_MEDIA_API_PORT:-18280}"
API_URL="http://127.0.0.1:$API_PORT"
PHONE="${I6_MEDIA_SMOKE_PHONE:-+8613800138190}"
CODE="${SMS_MOCK_CODE:-123456}"
RUN_ID="$(date +%s)-$$"
BASE=""
DATA=""
DB_URL="${DATABASE_URL:-}"
API_PID=""
API_BIN=""
API_LOG="/tmp/scolvpet-i6-media-api.log"
OBJECT_ROOT=""

cleanup() {
  if [[ -n "$API_PID" ]]; then
    kill "$API_PID" >/dev/null 2>&1 || true
    wait "$API_PID" >/dev/null 2>&1 || true
  fi
  if [[ -n "$API_BIN" ]]; then
    rm -f "$API_BIN"
  fi
  if [[ -n "$DATA" ]]; then
    pg_ctl -D "$DATA" stop -m fast >/dev/null 2>&1 || true
  fi
  if [[ -n "$BASE" ]]; then
    rm -rf "$BASE"
  fi
}
trap cleanup EXIT

if [[ -z "$DB_URL" ]]; then
  BASE="$(mktemp -d /tmp/scolvpet-i6-media.XXXXXX)"
  DATA="$BASE/data"
  OBJECT_ROOT="$BASE/objects"
  DB_PORT="${I6_MEDIA_DB_PORT:-$((57000 + RANDOM % 400))}"
  initdb -D "$DATA" --no-locale --encoding=UTF8 --auth=trust >/dev/null
  pg_ctl -D "$DATA" -o "-p $DB_PORT" -l "$BASE/postgres.log" start >/dev/null
  until pg_isready -h 127.0.0.1 -p "$DB_PORT" >/dev/null 2>&1; do sleep 0.2; done
  createdb -h 127.0.0.1 -p "$DB_PORT" scolvpet_i6_media
  DB_URL="postgres://$(whoami)@127.0.0.1:$DB_PORT/scolvpet_i6_media?sslmode=disable"
else
  OBJECT_ROOT="${IMPORT_OBJECT_STORE_DIR:-${TMPDIR:-/tmp}/scolvpet-i6-media-objects}"
fi

DATABASE_URL="$DB_URL" "$ROOT/db/scripts/migrate.sh" --seed >/dev/null

API_BIN="$(mktemp /tmp/scolvpet-i6-media-api.XXXXXX)"
(
  cd "$ROOT/api"
  "$ROOT/scripts/with-timeout.sh" 120 go build -o "$API_BIN" ./cmd/server
)
(
  export DATABASE_URL="$DB_URL"
  export API_ADDR=":$API_PORT"
  export SMS_MOCK_CODE="$CODE"
  export IMPORT_OBJECT_STORE_DIR="$OBJECT_ROOT"
  export OBJECT_STORE_PROVIDER=local
  export OUTBOX_PUBLISHER_MODE=success
  exec "$API_BIN" >"$API_LOG" 2>&1
) &
API_PID="$!"

for attempt in {1..100}; do
  if curl -fsS "$API_URL/readyz" >/dev/null 2>&1; then break; fi
  if ! kill -0 "$API_PID" >/dev/null 2>&1; then
    tail -n 60 "$API_LOG" >&2 || true
    exit 1
  fi
  sleep 0.3
done
curl -fsS "$API_URL/readyz" >/dev/null

json_field() { jq -r "$1"; }
header_value() {
  local file="$1" name="$2"
  awk -F': ' -v wanted="$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]')" '
    tolower($1) == wanted { gsub("\r", "", $2); print $2; exit }
  ' "$file"
}
assert_status() {
  local actual="$1" expected="$2" label="$3"
  [[ "$actual" == "$expected" ]] || { printf '%s: status=%s want=%s\n' "$label" "$actual" "$expected" >&2; exit 1; }
}
assert_replayed() {
  local file="$1" label="$2"
  [[ "$(header_value "$file" Idempotency-Replayed)" == "true" ]] || { printf '%s: replay header missing\n' "$label" >&2; exit 1; }
}

CODE_RESPONSE="$(curl -fsS -X POST "$API_URL/v1/auth/verification-codes" \
  -H 'Content-Type: application/json' -H "Idempotency-Key: i6-media-$RUN_ID-code" \
  -d "{\"phone\":\"$PHONE\",\"purpose\":\"login\"}")"
VERIFICATION_ID="$(printf '%s' "$CODE_RESPONSE" | json_field '.data.verification_id')"
SESSION="$(curl -fsS -X POST "$API_URL/v1/auth/sessions" \
  -H 'Content-Type: application/json' -H "Idempotency-Key: i6-media-$RUN_ID-login" \
  -d "{\"phone\":\"$PHONE\",\"verification_id\":\"$VERIFICATION_ID\",\"code\":\"$CODE\",\"device\":{\"platform\":\"ios\",\"app_version\":\"i6-media-smoke\"}}")"
TOKEN="$(printf '%s' "$SESSION" | json_field '.data.access_token')"
[[ -n "$TOKEN" && "$TOKEN" != "null" ]] || { printf 'session did not return access token\n' >&2; exit 1; }

TEMPLATES="$(curl -fsS "$API_URL/v1/species-rule-templates" -H "Authorization: Bearer $TOKEN")"
RULE_ID="$(printf '%s' "$TEMPLATES" | json_field '.data[0].id')"
HAMSTER_PAYLOAD="$(jq -cn --arg rule "$RULE_ID" --arg code "I6-MEDIA-$RUN_ID" \
  '{internal_code:$code,name:"I6 Media Smoke",variety_code:"syrian",species_rule_version_id:$rule,sex:"female",birth_date:"2026-05-01",source_type:"introduced"}')"
HAMSTER="$(curl -fsS -X POST "$API_URL/v1/hamsters" \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -H "Idempotency-Key: i6-media-$RUN_ID-hamster" -d "$HAMSTER_PAYLOAD")"
HAMSTER_ID="$(printf '%s' "$HAMSTER" | json_field '.data.id')"
HAMSTER_OWNER_ID="$(printf '%s' "$HAMSTER" | json_field '.data.owner_id')"
[[ -n "$HAMSTER_ID" && "$HAMSTER_ID" != "null" ]] || { printf 'hamster fixture was not created\n' >&2; exit 1; }

FIXTURE_FILE="$(mktemp /tmp/scolvpet-i6-media-fixture.XXXXXX)"
PNG_FIXTURE='iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII='
if ! printf '%s' "$PNG_FIXTURE" | base64 -D > "$FIXTURE_FILE" 2>/dev/null; then
  printf '%s' "$PNG_FIXTURE" | base64 -d > "$FIXTURE_FILE"
fi
SIZE_BYTES="$(wc -c < "$FIXTURE_FILE" | tr -d ' ')"
SHA256="$(shasum -a 256 "$FIXTURE_FILE" | awk '{print $1}')"
PRESIGN_PAYLOAD="$(jq -cn --arg file "fixture-$RUN_ID.png" --arg type image/png --arg sha "$SHA256" --argjson size "$SIZE_BYTES" \
  '{file_name:$file,content_type:$type,size_bytes:$size,sha256:$sha,purpose:"hamster_profile"}')"
PRESIGN_HEADERS="$(mktemp /tmp/scolvpet-i6-media-presign-headers.XXXXXX)"
PRESIGN_KEY="i6-media-$RUN_ID-presign"
PRESIGN="$(curl -fsS -D "$PRESIGN_HEADERS" -X POST "$API_URL/v1/media/uploads/presign" \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -H "Idempotency-Key: $PRESIGN_KEY" -d "$PRESIGN_PAYLOAD")"
UPLOAD_ID="$(printf '%s' "$PRESIGN" | json_field '.data.id')"
UPLOAD_URL="$(printf '%s' "$PRESIGN" | json_field '.data.upload_url')"
UPLOAD_ETAG="$(header_value "$PRESIGN_HEADERS" ETag)"
[[ -n "$UPLOAD_ID" && "$UPLOAD_ID" != "null" && "$UPLOAD_ETAG" == '"1"' ]] || { printf 'presign response missing id or ETag\n' >&2; exit 1; }

PRESIGN_REPLAY_HEADERS="$(mktemp /tmp/scolvpet-i6-media-presign-replay-headers.XXXXXX)"
PRESIGN_REPLAY="$(curl -fsS -D "$PRESIGN_REPLAY_HEADERS" -X POST "$API_URL/v1/media/uploads/presign" \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -H "Idempotency-Key: $PRESIGN_KEY" -d "$PRESIGN_PAYLOAD")"
[[ "$(printf '%s' "$PRESIGN" | jq -S -c '.data')" == "$(printf '%s' "$PRESIGN_REPLAY" | jq -S -c '.data')" ]] || { printf 'presign replay data mismatch\n' >&2; exit 1; }
assert_replayed "$PRESIGN_REPLAY_HEADERS" presign
[[ -n "$(header_value "$PRESIGN_REPLAY_HEADERS" ETag)" && -n "$(header_value "$PRESIGN_REPLAY_HEADERS" Location)" ]] || { printf 'presign replay headers missing\n' >&2; exit 1; }

PUT_HEADERS="$(mktemp /tmp/scolvpet-i6-media-put-headers.XXXXXX)"
PUT_KEY="i6-media-$RUN_ID-put"
PUT="$(curl -fsS -D "$PUT_HEADERS" -X PUT "$API_URL$UPLOAD_URL" \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: image/png' \
  -H "Idempotency-Key: $PUT_KEY" --data-binary "@$FIXTURE_FILE")"
[[ "$(header_value "$PUT_HEADERS" ETag)" == '"1"' ]] || { printf 'content PUT missing ETag\n' >&2; exit 1; }
PUT_REPLAY_HEADERS="$(mktemp /tmp/scolvpet-i6-media-put-replay-headers.XXXXXX)"
PUT_REPLAY="$(curl -fsS -D "$PUT_REPLAY_HEADERS" -X PUT "$API_URL$UPLOAD_URL" \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: image/png' \
  -H "Idempotency-Key: $PUT_KEY" --data-binary "@$FIXTURE_FILE")"
[[ "$(printf '%s' "$PUT" | jq -S -c '.data')" == "$(printf '%s' "$PUT_REPLAY" | jq -S -c '.data')" ]] || { printf 'content PUT replay data mismatch\n' >&2; exit 1; }
assert_replayed "$PUT_REPLAY_HEADERS" content-put

COMPLETE_PAYLOAD="$(jq -cn --arg etag "local-$RUN_ID" --arg sha "$SHA256" --argjson size "$SIZE_BYTES" \
  '{object_etag:$etag,size_bytes:$size,sha256:$sha}')"
COMPLETE_HEADERS="$(mktemp /tmp/scolvpet-i6-media-complete-headers.XXXXXX)"
COMPLETE_KEY="i6-media-$RUN_ID-complete"
COMPLETE="$(curl -fsS -D "$COMPLETE_HEADERS" -X POST "$API_URL/v1/media/uploads/$UPLOAD_ID/complete" \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -H "If-Match: $UPLOAD_ETAG" -H "Idempotency-Key: $COMPLETE_KEY" -d "$COMPLETE_PAYLOAD")"
MEDIA_ID="$(printf '%s' "$COMPLETE" | json_field '.data.id')"
MEDIA_ETAG="$(header_value "$COMPLETE_HEADERS" ETag)"
[[ -n "$MEDIA_ID" && "$MEDIA_ID" != "null" && "$MEDIA_ETAG" == '"1"' ]] || { printf 'complete response missing media id or ETag\n' >&2; exit 1; }

COMPLETE_REPLAY_HEADERS="$(mktemp /tmp/scolvpet-i6-media-complete-replay-headers.XXXXXX)"
COMPLETE_REPLAY="$(curl -fsS -D "$COMPLETE_REPLAY_HEADERS" -X POST "$API_URL/v1/media/uploads/$UPLOAD_ID/complete" \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -H "If-Match: $UPLOAD_ETAG" -H "Idempotency-Key: $COMPLETE_KEY" -d "$COMPLETE_PAYLOAD")"
[[ "$(printf '%s' "$COMPLETE" | jq -S -c '.data')" == "$(printf '%s' "$COMPLETE_REPLAY" | jq -S -c '.data')" ]] || { printf 'complete replay data mismatch\n' >&2; exit 1; }
assert_replayed "$COMPLETE_REPLAY_HEADERS" complete
[[ "$(header_value "$COMPLETE_REPLAY_HEADERS" ETag)" == '"1"' && -n "$(header_value "$COMPLETE_REPLAY_HEADERS" Location)" ]] || { printf 'complete replay headers missing\n' >&2; exit 1; }

MEDIA_GET_HEADERS="$(mktemp /tmp/scolvpet-i6-media-get-headers.XXXXXX)"
MEDIA_GET="$(curl -fsS -D "$MEDIA_GET_HEADERS" "$API_URL/v1/media/$MEDIA_ID" -H "Authorization: Bearer $TOKEN")"
[[ "$(printf '%s' "$MEDIA_GET" | json_field '.data.sha256')" == "$SHA256" ]] || { printf 'media SHA-256 mismatch after complete\n' >&2; exit 1; }
MEDIA_ETAG="$(header_value "$MEDIA_GET_HEADERS" ETag)"

for attempt in {1..30}; do
  STATUS="$(curl -fsS "$API_URL/v1/media/$MEDIA_ID/transcode-status" -H "Authorization: Bearer $TOKEN")"
  if [[ "$(printf '%s' "$STATUS" | json_field '.data.status')" == "succeeded" ]]; then break; fi
  sleep 0.5
done
[[ "$(printf '%s' "$STATUS" | json_field '.data.status')" == "succeeded" ]] || { printf 'initial media processor did not finish\n' >&2; exit 1; }

EDIT_PAYLOAD='{"operations":[{"op":"resize","width":1,"height":1}],"output_format":"png"}'
EDIT_HEADERS="$(mktemp /tmp/scolvpet-i6-media-edit-headers.XXXXXX)"
EDIT_KEY="i6-media-$RUN_ID-edit"
EDIT="$(curl -fsS -D "$EDIT_HEADERS" -X POST "$API_URL/v1/media/$MEDIA_ID/edit-recipes" \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -H "If-Match: $MEDIA_ETAG" -H "Idempotency-Key: $EDIT_KEY" -d "$EDIT_PAYLOAD")"
VARIANT_ID="$(printf '%s' "$EDIT" | json_field '.data.recipe_id')"
MEDIA_ETAG="$(header_value "$EDIT_HEADERS" ETag)"
[[ -n "$VARIANT_ID" && "$VARIANT_ID" != "null" && "$MEDIA_ETAG" == '"2"' ]] || { printf 'edit recipe did not bump media version\n' >&2; exit 1; }
STATUS="$(curl -fsS "$API_URL/v1/media/$MEDIA_ID/transcode-status" -H "Authorization: Bearer $TOKEN")"
[[ "$(printf '%s' "$STATUS" | json_field '.data.status')" == "queued" ]] || { printf 'edit processing status is not queued\n' >&2; exit 1; }

# Inject a failed processor result after the successful run so the retry
# contract is exercised against the real media worker.
psql -X -v ON_ERROR_STOP=1 "$DB_URL" \
  -v owner_id="$HAMSTER_OWNER_ID" -v variant_id="$VARIANT_ID" -v job_id="$(printf '%s' "$EDIT" | json_field '.data.job.id')" <<'SQL'
UPDATE media_variant
SET status='failed', failure_code='SMOKE_PROCESSOR_FAILURE', failure_detail='injected by i6 media smoke'
WHERE owner_id = :'owner_id'::uuid AND id = :'variant_id'::uuid;
UPDATE async_job
SET status='failed', started_at=coalesce(started_at, now() - interval '1 second'), finished_at=now(), error_code='SMOKE_PROCESSOR_FAILURE', error_detail='injected by i6 media smoke'
WHERE owner_id = :'owner_id'::uuid AND id = :'job_id'::uuid;
SQL

RETRY_PAYLOAD="$(jq -cn --arg variant "$VARIANT_ID" \
  '{scope:"failed_variants",variant_ids:[$variant],reason:"i6 media smoke retry"}')"
RETRY_HEADERS="$(mktemp /tmp/scolvpet-i6-media-retry-headers.XXXXXX)"
RETRY="$(curl -fsS -D "$RETRY_HEADERS" -X POST "$API_URL/v1/media/$MEDIA_ID/retry-processing" \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -H "If-Match: $MEDIA_ETAG" -H "Idempotency-Key: i6-media-$RUN_ID-retry" -d "$RETRY_PAYLOAD")"
MEDIA_ETAG="$(header_value "$RETRY_HEADERS" ETag)"
[[ "$(printf '%s' "$RETRY" | json_field '.data.job.status')" == "queued" && "$MEDIA_ETAG" == '"3"' ]] || { printf 'retry did not queue a new job or bump media version\n' >&2; exit 1; }
for attempt in {1..30}; do
  STATUS="$(curl -fsS "$API_URL/v1/media/$MEDIA_ID/transcode-status" -H "Authorization: Bearer $TOKEN")"
  if [[ "$(printf '%s' "$STATUS" | json_field '.data.status')" == "succeeded" ]]; then break; fi
  sleep 0.5
done
[[ "$(printf '%s' "$STATUS" | json_field '.data.status')" == "succeeded" ]] || { printf 'retry media processor did not finish\n' >&2; exit 1; }

COVER_PAYLOAD="$(jq -cn --arg variant "$VARIANT_ID" '{media_variant_id:$variant}')"
COVER_HEADERS="$(mktemp /tmp/scolvpet-i6-media-cover-headers.XXXXXX)"
COVER="$(curl -fsS -D "$COVER_HEADERS" -X PUT "$API_URL/v1/media/$MEDIA_ID/cover" \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -H "If-Match: $MEDIA_ETAG" -H "Idempotency-Key: i6-media-$RUN_ID-cover" -d "$COVER_PAYLOAD")"
MEDIA_ETAG="$(header_value "$COVER_HEADERS" ETag)"
[[ "$(printf '%s' "$COVER" | json_field '.data.id')" == "$MEDIA_ID" && "$MEDIA_ETAG" == '"4"' ]] || { printf 'cover update did not persist or bump media version\n' >&2; exit 1; }

SHARE_PAYLOAD="$(jq -cn --arg subject "$HAMSTER_ID" --arg media "$MEDIA_ID" \
  '{subject_type:"hamster",subject_id:$subject,fields:["name","sex","birth_date","variety","cover"],media_ids:[$media]}')"
SHARE_HEADERS="$(mktemp /tmp/scolvpet-i6-media-share-headers.XXXXXX)"
SHARE="$(curl -fsS -D "$SHARE_HEADERS" -X POST "$API_URL/v1/shares" \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -H "Idempotency-Key: i6-media-$RUN_ID-share" -d "$SHARE_PAYLOAD")"
SHARE_ID="$(printf '%s' "$SHARE" | json_field '.data.id')"
SHARE_TOKEN="$(printf '%s' "$SHARE" | json_field '.data.token')"
SHARE_ETAG="$(header_value "$SHARE_HEADERS" ETag)"
[[ -n "$SHARE_ID" && "$SHARE_ID" != "null" && -n "$SHARE_TOKEN" && "$SHARE_TOKEN" != "null" && "$SHARE_ETAG" == '"1"' ]] || { printf 'share was not created with token and ETag\n' >&2; exit 1; }

PREVIEW="$(curl -fsS "$API_URL/v1/shares/$SHARE_ID/preview" -H "Authorization: Bearer $TOKEN")"
[[ "$(printf '%s' "$PREVIEW" | json_field '.data.subject_type')" == "hamster" && "$(printf '%s' "$PREVIEW" | json_field '.data.media | length')" == "1" ]] || { printf 'owner share preview projection mismatch\n' >&2; exit 1; }
PUBLIC="$(curl -fsS "$API_URL/v1/public/shares/$SHARE_TOKEN")"
[[ "$(printf '%s' "$PUBLIC" | json_field '.data.share_id')" == "$SHARE_ID" && "$(printf '%s' "$PUBLIC" | json_field '.data.subject_type')" == "hamster" && "$(printf '%s' "$PUBLIC" | json_field '.data.display.name')" == "I6 Media Smoke" && "$(printf '%s' "$PUBLIC" | json_field '.data.display.birth_date')" == "2026-05-01" ]] || { printf 'public share token projection mismatch\n' >&2; exit 1; }
PUBLIC_MEDIA_URL="$(printf '%s' "$PUBLIC" | json_field '.data.media[0].url')"
[[ "$PUBLIC_MEDIA_URL" != "null" && -n "$PUBLIC_MEDIA_URL" ]] || { printf 'public share media URL missing\n' >&2; exit 1; }
curl -fsS "$API_URL$PUBLIC_MEDIA_URL" -o /tmp/scolvpet-i6-media-public-body \
  -D /tmp/scolvpet-i6-media-public-headers >/dev/null
grep -qi '^Content-Type: image/png' /tmp/scolvpet-i6-media-public-headers || { printf 'public media content type missing\n' >&2; exit 1; }

REVOKE_PAYLOAD='{"reason":"i6 media smoke revoke"}'
REVOKE_HEADERS="$(mktemp /tmp/scolvpet-i6-media-revoke-headers.XXXXXX)"
REVOKE_KEY="i6-media-$RUN_ID-revoke"
REVOKE="$(curl -fsS -D "$REVOKE_HEADERS" -X POST "$API_URL/v1/shares/$SHARE_ID/revoke" \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -H "If-Match: $SHARE_ETAG" -H "Idempotency-Key: $REVOKE_KEY" -d "$REVOKE_PAYLOAD")"
[[ "$(printf '%s' "$REVOKE" | json_field '.data.share.revoked_at')" != "null" && "$(header_value "$REVOKE_HEADERS" ETag)" == '"2"' ]] || { printf 'share revoke did not persist\n' >&2; exit 1; }
REVOKE_REPLAY_HEADERS="$(mktemp /tmp/scolvpet-i6-media-revoke-replay-headers.XXXXXX)"
REVOKE_REPLAY="$(curl -fsS -D "$REVOKE_REPLAY_HEADERS" -X POST "$API_URL/v1/shares/$SHARE_ID/revoke" \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -H "If-Match: $SHARE_ETAG" -H "Idempotency-Key: $REVOKE_KEY" -d "$REVOKE_PAYLOAD")"
[[ "$(printf '%s' "$REVOKE" | jq -S -c '.data')" == "$(printf '%s' "$REVOKE_REPLAY" | jq -S -c '.data')" ]] || { printf 'revoke replay data mismatch\n' >&2; exit 1; }
assert_replayed "$REVOKE_REPLAY_HEADERS" revoke

PUBLIC_STATUS="$(curl -sS -o /tmp/scolvpet-i6-media-public-revoked.json -w '%{http_code}' "$API_URL/v1/public/shares/$SHARE_TOKEN")"
assert_status "$PUBLIC_STATUS" 404 public-revoked
PUBLIC_MEDIA_STATUS="$(curl -sS -o /tmp/scolvpet-i6-media-public-revoked-body -w '%{http_code}' "$API_URL$PUBLIC_MEDIA_URL")"
assert_status "$PUBLIC_MEDIA_STATUS" 404 public-media-revoked

EVENTS=""
OUTBOX=""
for attempt in {1..40}; do
  EVENTS="$(psql -XAt "$DB_URL" -c "select count(*) from domain_event where owner_id = '$HAMSTER_OWNER_ID'::uuid;")"
  OUTBOX="$(psql -XAt "$DB_URL" -c "select count(*) from outbox_message where owner_id = '$HAMSTER_OWNER_ID'::uuid and status='published';")"
  if [[ "$EVENTS" -ge 8 && "$OUTBOX" -ge 8 ]]; then break; fi
  sleep 0.5
done
[[ "$EVENTS" -ge 8 ]] || { printf 'media event count too low: %s\n' "$EVENTS" >&2; exit 1; }
[[ "$OUTBOX" -ge 8 ]] || { printf 'published outbox count too low: %s\n' "$OUTBOX" >&2; exit 1; }

rm -f "$PRESIGN_HEADERS" "$PRESIGN_REPLAY_HEADERS" "$COMPLETE_HEADERS" "$COMPLETE_REPLAY_HEADERS" \
  "$PUT_HEADERS" "$PUT_REPLAY_HEADERS" "$MEDIA_GET_HEADERS" "$EDIT_HEADERS" "$RETRY_HEADERS" "$COVER_HEADERS" "$SHARE_HEADERS" \
  "$REVOKE_HEADERS" "$REVOKE_REPLAY_HEADERS" "$FIXTURE_FILE" \
  /tmp/scolvpet-i6-media-public-revoked.json /tmp/scolvpet-i6-media-public-body \
  /tmp/scolvpet-i6-media-public-headers /tmp/scolvpet-i6-media-public-revoked-body

printf 'I6 media smoke verified: upload=%s media=%s variant=%s hamster=%s events=%s published_outbox=%s\n' \
  "$UPLOAD_ID" "$MEDIA_ID" "$VARIANT_ID" "$HAMSTER_ID" "$EVENTS" "$OUTBOX"
