#!/usr/bin/env bash
# P1-2 production readiness smoke：
#   HTTP 断言（给定 BASE_URL 时）：/healthz 200 且 status=ok；/readyz 200 且 status=ready
#     （DB 不通时 readyz 为 503 not_ready）。readyz 报告 environment=production 时，
#     进一步断言 checks：sms_provider=http、sms_mock_code_set=false、wechat_provider=http
#     （旧二进制无 environment 字段则跳过，保持向后兼容）。
#   静态断言（给定 ENV_FILE 时，不起服务）：production env 文件必须
#     APP_ENV=production、SMS_MOCK_CODE 为空、SMS_PROVIDER=http、WECHAT_PROVIDER=http
#     （对应 api/cmd/server/config.go validateProductionConfig 的 fail-closed 校验）。
# 用法（位置参数或环境变量，至少给一个）：
#   scripts/production-readiness-smoke.sh https://p.scolv.com:8443 /opt/scolvpet/.env.production
#   ENV_FILE=/opt/scolvpet/.env.production scripts/production-readiness-smoke.sh   # 仅静态断言
set -euo pipefail

BASE_URL="${1:-${BASE_URL:-}}"
ENV_FILE="${2:-${ENV_FILE:-}}"

if [[ -z "$BASE_URL" && -z "$ENV_FILE" ]]; then
  printf 'usage: %s [BASE_URL] [ENV_FILE]（至少提供一个）\n' "$0" >&2
  exit 2
fi

fail() { printf '%s\n' "$*" >&2; exit 1; }

# 取 env 文件里某 key 的最终值（最后一次赋值生效，忽略注释行与缺失 key）。
env_get() {
  grep -E "^$1=" "$ENV_FILE" | tail -n 1 | cut -d= -f2- || true
}

# --- HTTP 断言 ---
if [[ -n "$BASE_URL" ]]; then
  BASE_URL="${BASE_URL%/}"
  HEALTH_BODY="$(mktemp /tmp/scolvpet-prod-smoke-health.XXXXXX)"
  READY_BODY="$(mktemp /tmp/scolvpet-prod-smoke-ready.XXXXXX)"
  trap 'rm -f "$HEALTH_BODY" "$READY_BODY"' EXIT

  HEALTH_STATUS="$(curl -sS -o "$HEALTH_BODY" -w '%{http_code}' "$BASE_URL/healthz")"
  [[ "$HEALTH_STATUS" == "200" ]] || fail "/healthz want 200 got $HEALTH_STATUS body=$(cat "$HEALTH_BODY")"
  [[ "$(jq -r '.status // empty' "$HEALTH_BODY")" == "ok" ]] || fail "/healthz status want ok body=$(cat "$HEALTH_BODY")"
  [[ "$(jq -r '.service // empty' "$HEALTH_BODY")" == "scolvpet-api" ]] || fail "/healthz service want scolvpet-api body=$(cat "$HEALTH_BODY")"

  READY_STATUS="$(curl -sS -o "$READY_BODY" -w '%{http_code}' "$BASE_URL/readyz")"
  [[ "$READY_STATUS" == "200" ]] || fail "/readyz want 200 got $READY_STATUS body=$(cat "$READY_BODY")"
  [[ "$(jq -r '.status // empty' "$READY_BODY")" == "ready" ]] || fail "/readyz status want ready body=$(cat "$READY_BODY")"

  READY_ENV="$(jq -r '.environment // empty' "$READY_BODY")"
  if [[ "$READY_ENV" == "production" ]]; then
    [[ "$(jq -r '.checks.sms_provider // empty' "$READY_BODY")" == "http" ]] \
      || fail "/readyz checks.sms_provider want http body=$(cat "$READY_BODY")"
    [[ "$(jq -r '.checks.sms_mock_code_set' "$READY_BODY")" == "false" ]] \
      || fail "/readyz checks.sms_mock_code_set want false body=$(cat "$READY_BODY")"
    [[ "$(jq -r '.checks.wechat_provider // empty' "$READY_BODY")" == "http" ]] \
      || fail "/readyz checks.wechat_provider want http body=$(cat "$READY_BODY")"
  fi
fi

# --- 生产配置静态断言 ---
if [[ -n "$ENV_FILE" ]]; then
  [[ -f "$ENV_FILE" ]] || fail "env file not found: $ENV_FILE"
  APP_ENV_VALUE="$(env_get APP_ENV)"
  [[ "$APP_ENV_VALUE" == "production" ]] || fail "APP_ENV want production got '$APP_ENV_VALUE' ($ENV_FILE)"
  MOCK_VALUE="$(env_get SMS_MOCK_CODE)"
  [[ -z "$MOCK_VALUE" ]] || fail "SMS_MOCK_CODE must be empty in production, got '$MOCK_VALUE' ($ENV_FILE)"
  PROVIDER_VALUE="$(env_get SMS_PROVIDER)"
  [[ "$PROVIDER_VALUE" == "http" ]] || fail "SMS_PROVIDER want http got '$PROVIDER_VALUE' ($ENV_FILE)"
  WECHAT_PROVIDER_VALUE="$(env_get WECHAT_PROVIDER)"
  [[ "$WECHAT_PROVIDER_VALUE" == "http" ]] || fail "WECHAT_PROVIDER want http got '$WECHAT_PROVIDER_VALUE' ($ENV_FILE)"
fi

printf 'production-readiness smoke PASS: base_url=%s env_file=%s\n' \
  "${BASE_URL:-<skipped>}" "${ENV_FILE:-<skipped>}"
