import { useCallback } from 'react'
import Taro from '@tarojs/taro'
import BListPage, { type BListItem } from '../../../components/BListPage'
import { defaultApi } from '../../../api/client'

export default function RemindersPage() {
  const load = useCallback(async (): Promise<BListItem[]> => {
    const response = await defaultApi.listReminders({ limit: 100 })
    return (response.data || []).map((item: any) => ({ id: item.id, title: item.title || item.ruleCode || '提醒', subtitle: `${item.state || 'pending'} · ${item.nextDueAt || item.scheduledAt || ''}`, value: item.state || '待处理', tone: item.state === 'completed' ? 'success' as const : 'warning' as const }))
  }, [])
  return <BListPage title="提醒与日历" eyebrow="M2" load={load} footer="提醒列表是小程序订阅消息设置的业务来源" actionLabel="新增照护提醒" actionCapability="write_task" onAction={() => Taro.navigateTo({ url: '/packages/reminders/create/index' })} secondaryActionLabel="打开日历" onSecondaryAction={() => Taro.navigateTo({ url: '/packages/reminders/calendar/index' })} />
}
