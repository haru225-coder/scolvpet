import { Input, ScrollView, Text, View } from '@tarojs/components'
import Taro, { useDidShow } from '@tarojs/taro'
import { useCallback, useEffect, useMemo, useState } from 'react'
import {
  Hero,
  Section,
  SectionList,
  Cell,
  FormRow,
  Button,
  SwipeAction,
  SegmentedControl,
  Tag,
  Empty,
  metrics,
  motion,
  palette
} from '@scolvpet/mp-ui'

import { defaultApi } from '../../api/default-api'
import { newIdempotencyKey } from '../../api/runtime-config'
import { formatNetworkError, formatUserError } from '../../api/errors'
import {
  formatDevelopmentLoginError,
  getLastEnsureError,
  requireBreederSession,
  shouldAutoEnterDevelopmentSession
} from '../../auth/dev-session'
import { isOfflineDevMode, isOfflineDevSession } from '../../auth/offline-dev'
import { canUseCapability } from '../../auth/permissions'
import { peekBreederSession } from '../../auth/session'
import { readTodaySnapshot, saveTodaySnapshot } from '../../offline/snapshots'
import ProfileAvatar from '../../components/ProfileAvatar'
import { copyDiag, diag } from '../../utils/diag'
import { buildTaskCorrectionRequest } from '../../utils/record-correction'
import { taskScanSubtitle, taskTimeLabel } from '../../utils/scan-labels'
import {
  buildSubjectMap,
  collectTaskSubjectRefs,
  unwrapSubjectRecord
} from '../../utils/task-subjects'
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

async function fetchTaskSubjects(tasks: Task[]) {
  const { hamsterIds, litterIds } = collectTaskSubjectRefs(tasks)
  if (!hamsterIds.length && !litterIds.length) return {}
  const [hamsters, litters] = await Promise.all([
    Promise.all(
      hamsterIds.map((id) =>
        defaultApi.getHamster({ hamsterId: id }).then(unwrapSubjectRecord).catch(() => null)
      )
    ),
    Promise.all(
      litterIds.map((id) =>
        defaultApi.getLitter({ litterId: id }).then(unwrapSubjectRecord).catch(() => null)
      )
    )
  ])
  return buildSubjectMap(hamsters, litters)
}

export default function TodayPage() {
  const [tasks, setTasks] = useState<Task[]>([])
  /** targetId / subjectId → 仓鼠或窝次；任务 API 本身不带日龄 */
  const [subjects, setSubjects] = useState<Record<string, Record<string, unknown>>>({})
  const [filter, setFilter] = useState(0)
  const [panelFor, setPanelFor] = useState<Task | null>(null)
  const [panelKind, setPanelKind] = useState<'skip' | 'reopen'>('skip')
  const [reasonDraft, setReasonDraft] = useState('')
  const [refreshing, setRefreshing] = useState(false)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [offlineMessage, setOfflineMessage] = useState('')

  useDidShow(() => markTabActive('/pages/today/index'))

  const loadTasks = useCallback(async () => {
    setError('')
    setOfflineMessage('')
    diag(`loadTasks start api=${(config as { API_BASE?: string }).API_BASE || ''}`)

    // 统一 require：开发 mock 登录 / 生产 hydrate；失败不二次发码。
    // 401 重登见下方 force: true。
    const sess = await requireBreederSession()
    if (!sess) {
      if (shouldAutoEnterDevelopmentSession()) {
        const upgradeError =
          getLastEnsureError() || formatDevelopmentLoginError(new Error('开发自动登录失败'))
        setTasks([])
        setLoading(false)
        setRefreshing(false)
        setError(upgradeError)
        void Taro.showModal({
          title: '暂时连不上服务器',
          content: upgradeError.slice(0, 600),
          confirmText: '复制详情',
          cancelText: '关闭',
          success: (res) => {
            if (res.confirm) void copyDiag()
          }
        })
        return
      }
      setLoading(false)
      setError('请先登录经营账号')
      return
    }

    if (isOfflineDevMode() || isOfflineDevSession(peekBreederSession())) {
      setTasks([])
      setLoading(false)
      setRefreshing(false)
      setError('当前是离线会话。请到登录页重新连接服务器。')
      return
    }

    try {
      const response = await defaultApi.listTasks({ limit: 100 })
      const nextTasks = sortTasksForToday(response.data || [])
      setTasks(nextTasks)
      saveTodaySnapshot(nextTasks)
      diag(`listTasks ok count=${nextTasks.length}`)
      setSubjects(await fetchTaskSubjects(nextTasks).catch(() => ({})))
    } catch (cause) {
      const raw = cause instanceof Error ? cause.message : String(cause || '')
      const isUnauthorized =
        /\b401\b/.test(raw) ||
        /unauthorized/i.test(raw) ||
        raw.includes('未授权') ||
        raw.includes('鉴权')
      // 开发：token 失效 → force ensure 重登一次（仍单飞，不叠二次发码）
      if (isUnauthorized && shouldAutoEnterDevelopmentSession()) {
        diag(`listTasks 401 → force re-login once raw=${raw.slice(0, 120)}`)
        const again = await requireBreederSession({ force: true })
        if (again) {
          try {
            const response = await defaultApi.listTasks({ limit: 100 })
            const nextTasks = sortTasksForToday(response.data || [])
            setTasks(nextTasks)
            saveTodaySnapshot(nextTasks)
            diag(`listTasks ok after re-login count=${nextTasks.length}`)
            setSubjects(await fetchTaskSubjects(nextTasks).catch(() => ({})))
            return
          } catch (retryCause) {
            const msg = formatNetworkError(retryCause, '今日任务加载失败')
            setError(msg)
            return
          }
        }
        setError(
          getLastEnsureError() || formatDevelopmentLoginError(new Error('开发自动登录失败'))
        )
        return
      }
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
  }, [])

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
      toast(await formatUserError(cause, '完成任务失败'))
    }
  }

  function openPanel(task: Task, kind: 'skip' | 'reopen') {
    setPanelFor(task)
    setPanelKind(kind)
    setReasonDraft('')
  }

  async function cancel(task: Task) {
    try {
      const response = await defaultApi.cancelTask({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: `"${task.version}"`,
        taskId: task.id,
        taskCorrectionRequest: buildTaskCorrectionRequest(reasonDraft)
      })
      setTasks((current) => current.map((item) => item.id === task.id ? response.data : item))
      setPanelFor(null)
      setReasonDraft('')
      toast('任务已跳过')
    } catch (cause) {
      toast(
        cause instanceof Error && cause.message.includes('原因')
          ? cause.message
          : await formatUserError(cause, '跳过任务失败')
      )
    }
  }

  async function reopen(task: Task) {
    try {
      const response = await defaultApi.reopenTask({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: `"${task.version}"`,
        taskId: task.id,
        taskCorrectionRequest: buildTaskCorrectionRequest(reasonDraft)
      })
      setTasks((current) => current.map((item) => item.id === task.id ? response.data : item))
      setPanelFor(null)
      setReasonDraft('')
      toast('任务已恢复待办')
    } catch (cause) {
      toast(
        cause instanceof Error && cause.message.includes('原因')
          ? cause.message
          : await formatUserError(cause, '恢复任务失败')
      )
    }
  }

  const sessionNow = peekBreederSession()
  const isOnlineSession =
    Boolean(sessionNow) && !isOfflineDevSession(sessionNow) && !isOfflineDevMode()
  const statusLine = isOnlineSession
    ? `● 已联网 ${sessionNow?.organizationName || sessionNow?.displayName || ''}`.trim()
    : error
      ? '● 未联网（点此复制详情）'
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
        {/* 仅未联网时展示诊断条，避免主路径一打开就像工程 Demo */}
        {!isOnlineSession ? (
          <View
            hoverClass="mp-press"
            hoverStayTime={motion.press}
            style={{
              margin: `8px ${metrics.pagePadding}px 0`,
              padding: '10px 12px',
              borderRadius: '8px',
              backgroundColor: 'rgba(226,104,91,0.18)',
              border: '1px solid rgba(226,104,91,0.4)'
            }}
            onClick={() => {
              void copyDiag().then((ok) =>
                Taro.showToast({ title: ok ? '诊断已复制，发给开发' : '复制失败', icon: 'none' })
              )
            }}
          >
            <Text style={{ fontSize: '13px', fontWeight: 600, color: '#FFFFFF' }}>{statusLine}</Text>
            <Text style={{ display: 'block', marginTop: '4px', fontSize: '11px', color: 'rgba(255,255,255,0.55)' }}>
              点此复制诊断
            </Text>
          </View>
        ) : null}
        <Hero
          back
          badge={
            isOnlineSession
              ? sessionNow?.organizationName || sessionNow?.displayName || '今日'
              : isOfflineDevMode() || isOfflineDevSession(sessionNow)
                ? '离线'
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
              ? `下一件：${taskTitle(nextTask)} · ${taskTimeLabel(nextTask.scheduledAt)}`
              : isOnlineSession
                ? '没有待办时，可以去种群里试配模拟'
                : '登录后，照护安排会出现在这里'
          }
          primary={
            nextTask && canUseCapability('write_task')
              ? { text: '完成一件', onClick: () => void complete(nextTask) }
              : undefined
          }
          secondary={
            nextTask && canUseCapability('write_task')
              ? { text: '稍后', onClick: () => openPanel(nextTask, 'skip') }
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
                subtitle="确认已登录且网络可用"
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
                    ? [{ text: '恢复待办', onClick: () => openPanel(task, 'reopen') }]
                    : canUseCapability('write_task') ? [
                        { text: '完成', onClick: () => void complete(task) },
                        { text: '跳过', danger: true, onClick: () => openPanel(task, 'skip') }
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
        {panelFor ? (
          <SectionList>
            <Section header={panelKind === 'skip' ? '跳过这项任务?' : '恢复待办?'} footer="原因会写进任务审计，不能留空">
              <FormRow label="原因">
                <Input
                  placeholder={panelKind === 'skip' ? '例如：今天来不及' : '例如：记错了'}
                  placeholderStyle={`color: ${palette.tertiaryLabel}`}
                  value={reasonDraft}
                  onInput={(event) => setReasonDraft(event.detail.value)}
                  style={{ color: '#FFFFFF' }}
                />
              </FormRow>
              <View style={{ padding: `${metrics.space12}px ${metrics.pagePadding}px ${metrics.space8}px` }}>
                <Button
                  block
                  variant="filled"
                  onClick={() => {
                    if (panelKind === 'skip') void cancel(panelFor)
                    else void reopen(panelFor)
                  }}
                >
                  {panelKind === 'skip' ? '跳过一次' : '确认恢复'}
                </Button>
              </View>
              <Cell
                title="取消"
                onClick={() => {
                  setPanelFor(null)
                  setReasonDraft('')
                }}
              />
            </Section>
          </SectionList>
        ) : null}
        <View style={{ height: tabPageBottomPad() + 'px' }} />
      </ScrollView>
    </View>
  )
}
