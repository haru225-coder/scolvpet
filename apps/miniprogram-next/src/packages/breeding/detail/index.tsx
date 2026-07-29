import { Input, ScrollView, View } from '@tarojs/components'
import { useLoad } from '@tarojs/taro'
import { useCallback, useState } from 'react'
import { Cell, Empty, FormRow, NavBar, Section, SectionList, Tag, crayon, paperGrain, metrics } from '@scolvpet/mp-ui'

import { defaultApi, newIdempotencyKey } from '../../../api/client'
import { CapabilityButton } from '../../../components/CapabilityButton'

type PlanData = { id: string; name?: string; sireId: string; damId: string; state?: string; version?: number; activePairingAttemptId?: string | null; litterId?: string | null; plannedPairingAt?: string | null }

export default function BreedingDetailPage() {
  const [planId, setPlanId] = useState('')
  const [plan, setPlan] = useState<PlanData | null>(null)
  const [attempts, setAttempts] = useState<any[]>([])
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
      const [detail, attemptResponse] = await Promise.all([
        defaultApi.getBreedingPlan({ planId: id }),
        defaultApi.listPairingAttempts({ planId: id, limit: 30 })
      ])
      const nextPlan = detail.data as PlanData
      const nextAttempts = attemptResponse.data || []
      setPlan(nextPlan)
      setAttempts(nextAttempts)
      setAttemptId(nextPlan.activePairingAttemptId || nextAttempts[0]?.id || '')
      setMessage('状态推进由服务端按繁育不变量和笼位版本校验')
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : '繁育计划读取失败')
    }
  }, [])

  useLoad((options) => {
    const id = String(options?.id || '')
    setPlanId(id)
    if (id) void load(id)
    else setMessage('缺少繁育计划 ID')
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
    if (!plan || !enclosureId.trim()) { setMessage('请填写配对笼舍 ID'); return }
    void runAction(async () => {
      await defaultApi.startPairing({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: String(plan.version ?? 0),
        planId,
        startPairingRequest: { enclosureId: enclosureId.trim(), startedAt: new Date(), timezone: 'Asia/Taipei' }
      })
    }, '配对已开始')
  }

  function recordObservation() {
    if (!plan || !attemptId.trim()) { setMessage('请填写配对尝试 ID'); return }
    void runAction(async () => {
      await defaultApi.recordPairingObservation({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: String(plan.version ?? 0),
        attemptId: attemptId.trim(),
        recordObservationRequest: { observedAt: new Date(), type: observationType, severity: 'info', notes: observationNote.trim() || null } as any
      })
    }, '配对观察已记录')
  }

  function startGestation() {
    if (!plan || !attemptId.trim()) { setMessage('请先填写配对尝试 ID'); return }
    void runAction(async () => {
      await defaultApi.startGestationMonitoring({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: String(plan.version ?? 0),
        planId,
        startGestationRequest: { pairingAttemptId: attemptId.trim(), result: 'effective', baselineAt: new Date(), timezone: 'Asia/Taipei' }
      })
    }, '已进入孕期观察')
  }

  function separatePairing() {
    if (!plan || !attemptId.trim() || !sireDestinationEnclosureId.trim() || !damDestinationEnclosureId.trim()) {
      setMessage('请填写配对尝试 ID、公鼠去向和母鼠去向')
      return
    }
    if (sireDestinationEnclosureId.trim() === damDestinationEnclosureId.trim()) {
      setMessage('配对结束后公鼠和母鼠必须进入不同笼舍')
      return
    }
    void runAction(async () => {
      await defaultApi.separatePairing({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: String(plan.version ?? 0),
        attemptId: attemptId.trim(),
        separatePairingRequest: {
          endedAt: new Date(),
          separatedAt: new Date(),
          result: pairingResult,
          sireDestinationEnclosureId: sireDestinationEnclosureId.trim(),
          damDestinationEnclosureId: damDestinationEnclosureId.trim(),
          safetyStop: pairingResult === 'safety_stop',
          timezone: 'Asia/Taipei',
          notes: '小程序端结束配对并分笼'
        } as any
      })
    }, '配对已结束，分笼事实已记录')
  }

  function confirmBirth() {
    const count = Number(birthCount)
    if (!plan || !Number.isInteger(count) || count <= 0) { setMessage('请填写正整数出生存活数'); return }
    void runAction(async () => {
      await defaultApi.confirmBirth({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: String(plan.version ?? 0),
        planId,
        confirmBirthRequest: {
          bornAt: new Date(),
          enclosureId: birthEnclosureId.trim() || null,
          initialAliveCount: count,
          initialOtherCount: 0,
          damCondition: { status: damStatus, notes: '小程序端出生确认' },
          outcomeReason: birthReason.trim() || '出生确认',
          timezone: 'Asia/Taipei'
        } as any
      })
    }, '出生事实已确认')
  }

  function completePlan() {
    if (!plan) return
    void runAction(async () => {
      await defaultApi.completeBreedingPlan({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: String(plan.version ?? 0),
        planId,
        completeBreedingPlanRequest: { completedAt: new Date(), timezone: 'Asia/Taipei', notes: '小程序端完成计划' }
      })
    }, '繁育计划已完成')
  }

  function publishPlan() {
    if (!plan || !enclosureId.trim()) { setMessage('发布前请填写计划配对笼舍 ID'); return }
    void runAction(async () => {
      await defaultApi.publishBreedingPlan({
        idempotencyKey: newIdempotencyKey(),
        ifMatch: String(plan.version ?? 0),
        planId,
        publishBreedingPlanRequest: { plannedPairingAt: new Date(), pairingEnclosureId: enclosureId.trim(), timezone: 'Asia/Taipei' }
      })
    }, '繁育计划已发布')
  }

  return (
    <View style={{ height: '100vh', display: 'flex', flexDirection: 'column', backgroundColor: crayon.paper, backgroundImage: paperGrain }}>
      <NavBar title={plan?.name || '繁育计划详情'} back right={<Tag tone="accent">繁育</Tag>} />
      <ScrollView scrollY type="list" bounces enhanced showScrollbar={false} style={{ flex: 1 }}>
        {!plan ? <Empty title="正在读取计划" description={message} /> : (
          <SectionList>
            <Section header="计划状态" footer={message}>
              <Cell title={plan.name || planId} subtitle={`${plan.sireId} × ${plan.damId}`} value={<Tag tone={plan.state === 'completed' ? 'success' : 'warning'}>{plan.state || 'draft'}</Tag>} />
              <Cell title="当前窝次" value={plan.litterId || '尚未出生'} />
              <Cell title="版本" value={String(plan.version ?? '-')} />
            </Section>
            <Section header="发布 / 开始配对">
              <FormRow label="配对笼舍 ID"><Input value={enclosureId} placeholder="填写笼舍 ID" onInput={(event) => setEnclosureId(event.detail.value)} /></FormRow>
              <CapabilityButton capability="write_breeding" block disabled={busy} onClick={publishPlan}>发布计划</CapabilityButton>
              <CapabilityButton capability="write_breeding" block variant="outlined" disabled={busy} onClick={startPairing}>开始配对</CapabilityButton>
            </Section>
            <Section header="配对观察与孕期">
              <FormRow label="配对尝试 ID"><Input value={attemptId} placeholder="从下方记录选择或粘贴" onInput={(event) => setAttemptId(event.detail.value)} /></FormRow>
              <FormRow label="观察类型" divider><Input value={observationType} placeholder="mating_observed / no_mating" onInput={(event) => setObservationType(event.detail.value)} /></FormRow>
              <FormRow label="观察备注" divider><Input value={observationNote} placeholder="可选" onInput={(event) => setObservationNote(event.detail.value)} /></FormRow>
              <CapabilityButton capability="write_breeding" block disabled={busy} onClick={recordObservation}>记录配对观察</CapabilityButton>
              <CapabilityButton capability="write_breeding" block variant="outlined" disabled={busy} onClick={startGestation}>开始孕期观察</CapabilityButton>
            </Section>
            <Section header="结束配对并分笼" footer="服务端会原子关闭临时配对入住，并创建双方的新入住事实">
              <FormRow label="公鼠去向"><Input value={sireDestinationEnclosureId} placeholder="目标笼舍 ID" onInput={(event) => setSireDestinationEnclosureId(event.detail.value)} /></FormRow>
              <FormRow label="母鼠去向" divider><Input value={damDestinationEnclosureId} placeholder="必须与公鼠不同" onInput={(event) => setDamDestinationEnclosureId(event.detail.value)} /></FormRow>
              <FormRow label="配对结果" divider><Input value={pairingResult} placeholder="effective / uncertain / ineffective / safety_stop" onInput={(event) => setPairingResult(event.detail.value)} /></FormRow>
              <CapabilityButton capability="write_breeding" block disabled={busy} onClick={separatePairing}>结束配对并分笼</CapabilityButton>
            </Section>
            <Section header="出生确认">
              <FormRow label="存活数"><Input type="number" value={birthCount} placeholder="例如 6" onInput={(event) => setBirthCount(event.detail.value)} /></FormRow>
              <FormRow label="出生笼舍 ID" divider><Input value={birthEnclosureId} placeholder="可选" onInput={(event) => setBirthEnclosureId(event.detail.value)} /></FormRow>
              <FormRow label="母体状态" divider><Input value={damStatus} placeholder="stable / needs_observation / requires_care" onInput={(event) => setDamStatus(event.detail.value)} /></FormRow>
              <FormRow label="出生原因" divider><Input value={birthReason} onInput={(event) => setBirthReason(event.detail.value)} /></FormRow>
              <CapabilityButton capability="write_breeding" block disabled={busy} onClick={confirmBirth}>提交出生确认</CapabilityButton>
            </Section>
            <Section header="收尾">
              <CapabilityButton capability="write_breeding" block variant="outlined" disabled={busy} onClick={completePlan}>完成繁育计划</CapabilityButton>
            </Section>
            <Section header="配对尝试" footer={`共 ${attempts.length} 条`}>
              {attempts.length ? attempts.map((item) => <Cell key={item.id} title={item.id} subtitle={`${item.enclosureId} · ${item.startedAt || ''}`} value={<Tag tone={item.status === 'ended' ? 'success' : 'warning'}>{item.status || 'pairing'}</Tag>} onClick={() => setAttemptId(item.id)} />) : <Cell title="暂无配对尝试" />}
            </Section>
            <View style={{ height: `${metrics.bottomSafePadding}px` }} />
          </SectionList>
        )}
      </ScrollView>
    </View>
  )
}
