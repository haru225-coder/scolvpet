import { useCallback } from 'react'
import Taro from '@tarojs/taro'
import BListPage, { type BListItem } from '../../../components/BListPage'
import { defaultApi } from '../../../api/client'

export default function LittersPage() {
  const load = useCallback(async (): Promise<BListItem[]> => {
    const response = await defaultApi.listLitters({ limit: 100 })
    return (response.data || []).map((item: any) => ({ id: item.id, title: item.name || item.code || '窝次', subtitle: `${item.state || 'active'} · ${item.bornAt || '出生日期未记录'}`, value: item.state || 'active', tone: item.state === 'closed' ? 'success' as const : 'warning' as const }))
  }, [])
  return <BListPage title="窝次看板" eyebrow="M2" load={load} onSelect={(item) => Taro.navigateTo({ url: `/packages/litters/detail/index?id=${encodeURIComponent(item.id)}` })} footer="窝次、性别分笼与个体化动作使用 DefaultApi" />
}
