import { useCallback } from 'react'
import Taro from '@tarojs/taro'
import BListPage, { type BListItem } from '../../../components/BListPage'
import { defaultApi } from '../../../api/client'

export default function BreedingPage() {
  const load = useCallback(async (): Promise<BListItem[]> => {
    const response = await defaultApi.listBreedingPlans({ limit: 100 })
    return (response.data || []).map((item: any) => ({
      id: item.id,
      title: item.title || `${item.sireId || '待定'} × ${item.damId || '待定'}`,
      subtitle: `${item.state || 'draft'} · ${item.createdAt || ''}`,
      value: item.state || 'draft',
      tone: item.state === 'completed' ? 'success' : item.state === 'blocked' ? 'danger' : 'warning'
    }))
  }, [])
  return <BListPage title="繁育计划" eyebrow="M2" load={load} onSelect={(item) => Taro.navigateTo({ url: `/packages/breeding/detail/index?id=${encodeURIComponent(item.id)}` })} footer="计划、配对、孕期和出生动作均来自生成客户端" actionLabel="新建繁育计划" actionCapability="write_breeding" onAction={() => Taro.navigateTo({ url: '/packages/breeding/create/index' })} />
}
