import { Input, ScrollView, View } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useEffect, useState } from 'react'
import { Cell, FormRow, NavBar, Section, SectionList, Tag, crayon, paperGrain, metrics } from '@scolvpet/mp-ui'

import { defaultApi, newIdempotencyKey } from '../../../api/client'
import { CapabilityButton } from '../../../components/CapabilityButton'

type TemplateStatus = 'accept' | 'reject' | 'ban' | 'unknown'

type SubscriptionRecord = {
  templateId?: string | null
  status?: TemplateStatus
}

function parseTemplateIds(value: string) {
  return [...new Set(value.split(/[,，\s]+/).map((item) => item.trim()).filter(Boolean))]
}

function statusMap(records: SubscriptionRecord[]) {
  return records.reduce<Record<string, TemplateStatus>>((result, record) => {
    const templateId = String(record.templateId || '').trim()
    if (templateId) result[templateId] = record.status || 'unknown'
    return result
  }, {})
}

export default function SubscriptionSettingsPage() {
  const [templateText, setTemplateText] = useState('')
  const [templateStatuses, setTemplateStatuses] = useState<Record<string, TemplateStatus>>({})
  const [message, setMessage] = useState('订阅模板由微信公众平台申请后填入；后端下发通道需同时配置。')

  useEffect(() => {
    let active = true
    void defaultApi.listWechatSubscriptions().then((response) => {
      if (!active) return
      const records = (Array.isArray(response.data) ? response.data : []) as SubscriptionRecord[]
      setTemplateText(records.map((record) => String(record.templateId || '').trim()).filter(Boolean).join(','))
      setTemplateStatuses(statusMap(records))
      setMessage(records.length ? '已从服务端读取当前微信订阅模板。' : '服务端尚未配置微信订阅模板。')
    }).catch((cause) => {
      if (active) setMessage(cause instanceof Error ? cause.message : '读取服务端订阅模板失败')
    })
    return () => { active = false }
  }, [])

  async function save() {
    const templateIds = parseTemplateIds(templateText)
    if (!templateIds.length) { setMessage('请先填写至少一个微信订阅消息模板 ID'); return }
    try {
      const templates = Object.fromEntries(templateIds.map((templateId) => [templateId, templateStatuses[templateId] || 'unknown'])) as Record<string, TemplateStatus>
      const response = await defaultApi.upsertWechatSubscriptions({
        idempotencyKey: newIdempotencyKey(),
        upsertWechatSubscriptionsRequest: { templates }
      })
      setTemplateStatuses(statusMap((response.data || []) as SubscriptionRecord[]))
      setTemplateText(templateIds.join(','))
      setMessage('模板列表已保存到服务端；请求微信授权后会更新具体状态。')
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : '保存服务端订阅模板失败')
    }
  }

  async function requestSubscription() {
    const templateIds = parseTemplateIds(templateText)
    if (!templateIds.length) { setMessage('请先填写至少一个微信订阅消息模板 ID'); return }
    const wxApi = (globalThis as any).wx
    const requestSubscribeMessage = wxApi?.requestSubscribeMessage || (Taro as any).requestSubscribeMessage
    if (typeof requestSubscribeMessage !== 'function') { setMessage('当前运行环境没有订阅消息能力，请在微信开发者工具或真机中操作'); return }
    try {
      const result = await requestSubscribeMessage({ tmplIds: templateIds })
      const templates: Record<string, 'accept' | 'reject' | 'ban' | 'unknown'> = {}
      for (const templateId of templateIds) {
        const status = String(result?.[templateId] || 'unknown').toLowerCase()
        templates[templateId] = status === 'accept' || status === 'reject' || status === 'ban' ? status : 'unknown'
      }
      await defaultApi.upsertWechatSubscriptions({
        idempotencyKey: newIdempotencyKey(),
        upsertWechatSubscriptionsRequest: { templates }
      })
      setTemplateStatuses(templates)
      setMessage('微信授权结果已同步服务端；只有 accept 模板会接收任务与业务提醒。')
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : '订阅消息授权或同步失败')
    }
  }

  return <View style={{ height: '100vh', backgroundColor: crayon.paper, backgroundImage: paperGrain }}>
    <NavBar title="订阅消息设置" back right={<Tag tone="accent">M2</Tag>} />
    <ScrollView scrollY style={{ height: 'calc(100vh - 88px)' }}><SectionList>
      <Section header="微信订阅模板" footer={message}>
        <FormRow label="模板 ID（逗号分隔）"><Input value={templateText} placeholder="从微信公众平台复制 tmpl_xxx" onInput={(event) => setTemplateText(event.detail.value)} /></FormRow>
        <CapabilityButton capability="manage_subscriptions" block variant="outlined" onClick={save}>保存模板列表</CapabilityButton>
        <CapabilityButton capability="manage_subscriptions" block disabled={!templateText.trim()} onClick={() => void requestSubscription()}>请求微信订阅授权</CapabilityButton>
      </Section>
      <Section header="当前边界"><Cell title="提醒来源" subtitle="今日任务与业务提醒" /><Cell title="投递状态" subtitle="由服务端订阅消息通道和模板配置决定" /></Section>
      <View style={{ height: `${metrics.bottomSafePadding}px` }} />
    </SectionList></ScrollView>
  </View>
}
