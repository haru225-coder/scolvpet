import { useCallback } from 'react'
import Taro from '@tarojs/taro'
import BListPage, { type BListItem } from '../../../components/BListPage'
import { defaultApi } from '../../../api/client'
import { litterScanSubtitle } from '../../../utils/scan-labels'
import { humanShortLabel } from '../../../utils/tab-routes'

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
        tone: item.state === 'closed' ? ('success' as const) : ('warning' as const)
      }
    })
  }, [])
  return (
    <BListPage
      title="窝次看板"
      load={load}
      onSelect={(item) => Taro.navigateTo({ url: `/packages/litters/detail/index?id=${encodeURIComponent(item.id)}` })}
      footer="分笼、个体化与断奶进度"
      emptyTitle="还没有窝次"
      emptyDescription="窝次会在出生登记后出现；想先看配色可去试配模拟"
      actionLabel="试配模拟"
      onAction={() => Taro.navigateTo({ url: '/packages/genetic/create/index' })}
    />
  )
}
