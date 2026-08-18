import { describe, expect, it } from 'vitest'

import { buildParentIndex, displayName, pedigreeDataFromLitters } from '../src/utils/pedigree-from-litters'
import { buildPedigreeRows } from '../src/utils/pedigree'

const hamsters = [
  { id: 'A', name: '小雪', sex: 'female' },
  { id: 'S', name: '阿黑', sex: 'male' },
  { id: 'D', name: '阿蜜', sex: 'female' },
  { id: 'GS', internalCode: 'M-001', sex: 'male' },
  { id: 'GD', name: '奶奶蜜', sex: 'female' },
  { id: 'MGS', name: '外公火', sex: 'male' },
  { id: 'MGD', name: '外婆灰', sex: 'female' }
]

const litters = [
  { id: 'L1', code: '2026-A', sireId: 'S', damId: 'D', memberIds: ['A', 'A2'] },
  { id: 'L0', code: '2025-S', sireId: 'GS', damId: 'GD', members: [{ hamsterId: 'S' }] },
  { id: 'L2', code: '2025-D', sire_id: 'MGS', dam_id: 'MGD', member_ids: ['D'] },
  { id: 'L9', code: '空窝', memberIds: ['X'] }
]

// 客户验收三行标准之三：个体档案里点得到族谱，能往上看两代。
// 个体档案不下发 sireId/damId，父母关系只在窝次上，所以这层反推必须成立。
describe('族谱能打开（窝次反推）', () => {
  it('三代齐全时能长出 祖代 / 父母 / 当前 三行', () => {
    const { data, coverage } = pedigreeDataFromLitters({ rootId: 'A', litters, hamsters, generations: 3 })
    expect(coverage.hasAnyParent).toBe(true)

    const rows = buildPedigreeRows(data, 'A')
    expect(rows.map((row) => row.label)).toEqual(['祖代', '父母', '当前'])

    const parents = rows.filter((row) => row.label === '父母')[0]
    expect(parents.nodes.map((node) => node.name)).toEqual(['阿黑', '阿蜜'])

    const grand = rows.filter((row) => row.label === '祖代')[0]
    expect(grand.nodes.map((node) => node.role)).toEqual(['爷爷', '奶奶', '外公', '外婆'])
    expect(grand.nodes[0].name).toBe('M-001')
    expect(grand.nodes[2].name).toBe('外公火')
  })

  it('祖辈可点，且当前这只不往自己跳', () => {
    const { data } = pedigreeDataFromLitters({ rootId: 'A', litters, hamsters, generations: 3 })
    const rows = buildPedigreeRows(data, 'A')
    const parents = rows.filter((row) => row.label === '父母')[0]
    expect(parents.nodes.every((node) => node.tappable)).toBe(true)
    expect(parents.nodes.every((node) => node.id !== 'A')).toBe(true)
  })

  it('这只不在任何窝里时，给可操作的中文空态', () => {
    const { coverage } = pedigreeDataFromLitters({ rootId: 'ZZ', litters, hamsters })
    expect(coverage.hasAnyParent).toBe(false)
    expect(coverage.note).toContain('窝次')
  })

  it('窝次没登记公母时，提示指向去登记公母', () => {
    const { coverage } = pedigreeDataFromLitters({
      rootId: 'A',
      litters: [{ id: 'L', memberIds: ['A'] }],
      hamsters
    })
    expect(coverage.littersWithParents).toBe(0)
    expect(coverage.note).toContain('公母')
  })

  it('环（自己是自己的父）不死循环', () => {
    const { data } = pedigreeDataFromLitters({
      rootId: 'A',
      litters: [{ id: 'L', sireId: 'A', damId: 'D', memberIds: ['A'] }],
      hamsters,
      generations: 4
    })
    expect(data.edges.length).toBe(2)
  })

  it('一只被登记进两窝时保留第一条并计数，不静默覆盖', () => {
    const { index, conflicts } = buildParentIndex([
      { id: 'L1', sireId: 'S', damId: 'D', memberIds: ['A'] },
      { id: 'L2', sireId: 'GS', damId: 'GD', memberIds: ['A'] }
    ])
    expect(index.get('A')).toEqual({ sireId: 'S', damId: 'D' })
    expect(conflicts).toBe(1)
  })

  it('不把裸 UUID 甩给用户', () => {
    expect(displayName(undefined, '9f8e7d6c-1111-2222-3333-444455556666')).toBe('未命名 9f8e')
    expect(displayName({ internalCode: 'B-12' }, 'x')).toBe('B-12')
    expect(displayName({ name: '小雪', internalCode: 'B-12' }, 'x')).toBe('小雪')
  })
})

import { pedigreeDataFromApiGraph } from '../src/utils/pedigree-from-litters'

describe('家谱 API 图兜底', () => {
  it('parentages 能推出 hasAnyParent', () => {
    const { coverage, data } = pedigreeDataFromApiGraph({
      rootId: 'child-1',
      graph: {
        root_hamster_id: 'child-1',
        nodes: [
          { id: 'child-1', name: '哈豆', sex: 'male' },
          { id: 'sire-1', name: '哈鲁', sex: 'male' },
          { id: 'dam-1', name: '哈尔', sex: 'female' }
        ],
        parentages: [
          { child_hamster_id: 'child-1', parent_hamster_id: 'sire-1', role: 'sire' },
          { child_hamster_id: 'child-1', parent_hamster_id: 'dam-1', role: 'dam' }
        ]
      }
    })
    expect(coverage.hasAnyParent).toBe(true)
    expect(data.edges).toHaveLength(2)
    expect(data.nodes.map((n) => n.public_name).sort()).toEqual(['哈豆', '哈尔', '哈鲁'].sort())
    expect(coverage.note).toContain('家谱登记')
  })

  it('litter_parents + litter_members 也能推出父母，不必再打窝次 N+1', () => {
    const { coverage, data } = pedigreeDataFromApiGraph({
      rootId: 'A',
      graph: {
        rootHamsterId: 'A',
        nodes: [
          { id: 'A', name: '小雪', sex: 'female' },
          { id: 'S', name: '阿黑', sex: 'male' },
          { id: 'D', name: '阿蜜', sex: 'female' }
        ],
        parentages: [],
        litter_parents: [
          { litter_id: 'L1', parent_id: 'S', role: 'sire' },
          { litter_id: 'L1', hamster_id: 'D', role: 'dam' }
        ],
        litter_members: [{ litter_id: 'L1', hamster_id: 'A' }]
      }
    })
    expect(coverage.hasAnyParent).toBe(true)
    expect(data.edges).toHaveLength(2)
    expect(coverage.note).toContain('窝次')
  })

  it('显式家谱边优先于窝次边，同角色不重复', () => {
    const { data } = pedigreeDataFromApiGraph({
      rootId: 'A',
      graph: {
        nodes: [
          { id: 'A', name: '小雪' },
          { id: 'S1', name: '登记公' },
          { id: 'S2', name: '窝次公' },
          { id: 'D', name: '阿蜜' }
        ],
        parentages: [{ childHamsterId: 'A', parentHamsterId: 'S1', role: 'sire' }],
        litterParents: [{ litterId: 'L1', parentId: 'S2', role: 'sire' }, { litterId: 'L1', parentId: 'D', role: 'dam' }],
        litterMembers: [{ litterId: 'L1', hamsterId: 'A' }]
      }
    })
    const sire = data.edges.find((edge) => edge.role === 'sire')
    const dam = data.edges.find((edge) => edge.role === 'dam')
    expect(sire?.parent_hamster_id).toBe('S1')
    expect(dam?.parent_hamster_id).toBe('D')
    expect(data.note).toContain('家谱登记与窝次')
  })
})
