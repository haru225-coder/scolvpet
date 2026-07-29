import { Input, Picker, ScrollView, Textarea, View } from '@tarojs/components'
import Taro, { useLoad } from '@tarojs/taro'
import { useState } from 'react'
import { FormRow, NavBar, Section, SectionList, Tag, crayon, paperGrain, metrics } from '@scolvpet/mp-ui'

import { defaultApi, geneticApi, newIdempotencyKey } from '../../../api/client'
import { CapabilityButton } from '../../../components/CapabilityButton'
import { encodePhenotype, readPhenotypeSeries, type PhenotypeSeries } from '../../../utils/phenotype'
import type { ApiEnvelope } from '../../../api/types'

export default function CreateAnimalPage() {
  const [internalCode, setInternalCode] = useState('')
  const [name, setName] = useState('')
  const [sex, setSex] = useState('unknown')
  const [varietyCode, setVarietyCode] = useState('')
  const [seriesCode, setSeriesCode] = useState('')
  const [phenotypeLabel, setPhenotypeLabel] = useState('')
  const [seriesOptions, setSeriesOptions] = useState<PhenotypeSeries[]>([])
  const [birthDate, setBirthDate] = useState('')
  const [notes, setNotes] = useState('')
  const [ruleVersionId, setRuleVersionId] = useState('')
  const [message, setMessage] = useState('正在加载物种规则…')
  const [busy, setBusy] = useState(false)

  useLoad(() => {
    void defaultApi.listSpeciesRuleVersions({ limit: 20 }).then((response: ApiEnvelope) => {
      const first = response.data?.[0]
      if (first) {
        setRuleVersionId(first.id)
        setMessage(`使用规则：${first.speciesCode} v${first.version}`)
      } else setMessage('暂时没有可用物种规则')
    }).catch((cause: unknown) => setMessage(cause instanceof Error ? cause.message : '物种规则加载失败'))
    void geneticApi.listGeneticPhenotypeCatalog().then((response: ApiEnvelope) => {
      const options = readPhenotypeSeries(response)
      setSeriesOptions(options)
      if (options[0]) {
        setSeriesCode(options[0].code)
        setPhenotypeLabel(options[0].phenotypes[0] || '')
      }
    }).catch(() => undefined)
  })

  async function submit() {
    if (!internalCode.trim() || !ruleVersionId) {
      setMessage('请填写内部编号，并等待物种规则加载')
      return
    }
    setBusy(true)
    try {
      await defaultApi.createHamster({
        idempotencyKey: newIdempotencyKey(),
        hamsterCreateRequest: {
          internalCode: internalCode.trim(),
          name: name.trim() || null,
          speciesRuleVersionId: ruleVersionId,
          varietyCode: varietyCode.trim() || encodePhenotype(seriesCode, phenotypeLabel) || null,
          sex,
          sourceType: 'introduced',
          birthDate: birthDate ? new Date(`${birthDate}T00:00:00Z`) : null,
          notes: notes.trim() || null
        } as any
      })
      Taro.showToast({ title: '个体已创建', icon: 'success' })
      setTimeout(() => Taro.navigateBack(), 350)
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : '创建失败')
    } finally {
      setBusy(false)
    }
  }

  const sexLabels = ['待定', '公', '母']
  const sexValues = ['unknown', 'male', 'female']
  const sexIndex = Math.max(0, sexValues.indexOf(sex))
  const selectedSeries = seriesOptions.find((item) => item.code === seriesCode)
  const phenotypeOptions = selectedSeries?.phenotypes || []
  const phenotypeIndex = Math.max(0, phenotypeOptions.indexOf(phenotypeLabel))

  return <View style={{ height: '100vh', backgroundColor: crayon.paper, backgroundImage: paperGrain }}><NavBar title="新增个体" back right={<Tag tone="accent">M2</Tag>} /><ScrollView scrollY style={{ height: 'calc(100vh - 88px)' }}><SectionList><Section header="档案信息" footer={message}><FormRow label="内部编号"><Input placeholder="例如 SY-001" value={internalCode} onInput={(event) => setInternalCode(event.detail.value)} /></FormRow><FormRow label="名称" divider><Input placeholder="可选" value={name} onInput={(event) => setName(event.detail.value)} /></FormRow><FormRow label="性别" divider><Picker mode="selector" range={sexLabels} value={sexIndex} onChange={(event) => setSex(sexValues[Number(event.detail.value)] || 'unknown')}><Input value={sexLabels[sexIndex]} disabled /></Picker></FormRow>{seriesOptions.length ? <><FormRow label="表型系列" divider><Picker mode="selector" range={seriesOptions.map((item) => item.name)} value={Math.max(0, seriesOptions.findIndex((item) => item.code === seriesCode))} onChange={(event) => { const selected = seriesOptions[Number(event.detail.value)]; setSeriesCode(selected?.code || ''); setPhenotypeLabel(selected?.phenotypes[0] || ''); setVarietyCode('') }}><Input value={selectedSeries?.name || '选择系列'} disabled /></Picker></FormRow><FormRow label="表型" divider><Picker mode="selector" range={phenotypeOptions} value={phenotypeIndex} onChange={(event) => { setPhenotypeLabel(phenotypeOptions[Number(event.detail.value)] || ''); setVarietyCode('') }}><Input value={phenotypeLabel || '选择表型'} disabled /></Picker></FormRow></> : null}<FormRow label="品系代码" divider><Input placeholder={seriesOptions.length ? '可选，留空使用系列|表型' : '可选'} value={varietyCode} onInput={(event) => setVarietyCode(event.detail.value)} /></FormRow><FormRow label="出生日期" divider><Picker mode="date" value={birthDate} onChange={(event) => setBirthDate(event.detail.value)}><Input value={birthDate || '未填写'} disabled /></Picker></FormRow><FormRow label="备注" divider><Textarea value={notes} maxlength={1000} placeholder="可选" onInput={(event) => setNotes(event.detail.value)} /></FormRow></Section><CapabilityButton capability="write_hamster" block disabled={busy} onClick={() => void submit()}>{busy ? '保存中…' : '创建个体'}</CapabilityButton><View style={{ height: `${metrics.bottomSafePadding}px` }} /></SectionList></ScrollView></View>
}
