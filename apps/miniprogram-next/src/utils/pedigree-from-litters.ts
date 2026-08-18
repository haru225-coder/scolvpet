/**
 * 经营端族谱数据源（窝次反推）。
 *
 * 背景：个体档案（GET /v1/hamsters/{id}）不下发 sireId / damId，父母关系只存在于
 * 窝次上（LitterData.sireId / damId）。公开谱系接口 /public/sites/{slug}/... 要求
 * 个体 public === true，经营端自己的库大部分不公开，因此不能复用。
 *
 * 本模块只做一件事：把「窝次 + 窝成员」翻译成 utils/pedigree.js 已经吃的
 * { nodes, edges } 形状，再交给已单测过的 buildPedigreeRows 排版。
 * 谱系排版逻辑不在这里重复实现。
 *
 * 纯函数、无 Taro 依赖，可直接单测。
 */

export type LitterLike = {
  id?: string
  code?: string
  sireId?: string
  damId?: string
  sire_id?: string
  dam_id?: string
  memberIds?: string[]
  member_ids?: string[]
  members?: Array<{ hamsterId?: string; hamster_id?: string; id?: string }>
}

export type HamsterLike = {
  id?: string
  hamsterId?: string
  name?: string
  internalCode?: string
  internal_code?: string
  sex?: string
}

/** 与 utils/pedigree.js 的输入契约一致（蛇形，勿改字段名）。 */
export type PedigreeNode = {
  hamster_id: string
  public_name: string
  sex: string
  public: boolean
}

export type PedigreeEdge = {
  child_hamster_id: string
  parent_hamster_id: string
  role: 'sire' | 'dam'
}

export type PedigreeData = {
  root_hamster_id: string
  root_public_name: string
  note: string
  nodes: PedigreeNode[]
  edges: PedigreeEdge[]
}

/** 反推能不能成立的自检结果，用来决定页面显示树还是显示中文空态。 */
export type LineageCoverage = {
  /** 至少拿到一代父母 */
  hasAnyParent: boolean
  /** 窝次里带了 sire/dam 的条数 */
  littersWithParents: number
  /** 能定位到「属于哪一窝」的个体数 */
  childrenResolved: number
  /** 供页面直接展示的中文说明 */
  note: string
}

function pickId(value: unknown): string {
  const t = String(value ?? '').trim()
  return t
}

function litterSire(litter: LitterLike): string {
  return pickId(litter.sireId ?? litter.sire_id)
}

function litterDam(litter: LitterLike): string {
  return pickId(litter.damId ?? litter.dam_id)
}

/** 一条窝次里的成员 id，兼容 memberIds / member_ids / members[]。 */
export function litterMemberIds(litter: LitterLike): string[] {
  const direct = litter.memberIds ?? litter.member_ids
  if (Array.isArray(direct)) return direct.map(pickId).filter(Boolean)
  if (Array.isArray(litter.members)) {
    return litter.members
      .map((m) => pickId(m?.hamsterId ?? m?.hamster_id ?? m?.id))
      .filter(Boolean)
  }
  return []
}

/** 个体显示名：名字 > 编号 > 短 id，绝不把裸 UUID 甩给用户。 */
export function displayName(hamster: HamsterLike | undefined, id: string): string {
  const name = String(hamster?.name ?? '').trim()
  if (name) return name
  const code = String(hamster?.internalCode ?? hamster?.internal_code ?? '').trim()
  if (code) return code
  if (!id) return '没登记'
  return `未命名 ${id.slice(0, 4)}`
}

/**
 * 建 childId -> { sireId, damId } 映射。
 * 一只个体只应归属一窝；出现冲突时保留第一条并计数，不静默覆盖。
 */
export function buildParentIndex(litters: LitterLike[]): {
  index: Map<string, { sireId: string; damId: string }>
  conflicts: number
  littersWithParents: number
} {
  const index = new Map<string, { sireId: string; damId: string }>()
  let conflicts = 0
  let littersWithParents = 0

  for (const litter of litters || []) {
    const sireId = litterSire(litter)
    const damId = litterDam(litter)
    if (!sireId && !damId) continue
    littersWithParents += 1
    for (const childId of litterMemberIds(litter)) {
      if (!childId) continue
      if (index.has(childId)) {
        conflicts += 1
        continue
      }
      index.set(childId, { sireId, damId })
    }
  }

  return { index, conflicts, littersWithParents }
}

/**
 * 从窝次反推出以 rootId 为根、最多 generations 代的 { nodes, edges }。
 * generations = 3 表示：当前 + 父母 + 祖代（与公开谱系接口默认一致）。
 */
export function pedigreeDataFromLitters(args: {
  rootId: string
  litters: LitterLike[]
  hamsters: HamsterLike[]
  generations?: number
}): { data: PedigreeData; coverage: LineageCoverage } {
  const rootId = pickId(args.rootId)
  const generations = Math.max(1, Math.min(4, Number(args.generations) || 3))
  const { index, littersWithParents } = buildParentIndex(args.litters || [])

  const hamsterById = new Map<string, HamsterLike>()
  for (const h of args.hamsters || []) {
    const id = pickId(h?.id ?? h?.hamsterId)
    if (id) hamsterById.set(id, h)
  }

  const nodes: PedigreeNode[] = []
  const edges: PedigreeEdge[] = []
  const emitted = new Set<string>()

  function emitNode(id: string) {
    if (!id || emitted.has(id)) return
    emitted.add(id)
    const h = hamsterById.get(id)
    nodes.push({
      hamster_id: id,
      public_name: displayName(h, id),
      sex: String(h?.sex ?? '').trim(),
      // 经营端自己看自己的库，全部按已登记处理（public 只是 pedigree.js 的可点判据）
      public: true
    })
  }

  // 逐层向上展开，避免环导致的无限递归
  emitNode(rootId)
  let frontier = rootId ? [rootId] : []
  const visited = new Set<string>(frontier)

  for (let depth = 1; depth < generations && frontier.length; depth += 1) {
    const next: string[] = []
    for (const childId of frontier) {
      const parents = index.get(childId)
      if (!parents) continue
      const pairs: Array<['sire' | 'dam', string]> = [
        ['sire', parents.sireId],
        ['dam', parents.damId]
      ]
      for (const [role, parentId] of pairs) {
        if (!parentId) continue
        emitNode(parentId)
        edges.push({ child_hamster_id: childId, parent_hamster_id: parentId, role })
        if (!visited.has(parentId)) {
          visited.add(parentId)
          next.push(parentId)
        }
      }
    }
    frontier = next
  }

  const childrenResolved = index.size
  const hasAnyParent = edges.length > 0
  const rootName = displayName(hamsterById.get(rootId), rootId)

  const note = hasAnyParent
    ? '父母关系来自窝次记录'
    : littersWithParents === 0
      ? '窝次里还没登记公母，登记后这里会自动长出族谱'
      : '这只还没出现在已有窝次的成员里，加进去之后这里会出族谱'

  return {
    data: {
      root_hamster_id: rootId,
      root_public_name: rootName,
      note,
      nodes,
      edges
    },
    coverage: { hasAnyParent, littersWithParents, childrenResolved, note }
  }
}

/**
 * 把 GET /v1/hamsters/{id}/pedigree 的图（parentages + nodes）翻成
 * 与 pedigreeDataFromLitters 相同的 { nodes, edges } 契约。
 * 窝次链路走不通时的兜底（createPedigreeParentage / 导入边）。
 */
export function pedigreeDataFromApiGraph(args: {
  rootId: string
  graph: {
    root_hamster_id?: string
    rootHamsterId?: string
    nodes?: Array<Record<string, unknown>>
    parentages?: Array<Record<string, unknown>>
  } | null | undefined
}): { data: PedigreeData; coverage: LineageCoverage } {
  const rootId = pickId(args.rootId || args.graph?.root_hamster_id || args.graph?.rootHamsterId)
  const rawNodes = Array.isArray(args.graph?.nodes) ? args.graph!.nodes! : []
  const rawParentages = Array.isArray(args.graph?.parentages) ? args.graph!.parentages! : []

  const hamsterById = new Map<string, HamsterLike>()
  for (const n of rawNodes) {
    const id = pickId(n.id ?? n.hamster_id ?? n.hamsterId)
    if (!id) continue
    hamsterById.set(id, {
      id,
      name: String(n.name ?? ''),
      internalCode: String(n.internal_code ?? n.internalCode ?? ''),
      sex: String(n.sex ?? '')
    })
  }

  const nodes: PedigreeNode[] = []
  const edges: PedigreeEdge[] = []
  const emitted = new Set<string>()

  function emitNode(id: string) {
    if (!id || emitted.has(id)) return
    emitted.add(id)
    const h = hamsterById.get(id)
    nodes.push({
      hamster_id: id,
      public_name: displayName(h, id),
      sex: String(h?.sex ?? '').trim(),
      public: true
    })
  }

  emitNode(rootId)
  for (const edge of rawParentages) {
    const child = pickId(edge.child_hamster_id ?? edge.childHamsterId)
    const parent = pickId(edge.parent_hamster_id ?? edge.parentHamsterId)
    const roleRaw = String(edge.role ?? '').toLowerCase()
    const role: 'sire' | 'dam' | '' = roleRaw === 'sire' || roleRaw === 'dam' ? roleRaw : ''
    if (!child || !parent || !role) continue
    // 仅保留有效边
    if (edge.valid_to || edge.validTo) continue
    emitNode(child)
    emitNode(parent)
    edges.push({ child_hamster_id: child, parent_hamster_id: parent, role })
  }

  const hasAnyParent = edges.some((e) => e.child_hamster_id === rootId)
  const rootName = displayName(hamsterById.get(rootId), rootId)
  const note = hasAnyParent
    ? '父母关系来自家谱登记'
    : '还没有父母边。可在窝次登记公母，或通过家谱接口登记父母'

  return {
    data: {
      root_hamster_id: rootId,
      root_public_name: rootName,
      note,
      nodes,
      edges
    },
    coverage: {
      hasAnyParent,
      littersWithParents: 0,
      childrenResolved: hasAnyParent ? 1 : 0,
      note
    }
  }
}
