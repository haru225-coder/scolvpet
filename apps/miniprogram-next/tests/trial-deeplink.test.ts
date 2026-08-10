import { describe, expect, it } from 'vitest'
import {
  buildTrialDeepLink,
  dualTrialFromLitterParents,
  dualTrialFromPair,
  findProfileByHamsterId,
  litterParentIds,
  phenotypeFromAnimal,
  profileListFromResponse,
  resolveLitterParentTrialUrl,
  sideFromGeneticProfile,
  trialSideFromAnimal
} from '../src/genetics/trial-deeplink'

describe('trial-deeplink', () => {
  it('buildTrialDeepLink 单侧带 key 与样子', () => {
    const url = buildTrialDeepLink({
      series: 'syrian',
      side: 'sire',
      key: 'A/a B/B',
      phenotype: '黑眼白'
    })
    expect(url).toContain('/packages/genetic/create/index?')
    expect(url).toContain('side=sire')
    expect(url).toContain('series=syrian')
    expect(url).toContain('sire_key=')
    expect(url).toContain('sire_ph=')
  })

  it('buildTrialDeepLink 双侧公母', () => {
    const url = buildTrialDeepLink({
      series: 'syrian',
      sire: { key: 'k1', phenotype: '公样' },
      dam: { phenotype: '母样' }
    })
    expect(url).toContain('sire_key=')
    expect(url).toContain('sire_ph=')
    expect(url).toContain('dam_ph=')
    expect(url).not.toContain('side=')
  })

  it('phenotypeFromAnimal 解析 varietyCode', () => {
    expect(
      phenotypeFromAnimal({
        varietyCode: 'syrian|奶油',
        corePhenotypeLabel: ''
      })
    ).toEqual({ series: 'syrian', label: '奶油' })
  })

  it('trialSideFromAnimal 按性别分侧并优先档案 key', () => {
    const male = trialSideFromAnimal(
      { sex: 'male', varietyCode: 'syrian|金黄' },
      { genotype: { key: 'G1', series: 'syrian' }, phenotype: { label: '金黄', series: 'syrian' } }
    )
    expect(male.side).toBe('sire')
    expect(male.key).toBe('G1')
    expect(male.phenotype).toBe('金黄')

    const female = trialSideFromAnimal({ sex: 'female', corePhenotypeLabel: '银狐' }, null)
    expect(female.side).toBe('dam')
    expect(female.phenotype).toBe('银狐')
  })

  it('findProfileByHamsterId / profileListFromResponse', () => {
    const list = profileListFromResponse({
      data: [{ id: 'p1', hamsterId: 'h1' }, { id: 'p2', hamster_id: 'h2' }]
    })
    expect(list).toHaveLength(2)
    expect(findProfileByHamsterId(list, 'h2')?.id).toBe('p2')
    expect(findProfileByHamsterId(list, 'missing')).toBeNull()
  })

  it('sideFromGeneticProfile 空档案', () => {
    expect(sideFromGeneticProfile(null)).toEqual({ series: '' })
  })

  it('dualTrialFromPair 按公母性别入座', () => {
    const pair = dualTrialFromPair(
      { sex: 'female', varietyCode: 'syrian|母样' },
      { sex: 'male', corePhenotypeLabel: '公样' },
      { genotype: { key: 'DAM1', series: 'syrian' }, phenotype: { label: '母样', series: 'syrian' } },
      { genotype: { key: 'SIRE1', series: 'syrian' }, phenotype: { label: '公样', series: 'syrian' } }
    )
    expect(pair.assignedBySex).toBe(true)
    expect(pair.sire?.key).toBe('SIRE1')
    expect(pair.dam?.key).toBe('DAM1')
    expect(pair.series).toBe('syrian')
  })

  it('dualTrialFromPair 性别不明时按点选顺序', () => {
    const pair = dualTrialFromPair(
      { sex: 'unknown', corePhenotypeLabel: '先点' },
      { sex: 'unknown', corePhenotypeLabel: '后点' },
      null,
      null
    )
    expect(pair.assignedBySex).toBe(false)
    expect(pair.sire?.phenotype).toBe('先点')
    expect(pair.dam?.phenotype).toBe('后点')
  })

  it('litterParentIds 兼容 snake/camel', () => {
    expect(litterParentIds({ sireId: 'S1', dam_id: 'D1' })).toEqual({ sireId: 'S1', damId: 'D1' })
  })

  it('dualTrialFromLitterParents 拼双侧', () => {
    const pair = dualTrialFromLitterParents({
      sireAnimal: { varietyCode: 'syrian|公样' },
      damAnimal: { corePhenotypeLabel: '母样' },
      sireProfile: { genotype: { key: 'SK', series: 'syrian' }, phenotype: { label: '公样', series: 'syrian' } },
      damProfile: null
    })
    expect(pair.series).toBe('syrian')
    expect(pair.sire?.key).toBe('SK')
    expect(pair.dam?.phenotype).toBe('母样')
  })

  it('resolveLitterParentTrialUrl 无公母报错', async () => {
    const r = await resolveLitterParentTrialUrl({
      litter: {},
      getHamster: async () => null,
      listProfiles: async () => []
    })
    expect(r).toEqual({ error: '本窝未登记公母' })
  })

  it('resolveLitterParentTrialUrl 成功拼 URL', async () => {
    const r = await resolveLitterParentTrialUrl({
      litter: { sireId: 's1', damId: 'd1' },
      getHamster: async (id) =>
        id === 's1'
          ? { data: { sex: 'male', corePhenotypeLabel: '公样' } }
          : { data: { sex: 'female', corePhenotypeLabel: '母样' } },
      listProfiles: async () => ({
        data: [{ hamsterId: 's1', genotype: { key: 'K1', series: 'syrian' }, phenotype: { series: 'syrian', label: '公样' } }]
      })
    })
    expect('url' in r).toBe(true)
    if ('url' in r) {
      expect(r.url).toContain('sire_key=')
      expect(r.url).toContain('dam_ph=')
    }
  })
})
