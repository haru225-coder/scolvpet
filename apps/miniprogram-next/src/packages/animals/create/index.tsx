import { Input, Picker, ScrollView, Textarea, View } from '@tarojs/components'
import Taro, { useLoad } from '@tarojs/taro'
import { useState } from 'react'
import { Cell, FormRow, NavBar, Section, SectionList, Tag, metrics, palette } from '@scolvpet/mp-ui'

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
  const [showAdvanced, setShowAdvanced] = useState(false)

  useLoad(() => {
    void defaultApi.listSpeciesRuleVersions({ limit: 20 }).then((response: ApiEnvelope) => {
      const first = response.data?.[0]
      if (first) {
        setRuleVersionId(first.id)
        setMessage(`已自动选用规则 v${first.version ?? 1}，一般不用改`)
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

  return (
    <View style={{ height: '100vh', backgroundColor: palette.systemBackground }}>
      <NavBar title="新增个体" back />
      <ScrollView scrollY style={{ height: 'calc(100vh - 88px)' }}>
        <SectionList>
          <Section header="档案信息" footer={message}>
            <FormRow label="内部编号">
              <Input
                placeholder="例如 SY-001"
                placeholderStyle="color: rgba(255,255,255,0.35)"
                value={internalCode}
                onInput={(event) => setInternalCode(event.detail.value)}
                style={{ color: '#FFFFFF' }}
              />
            </FormRow>
            <FormRow label="名称" divider>
              <Input
                placeholder="可选"
                placeholderStyle="color: rgba(255,255,255,0.35)"
                value={name}
                onInput={(event) => setName(event.detail.value)}
                style={{ color: '#FFFFFF' }}
              />
            </FormRow>
            <FormRow label="性别" divider>
              <Picker
                mode="selector"
                range={sexLabels}
                value={sexIndex}
                onChange={(event) => setSex(sexValues[Number(event.detail.value)] || 'unknown')}
              >
                <Cell title={sexLabels[sexIndex]} value={<Tag>选择</Tag>} />
              </Picker>
            </FormRow>
            {seriesOptions.length ? (
              <>
                <FormRow label="样子系列" divider>
                  <Picker
                    mode="selector"
                    range={seriesOptions.map((item) => item.name)}
                    value={Math.max(0, seriesOptions.findIndex((item) => item.code === seriesCode))}
                    onChange={(event) => {
                      const selected = seriesOptions[Number(event.detail.value)]
                      setSeriesCode(selected?.code || '')
                      setPhenotypeLabel(selected?.phenotypes[0] || '')
                      setVarietyCode('')
                    }}
                  >
                    <Cell title={selectedSeries?.name || '选择系列'} value={<Tag>选择</Tag>} />
                  </Picker>
                </FormRow>
                <FormRow label="样子" divider>
                  <Picker
                    mode="selector"
                    range={phenotypeOptions}
                    value={phenotypeIndex}
                    onChange={(event) => {
                      setPhenotypeLabel(phenotypeOptions[Number(event.detail.value)] || '')
                      setVarietyCode('')
                    }}
                  >
                    <Cell title={phenotypeLabel || '选择样子'} value={<Tag>选择</Tag>} />
                  </Picker>
                </FormRow>
              </>
            ) : null}
            <FormRow label="出生日期" divider>
              <Picker mode="date" value={birthDate} onChange={(event) => setBirthDate(event.detail.value)}>
                <Cell title={birthDate || '未填写'} value={<Tag>选择</Tag>} />
              </Picker>
            </FormRow>
            <FormRow label="备注" divider>
              <Textarea
                value={notes}
                maxlength={1000}
                placeholder="可选"
                placeholderStyle="color: rgba(255,255,255,0.35)"
                onInput={(event) => setNotes(event.detail.value)}
                style={{ color: '#FFFFFF' }}
              />
            </FormRow>
          </Section>
          <Section header="高级（一般不用）">
            <Cell
              title={showAdvanced ? '收起高级' : '展开高级'}
              subtitle="手动品系代码，选样子后通常可留空"
              value={<Tag>{showAdvanced ? '已展开' : '折叠'}</Tag>}
              onClick={() => setShowAdvanced((v) => !v)}
            />
            {showAdvanced ? (
              <FormRow label="品系代码" divider>
                <Input
                  placeholder="可选，一般可留空"
                  placeholderStyle="color: rgba(255,255,255,0.35)"
                  value={varietyCode}
                  onInput={(event) => setVarietyCode(event.detail.value)}
                  style={{ color: '#FFFFFF' }}
                />
              </FormRow>
            ) : null}
          </Section>
          <CapabilityButton capability="write_hamster" block disabled={busy} onClick={() => void submit()}>
            {busy ? '保存中…' : '创建个体'}
          </CapabilityButton>
          <View style={{ height: `${metrics.bottomSafePadding}px` }} />
        </SectionList>
      </ScrollView>
    </View>
  )
}
