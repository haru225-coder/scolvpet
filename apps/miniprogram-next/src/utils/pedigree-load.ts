import {
  litterMemberIds,
  pedigreeDataFromApiGraph,
  pedigreeDataFromLitters,
  type HamsterLike,
  type LineageCoverage,
  type LitterLike,
  type PedigreeData
} from './pedigree-from-litters'

export const MAX_LITTERS_TO_EXPAND = 40
export const MAX_PEDIGREE_NAME_FETCHES = 8

export type PedigreeFetchApi = {
  getHamster: (args: { hamsterId: string }) => Promise<unknown>
  getHamsterPedigree: (args: { hamsterId: string; generations?: number }) => Promise<unknown>
  listLitters: (args: { limit: number }) => Promise<unknown>
  listLitterMembers: (args: { litterId: string; limit: number }) => Promise<unknown>
}

function unwrapData(raw: unknown): unknown {
  if (!raw || typeof raw !== 'object') return raw
  return (raw as { data?: unknown }).data ?? raw
}

function unwrapList<T>(raw: unknown): T[] {
  const data = unwrapData(raw)
  return Array.isArray(data) ? (data as T[]) : []
}

function asHamster(raw: unknown, fallbackId?: string): HamsterLike | null {
  const item = unwrapData(raw)
  if (!item || typeof item !== 'object') return null
  const record = item as HamsterLike
  const id = String(record.id || record.hamsterId || fallbackId || '').trim()
  if (!id) return null
  return { ...record, id }
}

/**
 * 经营端族谱拉数：先 getHamster + getHamsterPedigree（图里已含窝次父母/成员）。
 * 图上没有父母时才退回 listLitters + 有限窝次成员，不再全量 listHamsters。
 */
export async function loadOperatingPedigree(
  api: PedigreeFetchApi,
  rootId: string,
  generations = 3
): Promise<{ data: PedigreeData; coverage: LineageCoverage }> {
  const [hamsterRaw, graphRaw] = await Promise.all([
    api.getHamster({ hamsterId: rootId }),
    api.getHamsterPedigree({ hamsterId: rootId, generations }).catch(() => null)
  ])
  const root = asHamster(hamsterRaw, rootId)
  const graph = unwrapData(graphRaw) as Parameters<typeof pedigreeDataFromApiGraph>[0]['graph']
  const fromApi = pedigreeDataFromApiGraph({ rootId, graph, generations })
  if (root && (root.name || root.internalCode || root.internal_code)) {
    fromApi.data.root_public_name = String(root.name || root.internalCode || root.internal_code)
  }
  if (fromApi.coverage.hasAnyParent) return fromApi

  const littersRaw = await api.listLitters({ limit: 100 }).catch(() => ({ data: [] }))
  const litters = unwrapList<LitterLike>(littersRaw).filter(
    (litter) => litter?.sireId || litter?.damId || litter?.sire_id || litter?.dam_id
  )
  const expanded: LitterLike[] = await Promise.all(
    litters.slice(0, MAX_LITTERS_TO_EXPAND).map(async (litter) => {
      if (litterMemberIds(litter).length) return litter
      const litterId = String(litter?.id ?? '')
      if (!litterId) return litter
      try {
        const members = await api.listLitterMembers({ litterId, limit: 100 })
        return { ...litter, members: unwrapList(members) }
      } catch {
        return litter
      }
    })
  )

  const seed: HamsterLike[] = root ? [root] : []
  const first = pedigreeDataFromLitters({ rootId, litters: expanded, hamsters: seed, generations })
  const missing = first.data.nodes
    .map((node) => node.hamster_id)
    .filter((id) => id && id !== rootId)
    .slice(0, MAX_PEDIGREE_NAME_FETCHES)
  if (!missing.length) return first

  const extras = await Promise.all(
    missing.map((id) =>
      api
        .getHamster({ hamsterId: id })
        .then((raw) => asHamster(raw, id))
        .catch(() => null)
    )
  )
  return pedigreeDataFromLitters({
    rootId,
    litters: expanded,
    hamsters: [...seed, ...extras.filter((item): item is HamsterLike => Boolean(item))],
    generations
  })
}
