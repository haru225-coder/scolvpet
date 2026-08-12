import { Input, ScrollView, Textarea, View } from '@tarojs/components'
import { useEffect, useState } from 'react'
import { Button, Cell, FormRow, NavBar, Section, SectionList, Tag, metrics, palette } from '@scolvpet/mp-ui'

import { newIdempotencyKey, p1Api } from '../../../api/client'
import { CapabilityButton } from '../../../components/CapabilityButton'
import { formatUserError } from '../../../api/errors'

export default function ContractTemplatesPage() {
  const [kind, setKind] = useState<'contract' | 'receipt'>('contract')
  const [templates, setTemplates] = useState<any[]>([])
  const [name, setName] = useState('交接协议')
  const [bodyText, setBodyText] = useState('')
  const [message, setMessage] = useState('正在读取合同与回执模板…')
  const [busy, setBusy] = useState(false)

  async function load() {
    setBusy(true)
    try {
      const [contracts, receipts] = await Promise.all([
        p1Api.listContractTemplates(),
        p1Api.listReceiptTemplates()
      ])
      setTemplates([...(contracts.data || []), ...(receipts.data || [])])
      setMessage(`已读取 ${(contracts.data?.length || 0) + (receipts.data?.length || 0)} 个模板`)
    } catch (cause) {
      setMessage(await formatUserError(cause, '模板读取失败'))
    } finally {
      setBusy(false)
    }
  }
  useEffect(() => {
    void load()
  }, [])

  async function create() {
    if (!name.trim()) {
      setMessage('请填写模板名称')
      return
    }
    setBusy(true)
    try {
      const request = {
        idempotencyKey: newIdempotencyKey(),
        createDocumentTemplateRequest: { name: name.trim(), bodyText: bodyText.trim() || undefined }
      }
      if (kind === 'receipt') await p1Api.createReceiptTemplate(request as any)
      else await p1Api.createContractTemplate(request as any)
      setMessage(`${kind === 'receipt' ? '回执' : '合同'}模板已创建`)
      setName(kind === 'receipt' ? '订金回执' : '交接协议')
      setBodyText('')
      await load()
    } catch (cause) {
      setMessage(await formatUserError(cause, '模板创建失败'))
    } finally {
      setBusy(false)
    }
  }

  return (
    <View
      style={{
        height: '100vh',
        display: 'flex',
        flexDirection: 'column',
        backgroundColor: palette.systemBackground
      }}
    >
      <NavBar title="合同与回执模板" back />
      <ScrollView scrollY style={{ flex: 1 }}>
        <SectionList>
          <Section header="新建模板" footer={message}>
            <Cell
              title="模板类型"
              value={<Tag>{kind === 'receipt' ? '回执' : '合同'}</Tag>}
              onClick={() => {
                const next = kind === 'contract' ? 'receipt' : 'contract'
                setKind(next)
                setName(next === 'receipt' ? '订金回执' : '交接协议')
              }}
            />
            <FormRow label="名称">
              <Input
                value={name}
                placeholder="例如：交接协议"
                placeholderStyle={`color: ${palette.tertiaryLabel}`}
                onInput={(event) => setName(event.detail.value)}
                style={{ color: '#FFFFFF' }}
              />
            </FormRow>
            <FormRow label="正文" divider>
              <Textarea
                value={bodyText}
                placeholder="可留空，系统会用默认模板"
                placeholderStyle={`color: ${palette.tertiaryLabel}`}
                onInput={(event) => setBodyText(event.detail.value)}
                style={{ minHeight: '140px', width: '100%', color: '#FFFFFF' }}
              />
            </FormRow>
            <CapabilityButton
              capability="write_documents"
              block
              disabled={busy}
              onClick={() => void create()}
            >
              创建{kind === 'receipt' ? '回执' : '合同'}模板
            </CapabilityButton>
            <Button block variant="outlined" disabled={busy} onClick={() => void load()}>
              刷新模板
            </Button>
          </Section>
          <Section header="已有模板" footer={`共 ${templates.length} 个`}>
            {templates.length ? (
              templates.map((item) => (
                <Cell
                  key={item.id}
                  title={item.name}
                  subtitle={`${item.kind === 'receipt' ? '回执' : '合同'} · 第 ${item.version ?? 1} 版`}
                  value={<Tag>{item.kind === 'receipt' ? '回执' : '合同'}</Tag>}
                />
              ))
            ) : (
              <Cell title="尚无模板" subtitle="创建后可在新增合同或回执中选择" />
            )}
          </Section>
          <View style={{ height: `${metrics.bottomSafePadding}px` }} />
        </SectionList>
      </ScrollView>
    </View>
  )
}
