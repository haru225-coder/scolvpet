import { useCallback } from 'react'
import Taro from '@tarojs/taro'
import BListPage, { type BListItem } from '../../../components/BListPage'
import { defaultApi } from '../../../api/client'
import { shortDate } from '../../../utils/scan-labels'
import { humanShortLabel } from '../../../utils/tab-routes'

function dueLabel(raw: unknown): string | undefined {
  if (raw == null || raw === '') return undefined
  const d = raw instanceof Date ? raw : new Date(String(raw))
  if (Number.isNaN(d.getTime())) return undefined
  const day = shortDate(d)
  const hh = String(d.getHours()).padStart(2, '0')
  const mm = String(d.getMinutes()).padStart(2, '0')
  // 午夜整点只显示日期
  if (hh === '00' && mm === '00') return day
  return day ? `${day} ${hh}:${mm}` : undefined
}

export default function RemindersPage() {
  const load = useCallback(async (): Promise<BListItem[]> => {
    const response = await defaultApi.listReminders({ limit: 100 })
    return (response.data || []).map((item: any) => {
      const state = humanShortLabel(item.state || 'pending') || String(item.state || '')
      const when = dueLabel(item.nextDueAt || item.scheduledAt || item.next_due_at || item.scheduled_at)
      return {
        id: item.id,
        title: item.title || item.ruleName || '照护提醒',
        subtitle: [when, item.targetType || item.target_type ? humanShortLabel(item.targetType || item.target_type) : '']
          .filter(Boolean)
          .join(' · ') || state,
        value: state,
        tone: item.state === 'completed' ? ('success' as const) : ('warning' as const)
      }
    })
  }, [])
  return (
    <BListPage
      title="提醒与日历"
      load={load}
      footer="到点会进今日照护"
      emptyTitle="还没有提醒"
      emptyDescription="建一条照护提醒，到点会出现在今日"
      actionLabel="新增照护提醒"
      actionCapability="write_task"
      onAction={() => Taro.navigateTo({ url: '/packages/reminders/create/index' })}
      secondaryActionLabel="打开日历"
      onSecondaryAction={() => Taro.navigateTo({ url: '/packages/reminders/calendar/index' })}
    />
  )
}
