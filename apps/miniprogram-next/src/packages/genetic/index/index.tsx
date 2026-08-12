import { useCallback, useRef, useState } from 'react'
import Taro, { useDidShow } from '@tarojs/taro'
import BListPage, { type BListItem } from '../../../components/BListPage'
import { ActionPanel, statusColors } from '@scolvpet/mp-ui'
import { p1Api } from '../../../api/p1-api'
import { notifyUserError } from '../../../api/errors'
import { DOMAIN_HOME } from '../../../utils/tab-routes'
import {
  buildTrialDeepLink,
  profileListFromResponse,
  sideFromGeneticProfile
} from '../../../genetics/trial-deeplink'

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
  return sideFromGeneticProfile(item).phenotype || ''
}

function genotypeKeyOf(item: any): string {
  return sideFromGeneticProfile(item).key || ''
}

function seriesOf(item: any): string {
  return sideFromGeneticProfile(item).series
}

function hamsterLabelOf(item: any): string {
  const name = String(item?.hamsterName || item?.hamster_name || '').trim()
  const code = String(item?.hamsterCode || item?.hamster_code || '').trim()
  if (name && code) return `${name}（${code}）`
  return name || code || ''
}

/** 试配入口：档案列表（绑定个体 / 试配 / 重命名 / 删除）+ 位点参考。 */
export default function GeneticPage() {
  const [reloadToken, setReloadToken] = useState(0)
  const firstShow = useRef(true)
  /** 当前被点开的档案行菜单 */
  const [menu, setMenu] = useState<{
    data: Record<string, unknown>
    key: string
    series: string
    ph: string
    canTrial: boolean
  } | null>(null)

  // 从绑定页返回时刷新列表（首屏交给 BListPage 自己 load，避免双请求）
  useDidShow(() => {
    if (firstShow.current) {
      firstShow.current = false
      return
    }
    setReloadToken((n) => n + 1)
  })

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
      const hamster = hamsterLabelOf(item)
      const hamsterId = String(item.hamsterId || item.hamster_id || '').trim()
      const parts = [
        label ? `样子 ${label}` : '',
        key ? `key ${key}` : '',
        hamster ? `个体 ${hamster}` : '未绑定个体',
        item.notes ? String(item.notes).slice(0, 40) : ''
      ].filter(Boolean)
      return {
        id: `profile-${item.id}`,
        title: item.name || '遗传档案',
        subtitle: parts.join(' · '),
        value: confidenceLabel(conf),
        tone: hamsterId ? 'success' : confidenceTone(conf),
        data: {
          kind: 'profile',
          id: String(item.id || ''),
          name: String(item.name || ''),
          confidence: conf,
          series: seriesOf(item),
          phenotypeLabel: label,
          genotypeKey: key,
          version: Number(item.version || 1),
          hamsterId,
          hamsterLabel: hamster,
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
        updateGeneticProfileRequest: { name, version } as any
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
      confirmColor: statusColors.systemRed
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

  function bindHamster(data: Record<string, unknown>) {
    const id = String(data.id || '')
    const version = Number(data.version || 0)
    const current = String(data.hamsterId || '').trim()
    if (!id || version <= 0) {
      void Taro.showToast({ title: '档案数据不完整', icon: 'none' })
      return
    }
    const q = [
      `profile_id=${encodeURIComponent(id)}`,
      `version=${encodeURIComponent(String(version))}`,
      current ? `current_hamster_id=${encodeURIComponent(current)}` : ''
    ]
      .filter(Boolean)
      .join('&')
    void Taro.navigateTo({ url: `${DOMAIN_HOME.geneticBindHamster}?${q}` })
  }

  return (
    <>
      <BListPage
        key={reloadToken}
        title="试配模拟"
        load={load}
        footer="点档案：试配 / 绑定个体 / 重命名 / 删除。"
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
          // 有 key 或有样子都可带入试配；无两者则只剩绑定/改名/删
          const canTrial = Boolean(key || ph)
          setMenu({ data, key, series, ph, canTrial })
        }}
      />
      <ActionPanel
        open={menu != null}
        title={menu ? String(menu.data.name || '该档案') : undefined}
        actions={[
          ...(menu?.canTrial
            ? [
                {
                  text: '设为公本并去试配',
                  onClick: () =>
                    void Taro.navigateTo({
                      url: buildTrialDeepLink({
                        series: menu.series,
                        side: 'sire',
                        key: menu.key || undefined,
                        phenotype: menu.ph || undefined
                      })
                    })
                },
                {
                  text: '设为母本并去试配',
                  onClick: () =>
                    void Taro.navigateTo({
                      url: buildTrialDeepLink({
                        series: menu.series,
                        side: 'dam',
                        key: menu.key || undefined,
                        phenotype: menu.ph || undefined
                      })
                    })
                }
              ]
            : []),
          { text: '绑定/更换个体', onClick: () => menu && void bindHamster(menu.data) },
          { text: '重命名', onClick: () => menu && void renameProfile(menu.data) },
          { text: '删除档案', danger: true, onClick: () => menu && void deleteProfile(menu.data) }
        ]}
        onClose={() => setMenu(null)}
      />
    </>
  )
}
