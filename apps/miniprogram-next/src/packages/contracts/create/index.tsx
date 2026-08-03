import { Input, Picker, ScrollView, View } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useEffect, useState } from 'react'
import { Button, Cell, FormRow, NavBar, Section, SectionList, Tag, metrics, palette } from '@scolvpet/mp-ui'

import { newIdempotencyKey, p1Api, p1CrmApi } from '../../../api/client'
import { CapabilityButton } from '../../../components/CapabilityButton'
import type { ApiEnvelope } from '../../../api/types'

function yuanToCents(text: string) {
  const n = Number(String(text || '').trim())
  if (!Number.isFinite(n) || n < 0) return null
  return Math.round(n * 100)
}

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
  const [amountYuan, setAmountYuan] = useState('')
  const [title, setTitle] = useState('')
  const [message, setMessage] = useState('正在读取模板与客户…')
  const [busy, setBusy] = useState(false)
  const [templateFailed, setTemplateFailed] = useState(false)

  function reloadTemplates() {
    setTemplateFailed(false)
    void (isReceipt ? p1Api.listReceiptTemplates() : p1Api.listContractTemplates())
      .then((response: ApiEnvelope) => {
        const next = response.data || []
        setTemplates(next)
        if (!templateId && next[0]) setTemplateId(next[0].id)
        setMessage(
          next.length
            ? '请选择模板和客户后创建'
            : '还没有模板。请先到模板管理页建一个，再回来。'
        )
      })
      .catch((cause: unknown) => {
        setTemplateFailed(true)
        setMessage(cause instanceof Error ? cause.message : '模板读取失败，请重试')
      })
  }

  useEffect(() => {
    reloadTemplates()
  }, [isReceipt])

  useEffect(() => {
    void Promise.all([
      p1CrmApi.listCrmContacts(),
      p1CrmApi.listCrmHandovers(),
      p1CrmApi.listCrmReservations()
    ])
      .then(([contactResponse, handoverResponse, reservationResponse]) => {
        const nextContacts = contactResponse.data || []
        const nextHandovers = handoverResponse.data || []
        const nextReservations = reservationResponse.data || []
        setContacts(nextContacts)
        setHandovers(nextHandovers)
        setReservations(nextReservations)
        if (!contactId && nextContacts[0]) setContactId(nextContacts[0].id)
      })
      .catch(() => {
        setMessage((prev) => (prev.includes('模板') ? prev : '客户列表暂时读不到，可先建客户再回来'))
      })
  }, [])

  async function submit() {
    if (!templates.length || !templateId) {
      setMessage(templates.length ? '请选择模板' : '请先创建模板')
      return
    }
    if (isReceipt) {
      const cents = yuanToCents(amountYuan)
      if (cents == null) {
        setMessage('请填写金额（元），例如 199.00')
        return
      }
    }
    setBusy(true)
    try {
      const cents = isReceipt ? yuanToCents(amountYuan) : null
      const request = isReceipt
        ? {
            idempotencyKey: newIdempotencyKey(),
            createReceiptRequest: {
              templateId,
              contactId: contactId || null,
              handoverId: handoverId || null,
              reservationId: reservationId || null,
              title: title.trim() || undefined,
              amountCents: cents,
              currency: 'CNY'
            }
          }
        : {
            idempotencyKey: newIdempotencyKey(),
            createContractRequest: {
              templateId,
              contactId: contactId || null,
              handoverId: handoverId || null,
              reservationId: reservationId || null,
              title: title.trim() || undefined
            }
          }
      const response = isReceipt
        ? await p1Api.createReceipt(request as any)
        : await p1Api.createContract(request as any)
      const contractId = (response.data as any)?.id
      if (contractId) {
        const issueRequest = {
          idempotencyKey: newIdempotencyKey(),
          documentId: contractId,
          ifMatch: String((response.data as any)?.version ?? 0)
        }
        if (isReceipt) await p1Api.issueReceipt(issueRequest)
        else await p1Api.issueContract(issueRequest)
      }
      Taro.showToast({ title: `${isReceipt ? '回执' : '合同'}已创建`, icon: 'success' })
      setTimeout(() => Taro.navigateBack(), 350)
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : `${isReceipt ? '回执' : '合同'}创建失败`)
    } finally {
      setBusy(false)
    }
  }

  const templateLabels = templates.map((item) => item.name || item.title || '未命名模板')
  const contactLabels = contacts.map(
    (item) => `${item.displayName || item.name || '客户'} · ${item.phoneMasked || item.phone || '无手机号'}`
  )
  const handoverLabels = handovers.map(
    (item) => `${item.contactName || item.title || '交付'} · ${item.hamsterName || '个体待定'}`
  )
  const reservationLabels = reservations.map(
    (item) => `${item.contactName || '预订'} · ${item.title || '未命名'}`
  )
  const templateIndex = Math.max(0, templates.findIndex((item) => item.id === templateId))
  const contactIndex = Math.max(0, contacts.findIndex((item) => item.id === contactId))
  const handoverIndex = Math.max(0, handovers.findIndex((item) => item.id === handoverId))
  const reservationIndex = Math.max(0, reservations.findIndex((item) => item.id === reservationId))

  return (
    <View style={{ height: '100vh', backgroundColor: palette.systemBackground }}>
      <NavBar
        title={`新增${isReceipt ? '回执' : '合同'}`}
        back
      />
      <ScrollView scrollY style={{ height: 'calc(100vh - 88px)' }}>
        <SectionList>
          <Section header={`${isReceipt ? '回执' : '合同'}信息`} footer={message}>
            {templates.length ? (
              <FormRow label="模板">
                <Picker
                  mode="selector"
                  range={templateLabels}
                  value={templateIndex}
                  onChange={(event) => setTemplateId(templates[Number(event.detail.value)]?.id || '')}
                >
                  <Cell title={templateLabels[templateIndex] || '选择模板'} value={<Tag>选择</Tag>} />
                </Picker>
              </FormRow>
            ) : (
              <FormRow label="模板">
                <Cell
                  title={templateFailed ? '模板读取失败' : '还没有模板'}
                  subtitle={templateFailed ? '点此重试' : '去模板管理页新建'}
                  chevron
                  onClick={() =>
                    templateFailed
                      ? reloadTemplates()
                      : Taro.navigateTo({ url: '/packages/contracts/templates/index' })
                  }
                />
              </FormRow>
            )}
            {contacts.length ? (
              <FormRow label="客户" divider>
                <Picker
                  mode="selector"
                  range={contactLabels}
                  value={contactIndex}
                  onChange={(event) => setContactId(contacts[Number(event.detail.value)]?.id || '')}
                >
                  <Cell title={contactLabels[contactIndex] || '选择客户'} value={<Tag>选择</Tag>} />
                </Picker>
              </FormRow>
            ) : (
              <FormRow label="客户" divider>
                <Cell
                  title="还没有客户"
                  subtitle="可选；点此去新增客户"
                  chevron
                  onClick={() => Taro.navigateTo({ url: '/packages/crm/create/index' })}
                />
              </FormRow>
            )}
            {handovers.length ? (
              <FormRow label="交付" divider>
                <Picker
                  mode="selector"
                  range={['不关联', ...handoverLabels]}
                  value={handoverId ? handoverIndex + 1 : 0}
                  onChange={(event) => {
                    const i = Number(event.detail.value)
                    setHandoverId(i === 0 ? '' : handovers[i - 1]?.id || '')
                  }}
                >
                  <Cell
                    title={handoverId ? handoverLabels[handoverIndex] || '选择交付' : '不关联'}
                    value={<Tag>选择</Tag>}
                  />
                </Picker>
              </FormRow>
            ) : null}
            {reservations.length ? (
              <FormRow label="预订" divider>
                <Picker
                  mode="selector"
                  range={['不关联', ...reservationLabels]}
                  value={reservationId ? reservationIndex + 1 : 0}
                  onChange={(event) => {
                    const i = Number(event.detail.value)
                    setReservationId(i === 0 ? '' : reservations[i - 1]?.id || '')
                  }}
                >
                  <Cell
                    title={reservationId ? reservationLabels[reservationIndex] || '选择预订' : '不关联'}
                    value={<Tag>选择</Tag>}
                  />
                </Picker>
              </FormRow>
            ) : null}
            {isReceipt ? (
              <FormRow label="金额（元）" divider>
                <Input
                  type="digit"
                  value={amountYuan}
                  placeholder="例如 199.00"
                  placeholderStyle="color: rgba(255,255,255,0.35)"
                  onInput={(event) => setAmountYuan(event.detail.value)}
                  style={{ color: '#FFFFFF' }}
                />
              </FormRow>
            ) : null}
            <FormRow label="标题" divider>
              <Input
                value={title}
                placeholder="可选"
                placeholderStyle="color: rgba(255,255,255,0.35)"
                onInput={(event) => setTitle(event.detail.value)}
                style={{ color: '#FFFFFF' }}
              />
            </FormRow>
          </Section>
          <CapabilityButton
            capability="write_documents"
            block
            disabled={busy || !templates.length}
            onClick={() => void submit()}
          >
            {busy ? '创建中…' : `创建并签发${isReceipt ? '回执' : '合同'}`}
          </CapabilityButton>
          {!isReceipt ? (
            <Button
              variant="outlined"
              block
              disabled={busy}
              onClick={() => Taro.navigateTo({ url: '/packages/contracts/create/index?kind=receipt' })}
            >
              切换为新增回执
            </Button>
          ) : (
            <Button
              variant="outlined"
              block
              disabled={busy}
              onClick={() => Taro.navigateTo({ url: '/packages/contracts/create/index' })}
            >
              切换为新增合同
            </Button>
          )}
          {!templates.length ? (
            <Button
              variant="outlined"
              block
              disabled={busy}
              onClick={() =>
                templateFailed
                  ? reloadTemplates()
                  : Taro.navigateTo({ url: '/packages/contracts/templates/index' })
              }
            >
              {templateFailed ? '重试读取模板' : '去管理模板'}
            </Button>
          ) : null}
          <View style={{ height: `${metrics.bottomSafePadding}px` }} />
        </SectionList>
      </ScrollView>
    </View>
  )
}
