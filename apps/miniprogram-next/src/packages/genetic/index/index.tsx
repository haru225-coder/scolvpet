import { useCallback } from 'react'
import Taro from '@tarojs/taro'
import BListPage, { type BListItem } from '../../../components/BListPage'
import { p1Api } from '../../../api/p1-api'
import { DOMAIN_HOME } from '../../../utils/tab-routes'

function confidenceLabel(raw: unknown): string {
  const c = String(raw || '').trim().toLowerCase()
  if (c === 'inferred') return '反推'
  if (c === 'observed') return '实测'
  if (c === 'unknown') return '未知'
  return c || '档案'
}

function confidenceTone(raw: unknown): BListItem['tone'] {
  const c = String(raw || '').trim().toLowerCase()
  if (c === 'inferred') return 'warning'
  if (c === 'observed') return 'success'
  return 'accent'
}

function phenotypeLabelOf(item: any): string {
  const ph = item?.phenotype || {}
  return String(ph.label || ph.summary || ph.Label || '').trim()
}

function genotypeKeyOf(item: any): string {
  const g = item?.genotype || {}
  return String(g.key || g.Key || '').trim()
}

function seriesOf(item: any): string {
  const ph = item?.phenotype || {}
  const g = item?.genotype || {}
  return String(ph.series || g.series || '').trim()
}

function buildTrialUrl(opts: {
  series?: string
  side: 'sire' | 'dam'
  key: string
  phenotype?: string
}): string {
  const q: string[] = [`side=${opts.side}`]
  if (opts.series) q.push(`series=${encodeURIComponent(opts.series)}`)
  if (opts.key) q.push(`${opts.side}_key=${encodeURIComponent(opts.key)}`)
  if (opts.phenotype) q.push(`${opts.side}_ph=${encodeURIComponent(opts.phenotype)}`)
  // 分包 create 页支持 query；Tab 的 switchTab 不支持 query
  return `${DOMAIN_HOME.geneticCreate}?${q.join('&')}`
}

/** 试配入口列表：主 CTA 进模拟器；列表展示档案/位点，点档案可带入试配。 */
export default function GeneticPage() {
  const load = useCallback(async (): Promise<BListItem[]> => {
    const [profilesRes, lociRes] = await Promise.all([p1Api.listGeneticProfiles(), p1Api.listGeneticLoci()])
    const profiles = (profilesRes as any)?.data ?? profilesRes
    const loci = (lociRes as any)?.data ?? lociRes
    const profileList = Array.isArray(profiles) ? profiles : profiles?.items || []
    const lociList = Array.isArray(loci) ? loci : loci?.items || []

    const locusItems: BListItem[] = lociList.map((item: any) => ({
      id: `locus-${item.id || item.code}`,
      title: item.name || item.code || '遗传位点',
      subtitle: item.series || item.description || item.code || undefined,
      value: '位点',
      tone: 'accent' as const
    }))

    const profileItems: BListItem[] = profileList.map((item: any) => {
      const conf = item.confidence
      const label = phenotypeLabelOf(item)
      const key = genotypeKeyOf(item)
      const bound = String(item.hamsterName || item.hamsterCode || item.hamsterId || '').trim()
      const parts = [
        label ? `样子 ${label}` : '',
        key ? `key ${key}` : '',
        bound ? `个体 ${bound}` : '未绑定个体',
        item.notes ? String(item.notes).slice(0, 40) : ''
      ].filter(Boolean)
      return {
        id: `profile-${item.id}`,
        title: item.name || '遗传档案',
        subtitle: parts.join(' · '),
        value: confidenceLabel(conf),
        tone: confidenceTone(conf),
        data: {
          kind: 'profile',
          id: item.id,
          name: item.name,
          confidence: conf,
          series: seriesOf(item),
          phenotypeLabel: label,
          genotypeKey: key,
          genotype: item.genotype || {}
        }
      }
    })

    // 档案在前，方便点选；位点参考在后
    return [...profileItems, ...locusItems]
  }, [])

  return (
    <BListPage
      title="试配模拟"
      load={load}
      footer="点档案可设为公/母并去试配。主路径也可直接开始试配。"
      emptyTitle="直接开始试配"
      emptyDescription="选好公母样子，立刻看可能长什么样"
      actionLabel="开始试配"
      actionCapability="write_genetic"
      onAction={() => Taro.navigateTo({ url: DOMAIN_HOME.geneticCreate })}
      onSelect={(item) => {
        const data = item.data
        if (!data || data.kind !== 'profile') {
          void Taro.showToast({ title: '位点仅供参考', icon: 'none' })
          return
        }
        const key = String(data.genotypeKey || '').trim()
        if (!key) {
          void Taro.showToast({ title: '该档案没有基因型 key', icon: 'none' })
          return
        }
        const series = String(data.series || '')
        const ph = String(data.phenotypeLabel || '')
        void Taro.showActionSheet({
          itemList: ['设为公本并去试配', '设为母本并去试配']
        })
          .then((res) => {
            const side = res.tapIndex === 0 ? 'sire' : 'dam'
            void Taro.navigateTo({
              url: buildTrialUrl({ series, side, key, phenotype: ph })
            })
          })
          .catch(() => undefined)
      }}
    />
  )
}
