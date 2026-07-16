#!/bin/zsh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${OPENAPI_GENERATOR_VERSION:-7.23.0}"
OUTPUT_DIR="${OUTPUT_DIR:-generated/dart/scolvpet_api}"
COMMAND_TIMEOUT_SECONDS="${OPENAPI_CLIENT_COMMAND_TIMEOUT_SECONDS:-300}"
TIMEOUT_SCRIPT="$ROOT/scripts/with-timeout.sh"

if [[ -z "${JAVA_HOME:-}" ]] && command -v /usr/libexec/java_home >/dev/null 2>&1; then
  JAVA_HOME="$(/usr/libexec/java_home -v 17 2>/dev/null || true)"
  export JAVA_HOME
fi
if [[ -z "${JAVA_HOME:-}" ]] && [[ -d "/opt/homebrew/opt/openjdk@17" ]]; then
  export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
  export PATH="$JAVA_HOME/bin:$PATH"
fi

if ! command -v java >/dev/null 2>&1; then
  printf 'Java 17+ is required for OpenAPI Generator %s\n' "$VERSION" >&2
  exit 2
fi

cd "$ROOT"
rm -rf "$OUTPUT_DIR/test"
"$TIMEOUT_SCRIPT" "$COMMAND_TIMEOUT_SECONDS" npx --yes @openapitools/openapi-generator-cli@2.25.0 generate \
  -i specs/api/openapi.yaml \
  -g dart-dio \
  -o "$OUTPUT_DIR" \
  --additional-properties=pubName=scolvpet_api,pubVersion=1.0.0,useEnumExtension=true,serializationLibrary=json_serializable \
  --global-property=models,apis,supportingFiles

if [[ "$OUTPUT_DIR" == /* ]]; then
  GENERATED_DART_ROOT="$OUTPUT_DIR"
else
  GENERATED_DART_ROOT="$ROOT/$OUTPUT_DIR"
fi
export GENERATED_DART_ROOT
node tools/prepare-generated-dart.mjs
rm -rf "$OUTPUT_DIR/test"
(
  cd "$OUTPUT_DIR"
  pub_args=()
  if [[ "${DART_PUB_OFFLINE:-0}" == "1" ]]; then
    pub_args+=(--offline)
  fi
  "$TIMEOUT_SCRIPT" "$COMMAND_TIMEOUT_SECONDS" dart pub get "${pub_args[@]}"
  "$TIMEOUT_SCRIPT" "$COMMAND_TIMEOUT_SECONDS" dart run build_runner build --delete-conflicting-outputs
)
