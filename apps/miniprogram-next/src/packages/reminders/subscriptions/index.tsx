import { Input, ScrollView, View } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useState } from 'react'
import { Cell, FormRow, NavBar, Section, SectionList, Tag, crayon, paperGrain, metrics } from '@scolvpet/mp-ui'

import { defaultApi, newIdempotencyKey } from '../../../api/client'
import { readSessionStorage, writeSessionStorage } from '../../../auth/session'
import { CapabilityButton } from '../../../components/CapabilityButton'

const TEMPLATE_KEY = 'scolvpet_wechat_subscribe_template_ids'

export default function SubscriptionSettingsPage() {
  const [templateText, setTemplateText] = useState(readSessionStorage<string>(TEMPLATE_KEY) || '')
  const [message, setMessage] = useState('订阅模板由微信公众平台申请后填入；后端下发通道需同时配置。')

  function save() {
    writeSessionStorage(TEMPLATE_KEY, templateText)
    setMessage('模板 ID 已保存在本机，下一次授权会使用当前列表。')
  }

  async function requestSubscription() {
    const templateIds = templateText.split(/[,，\s]+/).map((value: string) => value.trim()).filter(Boolean)
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
      save()
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
