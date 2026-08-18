import { Input, ScrollView, Text, View } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useEffect, useState } from 'react'
import { Button, Cell, Empty, FormRow, LargeTitle, NavBar, Section, SectionList, Tag, metrics, palette } from '@scolvpet/mp-ui'

import { newIdempotencyKey, p2Api } from '../../../api/client'
import { requireBreederSession } from '../../../auth/dev-session'
import type { ApiEnvelope } from '../../../api/types'
import { humanShortLabel, openPage } from '../../../utils/tab-routes'
import { formatUserError } from '../../../api/errors'

type Turn = { role: 'user' | 'assistant'; text: string; facts?: string[]; actions?: any[] }
const PRESETS = [
  '现在有多少只在养？',
  '有没有逾期任务？',
  '最近客户预订怎么样？',
  '本月收支摘要？',
  '最近有哪些窝次？',
  '你能做什么？',
]

export default function AssistantPage() {
  const [question, setQuestion] = useState('')
  const [turns, setTurns] = useState<Turn[]>([])
  const [sessionId, setSessionId] = useState<string | undefined>()
  const [capabilities, setCapabilities] = useState<any>(null)
  const [busy, setBusy] = useState(false)
  const [message, setMessage] = useState('')
  /** NavBar 折叠滚动进度 */
  const [scrollTop, setScrollTop] = useState(0)

  useEffect(() => {
    void (async () => {
      const session = await requireBreederSession()
      if (!session) {
        setMessage('请先登录经营账号')
        return
      }
      try {
        const response = await p2Api.assistantCapabilities()
        setCapabilities((response as ApiEnvelope).data)
      } catch (cause: unknown) {
        setMessage(await formatUserError(cause, '助手能力加载失败'))
      }
    })()
  }, [])

  async function ask(input?: string) {
    const text = (input ?? question).trim()
    if (!text || busy) return
    setBusy(true)
    setMessage('')
    setTurns((current) => [...current, { role: 'user', text }])
    setQuestion('')
    try {
      const response = await p2Api.chatAssistant({
        idempotencyKey: newIdempotencyKey(),
        assistantChatRequest: { message: text, sessionId, preferLlm: Boolean(capabilities?.llmAvailable) }
      })
      const data = response.data
      setSessionId(data.sessionId)
      setTurns((current) => [...current, { role: 'assistant', text: data.answer, facts: (data.facts || []).map((fact: any) => `${fact.label}: ${fact.value}`), actions: data.actions || [] }])
    } catch (cause) {
      setMessage(await formatUserError(cause, '助手响应失败'))
    } finally {
      setBusy(false)
    }
  }

  async function resolveAction(action: any, confirm: boolean) {
    // 本地草稿动作（如 task_draft）不走服务端确认：它们跳转到新建表单处理，
    // 不应出现确认/取消按钮；若仍被触发（数据异常），给中性提示而非报错。
    if (!action.actionId) {
      setMessage('该操作已在本地处理，请直接在卡片上继续')
      return
    }
    setBusy(true)
    try {
      if (confirm) await p2Api.confirmAssistantAction({ actionId: action.actionId, idempotencyKey: newIdempotencyKey() })
      else await p2Api.cancelAssistantAction({ actionId: action.actionId, idempotencyKey: newIdempotencyKey() })
      setTurns((current) => current.map((turn) => ({ ...turn, actions: turn.actions?.map((item) => item.actionId === action.actionId ? { ...item, status: confirm ? 'executed' : 'cancelled' } : item) })))
    } catch (cause) {
      setMessage(await formatUserError(cause, '助手动作处理失败'))
    } finally {
      setBusy(false)
    }
  }

  function clearConversation() {
    setTurns([])
    setSessionId(undefined)
    setMessage('对话已清空')
  }

  function openAction(action: any) {
    const type = String(action?.type || '')
    const id = action?.payload?.hamster_id || action?.payload?.hamsterId
    if (type === 'open_hamster' && id) Taro.navigateTo({ url: `/packages/animals/detail/index?id=${encodeURIComponent(id)}` })
    else if (type === 'task_draft') {
      const payload = action?.payload || {}
      const query = Object.entries({
        title: String(payload.title || action.label || ''),
        targetType: String(payload.target_type || ''),
        targetId: String(payload.target_id || ''),
        taskType: String(payload.task_type || 'custom'),
        priority: String(payload.priority || 'normal'),
        notes: String(payload.notes || ''),
        scheduledAt: String(payload.scheduled_at || '')
      }).map(([key, value]) => `${key}=${encodeURIComponent(value)}`).join('&')
      Taro.navigateTo({ url: `/packages/reminders/create/index?${query}` })
    }
    else if (type === 'open_tasks' || type === 'open_data_center') {
      openPage(type === 'open_tasks' ? '/pages/today/index' : '/packages/data-center/index/index')
    }
  }

  return (
    <View style={{ height: '100vh', display: 'flex', flexDirection: 'column', backgroundColor: palette.systemBackground }}>
      <NavBar title="AI 助手" back scrollTop={scrollTop} />
      <ScrollView
        scrollY
        type="list"
        bounces
        enhanced
        showScrollbar={false}
        style={{ flex: 1 }}
        onScroll={(event) => setScrollTop(event.detail?.scrollTop || 0)}
      >
        <LargeTitle title="AI 助手" />
        {capabilities ? <SectionList><Section header="当前能力" footer={capabilities.disclaimer}><Cell title={capabilities.llmAvailable ? '规则 + AI' : '规则助手'} subtitle={`${(capabilities.intents || []).join(' · ')}`} value={<Tag tone="success">在线</Tag>} /></Section></SectionList> : null}
        {!capabilities && message ? <Empty title={message} description="登录后可使用经营问答" /> : null}
        <SectionList>
          <Section header="快捷问题">
            {PRESETS.map((preset) => <Cell key={preset} title={preset} chevron onClick={() => void ask(preset)} />)}
            {turns.length ? <Button block variant="outlined" disabled={busy} onClick={clearConversation}>清空当前对话</Button> : null}
          </Section>
          <Section header="对话">
            {turns.length === 0 ? <Cell title="例如：今天有哪些逾期照护任务？" subtitle="助手只读取当前经营账号的数据" /> : turns.map((turn, index) => <View key={`${turn.role}-${index}`} style={{ padding: '12px 16px' }}><Text style={{ fontWeight: '600' }}>{turn.role === 'user' ? '我' : '熊舍助手'}</Text><Text style={{ display: 'block', paddingTop: '6px' }}>{turn.text}</Text>{turn.facts?.map((fact) => <Text key={fact} style={{ display: 'block', paddingTop: '4px', color: 'rgba(255,255,255,0.55)' }}>{fact}</Text>)}{turn.actions?.map((action) => <View key={action.actionId || action.label} style={{ paddingTop: '10px' }}><Cell title={action.label} subtitle={action.summary} value={<Tag tone={action.status === 'executed' ? 'success' : action.status === 'cancelled' ? 'danger' : 'warning'}>{action.status ? humanShortLabel(action.status) : (action.requiresConfirmation ? '待确认' : '建议')}</Tag>} onClick={() => openAction(action)} />{action.requiresConfirmation && action.actionId && !action.status ? <View style={{ display: 'flex', gap: '12px', paddingTop: '8px' }}><Button variant="outlined" disabled={busy} onClick={() => void resolveAction(action, true)}>确认执行</Button><Button variant="text" disabled={busy} onClick={() => void resolveAction(action, false)}>取消</Button></View> : null}</View>)}</View>)}
          </Section>
          <Section header="提问">
            <FormRow label="问题"><Input value={question} placeholder="输入经营问题" onInput={(event) => setQuestion(event.detail.value)} onConfirm={() => void ask()} /></FormRow>
            <Button block disabled={busy || !question.trim()} onClick={() => void ask()}>{busy ? '思考中…' : '发送'}</Button>
          </Section>
        </SectionList>
        {message ? <Text style={{ display: 'block', padding: `0 ${metrics.pagePadding}px ${metrics.space16}px` }}>{message}</Text> : null}
      </ScrollView>
    </View>
  )
}
