import { Input, ScrollView, Textarea, View } from '@tarojs/components'
import Taro, { useLoad } from '@tarojs/taro'
import { useState } from 'react'
import { FormRow, NavBar, Section, SectionList, Tag, crayon, paperGrain, metrics } from '@scolvpet/mp-ui'

import { defaultApi, newIdempotencyKey } from '../../../api/client'
import { CapabilityButton } from '../../../components/CapabilityButton'
import type { ApiEnvelope } from '../../../api/types'

export default function BatchCreateAnimalsPage() {
  const [ruleVersionId, setRuleVersionId] = useState('')
  const [rows, setRows] = useState('')
  const [message, setMessage] = useState('每行：内部编号,名称,性别,品系；服务端按原子批次处理')
  const [busy, setBusy] = useState(false)

  useLoad(() => { void defaultApi.listSpeciesRuleVersions({ limit: 20 }).then((response: ApiEnvelope) => { setRuleVersionId(response.data?.[0]?.id || ''); setMessage(response.data?.[0] ? `默认规则：${response.data[0].speciesCode} v${response.data[0].version}` : '请填写物种规则版本 ID') }).catch((cause: unknown) => setMessage(cause instanceof Error ? cause.message : '物种规则加载失败')) })

  async function submit() {
    const items = rows.split('\n').map((row) => row.split(',').map((value) => value.trim())).filter((parts) => parts[0])
    if (!ruleVersionId || !items.length) { setMessage('请填写规则版本和至少一行个体'); return }
    setBusy(true)
    try {
      await defaultApi.batchCreateHamsters({
        idempotencyKey: newIdempotencyKey(),
        hamsterBatchCreateRequest: {
          atomic: true,
          items: items.map(([internalCode, name, sex, varietyCode], index) => ({ clientItemId: `${Date.now()}-${index}`, hamster: { internalCode, name: name || null, speciesRuleVersionId: ruleVersionId, sex: sex || 'unknown', varietyCode: varietyCode || null, sourceType: 'introduced' } }))
        } as any
      })
      Taro.showToast({ title: `已创建 ${items.length} 只`, icon: 'success' }); setTimeout(() => Taro.navigateBack(), 350)
    } catch (cause) { setMessage(cause instanceof Error ? cause.message : '批量创建失败') } finally { setBusy(false) }
  }

  return <View style={{ height: '100vh', backgroundColor: crayon.paper, backgroundImage: paperGrain }}><NavBar title="批量新增个体" back right={<Tag tone="accent">M2</Tag>} /><ScrollView scrollY style={{ height: 'calc(100vh - 88px)' }}><SectionList><Section header="批次设置" footer={message}><FormRow label="规则版本 ID"><Input value={ruleVersionId} placeholder="自动读取，也可手动填写" onInput={(event) => setRuleVersionId(event.detail.value)} /></FormRow><FormRow label="个体清单" divider><Textarea value={rows} maxlength={10000} placeholder="SY-001,布丁,female,gold\nSY-002,团子,male,cinnamon" onInput={(event) => setRows(event.detail.value)} style={{ minHeight: '180px', width: '100%' }} /></FormRow></Section><CapabilityButton capability="write_hamster" block disabled={busy} onClick={() => void submit()}>{busy ? '批量创建中…' : '原子批量创建'}</CapabilityButton><View style={{ height: `${metrics.bottomSafePadding}px` }} /></SectionList></ScrollView></View>
}
