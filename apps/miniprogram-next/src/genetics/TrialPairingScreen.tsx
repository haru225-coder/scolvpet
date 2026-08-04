import { Picker, ScrollView, Textarea, View } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { useEffect, useMemo, useState } from 'react'
import { Button, Cell, FormRow, NavBar, Section, SectionList, Tag, metrics, palette } from '@scolvpet/mp-ui'

import { defaultApi, geneticApi, newIdempotencyKey, p1Api } from '../api/client'
import { formatUserError, notifyUserError, presentUserMessage } from '../api/errors'
import { readBreederSession } from '../auth/session'
import { CapabilityButton } from '../components/CapabilityButton'
import {
  GeneticsUiCopy,
  buildGeneticsConclusion,
  decorateOutcomes,
  formatGeneticsPercent,
  humanMissing
} from './genetics-copy'
import { getFallbackPhenotypeCatalog } from './fallback-catalog'

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
  const [message, setMessage] = useState<string>(GeneticsUiCopy.emptyHint)
  const [busy, setBusy] = useState(false)
  const [showPro, setShowPro] = useState(false)
  const [showMore, setShowMore] = useState(false)

  function applyCatalog(nextCatalog: { series: any[] }, note?: string) {
    setCatalog(nextCatalog)
    const seriesList = Array.isArray(nextCatalog?.series) ? nextCatalog.series : []
    if ((!series || !seriesList.some((s) => String(s.code || s.Code) === series)) && seriesList[0]) {
      setSeries(String(seriesList[0].code || seriesList[0].Code || ''))
      const phenos = seriesList[0].phenotypes || seriesList[0].Phenotypes || []
      const firstPheno = phenos[0]
      if (firstPheno) {
        setSirePhenotype(String(firstPheno))
        setDamPhenotype(String(firstPheno))
        setTargetPhenotype(String(firstPheno))
      }
    }
    if (!seriesList.length) {
      setMessage('还没有样子目录，请刷新后再试')
    } else {
      setMessage(note || GeneticsUiCopy.emptyHint)
    }
  }

  async function loadReferenceData() {
    // 分包页冷启动：storage 有会话但内存 token 空 → 目录 401
    if (!readBreederSession()) {
      setMessage('请先登录经营账号')
      applyCatalog(getFallbackPhenotypeCatalog(), '未登录：先用内置目录预览，登录后可试配')
      return
    }
    try {
      const [catalogResponse, feedbackResponse] = await Promise.all([
        geneticApi.listGeneticPhenotypeCatalog(),
        geneticApi.listGeneticFeedbackSummary().catch(() => ({ data: { pairs: [] } }))
      ])
      void defaultApi
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
  const phenotypeOptions: string[] = selectedSeries?.phenotypes || []
  const sireIndex = Math.max(0, phenotypeOptions.indexOf(sirePhenotype))
  const damIndex = Math.max(0, phenotypeOptions.indexOf(damPhenotype))
  const targetIndex = Math.max(0, phenotypeOptions.indexOf(targetPhenotype))

  const seriesCode = useMemo(
    () => String(selectedSeries?.code || series || '').trim(),
    [selectedSeries, series]
  )

  async function simulate() {
    if (!readBreederSession()) {
      const msg = '请先登录经营账号'
      setMessage(msg)
      void presentUserMessage(msg)
      return
    }
    if (!seriesCode || !sirePhenotype.trim() || !damPhenotype.trim()) {
      const msg = '请选择系列、公的样子和母的样子'
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
          sirePhenotype: sirePhenotype.trim(),
          damPhenotype: damPhenotype.trim()
        } as any
      })
      // 生成客户端可能返回 envelope 或已解包 data
      const data = ((response as any)?.data ?? response) as any
      const rawOutcomes = data?.outcomes || data?.tableOutcomes || data?.table_outcomes || []
      const outcomes = decorateOutcomes(rawOutcomes)
      const conclusion = buildGeneticsConclusion({
        notes: data?.notes,
        predictionBasis: data?.predictionBasis || data?.prediction_basis,
        sirePhenotype: data?.sirePhenotype || data?.sire_phenotype || sirePhenotype,
        damPhenotype: data?.damPhenotype || data?.dam_phenotype || damPhenotype,
        sire: data?.sire,
        dam: data?.dam,
        outcomes: rawOutcomes
      })
      setResult({ ...data, outcomes, conclusion })
      setMessage(conclusion.line)
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
      setMessage('对照已保存')
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
    const first = selected?.phenotypes?.[0] ? String(selected.phenotypes[0]) : ''
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
          <Section header="选父母样子" footer={message}>
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
                      setSirePhenotype(phenotypeOptions[Number(event.detail.value)] || '')
                      setResult(null)
                    }}
                  >
                    <Cell title={sirePhenotype || '选择样子'} value={<Tag>选择</Tag>} />
                  </Picker>
                </FormRow>
                <FormRow label="母的样子" divider>
                  <Picker
                    mode="selector"
                    range={phenotypeOptions.length ? phenotypeOptions : ['（请先选系列）']}
                    value={damIndex}
                    onChange={(event) => {
                      if (!requireLogin('试配')) return
                      setDamPhenotype(phenotypeOptions[Number(event.detail.value)] || '')
                      setResult(null)
                    }}
                  >
                    <Cell title={damPhenotype || '选择样子'} value={<Tag>选择</Tag>} />
                  </Picker>
                </FormRow>
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
                  subtitle="以下为模拟概率，不是保证"
                  value={<Tag tone={conclusionTone as any}>{result.conclusion?.tone === 'red' ? '风险' : '结论'}</Tag>}
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
                        setTargetPhenotype(phenotypeOptions[Number(event.detail.value)] || '')
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
