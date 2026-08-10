import { useCallback } from 'react'
import Taro from '@tarojs/taro'
import BListPage, { type BListItem } from '../../../components/BListPage'
import { defaultApi } from '../../../api/default-api'
import { p1Api } from '../../../api/p1-api'
import { litterScanSubtitle } from '../../../utils/scan-labels'
import { DOMAIN_HOME, humanShortLabel } from '../../../utils/tab-routes'
import { resolveLitterParentTrialUrl } from '../../../genetics/trial-deeplink'

export default function LittersPage() {
  const load = useCallback(async (): Promise<BListItem[]> => {
    const response = await defaultApi.listLitters({ limit: 100 })
    return (response.data || []).map((item: any) => {
      const state = humanShortLabel(item.state || 'active')
      const managed = Number(item.currentManagedCount ?? item.current_managed_count)
      return {
        id: item.id,
        title: item.name || item.code || '窝次',
        subtitle: litterScanSubtitle(item, state) || state,
        value: Number.isFinite(managed) && managed >= 0 ? `${managed}只` : state,
        tone: item.state === 'closed' ? ('success' as const) : ('warning' as const),
        data: { litter: item }
      }
    })
  }, [])

  async function openParentTrial(litter: any) {
    try {
      const resolved = await resolveLitterParentTrialUrl({
        litter,
        getHamster: (hamsterId) => defaultApi.getHamster({ hamsterId }),
        listProfiles: () => p1Api.listGeneticProfiles()
      })
      if ('error' in resolved) {
        void Taro.showToast({ title: resolved.error, icon: 'none' })
        return
      }
      void Taro.navigateTo({ url: resolved.url })
    } catch {
      void Taro.showToast({ title: '打开试配失败', icon: 'none' })
    }
  }

  return (
    <BListPage
      title="窝次看板"
      load={load}
      onSelect={(item) => {
        const litter = (item.data as any)?.litter
        void Taro.showActionSheet({
          itemList: ['打开窝次', '用公母试配']
        })
          .then((res) => {
            if (res.tapIndex === 0) {
              void Taro.navigateTo({
                url: `/packages/litters/detail/index?id=${encodeURIComponent(item.id)}`
              })
              return
            }
            if (res.tapIndex === 1) void openParentTrial(litter || { id: item.id })
          })
          .catch(() => undefined)
      }}
      footer="点窝次：打开详情或用公母试配 · 分笼/个体化/断奶在详情里"
      emptyTitle="还没有窝次"
      emptyDescription="窝次会在出生登记后出现；想先看配色可去试配模拟"
      actionLabel="试配模拟"
      onAction={() => Taro.navigateTo({ url: DOMAIN_HOME.geneticCreate })}
    />
  )
}
