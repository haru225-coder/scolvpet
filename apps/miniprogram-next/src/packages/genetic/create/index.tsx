import { Input, Picker, ScrollView, Textarea, View } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useEffect, useMemo, useState } from 'react'
import { Button, Cell, FormRow, NavBar, Section, SectionList, Tag, metrics, palette } from '@scolvpet/mp-ui'

import { defaultApi, geneticApi, newIdempotencyKey, p1Api } from '../../../api/client'
import { CapabilityButton } from '../../../components/CapabilityButton'
import {
  GeneticsUiCopy,
  buildGeneticsConclusion,
  decorateOutcomes,
  formatGeneticsPercent,
  humanMissing
} from '../../../genetics/genetics-copy'

function field(value: any, camel: string, snake: string, fallback: any = '') {
  return value?.[camel] ?? value?.[snake] ?? fallback
}

function animalLabel(item: any) {
  const name = String(item?.name || '').trim()
  const code = String(item?.internalCode || item?.internal_code || '').trim()
  if (name && code) return `${name} · ${code}`
  return name || code || '未命名个体'
}

export default function GeneticWorkbenchPage() {
  const [hamsterId, setHamsterId] = useState('')
  const [hamsters, setHamsters] = useState<any[]>([])
  const [profileName, setProfileName] = useState('')
  const [series, setSeries] = useState('')
  const [sirePhenotype, setSirePhenotype] = useState('')
  const [damPhenotype, setDamPhenotype] = useState('')
  const [targetPhenotype, setTargetPhenotype] = useState('')
  const [actualCountsText, setActualCountsText] = useState('')
  const [result, setResult] = useState<any>(null)
  const [targetCrosses, setTargetCrosses] = useState<any[]>([])
  const [catalog, setCatalog] = useState<any>(null)
  const [feedbackPairs, setFeedbackPairs] = useState<any[]>([])
  const [actualComparison, setActualComparison] = useState<any>(null)
  const [message, setMessage] = useState('从目录选系列和样子，再试配')
  const [busy, setBusy] = useState(false)
  const [showPro, setShowPro] = useState(false)

  async function loadReferenceData() {
    try {
      const [catalogResponse, feedbackResponse, hamsterResponse] = await Promise.all([
        geneticApi.listGeneticPhenotypeCatalog(),
        geneticApi.listGeneticFeedbackSummary(),
        defaultApi.listHamsters({ limit: 100 }).catch(() => ({ data: [] as any[] }))
      ])
      const nextCatalog = catalogResponse?.data || catalogResponse
      setCatalog(nextCatalog)
      setFeedbackPairs(feedbackResponse?.data?.pairs || feedbackResponse?.pairs || [])
      const list = (hamsterResponse as any)?.data || []
      setHamsters(list)
      const seriesList = Array.isArray(nextCatalog?.series) ? nextCatalog.series : []
      if (!series && seriesList[0]) {
        setSeries(String(seriesList[0].code || ''))
        const firstPheno = seriesList[0].phenotypes?.[0]
        if (firstPheno) {
          setSirePhenotype(String(firstPheno))
          setDamPhenotype(String(firstPheno))
          setTargetPhenotype(String(firstPheno))
        }
      }
      if (!hamsterId && list[0]) setHamsterId(list[0].id)
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : '目录读取失败，请先登录经营账号')
    }
  }

  useEffect(() => {
    void loadReferenceData()
  }, [])

  const catalogSeries = Array.isArray(catalog?.series) ? catalog.series : []
  const seriesLabels = catalogSeries.map((item: any) => item.name || item.code || '系列')
  const seriesIndex = Math.max(0, catalogSeries.findIndex((item: any) => item.code === series))
  const selectedSeries = catalogSeries[seriesIndex]
  const phenotypeOptions: string[] = selectedSeries?.phenotypes || []
  const sireIndex = Math.max(0, phenotypeOptions.indexOf(sirePhenotype))
  const damIndex = Math.max(0, phenotypeOptions.indexOf(damPhenotype))
  const targetIndex = Math.max(0, phenotypeOptions.indexOf(targetPhenotype))
  const hamsterLabels = hamsters.map(animalLabel)
  const hamsterIndex = Math.max(0, hamsters.findIndex((item) => item.id === hamsterId))

  const seriesCode = useMemo(
    () => String(selectedSeries?.code || series || '').trim(),
    [selectedSeries, series]
  )

  async function saveProfile() {
    if (!profileName.trim()) {
      setMessage('请填写遗传档案名称')
      return
    }
    setBusy(true)
    try {
      await p1Api.createGeneticProfile({
        idempotencyKey: newIdempotencyKey(),
        createGeneticProfileRequest: {
          hamsterId: hamsterId.trim() || null,
          name: profileName.trim(),
          phenotype: {},
          genotype: {},
          confidence: 'observed'
        } as any
      })
      Taro.showToast({ title: '遗传档案已保存', icon: 'success' })
      setProfileName('')
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : '遗传档案保存失败')
    } finally {
      setBusy(false)
    }
  }

  async function simulate() {
    if (!seriesCode || !sirePhenotype.trim() || !damPhenotype.trim()) {
      setMessage('请选择系列、公的样子和母的样子')
      return
    }
    setBusy(true)
    try {
      const response = await p1Api.simulateGeneticBreeding({
        idempotencyKey: newIdempotencyKey(),
        geneticSimulationRequest: {
          mode: 'phenotype_table',
          series: seriesCode,
          sirePhenotype: sirePhenotype.trim(),
          damPhenotype: damPhenotype.trim()
        } as any
      })
      const data = response.data as any
      const outcomes = decorateOutcomes(data?.outcomes || [])
      const conclusion = buildGeneticsConclusion({
        notes: data?.notes,
        predictionBasis: data?.predictionBasis || data?.prediction_basis,
        sirePhenotype: data?.sirePhenotype || data?.sire_phenotype || sirePhenotype,
        damPhenotype: data?.damPhenotype || data?.dam_phenotype || damPhenotype,
        sire: data?.sire,
        dam: data?.dam,
        outcomes: data?.outcomes || []
      })
      setResult({ ...data, outcomes, conclusion })
      setMessage(conclusion.line)
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : GeneticsUiCopy.missingData)
    } finally {
      setBusy(false)
    }
  }

  async function findTargetCrosses() {
    if (!seriesCode || !targetPhenotype.trim()) {
      setMessage('请选择系列和目标样子')
      return
    }
    setBusy(true)
    try {
      const response = await geneticApi.listGeneticTargetCrosses({
        series: seriesCode,
        phenotype: targetPhenotype.trim()
      })
      setTargetCrosses(response?.data?.crosses || response?.crosses || [])
      setMessage(
        `找到 ${response?.data?.crosses?.length || response?.crosses?.length || 0} 组可能生出「${targetPhenotype.trim()}」的配对`
      )
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : '反查失败，请稍后重试')
    } finally {
      setBusy(false)
    }
  }

  async function compareActual() {
    if (!seriesCode || !sirePhenotype.trim() || !damPhenotype.trim()) {
      setMessage('请先选择系列、公的样子和母的样子')
      return
    }
    const actualCounts: Record<string, number> = {}
    for (const line of actualCountsText
      .split('\n')
      .map((item) => item.trim())
      .filter(Boolean)) {
      const separator = line.lastIndexOf(':')
      const phenotype = separator >= 0 ? line.slice(0, separator).trim() : ''
      const count = separator >= 0 ? Number(line.slice(separator + 1).trim()) : Number.NaN
      if (!phenotype || !Number.isInteger(count) || count < 0) {
        setMessage(`这行写得不对：${line}；请用「样子:数量」`)
        return
      }
      actualCounts[phenotype] = count
    }
    if (!Object.keys(actualCounts).length) {
      setMessage('请至少填一行实际样子数量')
      return
    }
    setBusy(true)
    try {
      const response = await geneticApi.compareGeneticActual({
        requestBody: {
          series: seriesCode,
          sire_phenotype: sirePhenotype.trim(),
          dam_phenotype: damPhenotype.trim(),
          actual_counts: actualCounts,
          save: true
        }
      })
      setActualComparison(response?.data?.comparison || response?.comparison || response)
      setMessage('对照已保存，之后可在历史里回看')
      await loadReferenceData()
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : '对照保存失败')
    } finally {
      setBusy(false)
    }
  }

  function pickSeries(index: number) {
    const selected = catalogSeries[index]
    const code = String(selected?.code || '')
    setSeries(code)
    const first = selected?.phenotypes?.[0] ? String(selected.phenotypes[0]) : ''
    if (first) {
      setSirePhenotype(first)
      setDamPhenotype(first)
      setTargetPhenotype(first)
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
      <NavBar title="试配一下" back />
      <ScrollView
        scrollY
        type="list"
        bounces
        enhanced
        showScrollbar={false}
        style={{ flex: 1 }}
      >
        <SectionList>
          <Section header="遗传档案" footer={message}>
            {hamsters.length ? (
              <FormRow label="关联个体">
                <Picker
                  mode="selector"
                  range={['不关联', ...hamsterLabels]}
                  value={hamsterId ? hamsterIndex + 1 : 0}
                  onChange={(event) => {
                    const i = Number(event.detail.value)
                    setHamsterId(i === 0 ? '' : hamsters[i - 1]?.id || '')
                  }}
                >
                  <Cell
                    title={hamsterId ? hamsterLabels[hamsterIndex] || '选择个体' : '不关联'}
                    value={<Tag>选择</Tag>}
                  />
                </Picker>
              </FormRow>
            ) : (
              <FormRow label="关联个体">
                <Cell title="还没有个体" subtitle="可选，不强制" />
              </FormRow>
            )}
            <FormRow label="档案名称" divider>
              <Input
                value={profileName}
                placeholder="例如：001 的样子档案"
                placeholderStyle="color: rgba(255,255,255,0.35)"
                onInput={(event) => setProfileName(event.detail.value)}
                style={{ color: '#FFFFFF' }}
              />
            </FormRow>
            <CapabilityButton
              capability="write_genetic"
              block
              disabled={busy}
              onClick={() => void saveProfile()}
            >
              保存遗传档案
            </CapabilityButton>
          </Section>

          <Section header="可选样子目录" footer={catalog?.title ? String(catalog.title) : '从当前熊舍规则读取'}>
            {catalogSeries.length ? (
              catalogSeries.map((item: any) => (
                <Cell
                  key={item.code}
                  title={item.name || item.code}
                  subtitle={(item.phenotypes || []).join('、')}
                  value={<Tag>目录</Tag>}
                  onClick={() => {
                    const idx = catalogSeries.findIndex((s: any) => s.code === item.code)
                    if (idx >= 0) pickSeries(idx)
                  }}
                />
              ))
            ) : (
              <Cell title="目录还没出来" subtitle="登录后点刷新再试" />
            )}
            <Button block variant="outlined" disabled={busy} onClick={() => void loadReferenceData()}>
              刷新目录
            </Button>
          </Section>

          <Section header={GeneticsUiCopy.pageTitle}>
            {catalogSeries.length ? (
              <>
                <FormRow label="系列">
                  <Picker
                    mode="selector"
                    range={seriesLabels}
                    value={seriesIndex}
                    onChange={(event) => pickSeries(Number(event.detail.value))}
                  >
                    <Cell title={seriesLabels[seriesIndex] || '选择系列'} value={<Tag>选择</Tag>} />
                  </Picker>
                </FormRow>
                <FormRow label="公的样子" divider>
                  <Picker
                    mode="selector"
                    range={phenotypeOptions.length ? phenotypeOptions : ['（请先选系列）']}
                    value={sireIndex}
                    onChange={(event) =>
                      setSirePhenotype(phenotypeOptions[Number(event.detail.value)] || '')
                    }
                  >
                    <Cell title={sirePhenotype || '选择样子'} value={<Tag>选择</Tag>} />
                  </Picker>
                </FormRow>
                <FormRow label="母的样子" divider>
                  <Picker
                    mode="selector"
                    range={phenotypeOptions.length ? phenotypeOptions : ['（请先选系列）']}
                    value={damIndex}
                    onChange={(event) =>
                      setDamPhenotype(phenotypeOptions[Number(event.detail.value)] || '')
                    }
                  >
                    <Cell title={damPhenotype || '选择样子'} value={<Tag>选择</Tag>} />
                  </Picker>
                </FormRow>
              </>
            ) : (
              <Cell title="还没有样子目录" subtitle="点上方刷新，或先配置规则" />
            )}
            <CapabilityButton
              capability="write_genetic"
              block
              disabled={busy || !catalogSeries.length}
              onClick={() => void simulate()}
            >
              {GeneticsUiCopy.runCta}
            </CapabilityButton>
          </Section>

          {result ? (
            <Section header={GeneticsUiCopy.resultHeading} footer={result.conclusion?.line || message}>
              <Cell
                title={result.conclusion?.line || GeneticsUiCopy.resultHeading}
                subtitle={`${humanMissing(result.sirePhenotype || sirePhenotype)}（公）× ${humanMissing(result.damPhenotype || damPhenotype)}（母）`}
                value={
                  <Tag
                    tone={
                      result.conclusion?.tone === 'red'
                        ? 'danger'
                        : result.conclusion?.tone === 'green'
                          ? 'success'
                          : 'accent'
                    }
                  >
                    {result.conclusion?.tone === 'red' ? '风险' : '结论'}
                  </Tag>
                }
              />
              {(result.outcomes || []).map((item: any) => (
                <Cell
                  key={item.genotypeKey || item.displayName}
                  title={item.displayName || humanMissing(item.phenotypeLabel)}
                  subtitle={item.aboutLabel || ''}
                  value={<Tag>{item.percentLabel || formatGeneticsPercent(item.probability)}</Tag>}
                />
              ))}
              <Cell
                title={showPro ? '收起专业代码' : GeneticsUiCopy.professionalSectionTitle}
                subtitle="需要时再看"
                value={<Tag>{showPro ? '已展开' : '折叠'}</Tag>}
                onClick={() => setShowPro((v) => !v)}
              />
              {showPro
                ? (result.outcomes || []).map((item: any) => (
                    <Cell
                      key={`pro-${item.genotypeKey || item.displayName}`}
                      title={item.professionalKey || item.genotypeKey || '—'}
                      subtitle={item.displayName}
                      value={<Tag tone="warning">{item.percentLabel}</Tag>}
                    />
                  ))
                : null}
            </Section>
          ) : null}

          <Section header="想要某种样子，反查怎么配">
            {phenotypeOptions.length ? (
              <FormRow label="目标样子">
                <Picker
                  mode="selector"
                  range={phenotypeOptions}
                  value={targetIndex}
                  onChange={(event) =>
                    setTargetPhenotype(phenotypeOptions[Number(event.detail.value)] || '')
                  }
                >
                  <Cell title={targetPhenotype || '选择样子'} value={<Tag>选择</Tag>} />
                </Picker>
              </FormRow>
            ) : (
              <FormRow label="目标样子">
                <Input
                  value={targetPhenotype}
                  placeholder="例如：蜜波利"
                  placeholderStyle="color: rgba(255,255,255,0.35)"
                  onInput={(event) => setTargetPhenotype(event.detail.value)}
                  style={{ color: '#FFFFFF' }}
                />
              </FormRow>
            )}
            <CapabilityButton
              capability="write_genetic"
              block
              variant="outlined"
              disabled={busy}
              onClick={() => void findTargetCrosses()}
            >
              找推荐配对
            </CapabilityButton>
            {targetCrosses.map((item) => (
              <Cell
                key={`${item.parent_a || item.parentA}-${item.parent_b || item.parentB}`}
                title={`${item.parent_a || item.parentA} × ${item.parent_b || item.parentB}`}
                subtitle={`历史窝数 ${field(item, 'historyLitters', 'history_litter_count', 0)}`}
                value={
                  <Tag tone="success">{`${Math.round(Number(field(item, 'targetProbability', 'target_probability', 0)) * 100)}%`}</Tag>
                }
              />
            ))}
          </Section>

          <Section header="实际窝次对照" footer="每行：样子:数量，例如 蜜波利:3">
            <FormRow label="实际样子数量">
              <Textarea
                value={actualCountsText}
                placeholder={'蜜波利:3\n黑蜜波利:1'}
                placeholderStyle="color: rgba(255,255,255,0.35)"
                onInput={(event) => setActualCountsText(event.detail.value)}
                style={{ minHeight: '96px', width: '100%', color: '#FFFFFF' }}
              />
            </FormRow>
            <CapabilityButton
              capability="write_genetic"
              block
              disabled={busy}
              onClick={() => void compareActual()}
            >
              对照并保存
            </CapabilityButton>
            {actualComparison ? (
              <Cell
                title={`总数 ${field(actualComparison, 'totalActual', 'total_actual', 0)}`}
                subtitle={`平均误差 ${Number(field(actualComparison, 'meanAbsError', 'mean_abs_error', 0)).toFixed(3)}`}
                value={<Tag tone="success">已保存</Tag>}
              />
            ) : null}
          </Section>

          <Section header="历史对照" footer={feedbackPairs.length ? `共 ${feedbackPairs.length} 组` : '还没有对照记录'}>
            {feedbackPairs.slice(0, 20).map((item) => (
              <Cell
                key={`${item.series}-${item.sire_phenotype || item.sirePhenotype}-${item.dam_phenotype || item.damPhenotype}`}
                title={`${item.sire_phenotype || item.sirePhenotype} × ${item.dam_phenotype || item.damPhenotype}`}
                subtitle={`样本 ${field(item, 'sampleCount', 'sample_count', 0)} · 平均误差 ${Number(field(item, 'avgMeanAbsError', 'avg_mean_abs_error', 0)).toFixed(3)}`}
                value={<Tag tone="warning">历史</Tag>}
              />
            ))}
          </Section>
          <View style={{ height: `${metrics.bottomSafePadding}px` }} />
        </SectionList>
      </ScrollView>
    </View>
  )
}
