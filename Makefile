SHELL := /bin/bash

-include .env
# LLM 出站（Grok2API）；make 配方默认不 export 变量，这里显式导出给 api-run/smoke。
export AI_API_KEY AI_BASE_URL AI_MODEL XAI_API_KEY XAI_BASE_URL XAI_MODEL

OPENAPI_GENERATOR_VERSION := 7.23.0
DATABASE_URL ?= postgres://scolvpet:scolvpet@127.0.0.1:55432/scolvpet?sslmode=disable
FLUTTER_COMMAND_TIMEOUT_SECONDS ?= 900
FLUTTER_BUILD_TIMEOUT_SECONDS ?= 1800
GRADLE_NETWORK_TIMEOUT_MS ?= 60000
FLUTTER_GRADLE_OPTS = -Dhttp.connectionTimeout=$(GRADLE_NETWORK_TIMEOUT_MS) -Dhttp.socketTimeout=$(GRADLE_NETWORK_TIMEOUT_MS) -Dhttps.connectionTimeout=$(GRADLE_NETWORK_TIMEOUT_MS) -Dhttps.socketTimeout=$(GRADLE_NETWORK_TIMEOUT_MS)
TIMEOUT_SCRIPT := $(CURDIR)/scripts/with-timeout.sh

.PHONY: help api-test api-run db-verify db-seed generate-migrations migration-drift openapi-lint openapi-conformance client-drift web-test web-build web-lint miniprogram-test flutter-pub-get flutter-analyze flutter-test flutter-build-android release-miniprogram smoke reservation-smoke media-smoke objectstore-smoke outbox-test timeout-test ci

help:
	@printf '%s\n' '主入口:' '  make ci              运行可执行的 I1 检查' '  make db-verify       新建临时 PostgreSQL 并验证迁移复跑/种子/checksum' '  make api-test        API 单元测试' '  make generate-client 用固定 OpenAPI Generator 生成 dart-dio 客户端' '  make smoke            启动 API 并跑 I1 演示链' '  make reservation-smoke 经营闭环：公开预订→合同→交付→回执→客户只读' '  make flutter-test    Flutter 单元/Widget/契约模型测试'

api-test:
	cd api && go test ./...

api-run:
	cd api && go run ./cmd/server

db-verify:
	db/scripts/verify-fresh-postgres.sh

db-seed:
	DATABASE_URL='$(DATABASE_URL)' db/scripts/migrate.sh --seed

generate-migrations:
	node tools/split-schema.mjs

migration-drift:
	node tools/check-migrations-drift.mjs

openapi-lint:
	npx --yes @redocly/cli@1.34.5 lint specs/api/openapi.yaml

openapi-conformance:
	node tools/check-openapi-route-conformance.mjs

miniprogram-test:
	cd apps/miniprogram && node --test test/*.test.mjs
	@set -euo pipefail; \
	cd apps/miniprogram; \
	while IFS= read -r f; do node --check "$$f"; done < <(find . -name '*.js' -not -path './node_modules/*'); \
	while IFS= read -r f; do node -e "JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'))" "$$f"; done < <(find . -name '*.json' -not -path './node_modules/*')

generate-client:
	OPENAPI_GENERATOR_VERSION=$(OPENAPI_GENERATOR_VERSION) tools/generate-dart-client.sh

client-drift:
	OPENAPI_GENERATOR_VERSION=$(OPENAPI_GENERATOR_VERSION) tools/check-generated-dart-client.sh

web-test:
	cd apps/web && npm test

web-build:
	cd apps/web && npm run build

web-lint:
	cd apps/web && npm run lint

flutter-pub-get:
	cd apps/mobile && $(TIMEOUT_SCRIPT) $(FLUTTER_COMMAND_TIMEOUT_SECONDS) flutter pub get

flutter-analyze:
	cd apps/mobile && $(TIMEOUT_SCRIPT) $(FLUTTER_COMMAND_TIMEOUT_SECONDS) flutter analyze

flutter-test:
	cd apps/mobile && $(TIMEOUT_SCRIPT) $(FLUTTER_COMMAND_TIMEOUT_SECONDS) flutter test

flutter-build-android:
	cd apps/mobile && GRADLE_OPTS="$${GRADLE_OPTS:-} $(FLUTTER_GRADLE_OPTS)" $(TIMEOUT_SCRIPT) $(FLUTTER_BUILD_TIMEOUT_SECONDS) flutter build apk --debug

# Formal mini-program build: fail-closed on AppID and production API base.
# Required env:
#   MP_APPID=wx...                      (real AppID, not touristappid)
#   MP_API_BASE=https://api.example.com (https, default port, not p.scolv.com)
# Overwrites apps/miniprogram/utils/config.js + project.config.json appid;
# run scripts/build-miniprogram.sh --restore to get development defaults back.
release-miniprogram:
	@MP_APP_ENV=production scripts/build-miniprogram.sh

# Formal release AAB: fail-closed on store ID, signing, and production API.
# Required env:
#   PRODUCTION_API_BASE_URL=https://api.example.com   (must be https, not temp VPS)
#   SCOLVPET_UPLOAD_STORE_FILE / PASSWORD / KEY_ALIAS / KEY_PASSWORD
# mobile-identifiers.properties must set SCOLVPET_APP_ID to formal store id (not .dev).
release-android:
	@set -euo pipefail; \
	APP_ID="$$(grep -E '^SCOLVPET_APP_ID=' apps/mobile/android/mobile-identifiers.properties | head -1 | cut -d= -f2-)"; \
	test -n "$$APP_ID" || { echo 'SCOLVPET_APP_ID missing' >&2; exit 1; }; \
	case "$$APP_ID" in *'.dev'|*'cn.scolvpet.dev') echo "formal SCOLVPET_APP_ID required, got $$APP_ID" >&2; exit 1;; esac; \
	test -n "$${PRODUCTION_API_BASE_URL:-}" || { echo 'PRODUCTION_API_BASE_URL required (https production API root)' >&2; exit 1; }; \
	case "$$PRODUCTION_API_BASE_URL" in \
	  https://*) ;; \
	  *) echo "PRODUCTION_API_BASE_URL must be https://, got $$PRODUCTION_API_BASE_URL" >&2; exit 1;; \
	esac; \
	case "$$PRODUCTION_API_BASE_URL" in \
	  *localhost*|*127.0.0.1*|*192.168.*|*10.*|*p.scolv.com*) \
	    echo "PRODUCTION_API_BASE_URL looks like temp/dev host: $$PRODUCTION_API_BASE_URL" >&2; exit 1;; \
	esac; \
	STORE_FILE="$${SCOLVPET_UPLOAD_STORE_FILE:-$$(grep -E '^SCOLVPET_UPLOAD_STORE_FILE=' apps/mobile/android/mobile-identifiers.properties 2>/dev/null | cut -d= -f2-)}"; \
	STORE_PASS="$${SCOLVPET_UPLOAD_STORE_PASSWORD:-$$(grep -E '^SCOLVPET_UPLOAD_STORE_PASSWORD=' apps/mobile/android/mobile-identifiers.properties 2>/dev/null | cut -d= -f2-)}"; \
	KEY_ALIAS="$${SCOLVPET_UPLOAD_KEY_ALIAS:-$$(grep -E '^SCOLVPET_UPLOAD_KEY_ALIAS=' apps/mobile/android/mobile-identifiers.properties 2>/dev/null | cut -d= -f2-)}"; \
	KEY_PASS="$${SCOLVPET_UPLOAD_KEY_PASSWORD:-$$(grep -E '^SCOLVPET_UPLOAD_KEY_PASSWORD=' apps/mobile/android/mobile-identifiers.properties 2>/dev/null | cut -d= -f2-)}"; \
	test -n "$$STORE_FILE" -a -n "$$STORE_PASS" -a -n "$$KEY_ALIAS" -a -n "$$KEY_PASS" || { echo 'SCOLVPET_UPLOAD_* keystore credentials required' >&2; exit 1; }; \
	test -f "$$STORE_FILE" || { echo "keystore file not found: $$STORE_FILE" >&2; exit 1; }; \
	export SCOLVPET_UPLOAD_STORE_FILE="$$STORE_FILE" SCOLVPET_UPLOAD_STORE_PASSWORD="$$STORE_PASS" SCOLVPET_UPLOAD_KEY_ALIAS="$$KEY_ALIAS" SCOLVPET_UPLOAD_KEY_PASSWORD="$$KEY_PASS"; \
	cd apps/mobile && GRADLE_OPTS="$${GRADLE_OPTS:-} $(FLUTTER_GRADLE_OPTS)" $(TIMEOUT_SCRIPT) $(FLUTTER_BUILD_TIMEOUT_SECONDS) \
	  flutter build appbundle --release --dart-define=API_BASE_URL="$$PRODUCTION_API_BASE_URL"

outbox-test:
	scripts/i1-outbox-test.sh

timeout-test:
	@$(TIMEOUT_SCRIPT) 5 sh -c 'exit 0'
	@set +e; $(TIMEOUT_SCRIPT) 1 sh -c 'sleep 3'; rc=$$?; set -e; test $$rc -eq 124
	@printf '%s\n' 'timeout wrapper verified: short=passed timeout=exit-124'

smoke:
	# Prefer ephemeral Postgres unless explicitly reusing an external DB.
	# Shared DATABASE_URL retains durable SMS rate-limit state across runs.
	I1_USE_EXTERNAL_DB=$${I1_USE_EXTERNAL_DB:-0} scripts/i1-smoke.sh

reservation-smoke:
	scripts/public-reservation-smoke.sh

media-smoke:
	scripts/i6-media-smoke.sh

objectstore-smoke:
	scripts/i6-objectstore-smoke.sh

ci: db-verify migration-drift openapi-lint openapi-conformance client-drift api-test smoke reservation-smoke media-smoke objectstore-smoke outbox-test timeout-test web-lint web-test web-build miniprogram-test flutter-pub-get flutter-analyze flutter-test flutter-build-android
