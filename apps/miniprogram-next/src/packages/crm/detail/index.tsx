import { Input, Picker, ScrollView, Textarea, View } from '@tarojs/components'
import Taro, { useLoad } from '@tarojs/taro'
import { useCallback, useEffect, useState } from 'react'
import { Cell, Empty, FormRow, NavBar, Section, SectionList, Tag, metrics, palette } from '@scolvpet/mp-ui'

import { defaultApi, newIdempotencyKey, p1CrmApi } from '../../../api/client'
import { CapabilityButton } from '../../../components/CapabilityButton'
import type { ApiEnvelope } from '../../../api/types'
import { humanShortLabel } from '../../../utils/tab-routes'

export function loadCrmDetail(type: string, recordId: string) {
  switch (type) {
    case 'contact': return p1CrmApi.getCrmContact({ contactId: recordId })
    case 'reservation': return p1CrmApi.getCrmReservation({ reservationId: recordId })
    case 'handover': return p1CrmApi.getCrmHandover({ handoverId: recordId })
    default: throw new Error('CRM 记录类型无效')
  }
}

export default function CrmDetailPage() {
  const [kind, setKind] = useState('')
  const [recordId, setRecordId] = useState('')
  const [record, setRecord] = useState<any>(null)
  const [hamsters, setHamsters] = useState<any[]>([])
  const [hamsterId, setHamsterId] = useState('')
  const [title, setTitle] = useState('')
  const [notes, setNotes] = useState('')
  const [message, setMessage] = useState('正在读取 CRM 记录…')
  const [busy, setBusy] = useState(false)

  const load = useCallback(async (id: string, type: string) => {
    try {
      const response = await loadCrmDetail(type, id)
      const data = response.data
      setRecord(data || null)
      setMessage(data ? 'CRM 操作会直接进入客户、预订和交付状态机' : '记录暂时不存在')
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : 'CRM 记录读取失败')
    }
  }, [])

  useLoad((options) => {
    const raw = String(options?.id || '')
    const separator = raw.indexOf('-')
    const type = separator > 0 ? raw.slice(0, separator) : String(options?.kind || '')
    const id = separator > 0 ? raw.slice(separator + 1) : raw
    setKind(type)
    setRecordId(id)
    if (id && type) void load(id, type)
    else setMessage('缺少 CRM 记录 ID')
  })

  useEffect(() => {
    if (kind !== 'contact') return
    void defaultApi.listHamsters({ limit: 100 }).then((response: ApiEnvelope) => setHamsters(response.data || [])).catch(() => undefined)
  }, [kind])

  async function createReservation() {
    if (!recordId || kind !== 'contact') return
    if (!title.trim()) { setMessage('请填写预订标题'); return }
    setBusy(true)
    try {
      await p1CrmApi.createCrmReservation({ idempotencyKey: newIdempotencyKey(), createCrmReservationRequest: { contactId: recordId, hamsterId: hamsterId.trim() || null, title: title.trim(), notes: notes.trim() || null } })
      Taro.showToast({ title: '预订已创建', icon: 'success' })
      await load(recordId, kind)
    } catch (cause) { setMessage(cause instanceof Error ? cause.message : '创建预订失败') } finally { setBusy(false) }
  }

  async function createHandover() {
    if (!recordId || kind !== 'contact') return
    setBusy(true)
    try {
      await p1CrmApi.createCrmHandover({ idempotencyKey: newIdempotencyKey(), createCrmHandoverRequest: { contactId: recordId, hamsterId: hamsterId.trim() || null, notes: notes.trim() || null, scheduledAt: new Date() } })
      Taro.showToast({ title: '交付已创建', icon: 'success' })
      await load(recordId, kind)
    } catch (cause) { setMessage(cause instanceof Error ? cause.message : '创建交付失败') } finally { setBusy(false) }
  }

  async function reservationAction(action: 'confirm' | 'cancel') {
    setBusy(true)
    try {
      if (action === 'confirm') await p1CrmApi.confirmCrmReservation({ reservationId: recordId, idempotencyKey: newIdempotencyKey() })
      else await p1CrmApi.cancelCrmReservation({ reservationId: recordId, idempotencyKey: newIdempotencyKey() })
      setMessage(action === 'confirm' ? '预订已确认' : '预订已取消')
      await load(recordId, kind)
    } catch (cause) { setMessage(cause instanceof Error ? cause.message : '预订状态更新失败') } finally { setBusy(false) }
  }

  async function completeHandover() {
    setBusy(true)
    try {
      await p1CrmApi.completeCrmHandover({ handoverId: recordId, idempotencyKey: newIdempotencyKey() })
      setMessage('交付已完成')
      await load(recordId, kind)
    } catch (cause) { setMessage(cause instanceof Error ? cause.message : '交付完成失败') } finally { setBusy(false) }
  }

  const hamsterLabels = hamsters.map((item) => `${item.name || item.internalCode || '个体'} · ${item.internalCode || item.id}`)
  const hamsterIndex = Math.max(0, hamsters.findIndex((item) => item.id === hamsterId))

  return (
    <View style={{ height: '100vh', display: 'flex', flexDirection: 'column', backgroundColor: palette.systemBackground }}>
      <NavBar title="客户详情" back />
      <ScrollView scrollY type="list" bounces enhanced showScrollbar={false} style={{ flex: 1 }}>
        {!record ? <Empty title="正在读取记录" description={message} /> : <SectionList>
          <Section header="记录" footer={message}>
            <Cell
              title={record.name || record.title || record.contactName || '客户记录'}
              subtitle={`${record.phone || record.hamsterName || record.notes || humanShortLabel(kind) || ''}`}
              value={
                <Tag tone={record.status === 'cancelled' || record.status === 'canceled' ? 'danger' : 'success'}>
                  {humanShortLabel(record.status || 'active')}
                </Tag>
              }
            />
          </Section>
          {kind === 'contact' ? <Section header="客户经营动作">
            {hamsters.length ? (
              <FormRow label="关联个体">
                <Picker mode="selector" range={hamsterLabels} value={hamsterIndex} onChange={(event) => setHamsterId(hamsters[Number(event.detail.value)]?.id || '')}>
                  <Cell title={hamsterLabels[hamsterIndex] || '选择个体'} value={<Tag>选择</Tag>} />
                </Picker>
              </FormRow>
            ) : (
              <FormRow label="关联个体">
                <Cell
                  title="还没有个体"
                  subtitle="去档案新增后可在这里选"
                  chevron
                  onClick={() => Taro.navigateTo({ url: '/packages/animals/create/index' })}
                />
              </FormRow>
            )}
            <FormRow label="标题" divider><Input value={title} placeholder="预订标题" onInput={(event) => setTitle(event.detail.value)} /></FormRow>
            <FormRow label="备注" divider><Textarea value={notes} maxlength={1000} placeholder="可选" onInput={(event) => setNotes(event.detail.value)} /></FormRow>
            <CapabilityButton capability="write_crm" block disabled={busy} onClick={() => void createReservation()}>创建预订</CapabilityButton>
            <CapabilityButton capability="write_crm" block variant="outlined" disabled={busy} onClick={() => void createHandover()}>创建交付</CapabilityButton>
          </Section> : null}
          {kind === 'reservation' ? <Section header="预订状态"><CapabilityButton capability="write_crm" block disabled={busy} onClick={() => void reservationAction('confirm')}>确认预订</CapabilityButton><CapabilityButton capability="write_crm" block variant="outlined" disabled={busy} onClick={() => void reservationAction('cancel')}>取消预订</CapabilityButton></Section> : null}
          {kind === 'handover' ? <Section header="交付状态"><CapabilityButton capability="write_crm" block disabled={busy} onClick={() => void completeHandover()}>完成交付</CapabilityButton></Section> : null}
          <View style={{ height: `${metrics.bottomSafePadding}px` }} />
        </SectionList>}
      </ScrollView>
    </View>
  )
}
