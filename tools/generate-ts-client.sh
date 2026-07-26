#!/usr/bin/env bash
# TS 契约客户端生成(docs/33 M0-4),机制对齐 tools/generate-dart-client.sh:
# 固定 OpenAPI Generator 版本,typescript-fetch,输出 generated/ts/scolvpet-api。
# Taro 侧统一经 apps/miniprogram-next/src/api adapter 消费,禁止手写 fetch 封装。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${OPENAPI_GENERATOR_VERSION:-7.23.0}"
OUTPUT_DIR="${OUTPUT_DIR:-generated/ts/scolvpet-api}"
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
GENERATOR_JAR="$ROOT/.cache/openapi-generator/$VERSION.jar"
if [[ -f "$GENERATOR_JAR" ]]; then
  GENERATOR=(java -jar "$GENERATOR_JAR")
else
  GENERATOR=(npx --yes @openapitools/openapi-generator-cli@2.25.0)
fi
"$TIMEOUT_SCRIPT" "$COMMAND_TIMEOUT_SECONDS" "${GENERATOR[@]}" generate \
  -i specs/api/openapi.yaml \
  -g typescript-fetch \
  -o "$OUTPUT_DIR" \
  --additional-properties=supportsES6=true,npmName=@scolvpet/scolvpet-api,npmVersion=1.0.0 \
  --global-property=models,apis,supportingFiles

if [[ "$OUTPUT_DIR" == /* ]]; then
  GENERATED_TS_ROOT="$OUTPUT_DIR"
else
  GENERATED_TS_ROOT="$ROOT/$OUTPUT_DIR"
fi
export GENERATED_TS_ROOT
node tools/prepare-generated-ts.mjs
