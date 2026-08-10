import { useCallback, useState } from 'react'
import Taro from '@tarojs/taro'
import BListPage, { type BListItem } from '../../../components/BListPage'
import { p1Api } from '../../../api/p1-api'
import { notifyUserError } from '../../../api/errors'
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
  return `${DOMAIN_HOME.geneticCreate}?${q.join('&')}`
}

function profileListFromResponse(profilesRes: any): any[] {
  const profiles = profilesRes?.data ?? profilesRes
  if (Array.isArray(profiles)) return profiles
  if (Array.isArray(profiles?.items)) return profiles.items
  if (Array.isArray(profiles?.data)) return profiles.data
  return []
}

/** 试配入口：档案列表（置信度/编辑/删除/带入试配）+ 位点参考。 */
export default function GeneticPage() {
  const [reloadToken, setReloadToken] = useState(0)

  const load = useCallback(async (): Promise<BListItem[]> => {
    void reloadToken
    const [profilesRes, lociRes] = await Promise.all([p1Api.listGeneticProfiles(), p1Api.listGeneticLoci()])
    const profileList = profileListFromResponse(profilesRes)
    const lociRaw = (lociRes as any)?.data ?? lociRes
    const lociList = Array.isArray(lociRaw) ? lociRaw : lociRaw?.items || []

    const locusItems: BListItem[] = lociList.map((item: any) => ({
      id: `locus-${item.id || item.code}`,
      title: item.name || item.code || '遗传位点',
      subtitle: item.series || item.description || item.code || undefined,
      value: '位点',
      tone: 'accent' as const,
      data: { kind: 'locus' }
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
          id: String(item.id || ''),
          name: String(item.name || ''),
          confidence: conf,
          series: seriesOf(item),
          phenotypeLabel: label,
          genotypeKey: key,
          version: Number(item.version || 1),
          genotype: item.genotype || {},
          phenotype: item.phenotype || {},
          notes: item.notes ?? null
        }
      }
    })

    return [...profileItems, ...locusItems]
  }, [reloadToken])

  async function renameProfile(data: Record<string, unknown>) {
    const id = String(data.id || '')
    const version = Number(data.version || 0)
    const currentName = String(data.name || '')
    if (!id || version <= 0) {
      void Taro.showToast({ title: '档案数据不完整', icon: 'none' })
      return
    }
    const modal = await Taro.showModal({
      title: '重命名档案',
      editable: true,
      placeholderText: currentName || '档案名称',
      content: currentName
    } as any)
    if (!modal.confirm) return
    const name = String((modal as any).content || '').trim()
    if (!name) {
      void Taro.showToast({ title: '名称不能为空', icon: 'none' })
      return
    }
    try {
      await p1Api.updateGeneticProfile({
        profileId: id,
        updateGeneticProfileRequest: {
          name,
          version
        } as any
      } as any)
      void Taro.showToast({ title: '已重命名', icon: 'success' })
      setReloadToken((n) => n + 1)
    } catch (cause) {
      await notifyUserError(cause, '重命名失败')
    }
  }

  async function deleteProfile(data: Record<string, unknown>) {
    const id = String(data.id || '')
    const name = String(data.name || '该档案')
    if (!id) return
    const modal = await Taro.showModal({
      title: '删除档案',
      content: `确定删除「${name}」？不可恢复`,
      confirmText: '删除',
      confirmColor: '#E05454'
    })
    if (!modal.confirm) return
    try {
      await p1Api.deleteGeneticProfile({ profileId: id } as any)
      void Taro.showToast({ title: '已删除', icon: 'success' })
      setReloadToken((n) => n + 1)
    } catch (cause) {
      await notifyUserError(cause, '删除失败')
    }
  }

  return (
    <BListPage
      key={reloadToken}
      title="试配模拟"
      load={load}
      footer="点档案：试配 / 重命名 / 删除。主路径也可直接开始试配。"
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
        const series = String(data.series || '')
        const ph = String(data.phenotypeLabel || '')
        const itemList = key
          ? ['设为公本并去试配', '设为母本并去试配', '重命名', '删除档案']
          : ['重命名', '删除档案']
        void Taro.showActionSheet({ itemList })
          .then((res) => {
            const idx = res.tapIndex
            if (key) {
              if (idx === 0 || idx === 1) {
                const side = idx === 0 ? 'sire' : 'dam'
                void Taro.navigateTo({
                  url: buildTrialUrl({ series, side, key, phenotype: ph })
                })
                return
              }
              if (idx === 2) {
                void renameProfile(data)
                return
              }
              if (idx === 3) {
                void deleteProfile(data)
              }
              return
            }
            if (idx === 0) void renameProfile(data)
            if (idx === 1) void deleteProfile(data)
          })
          .catch(() => undefined)
      }}
    />
  )
}
