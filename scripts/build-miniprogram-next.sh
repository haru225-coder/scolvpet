#!/usr/bin/env bash
# Build-time config injection for apps/miniprogram-next (docs/33 M0-1).
#
# Ported 1:1 from scripts/build-miniprogram.sh — same env contract, same
# fail-closed rules — with paths adapted to the Taro project layout:
# config lives at src/utils/config.js (copied verbatim into dist/ for the
# blended native pages), project.config.json sits at the project root.
# Tests point MP_TARGET_DIR at a scratch copy so the repo stays clean.
#
# Env:
#   MP_APP_ENV   development (default) | production
#   MP_API_BASE  API root URL (default: dev staging base)
#   MP_APPID     WeChat AppID (development defaults to the checked-in project config)
#   MP_TARGET_DIR  override target dir (tests only)
#
# Fail-closed (MP_APP_ENV=production only — dev builds pass through):
#   - MP_APPID empty, touristappid, or not wx + 16 lowercase hex chars
#   - MP_API_BASE hits p.scolv.com, carries an explicit port, or is not https://
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${MP_TARGET_DIR:-$ROOT_DIR/apps/miniprogram-next}"
CONFIG_JS="$TARGET_DIR/src/utils/config.js"
PROJECT_JSON="$TARGET_DIR/project.config.json"
CONFIG_BACKUP="$TARGET_DIR/.config.js.release-backup"
PROJECT_BACKUP="$TARGET_DIR/.project.config.json.release-backup"

# Development defaults — must stay byte-identical to the committed files.
DEV_APP_ENV='development'
DEV_API_BASE='https://p.scolv.com:8443'
DEV_APPID="$(node -e '
  const fs = require("fs");
  const project = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
  process.stdout.write(project.appid || "touristappid");
' "$ROOT_DIR/apps/miniprogram-next/project.config.json")"

fail() { printf 'release gate: %s\n' "$1" >&2; exit 1; }

set_appid() {
  # Regex-replace the appid value so the file formatting stays untouched.
  node -e '
    const fs = require("fs");
    const [file, appid] = process.argv.slice(1);
    const src = fs.readFileSync(file, "utf8");
    const out = src.replace(/("appid":\s*")[^"]*(")/, `$1${appid}$2`);
    if (out === src && !src.includes(`"appid": "${appid}"`)) {
      console.error("appid field not found in " + file);
      process.exit(1);
    }
    fs.writeFileSync(file, out);
  ' "$PROJECT_JSON" "$1"
}

set_url_check() {
  node -e '
    const fs = require("fs");
    const [file, value] = process.argv.slice(1);
    const src = fs.readFileSync(file, "utf8");
    const out = src.replace(/("urlCheck":\s*)(?:true|false)/, `$1${value}`);
    if (out === src && !src.includes(`"urlCheck": ${value}`)) {
      console.error("urlCheck field not found in " + file);
      process.exit(1);
    }
    fs.writeFileSync(file, out);
  ' "$PROJECT_JSON" "$1"
}

set_config_values() {
  node -e '
    const fs = require("fs");
    const [file, appEnv, apiBase, devPhone, devCode] = process.argv.slice(1);
    let src = fs.readFileSync(file, "utf8");
    const replaceConst = (name, value) => {
      const quote = String.fromCharCode(39);
      const pattern = new RegExp(`const ${name} = ${quote}[^${quote}]*${quote};`);
      if (!pattern.test(src)) {
        console.error(`${name} field not found in ${file}`);
        process.exit(1);
      }
      src = src.replace(pattern, `const ${name} = ${quote}${value}${quote};`);
    };
    replaceConst("APP_ENV", appEnv);
    replaceConst("API_BASE", apiBase);
    replaceConst("DEV_LOGIN_PHONE", devPhone);
    replaceConst("DEV_LOGIN_CODE", devCode);
    fs.writeFileSync(file, src);
  ' "$CONFIG_JS" "$1" "$2" "$3" "$4"
}

save_backups() {
  # Preserve both files byte-for-byte, including hardening logic and DevTools keys.
  if [ ! -f "$CONFIG_BACKUP" ]; then
    cp "$CONFIG_JS" "$CONFIG_BACKUP"
  fi
  if [ ! -f "$PROJECT_BACKUP" ]; then
    cp "$PROJECT_JSON" "$PROJECT_BACKUP"
  fi
}

restore_backups() {
  if [ -f "$CONFIG_BACKUP" ]; then
    cp "$CONFIG_BACKUP" "$CONFIG_JS"
    rm -f "$CONFIG_BACKUP"
  else
    set_config_values "$DEV_APP_ENV" "$DEV_API_BASE" '13800138000' '123456'
  fi
  if [ -f "$PROJECT_BACKUP" ]; then
    cp "$PROJECT_BACKUP" "$PROJECT_JSON"
    rm -f "$PROJECT_BACKUP"
  else
    set_appid "$DEV_APPID"
    set_url_check false
  fi
}

if [ "${1:-}" = "--restore" ]; then
  restore_backups
  printf 'restored development defaults in %s\n' "$TARGET_DIR"
  exit 0
fi

APP_ENV="${MP_APP_ENV:-$DEV_APP_ENV}"
API_BASE="${MP_API_BASE:-$DEV_API_BASE}"
APPID="${MP_APPID-$DEV_APPID}"

if [ "$APP_ENV" = "production" ]; then
  test -n "$APPID" || fail 'MP_APPID is required for production builds'
  [ "$APPID" != "touristappid" ] || fail 'MP_APPID must not be touristappid for production builds'
  case "$APPID" in
    wx*) ;;
    *) fail "MP_APPID must start with wx for production builds, got $APPID" ;;
  esac
  [ "${#APPID}" -eq 18 ] || fail "MP_APPID must be wx + 16 hex chars (18 total), got ${#APPID} chars: $APPID"
  case "${APPID#wx}" in
    *[!0-9a-f]*) fail "MP_APPID must be wx followed by 16 lowercase hex chars, got $APPID" ;;
  esac
  case "$API_BASE" in
    https://*) ;;
    *) fail "MP_API_BASE must start with https://, got $API_BASE" ;;
  esac
  case "$API_BASE" in
    *p.scolv.com*) fail "MP_API_BASE hits staging host p.scolv.com: $API_BASE" ;;
  esac
  HOST_PART="${API_BASE#https://}"; HOST_PART="${HOST_PART%%/*}"
  case "$HOST_PART" in
    *:*) fail "MP_API_BASE must not carry an explicit port (WeChat requires default 443): $API_BASE" ;;
  esac
fi

# Guard the JS string interpolation below against broken output.
case "$API_BASE$APPID" in
  *"'"*|*'\'*) fail 'MP_API_BASE / MP_APPID must not contain quotes or backslashes' ;;
esac

save_backups
if [ "$APP_ENV" = "production" ]; then
  set_config_values "$APP_ENV" "$API_BASE" '' ''
else
  set_config_values "$APP_ENV" "$API_BASE" '13800138000' '123456'
fi
set_appid "$APPID"
if [ "$APP_ENV" = "production" ]; then
  set_url_check true
else
  set_url_check false
fi
printf 'built miniprogram-next config: APP_ENV=%s API_BASE=%s appid=%s\n' "$APP_ENV" "$API_BASE" "$APPID"
