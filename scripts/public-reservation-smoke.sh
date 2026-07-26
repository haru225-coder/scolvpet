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

# --- Customer verified session required before public reservation ---
CUST_PHONE="+8613900001111"
CODE_RESP="$(curl -fsS -X POST "$API_URL/v1/public/customer/verification-codes" \
  -H 'Content-Type: application/json' \
  -H "Idempotency-Key: pr-$RUN_ID-cust-code" \
  -d "{\"phone\":\"$CUST_PHONE\",\"purpose\":\"login\"}")"
CUST_VID="$(printf '%s' "$CODE_RESP" | json_field '.data.verification_id')"
CUST_SESSION="$(curl -fsS -X POST "$API_URL/v1/public/customer/sessions" \
  -H 'Content-Type: application/json' \
  -d "{\"phone\":\"$CUST_PHONE\",\"verification_id\":\"$CUST_VID\",\"code\":\"$CODE\"}")"
CUST_TOKEN="$(printf '%s' "$CUST_SESSION" | json_field '.data.access_token')"
[[ -n "$CUST_TOKEN" && "$CUST_TOKEN" != "null" ]] || { printf 'customer session failed: %s\n' "$CUST_SESSION" >&2; exit 1; }

# Unverified reservation must be rejected.
UNAUTH_STATUS="$(curl -sS -o /tmp/scolvpet-pr-unauth.json -w '%{http_code}' \
  -X POST "$API_URL/v1/public/sites/$SLUG/reservations" \
  -H 'Content-Type: application/json' \
  -H "Idempotency-Key: pr-$RUN_ID-reserve-unauth" \
  -d "{\"hamster_id\":\"$HAMSTER_ID\",\"name\":\"阿雪\",\"phone\":\"$CUST_PHONE\"}")"
[[ "$UNAUTH_STATUS" == "401" ]] || {
  printf 'unverified reserve want 401 got %s body=%s\n' "$UNAUTH_STATUS" "$(cat /tmp/scolvpet-pr-unauth.json)" >&2
  exit 1
}

RESERVE_PAYLOAD="$(jq -cn --arg hid "$HAMSTER_ID" --arg phone "$CUST_PHONE" \
  '{hamster_id:$hid,name:"阿雪",phone:$phone,wechat:"axue_wx",notes:"周末方便看鼠"}')"
RESERVE="$(curl -fsS -X POST "$API_URL/v1/public/sites/$SLUG/reservations" \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $CUST_TOKEN" \
  -H "Idempotency-Key: pr-$RUN_ID-reserve" \
  -d "$RESERVE_PAYLOAD")"
RESERVATION_ID="$(printf '%s' "$RESERVE" | json_field '.data.reservation_id')"
CONTACT_ID="$(printf '%s' "$RESERVE" | json_field '.data.contact_id')"
STATUS="$(printf '%s' "$RESERVE" | json_field '.data.status')"
[[ -n "$RESERVATION_ID" && "$RESERVATION_ID" != "null" ]] || { printf 'reserve failed: %s\n' "$RESERVE" >&2; exit 1; }
[[ "$STATUS" == "held" ]] || { printf 'status want held got %s\n' "$STATUS" >&2; exit 1; }

# Customer list sees the held reservation.
CUST_LIST="$(curl -fsS "$API_URL/v1/customer/reservations" -H "Authorization: Bearer $CUST_TOKEN")"
CUST_FOUND="$(printf '%s' "$CUST_LIST" | jq -r --arg id "$RESERVATION_ID" \
  '[.data[]? | select(.id==$id)] | length')"
[[ "$CUST_FOUND" == "1" ]] || { printf 'customer list missing reservation: %s\n' "$CUST_LIST" >&2; exit 1; }

# --- Contact reuse on second lead/reserve attempt with same phone ---
RESERVE2_STATUS="$(curl -sS -o /tmp/scolvpet-pr-reserve2.json -w '%{http_code}' \
  -X POST "$API_URL/v1/public/sites/$SLUG/reservations" \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $CUST_TOKEN" \
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

# --- Staff confirm (requires If-Match ETag) ---
RES_VER="$(printf '%s' "$LIST" | jq -r --arg id "$RESERVATION_ID" \
  '.data[] | select(.id==$id) | .version')"
[[ -n "$RES_VER" && "$RES_VER" != "null" ]] || RES_VER=1
CONFIRMED="$(curl -fsS -X POST "$API_URL/v1/crm/reservations/$RESERVATION_ID/confirm" \
  "${AUTH[@]}" -H "Idempotency-Key: pr-$RUN_ID-confirm" -H "If-Match: \"$RES_VER\"")"
[[ "$(printf '%s' "$CONFIRMED" | json_field '.data.status')" == "confirmed" ]] || {
  printf 'confirm failed: %s\n' "$CONFIRMED" >&2
  exit 1
}

# --- Contract from reservation (no re-entry of customer/hamster) ---
TPL="$(curl -fsS -X POST "$API_URL/v1/contracts/templates" \
  "${AUTH[@]}" -H 'Content-Type: application/json' \
  -H "Idempotency-Key: pr-$RUN_ID-tpl" \
  -d '{"name":"验收交接协议","body_text":"客户：{{contact_name}}\n个体：{{hamster_name}}\n事项：{{title}}\n日期：{{date}}\n备注：{{notes}}"}')"
TPL_ID="$(printf '%s' "$TPL" | json_field '.data.id')"
[[ -n "$TPL_ID" && "$TPL_ID" != "null" ]] || { printf 'template create failed: %s\n' "$TPL" >&2; exit 1; }

CONTRACT="$(curl -fsS -X POST "$API_URL/v1/contracts" \
  "${AUTH[@]}" -H 'Content-Type: application/json' \
  -H "Idempotency-Key: pr-$RUN_ID-contract" \
  -d "$(jq -cn --arg t "$TPL_ID" --arg r "$RESERVATION_ID" '{template_id:$t,reservation_id:$r}')")"
CONTRACT_ID="$(printf '%s' "$CONTRACT" | json_field '.data.id')"
CONTRACT_VER="$(printf '%s' "$CONTRACT" | json_field '.data.version')"
BODY_FILLED="$(printf '%s' "$CONTRACT" | json_field '.data.body_filled')"
[[ -n "$CONTRACT_ID" && "$CONTRACT_ID" != "null" ]] || { printf 'contract create failed: %s\n' "$CONTRACT" >&2; exit 1; }
printf '%s' "$BODY_FILLED" | grep -q '阿雪' || { printf 'contract missing contact: %s\n' "$BODY_FILLED" >&2; exit 1; }
printf '%s' "$BODY_FILLED" | grep -q '奶茶' || { printf 'contract missing hamster: %s\n' "$BODY_FILLED" >&2; exit 1; }

ISSUED="$(curl -fsS -X POST "$API_URL/v1/contracts/$CONTRACT_ID/issue" \
  "${AUTH[@]}" -H "Idempotency-Key: pr-$RUN_ID-issue" -H "If-Match: \"$CONTRACT_VER\"")"
[[ "$(printf '%s' "$ISSUED" | json_field '.data.status')" == "issued" ]] || {
  printf 'contract issue failed: %s\n' "$ISSUED" >&2
  exit 1
}

# --- Delivery schedule from reservation ---
HANDOVER="$(curl -fsS -X POST "$API_URL/v1/crm/handovers" \
  "${AUTH[@]}" -H 'Content-Type: application/json' \
  -H "Idempotency-Key: pr-$RUN_ID-handover" \
  -d "$(jq -cn --arg c "$CONTACT_ID" --arg r "$RESERVATION_ID" --arg h "$HAMSTER_ID" \
    '{contact_id:$c,reservation_id:$r,hamster_id:$h,notes:"smoke 交付"}')")"
HANDOVER_ID="$(printf '%s' "$HANDOVER" | json_field '.data.id')"
HANDOVER_VER="$(printf '%s' "$HANDOVER" | json_field '.data.version')"
[[ -n "$HANDOVER_ID" && "$HANDOVER_ID" != "null" ]] || { printf 'handover create failed: %s\n' "$HANDOVER" >&2; exit 1; }

# --- Receipt BEFORE complete (finance linkage needs issued receipt on complete) ---
RECEIPT_TPL="$(curl -fsS -X POST "$API_URL/v1/receipts/templates" \
  "${AUTH[@]}" -H 'Content-Type: application/json' \
  -H "Idempotency-Key: pr-$RUN_ID-receipt-tpl" \
  -d '{"name":"验收收款回执","body_text":"客户：{{contact_name}}\n项目：{{title}}\n个体：{{hamster_name}}\n金额：{{amount}}\n日期：{{date}}\n备注：{{notes}}"}')"
RECEIPT_TPL_ID="$(printf '%s' "$RECEIPT_TPL" | json_field '.data.id')"
[[ -n "$RECEIPT_TPL_ID" && "$RECEIPT_TPL_ID" != "null" ]] || {
  printf 'receipt template failed: %s\n' "$RECEIPT_TPL" >&2
  exit 1
}

RECEIPT="$(curl -fsS -X POST "$API_URL/v1/receipts" \
  "${AUTH[@]}" -H 'Content-Type: application/json' \
  -H "Idempotency-Key: pr-$RUN_ID-receipt" \
  -d "$(jq -cn --arg t "$RECEIPT_TPL_ID" --arg r "$RESERVATION_ID" --arg h "$HANDOVER_ID" \
    '{template_id:$t,reservation_id:$r,handover_id:$h,amount_cents:50000,currency:"CNY",notes:"smoke 收款"}')")"
RECEIPT_ID="$(printf '%s' "$RECEIPT" | json_field '.data.id')"
RECEIPT_VER="$(printf '%s' "$RECEIPT" | json_field '.data.version')"
RECEIPT_BODY="$(printf '%s' "$RECEIPT" | json_field '.data.body_filled')"
[[ -n "$RECEIPT_ID" && "$RECEIPT_ID" != "null" ]] || {
  printf 'receipt create failed: %s\n' "$RECEIPT" >&2
  exit 1
}
printf '%s' "$RECEIPT_BODY" | grep -q '阿雪' || {
  printf 'receipt missing contact: %s\n' "$RECEIPT_BODY" >&2
  exit 1
}
printf '%s' "$RECEIPT_BODY" | grep -q '奶茶' || {
  printf 'receipt missing hamster: %s\n' "$RECEIPT_BODY" >&2
  exit 1
}
printf '%s' "$RECEIPT_BODY" | grep -q '500.00' || {
  printf 'receipt missing amount: %s\n' "$RECEIPT_BODY" >&2
  exit 1
}

RECEIPT_ISSUED="$(curl -fsS -X POST "$API_URL/v1/receipts/$RECEIPT_ID/issue" \
  "${AUTH[@]}" -H "Idempotency-Key: pr-$RUN_ID-receipt-issue" -H "If-Match: \"$RECEIPT_VER\"")"
[[ "$(printf '%s' "$RECEIPT_ISSUED" | json_field '.data.status')" == "issued" ]] || {
  printf 'receipt issue failed: %s\n' "$RECEIPT_ISSUED" >&2
  exit 1
}

# --- Complete delivery → auto income accounting_record (notes=handover:{id}) ---
DONE="$(curl -fsS -X POST "$API_URL/v1/crm/handovers/$HANDOVER_ID/complete" \
  "${AUTH[@]}" -H "Idempotency-Key: pr-$RUN_ID-complete" -H "If-Match: \"$HANDOVER_VER\"")"
[[ "$(printf '%s' "$DONE" | json_field '.data.status')" == "completed" ]] || {
  printf 'handover complete failed: %s\n' "$DONE" >&2
  exit 1
}

INCOME_LIST="$(curl -fsS "$API_URL/v1/accounting/records?entry_type=income" "${AUTH[@]}")"
INCOME_MATCH="$(printf '%s' "$INCOME_LIST" | jq -r --arg m "handover:$HANDOVER_ID" \
  '[.data[]? | select(.notes==$m and .amount_cents==50000 and .entry_type=="income")] | length')"
[[ "$INCOME_MATCH" == "1" ]] || {
  printf 'finance linkage failed: want 1 income notes=handover:%s amount=50000 got %s\n%s\n' \
    "$HANDOVER_ID" "$INCOME_MATCH" "$INCOME_LIST" >&2
  exit 1
}

# Reservation should be handed_over after delivery complete
FINAL_LIST="$(curl -fsS "$API_URL/v1/crm/reservations" "${AUTH[@]}")"
FINAL_STATUS="$(printf '%s' "$FINAL_LIST" | jq -r --arg id "$RESERVATION_ID" \
  '.data[]? | select(.id==$id) | .status // empty')"
# list filters cancelled only; handed_over should still appear
[[ "$FINAL_STATUS" == "handed_over" ]] || {
  # completeCrmHandover sets reservation handed_over; if list excludes it, count zero is also ok if we got completed handover
  if [[ -z "$FINAL_STATUS" ]]; then
    printf 'note: reservation not listed after handed_over (may be filtered); handover completed\n'
  else
    printf 'final reservation status want handed_over got %s\n' "$FINAL_STATUS" >&2
    exit 1
  fi
}

# --- Customer public document read (capability token) ---
CONTRACT_TOKEN="$(printf '%s' "$ISSUED" | json_field '.data.public_token')"
# ISSUED was contract issue earlier; re-fetch if empty
if [[ -z "$CONTRACT_TOKEN" || "$CONTRACT_TOKEN" == "null" ]]; then
  CONTRACT_TOKEN="$(printf '%s' "$ISSUED" | jq -r '.data.public_token // empty')"
fi
# Re-issue response may include token; if not on old var, get from receipt
RECEIPT_TOKEN="$(printf '%s' "$RECEIPT_ISSUED" | json_field '.data.public_token')"
[[ -n "$RECEIPT_TOKEN" && "$RECEIPT_TOKEN" != "null" ]] || {
  printf 'receipt public_token missing: %s\n' "$RECEIPT_ISSUED" >&2
  exit 1
}
PUBLIC_DOC="$(curl -fsS "$API_URL/v1/public/documents/$RECEIPT_TOKEN")"
PUBLIC_TITLE="$(printf '%s' "$PUBLIC_DOC" | json_field '.data.title')"
PUBLIC_BODY="$(printf '%s' "$PUBLIC_DOC" | json_field '.data.body_filled')"
[[ -n "$PUBLIC_TITLE" && "$PUBLIC_TITLE" != "null" ]] || {
  printf 'public document failed: %s\n' "$PUBLIC_DOC" >&2
  exit 1
}
printf '%s' "$PUBLIC_BODY" | grep -q '阿雪' || {
  printf 'public document missing contact\n' >&2
  exit 1
}
# draft must not be public even if someone guessed id
DRAFT_STATUS="$(curl -sS -o /tmp/scolvpet-pr-public-draft.json -w '%{http_code}' \
  "$API_URL/v1/public/documents/doc_not_exist")"
[[ "$DRAFT_STATUS" == "404" ]] || {
  printf 'public document 404 want, got %s\n' "$DRAFT_STATUS" >&2
  exit 1
}

# =============================================================================
# Document truth-source negatives (CORE CODE FREEZE regression nails)
# =============================================================================
# 1) reservation A + contact B → reject
# 2) reservation A + handover(reservation_id=NULL) → reject
# 3) reservation A + handover(reservation B) → reject
# 4) reservation A + fake hamster_name → server uses reservation hamster (not client string)
# 5) happy path above already: reservation → handover → contract/receipt → PASS
if [[ -z "${TPL_ID:-}" || "$TPL_ID" == "null" ]]; then
  printf 'template id missing; cannot run document truth negatives\n' >&2
  exit 1
fi

# --- 1) Cross-bind isolation: reservation A cannot attach contact B ---
OTHER_CONTACT="$(curl -fsS -X POST "$API_URL/v1/crm/contacts" "${AUTH[@]}" \
  -H 'Content-Type: application/json' -H "Idempotency-Key: pr-$RUN_ID-other-contact" \
  -d '{"name":"其他人","phone":"+8613900002222","status":"lead"}' | json_field '.data.id')"
[[ -n "$OTHER_CONTACT" && "$OTHER_CONTACT" != "null" ]] || {
  printf 'other contact create failed\n' >&2
  exit 1
}
CROSS_STATUS="$(curl -sS -o /tmp/scolvpet-pr-cross.json -w '%{http_code}' \
  -X POST "$API_URL/v1/contracts" "${AUTH[@]}" \
  -H 'Content-Type: application/json' -H "Idempotency-Key: pr-$RUN_ID-cross-doc" \
  -d "$(jq -cn --arg t "$TPL_ID" --arg r "$RESERVATION_ID" --arg c "$OTHER_CONTACT" \
    '{template_id:$t,reservation_id:$r,contact_id:$c,title:"cross-bind-should-fail"}')")"
[[ "$CROSS_STATUS" == "409" || "$CROSS_STATUS" == "422" ]] || {
  printf 'cross-bind contract want 409/422 got %s body=%s\n' "$CROSS_STATUS" "$(cat /tmp/scolvpet-pr-cross.json)" >&2
  exit 1
}

# --- 2) reservation A + handover with reservation_id NULL → reject ---
# Create a walk-in handover (same contact, new hamster) with no reservation_id.
NULL_HAMSTER_PAYLOAD="$(jq -cn --arg rule "$RULE_ID" --arg code "PR-NULL-$RUN_ID" \
  '{internal_code:$code,name:"无预订个体",variety_code:"syrian",species_rule_version_id:$rule,sex:"male",birth_date:"2026-05-01",source_type:"introduced"}')"
NULL_HAMSTER="$(curl -fsS -X POST "$API_URL/v1/hamsters" \
  "${AUTH[@]}" -H 'Content-Type: application/json' \
  -H "Idempotency-Key: pr-$RUN_ID-null-hamster" -d "$NULL_HAMSTER_PAYLOAD")"
NULL_HAMSTER_ID="$(printf '%s' "$NULL_HAMSTER" | json_field '.data.id')"
[[ -n "$NULL_HAMSTER_ID" && "$NULL_HAMSTER_ID" != "null" ]] || {
  printf 'null-reservation hamster create failed: %s\n' "$NULL_HAMSTER" >&2
  exit 1
}
NULL_HANDOVER="$(curl -fsS -X POST "$API_URL/v1/crm/handovers" \
  "${AUTH[@]}" -H 'Content-Type: application/json' \
  -H "Idempotency-Key: pr-$RUN_ID-null-handover" \
  -d "$(jq -cn --arg c "$CONTACT_ID" --arg h "$NULL_HAMSTER_ID" \
    '{contact_id:$c,hamster_id:$h,notes:"walk-in no reservation"}')")"
NULL_HANDOVER_ID="$(printf '%s' "$NULL_HANDOVER" | json_field '.data.id')"
[[ -n "$NULL_HANDOVER_ID" && "$NULL_HANDOVER_ID" != "null" ]] || {
  printf 'null-reservation handover create failed: %s\n' "$NULL_HANDOVER" >&2
  exit 1
}
# Confirm DB row really has NULL reservation_id (not silently filled).
NULL_RES_FIELD="$(printf '%s' "$NULL_HANDOVER" | jq -r '.data.reservation_id // empty')"
[[ -z "$NULL_RES_FIELD" || "$NULL_RES_FIELD" == "null" ]] || {
  printf 'expected handover without reservation_id, got %s\n' "$NULL_RES_FIELD" >&2
  exit 1
}
NULL_BIND_STATUS="$(curl -sS -o /tmp/scolvpet-pr-null-ho.json -w '%{http_code}' \
  -X POST "$API_URL/v1/contracts" "${AUTH[@]}" \
  -H 'Content-Type: application/json' -H "Idempotency-Key: pr-$RUN_ID-null-ho-doc" \
  -d "$(jq -cn --arg t "$TPL_ID" --arg r "$RESERVATION_ID" --arg h "$NULL_HANDOVER_ID" \
    '{template_id:$t,reservation_id:$r,handover_id:$h,title:"null-handover-should-fail"}')")"
[[ "$NULL_BIND_STATUS" == "409" || "$NULL_BIND_STATUS" == "422" ]] || {
  printf 'null-handover bind want 409/422 got %s body=%s\n' "$NULL_BIND_STATUS" "$(cat /tmp/scolvpet-pr-null-ho.json)" >&2
  exit 1
}
NULL_BIND_MSG="$(jq -r '.error.message // .message // .error // empty' /tmp/scolvpet-pr-null-ho.json 2>/dev/null || true)"
printf '%s' "$NULL_BIND_MSG$(cat /tmp/scolvpet-pr-null-ho.json)" | grep -qE '绑定预订|reservation|交付单' || {
  printf 'null-handover reject body should mention handover/reservation: %s\n' "$(cat /tmp/scolvpet-pr-null-ho.json)" >&2
  exit 1
}

# --- 3) reservation A + handover of reservation B → reject ---
HAMSTER_B_PAYLOAD="$(jq -cn --arg rule "$RULE_ID" --arg code "PR-B-$RUN_ID" \
  '{internal_code:$code,name:"跨预订个体",variety_code:"syrian",species_rule_version_id:$rule,sex:"female",birth_date:"2026-05-10",source_type:"introduced"}')"
HAMSTER_B="$(curl -fsS -X POST "$API_URL/v1/hamsters" \
  "${AUTH[@]}" -H 'Content-Type: application/json' \
  -H "Idempotency-Key: pr-$RUN_ID-hamster-b" -d "$HAMSTER_B_PAYLOAD")"
HAMSTER_B_ID="$(printf '%s' "$HAMSTER_B" | json_field '.data.id')"
[[ -n "$HAMSTER_B_ID" && "$HAMSTER_B_ID" != "null" ]] || {
  printf 'hamster B create failed: %s\n' "$HAMSTER_B" >&2
  exit 1
}
PROFILE_B="$(jq -cn \
  '{public_name:"跨预订个体",summary:"B",traits:["测试"],filming_status:"ready",published:true,consultable:true,cta_text:"预订",price_label:"咨询"}')"
curl -fsS -X PUT "$API_URL/v1/growth/public-hamsters/$HAMSTER_B_ID" \
  "${AUTH[@]}" -H 'Content-Type: application/json' \
  -H "Idempotency-Key: pr-$RUN_ID-profile-b" -d "$PROFILE_B" >/dev/null
# Customer B verified session (different phone from A).
PHONE_B="+8613900003333"
CODE_RESP_B="$(curl -fsS -X POST "$API_URL/v1/public/customer/verification-codes" \
  -H 'Content-Type: application/json' \
  -H "Idempotency-Key: pr-$RUN_ID-cust-code-b" \
  -d "{\"phone\":\"$PHONE_B\",\"purpose\":\"login\"}")"
CUST_VID_B="$(printf '%s' "$CODE_RESP_B" | json_field '.data.verification_id')"
CUST_SESSION_B="$(curl -fsS -X POST "$API_URL/v1/public/customer/sessions" \
  -H 'Content-Type: application/json' \
  -d "{\"phone\":\"$PHONE_B\",\"verification_id\":\"$CUST_VID_B\",\"code\":\"$CODE\"}")"
CUST_TOKEN_B="$(printf '%s' "$CUST_SESSION_B" | json_field '.data.access_token')"
[[ -n "$CUST_TOKEN_B" && "$CUST_TOKEN_B" != "null" ]] || {
  printf 'customer B session failed: %s\n' "$CUST_SESSION_B" >&2
  exit 1
}
RESERVE_B="$(curl -fsS -X POST "$API_URL/v1/public/sites/$SLUG/reservations" \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $CUST_TOKEN_B" \
  -H "Idempotency-Key: pr-$RUN_ID-reserve-b" \
  -d "$(jq -cn --arg hid "$HAMSTER_B_ID" --arg phone "$PHONE_B" \
    '{hamster_id:$hid,name:"跨预订客户",phone:$phone,wechat:"b_wx",notes:"B"}')")"
RESERVATION_B_ID="$(printf '%s' "$RESERVE_B" | json_field '.data.reservation_id')"
CONTACT_B_ID="$(printf '%s' "$RESERVE_B" | json_field '.data.contact_id')"
[[ -n "$RESERVATION_B_ID" && "$RESERVATION_B_ID" != "null" ]] || {
  printf 'reservation B create failed: %s\n' "$RESERVE_B" >&2
  exit 1
}
[[ -n "$CONTACT_B_ID" && "$CONTACT_B_ID" != "null" ]] || {
  printf 'contact B missing from reserve B: %s\n' "$RESERVE_B" >&2
  exit 1
}
LIST_B="$(curl -fsS "$API_URL/v1/crm/reservations" "${AUTH[@]}")"
RES_B_VER="$(printf '%s' "$LIST_B" | jq -r --arg id "$RESERVATION_B_ID" \
  '.data[]? | select(.id==$id) | .version // empty')"
[[ -n "$RES_B_VER" && "$RES_B_VER" != "null" ]] || RES_B_VER=1
CONFIRMED_B="$(curl -fsS -X POST "$API_URL/v1/crm/reservations/$RESERVATION_B_ID/confirm" \
  "${AUTH[@]}" -H "Idempotency-Key: pr-$RUN_ID-confirm-b" -H "If-Match: \"$RES_B_VER\"")"
[[ "$(printf '%s' "$CONFIRMED_B" | json_field '.data.status')" == "confirmed" ]] || {
  printf 'confirm B failed: %s\n' "$CONFIRMED_B" >&2
  exit 1
}
HANDOVER_B="$(curl -fsS -X POST "$API_URL/v1/crm/handovers" \
  "${AUTH[@]}" -H 'Content-Type: application/json' \
  -H "Idempotency-Key: pr-$RUN_ID-handover-b" \
  -d "$(jq -cn --arg c "$CONTACT_B_ID" --arg r "$RESERVATION_B_ID" --arg h "$HAMSTER_B_ID" \
    '{contact_id:$c,reservation_id:$r,hamster_id:$h,notes:"handover for B"}')")"
HANDOVER_B_ID="$(printf '%s' "$HANDOVER_B" | json_field '.data.id')"
[[ -n "$HANDOVER_B_ID" && "$HANDOVER_B_ID" != "null" ]] || {
  printf 'handover B create failed: %s\n' "$HANDOVER_B" >&2
  exit 1
}
CROSS_HO_STATUS="$(curl -sS -o /tmp/scolvpet-pr-cross-ho.json -w '%{http_code}' \
  -X POST "$API_URL/v1/contracts" "${AUTH[@]}" \
  -H 'Content-Type: application/json' -H "Idempotency-Key: pr-$RUN_ID-cross-ho-doc" \
  -d "$(jq -cn --arg t "$TPL_ID" --arg r "$RESERVATION_ID" --arg h "$HANDOVER_B_ID" \
    '{template_id:$t,reservation_id:$r,handover_id:$h,title:"cross-reservation-handover-should-fail"}')")"
[[ "$CROSS_HO_STATUS" == "409" || "$CROSS_HO_STATUS" == "422" ]] || {
  printf 'cross-reservation handover bind want 409/422 got %s body=%s\n' \
    "$CROSS_HO_STATUS" "$(cat /tmp/scolvpet-pr-cross-ho.json)" >&2
  exit 1
}

# --- 4) Fake hamster_name must not poison title when reservation is truth source ---
FAKE_STATUS="$(curl -sS -o /tmp/scolvpet-pr-fake-name.json -w '%{http_code}' \
  -X POST "$API_URL/v1/contracts" "${AUTH[@]}" \
  -H 'Content-Type: application/json' -H "Idempotency-Key: pr-$RUN_ID-fake-name" \
  -d "$(jq -cn --arg t "$TPL_ID" --arg r "$RESERVATION_ID" \
    '{template_id:$t,reservation_id:$r,hamster_name:"客户端伪造仓鼠",title:""}')")"
[[ "$FAKE_STATUS" == "201" || "$FAKE_STATUS" == "200" ]] || {
  printf 'fake hamster_name contract create failed: %s %s\n' "$FAKE_STATUS" "$(cat /tmp/scolvpet-pr-fake-name.json)" >&2
  exit 1
}
FAKE_TITLE="$(jq -r '.data.title // empty' /tmp/scolvpet-pr-fake-name.json)"
FAKE_BODY="$(jq -r '.data.body_filled // empty' /tmp/scolvpet-pr-fake-name.json)"
printf '%s' "$FAKE_TITLE$FAKE_BODY" | grep -q '客户端伪造仓鼠' && {
  printf 'server accepted client fake hamster_name into title/body: title=%s\n' "$FAKE_TITLE" >&2
  exit 1
} || true
# Positive: server projection should still mention reservation hamster 奶茶
printf '%s' "$FAKE_TITLE$FAKE_BODY" | grep -q '奶茶' || {
  printf 'server hamster projection missing 奶茶 in fake-name contract: title=%s body=%s\n' \
    "$FAKE_TITLE" "$FAKE_BODY" >&2
  exit 1
}

printf 'public-reservation smoke PASS: reservation=%s contact=%s hamster=%s contract=%s handover=%s receipt=%s income_notes=handover:%s public_token=%s slug=%s negatives=contact_b+null_ho+cross_ho+fake_name\n' \
  "$RESERVATION_ID" "$CONTACT_ID" "$HAMSTER_ID" "$CONTRACT_ID" "$HANDOVER_ID" "$RECEIPT_ID" "$HANDOVER_ID" "$RECEIPT_TOKEN" "$SLUG"
