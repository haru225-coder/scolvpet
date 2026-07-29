import { Input, ScrollView, Textarea, View } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useEffect, useState } from 'react'
import { Button, Cell, FormRow, NavBar, Section, SectionList, Tag, crayon, paperGrain, metrics } from '@scolvpet/mp-ui'

import { geneticApi, newIdempotencyKey, p1Api } from '../../../api/client'
import { CapabilityButton } from '../../../components/CapabilityButton'

function field(value: any, camel: string, snake: string, fallback: any = '') {
  return value?.[camel] ?? value?.[snake] ?? fallback
}

export default function GeneticWorkbenchPage() {
  const [hamsterId, setHamsterId] = useState('')
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
  const [message, setMessage] = useState('支持档案、目录、配对模拟、目标交配和实际反馈闭环')
  const [busy, setBusy] = useState(false)

  async function loadReferenceData() {
    try {
      const [catalogResponse, feedbackResponse] = await Promise.all([
        geneticApi.listGeneticPhenotypeCatalog(),
        geneticApi.listGeneticFeedbackSummary()
      ])
      setCatalog(catalogResponse?.data || catalogResponse)
      setFeedbackPairs(feedbackResponse?.data?.pairs || feedbackResponse?.pairs || [])
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : '遗传目录读取失败，请先登录经营账号')
    }
  }

  useEffect(() => { void loadReferenceData() }, [])

  async function saveProfile() {
    if (!profileName.trim()) { setMessage('请填写遗传档案名称'); return }
    setBusy(true)
    try {
      await p1Api.createGeneticProfile({ idempotencyKey: newIdempotencyKey(), createGeneticProfileRequest: { hamsterId: hamsterId.trim() || null, name: profileName.trim(), phenotype: {}, genotype: {}, confidence: 'observed' } as any })
      Taro.showToast({ title: '遗传档案已保存', icon: 'success' })
      setProfileName('')
    } catch (cause) { setMessage(cause instanceof Error ? cause.message : '遗传档案保存失败') } finally { setBusy(false) }
  }

  async function simulate() {
    if (!series.trim() || !sirePhenotype.trim() || !damPhenotype.trim()) { setMessage('请填写系列、父本表型和母本表型'); return }
    setBusy(true)
    try {
      const response = await p1Api.simulateGeneticBreeding({ idempotencyKey: newIdempotencyKey(), geneticSimulationRequest: { mode: 'phenotype_table', series: series.trim(), sirePhenotype: sirePhenotype.trim(), damPhenotype: damPhenotype.trim() } as any })
      setResult(response.data)
      setMessage('模拟结果已返回，来源和概率均保留在结果中')
    } catch (cause) { setMessage(cause instanceof Error ? cause.message : '遗传模拟失败') } finally { setBusy(false) }
  }

  async function findTargetCrosses() {
    if (!series.trim() || !targetPhenotype.trim()) { setMessage('请填写系列和目标表型'); return }
    setBusy(true)
    try {
      const response = await geneticApi.listGeneticTargetCrosses({ series: series.trim(), phenotype: targetPhenotype.trim() })
      setTargetCrosses(response?.data?.crosses || response?.crosses || [])
      setMessage(`已找到可产生“${targetPhenotype.trim()}”的 ${response?.data?.crosses?.length || response?.crosses?.length || 0} 组父本组合`)
    } catch (cause) { setMessage(cause instanceof Error ? cause.message : '目标交配检索失败') } finally { setBusy(false) }
  }

  async function compareActual() {
    if (!series.trim() || !sirePhenotype.trim() || !damPhenotype.trim()) { setMessage('请先填写系列、父本表型和母本表型'); return }
    const actualCounts: Record<string, number> = {}
    for (const line of actualCountsText.split('\n').map((item) => item.trim()).filter(Boolean)) {
      const separator = line.lastIndexOf(':')
      const phenotype = separator >= 0 ? line.slice(0, separator).trim() : ''
      const count = separator >= 0 ? Number(line.slice(separator + 1).trim()) : Number.NaN
      if (!phenotype || !Number.isInteger(count) || count < 0) { setMessage(`实际表型格式不正确：${line}；请使用“表型:数量”`); return }
      actualCounts[phenotype] = count
    }
    if (!Object.keys(actualCounts).length) { setMessage('请至少填写一行实际表型数量'); return }
    setBusy(true)
    try {
      const response = await geneticApi.compareGeneticActual({ requestBody: { series: series.trim(), sire_phenotype: sirePhenotype.trim(), dam_phenotype: damPhenotype.trim(), actual_counts: actualCounts, save: true } })
      setActualComparison(response?.data?.comparison || response?.comparison || response)
      setMessage('实际窝次已完成对比并保存到历史反馈')
      await loadReferenceData()
    } catch (cause) { setMessage(cause instanceof Error ? cause.message : '实际表型对比失败') } finally { setBusy(false) }
  }

  const catalogSeries = Array.isArray(catalog?.series) ? catalog.series : []

  return <View style={{ height: '100vh', display: 'flex', flexDirection: 'column', backgroundColor: crayon.paper, backgroundImage: paperGrain }}><NavBar title="遗传工作台" back right={<Tag tone="accent">M4</Tag>} /><ScrollView scrollY type="list" bounces enhanced showScrollbar={false} style={{ flex: 1 }}><SectionList>
    <Section header="遗传档案" footer={message}>
      <FormRow label="个体 ID"><Input value={hamsterId} placeholder="可选" onInput={(event) => setHamsterId(event.detail.value)} /></FormRow>
      <FormRow label="档案名称" divider><Input value={profileName} placeholder="例如：001 的表型档案" onInput={(event) => setProfileName(event.detail.value)} /></FormRow>
      <CapabilityButton capability="write_genetic" block disabled={busy} onClick={() => void saveProfile()}>保存遗传档案</CapabilityButton>
    </Section>
    <Section header="权威表型目录" footer={catalog?.title ? `${catalog.title} · ${catalog.version || ''}` : '从服务端遗传核心表读取'}>
      {catalogSeries.length ? catalogSeries.map((item: any) => <Cell key={item.code} title={item.name || item.code} subtitle={(item.phenotypes || []).join('、')} value={<Tag tone="accent">{item.code}</Tag>} />) : <Cell title="目录尚未返回" subtitle="登录后点击刷新可读取核心表" />}
      <Button block variant="outlined" disabled={busy} onClick={() => void loadReferenceData()}>刷新目录与历史反馈</Button>
    </Section>
    <Section header="配对模拟">
      <FormRow label="系列"><Input value={series} placeholder="例如：poly" onInput={(event) => setSeries(event.detail.value)} /></FormRow>
      <FormRow label="父本表型" divider><Input value={sirePhenotype} placeholder="例如 black" onInput={(event) => setSirePhenotype(event.detail.value)} /></FormRow>
      <FormRow label="母本表型" divider><Input value={damPhenotype} placeholder="例如 cinnamon" onInput={(event) => setDamPhenotype(event.detail.value)} /></FormRow>
      <CapabilityButton capability="write_genetic" block disabled={busy} onClick={() => void simulate()}>运行配对模拟</CapabilityButton>
    </Section>
    {result ? <Section header="模拟结果"><Cell title={`${result.seriesName || result.series || series}`} subtitle={result.notes || result.predictionBasis || ''} value={<Tag tone="success">已完成</Tag>} />{(result.outcomes || []).map((item: any) => <Cell key={item.genotypeKey} title={item.phenotypeLabel} subtitle={item.genotypeKey} value={<Tag>{`${Math.round(Number(item.probability || 0) * 100)}%`}</Tag>} />)}</Section> : null}
    <Section header="目标表型反查父本">
      <FormRow label="目标表型"><Input value={targetPhenotype} placeholder="例如：蜜波利" onInput={(event) => setTargetPhenotype(event.detail.value)} /></FormRow>
      <CapabilityButton capability="write_genetic" block variant="outlined" disabled={busy} onClick={() => void findTargetCrosses()}>查找推荐父本组合</CapabilityButton>
      {targetCrosses.map((item) => <Cell key={`${item.parent_a || item.parentA}-${item.parent_b || item.parentB}`} title={`${item.parent_a || item.parentA} × ${item.parent_b || item.parentB}`} subtitle={`${field(item, 'predictionBasis', 'prediction_basis', '核心表')} · 历史窝数 ${field(item, 'historyLitters', 'history_litter_count', 0)}`} value={<Tag tone="success">{`${Math.round(Number(field(item, 'targetProbability', 'target_probability', 0)) * 100)}%`}</Tag>} />)}
    </Section>
    <Section header="实际窝次对比" footer="每行填写：表型:数量；提交后写入历史反馈，用于后续校准">
      <FormRow label="实际表型数量"><Textarea value={actualCountsText} placeholder="black:3\ncinnamon:2" onInput={(event) => setActualCountsText(event.detail.value)} style={{ minHeight: '96px', width: '100%' }} /></FormRow>
      <CapabilityButton capability="write_genetic" block disabled={busy} onClick={() => void compareActual()}>对比并保存本次反馈</CapabilityButton>
      {actualComparison ? <Cell title={`总数 ${field(actualComparison, 'totalActual', 'total_actual', 0)}`} subtitle={`平均绝对误差 ${Number(field(actualComparison, 'meanAbsError', 'mean_abs_error', 0)).toFixed(3)} · 总变异 ${Number(field(actualComparison, 'totalVariation', 'total_variation', 0)).toFixed(3)}`} value={<Tag tone="success">已保存</Tag>} /> : null}
    </Section>
    <Section header="历史反馈摘要" footer={feedbackPairs.length ? `共 ${feedbackPairs.length} 组组合` : '尚无已保存的实际窝次反馈'}>
      {feedbackPairs.slice(0, 20).map((item) => <Cell key={`${item.series}-${item.sire_phenotype || item.sirePhenotype}-${item.dam_phenotype || item.damPhenotype}`} title={`${item.series} · ${item.sire_phenotype || item.sirePhenotype} × ${item.dam_phenotype || item.damPhenotype}`} subtitle={`样本 ${field(item, 'sampleCount', 'sample_count', 0)} · 平均误差 ${Number(field(item, 'avgMeanAbsError', 'avg_mean_abs_error', 0)).toFixed(3)}`} value={<Tag tone="warning">历史</Tag>} />)}
    </Section>
    <View style={{ height: `${metrics.bottomSafePadding}px` }} />
  </SectionList></ScrollView></View>
}
