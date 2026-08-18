import { describe, expect, it } from 'vitest'

import { loadOperatingPedigree, type PedigreeFetchApi } from '../src/utils/pedigree-load'

function fakeApi(overrides: Partial<PedigreeFetchApi> = {}): PedigreeFetchApi & {
  calls: { getHamster: string[]; getHamsterPedigree: string[]; listLitters: number; listLitterMembers: string[] }
} {
  const calls = { getHamster: [] as string[], getHamsterPedigree: [] as string[], listLitters: 0, listLitterMembers: [] as string[] }
  return {
    calls,
    getHamster: async ({ hamsterId }) => {
      calls.getHamster.push(hamsterId)
      return { data: { id: hamsterId, name: hamsterId === 'A' ? '小雪' : hamsterId, sex: 'female' } }
    },
    getHamsterPedigree: async ({ hamsterId }) => {
      calls.getHamsterPedigree.push(hamsterId)
      return { data: { rootHamsterId: hamsterId, nodes: [], parentages: [], litterParents: [], litterMembers: [] } }
    },
    listLitters: async () => {
      calls.listLitters += 1
      return { data: [] }
    },
    listLitterMembers: async ({ litterId }) => {
      calls.listLitterMembers.push(litterId)
      return { data: [] }
    },
    ...overrides
  }
}

describe('经营端族谱拉数', () => {
  it('家谱图已有父母时不再 listLitters / listLitterMembers', async () => {
    const api = fakeApi({
      getHamsterPedigree: async ({ hamsterId }) => {
        api.calls.getHamsterPedigree.push(hamsterId)
        return {
          data: {
            rootHamsterId: hamsterId,
            nodes: [
              { id: 'A', name: '小雪', sex: 'female' },
              { id: 'S', name: '阿黑', sex: 'male' }
            ],
            parentages: [{ childHamsterId: 'A', parentHamsterId: 'S', role: 'sire' }],
            litterParents: [],
            litterMembers: []
          }
        }
      }
    })
    const result = await loadOperatingPedigree(api, 'A')
    expect(result.coverage.hasAnyParent).toBe(true)
    expect(result.data.root_public_name).toBe('小雪')
    expect(api.calls.listLitters).toBe(0)
    expect(api.calls.listLitterMembers).toEqual([])
  })

  it('图上只有窝次父母时也不打窝次列表', async () => {
    const api = fakeApi({
      getHamsterPedigree: async ({ hamsterId }) => {
        api.calls.getHamsterPedigree.push(hamsterId)
        return {
          data: {
            root_hamster_id: hamsterId,
            nodes: [{ id: 'A', name: '小雪' }, { id: 'D', name: '阿蜜' }],
            parentages: [],
            litter_parents: [{ litter_id: 'L1', parent_id: 'D', role: 'dam' }],
            litter_members: [{ litter_id: 'L1', hamster_id: 'A' }]
          }
        }
      }
    })
    const result = await loadOperatingPedigree(api, 'A')
    expect(result.coverage.hasAnyParent).toBe(true)
    expect(api.calls.listLitters).toBe(0)
  })

  it('家谱图空时才退回窝次，并且只点查出现过的个体名', async () => {
    const api = fakeApi({
      listLitters: async () => {
        api.calls.listLitters += 1
        return { data: [{ id: 'L1', sireId: 'S', damId: 'D' }] }
      },
      listLitterMembers: async ({ litterId }) => {
        api.calls.listLitterMembers.push(litterId)
        return { data: [{ hamsterId: 'A' }] }
      }
    })
    const result = await loadOperatingPedigree(api, 'A')
    expect(result.coverage.hasAnyParent).toBe(true)
    expect(api.calls.listLitters).toBe(1)
    expect(api.calls.listLitterMembers).toEqual(['L1'])
    expect(api.calls.getHamster.sort()).toEqual(['A', 'D', 'S'])
  })
})
