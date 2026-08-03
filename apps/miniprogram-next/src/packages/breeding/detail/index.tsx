import { Input, Picker, ScrollView, View } from '@tarojs/components'
import { useLoad } from '@tarojs/taro'
import { useCallback, useState } from 'react'
import {
  Cell,
  Empty,
  FormRow,
  NavBar,
  Section,
  SectionList,
  Tag,
  metrics,
  palette
} from '@scolvpet/mp-ui'

import { defaultApi, newIdempotencyKey } from '../../../api/client'
import { CapabilityButton } from '../../../components/CapabilityButton'
import { humanShortLabel } from '../../../utils/tab-routes'

type PlanData = {
  id: string
  name?: string
  sireId: string
  damId: string
  state?: string
  version?: number
  activePairingAttemptId?: string | null
  litterId?: string | null
  plannedPairingAt?: string | null
}

type Option = { id: string; label: string }

const OBSERVATION_OPTIONS = [
  { value: 'mating_observed', label: '已见配' },
  { value: 'no_mating', label: '未见配' }
]

const PAIRING_RESULT_OPTIONS = [
  { value: 'effective', label: '有效' },
  { value: 'uncertain', label: '不确定' },
  { value: 'ineffective', label: '无效' },
  { value: 'safety_stop', label: '安全中止' }
]

const DAM_STATUS_OPTIONS = [
  { value: 'stable', label: '稳定' },
  { value: 'needs_observation', label: '需观察' },
  { value: 'requires_care', label: '需护理' }
]

function enclosureLabel(item: any) {
  const name = String(item?.name || item?.code || '').trim()
  return name || item?.id || '笼舍'
}

export default function BreedingDetailPage() {
  const [planId, setPlanId] = useState('')
  const [plan, setPlan] = useState<PlanData | null>(null)
  const [attempts, setAttempts] = useState<any[]>([])
  const [enclosures, setEnclosures] = useState<Option[]>([])
  const [enclosureId, setEnclosureId] = useState('')
  const [attemptId, setAttemptId] = useState('')
  const [sireDestinationEnclosureId, setSireDestinationEnclosureId] = useState('')
  const [damDestinationEnclosureId, setDamDestinationEnclosureId] = useState('')
  const [pairingResult, setPairingResult] = useState('effective')
  const [observationType, setObservationType] = useState('mating_observed')
  const [observationNote, setObservationNote] = useState('')
  const [birthCount, setBirthCount] = useState('')
  const [birthEnclosureId, setBirthEnclosureId] = useState('')
  const [damStatus, setDamStatus] = useState('stable')
  const [birthReason, setBirthReason] = useState('正常出生')
  const [message, setMessage] = useState('正在读取繁育计划…')
  const [busy, setBusy] = useState(false)

  const load = useCallback(async (id: string) => {
    try {
      const [detail, attemptResponse, enclosureResponse] = await Promise.all([
        defaultApi.getBreedingPlan({ planId: id }),
        defaultApi.listPairingAttempts({ planId: id, limit: 30 }),
        defaultApi.listEnclosures({ limit: 100 }).catch(() => ({ data: [] as any[] }))
      ])
      const nextPlan = detail.data as PlanData
      const nextAttempts = attemptResponse.data || []
      const enclosureOpts = ((enclosureResponse as any).data || []).map((item: any) => ({
        id: item.id,
        label: enclosureLabel(item)
      }))
      setPlan(nextPlan)
      setAttempts(nextAttempts)
      setEnclosures(enclosureOpts)
      setAttemptId(nextPlan.activePairingAttemptId || nextAttempts[0]?.id || '')
      if (!enclosureId && enclosureOpts[0]) setEnclosureId(enclosureOpts[0].id)
      if (!sireDestinationEnclosureId && enclosureOpts[0]) setSireDestinationEnclosureId(enclosureOpts[0].id)
      if (!damDestinationEnclosureId && enclosureOpts[1]) {
        setDamDestinationEnclosureId(enclosureOpts[1].id)
      } else if (!damDestinationEnclosureId && enclosureOpts[0]) {
        setDamDestinationEnclosureId(enclosureOpts[0].id)
      }
      setMessage(
        enclosureOpts.length
          ? '选好笼舍与观察类型后，按步骤推进'
          : '暂无笼舍列表，请先在系统中建笼舍'
      )
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : '繁育计划读取失败')
    }
  }, [])

  useLoad((options) => {
    const id = String(options?.id || '')
    setPlanId(id)
    if (id) void load(id)
    else setMessage('缺少繁育计划')
  })

  async function runAction(action: () => Promise<void>, success: string) {
    setBusy(true)
    try {
      await action()
      setMessage(success)
      if (planId) await load(planId)
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : '操作失败')
    } finally {
      setBusy(false)
    }
  }

  function startPairing() {
    if (!plan || !enclosureId) {
      setMessage(enclosures.length ? '请选择配对笼舍' : '没有可选笼舍')
      return
    }
    void runAction(async () => {
      await defaultApi.startPairing({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: String(plan.version ?? 0),
        planId,
        startPairingRequest: {
          enclosureId,
          startedAt: new Date(),
          timezone: 'Asia/Taipei'
        }
      })
    }, '配对已开始')
  }

  function recordObservation() {
    if (!plan || !attemptId) {
      setMessage(attempts.length ? '请选择配对尝试' : '还没有配对尝试，请先开始配对')
      return
    }
    void runAction(async () => {
      await defaultApi.recordPairingObservation({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: String(plan.version ?? 0),
        attemptId,
        recordObservationRequest: {
          observedAt: new Date(),
          type: observationType,
          severity: 'info',
          notes: observationNote.trim() || null
        } as any
      })
    }, '配对观察已记录')
  }

  function startGestation() {
    if (!plan || !attemptId) {
      setMessage('请先选择配对尝试')
      return
    }
    void runAction(async () => {
      await defaultApi.startGestationMonitoring({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: String(plan.version ?? 0),
        planId,
        startGestationRequest: {
          pairingAttemptId: attemptId,
          result: 'effective',
          baselineAt: new Date(),
          timezone: 'Asia/Taipei'
        }
      })
    }, '已进入孕期观察')
  }

  function separatePairing() {
    if (!plan || !attemptId || !sireDestinationEnclosureId || !damDestinationEnclosureId) {
      setMessage('请选择配对尝试，以及公、母去向笼舍')
      return
    }
    if (sireDestinationEnclosureId === damDestinationEnclosureId) {
      setMessage('公、母必须去不同笼舍')
      return
    }
    void runAction(async () => {
      await defaultApi.separatePairing({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: String(plan.version ?? 0),
        attemptId,
        separatePairingRequest: {
          endedAt: new Date(),
          separatedAt: new Date(),
          result: pairingResult,
          sireDestinationEnclosureId,
          damDestinationEnclosureId,
          timezone: 'Asia/Taipei'
        } as any
      })
    }, '已结束配对并分笼')
  }

  function confirmBirth() {
    if (!plan) return
    const count = Number(birthCount)
    if (!Number.isInteger(count) || count < 0) {
      setMessage('请填写存活数')
      return
    }
    void runAction(async () => {
      await defaultApi.confirmBirth({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: String(plan.version ?? 0),
        planId,
        confirmBirthRequest: {
          liveCount: count,
          enclosureId: birthEnclosureId || null,
          damStatus,
          reason: birthReason.trim() || '正常出生',
          bornAt: new Date(),
          timezone: 'Asia/Taipei'
        } as any
      })
    }, '出生确认已提交')
  }

  function completePlan() {
    if (!plan) return
    void runAction(async () => {
      await defaultApi.completeBreedingPlan({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: String(plan.version ?? 0),
        planId,
        completeBreedingPlanRequest: {
          completedAt: new Date(),
          timezone: 'Asia/Taipei'
        }
      })
    }, '繁育计划已完成')
  }

  function publishPlan() {
    if (!plan || !enclosureId) {
      setMessage(enclosures.length ? '发布前请选择配对笼舍' : '没有可选笼舍')
      return
    }
    void runAction(async () => {
      await defaultApi.publishBreedingPlan({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: String(plan.version ?? 0),
        planId,
        publishBreedingPlanRequest: {
          plannedPairingAt: new Date(),
          pairingEnclosureId: enclosureId,
          timezone: 'Asia/Taipei'
        }
      })
    }, '繁育计划已发布')
  }

  const enclosureIndex = Math.max(0, enclosures.findIndex((item) => item.id === enclosureId))
  const sireDestIndex = Math.max(0, enclosures.findIndex((item) => item.id === sireDestinationEnclosureId))
  const damDestIndex = Math.max(0, enclosures.findIndex((item) => item.id === damDestinationEnclosureId))
  const birthEncIndex = Math.max(0, enclosures.findIndex((item) => item.id === birthEnclosureId))
  const attemptLabels = attempts.map((item, index) => {
    const status = humanShortLabel(item.status || 'pairing')
    const cage = item.enclosureName || item.enclosureCode || (item.enclosureId ? '已选笼舍' : '笼舍未记')
    return `第 ${index + 1} 次 · ${status} · ${cage}`
  })
  const attemptIndex = Math.max(0, attempts.findIndex((item) => item.id === attemptId))
  const obsIndex = Math.max(0, OBSERVATION_OPTIONS.findIndex((o) => o.value === observationType))
  const resultIndex = Math.max(0, PAIRING_RESULT_OPTIONS.findIndex((o) => o.value === pairingResult))
  const damIndex = Math.max(0, DAM_STATUS_OPTIONS.findIndex((o) => o.value === damStatus))

  return (
    <View style={{ height: '100vh', display: 'flex', flexDirection: 'column', backgroundColor: palette.systemBackground }}>
      <NavBar title={plan?.name || '繁育计划详情'} back />
      <ScrollView scrollY type="list" bounces enhanced showScrollbar={false} style={{ flex: 1 }}>
        {!plan ? (
          <Empty title="正在读取计划" description={message} />
        ) : (
          <SectionList>
            <Section header="计划状态" footer={message}>
              <Cell
                title={plan.name || planId}
                subtitle="公 × 母 配对计划"
                value={
                  <Tag tone={plan.state === 'completed' ? 'success' : 'warning'}>
                    {humanShortLabel(plan.state || 'draft')}
                  </Tag>
                }
              />
              <Cell title="当前窝次" value={plan.litterId ? '已有窝次' : '尚未出生'} />
            </Section>
            <Section header="发布 / 开始配对">
              {enclosures.length ? (
                <FormRow label="配对笼舍">
                  <Picker
                    mode="selector"
                    range={enclosures.map((item) => item.label)}
                    value={enclosureIndex}
                    onChange={(event) => setEnclosureId(enclosures[Number(event.detail.value)]?.id || '')}
                  >
                    <Cell title={enclosures[enclosureIndex]?.label || '选择笼舍'} value={<Tag>选择</Tag>} />
                  </Picker>
                </FormRow>
              ) : (
                <FormRow label="配对笼舍">
                  <Cell title="还没有笼舍" subtitle="请先在系统中建笼舍" />
                </FormRow>
              )}
              <CapabilityButton capability="write_breeding" block disabled={busy} onClick={publishPlan}>
                发布计划
              </CapabilityButton>
              <CapabilityButton capability="write_breeding" block variant="outlined" disabled={busy} onClick={startPairing}>
                开始配对
              </CapabilityButton>
            </Section>
            <Section header="配对观察与孕期">
              {attempts.length ? (
                <FormRow label="配对尝试">
                  <Picker
                    mode="selector"
                    range={attemptLabels}
                    value={attemptIndex}
                    onChange={(event) => setAttemptId(attempts[Number(event.detail.value)]?.id || '')}
                  >
                    <Cell title={attemptLabels[attemptIndex] || '选择尝试'} value={<Tag>选择</Tag>} />
                  </Picker>
                </FormRow>
              ) : (
                <FormRow label="配对尝试">
                  <Cell title="还没有配对尝试" subtitle="先点「开始配对」" />
                </FormRow>
              )}
              <FormRow label="观察类型" divider>
                <Picker
                  mode="selector"
                  range={OBSERVATION_OPTIONS.map((o) => o.label)}
                  value={obsIndex}
                  onChange={(event) =>
                    setObservationType(OBSERVATION_OPTIONS[Number(event.detail.value)]?.value || 'mating_observed')
                  }
                >
                  <Cell title={OBSERVATION_OPTIONS[obsIndex]?.label || '选择'} value={<Tag>选择</Tag>} />
                </Picker>
              </FormRow>
              <FormRow label="观察备注" divider>
                <Input
                  value={observationNote}
                  placeholder="可选"
                  placeholderStyle="color: rgba(255,255,255,0.35)"
                  onInput={(event) => setObservationNote(event.detail.value)}
                  style={{ color: '#FFFFFF' }}
                />
              </FormRow>
              <CapabilityButton capability="write_breeding" block disabled={busy} onClick={recordObservation}>
                记录配对观察
              </CapabilityButton>
              <CapabilityButton capability="write_breeding" block variant="outlined" disabled={busy} onClick={startGestation}>
                开始孕期观察
              </CapabilityButton>
            </Section>
            <Section header="结束配对并分笼" footer="公、母必须去不同笼舍">
              {enclosures.length ? (
                <>
                  <FormRow label="公鼠去向">
                    <Picker
                      mode="selector"
                      range={enclosures.map((item) => item.label)}
                      value={sireDestIndex}
                      onChange={(event) =>
                        setSireDestinationEnclosureId(enclosures[Number(event.detail.value)]?.id || '')
                      }
                    >
                      <Cell title={enclosures[sireDestIndex]?.label || '选择'} value={<Tag>选择</Tag>} />
                    </Picker>
                  </FormRow>
                  <FormRow label="母鼠去向" divider>
                    <Picker
                      mode="selector"
                      range={enclosures.map((item) => item.label)}
                      value={damDestIndex}
                      onChange={(event) =>
                        setDamDestinationEnclosureId(enclosures[Number(event.detail.value)]?.id || '')
                      }
                    >
                      <Cell title={enclosures[damDestIndex]?.label || '选择'} value={<Tag>选择</Tag>} />
                    </Picker>
                  </FormRow>
                </>
              ) : (
                <FormRow label="去向笼舍">
                  <Cell title="还没有笼舍可选" />
                </FormRow>
              )}
              <FormRow label="配对结果" divider>
                <Picker
                  mode="selector"
                  range={PAIRING_RESULT_OPTIONS.map((o) => o.label)}
                  value={resultIndex}
                  onChange={(event) =>
                    setPairingResult(PAIRING_RESULT_OPTIONS[Number(event.detail.value)]?.value || 'effective')
                  }
                >
                  <Cell title={PAIRING_RESULT_OPTIONS[resultIndex]?.label || '选择'} value={<Tag>选择</Tag>} />
                </Picker>
              </FormRow>
              <CapabilityButton capability="write_breeding" block disabled={busy} onClick={separatePairing}>
                结束配对并分笼
              </CapabilityButton>
            </Section>
            <Section header="出生确认">
              <FormRow label="存活数">
                <Input
                  type="number"
                  value={birthCount}
                  placeholder="例如 6"
                  placeholderStyle="color: rgba(255,255,255,0.35)"
                  onInput={(event) => setBirthCount(event.detail.value)}
                  style={{ color: '#FFFFFF' }}
                />
              </FormRow>
              {enclosures.length ? (
                <FormRow label="出生笼舍" divider>
                  <Picker
                    mode="selector"
                    range={['不指定', ...enclosures.map((item) => item.label)]}
                    value={birthEnclosureId ? birthEncIndex + 1 : 0}
                    onChange={(event) => {
                      const i = Number(event.detail.value)
                      setBirthEnclosureId(i === 0 ? '' : enclosures[i - 1]?.id || '')
                    }}
                  >
                    <Cell
                      title={
                        birthEnclosureId
                          ? enclosures[birthEncIndex]?.label || '选择'
                          : '不指定'
                      }
                      value={<Tag>选择</Tag>}
                    />
                  </Picker>
                </FormRow>
              ) : null}
              <FormRow label="母体状态" divider>
                <Picker
                  mode="selector"
                  range={DAM_STATUS_OPTIONS.map((o) => o.label)}
                  value={damIndex}
                  onChange={(event) =>
                    setDamStatus(DAM_STATUS_OPTIONS[Number(event.detail.value)]?.value || 'stable')
                  }
                >
                  <Cell title={DAM_STATUS_OPTIONS[damIndex]?.label || '选择'} value={<Tag>选择</Tag>} />
                </Picker>
              </FormRow>
              <FormRow label="出生原因" divider>
                <Input
                  value={birthReason}
                  onInput={(event) => setBirthReason(event.detail.value)}
                  style={{ color: '#FFFFFF' }}
                />
              </FormRow>
              <CapabilityButton capability="write_breeding" block disabled={busy} onClick={confirmBirth}>
                提交出生确认
              </CapabilityButton>
            </Section>
            <Section header="收尾">
              <CapabilityButton capability="write_breeding" block variant="outlined" disabled={busy} onClick={completePlan}>
                完成繁育计划
              </CapabilityButton>
            </Section>
            <Section header="配对尝试" footer={`共 ${attempts.length} 条 · 点一条可选中`}>
              {attempts.length ? (
                attempts.map((item) => (
                  <Cell
                    key={item.id}
                    title={humanShortLabel(item.status || 'pairing')}
                    subtitle={item.startedAt || item.enclosureId || ''}
                    value={
                      <Tag tone={item.status === 'ended' ? 'success' : 'warning'}>
                        {item.id === attemptId ? '当前' : '选择'}
                      </Tag>
                    }
                    onClick={() => setAttemptId(item.id)}
                  />
                ))
              ) : (
                <Cell title="暂无配对尝试" />
              )}
            </Section>
            <View style={{ height: `${metrics.bottomSafePadding}px` }} />
          </SectionList>
        )}
      </ScrollView>
    </View>
  )
}
