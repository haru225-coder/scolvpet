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

.PHONY: help api-test api-run db-verify db-seed generate-migrations migration-drift openapi-lint client-drift web-test web-build web-lint flutter-pub-get flutter-analyze flutter-test flutter-build-android smoke reservation-smoke media-smoke objectstore-smoke outbox-test timeout-test ci

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

outbox-test:
	scripts/i1-outbox-test.sh

timeout-test:
	@$(TIMEOUT_SCRIPT) 5 sh -c 'exit 0'
	@set +e; $(TIMEOUT_SCRIPT) 1 sh -c 'sleep 3'; rc=$$?; set -e; test $$rc -eq 124
	@printf '%s\n' 'timeout wrapper verified: short=passed timeout=exit-124'

smoke:
	scripts/i1-smoke.sh

reservation-smoke:
	scripts/public-reservation-smoke.sh

media-smoke:
	scripts/i6-media-smoke.sh

objectstore-smoke:
	scripts/i6-objectstore-smoke.sh

ci: db-verify migration-drift openapi-lint client-drift api-test smoke reservation-smoke media-smoke objectstore-smoke outbox-test timeout-test web-lint web-test web-build flutter-pub-get flutter-analyze flutter-test flutter-build-android
