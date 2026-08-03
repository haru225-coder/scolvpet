import { ScrollView, Text, View } from '@tarojs/components'
import Taro, { useDidShow } from '@tarojs/taro'
import { useCallback, useEffect, useMemo, useState } from 'react'
import {
  Hero,
  Section,
  SectionList,
  Cell,
  SwipeAction,
  SegmentedControl,
  Tag,
  Empty,
  ActionPanel,
  metrics,
  palette
} from '@scolvpet/mp-ui'

import { defaultApi, newIdempotencyKey } from '../../api/client'
import { formatNetworkError } from '../../api/errors'
import {
  createDevelopmentBreederSession,
  formatDevelopmentLoginError,
  shouldAutoEnterDevelopmentSession
} from '../../auth/dev-session'
import { isOfflineDevMode, isOfflineDevSession } from '../../auth/offline-dev'
import { canUseCapability } from '../../auth/permissions'
import { clearBreederSession, peekBreederSession, readBreederSession } from '../../auth/session'
import { readTodaySnapshot, saveTodaySnapshot } from '../../offline/snapshots'
import ProfileAvatar from '../../components/ProfileAvatar'
import { copyDiag, diag } from '../../utils/diag'
import { taskScanSubtitle, taskTimeLabel } from '../../utils/scan-labels'
import { markTabActive, tabPageBottomPad } from '../../utils/tab-routes'
import config from '../../utils/config'

// 服务端任务形状：只声明本页真正读到的字段，其余字段透传。
type Task = {
  id: string
  [key: string]: any
}
const FILTERS = ['全部', '待办', '已完成'] as const

// 入口不再堆在今日页：域入口由三栏（今日/种群/经营）与右上角头像承载，
// 路径映射集中在 src/utils/tab-routes.ts（旧深链一律不改）。

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

/** 从 listHamsters / listLitters 建 id → 主体，供任务行补日龄与真名 */
function buildSubjectMap(hamsters: any[], litters: any[]): Record<string, Record<string, unknown>> {
  const map: Record<string, Record<string, unknown>> = {}
  for (const item of hamsters) {
    const id = String(item?.id || '').trim()
    if (id) map[id] = item as Record<string, unknown>
  }
  for (const item of litters) {
    const id = String(item?.id || '').trim()
    if (id) map[id] = item as Record<string, unknown>
  }
  return map
}

function resolveTaskSubject(
  task: Task,
  subjects: Record<string, Record<string, unknown>>
): Record<string, unknown> | undefined {
  const ids = [
    task.targetId,
    task.target_id,
    ...(Array.isArray(task.subjectIds) ? task.subjectIds : []),
    ...(Array.isArray(task.subject_ids) ? task.subject_ids : [])
  ]
  for (const raw of ids) {
    const id = String(raw || '').trim()
    if (id && subjects[id]) return subjects[id]
  }
  return undefined
}

/** 客户端队列排序：未完成优先 → 优先级 → 计划时间。服务端排序接口到位后可替换。 */
export function sortTasksForToday(tasks: Task[]): Task[] {
  const priorityRank = (raw: unknown) => {
    const p = String(raw || 'normal').toLowerCase()
    if (p === 'urgent' || p === 'high' || p === 'critical') return 0
    if (p === 'low') return 2
    return 1
  }
  const stateRank = (raw: unknown) => {
    const s = String(raw || '')
    if (s === 'completed' || s === 'cancelled' || s === 'canceled' || s === 'superseded') return 1
    return 0
  }
  const timeMs = (raw: unknown) => {
    const date = raw instanceof Date ? raw : new Date(String(raw || ''))
    const n = date.getTime()
    return Number.isNaN(n) ? Number.MAX_SAFE_INTEGER : n
  }
  return [...tasks].sort((a, b) => {
    const byState = stateRank(a.state) - stateRank(b.state)
    if (byState !== 0) return byState
    const byPri = priorityRank(a.priority) - priorityRank(b.priority)
    if (byPri !== 0) return byPri
    const byTime = timeMs(a.scheduledAt) - timeMs(b.scheduledAt)
    if (byTime !== 0) return byTime
    return String(a.id || '').localeCompare(String(b.id || ''))
  })
}

export function toast(title: string) {
  Taro.showToast({ title, icon: 'none' })
}

export default function TodayPage() {
  const [tasks, setTasks] = useState<Task[]>([])
  /** targetId / subjectId → 仓鼠或窝次；任务 API 本身不带日龄 */
  const [subjects, setSubjects] = useState<Record<string, Record<string, unknown>>>({})
  const [filter, setFilter] = useState(0)
  const [panelFor, setPanelFor] = useState<Task | null>(null)
  const [refreshing, setRefreshing] = useState(false)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [offlineMessage, setOfflineMessage] = useState('')

  useDidShow(() => markTabActive('/pages/today/index'))

  /**
   * 开发：清掉离线假会话并连当前 API（pet.scolv.com）。
   * 失败绝不重新 enterOffline。返回 error 文案；成功返回 ''。
   */
  const tryOnlineLogin = useCallback(async (): Promise<string> => {
    if (!shouldAutoEnterDevelopmentSession()) return '开发自动登录未启用'
    try {
      if (isOfflineDevMode() || isOfflineDevSession(peekBreederSession())) {
        diag('clear sticky offline session')
        clearBreederSession()
      }
      // 开发构建：每次都强制重新登录 pet，避免半残会话
      if (peekBreederSession() && !isOfflineDevSession(peekBreederSession())) {
        // 已有真会话可复用；若想强制刷新可 clear 再登
      } else {
        clearBreederSession()
      }
      await createDevelopmentBreederSession()
      return ''
    } catch (cause) {
      const msg = formatDevelopmentLoginError(cause)
      diag(`tryOnlineLogin fail ${msg.slice(0, 200)}`)
      return msg
    }
  }, [])

  const loadTasks = useCallback(async () => {
    setError('')
    setOfflineMessage('')
    diag(`loadTasks start api=${(config as { API_BASE?: string }).API_BASE || ''}`)

    // 开发：无会话 / 离线假会话 → 必须先在线登录
    if (shouldAutoEnterDevelopmentSession()) {
      const sess = peekBreederSession()
      if (!sess || isOfflineDevMode() || isOfflineDevSession(sess)) {
        const upgradeError = await tryOnlineLogin()
        if (upgradeError) {
          setTasks([])
          setLoading(false)
          setRefreshing(false)
          setError(upgradeError)
          void Taro.showModal({
            title: '连不上 pet.scolv.com',
            content: upgradeError.slice(0, 600),
            confirmText: '复制诊断',
            cancelText: '关闭',
            success: (res) => {
              if (res.confirm) void copyDiag()
            }
          })
          return
        }
      }
    } else if (!readBreederSession()) {
      setLoading(false)
      setError('请先登录经营账号')
      return
    }

    if (isOfflineDevMode() || isOfflineDevSession(peekBreederSession())) {
      setTasks([])
      setLoading(false)
      setRefreshing(false)
      setError('当前是离线假会话。请点「连 pet.scolv.com 进入」。')
      return
    }

    try {
      const response = await defaultApi.listTasks({ limit: 100 })
      const nextTasks = sortTasksForToday(response.data || [])
      setTasks(nextTasks)
      saveTodaySnapshot(nextTasks)
      diag(`listTasks ok count=${nextTasks.length}`)
      // 任务行补目标真名 + 日龄：一次仓鼠/窝次列表即可，失败不挡主路径
      try {
        const [hamsterRes, litterRes] = await Promise.all([
          defaultApi.listHamsters({ limit: 100 }).catch(() => ({ data: [] as any[] })),
          defaultApi.listLitters({ limit: 100 }).catch(() => ({ data: [] as any[] }))
        ])
        setSubjects(buildSubjectMap(hamsterRes.data || [], litterRes.data || []))
      } catch {
        setSubjects({})
      }
    } catch (cause) {
      const snapshot = readTodaySnapshot()
      const msg = formatNetworkError(cause, '今日任务加载失败')
      diag(`listTasks fail ${msg.slice(0, 200)}`)
      if (snapshot) {
        setTasks(snapshot.tasks)
        setOfflineMessage(
          `已登录但拉任务失败，展示本地快照。${msg.slice(0, 120)}`
        )
      } else setError(msg)
    } finally {
      setLoading(false)
      setRefreshing(false)
    }
  }, [tryOnlineLogin])

  useEffect(() => {
    void loadTasks()
  }, [loadTasks])

  const visible = useMemo(() => tasks.filter((task) => {
    if (filter === 0) return true
    if (filter === 1) return task.state !== 'completed' && task.state !== 'cancelled' && task.state !== 'superseded'
    return task.state === 'completed'
  }), [filter, tasks])

  // 未完成队列（客户端排序后的第一件，仅作快捷入口，不承诺服务端优先级）。
  const openTasks = useMemo(
    () =>
      tasks.filter(
        (task) => task.state !== 'completed' && task.state !== 'cancelled' && task.state !== 'superseded'
      ),
    [tasks]
  )
  const nextTask = openTasks[0] || null
  const openCount = openTasks.length

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

  const sessionNow = peekBreederSession()
  const isOnlineSession =
    Boolean(sessionNow) && !isOfflineDevSession(sessionNow) && !isOfflineDevMode()
  const statusLine = isOnlineSession
    ? `● 已联网 ${sessionNow?.organizationName || sessionNow?.displayName || ''} · pet.scolv.com`
    : error
      ? '● 未联网（点下方复制诊断）'
      : loading
        ? '● 连接中…'
        : '● 未登录'

  return (
    <View style={{ height: '100vh', display: 'flex', flexDirection: 'column', backgroundColor: palette.systemBackground }}>
      <ScrollView
        scrollY
        type="list"
        bounces
        enhanced
        showScrollbar={false}
        refresherEnabled
        refresherTriggered={refreshing}
        refresherBackground={palette.systemBackground}
        onRefresherRefresh={() => {
          if (!refreshing) {
            setRefreshing(true)
            void loadTasks()
          }
        }}
        style={{ flex: 1 }}
      >
        {/* 真机一眼能看懂：绿=在线，红=挂了。别再跟「空列表」搞混。 */}
        <View
          style={{
            margin: `8px ${metrics.pagePadding}px 0`,
            padding: '10px 12px',
            borderRadius: '8px',
            backgroundColor: isOnlineSession ? 'rgba(107,168,120,0.2)' : 'rgba(226,104,91,0.18)',
            border: `1px solid ${isOnlineSession ? 'rgba(143,203,155,0.45)' : 'rgba(226,104,91,0.4)'}`
          }}
          onClick={() => {
            void copyDiag().then((ok) =>
              Taro.showToast({ title: ok ? '诊断已复制，发给开发' : '复制失败', icon: 'none' })
            )
          }}
        >
          <Text style={{ fontSize: '13px', fontWeight: 600, color: '#FFFFFF' }}>{statusLine}</Text>
          <Text style={{ display: 'block', marginTop: '4px', fontSize: '11px', color: 'rgba(255,255,255,0.55)' }}>
            点此复制诊断 · 空列表≠离线
          </Text>
        </View>
        <Hero
          badge={
            isOnlineSession
              ? sessionNow?.organizationName || sessionNow?.displayName || '已联网'
              : isOfflineDevMode() || isOfflineDevSession(sessionNow)
                ? '离线假会话'
                : openCount > 0
                  ? '今日待办'
                  : '今日'
          }
          title={
            openCount > 0
              ? `今天待办 ${openCount} 件`
              : '今天没有待办'
          }
          subtitle={
            nextTask
              ? `例如：${taskTitle(nextTask)} · ${taskTimeLabel(nextTask.scheduledAt)}`
              : isOnlineSession
                ? '已连 pet.scolv.com · 演示账号暂无任务（不是离线）'
                : '新的照护安排会出现在这里'
          }
          primary={
            nextTask && canUseCapability('write_task')
              ? { text: '完成一件', onClick: () => void complete(nextTask) }
              : undefined
          }
          secondary={
            nextTask && canUseCapability('write_task')
              ? { text: '稍后', onClick: () => setPanelFor(nextTask) }
              : undefined
          }
          right={<ProfileAvatar />}
        />
        <View style={{ padding: `0 ${metrics.pagePadding}px ${metrics.space16}px` }}>
          <SegmentedControl segments={[...FILTERS]} value={filter} onChange={setFilter} />
        </View>
        {loading ? <Empty title="正在读取今日照护" /> : null}
        {!loading && error ? (
          <SectionList>
            <Section header="连接失败">
              <Cell
                title={error}
                subtitle="点这里去登录页"
                chevron
                onClick={() => void Taro.navigateTo({ url: '/pages/login/index' })}
              />
              <Cell
                title="重试连接服务器"
                subtitle="合法域名须与 API 一致（当前包：https://pet.scolv.com）"
                chevron
                onClick={() => {
                  setLoading(true)
                  void loadTasks()
                }}
              />
            </Section>
          </SectionList>
        ) : null}
        {/* 主视窗已经报过空态了。只有「有任务但被当前筛选挡住」时才需要再说一次。 */}
        {!loading && !error && visible.length === 0 && tasks.length > 0 ? (
          <Empty
            title={filter === 2 ? '还没有完成的' : '这个筛选下没有内容'}
            description={filter === 2 ? '完成一件后会出现在这里' : undefined}
          />
        ) : null}
        {!loading && !error && offlineMessage ? (
          <SectionList>
            <Section header="提示">
              <Cell
                title={offlineMessage}
                subtitle="点这里重试拉任务"
                chevron
                onClick={() => {
                  setLoading(true)
                  void loadTasks()
                }}
              />
            </Section>
          </SectionList>
        ) : null}
        {!loading && !error && visible.length > 0 ? (
          <SectionList>
            <Section header="照护队列" footer={`共 ${visible.length} 项`}>
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
                    subtitle={taskScanSubtitle(task, resolveTaskSubject(task, subjects))}
                    value={stateTag(task.state)}
                  />
                </SwipeAction>
              ))}
            </Section>
          </SectionList>
        ) : null}
        <View style={{ height: tabPageBottomPad() + 'px' }} />
      </ScrollView>
      <ActionPanel
        open={panelFor != null}
        title="跳过这项任务?"
        actions={[
          { text: '跳过一次', danger: true, onClick: () => { if (panelFor) void cancel(panelFor) } }
        ]}
        onClose={() => setPanelFor(null)}
      />
    </View>
  )
}
