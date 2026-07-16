#!/bin/zsh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

if ! command -v initdb >/dev/null 2>&1 && command -v pg_config >/dev/null 2>&1; then
  PG_BIN="$(pg_config --bindir)"
  export PATH="$PG_BIN:$PATH"
fi

PG_MAJOR="$(pg_config --version | awk '{print $2}' | cut -d. -f1)"
[[ "$PG_MAJOR" == "15" ]] || {
  printf 'PostgreSQL 15 required, found: %s\n' "$(pg_config --version)" >&2
  exit 1
}

BASE="$(mktemp -d /tmp/scolvpet-i2-pg15.XXXXXX)"
DATA="$BASE/data"
PORT="${SCOLVPET_I2_VERIFY_PORT:-$((56000 + RANDOM % 1000))}"
DB="scolvpet_i2_verify"

cleanup() {
  pg_ctl -D "$DATA" stop -m fast >/dev/null 2>&1 || true
  rm -rf "$BASE"
}
trap cleanup EXIT

initdb -D "$DATA" --no-locale --encoding=UTF8 --auth=trust >/dev/null
pg_ctl -D "$DATA" -o "-p $PORT" -l "$BASE/postgres.log" start >/dev/null
until pg_isready -h 127.0.0.1 -p "$PORT" >/dev/null 2>&1; do sleep 0.2; done
createdb -h 127.0.0.1 -p "$PORT" "$DB"

URL="postgres://$(whoami)@127.0.0.1:$PORT/$DB?sslmode=disable"
if ! DATABASE_URL="$URL" "$ROOT/db/scripts/migrate.sh" --seed >"$BASE/migrate.log" 2>&1; then
  cat "$BASE/migrate.log" >&2
  exit 1
fi

pass_count=0

expect_pass() {
  local label="$1"
  local sql
  sql="$(cat)"
  if ! psql -Xq -v ON_ERROR_STOP=1 "$URL" <<<"$sql" >"$BASE/pass.log" 2>&1; then
    printf 'FAIL(pass): %s\n' "$label" >&2
    cat "$BASE/pass.log" >&2
    exit 1
  fi
  pass_count=$((pass_count + 1))
  printf 'ok %02d - %s\n' "$pass_count" "$label"
}

expect_fail() {
  local label="$1"
  local expected_state="$2"
  local sql output exit_code
  sql="$(cat)"
  set +e
  output="$(psql -Xq -v ON_ERROR_STOP=1 -v VERBOSITY=verbose "$URL" <<<"$sql" 2>&1)"
  exit_code=$?
  set -e
  if [[ $exit_code -eq 0 ]]; then
    printf 'FAIL(expected failure): %s\n' "$label" >&2
    exit 1
  fi
  if [[ "$output" != *"$expected_state"* ]]; then
    printf 'FAIL(sqlstate %s): %s\n%s\n' "$expected_state" "$label" "$output" >&2
    exit 1
  fi
  pass_count=$((pass_count + 1))
  printf 'ok %02d - %s [%s]\n' "$pass_count" "$label" "$expected_state"
}

expect_pass "0010 增量迁移可直接重复执行" <<SQL
\i $ROOT/db/migrations/0010_i2_database_constraints.sql
SQL

expect_pass "目标表 owner_id、编号唯一索引与笼位排斥约束齐全" <<'SQL'
DO $$
DECLARE
  missing_owner_columns integer;
  required_indexes integer;
  required_exclusions integer;
BEGIN
  SELECT count(*) INTO missing_owner_columns
  FROM unnest(ARRAY[
    'hamster', 'enclosure', 'enclosure_stay', 'weight_record', 'litter',
    'pedigree_parentage', 'litter_parent', 'litter_member',
    'relationship_assertion', 'import_job', 'import_row', 'import_issue'
  ]) AS required(table_name)
  WHERE NOT EXISTS (
    SELECT 1
    FROM pg_attribute a
    WHERE a.attrelid = required.table_name::regclass
      AND a.attname = 'owner_id'
      AND a.attnotnull
      AND NOT a.attisdropped
  );

  SELECT count(*) INTO required_indexes
  FROM pg_indexes
  WHERE schemaname = 'public'
    AND indexname IN (
      'ux_hamster_owner_internal_code',
      'ux_enclosure_owner_code',
      'ux_litter_owner_code'
    );

  SELECT count(*) INTO required_exclusions
  FROM pg_constraint
  WHERE conrelid = 'enclosure_stay'::regclass
    AND contype = 'x'
    AND conname IN (
      'ex_enclosure_stay_hamster_period',
      'ex_enclosure_stay_single_period'
    );

  IF missing_owner_columns <> 0 OR required_indexes <> 3 OR required_exclusions <> 2 THEN
    RAISE EXCEPTION 'I2 schema inventory mismatch: owner=% indexes=% exclusions=%',
      missing_owner_columns, required_indexes, required_exclusions;
  END IF;
END;
$$;
SQL

expect_pass "建立双 owner、笼盒与仓鼠夹具" <<'SQL'
INSERT INTO enclosure (
  id, owner_id, organization_id, code, capacity, created_by, updated_by
) VALUES
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000101', 'E-01', 1, '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001'),
  ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000101', 'E-02', 1, '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001'),
  ('10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000101', 'E-PAIR', 2, '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001'),
  ('20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000102', 'E-01', 1, '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002');

INSERT INTO hamster (
  id, owner_id, organization_id, internal_code, name, species_rule_version_id,
  sex, birth_date, source_type, created_by, updated_by
) VALUES
  ('11000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000101', 'H-01', '甲', '00000000-0000-0000-0000-000000000201', 'male',   '2025-01-01', 'introduced', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001'),
  ('11000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000101', 'H-02', '乙', '00000000-0000-0000-0000-000000000201', 'female', '2025-01-02', 'introduced', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001'),
  ('11000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000101', 'H-03', '丙', '00000000-0000-0000-0000-000000000201', 'male',   '2025-01-03', 'introduced', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001'),
  ('11000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000101', 'H-04', '丁', '00000000-0000-0000-0000-000000000201', 'female', '2025-01-04', 'introduced', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001'),
  ('11000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000101', 'H-05', '戊', '00000000-0000-0000-0000-000000000201', 'male',   '2025-01-05', 'introduced', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001'),
  ('11000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000101', 'H-06', '己', '00000000-0000-0000-0000-000000000201', 'female', '2025-01-06', 'introduced', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001'),
  ('21000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000102', 'H-01', '跨 owner', '00000000-0000-0000-0000-000000000201', 'male', '2025-01-01', 'introduced', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002');
SQL

expect_fail "仓鼠编号在软删除后仍不可复用" 23505 <<'SQL'
INSERT INTO hamster (
  owner_id, organization_id, internal_code, species_rule_version_id,
  sex, source_type, created_by, updated_by, deleted_at
) VALUES (
  '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000101',
  'H-01', '00000000-0000-0000-0000-000000000201', 'male', 'introduced',
  '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', now()
);
SQL

expect_fail "空白仓鼠编号被拒绝" 23514 <<'SQL'
INSERT INTO hamster (
  owner_id, organization_id, internal_code, species_rule_version_id,
  sex, source_type, created_by, updated_by
) VALUES (
  '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000101',
  '   ', '00000000-0000-0000-0000-000000000201', 'male', 'introduced',
  '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001'
);
SQL

expect_pass "不同 owner 可使用相同业务编号" <<'SQL'
SELECT 1
FROM hamster a
JOIN hamster b ON a.internal_code = b.internal_code AND a.owner_id <> b.owner_id
WHERE a.internal_code = 'H-01';
SQL

expect_fail "仓鼠当前笼盒不可跨 owner" 23503 <<'SQL'
UPDATE hamster
SET current_enclosure_id = '20000000-0000-0000-0000-000000000001'
WHERE id = '11000000-0000-0000-0000-000000000001';
SQL

expect_pass "写入首条普通笼位时段" <<'SQL'
INSERT INTO enclosure_stay (
  id, owner_id, enclosure_id, hamster_id, purpose,
  started_at, ended_at, operator_id
) VALUES (
  '12000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001',
  '10000000-0000-0000-0000-000000000001', '11000000-0000-0000-0000-000000000001',
  'single', '2026-01-01T10:00:00Z', '2026-01-01T11:00:00Z',
  '00000000-0000-0000-0000-000000000001'
);
SQL

expect_fail "同笼盒普通入住时段重叠被拒绝" 23P01 <<'SQL'
INSERT INTO enclosure_stay (
  owner_id, enclosure_id, hamster_id, purpose,
  started_at, ended_at, operator_id
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  '10000000-0000-0000-0000-000000000001', '11000000-0000-0000-0000-000000000002',
  'single', '2026-01-01T10:30:00Z', '2026-01-01T11:30:00Z',
  '00000000-0000-0000-0000-000000000001'
);
SQL

expect_fail "同仓鼠跨笼盒时段重叠被拒绝" 23P01 <<'SQL'
INSERT INTO enclosure_stay (
  owner_id, enclosure_id, hamster_id, purpose,
  started_at, ended_at, operator_id
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  '10000000-0000-0000-0000-000000000002', '11000000-0000-0000-0000-000000000001',
  'single', '2026-01-01T10:30:00Z', '2026-01-01T11:30:00Z',
  '00000000-0000-0000-0000-000000000001'
);
SQL

expect_pass "相邻半开时段允许入住" <<'SQL'
INSERT INTO enclosure_stay (
  owner_id, enclosure_id, hamster_id, purpose,
  started_at, ended_at, operator_id
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  '10000000-0000-0000-0000-000000000001', '11000000-0000-0000-0000-000000000002',
  'single', '2026-01-01T11:00:00Z', '2026-01-01T12:00:00Z',
  '00000000-0000-0000-0000-000000000001'
);
SQL

expect_fail "笼位操作人不可跨 owner" 23514 <<'SQL'
INSERT INTO enclosure_stay (
  owner_id, enclosure_id, hamster_id, purpose,
  started_at, ended_at, operator_id
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  '10000000-0000-0000-0000-000000000002', '11000000-0000-0000-0000-000000000003',
  'single', '2026-01-02T10:00:00Z', '2026-01-02T11:00:00Z',
  '00000000-0000-0000-0000-000000000002'
);
SQL

expect_pass "合法配对尝试允许同一配对笼的两只参与鼠" <<'SQL'
INSERT INTO breeding_plan (
  id, owner_id, organization_id, name, sire_id, dam_id,
  species_rule_version_id, created_by, updated_by
) VALUES (
  '12100000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000101', 'I2 配对笼验证',
  '11000000-0000-0000-0000-000000000001', '11000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000201',
  '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001'
);

INSERT INTO pairing_attempt (
  id, owner_id, breeding_plan_id, attempt_no, sire_id, dam_id,
  pairing_enclosure_id, started_at, separation_deadline, created_by, updated_by
) VALUES (
  '12200000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001',
  '12100000-0000-0000-0000-000000000001', 1,
  '11000000-0000-0000-0000-000000000001', '11000000-0000-0000-0000-000000000002',
  '10000000-0000-0000-0000-000000000003', '2026-02-01T10:00:00Z',
  '2026-02-01T11:00:00Z', '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000001'
);

INSERT INTO enclosure_stay (
  owner_id, enclosure_id, hamster_id, pairing_attempt_id, purpose,
  started_at, ended_at, operator_id
) VALUES
  ('00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000003', '11000000-0000-0000-0000-000000000001', '12200000-0000-0000-0000-000000000001', 'pairing_temp', '2026-02-01T10:00:00Z', '2026-02-01T11:00:00Z', '00000000-0000-0000-0000-000000000001'),
  ('00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000003', '11000000-0000-0000-0000-000000000002', '12200000-0000-0000-0000-000000000001', 'pairing_temp', '2026-02-01T10:00:00Z', '2026-02-01T11:00:00Z', '00000000-0000-0000-0000-000000000001');
SQL

expect_fail "配对笼同时段拒绝第三只普通入住" 23P01 <<'SQL'
INSERT INTO enclosure_stay (
  owner_id, enclosure_id, hamster_id, purpose,
  started_at, ended_at, operator_id
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  '10000000-0000-0000-0000-000000000003', '11000000-0000-0000-0000-000000000003',
  'single', '2026-02-01T10:15:00Z', '2026-02-01T10:45:00Z',
  '00000000-0000-0000-0000-000000000001'
);
SQL

expect_fail "谱系自环被拒绝" 23514 <<'SQL'
INSERT INTO pedigree_parentage (
  owner_id, parent_id, child_id, role, evidence_type, created_by, updated_by
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  '11000000-0000-0000-0000-000000000001', '11000000-0000-0000-0000-000000000001',
  'sire', 'imported', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001'
);
SQL

expect_fail "谱系父母性别角色冲突被拒绝" 23514 <<'SQL'
INSERT INTO pedigree_parentage (
  owner_id, parent_id, child_id, role, evidence_type, created_by, updated_by
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  '11000000-0000-0000-0000-000000000002', '11000000-0000-0000-0000-000000000004',
  'sire', 'imported', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001'
);
SQL

expect_pass "建立两段无环谱系" <<'SQL'
INSERT INTO pedigree_parentage (
  owner_id, parent_id, child_id, role, evidence_type, created_by, updated_by
) VALUES
  ('00000000-0000-0000-0000-000000000001', '11000000-0000-0000-0000-000000000001', '11000000-0000-0000-0000-000000000002', 'sire', 'imported', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001'),
  ('00000000-0000-0000-0000-000000000001', '11000000-0000-0000-0000-000000000002', '11000000-0000-0000-0000-000000000003', 'dam',  'imported', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001');
SQL

expect_fail "三代闭环被递归检查拒绝" 23514 <<'SQL'
INSERT INTO pedigree_parentage (
  owner_id, parent_id, child_id, role, evidence_type, created_by, updated_by
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  '11000000-0000-0000-0000-000000000003', '11000000-0000-0000-0000-000000000001',
  'sire', 'imported', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001'
);
SQL

expect_fail "关系断言自指被拒绝" 23514 <<'SQL'
INSERT INTO relationship_assertion (
  owner_id, organization_id, assertion_kind, subject_type, subject_id,
  related_type, related_id, evidence_type, created_by
) VALUES (
  '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000101',
  'parentage', 'hamster', '11000000-0000-0000-0000-000000000001',
  'hamster', '11000000-0000-0000-0000-000000000001', 'imported',
  '00000000-0000-0000-0000-000000000001'
);
SQL

set +e
psql -Xq -v ON_ERROR_STOP=1 -v VERBOSITY=verbose "$URL" >"$BASE/cycle-a.log" 2>&1 <<'SQL' &
BEGIN;
INSERT INTO pedigree_parentage (
  owner_id, parent_id, child_id, role, evidence_type, created_by, updated_by
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  '11000000-0000-0000-0000-000000000005', '11000000-0000-0000-0000-000000000006',
  'sire', 'imported', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001'
);
SELECT pg_sleep(0.8);
COMMIT;
SQL
cycle_a_pid=$!
sleep 0.2
psql -Xq -v ON_ERROR_STOP=1 -v VERBOSITY=verbose "$URL" >"$BASE/cycle-b.log" 2>&1 <<'SQL'
BEGIN;
INSERT INTO pedigree_parentage (
  owner_id, parent_id, child_id, role, evidence_type, created_by, updated_by
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  '11000000-0000-0000-0000-000000000006', '11000000-0000-0000-0000-000000000005',
  'dam', 'imported', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001'
);
COMMIT;
SQL
cycle_b_status=$?
wait "$cycle_a_pid"
cycle_a_status=$?
set -e
if [[ $cycle_a_status -ne 0 || $cycle_b_status -eq 0 ]] || ! rg -q '23514|pedigree cycle detected' "$BASE/cycle-b.log"; then
  printf 'FAIL: concurrent pedigree cycle guard\n' >&2
  cat "$BASE/cycle-a.log" "$BASE/cycle-b.log" >&2
  exit 1
fi
pass_count=$((pass_count + 1))
printf 'ok %02d - 并发反向谱系边被串行化并拒绝 [23514]\n' "$pass_count"

expect_fail "历史窝次必须保持 origin=import/state=closed" 23514 <<'SQL'
INSERT INTO litter (
  owner_id, organization_id, origin, code, state, born_at, created_by, updated_by
) VALUES (
  '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000101',
  'import', 'L-BAD', 'newborn', '2025-01-04T00:00:00Z',
  '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001'
);
SQL

expect_pass "历史窝次允许未知父母且无需运行态数量事件" <<'SQL'
BEGIN;
INSERT INTO litter (
  id, owner_id, organization_id, origin, code, state, born_at, created_by, updated_by
) VALUES (
  '13000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000101', 'import', 'L-UNKNOWN', 'closed',
  '2025-01-05T00:00:00Z', '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000001'
);
INSERT INTO litter_member (
  owner_id, litter_id, member_type, hamster_id, evidence_type, created_by, updated_by
) VALUES (
  '00000000-0000-0000-0000-000000000001', '13000000-0000-0000-0000-000000000001',
  'hamster', '11000000-0000-0000-0000-000000000004', 'imported',
  '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001'
);
COMMIT;

DO $$
DECLARE cached litter%ROWTYPE;
BEGIN
  SELECT * INTO cached FROM litter WHERE id = '13000000-0000-0000-0000-000000000001';
  IF cached.initial_alive_count <> 1 OR cached.current_managed_count <> 1
    OR cached.individualized_alive_count <> 1 OR cached.unindividualized_alive_count <> 0 THEN
    RAISE EXCEPTION 'historical litter cache mismatch';
  END IF;
END;
$$;
SQL

expect_pass "历史窝次已知父本时原子建立父母、成员和谱系边" <<'SQL'
BEGIN;
INSERT INTO litter (
  id, owner_id, organization_id, origin, code, state, born_at, created_by, updated_by
) VALUES (
  '13000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000101', 'import', 'L-KNOWN', 'closed',
  '2025-01-04T00:00:00Z', '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000001'
);
INSERT INTO litter_parent (
  owner_id, litter_id, parent_id, role, evidence_type, created_by, updated_by
) VALUES (
  '00000000-0000-0000-0000-000000000001', '13000000-0000-0000-0000-000000000002',
  '11000000-0000-0000-0000-000000000001', 'sire', 'imported',
  '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001'
);
INSERT INTO litter_member (
  owner_id, litter_id, member_type, hamster_id, evidence_type, created_by, updated_by
) VALUES (
  '00000000-0000-0000-0000-000000000001', '13000000-0000-0000-0000-000000000002',
  'hamster', '11000000-0000-0000-0000-000000000003', 'imported',
  '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001'
);
INSERT INTO pedigree_parentage (
  owner_id, parent_id, child_id, role, evidence_type, created_by, updated_by
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  '11000000-0000-0000-0000-000000000001', '11000000-0000-0000-0000-000000000003',
  'sire', 'imported', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001'
);
COMMIT;
SQL

expect_fail "历史窝次依赖的谱系边不可单独失效" 23514 <<'SQL'
BEGIN;
UPDATE pedigree_parentage
SET status = 'superseded', valid_to = now(), correction_note = 'I2 guard probe'
WHERE owner_id = '00000000-0000-0000-0000-000000000001'
  AND parent_id = '11000000-0000-0000-0000-000000000001'
  AND child_id = '11000000-0000-0000-0000-000000000003'
  AND role = 'sire'
  AND status = 'accepted'
  AND valid_to IS NULL;
COMMIT;
SQL

expect_pass "建立第二个无父母历史窝次用于旧侧校验" <<'SQL'
BEGIN;
INSERT INTO litter (
  id, owner_id, organization_id, origin, code, state, born_at, created_by, updated_by
) VALUES (
  '13000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000101', 'import', 'L-TARGET', 'closed',
  '2025-01-05T00:00:00Z', '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000001'
);
INSERT INTO litter_member (
  owner_id, litter_id, member_type, hamster_id, evidence_type, created_by, updated_by
) VALUES (
  '00000000-0000-0000-0000-000000000001', '13000000-0000-0000-0000-000000000004',
  'hamster', '11000000-0000-0000-0000-000000000005', 'imported',
  '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001'
);
COMMIT;
SQL

expect_fail "移动历史成员时旧窝次也必须保持完整" 23514 <<'SQL'
BEGIN;
UPDATE litter_member
SET litter_id = '13000000-0000-0000-0000-000000000004'
WHERE owner_id = '00000000-0000-0000-0000-000000000001'
  AND litter_id = '13000000-0000-0000-0000-000000000001'
  AND hamster_id = '11000000-0000-0000-0000-000000000004'
  AND status = 'accepted'
  AND valid_to IS NULL;
COMMIT;
SQL

expect_fail "历史窝次缺少继承谱系边时整组回滚" 23514 <<'SQL'
BEGIN;
INSERT INTO litter (
  id, owner_id, organization_id, origin, code, state, born_at, created_by, updated_by
) VALUES (
  '13000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000101', 'import', 'L-MISSING-EDGE', 'closed',
  '2025-01-06T00:00:00Z', '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000001'
);
INSERT INTO litter_parent (
  owner_id, litter_id, parent_id, role, evidence_type, created_by, updated_by
) VALUES (
  '00000000-0000-0000-0000-000000000001', '13000000-0000-0000-0000-000000000003',
  '11000000-0000-0000-0000-000000000001', 'sire', 'imported',
  '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001'
);
INSERT INTO litter_member (
  owner_id, litter_id, member_type, hamster_id, evidence_type, created_by, updated_by
) VALUES (
  '00000000-0000-0000-0000-000000000001', '13000000-0000-0000-0000-000000000003',
  'hamster', '11000000-0000-0000-0000-000000000006', 'imported',
  '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001'
);
COMMIT;
SQL

expect_fail "历史窝次 origin 不可改写" 55000 <<'SQL'
UPDATE litter SET origin = 'breeding'
WHERE id = '13000000-0000-0000-0000-000000000001';
SQL

expect_fail "体重必须为正数" 23514 <<'SQL'
INSERT INTO weight_record (
  owner_id, organization_id, subject_type, hamster_id, measurement_kind,
  weight_g, recorded_at, source, operator_id
) VALUES (
  '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000101',
  'hamster', '11000000-0000-0000-0000-000000000001', 'individual',
  0, now(), 'manual', '00000000-0000-0000-0000-000000000001'
);
SQL

expect_fail "体重差值必须与快照一致" 23514 <<'SQL'
INSERT INTO weight_record (
  owner_id, organization_id, subject_type, hamster_id, measurement_kind,
  weight_g, recorded_at, source, birth_weight_g, change_from_birth_g, operator_id
) VALUES (
  '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000101',
  'hamster', '11000000-0000-0000-0000-000000000001', 'individual',
  30, now(), 'manual', 25, 4, '00000000-0000-0000-0000-000000000001'
);
SQL

expect_fail "体重操作人不可跨 owner" 23514 <<'SQL'
INSERT INTO weight_record (
  owner_id, organization_id, subject_type, hamster_id, measurement_kind,
  weight_g, recorded_at, source, operator_id
) VALUES (
  '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000101',
  'hamster', '11000000-0000-0000-0000-000000000001', 'individual',
  30, now(), 'manual', '00000000-0000-0000-0000-000000000002'
);
SQL

expect_pass "合法体重与差值快照可写入" <<'SQL'
INSERT INTO weight_record (
  owner_id, organization_id, subject_type, hamster_id, measurement_kind,
  weight_g, recorded_at, source, acquisition_key,
  birth_weight_g, change_from_birth_g, previous_weight_g, change_from_previous_g,
  operator_id
) VALUES (
  '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000101',
  'hamster', '11000000-0000-0000-0000-000000000001', 'individual',
  30, now(), 'manual', 'i2-weight-1', 25, 5, 29, 1,
  '00000000-0000-0000-0000-000000000001'
);
SQL

expect_pass "建立三组导入任务夹具" <<'SQL'
INSERT INTO async_job (
  id, owner_id, organization_id, job_type, idempotency_key, created_by
) VALUES
  ('14000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000101', 'import', 'i2-async-1', '00000000-0000-0000-0000-000000000001'),
  ('14000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000101', 'import', 'i2-async-2', '00000000-0000-0000-0000-000000000001'),
  ('14000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000101', 'import', 'i2-async-3', '00000000-0000-0000-0000-000000000001');

INSERT INTO import_job (
  id, owner_id, organization_id, async_job_id, template_type,
  source_object_key, original_filename, file_sha256, idempotency_batch_key, created_by
) VALUES
  ('15000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000101', '14000000-0000-0000-0000-000000000001', 'hamster', 'imports/i2-1.csv', 'i2-1.csv', repeat('1', 64), 'i2-batch-1', '00000000-0000-0000-0000-000000000001'),
  ('15000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000101', '14000000-0000-0000-0000-000000000002', 'hamster', 'imports/i2-2.csv', 'i2-2.csv', repeat('2', 64), 'i2-batch-2', '00000000-0000-0000-0000-000000000001'),
  ('15000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000101', '14000000-0000-0000-0000-000000000003', 'hamster', 'imports/i2-3.csv', 'i2-3.csv', repeat('3', 64), 'i2-batch-3', '00000000-0000-0000-0000-000000000001');
SQL

expect_pass "同窝导入组完成全量预检" <<'SQL'
INSERT INTO import_row (
  id, owner_id, import_job_id, row_number, raw_data, row_sha256,
  idempotency_key, atomic_group_key, atomic_group_fingerprint
) VALUES
  ('16000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '15000000-0000-0000-0000-000000000001', 1, '{"internal_code":"H-01","litter_code":"L-I2"}', repeat('a',64), 'i2-row-1', 'L-I2', repeat('a',64)),
  ('16000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', '15000000-0000-0000-0000-000000000001', 2, '{"internal_code":"H-02","litter_code":"L-I2"}', repeat('b',64), 'i2-row-2', 'L-I2', repeat('a',64));

BEGIN;
UPDATE import_row SET status = 'valid'
WHERE import_job_id = '15000000-0000-0000-0000-000000000001';
UPDATE import_job
SET status = 'ready', total_rows = 2, valid_rows = 2, invalid_rows = 0, prechecked_at = now()
WHERE id = '15000000-0000-0000-0000-000000000001';
COMMIT;

UPDATE import_job SET status = 'applying'
WHERE id = '15000000-0000-0000-0000-000000000001';
SQL

expect_fail "同窝导入组核心事实指纹不一致被拒绝" 23514 <<'SQL'
INSERT INTO import_row (
  owner_id, import_job_id, row_number, raw_data, row_sha256,
  idempotency_key, atomic_group_key, atomic_group_fingerprint
) VALUES (
  '00000000-0000-0000-0000-000000000001', '15000000-0000-0000-0000-000000000002',
  1, '{"litter_code":"L-MIX"}', repeat('c',64), 'i2-row-mix-1', 'L-MIX', repeat('c',64)
);
INSERT INTO import_row (
  owner_id, import_job_id, row_number, raw_data, row_sha256,
  idempotency_key, atomic_group_key, atomic_group_fingerprint
) VALUES (
  '00000000-0000-0000-0000-000000000001', '15000000-0000-0000-0000-000000000002',
  2, '{"litter_code":"L-MIX"}', repeat('d',64), 'i2-row-mix-2', 'L-MIX', repeat('d',64)
);
SQL

expect_fail "同窝导入组不允许只应用部分成员" 23514 <<'SQL'
BEGIN;
UPDATE import_row
SET status = 'imported', target_table = 'hamster',
    target_id = '11000000-0000-0000-0000-000000000001', processed_at = now()
WHERE id = '16000000-0000-0000-0000-000000000001';
UPDATE import_job SET imported_rows = 1
WHERE id = '15000000-0000-0000-0000-000000000001';
COMMIT;
SQL

expect_pass "同窝导入组可在单事务中整体应用" <<'SQL'
BEGIN;
UPDATE import_row
SET status = 'imported', target_table = 'hamster',
    target_id = CASE row_number
      WHEN 1 THEN '11000000-0000-0000-0000-000000000001'::uuid
      ELSE '11000000-0000-0000-0000-000000000002'::uuid
    END,
    processed_at = now()
WHERE import_job_id = '15000000-0000-0000-0000-000000000001';
UPDATE import_job SET imported_rows = 2
WHERE id = '15000000-0000-0000-0000-000000000001';
COMMIT;

UPDATE import_job SET status = 'succeeded', applied_at = now()
WHERE id = '15000000-0000-0000-0000-000000000001';
SQL

expect_fail "import_issue 不可引用同 owner 下另一 job 的行" 23503 <<'SQL'
INSERT INTO import_issue (
  owner_id, import_job_id, import_row_id, severity, issue_code, message
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  '15000000-0000-0000-0000-000000000002',
  '16000000-0000-0000-0000-000000000001',
  'error', 'ROW_JOB_MISMATCH', 'row must belong to issue job'
);
SQL

expect_fail "import_row 结果目标不可跨 owner" 23514 <<'SQL'
UPDATE import_row
SET status = 'imported', target_table = 'hamster',
    target_id = '21000000-0000-0000-0000-000000000001', processed_at = now()
WHERE owner_id = '00000000-0000-0000-0000-000000000001'
  AND import_job_id = '15000000-0000-0000-0000-000000000002'
  AND row_number = 1;
SQL

expect_fail "导入任务不可在行未终态时提前标记成功" 23514 <<'SQL'
BEGIN;
INSERT INTO import_row (
  owner_id, import_job_id, row_number, raw_data, row_sha256, idempotency_key
) VALUES (
  '00000000-0000-0000-0000-000000000001', '15000000-0000-0000-0000-000000000003',
  1, '{"internal_code":"H-03"}', repeat('e',64), 'i2-row-premature'
);
UPDATE import_row SET status = 'valid'
WHERE import_job_id = '15000000-0000-0000-0000-000000000003';
UPDATE import_job
SET status = 'succeeded', total_rows = 1, valid_rows = 1, invalid_rows = 0,
    imported_rows = 0, skipped_rows = 0, prechecked_at = now(), applied_at = now()
WHERE id = '15000000-0000-0000-0000-000000000003';
COMMIT;
SQL

MIGRATIONS="$(psql -XAt "$URL" -c "select count(*) from scolvpet_meta.schema_migrations;")"
CONSTRAINTS="$(psql -XAt "$URL" -c "select count(*) from pg_constraint where conname like 'ck_%' or conname like 'ex_%';")"

printf 'I2 database constraints verified: checks=%s migrations=%s constraints=%s postgres=%s port=%s\n' \
  "$pass_count" "$MIGRATIONS" "$CONSTRAINTS" "$(pg_config --version)" "$PORT"
