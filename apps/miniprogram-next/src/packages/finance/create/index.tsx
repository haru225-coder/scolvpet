import { Input, Picker, ScrollView, View } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useEffect, useState } from 'react'
import { Cell, FormRow, NavBar, Section, SectionList, Tag, crayon, paperGrain, metrics } from '@scolvpet/mp-ui'

import { newIdempotencyKey, p1Api } from '../../../api/client'
import { CapabilityButton } from '../../../components/CapabilityButton'
import type { ApiEnvelope } from '../../../api/types'

export default function CreateAccountingPage() {
  const [categories, setCategories] = useState<any[]>([])
  const [categoryId, setCategoryId] = useState('')
  const [title, setTitle] = useState('')
  const [amount, setAmount] = useState('')
  const [entryType, setEntryType] = useState('expense')
  const [message, setMessage] = useState('')
  const [busy, setBusy] = useState(false)
  useEffect(() => { void p1Api.listAccountingCategories({}).then((response: ApiEnvelope) => setCategories(response.data || [])).catch(() => undefined) }, [])
  async function submit() {
    const amountCents = Math.round(Number(amount) * 100)
    if (!title.trim() || !Number.isFinite(amountCents) || amountCents <= 0) { setMessage('请填写标题和正数金额（元）'); return }
    setBusy(true)
    try {
      await p1Api.createAccountingRecord({ idempotencyKey: newIdempotencyKey(), createAccountingRecordRequest: { title: title.trim(), amountCents, entryType, categoryId: categoryId || null, currency: 'CNY', occurredAt: new Date() } as any })
      Taro.showToast({ title: '收支已记录', icon: 'success' }); setTimeout(() => Taro.navigateBack(), 350)
    } catch (cause) { setMessage(cause instanceof Error ? cause.message : '保存收支失败') } finally { setBusy(false) }
  }
  const categoryLabels = categories.map((item) => `${item.name} · ${item.entryType === 'income' ? '收入' : '支出'}`)
  const categoryIndex = Math.max(0, categories.findIndex((item) => item.id === categoryId))
  const entryTypeLabels = ['支出', '收入']
  const entryTypeIndex = entryType === 'income' ? 1 : 0
  return <View style={{ height: '100vh', backgroundColor: crayon.paper, backgroundImage: paperGrain }}><NavBar title="新增收支" back right={<Tag tone="accent">财务</Tag>} /><ScrollView scrollY style={{ height: 'calc(100vh - 88px)' }}><SectionList><Section header="收支记录" footer={message || '金额按元输入，服务端按分保存'}><FormRow label="标题"><Input placeholder="例如 垫料采购" value={title} onInput={(event) => setTitle(event.detail.value)} /></FormRow><FormRow label="金额（元）" divider><Input type="digit" placeholder="0.00" value={amount} onInput={(event) => setAmount(event.detail.value)} /></FormRow><FormRow label="类型" divider><Picker mode="selector" range={entryTypeLabels} value={entryTypeIndex} onChange={(event) => setEntryType(Number(event.detail.value) === 1 ? 'income' : 'expense')}><Cell title={entryType === 'income' ? '收入' : '支出'} value={<Tag>选择</Tag>} /></Picker></FormRow>{categories.length ? <FormRow label="分类" divider><Picker mode="selector" range={categoryLabels} value={categoryIndex} onChange={(event) => setCategoryId(categories[Number(event.detail.value)]?.id || '')}><Cell title={categoryLabels[categoryIndex] || '选择分类'} value={<Tag>选择</Tag>} /></Picker></FormRow> : null}</Section><CapabilityButton capability="write_accounting" block disabled={busy} onClick={() => void submit()}>{busy ? '保存中…' : '保存收支'}</CapabilityButton><View style={{ height: `${metrics.bottomSafePadding}px` }} /></SectionList></ScrollView></View>
}
