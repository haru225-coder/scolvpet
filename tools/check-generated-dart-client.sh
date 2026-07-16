#!/bin/zsh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OPENAPI_GENERATOR_VERSION="${OPENAPI_GENERATOR_VERSION:-7.23.0}"
TEMP="$(mktemp -d /tmp/scolvpet-dart-client.XXXXXX)"
TEMP="$(cd "$TEMP" && pwd)"
trap 'rm -rf "$TEMP"' EXIT

OUTPUT_DIR="$TEMP/scolvpet_api" OPENAPI_GENERATOR_VERSION="$OPENAPI_GENERATOR_VERSION" "$ROOT/tools/generate-dart-client.sh" >/dev/null

diff -ru \
  --exclude='.dart_tool' \
  --exclude='.openapi-generator' \
  --exclude='pubspec.lock' \
  "$ROOT/generated/dart/scolvpet_api" "$TEMP/scolvpet_api"
COUNT="$(find "$ROOT/generated/dart/scolvpet_api" -type f -not -path '*/.openapi-generator/*' -not -path '*/.dart_tool/*' | wc -l | tr -d ' ')"
[[ "$COUNT" -gt 0 ]] || { printf 'generated client is empty\n' >&2; exit 1; }
printf 'generated dart client drift check passed: %s files\n' "$COUNT"
