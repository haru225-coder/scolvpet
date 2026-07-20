#!/usr/bin/env bash
# GATE-03 minimal: public site reserve → crm_reservation → staff list sees it.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
API_PORT="${PUBLIC_RESERVATION_API_PORT:-18081}"
API_URL="http://127.0.0.1:$API_PORT"
PHONE="+8613800138200"
CODE="${SMS_MOCK_CODE:-123456}"
RUN_ID="${PUBLIC_RESERVATION_RUN_ID:-$(date +%s)}"
SLUG="gate03-${RUN_ID}"
BASE=""
DATA=""
API_PID=""
API_BIN=""
API_LOG="/tmp/scolvpet-public-reservation-api.log"

if ! command -v initdb >/dev/null 2>&1 && command -v pg_config >/dev/null 2>&1; then
  export PATH="$(pg_config --bindir):$PATH"
fi

cleanup() {
  if [[ -n "$API_PID" ]]; then
    kill "$API_PID" >/dev/null 2>&1 || true
    wait "$API_PID" >/dev/null 2>&1 || true
  fi
  if [[ -n "$API_BIN" ]]; then rm -f "$API_BIN"; fi
  if [[ -n "$DATA" ]]; then pg_ctl -D "$DATA" stop -m fast >/dev/null 2>&1 || true; fi
  if [[ -n "$BASE" ]]; then rm -rf "$BASE"; fi
}
trap cleanup EXIT

json_field() { jq -r "$1"; }

if [[ -n "${DATABASE_URL:-}" && "${PUBLIC_RESERVATION_USE_EXTERNAL_DB:-}" == "1" ]]; then
  DB_URL="$DATABASE_URL"
else
  BASE="$(mktemp -d /tmp/scolvpet-public-reservation.XXXXXX)"
  DATA="$BASE/data"
  PORT="${PUBLIC_RESERVATION_DB_PORT:-$((56100 + RANDOM % 400))}"
  initdb -D "$DATA" --no-locale --encoding=UTF8 --auth=trust >/dev/null
  pg_ctl -D "$DATA" -o "-p $PORT" -l "$BASE/postgres.log" start >/dev/null
  until pg_isready -h 127.0.0.1 -p "$PORT" >/dev/null 2>&1; do sleep 0.2; done
  createdb -h 127.0.0.1 -p "$PORT" scolvpet_public_reservation
  DB_URL="postgres://$(whoami)@127.0.0.1:$PORT/scolvpet_public_reservation?sslmode=disable"
  DATABASE_URL="$DB_URL" "$ROOT/db/scripts/migrate.sh" --seed >/dev/null
fi

API_BIN="$(mktemp /tmp/scolvpet-public-reservation-api.XXXXXX)"
(
  cd "$ROOT/api"
  "$ROOT/scripts/with-timeout.sh" 120 go build -o "$API_BIN" ./cmd/server
)
(
  export DATABASE_URL="$DB_URL"
  export API_ADDR=":$API_PORT"
  export SMS_MOCK_CODE="$CODE"
  export SMS_PROVIDER=mock
  export JWT_SECRET=public-reservation-smoke-secret
  exec "$API_BIN" >"$API_LOG" 2>&1
) &
API_PID="$!"
for _ in {1..100}; do
  if curl -fsS "$API_URL/readyz" >/dev/null 2>&1; then break; fi
  if ! kill -0 "$API_PID" >/dev/null 2>&1; then
    tail -n 60 "$API_LOG" >&2 || true
    exit 1
  fi
  sleep 0.3
done
curl -fsS "$API_URL/readyz" >/dev/null

# --- Staff auth ---
CODE_RESPONSE="$(curl -fsS -X POST "$API_URL/v1/auth/verification-codes" \
  -H 'Content-Type: application/json' -H "Idempotency-Key: pr-$RUN_ID-code" \
  -d "{\"phone\":\"$PHONE\",\"purpose\":\"login\"}")"
VERIFICATION_ID="$(printf '%s' "$CODE_RESPONSE" | json_field '.data.verification_id')"
SESSION="$(curl -fsS -X POST "$API_URL/v1/auth/sessions" \
  -H 'Content-Type: application/json' -H "Idempotency-Key: pr-$RUN_ID-login" \
  -d "{\"phone\":\"$PHONE\",\"verification_id\":\"$VERIFICATION_ID\",\"code\":\"$CODE\",\"device\":{\"platform\":\"ios\",\"app_version\":\"public-reservation-smoke\"}}")"
TOKEN="$(printf '%s' "$SESSION" | json_field '.data.access_token')"
[[ -n "$TOKEN" && "$TOKEN" != "null" ]] || { printf 'login failed\n' >&2; exit 1; }
AUTH=(-H "Authorization: Bearer $TOKEN")

# --- Real hamster ---
TEMPLATES="$(curl -fsS "$API_URL/v1/species-rule-templates" "${AUTH[@]}")"
RULE_ID="$(printf '%s' "$TEMPLATES" | json_field '.data[0].id')"
[[ -n "$RULE_ID" && "$RULE_ID" != "null" ]] || { printf 'species rule template missing\n' >&2; exit 1; }

HAMSTER_PAYLOAD="$(jq -cn --arg rule "$RULE_ID" --arg code "PR-$RUN_ID" \
  '{internal_code:$code,name:"奶茶",variety_code:"syrian",species_rule_version_id:$rule,sex:"female",birth_date:"2026-04-18",source_type:"introduced"}')"
HAMSTER="$(curl -fsS -X POST "$API_URL/v1/hamsters" \
  "${AUTH[@]}" -H 'Content-Type: application/json' \
  -H "Idempotency-Key: pr-$RUN_ID-hamster" -d "$HAMSTER_PAYLOAD")"
HAMSTER_ID="$(printf '%s' "$HAMSTER" | json_field '.data.id')"
[[ -n "$HAMSTER_ID" && "$HAMSTER_ID" != "null" ]] || { printf 'hamster create failed: %s\n' "$HAMSTER" >&2; exit 1; }

# --- Publish public profile (reservable source) ---
PROFILE_PAYLOAD="$(jq -cn \
  '{public_name:"奶茶",summary:"亲人、活动规律",traits:["亲人"],filming_status:"ready",published:true,consultable:true,cta_text:"预订这只",price_label:"咨询报价"}')"
curl -fsS -X PUT "$API_URL/v1/growth/public-hamsters/$HAMSTER_ID" \
  "${AUTH[@]}" -H 'Content-Type: application/json' \
  -H "Idempotency-Key: pr-$RUN_ID-profile" -d "$PROFILE_PAYLOAD" >/dev/null

# --- Public site ---
SITE_PAYLOAD="$(jq -cn --arg slug "$SLUG" \
  '{slug:$slug,title:"GATE03 测试熊舍",tagline:"公开预订验收",about:"smoke",theme_color:"#c77852",show_stats:true,show_contact:true}')"
curl -fsS -X PUT "$API_URL/v1/public-site" \
  "${AUTH[@]}" -H 'Content-Type: application/json' \
  -H "Idempotency-Key: pr-$RUN_ID-site" -d "$SITE_PAYLOAD" >/dev/null
curl -fsS -X POST "$API_URL/v1/public-site/publish" \
  "${AUTH[@]}" -H "Idempotency-Key: pr-$RUN_ID-publish" >/dev/null

# --- Catalog: Backend reservable true ---
CATALOG="$(curl -fsS "$API_URL/v1/public/sites/$SLUG/catalog")"
RESERVABLE="$(printf '%s' "$CATALOG" | jq -r --arg id "$HAMSTER_ID" \
  '.data.hamsters[]? | select(.hamster_id==$id) | .reservable')"
[[ "$RESERVABLE" == "true" ]] || {
  printf 'catalog reservable want true got %s\n%s\n' "$RESERVABLE" "$CATALOG" >&2
  exit 1
}

# --- Customer public reservation (no staff token) ---
RESERVE_PAYLOAD="$(jq -cn --arg hid "$HAMSTER_ID" \
  '{hamster_id:$hid,name:"阿雪",phone:"13900001111",wechat:"axue_wx",notes:"周末方便看鼠"}')"
RESERVE="$(curl -fsS -X POST "$API_URL/v1/public/sites/$SLUG/reservations" \
  -H 'Content-Type: application/json' \
  -H "Idempotency-Key: pr-$RUN_ID-reserve" \
  -d "$RESERVE_PAYLOAD")"
RESERVATION_ID="$(printf '%s' "$RESERVE" | json_field '.data.reservation_id')"
CONTACT_ID="$(printf '%s' "$RESERVE" | json_field '.data.contact_id')"
STATUS="$(printf '%s' "$RESERVE" | json_field '.data.status')"
[[ -n "$RESERVATION_ID" && "$RESERVATION_ID" != "null" ]] || { printf 'reserve failed: %s\n' "$RESERVE" >&2; exit 1; }
[[ "$STATUS" == "held" ]] || { printf 'status want held got %s\n' "$STATUS" >&2; exit 1; }

# --- Contact reuse on second lead/reserve attempt with same phone ---
RESERVE2_STATUS="$(curl -sS -o /tmp/scolvpet-pr-reserve2.json -w '%{http_code}' \
  -X POST "$API_URL/v1/public/sites/$SLUG/reservations" \
  -H 'Content-Type: application/json' \
  -H "Idempotency-Key: pr-$RUN_ID-reserve-dup" \
  -d "$RESERVE_PAYLOAD")"
[[ "$RESERVE2_STATUS" == "409" ]] || {
  printf 'double book want 409 got %s body=%s\n' "$RESERVE2_STATUS" "$(cat /tmp/scolvpet-pr-reserve2.json)" >&2
  exit 1
}

# --- Staff CRM list sees the reservation ---
LIST="$(curl -fsS "$API_URL/v1/crm/reservations" "${AUTH[@]}")"
FOUND="$(printf '%s' "$LIST" | jq -r --arg id "$RESERVATION_ID" \
  '[.data[]? | select(.id==$id)] | length')"
[[ "$FOUND" == "1" ]] || { printf 'staff list missing reservation: %s\n' "$LIST" >&2; exit 1; }
LIST_CONTACT="$(printf '%s' "$LIST" | jq -r --arg id "$RESERVATION_ID" \
  '.data[] | select(.id==$id) | .contact_name')"
LIST_HAMSTER="$(printf '%s' "$LIST" | jq -r --arg id "$RESERVATION_ID" \
  '.data[] | select(.id==$id) | .hamster_id')"
LIST_STATUS="$(printf '%s' "$LIST" | jq -r --arg id "$RESERVATION_ID" \
  '.data[] | select(.id==$id) | .status')"
[[ "$LIST_CONTACT" == "阿雪" ]] || { printf 'contact_name want 阿雪 got %s\n' "$LIST_CONTACT" >&2; exit 1; }
[[ "$LIST_HAMSTER" == "$HAMSTER_ID" ]] || { printf 'hamster_id mismatch\n' >&2; exit 1; }
[[ "$LIST_STATUS" == "held" ]] || { printf 'list status want held got %s\n' "$LIST_STATUS" >&2; exit 1; }

# --- Contact appears in CRM contacts ---
CONTACTS="$(curl -fsS "$API_URL/v1/crm/contacts" "${AUTH[@]}")"
CONTACT_FOUND="$(printf '%s' "$CONTACTS" | jq -r --arg id "$CONTACT_ID" \
  '[.data[]? | select(.id==$id)] | length')"
[[ "$CONTACT_FOUND" == "1" ]] || { printf 'contact missing in CRM\n' >&2; exit 1; }

# --- After open reservation, catalog reservable false ---
CATALOG2="$(curl -fsS "$API_URL/v1/public/sites/$SLUG/catalog")"
RESERVABLE2="$(printf '%s' "$CATALOG2" | jq -r --arg id "$HAMSTER_ID" \
  '.data.hamsters[]? | select(.hamster_id==$id) | .reservable')"
[[ "$RESERVABLE2" == "false" ]] || {
  printf 'after reserve catalog reservable want false got %s\n' "$RESERVABLE2" >&2
  exit 1
}

# --- Staff confirm ---
CONFIRMED="$(curl -fsS -X POST "$API_URL/v1/crm/reservations/$RESERVATION_ID/confirm" \
  "${AUTH[@]}" -H "Idempotency-Key: pr-$RUN_ID-confirm")"
[[ "$(printf '%s' "$CONFIRMED" | json_field '.data.status')" == "confirmed" ]] || {
  printf 'confirm failed: %s\n' "$CONFIRMED" >&2
  exit 1
}

printf 'public-reservation smoke PASS: reservation=%s contact=%s hamster=%s slug=%s\n' \
  "$RESERVATION_ID" "$CONTACT_ID" "$HAMSTER_ID" "$SLUG"
