import { Input, Picker, ScrollView, View } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useEffect, useState } from 'react'
import { Button, Cell, FormRow, NavBar, Section, SectionList, Tag, crayon, paperGrain, metrics } from '@scolvpet/mp-ui'

import { newIdempotencyKey, p1Api, p1CrmApi } from '../../../api/client'
import { CapabilityButton } from '../../../components/CapabilityButton'
import type { ApiEnvelope } from '../../../api/types'

export default function CreateContractPage() {
  const routeKind = Taro.getCurrentInstance().router?.params?.kind
  const isReceipt = routeKind === 'receipt'
  const [templateId, setTemplateId] = useState('')
  const [templates, setTemplates] = useState<any[]>([])
  const [contacts, setContacts] = useState<any[]>([])
  const [handovers, setHandovers] = useState<any[]>([])
  const [reservations, setReservations] = useState<any[]>([])
  const [contactId, setContactId] = useState('')
  const [handoverId, setHandoverId] = useState('')
  const [reservationId, setReservationId] = useState('')
  const [amountCents, setAmountCents] = useState('')
  const [title, setTitle] = useState('')
  const [message, setMessage] = useState(`${isReceipt ? '回执' : '合同'}模板 ID 来自服务端模板列表`)
  const [busy, setBusy] = useState(false)

  useEffect(() => {
    void (isReceipt ? p1Api.listReceiptTemplates() : p1Api.listContractTemplates()).then((response: ApiEnvelope) => {
      const next = response.data || []
      setTemplates(next)
      if (!templateId && next[0]) setTemplateId(next[0].id)
      setMessage(next.length ? '模板已从服务端载入，可直接选择' : '暂无模板，请先到模板管理页创建')
    }).catch((cause: unknown) => setMessage(cause instanceof Error ? cause.message : '模板读取失败'))
  }, [isReceipt])

  useEffect(() => {
    void Promise.all([
      p1CrmApi.listCrmContacts(),
      p1CrmApi.listCrmHandovers(),
      p1CrmApi.listCrmReservations()
    ]).then(([contactResponse, handoverResponse, reservationResponse]) => {
      setContacts(contactResponse.data || [])
      setHandovers(handoverResponse.data || [])
      setReservations(reservationResponse.data || [])
    }).catch(() => undefined)
  }, [])

  async function submit() {
    if (!templateId.trim()) { setMessage('请填写合同模板 ID'); return }
    if (isReceipt && (!amountCents.trim() || Number(amountCents) < 0)) { setMessage('回执需要填写金额（分）'); return }
    setBusy(true)
    try {
      const request = isReceipt
        ? { idempotencyKey: newIdempotencyKey(), createReceiptRequest: { templateId: templateId.trim(), contactId: contactId.trim() || null, handoverId: handoverId.trim() || null, reservationId: reservationId.trim() || null, title: title.trim() || undefined, amountCents: Number(amountCents), currency: 'CNY' } }
        : { idempotencyKey: newIdempotencyKey(), createContractRequest: { templateId: templateId.trim(), contactId: contactId.trim() || null, handoverId: handoverId.trim() || null, reservationId: reservationId.trim() || null, title: title.trim() || undefined } }
      const response = isReceipt ? await p1Api.createReceipt(request as any) : await p1Api.createContract(request as any)
      const contractId = (response.data as any)?.id
      if (contractId) {
        const issueRequest = { idempotencyKey: newIdempotencyKey(), documentId: contractId, ifMatch: String((response.data as any)?.version ?? 0) }
        if (isReceipt) await p1Api.issueReceipt(issueRequest)
        else await p1Api.issueContract(issueRequest)
      }
      Taro.showToast({ title: `${isReceipt ? '回执' : '合同'}已创建`, icon: 'success' }); setTimeout(() => Taro.navigateBack(), 350)
    } catch (cause) { setMessage(cause instanceof Error ? cause.message : `${isReceipt ? '回执' : '合同'}创建失败`) } finally { setBusy(false) }
  }

  const templateLabels = templates.map((item) => item.name || item.id)
  const contactLabels = contacts.map((item) => `${item.name || '客户'} · ${item.phone || item.id}`)
  const handoverLabels = handovers.map((item) => `${item.contactName || '交付'} · ${item.hamsterName || item.id}`)
  const reservationLabels = reservations.map((item) => `${item.contactName || '预订'} · ${item.title || item.id}`)
  const templateIndex = Math.max(0, templates.findIndex((item) => item.id === templateId))
  const contactIndex = Math.max(0, contacts.findIndex((item) => item.id === contactId))
  const handoverIndex = Math.max(0, handovers.findIndex((item) => item.id === handoverId))
  const reservationIndex = Math.max(0, reservations.findIndex((item) => item.id === reservationId))

  return (
    <View style={{ height: '100vh', backgroundColor: crayon.paper, backgroundImage: paperGrain }}>
      <NavBar title={`新增${isReceipt ? '回执' : '合同'}`} back right={<Tag tone="accent">{isReceipt ? '回执' : '合同'}</Tag>} />
      <ScrollView scrollY style={{ height: 'calc(100vh - 88px)' }}>
        <SectionList>
          <Section header={`${isReceipt ? '回执' : '合同'}信息`} footer={message}>
            {templates.length ? <FormRow label="模板"><Picker mode="selector" range={templateLabels} value={templateIndex} onChange={(event) => setTemplateId(templates[Number(event.detail.value)]?.id || '')}><Cell title={templateLabels[templateIndex] || '选择模板'} value={<Tag tone="accent">选择</Tag>} /></Picker></FormRow> : <FormRow label="模板 ID"><Input value={templateId} placeholder="到模板管理页创建后复制" onInput={(event) => setTemplateId(event.detail.value)} /></FormRow>}
            {contacts.length ? <FormRow label="客户"><Picker mode="selector" range={contactLabels} value={contactIndex} onChange={(event) => setContactId(contacts[Number(event.detail.value)]?.id || '')}><Cell title={contactLabels[contactIndex] || '选择客户'} value={<Tag>选择</Tag>} /></Picker></FormRow> : <FormRow label="客户 ID"><Input value={contactId} placeholder="可选" onInput={(event) => setContactId(event.detail.value)} /></FormRow>}
            {handovers.length ? <FormRow label="交付"><Picker mode="selector" range={handoverLabels} value={handoverIndex} onChange={(event) => setHandoverId(handovers[Number(event.detail.value)]?.id || '')}><Cell title={handoverLabels[handoverIndex] || '选择交付'} value={<Tag>选择</Tag>} /></Picker></FormRow> : <FormRow label="交付 ID"><Input value={handoverId} placeholder="可选" onInput={(event) => setHandoverId(event.detail.value)} /></FormRow>}
            {reservations.length ? <FormRow label="预订"><Picker mode="selector" range={reservationLabels} value={reservationIndex} onChange={(event) => setReservationId(reservations[Number(event.detail.value)]?.id || '')}><Cell title={reservationLabels[reservationIndex] || '选择预订'} value={<Tag>选择</Tag>} /></Picker></FormRow> : <FormRow label="预订 ID"><Input value={reservationId} placeholder="可选" onInput={(event) => setReservationId(event.detail.value)} /></FormRow>}
            {isReceipt ? <FormRow label="金额（分）" divider><Input type="number" value={amountCents} placeholder="例如 19900" onInput={(event) => setAmountCents(event.detail.value)} /></FormRow> : null}
            <FormRow label="标题" divider><Input value={title} placeholder="可选" onInput={(event) => setTitle(event.detail.value)} /></FormRow>
          </Section>
          <CapabilityButton capability="write_documents" block disabled={busy} onClick={() => void submit()}>{busy ? '创建中…' : `创建并签发${isReceipt ? '回执' : '合同'}`}</CapabilityButton>
          {!isReceipt ? <Button variant="text" block disabled={busy} onClick={() => Taro.navigateTo({ url: '/packages/contracts/create/index?kind=receipt' })}>切换为新增回执</Button> : <Button variant="text" block disabled={busy} onClick={() => Taro.navigateTo({ url: '/packages/contracts/create/index' })}>切换为新增合同</Button>}
          <View style={{ height: `${metrics.bottomSafePadding}px` }} />
        </SectionList>
      </ScrollView>
    </View>
  )
}
