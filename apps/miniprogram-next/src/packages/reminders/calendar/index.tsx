import { ScrollView, View } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useEffect, useState } from 'react'
import { Button, Cell, Empty, NavBar, Section, SectionList, Tag, metrics, palette } from '@scolvpet/mp-ui'

import { defaultApi } from '../../../api/client'
import { requireBreederSession } from '../../../auth/dev-session'
import { resolveSubscribeTemplateIds } from '../../../utils/subscribe-templates'
import { humanShortLabel } from '../../../utils/tab-routes'
import { formatUserError } from '../../../api/errors'

type CalendarEntry = { id: string; dateKey: string; title: string; subtitle: string; state: string }

function dateKey(value: unknown) {
  const date = value instanceof Date ? value : new Date(String(value || ''))
  return Number.isNaN(date.getTime())
    ? '未定日期'
    : date.toLocaleDateString('zh-CN', { year: 'numeric', month: '2-digit', day: '2-digit', weekday: 'short' })
}

function timeLabel(value: unknown) {
  const date = value instanceof Date ? value : new Date(String(value || ''))
  return Number.isNaN(date.getTime())
    ? '时间待定'
    : date.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
}

export default function CalendarPage() {
  const [entries, setEntries] = useState<CalendarEntry[]>([])
  const [message, setMessage] = useState('正在聚合任务和提醒')
  const [loading, setLoading] = useState(true)
  const [showSubscribe, setShowSubscribe] = useState(false)

  useEffect(() => {
    void (async () => {
      const session = await requireBreederSession()
      if (!session) {
        setMessage('请先登录经营账号')
        setLoading(false)
        return
      }
      void resolveSubscribeTemplateIds()
        .then((ids) => setShowSubscribe(ids.length > 0))
        .catch(() => setShowSubscribe(false))
      try {
        const [tasks, reminders] = await Promise.all([
          defaultApi.listTasks({ limit: 100 }),
          defaultApi.listReminders({ limit: 100 })
        ])
        const taskEntries = (tasks.data || []).map((item: any) => ({
          id: `task-${item.id}`,
          dateKey: dateKey(item.scheduledAt),
          title: item.title || '照护任务',
          subtitle: `${timeLabel(item.scheduledAt)} · ${humanShortLabel(item.targetType || 'custom')}`,
          state: item.state || 'pending'
        }))
        const reminderEntries = (reminders.data || []).map((item: any) => ({
          id: `reminder-${item.id}`,
          dateKey: dateKey(item.scheduledAt),
          title: item.title || item.ruleName || '业务提醒',
          subtitle: `${timeLabel(item.scheduledAt)} · ${humanShortLabel(item.targetType || 'reminder')}`,
          state: item.state || 'pending'
        }))
        setEntries(
          [...taskEntries, ...reminderEntries].sort((a, b) => a.dateKey.localeCompare(b.dateKey))
        )
        setMessage('')
      } catch (cause) {
        setMessage(await formatUserError(cause, '日历加载失败'))
      } finally {
        setLoading(false)
      }
    })()
  }, [])

  const groups = entries.reduce<Record<string, CalendarEntry[]>>((result, entry) => {
    if (!result[entry.dateKey]) result[entry.dateKey] = []
    result[entry.dateKey].push(entry)
    return result
  }, {})

  return (
    <View style={{ height: '100vh', display: 'flex', flexDirection: 'column', backgroundColor: palette.systemBackground }}>
      <NavBar title="日历" back />
      <ScrollView scrollY style={{ flex: 1 }}>
        {showSubscribe ? (
          <View style={{ padding: `${metrics.space16}px ${metrics.pagePadding}px 0` }}>
            <Button
              block
              variant="outlined"
              onClick={() => Taro.navigateTo({ url: '/packages/reminders/subscriptions/index' })}
            >
              订阅消息设置
            </Button>
          </View>
        ) : null}
        {loading ? <Empty title="正在读取日历" description="聚合今日任务与业务提醒" /> : null}
        {!loading && message ? (
          <SectionList>
            <Section header="需要处理">
              <Cell title={message} />
            </Section>
          </SectionList>
        ) : null}
        {!loading && !message && !entries.length ? (
          <Empty title="暂无日历事项" description="创建照护任务后会按日期聚合显示" />
        ) : null}
        {!loading && !message
          ? Object.entries(groups).map(([day, items]) => (
              <SectionList key={day}>
                <Section header={day} footer={`共 ${items.length} 项`}>
                  {items.map((item) => (
                    <Cell
                      key={item.id}
                      title={item.title}
                      subtitle={item.subtitle}
                      value={
                        <Tag tone={item.state === 'completed' ? 'success' : 'warning'}>
                          {humanShortLabel(item.state)}
                        </Tag>
                      }
                      chevron
                      onClick={() => Taro.navigateTo({ url: '/pages/today/index' })}
                    />
                  ))}
                </Section>
              </SectionList>
            ))
          : null}
        <View style={{ height: `${metrics.bottomSafePadding}px` }} />
      </ScrollView>
    </View>
  )
}
