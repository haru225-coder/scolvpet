import { DOMAIN_HOME } from '../utils/tab-routes'
import { decodePhenotype } from '../utils/phenotype'

export type TrialSide = 'sire' | 'dam'

export type TrialSideInput = {
  key?: string
  phenotype?: string
}

export type BuildTrialDeepLinkOpts = {
  series?: string
  /** 单侧入口（档案列表设公/母） */
  side?: TrialSide
  key?: string
  phenotype?: string
  /** 双侧入口（窝次公母、双选） */
  sire?: TrialSideInput
  dam?: TrialSideInput
}

/** 从个体档案字段解析系列 + 样子。 */
export function phenotypeFromAnimal(animal: any): { series: string; label: string } {
  const label = String(
    animal?.corePhenotypeLabel || animal?.core_phenotype_label || animal?.phenotypeLabel || ''
  ).trim()
  const variety = String(animal?.varietyCode || animal?.variety_code || '').trim()
  const decoded = variety ? decodePhenotype(variety) : null
  return {
    series: String(decoded?.series || '').trim(),
    label: label || decoded?.label || ''
  }
}

/** 从遗传档案解析系列 / 样子 / genotype key。 */
export function sideFromGeneticProfile(profile: any | null | undefined): TrialSideInput & {
  series: string
} {
  if (!profile) return { series: '' }
  const key = String(profile?.genotype?.key || profile?.genotype?.Key || '').trim()
  const ph = profile?.phenotype || {}
  const g = profile?.genotype || {}
  const series = String(ph.series || g.series || '').trim()
  const phenotype = String(ph.label || ph.summary || ph.Label || '').trim()
  return { series, key: key || undefined, phenotype: phenotype || undefined }
}

/**
 * 试配模拟深链（packages/genetic/create → TrialPairingScreen）。
 * 支持单侧 side + key/ph，或双侧 sire/dam。
 */
export function buildTrialDeepLink(opts: BuildTrialDeepLinkOpts): string {
  const q: string[] = []
  const series = String(opts.series || '').trim()
  if (series) q.push(`series=${encodeURIComponent(series)}`)

  if (opts.sire || opts.dam) {
    const sireKey = String(opts.sire?.key || '').trim()
    const sirePh = String(opts.sire?.phenotype || '').trim()
    const damKey = String(opts.dam?.key || '').trim()
    const damPh = String(opts.dam?.phenotype || '').trim()
    if (sireKey) q.push(`sire_key=${encodeURIComponent(sireKey)}`)
    if (sirePh) q.push(`sire_ph=${encodeURIComponent(sirePh)}`)
    if (damKey) q.push(`dam_key=${encodeURIComponent(damKey)}`)
    if (damPh) q.push(`dam_ph=${encodeURIComponent(damPh)}`)
  } else if (opts.side) {
    q.push(`side=${opts.side}`)
    const key = String(opts.key || '').trim()
    const ph = String(opts.phenotype || '').trim()
    if (key) q.push(`${opts.side}_key=${encodeURIComponent(key)}`)
    if (ph) q.push(`${opts.side}_ph=${encodeURIComponent(ph)}`)
  }

  return q.length ? `${DOMAIN_HOME.geneticCreate}?${q.join('&')}` : DOMAIN_HOME.geneticCreate
}

/** 按 hamsterId 在档案列表中找绑定项。 */
export function findProfileByHamsterId(profiles: any[], hamsterId: string): any | null {
  const id = String(hamsterId || '').trim()
  if (!id) return null
  return (
    profiles.find((p) => String(p?.hamsterId || p?.hamster_id || '').trim() === id) || null
  )
}

export function profileListFromResponse(profilesRes: any): any[] {
  const profiles = profilesRes?.data ?? profilesRes
  if (Array.isArray(profiles)) return profiles
  if (Array.isArray(profiles?.items)) return profiles.items
  if (Array.isArray(profiles?.data)) return profiles.data
  return []
}

/**
 * 用个体 + 可选已绑档案，拼单侧试配参数（性别 → 公/母）。
 */
export function trialSideFromAnimal(
  animal: any,
  profile?: any | null
): { side: TrialSide; series: string; key?: string; phenotype?: string } {
  const sex = String(animal?.sex || '').trim()
  const side: TrialSide = sex === 'female' ? 'dam' : 'sire'
  const fromAnimal = phenotypeFromAnimal(animal)
  const fromProfile = sideFromGeneticProfile(profile)
  return {
    side,
    series: fromProfile.series || fromAnimal.series,
    key: fromProfile.key,
    phenotype: fromProfile.phenotype || fromAnimal.label || undefined
  }
}

/**
 * 两只个体 → 双侧试配参数。
 * 能分清公母时按性别入座；否则按点选顺序：先点=公、后点=母。
 */
/** 窝次对象上的公母 id（兼容 snake）。 */
export function litterParentIds(litter: any): { sireId: string; damId: string } {
  return {
    sireId: String(litter?.sireId || litter?.sire_id || '').trim(),
    damId: String(litter?.damId || litter?.dam_id || '').trim()
  }
}

/**
 * 窝次公母 → 试配深链参数（纯拼装；拉个体/档案由调用方完成）。
 */
export function dualTrialFromLitterParents(opts: {
  sireAnimal?: any | null
  damAnimal?: any | null
  sireProfile?: any | null
  damProfile?: any | null
}): BuildTrialDeepLinkOpts {
  const sireSide = sideFromGeneticProfile(opts.sireProfile)
  const damSide = sideFromGeneticProfile(opts.damProfile)
  const sirePh = phenotypeFromAnimal(opts.sireAnimal)
  const damPh = phenotypeFromAnimal(opts.damAnimal)
  return {
    series: sireSide.series || damSide.series || sirePh.series || damPh.series || '',
    sire: {
      key: sireSide.key,
      phenotype: sireSide.phenotype || sirePh.label || undefined
    },
    dam: {
      key: damSide.key,
      phenotype: damSide.phenotype || damPh.label || undefined
    }
  }
}

/**
 * 拉窝次公母个体 + 遗传档案，拼好试配 URL。
 * 无公母 id 时返回 error。
 */
export async function resolveLitterParentTrialUrl(opts: {
  litter: any
  getHamster: (hamsterId: string) => Promise<any>
  listProfiles: () => Promise<any>
}): Promise<{ url: string } | { error: string }> {
  const { sireId, damId } = litterParentIds(opts.litter)
  if (!sireId && !damId) {
    return { error: '本窝未登记公母' }
  }
  const [sireRes, damRes, profilesRes] = await Promise.all([
    sireId ? opts.getHamster(sireId).catch(() => null) : Promise.resolve(null),
    damId ? opts.getHamster(damId).catch(() => null) : Promise.resolve(null),
    opts.listProfiles().catch(() => null)
  ])
  const profiles = profilesRes ? profileListFromResponse(profilesRes) : []
  const sireAnimal = (sireRes as any)?.data ?? sireRes
  const damAnimal = (damRes as any)?.data ?? damRes
  const pair = dualTrialFromLitterParents({
    sireAnimal,
    damAnimal,
    sireProfile: sireId ? findProfileByHamsterId(profiles, sireId) : null,
    damProfile: damId ? findProfileByHamsterId(profiles, damId) : null
  })
  const hasAny =
    Boolean(pair.sire?.key || pair.sire?.phenotype || pair.dam?.key || pair.dam?.phenotype)
  if (!hasAny) {
    return { error: '公母档案暂无样子，可到试配页手选' }
  }
  return { url: buildTrialDeepLink(pair) }
}

export function dualTrialFromPair(
  animalA: any,
  animalB: any,
  profileA?: any | null,
  profileB?: any | null
): BuildTrialDeepLinkOpts & { assignedBySex: boolean } {
  const sexA = String(animalA?.sex || '').trim().toLowerCase()
  const sexB = String(animalB?.sex || '').trim().toLowerCase()

  let sire = animalA
  let dam = animalB
  let sireProfile = profileA
  let damProfile = profileB
  let assignedBySex = false

  if (sexA === 'male' && sexB === 'female') {
    assignedBySex = true
  } else if (sexA === 'female' && sexB === 'male') {
    sire = animalB
    dam = animalA
    sireProfile = profileB
    damProfile = profileA
    assignedBySex = true
  } else if (sexA === 'female' && sexB !== 'male') {
    // A 明确是母 → A 坐母位
    sire = animalB
    dam = animalA
    sireProfile = profileB
    damProfile = profileA
    assignedBySex = sexA === 'female'
  } else if (sexB === 'female' && sexA !== 'male') {
    // B 明确是母、A 非公 → B 坐母
    assignedBySex = true
  }

  const sireSide = sideFromGeneticProfile(sireProfile)
  const damSide = sideFromGeneticProfile(damProfile)
  const sirePh = phenotypeFromAnimal(sire)
  const damPh = phenotypeFromAnimal(dam)
  return {
    series: sireSide.series || damSide.series || sirePh.series || damPh.series || '',
    sire: {
      key: sireSide.key,
      phenotype: sireSide.phenotype || sirePh.label || undefined
    },
    dam: {
      key: damSide.key,
      phenotype: damSide.phenotype || damPh.label || undefined
    },
    assignedBySex
  }
}
