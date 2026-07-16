#!/usr/bin/env bash
# I6 object store smoke for local + optional S3/MinIO live backends.
#
# Local path (always runs):
#   go test ./internal/objectstore  unit suite
#
# Live path (optional): set all of
#   OBJECT_STORE_ENDPOINT
#   OBJECT_STORE_BUCKET
#   OBJECT_STORE_REGION
#   OBJECT_STORE_ACCESS_KEY
#   OBJECT_STORE_SECRET_KEY
# Optional:
#   OBJECT_STORE_PATH_STYLE   true|false
#   OBJECT_STORE_SMOKE_PREFIX object key prefix
#
# Credentials are never written to the repository. Logs only print masked keys.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/api"

mask_secret() {
  local value="${1:-}"
  if [[ -z "$value" ]]; then
    printf '%s' '(empty)'
    return
  fi
  if [[ ${#value} -le 4 ]]; then
    printf '%s' '****'
    return
  fi
  printf '%s***%s' "${value:0:2}" "${value: -2}"
}

log() {
  printf '[i6-objectstore-smoke] %s\n' "$*"
}

log "running local ObjectStore unit suite"
go test ./internal/objectstore/ -count=1 -run 'TestLocalFS|TestS3ObjectStorePutGetDelete|TestS3ObjectStoreRejects|TestS3ObjectStoreVirtualHosted|TestNewS3'
log "local objectstore tests passed"

ENDPOINT="${OBJECT_STORE_ENDPOINT:-}"
BUCKET="${OBJECT_STORE_BUCKET:-}"
REGION="${OBJECT_STORE_REGION:-}"
ACCESS_KEY="${OBJECT_STORE_ACCESS_KEY:-}"
SECRET_KEY="${OBJECT_STORE_SECRET_KEY:-}"
PATH_STYLE="${OBJECT_STORE_PATH_STYLE:-}"

missing=()
[[ -z "$ENDPOINT" ]] && missing+=("OBJECT_STORE_ENDPOINT")
[[ -z "$BUCKET" ]] && missing+=("OBJECT_STORE_BUCKET")
[[ -z "$REGION" ]] && missing+=("OBJECT_STORE_REGION")
[[ -z "$ACCESS_KEY" ]] && missing+=("OBJECT_STORE_ACCESS_KEY")
[[ -z "$SECRET_KEY" ]] && missing+=("OBJECT_STORE_SECRET_KEY")

if (( ${#missing[@]} > 0 )); then
  log "待确认: S3/MinIO live smoke skipped (missing ${missing[*]})"
  log "local verification path is executable via this script without live credentials"
  exit 0
fi

if [[ -z "$PATH_STYLE" ]]; then
  if [[ "$ENDPOINT" == *"localhost"* || "$ENDPOINT" == *"127.0.0.1"* || "$ENDPOINT" == *"minio"* ]]; then
    PATH_STYLE=true
  else
    PATH_STYLE=false
  fi
  export OBJECT_STORE_PATH_STYLE="$PATH_STYLE"
fi

log "live smoke endpoint=$ENDPOINT bucket=$BUCKET region=$REGION path_style=$PATH_STYLE"
log "access_key=$(mask_secret "$ACCESS_KEY") secret_key=$(mask_secret "$SECRET_KEY")"

go test ./internal/objectstore/ -count=1 -run TestS3ObjectStoreLiveSmoke -v
log "S3/MinIO live smoke completed"
