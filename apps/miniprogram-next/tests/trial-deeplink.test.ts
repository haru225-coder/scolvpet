import { describe, expect, it } from 'vitest'
import {
  buildTrialDeepLink,
  findProfileByHamsterId,
  phenotypeFromAnimal,
  profileListFromResponse,
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
})
