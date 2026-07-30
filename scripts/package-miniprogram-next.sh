#!/usr/bin/env bash
# Create a source-only handoff archive for apps/miniprogram-next.
# Generated output and developer-local configuration must never leave the
# workspace in a source review/reproduction bundle (docs/33 M0-1).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_PATH="${1:-}"
SOURCE_DIR="${2:-$ROOT_DIR/apps/miniprogram-next}"

if [ -z "$OUTPUT_PATH" ]; then
  printf 'usage: %s OUTPUT.zip [SOURCE_DIR]\n' "$0" >&2
  exit 2
fi
if [ ! -d "$SOURCE_DIR" ]; then
  printf 'package gate: source directory not found: %s\n' "$SOURCE_DIR" >&2
  exit 1
fi

SOURCE_DIR="$(cd "$SOURCE_DIR" && pwd)"
OUTPUT_PATH="$(python3 -c 'import os,sys; print(os.path.abspath(sys.argv[1]))' "$OUTPUT_PATH")"
case "$OUTPUT_PATH" in
  "$SOURCE_DIR"/*) printf 'package gate: output archive must be outside source directory\n' >&2; exit 1 ;;
esac

mkdir -p "$(dirname "$OUTPUT_PATH")"
rm -f "$OUTPUT_PATH"
(
  cd "$SOURCE_DIR"
  zip -q -r "$OUTPUT_PATH" . \
    -x 'dist/*' \
       'project.private.config.json' \
       'node_modules/*' \
       '.git/*' \
       '.DS_Store' \
       '*.log'
)
printf 'created source-only mini-program package: %s\n' "$OUTPUT_PATH"
