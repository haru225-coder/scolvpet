import { Input, ScrollView, View } from '@tarojs/components'
import Taro, { useLoad } from '@tarojs/taro'
import { useState } from 'react'
import { FormRow, NavBar, Section, SectionList, Tag, crayon, paperGrain, metrics } from '@scolvpet/mp-ui'

import { defaultApi, newIdempotencyKey } from '../../../api/client'
import { CapabilityButton } from '../../../components/CapabilityButton'

export default function CreateBreedingPlanPage() {
  const [sireId, setSireId] = useState('')
  const [damId, setDamId] = useState('')
  const [ruleVersionId, setRuleVersionId] = useState('')
  const [name, setName] = useState('')
  const [message, setMessage] = useState('正在准备个体与物种规则…')
  const [busy, setBusy] = useState(false)
  useLoad(() => {
    void Promise.all([defaultApi.listHamsters({ limit: 100 }), defaultApi.listSpeciesRuleVersions({ limit: 20 })]).then(([hamsters, rules]) => {
      const males = (hamsters.data || []).filter((item: any) => item.sex === 'male')
      const females = (hamsters.data || []).filter((item: any) => item.sex === 'female')
      setSireId(males[0]?.id || '')
      setDamId(females[0]?.id || '')
      setRuleVersionId(rules.data?.[0]?.id || '')
      setMessage(`已载入 ${hamsters.data?.length || 0} 只个体、${rules.data?.length || 0} 条规则`)
    }).catch((cause) => setMessage(cause instanceof Error ? cause.message : '准备繁育数据失败'))
  })
  async function submit() {
    if (!sireId || !damId || !ruleVersionId) { setMessage('请填写父本、母本和规则版本 ID'); return }
    setBusy(true)
    try {
      await defaultApi.createBreedingPlan({ idempotencyKey: newIdempotencyKey(), breedingPlanCreateRequest: { name: name.trim() || null, sireId, damId, ruleVersionId } })
      Taro.showToast({ title: '繁育计划已创建', icon: 'success' }); setTimeout(() => Taro.navigateBack(), 350)
    } catch (cause) { setMessage(cause instanceof Error ? cause.message : '创建繁育计划失败') } finally { setBusy(false) }
  }
  return <View style={{ height: '100vh', backgroundColor: crayon.paper, backgroundImage: paperGrain }}><NavBar title="新建繁育计划" back right={<Tag tone="accent">繁育</Tag>} /><ScrollView scrollY style={{ height: 'calc(100vh - 88px)' }}><SectionList><Section header="配对向导" footer={message}><FormRow label="父本 ID"><Input value={sireId} placeholder="从个体页复制" onInput={(event) => setSireId(event.detail.value)} /></FormRow><FormRow label="母本 ID" divider><Input value={damId} placeholder="从个体页复制" onInput={(event) => setDamId(event.detail.value)} /></FormRow><FormRow label="规则版本 ID" divider><Input value={ruleVersionId} placeholder="物种规则版本" onInput={(event) => setRuleVersionId(event.detail.value)} /></FormRow><FormRow label="计划名称" divider><Input value={name} placeholder="可选" onInput={(event) => setName(event.detail.value)} /></FormRow></Section><CapabilityButton capability="write_breeding" block disabled={busy} onClick={() => void submit()}>{busy ? '创建中…' : '创建计划'}</CapabilityButton><View style={{ height: `${metrics.bottomSafePadding}px` }} /></SectionList></ScrollView></View>
}
