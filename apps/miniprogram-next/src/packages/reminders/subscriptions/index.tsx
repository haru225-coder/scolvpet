import { ScrollView, View } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useEffect, useMemo, useState } from 'react'
import { Cell, Empty, NavBar, Section, SectionList, Tag, metrics, palette } from '@scolvpet/mp-ui'

import { defaultApi, newIdempotencyKey } from '../../../api/client'
import { CapabilityButton } from '../../../components/CapabilityButton'
import { formatUserError } from '../../../api/errors'
import {
  parseTemplateIds,
  resolveSubscribeTemplateIds
} from '../../../utils/subscribe-templates'
import config from '../../../utils/config'

type TemplateStatus = 'accept' | 'reject' | 'ban' | 'unknown'

type SubscriptionRecord = {
  templateId?: string | null
  status?: TemplateStatus
}

function statusLabel(status: TemplateStatus) {
  if (status === 'accept') return '已授权'
  if (status === 'reject') return '已拒绝'
  if (status === 'ban') return '被禁止'
  return '未授权'
}

function statusTone(status: TemplateStatus): 'success' | 'danger' | 'warning' | 'accent' {
  if (status === 'accept') return 'success'
  if (status === 'reject' || status === 'ban') return 'danger'
  return 'warning'
}

function statusMap(records: SubscriptionRecord[]) {
  return records.reduce<Record<string, TemplateStatus>>((result, record) => {
    const templateId = String(record.templateId || '').trim()
    if (templateId) result[templateId] = record.status || 'unknown'
    return result
  }, {})
}

export default function SubscriptionSettingsPage() {
  const [templateIds, setTemplateIds] = useState<string[]>([])
  const [templateStatuses, setTemplateStatuses] = useState<Record<string, TemplateStatus>>({})
  const [message, setMessage] = useState('正在读取…')
  const [busy, setBusy] = useState(false)
  const [ready, setReady] = useState(false)

  useEffect(() => {
    let active = true
    void (async () => {
      try {
        const response = await defaultApi.listWechatSubscriptions()
        if (!active) return
        const records = (Array.isArray(response.data) ? response.data : []) as SubscriptionRecord[]
        const serverIds = records.map((record) => String(record.templateId || '').trim()).filter(Boolean)
        const fromConfig = parseTemplateIds(
          (config as { WECHAT_SUBSCRIBE_TEMPLATE_IDS?: string }).WECHAT_SUBSCRIBE_TEMPLATE_IDS || ''
        )
        const ids = [...new Set([...serverIds, ...fromConfig])]
        setTemplateIds(ids)
        setTemplateStatuses(statusMap(records))
        setMessage(ids.length ? '点下方向微信申请授权，授权后可收到到点提醒。' : '')
      } catch {
        if (!active) return
        // 服务端失败时仍尝试本地配置
        const ids = await resolveSubscribeTemplateIds()
        if (!active) return
        setTemplateIds(ids)
        setMessage(ids.length ? '点下方向微信申请授权。' : '')
      } finally {
        if (active) setReady(true)
      }
    })()
    return () => {
      active = false
    }
  }, [])

  const rows = useMemo(
    () =>
      templateIds.map((id, index) => ({
        id,
        title: `提醒模板 ${index + 1}`,
        status: templateStatuses[id] || 'unknown'
      })),
    [templateIds, templateStatuses]
  )

  async function syncUnknownToServer() {
    if (!templateIds.length) return
    const templates = Object.fromEntries(
      templateIds.map((templateId) => [templateId, templateStatuses[templateId] || 'unknown'])
    ) as Record<string, TemplateStatus>
    await defaultApi.upsertWechatSubscriptions({
      idempotencyKey: newIdempotencyKey(),
      upsertWechatSubscriptionsRequest: { templates }
    })
  }

  async function requestSubscription() {
    if (!templateIds.length) return
    const wxApi = (globalThis as any).wx
    const requestSubscribeMessage = wxApi?.requestSubscribeMessage || (Taro as any).requestSubscribeMessage
    if (typeof requestSubscribeMessage !== 'function') {
      setMessage('请在微信里打开后再授权')
      return
    }
    setBusy(true)
    try {
      await syncUnknownToServer()
      const result = await requestSubscribeMessage({ tmplIds: templateIds })
      const templates: Record<string, TemplateStatus> = {}
      for (const templateId of templateIds) {
        const status = String(result?.[templateId] || 'unknown').toLowerCase()
        templates[templateId] =
          status === 'accept' || status === 'reject' || status === 'ban' ? status : 'unknown'
      }
      await defaultApi.upsertWechatSubscriptions({
        idempotencyKey: newIdempotencyKey(),
        upsertWechatSubscriptionsRequest: { templates }
      })
      setTemplateStatuses(templates)
      setMessage('授权结果已同步。只有「已授权」的才会收到提醒。')
    } catch (cause) {
      setMessage(await formatUserError(cause, '授权失败，请稍后再试'))
    } finally {
      setBusy(false)
    }
  }

  // 无模板：不讲运营术语，明确功能暂不可用
  if (ready && !templateIds.length) {
    return (
      <View style={{ height: '100vh', backgroundColor: palette.systemBackground }}>
        <NavBar title="订阅消息" back />
        <Empty
          title="暂时开不了到点提醒"
          description="当前账号还没接好微信提醒，不影响你在今日页里手动处理任务"
        />
      </View>
    )
  }

  return (
    <View style={{ height: '100vh', display: 'flex', flexDirection: 'column', backgroundColor: palette.systemBackground }}>
      <NavBar title="订阅消息" back />
      <ScrollView scrollY style={{ flex: 1 }}>
        <SectionList>
          <Section header="消息提醒授权" footer={message || (ready ? '' : '正在读取…')}>
            {rows.length ? (
              rows.map((row) => (
                <Cell
                  key={row.id}
                  title={row.title}
                  subtitle="任务与业务到点提醒"
                  value={<Tag tone={statusTone(row.status)}>{statusLabel(row.status)}</Tag>}
                />
              ))
            ) : (
              <Cell title="正在读取…" />
            )}
          </Section>
          <CapabilityButton
            capability="manage_subscriptions"
            block
            disabled={busy || !templateIds.length}
            onClick={() => void requestSubscription()}
          >
            {busy ? '处理中…' : '向微信申请提醒授权'}
          </CapabilityButton>
          <Section header="说明">
            <Cell title="提醒来源" subtitle="今日任务、预约等到点事项" />
            <Cell title="怎么用" subtitle="授权后，到点会收到微信提醒" />
          </Section>
          <View style={{ height: `${metrics.bottomSafePadding}px` }} />
        </SectionList>
      </ScrollView>
    </View>
  )
}
