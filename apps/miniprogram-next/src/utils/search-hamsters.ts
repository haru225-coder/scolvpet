export const MAX_HAMSTER_SEARCH = 20

export type HamsterSearchApi = {
  listHamsters: (req: { limit?: number; q?: string; sex?: 'male' | 'female' }) => Promise<unknown>
}

export function unwrapHamsterList(raw: unknown): Array<Record<string, unknown>> {
  const root = raw && typeof raw === 'object' ? (raw as { data?: unknown }).data ?? raw : raw
  const list = Array.isArray(root)
    ? root
    : root && typeof root === 'object' && Array.isArray((root as { items?: unknown }).items)
      ? (root as { items: unknown[] }).items
      : []
  return list.filter((item): item is Record<string, unknown> => Boolean(item) && typeof item === 'object')
}

export function hamsterSearchLabel(item: Record<string, unknown>): string {
  const name = String(item.name || '').trim()
  const code = String(item.internalCode || item.internal_code || '').trim()
  if (name && code) return `${name} · ${code}`
  return name || code || String(item.id || '')
}

export async function searchHamsters(
  api: HamsterSearchApi,
  args: { q?: string; sex?: 'male' | 'female'; excludeId?: string; limit?: number } = {}
): Promise<Array<Record<string, unknown>>> {
  const response = await api.listHamsters({
    limit: args.limit ?? MAX_HAMSTER_SEARCH,
    q: args.q?.trim() || undefined,
    sex: args.sex
  })
  const exclude = String(args.excludeId || '').trim()
  return unwrapHamsterList(response).filter((item) => {
    const id = String(item.id || '').trim()
    return Boolean(id) && id !== exclude
  })
}
