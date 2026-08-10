import { Picker, ScrollView, Textarea, View } from '@tarojs/components'
import Taro, { useRouter } from '@tarojs/taro'
import { useEffect, useMemo, useState } from 'react'
import { Button, Cell, FormRow, NavBar, Section, SectionList, Tag, metrics, palette } from '@scolvpet/mp-ui'

import { newIdempotencyKey } from '../api/runtime-config'
import { geneticApi } from '../api/genetic-api'
import { p1Api } from '../api/p1-api'
import { formatUserError, notifyUserError, presentUserMessage } from '../api/errors'
import { requireBreederSession } from '../auth/dev-session'
import { readBreederSession } from '../auth/session'
import { CapabilityButton } from '../components/CapabilityButton'
import {
  GeneticsUiCopy,
  buildGeneticsConclusion,
  decorateOutcomes,
  formatGeneticsPercent,
  humanMissing,
  humanizePredictionBasis
} from './genetics-copy'
import { getFallbackPhenotypeCatalog } from './fallback-catalog'
import {
  canonicalPhenotypeLabel,
  dedupePhenotypeOptions,
  phenotypeAliasHint,
  phenotypeModeAssumptionNote
} from './phenotype-options'

function field(value: any, camel: string, snake: string, fallback: any = '') {
  return value?.[camel] ?? value?.[snake] ?? fallback
}

/** 兼容 envelope / 直出 / 蛇形字段的目录形状。 */
function normalizeCatalog(raw: any): { series: any[] } {
  const root = raw?.data ?? raw ?? {}
  const nested = root?.data && typeof root.data === 'object' ? root.data : root
  const series =
    (Array.isArray(nested?.series) && nested.series) ||
    (Array.isArray(nested?.Series) && nested.Series) ||
    (Array.isArray(root?.series) && root.series) ||
    []
  return { ...(typeof nested === 'object' && nested ? nested : {}), series }
}

export type TrialPairingScreenProps = {
  /** Tab 页为 true：不显示返回箭头（switchTab 无栈可回） */
  hideBack?: boolean
}

/**
 * 试配模拟器（产品主路径）。
 * 2026-08：不再引导「繁育计划」状态机；本页只做表型试配 + 结果展示。
 * 反查 / 实际对照收在「更多工具」，避免一屏堆成后台表单。
 * Tab 与 packages/genetic/create 共用；hideBack 仅 Tab 传 true。
 */
export default function TrialPairingScreen({ hideBack = false }: TrialPairingScreenProps) {
  const router = useRouter()
  const [series, setSeries] = useState('')
  const [sirePhenotype, setSirePhenotype] = useState('')
  const [damPhenotype, setDamPhenotype] = useState('')
  /** 精确基因型 key（多代续推）；有值时 simulate 走 locus model */
  const [sireGenotypeKey, setSireGenotypeKey] = useState('')
  const [damGenotypeKey, setDamGenotypeKey] = useState('')
  const [targetPhenotype, setTargetPhenotype] = useState('')
  const [actualCountsText, setActualCountsText] = useState('')
  const [result, setResult] = useState<any>(null)
  const [targetCrosses, setTargetCrosses] = useState<any[]>([])
  const [catalog, setCatalog] = useState<any>(null)
  const [feedbackPairs, setFeedbackPairs] = useState<any[]>([])
  const [actualComparison, setActualComparison] = useState<any>(null)
  const [parentInference, setParentInference] = useState<any>(null)
  const [message, setMessage] = useState<string>(GeneticsUiCopy.emptyHint)
  const [busy, setBusy] = useState(false)
  const [showPro, setShowPro] = useState(false)
  const [showMore, setShowMore] = useState(false)
  const [queryApplied, setQueryApplied] = useState(false)

  // 从档案列表 / 深链带入：series、sire_key、dam_key、sire_ph、dam_ph
  useEffect(() => {
    if (queryApplied) return
    const p = router?.params || {}
    const seriesQ = String(p.series || '').trim()
    const sireKey = String(p.sire_key || '').trim()
    const damKey = String(p.dam_key || '').trim()
    const sirePh = String(p.sire_ph || '').trim()
    const damPh = String(p.dam_ph || '').trim()
    const side = String(p.side || '').trim()
    // 兼容 side=sire|dam 单侧带 key
    const sideKey = String(p[`${side}_key`] || p.key || '').trim()
    const sidePh = String(p[`${side}_ph`] || p.ph || '').trim()

    let applied = false
    if (seriesQ) {
      setSeries(seriesQ)
      applied = true
    }
    if (sireKey || (side === 'sire' && sideKey)) {
      const k = sireKey || sideKey
      setSireGenotypeKey(k)
      if (sirePh || (side === 'sire' && sidePh)) setSirePhenotype(sirePh || sidePh)
      applied = true
    } else if (sirePh || (side === 'sire' && sidePh)) {
      // 无基因型 key 时仍带表型（个体档案试配入口）
      setSirePhenotype(sirePh || sidePh)
      applied = true
    }
    if (damKey || (side === 'dam' && sideKey)) {
      const k = damKey || sideKey
      setDamGenotypeKey(k)
      if (damPh || (side === 'dam' && sidePh)) setDamPhenotype(damPh || sidePh)
      applied = true
    } else if (damPh || (side === 'dam' && sidePh)) {
      setDamPhenotype(damPh || sidePh)
      applied = true
    }
    if (applied) {
      const hasKey = Boolean(sireKey || damKey || sideKey)
      setMessage(hasKey ? '已从档案/深链带入基因型，可补全另一侧后试配' : '已从个体带入样子，可补全另一侧后试配')
      if (hasKey) setShowPro(true)
    }
    setQueryApplied(true)
  }, [router?.params, queryApplied])

  function clearGenotypePins() {
    setSireGenotypeKey('')
    setDamGenotypeKey('')
  }

  /** 把某基因型钉到公/母，供下一轮试配（③ 多代）。 */
  function pinGenotype(side: 'sire' | 'dam', key: string, displayLabel?: string) {
    const k = String(key || '').trim()
    if (!k || k === '—') {
      void presentUserMessage('没有可用的基因型 key')
      return
    }
    const label = String(displayLabel || '').trim()
    // 尽量把表型也同步成展示名（去掉携带括号）
    const phenoRaw = label.includes('（') ? label.slice(0, label.indexOf('（')).trim() : label
    const pheno = phenoRaw ? canonicalPhenotypeLabel(seriesCode, phenoRaw) : ''
    if (side === 'sire') {
      setSireGenotypeKey(k)
      if (pheno) setSirePhenotype(pheno)
    } else {
      setDamGenotypeKey(k)
      if (pheno) setDamPhenotype(pheno)
    }
    setMessage(
      side === 'sire'
        ? `已把「${label || k}」设为公本基因型，可再点试配`
        : `已把「${label || k}」设为母本基因型，可再点试配`
    )
    void Taro.showToast({ title: side === 'sire' ? '已设为公' : '已设为母', icon: 'success', duration: 900 })
  }

  function offerPinGenotype(key: string, displayLabel?: string) {
    const k = String(key || '').trim()
    if (!k || k === '—') {
      void presentUserMessage('没有可用的基因型 key')
      return
    }
    const label = String(displayLabel || k).trim()
    void Taro.showActionSheet({
      itemList: ['设为公本（下一配）', '设为母本（下一配）', '公母都设成这个（自交）']
    })
      .then((res) => {
        const idx = Number(res.tapIndex)
        if (idx === 0) pinGenotype('sire', k, label)
        else if (idx === 1) pinGenotype('dam', k, label)
        else if (idx === 2) {
          pinGenotype('sire', k, label)
          pinGenotype('dam', k, label)
          setMessage(`公母都钉成「${label}」，可点试配看自交`)
        }
      })
      .catch(() => undefined)
  }

  function genotypeMapFromInference(side: 'sire' | 'dam') {
    const top = parentInference?.hypotheses?.[0]
    if (!top) return null
    const key = String(
      side === 'sire'
        ? top.sire_genotype_key || top.sireGenotypeKey || ''
        : top.dam_genotype_key || top.damGenotypeKey || ''
    ).trim()
    const display = String(
      side === 'sire' ? top.sire_display || top.sireDisplay || '' : top.dam_display || top.damDisplay || ''
    ).trim()
    if (!key) return null
    const alleles: Record<string, string> = { series: seriesCode, key }
    for (const part of key.split('|')) {
      const [k, v] = part.split('=')
      if (k && v) alleles[k.trim()] = v.trim()
    }
    const phenoRaw = display.includes('（') ? display.slice(0, display.indexOf('（')).trim() : display
    return {
      key,
      display,
      alleles,
      phenotypeLabel: phenoRaw || canonicalPhenotypeLabel(seriesCode, display)
    }
  }

  async function saveInferredParentsAsProfiles() {
    if (!readBreederSession()) {
      void presentUserMessage('请先登录经营账号')
      return
    }
    if (!seriesCode || !parentInference?.hypotheses?.[0]) {
      void presentUserMessage('还没有反推结果可保存')
      return
    }
    const sire = genotypeMapFromInference('sire')
    const dam = genotypeMapFromInference('dam')
    if (!sire || !dam) {
      void presentUserMessage('反推结果缺少基因型 key')
      return
    }
    setBusy(true)
    try {
      const stamp = new Date().toISOString().slice(0, 16).replace('T', ' ')
      const pct = Math.round(Number(parentInference.hypotheses[0].probability || 0) * 100)
      const note = `试配窝次反推 · 联合后验约 ${pct}% · ${stamp}`
      await p1Api.createGeneticProfile({
        idempotencyKey: newIdempotencyKey(),
        createGeneticProfileRequest: {
          name: `反推·公·${sire.display || sire.phenotypeLabel}`,
          confidence: 'inferred',
          phenotype: {
            series: seriesCode,
            label: sire.phenotypeLabel,
            source: 'parent_inference'
          },
          genotype: sire.alleles,
          notes: note
        } as any
      })
      await p1Api.createGeneticProfile({
        idempotencyKey: newIdempotencyKey(),
        createGeneticProfileRequest: {
          name: `反推·母·${dam.display || dam.phenotypeLabel}`,
          confidence: 'inferred',
          phenotype: {
            series: seriesCode,
            label: dam.phenotypeLabel,
            source: 'parent_inference'
          },
          genotype: dam.alleles,
          notes: note
        } as any
      })
      setMessage(`已保存两条 inferred 遗传档案（公/母）· 后验约 ${pct}%`)
      void Taro.showToast({ title: '档案已保存', icon: 'success', duration: 1200 })
    } catch (cause) {
      setMessage(await notifyUserError(cause, '保存遗传档案失败'))
    } finally {
      setBusy(false)
    }
  }

  function applyInferredParentsAsPins() {
    const top = parentInference?.hypotheses?.[0]
    if (!top) {
      void presentUserMessage('还没有反推结果')
      return
    }
    const sk = String(top.sire_genotype_key || top.sireGenotypeKey || '').trim()
    const dk = String(top.dam_genotype_key || top.damGenotypeKey || '').trim()
    const sd = String(top.sire_display || top.sireDisplay || '').trim()
    const dd = String(top.dam_display || top.damDisplay || '').trim()
    if (sk) {
      setSireGenotypeKey(sk)
      if (sd) setSirePhenotype(sd.includes('（') ? sd.slice(0, sd.indexOf('（')).trim() : sd)
    }
    if (dk) {
      setDamGenotypeKey(dk)
      if (dd) setDamPhenotype(dd.includes('（') ? dd.slice(0, dd.indexOf('（')).trim() : dd)
    }
    setShowMore(false)
    setMessage(`已用反推亲本：${sd || sk} × ${dd || dk}，点试配看下一代`)
    void Taro.showToast({ title: '已填入亲本', icon: 'success', duration: 1000 })
    try {
      setTimeout(() => {
        void Taro.pageScrollTo({ selector: '#genetic-result', duration: 280 }).catch(() => undefined)
      }, 80)
    } catch {
      // ignore
    }
  }

  function applyCatalog(nextCatalog: { series: any[] }, note?: string) {
    setCatalog(nextCatalog)
    const seriesList = Array.isArray(nextCatalog?.series) ? nextCatalog.series : []
    if ((!series || !seriesList.some((s) => String(s.code || s.Code) === series)) && seriesList[0]) {
      const code = String(seriesList[0].code || seriesList[0].Code || '')
      setSeries(code)
      clearGenotypePins()
      const phenos = dedupePhenotypeOptions(code, seriesList[0].phenotypes || seriesList[0].Phenotypes || [])
      const firstPheno = phenos[0]
      if (firstPheno) {
        setSirePhenotype(firstPheno)
        setDamPhenotype(firstPheno)
        setTargetPhenotype(firstPheno)
      }
    }
    if (!seriesList.length) {
      setMessage('还没有样子目录，请刷新后再试')
    } else {
      setMessage(note || GeneticsUiCopy.emptyHint)
    }
  }

  async function loadReferenceData() {
    // 开发：Tab 首屏可能先于登录页；先 require 演示会话再读目录。
    // 生产：只 hydrate；无会话则内置目录预览 + 提示登录。
    const session = await requireBreederSession()
    if (!session) {
      setMessage('请先登录经营账号')
      applyCatalog(getFallbackPhenotypeCatalog(), '未登录：先用内置目录预览，登录后可试配')
      return
    }
    try {
      const [catalogResponse, feedbackResponse] = await Promise.all([
        geneticApi.listGeneticPhenotypeCatalog(),
        geneticApi.listGeneticFeedbackSummary().catch(() => ({ data: { pairs: [] } }))
      ])
      const nextCatalog = normalizeCatalog(catalogResponse)
      const seriesList = Array.isArray(nextCatalog?.series) ? nextCatalog.series : []
      if (seriesList.length) {
        applyCatalog(nextCatalog)
      } else {
        applyCatalog(getFallbackPhenotypeCatalog(), '服务端目录为空，已用内置表型目录')
      }
      const fb = (feedbackResponse as any)?.data ?? feedbackResponse
      setFeedbackPairs(fb?.pairs || fb?.data?.pairs || [])
    } catch (cause) {
      const err = await formatUserError(cause, '目录读取失败')
      applyCatalog(getFallbackPhenotypeCatalog(), `${err} · 已切换内置目录，可继续选样子试配`)
    }
  }

  useEffect(() => {
    void loadReferenceData()
  }, [])

  const catalogSeries = Array.isArray(catalog?.series) ? catalog.series : []
  const seriesLabels = catalogSeries.map((item: any) => item.name || item.code || '系列')
  const seriesIndex = Math.max(0, catalogSeries.findIndex((item: any) => item.code === series))
  const selectedSeries = catalogSeries[seriesIndex]
  const seriesCode = useMemo(
    () => String(selectedSeries?.code || series || '').trim(),
    [selectedSeries, series]
  )
  const phenotypeOptions: string[] = useMemo(
    () => dedupePhenotypeOptions(seriesCode, selectedSeries?.phenotypes || selectedSeries?.Phenotypes || []),
    [seriesCode, selectedSeries]
  )
  const sireIndex = Math.max(0, phenotypeOptions.indexOf(canonicalPhenotypeLabel(seriesCode, sirePhenotype)))
  const damIndex = Math.max(0, phenotypeOptions.indexOf(canonicalPhenotypeLabel(seriesCode, damPhenotype)))
  const targetIndex = Math.max(
    0,
    phenotypeOptions.indexOf(canonicalPhenotypeLabel(seriesCode, targetPhenotype))
  )
  const hasExactGenotype = Boolean(sireGenotypeKey || damGenotypeKey)
  const formFooter = [
    message,
    phenotypeModeAssumptionNote(seriesCode, hasExactGenotype)
  ]
    .filter(Boolean)
    .join(' · ')

  async function simulate() {
    if (!readBreederSession()) {
      const msg = '请先登录经营账号'
      setMessage(msg)
      void presentUserMessage(msg)
      return
    }
    // 有 genotype key 时可只靠 key；否则必须有表型
    if (!seriesCode) {
      const msg = '请选择系列'
      setMessage(msg)
      void presentUserMessage(msg)
      return
    }
    if (!sireGenotypeKey && !sirePhenotype.trim()) {
      const msg = '请选择公的样子，或从专业结果里钉一个基因型'
      setMessage(msg)
      void presentUserMessage(msg)
      return
    }
    if (!damGenotypeKey && !damPhenotype.trim()) {
      const msg = '请选择母的样子，或从专业结果里钉一个基因型'
      setMessage(msg)
      void presentUserMessage(msg)
      return
    }
    setBusy(true)
    setResult(null)
    setMessage('正在计算…')
    try {
      const response = await p1Api.simulateGeneticBreeding({
        idempotencyKey: newIdempotencyKey(),
        geneticSimulationRequest: {
          mode: 'phenotype_table',
          series: seriesCode,
          sirePhenotype: sirePhenotype.trim() || undefined,
          damPhenotype: damPhenotype.trim() || undefined,
          sireGenotypeKey: sireGenotypeKey.trim() || undefined,
          damGenotypeKey: damGenotypeKey.trim() || undefined
        } as any
      })
      // 生成客户端可能返回 envelope 或已解包 data
      const data = ((response as any)?.data ?? response) as any
      // Prefer table_outcomes: carries carrier_summary + genotype_breakdown for ③
      const rawOutcomes =
        data?.tableOutcomes ||
        data?.table_outcomes ||
        data?.outcomes ||
        []
      const outcomes = decorateOutcomes(rawOutcomes)
      const predictionBasis = data?.predictionBasis || data?.prediction_basis
      const conclusion = buildGeneticsConclusion({
        notes: data?.notes,
        predictionBasis,
        sirePhenotype: data?.sirePhenotype || data?.sire_phenotype || sirePhenotype,
        damPhenotype: data?.damPhenotype || data?.dam_phenotype || damPhenotype,
        sire: data?.sire,
        dam: data?.dam,
        outcomes: rawOutcomes
      })
      setResult({
        ...data,
        outcomes,
        conclusion,
        predictionBasis,
        basisLabel: humanizePredictionBasis(predictionBasis)
      })
      setMessage(`${conclusion.line} · ${humanizePredictionBasis(predictionBasis)}`)
      void Taro.showToast({ title: '模拟完成', icon: 'success', duration: 1200 })
      // 滚到结果区（小程序 pageScrollTo；失败静默）
      try {
        setTimeout(() => {
          void Taro.pageScrollTo({ selector: '#genetic-result', duration: 280 }).catch(() => undefined)
        }, 80)
      } catch {
        // ignore
      }
    } catch (cause) {
      const msg = await notifyUserError(cause, GeneticsUiCopy.missingData)
      setMessage(msg)
    } finally {
      setBusy(false)
    }
  }

  async function findTargetCrosses() {
    if (!readBreederSession()) {
      const msg = '请先登录经营账号'
      setMessage(msg)
      void presentUserMessage(msg)
      return
    }
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
      const crosses = response?.data?.crosses || response?.crosses || []
      setTargetCrosses(crosses)
      setMessage(`找到 ${crosses.length} 组可能生出「${targetPhenotype.trim()}」的配对`)
    } catch (cause) {
      setMessage(await notifyUserError(cause, '反查失败，请稍后重试'))
    } finally {
      setBusy(false)
    }
  }

  async function compareActual() {
    if (!readBreederSession()) {
      const msg = '请先登录经营账号'
      setMessage(msg)
      void presentUserMessage(msg)
      return
    }
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

      // ④ 家系反推：用同一窝计数估公/母基因型后验
      let inferNote = ''
      try {
        const inferred = await geneticApi.inferGeneticParents({
          requestBody: {
            series: seriesCode,
            sire_phenotype: sirePhenotype.trim(),
            dam_phenotype: damPhenotype.trim(),
            actual_counts: actualCounts
          } as any
        })
        const data = (inferred as any)?.data ?? inferred
        setParentInference(data)
        const top = data?.hypotheses?.[0]
        if (top) {
          const pct = Math.round(Number(top.probability || 0) * 100)
          inferNote = ` · 最可能亲本 ${top.sire_display || top.sireDisplay} × ${top.dam_display || top.damDisplay}（${pct}%）`
        }
      } catch {
        setParentInference(null)
      }

      setMessage(`对照已保存${inferNote}`)
      await loadReferenceData()
    } catch (cause) {
      setMessage(await notifyUserError(cause, '对照保存失败'))
    } finally {
      setBusy(false)
    }
  }

  function requireLogin(action: string): boolean {
    if (readBreederSession()) return true
    const msg = `请先登录经营账号再${action}`
    setMessage(msg)
    void presentUserMessage(msg)
    return false
  }

  function pickSeries(index: number) {
    // 未登录也能预览目录，但一点选就拦，避免「选完公母才说要登录」
    if (!requireLogin('试配')) return
    const selected = catalogSeries[index]
    const code = String(selected?.code || '')
    setSeries(code)
    clearGenotypePins()
    const phenos = dedupePhenotypeOptions(code, selected?.phenotypes || selected?.Phenotypes || [])
    const first = phenos[0] || ''
    if (first) {
      setSirePhenotype(first)
      setDamPhenotype(first)
      setTargetPhenotype(first)
    }
    setResult(null)
  }

  const conclusionTone =
    result?.conclusion?.tone === 'red'
      ? 'danger'
      : result?.conclusion?.tone === 'green'
        ? 'success'
        : result?.conclusion?.tone === 'orange'
          ? 'warning'
          : 'accent'

  return (
    <View
      style={{
        height: '100vh',
        display: 'flex',
        flexDirection: 'column',
        backgroundColor: palette.systemBackground
      }}
    >
      <NavBar title="试配模拟" back={!hideBack} />
      <ScrollView scrollY type="list" bounces enhanced showScrollbar={false} style={{ flex: 1 }}>
        <SectionList>
          <Section header="选父母样子" footer={formFooter}>
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
                    onChange={(event) => {
                      if (!requireLogin('试配')) return
                      const next = phenotypeOptions[Number(event.detail.value)] || ''
                      setSirePhenotype(next)
                      setSireGenotypeKey('')
                      setResult(null)
                    }}
                  >
                    <Cell
                      title={canonicalPhenotypeLabel(seriesCode, sirePhenotype) || '选择样子'}
                      subtitle={
                        sireGenotypeKey
                          ? `基因型已钉：${sireGenotypeKey}`
                          : phenotypeAliasHint(seriesCode, canonicalPhenotypeLabel(seriesCode, sirePhenotype)) ||
                            undefined
                      }
                      value={sireGenotypeKey ? <Tag tone="warning">精确</Tag> : <Tag>选择</Tag>}
                    />
                  </Picker>
                </FormRow>
                <FormRow label="母的样子" divider>
                  <Picker
                    mode="selector"
                    range={phenotypeOptions.length ? phenotypeOptions : ['（请先选系列）']}
                    value={damIndex}
                    onChange={(event) => {
                      if (!requireLogin('试配')) return
                      const next = phenotypeOptions[Number(event.detail.value)] || ''
                      setDamPhenotype(next)
                      setDamGenotypeKey('')
                      setResult(null)
                    }}
                  >
                    <Cell
                      title={canonicalPhenotypeLabel(seriesCode, damPhenotype) || '选择样子'}
                      subtitle={
                        damGenotypeKey
                          ? `基因型已钉：${damGenotypeKey}`
                          : phenotypeAliasHint(seriesCode, canonicalPhenotypeLabel(seriesCode, damPhenotype)) ||
                            undefined
                      }
                      value={damGenotypeKey ? <Tag tone="warning">精确</Tag> : <Tag>选择</Tag>}
                    />
                  </Picker>
                </FormRow>
                {sireGenotypeKey || damGenotypeKey ? (
                  <Cell
                    title="清除精确基因型"
                    subtitle="回到只按样子（表型）试配"
                    value={<Tag>清除</Tag>}
                    onClick={() => {
                      clearGenotypePins()
                      setMessage('已清除精确基因型，下次按样子试配')
                    }}
                  />
                ) : null}
              </>
            ) : (
              <Cell title="还没有样子目录" subtitle="点下方刷新，或先配置物种规则" />
            )}
            {/* 主按钮不用 CapabilityButton：避免能力位缺失时按钮整颗消失像「点不动」 */}
            <Button block disabled={busy} onClick={() => void simulate()}>
              {busy ? '计算中…' : GeneticsUiCopy.runCta}
            </Button>
            <Button block variant="outlined" disabled={busy} onClick={() => void loadReferenceData()}>
              刷新目录
            </Button>
          </Section>

          <View id="genetic-result">
            {result ? (
              <Section
                header={GeneticsUiCopy.resultHeading}
                footer={`${humanMissing(result.sirePhenotype || sirePhenotype)}（公）× ${humanMissing(result.damPhenotype || damPhenotype)}（母）`}
              >
                <Cell
                  title={result.conclusion?.line || GeneticsUiCopy.resultHeading}
                  subtitle={`${result.basisLabel || humanizePredictionBasis(result.predictionBasis)} · 概率不是保证`}
                  value={<Tag tone={conclusionTone as any}>{result.conclusion?.tone === 'red' ? '风险' : '结论'}</Tag>}
                />
                <Cell
                  title={result.basisLabel || humanizePredictionBasis(result.predictionBasis)}
                  subtitle={
                    sireGenotypeKey || damGenotypeKey
                      ? `本轮使用了精确基因型${sireGenotypeKey ? ' · 公' : ''}${damGenotypeKey ? ' · 母' : ''}`
                      : '表内配对走权威表；表外由位点模型补算'
                  }
                  value={<Tag tone="warning">依据</Tag>}
                />
                {(result.outcomes || []).length ? (
                  (result.outcomes || []).map((item: any) => (
                    <Cell
                      key={item.genotypeKey || item.displayName}
                      title={item.displayName || humanMissing(item.phenotypeLabel)}
                      subtitle={item.aboutLabel || ''}
                      value={<Tag tone="success">{item.percentLabel || formatGeneticsPercent(item.probability)}</Tag>}
                    />
                  ))
                ) : (
                  <Cell title="没有算出结果" subtitle={GeneticsUiCopy.missingData} />
                )}
                <Cell
                  title={showPro ? '收起专业信息' : GeneticsUiCopy.professionalSectionTitle}
                  subtitle={showPro ? '点某一基因型 → 选公/母/自交' : '展开后点选基因型做多代续推'}
                  value={<Tag>{showPro ? '已展开' : '折叠'}</Tag>}
                  onClick={() => setShowPro((v) => !v)}
                />
                {showPro
                  ? (result.outcomes || []).flatMap((item: any) => {
                      const rows = (item.genotypeBreakdown || []).length
                        ? item.genotypeBreakdown
                        : [
                            {
                              key: item.professionalKey || item.genotypeKey || '—',
                              displayLabel: item.displayName,
                              percentLabel: item.percentLabel,
                              carrierTags: []
                            }
                          ]
                      return rows.map((g: any, idx: number) => {
                        const key = g.key || item.professionalKey || '—'
                        const label = g.displayLabel || g.key || item.displayName || '—'
                        return (
                          <Cell
                            key={`pro-${item.displayName}-${key}-${idx}`}
                            title={label}
                            subtitle={[key, ...(g.carrierTags || []), '点选设为亲本'].filter(Boolean).join(' · ')}
                            value={<Tag tone="warning">{g.percentLabel || item.percentLabel}</Tag>}
                            onClick={() => offerPinGenotype(key, label)}
                          />
                        )
                      })
                    })
                  : null}
              </Section>
            ) : (
              <Section header={GeneticsUiCopy.resultHeading}>
                <Cell title="还没有结果" subtitle="选好公母样子后点「试配一下」" />
              </Section>
            )}
          </View>

          <Section header="更多工具">
            <Cell
              title={showMore ? '收起反查与对照' : '反查配对 / 实际窝次对照'}
              subtitle="日常试配一般用不到"
              value={<Tag>{showMore ? '收起' : '展开'}</Tag>}
              onClick={() => setShowMore((v) => !v)}
            />
          </Section>

          {showMore ? (
            <>
              <Section header="想要某种样子，反查怎么配">
                {phenotypeOptions.length ? (
                  <FormRow label="目标样子">
                    <Picker
                      mode="selector"
                      range={phenotypeOptions}
                      value={targetIndex}
                      onChange={(event) =>
                        setTargetPhenotype(
                          phenotypeOptions[Number(event.detail.value)] || ''
                        )
                      }
                    >
                      <Cell title={targetPhenotype || '选择样子'} value={<Tag>选择</Tag>} />
                    </Picker>
                  </FormRow>
                ) : (
                  <Cell title="请先选系列" />
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
                {parentInference?.hypotheses?.[0] ? (
                  <>
                    <Cell
                      title={`亲本反推：${parentInference.hypotheses[0].sire_display || parentInference.hypotheses[0].sireDisplay || '公'} × ${parentInference.hypotheses[0].dam_display || parentInference.hypotheses[0].damDisplay || '母'}`}
                      subtitle={`联合后验 ${Math.round(Number(parentInference.hypotheses[0].probability || 0) * 100)}% · 公 ${parentInference.sire_marginal?.[0]?.display_label || parentInference.sireMarginal?.[0]?.displayLabel || '—'} / 母 ${parentInference.dam_marginal?.[0]?.display_label || parentInference.damMarginal?.[0]?.displayLabel || '—'}`}
                      value={
                        <Tag tone="warning">{`${Math.round(Number(parentInference.hypotheses[0].probability || 0) * 100)}%`}</Tag>
                      }
                    />
                    <Cell
                      title="用这对亲本再试配"
                      subtitle="把反推的公/母基因型钉进试配，再点「试配一下」"
                      value={<Tag tone="success">填入</Tag>}
                      onClick={() => applyInferredParentsAsPins()}
                    />
                    <Cell
                      title="保存为遗传档案"
                      subtitle="confidence=inferred · 写入公/母两条档案"
                      value={<Tag tone="warning">保存</Tag>}
                      onClick={() => void saveInferredParentsAsProfiles()}
                    />
                  </>
                ) : null}
                {actualComparison ? (
                  <Cell
                    title={`总数 ${field(actualComparison, 'totalActual', 'total_actual', 0)}`}
                    subtitle={`平均误差 ${Number(field(actualComparison, 'meanAbsError', 'mean_abs_error', 0)).toFixed(3)}`}
                    value={<Tag tone="success">已保存</Tag>}
                  />
                ) : null}
              </Section>

              <Section
                header="历史对照"
                footer={feedbackPairs.length ? `共 ${feedbackPairs.length} 组` : '还没有对照记录'}
              >
                {feedbackPairs.slice(0, 20).map((item) => (
                  <Cell
                    key={`${item.series}-${item.sire_phenotype || item.sirePhenotype}-${item.dam_phenotype || item.damPhenotype}`}
                    title={`${item.sire_phenotype || item.sirePhenotype} × ${item.dam_phenotype || item.damPhenotype}`}
                    subtitle={`样本 ${field(item, 'sampleCount', 'sample_count', 0)} · 平均误差 ${Number(field(item, 'avgMeanAbsError', 'avg_mean_abs_error', 0)).toFixed(3)}`}
                    value={<Tag tone="warning">历史</Tag>}
                  />
                ))}
              </Section>
            </>
          ) : null}

          <View style={{ height: `${metrics.bottomSafePadding}px` }} />
        </SectionList>
      </ScrollView>
    </View>
  )
}
