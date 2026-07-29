import { useCallback } from 'react'
import Taro from '@tarojs/taro'
import BListPage, { type BListItem } from '../../../components/BListPage'
import { p1CrmApi } from '../../../api/client'

export default function CrmPage() {
  const load = useCallback(async (): Promise<BListItem[]> => {
    const [contacts, reservations, handovers] = await Promise.all([
      p1CrmApi.listCrmContacts(),
      p1CrmApi.listCrmReservations(),
      p1CrmApi.listCrmHandovers()
    ])
    return [
      ...(contacts.data || []).map((item: any) => ({ id: `contact-${item.id}`, title: item.displayName || item.name || '客户', subtitle: item.phoneMasked || item.phone || '联系方式未记录', value: '客户', tone: 'accent' as const })),
      ...(reservations.data || []).map((item: any) => ({ id: `reservation-${item.id}`, title: item.title || item.customerName || '预订', subtitle: item.state || item.status || '待处理', value: '预订', tone: 'warning' as const })),
      ...(handovers.data || []).map((item: any) => ({ id: `handover-${item.id}`, title: item.title || '交付事项', subtitle: item.state || item.status || '待处理', value: '交付', tone: 'success' as const }))
    ]
  }, [])
  return <BListPage title="CRM" eyebrow="M3" load={load} onSelect={(item) => Taro.navigateTo({ url: `/packages/crm/detail/index?id=${encodeURIComponent(item.id)}` })} footer="客户、预订和交付记录" actionLabel="新增客户" actionCapability="write_crm" onAction={() => Taro.navigateTo({ url: '/packages/crm/create/index' })} />
}
