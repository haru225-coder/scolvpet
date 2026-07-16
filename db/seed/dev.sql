BEGIN;

INSERT INTO account (id, phone_country_code, phone_number, display_name)
VALUES
  ('00000000-0000-0000-0000-000000000001', '+86', '13800138000', '演示舍主一'),
  ('00000000-0000-0000-0000-000000000002', '+86', '13800138001', '演示舍主二')
ON CONFLICT (id) DO UPDATE SET display_name = excluded.display_name;

INSERT INTO organization (id, owner_id, code, name, mode, timezone, weight_unit, created_by, updated_by)
VALUES
  ('00000000-0000-0000-0000-000000000101', '00000000-0000-0000-0000-000000000001', 'demo-one', '雪团熊舍', 'personal', 'Asia/Shanghai', 'g', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001'),
  ('00000000-0000-0000-0000-000000000102', '00000000-0000-0000-0000-000000000002', 'demo-two', '云朵熊舍', 'personal', 'Asia/Shanghai', 'g', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002')
ON CONFLICT (id) DO UPDATE SET name = excluded.name, updated_at = now();

INSERT INTO species_rule_version (
  id, owner_id, scope, species_code, variety_scope, display_name, version_no,
  status, gestation_min_days, gestation_max_days, pairing_max_minutes,
  weaning_target_days, sexing_target_days, separation_target_days,
  post_breeding_rest_days, profile_creation_deadline_days, weight_reference,
  reminder_rules, source_note, checksum, effective_at, created_by, updated_by
)
VALUES (
  '00000000-0000-0000-0000-000000000201', NULL, 'system', 'mesocricetus_auratus',
  '["golden", "long_hair", "syrian"]'::jsonb, '金丝熊基础规则', 1,
  'published', 16, 18, 15, 21, 28, 35, 7, 42,
  '{"unit":"g","drop_alert_24h_percent":8}'::jsonb,
  '{"pairing_timeout":true,"gestation_window":true}'::jsonb,
  'I1 开发基线系统模板', 'i1-demo-mesocricetus-v1', '2026-07-16T00:00:00Z', NULL, NULL
)
ON CONFLICT (id) DO UPDATE SET display_name = excluded.display_name, updated_at = now();

INSERT INTO usage_meter (owner_id, metric, current_value, measured_at)
SELECT a.id, metric, 0, now()
FROM account a
JOIN organization o ON o.owner_id = a.id
CROSS JOIN unnest(enum_range(NULL::usage_metric)) AS metric
ON CONFLICT (owner_id, metric) DO NOTHING;

COMMIT;
