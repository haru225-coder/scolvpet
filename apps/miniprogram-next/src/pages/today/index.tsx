import { ScrollView, View } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useCallback, useEffect, useMemo, useState } from 'react'
import {
  NavBar,
  LargeTitle,
  Section,
  SectionList,
  Cell,
  SwipeAction,
  SegmentedControl,
  Tag,
  Empty,
  ActionPanel,
  Sticker,
  crayon,
  paperGrain,
  metrics
} from '@scolvpet/mp-ui'

import { defaultApi, newIdempotencyKey } from '../../api/client'
import { canUseCapability } from '../../auth/permissions'
import { clearBreederSession, peekBreederSession, readBreederSession } from '../../auth/session'
import { readTodaySnapshot, saveTodaySnapshot } from '../../offline/snapshots'

// 服务端任务形状：只声明本页真正读到的字段，其余字段透传。
type Task = {
  id: string
  [key: string]: any
}
const FILTERS = ['全部', '待办', '已完成'] as const

// 经营入口单一真源：任务列表和空态共用，避免两处手写 Cell 漂移。
const ENTRIES: Array<{ title: string; subtitle?: string; url: string }> = [
  { title: '个体档案', subtitle: '检索、体重、健康快录', url: '/packages/animals/index/index' },
  { title: '窝次看板', url: '/packages/litters/index/index' },
  { title: '繁育计划', url: '/packages/breeding/index/index' },
  { title: '提醒与日历', url: '/packages/reminders/index/index' },
  { title: 'CRM 客户', url: '/packages/crm/index/index' },
  { title: '合同与回执', url: '/packages/contracts/index/index' },
  { title: '财务', url: '/packages/finance/index/index' },
  { title: '遗传与模拟', url: '/packages/genetic/index/index' },
  { title: '数据中心', url: '/packages/data-center/index/index' },
  { title: 'AI 助手', url: '/packages/ai/index/index' }
]

function logout() {
  clearBreederSession()
  void Taro.reLaunch({ url: '/pages/login/index' })
}

function EntrySection() {
  return (
    <Section header="经营入口" seed={1}>
      {ENTRIES.map((entry) => (
        <Cell key={entry.url} title={entry.title} subtitle={entry.subtitle} chevron onClick={() => Taro.navigateTo({ url: entry.url })} />
      ))}
    </Section>
  )
}

// 账号入口：退出时一并清掉本机离线快照，避免共用设备串号。
function AccountSection() {
  const session = peekBreederSession()
  if (!session) return null
  return (
    <Section header="账号" footer={session.organizationName || undefined}>
      <Cell
        title="退出登录"
        subtitle={session.phoneMasked || session.displayName}
        onClick={logout}
      />
    </Section>
  )
}

function stateTag(state: string) {
  if (state === 'completed') return <Tag tone="success">已完成</Tag>
  if (state === 'cancelled' || state === 'superseded') return <Tag>已关闭</Tag>
  if (state === 'snoozed') return <Tag tone="warning">已顺延</Tag>
  return <Tag>待办</Tag>
}

function taskTitle(task: Task) {
  return task.title || ({
    enclosure_cleaning: '笼舍清洁',
    medication: '用药记录',
    pup_weight_check: '幼崽体重记录',
    custom: '照护任务'
  } as Record<string, string>)[task.taskType] || '照护任务'
}

function taskTime(task: Task) {
  const date = task.scheduledAt instanceof Date ? task.scheduledAt : new Date(task.scheduledAt)
  return Number.isNaN(date.getTime()) ? '时间待定' : date.toLocaleString('zh-CN', { hour: '2-digit', minute: '2-digit' })
}

export function toast(title: string) {
  Taro.showToast({ title, icon: 'none' })
}

export default function TodayPage() {
  const [tasks, setTasks] = useState<Task[]>([])
  const [filter, setFilter] = useState(0)
  const [scrollTop, setScrollTop] = useState(0)
  const [panelFor, setPanelFor] = useState<Task | null>(null)
  const [refreshing, setRefreshing] = useState(false)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [offlineMessage, setOfflineMessage] = useState('')

  const loadTasks = useCallback(async () => {
    if (!readBreederSession()) {
      setLoading(false)
      setError('请先登录 B 端经营账号')
      return
    }
    setError('')
    setOfflineMessage('')
    try {
      const response = await defaultApi.listTasks({ limit: 100 })
      const nextTasks = response.data || []
      setTasks(nextTasks)
      saveTodaySnapshot(nextTasks)
    } catch (cause) {
      const snapshot = readTodaySnapshot()
      if (snapshot) {
        setTasks(snapshot.tasks)
        setOfflineMessage(`网络暂时不可用，展示 ${new Date(snapshot.savedAt).toLocaleString('zh-CN')} 的只读快照`)
      } else setError(cause instanceof Error ? cause.message : '今日任务加载失败')
    } finally {
      setLoading(false)
      setRefreshing(false)
    }
  }, [])

  useEffect(() => {
    void loadTasks()
  }, [loadTasks])

  const visible = useMemo(() => tasks.filter((task) => {
    if (filter === 0) return true
    if (filter === 1) return task.state !== 'completed' && task.state !== 'cancelled' && task.state !== 'superseded'
    return task.state === 'completed'
  }), [filter, tasks])

  async function complete(task: Task) {
    try {
      const subjects = (task.subjectIds || []).filter((id: string) => !(task.completedSubjectIds || []).includes(id))
      const subjectIds = subjects.length ? subjects : [task.targetId]
      const response = await defaultApi.completeTask({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: `"${task.version}"`,
        taskId: task.id,
        completeTaskRequest: {
          completedAt: new Date(),
          subjectResults: subjectIds.map((subjectId: string) => ({ subjectId, status: 'completed' }))
        } as any
      })
      setTasks((current) => current.map((item) => item.id === task.id ? response.data.task : item))
      toast('任务已完成')
    } catch (cause) {
      toast(cause instanceof Error ? cause.message : '完成任务失败')
    }
  }

  async function cancel(task: Task) {
    try {
      const response = await defaultApi.cancelTask({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: `"${task.version}"`,
        taskId: task.id,
        taskCorrectionRequest: { reason: '小程序端跳过一次' }
      })
      setTasks((current) => current.map((item) => item.id === task.id ? response.data : item))
      setPanelFor(null)
      toast('任务已跳过')
    } catch (cause) {
      toast(cause instanceof Error ? cause.message : '跳过任务失败')
    }
  }

  async function reopen(task: Task) {
    try {
      const response = await defaultApi.reopenTask({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: `"${task.version}"`,
        taskId: task.id,
        taskCorrectionRequest: { reason: '小程序端恢复待办' }
      })
      setTasks((current) => current.map((item) => item.id === task.id ? response.data : item))
      toast('任务已恢复待办')
    } catch (cause) {
      toast(cause instanceof Error ? cause.message : '恢复任务失败')
    }
  }

  return (
    <View style={{ height: '100vh', display: 'flex', flexDirection: 'column', backgroundColor: crayon.paper, backgroundImage: paperGrain }}>
      <NavBar title="今日" scrollTop={scrollTop} right={<Tag tone="accent">B 端</Tag>} />
      <ScrollView
        scrollY
        type="list"
        bounces
        enhanced
        showScrollbar={false}
        refresherEnabled
        refresherTriggered={refreshing}
        refresherBackground={crayon.paper}
        onRefresherRefresh={() => {
          if (!refreshing) {
            setRefreshing(true)
            void loadTasks()
          }
        }}
        style={{ flex: 1 }}
        onScroll={(event: { detail?: { scrollTop?: number } }) => setScrollTop(event.detail?.scrollTop || 0)}
      >
        <LargeTitle title="今日" sticker={<Sticker name="hamster" size={52} tilt={4} />} />
        <View style={{ padding: `0 ${metrics.pagePadding}px ${metrics.space16}px` }}>
          <SegmentedControl segments={[...FILTERS]} value={filter} onChange={setFilter} />
        </View>
        {loading ? <Empty title="正在读取照护队列" description="从经营账户加载今天的任务" /> : null}
        {!loading && error ? (
          <SectionList>
            <Section header="需要处理">
              <Cell title={error} subtitle="请登录后重试，或下拉刷新" onClick={() => Taro.navigateTo({ url: '/pages/login/index' })} />
            </Section>
          </SectionList>
        ) : null}
        {!loading && !error && visible.length === 0 ? (
          <Empty title={filter === 2 ? '还没有完成的任务' : '暂无今日任务'} description="任务会从后端经营数据自动进入这里" />
        ) : null}
        {!loading && !error && offlineMessage ? <SectionList><Section header="弱网提示"><Cell title={offlineMessage} subtitle="完成、跳过等写操作需要恢复网络后执行" /></Section></SectionList> : null}
        {!loading && !error && visible.length > 0 ? (
          <SectionList>
            <Section header="照护队列" footer={`共 ${visible.length} 项 · 已连接经营数据`}>
              {visible.map((task) => (
                <SwipeAction
                  key={task.id}
                  actions={canUseCapability('write_task') && (task.state === 'completed' || task.state === 'cancelled' || task.state === 'superseded')
                    ? [{ text: '恢复待办', onClick: () => void reopen(task) }]
                    : canUseCapability('write_task') ? [
                        { text: '完成', onClick: () => void complete(task) },
                        { text: '跳过', danger: true, onClick: () => setPanelFor(task) }
                      ] : []}
                >
                  <Cell
                    title={taskTitle(task)}
                    subtitle={`${taskTime(task)} · ${task.targetType || '经营对象'}`}
                    value={stateTag(task.state)}
                    chevron
                    onClick={() => toast(`任务版本 ${task.version}`)}
                  />
                </SwipeAction>
              ))}
            </Section>
            <EntrySection />
            <AccountSection />
          </SectionList>
        ) : null}
        {!loading && !error && visible.length === 0 ? (
          <SectionList>
            <EntrySection />
            <AccountSection />
          </SectionList>
        ) : null}
      </ScrollView>
      <ActionPanel
        open={panelFor != null}
        title="跳过这项任务?"
        actions={[
          { text: '跳过一次', danger: true, onClick: () => { if (panelFor) void cancel(panelFor) } },
          { text: '顺延到明天', onClick: () => { setPanelFor(null); toast('当前契约仅提供取消/重开，已保留为待办') } }
        ]}
        onClose={() => setPanelFor(null)}
      />
    </View>
  )
}
