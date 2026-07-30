import { ScrollView, Text, View } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useEffect, useRef, useState } from 'react'
import { Button, Cell, NavBar, Section, SectionList, Tag, crayon, paperGrain, metrics } from '@scolvpet/mp-ui'

import { downloadDocumentPdf, p1Api } from '../../../api/client'
import { CapabilityButton } from '../../../components/CapabilityButton'
import { createIdempotencyIntent } from '../../../api/idempotency'

type DocumentItem = {
  id: string
  kind?: 'contract' | 'receipt'
  title?: string
  bodyFilled?: string
  status?: string
  version?: number
  publicUrl?: string | null
  contactName?: string
}

export function isDocumentVersionConflict(error: unknown) {
  const response = error && typeof error === 'object' ? (error as { response?: { status?: unknown } }).response : undefined
  return Number(response?.status) === 409
}

export default function ContractDetailPage() {
  const route = Taro.getCurrentInstance().router?.params || {}
  const kind = route.kind === 'receipt' ? 'receipt' : 'contract'
  const documentId = route.documentId || ''
  const [item, setItem] = useState<DocumentItem | null>(null)
  const [message, setMessage] = useState('正在读取单据')
  const [busy, setBusy] = useState(false)
  const transitionIntents = useRef<Record<string, ReturnType<typeof createIdempotencyIntent>>>({}).current

  async function load() {
    try {
      const response = kind === 'receipt' ? await p1Api.listReceipts() : await p1Api.listContracts()
      const found = ((response.data || []) as DocumentItem[]).find((entry) => entry.id === documentId)
      if (!found) { setMessage('单据不存在或已不属于当前经营账号'); return }
      setItem(found)
      setMessage('')
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : '单据加载失败')
    }
  }

  useEffect(() => { void load() }, [documentId, kind])

  async function transition(action: 'issue' | 'revoke') {
    if (!item) return
    setBusy(true)
    try {
      const intentKey = `${kind}:${item.id}:${action}`
      const intent = transitionIntents[intentKey] || (transitionIntents[intentKey] = createIdempotencyIntent())
      const request = { idempotencyKey: intent.getKey(), documentId: item.id, ifMatch: String(item.version ?? 0) }
      const response = kind === 'receipt'
        ? (action === 'issue' ? await p1Api.issueReceipt(request) : await p1Api.revokeReceipt(request))
        : (action === 'issue' ? await p1Api.issueContract(request) : await p1Api.revokeContract(request))
      setItem(response.data as DocumentItem)
      intent.complete()
      Taro.showToast({ title: action === 'issue' ? '已签发' : '已撤销', icon: 'success' })
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : '状态更新失败')
      if (isDocumentVersionConflict(cause)) {
        await load()
        setMessage('单据已被其他成员更新，请确认最新状态后重试')
      }
    } finally {
      setBusy(false)
    }
  }

  function copyPublicUrl() {
    if (!item?.publicUrl) return
    Taro.setClipboardData({ data: item.publicUrl })
  }

  async function downloadPdf() {
    if (!item || item.status !== 'issued') return
    setBusy(true)
    try {
      const filePath = await downloadDocumentPdf(kind, item.id)
      await Taro.openDocument({ filePath, fileType: 'pdf', showMenu: true })
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : 'PDF 下载失败')
    } finally {
      setBusy(false)
    }
  }

  return <View style={{ height: '100vh', backgroundColor: crayon.paper, backgroundImage: paperGrain }}>
    <NavBar title={kind === 'receipt' ? '回执详情' : '合同详情'} back right={<Tag tone="accent">M3</Tag>} />
    <ScrollView scrollY style={{ height: 'calc(100vh - 88px)' }}>
      {message ? <SectionList><Section header="状态"><Cell title={message} /></Section></SectionList> : null}
      {item ? <SectionList>
        <Section header="单据状态" footer={`版本 ${item.version ?? 0}`}>
          <Cell title={item.title || (kind === 'receipt' ? '回执' : '合同')} subtitle={item.contactName || '未关联客户'} value={<Tag tone={item.status === 'issued' ? 'success' : item.status === 'archived' ? 'danger' : 'warning'}>{item.status || 'draft'}</Tag>} />
          {item.publicUrl ? <Cell title="公开链接" subtitle={item.publicUrl} onClick={copyPublicUrl} /> : null}
        </Section>
        {item.bodyFilled ? <Section header="正文"><Text style={{ display: 'block', whiteSpace: 'pre-wrap', color: crayon.ink, padding: `0 ${metrics.pagePadding}px ${metrics.space16}px` }}>{item.bodyFilled}</Text></Section> : null}
        <View style={{ padding: `0 ${metrics.pagePadding}px`, display: 'flex', gap: `${metrics.space12}px` }}>
          {item.status === 'draft' ? <CapabilityButton capability="write_documents" block disabled={busy} onClick={() => void transition('issue')}>签发{kind === 'receipt' ? '回执' : '合同'}</CapabilityButton> : null}
          {item.status === 'issued' ? <CapabilityButton capability="write_documents" variant="outlined" block disabled={busy} onClick={() => void transition('revoke')}>撤销并失效公开链接</CapabilityButton> : null}
          {item.status === 'issued' ? <Button variant="outlined" block disabled={busy} onClick={() => void downloadPdf()}>下载 PDF</Button> : null}
        </View>
      </SectionList> : null}
      <View style={{ height: `${metrics.bottomSafePadding}px` }} />
    </ScrollView>
  </View>
}
