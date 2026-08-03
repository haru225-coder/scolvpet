import { useCallback } from 'react'
import Taro from '@tarojs/taro'
import BListPage, { type BListItem } from '../../../components/BListPage'
import { p1CrmApi } from '../../../api/client'
import { humanShortLabel } from '../../../utils/tab-routes'

export async function loadCrmListItems(): Promise<BListItem[]> {
  const [contacts, reservations, handovers] = await Promise.allSettled([
    p1CrmApi.listCrmContacts(),
    p1CrmApi.listCrmReservations(),
    p1CrmApi.listCrmHandovers()
  ])
  if (contacts.status === 'rejected' && reservations.status === 'rejected' && handovers.status === 'rejected') {
    throw new Error('客户数据读取失败，请稍后重试')
  }
  return [
    ...(contacts.status === 'fulfilled'
      ? (contacts.value.data || []).map((item: any) => {
          const phone = String(item.phoneMasked || item.phone || '').trim()
          const wechat = String(item.wechat || '').trim()
          const contact = [phone, wechat ? `微信 ${wechat}` : ''].filter(Boolean).join(' · ')
          return {
            id: `contact-${item.id}`,
            title: item.displayName || item.name || '客户',
            subtitle: contact || '联系方式未记录',
            value: phone || wechat || undefined
          }
        })
      : []),
    ...(reservations.status === 'fulfilled'
      ? (reservations.value.data || []).map((item: any) => {
          const state = humanShortLabel(item.state || item.status || 'pending')
          const who = String(item.customerName || item.contactName || '').trim()
          return {
            id: `reservation-${item.id}`,
            title: item.title || who || '预订',
            subtitle: [state, who && item.title ? who : ''].filter(Boolean).join(' · ') || state,
            value: state,
            tone: 'warning' as const
          }
        })
      : []),
    ...(handovers.status === 'fulfilled'
      ? (handovers.value.data || []).map((item: any) => {
          const state = humanShortLabel(item.state || item.status || 'pending')
          const who = String(item.customerName || item.contactName || '').trim()
          return {
            id: `handover-${item.id}`,
            title: item.title || '交付事项',
            subtitle: [state, who].filter(Boolean).join(' · ') || state,
            value: state,
            tone: 'success' as const
          }
        })
      : [])
  ]
}

export default function CrmPage() {
  const load = useCallback(loadCrmListItems, [])
  return (
    <BListPage
      title="客户"
      load={load}
      onSelect={(item) => Taro.navigateTo({ url: `/packages/crm/detail/index?id=${encodeURIComponent(item.id)}` })}
      footer="预订、交付和跟进"
      emptyTitle="还没有客户"
      emptyDescription="先记下第一位客户，预订和交付会跟在后面"
      actionLabel="新增客户"
      actionCapability="write_crm"
      onAction={() => Taro.navigateTo({ url: '/packages/crm/create/index' })}
    />
  )
}
