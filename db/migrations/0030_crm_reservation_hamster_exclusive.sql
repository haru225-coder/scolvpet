-- T1-03/05: one open reservation per hamster (held/confirmed exclusive).
BEGIN;

-- Fail-safe if historical duplicates exist: keep the newest open row per hamster.
WITH ranked AS (
  SELECT id,
         ROW_NUMBER() OVER (
           PARTITION BY owner_id, hamster_id
           ORDER BY reserved_at DESC, id DESC
         ) AS rn
  FROM crm_reservation
  WHERE hamster_id IS NOT NULL
    AND status IN ('held', 'confirmed')
)
UPDATE crm_reservation r
SET status = 'cancelled',
    version = r.version + 1,
    updated_at = now(),
    notes = CASE
      WHEN r.notes IS NULL OR btrim(r.notes) = '' THEN '系统：历史重复开放预订已取消（0030 exclusive）'
      ELSE r.notes || E'\n系统：历史重复开放预订已取消（0030 exclusive）'
    END
FROM ranked
WHERE r.id = ranked.id
  AND ranked.rn > 1;

CREATE UNIQUE INDEX IF NOT EXISTS ux_crm_reservation_open_hamster
  ON crm_reservation (owner_id, hamster_id)
  WHERE hamster_id IS NOT NULL
    AND status IN ('held', 'confirmed');

COMMIT;
