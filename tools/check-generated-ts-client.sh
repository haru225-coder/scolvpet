#!/usr/bin/env bash
# TS client drift 检查(docs/33 M0-4),机制对齐 tools/check-generated-dart-client.sh。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OPENAPI_GENERATOR_VERSION="${OPENAPI_GENERATOR_VERSION:-7.23.0}"
TEMP="$(mktemp -d /tmp/scolvpet-ts-client.XXXXXX)"
TEMP="$(cd "$TEMP" && pwd)"
trap 'rm -rf "$TEMP"' EXIT

OUTPUT_DIR="$TEMP/scolvpet-api" OPENAPI_GENERATOR_VERSION="$OPENAPI_GENERATOR_VERSION" "$ROOT/tools/generate-ts-client.sh" >/dev/null

diff -ru \
  --exclude='.openapi-generator' \
  "$ROOT/generated/ts/scolvpet-api" "$TEMP/scolvpet-api"
COUNT="$(find "$ROOT/generated/ts/scolvpet-api" -type f -not -path '*/.openapi-generator/*' | wc -l | tr -d ' ')"
[[ "$COUNT" -gt 0 ]] || { printf 'generated ts client is empty\n' >&2; exit 1; }
printf 'generated ts client drift check passed: %s files\n' "$COUNT"
