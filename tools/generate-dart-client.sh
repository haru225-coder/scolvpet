#!/usr/bin/env bash
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
GENERATOR_JAR="$ROOT/.cache/openapi-generator/$VERSION.jar"
# 与 generate-ts-client 一致：无 jar 时下载固定版本，避免 CI drift 与本机不一致。
if [[ ! -f "$GENERATOR_JAR" ]]; then
  mkdir -p "$(dirname "$GENERATOR_JAR")"
  printf 'downloading openapi-generator-cli %s ...\n' "$VERSION" >&2
  curl -fsSL \
    "https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/${VERSION}/openapi-generator-cli-${VERSION}.jar" \
    -o "$GENERATOR_JAR"
fi
GENERATOR=(java -jar "$GENERATOR_JAR")
"$TIMEOUT_SCRIPT" "$COMMAND_TIMEOUT_SECONDS" "${GENERATOR[@]}" generate \
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
  if [[ "${DART_PUB_OFFLINE:-0}" == "1" ]]; then
    "$TIMEOUT_SCRIPT" "$COMMAND_TIMEOUT_SECONDS" dart pub get --offline
  else
    "$TIMEOUT_SCRIPT" "$COMMAND_TIMEOUT_SECONDS" dart pub get
  fi
  "$TIMEOUT_SCRIPT" "$COMMAND_TIMEOUT_SECONDS" dart run build_runner build --delete-conflicting-outputs
)
