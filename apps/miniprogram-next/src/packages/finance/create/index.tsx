import { Input, Picker, ScrollView, View } from '@tarojs/components'
import Taro, { useLoad } from '@tarojs/taro'
import { useEffect, useRef, useState } from 'react'
import { Cell, FormRow, NavBar, Section, SectionList, Tag, metrics, palette } from '@scolvpet/mp-ui'

import { p1Api } from '../../../api/client'
import { createIdempotencyIntent } from '../../../api/idempotency'
import { CapabilityButton } from '../../../components/CapabilityButton'
import type { ApiEnvelope } from '../../../api/types'
import { formatUserError } from '../../../api/errors'
import { buildReversalDraft } from '../../../utils/finance-reversal'

type AccountingCategoryLike = { id?: string; name?: string; entryType?: string }

export function filterCategoriesForEntryType(categories: AccountingCategoryLike[], entryType: string) {
  return categories.filter((category) => category.entryType === entryType)
}

export default function CreateAccountingPage() {
  const [categories, setCategories] = useState<any[]>([])
  const [categoryId, setCategoryId] = useState('')
  const [title, setTitle] = useState('')
  const [amount, setAmount] = useState('')
  const [entryType, setEntryType] = useState('expense')
  const [message, setMessage] = useState('')
  const [busy, setBusy] = useState(false)
  const [reversalNotes, setReversalNotes] = useState('')
  const createIntent = useRef(createIdempotencyIntent()).current
  useEffect(() => { void p1Api.listAccountingCategories({}).then((response: ApiEnvelope) => setCategories(response.data || [])).catch(() => undefined) }, [])
  useLoad((query) => {
    if (String(query?.reverse || '') !== '1') return
    try {
      const draft = buildReversalDraft({
        id: String(query?.id || ''),
        title: decodeURIComponent(String(query?.title || '')),
        amountCents: Number(query?.amountCents),
        entryType: String(query?.entryType || 'expense')
      })
      setTitle(draft.title)
      setAmount(draft.amount)
      setEntryType(draft.entryType)
      setReversalNotes(draft.notes)
      setMessage('这是反向冲销。核对金额后保存，会新记一笔，原记录不动')
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : '冲销草稿无效')
    }
  })
  async function submit() {
    const amountCents = Math.round(Number(amount) * 100)
    if (!title.trim() || !Number.isFinite(amountCents) || amountCents <= 0) { setMessage('请填写标题和正数金额（元）'); return }
    setBusy(true)
    try {
      await p1Api.createAccountingRecord({ idempotencyKey: createIntent.getKey(), createAccountingRecordRequest: { title: title.trim(), amountCents, entryType, categoryId: categoryId || null, currency: 'CNY', occurredAt: new Date(), notes: reversalNotes || null } as any })
      createIntent.complete()
      Taro.showToast({ title: '收支已记录', icon: 'success' }); setTimeout(() => Taro.navigateBack(), 350)
    } catch (cause) { setMessage(await formatUserError(cause, '保存收支失败')) } finally { setBusy(false) }
  }
  const visibleCategories = filterCategoriesForEntryType(categories, entryType)
  const categoryLabels = visibleCategories.map((item) => `${item.name} · ${item.entryType === 'income' ? '收入' : '支出'}`)
  const categoryIndex = Math.max(0, visibleCategories.findIndex((item) => item.id === categoryId))
  const entryTypeLabels = ['支出', '收入']
  const entryTypeIndex = entryType === 'income' ? 1 : 0
  return <View style={{ height: '100vh', display: 'flex', flexDirection: 'column', backgroundColor: palette.systemBackground }}><NavBar title="新增收支" back /><ScrollView scrollY style={{ flex: 1 }}><SectionList><Section header="收支记录" footer={message || '金额按元输入，服务端按分保存'}><FormRow label="标题"><Input placeholder="例如 垫料采购" value={title} onInput={(event) => setTitle(event.detail.value)} /></FormRow><FormRow label="金额（元）" divider><Input type="digit" placeholder="0.00" value={amount} onInput={(event) => setAmount(event.detail.value)} /></FormRow><FormRow label="类型" divider><Picker mode="selector" range={entryTypeLabels} value={entryTypeIndex} onChange={(event) => { setEntryType(Number(event.detail.value) === 1 ? 'income' : 'expense'); setCategoryId('') }}><Cell title={entryType === 'income' ? '收入' : '支出'} value={<Tag>选择</Tag>} /></Picker></FormRow>{visibleCategories.length ? <FormRow label="分类" divider><Picker mode="selector" range={categoryLabels} value={categoryIndex} onChange={(event) => setCategoryId(visibleCategories[Number(event.detail.value)]?.id || '')}><Cell title={categoryLabels[categoryIndex] || '选择分类'} value={<Tag>选择</Tag>} /></Picker></FormRow> : null}</Section><CapabilityButton capability="write_accounting" block disabled={busy} onClick={() => void submit()}>{busy ? '保存中…' : '保存收支'}</CapabilityButton><View style={{ height: `${metrics.bottomSafePadding}px` }} /></SectionList></ScrollView></View>
}
