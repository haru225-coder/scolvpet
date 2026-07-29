import { ScrollView, View } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useEffect, useState } from 'react'
import { Button, Cell, Empty, NavBar, Section, SectionList, Tag, crayon, paperGrain, metrics } from '@scolvpet/mp-ui'

import { defaultApi } from '../../../api/client'
import { readBreederSession } from '../../../auth/session'

type CalendarEntry = { id: string; dateKey: string; title: string; subtitle: string; state: string }

function dateKey(value: unknown) {
  const date = value instanceof Date ? value : new Date(String(value || ''))
  return Number.isNaN(date.getTime()) ? '未定日期' : date.toLocaleDateString('zh-CN', { year: 'numeric', month: '2-digit', day: '2-digit', weekday: 'short' })
}

function timeLabel(value: unknown) {
  const date = value instanceof Date ? value : new Date(String(value || ''))
  return Number.isNaN(date.getTime()) ? '时间待定' : date.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
}

export default function CalendarPage() {
  const [entries, setEntries] = useState<CalendarEntry[]>([])
  const [message, setMessage] = useState('正在聚合任务和提醒')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (!readBreederSession()) { setMessage('请先登录 B 端经营账号'); setLoading(false); return }
    void Promise.all([defaultApi.listTasks({ limit: 100 }), defaultApi.listReminders({ limit: 100 })]).then(([tasks, reminders]) => {
      const taskEntries = (tasks.data || []).map((item: any) => ({ id: `task-${item.id}`, dateKey: dateKey(item.scheduledAt), title: item.title || '照护任务', subtitle: `${timeLabel(item.scheduledAt)} · ${item.targetType || 'custom'}`, state: item.state || 'pending' }))
      const reminderEntries = (reminders.data || []).map((item: any) => ({ id: `reminder-${item.id}`, dateKey: dateKey(item.scheduledAt), title: item.ruleCode || '业务提醒', subtitle: `${timeLabel(item.scheduledAt)} · ${item.targetType || '站内提醒'}`, state: item.state || 'pending' }))
      setEntries([...taskEntries, ...reminderEntries].sort((a, b) => a.dateKey.localeCompare(b.dateKey)))
      setMessage('')
    }).catch((cause) => setMessage(cause instanceof Error ? cause.message : '日历加载失败')).finally(() => setLoading(false))
  }, [])

  const groups = entries.reduce<Record<string, CalendarEntry[]>>((result, entry) => {
    if (!result[entry.dateKey]) result[entry.dateKey] = []
    result[entry.dateKey].push(entry)
    return result
  }, {})

  return <View style={{ height: '100vh', backgroundColor: crayon.paper, backgroundImage: paperGrain }}>
    <NavBar title="日历聚合" back right={<Tag tone="accent">M2</Tag>} />
    <ScrollView scrollY style={{ height: 'calc(100vh - 88px)' }}>
      <View style={{ padding: `${metrics.space16}px ${metrics.pagePadding}px 0` }}><Button block variant="outlined" onClick={() => Taro.navigateTo({ url: '/packages/reminders/subscriptions/index' })}>订阅消息设置</Button></View>
      {loading ? <Empty title="正在读取日历" description="聚合今日任务与业务提醒" /> : null}
      {!loading && message ? <SectionList><Section header="需要处理"><Cell title={message} /></Section></SectionList> : null}
      {!loading && !message && !entries.length ? <Empty title="暂无日历事项" description="创建照护任务后会按日期聚合显示" /> : null}
      {!loading && !message ? Object.entries(groups).map(([day, items]) => <SectionList key={day}><Section header={day} footer={`共 ${items.length} 项`}>
        {items.map((item) => <Cell key={item.id} title={item.title} subtitle={item.subtitle} value={<Tag tone={item.state === 'completed' ? 'success' : 'warning'}>{item.state}</Tag>} />)}
      </Section></SectionList>) : null}
      <View style={{ height: `${metrics.bottomSafePadding}px` }} />
    </ScrollView>
  </View>
}
