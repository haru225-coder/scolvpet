#!/usr/bin/env bash
# TS 契约客户端生成(docs/33 M0-4),机制对齐 tools/generate-dart-client.sh:
# 固定 OpenAPI Generator 版本,typescript-fetch,输出 generated/ts/scolvpet-api。
# Taro 侧统一经 apps/miniprogram-next/src/api adapter 消费,禁止手写 fetch 封装。
#
# 默认：按 apps/miniprogram-next 实际调用面收窄 OpenAPI 再生成（减 DefaultApi 体积）。
# 全量（调试 / 对照）: OPENAPI_TS_FULL=1 tools/generate-ts-client.sh
# 权威全量契约仍是 specs/api/openapi.yaml；Dart 客户端不受影响。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${OPENAPI_GENERATOR_VERSION:-7.23.0}"
OUTPUT_DIR="${OUTPUT_DIR:-generated/ts/scolvpet-api}"
COMMAND_TIMEOUT_SECONDS="${OPENAPI_CLIENT_COMMAND_TIMEOUT_SECONDS:-300}"
TIMEOUT_SCRIPT="$ROOT/scripts/with-timeout.sh"
FULL_SPEC="$ROOT/specs/api/openapi.yaml"
FILTERED_SPEC="$ROOT/.cache/openapi-ts-client.filtered.json"

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

mkdir -p "$(dirname "$FILTERED_SPEC")"
node tools/filter-openapi-for-ts-client.mjs "$FULL_SPEC" "$FILTERED_SPEC"
INPUT_SPEC="$FILTERED_SPEC"

# openapi-generator 不会删除已不在契约中的旧文件；先清空输出再生成，避免残留 GrowthApi 等。
if [[ "$OUTPUT_DIR" == /* ]]; then
  CLEAN_DIR="$OUTPUT_DIR"
else
  CLEAN_DIR="$ROOT/$OUTPUT_DIR"
fi
rm -rf "$CLEAN_DIR"
mkdir -p "$CLEAN_DIR"

GENERATOR_JAR="$ROOT/.cache/openapi-generator/$VERSION.jar"
# CI 无本机 .cache jar 时也必须固定 7.23.0，禁止 npx 默认拉「最新」造成 drift 假红。
if [[ ! -f "$GENERATOR_JAR" ]]; then
  mkdir -p "$(dirname "$GENERATOR_JAR")"
  printf 'downloading openapi-generator-cli %s ...\n' "$VERSION" >&2
  curl -fsSL \
    "https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/${VERSION}/openapi-generator-cli-${VERSION}.jar" \
    -o "$GENERATOR_JAR"
fi
GENERATOR=(java -jar "$GENERATOR_JAR")
"$TIMEOUT_SCRIPT" "$COMMAND_TIMEOUT_SECONDS" "${GENERATOR[@]}" generate \
  -i "$INPUT_SPEC" \
  -g typescript-fetch \
  -o "$OUTPUT_DIR" \
  --additional-properties=supportsES6=true,npmName=@scolvpet/scolvpet-api,npmVersion=1.0.0 \
  --global-property=models,apis,supportingFiles \
  --skip-validate-spec

if [[ "$OUTPUT_DIR" == /* ]]; then
  GENERATED_TS_ROOT="$OUTPUT_DIR"
else
  GENERATED_TS_ROOT="$ROOT/$OUTPUT_DIR"
fi
export GENERATED_TS_ROOT
node tools/prepare-generated-ts.mjs
