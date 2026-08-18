export const MAX_TODAY_SUBJECT_FETCHES = 16

export function collectTaskSubjectRefs(tasks: readonly object[]) {
  const hamsterIds = new Set<string>()
  const litterIds = new Set<string>()
  for (const task of tasks) {
    const rec = task as Record<string, unknown>
    const type = String(rec.targetType || rec.target_type || '').toLowerCase()
    const rawIds = [
      rec.targetId,
      rec.target_id,
      ...(Array.isArray(rec.subjectIds) ? rec.subjectIds : []),
      ...(Array.isArray(rec.subject_ids) ? rec.subject_ids : [])
    ]
    for (const raw of rawIds) {
      const id = String(raw || '').trim()
      if (!id || id === 'custom') continue
      if (type === 'litter') litterIds.add(id)
      else hamsterIds.add(id)
    }
  }
  return {
    hamsterIds: [...hamsterIds].slice(0, MAX_TODAY_SUBJECT_FETCHES),
    litterIds: [...litterIds].slice(0, MAX_TODAY_SUBJECT_FETCHES)
  }
}

export function unwrapSubjectRecord(raw: unknown): Record<string, unknown> | null {
  const root = raw && typeof raw === 'object' ? (raw as { data?: unknown }).data ?? raw : raw
  const item =
    root && typeof root === 'object' && 'litter' in (root as object)
      ? (root as { litter?: unknown }).litter
      : root
  if (!item || typeof item !== 'object') return null
  const id = String((item as { id?: unknown }).id || '').trim()
  if (!id) return null
  return item as Record<string, unknown>
}

export function buildSubjectMap(
  hamsters: Array<Record<string, unknown> | null | undefined>,
  litters: Array<Record<string, unknown> | null | undefined>
): Record<string, Record<string, unknown>> {
  const map: Record<string, Record<string, unknown>> = {}
  for (const item of [...hamsters, ...litters]) {
    if (!item) continue
    const id = String(item.id || '').trim()
    if (id) map[id] = item
  }
  return map
}
