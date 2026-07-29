import { Input, Picker, ScrollView, View } from '@tarojs/components'
import { useEffect, useState } from 'react'
import { Button, Cell, FormRow, NavBar, Section, SectionList, Tag, crayon, paperGrain, metrics } from '@scolvpet/mp-ui'

import { newIdempotencyKey, p1Api } from '../../../api/client'
import { CapabilityButton } from '../../../components/CapabilityButton'

export default function AccountingCategoriesPage() {
  const [categories, setCategories] = useState<any[]>([])
  const [name, setName] = useState('')
  const [entryType, setEntryType] = useState('expense')
  const [message, setMessage] = useState('正在读取记账分类…')
  const [busy, setBusy] = useState(false)

  async function load() {
    setBusy(true)
    try { const response = await p1Api.listAccountingCategories({}); setCategories(response.data || []); setMessage(`已读取 ${response.data?.length || 0} 个分类`) } catch (cause) { setMessage(cause instanceof Error ? cause.message : '分类读取失败') } finally { setBusy(false) }
  }
  useEffect(() => { void load() }, [])

  async function create() {
    if (!name.trim()) { setMessage('请填写分类名称'); return }
    setBusy(true)
    try { await p1Api.createAccountingCategory({ idempotencyKey: newIdempotencyKey(), createAccountingCategoryRequest: { name: name.trim(), entryType: entryType as any } }); setName(''); setMessage('分类已创建'); await load() } catch (cause) { setMessage(cause instanceof Error ? cause.message : '分类创建失败') } finally { setBusy(false) }
  }

  return <View style={{ height: '100vh', display: 'flex', flexDirection: 'column', backgroundColor: crayon.paper, backgroundImage: paperGrain }}><NavBar title="记账分类" back right={<Tag tone="accent">M3</Tag>} /><ScrollView scrollY style={{ height: 'calc(100vh - 88px)' }}><SectionList>
    <Section header="新建分类" footer={message}><FormRow label="分类名称"><Input value={name} placeholder="例如：垫料采购" onInput={(event) => setName(event.detail.value)} /></FormRow><FormRow label="类型" divider><Picker mode="selector" range={['收入', '支出']} value={entryType === 'income' ? 0 : 1} onChange={(event) => setEntryType(Number(event.detail.value) === 0 ? 'income' : 'expense')}><Cell title={entryType === 'income' ? '收入' : '支出'} value={<Tag>选择</Tag>} /></Picker></FormRow><CapabilityButton capability="write_accounting" block disabled={busy} onClick={() => void create()}>保存分类</CapabilityButton><Button block variant="outlined" disabled={busy} onClick={() => void load()}>刷新分类</Button></Section>
    <Section header="已有分类" footer={`共 ${categories.length} 个`}>
      {categories.length ? categories.map((item) => <Cell key={item.id} title={item.name} subtitle={item.entryType === 'income' ? '收入' : '支出'} value={<Tag tone={item.entryType === 'income' ? 'success' : 'warning'}>{item.entryType}</Tag>} />) : <Cell title="尚无分类" subtitle="新建后可在收支记录中选择" />}
    </Section><View style={{ height: `${metrics.bottomSafePadding}px` }} /></SectionList></ScrollView></View>
}
